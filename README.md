# Rent Management System (Mumbai, India)

## Overview:
This Rent Management System helps manage rental payments for properties in Mumbai, India. The system allows landlords and tenants to track rent payments, view payment histories, and prevent overpayments. The database contains tables for tenants, properties, and payments, along with stored procedures and triggers for validating and recording rent payments.

## Features:
- **Tenant Management**: Store and manage tenant information, including personal details like name, email, and phone number.
- **Property Management**: Track available rental properties, including rent amounts, locations, and property owners.
- **Payment Tracking**: Record rent payments and ensure that the correct amount is paid (no underpayment or overpayment).
- **Overdue Payments**: Query to view tenants with pending payments.
- **Total Payments Collected**: Query to view the total rent collected for each property.
  
## Technology Stack:
- **SQL Server**: For database and query management.
- **Stored Procedures**: To handle rent payment logic and validation.
- **Triggers**: To prevent overpayment.

## Database Schema:
- **Tenants**: Stores tenant details.
- **Properties**: Stores property details such as rent amount and owner.
- **Payments**: Tracks rent payments, payment status, and payment amounts.

## Setup Instructions:
1. Clone the repository.
2. Open the `.sql` file in SQL Server Management Studio (SSMS).
3. Run the script to create the database and tables.
4. Use the provided stored procedures to insert and manage tenant and property data.

## Sample Queries:
- Get Payment History
- Check Total Payment Collected for each Property
- View Tenants with Overdue Payments
