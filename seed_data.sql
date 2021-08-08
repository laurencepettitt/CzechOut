
/******************************************************************************
**   Users, Employees & Customers
**/
INSERT INTO Users (
        Email,
        PhoneNumber,
        FirstName,
        LastName,
        DateOfBirth,
        ResidenceAddress,
        AccountOpen,
        AccountClose
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

INSERT INTO Employees (UserID, JobTitle) VALUES (@@IDENTITY, 'Founder')

INSERT INTO Users (
        Email,
        PhoneNumber,
        FirstName,
        LastName,
        DateOfBirth,
        ResidenceAddress,
        AccountOpen,
        AccountClose
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

INSERT INTO Employees (UserID, JobTitle) VALUES (@@IDENTITY, 'HeadCoach')

INSERT INTO Users (
        Email,
        PhoneNumber,
        FirstName,
        LastName,
        DateOfBirth,
        ResidenceAddress,
        AccountOpen,
        AccountClose
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

INSERT INTO Employees (UserID, JobTitle) VALUES (@@IDENTITY, 'CasualGenius')

INSERT INTO MemberTypes (MemberTypeName, MemberTypeDescription)
    VALUES ('GetSwole-1Month', 'Get Swole - 1 Month Membership')

DECLARE @MemberID INT
SET @MemberID = @@IDENTITY

INSERT INTO Users (
        Email,
        PhoneNumber,
        FirstName,
        LastName,
        DateOfBirth,
        ResidenceAddress,
        AccountOpen,
        AccountClose
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

INSERT INTO Customers (UserID, MemberTypeID)
    VALUES (@@IDENTITY, @MemberID)

/******************************************************************************
**   Resources
**/
INSERT INTO Resources VALUES ('SwimmingPool')

INSERT INTO Resources VALUES ('Studio1')
INSERT INTO Resources VALUES ('Studio2')
INSERT INTO Resources VALUES ('Studio3')

INSERT INTO Resources VALUES ('Squash1')
INSERT INTO Resources VALUES ('Squash2')
INSERT INTO Resources VALUES ('Squash3')

INSERT INTO Resources VALUES ('IndoorTennis1')
INSERT INTO Resources VALUES ('IndoorTennis2')
INSERT INTO Resources VALUES ('IndoorTennis3')

INSERT INTO Resources VALUES ('TennisOutdoor1')
INSERT INTO Resources VALUES ('TennisOutdoor2')
INSERT INTO Resources VALUES ('TennisOutdoor3')

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

INSERT INTO ResourceReservations (ResourceID, StartDateTime, EndDateTime)
    VALUES (
        [dbo].Get_ResourceID('Studio1'),
        '2021-08-08 10:00:00',
        '2021-08-08 11:00:00'
    )
    -- TODO: Associate resources to products?
