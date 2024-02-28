--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JohannaHolmes')
	 Begin 
	  Alter Database [Assignment06DB_JohannaHolmes] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JohannaHolmes;
	 End
	Create Database Assignment06DB_JohannaHolmes;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JohannaHolmes;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

go
Create view VCategories as 
Select CategoryID, CategoryName From Categories;
go

Create view VProducts as 
Select ProductID, ProductName, CategoryID, UnitPrice From Products;
go

Create view VEmployees as 
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From Employees;
go


Create view VInventories as 
Select InventoryID, InventoryDate, EmployeeID, ProductID, Count From Inventories;
go



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?


--GRANT SELECT ON OBJECT::Assignment06DB_JohannaHolmes.VCategories TO sa;  
--GO  

--DENY SELECT ON OBJECT::Assignment06DB_JohannaHolmes.VCategories TO sa;  
--GO 

Deny Select on Categories To Public;
Deny Select on Products To Public;
Deny Select on Employees To Public;
Deny Select on Inventories To Public;

go 

Grant Select On VCategories To Public;
Grant Select On VProducts To Public;
Grant Select On VEmployees To Public;
Grant Select On VInventories To Public;

go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create view [VProductsByCategories] 
as 
Select CategoryName, ProductName, UnitPrice
from Categories C inner join Products P on C.CategoryID = P.CategoryID ;

Go
Select * from [VProductsByCategories]
order by CategoryName, ProductName;

go
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create view [VInventoriesByProductsByDates] 
as 
Select ProductName, Count, InventoryDate  
From Products P inner join Inventories I on P.ProductID = I.ProductID
Inner join Categories C on P.CategoryID = C.CategoryID;

go
Select *From [VInventoriesByProductsByDates]
Order by ProductName, InventoryDate, Count;
go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create view [vInventoriesByEmployeesByDates] as

Select distinct InventoryDate, [EmployeeFirstName] + ' ' + EmployeeLastName  EmployeeName
From Inventories I Inner Join Employees E On I.EmployeeID = E.EmployeeID;


go

Select *from [vInventoriesByEmployeesByDates]
Order by InventoryDate;
go


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create view [vInventoriesByProductsByCategories] as

Select CategoryName, ProductName, InventoryDate, Count 
From Products P inner join Inventories I on P.ProductID = I.ProductID
Inner join Categories C on P.CategoryID = C.CategoryID;

go
Select *from [vInventoriesByProductsByCategories]
Order by CategoryName, ProductName, InventoryDate, Count; 



-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

go

Create view [vInventoriesByProductsByEmployees] as

Select CategoryName, ProductName, InventoryDate, Count, [EmployeeFirstName] + ' ' + EmployeeLastName  EmployeeName 
From Products P inner join Inventories I on P.ProductID = I.ProductID
Inner join Categories C on P.CategoryID = C.CategoryID
Inner join Employees E on I.EmployeeID = E.EmployeeID;

go
Select *from [vInventoriesByProductsByEmployees] 
Order by InventoryDate, CategoryName, ProductName, EmployeeName;



-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

go

Create view [vInventoriesForChaiAndChangByEmployees] as


Select CategoryName, ProductName, InventoryDate, Count, [EmployeeFirstName] + ' ' + EmployeeLastName  EmployeeName 
From Products P inner join Inventories I on P.ProductID = I.ProductID
Inner join Categories C on P.CategoryID = C.CategoryID
Inner join Employees E on I.EmployeeID = E.EmployeeID
Where P.ProductID in (Select ProductID 
						From Products 
						Where ProductName = 'Chai' or ProductName = 'chang'
						 );

go


Select *from[vInventoriesForChaiAndChangByEmployees]

Order by InventoryDate, CategoryName, ProductName;



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

go

Create view [vEmployeesByManager] as

Select M.[EmployeeFirstName] + ' ' + M.EmployeeLastName Manager,
E.[EmployeeFirstName] + ' ' + E.EmployeeLastName Employees
from employees E Inner Join Employees M on E.ManagerID = M.EmployeeID; 

go

Select *from [vEmployeesByManager]

Order by Manager, Employees;



-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

go


Create view [vInventoriesByProductsByCategoriesByEmployees] as 

Select C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, 
	   E.EmployeeID, E.[EmployeeFirstName] + ' ' + E.EmployeeLastName  Employee, 
	   M.[EmployeeFirstName] + ' ' + M.EmployeeLastName  Manager

From Products P inner join Inventories I on P.ProductID = I.ProductID
Inner join Categories C on P.CategoryID = C.CategoryID
Inner join Employees E on I.EmployeeID = E.EmployeeID
Inner Join Employees M on E.ManagerID = M.EmployeeID; 

go 

Select *from [vInventoriesByProductsByCategoriesByEmployees]



-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/