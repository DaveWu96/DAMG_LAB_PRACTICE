
-- Lab 4 Solutions

-- PART A
CREATE TABLE dbo.Patient
 (
 PatientID int NOT NULL PRIMARY KEY,
 LastName varchar(40) NOT NULL,
 FirstName varchar(40) NOT NULL,
 DateOfBirth date NOT NULL
 );

CREATE TABLE dbo.Test
 (
 TestID int NOT NULL PRIMARY KEY ,
 Name varchar(40) NOT NULL,
 Description varchar(200) NOT NULL
 );

CREATE TABLE dbo.Result
 (
 PatientID int NOT NULL REFERENCES dbo.Patient(PatientID),
 TestID int NOT NULL REFERENCES dbo.Test(TestID),
 Date date NOT NULL,
	CONSTRAINT PKItem PRIMARY KEY CLUSTERED (PatientID,TestID,Date)
 );

-- PART B - 1 (2 points)

-- Solution 1
Select SalesOrderID, 
Stuff((Select top 3 with ties ', ' + rtrim(cast(ProductId as char)) 
       From Sales.SalesOrderDetail 
       Where SalesOrderId = h.SalesOrderId
       Order By OrderQty desc
       FOR XML PATH('')) , 1, 2, '') as Products
From Sales.SalesOrderHeader h
Order by h.SalesOrderID;

-- OR

-- Solution 2 ( points)
with temp as
(SELECT sh.SalesOrderID, sd.ProductID,
        rank() over (partition by sh.SalesOrderID order by orderqty desc) Ranking
 FROM Sales.SalesOrderHeader sh
 JOIN Sales.SalesOrderDetail sd
 ON sh.SalesOrderID = sd.SalesOrderID
)
SELECT	SalesOrderID,
		STRING_AGG(	cast(ProductID as varchar)
					, ', ')	
					AS Products
FROM temp 
WHERE Ranking <= 3
GROUP BY SalesOrderID
ORDER BY SalesOrderID;

-- OR

-- Solution 3 (AdventureWorks2017 only)

with temp as
(SELECT sh.SalesOrderID, sd.ProductID,
        rank() over (partition by sh.SalesOrderID order by orderqty desc) Ranking
 FROM Sales.SalesOrderHeader sh
 JOIN Sales.SalesOrderDetail sd
 ON sh.SalesOrderID = sd.SalesOrderID
)
SELECT	SalesOrderID,
		STRING_AGG(	cast(ProductID as varchar)
					, ', ')	
					WITHIN GROUP (ORDER BY Ranking)
					AS Products
FROM temp 
WHERE Ranking <= 3
GROUP BY SalesOrderID
ORDER BY SalesOrderID;


-- PART B - 2 (2 points)

with t1 as (
select SalesPersonID, TotalDue OrderValue,
       row_number() over (partition by SalesPersonID order by TotalDue desc) rv
from Sales.SalesOrderHeader
where SalesPersonID is not null),

t3 as (
select SalesPersonID, sh.SalesOrderID, 
       sum(sd.OrderQty) ooq,
       rank() over (partition by SalesPersonID order by sum(sd.OrderQty) desc) ro
from Sales.SalesOrderHeader sh
join Sales.SalesOrderDetail sd
on sh.SalesOrderID = sd.SalesOrderID
where SalesPersonID is not null
group by SalesPersonID, sh.SalesOrderID
),

t4 as (
select SalesPersonID, sum(TotalDue) TotalSales
from Sales.SalesOrderHeader
where SalesPersonID is not null
group by SalesPersonID)

select distinct t1.SalesPersonID,  
       cast(OrderValue as int) HighestOrderValue, 
	   cast(TotalSales as int) TotalSales,

STUFF((SELECT  TOP 3 WITH TIES ', '+RTRIM(CAST(SalesOrderID as char))  
       FROM t3  
	   WHERE t3.SalesPersonID = t1.SalesPersonID
       ORDER BY ro
       FOR XML PATH('')) , 1, 2, '') AS Orders

from t1 join t3 on t1.SalesPersonID = t3.SalesPersonID
join t4 on t3.SalesPersonID = t4.SalesPersonID
where rv =1 and TotalSales > 10000000 
order by t1.SalesPersonID;


--Part C (2 points)

-- Solution

IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL
DROP TABLE #TempTable;

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
    -- Top-level compoments
	SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
        b.EndDate, 0 AS ComponentLevel
    FROM Production.BillOfMaterials AS b
    WHERE b.ProductAssemblyID = 992
          AND b.EndDate IS NULL

    UNION ALL

	-- All other sub-compoments
    SELECT bom.ProductAssemblyID, bom.ComponentID, bom.PerAssemblyQty,
        bom.EndDate, ComponentLevel + 1
    FROM Production.BillOfMaterials AS bom 
        INNER JOIN Parts AS p
        ON bom.ProductAssemblyID = p.ComponentID
        AND bom.EndDate IS NULL
)
SELECT AssemblyID, ComponentID, Name, ListPrice, PerAssemblyQty, 
       ListPrice * PerAssemblyQty SubTotal, ComponentLevel

into #TempTable

FROM Parts AS p
    INNER JOIN Production.Product AS pr
    ON p.ComponentID = pr.ProductID
ORDER BY ComponentLevel, AssemblyID, ComponentID;


SELECT
	(SELECT SUM(ListPrice)
	FROM #TempTable
	WHERE ComponentLevel = 0 and ComponentID IN (808, 949))
	-
	(SELECT SUM(ListPrice)
	FROM #TempTable
	WHERE ComponentLevel = 1 and AssemblyID IN (808, 949)) AS 'Price Difference';


