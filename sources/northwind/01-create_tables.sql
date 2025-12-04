-- =============================================
-- TABELAS
-- =============================================
USE northwind;


-- Tabela: Categories
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(15) NOT NULL,
    Description TEXT,
    Picture LONGBLOB
) ENGINE=InnoDB;

-- Tabela: Customers
CREATE TABLE Customers (
    CustomerID VARCHAR(5) PRIMARY KEY,
    CompanyName VARCHAR(40) NOT NULL,
    ContactName VARCHAR(30),
    ContactTitle VARCHAR(30),
    Address VARCHAR(60),
    City VARCHAR(15),
    Region VARCHAR(15),
    PostalCode VARCHAR(10),
    Country VARCHAR(15),
    Phone VARCHAR(24),
    Fax VARCHAR(24)
) ENGINE=InnoDB;

-- Tabela: Employees
CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    LastName VARCHAR(20) NOT NULL,
    FirstName VARCHAR(10) NOT NULL,
    Title VARCHAR(30),
    TitleOfCourtesy VARCHAR(25),
    BirthDate DATETIME,
    HireDate DATETIME,
    Address VARCHAR(60),
    City VARCHAR(15),
    Region VARCHAR(15),
    PostalCode VARCHAR(10),
    Country VARCHAR(15),
    HomePhone VARCHAR(24),
    Extension VARCHAR(4),
    Photo LONGBLOB,
    Notes TEXT,
    ReportsTo INT,
    PhotoPath VARCHAR(255),
    CONSTRAINT FK_Employees_Employees FOREIGN KEY (ReportsTo) 
        REFERENCES Employees(EmployeeID)
) ENGINE=InnoDB;

-- Tabela: Shippers
CREATE TABLE Shippers (
    ShipperID INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(40) NOT NULL,
    Phone VARCHAR(24)
) ENGINE=InnoDB;

-- Tabela: Suppliers
CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(40) NOT NULL,
    ContactName VARCHAR(30),
    ContactTitle VARCHAR(30),
    Address VARCHAR(60),
    City VARCHAR(15),
    Region VARCHAR(15),
    PostalCode VARCHAR(10),
    Country VARCHAR(15),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    HomePage TEXT
) ENGINE=InnoDB;

-- Tabela: Products
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(40) NOT NULL,
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(20),
    UnitPrice DECIMAL(10,2) DEFAULT 0,
    UnitsInStock SMALLINT DEFAULT 0,
    UnitsOnOrder SMALLINT DEFAULT 0,
    ReorderLevel SMALLINT DEFAULT 0,
    Discontinued TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) 
        REFERENCES Categories(CategoryID),
    CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierID) 
        REFERENCES Suppliers(SupplierID)
) ENGINE=InnoDB;

-- Tabela: Orders
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID VARCHAR(5),
    EmployeeID INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia INT,
    Freight DECIMAL(10,2) DEFAULT 0,
    ShipName VARCHAR(40),
    ShipAddress VARCHAR(60),
    ShipCity VARCHAR(15),
    ShipRegion VARCHAR(15),
    ShipPostalCode VARCHAR(10),
    ShipCountry VARCHAR(15),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) 
        REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Orders_Employees FOREIGN KEY (EmployeeID) 
        REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_Orders_Shippers FOREIGN KEY (ShipVia) 
        REFERENCES Shippers(ShipperID)
) ENGINE=InnoDB;

-- Tabela: Order Details
CREATE TABLE `Order Details` (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL DEFAULT 0,
    Quantity SMALLINT NOT NULL DEFAULT 1,
    Discount DECIMAL(4,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID) 
        REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) 
        REFERENCES Products(ProductID),
    CONSTRAINT CHK_Discount CHECK (Discount >= 0 AND Discount <= 1),
    CONSTRAINT CHK_Quantity CHECK (Quantity > 0),
    CONSTRAINT CHK_UnitPrice CHECK (UnitPrice >= 0)
) ENGINE=InnoDB;

-- Tabela: Region
CREATE TABLE Region (
    RegionID INT PRIMARY KEY,
    RegionDescription VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Tabela: Territories
CREATE TABLE Territories (
    TerritoryID VARCHAR(20) PRIMARY KEY,
    TerritoryDescription VARCHAR(50) NOT NULL,
    RegionID INT NOT NULL,
    CONSTRAINT FK_Territories_Region FOREIGN KEY (RegionID) 
        REFERENCES Region(RegionID)
) ENGINE=InnoDB;

-- Tabela: EmployeeTerritories
CREATE TABLE EmployeeTerritories (
    EmployeeID INT NOT NULL,
    TerritoryID VARCHAR(20) NOT NULL,
    PRIMARY KEY (EmployeeID, TerritoryID),
    CONSTRAINT FK_EmployeeTerritories_Employees FOREIGN KEY (EmployeeID) 
        REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_EmployeeTerritories_Territories FOREIGN KEY (TerritoryID) 
        REFERENCES Territories(TerritoryID)
) ENGINE=InnoDB;

-- =============================================
-- ÍNDICES
-- =============================================

CREATE INDEX idx_CategoryName ON Categories(CategoryName);
CREATE INDEX idx_City ON Customers(City);
CREATE INDEX idx_CompanyName ON Customers(CompanyName);
CREATE INDEX idx_PostalCode ON Customers(PostalCode);
CREATE INDEX idx_Region ON Customers(Region);
CREATE INDEX idx_LastName ON Employees(LastName);
CREATE INDEX idx_PostalCodeEmp ON Employees(PostalCode);
CREATE INDEX idx_OrderDate ON Orders(OrderDate);
CREATE INDEX idx_ShippedDate ON Orders(ShippedDate);
CREATE INDEX idx_ShipPostalCode ON Orders(ShipPostalCode);
CREATE INDEX idx_ProductName ON Products(ProductName);

-- =============================================
-- VIEWS
-- =============================================

-- View: Alphabetical list of products
CREATE VIEW `Alphabetical list of products` AS
SELECT Products.*, Categories.CategoryName
FROM Categories 
INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued = 0;

-- View: Current Product List
CREATE VIEW `Current Product List` AS
SELECT ProductID, ProductName
FROM Products
WHERE Discontinued = 0;

-- View: Customer and Suppliers by City
CREATE VIEW `Customer and Suppliers by City` AS
SELECT City, CompanyName, ContactName, 'Customers' AS Relationship
FROM Customers
UNION
SELECT City, CompanyName, ContactName, 'Suppliers'
FROM Suppliers;

-- View: Invoices
CREATE VIEW Invoices AS
SELECT Orders.ShipName, Orders.ShipAddress, Orders.ShipCity, 
       Orders.ShipRegion, Orders.ShipPostalCode, Orders.ShipCountry,
       Orders.CustomerID, Customers.CompanyName AS CustomerName,
       Customers.Address, Customers.City, Customers.Region,
       Customers.PostalCode, Customers.Country,
       CONCAT(Employees.FirstName, ' ', Employees.LastName) AS Salesperson,
       Orders.OrderID, Orders.OrderDate, Orders.RequiredDate,
       Orders.ShippedDate, Shippers.CompanyName AS ShipperName,
       `Order Details`.ProductID, Products.ProductName,
       `Order Details`.UnitPrice, `Order Details`.Quantity,
       `Order Details`.Discount,
       `Order Details`.UnitPrice * `Order Details`.Quantity * (1 - `Order Details`.Discount) AS ExtendedPrice,
       Orders.Freight
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Employees ON Employees.EmployeeID = Orders.EmployeeID
INNER JOIN `Order Details` ON Orders.OrderID = `Order Details`.OrderID
INNER JOIN Products ON Products.ProductID = `Order Details`.ProductID
INNER JOIN Shippers ON Shippers.ShipperID = Orders.ShipVia;

-- View: Order Details Extended
CREATE VIEW `Order Details Extended` AS
SELECT `Order Details`.OrderID, `Order Details`.ProductID,
       Products.ProductName, `Order Details`.UnitPrice,
       `Order Details`.Quantity, `Order Details`.Discount,
       `Order Details`.UnitPrice * `Order Details`.Quantity * (1 - `Order Details`.Discount) AS ExtendedPrice
FROM Products
INNER JOIN `Order Details` ON Products.ProductID = `Order Details`.ProductID;

-- View: Order Subtotals
CREATE VIEW `Order Subtotals` AS
SELECT OrderID, SUM(UnitPrice * Quantity * (1 - Discount)) AS Subtotal
FROM `Order Details`
GROUP BY OrderID;

-- View: Product Sales for 1997
CREATE VIEW `Product Sales for 1997` AS
SELECT Categories.CategoryName, Products.ProductName,
       SUM(`Order Details`.UnitPrice * `Order Details`.Quantity * (1 - `Order Details`.Discount)) AS ProductSales
FROM Categories
INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
INNER JOIN `Order Details` ON Products.ProductID = `Order Details`.ProductID
INNER JOIN Orders ON Orders.OrderID = `Order Details`.OrderID
WHERE Orders.ShippedDate BETWEEN '1997-01-01' AND '1997-12-31'
GROUP BY Categories.CategoryName, Products.ProductName;

-- View: Products Above Average Price
CREATE VIEW `Products Above Average Price` AS
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products);

-- View: Products by Category
CREATE VIEW `Products by Category` AS
SELECT Categories.CategoryName, Products.ProductName,
       Products.QuantityPerUnit, Products.UnitsInStock,
       Products.Discontinued
FROM Categories
INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued = 0;

-- View: Quarterly Orders
CREATE VIEW `Quarterly Orders` AS
SELECT DISTINCT Customers.CustomerID, Customers.CompanyName,
       Customers.City, Customers.Country
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.OrderDate BETWEEN '1997-01-01' AND '1997-12-31';

-- View: Sales by Category
CREATE VIEW `Sales by Category` AS
SELECT Categories.CategoryID, Categories.CategoryName,
       Products.ProductName,
       SUM(`Order Details`.UnitPrice * `Order Details`.Quantity * (1 - `Order Details`.Discount)) AS ProductSales
FROM Categories
INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
INNER JOIN `Order Details` ON Products.ProductID = `Order Details`.ProductID
INNER JOIN Orders ON Orders.OrderID = `Order Details`.OrderID
WHERE Orders.OrderDate BETWEEN '1997-01-01' AND '1997-12-31'
GROUP BY Categories.CategoryID, Categories.CategoryName, Products.ProductName;

-- View: Sales Totals by Amount
CREATE VIEW `Sales Totals by Amount` AS
SELECT `Order Subtotals`.Subtotal AS SaleAmount,
       Orders.OrderID, Customers.CompanyName, Orders.ShippedDate
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN `Order Subtotals` ON Orders.OrderID = `Order Subtotals`.OrderID
WHERE `Order Subtotals`.Subtotal > 2500
  AND Orders.ShippedDate BETWEEN '1997-01-01' AND '1997-12-31';

-- View: Summary of Sales by Quarter
CREATE VIEW `Summary of Sales by Quarter` AS
SELECT Orders.ShippedDate, Orders.OrderID,
       `Order Subtotals`.Subtotal
FROM Orders
INNER JOIN `Order Subtotals` ON Orders.OrderID = `Order Subtotals`.OrderID
WHERE Orders.ShippedDate IS NOT NULL;

-- View: Summary of Sales by Year
CREATE VIEW `Summary of Sales by Year` AS
SELECT Orders.ShippedDate, Orders.OrderID,
       `Order Subtotals`.Subtotal
FROM Orders
INNER JOIN `Order Subtotals` ON Orders.OrderID = `Order Subtotals`.OrderID
WHERE Orders.ShippedDate IS NOT NULL;
