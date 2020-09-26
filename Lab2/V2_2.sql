USE [AdventureWorks2012];
GO

-- a) �������� ������� dbo.PersonPhone � ����� �� ����������
-- ��� Person.PersonPhone, �� ������� �������, ����������� � ��������;

CREATE TABLE dbo.[PersonPhone] (
	[BusinessEntityID] INT NOT NULL,
	[PhoneNumber] NVARCHAR(25) NOT NULL,
	[PhoneNumberTypeID] INT NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
);

GO

-- b) ��������� ���������� ALTER TABLE, �������� � ������� dbo.PersonPhone
-- ����� ���� ID, ������� �������� ���������� ������������ UNIQUE ����
-- bigint � ����� �������� identity. ��������� �������� ��� ���� identity
-- ������� 2 � ���������� ������� 2;

ALTER TABLE dbo.[PersonPhone]
ADD [ID] bigint identity(2, 2) UNIQUE;

GO

-- c) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.PersonPhone
-- ����������� ��� ���� PhoneNumber, ����������� ���������� ����� ���� �������;

ALTER TABLE dbo.[PersonPhone]
ADD CONSTRAINT CHK_PhoneNumber_PersonPhone
	CHECK (PATINDEX('%[a-zA-Z]%', [PhoneNumber]) = 0);
GO

-- d) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.PersonPhone
-- ����������� DEFAULT ��� ���� PhoneNumberTypeID, ������� �������� �� ��������� 1;

ALTER TABLE dbo.[PersonPhone]
ADD CONSTRAINT df_PhoneNumberTypeID
	DEFAULT 1 FOR [PhoneNumberTypeID];

GO

-- e) ��������� ����� ������� ������� �� Person.PersonPhone, ��� ���� PhoneNumber
-- �� �������� �������� �(� � �)� � ������ ��� ��� �����������, ������� ����������
-- � ������� HumanResources.Employee, � �� ���� �������� �� ������ ��������� � �����
-- ������ ������ � ������;

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

-- f) �������� ���� PhoneNumber, �������� ���������� null ��������.

ALTER TABLE dbo.[PersonPhone]
ALTER COLUMN [PhoneNumber] nvarchar(25) null;

GO

 