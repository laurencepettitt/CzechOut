-- Admin creates exercise class with capacity 15
EXEC Add_Product 'HIIT', 15, '2021-09-21 10:00:00', '2021-09-21 11:00:00'

-- Admin adds dependency of the class on a fitness studio
EXEC Add_ProductResource 'HIIT', 'Studio1' 

EXEC Add_ProductResource 'HIIT', 'SwimmingPool'

EXEC Add_Product 'CardioFit', 15, '2021-09-21 12:00:00', '2021-09-21 12:30:00'

EXEC Add_ProductResource 'CardioFit', 'Studio1'

EXEC Add_Product 'BodyBoost', 15, '2021-09-21 08:00:00', '2021-09-21 10:00:00'

EXEC Add_ProductResource 'BodyBoost', 'Studio1'

EXEC Add_Product 'Spinning', 15, '2021-09-21 10:30:00', '2021-09-21 11:30:00'

-- Test: this won't commit (double-booking of resource)
EXEC Add_ProductResource 'Spinning', 'Studio1'

-- Customer reserves one slot in the class
EXEC Add_Reservation 'smellthebacon@royalmail.uk', 'HIIT', 1

