/*
Задание 1  Заполнение таблиц БД искусственными данными 
Используя  процедуру  из  решения  1-го  задания  из  лабораторной  работы  №  8, 
сгенерировать около ста тысяч строк в таблице сотрудников. Все значения атрибутов строк 
должны  быть  распределены  по  равномерному  закону  распределения  вероятностей  с 
использованием функций пакета DBMS_RANDOM: 
− для  некоторых  колонок  использовать  случайно  выбранные  значения  на  основе 
функций пакета DBMS_RANDOM: 
a) идентификатор сотрудника определяется как значение счетчика цикла; 
b) имя,  фамилия  сотрудника  определяется  как  случайное  буквенное  значение 
размерностью 10 символов; 
c) E-mail  сотрудника  определяется  как  сформированная  фамилия  сотрудника  + 
значение счетчика цикла; 
d)  дата зачисления определяется как ‘01.01.2000’ + случайное число от 1 до 1000; 
e) идентификатор  подразделения  определяется  случайным  числом  в  допустимом 
диапазоне  идентификаторов  подразделений  (использовать  предварительно  созданную 
коллекцию); 
f)  идентификатор  должности  определяется  случайным  числом  в  допустимом 
диапазоне идентификаторов, используя порядковый номер получаемой должности из списка 
должностей (использовать предварительно созданную коллекцию). 
В процедуре вычислить время выполнения всех операций внесения данных в таблицу. 
*/

DECLARE
	min_empno employees.employee_id%TYPE;
	TYPE Jobs IS TABLE OF employees.job_id%TYPE;
	job_list Jobs;
  TYPE Depts IS TABLE OF employees.department_id%TYPE;
	dept_list Depts;
	TYPE Emps IS TABLE OF employees%ROWTYPE;
	emp_list Emps := Emps();
	job_elem NUMERIC(2);
	row_count CONSTANT PLS_INTEGER := 100000;
  t1 integer;
  t2 integer;
  t integer;
BEGIN
	SELECT max(employee_id) INTO min_empno from employees;
	emp_list.EXTEND(row_count);
	SELECT distinct job_id BULK COLLECT INTO job_list from employees;
  SELECT distinct department_id BULK COLLECT INTO dept_list from employees;
	FOR j IN 1..row_count LOOP
		emp_list(j).employee_id := j+min_empno; 
		emp_list(j).last_name := DBMS_RANDOM.STRING('A',10); 
		emp_list(j).email := emp_list(j).last_name || j;
		emp_list(j).job_id := job_list(ROUND(DBMS_RANDOM.VALUE(1,job_list.count))); 
		emp_list(j).department_id := dept_list(ROUND(DBMS_RANDOM.VALUE(1,dept_list.count))); 
    emp_list(j).hire_date:=to_date('01/01/2000','DD/MM/YYYY')+ROUND(DBMS_RANDOM.VALUE(1,1000));
		emp_list(j).salary := ROUND(DBMS_RANDOM.VALUE(1,3))*1000;
	END LOOP;
  t1:= DBMS_UTILITY.get_time;
	FORALL j IN emp_list.FIRST..emp_list.LAST
		INSERT INTO employees (employee_id, last_name, email, job_id, department_id, hire_date, salary)
			VALUES(emp_list(j).employee_id, emp_list(j).last_name, emp_list(j).email, emp_list(j).job_id, emp_list(j).department_id, emp_list(j).hire_date, emp_list(j).salary);
  t2:= DBMS_UTILITY.get_time;
  t:=t2-t1;
  dbms_output.put_line('Time spent: '|| t/100 || ' seconds');
END;
/

--Time spent: 11.39 seconds


/*
Задание 2 Анализ физического плана выполнения запросов 
Пусть заданы запросы из решений: 
- задания 1,2,3,4,5,6,7 из 1-го этапа лабораторной лабораторной работы № 3; 
- задания 1 и 6 из 1-го этапа лабораторной работы № 6. 
1.1  Для  указанных  запросов  получить  физические  планы  выполнения  запросов, 
используя команду AUTOTRACE утилиты SQLPlus или любую другую команду. 
1.2 Изучить созданные планы, рисуя на отдельном листе бумаги деревья физического 
плана  выполнения  запросов.  При  необходимости  изучить  назначение  алгоритмов  в 
документе, представленном по адресам 
*/


-- задания 1,2,3,4,5,6,7 из 1-го этапа лабораторной лабораторной работы № 3

/*
1. Выполнить  запрос,  который  получает  фамилии  сотрудников  и  их  E-mail  адреса  в 
полном формате: значение атрибута E-mail + "@Netcracker.com" 
*/

SELECT last_name, email || '@Netcracker.com' as "Email"
FROM employees;

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |   100K|  2639K|   236   (1)| 00:00:03 |
|   1 |  TABLE ACCESS FULL| EMPLOYEES |   100K|  2639K|   236   (1)| 00:00:03 |
-------------------------------------------------------------------------------

/*
2. Выполнить запрос, который: 
- получает фамилию сотрудников и их зарплату; 
- зарплата превышает 15000$. 
*/

SELECT last_name, salary
FROM employees
WHERE salary>15000;
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |     3 |    45 |   237   (1)| 00:00:03 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |     3 |    45 |   237   (1)| 00:00:03 |
-------------------------------------------------------------------------------

/*
3.  Выполнить  запрос,  который  получает  фамилии  сотрудников,  зарплату,  комиссионные, 
их зарплату за год с учетом комиссионных. 
*/

SELECT last_name, salary, COMMISSION_PCT, 12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees;

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |   100K|  1661K|   237   (1)| 00:00:03 |
|   1 |  TABLE ACCESS FULL| EMPLOYEES |   100K|  1661K|   237   (1)| 00:00:03 |
-------------------------------------------------------------------------------


/*
4 Выполнить запрос, который: 
- получает для каждого сотрудника cтроку в формате 
'Dear '+A+ '  ' + B + ’! ' + ‘ Your salary = ‘ + C,
где  A  =  {‘Mr.’,’Mrs.’}  –  сокращенный  вариант  обращения  к  мужчине  или  женщине  
(предположить, что женщиной являются все сотрудницы, имя которых заканчивается на букву 
‘a’ или ‘e’)  
B – фамилия сотрудника; 
C – годовая зарплата с учетом комиссионных сотрудника 
*/

/*
SELECT 'Dear ' || 'Mrs ' || last_name || ' ' || first_name || '! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where first_name like '%a' or first_name like '%e'
Union
SELECT 'Dear ' || 'Mr ' || last_name || ' ' ||first_name ||'! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where first_name not like '%a' and first_name not like '%e';
*/

SELECT 'Dear ' || 'Mrs ' || last_name || ' ' || first_name || '! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where SUBSTR(first_name,LENGTH(first_name),1) = 'a' or SUBSTR(first_name,LENGTH(first_name),1) = 'e'
Union
SELECT 'Dear ' || 'Mr ' || last_name || ' ' ||first_name ||'! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where SUBSTR(first_name,LENGTH(first_name),1) <> 'a' and SUBSTR(first_name,LENGTH(first_name),1) <> 'e';

---------------------------------------------------------------------------------
| Id  | Operation           | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |           |  2242 | 42598 |   480  (52)| 00:00:06 |
|   1 |  SORT UNIQUE        |           |  2242 | 42598 |   480  (52)| 00:00:06 |
|   2 |   UNION-ALL         |           |       |       |            |          |
|*  3 |    TABLE ACCESS FULL| EMPLOYEES |  1992 | 37848 |   240   (3)| 00:00:03 |
|*  4 |    TABLE ACCESS FULL| EMPLOYEES |   250 |  4750 |   238   (2)| 00:00:03 |
---------------------------------------------------------------------------------

/*
5. Выполнить запрос, который: 
- получает названия подразделений; 
- подразделения расположены в городе Seattle. 
*/

select department_name, city
from DEPARTMENTS, LOCATIONS
where DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and city='Seattle';

----------------------------------------------------------------------------------
| Id  | Operation          | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |             |     4 |   108 |     5  (20)| 00:00:01 |
|*  1 |  HASH JOIN         |             |     4 |   108 |     5  (20)| 00:00:01 |
|*  2 |   TABLE ACCESS FULL| LOCATIONS   |     1 |    12 |     2   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| DEPARTMENTS |    27 |   405 |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------

/*
6. Выполнить запрос, который: 
- получает фамилию, должность, номер подразделения сотрудников 
- сотрудники работают в городе Toronto. 
*/

select last_name, job_title, e.department_id, city
from EMPLOYEES e
join JOBS j on (e.JOB_ID = j.JOB_ID)
join DEPARTMENTS d on (e.DEPARTMENT_ID = d.DEPARTMENT_ID) 
join LOCATIONS l on  (d.LOCATION_ID = l.LOCATION_ID) 
where city='Toronto';


--------------------------------------------------------------------------------------
| Id  | Operation              | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |             | 13015 |   864K|   244   (2)| 00:00:03 |
|*  1 |  HASH JOIN             |             | 13015 |   864K|   244   (2)| 00:00:03 |
|*  2 |   HASH JOIN            |             |    73 |  3358 |     7  (15)| 00:00:01 |
|   3 |    MERGE JOIN CARTESIAN|             |    19 |   741 |     4   (0)| 00:00:01 |
|*  4 |     TABLE ACCESS FULL  | LOCATIONS   |     1 |    12 |     2   (0)| 00:00:01 |
|   5 |     BUFFER SORT        |             |    19 |   513 |     2   (0)| 00:00:01 |
|   6 |      TABLE ACCESS FULL | JOBS        |    19 |   513 |     2   (0)| 00:00:01 |
|   7 |    TABLE ACCESS FULL   | DEPARTMENTS |    27 |   189 |     2   (0)| 00:00:01 |
|*  8 |   TABLE ACCESS FULL    | EMPLOYEES   | 91103 |  1957K|   237   (1)| 00:00:03 |
--------------------------------------------------------------------------------------

/*
7. Выполнить запрос, который: 
- получает  номер и название подразделений; 
- подразделения расположены в стране UNITED STATES OF AMERICA 
- в подразделениях не должно быть сотрудников. 
*/

select department_id, department_name, country_name
from DEPARTMENTS, LOCATIONS, COUNTRIES
where DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and
      LOCATIONS.COUNTRY_ID = COUNTRIES.COUNTRY_ID
      and country_name = 'United States of America' and DEPARTMENTS.MANAGER_ID is NULL;

-------------------------------------------------------------------------------------
| Id  | Operation             | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |             |     1 |    39 |     7  (15)| 00:00:01 |
|*  1 |  HASH JOIN            |             |     1 |    39 |     7  (15)| 00:00:01 |
|   2 |   MERGE JOIN CARTESIAN|             |    16 |   528 |     4   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL  | COUNTRIES   |     1 |    12 |     2   (0)| 00:00:01 |
|   4 |    BUFFER SORT        |             |    16 |   336 |     2   (0)| 00:00:01 |
|*  5 |     TABLE ACCESS FULL | DEPARTMENTS |    16 |   336 |     2   (0)| 00:00:01 |
|   6 |   TABLE ACCESS FULL   | LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

--задания 1 и 6 из 1-го этапа лабораторной работы № 6

/*
1. Выполнить запрос, который: 
- получает названия должностей; 
- на указанных должностях должны работать сотрудники. 
*/

SELECT j.job_title
	FROM jobs j
	WHERE EXISTS (
			SELECT e.job_id 
			FROM employees e 
			WHERE e.job_id = j.job_id);

--------------------------------------------------------------------------------
| Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |    19 |   665 |   239   (1)| 00:00:03 |
|*  1 |  HASH JOIN SEMI    |           |    19 |   665 |   239   (1)| 00:00:03 |
|   2 |   TABLE ACCESS FULL| JOBS      |    19 |   513 |     2   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| EMPLOYEES |   100K|   782K|   237   (1)| 00:00:03 |
--------------------------------------------------------------------------------
		
/*
6.  Выполнить  запрос,  который  получает  список  стран  и  подразделений,  в  которых  не 
работают сотрудники. 
*/

SELECT c.COUNTRY_NAME, dept.DEPARTMENT_NAME
FROM DEPARTMENTS dept LEFT JOIN EMPLOYEES emp ON (dept.DEPARTMENT_ID = emp.DEPARTMENT_ID)
JOIN LOCATIONS loc ON (loc.LOCATION_ID = dept.LOCATION_ID)
JOIN COUNTRIES c ON (loc.COUNTRY_ID = c.COUNTRY_ID)
WHERE NOT EXISTS (SELECT emp2.EMPLOYEE_ID
FROM EMPLOYEES emp2
WHERE dept.DEPARTMENT_ID = emp2.DEPARTMENT_ID);

-------------------------------------------------------------------------------------
| Id  | Operation             | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |             | 89042 |  3739K|   483   (2)| 00:00:06 |
|*  1 |  HASH JOIN OUTER      |             | 89042 |  3739K|   483   (2)| 00:00:06 |
|*  2 |   HASH JOIN           |             |    17 |   680 |   245   (2)| 00:00:03 |
|*  3 |    HASH JOIN          |             |    17 |   476 |   242   (2)| 00:00:03 |
|*  4 |     HASH JOIN ANTI    |             |    17 |   374 |   240   (2)| 00:00:03 |
|   5 |      TABLE ACCESS FULL| DEPARTMENTS |    27 |   513 |     2   (0)| 00:00:01 |
|*  6 |      TABLE ACCESS FULL| EMPLOYEES   | 91103 |   266K|   237   (1)| 00:00:03 |
|   7 |     TABLE ACCESS FULL | LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
|   8 |    TABLE ACCESS FULL  | COUNTRIES   |    25 |   300 |     2   (0)| 00:00:01 |
|*  9 |   TABLE ACCESS FULL   | EMPLOYEES   | 91103 |   266K|   237   (1)| 00:00:03 |
-------------------------------------------------------------------------------------

/*
Задание 3 Создание дополнительных индексов 
3.1 На основе анализа физ.планов каждого из запросов 2-го задания создать индексы 
(B-tree  или  функциональные),  которые  могут  ускорить  выполнение  запросов  с  учетом 
стратегии оптимизации по правилам. 
*/

CREATE INDEX i_email ON employees (email);

/*
Error report -
SQL Error: ORA-01408: such column list already indexed

Oracle автоматически создаёт индексы для полей, содержащих только уникальные значения,
поэтому индекс для атрибута Email уже существует в системе
*/

CREATE INDEX sal ON employees (salary);

CREATE INDEX commission ON employees (commission_pct);

CREATE INDEX f_name ON employees (SUBSTR(first_name,LENGTH(first_name),1)) 

CREATE INDEX  city ON locations (city);

CREATE INDEX job_title ON jobs (job_title);

CREATE INDEX dept_id on employees(department_id);

CREATE INDEX  job_id ON employees (job_id);

CREATE INDEX  man_id ON departments (manager_id);

--просмотр всех индексов
SELECT user_tables.table_name, user_indexes.index_name
FROM user_tables JOIN user_indexes on user_indexes.table_name = user_tables.table_name
ORDER by user_tables.table_name,user_indexes.index_name;


/*
3.2  Отменить  внесение  данных  по  1-му  заданию  и  повторить  этот  процесс  для 
таблицы сотрудников с учетом того, что в ней появились индексы из задания 3.1 
Сравнить время выполнения с результатом из 1-го задания. 
*/

rollback;
-- Time spent: 20.17 seconds
-- Время выполнения запроса увеличилось 
/*
3.3  После  создания  индексов  повторить  создание  физических  планов  для  всех 
запросов (без создания деревьев). 
*/

SELECT last_name, email || '@Netcracker.com' as "Email"
FROM employees;
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |   100K|  2639K|   236   (1)| 00:00:03 |
|   1 |  TABLE ACCESS FULL| EMPLOYEES |   100K|  2639K|   236   (1)| 00:00:03 |
-------------------------------------------------------------------------------

SELECT last_name, salary
FROM employees
WHERE salary>15000;
-----------------------------------------------------------------------------------------
| Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |           |     3 |    45 |     3   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES |     3 |    45 |     3   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | SAL       |     3 |       |     2   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------

SELECT last_name, salary, COMMISSION_PCT, 12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees;
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |   100K|  1661K|   237   (1)| 00:00:03 |
|   1 |  TABLE ACCESS FULL| EMPLOYEES |   100K|  1661K|   237   (1)| 00:00:03 |
-------------------------------------------------------------------------------

SELECT 'Dear ' || 'Mrs ' || last_name || ' ' || first_name || '! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where SUBSTR(first_name,LENGTH(first_name),1) = 'a' or SUBSTR(first_name,LENGTH(first_name),1) = 'e'
Union
SELECT 'Dear ' || 'Mr ' || last_name || ' ' ||first_name ||'! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where SUBSTR(first_name,LENGTH(first_name),1) <> 'a' and SUBSTR(first_name,LENGTH(first_name),1) <> 'e';
--------------------------------------------------------------------------------------------
| Id  | Operation                      | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |           |  1251 | 28773 |   257  (94)| 00:00:04 |
|   1 |  SORT UNIQUE                   |           |  1251 | 28773 |   257  (94)| 00:00:04 |
|   2 |   UNION-ALL                    |           |       |       |            |          |
|   3 |    INLIST ITERATOR             |           |       |       |            |          |
|   4 |     TABLE ACCESS BY INDEX ROWID| EMPLOYEES |  1001 | 23023 |    17   (0)| 00:00:01 |
|*  5 |      INDEX RANGE SCAN          | F_NAME    |   107 |       |     1   (0)| 00:00:01 |
|*  6 |    TABLE ACCESS FULL           | EMPLOYEES |   250 |  5750 |   238   (2)| 00:00:03 |
--------------------------------------------------------------------------------------------

select department_name, city
from DEPARTMENTS, LOCATIONS
where DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and city='Seattle';

----------------------------------------------------------------------------------
| Id  | Operation          | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |             |     4 |   108 |     5  (20)| 00:00:01 |
|*  1 |  HASH JOIN         |             |     4 |   108 |     5  (20)| 00:00:01 |
|*  2 |   TABLE ACCESS FULL| LOCATIONS   |     1 |    12 |     2   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| DEPARTMENTS |    27 |   405 |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------

select last_name, job_title, e.department_id, city
from EMPLOYEES e
join JOBS j on (e.JOB_ID = j.JOB_ID)
join DEPARTMENTS d on (e.DEPARTMENT_ID = d.DEPARTMENT_ID) 
join LOCATIONS l on  (d.LOCATION_ID = l.LOCATION_ID) 
where city='Toronto';


--------------------------------------------------------------------------------------
| Id  | Operation              | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |             | 13015 |   864K|   244   (2)| 00:00:03 |
|*  1 |  HASH JOIN             |             | 13015 |   864K|   244   (2)| 00:00:03 |
|*  2 |   HASH JOIN            |             |    73 |  3358 |     7  (15)| 00:00:01 |
|   3 |    MERGE JOIN CARTESIAN|             |    19 |   741 |     4   (0)| 00:00:01 |
|*  4 |     TABLE ACCESS FULL  | LOCATIONS   |     1 |    12 |     2   (0)| 00:00:01 |
|   5 |     BUFFER SORT        |             |    19 |   513 |     2   (0)| 00:00:01 |
|   6 |      TABLE ACCESS FULL | JOBS        |    19 |   513 |     2   (0)| 00:00:01 |
|   7 |    TABLE ACCESS FULL   | DEPARTMENTS |    27 |   189 |     2   (0)| 00:00:01 |
|*  8 |   TABLE ACCESS FULL    | EMPLOYEES   | 91103 |  1957K|   237   (1)| 00:00:03 |
--------------------------------------------------------------------------------------

select department_id, department_name, country_name
from DEPARTMENTS, LOCATIONS, COUNTRIES
where DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and
      LOCATIONS.COUNTRY_ID = COUNTRIES.COUNTRY_ID
      and country_name = 'United States of America' and DEPARTMENTS.MANAGER_ID is NULL;

-------------------------------------------------------------------------------------
| Id  | Operation             | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |             |     1 |    39 |     7  (15)| 00:00:01 |
|*  1 |  HASH JOIN            |             |     1 |    39 |     7  (15)| 00:00:01 |
|   2 |   MERGE JOIN CARTESIAN|             |    16 |   528 |     4   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL  | COUNTRIES   |     1 |    12 |     2   (0)| 00:00:01 |
|   4 |    BUFFER SORT        |             |    16 |   336 |     2   (0)| 00:00:01 |
|*  5 |     TABLE ACCESS FULL | DEPARTMENTS |    16 |   336 |     2   (0)| 00:00:01 |
|   6 |   TABLE ACCESS FULL   | LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

SELECT j.job_title
	FROM jobs j
	WHERE EXISTS (
			SELECT e.job_id 
			FROM employees e 
			WHERE e.job_id = j.job_id);

-----------------------------------------------------------------------------
| Id  | Operation          | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |        |    19 |   665 |    21   (0)| 00:00:01 |
|   1 |  NESTED LOOPS SEMI |        |    19 |   665 |    21   (0)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| JOBS   |    19 |   513 |     2   (0)| 00:00:01 |
|*  3 |   INDEX RANGE SCAN | JOB_ID |   100K|   782K|     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------
		
SELECT c.COUNTRY_NAME, dept.DEPARTMENT_NAME
FROM DEPARTMENTS dept LEFT JOIN EMPLOYEES emp ON (dept.DEPARTMENT_ID = emp.DEPARTMENT_ID)
JOIN LOCATIONS loc ON (loc.LOCATION_ID = dept.LOCATION_ID)
JOIN COUNTRIES c ON (loc.COUNTRY_ID = c.COUNTRY_ID)
WHERE NOT EXISTS (SELECT emp2.EMPLOYEE_ID
FROM EMPLOYEES emp2
WHERE dept.DEPARTMENT_ID = emp2.DEPARTMENT_ID);

-------------------------------------------------------------------------------------
| Id  | Operation             | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |             | 89042 |  3739K|    86   (4)| 00:00:02 |
|*  1 |  HASH JOIN OUTER      |             | 89042 |  3739K|    86   (4)| 00:00:02 |
|*  2 |   HASH JOIN           |             |    17 |   680 |    34   (3)| 00:00:01 |
|*  3 |    HASH JOIN          |             |    17 |   476 |    32   (4)| 00:00:01 |
|   4 |     NESTED LOOPS ANTI |             |    17 |   374 |    29   (0)| 00:00:01 |
|   5 |      TABLE ACCESS FULL| DEPARTMENTS |    27 |   513 |     2   (0)| 00:00:01 |
|*  6 |      INDEX RANGE SCAN | DEPT_ID     | 35040 |   102K|     1   (0)| 00:00:01 |
|   7 |     TABLE ACCESS FULL | LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
|   8 |    TABLE ACCESS FULL  | COUNTRIES   |    25 |   300 |     2   (0)| 00:00:01 |
|*  9 |   INDEX FAST FULL SCAN| DEPT_ID     | 91103 |   266K|    51   (2)| 00:00:01 |
-------------------------------------------------------------------------------------

/*
3.4 По каждому запросу сравнить физ.планы до создания индексов и после создания 
индексов и указать в отчете на обнаруженные отличия. 
*/

SELECT last_name, email || '@Netcracker.com' as "Email"
FROM employees;
--Oracle не использует индексы, т.к. в запросе нет предложения WHERE. 

SELECT last_name, salary
FROM employees
WHERE salary>15000;
--Использован индекс sal: Cost был 237, стал 3

SELECT last_name, salary, COMMISSION_PCT, 12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees;
--Oracle не использует индексы, т.к. в запросе нет предложения WHERE. 

SELECT 'Dear ' || 'Mrs ' || last_name || ' ' || first_name || '! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where SUBSTR(first_name,LENGTH(first_name),1) = 'a' or SUBSTR(first_name,LENGTH(first_name),1) = 'e'
Union
SELECT 'Dear ' || 'Mr ' || last_name || ' ' ||first_name ||'! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where SUBSTR(first_name,LENGTH(first_name),1) <> 'a' and SUBSTR(first_name,LENGTH(first_name),1) <> 'e';
-- Использован индекс f_name: Cost был 480, стал 257

-- В следующих трех примерах необходим был бы специальный текстовый индекс, поэтому изменений 
в запросах не наблюдается

select department_name, city
from DEPARTMENTS, LOCATIONS
where DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and city='Seattle';

select last_name, job_title, e.department_id, city
from EMPLOYEES e
join JOBS j on (e.JOB_ID = j.JOB_ID)
join DEPARTMENTS d on (e.DEPARTMENT_ID = d.DEPARTMENT_ID) 
join LOCATIONS l on  (d.LOCATION_ID = l.LOCATION_ID) 
where city='Toronto';

select department_id, department_name, country_name
from DEPARTMENTS, LOCATIONS, COUNTRIES
where DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and
      LOCATIONS.COUNTRY_ID = COUNTRIES.COUNTRY_ID
      and country_name = 'United States of America' and DEPARTMENTS.MANAGER_ID is NULL;
      
-- а вот тут не поможет и индекс man_id, потому что индексы не хранят null значения


SELECT j.job_title
	FROM jobs j
	WHERE EXISTS (
			SELECT e.job_id 
			FROM employees e 
			WHERE e.job_id = j.job_id);
-- Использован индекс job_id: Cost был 239, стал 21 			
	
SELECT c.COUNTRY_NAME, dept.DEPARTMENT_NAME
FROM DEPARTMENTS dept LEFT JOIN EMPLOYEES emp ON (dept.DEPARTMENT_ID = emp.DEPARTMENT_ID)
JOIN LOCATIONS loc ON (loc.LOCATION_ID = dept.LOCATION_ID)
JOIN COUNTRIES c ON (loc.COUNTRY_ID = c.COUNTRY_ID)
WHERE NOT EXISTS (SELECT emp2.EMPLOYEE_ID
FROM EMPLOYEES emp2
WHERE dept.DEPARTMENT_ID = emp2.DEPARTMENT_ID);
-- Использован индекс dept_id: Cost был 971, стал 86 

/*
Вывод:
Применение индексов представляет собой компромисс между ускорением получения результатов 
запросов и замедлением обновлений и вставок данных. 
Если таблицы в основном используются для чтения информации, то лучше иметь много индексов. 
Если в базе данных осуществляется большое количество вставок, обновлений и удалений, то 
лучше обойтись меньшим числом индексов.
*/