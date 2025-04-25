from flask import Flask, request, jsonify, render_template, url_for
import pyodbc
from datetime import datetime


app = Flask(__name__)

# SQL Server connection
conn_str = (
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=DESKTOP-5QMBS32;"
    "Database=InjecPro;"
    "Trusted_Connection=yes;"
)

conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Route: Login Page
@app.route('/')
def login_page():
    return render_template("login.html")

# Route: Dashboard Page
@app.route('/dashboard')
def dashboard():
    return render_template("dashboard.html")

@app.route('/productinfo')
def product_info():
    return render_template('productinfo.html')

@app.route('/add-product')
def add_product():
    return render_template('addproduct.html')


@app.route('/api/add-product', methods=['POST'])
def api_add_product():
    data = request.get_json()
    name = data.get('productName')
    client = data.get('client')

    cursor.execute("INSERT INTO products (name, client) OUTPUT INSERTED.id VALUES (?, ?)", (name, client))
    new_id = cursor.fetchone()[0]
    conn.commit()

    return jsonify({"success": True, "productId": new_id})


@app.route('/cost-calculator')
def cost_calculator():
    return render_template('cost_calculator.html')


@app.route('/api/products/<int:product_id>/load-cost', methods=['GET'])
def load_product_cost(product_id):
    cursor.execute("SELECT * FROM product_materials WHERE product_id = ?", product_id)
    materials = [
        {
            "description": row.description,
            "quantity": float(row.quantity),
            "unitPrice": float(row.unit_price),
            "usageType": row.usage_type,
            "unitCost": float(row.unit_cost_per_piece)
        } for row in cursor.fetchall()
    ]

    cursor.execute("SELECT * FROM product_operational_costs WHERE product_id = ?", product_id)
    op_row = cursor.fetchone()
    operational = {}
    if op_row:
        operational = {
            "injTon": op_row.injection_ton,
            "numCav": op_row.num_cavities,
            "cycle": op_row.cycle_time_sec,
            "efficiency": op_row.efficiency_percent,
            "rate": op_row.hourly_rate
        }

    return jsonify({"materials": materials, "operational": operational})

@app.route('/api/products/<int:product_id>/save-cost', methods=['POST'])
def save_product_cost(product_id):
    try:
        data = request.get_json()
        print("🔧 Payload received:", data)

        total_material = data.get('totalMaterialCost')
        operational_cost = data.get('operationalCost')
        materials = data.get('materials', [])
        operational = data.get('operational', {})

        cursor.execute("DELETE FROM product_materials WHERE product_id = ?", product_id)
        for material in materials:
            cursor.execute("""
                INSERT INTO product_materials (product_id, description, quantity, unit_price, usage_type, unit_cost_per_piece)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                product_id,
                material['description'],
                material['quantity'],
                material['unitPrice'],
                material['usageType'],
                material['unitCost']  # ✅ Make sure this field exists in the payload
            ))

        cursor.execute("DELETE FROM product_operational_costs WHERE product_id = ?", product_id)

        # Calculate units/hour and cost/unit
        cycle = operational.get('cycle') or 1
        cavities = operational.get('numCav') or 1
        efficiency = operational.get('efficiency') or 100
        rate = operational.get('rate') or 0

        units_per_hour = (3600 / cycle) * cavities
        cost_per_unit = (rate / units_per_hour) / (efficiency / 100)

        cursor.execute("""
            INSERT INTO product_operational_costs 
            (product_id, injection_ton, num_cavities, cycle_time_sec, efficiency_percent, hourly_rate, units_per_hour, cost_per_unit)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            product_id,
            operational.get('injTon'),
            cavities,
            cycle,
            efficiency,
            rate,
            units_per_hour,
            cost_per_unit
        ))

        cursor.execute("""
            INSERT INTO product_cost_history (product_id, material_cost, operational_cost, total_cost)
            VALUES (?, ?, ?, ?)
        """, (
            product_id,
            total_material,
            operational_cost,
            total_material + operational_cost
        ))

        cursor.execute("""
            UPDATE products 
            SET last_unit_cost = ? 
            WHERE id = ?
        """, (total_material + operational_cost, product_id))

        conn.commit()
        return jsonify({"success": True})
    
    except Exception as e:
        print("❌ ERROR during save:", str(e))
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/planner/<int:product_id>', methods=['GET'])
def planner_fetch(product_id):
    cursor.execute("SELECT description, quantity, usage_type FROM product_materials WHERE product_id = ?", product_id)
    materials = cursor.fetchall()

    cursor.execute("SELECT units_per_hour FROM product_operational_costs WHERE product_id = ?", product_id)
    op = cursor.fetchone()

    return jsonify({
        "materials": [
            {"description": row.description, "quantity": float(row.quantity), "usageType": row.usage_type} for row in materials
        ],
        "unitsPerHour": float(op.units_per_hour) if op else 0
    })

@app.route('/api/inventory/add', methods=['POST'])
def planner_save():
    data = request.get_json()
    product_id = data.get('product_id')
    quantity = data.get('quantity_to_produce')
    hours = data.get('estimated_hours')
    materials = data.get('materials')

    cursor.execute("""
        INSERT INTO production_plans (product_id, target_quantity, estimated_hours, created_at)
        OUTPUT INSERTED.id
        VALUES (?, ?, ?, ?)
    """, (product_id, quantity, hours, datetime.now()))

    plan_id = cursor.fetchone()[0]

    for mat in materials:
        cursor.execute("""
            INSERT INTO production_plan_materials (production_plan_id, material_description, required_quantity)
            VALUES (?, ?, ?)
        """, (plan_id, mat['description'], mat['quantity']))

    cursor.execute("""
        INSERT INTO inventory (product_id, quantity_to_produce, estimated_hours, created_at)
        VALUES (?, ?, ?, ?)
    """, (product_id, quantity, hours, datetime.now()))

    conn.commit()
    return jsonify({"success": True})

@app.route('/api/production-summary', methods=['GET'])
def production_summary():
    cursor.execute("""
        SELECT 
            i.id AS inventory_id,
            p.name AS product,
            p.client,
            i.quantity_to_produce,
            i.estimated_hours,
            i.created_at
        FROM inventory i
        JOIN products p ON i.product_id = p.id
        ORDER BY i.created_at DESC
    """)
    inventories = cursor.fetchall()

    summary = []
    for inv in inventories:
        cursor.execute("""
            SELECT 
                ISNULL(SUM(quantity_produced), 0) AS total_qty,
                ISNULL(SUM(hours_worked), 0) AS total_hours
            FROM production_logs
            WHERE inventory_id = ?
        """, inv.inventory_id)
        logs = cursor.fetchone()

        produced = logs.total_qty
        worked = logs.total_hours
        remaining = inv.quantity_to_produce - produced

        summary.append({
            "inventory_id": inv.inventory_id,
            "product": inv.product,
            "client": inv.client,
            "planned_qty": inv.quantity_to_produce,
            "produced_qty": produced,
            "remaining_qty": max(remaining, 0),
            "planned_hours": inv.estimated_hours,
            "worked_hours": worked,
            "status": "Completed" if produced >= inv.quantity_to_produce else "In Progress"
        })

    return jsonify(summary)

@app.route('/api/inventory-log', methods=['POST'])
def log_production():
    try:
        data = request.get_json()
        print("📥 Production log received:", data)

        inventory_id = int(data.get('inventory_id'))  # 🛠️ This needs to match your payload key
        quantity = int(data.get('quantity'))
        hours = float(data.get('hours'))
        user_id = 1006  # Temporary hardcoded user

        cursor.execute("""
            INSERT INTO production_logs (inventory_id, user_id, date_logged, quantity_produced, hours_worked)
            VALUES (?, ?, GETDATE(), ?, ?)
        """, (inventory_id, user_id, quantity, hours))

        conn.commit()
        return jsonify({"success": True})
    except Exception as e:
        print("❌ Production Log Error:", e)
        return jsonify({"success": False, "message": str(e)}), 500

@app.route('/api/delete-plan/<int:inventory_id>', methods=['DELETE'])
def delete_production_plan(inventory_id):
    try:
        cursor.execute("DELETE FROM production_logs WHERE inventory_id = ?", inventory_id)
        cursor.execute("DELETE FROM inventory WHERE id = ?", inventory_id)
        conn.commit()
        return jsonify({"success": True})
    except Exception as e:
        print("❌ Deletion Error:", e)
        return jsonify({"success": False, "message": str(e)}), 500

@app.route('/api/products', methods=['GET'])
def get_products():
    cursor.execute("""
        SELECT id, name, client, last_unit_cost 
        FROM products 
        WHERE last_unit_cost IS NOT NULL AND last_unit_cost > 0
    """)
    rows = cursor.fetchall()

    products = []
    for row in rows:
        products.append({
            "id": row.id,
            "name": row.name,
            "client": row.client,
            "cost": row.last_unit_cost
        })

    return jsonify(products)


@app.route('/inventory')
def inventory():
    return render_template('inventory.html')


@app.route('/planner')
def production_planner():
    return render_template('planner.html')


# Login API
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    cursor.execute("SELECT id, username, role FROM users WHERE username=? AND password=?", (username, password))
    user = cursor.fetchone()

    if user:
        return jsonify({
            "success": True,
            "redirect": url_for('dashboard'),
            "role": user.role  # ✅ send role to frontend
        })
    else:
        return jsonify({"success": False, "message": "Invalid username or password"}), 401


if __name__ == '__main__':
    app.run(debug=True)