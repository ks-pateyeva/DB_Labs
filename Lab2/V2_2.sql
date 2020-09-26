USE [AdventureWorks2012];
GO

-- a) создайте таблицу dbo.PersonPhone с такой же структурой
-- как Person.PersonPhone, не включая индексы, ограничения и триггеры;

CREATE TABLE dbo.[PersonPhone] (
	[BusinessEntityID] INT NOT NULL,
	[PhoneNumber] NVARCHAR(25) NOT NULL,
	[PhoneNumberTypeID] INT NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
);

GO

-- b) используя инструкцию ALTER TABLE, добавьте в таблицу dbo.PersonPhone
-- новое поле ID, которое является уникальным ограничением UNIQUE типа
-- bigint и имеет свойство identity. Начальное значение для поля identity
-- задайте 2 и приращение задайте 2;

ALTER TABLE dbo.[PersonPhone]
ADD [ID] bigint identity(2, 2) UNIQUE;

GO

-- c) используя инструкцию ALTER TABLE, создайте для таблицы dbo.PersonPhone
-- ограничение для поля PhoneNumber, запрещающее заполнение этого поля буквами;

ALTER TABLE dbo.[PersonPhone]
ADD CONSTRAINT CHK_PhoneNumber_PersonPhone
	CHECK (PATINDEX('%[a-zA-Z]%', [PhoneNumber]) = 0);
GO

-- d) используя инструкцию ALTER TABLE, создайте для таблицы dbo.PersonPhone
-- ограничение DEFAULT для поля PhoneNumberTypeID, задайте значение по умолчанию 1;

ALTER TABLE dbo.[PersonPhone]
ADD CONSTRAINT df_PhoneNumberTypeID
	DEFAULT 1 FOR [PhoneNumberTypeID];

GO

-- e) заполните новую таблицу данными из Person.PersonPhone, где поле PhoneNumber
-- не содержит символов ‘(‘ и ‘)’ и только для тех сотрудников, которые существуют
-- в таблице HumanResources.Employee, а их дата принятия на работу совпадает с датой
-- начала работы в отделе;

INSERT INTO dbo.[PersonPhone]
	SELECT 
		pp.[BusinessEntityID],
		[PhoneNumber],
		[PhoneNumberTypeID],
		pp.[ModifiedDate]
	FROM Person.[PersonPhone] pp

	JOIN HumanResources.[Employee] e
		ON e.[BusinessEntityID] = pp.[BusinessEntityID]
	JOIN HumanResources.[EmployeeDepartmentHistory] edh
		ON edh.[BusinessEntityID] = e.[BusinessEntityID]

	WHERE
		[PhoneNumber] not like '%[()]%'
		and [StartDate] = [HireDate];

GO

SELECT [BusinessEntityID]
      ,[PhoneNumber]
      ,[PhoneNumberTypeID]
      ,[ModifiedDate]
      ,[ID]
  FROM [dbo].[PersonPhone];

GO

-- f) измените поле PhoneNumber, разрешив добавление null значений.

ALTER TABLE dbo.[PersonPhone]
ALTER COLUMN [PhoneNumber] nvarchar(25) null;

GO

 