-- Author:		Laurence Pettitt
-- Project:		Database Applications (NDBI026)
-- Description:	Database Application for managing a Sports Centre called CzechOut
--				The application allows registration of Employees and Customers,
--				creation of bookable items such as classes (called Products)
--				management of the Resources required to make the Products possible
--				(e.g. rooms/facilities) and Reservation of users to Products,
--				as well as the deletion/removal/cancellation of the above.
--				The application ensures that Resources are not required by multiple
--				Products at any one time.

USE [CzechOut]

/******************************************************************************
**   Tables
**/

-- Users have personal details.
-- Email and phone number are both unique identifiers (e.g. for login)
-- The account is only valid/active while the date is greater than or equal to
-- AccountOpen and, either less than or equal to AccountClose or AccountClose is NULL.
DROP TABLE IF EXISTS Users
CREATE TABLE Users (
    [UserID] INT IDENTITY
        CONSTRAINT Users_PK PRIMARY KEY,
    [Email] VARCHAR(256) NOT NULL
        CONSTRAINT Users_CHK_Email_Format CHECK([Email] LIKE '_%@_%._%')
        CONSTRAINT Users_U_Email UNIQUE,
    [PhoneNumber] VARCHAR(16) NOT NULL
        CONSTRAINT Users_U_PhoneNumber UNIQUE,
    [FirstName] NVARCHAR(256) NOT NULL,
    [LastName] NVARCHAR(256) NOT NULL,
    [DateOfBirth] DATE NOT NULL,
    [Address] VARCHAR(256) NOT NULL,
    [AccountOpen] DATE NOT NULL DEFAULT GETDATE(),
    [AccountClose] DATE
)

-- Describes the types of memberships that Customers can have
DROP TABLE IF EXISTS MemberTypes
CREATE TABLE MemberTypes (
    [MemberTypeID] INT IDENTITY
        CONSTRAINT MemberTypes_PK PRIMARY KEY,
    [Name] VARCHAR(256) NOT NULL
        CONSTRAINT MemberTypes_U_MemberTypeName UNIQUE,
    [Description] VARCHAR(256)
)

-- Customers are Users which are able to book Products
DROP TABLE IF EXISTS Customers
CREATE TABLE Customers (
    [UserID] INT
        CONSTRAINT Customers_PK PRIMARY KEY
        CONSTRAINT Customers_FK_Users REFERENCES Users([UserID])
            ON DELETE CASCADE,
    [MemberTypeID] INT
        CONSTRAINT Customers_FK_MemberTypes REFERENCES MemberTypes([MemberTypeID])
            ON DELETE SET NULL
)

-- Employees are Users which can create Products and Resources
DROP TABLE IF EXISTS Employees
CREATE TABLE Employees (
    [UserID] INT
        CONSTRAINT Employees_PK PRIMARY KEY
        CONSTRAINT Employees_FK_Users REFERENCES Users([UserID])
            ON DELETE CASCADE,
    [JobTitle] CHAR(256)
)

-- A Resource can be associated with at most one Product at a time
DROP TABLE IF EXISTS Resources
CREATE TABLE Resources (
    [ResourceID] INT IDENTITY
        CONSTRAINT Resources_PK PRIMARY KEY,
    [Name] VARCHAR(256) NOT NULL
        CONSTRAINT Resources_U_Name UNIQUE
)

-- The Product table provides bookable items (e.g. classes and events) which have a capacity (Quantity) and duration
DROP TABLE IF EXISTS Products
CREATE TABLE Products (
    [ProductID] INT IDENTITY
        CONSTRAINT Products_PK PRIMARY KEY,
    [Name] VARCHAR(256)
        CONSTRAINT Products_U_Name UNIQUE,
    [Quantity] INT NOT NULL,
    [BeginDateTime] DATETIME NOT NULL,
    [EndDateTime] DATETIME NOT NULL
)

-- The ProductResources table links Products to their required Resources
DROP TABLE IF EXISTS ProductResources
CREATE TABLE ProductResources (
    [ProductID] INT NOT NULL
        CONSTRAINT ProductResources_FK_Products REFERENCES Products([ProductID])
          ON DELETE CASCADE,
    [ResourceID] INT NOT NULL
        CONSTRAINT ProductResources_FK_Resources REFERENCES Resources([ResourceID])
          ON DELETE NO ACTION, 
	CONSTRAINT ProductResources_PK PRIMARY KEY ([ProductID], [ResourceID])
)

-- The Reservations table allows Users to reserve Products
DROP TABLE IF EXISTS Reservations
CREATE TABLE Reservations (
    [UserID] INT
        CONSTRAINT Reservations_FK_Users REFERENCES Users([UserID])
            ON DELETE CASCADE,
    [ProductID] INT 
        CONSTRAINT Reservations_FK_Product REFERENCES Products([ProductID])
            ON DELETE NO ACTION,
    [Quantity] INT NOT NULL
)


/******************************************************************************
**   Procedures & Functions
**/
GO
CREATE FUNCTION Get_UserID ( @email VARCHAR(256) ) RETURNS INTEGER
    AS BEGIN
        RETURN ( SELECT U.[UserID] FROM Users U WHERE U.[Email]=@email )
    END
GO

GO
CREATE FUNCTION Get_ResourceID ( @name VARCHAR(256) ) RETURNS INTEGER
    AS BEGIN
        RETURN ( SELECT R.[ResourceID] FROM Resources R WHERE R.[Name]=@name )
    END
GO

GO
CREATE FUNCTION Get_ProductID ( @name VARCHAR(256) ) RETURNS INTEGER
    AS BEGIN
        RETURN ( SELECT P.[ProductID] FROM Products P WHERE P.[Name]=@name )
    END
GO

GO
CREATE FUNCTION Get_MemberTypeID ( @name VARCHAR(256) ) RETURNS INTEGER
    AS BEGIN
        RETURN ( SELECT M.[MemberTypeID] FROM MemberTypes M WHERE M.[Name]=@name )
    END
GO

-- Add_Or_Update_Reservation will add a reservation of a product if none exists for the user
-- otherwise @quantity will be added to the already reserved quantity of the product to the user.
GO
CREATE PROCEDURE Add_Or_Update_Reservation
		@email VARCHAR(256), @productName VARCHAR(256), @quantity INT
	AS BEGIN
		BEGIN TRANSACTION
			DECLARE	@productID INT, @userID INT
			SET @userID = [dbo].Get_UserID(@email)
			SET @productID = [dbo].Get_ProductID(@productName)
			IF EXISTS (
				SELECT * FROM Reservations Rs
					WHERE (Rs.[UserID] = @userID)
					AND (Rs.[ProductID] = @productID)
			)
				UPDATE Reservations
					SET [Quantity] = ([Quantity] + @quantity)
					WHERE ([ProductID] = @productID) AND ([UserID] = @userID)
			ELSE
				INSERT INTO Reservations([UserID], [ProductID], [Quantity])
					VALUES (@userID, @productID, @quantity)
		COMMIT TRANSACTION
	END
GO


-- If @productName is not NULL, Remove_Reservation deletes the reservation of @productName,
-- for the user @email. If @productName is NULL, all reservations for the user @email are deleted.
GO
CREATE PROCEDURE Remove_Reservation
		@email VARCHAR(256),
		@productName VARCHAR(256) = NULL
	AS BEGIN
		DELETE FROM Reservations 
			WHERE ([UserID] = [dbo].Get_UserID(@email))
			AND (
				(@productName IS NULL) OR
				([ProductID] = [dbo].Get_ProductID(@productName))
			)
	END
GO

GO
CREATE PROCEDURE Add_Customer
        @email VARCHAR(256), @phoneNumber VARCHAR(16),
		@firstName VARCHAR(256), @lastName VARCHAR(256),
        @dob DATE, @address VARCHAR(256), @accountOpen DATE = DEFAULT,
		@accountClose DATE = NULL, @memberTypeName VARCHAR(256)
    AS BEGIN
		BEGIN TRANSACTION
			INSERT INTO Users (
				[Email], [PhoneNumber], [FirstName], [LastName],
				[DateOfBirth], [Address], [AccountOpen], [AccountClose]
			) VALUES (
				@email, @phoneNumber, @firstName, @lastName,
				@dob, @address, @accountOpen, @accountClose
			)

			INSERT INTO Customers (
				[UserID],
				[MemberTypeID]
			) VALUES (
				@@IDENTITY,
				[dbo].Get_MemberTypeID(@memberTypeName)
			)
		COMMIT TRANSACTION
    END
GO


GO
CREATE PROCEDURE Close_User_Account
		@email VARCHAR(256)
	AS BEGIN
		BEGIN TRANSACTION
			EXEC Remove_Reservation @email
			UPDATE Users
				SET [AccountClose] = GETDATE()
				WHERE [Email] = @email
		COMMIT TRANSACTION
	END
GO

GO
CREATE PROCEDURE Close_Customer_Account
		@email VARCHAR(256)
	AS BEGIN
		EXEC Close_User_Account @email
	END
GO

GO
CREATE PROCEDURE Add_Employee
        @email VARCHAR(256), @phoneNumber VARCHAR(16),
		@firstName VARCHAR(256), @lastName VARCHAR(256),
        @dob DATE, @address VARCHAR(256), @accountOpen DATE = DEFAULT,
		@accountClose DATE = NULL, @jobTitle VARCHAR(256) = NULL
    AS BEGIN
		BEGIN TRANSACTION
			INSERT INTO Users (
				[Email], [PhoneNumber], [FirstName], [LastName],
				[DateOfBirth], [Address], [AccountOpen], [AccountClose]
			) VALUES (
				@email, @phoneNumber, @firstName, @lastName,
				@dob, @address, @accountOpen, @accountClose
			)

			INSERT INTO Employees(
				[UserID],
				[JobTitle]
			) VALUES (
				@@IDENTITY,
				@jobTitle
			)
		COMMIT TRANSACTION
    END
GO

GO
CREATE PROCEDURE Close_Employee_Account
		@email VARCHAR(256)
	AS BEGIN
		EXEC Close_User_Account @email
	END
GO

GO
CREATE PROCEDURE Add_Product
		@name VARCHAR(256), @quantity INT,
		@beginDateTime DATETIME, @endDateTime DATETIME
	AS BEGIN
		INSERT INTO Products ([Name], [Quantity], [BeginDateTime], [EndDateTime])
		VALUES (@name, @quantity, @beginDateTime, @endDateTime)
	END
GO

GO
CREATE PROCEDURE Cancel_Product
		@name VARCHAR(256)
	AS BEGIN
		BEGIN TRANSACTION
			DELETE Rs FROM Reservations Rs
				INNER JOIN Products Ps ON (Ps.ProductID = Rs.ProductID)
				WHERE (Ps.[Name] = @name)
			DELETE FROM Products
				WHERE ([Name] = @name)
		COMMIT TRANSACTION
	END

GO
CREATE PROCEDURE Update_Product_Schedule
		@name VARCHAR(256),
		@beginDateTime DATETIME, @endDateTime DATETIME
	AS BEGIN
		UPDATE Products SET [BeginDateTime] = @beginDateTime, [EndDateTime] = @endDateTime
		WHERE ([Name]=@name)
	END
GO

GO
CREATE PROCEDURE Update_Product_Quantity
		@name VARCHAR(256), @quantity INT
	AS BEGIN
		UPDATE Products SET [Quantity] = @quantity
		WHERE ([Name]=@name)
	END
GO

GO
CREATE PROCEDURE Add_Resource
		@name VARCHAR(256)
	AS BEGIN
		INSERT INTO Resources([Name])
		VALUES ( @name)
	END
GO

GO
CREATE PROCEDURE Add_ProductResource
		@productName VARCHAR(256), @resourceName VARCHAR(256)
	AS BEGIN
		INSERT INTO ProductResources([ProductID], [ResourceID])
		VALUES ([dbo].Get_ProductID(@productName), [dbo].Get_ResourceID(@resourceName))
	END
GO

GO
CREATE PROCEDURE Add_MemberType
		@name VARCHAR(256), @description VARCHAR(256) = NULL
	AS BEGIN
		INSERT INTO MemberTypes([Name], [Description])
		VALUES (@name, @description)
	END
GO

-- Get_Overlaps function takes a productID corresponding to a product P1
-- and returns a table of pairs of products, P1 and P2, such that
-- P1 and P2 both depend upon a common resource with resourceID at the same time.
-- This function can be used in a trigger to check for a double booking of a resource,
-- so the transaction can be rolled back to avoid the double booking.
GO
CREATE FUNCTION Get_Overlaps (@productID INT) RETURNS TABLE
	AS RETURN
		SELECT	P1.ProductID AS P1_ProductID, P1.BeginDateTime AS P1_BeginDateTime, P1.EndDateTime AS P1_EndDateTime,
				PR1.ResourceID,
				P2.ProductID AS P2_ProductID, P2.BeginDateTime AS P2_BeginDateTime, P2.EndDateTime AS P2_EndDateTime FROM
			(SELECT * FROM Products WHERE (Products.ProductID=@productID)) AS P1
			-- Resources required for the product
			INNER JOIN ProductResources AS PR1 ON (P1.ProductID=PR1.ProductID)
			-- Resources required by this product and other products
			INNER JOIN ProductResources AS PR2 ON (PR1.ResourceID=PR2.ResourceID) AND (P1.ProductID<>PR2.ProductID)
			-- Products requiring resources required by this product
			INNER JOIN Products AS P2 ON (PR2.ProductID=P2.ProductID)
			-- Products requiring resources required by this product, with an overlap
			WHERE (
				(P1.BeginDateTime <= P2.BeginDateTime) AND (P1.EndDateTime > P2.BeginDateTime) OR
				(P2.BeginDateTime <= P1.BeginDateTime) AND (P2.EndDateTime > P1.BeginDateTime)
			)
GO

-- Get_OverReservedProducts function takes a productID corresponding to a product P
-- and returns the ReservedQuantity of that 
GO
CREATE FUNCTION Get_ReservedQuantity (@productID INT) RETURNS INT
	AS BEGIN
		DECLARE @res INT
		SELECT @res = SUM(Quantity) FROM Reservations WHERE (@productID=ProductID)
		RETURN @res
	END
GO



/******************************************************************************
**   Views
**/
-- View_ProductsResources shows product data and associated resource data.
GO
CREATE VIEW View_Customers
        AS
            SELECT  Cs.[MemberTypeID],
                            Us.[FirstName],
                            Us.[LastName],
                            Us.[Email],
                            Us.[Address],
                            Us.[PhoneNumber],
                            Us.[DateOfBirth],
                            Us.[AccountOpen],
                            Us.[AccountClose]
                    FROM Customers Cs
                    INNER JOIN Users Us ON (Cs.UserID=Us.UserID)
GO

-- View_Reservations shows product reservations made by users (usually customers)
GO
CREATE VIEW View_Reservations
        AS
            SELECT		Us.[FirstName],
						Us.[LastName],
                        Ps.[Name],
						Rs.[Quantity],
						Ps.[Quantity] AS ProductQuantity
                    FROM Reservations Rs
                    INNER JOIN Users Us ON (Rs.UserID=Us.UserID)
                    INNER JOIN Products Ps ON (Rs.ProductID=Ps.ProductID)
GO

-- View_Products_Reserved_1Week shows products, and their reserved quantity, this week
GO
CREATE VIEW View_Products_Reserved_1Week
        AS
            SELECT		Ps.[Name],
						Ps.[BeginDateTime],
                        Ps.[EndDateTime],
                        Ps.[Quantity],
                        [dbo].Get_ReservedQuantity(Ps.ProductID) AS ReservedQuantity
                    FROM Products AS Ps
                    WHERE Ps.BeginDateTime > GETDATE() AND Ps.[BeginDateTime] < DATEADD(WEEK, 1, GETDATE())
GO

/******************************************************************************
**   Triggers
**/
-- After_INSERT_UDPATE_ProductResources_Schedule ensures that the resource can be used by the product
-- for the product's duration.
GO
CREATE TRIGGER After_INSERT_UDPATE_ProductResources_Schedule ON ProductResources AFTER INSERT, UPDATE
	AS BEGIN
		IF EXISTS (
			SELECT * FROM [dbo].Get_Overlaps((SELECT i.ProductID FROM inserted AS i)) 
		)
		BEGIN
			RAISERROR('One or more resources are not available in the period specified for this product.', 15, 1)
			ROLLBACK TRANSACTION
		END
	END
GO

-- After_UDPATE_Products_Schedule ensures that after a product is updated, it's resources are available
-- in the period specified by BeginDateTime and EndDateTime (in case it was changed),
GO
CREATE TRIGGER After_UDPATE_Products_Schedule ON Products AFTER UPDATE
	AS BEGIN
		IF EXISTS (
			SELECT * FROM [dbo].Get_Overlaps((SELECT i.ProductID FROM inserted AS i)) 
		)
		BEGIN
			RAISERROR('One or more resources are not available in the period specified for this product.', 15, 1)
			ROLLBACK TRANSACTION
		END
	END
GO

-- After_UDPATE_Products_Quantity ensures that the Quantity is not less than the sum
-- of the Quantities of its reservations.
GO
CREATE TRIGGER After_UDPATE_Products_Quantity ON Products AFTER UPDATE
	AS BEGIN
		IF EXISTS (
			SELECT * FROM inserted AS i WHERE i.Quantity < [dbo].Get_ReservedQuantity(i.ProductID)
		)
		BEGIN
			RAISERROR('The specified product Quantity is less than the amount already reserved.', 15, 1)
			ROLLBACK TRANSACTION
		END
	END
GO

-- After_INSERT_UDPATE_Reservations ensures that after a reservation is inserted or updated, 
-- the total reserved quantity is not above the product's quantity.
GO
CREATE TRIGGER After_INSERT_UDPATE_Reservations ON Reservations AFTER INSERT, UPDATE
	AS BEGIN
		IF EXISTS (
			SELECT * FROM inserted AS i
			INNER JOIN Products P on (i.ProductID=P.ProductID)
			WHERE P.Quantity < [dbo].Get_ReservedQuantity(P.ProductID)
		)
		BEGIN
			RAISERROR('This product is at capacity.', 15, 1)
			ROLLBACK TRANSACTION
		END
	END
GO
