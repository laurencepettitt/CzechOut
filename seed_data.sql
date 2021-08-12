
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
INSERT INTO Resources VALUES ('SwimmingPool', 1)

INSERT INTO Resources VALUES ('Studio', 3)

INSERT INTO Resources VALUES ('Squash', 3)

INSERT INTO Resources VALUES ('TennisIndoor', 3)

INSERT INTO Resources VALUES ('TennisOutdoor', 3)

-- INSERT INTO ResourceReservations (ResourceID, StartDateTime, EndDateTime)
--     SELECT res.ResourceID, val.StartDateTime, val.EndDateTime
--         FROM (
--             VALUES (
--                 'Studio1',
--                 '2021-08-08 10:00:00',
--                 '2021-08-08 11:00:00'
--                 -- TODO: Associate resources to products?
--             )
--         ) val (ResourceName, StartDateTime, EndDateTime)
--         LEFT JOIN Resources res USING (ResourceName)


-- Admin creates exercise class with capacity 15
INSERT INTO Products ([Name], [Quantity], [BeginDateTime], [EndDateTime])
    VALUES ('HIIT', 15, '2021-09-21 10:00:00', '2021-09-21 11:00:00')

-- Admin adds dependency of the class on a fitness studio
INSERT INTO ProductResources ([ProductID], [ResourceID], [Quantity])
    VALUES (@@IDENTITY, [dbo].Get_ResourceID('Studio'), 1)

-- Customer reserves one slot in the class
INSERT INTO Reservations ([UserID], [ProductID], [Quantity])
    VALUES ( [dbo].Get_UserID('smellthebacon@royalmail.uk'), [dbo].Get_ProductID('HIIT'), 1)
