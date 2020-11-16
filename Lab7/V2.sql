--------------- lab7--------------

USE [AdventureWorks2012];

GO

--Вывести значения полей [ProductID], [Name], [ProductNumber] из таблицы [Production].[Product]
--в виде xml, сохраненного в переменную. Создать хранимую процедуру, возвращающую таблицу,
--заполненную из xml переменной представленного вида. Вызвать эту процедуру для заполненной
--на первом шаге переменной.

DECLARE @Product XML;
SET @Product = ( 
	SELECT
		ProductID AS [@ID],
		[Name],
		[ProductNumber]
	FROM [Production].[Product]
	WHERE [ProductID] = 1 OR [ProductID] = 2
	FOR XML PATH('Product'), ROOT('Products')
);

SELECT @Product;

--EXECUTE [dbo].[usp_GetProductFromXML] @Product;

GO


IF EXISTS (
	SELECT * FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[usp_GetProductFromXML]') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1
)
	DROP PROCEDURE [dbo].[usp_GetProductFromXML];

GO

CREATE PROCEDURE [dbo].[usp_GetProductFromXML]
(
	@Product XML
)
AS
BEGIN
	DECLARE @hdoc INT;
	EXEC sp_xml_preparedocument @hdoc OUTPUT, @Product;
	SELECT * FROM OPENXML(@hdoc, '/Products/Product', 2)
	WITH (
		[ProductID] INT '@ID',
		[Name] NVARCHAR(50),
		[ProductNumber] NVARCHAR(25)
	);

	EXEC sp_xml_removedocument @hdoc;
END;

GO