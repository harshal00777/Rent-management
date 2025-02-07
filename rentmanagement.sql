CREATE DATABASE RentManagementDB;
GO

USE RentManagementDB;
GO

CREATE TABLE Tenants (
    TenantID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(15),
    JoinDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Properties (
    PropertyID INT PRIMARY KEY IDENTITY(1,1),
    PropertyName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    RentAmount DECIMAL(10, 2) NOT NULL,
    OwnerName NVARCHAR(100) NOT NULL
);
GO

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

CREATE PROCEDURE RecordRentPayment
    @TenantID INT,
    @PropertyID INT,
    @Amount DECIMAL(10, 2)
AS
BEGIN
    DECLARE @RentAmount DECIMAL(10, 2);

    SELECT @RentAmount = RentAmount FROM Properties WHERE PropertyID = @PropertyID;

    IF @Amount < @RentAmount
    BEGIN
        RAISERROR('Payment is less than the rent amount. Payment not recorded.', 16, 1);
        RETURN;
    END

    INSERT INTO Payments (TenantID, PropertyID, Amount, Status)
    VALUES (@TenantID, @PropertyID, @Amount, 'Paid');

    PRINT 'Rent payment recorded successfully!';
END;
GO

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

INSERT INTO Tenants (FirstName, LastName, Email, Phone) VALUES
('Amit', 'Patel', 'amit.patel@gmail.com', '9876543210'),
('Riya', 'Sharma', 'riya.sharma@example.com', '9123456789'),
('Karan', 'Singh', 'karan.singh@yahoo.com', '9234567890');
GO

INSERT INTO Properties (PropertyName, Address, RentAmount, OwnerName) VALUES
('Sea View Apartment', 'Mumbai, Worli, India', 25000.00, 'Rajesh Mehta'),
('City Center Flat', 'Mumbai, Andheri, India', 30000.00, 'Pooja Desai'),
('Garden Villa', 'Mumbai, Bandra, India', 40000.00, 'Sanjay Gupta');
GO

EXEC RecordRentPayment @TenantID = 1, @PropertyID = 1, @Amount = 25000.00;
EXEC RecordRentPayment @TenantID = 2, @PropertyID = 2, @Amount = 30000.00;
EXEC RecordRentPayment @TenantID = 3, @PropertyID = 3, @Amount = 40000.00;
GO

SELECT t.FirstName, t.LastName, p.PropertyName, pay.Amount, pay.PaymentDate, pay.Status
FROM Payments pay
JOIN Tenants t ON pay.TenantID = t.TenantID
JOIN Properties p ON pay.PropertyID = p.PropertyID
ORDER BY pay.PaymentDate DESC;
GO

SELECT p.PropertyName, SUM(pay.Amount) AS TotalCollected
FROM Payments pay
JOIN Properties p ON pay.PropertyID = p.PropertyID
GROUP BY p.PropertyName;
GO

SELECT t.FirstName, t.LastName, p.PropertyName, pay.Amount
FROM Payments pay
JOIN Tenants t ON pay.TenantID = t.TenantID
JOIN Properties p ON pay.PropertyID = p.PropertyID
WHERE pay.Status = 'Pending'
ORDER BY t.LastName;
GO
