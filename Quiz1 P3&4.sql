USE AdventureWorks2008R2;
/*3*/
SELECT CustomerID,
    COUNT(DISTINCT p.ProductID) AS "unique products",
    COUNT(DISTINCT 
        CASE WHEN Color IS NOT NULL 
             THEN Color END) AS "unique colors",
        MAX(TotalDue) AS "highest order value"
FROM Sales.SalesOrderHeader soh
JOIN sales.SalesOrderDetail sod
ON soh.SalesOrderID =sod.SalesOrderID
JOIN Production.Product p 
ON p.ProductID = sod.ProductID
where TotalDue >128000 AND soh.SalesOrderID >0
GROUP BY CustomerID, Color, TotalDue
Order By CustomerID


/*4*/
WITH large_orders AS (
    SELECT 
        City,
        StateProvinceID,
        COUNT(*) AS large_order_count
    FROM Sales.SalesOrderHeader AS soh
    JOIN Person.Address AS a
        ON soh.ShipToAddressID = a.AddressID
    WHERE TotalDue > 50000
    GROUP BY City, StateProvinceID
),
small_orders AS (
    SELECT 
        City,
        StateProvinceID,
        COUNT(*) AS small_order_count
    FROM Sales.SalesOrderHeader AS soh
    JOIN Person.Address AS a
        ON soh.ShipToAddressID = a.AddressID
    WHERE TotalDue < 1000
    GROUP BY City, StateProvinceID
)
SELECT
    large_orders.City,
    large_orders.StateProvinceID
FROM large_orders
JOIN small_orders
    ON large_orders.City = small_orders.City
    AND large_orders.StateProvinceID = small_orders.StateProvinceID
WHERE 
    large_orders.large_order_count <= 10 AND 
    small_orders.small_order_count <= 10
ORDER BY City;