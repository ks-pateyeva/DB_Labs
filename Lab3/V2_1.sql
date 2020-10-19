----- lab3 -----

USE [AdventureWorks2012];

GO

--a) добавить в таблицу dbo.PersonPhone поле HireDate типа date;

ALTER TABLE dbo.PersonPhone
ADD [HireDate] DATE;

GO

--b) объявить табличную переменную с такой же структурой как dbo.PersonPhone и заполнить ее данными из dbo.PersonPhone.
--Заполнить поле HireDate значениями из поля HireDate таблицы HumanResources.Employee;

DECLARE @PersonPhoneCopy TABLE (
	[BusinessEntityID] INT NOT NULL,
	[PhoneNumber] NVARCHAR(25) NULL,
	[PhoneNumberTypeID] BIGINT NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
	[ID] BIGINT NOT NULL,
	[HireDate] DATE NULL
);

INSERT INTO @PersonPhoneCopy 
	SELECT
		pp.[BusinessEntityID],
		[PhoneNumber],
		[PhoneNumberTypeID],
		pp.[ModifiedDate],
		[ID],
		hre.[HireDate]
	FROM dbo.PersonPhone pp
		JOIN [HumanResources].[Employee] hre
		ON pp.[BusinessEntityID] = hre.[BusinessEntityID];

--SELECT * FROM @PersonPhoneCopy;

--c) обновить HireDate в dbo.PersonPhone данными из табличной переменной, добавив к HireDate один день;

UPDATE dbo.PersonPhone
SET dbo.PersonPhone.[HireDate] = DATEADD(DAY, 1, ppc.[HireDate])
FROM dbo.PersonPhone pp
	JOIN @PersonPhoneCopy AS ppc
	ON pp.[BusinessEntityID] = ppc.[BusinessEntityID]

SELECT * FROM dbo.PersonPhone;

GO

--d) удалить данные из dbo.PersonPhone, для тех сотрудников, у которых почасовая ставка в таблице HumanResources.EmployeePayHistory больше 50;

DELETE FROM dbo.PersonPhone
WHERE EXISTS (
	SELECT
		[BusinessEntityID]
	FROM HumanResources.EmployeePayHistory eph
	WHERE dbo.PersonPhone.[BusinessEntityID] = eph.[BusinessEntityID]
		AND Rate > 50
);

--SELECT * FROM HumanResources.EmployeePayHistory 
--WHERE Rate > 50;

--SELECT * FROM HumanResources.EmployeePayHistory eph
--JOIN dbo.PersonPhone pp
--ON pp.[BusinessEntityID] = eph.[BusinessEntityID]
--WHERE pp.[BusinessEntityID] = eph.[BusinessEntityID]
--	AND Rate > 50

GO

--e) удалить все созданные ограничения и значения по умолчанию. После этого, удалить поле ID.
--Имена ограничений можно найти в метаданных. Имена значений по умолчанию найти самостоятельно, привести код, которым пользовались для поиска;


SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE [TABLE_SCHEMA] = 'dbo'
	AND [TABLE_NAME] = 'PersonPhone';

GO

SELECT * FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE [CONSTRAINT_SCHEMA] = 'dbo'

GO

ALTER TABLE dbo.PersonPhone 
DROP CONSTRAINT
	CHK_PhoneNumber_PersonPhone,
	DF_PhoneNumberTypeID,
	UQ__PersonPh__3214EC26C48700F1;

GO

ALTER TABLE dbo.PersonPhone 
DROP COLUMN [ID];

GO

--f) удалите таблицу dbo.PersonPhone

DROP TABLE dbo.PersonPhone;

GO

--SELECT * FROM dbo.PersonPhone;

--GO