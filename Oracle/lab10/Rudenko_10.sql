/*
Этап 1. Информационные запросы на обновление данных на основе предварительных 
преобразований с использованием регулярных выражений 
1. Для каждого сотрудника сгенерировать новый электронный адрес по шаблону A@B.C.D, 
где A – значение колонки email, B,C – части значения колонки job_id, находящиеся перед и после 
символа _, D – значение колонки country_id. 
*/

-Варианты
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
2.  Для  строковых  значений  колонки  street_address,  содержащих  цифровой  код  в  начале 
строки,  выполнить  перенос  кода  в  конец  строки,  поставив  перед  ним  запятую.  Если  в  процессе 
обновления  будет  выдана  ошибка  о  превышении  длины  обновляемой  строки,  выполнить 
расширение длины колонки street_address ( операция alter table … modify ) 
*/

update locations
set STREET_ADDRESS = REGEXP_REPLACE(street_address, '^(\d+) (.*)', '\2, \1');

/*
3.  Для  строковых  значений  колонки  street_address,  содержащих  в  конце  цифровой  код, 
который не отделен от предыдущей подстроки запятой, включить эту запятую. 
*/

update locations
set STREET_ADDRESS = REGEXP_REPLACE(trim(street_address), '([^,]+)(, | )(\d+)$', '\1, \3');

-- Локация с id 2800 'Rua Frei Caneca 1360 ' содержит в конце символ пробела, поэтому использована функция trim.

/*
4. Для строковых значений колонки phone_number формат XXX.XXX.XXXX преобразовать 
к формату (XXX) XXX-XX-XX 
*/

UPDATE EMPLOYEES
SET PHONE_NUMBER = regexp_replace (PHONE_NUMBER, '(\d{3})\.(\d{3})\.(\d{2})(\d{2})', '(\1) \2-\3-\4')
where length(PHONE_NUMBER) = 12;
-- этим условием отсекаем сотрудников, чей номер не соответствует маске

--Result: 72 rows updated


/*
5. В составных названиях подразделений, содержащих два слова, поменять порядок слов. 
Например: Government Sales преобразуется к Sales of Government.  
*/

-- будем считать, что между словами 1 пробел, в начале и в конце названий пробелов нет

UPDATE DEPARTMENTS
SET DEPARTMENT_NAME = regexp_replace (DEPARTMENT_NAME, '([[:alpha:]]+)(\s)([[:alpha:]]+)', '\3 of \1')
WHERE LENGTH(DEPARTMENT_NAME)-LENGTH(REPLACE(DEPARTMENT_NAME, ' ')) = 1; --универсальный способ
--WHERE REGEXP_COUNT(DEPARTMENT_NAME,' ')=1; -- начиная с Oracle 11g

--Result: 8 rows updated

/*
Этап  2.  Информационные  запросы  на  выборку  данных  на  основе  регулярных 
выражений 
1.  Выбрать  подразделения,  в  полном  названии  которых  присутствуют  повторяющиеся 
подряд буквы. 
*/

select department_name
from departments
where REGEXP_SUBSTR(DEPARTMENT_NAME,'(\D+)\1') is not null;
-- where REGEXP_LIKE(DEPARTMENT_NAME,'(\D+)\1'); -- лучше было так

/*
2. Для каждого сотрудника выбрать полное название занимаемой им должности и страны 
расположения  на  основе  анализа  электронного  адреса,  сформированного  по  шаблону  A@B.C.D, 
где A – значение колонки email, B,C – части значения колонки job_id, находящиеся перед и после 
символа _, D – значение колонки country_id. 
*/

select first_name || ' ' || last_name as Employee,
    (select job_title from jobs where job_id = regexp_replace(email,'([^@]+)(@)([^\.]+)(\.)([^\.]+)(\.)(.+)','\3_\5')) as Job_Title,
    (select country_name from countries where country_id = regexp_substr(email,'[[:alpha:]]+$')) as Country
from EMPLOYEES e; 

/*
3. Для составных названий подразделений получить множество подстрок. Формат строки 
выборки: Полное название, первая часть, вторая часть. 
*/

select department_name, regexp_substr(DEPARTMENT_NAME, '[[:alpha:]]+'), regexp_substr(DEPARTMENT_NAME, '[[:alpha:]]+$')
from departments
WHERE LENGTH(DEPARTMENT_NAME)-LENGTH(REPLACE(DEPARTMENT_NAME, ' ')) = 1;

/*
4.  Выбрать  список  близких  по  смыслу  названий  должностей, когда совпадают  некоторые 
подстроки из строк названий. Формат выборки: Должность1, Должность 2. Примеры пар близких 
по  смыслу  названий  должностей:  Finance  Manager  и  Accounting  Manager,  Sales  Manager  и  Sales 
Representative и т.д. 
*/

-- за близкие по смыслу примем все должности, в которых хотя бы одно слово общее

SELECT J1.JOB_TITLE, J2.JOB_TITLE
FROM JOBS J1, JOBS J2
WHERE (REGEXP_LIKE(J1.JOB_TITLE, REGEXP_substr(J2.JOB_TITLE,'[^ ]+',1,1)) 
      OR REGEXP_LIKE(J1.JOB_TITLE, REGEXP_substr(J2.JOB_TITLE,'[^ ]+',1,2))
      OR REGEXP_LIKE(J1.JOB_TITLE, REGEXP_substr(J2.JOB_TITLE,'[^ ]+',1,3)))
      and length (J1.JOB_TITLE)<length (J2.JOB_TITLE);

/* последнее условие позволяет отсечь ненужные строки 1 и 3
1  President	                              President
2  President	                              Administration Vice President
3  Administration Vice President	          President
*/


/* 
Этап 3 Информационные запросы на выборку данных с аналитической обработкой 
1.  Выбрать  сотрудников  с  группировкой  по  странам  и  их  разделением  на  три  группы  в 
каждой стране. 
*/

select last_name, country_name, 
    NTILE(3) OVER (PARTITION by country_name ORDER BY last_name) AS cntile
from EMPLOYEES e
join DEPARTMENTS d USING (department_id)
join LOCATIONS l USING (location_id)
join COUNTRIES c USING (country_id);

/*
2.  Выбрать  максимальную  зарплату  сотрудников  с  группировкой  по  городам,  в  которых 
расположены  подразделения  сотрудников,  так  чтобы  в каждой  строке  выдавалась  максимальная 
зарплата всех сотрудников вплоть до указанного. 
*/

select first_name  || ' ' || last_name, city, salary, max(salary) OVER (PARTITION by city order by first_name desc) AS max_salary
from EMPLOYEES e
join DEPARTMENTS d USING (department_id)
join LOCATIONS l USING (location_id);

/*
3. Для каждой страны выбрать двух самых высокооплачиваемых сотрудников. 
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
4. Для каждой страны выбрать высокооплачиваемых сотрудников, уровень зарплат которых 
находится на втором месте. 
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
5. Выбрать сотрудников, у которых ранг (уровень) зарплат  <= 0.25 в группах сотрудников, 
работающих в подразделениях из одной страны. 
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
6.  Показать  минимальную  зарплату  по  текущему  сотруднику  и  предыдущим  2-м 
сотрудникам,  сгруппированным  в  группе  по  подразделениями  и  отсортированным  в  порядке 
убывания зарплаты. 
*/

-- Примечание: сотрудники отсортированы в порядке возрастания зп, иначе мин. зп текущего сотрудника и 2-ух перед ним и есть
зарплата этого сотрудника 

select first_name  || ' ' || last_name as employee, department_id, salary, 
       min(salary) over (partition by department_id order by salary asc rows between 2 preceding and current row)
from employees;

/*
7. Выбрать среднюю зарплату сотрудников (с учетом премиальных) за третий месяц всех 
лет и определить ее изменение в процентах по отношению к предыдущему и следующему году. 
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
8. Выбрать текущие затраты компании на зарплату сотрудникам с квартальной разбивкой за 
все годы работы компании. 
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