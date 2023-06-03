USE master;
GO
DECLARE @data_location nvarchar(256);
SET @data_location = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1)
      FROM master.sys.master_files
      WHERE database_id = 1 AND file_id = 1);
EXECUTE
('CREATE DATABASE GroceryManagementSyetem
ON PRIMARY(NAME = GroceryDB_data, FILENAME = ''' + @data_location + 'GroceryManagementSyetem_data.mdf'',SIZE = 20MB, MAXSIZE = Unlimited, FILEGROWTH = 2MB)
LOG ON (NAME = GrocaryMgt_log, FILENAME = ''' + @data_location + 'GroceryManagementSyetem_log.ldf'', SIZE = 10MB, MAXSIZE = 100MB, FILEGROWTH = 1MB)'
);
GO

CREATE SCHEMA gms
GO
----drop GroceryManagementSyetem

Use GroceryManagementSyetem
Create Table Employees
(
EmployeeID Int primary key,
EmployeeFirstName Varchar(30),
EmployeeLastName Varchar(30),
PhoneNo Varchar(30) Unique CHECK(PhoneNo Like '018%' Or PhoneNo Like '017%'),
EmployeeAddress  Varchar(50),
JoinDate DateTime Not Null Default (GETDATE()),
Position Varchar(30)
);
Go

Use GroceryManagementSyetem
Create Table Customers
(
CustomerID Int primary key Identity(1,1),
CustomerName Varchar(30),
PhoneNo Varchar(30) Unique ,
City  Varchar(50) SPARSE,
);
Go

Use GroceryManagementSyetem
Create Table Catagories
(
CatagoryID Int primary key Identity(1,1),
CatagoryName Varchar(30),
Details Varchar(200)  
);
Go

Use GroceryManagementSyetem
Create Table Products
(
ProductID Int primary key Identity(1,1) ,
Productname Varchar(30) not Null,
CatagoryID Int Foreign key references Catagories (CatagoryID),
AvailableQuantity Int,
UnitPrice Money,
Vat  As (UnitPrice * .15),
TotalUnitPrice AS (UnitPrice+(UnitPrice * .15))
);
Go

Use GroceryManagementSyetem
Create Table Orders
(
OrderID Int primary key Identity(1,1),
CustomerID Int Foreign key references Customers (CustomerID),
OrderDate DateTime Default (GetDate())
);
Go

Use GroceryManagementSyetem
Create Table OrderDetails
(
OrderDetailsId Int Identity(1,1),
OrderID Int Foreign key references Orders (OrderID),
ProductID Int Foreign key references Products (ProductID),
Quantity Int 
);
Go 

Use GroceryManagementSyetem
Create Table OrderDetails_Audit
(
OrderID Int,
ProductID Int,
Quantity Int ,
UnitPrice Money,
Totalprice money,
Actiontype varchar(100),
Actiontime dateTime
);
Go

Use GroceryManagementSyetem
Create Table Archive_Delete
(
OrderDetailsId Int,
OrderID Int,
ProductID Int,
Quantity Int
);
Go

---------------Clustered And Non ClusterIndex-------------

Create Clustered index ix _Cclustered
On OrderDetails (OrderDetailsId)
Go
Create NonClustered index NClustered
On OrderDetails(Quantity)
Go
---------------Create Sequence----------------------------

Create Sequence sq_Employee
As
BigInt
Start With 1
Increment By 1
Go

--------------- Alter Column(Column, Column name, data type )------------------

Alter Table Employee Add Salary Money
Alter Table Employee Alter Column Salary Decimal
Alter Table Employee Drop Column Salary 
GO


---------------------------------View--------------------------------
Create View vw_Products 
AS
Select ProductID,Productname,AvailableQuantity,UnitPrice,Vat, TotalUnitPrice
From Products;
Go


----------------------------Temporary Table-----------------------------

CREATE Table ##New_Customer 
(CustomerID int,
CustomerName varchar(30),
PhoneNo varchar(30),
City varchar(30)
);
Go


---------------------------Store Procedure---------------------------


Create PROC sp_OrderDetails
@CustomerID Int,
@OrderID Int,
@ProductID Int,
@Quantity Int
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRAN
			IF @Quantity<=(Select AvailableQuantity From Products WHERE ProductID= @ProductID)

			INSERT INTO Orders Values(@CustomerID,GetDate());
			INSERT INTO OrderDetails(OrderID,ProductID,Quantity) Values(@OrderID,@ProductID,@Quantity);
			UPDATE Products SET AvailableQuantity= AvailableQuantity-@Quantity
			WHERE ProductID= @ProductID
			Print  'The Order Placed Successfully111'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION		
		PRINT 'The Number of Ordered Product is not available right now.'
	END CATCH
END
EXEC sp_OrderDetails 7,50,23,2

Go
-----------------------Scalar Function------------------------


CREATE FUNCTION fn_Total
(@OrderId Int)
Returns Int
BEGIN
	Return(Select Sum(UnitPrice+Vat) AS Total
	FROM Customers Join Orders ON Customers.CustomerID=Orders.CustomerID
	Join OrderDetails on Orders.OrderID=OrderDetails.OrderID
	Join Products On Products.ProductID=OrderDetails.OrderID
	WHERE OrderDetails.OrderID=@OrderId
	GROUP BY OrderDetails.OrderID)
END
GO
Select dbo.fn_Total(1)
GO
-----------------------tabular Function----------------------------


Create Function fn_TotalAmountofs_Customer
(@customerID Int)
Returns Table
As

	Return(Select Customers.CustomerID,CustomerName,OrderDetails.OrderID,
	Sum(Quantity*TotalUnitPrice) As Amount
	From Customers Join Orders On Customers.CustomerID=Orders.CustomerID
	Join OrderDetails on Orders.OrderID=OrderDetails.OrderID
	Join Products On Products.ProductID=OrderDetails.ProductID
	Where Customers.CustomerID=@customerID 
	Group By  Customers.CustomerID,CustomerName,OrderDetails.OrderID
	Having OrderDetails.OrderID>3);
Go	


----------------------------------------Trigger---------------------------------------

Create Trigger trg_InsteadOfInsert on dbo.OrderDetails
Instead Of Insert
AS
Declare
@OrderId int,
@ProductID Int,
@quantity Int,
@UnitPrice money,
@totalprice money,
@actiontype varchar (100),
@actiontime datetime

Select @OrderId=i.OrderID From Inserted i
Select @ProductID=i.ProductID From Inserted i
Select @quantity=i.Quantity From Inserted i
Select @UnitPrice=(Select AvailableQuantity From Products WHERE ProductID= @ProductID)
Select @totalprice=@UnitPrice*@quantity
Set @actiontype='Inserted Successfull....Instead of Insert trigger Fired'

Begin
	Begin tran
	If @quantity >(Select AvailableQuantity From Products WHERE ProductID= @ProductID)
		Begin
		Raiserror ('Quantity Must Be Below Than Available quantity',16,1)
		Rollback
		End
	Else
		Begin
		Insert Into OrderDetails (OrderID,ProductID,Quantity) 
		values (@OrderId,@ProductID,@quantity    

		Insert into OrderDetails_Audit(OrderID,ProductID,Quantity,UnitPrice,Totalprice,Actiontype,Actiontime)
		Values (@@IDENTITY,@ProductID,@quantity,@UnitPrice,@totalprice,@actiontype,Getdate())

		End
	Commit tran
	Print'Instead Of Insert Trigger Fired!!!! '
End
Go

--------------------------------After Delete Trigger-----------------------
Create Trigger Order_Delete On OrderDetails
After Delete
As
Insert Into Archive_Delete
(OrderDetailsId,OrderID,ProductID,Quantity)
Select OrderDetailsId,OrderID,ProductID,Quantity
From Deleted
Go