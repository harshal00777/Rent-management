-- Create a new database for Rent Management System
CREATE DATABASE RentManagementDB;
GO

USE RentManagementDB;
GO

-- Create a table for storing Tenant information
CREATE TABLE Tenants (
    TenantID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(15),
    JoinDate DATETIME DEFAULT GETDATE()
);
GO

-- Create a table for storing Property information
CREATE TABLE Properties (
    PropertyID INT PRIMARY KEY IDENTITY(1,1),
    PropertyName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    RentAmount DECIMAL(10, 2) NOT NULL,  -- Monthly rent for the property
    OwnerName NVARCHAR(100) NOT NULL
);
GO

-- Create a table for storing Rent Payments
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    TenantID INT,
    PropertyID INT,
    PaymentDate DATETIME DEFAULT GETDATE(),
    Amount DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(50) CHECK (Status IN ('Paid', 'Pending')),
    FOREIGN KEY (TenantID) REFERENCES Tenants(TenantID),
    FOREIGN KEY (PropertyID) REFERENCES Properties(PropertyID)
);
GO

-- Create a procedure to record Rent Payment
CREATE PROCEDURE RecordRentPayment
    @TenantID INT,
    @PropertyID INT,
    @Amount DECIMAL(10, 2)
AS
BEGIN
    DECLARE @RentAmount DECIMAL(10, 2);

    -- Get the Rent Amount for the Property
    SELECT @RentAmount = RentAmount FROM Properties WHERE PropertyID = @PropertyID;

    -- Ensure the amount is equal to or greater than the Rent Amount
    IF @Amount < @RentAmount
    BEGIN
        RAISERROR('Payment is less than the rent amount. Payment not recorded.', 16, 1);
        RETURN;
    END

    -- Insert payment record into Payments table
    INSERT INTO Payments (TenantID, PropertyID, Amount, Status)
    VALUES (@TenantID, @PropertyID, @Amount, 'Paid');

    PRINT 'Rent payment recorded successfully!';
END;
GO

-- Create a trigger to prevent overpayment (if more than rent is paid)
CREATE TRIGGER trg_PreventOverpayment
ON Payments
AFTER INSERT
AS
BEGIN
    DECLARE @Amount DECIMAL(10, 2);
    DECLARE @RentAmount DECIMAL(10, 2);
    DECLARE @TenantID INT;
    DECLARE @PropertyID INT;

    SELECT @Amount = Amount, @TenantID = TenantID, @PropertyID = PropertyID FROM inserted;
    SELECT @RentAmount = RentAmount FROM Properties WHERE PropertyID = @PropertyID;

    IF @Amount > @RentAmount
    BEGIN
        RAISERROR('Overpayment detected. Payment amount is greater than the rent.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Insert some sample tenants into the Tenants table
INSERT INTO Tenants (FirstName, LastName, Email, Phone) VALUES
('Amit', 'Patel', 'amit.patel@gmail.com', '9876543210'),
('Riya', 'Sharma', 'riya.sharma@example.com', '9123456789'),
('Karan', 'Singh', 'karan.singh@yahoo.com', '9234567890');
GO

-- Insert some sample properties into the Properties table
INSERT INTO Properties (PropertyName, Address, RentAmount, OwnerName) VALUES
('Sea View Apartment', 'Mumbai, Worli, India', 25000.00, 'Rajesh Mehta'),
('City Center Flat', 'Mumbai, Andheri, India', 30000.00, 'Pooja Desai'),
('Garden Villa', 'Mumbai, Bandra, India', 40000.00, 'Sanjay Gupta');
GO

-- Record Rent Payments for tenants
EXEC RecordRentPayment @TenantID = 1, @PropertyID = 1, @Amount = 25000.00; -- Amit paid for Sea View Apartment
EXEC RecordRentPayment @TenantID = 2, @PropertyID = 2, @Amount = 30000.00; -- Riya paid for City Center Flat
EXEC RecordRentPayment @TenantID = 3, @PropertyID = 3, @Amount = 40000.00; -- Karan paid for Garden Villa
GO

-- Sample Query: Get the payment history for each tenant
SELECT t.FirstName, t.LastName, p.PropertyName, pay.Amount, pay.PaymentDate, pay.Status
FROM Payments pay
JOIN Tenants t ON pay.TenantID = t.TenantID
JOIN Properties p ON pay.PropertyID = p.PropertyID
ORDER BY pay.PaymentDate DESC;
GO

-- Sample Query: Check total payment collected for each property
SELECT p.PropertyName, SUM(pay.Amount) AS TotalCollected
FROM Payments pay
JOIN Properties p ON pay.PropertyID = p.PropertyID
GROUP BY p.PropertyName;
GO

-- Sample Query: Get tenants with overdue payments (Payments still pending)
SELECT t.FirstName, t.LastName, p.PropertyName, pay.Amount
FROM Payments pay
JOIN Tenants t ON pay.TenantID = t.TenantID
JOIN Properties p ON pay.PropertyID = p.PropertyID
WHERE pay.Status = 'Pending'
ORDER BY t.LastName;
GO
