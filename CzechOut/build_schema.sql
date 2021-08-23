-- TODO: set schema
USE [CzechOut]
-- schema [dbo]

/******************************************************************************
**   Tables
**/
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

DROP TABLE IF EXISTS MemberTypes

CREATE TABLE MemberTypes (
    [MemberTypeID] INT IDENTITY
        CONSTRAINT MemberTypes_PK PRIMARY KEY,
    [Name] VARCHAR(256) NOT NULL
        CONSTRAINT MemberTypes_U_MemberTypeName UNIQUE,
    [Description] VARCHAR(256)
)

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

DROP TABLE IF EXISTS Employees

CREATE TABLE Employees (
    [UserID] INT
        CONSTRAINT Employees_PK PRIMARY KEY
        CONSTRAINT Employees_FK_Users REFERENCES Users([UserID])
            ON DELETE CASCADE,
    [JobTitle] CHAR(256)
)

DROP TABLE IF EXISTS Resources

CREATE TABLE Resources (
    [ResourceID] INT IDENTITY
        CONSTRAINT Resources_PK PRIMARY KEY,
    [Name] VARCHAR(256) NOT NULL
        CONSTRAINT Resources_U_Name UNIQUE -- TODO: is UNIQUE efficient?
)

DROP TABLE IF EXISTS Products

CREATE TABLE Products (
    [ProductID] INT IDENTITY
        CONSTRAINT Products_PK PRIMARY KEY,
    [Name] VARCHAR(256)
        CONSTRAINT Products_U_Name UNIQUE, -- TODO: is UNIQUE efficient?
    [Quantity] INT NOT NULL,
    [BeginDateTime] DATETIME NOT NULL,
    [EndDateTime] DATETIME NOT NULL
)

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

DROP TABLE IF EXISTS Reservations

CREATE TABLE Reservations (
    [UserID] INT
        CONSTRAINT Reservations_FK_Users REFERENCES Users([UserID])
            ON DELETE CASCADE,
    [ProductID] INT 
        CONSTRAINT Reservations_FK_Product REFERENCES Products([ProductID])
            ON DELETE NO ACTION,
    [Quantity] INT NOT NULL
    -- [BeginDateTime] DATETIME NOT NULL,
    -- [EndDateTime] DATETIME NOT NULL
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

GO
CREATE PROCEDURE Add_Member
        @email VARCHAR(256), @phoneNumber VARCHAR(16), @firstName VARCHAR(256), @lastName VARCHAR(256),
        @dob DATE, @address VARCHAR(256), @accountOpen DATE = DEFAULT, @accountClose DATE = NULL, @memberTypeName VARCHAR(256)
    AS BEGIN
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
    END
GO

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

/******************************************************************************
**   Views
**/
GO
CREATE VIEW View_ProductsResources
	AS
		SELECT  Ps.ProductID,
				Ps.BeginDateTime,
				Ps.EndDateTime,
				Rs.[ResourceID]
			FROM Resources Rs
			INNER JOIN ProductResources AS PRs ON (Rs.ResourceID=PRs.ResourceID)
			INNER JOIN Products AS Ps ON (PRs.ProductID=Ps.ProductID)
GO

/******************************************************************************
**   Procedures & Functions
**/
GO
CREATE TRIGGER After_UDPATE_ProductResources ON ProductResources AFTER INSERT, UPDATE
	AS BEGIN
		IF EXISTS (
			SELECT * FROM [dbo].Get_Overlaps((SELECT i.ProductID FROM inserted AS i)) 
		)
		BEGIN
			RAISERROR('One or more resources are not available in the period specified to create this product.', 15, 1)
			ROLLBACK TRANSACTION
		END
	END
GO

SELECT * FROM [dbo].Get_Overlaps(
	(	
		SELECT T1.ProductID FROM (
			VALUES ([dbo].Get_ProductID('HIIT'), [dbo].Get_ResourceID('Studio1'))
		) AS T1 ([ProductID], [ResourceID])
	)
)

SELECT * FROM Products
SELECT * FROM ProductResources
SELECT * FROM Resources
