------------------------CRUD operation---------------------------
Insert Into Employees values
(Next value For sq_Employee,'Raihan','Karim','0182020040','Ctg','20120/01/01','Manager'),
(Next value For sq_Employee,'Jahed','sarwar','0182232424','Dhaka','20120/01/01','Cashier'),
(Next value For sq_Employee,'Minhaj','Uddin','0172042460','Ctg','20120/01/01','Sr. Salesman'),
(Next value For sq_Employee,'Anowar','Akash','01879472470','Dhaka',Default,'Jr. Salesman'),
(Next value For sq_Employee,'Fahim','Tarek','01828273975','Ctg',Default,'Jr. Salesman');
Go
Insert Into Customers values
('Nijam','1082004050','Sylet'),
('Minhaj','1082030060','Ctg'),
('Sakib','10820304070','Dhaka'),
('Rakib','1082034080','Ctg'),
('Monir','1020304090','Dhaka'),
('Saiful','108204051','Coxbazar'),
('Kabir','1082030052','Ctg'),
('Rahim','108204053','Dhaka'),
('Fahim','1082030054','Ctg'),
('wahid','10820304055','Ctg'),
('Samin','10820380','Dhaka'),
('Shahid','10852034950','Ctg'),
('Hamid','10720304058','Ctg'),
('Fahad','100304090','Sylet'),
('Asif','1082030524059','Ctg'),
('Belal','10828555650','Coxbazar');
Go
Insert Into Catagories values
('Fruits','Apple,Banana,Grapes,Orange,Milon,Lamon'),
('Dairy','Milk,Butter,Egg,Yogurt,'),
('Vegetables','Broccoli,Cucumber,Tomato,Carrots,Garlic,Onion'),
('Beverages','Water,Juice,Coffee,Tea'),
('Fruits','Apple,Banana,Grapes,Orange,Milon,Lamon'),
('Meat/Fish','Beef,Maton,Chiken,Fish');
Go
Insert Into Products values
('Apple',1,100,50),
('Banana',1,500,10),
('Grapes',1,1000,10),
('Orange',1,100,50),
('Milon',1,200,80),
('Lamon',1,300,20),
('Milk',2,100,50),
('Butter',2,50,50),
('Egg',2,100,10),
('Yogurt',2,100,70),
('Broccoli',3,100,50),
('Cucumber',3,150,20),
('Tomato',3,300,20),
('Carrots',3,100,50),
('Garlic',3,500,10),
('Onion',3,400,20),
('Water',4,200,20),
('Juice',4,100,50),
('Coffee',4,100,50),
('Tea',4,100,30),
('Beef',6,40,800),
('Maton',6,50,700),
('Chiken',6,100,500),
('Fish',6,50,500);
GO 
Insert Into Orders values 
(1,Default),(2,Default),(3,Default),(4,Default),(5,Default),(6,Default),(7,Default),(8,Default),
(9,Default),(10,Default),(1,Default),(2,Default),(1,Default),(2,Default),(1,Default),(3,Default);

Go
Insert Into OrderDetails values (1,15,8),(1,1,10),(1,10,20),(2,15,8),(2,3,9),(2,17,10),(3,15,5),(3,3,10),
(4,5,5),(4,7,5),(5,11,8),(6,2,5),(7,6,6),(7,20,5),(7,19,8),(8,15,20),(8,13,9),(9,23,5),(10,19,5),
(1,3,5),(1,20,5),(2,17,5),(2,9,5),(1,14,15),(1,24,5),(1,16,12),(2,15,7),(2,13,13),(1,15,5),(3,19,5);
;
Go
Select * from OrderDetails
Insert Into ##New_Customer values
(2,'Mahin','01817222182','Ctg'),
(8,'Minar','01690046103','Dhaka'),
(4,'Faisal','01917222182','Ctg'),
(55,'Tuhin','018596857','Dhaka'),
(60,'Istiak','01896547855','Ctg');
Go

Update Catagories
Set CatagoryName='Rice', Details='Amon Rice,Deshi rice,Premium Rice,Basmati Rice'
Where CatagoryID=5;
Go


Insert Into Products values
('Amon Rice',5,50,70),
('Deshi Rice',5,50,50),
('Premiur Rice',5,50,80),
('Basmati Rice',5,50,90);
Go
DELETE Products
Where ProductID=28
Go

-----------------------------------Merge---------------------------------

MERGE Customers As T
Using ##New_Customer As S
On T.CustomerID=S.CustomerID
When MATCHED
Then UPDATE SET T.CustomerName=S.CustomerName,T.PhoneNo=S.PhoneNo,T.City=S.City
WHEN NOT MATCHED THEN INSERT (CustomerName,PhoneNo,City) VALUES (S.CustomerName,S.PhoneNo,S.City);
Go

----------------------------------CTE-------------------------------
With MyCTE
As
(
Select CustomerID,CustomerName,phoneNo,City From Customers Where CustomerID=1
)
Select * From MyCTE Where CustomerID=4
-----------------------------------UNION------------------------------

Select EmployeeFirstName From Employees
Union All
Select CustomerName From Customers


-----------------------------------CASE--------------------------------


Select Customers.CustomerID,CustomerName,OrderDetails.OrderID,OrderDetails.ProductID,Quantity,TotalUnitPrice,
(Quantity*TotalUnitPrice) As Amount,
CASE
WHEN Quantity*TotalUnitPrice>500 Then 'Customer will get 50 taka Bonus'
WHEN Quantity*TotalUnitPrice>400 Then 'Customer will get 30 taka Bonus'
Else 'No Bonus'
END AS BONUS
From Customers Join Orders On Customers.CustomerID=Orders.CustomerID
Join OrderDetails on Orders.OrderID=OrderDetails.OrderID
Join Products On Products.ProductID=OrderDetails.OrderID;
Go


---------------SubQuery,Basic Six Clause,Aggregate Function----------------------

Select Customers.CustomerID,CustomerName,OrderDetails.OrderID,
Sum(Quantity*TotalUnitPrice) As Amount
From Customers Join Orders On Customers.CustomerID=Orders.CustomerID
Join OrderDetails on Orders.OrderID=OrderDetails.OrderID
Join Products On Products.ProductID=OrderDetails.ProductID
Where Customers.CustomerID=3
Group By  Customers.CustomerID,CustomerName,OrderDetails.OrderID
Having OrderDetails.OrderID>3
Order BY CustomerName DESC

---------------------------------OFFSET and FETCH-------------------------------

Select Customers.CustomerID,CustomerName,OrderDetails.OrderID,
Sum(Quantity*TotalUnitPrice) As Amount
From Customers Join Orders On Customers.CustomerID=Orders.CustomerID
Join OrderDetails on Orders.OrderID=OrderDetails.OrderID
Join Products On Products.ProductID=OrderDetails.ProductID
Group By  Customers.CustomerID,CustomerName,OrderDetails.OrderID
Having OrderDetails.OrderID>2
Order BY Amount DESC
	Offset 2 Rows
	Fetch Next  3 Rows Only;
Go

---------------------------------Table Variable------------------------------------

Declare @Customers Table
(
StudentId Int Identity(1,1),
StudentName varchar(30)
);
Insert Into @Customers Values ('Kasem'),('Rasel')
Select * From @Customers;
Go


----------------------------Rollup & Cube---------------------

Select OrderDetails.OrderID,Count(*) As TotalOrder,
Sum(Quantity*TotalUnitPrice) As Amount
From Customers Join Orders On Customers.CustomerID=Orders.CustomerID
Join OrderDetails on Orders.OrderID=OrderDetails.OrderID
Join Products On Products.ProductID=OrderDetails.ProductID 
Group By OrderDetails.OrderID With Rollup
Go

Select OrderDetails.OrderID,Count(*) As TotalOrder,
Sum(Quantity*TotalUnitPrice) As Amount
From Customers Join Orders On Customers.CustomerID=Orders.CustomerID
Join OrderDetails on Orders.OrderID=OrderDetails.OrderID
Join Products On Products.ProductID=OrderDetails.ProductID 
Group By OrderDetails.OrderID With Cube



---------------------------Some Function-----------------------

Select Cast ('01-June-2020 10:00 AM' As Date);
Select Convert (Time,'01-June-2020 10:00 AM' );
Select Round(12.75,0)
Select Round(12.75,1)
Select Round(12.75,-1)
Select Round(12.75,0)
Select Ceiling(2.85)
Select Floor(2.85)
Select Isdate(2016-02-29)

Select * From OrderDetails
--Isdate
SELECT ISDATE('2030-05-21')
--Datepart
SELECT DATEPART(MONTH,'2030-05-21')
--Datename
SELECT DATENAME(MONTH,'2030-05-21')
--Sysdatetime
SELECT Sysdatetime()
--UTC
SELECT GETUTCDATE()

--Datediff
SELECT CustomerID,
	DATEDIFF(YEAR, JoinDate, GETDATE()) AS Age
FROM Customers

--All
SELECT CustomerID,CustomerName,EmployeeID,OrderID
FROM Customers
JOIN Employees ON Employees.EmployeeID=Customers.customerID
WHERE OrderID> ALL
	(SELECT ClassID FROM sm.Student_Class WHERE ClassID=2);
GO
--ANY
SELECT s.StudentID,StudentName,ClassID,SectionID
FROM sm.Students s
JOIN sm.Student_Class sc ON s.StudentID=sc.StudentID
WHERE ClassID< ANY
	(SELECT ClassID FROM sm.Student_Class WHERE ClassID=2);
GO



--------------------------JOIN--------------------------------
Use GroceryManagementSyetem
SELECT CustomerName,City,EmployeeFirstName,EmployeeAddress FROM Customers
JOIN Employees
ON Customers.CustomerID=Employees.EmployeeID
GO

Use GroceryManagementSyetem
SELECT * FROM Customers
INNER JOIN Employees
ON Customers.CustomerID=Employees.EmployeeID
Go


Use GroceryManagementSyetem
SELECT * FROM Customers
OUTER JOIN Employees
ON Customers.CustomerID=Employees.EmployeeID
GO

Use GroceryManagementSyetem
SELECT * FROM Customers
Left JOIN Employees
ON Customers.CustomerID=Employees.EmployeeID


SELECT * FROM Customers
Right JOIN Employees
ON Customers.CustomerID=Employees.EmployeeID



SELECT * 
FROM Employees AS a, Employees AS b
Where a.CustomerID<>b.CustomerID




SELECT * FROM Customers
CROSS JOIN Employees
ON Customers.CustomerID=Employees.EmployeeID



--------------Distinct
Use GroceryManagementSyetem
Select Distinct EmployeeFirstName
From Employees
Go


-------------WildCard
Use GroceryManagementSyetem
Select * From Employees
Where EmployeeFirstname Like 'Fa' 
Go


Use GroceryManagementSyetem
Select * From Customers
Where CustomerName Like 'Fa' 
Go
