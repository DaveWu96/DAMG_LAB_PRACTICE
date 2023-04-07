
-- Lab 3p Solutions

-- 3-1

SELECT SalesPersonID, p.LastName, p.FirstName,
       COUNT(o.SalesOrderid) [Total Orders],
	   CASE
		  WHEN COUNT(o.SalesOrderID) BETWEEN 1 AND 120
			 THEN 'Do more!'
		  WHEN COUNT(o.SalesOrderID) BETWEEN 121 AND 320
			 THEN 'Fine!'
		  ELSE 'Excellent!'
	   END AS Performance
FROM Sales.SalesOrderHeader o
JOIN Person.Person p
   ON o.SalesPersonID = p.BusinessEntityID
GROUP BY o.SalesPersonID, p.LastName, p.FirstName
ORDER BY p.LastName, p.FirstName;


-- 3-2

SELECT o.TerritoryID, s.Name, o.SalesPersonID,
  COUNT(o.SalesOrderid) [Total Orders],
  RANK() OVER (PARTITION BY o.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC) [Rank]
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesTerritory s
   ON o.TerritoryID = s.TerritoryID
WHERE SalesPersonID IS NOT NULL
GROUP BY o.TerritoryID, s.Name, o.SalesPersonID
ORDER BY o.TerritoryID;


-- 3-3

select top 1 with ties t.TerritoryID, Name, 
       round(max(TotalDue), 2) HighestOrderValue,
	   cast(sum(TotalDue) as int) TotalSales
from Sales.SalesTerritory t
join Sales.SalesOrderHeader sh
on t.TerritoryID = sh.TerritoryID
where t.TerritoryID not in
(select TerritoryID
 from Sales.SalesOrderHeader
 where TotalDue > 120000)
group by t.TerritoryID, name
order by sum(TotalDue) asc;


-- 3-4

with t1 as (
select SalesPersonID, 
       count(distinct StateProvinceID) sc,
	   sum(TotalDue) Sale,
	   rank() over (order by sum(TotalDue) desc) BR
from Sales.SalesOrderHeader sh
join Person.Address a
on sh.ShipToAddressID = a.AddressID
where SalesPersonID is not null
group by sh.SalesPersonID)

select SalesPersonID, SC, Sale, LastName, FirstName
from t1
join Person.Person p
on t1.SalesPersonID = p.BusinessEntityID
where BR <= 3 and SC >10
order by SalesPersonID;


-- 3-5

with temp1 as
(select p.Color, sum(sd.OrderQty) TtlQty
 from Sales.SalesOrderHeader sh
 join Sales.SalesOrderDetail sd
      on sh.SalesOrderID = sd.SalesOrderID
 join Production.Product p
      on sd.ProductID = p.ProductID
 where year(OrderDate) = 2006 and month(OrderDate) = 10
 group by p.Color),

temp2 as
(select p.Color, sum(sd.OrderQty) TtlQty
 from Sales.SalesOrderHeader sh
 join Sales.SalesOrderDetail sd
      on sh.SalesOrderID = sd.SalesOrderID
 join Production.Product p
      on sd.ProductID = p.ProductID
 where year(OrderDate) = 2006 and month(OrderDate) = 11
 group by p.Color)

select top 1 with ties t1.Color, (t2.TtlQty - t1.TtlQty) Increase
from temp1 t1
join temp2 t2
     on t1.Color = t2.Color
order by Increase desc;


