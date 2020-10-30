--------- lab4 ----------

USE AdventureWorks2012;

GO

--a) Создайте таблицу Production.LocationHst, которая будет хранить информацию об изменениях в таблице Production.Location.
--обязательные поля, которые должны присутствовать в таблице: ID Ч первичный ключ IDENTITY(1,1);
--Action Ч совершенное действие (insert, update или delete); ModifiedDate Ч дата и время, когда была совершена операция;
--SourceID Ч первичный ключ исходной таблицы; UserName Ч имя пользователя, совершившего операцию. 

CREATE TABLE [Production].[LocationHst] (
	[ID] INT IDENTITY(1, 1) PRIMARY KEY,
	[Action] NVARCHAR(6) NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
	[SourceID] SMALLINT NOT NULL, 
	[UserName] NVARCHAR(30) NOT NULL
);

GO

--b) создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE для таблицы Production.Location.
--триггер должен заполнять таблицу Production.LocationHst с указанием типа операции в поле Action в зависимости
--от оператора, вызвавшего триггер.

CREATE TRIGGER [TR_Production_Location_AFTER_DML]
ON Production.Location
AFTER INSERT, UPDATE, DELETE   
AS
	-- UPDATE
	IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		INSERT INTO Production.LocationHst
		SELECT 'update',
				CURRENT_TIMESTAMP,
				[LocationID],
				CURRENT_USER
		FROM inserted
	END
	-- INSERT
	ELSE IF EXISTS (SELECT * FROM inserted)
	BEGIN
		INSERT INTO Production.LocationHst 
		SELECT 'insert',
				CURRENT_TIMESTAMP,
				[LocationID],
				CURRENT_USER
		FROM inserted
	END
	-- DELETE
	ELSE IF EXISTS (SELECT * FROM deleted)
	BEGIN
		INSERT INTO Production.LocationHst
		SELECT 'delete',
				CURRENT_TIMESTAMP,
				[LocationID],
				CURRENT_USER
		FROM deleted;
	END;

GO

------- проверка --------

------- на вставку -------
INSERT INTO [Production].[Location] (
	[Name], 
	[CostRate], 
	[Availability], 
	[ModifiedDate]
) VALUES (
	'test',
	0,
	0,
	CURRENT_TIMESTAMP
);

GO

------- на обновление -------
UPDATE [Production].[Location] 
SET [Name] = 'test_update' WHERE [LocationID] = 61;	

GO

-------удаление--------
DELETE FROM [Production].[Location]
WHERE [LocationID] = 61;

GO

--c) создайте представление VIEW, отображающее все поля таблицы Production.Location.

CREATE VIEW [VI_Production_Location]
AS 
	SELECT * FROM [Production].[Location];

GO

--d) вставьте новую строку в Production.Location через представление. обновите вставленную строку. удалите вставленную строку.
--”бедитесь, что все три операции отображены в Production.LocationHst.

---- вставка -----
INSERT INTO [VI_Production_Location] (
	[Name], 
	[CostRate], 
	[Availability], 
	[ModifiedDate]
) VALUES (
	'test view',
	0,
	0,
	CURRENT_TIMESTAMP
);	

GO

 --- проверка ---
DECLARE @SourceID smallint;
SET @SourceID = (
	SELECT [LocationID] FROM [Production].[Location]
	WHERE [Name] = 'test view'
);

--SELECT * FROM [VI_Production_Location]
--WHERE [LocationID] = @SourceID;

--SELECT * FROM [Production].[LocationHst]
--WHERE [SourceID] = @SourceID;

-------- обновление ---------

UPDATE [VI_Production_Location]
SET [Name] = 'TEST VIEW UPDATE' WHERE [LocationID] = @SourceID;

-------- проверка-----------
SELECT * FROM [VI_Production_Location]
WHERE [LocationID] = @SourceID;

GO;

DECLARE @SourceID smallint;
SET @SourceID = (
	SELECT [LocationID] FROM [Production].[Location]
	WHERE [Name] = 'TEST VIEW UPDATE'
);

--SELECT * FROM [Production].[LocationHst]
--WHERE [SourceID] = @SourceID;

------ удаление ---------
DELETE FROM [VI_Production_Location]
WHERE [LocationID] = @SourceID;

-------- проверка -----------
--SELECT * FROM [VI_Production_Location]
--WHERE [LocationID] = @SourceID;

SELECT * FROM [Production].[LocationHst]
WHERE [SourceID] = @SourceID;

GO;