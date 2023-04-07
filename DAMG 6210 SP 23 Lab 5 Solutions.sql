
-- Lab 5 Solutions

-- Lab 5-1

create function salesByMonthYear
(@month int, @year int, @color varchar(20))
returns money
As
Begin 
	Declare @sale money;
	select @sale = isnull( sum(UnitPrice*OrderQty) , 0)
	from sales.SalesOrderHeader sh
	join Sales.SalesOrderDetail sd
	on sh.SalesOrderID = sd.SalesOrderID
	join Production.Product p
	on p.ProductID = sd.ProductID
	where month(orderDate) = @month and year(OrderDate) = @year
	      and Color = @color
	return @sale;
End

select dbo.salesByMonthYear(2005, 3, 'Yellow');
drop function dbo.salesByMonthYear;


-- Lab 5-2

-- Create a table-valued function
create function uf_GetCustomerName
(@CustID int)
returns @tbl table  (name varchar(200))
  begin
     declare @fullname varchar(200) = '' ;

     select @fullname = p.FirstName + ' ' + p.LastName
     from Sales.Customer c
     join Person.Person p
     on c.PersonID = p.BusinessEntityID
     where c.CustomerID = @custID;

     insert into @tbl values (@fullname);

     return;
  end

-- Test run the function
select * from dbo.uf_GetCustomerName(11000)


-- Lab 5-3

CREATE TRIGGER dbo.utrLastModified
ON dbo.SaleOrderDetail 
AFTER INSERT, UPDATE, DELETE
AS  BEGIN
    DECLARE @oid INT;
	SET @oid = ISNULL((SELECT OrderID FROM Inserted), (SELECT OrderID FROM Deleted));
    UPDATE dbo.SaleOrder SET LastModified = GETDATE()
	WHERE OrderID = @oid
	END


-- Lab 5-4

create trigger trAuditBonus
on Bonus
after INSERT
as
begin
   declare @ttlBonus int, @empID int, @enterAmount int, @yr int;
   set @yr = (select year(BonusDate) from inserted);
   set @empID = (select EmployeeID from inserted);
   select @ttlBonus = sum(BonusAmount)
      from Bonus
      where EmployeeID = @empID and year(BonusDate) = @yr;

   if @ttlBonus > 100000
      begin
         rollback transaction;
         set @enterAmount = (select BonusAmount from inserted);
         insert into BonusAudit (EnteredAmount)
            values (@enterAmount);
      end
end
