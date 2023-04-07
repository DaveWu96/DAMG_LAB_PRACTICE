
--Lab 2-2 Solutions

-- 2-1
USE AdventureWorks2008R2;
select CustomerID, SalesOrderID, cast(OrderDate as date) 'Order Date',
       cast(TotalDue as int) 'Total Due'
from Sales.SalesOrderHeader
where OrderDate > '5-5-2007' and TotalDue > 125000
order by CustomerID, OrderDate;


-- 2-2

Select p.ProductID as 'Product ID',
       p.Name as 'Product Name',
       count(sod.ProductID) as 'Times Sold',
	   sum(OrderQty) as 'Total Quantity'
From Production.Product p 
join Sales.SalesOrderDetail sod
on p.ProductID = sod.ProductID
Group By p.ProductID, p.Name
Having count(sod.ProductID) > 353 
Order by count(sod.ProductID) desc, p.ProductID;


-- 2-3

Select ProductID as 'Product ID', 
       Name as 'Product Name',
       cast(ListPrice as int) as 'List Price'
From Production.Product
Where ListPrice > (Select avg (ListPrice) + 1000
                   From Production.Product 
				   where ProductID in (911, 915))
ORDER BY ListPrice desc;


-- 2-4

select distinct CustomerID, cast(sum(TotalDue) as int) 'Total Purchase'
from Sales.SalesOrderHeader
where CustomerID not in
(select CustomerID
 from Sales.SalesOrderHeader
 where OrderDate >'9-5-2005')
group by CustomerID
order by CustomerID desc;


-- 2-5

with temp as (
select CustomerID, count(distinct SalesOrderID) TotalOrder
from Sales.SalesOrderHeader
where TotalDue > 100000
group by CustomerID)
select sh.CustomerID, p.FirstName, p.LastName, cast(sum(TotalDue) as int) TotalPurchase
from Sales.SalesOrderHeader sh
join temp t
on t.CustomerID = sh.CustomerID
join Sales.Customer c
on c.CustomerID = sh.CustomerID
join Person.Person p
on p.BusinessEntityID = c.PersonID
where TotalOrder > 3
group by sh.CustomerID, p.FirstName, p.LastName
order by sh.CustomerID;


-- 2-6

select (select sum(OrderQty)
from Sales.SalesOrderDetail sd
join Sales.SalesOrderHeader sh
on sd.SalesOrderID = sh.SalesOrderID
where sh.TerritoryID = 1)
-
(select sum(OrderQty)
from Sales.SalesOrderDetail sd
join Sales.SalesOrderHeader sh
on sd.SalesOrderID = sh.SalesOrderID
where sh.TerritoryID = 2);


