SELECT
  department,
  job,
  SUM(CASE WHEN quarter = 'Q1' THEN number_of_employees_hired ELSE 0 END) AS Q1,
  SUM(CASE WHEN quarter = 'Q2' THEN number_of_employees_hired ELSE 0 END) AS Q2,
  SUM(CASE WHEN quarter = 'Q3' THEN number_of_employees_hired ELSE 0 END) AS Q3,
  SUM(CASE WHEN quarter = 'Q4' THEN number_of_employees_hired ELSE 0 END) AS Q4
FROM
  (SELECT
    DEP.department,
    JOB.job,
    YEAR(HEP.datetime) AS year,
    CASE 
      WHEN MONTH(HEP.datetime) BETWEEN 1 AND 3 THEN 'Q1'
      WHEN MONTH(HEP.datetime) BETWEEN 4 AND 6 THEN 'Q2'
      WHEN MONTH(HEP.datetime) BETWEEN 7 AND 9 THEN 'Q3'
      WHEN MONTH(HEP.datetime) BETWEEN 10 AND 12 THEN 'Q4'
    END AS quarter,
    COUNT(*) AS number_of_employees_hired
  FROM
    'hired_employees.csv' AS HEP
  JOIN
    'departments.csv' AS DEP ON HEP.department_id = DEP.id
  JOIN
    'jobs.csv' AS JOB ON HEP.job_id = JOB.id
  WHERE
    YEAR(HEP.datetime) = 2021
  GROUP BY
    DEP.department,
    JOB.job,
    year,
    quarter) AS subquery
GROUP BY
  department,
  job
ORDER BY
  department,
  job;