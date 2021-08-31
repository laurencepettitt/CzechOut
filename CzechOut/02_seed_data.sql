-- Author:		Laurence Pettitt
-- Project:		Database Applications (NDBI026)

USE [CzechOut]

/******************************************************************************
**   Users, Employees & Customers
**/
EXEC Add_Employee 
        'smellthebacon@royalmail.uk',
        0700000000,
        'Francis',
        'Bacon',
        '1600-01-01',
        'The Strand, London, England',
        '2021-01-01',
        NULL,
        'Founder'

EXEC Add_Employee
        'locke@mail.tld',
        0700000001,
        'Johne',
        'Locke',
        '1600-01-01',
        'England',
        '2021-01-01',
        NULL,
        'HeadCoach'

EXEC Add_Employee
        'czechitout@science.cz',
        0700000002,
        'Jan',
        'Purkyně',
        '1800-01-01',
        'Czechia',
        '2021-01-01',
        NULL,
        'CasualGenius'

INSERT INTO MemberTypes ([Name], [Description])
    VALUES ('GetSwole-1Month', 'Get Swole - 1 Month Membership')

EXEC ADD_Customer
        'classicsmith@econ.uk',
        0700000003,
        'Adam',
        'Smith',
        '1700-01-01',
        'England',
        '2021-02-01',
        '2022-02-01',
        'GetSwole-1Month'

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
