
-- SQL Script for Plastic Injection Cost and Inventory Management System

BEGIN
    CREATE DATABASE InjecPro;
END
GO

-- Switch context to the new database
USE InjecPro;
GO

-- Users Table
CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    client NVARCHAR(100),
    last_unit_cost FLOAT -- optional: can be NULL until calculated
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    password TEXT NOT NULL
);

-- Table: product_materials
CREATE TABLE product_materials (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity DECIMAL(10,4),
    unit_price DECIMAL(10,4),
    usage_type VARCHAR(20) CHECK (usage_type IN ('per_piece', 'per_units')),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Table: product_operational_costs
CREATE TABLE product_operational_costs (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    injection_ton INT,
    num_cavities INT,
    cycle_time_sec DECIMAL(10,2),
    efficiency_percent DECIMAL(5,2),
    hourly_rate DECIMAL(10,2),
    units_per_hour DECIMAL(10,2),
    cost_per_unit DECIMAL(10,4),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Table: product_cost_history
CREATE TABLE product_cost_history (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    material_cost DECIMAL(10,4),
    operational_cost DECIMAL(10,4),
    total_cost DECIMAL(10,4),
    calculated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Table: inventory
CREATE TABLE inventory (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    quantity_to_produce INT,
    estimated_hours DECIMAL(10,2),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Table: production_plans
CREATE TABLE production_plans (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    target_quantity INT,
    estimated_hours DECIMAL(10,2),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Table: production_plan_materials
CREATE TABLE production_plan_materials (
    id INT PRIMARY KEY IDENTITY(1,1),
    production_plan_id INT NOT NULL,
    material_description VARCHAR(255),
    required_quantity DECIMAL(10,4),
    FOREIGN KEY (production_plan_id) REFERENCES production_plans(id) ON DELETE CASCADE
);

-- Table: production_logs
CREATE TABLE production_logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    inventory_id INT NOT NULL,
    user_id INT NOT NULL,
    date_logged DATE DEFAULT CAST(GETDATE() AS DATE),
    quantity_produced INT,
    hours_worked DECIMAL(10,2),
    FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);