USE [CzechOut]

/******************************************************************************
**   Users, Employees & Customers
**/
INSERT INTO Users (
        [Email],
        [PhoneNumber],
        [FirstName],
        [LastName],
        [DateOfBirth],
        [Address],
        [AccountOpen],
        [AccountClose]
    ) VALUES (
        'smellthebacon@royalmail.uk',
        0700000000,
        'Francis',
        'Bacon',
        '1600-01-01',
        'The Strand, London, England',
        '2021-01-01',
        NULL
    )

INSERT INTO Employees ([UserID], [JobTitle]) VALUES (@@IDENTITY, 'Founder')

INSERT INTO Users (
        [Email],
        [PhoneNumber],
        [FirstName],
        [LastName],
        [DateOfBirth],
        [Address],
        [AccountOpen],
        [AccountClose]
    ) VALUES (
        'locke@mail.tld',
        0700000001,
        'Johne',
        'Locke',
        '1600-01-01',
        'England',
        '2021-01-01',
        NULL
    )

INSERT INTO Employees ([UserID], [JobTitle]) VALUES (@@IDENTITY, 'HeadCoach')

INSERT INTO Users (
        [Email],
        [PhoneNumber],
        [FirstName],
        [LastName],
        [DateOfBirth],
        [Address],
        [AccountOpen],
        [AccountClose]
    ) VALUES (
        'czechitout@science.cz',
        0700000002,
        'Jan',
        'Purkyně',
        '1800-01-01',
        'Czechia',
        '2021-01-01',
        NULL
    )

INSERT INTO Employees ([UserID], [JobTitle]) VALUES (@@IDENTITY, 'CasualGenius')

INSERT INTO MemberTypes ([Name], [Description])
    VALUES ('GetSwole-1Month', 'Get Swole - 1 Month Membership')

DECLARE @MemberID INT
SET @MemberID = @@IDENTITY

INSERT INTO Users (
        [Email],
        [PhoneNumber],
        [FirstName],
        [LastName],
        [DateOfBirth],
        [Address],
        [AccountOpen],
        [AccountClose]
    ) VALUES (
        'classicsmith@econ.uk',
        0700000003,
        'Adam',
        'Smith',
        '1700-01-01',
        'England',
        '2021-02-01',
        '2021-03-01'
    )

INSERT INTO Customers ([UserID], [MemberTypeID])
    VALUES (@@IDENTITY, @MemberID)

/******************************************************************************
**   Resources
**/
INSERT INTO Resources VALUES ('SwimmingPool')

INSERT INTO Resources VALUES ('Studio1')
INSERT INTO Resources VALUES ('Studio2')

INSERT INTO Resources VALUES ('Squash1')
INSERT INTO Resources VALUES ('Squash2')
INSERT INTO Resources VALUES ('Squash3')

INSERT INTO Resources VALUES ('TennisIndoor1')
INSERT INTO Resources VALUES ('TennisIndoor2')
INSERT INTO Resources VALUES ('TennisIndoor3')

INSERT INTO Resources VALUES ('TennisOutdoor1')
INSERT INTO Resources VALUES ('TennisOutdoor2')
INSERT INTO Resources VALUES ('TennisOutdoor3')

-- Admin creates exercise class with capacity 15
INSERT INTO Products ([Name], [Quantity], [BeginDateTime], [EndDateTime])
    VALUES ('HIIT', 15, '2021-09-21 10:00:00', '2021-09-21 11:00:00')

-- Admin adds dependency of the class on a fitness studio
INSERT INTO ProductResources ([ProductID], [ResourceID])
    VALUES ([dbo].Get_ProductID('HIIT'), [dbo].Get_ResourceID('Studio1'))

INSERT INTO ProductResources ([ProductID], [ResourceID])
    VALUES ([dbo].Get_ProductID('HIIT'), [dbo].Get_ResourceID('SwimmingPool'))

INSERT INTO Products ([Name], [Quantity], [BeginDateTime], [EndDateTime])
    VALUES ('CardioFit', 15, '2021-09-21 12:00:00', '2021-09-21 12:30:00')

INSERT INTO ProductResources ([ProductID], [ResourceID])
    VALUES (@@IDENTITY, [dbo].Get_ResourceID('Studio1'))

INSERT INTO Products ([Name], [Quantity], [BeginDateTime], [EndDateTime])
    VALUES ('BodyBoost', 15, '2021-09-21 08:00:00', '2021-09-21 10:00:00')

INSERT INTO ProductResources ([ProductID], [ResourceID])
    VALUES (@@IDENTITY, [dbo].Get_ResourceID('Studio1'))

INSERT INTO Products ([Name], [Quantity], [BeginDateTime], [EndDateTime])
    VALUES ('Spinning', 15, '2021-09-21 10:30:00', '2021-09-21 11:30:00')



-- Customer reserves one slot in the class
INSERT INTO Reservations ([UserID], [ProductID], [Quantity])
    VALUES ( [dbo].Get_UserID('smellthebacon@royalmail.uk'), [dbo].Get_ProductID('HIIT'), 1)



-- Test: this won't commit (double-booking of resource)
INSERT INTO ProductResources ([ProductID], [ResourceID])
    VALUES ([dbo].Get_ProductID('Spinning'), [dbo].Get_ResourceID('Studio1'))
