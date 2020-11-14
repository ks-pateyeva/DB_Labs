------LAB 5---------
USE [AdventureWorks2012];

GO

--Создайте scalar-valued функцию, которая будет принимать в качестве входного
--параметра id отдела (HumanResources.Department.DepartmentID) и возвращать
--количество сотрудников, работающих в отделе.

CREATE FUNCTION [HumanResources].[ufn_GetDepartmentEmploeeCount](@DepartmentID smallint)
RETURNS int
AS
BEGIN
	DECLARE @ret int;
	SELECT @ret = COUNT(*)
	FROM [HumanResources].[EmployeeDepartmentHistory] edh
	WHERE edh.[DepartmentID] = @DepartmentID AND edh.[EndDate] IS NULL

	RETURN @ret;
END;

GO
---------- ПРОВЕРКА ------------

PRINT [HumanResources].[ufn_GetDepartmentEmploeeCount](10);

GO

--SELECT COUNT(*) FROM [HumanResources].[EmployeeDepartmentHistory] edh
--WHERE edh.[DepartmentID] = 10 AND edh.[EndDate] IS NULL;

--GO

SELECT * FROM [HumanResources].[EmployeeDepartmentHistory] edh
WHERE edh.[DepartmentID] = 10 AND edh.[EndDate] IS NULL;

GO


--Создайте inline table-valued функцию, которая будет принимать в качестве
--входного параметра id отдела (HumanResources.Department.DepartmentID), а
--возвращать сотрудников, которые работают в отделе более 11 лет.

CREATE FUNCTION [HumanResources].[ufnGetMoreElevenYearsInDepartmentEmployees] (@DepartmentID smallint)
RETURNS TABLE
AS
	RETURN (
		SELECT * FROM [HumanResources].[EmployeeDepartmentHistory]
		WHERE
			[DepartmentID] = @DepartmentID
			AND DATEDIFF(YEAR, [StartDate], GETDATE()) > 11
			AND [EndDate] IS NULL
	);

GO

----------проверка-----------

SELECT * FROM [HumanResources].[ufnGetMoreElevenYearsInDepartmentEmployees](10);

GO

SELECT * FROM [HumanResources].[EmployeeDepartmentHistory]
WHERE
	[DepartmentID] = 10
	AND DATEDIFF(YEAR, [StartDate], GETDATE()) > 11
	AND [EndDate] IS NULL;
GO

--Вызовите функцию для каждого отдела, применив оператор CROSS APPLY.
--Вызовите функцию для каждого отдела, применив оператор OUTER APPLY.

SELECT 
	d.[DepartmentID],
	[BusinessEntityID],
	[Name],
	[GroupName],
	[ShiftID],
	[StartDate], 
	[EndDate],
	d.[ModifiedDate]
FROM [HumanResources].[Department] d
CROSS APPLY [HumanResources].[ufnGetMoreElevenYearsInDepartmentEmployees](d.[DepartmentID])
ORDER BY d.[DepartmentID];

GO

SELECT 
d.[DepartmentID],
	[BusinessEntityID],
	[Name],
	[GroupName],
	[ShiftID],
	[StartDate], 
	[EndDate],
	d.[ModifiedDate]
FROM [HumanResources].[Department] AS d
OUTER APPLY [HumanResources].ufnGetMoreElevenYearsInDepartmentEmployees(d.DepartmentID)
ORDER BY d.[DepartmentID]

GO

--Измените созданную inline table-valued функцию, сделав ее multistatement table-valued
--(предварительно сохранив для проверки код создания inline table-valued функции).

DROP FUNCTION IF EXISTS [HumanResources].[ufnGetMoreElevenYearsInDepartmentEmployees];

GO

CREATE FUNCTION [HumanResources].[ufnGetMoreElevenYearsInDepartmentEmployees] (@DepartmentID smallint)
RETURNS @e TABLE (
	[DepartmentID] SMALLINT NOT NULL,
	[BusinessEntityID] INT NOT NULL,
	[ShiftID] TINYINT NOT NULL,
	[StartDate] DATE NOT NULL, 
	[EndDate] DATE NULL,
	[ModifiedDate] DATETIME NOT NULL
) AS
	BEGIN
	INSERT INTO @e
		SELECT * FROM [HumanResources].[EmployeeDepartmentHistory]
			WHERE
				[DepartmentID] = @DepartmentID
				AND DATEDIFF(YEAR, [StartDate], GETDATE()) > 11
				AND [EndDate] IS NULL
	RETURN;
END;

GO

-------- проверка ------------

SELECT * FROM [HumanResources].[ufnGetMoreElevenYearsInDepartmentEmployees](10)

GO