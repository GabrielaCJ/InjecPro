USE [master]
GO
/****** Object:  Database [InjecPro]    Script Date: 4/22/2025 1:46:51 PM ******/
CREATE DATABASE [InjecPro]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'InjecPro', FILENAME = N'C:\Program Files\2019\MSSQL15.MSSQLSERVER02\MSSQL\DATA\InjecPro.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'InjecPro_log', FILENAME = N'C:\Program Files\2019\MSSQL15.MSSQLSERVER02\MSSQL\DATA\InjecPro_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [InjecPro] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [InjecPro].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [InjecPro] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [InjecPro] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [InjecPro] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [InjecPro] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [InjecPro] SET ARITHABORT OFF 
GO
ALTER DATABASE [InjecPro] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [InjecPro] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [InjecPro] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [InjecPro] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [InjecPro] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [InjecPro] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [InjecPro] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [InjecPro] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [InjecPro] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [InjecPro] SET  ENABLE_BROKER 
GO
ALTER DATABASE [InjecPro] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [InjecPro] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [InjecPro] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [InjecPro] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [InjecPro] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [InjecPro] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [InjecPro] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [InjecPro] SET RECOVERY FULL 
GO
ALTER DATABASE [InjecPro] SET  MULTI_USER 
GO
ALTER DATABASE [InjecPro] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [InjecPro] SET DB_CHAINING OFF 
GO
ALTER DATABASE [InjecPro] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [InjecPro] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [InjecPro] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [InjecPro] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'InjecPro', N'ON'
GO
ALTER DATABASE [InjecPro] SET QUERY_STORE = OFF
GO
USE [InjecPro]
GO
/****** Object:  Table [dbo].[inventory]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[inventory](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[quantity_to_produce] [int] NULL,
	[estimated_hours] [decimal](10, 2) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[product_cost_history]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product_cost_history](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[material_cost] [decimal](10, 4) NULL,
	[operational_cost] [decimal](10, 4) NULL,
	[total_cost] [decimal](10, 4) NULL,
	[calculated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[product_materials]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product_materials](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[description] [varchar](255) NOT NULL,
	[quantity] [decimal](10, 4) NULL,
	[unit_price] [decimal](10, 4) NULL,
	[usage_type] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[product_operational_costs]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product_operational_costs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[injection_ton] [int] NULL,
	[num_cavities] [int] NULL,
	[cycle_time_sec] [decimal](10, 2) NULL,
	[efficiency_percent] [decimal](5, 2) NULL,
	[hourly_rate] [decimal](10, 2) NULL,
	[units_per_hour] [decimal](10, 2) NULL,
	[cost_per_unit] [decimal](10, 4) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[production_logs]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[production_logs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[inventory_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[date_logged] [date] NULL,
	[quantity_produced] [int] NULL,
	[hours_worked] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[production_plan_materials]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[production_plan_materials](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[production_plan_id] [int] NOT NULL,
	[material_description] [varchar](255) NULL,
	[required_quantity] [decimal](10, 4) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[production_plans]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[production_plans](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[target_quantity] [int] NULL,
	[estimated_hours] [decimal](10, 2) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[products]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[products](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[client] [nvarchar](100) NULL,
	[last_unit_cost] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[users]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](255) NULL,
	[password] [nvarchar](100) NULL,
	[role] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[product_cost_history] ADD  DEFAULT (getdate()) FOR [calculated_at]
GO
ALTER TABLE [dbo].[production_logs] ADD  DEFAULT (CONVERT([date],getdate())) FOR [date_logged]
GO
ALTER TABLE [dbo].[production_plans] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[product_cost_history]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[product_materials]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[product_operational_costs]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[production_logs]  WITH CHECK ADD FOREIGN KEY([inventory_id])
REFERENCES [dbo].[inventory] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[production_logs]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[production_plan_materials]  WITH CHECK ADD FOREIGN KEY([production_plan_id])
REFERENCES [dbo].[production_plans] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[production_plans]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[product_materials]  WITH CHECK ADD CHECK  (([usage_type]='per_units' OR [usage_type]='per_piece'))
GO
/****** Object:  StoredProcedure [dbo].[CreateProductionPlan]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[CreateProductionPlan]
    @ProductID INT,
    @Quantity INT,
    @EstimatedHours FLOAT,
    @PlanID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO production_plans (product_id, target_quantity, estimated_hours, created_at)
    VALUES (@ProductID, @Quantity, @EstimatedHours, GETDATE());

    SET @PlanID = SCOPE_IDENTITY();
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteProductionPlan]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[DeleteProductionPlan]
    @InventoryID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete related production logs
    DELETE FROM production_logs WHERE inventory_id = @InventoryID;

    -- Delete the inventory plan itself
    DELETE FROM inventory WHERE id = @InventoryID;
END
GO
/****** Object:  StoredProcedure [dbo].[GetAllProductsWithCost]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GetAllProductsWithCost]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, name, client, last_unit_cost 
    FROM products
    WHERE last_unit_cost IS NOT NULL AND last_unit_cost > 0;
END

GO
/****** Object:  StoredProcedure [dbo].[GetProductionSummary]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GetProductionSummary]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        i.id AS inventory_id,
        p.name AS product,
        p.client,
        i.quantity_to_produce AS planned_qty,
        i.estimated_hours AS planned_hours,
        i.created_at,
        ISNULL(SUM(pl.quantity_produced), 0) AS produced_qty,
        ISNULL(SUM(pl.hours_worked), 0) AS worked_hours,
        (i.quantity_to_produce - ISNULL(SUM(pl.quantity_produced), 0)) AS remaining_qty,
        CASE 
            WHEN ISNULL(SUM(pl.quantity_produced), 0) >= i.quantity_to_produce THEN 'Completed'
            ELSE 'In Progress'
        END AS status
    FROM inventory i
    JOIN products p ON i.product_id = p.id
    LEFT JOIN production_logs pl ON pl.inventory_id = i.id
    GROUP BY 
        i.id, p.name, p.client, i.quantity_to_produce, i.estimated_hours, i.created_at
    ORDER BY i.created_at DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetUserLoginDetails]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GetUserLoginDetails]
    @Username NVARCHAR(100)
AS
BEGIN
    SELECT id, username, password, role
    FROM users
    WHERE username = @Username
END
GO
/****** Object:  StoredProcedure [dbo].[LogProductionEntry]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[LogProductionEntry]
    @PlanID INT,
    @Quantity INT,
    @Hours FLOAT,
    @UserID INT = 1  -- Optional: default user
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @InventoryID INT;

    -- Get product_id from the plan
    SELECT @ProductID = product_id
    FROM production_plans
    WHERE id = @PlanID;

    IF @ProductID IS NULL
    BEGIN
        RAISERROR('Plan not found.', 16, 1);
        RETURN;
    END

    -- Get latest inventory ID for this product
    SELECT TOP 1 @InventoryID = id
    FROM inventory
    WHERE product_id = @ProductID
    ORDER BY created_at DESC;

    IF @InventoryID IS NULL
    BEGIN
        RAISERROR('Inventory not found.', 16, 1);
        RETURN;
    END

    -- Insert production log
    INSERT INTO production_logs (inventory_id, user_id, date_logged, quantity_produced, hours_worked)
    VALUES (@InventoryID, @UserID, GETDATE(), @Quantity, @Hours);
END
GO
/****** Object:  StoredProcedure [dbo].[RegisterUser]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[RegisterUser]
    @Username NVARCHAR(100),
    @PasswordHash NVARCHAR(100),
    @Role NVARCHAR(50)
AS
BEGIN
    -- Check if username already exists
    IF EXISTS (SELECT 1 FROM users WHERE username = @Username)
    BEGIN
        RAISERROR('Username already exists.', 16, 1)
        RETURN
    END

    -- Insert the new user
    INSERT INTO users (username, password, role)
    VALUES (@Username, @PasswordHash, @Role)
END
GO
/****** Object:  StoredProcedure [dbo].[SaveOperationalCostAndHistory]    Script Date: 4/22/2025 1:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[SaveOperationalCostAndHistory]
    @ProductID INT,
    @InjectionTon FLOAT,
    @NumCavities INT,
    @CycleTimeSec FLOAT,
    @EfficiencyPercent FLOAT,
    @HourlyRate FLOAT,
    @TotalMaterial FLOAT,
    @OperationalCost FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitsPerHour FLOAT, @CostPerUnit FLOAT;

    -- Safe fallback values
    IF @CycleTimeSec = 0 SET @CycleTimeSec = 1;
    IF @NumCavities = 0 SET @NumCavities = 1;
    IF @EfficiencyPercent = 0 SET @EfficiencyPercent = 100;

    SET @UnitsPerHour = (3600.0 / @CycleTimeSec) * @NumCavities;
    SET @CostPerUnit = (@HourlyRate / @UnitsPerHour) / (@EfficiencyPercent / 100.0);

    -- Remove old operational costs
    DELETE FROM product_operational_costs WHERE product_id = @ProductID;

    -- Insert new operational cost
    INSERT INTO product_operational_costs 
    (product_id, injection_ton, num_cavities, cycle_time_sec, efficiency_percent, hourly_rate, units_per_hour, cost_per_unit)
    VALUES (@ProductID, @InjectionTon, @NumCavities, @CycleTimeSec, @EfficiencyPercent, @HourlyRate, @UnitsPerHour, @CostPerUnit);

    -- Insert history
    INSERT INTO product_cost_history (product_id, material_cost, operational_cost, total_cost)
    VALUES (@ProductID, @TotalMaterial, @OperationalCost, @TotalMaterial + @OperationalCost);

    -- Update last unit cost
    UPDATE products
    SET last_unit_cost = @TotalMaterial + @OperationalCost
    WHERE id = @ProductID;
END
GO
USE [master]
GO
ALTER DATABASE [InjecPro] SET  READ_WRITE 
GO
