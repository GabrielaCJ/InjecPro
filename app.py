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
