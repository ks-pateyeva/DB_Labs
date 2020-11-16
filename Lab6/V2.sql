--------------- lab6--------------

USE [AdventureWorks2012];

GO

--Создайте хранимую процедуру, котора¤ будет возвращать сводную
--таблицу (оператор PIVOT), отображающую данные о максимальном
--весе (Production.Product.Weight) продукта в каждой подкатегории
--(Production.ProductSubcategory) для определенного цвета. Список
--цветов передайте в процедуру через входной параметр.

IF EXISTS (
	SELECT * FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[usp_GetProductSubcategoryMaxWeightByColor]') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1
)
	DROP PROCEDURE [dbo].[usp_GetProductSubcategoryMaxWeightByColor]

GO

CREATE PROCEDURE [dbo].[usp_GetProductSubcategoryMaxWeightByColor]
(
	@colors NVARCHAR(MAX)
)
AS
BEGIN
	EXECUTE('SELECT Name, ' + @colors + ' FROM (
				SELECT
					ps.[Name],
					p.[Weight],
					p.[Color]
				FROM [Production].[Product] p
				INNER JOIN [Production].[ProductSubcategory] ps
					ON ps.[ProductSubcategoryID] = p.[ProductSubcategoryID]
			) s
			PIVOT
			(
				MAX(Weight)
			FOR Color IN (' + @colors + ')) as pvt');
END

----------ПРОВЕРКА-----------
EXECUTE [dbo].[usp_GetProductSubcategoryMaxWeightByColor] '[Black],[Silver],[Yellow]';

GO