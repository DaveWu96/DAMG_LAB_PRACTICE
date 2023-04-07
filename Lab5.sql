
-- Lab 5-1 
 
/* Create a function in your own database that takes three 
   parameters: 
 
   1) A year parameter  
   2) A month parameter 
   3) A color parameter 
 
   The function then calculates and returns the total sales  
   for products in the requested color during the requested  
   year and month. If there was no sale for the requested period,  
   returns 0. 
 
   Hints: a) Use UnitPrice*OrderQty for calculating the total sale. 
          b) The year and month parameters should use  
             the INT data type. The color parameter 
 should use varchar. 
          c) Make sure the function returns 0 if there 
             was no sale in the database for the requested 
             period.  
          d) Use data from AdventureWorks2008R2 */ 
 

create Function sales (@Year int, @Month int, @color varchar(20))
    RETURNS Numeric (12,4)
    AS BEGIN
    DECLARE @SUM Numeric (12,4) = 0
	select  @SUM = SUM(UnitPrice*OrderQty) from sales.SalesOrderHeader h
	join sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID  
	join Production.Product AS pr on pr.ProductID = d.ProductID
	Where month(OrderDate) = @Month AND year(OrderDate) = @Year and color=@color
    RETURN isnull(@SUM,0);
    END

select dbo.sales('2005','7','Black');



-- Lab 5-2 
 
/* Using data from AdventureWorks2008R2, create a function that accepts 
   a customer id and returns the full name (last name + first name) 
   of the customer. */ 

create Function fullNameOfCustomer (@CustomerID varchar(20))
RETURNS varchar(50)
AS BEGIN
DECLARE @full_name varchar(50)
select @full_name=lastname+ ' '+FirstName from sales.customer c
join person.Person p on p.BusinessEntityID=c.PersonID
where CustomerID=@CustomerID;
RETURN @full_name;
END;
 
select dbo.fullNameOfCustomer('19184');


-- Lab 5-3 
 
/* With three tables as defined below: */ 
 
CREATE TABLE Customer 
(CustomerID INT PRIMARY KEY, 
 CustomerLName VARCHAR(30), 
 CustomerFName VARCHAR(30)); 
 
CREATE TABLE SaleOrder 
(OrderID INT IDENTITY PRIMARY KEY, 
 CustomerID INT REFERENCES Customer(CustomerID), 
 OrderDate DATE, 
 LastModified datetime); 
 
CREATE TABLE SaleOrderDetail 
(OrderID INT REFERENCES SaleOrder(OrderID), 
 ProductID INT, 
 Quantity INT, 
 UnitPrice INT, 
 PRIMARY KEY (OrderID, ProductID)); 

 
/* Write a trigger to put the change date and time in the LastModified column 
   of the Order table whenever an order item in SaleOrderDetail is changed. */ 

create TRIGGER changed_salesorderDetail
ON  SaleOrderDetail
after update
AS
BEGIN

update SaleOrder set LastModified=getdate() where OrderID=(select OrderID from inserted);

END;

-- test:
-- insert into SaleOrder values (null,null,null);
-- insert into SaleOrderDetail values (1,1001,100,50);
-- update SaleOrderDetail set Quantity=102 where OrderID=1;
-- select * from SaleOrder
 

-- Lab 5-4 
 
/* In an investment company, bonuses are handed out to the top-performing 
   employees every quarter. There is a business rule that no employee can 
   be granted more than a total of $100,000 as bonuses per year. Any attempt 
   to give an employee more than $100,000 for bonuses in a year must be logged in an audit table and the violating bonus is not allowed. 

   Given the following 3 tables, please write a trigger to implement 
   the business rule. The rule must be enforced every year automatically. 
   Assume only one bonus is entered in the database at a time. 
   You can just consider the INSERT scenarios. 

*/ 
 
create table Employee 
(EmployeeID int primary key, 
 EmpLastName varchar(50), 
 EmpFirstName varchar(50), 
 DepartmentID smallint); 
 
create table Bonus 
(BonusID int identity primary key, 
 BonusAmount int, 
 BonusDate date NOT NULL, 
 EmployeeID int NOT NULL); 
 
create table BonusAudit  -- Audit Table 
(AuditID int identity primary key, 
 EnteredBy varchar(50) default original_login(), 
 EnterTime datetime default getdate(), 
 EnteredAmount int not null); 
  

create TRIGGER insert_Bonus
ON  Bonus
after insert
AS
BEGIN

declare @EnteredBy varchar(20)
declare @EnteredAmount varchar(20)
declare @year varchar(20)

select @EnteredBy=EmployeeID from inserted
select @EnteredAmount=BonusAmount from inserted
select @year=cast(year(BonusDate) as varchar(20)) from inserted

if (select sum(BonusAmount) from Bonus where EmployeeID=(select EmployeeID from inserted) and year(BonusDate)=@year )>100000
begin
	rollback;
	print('it is not allow to give an employee more than $100,000 for bonuses in a year(') + @year + ')'
	insert into BonusAudit(EnteredBy,EnterTime,EnteredAmount) values (@EnteredBy,getdate(),@EnteredAmount);
end

END;

-- test:
-- insert into Bonus values (95000,'2023-03-30',1);
-- insert into Bonus values (4000,'2023-03-30',1);
-- insert into Bonus values (8000,'2023-03-30',1);
-- insert into Bonus values (9998000,'2022-11-30',1);
-- insert into Bonus values (8000,'2022-11-30',1);
-- select * from BonusAudit
-- select * from Bonus
-- delete from BonusAudit
-- delete from Bonus