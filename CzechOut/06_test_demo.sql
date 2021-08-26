-- Author:		Laurence Pettitt
-- Project:		Database Applications (NDBI026)

USE [CzechOut]

-- Admin creates exercise class with capacity 15 which uses Studio1 and SwimmingPool
EXEC Add_Product 'HIIT', 15, '2021-09-21 10:00:00', '2021-09-21 11:00:00'
EXEC Add_ProductResource 'HIIT', 'Studio1' 
EXEC Add_ProductResource 'HIIT', 'SwimmingPool'

-- Admin creates CardioFit class which uses Studio1, but at a different timne to HIIT
EXEC Add_Product 'CardioFit', 15, '2021-09-21 12:00:00', '2021-09-21 12:30:00'
EXEC Add_ProductResource 'CardioFit', 'Studio1'

-- Admin creates BodyBoost class which ends at the same time as HIIT and also uses Studio1
EXEC Add_Product 'BodyBoost', 15, '2021-09-21 08:00:00', '2021-09-21 10:00:00'
EXEC Add_ProductResource 'BodyBoost', 'Studio1'

-- Admin creates Spinning class which overlaps HIIT
EXEC Add_Product 'Spinning', 15, '2021-09-21 10:30:00', '2021-09-21 11:30:00'
-- So this won't work (double-booking of Studio1)
GO
	EXEC Add_ProductResource 'Spinning', 'Studio1'
GO
-- But this will work fine
EXEC Add_ProductResource 'Spinning', 'Studio2'

-- Let's create another product using Studio2, which doesn't overlap anything
EXEC ADD_Product 'FitX', 15, '2021-10-21 10:30:00', '2021-10-21 11:30:00'
EXEC Add_ProductResource 'FitX', 'Studio2'

SELECT	Ps.[Name] AS ProductName, Ps.[Quantity], Ps.[BeginDateTime], Ps.[EndDateTime],
		Rs.[Name] AS ResourceName
	FROM Products Ps
	INNER JOIN ProductResources PRs ON (Ps.[ProductID] = PRs.[ProductID])
	INNER JOIN Resources Rs ON (PRs.[ResourceID] = Rs.[ResourceID])

-- We cannot move FitX so that it overlaps Spinning because they both use Studio2
GO
	EXEC Update_Product_Schedule 'FitX', '2021-09-21 10:30:00', '2021-09-21 11:30:00'
GO

SELECT * FROM Products

-- Let's say we want to cancel Spinning, to move FitX in it's place
-- But someone reserves a slot in Spinning
EXEC Add_Or_Update_Reservation 'smellthebacon@royalmail.uk', 'Spinning', 1
-- Then we cannot delete the Spinning class
GO
	DELETE FROM Products WHERE ([Name] = 'Spinning')
GO

SELECT * FROM Products

-- But we can delete it with the stored procedure (which deletes reservations first)
EXEC Cancel_Product 'Spinning'
EXEC Update_Product_Schedule 'FitX', '2021-09-21 10:30:00', '2021-09-21 11:30:00'

SELECT * FROM Products

-- User reserves one slot in the HIIT class
EXEC Add_Or_Update_Reservation 'smellthebacon@royalmail.uk', 'HIIT', 1

-- User reserves 14 slots in the class
EXEC Add_Or_Update_Reservation 'classicsmith@econ.uk', 'HIIT', 14

--  Now class is at capacity
SELECT * FROM View_Reservations WHERE ([Name] = 'HIIT')
SELECT [dbo].Get_ReservedQuantity([dbo].Get_ProductID('HIIT')) AS ReservedQuantity
SELECT Quantity FROM Products WHERE ([Name] = 'HIIT')

-- No more slots can be reserved
GO
EXEC Add_Or_Update_Reservation 'czechitout@science.cz', 'HIIT', 1
GO
EXEC Add_Or_Update_Reservation 'smellthebacon@royalmail.uk', 'HIIT', 1
GO

-- Let's add a class which will happen this week and reserve two places in it
DECLARE @beginP DATETIME, @endP DATETIME
SET @beginP = DATEADD(HOUR, 10, GETDATE())
SET @endP = DATEADD(HOUR, 11, GETDATE())
EXEC Add_Product 'CalisthenicsStarter', 8, @beginP, @endP
EXEC Add_Or_Update_Reservation 'czechitout@science.cz', 'CalisthenicsStarter', 2

-- And we see that it shows in the view correctly
SELECT * FROM View_Products_Reserved_1Week
