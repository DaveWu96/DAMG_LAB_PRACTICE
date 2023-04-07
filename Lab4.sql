-- Lab 4 Questions 
-- Part A (2 points) 
-- Create 3 tables and the corresponding relationships to implement the ERD below in your own database. 

create table patient(
	patientid varchar(30) primary key,
	lastName varchar(30),
	FirstName varchar(50),
	DateOfBirth date
);

create table test(
	testid varchar(30) primary key,
	Name varchar(30),
	Description varchar(50)
);

create table result(
	testid varchar(30),
	patientid varchar(30),
	Description varchar(50),
	foreign key(patientid) references patient(patientid),
	foreign key(testid) references test(testid)
);


-- Part B-1 (2 points) 

SELECT SalesOrderID,STRING_AGG(productid, ',') AS products
from 
(
select SalesOrderID,productid from (
select SalesOrderID,orderqty,productid,dense_rank() over(partition by SalesOrderID order by orderqty desc) as ranking from sales.SalesOrderDetail
) base where ranking<=3
) t
GROUP BY SalesOrderID
order by SalesOrderID asc;

-- Part B-2 (2 points) 

SELECT SalesPersonId,cast(max_total as int) as HighestOrderValue,cast(total_sales as int) as TotalSales,STRING_AGG(SalesOrderID, ',') AS Orders
from 
(
select  salespersonid,SalesOrderID,totalOrderQty,totaldue,qty_rank,max_total,total_sales
from (
select salespersonid,SalesOrderID,totalOrderQty,totaldue,
dense_rank() over(partition by salespersonid order by totalOrderQty desc) as qty_rank,
max(totaldue) over(partition by salespersonid order by totaldue desc) as max_total,
sum(totaldue) over(partition by salespersonid) as total_sales
from 
(
select salespersonid,d.SalesOrderID,sum(OrderQty) as totalOrderQty,min(totaldue) as totaldue
from sales.SalesOrderHeader h
join sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID  
where salespersonid is not null
group by salespersonid,d.SalesOrderID  
) base
) base2
where total_sales>10000000 and qty_rank<=3
) base3
group by salespersonid,max_total,total_sales
order by salespersonid

-- Part C (2 points) 

-- Starter code 
WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS 
( 
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty, 
           b.EndDate, 0 AS ComponentLevel
    FROM Production.BillOfMaterials AS b 
    WHERE b.ProductAssemblyID = 992 AND b.EndDate IS NULL  and ComponentID not in (808,949) --   instead of purchasing them for use at the level 0. 
	UNION ALL 
	SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty, 
           b.EndDate, 1 AS ComponentLevel
    FROM Production.BillOfMaterials AS b 
    WHERE b.ProductAssemblyID = 992 AND b.EndDate IS NULL  and ComponentID in (808,949) --  manufactured internally at the level 1.
    UNION ALL 
    SELECT bom.ProductAssemblyID, bom.ComponentID, bom.PerAssemblyQty, 
           bom.EndDate, ComponentLevel + 1 
    FROM Production.BillOfMaterials AS bom  
    INNER JOIN Parts AS p 
    ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL 
) 
SELECT AssemblyID, ComponentID, Name, PerAssemblyQty, ComponentLevel--  ,pr.ProductID 
FROM Parts AS p 
INNER JOIN Production.Product AS pr 
ON p.ComponentID = pr.ProductID 
ORDER BY ComponentLevel, AssemblyID, ComponentID; 