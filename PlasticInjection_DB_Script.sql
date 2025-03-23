
-- SQL Script for Plastic Injection Cost and Inventory Management System

BEGIN
    CREATE DATABASE PlasticInjectionDB;
END
GO

-- Switch context to the new database
USE PlasticInjectionDB;
GO

-- Users Table
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(50) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL -- e.g., 'admin', 'employee'
);

-- Machines Table
CREATE TABLE Machines (
    MachineID INT PRIMARY KEY IDENTITY(1,1),
    Description VARCHAR(100),
    Ton INT,
    CycleTime INT, -- in seconds
    Cavities INT,
    HourlyRate DECIMAL(10, 2),
    Efficiency DECIMAL(5, 2) -- percentage
);

-- Materials Table
CREATE TABLE Materials (
    MaterialID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100),
    Supplier VARCHAR(100),
    UnitCost DECIMAL(10, 2),
    Unit VARCHAR(20)
);

-- Inventory Table
CREATE TABLE Inventory (
    MaterialID INT PRIMARY KEY,
    QuantityInStock DECIMAL(10, 2),
    MinimumRequired DECIMAL(10, 2),
    LastUpdated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaterialID) REFERENCES Materials(MaterialID)
);

-- Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100),
    MachineID INT,
    MachineCost DECIMAL(10, 2),
    MaterialCost DECIMAL(10, 2),
    TotalCost AS (MachineCost + MaterialCost) PERSISTED,
    FOREIGN KEY (MachineID) REFERENCES Machines(MachineID)
);

-- MaterialUsage Table (Bill of Materials)
CREATE TABLE MaterialUsage (
    UsageID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    MaterialID INT,
    QuantityUsed DECIMAL(10, 4),
    CostPerPiece DECIMAL(10, 4),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (MaterialID) REFERENCES Materials(MaterialID)
);

-- ProductionLog Table
CREATE TABLE ProductionLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    QuantityProduced INT,
    EmployeeID INT,
    DateProduced DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (EmployeeID) REFERENCES Users(UserID)
);

-- Sample admin user
INSERT INTO Users (Username, PasswordHash, Role)
VALUES ('admin', 'hashed_password_placeholder', 'admin');

-- Sample machine
INSERT INTO Machines (Description, Ton, CycleTime, Cavities, HourlyRate, Efficiency)
VALUES ('Injection Molding Machine', 160, 32, 8, 95.00, 95);

-- Sample material
INSERT INTO Materials (Name, Supplier, UnitCost, Unit)
VALUES ('PP', 'Premix', 14.20, 'kg');

-- Sample inventory entry
INSERT INTO Inventory (MaterialID, QuantityInStock, MinimumRequired)
VALUES (1, 100.00, 20.00);

-- Sample product
INSERT INTO Products (Name, MachineID, MachineCost, MaterialCost)
VALUES ('Plastic Cap', 1, 0.11, 0.22);

-- Sample BOM entry
INSERT INTO MaterialUsage (ProductID, MaterialID, QuantityUsed, CostPerPiece)
VALUES (1, 1, 0.0130, 0.1846);
