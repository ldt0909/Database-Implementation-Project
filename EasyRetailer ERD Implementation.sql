CREATE DATABASE "EasyRetailer";
GO
USE "EasyRetailer";

CREATE TABLE CustomerType
	(TypeID INT NOT NULL PRIMARY KEY,
	TypeName VARCHAR(30)
	);

CREATE TABLE Customer
	(CustomerID INT NOT NULL PRIMARY KEY,	
	CustomerNumber VARCHAR(40) NOT NULL,
	CustomerName VARCHAR(50) NOT NULL,
	PhoneNumber1 VARCHAR(20) NOT NULL,
	PhoneNumber2 VARCHAR(20),
	EmailAddress1 VARCHAR(30),
	EmailAddress2 VARCHAR(30),
	CreditCheckFlag VARCHAR(10),
	TypeID INT NOT NULL FOREIGN KEY REFERENCES CustomerType(TypeID)
	);

CREATE TABLE CustomerAddress
	(AddressID INT NOT NULL PRIMARY KEY,
	AddressType VARCHAR(30) NOT NULL,
	CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
	AddressLine1 VARCHAR(50),
	AddressLine2 VARCHAR(50),
	City VARCHAR(20),
	State VARCHAR(20),
	Country VARCHAR(20),
	Zipcode VARCHAR(10),
	County VARCHAR(10),
	);

CREATE TABLE CustomerAccountInfo
	(AccountID INT NOT NULL PRIMARY KEY,
	CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
	AddressID INT NOT NULL FOREIGN KEY REFERENCES CustomerAddress(AddressID),
	AccountType VARCHAR (20),
	AccountNumber VARCHAR (20),
	AccountName VARCHAR (20),
	ExpirationDate DATE NOT NULL
	);

CREATE TABLE Tax
	(TaxID INT NOT NULL PRIMARY KEY,
	TaxName VARCHAR(20),
	TaxRate FLOAT
	);

CREATE TABLE Offer
	(OfferID INT NOT NULL PRIMARY KEY,
	OfferStartDate DATE,
	OfferEndDate DATE,
	CreationDate DATE,
	UpdationDate DATE,
	OfferType VARCHAR(20),
	OfferValue VARCHAR(100),
	);

CREATE TABLE Shipping
	(ShippingID INT NOT NULL PRIMARY KEY,
	ShippingNumber VARCHAR(20),
	ShippingStatus VARCHAR(20),
	ShippingType VARCHAR(20),
	EstimatedShippingDate DATE NOT NULL,
	CreationDate DATE,
	UpdationDate DATE,
	ServiceProvider VARCHAR(20)
	);

CREATE TABLE Supplier
	(SupplierID INT NOT NULL PRIMARY KEY,
	SupplierName VARCHAR(20) NOT NULL,
	Location VARCHAR(30) NOT NULL,
	CreationDate DATE,
	UpdationDate DATE
	);

CREATE TABLE ProductCategory
	(CategoryID INT NOT NULL PRIMARY KEY,
	CategoryNumber INT NOT NULL,
	Description VARCHAR(30),
	CreationDate DATE,
	UpdationDate DATE
	);

CREATE TABLE Product
	(ProductID INT NOT NULL PRIMARY KEY,
	ProductNumber INT NOT NULL,
	Type VARCHAR(20) NOT NULL,
	Name VARCHAR(20) NOT NULL,
	CategoryID INT NOT NULL REFERENCES ProductCategory(CategoryID),
	CreationDate DATE,
	UpdationDate DATE,
	ProductWeight FLOAT,
	ProductSize FLOAT,
	Description VARCHAR(50),
	Comment VARCHAR(70),
	ManufacturerName VARCHAR(20)
	);

CREATE TABLE Inventory
	(InventoryID INT NOT NULL PRIMARY KEY,
	CategoryID INT NOT NULL REFERENCES ProductCategory(CategoryID),
	ProductID INT NOT NULL REFERENCES Product(ProductID),
	Quantity INT,
	CreationDate DATE,
	UpdationDate DATE,
	Status VARCHAR(15) NOT NULL,
	SupplierID INT NOT NULL REFERENCES Supplier(SupplierID)
	);

CREATE TABLE InventoryLocation
	(LocationID INT NOT NULL PRIMARY KEY,
	InventoryID INT NOT NULL REFERENCES Inventory(InventoryID),
	AddressLine1 VARCHAR(30),
	AddressLine2 VARCHAR(30),
	City VARCHAR(15),
	State VARCHAR(15),
	Country VARCHAR(15),
	Zipcode VARCHAR(10),
	County VARCHAR(15)
	);

CREATE TABLE Pricing
	(PriceID INT NOT NULL PRIMARY KEY,
	Price FLOAT NOT NULL,
	ProductID INT NOT NULL REFERENCES Product(ProductID),
	CategoryID INT NOT NULL REFERENCES ProductCategory(CategoryID),
	PriceType VARCHAR(100) NOT NULL
	);

CREATE TABLE SellersAccountInfo
	(AccountID INT NOT NULL PRIMARY KEY,
	AccountNumber INT NOT NULL,
	AccountName VARCHAR(20) NOT NULL,
	LegerID INT NOT NULL,
	LegerName VARCHAR(20) NOT NULL,
	CreationDate DATE,
	UpdationDate DATE,
	Amount FLOAT
	);

CREATE TABLE dbo.OrderHeader
	(OrderID INT NOT NULL PRIMARY KEY,
	CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
	TaxID INT FOREIGN KEY REFERENCES Tax(TaxID),
	TotalPrice FLOAT NOT NULL,
	ShipToAddress VARCHAR(40),
	BillToAddress VARCHAR(40),
	OrderCreationDate DATE NOT NULL,
	OrderUpdationDate DATE,
	OrderStatus VARCHAR(10),
	ShippingID INT FOREIGN KEY REFERENCES Shipping(ShippingID),
	ShippingFee FLOAT,
	EstimatedDate DATE,
	AccountID INT NOT NULL FOREIGN KEY REFERENCES CustomerAccountInfo(AccountID),
	OfferID INT NOT NULL FOREIGN KEY REFERENCES Offer(OfferID)		
	);

CREATE TABLE dbo.OrderLines
	(LineID INT NOT NULL PRIMARY KEY,
	OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
	ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
	InventoryID INT NOT NULL FOREIGN KEY REFERENCES Inventory(InventoryID),
	Quantity VARCHAR(20),
	PriceID INT NOT NULL FOREIGN KEY REFERENCES Pricing(PriceID),
	Price FLOAT,
	LineStatus VARCHAR(20),
	ProductNumber VARCHAR(20)
	);

CREATE VIEW OpenOrders
AS
select oh.OrderID, cust.CustomerName,cust.CustomerNumber,custType.TypeName,
oh.TotalPrice,oh.OrderStatus,cust.EmailAddress1 as EmailAddress,
offer.OfferValue,ship.ShippingNumber,ShippingStatus,ship.ShippingType
from OrderHeader oh,Customer cust,Offer offer,CustomerType custType,shipping ship
where oh.OrderStatus='Open'
and cust.CustomerID=oh.CustomerID
and offer.OfferID=oh.OfferID
and custType.TypeID=cust.TypeID
and ship.ShippingID=oh.ShippingID


CREATE VIEW ProductDetails
AS
select prod.Name,pcat.Description,prod.ManufacturerName,prod.ProductWeight , 
invent.Status,invent.Quantity,supp.SupplierName 
from Product prod, ProductCategory pcat,Inventory invent, Supplier supp
where pcat.CategoryID=prod.CategoryID
and invent.ProductID=prod.ProductID
and supp.SupplierID=invent.SupplierID

CREATE VIEW TotalRevenue
as
select Amount as TotalRevenueAmount from SellersAccountInfo s
where s.AccountName='RevenueAccount'

CREATE VIEW Expenses
as
select Amount as ExpenseAmount from SellersAccountInfo s
where s.AccountName='DebitAccount'

CREATE VIEW Profit
as
select Amount as ProfitAmount from SellersAccountInfo s
where s.AccountName='CreditAccount'
