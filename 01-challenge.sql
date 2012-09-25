/*
1.  Find Second Highest salary for each department.  All second highest for each department should be listed.
*/
DECLARE @Employees TABLE(
	EmployeeID INT IDENTITY,
	EmployeeName VARCHAR(15),
	Department VARCHAR(15),
	Salary NUMERIC(16,2)
)

INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('T Cook','Finance', 40000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('D Michael','Finance', 25000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('A Smith','Finance', 25000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('D Adams','Finance', 15000)

INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('M Williams','IT', 80000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('D Jones','IT', 40000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('J Miller','IT', 50000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('L Lewis','IT', 50000)

INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('A Anderson','Back-Office', 25000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('S Martin','Back-Office', 15000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('J Garcia','Back-Office', 15000)
INSERT INTO @Employees(EmployeeName, Department, Salary)
VALUES('T Clerk','Back-Office', 10000)

SELECT E.* ,DENSE_RANK() OVER(PARTITION BY DEPARTMENT ORDER BY E.SALARY DESC) AS [RANK] 
		FROM @Employees E

-- Solution 1 --
;WITH GET_SALARY_BY_RANK_CTE 
	AS
	(
		SELECT 
			E.*
			,DENSE_RANK() OVER(PARTITION BY DEPARTMENT ORDER BY E.SALARY DESC) AS [RANK] 
		FROM @Employees E
	)

	SELECT 	EMPLOYEEID,EMPLOYEENAME,DEPARTMENT,SALARY
	FROM GET_SALARY_BY_RANK_CTE
	WHERE [RANK] = 2
	
	
-- Solution 2--

SELECT 	EMPLOYEEID,EMPLOYEENAME,DEPARTMENT,SALARY
FROM(  SELECT 
			E.*
			,DENSE_RANK() OVER(PARTITION BY DEPARTMENT ORDER BY E.SALARY DESC) AS [RANK] 
		FROM @Employees E) AS GET_SALARY_BY_RANK(EMPLOYEEID,EMPLOYEENAME,DEPARTMENT,SALARY,[RANK])
		WHERE [RANK] = 2
		
-- Solution 3
;WITH HighestSalaries (department, salary) AS
(
	SELECT department, max(salary) FROM @employees 
	GROUP BY department
),

SecondHighestSalaries (department, salary) AS
(
	SELECT e.department, max(e.salary)
	FROM @employees e
	LEFT JOIN HighestSalaries h ON e.department = h.department 
		AND e.salary = h.salary
	WHERE h.department is null
	GROUP BY e.department
)
SELECT e.*
FROM @employees e
JOIN SecondHighestSalaries s ON e.department = s.department 
	AND e.salary = s.salary
ORDER BY e.department

	
-- Solution 4
SELECT
	e.EmployeeID,
	e.EmployeeName,
	e.Department,
	e.Salary
FROM
	@Employees e
WHERE
	(SELECT
		COUNT(DISTINCT e2.Salary) 
	 FROM
		@Employees e2
	 WHERE
		e2.Department = e.Department AND
		e2.Salary >= e.Salary
	 GROUP BY
		e2.Department) = 2
ORDER BY
	e.Salary
	
	
-- Solution 5	
SELECT * FROM @Employees e1
	WHERE 2 <= (SELECT COUNT(DISTINCT Salary) FROM @Employees e2 
				    WHERE e1.Salary <= e2.Salary AND e1.Department = e2.Department)
				    