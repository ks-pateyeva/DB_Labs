----- lab3 -----

USE [AdventureWorks2012];

GO

--a) �������� � ������� dbo.PersonPhone ���� HireDate ���� date;

ALTER TABLE dbo.PersonPhone
ADD [HireDate] DATE;

GO

--b) �������� ��������� ���������� � ����� �� ���������� ��� dbo.PersonPhone � ��������� �� ������� �� dbo.PersonPhone.
--��������� ���� HireDate ���������� �� ���� HireDate ������� HumanResources.Employee;

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

--c) �������� HireDate � dbo.PersonPhone ������� �� ��������� ����������, ������� � HireDate ���� ����;

UPDATE dbo.PersonPhone
SET dbo.PersonPhone.[HireDate] = DATEADD(DAY, 1, ppc.[HireDate])
FROM dbo.PersonPhone pp
	JOIN @PersonPhoneCopy AS ppc
	ON pp.[BusinessEntityID] = ppc.[BusinessEntityID]

SELECT * FROM dbo.PersonPhone;

GO

--d) ������� ������ �� dbo.PersonPhone, ��� ��� �����������, � ������� ��������� ������ � ������� HumanResources.EmployeePayHistory ������ 50;

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

--e) ������� ��� ��������� ����������� � �������� �� ���������. ����� �����, ������� ���� ID.
--����� ����������� ����� ����� � ����������. ����� �������� �� ��������� ����� ��������������, �������� ���, ������� ������������ ��� ������;


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

--f) ������� ������� dbo.PersonPhone

DROP TABLE dbo.PersonPhone;

GO

--SELECT * FROM dbo.PersonPhone;

--GO