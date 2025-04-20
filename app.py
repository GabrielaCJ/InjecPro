from flask import Flask, request, jsonify, render_template, url_for
import pyodbc
from datetime import datetime
import bcrypt


app = Flask(__name__)

# SQL Server connection
conn_str = "Driver={ODBC Driver 17 for SQL Server};Server=SRIJANAPC\\MSSQLSERVER02;Database=InjecPro;Trusted_Connection=yes;Encrypt=no;TrustServerCertificate=yes;"


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

        # Delete & insert updated materials
        cursor.execute("DELETE FROM product_materials WHERE product_id = ?", product_id)
        for material in materials:
            cursor.execute("""
                INSERT INTO product_materials 
                (product_id, description, quantity, unit_price, usage_type, unit_cost_per_piece)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                product_id,
                material['description'],
                material['quantity'],
                material['unitPrice'],
                material['usageType'],
                material['unitCost']
            ))

        # Now call the stored procedure to handle operational + history
        cursor.execute("""
            EXEC SaveOperationalCostAndHistory 
                ?, ?, ?, ?, ?, ?, ?, ?
        """, (
            product_id,
            operational.get('injTon'),
            operational.get('numCav') or 1,
            operational.get('cycle') or 1,
            operational.get('efficiency') or 100,
            operational.get('rate') or 0,
            total_material,
            operational_cost
        ))

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
    try:
        cursor.execute("EXEC GetProductionSummary")
        rows = cursor.fetchall()

        summary = []
        for row in rows:
            summary.append({
                "inventory_id": row.inventory_id,
                "product": row.product,
                "client": row.client,
                "planned_qty": row.planned_qty,
                "produced_qty": row.produced_qty,
                "remaining_qty": max(row.remaining_qty, 0),
                "planned_hours": row.planned_hours,
                "worked_hours": row.worked_hours,
                "status": row.status
            })

        return jsonify(summary)

    except Exception as e:
        print(" Production Summary Error:", e)
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/inventory-log', methods=['POST'])
def log_production():
    try:
        data = request.get_json()
        print("📥 Production log received:", data)

        plan_id = int(data.get('plan_id'))
        quantity = int(data.get('quantity'))
        hours = float(data.get('hours'))
        user_id = 1  # placeholder or get from session/token later

        cursor.execute("EXEC LogProductionEntry ?, ?, ?, ?", (plan_id, quantity, hours, user_id))
        conn.commit()

        return jsonify({"success": True})

    except pyodbc.Error as e:
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


@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    # Use stored procedure to get user info
    cursor.execute("EXEC GetUserLoginDetails ?", (username,))
    user = cursor.fetchone()

    if user:
        stored_hash = user[2]  # password column

        if bcrypt.checkpw(password.encode(), stored_hash.encode()):
            return jsonify({
                "success": True,
                "redirect": url_for('dashboard'),
                "role": user[3]  # role column
            })

    return jsonify({"success": False, "message": "Invalid credentials"}), 401


@app.route('/signup')
def signup_page():
    return render_template('signup.html')


@app.route('/api/signup', methods=['POST'])
def signup():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    role = data.get('role')

    if not username or not password or not role:
        return jsonify({"success": False, "message": "All fields are required."})

    # Hash the password
    hashed_pw = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

    try:
        cursor.execute("EXEC RegisterUser ?, ?, ?", (username, hashed_pw, role))
        conn.commit()
        return jsonify({"success": True})
    
    except pyodbc.Error as e:
        error_msg = str(e)
        if "Username already exists" in error_msg:
            return jsonify({"success": False, "message": "Username already exists."})
        return jsonify({"success": False, "message": "Signup failed. Try again."})



if __name__ == '__main__':
    app.run(debug=True)