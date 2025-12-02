/* The following adds stored procedures */

-- MySQL Stored Procedures for Northwind Database

-- Set delimiter for procedure creation
DELIMITER $$

-- =============================================
-- Drop existing procedures if they exist
-- =============================================

DROP PROCEDURE IF EXISTS CustOrdersDetail$$
DROP PROCEDURE IF EXISTS CustOrdersOrders$$
DROP PROCEDURE IF EXISTS CustOrderHist$$
DROP PROCEDURE IF EXISTS SalesByCategory$$

-- =============================================
-- Procedure: CustOrdersDetail
-- Description: Returns detailed information about a specific order
-- =============================================

CREATE PROCEDURE CustOrdersDetail(IN OrderID_param INT)
BEGIN
    SELECT 
        P.ProductName,
        ROUND(OD.UnitPrice, 2) AS UnitPrice,
        OD.Quantity,
        CAST(OD.Discount * 100 AS SIGNED) AS Discount,
        ROUND(OD.Quantity * (1 - OD.Discount) * OD.UnitPrice, 2) AS ExtendedPrice
    FROM Products P
    INNER JOIN `Order Details` OD ON OD.ProductID = P.ProductID
    WHERE OD.OrderID = OrderID_param;
END$$

-- =============================================
-- Procedure: CustOrdersOrders
-- Description: Returns all orders for a specific customer
-- =============================================

CREATE PROCEDURE CustOrdersOrders(IN CustomerID_param VARCHAR(5))
BEGIN
    SELECT 
        OrderID,
        OrderDate,
        RequiredDate,
        ShippedDate
    FROM Orders
    WHERE CustomerID = CustomerID_param
    ORDER BY OrderID;
END$$

-- =============================================
-- Procedure: CustOrderHist
-- Description: Returns purchase history for a customer
-- =============================================

CREATE PROCEDURE CustOrderHist(IN CustomerID_param VARCHAR(5))
BEGIN
    SELECT 
        P.ProductName,
        SUM(OD.Quantity) AS Total
    FROM Products P
    INNER JOIN `Order Details` OD ON OD.ProductID = P.ProductID
    INNER JOIN Orders O ON O.OrderID = OD.OrderID
    INNER JOIN Customers C ON C.CustomerID = O.CustomerID
    WHERE C.CustomerID = CustomerID_param
    GROUP BY P.ProductName;
END$$

-- =============================================
-- Procedure: SalesByCategory
-- Description: Returns sales by category for a specific year
-- =============================================

CREATE PROCEDURE SalesByCategory(
    IN CategoryName_param VARCHAR(15),
    IN OrdYear_param VARCHAR(4)
)
BEGIN
    DECLARE year_validated VARCHAR(4);
    
    -- Validate year parameter
    IF OrdYear_param NOT IN ('1996', '1997', '1998') THEN
        SET year_validated = '1998';
    ELSE
        SET year_validated = OrdYear_param;
    END IF;
    
    SELECT 
        P.ProductName,
        ROUND(SUM(OD.Quantity * (1 - OD.Discount) * OD.UnitPrice), 0) AS TotalPurchase
    FROM `Order Details` OD
    INNER JOIN Orders O ON OD.OrderID = O.OrderID
    INNER JOIN Products P ON OD.ProductID = P.ProductID
    INNER JOIN Categories C ON P.CategoryID = C.CategoryID
    WHERE C.CategoryName = CategoryName_param
        AND YEAR(O.OrderDate) = year_validated
    GROUP BY P.ProductName
    ORDER BY P.ProductName;
END$$

-- Reset delimiter
DELIMITER ;

-- =============================================
-- Examples of how to call the procedures
-- =============================================

-- Example 1: Get details of order 10248
-- CALL CustOrdersDetail(10248);

-- Example 2: Get all orders for customer 'ALFKI'
-- CALL CustOrdersOrders('ALFKI');

-- Example 3: Get purchase history for customer 'ALFKI'
-- CALL CustOrderHist('ALFKI');

-- Example 4: Get sales by category 'Beverages' for year 1997
-- CALL SalesByCategory('Beverages', '1997');

-- Example 5: Get sales by category 'Seafood' (defaults to 1998)
-- CALL SalesByCategory('Seafood', '1999');
