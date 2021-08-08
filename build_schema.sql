
/******************************************************************************
**   Database
**/
-- TODO: Remove this from final version


/******************************************************************************
**   Tables
**/
DROP TABLE IF EXISTS Users

CREATE TABLE Users (
    UserID INT IDENTITY
        CONSTRAINT Users_PK PRIMARY KEY,
    Email VARCHAR(64) NOT NULL
        CONSTRAINT Users_CHK_Email_Format CHECK(Email LIKE '_%@_%._%')
        CONSTRAINT Users_U_Email UNIQUE,
    PhoneNumber VARCHAR(16) NOT NULL
        CONSTRAINT Users_U_PhoneNumber UNIQUE,
    FirstName NVARCHAR(64) NOT NULL,
    LastName NVARCHAR(64) NOT NULL,
    DateOfBirth DATE NOT NULL,
    ResidenceAddress VARCHAR(128) NOT NULL,
    AccountOpen DATE NOT NULL DEFAULT GETDATE(),
    AccountClose DATE
)

DROP TABLE IF EXISTS MemberTypes

CREATE TABLE MemberTypes (
    MemberTypeID INT IDENTITY
        CONSTRAINT MemberTypes_PK PRIMARY KEY,
    MemberTypeName VARCHAR(32) NOT NULL
        CONSTRAINT MemberTypes_U_MemberTypeName UNIQUE,
    MemberTypeDescription VARCHAR(256)
)

DROP TABLE IF EXISTS Customers

CREATE TABLE Customers (
    UserID INT
        CONSTRAINT Customers_PK PRIMARY KEY
        CONSTRAINT Customers_FK_Users REFERENCES Users(UserID)
            ON DELETE CASCADE,
    MemberTypeID INT
        CONSTRAINT Customers_FK_MemberTypes REFERENCES MemberTypes(MemberTypeID)
            ON DELETE SET NULL
)

DROP TABLE IF EXISTS Employees

CREATE TABLE Employees (
    UserID INT
        CONSTRAINT Employees_PK PRIMARY KEY
        CONSTRAINT Employees_FK_Users REFERENCES Users(UserID)
            ON DELETE CASCADE,
    JobTitle CHAR(32)
)

DROP TABLE IF EXISTS Resources

CREATE TABLE Resources (
    ResourceID INT IDENTITY
        CONSTRAINT Resources_PK PRIMARY KEY,
    ResourceName VARCHAR(64) NOT NULL
        CONSTRAINT Resources_U_ResourceName UNIQUE -- TODO: is UNIQUE efficient?
    -- TODO: Availability
)

DROP TABLE IF EXISTS Products

CREATE TABLE Products (
    ProductID INT IDENTITY
        CONSTRAINT Products_PK PRIMARY KEY,
    ProductName VARCHAR(64),
    IsPublic BIT NOT NULL DEFAULT 0
)

DROP TABLE IF EXISTS ResourceReservations

CREATE TABLE ResourceReservations (
    ResourceID INT
        CONSTRAINT ResourceReservations_FK_Resources REFERENCES Resources(ResourceID),
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME NOT NULL
    -- TODO: Associate resources to products?
    -- ForProduct INT NOT NULL
    --     CONSTRAINT ResourceReservations_FK_Products REFERENCES Products(ProductID),
    -- PRIMARY KEY (ResourceID, StartDateTime, EndDateTime)
)

/******************************************************************************
**   Procedures
**/
GO
CREATE FUNCTION Get_ResourceID ( @name CHARACTER varying(64) ) RETURNS INTEGER
    AS BEGIN
        RETURN ( SELECT R.ResourceID FROM Resources R WHERE R.ResourceName=@name )
    END
GO