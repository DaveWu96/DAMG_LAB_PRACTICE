
USE AdventureWorks2008R2;
/*Problem 1*/
SELECT SalesPersonID, p.LastName, p.FirstName,
 COUNT(SalesOrderid) AS "Total Orders", CASE
WHEN COUNT(SalesOrderid)>=0 AND COUNT(SalesOrderid)<=120 THEN 'DO MORE'
WHEN COUNT(SalesOrderid)>= 121 AND COUNT(SalesOrderid)<= 320 THEN 'FINE!'
ELSE 'Excellent!'
END AS SalesPersonFeedBack 
FROM Sales.SalesOrderHeader
JOIN Person.Person p
ON SalesPersonID = p.BusinessEntityID
GROUP BY SalesPersonID, p.LastName, p.FirstName
ORDER BY p.LastName, p.FirstName;

/*Problem 2*/
SELECT o.TerritoryID, s.Name, o.SalesPersonID,
COUNT(o.SalesOrderid) [Total Orders],
RANK() OVER(PARTITION BY o.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC) Ranking
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesTerritory s
 ON o.TerritoryID = s.TerritoryID
WHERE SalesPersonID IS NOT NULL
GROUP BY o.TerritoryID, s.Name, o.SalesPersonID
ORDER BY o.TerritoryID;

/*Problem3*/
SELECT  o.TerritoryID, s.Name, CAST(o.TotalDue AS INT) AS [Order Value],
RANK() OVER (PARTITION BY o. TerritoryID ORDER BY o.TotalDue DESC) AS [Rank]
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesTerritory s
ON o.TerritoryID = s.TerritoryID
WHERE TotalDue > 12000


/*Problem 4*/
SELECT TOP 3 SalesPersonID, pr.LastName, pr.FirstName, 
    SUM(oh.TotalDue) AS TotalSalesAmount, 
    COUNT(DISTINCT oh.ShipToAddressID) AS UniqueStatesProvinces
FROM Sales.SalesOrderHeader oh
JOIN Sales.SalesPerson s
ON oh.SalesPersonID = s.BusinessEntityID
JOIN Person.Person pr 
ON s.BusinessEntityID = pr.BusinessEntityID
JOIN Sales.SalesOrderDetail od 
ON oh.SalesOrderID = od.SalesOrderID
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID, pr.LastName, pr.FirstName
HAVING COUNT(DISTINCT oh.ShipToAddressID) > 10
ORDER BY TotalSalesAmount DESC, SalesPersonID ASC

/*Problem5 */
SELECT (select Count(od.OrderQty) [TotalOrder Quantity]
FROM Production.Product p 
JOIN Sales.SalesOrderDetail od 
ON  p.ProductID = od.ProductID
JOIN Sales.SalesOrderHeader oh
ON oh.SalesOrderID = od.SalesOrderID
where oh.OrderDate BETWEEN '2006-10-01' AND '2006-10-30')
-
(select Count(od.OrderQty)
FROM Production.Product p 
JOIN Sales.SalesOrderDetail od 
ON  p.ProductID = od.ProductID
JOIN Sales.SalesOrderHeader oh
ON oh.SalesOrderID = od.SalesOrderID
where oh.OrderDate BETWEEN '2006-11-01' AND '2006-11-30');
