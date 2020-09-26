USE [AdventureWorks2012];
GO

-- ������� 2

-- ������� �� ����� ������� ����������, ������� �������� �� �������
-- �Purchasing Manager�. � ����� ������� �������� �� �������, �
-- ��������� �������� ������ � ������ ������.

SELECT
	e.[BusinessEntityID],
	[JobTitle],
	d.[Name] AS 'DepartmentName',
	[StartDate],
	[EndDate]
FROM [HumanResources].[Employee] e

JOIN [HumanResources].[EmployeeDepartmentHistory] edh
	ON e.[BusinessEntityID] = edh.[BusinessEntityID]
JOIN [HumanResources].[Department] d 
	ON edh.[DepartmentID] = d.[DepartmentID]
WHERE
	[JobTitle] = 'Purchasing Manager';

GO

-- ������� �� ����� ������ �����������, � ������� ��������� ������
-- ���������� ���� �� ���� ���.

SELECT
	e.[BusinessEntityID],
	[JobTitle],
	COUNT(*) AS 'RateCount'
FROM [HumanResources].[Employee] e

JOIN [HumanResources].[EmployeePayHistory] eph
	ON e.[BusinessEntityID] = eph.[BusinessEntityID]
GROUP BY
	e.[BusinessEntityID],
	[JobTitle]
HAVING COUNT(*) > 1;

GO

-- ������� �� ����� ������������ ��������� ������ � ������ ������.
-- ������� ������ ���������� ����������. ���� ��������� ������ ��
-- �������� � ������ � �� ��������� ����� ������.

SELECT
	d.[DepartmentID],
	[Name],
	MAX(eph.[Rate]) AS 'MaxRate'
FROM [HumanResources].[Department] d

JOIN [HumanResources].[EmployeeDepartmentHistory] edh
	ON edh.[DepartmentID] = d.[DepartmentID]
JOIN [HumanResources].[EmployeePayHistory] eph
	ON eph.[BusinessEntityID] = edh.[BusinessEntityID]

WHERE
	[EndDate] is NULL
	
GROUP BY
	d.[DepartmentID],
	[Name];
GO