/*
���� 1. �������������� ������� �� ���������� ������ �� ������ ��������������� 
�������������� � �������������� ���������� ��������� 
1. ��� ������� ���������� ������������� ����� ����������� ����� �� ������� A@B.C.D, 
��� A � �������� ������� email, B,C � ����� �������� ������� job_id, ����������� ����� � ����� 
������� _, D � �������� ������� country_id. 
*/

-��������
--B.C = REGEXP_REPLACE(job_id,'([[:alpha:]]+)(\_)([[:alpha:]]+)','\1.\3')
--B.C = REGEXP_SUBSTR(job_id,'[[:alpha:]]+') || '.' || REGEXP_SUBSTR(job_id,'[[:alpha:]]+$')
--B.C = REGEXP_SUBSTR(job_id,'[[:alpha:]]+') || '.' || REGEXP_SUBSTR(job_id,'[[:alpha:]]+',1,2)

alter table employees
modify email varchar2(40);

UPDATE EMPLOYEES e1
SET e1.EMAIL = (
            select email || '@' || REGEXP_SUBSTR(job_id,'[[:alpha:]]+') || '.' || REGEXP_SUBSTR(job_id,'[[:alpha:]]+',1,2)|| '.' || country_id
            from EMPLOYEES e 
            join DEPARTMENTS d USING (department_id)
            join LOCATIONS l USING (location_id)
            join COUNTRIES c USING (country_id)
            join JOBS j USING (job_id)
            where e1.EMPLOYEE_ID=e.EMPLOYEE_ID);
            
/*
2.  ���  ���������  ��������  �������  street_address,  ����������  ��������  ���  �  ������ 
������,  ���������  �������  ����  �  �����  ������,  ��������  �����  ���  �������.  ����  �  �������� 
����������  �����  ������  ������  �  ����������  �����  �����������  ������,  ��������� 
���������� ����� ������� street_address ( �������� alter table � modify ) 
*/

update locations
set STREET_ADDRESS = REGEXP_REPLACE(street_address, '^(\d+) (.*)', '\2, \1');

/*
3.  ���  ���������  ��������  �������  street_address,  ����������  �  �����  ��������  ���, 
������� �� ������� �� ���������� ��������� �������, �������� ��� �������. 
*/

update locations
set STREET_ADDRESS = REGEXP_REPLACE(trim(street_address), '([^,]+)(, | )(\d+)$', '\1, \3');

-- ������� � id 2800 'Rua Frei Caneca 1360 ' �������� � ����� ������ �������, ������� ������������ ������� trim.

/*
4. ��� ��������� �������� ������� phone_number ������ XXX.XXX.XXXX ������������� 
� ������� (XXX) XXX-XX-XX 
*/

UPDATE EMPLOYEES
SET PHONE_NUMBER = regexp_replace (PHONE_NUMBER, '(\d{3})\.(\d{3})\.(\d{2})(\d{2})', '(\1) \2-\3-\4')
where length(PHONE_NUMBER) = 12;
-- ���� �������� �������� �����������, ��� ����� �� ������������� �����

--Result: 72 rows updated


/*
5. � ��������� ��������� �������������, ���������� ��� �����, �������� ������� ����. 
��������: Government Sales ������������� � Sales of Government.  
*/

-- ����� �������, ��� ����� ������� 1 ������, � ������ � � ����� �������� �������� ���

UPDATE DEPARTMENTS
SET DEPARTMENT_NAME = regexp_replace (DEPARTMENT_NAME, '([[:alpha:]]+)(\s)([[:alpha:]]+)', '\3 of \1')
WHERE LENGTH(DEPARTMENT_NAME)-LENGTH(REPLACE(DEPARTMENT_NAME, ' ')) = 1; --������������� ������
--WHERE REGEXP_COUNT(DEPARTMENT_NAME,' ')=1; -- ������� � Oracle 11g

--Result: 8 rows updated

/*
����  2.  ��������������  �������  ��  �������  ������  ��  ������  ���������� 
��������� 
1.  �������  �������������,  �  ������  ��������  �������  ������������  ������������� 
������ �����. 
*/

select department_name
from departments
where REGEXP_SUBSTR(DEPARTMENT_NAME,'(\D+)\1') is not null;
-- where REGEXP_LIKE(DEPARTMENT_NAME,'(\D+)\1'); -- ����� ���� ���

/*
2. ��� ������� ���������� ������� ������ �������� ���������� �� ��������� � ������ 
������������  ��  ������  �������  ������������  ������,  ���������������  ��  �������  A@B.C.D, 
��� A � �������� ������� email, B,C � ����� �������� ������� job_id, ����������� ����� � ����� 
������� _, D � �������� ������� country_id. 
*/

select first_name || ' ' || last_name as Employee,
    (select job_title from jobs where job_id = regexp_replace(email,'([^@]+)(@)([^\.]+)(\.)([^\.]+)(\.)(.+)','\3_\5')) as Job_Title,
    (select country_name from countries where country_id = regexp_substr(email,'[[:alpha:]]+$')) as Country
from EMPLOYEES e; 

/*
3. ��� ��������� �������� ������������� �������� ��������� ��������. ������ ������ 
�������: ������ ��������, ������ �����, ������ �����. 
*/

select department_name, regexp_substr(DEPARTMENT_NAME, '[[:alpha:]]+'), regexp_substr(DEPARTMENT_NAME, '[[:alpha:]]+$')
from departments
WHERE LENGTH(DEPARTMENT_NAME)-LENGTH(REPLACE(DEPARTMENT_NAME, ' ')) = 1;

/*
4.  �������  ������  �������  ��  ������  ��������  ����������, ����� ���������  ��������� 
��������� �� ����� ��������. ������ �������: ���������1, ��������� 2. ������� ��� ������� 
��  ������  ��������  ����������:  Finance  Manager  �  Accounting  Manager,  Sales  Manager  �  Sales 
Representative � �.�. 
*/

-- �� ������� �� ������ ������ ��� ���������, � ������� ���� �� ���� ����� �����

SELECT J1.JOB_TITLE, J2.JOB_TITLE
FROM JOBS J1, JOBS J2
WHERE (REGEXP_LIKE(J1.JOB_TITLE, REGEXP_substr(J2.JOB_TITLE,'[^ ]+',1,1)) 
      OR REGEXP_LIKE(J1.JOB_TITLE, REGEXP_substr(J2.JOB_TITLE,'[^ ]+',1,2))
      OR REGEXP_LIKE(J1.JOB_TITLE, REGEXP_substr(J2.JOB_TITLE,'[^ ]+',1,3)))
      and length (J1.JOB_TITLE)<length (J2.JOB_TITLE);

/* ��������� ������� ��������� ������ �������� ������ 1 � 3
1  President	                              President
2  President	                              Administration Vice President
3  Administration Vice President	          President
*/


/* 
���� 3 �������������� ������� �� ������� ������ � ������������� ���������� 
1.  �������  �����������  �  ������������  ��  �������  �  ��  �����������  ��  ���  ������  � 
������ ������. 
*/

select last_name, country_name, 
    NTILE(3) OVER (PARTITION by country_name ORDER BY last_name) AS cntile
from EMPLOYEES e
join DEPARTMENTS d USING (department_id)
join LOCATIONS l USING (location_id)
join COUNTRIES c USING (country_id);

/*
2.  �������  ������������  ��������  �����������  �  ������������  ��  �������,  �  ������� 
�����������  �������������  �����������,  ���  �����  � ������  ������  ����������  ������������ 
�������� ���� ����������� ������ �� ����������. 
*/

select first_name  || ' ' || last_name, city, salary, max(salary) OVER (PARTITION by city order by first_name desc) AS max_salary
from EMPLOYEES e
join DEPARTMENTS d USING (department_id)
join LOCATIONS l USING (location_id);

/*
3. ��� ������ ������ ������� ���� ����� ������������������ �����������. 
*/

with temp as
(
  select first_name  || ' ' || last_name as employee, country_name, salary, 
         ROW_NUMBER() OVER (PARTITION by country_name order by salary desc) AS position
  from EMPLOYEES e
  join DEPARTMENTS d USING (department_id)
  join LOCATIONS l USING (location_id)
  join COUNTRIES c USING (country_id)
)
select employee, country_name, salary
from temp
where position<=2;

/*
Michael Hartstein	Canada	                    13000
Pat Fay	          Canada	                    6000
Hermann Baer	Germany	                    10000
John Russell	United Kingdom	          14000
Karen Partners	United Kingdom	          13500
Steven King	United States of America	24000
Neena Kochhar	United States of America	17000
*/

/*
4. ��� ������ ������ ������� ������������������ �����������, ������� ������� ������� 
��������� �� ������ �����. 
*/

with temp as
(
  select first_name  || ' ' || last_name as employee, country_name, salary, 
         DENSE_RANK() OVER (PARTITION by country_name order by salary desc) AS dense_position
  from EMPLOYEES e
  join DEPARTMENTS d USING (department_id)
  join LOCATIONS l USING (location_id)
  join COUNTRIES c USING (country_id)
)
select employee, country_name, salary
from temp
where dense_position=2;

/*
Pat Fay	          Canada	                    6000
Karen Partners	United Kingdom	          13500
Neena Kochhar	United States of America	17000
Lex De Haan	United States of America	17000
*/

/*
5. ������� �����������, � ������� ���� (�������) �������  <= 0.25 � ������� �����������, 
���������� � �������������� �� ����� ������. 
*/

with temp as
(
  select first_name  || ' ' || last_name as employee, country_name, salary, 
         CUME_DIST() OVER (PARTITION by country_name order by salary) AS cume_dist
  from EMPLOYEES e
  join DEPARTMENTS d USING (department_id)
  join LOCATIONS l USING (location_id)
  join COUNTRIES c USING (country_id)
)
select employee, country_name, salary, round(cume_dist,3)
from temp
where cume_dist<=0.25;

/*
6.  ��������  �����������  ��������  ��  ��������  ����������  �  ����������  2-� 
�����������,  ���������������  �  ������  ��  ���������������  �  ���������������  �  ������� 
�������� ��������. 
*/

-- ����������: ���������� ������������� � ������� ����������� ��, ����� ���. �� �������� ���������� � 2-�� ����� ��� � ����
�������� ����� ���������� 

select first_name  || ' ' || last_name as employee, department_id, salary, 
       min(salary) over (partition by department_id order by salary asc rows between 2 preceding and current row)
from employees;

/*
7. ������� ������� �������� ����������� (� ������ �����������) �� ������ ����� ���� 
��� � ���������� �� ��������� � ��������� �� ��������� � ����������� � ���������� ����. 
*/

WITH 
m_y_sal AS 
	(	SELECT 	EXTRACT(Month FROM Hire_Date) m, 
				EXTRACT (Year FROM Hire_Date) as y, Salary FROM EMPLOYEES
	),
m_y_sal_sum AS 
	(	SELECT m, y, SUM(Salary) Sal 
		FROM m_y_sal 
		GROUP BY m, y
	),
month_list AS (
		SELECT rownum as m FROM dual CONNECT BY level <= 12),
year_list AS 
	( SELECT distinct extract (year from hire_date) y 
		FROM employees
	),
month_year_list AS 
	( SELECT y,m 
		FROM month_list, year_list
	),
m_y_sal_sum_add AS 
	( SELECT l.y,l.m,NVL(s.sal,0) Sal 
		from month_year_list l left	join m_y_sal_sum s on (l.m = s.m and l.y = s.y) 
	),
m_y_sal_sum2 AS 
	( SELECT m, y, SUM(Sal) OVER (ORDER BY y, m) Sum_Sal 
		FROM m_y_sal_sum_add
	),
m_y_sal_sum_l AS 
	( SELECT m, y, Sum_Sal, 
			LAG(Sum_Sal,1,Sum_Sal) OVER	(ORDER BY y, m)	Prior_Year, 
			LEAD(Sum_Sal, 1, Sum_Sal) OVER (ORDER BY y, m) Next_Year 
		FROM m_y_sal_sum2 where m = 3
	)
SELECT 	m,y,sum_sal,prior_year,round(100*prior_year/sum_sal) "p_y_%",
		next_year, round(100*next_year/sum_sal) "n_y_%" 
from m_y_sal_sum_l;

/*
8. ������� ������� ������� �������� �� �������� ����������� � ����������� ��������� �� 
��� ���� ������ ��������. 
*/

WITH m_y_sal AS (
	SELECT extract (month from hire_date) m, 
		extract (year from hire_date) y, salary FROM employees),
	m_y_sal_sum as (SELECT m,y,SUM(salary) sal from m_y_sal group by m,y),
	month_list AS (
		SELECT rownum as m FROM dual CONNECT BY level <= 12),
	year_list AS (
	SELECT distinct extract (year from hire_date) y FROM employees),
month_year_list AS (
SELECT y,m FROM month_list, year_list),
m_y_sal_sum_add AS (
SELECT l.y,l.m,NVL(s.sal,0) sal 
	from month_year_list l left join m_y_sal_sum s on 
	(l.m = s.m and l.y = s.y) ),
almost as (
SELECT trunc(m/3)+1-decode(mod(m,3), 0, 1, 0) quarter, y, SUM(sal) OVER (ORDER BY y,m) sum_sal 
from m_y_sal_sum_add)
SELECT quarter, y, sum(sum_sal) from almost
group by quarter, y
order by 2, 1;