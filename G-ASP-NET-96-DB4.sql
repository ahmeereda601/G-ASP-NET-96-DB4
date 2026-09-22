/* 
   ONLINE RETAIL SYSTEM
   */


-- 0. CREATE TABLES (لازم تتنفذ الأول)


CREATE TABLE Customers (
    CustomerId INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    ShippingAddress VARCHAR(200),
    RegistrationDate DATE
);

CREATE TABLE Suppliers (
    SupplierId INT PRIMARY KEY IDENTITY(1,1),
    SupplierName VARCHAR(100) NOT NULL
);

CREATE TABLE Categories (
    CategoryId INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Products (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT DEFAULT 0
);

CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY(1,1),
    CustomerId INT,
    TotalAmount DECIMAL(10,2),
    Status VARCHAR(50),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

CREATE TABLE OrderItems (
    OrderItemId INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT,
    ProductId INT,
    Quantity INT,
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

CREATE TABLE Reviews (
    ReviewId INT PRIMARY KEY IDENTITY(1,1),
    ProductId INT,
    Rating DECIMAL(3,2),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

CREATE TABLE StockTransactions (
    TranId INT PRIMARY KEY IDENTITY(1,1),
    ProductId INT,
    QuantityChange INT,
    TranDate DATE,
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);


-- 1. INSERT OPERATIONS


-- Insert a new Customer
INSERT INTO Customers
    (FullName, PhoneNumber, Email, ShippingAddress, RegistrationDate)
VALUES
    ('Ahmed Hassan', '01012345678', 'ahmed@example.com',
     'Cairo, Egypt', CAST(GETDATE() AS DATE));

-- Insert 3 new Suppliers
INSERT INTO Suppliers (SupplierName)
VALUES
    ('ABC Electronics'),
    ('Global Supplies'),
    ('Cairo Trading');

-- Insert 2 Categories
INSERT INTO Categories (CategoryName)
VALUES
    ('Electronics'),
    ('Home Appliances');

-- Insert a Product using only Name and UnitPrice
INSERT INTO Products (Name, UnitPrice)
VALUES ('Wireless Mouse', 450.00);

-- Create ArchivedStock table
CREATE TABLE ArchivedStock (
    TranId INT,
    ProductId INT,
    QuantityChange INT,
    TranDate DATE
);

-- Insert all StockTransactions before 2023
INSERT INTO ArchivedStock (TranId, ProductId, QuantityChange, TranDate)
SELECT TranId, ProductId, QuantityChange, TranDate
FROM StockTransactions
WHERE TranDate < '2023-01-01';


-- 2. TEMPORARY TABLES


-- Create #CustomerOrders
CREATE TABLE #CustomerOrders (
    OrderId INT,
    CustomerId INT,
    TotalAmount DECIMAL(10,2)
);

-- Insert customers/orders above 5000
INSERT INTO #CustomerOrders (OrderId, CustomerId, TotalAmount)
SELECT OrderId, CustomerId, TotalAmount
FROM Orders
WHERE TotalAmount > 5000;

-- Create ##TopRatedProducts
CREATE TABLE ##TopRatedProducts (
    ProductId INT,
    Rating DECIMAL(3,2)
);

-- Insert products with rating >= 4.5
INSERT INTO ##TopRatedProducts (ProductId, Rating)
SELECT ProductId, Rating
FROM Reviews
WHERE Rating >= 4.5;

 
-- 3. UPDATE OPERATIONS
 

-- Increase UnitPrice by 10% for products under 100 EGP
UPDATE Products
SET UnitPrice = UnitPrice * 1.10
WHERE UnitPrice < 100;

-- Update Order Status
UPDATE Orders
SET Status =
    CASE
        WHEN TotalAmount > 5000 THEN 'Premium'
        ELSE 'Standard'
    END;


-- 4. DELETE OPERATIONS


-- Delete a Review by ReviewId
DELETE FROM Reviews WHERE ReviewId = 10;

-- Delete all cancelled Orders
DELETE FROM Orders WHERE Status = 'Cancelled';

-- Delete OrderItems for a given OrderId
DELETE FROM OrderItems WHERE OrderId = 1001;


-- 5. MERGE OPERATION


-- Create #ProductsUpdate
CREATE TABLE #ProductsUpdate (
    ProductId INT,
    Name VARCHAR(100),
    UnitPrice DECIMAL(10,2),
    StockQuantity INT
);

-- Example data
INSERT INTO #ProductsUpdate (ProductId, Name, UnitPrice, StockQuantity)
VALUES
    (1,   'Laptop',      25000, 15),
    (2,   'Keyboard',     800, 30),
    (999, 'New Product', 1200, 20);

-- MERGE Products
MERGE Products AS Target
USING #ProductsUpdate AS Source
ON Target.ProductId = Source.ProductId

WHEN MATCHED THEN
    UPDATE SET
        Target.Name = Source.Name,
        Target.UnitPrice = Source.UnitPrice,
        Target.StockQuantity = Source.StockQuantity

WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductId, Name, UnitPrice, StockQuantity)
    VALUES (Source.ProductId, Source.Name, Source.UnitPrice, Source.StockQuantity)

WHEN NOT MATCHED BY SOURCE THEN
    DELETE;


/*
   HOTEL SYSTEM
  */


-- 0. CREATE TABLES


CREATE TABLE Guests (
    GuestId INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(100) NOT NULL,
    Nationality VARCHAR(50),
    PassportNumber VARCHAR(50),
    DateOfBirth DATE
);

CREATE TABLE Rooms (
    RoomId INT PRIMARY KEY IDENTITY(1,1),
    RoomType VARCHAR(50),
    DailyRate DECIMAL(10,2)
);

CREATE TABLE Reservations (
    ReservationId INT PRIMARY KEY IDENTITY(1,1),
    CheckinDate DATE,
    CheckoutDate DATE,
    ReservationStatus VARCHAR(50)
);

CREATE TABLE Reservation_Guest (
    ReservationId INT,
    GuestId INT,
    FOREIGN KEY (ReservationId) REFERENCES Reservations(ReservationId),
    FOREIGN KEY (GuestId) REFERENCES Guests(GuestId)
);

CREATE TABLE Staff (
    StaffId INT PRIMARY KEY,
    FullName VARCHAR(100),
    Position VARCHAR(100),
    Salary DECIMAL(10,2)
);


-- 1. INSERT OPERATIONS


-- Insert one Guest
INSERT INTO Guests (FullName, Nationality, PassportNumber, DateOfBirth)
VALUES ('Mohamed Ali', 'Egyptian', 'A12345678', '1995-05-20');

-- Insert multiple Guests
INSERT INTO Guests (FullName, Nationality, PassportNumber, DateOfBirth)
VALUES
    ('John Smith',  'American', 'US123456', '1988-03-15'),
    ('Sara Ahmed',  'Egyptian', 'E987654',  '1992-11-10'),
    ('David Brown', 'British',  'GB456789', '1985-07-25');

-- 2. UPDATE OPERATIONS


-- Increase DailyRate by 15% for all Suites
UPDATE Rooms
SET DailyRate = DailyRate * 1.15
WHERE RoomType = 'Suite';

-- Update ReservationStatus
UPDATE Reservations
SET ReservationStatus =
    CASE
        WHEN CheckoutDate < CAST(GETDATE() AS DATE) THEN 'Completed'
        WHEN CheckinDate  > CAST(GETDATE() AS DATE) THEN 'Upcoming'
        ELSE 'Active'
    END;

 
-- 3. DELETE OPERATIONS
 

-- Delete Reservation_Guest for a reservation
DELETE FROM Reservation_Guest
WHERE ReservationId = 1001;

-- 4. MERGE OPERATION

 

-- Create #StaffUpdates
CREATE TABLE #StaffUpdates (
    StaffId INT,
    FullName VARCHAR(100),
    Position VARCHAR(100),
    Salary DECIMAL(10,2)
);

-- Example data
INSERT INTO #StaffUpdates (StaffId, FullName, Position, Salary)
VALUES
    (1,   'Ahmed Hassan', 'Manager',      15000),
    (2,   'Sara Ali',     'Receptionist',  8000),
    (999, 'Omar Khaled',  'Chef',         10000);

-- MERGE Staff
MERGE Staff AS Target
USING #StaffUpdates AS Source
ON Target.StaffId = Source.StaffId

WHEN MATCHED THEN
    UPDATE SET
        Target.Position = Source.Position,
        Target.Salary   = Source.Salary

WHEN NOT MATCHED BY TARGET THEN
    INSERT (StaffId, FullName, Position, Salary)
    VALUES (Source.StaffId, Source.FullName, Source.Position, Source.Salary)

WHEN NOT MATCHED BY SOURCE THEN
    DELETE;