----- lab4 ----
USE [AdventureWorks2012];

GO

--a) —оздайте представление VIEW, отображающее данные из таблиц
--Production.Location и Production.ProductInventory, а также Name
--из таблицы Production.Product. —делайте невозможным просмотр
--исходного кода представлени¤. —оздайте уникальный кластерный
--индекс в представлении по пол¤м LocationID,ProductID.

CREATE VIEW [VI_Product] 
WITH SCHEMABINDING, ENCRYPTION
AS 
	SELECT 
		l.[LocationID],
		l.[Name] AS 'Location_Name',
		[CostRate],
		[Availability],
		l.[ModifiedDate] AS 'Location_ModifiedDate',
		pi.[ProductID],
		[Shelf],
		[Bin],
		[Quantity],
		pi.[rowguid],
		pi.[ModifiedDate] AS 'ProductInventory_ModifiedDate',
		p.[Name] AS 'Product_Name'
	FROM [Production].[Location] l
	INNER JOIN [Production].[ProductInventory] AS pi
		ON l.[LocationID] = pi.[LocationID]
	INNER JOIN [Production].[Product] p
		ON pi.[ProductID] = p.[ProductID];
GO

CREATE UNIQUE CLUSTERED INDEX [IXC_VI_Product_LocationID_ProductID]
	ON [VI_Product] (LocationID, ProductID); 
GO

--b) —оздайте три INSTEAD OF триггера дл¤ представлени¤ на операции
--INSERT, UPDATE, DELETE.  аждый триггер должен выполн¤ть соответствующие
--операции в таблицах Production.Location и Production.ProductInventory
--дл¤ указанного Product Name. ќбновление и удаление строк производите
--только в таблицах Production.Location и Production.ProductInventory,
--но не в Production.Product.

DROP TRIGGER IF EXISTS [TR_Product_INSTEAD_OF_INSERT_DDM];

GO

CREATE TRIGGER [TR_Product_INSTEAD_OF_INSERT_DDM]
ON [VI_Product]
INSTEAD OF INSERT
AS 
BEGIN
	IF NOT EXISTS (
		SELECT * FROM [Production].[Location] l
		INNER JOIN inserted
			ON inserted.[LocationID] = l.LocationID
	)
	BEGIN
		INSERT INTO [Production].[Location] (
			[Name],
			[CostRate],
			[Availability],
			[ModifiedDate])
		SELECT 
			[Location_Name],
			[CostRate],
			[Availability],
			[Location_ModifiedDate]
		FROM inserted
		INNER JOIN [Production].[Product] p
			ON [Product_Name] = p.[Name];
	END;
	ELSE
	BEGIN
		UPDATE [Production].[Location]
			SET
				[Name] = inserted.[Location_Name],
				[CostRate] = inserted.[CostRate],
				[Availability] = inserted.[Availability],
				[ModifiedDate] = inserted.[Location_ModifiedDate]
			FROM inserted
			WHERE [Production].[Location].[LocationID] = inserted.[LocationID];
	END;
	
	INSERT INTO [Production].[ProductInventory] (
		[ProductID],
		[LocationID],
		[Shelf],
		[Bin],
		[Quantity],
		[rowguid],
		[ModifiedDate])
	SELECT
		p.[ProductID],
		l.[LocationID],
		[Shelf],
		[Bin],
		[Quantity],
		inserted.[rowguid],
		[ProductInventory_ModifiedDate]
	FROM inserted
	INNER JOIN [Production].[Product] p
		ON inserted.[Product_Name] = p.[Name]
	INNER JOIN Production.Location l
		ON inserted.[Location_Name] = l.[Name];
END;

GO

DROP TRIGGER IF EXISTS [TR_Product_INSTEAD_OF_UPDATE_DDM];

GO

CREATE TRIGGER [TR_Product_INSTEAD_OF_UPDATE_DDM]
ON [VI_Product]
INSTEAD OF UPDATE
AS 
BEGIN
	UPDATE [Production].[Location]
	SET
		[Name] = inserted.[Location_Name],
		[CostRate] = inserted.[CostRate],
		[Availability] = inserted.[Availability],
		[ModifiedDate] = inserted.[Location_ModifiedDate]
	FROM [Production].[Location] l
	INNER JOIN inserted
		ON inserted.[LocationID] = l.[LocationID];
		
	UPDATE [Production].[ProductInventory]
	SET
		[Shelf] = inserted.[Shelf],
		[Bin] = inserted.[Bin],
		[Quantity] = inserted.[Quantity],
		[rowguid] = inserted.[rowguid],
		[ModifiedDate] = inserted.[ProductInventory_ModifiedDate]
	FROM [Production].[ProductInventory] pi
	INNER JOIN inserted
		ON inserted.[ProductID] = pi.[ProductID];
END;

GO

DROP TRIGGER IF EXISTS [TR_Product_INSTEAD_OF_DELETE_DDM];

GO

CREATE TRIGGER [TR_Product_INSTEAD_OF_DELETE_DDM]
ON [VI_Product]
INSTEAD OF DELETE AS 
BEGIN
	DECLARE @ProductID INT;

	SET @ProductID = (SELECT [ProductID] FROM deleted);

	CREATE TABLE #locations (
		[LocationID] SMALLINT NOT NULL
	);

	INSERT INTO #locations 
	SELECT DISTINCT pi.[LocationID] 
	FROM [Production].[ProductInventory] pi

	INNER JOIN deleted
		ON deleted.[ProductID] = pi.[ProductID]

	WHERE pi.[LocationID] NOT IN (
		SELECT DISTINCT ppi.[LocationID] 
		FROM [Production].[ProductInventory] ppi 
		WHERE ppi.[ProductID] != @ProductID
	); 

	DELETE pi
	FROM [Production].[ProductInventory] pi
	WHERE pi.[ProductID] = @ProductID;

	DELETE l 
	FROM [Production].[Location] l
	WHERE [LocationID] IN (SELECT * FROM #locations);

END

--c) ¬ставьте новую строку в представление, указав новые данные дл¤
--Location и ProductInventory, но дл¤ существующего Product (например дл¤ СAdjustable RaceТ).
--“риггер должен добавить новые строки в таблицы Production.Location и Production.ProductInventory
--дл¤ указанного Product Name. ќбновите вставленные строки через представление. ”далите строки.

----- вставка --------- 
INSERT INTO [VI_Product] (
	[Location_Name],
	[CostRate],
	[Availability],
	[Location_ModifiedDate],
	[Shelf],
	[Bin],
	[Quantity],
	[rowguid],
	[ProductInventory_ModifiedDate],
	[Product_Name]
) VALUES (
	'My Location',
	0,
	0,
	CURRENT_TIMESTAMP,
	'A',
	0,
	0,
	'694215B7-08F7-4C0D-ACB1-D734BA44C0C8',
	CURRENT_TIMESTAMP,
	'Adjustable Race'
);
GO
----- проверка -----
SELECT * FROM [Production].[Location]
WHERE [Name] = 'My Location';
GO

SELECT * FROM [Production].[ProductInventory]
WHERE [ProductID] = 1 AND [ModifiedDate] > CAST(GETDATE() AS DATE);
GO
----- конец проверки ------

---------обновление --------

UPDATE [VI_Product]
SET [CostRate] = 20
WHERE [Product_Name] = 'Adjustable Race'
	AND [Location_ModifiedDate] > CAST(GETDATE() AS DATE);

GO

SELECT
	[Name],
	[CostRate]
FROM [Production].[Location]
WHERE [Name] = 'My Location'
	AND [ModifiedDate] > CAST(GETDATE() AS DATE);

GO

UPDATE [VI_Product]
SET [Quantity] = 1024
WHERE [Product_Name] = 'Adjustable Race'
	AND [ProductInventory_ModifiedDate] > CAST(GETDATE() AS DATE);

GO

SELECT
	[Name],
	[Quantity]
FROM [Production].[ProductInventory] pi
INNER JOIN [Production].[Product] p
	ON pi.[ProductID] = p.[ProductID]
WHERE [Name] = 'Adjustable Race'
	AND pi.[ModifiedDate] > CAST(GETDATE() AS DATE);
GO

DELETE FROM [VI_Product]
WHERE [Product_Name] = 'Adjustable Race'
	AND [Quantity] = 1024 AND [CostRate] = 20;
GO

SELECT * FROM [Production].[Location] l
INNER JOIN [Production].[ProductInventory] i
	ON l.[LocationID] = i.[LocationID]
INNER JOIN [Production].[Product] p
	ON p.[ProductID] = i.[ProductID]
WHERE p.[Name] = 'Adjustable Race';
GO