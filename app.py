from flask import Flask, request, jsonify, render_template, url_for
import pyodbc

app = Flask(__name__)

# SQL Server connection
conn_str = (
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=SrijanaPC;"
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


@app.route('/api/products/<int:product_id>/save-cost', methods=['POST'])
def save_product_cost(product_id):
    data = request.get_json()

    total_material = data.get('totalMaterialCost')
    operational_cost = data.get('operationalCost')

    # Optionally extract and save 'materials' and 'operational' fields too

    cursor.execute("""
        UPDATE products 
        SET last_unit_cost = ? 
        WHERE id = ?
    """, (total_material + operational_cost, product_id))

    conn.commit()

    return jsonify({"success": True})

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

    cursor.execute("SELECT * FROM users WHERE username=? AND password=?", (username, password))
    user = cursor.fetchone()

    if user:
        return jsonify({"success": True, "redirect": url_for('dashboard')})
    else:
        return jsonify({"success": False, "message": "Invalid username or password"}), 401

if __name__ == '__main__':
    app.run(debug=True)
