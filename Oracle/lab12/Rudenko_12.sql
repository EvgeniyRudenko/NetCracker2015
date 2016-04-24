/*
Этап 2 Изучение структуры таблиц статистики 
2.1 Используя генератор первичного заполнения БД, внести в отношения employees 
100000 строк с нормальным распределением следующих случайных величин: 
a) идентификатор  подразделения  в  допустимом  диапазоне  идентификаторов 
подразделений (использовать предварительно созданную коллекцию); 
b)  идентификатор должности в допустимом диапазоне идентификаторов, используя 
порядковый  номер  получаемой  должности  из  списка  должностей  (использовать 
предварительно созданную коллекцию); 
c) зарплата из диапазона 1500 до 5000 с шагом 100; 
d) идентификатор менеджера из диапазона от 1 до 100-го сотрудника, которые уже 
были зарегистрированы в БД до выполнения задания 1.
*/

CREATE OR REPLACE FUNCTION normal_random(min_val NUMERIC, max_val NUMERIC)
RETURN NUMERIC
IS
BEGIN 
	RETURN 
	TRUNC((DBMS_RANDOM.VALUE(min_val,max_val) + DBMS_RANDOM.VALUE(min_val,max_val) +
	DBMS_RANDOM.VALUE(min_val,max_val) + DBMS_RANDOM.VALUE(min_val,max_val) + 
	DBMS_RANDOM.VALUE(min_val,max_val) + DBMS_RANDOM.VALUE(min_val,max_val) + 
	DBMS_RANDOM.VALUE(min_val,max_val) + DBMS_RANDOM.VALUE(min_val,max_val) )/8);
END;


DECLARE
	min_empno employees.employee_id%TYPE;
	TYPE Jobs IS TABLE OF employees.job_id%TYPE;
	job_list Jobs;
  TYPE Managers IS TABLE OF employees.employee_id%TYPE;
	manager_list Managers;
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
  SELECT employee_id BULK COLLECT INTO manager_list from employees WHERE rownum <= 100;
	FOR j IN 1..row_count LOOP
		emp_list(j).employee_id := j+min_empno;
    emp_list(j).manager_id := manager_list(normal_random(1,manager_list.count+1));
		emp_list(j).last_name := DBMS_RANDOM.STRING('A',10); 
		emp_list(j).email := emp_list(j).last_name || j;
		emp_list(j).job_id := job_list(normal_random(1,job_list.count+1)); 
		emp_list(j).department_id := dept_list(normal_random(1,dept_list.count+1)); 
    emp_list(j).hire_date:=to_date('01/01/2000','DD/MM/YYYY')+ROUND(DBMS_RANDOM.VALUE(1,1000));
		emp_list(j).salary := normal_random(15,51)*100;
	END LOOP;
  t1:= DBMS_UTILITY.get_time;
	FORALL j IN emp_list.FIRST..emp_list.LAST
		INSERT INTO employees (employee_id, last_name, email, job_id, manager_id, department_id, hire_date, salary)
			VALUES(emp_list(j).employee_id, emp_list(j).last_name, emp_list(j).email, emp_list(j).job_id, emp_list(j).manager_id, emp_list(j).department_id, emp_list(j).hire_date, emp_list(j).salary);
  t2:= DBMS_UTILITY.get_time;
  t:=t2-t1;
  dbms_output.put_line('Time spent: '|| t/100 || ' seconds');
END;
/

/*
2.2 Провести сбор статистики (полный сбор, частичный с процентом числа строк = 10 
%) получить содержание статистики по таблицам, колонкам и содержимого гистограмм. 
*/
begin  dbms_stats.gather_table_stats(ownname => 'LAB12', tabname => 'EMPLOYEES'
-- , method_opt => 'FOR COLUMNS comm'
); end; 
/

SELECT num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len
FROM user_tab_statistics
WHERE table_name = 'EMPLOYEES';

create or replace function raw_to_num(i_raw raw) 
return number 
as 
    m_n number; 
begin 
    dbms_stats.convert_raw_value(i_raw,m_n); 
    return m_n; 
end; 
/ 

SELECT column_name,
num_distinct,
raw_to_num(low_value) AS low_value,
raw_to_num(high_value) AS high_value,
density,num_nulls,avg_col_len,histogram,
num_buckets
FROM user_tab_col_statistics
WHERE table_name = 'EMPLOYEES';

BEGIN
dbms_stats.gather_table_stats(
ownname => 'LAB12',
tabname => 'EMPLOYEES',
estimate_percent => 100, -- estimate_percent=>dbms_stats.auto_sample_size
method_opt => 'for columns size skewonly job_id, size skewonly manager_id, size skewonly department_id, size skewonly salary', 
cascade => TRUE
);
END;
/

SELECT endpoint_value, endpoint_number,
endpoint_number - lag(endpoint_number,1,0)
	OVER (ORDER BY endpoint_number) AS frequency
FROM user_tab_histograms
WHERE table_name = 'EMPLOYEES' AND column_name = 'MANAGER_ID'
ORDER BY endpoint_number;

BEGIN
dbms_stats.gather_table_stats(
ownname => 'LAB12',
tabname => 'EMPLOYEES',
estimate_percent => 10,
method_opt => 'for columns size skewonly job_id, size skewonly manager_id, size skewonly department_id, size skewonly salary', 
cascade => TRUE
);
END;
/

SELECT endpoint_value, endpoint_number,
endpoint_number - lag(endpoint_number,1,0)
	OVER (ORDER BY endpoint_number) AS frequency
FROM user_tab_histograms
WHERE table_name = 'EMPLOYEES' AND column_name = 'MANAGER_ID'
ORDER BY endpoint_number;
/*
Этап 3 Анализ эффективности использования индексов 
3.1 Создать запросы на получение фактора селективности всех атрибутов таблицы 
employees. Все атрибуты разделить на две группы:  
1) фактор селективности >= 10%, 2) фактор селективности < 10%. 
*/

select COLUMN_NAME, NUM_DISTINCT/(select count(*) from employees) as Select_Factor
from SYS.USER_TAB_COLUMNS
where TABLE_NAME='EMPLOYEES' and NUM_DISTINCT/(select count(*) from employees)>=0.1
Union all
select COLUMN_NAME, NUM_DISTINCT/(select count(*) from employees) as Select_Factor
from SYS.USER_TAB_COLUMNS
where TABLE_NAME='EMPLOYEES' and NUM_DISTINCT/(select count(*) from employees)<0.1;
-- >= 0.1
EMPLOYEE_ID	1
LAST_NAME	          0.99995
EMAIL	          1
-- < 0.1
FIRST_NAME	0.00091
PHONE_NUMBER	0.00107
HIRE_DATE 	0.01086
JOB_ID	          0.00019
SALARY	          0.00066
COMMISSION_PCT	0.00007
MANAGER_ID	0.00083
DEPARTMENT_ID	0.00011

/*
3.2 Создать SQL-запросы к таблице employees по условиям создания WHERE-фразы, 
в которые входят атрибуты каждой из указанных групп фактора селективности: 

1) атрибут целого типа = значение; 
2) атрибут целого типа > значение; 
3) атрибут целого типа < значение; 
4) атрибут целого типа в диапазоне значений; 
5) атрибут строкового типа = значение; 
6) атрибут строкового типа like значение; 
7) атрибут типа «дата» в диапазоне значений. 
*/
SET AUTOTRACE ON EXPLAIN;
ANALYZE TABLE employees DELETE STATISTICS;

-- Фактор селективности >= 0.1
-- В качестве атрибута целого типа из этой группы выбран employee_id, строкового типа - last_name, даты - не имеется такого в группе

select * 
from employees
where employee_id = 222;

select * 
from employees
where employee_id < 5555;

select * 
from employees
where employee_id > 5555;

select * 
from employees
where employee_id > 5555 and employee_id < 9999;

select * 
from employees
where last_name = 'Rogers';

select * 
from employees
where last_name like 'R%';

-- Фактор селективности < 0.1
-- В качестве атрибута целого типа из этой группы выбран manager_id, строкового типа - job_id, даты - hire_date

select * 
from employees
where manager_id = 122;

select * 
from employees
where manager_id < 122;

select * 
from employees
where manager_id > 122;

select * 
from employees
where manager_id > 122 and manager_id < 133;

select * 
from employees
where job_id = 'FI_MGR';

select * 
from employees
where job_id like '%CLERK';

select * 
from employees
where hire_date between '01-JAN-96' and '01-JAN-98';

/*
3.3 Определить план выполнения созданных в 3.2 запросов с помощью команды 
EXPLAIN или SET AUTOTRACE ON. Для каждого плана определить методы доступа. 
*/

---------------------------------------------------
| Id  | Operation                   | Name        |
---------------------------------------------------
|   0 | SELECT STATEMENT            |             |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES   |
|*  2 |   INDEX UNIQUE SCAN         | SYS_C008270 |
---------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID"=222)

Note
-----
   - rule based optimizer used (consider using cbo)



---------------------------------------------------
| Id  | Operation                   | Name        |
---------------------------------------------------
|   0 | SELECT STATEMENT            |             |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES   |
|*  2 |   INDEX RANGE SCAN          | SYS_C008270 |
---------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID"<5555)

Note
-----
   - rule based optimizer used (consider using cbo)


   
---------------------------------------------------
| Id  | Operation                   | Name        |
---------------------------------------------------
|   0 | SELECT STATEMENT            |             |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES   |
|*  2 |   INDEX RANGE SCAN          | SYS_C008270 |
---------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID">5555)

Note
-----
   - rule based optimizer used (consider using cbo)



---------------------------------------------------
| Id  | Operation                   | Name        |
---------------------------------------------------
|   0 | SELECT STATEMENT            |             |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES   |
|*  2 |   INDEX RANGE SCAN          | SYS_C008270 |
---------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID">5555 AND "EMPLOYEE_ID"<9999)

Note
-----
   - rule based optimizer used (consider using cbo)



---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("LAST_NAME"='Rogers')

Note
-----
   - rule based optimizer used (consider using cbo)

---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------



Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("LAST_NAME" LIKE 'R%')

Note
-----
   - rule based optimizer used (consider using cbo)






---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("MANAGER_ID"=122)

Note
-----
   - rule based optimizer used (consider using cbo)
   
  
   
---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("MANAGER_ID"<122)

Note
-----
   - rule based optimizer used (consider using cbo)  



---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("MANAGER_ID">122)

Note
-----
   - rule based optimizer used (consider using cbo)
   

---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("MANAGER_ID"<133 AND "MANAGER_ID">122)

Note
-----
   - rule based optimizer used (consider using cbo)
   
   
   
---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("JOB_ID"='FI_MGR')

Note
-----
   - rule based optimizer used (consider using cbo)
   
   

---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("JOB_ID" LIKE '%CLERK')

Note
-----
   - rule based optimizer used (consider using cbo)
   
   

---------------------------------------
| Id  | Operation         | Name      |
---------------------------------------
|   0 | SELECT STATEMENT  |           |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |
---------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("HIRE_DATE"<='01-JAN-98' AND "HIRE_DATE">='01-JAN-96')

Note
-----
   - rule based optimizer used (consider using cbo)
   
/*
3.4 С учетом рекомендаций стратегий оптимизации по стоимости создать индексы для 
запросов, которые спроектированы в пункте 3.2. 
*/

--employee_id является первичным ключом таблицы EMPLOYEES, Oracle сам создаёт индекс для такого поля
CREATE INDEX last_name ON employees (last_name); 
CREATE INDEX last_name2 ON employees (substr(last_name,1,1)); 
CREATE INDEX manager_id ON employees (manager_id);
CREATE INDEX job_id ON employees (job_id);
CREATE INDEX job_id2 ON employees (substr(job_id,1,1)); 
CREATE INDEX hire_date ON employees (hire_date);
/*
3.5 Повторить пункт 3.3, но при наличии индексов. 
*/

ANALYZE TABLE employees compute STATISTICS;


-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |     1 |    59 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES   |     1 |    59 |     2   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | SYS_C008270 |     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID"=222)
   

-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |  5455 |   314K|    63   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES   |  5455 |   314K|    63   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | SYS_C008270 |  5455 |       |    12   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID"<5555)


-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           | 94652 |  5453K|   253   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES | 94652 |  5453K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("EMPLOYEE_ID">5555)


-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |  4444 |   256K|    51   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES   |  4444 |   256K|    51   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | SYS_C008270 |  4444 |       |    10   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID">5555 AND "EMPLOYEE_ID"<9999)


-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |     1 |    59 |   252   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |     1 |    59 |   252   (1)| 00:00:04 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("LAST_NAME"='Rogers')

-----------------------------------------------------------------------------------------
| Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |           |     1 |    59 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES |     1 |    59 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | LAST_NAME |     1 |       |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("LAST_NAME"='Rogers')

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |  1750 |   100K|   253   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |  1750 |   100K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("LAST_NAME" LIKE 'R%')
   
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |  1750 |   100K|   253   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |  1750 |   100K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("LAST_NAME" LIKE 'R%')
  
 
--Перепишем запрос для возможности использования функционального индекса

select * 
from employees
where substr(last_name,1,1)='R';
   
------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |  1001 | 63063 |   172   (0)| 00:00:03 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES  |  1001 | 63063 |   172   (0)| 00:00:03 |
|*  2 |   INDEX RANGE SCAN          | LAST_NAME2 |   400 |       |     3   (0)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access(SUBSTR("LAST_NAME",1,1)='R')


------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |   126 |  7938 |    47   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES  |   126 |  7938 |    47   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | MANAGER_ID |   126 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("MANAGER_ID"=122)


------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |   254 | 16002 |    93   (0)| 00:00:02 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES  |   254 | 16002 |    93   (0)| 00:00:02 |
|*  2 |   INDEX RANGE SCAN          | MANAGER_ID |   254 |       |     2   (0)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("MANAGER_ID"<122)
   
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           | 99726 |  6135K|   253   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES | 99726 |  6135K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("MANAGER_ID">122)
   
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |  4590 |   282K|   253   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |  4590 |   282K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("MANAGER_ID"<133 AND "MANAGER_ID">122)
   
-----------------------------------------------------------------------------------------
| Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |           | 20183 |  1241K|    45   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES | 20183 |  1241K|    45   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | JOB_ID2   |   400 |       |    26   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("JOB_ID"='FI_MGR')
   2 - access(SUBSTR("JOB_ID",1,1)='F')
   

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |  5005 |   307K|   253   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |  5005 |   307K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("JOB_ID" LIKE '%CLERK')
   
------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |   250 | 15750 |   250   (0)| 00:00:04 |
|*  1 |  FILTER                      |           |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| EMPLOYEES |   250 | 15750 |   250   (0)| 00:00:04 |
|*  3 |    INDEX RANGE SCAN          | HIRE_DATE |   450 |       |     3   (0)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(TO_DATE('01-JAN-96')<=TO_DATE('01-JAN-98'))
   3 - access("HIRE_DATE">='01-JAN-96' AND "HIRE_DATE"<='01-JAN-98')
   
/*
3.6 Сравнить значения COST для однотипных запросов при отсутствии и наличии 
индексов.
*/

/*
При RBO-оптимизации используется индексное сканирование и, например, в случае операций '<' или '>'
используется RANGE-индексное сканирование, которое не всегда является оправданным, а именно
использование RANGE-индексного сканирования уместно тогда, когда в выводе присутствует не более Х% от общего количества строк.

Например, запрос
*/

select * 
from employees
where employee_id > 5555;

--выводит 100206 - 5555 = 94651 строку

План запроса при RBO-оптимизации
---------------------------------------------------
| Id  | Operation                   | Name        |
---------------------------------------------------
|   0 | SELECT STATEMENT            |             |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES   |
|*  2 |   INDEX RANGE SCAN          | SYS_C008270 |
---------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID">5555)

Note
-----
   - rule based optimizer used (consider using cbo)
   
План запроса при СBO-оптимизации

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           | 94652 |  5453K|   253   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES | 94652 |  5453K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("EMPLOYEE_ID">5555)
   
-- Как видим, используя собранную статистику, Oracle решает отказаться от RANGE-индексного сканирования и правильно делает

-- Ставим эксперименты и находим граничные значения

select * 
from employees
where employee_id < 22672; -- всё ещё использует INDEX RANGE SCAN  

select * 
from employees
where employee_id < 22673; -- уже использует TABLE ACCESS FULL

-- Общее количество строк 100107, вывод 1-го запроса 22572, таким образом Х = 22572/100107*100% = 22,55 %
-- В разных версиях Oracle указаны разные Х, почему именно такая цифра достоверно неизвестно.


/*  
Этап 4. Анализ и управление сложными запросами 
4.1 В решениях лабораторной работы № 6: 
- выбрать запросы, включающие более двух таблиц во FROM-фразе; 
- используя команды управления методами доступа к данным, установить порядок связи 
типа ORDERED и STAR; 
- для полученных пар запросов определить план их выполнения и сравнить значения 
COST.
*/

--STAR is deprecated from Oracle 10g

/*
Выполнить запрос, который получает название страны с минимальным количеством 
сотрудников по сравнению с другими странами. 
*/

--SELECT c.COUNTRY_NAME, count(*) as "Number of Employees"
SELECT /*+ORDERED */ c.COUNTRY_NAME, count(*) as "Number of Employees"
FROM COUNTRIES c 
JOIN LOCATIONS l USING (country_id)
JOIN DEPARTMENTS d USING (location_id)
JOIN EMPLOYEES e USING (department_id)
GROUP BY c.COUNTRY_NAME
HAVING count(*) = (SELECT MIN(count(*))
                  FROM COUNTRIES c 
                  JOIN LOCATIONS l USING (country_id)
                  JOIN DEPARTMENTS d USING (location_id)
                  JOIN EMPLOYEES e USING (department_id)
                  GROUP BY c.COUNTRY_NAME);
                  
                 
----------------------------------------------------------------------------------------
| Id  | Operation               | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |             |     1 |    48 |   265   (4)| 00:00:04 |
|*  1 |  FILTER                 |             |       |       |            |          |
|   2 |   HASH GROUP BY         |             |     1 |    48 |   265   (4)| 00:00:04 |
|*  3 |    HASH JOIN            |             | 99494 |  4663K|   261   (2)| 00:00:04 |
|*  4 |     HASH JOIN           |             |    27 |  1188 |     7  (15)| 00:00:01 |
|*  5 |      HASH JOIN          |             |    23 |   414 |     5  (20)| 00:00:01 |
|   6 |       TABLE ACCESS FULL | LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
|   7 |       TABLE ACCESS FULL | COUNTRIES   |    25 |   300 |     2   (0)| 00:00:01 |
|   8 |      TABLE ACCESS FULL  | DEPARTMENTS |    27 |   702 |     2   (0)| 00:00:01 |
|   9 |     TABLE ACCESS FULL   | EMPLOYEES   |   100K|   391K|   253   (1)| 00:00:04 |
|  10 |   SORT AGGREGATE        |             |     1 |    48 |   265   (4)| 00:00:04 |
|  11 |    SORT GROUP BY        |             |     1 |    48 |   265   (4)| 00:00:04 |
|* 12 |     HASH JOIN           |             | 99494 |  4663K|   261   (2)| 00:00:04 |
|* 13 |      HASH JOIN          |             |    27 |  1188 |     7  (15)| 00:00:01 |
|* 14 |       HASH JOIN         |             |    23 |   414 |     5  (20)| 00:00:01 |
|  15 |        TABLE ACCESS FULL| LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
|  16 |        TABLE ACCESS FULL| COUNTRIES   |    25 |   300 |     2   (0)| 00:00:01 |
|  17 |       TABLE ACCESS FULL | DEPARTMENTS |    27 |   702 |     2   (0)| 00:00:01 |
|  18 |      TABLE ACCESS FULL  | EMPLOYEES   |   100K|   391K|   253   (1)| 00:00:04 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(COUNT(*)= (SELECT MIN(COUNT(*)) FROM "EMPLOYEES"
              "E","DEPARTMENTS" "D","LOCATIONS" "L","COUNTRIES" "C" WHERE
              "C"."COUNTRY_ID"="L"."COUNTRY_ID" AND "L"."LOCATION_ID"="D"."LOCATION_ID" AND
              "D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID" GROUP BY "C"."COUNTRY_NAME"))
   3 - access("D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID")
   4 - access("L"."LOCATION_ID"="D"."LOCATION_ID")
   5 - access("C"."COUNTRY_ID"="L"."COUNTRY_ID")
  12 - access("D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID")
  13 - access("L"."LOCATION_ID"="D"."LOCATION_ID")
  14 - access("C"."COUNTRY_ID"="L"."COUNTRY_ID")

Note
-----
   - dynamic sampling used for this statement (level=2)  
   
---------------------------------------------------------------------------------------
| Id  | Operation               | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |             |     1 |    29 |   265   (4)| 00:00:04 |
|*  1 |  FILTER                 |             |       |       |            |          |
|   2 |   HASH GROUP BY         |             |     1 |    29 |   265   (4)| 00:00:04 |
|*  3 |    HASH JOIN            |             | 99494 |  2817K|   261   (2)| 00:00:04 |
|*  4 |     HASH JOIN           |             |    27 |   675 |     7  (15)| 00:00:01 |
|*  5 |      HASH JOIN          |             |    23 |   414 |     5  (20)| 00:00:01 |
|   6 |       TABLE ACCESS FULL | COUNTRIES   |    25 |   300 |     2   (0)| 00:00:01 |
|   7 |       TABLE ACCESS FULL | LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
|   8 |      TABLE ACCESS FULL  | DEPARTMENTS |    27 |   189 |     2   (0)| 00:00:01 |
|   9 |     TABLE ACCESS FULL   | EMPLOYEES   |   100K|   391K|   253   (1)| 00:00:04 |
|  10 |   SORT AGGREGATE        |             |     1 |    29 |   265   (4)| 00:00:04 |
|  11 |    SORT GROUP BY        |             |     1 |    29 |   265   (4)| 00:00:04 |
|* 12 |     HASH JOIN           |             | 99494 |  2817K|   261   (2)| 00:00:04 |
|* 13 |      HASH JOIN          |             |    27 |   675 |     7  (15)| 00:00:01 |
|* 14 |       HASH JOIN         |             |    23 |   414 |     5  (20)| 00:00:01 |
|  15 |        TABLE ACCESS FULL| LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
|  16 |        TABLE ACCESS FULL| COUNTRIES   |    25 |   300 |     2   (0)| 00:00:01 |
|  17 |       TABLE ACCESS FULL | DEPARTMENTS |    27 |   189 |     2   (0)| 00:00:01 |
|  18 |      TABLE ACCESS FULL  | EMPLOYEES   |   100K|   391K|   253   (1)| 00:00:04 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(COUNT(*)= (SELECT MIN(COUNT(*)) FROM "EMPLOYEES"
              "E","DEPARTMENTS" "D","LOCATIONS" "L","COUNTRIES" "C" WHERE
              "C"."COUNTRY_ID"="L"."COUNTRY_ID" AND "L"."LOCATION_ID"="D"."LOCATION_ID" AND
              "D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID" GROUP BY "C"."COUNTRY_NAME"))
   3 - access("D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID")
   4 - access("L"."LOCATION_ID"="D"."LOCATION_ID")
   5 - access("C"."COUNTRY_ID"="L"."COUNTRY_ID")
  12 - access("D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID")
  13 - access("L"."LOCATION_ID"="D"."LOCATION_ID")
  14 - access("C"."COUNTRY_ID"="L"."COUNTRY_ID")       
         
/*
Выполнить  запрос,  который  получает  список  стран  и  подразделений,  в  которых  не 
работают сотрудники. 
*/    

--SELECT c.COUNTRY_NAME, dept.DEPARTMENT_NAME              
SELECT /*+ORDERED */ c.COUNTRY_NAME, dept.DEPARTMENT_NAME
FROM DEPARTMENTS dept LEFT JOIN EMPLOYEES emp ON (dept.DEPARTMENT_ID = emp.DEPARTMENT_ID)
JOIN LOCATIONS loc ON (loc.LOCATION_ID = dept.LOCATION_ID)
JOIN COUNTRIES c ON (loc.COUNTRY_ID = c.COUNTRY_ID)
WHERE NOT EXISTS (SELECT emp2.EMPLOYEE_ID
FROM EMPLOYEES emp2
WHERE dept.DEPARTMENT_ID = emp2.DEPARTMENT_ID);

-------------------------------------------------------------------------------------
| Id  | Operation             | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |             | 99494 |  6704K|   515   (2)| 00:00:07 |
|*  1 |  HASH JOIN OUTER      |             | 99494 |  6704K|   515   (2)| 00:00:07 |
|*  2 |   HASH JOIN ANTI      |             |    27 |  1755 |   261   (2)| 00:00:04 |
|*  3 |    HASH JOIN          |             |    27 |  1647 |     7  (15)| 00:00:01 |
|*  4 |     HASH JOIN         |             |    23 |   414 |     5  (20)| 00:00:01 |
|   5 |      TABLE ACCESS FULL| LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
|   6 |      TABLE ACCESS FULL| COUNTRIES   |    25 |   300 |     2   (0)| 00:00:01 |
|   7 |     TABLE ACCESS FULL | DEPARTMENTS |    27 |  1161 |     2   (0)| 00:00:01 |
|   8 |    TABLE ACCESS FULL  | EMPLOYEES   |   100K|   391K|   253   (1)| 00:00:04 |
|   9 |   TABLE ACCESS FULL   | EMPLOYEES   |   100K|   391K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("DEPT"."DEPARTMENT_ID"="EMP"."DEPARTMENT_ID"(+))
   2 - access("DEPT"."DEPARTMENT_ID"="EMP2"."DEPARTMENT_ID")
   3 - access("LOC"."LOCATION_ID"="DEPT"."LOCATION_ID")
   4 - access("LOC"."COUNTRY_ID"="C"."COUNTRY_ID")

Note
-----
   - dynamic sampling used for this statement (level=2)
   
-------------------------------------------------------------------------------------
| Id  | Operation             | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |             | 97243 |  4273K|   516   (2)| 00:00:07 |
|*  1 |  HASH JOIN            |             | 97243 |  4273K|   516   (2)| 00:00:07 |
|   2 |   TABLE ACCESS FULL   | COUNTRIES   |    25 |   300 |     2   (0)| 00:00:01 |
|*  3 |   HASH JOIN           |             | 97243 |  3133K|   513   (2)| 00:00:07 |
|   4 |    TABLE ACCESS FULL  | LOCATIONS   |    23 |   138 |     2   (0)| 00:00:01 |
|*  5 |    HASH JOIN OUTER    |             | 97243 |  2564K|   510   (2)| 00:00:07 |
|*  6 |     HASH JOIN ANTI    |             |    17 |   391 |   256   (2)| 00:00:04 |
|   7 |      TABLE ACCESS FULL| DEPARTMENTS |    27 |   513 |     2   (0)| 00:00:01 |
|   8 |      TABLE ACCESS FULL| EMPLOYEES   |   100K|   391K|   253   (1)| 00:00:04 |
|   9 |     TABLE ACCESS FULL | EMPLOYEES   |   100K|   391K|   253   (1)| 00:00:04 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("LOC"."COUNTRY_ID"="C"."COUNTRY_ID")
   3 - access("LOC"."LOCATION_ID"="DEPT"."LOCATION_ID")
   5 - access("DEPT"."DEPARTMENT_ID"="EMP"."DEPARTMENT_ID"(+))
   6 - access("DEPT"."DEPARTMENT_ID"="EMP2"."DEPARTMENT_ID")

   
/* 
4.2 С учетом рекомендаций по использованию индексов создать индексы для запросов, 
которые получены в пункте 4.1. 
*/
CREATE INDEX department_id ON employees (department_id);
CREATE INDEX location_id ON departments (location_id);
CREATE INDEX country_id ON locations (country_id);
/*
4.3 Для полученных пар запросов отдельно с учетом связи типа ORDERED и STAR
определить план их выполнения и сравнить значения COST. 
*/
------------------------------------------------------------------------------------------
| Id  | Operation                | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |               |     1 |    29 |    69  (11)| 00:00:01 |
|*  1 |  FILTER                  |               |       |       |            |          |
|   2 |   HASH GROUP BY          |               |     1 |    29 |    69  (11)| 00:00:01 |
|*  3 |    HASH JOIN             |               | 99494 |  2817K|    65   (5)| 00:00:01 |
|*  4 |     HASH JOIN            |               |    27 |   675 |     7  (15)| 00:00:01 |
|*  5 |      HASH JOIN           |               |    23 |   414 |     5  (20)| 00:00:01 |
|   6 |       TABLE ACCESS FULL  | COUNTRIES     |    25 |   300 |     2   (0)| 00:00:01 |
|   7 |       TABLE ACCESS FULL  | LOCATIONS     |    23 |   138 |     2   (0)| 00:00:01 |
|   8 |      TABLE ACCESS FULL   | DEPARTMENTS   |    27 |   189 |     2   (0)| 00:00:01 |
|   9 |     INDEX FAST FULL SCAN | DEPARTMENT_ID |   100K|   391K|    57   (2)| 00:00:01 |
|  10 |   SORT AGGREGATE         |               |     1 |    29 |    69  (11)| 00:00:01 |
|  11 |    SORT GROUP BY         |               |     1 |    29 |    69  (11)| 00:00:01 |
|* 12 |     HASH JOIN            |               | 99494 |  2817K|    65   (5)| 00:00:01 |
|* 13 |      HASH JOIN           |               |    27 |   675 |     7  (15)| 00:00:01 |
|* 14 |       HASH JOIN          |               |    23 |   414 |     5  (20)| 00:00:01 |
|  15 |        TABLE ACCESS FULL | LOCATIONS     |    23 |   138 |     2   (0)| 00:00:01 |
|  16 |        TABLE ACCESS FULL | COUNTRIES     |    25 |   300 |     2   (0)| 00:00:01 |
|  17 |       TABLE ACCESS FULL  | DEPARTMENTS   |    27 |   189 |     2   (0)| 00:00:01 |
|  18 |      INDEX FAST FULL SCAN| DEPARTMENT_ID |   100K|   391K|    57   (2)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(COUNT(*)= (SELECT MIN(COUNT(*)) FROM "EMPLOYEES" "E","DEPARTMENTS"
              "D","LOCATIONS" "L","COUNTRIES" "C" WHERE "C"."COUNTRY_ID"="L"."COUNTRY_ID" AND
              "L"."LOCATION_ID"="D"."LOCATION_ID" AND "D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID"
              GROUP BY "C"."COUNTRY_NAME"))
   3 - access("D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID")
   4 - access("L"."LOCATION_ID"="D"."LOCATION_ID")
   5 - access("C"."COUNTRY_ID"="L"."COUNTRY_ID")
  12 - access("D"."DEPARTMENT_ID"="E"."DEPARTMENT_ID")
  13 - access("L"."LOCATION_ID"="D"."LOCATION_ID")
  14 - access("C"."COUNTRY_ID"="L"."COUNTRY_ID")
  
  
  
-----------------------------------------------------------------------------------------
| Id  | Operation               | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |               | 97243 |  4273K|    92   (4)| 00:00:02 |
|*  1 |  HASH JOIN              |               | 97243 |  4273K|    92   (4)| 00:00:02 |
|   2 |   TABLE ACCESS FULL     | COUNTRIES     |    25 |   300 |     2   (0)| 00:00:01 |
|*  3 |   HASH JOIN             |               | 97243 |  3133K|    90   (4)| 00:00:02 |
|   4 |    TABLE ACCESS FULL    | LOCATIONS     |    23 |   138 |     2   (0)| 00:00:01 |
|*  5 |    HASH JOIN OUTER      |               | 97243 |  2564K|    87   (3)| 00:00:02 |
|   6 |     NESTED LOOPS ANTI   |               |    17 |   391 |    29   (0)| 00:00:01 |
|   7 |      TABLE ACCESS FULL  | DEPARTMENTS   |    27 |   513 |     2   (0)| 00:00:01 |
|*  8 |      INDEX RANGE SCAN   | DEPARTMENT_ID | 38503 |   150K|     1   (0)| 00:00:01 |
|   9 |     INDEX FAST FULL SCAN| DEPARTMENT_ID |   100K|   391K|    57   (2)| 00:00:01 |
-----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("LOC"."COUNTRY_ID"="C"."COUNTRY_ID")
   3 - access("LOC"."LOCATION_ID"="DEPT"."LOCATION_ID")
   5 - access("DEPT"."DEPARTMENT_ID"="EMP"."DEPARTMENT_ID"(+))
   8 - access("DEPT"."DEPARTMENT_ID"="EMP2"."DEPARTMENT_ID")
   
/*
4.4 В решениях лабораторной работы № 6: 
- выбрать запросы, включающие операторы IN, NOT IN, EXISTS, NOT EXISTS; - выполнить эквивалентную замену операторов (IN на EXISTS, EXISTS на IN), 
обеспечивающий тот же ответ на запрос; 
- для полученных пар запросов определить план их выполнения и сравнить значения 
COST.
*/

drop index job_id;
drop index job_id2;

/*
Выполнить запрос, который: 
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
|   0 | SELECT STATEMENT   |           |    19 |   684 |   255   (1)| 00:00:04 |
|*  1 |  HASH JOIN SEMI    |           |    19 |   684 |   255   (1)| 00:00:04 |
|   2 |   TABLE ACCESS FULL| JOBS      |    19 |   513 |     2   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| EMPLOYEES |   100K|   879K|   253   (1)| 00:00:04 |
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("E"."JOB_ID"="J"."JOB_ID")

SELECT j.job_title
	FROM jobs j
	WHERE j.job_id IN (
			SELECT e.job_id 
			FROM employees e 
			WHERE e.job_id = j.job_id);
			
--------------------------------------------------------------------------------
| Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |    19 |   684 |   255   (1)| 00:00:04 |
|*  1 |  HASH JOIN SEMI    |           |    19 |   684 |   255   (1)| 00:00:04 |
|   2 |   TABLE ACCESS FULL| JOBS      |    19 |   513 |     2   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| EMPLOYEES |   100K|   879K|   253   (1)| 00:00:04 |
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."JOB_ID"="E"."JOB_ID")			
/* 
4.5 С учетом рекомендаций по использованию индексов создать индексы для запросов, 
которые получены в пункте 4.4. 
*/

--для таблицы JOBS поле job_id - первичный ключ, Оракл сам создаёт индекс 
CREATE INDEX job_id ON employees (job_id);

/*
4.6 Для полученных пар запросов отдельно с учетом индекса и без индекса определить 
план их выполнения и сравнить значения COST.
*/

SELECT j.job_title
	FROM jobs j
	WHERE EXISTS (
			SELECT e.job_id 
			FROM employees e 
			WHERE e.job_id = j.job_id);
-----------------------------------------------------------------------------
| Id  | Operation          | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |        |    19 |   684 |    21   (0)| 00:00:01 |
|   1 |  NESTED LOOPS SEMI |        |    19 |   684 |    21   (0)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| JOBS   |    19 |   513 |     2   (0)| 00:00:01 |
|*  3 |   INDEX RANGE SCAN | JOB_ID |   100K|   879K|     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("E"."JOB_ID"="J"."JOB_ID")

SELECT j.job_title
	FROM jobs j
	WHERE j.job_id IN (
			SELECT e.job_id 
			FROM employees e 
			WHERE e.job_id = j.job_id);   
-----------------------------------------------------------------------------
| Id  | Operation          | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |        |    19 |   684 |    21   (0)| 00:00:01 |
|   1 |  NESTED LOOPS SEMI |        |    19 |   684 |    21   (0)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| JOBS   |    19 |   513 |     2   (0)| 00:00:01 |
|*  3 |   INDEX RANGE SCAN | JOB_ID |   100K|   879K|     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("J"."JOB_ID"="E"."JOB_ID")