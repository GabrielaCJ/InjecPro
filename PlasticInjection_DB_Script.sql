
-- SQL Script for Plastic Injection Cost and Inventory Management System

BEGIN
    CREATE DATABASE PlasticInjectionDB;
END
GO

-- Switch context to the new database
USE PlasticInjectionDB;
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
