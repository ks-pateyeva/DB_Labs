USE [AdventureWorks2012];
GO

-- ВАРИАНТ 2

-- Вывести на экран историю сотрудника, который работает на позиции
-- ‘Purchasing Manager’. В каких отделах компании он работал, с
-- указанием периодов работы в каждом отделе.

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

-- Вывести на экран список сотрудников, у которых почасовая ставка
-- изменялась хотя бы один раз.

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

-- Вывести на экран максимальную почасовую ставку в каждом отделе.
-- Вывести только актуальную информацию. Если сотрудник больше не
-- работает в отделе — не учитывать такие данные.

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