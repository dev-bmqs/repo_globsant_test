SELECT
	DEP.id,
	DEP.department,
	count(*) as number_of_employees_hired
FROM
	'hired_employees.csv' HEP
JOIN
	'departments.csv' DEP ON HEP.department_id = DEP.id
WHERE
	YEAR(HEP.datetime) = 2021
GROUP BY
	DEP.id,
	DEP.department
HAVING
	COUNT(*) > (
	SELECT
		AVG(dept_employees.count_employees)
	FROM
		(SELECT
			department_id,
			COUNT(*) AS count_employees
		 FROM
			'hired_employees.csv'
		 WHERE
			YEAR(datetime) = 2021
		 GROUP BY
			department_id) AS dept_employees
	)
ORDER BY
	number_of_employees_hired DESC;