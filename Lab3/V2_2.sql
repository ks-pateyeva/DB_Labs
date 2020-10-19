----- lab3 -----

USE [AdventureWorks2012];

GO

--a) выполнить код, созданный во втором задании второй лабораторной работы.
--Добавить в таблицу dbo.PersonPhone поля JobTitle NVARCHAR(50), BirthDate DATE и HireDate DATE.
--Также создайть в таблице вычисляемое поле HireAge, считающее количество лет, прошедших между BirthDate и HireDate.

ALTER TABLE dbo.PersonPhone 
ADD 
	[JobTitle] NVARCHAR(50), 
	[BirthDate] DATE, 
	[HireDate] DATE,
	[HireAge] AS DATEDIFF(YEAR, BirthDate, HireDate);

GO

--b) создайть временную таблицу #PersonPhone, с первичным ключом по полю BusinessEntityID.
--Временная таблица должна включать все поля таблицы dbo.PersonPhone за исключением поля HireAge.

CREATE TABLE #PersonPhone (
	[BusinessEntityID] INT NOT NULL PRIMARY KEY,
	[PhoneNumber] NVARCHAR(25) NULL,
	[PhoneNumberTypeID] INT NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
	[ID] BIGINT NOT NULL,
	[JobTitle] NVARCHAR(50) NULL,
	[BirthDate] DATE NULL,
	[HireDate] DATE NULL
);

--SELECT * FROM #PersonPhone;

GO

--c) заполнить временную таблицу данными из dbo.PersonPhone. Поля JobTitle, BirthDate и HireDate
--заполнить значениями из таблицы HumanResources.Employee. Выбрать только сотрудников с
--JobTitle = ‘Sales Representative’. Выборку данных для вставки в табличную переменную осуществить
--в Common Table Expression (CTE).

WITH PersonPhone_CTE
AS (
	SELECT 
		pp.[BusinessEntityID],
		[PhoneNumber],
		[PhoneNumberTypeID],
		pp.[ModifiedDate],
		[ID],
		e.[JobTitle], 
		e.[BirthDate], 
		e.[HireDate]
	FROM dbo.PersonPhone pp
	INNER JOIN HumanResources.Employee e
	ON e.[BusinessEntityID] = pp.[BusinessEntityID]
	WHERE e.[JobTitle] = 'Sales Representative'
)
INSERT INTO #PersonPhone
SELECT * FROM PersonPhone_CTE;

--SELECT * FROM #PersonPhone;

GO

--d) удалить из таблицы dbo.PersonPhone одну строку (где BusinessEntityID = 275)

DELETE FROM dbo.PersonPhone
WHERE [BusinessEntityID] = 275;

--SELECT * FROM dbo.PersonPhone
--WHERE [BusinessEntityID] = 275;

GO

--e) написать Merge выражение, использующее dbo.PersonPhone как target, а временную таблицу
--как source. Для связи target и source использовать BusinessEntityID. Обновить поля JobTitle,
--BirthDate и HireDate, если запись присутствует и в source и в target. Если строка присутствует
--во временной таблице, но не существует в target, добавить строку в dbo.PersonPhone. Если в dbo.PersonPhone
--присутствует такая строка, которой не существует во временной таблице, удалить строку из dbo.PersonPhone.

SET IDENTITY_INSERT dbo.PersonPhone ON;

GO

-- to check WHEN NOT MATCHED BY SOURCE case
INSERT INTO dbo.PersonPhone (
	[BusinessEntityID],
	[PhoneNumber],
	[PhoneNumberTypeID],
	[ModifiedDate],
	[ID],
	[JobTitle],
	[BirthDate],
	[HireDate]
) VALUES (
	999,
	NULL,
	1,
	GETDATE(),
	1,
	'Job Title',
	GETDATE(),
	GETDATE()
);

GO

--SELECT * FROM dbo.PersonPhone
--WHERE [BusinessEntityID] = 999;

--GO

MERGE dbo.PersonPhone target
USING #PersonPhone source
ON (target.[BusinessEntityID] = source.[BusinessEntityID])

WHEN MATCHED
	THEN UPDATE SET
			target.[JobTitle] = source.[JobTitle],
			target.[BirthDate] = source.[BirthDate],
			target.[HireDate] = source.[HireDate]

WHEN NOT MATCHED BY TARGET
	THEN INSERT (
		[BusinessEntityID],
		[PhoneNumber],
		[PhoneNumberTypeID],
		[ModifiedDate],
		[ID],
		[JobTitle], 
		[BirthDate], 
		[HireDate]
	) VALUES (
		source.[BusinessEntityID],	
		source.[PhoneNumber],
		source.[PhoneNumberTypeID],
		source.[ModifiedDate],
		source.[ID],
		source.[JobTitle], 
		source.[BirthDate], 
		source.[HireDate]
	)

WHEN NOT MATCHED BY SOURCE 
	THEN DELETE;

SET IDENTITY_INSERT dbo.PersonPhone OFF;

GO

--SELECT * FROM dbo.PersonPhone
--WHERE [BusinessEntityID] = 275 OR [BusinessEntityID] = 999;

--GO