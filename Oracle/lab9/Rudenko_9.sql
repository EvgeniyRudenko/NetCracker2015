/*
Задание 1. Журналирование DML-операций 
Разработать механизм журнализации DML-операций, выполняемых над таблицей с 
подразделениями, учитывая следующие действия: 
- создать таблицу с именем LOG_DEPARTMENTS. Структура таблицы должна 
включать: имя пользователя, тип операции, дата выполнения операции, атрибуты, 
содержащие старые и новые значения. 
- создать триггер журналирования. 
Проверить работу триггера журналирования для операции INSERT, UPDATE, DELETE.
*/

CREATE TABLE LOG_DEPARTMENTS (
	old_dep_id       NUMBER(4),
          dep_id	       NUMBER(4),		
	old_dep_name     VARCHAR2(30),
          dep_name         VARCHAR2(30),	
	old_man_id       NUMBER(6),	
	man_id	       NUMBER(6),	
	old_loc_id       NUMBER(4),
	loc_id           NUMBER(4),
          OP_TYPE	       CHAR(6),	
	USER_NAME	       CHAR(20),	
	CHANGE_DATE      DATE 		
); 

CREATE OR REPLACE TRIGGER LOG_DEPARTMENTS
	AFTER INSERT OR UPDATE OR DELETE ON DEPARTMENTS 
	FOR EACH ROW
DECLARE 
	OP_TYPE1 LOG_DEPARTMENTS.OP_TYPE%TYPE;
BEGIN
	IF INSERTING THEN OP_TYPE1 := 'INSERT'; END IF;
	IF UPDATING THEN OP_TYPE1 := 'UPDATE';  END IF;
	IF DELETING THEN OP_TYPE1 := 'DELETE'; END IF;
	INSERT INTO LOG_DEPARTMENTS VALUES 
		(:OLD.department_id, :NEW.department_id, :OLD.department_name, :NEW.department_name,
                     :OLD.manager_id, :NEW.manager_id, :OLD.location_id, :NEW.location_id, OP_TYPE1, USER, SYSDATE);
END;
/

insert into departments values (300,'NEW_DEPARTMENT',200,1500);


/* 
Задание 2. Автоматическая генерация целочисленных значений PK-колонок 
В  предыдущих  лабораторных  работах  необходимо  было  создавать  генераторы 
последовательностей  (SEQUENCE)  для  PK-атрибутов  таблиц.  Известно,  что  в  Oracle  11XE
отсутствует возможность: 
1) создавать  генераторы,  автоматически  проставляя  начальные  значения  с  учетом 
содержимого  таблиц  БД,  что  требует  от  администратора  вручную  выполнять  запросы  на 
получение максимальных значений PK-атрибутов; 
2) включать созданные генераторы в секцию DEFAULT описания колонок таблиц для 
автоматического  внесения  сгенерированного  значения  в  колонку,  что  требует  от 
программиста включать вручную функцию генерации NEXTVAL в INSERT-команды. 
Задание 2.1 Учитывая 2-й недостаток управления генераторами, разработать триггер 
автоматического  внесения  сгенерированного  значения  в  PK-колонки  целочисленного  типа 
таблицы EMPLOYEES и DEPARTMENTS. 
Проверить  работу  триггера  для  операций  INSERT  в  таблицы  EMPLOYEES  и 
DEPARTMENTS.Задание  
*/
create sequence dep_seq start with 310;

CREATE OR REPLACE TRIGGER TRIG_SEQ
	BEFORE INSERT ON DEPARTMENTS 
	FOR EACH ROW
BEGIN
  :NEW.department_id:=dep_seq.nextval;
END;
/

insert into departments (DEPARTMENT_NAME, MANAGER_ID, LOCATION_ID) 
                 values ('NEW_DEP',200,1700);
/*
2.2  Учитывая  1-й  недостаток  управления  генераторами,  а  также  используя 
разработанный  в  4-м  задании  7-й  лабораторной  работы  анонимный  PL/SQL-блок  по 
автоматическому  созданию  генераторов  целочисленных  значений  PK-колонок,  создать 
хранимую процедуру с учетом свойств: 
- название процедуры – CREATE_SEQUENCE; 
- входные параметры процедуры: имя таблицы, имя PK-колонки; 
- в  коде  процедуры  используется  динамический  запрос,  содержащий  PL/SQL-код 
триггера, пример которого создан в решении задания 1.1 
Проверить работу процедуры для таблиц EMPLOYEES и DEPARTMENTS.
*/
CREATE OR REPLACE PROCEDURE create_sequence
(table_name VARCHAR2, pk_col VARCHAR2)
IS
  max_pk NUMBER(5);
BEGIN
  begin
  EXECUTE IMMEDIATE 'select max (' || pk_col || ') from ' || table_name  into max_pk ;
  exception
    when others then
       RAISE_APPLICATION_ERROR(-20100, 'Error'); 
  end;

begin
  EXECUTE IMMEDIATE 'drop sequence ' || pk_col;
  EXECUTE IMMEDIATE 'create sequence ' || pk_col || ' start with ' || (max_pk + 1);
  EXCEPTION
  WHEN OTHERS THEN 
       EXECUTE IMMEDIATE 'create sequence ' || pk_col || ' start with ' || (max_pk + 1);
END;

begin
EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER TRIG_SEQ_' || table_name ||
                  ' BEFORE INSERT ON ' || table_name || 
                  ' FOR EACH ROW
                   BEGIN
                   :NEW.' || pk_col || ':= ' || pk_col || '.nextval;
                   END;';
end;

end;
/

begin
  CREATE_SEQUENCE('DEPARTMENTS','DEPARTMENT_ID');
  CREATE_SEQUENCE('EMPLOYEES','EMPLOYEE_ID');
end;
/

/*
Задание 3. Обеспечение сложных правил ограничения целостности данных 
Разработать сложное ограничение целостности по запрету устанавливать зарплаты 
сотрудникам, которые противоречат данным таблицы с учетом страны расположения 
подразделения и должности, на которой работает сотрудник.  
Ограничение разработать с учетом следующих действий: 
- создать таблицу SALARIES с ограничениями по зарплатам сотрудников, 
включающая: COUNTRY_NAME, JOB_TITLE, SALARY_MIN, SALARY_MAX. Заполнить 
таблицу двумя тестовыми записями; 
- создать триггер по контролю указанного ограничения целостности. 
Проверить работу триггера для операции INSERT, UPDATE. 
*/

CREATE TABLE SALARIES (
  COUNTRY_NAME  VARCHAR2(40),
  JOB_TITLE     VARCHAR2(35),
  SALARY_MIN    NUMBER (6),
  SALARY_MAX    NUMBER (6)
);

INSERT INTO SALARIES
SELECT c.COUNTRY_NAME, j.JOB_TITLE, min(e.SALARY), max (e.salary)
FROM JOBS j 
join EMPLOYEES e USING (job_id)
join DEPARTMENTS d USING (department_id)
join LOCATIONS l USING (location_id)
join COUNTRIES c USING (country_id)
group by c.COUNTRY_NAME, j.JOB_TITLE
order by 1,2;

CREATE VIEW DEP_COUNTRIES AS
  SELECT distinct department_id, c.COUNTRY_NAME 
  FROM EMPLOYEES e
  join DEPARTMENTS d USING (department_id)
  join LOCATIONS l USING (location_id)
  join COUNTRIES c USING (country_id);
  
Create view jobs_v as
select * from jobs;

CREATE OR REPLACE TRIGGER SALARY_CHECK 
	BEFORE INSERT OR UPDATE ON EMPLOYEES 
	FOR EACH ROW
DECLARE
	MIN_SALARY SALARIES.SALARY_MIN%TYPE;
	MAX_SALARY SALARIES.SALARY_MAX%TYPE;
	SALARY_OUT_OF_RANGE EXCEPTION;
  v_job_title JOBS.JOB_TITLE%TYPE;
  v_country_name COUNTRIES.COUNTRY_NAME%TYPE;
  v_department_id DEPARTMENTS.DEPARTMENT_ID%TYPE;
BEGIN
  select job_title into v_job_title
  from JOBS_v where JOB_ID = :OLD.JOB_ID;
  v_department_id := :OLD.department_id; 
  SELECT country_name into v_country_name
  from DEP_COUNTRIES
  where department_id = v_department_id;
  SELECT SALARY_MIN, SALARY_MAX INTO MIN_SALARY, MAX_SALARY 
	FROM SALARIES s
	WHERE s.JOB_TITLE = v_job_title and s.COUNTRY_NAME = v_country_name;
  /* если новый оклад служащего меньше или больше, 
	чем ограничение по должностной классификации, 
	выполняется исключительная ситуация, 
	а операция отменяется. */
	IF (:NEW.SALARY < MIN_SALARY OR :NEW.SALARY > MAX_SALARY) THEN 
    RAISE SALARY_OUT_OF_RANGE;
	END IF;
EXCEPTION
	-- обработка исключения по недопустимому значению оклада сотрудника
	WHEN SALARY_OUT_OF_RANGE THEN
		RAISE_APPLICATION_ERROR(-20300, 'Оклад ' || :NEW.SALARY || 
				' вне диапазона для должности ' || v_job_title || ' в стране ' || v_country_name || 
				' для служащего ' || :NEW.FIRST_NAME || ' ' || :NEW.LAST_NAME);
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20301, 
				'Неверная должностная классификация ' || v_job_title);
END;
/

update employees
set salary = 2000
where employee_id=135;


/*
Задание 4. Материализация представлений (виртуальных таблиц) 
Сократить временя расчета средней зарплаты сотрудников в каждом подразделении 
на основе материализации соответствующего запроса. 
4.1 Создать запрос на получение максимальной зарплаты сотрудников в каждом 
подразделении 
4.2 Создать таблицу MAX_DEPART_SALARY по созданному ранее запросу. 
4.3 Создать триггер по автоматическому согласованию содержимого этой таблицы и 
содержимого таблицы сотрудников. 
Проверить работу триггера для операции INSERT, UPDATE, DELETE.
*/
drop table MAX_DEPART_SALARY; 
CREATE TABLE MAX_DEPART_SALARY AS
  select department_id dept_id, max(salary) max_salary
  from departments d LEFT join employees e using (department_id)
  group by department_id;
 
  
--Вот так для удаления попробовал, но не уверен, как правильно надо

CREATE OR REPLACE TRIGGER MAX_SALARY
AFTER INSERT OR DELETE ON EMPLOYEES 
FOR EACH ROW
DECLARE 
  PRAGMA AUTONOMOUS_TRANSACTION;	
  sal Employees.salary%TYPE;
BEGIN
  select max(salary) into sal
  from EMPLOYEES
  where department_id = :old.department_id and employee_id<>:old.employee_id;
  update max_depart_salary
  set max_salary = sal 
  where dept_id = :old.department_id;
  commit;
END;
/

alter table employees disable constraint SYS_C007961;
alter table departments disable constraint DEPT_MGR_FK;

delete from employees
where employee_id=205;

/* 
Задание 5. Автоматическая генерация строковых значений PK-колонок 
Некоторые  PK-колонки  таблиц  БД  из  лабораторной  работы  содержат  строковые 
значения, что не позволяет создавать генераторы. Примером такой таблицы является таблица 
JOBS и ее колонка JOI_ID.Разработать функцию генерации значения колонки JOB_ID , предполагая следующее: 
- название функции GET_JOB_ID; 
- входной параметр функции – строка со значением колонки JOB_TITLE; 
- значение  колонки  JOB_ID  получать  из  значения  JOB_TITLE  как  объединение 
первых букв слов из значения колонки с разделителем «_», например, Shipping Clerk = S_C
- для получения в цикле первых букв слов рекомендуется использовать функции: 
o INSTR( string, substring, start_position); 
o SUBSTR( string, start_position, length); 
- после формирования значения проверять его на уникальность в БД; 
- если полученное значение не является уникальным, добавлять к нему цифру. 
Разработать  триггер  автоматического  внесения  или  изменения  сгенерированного 
значения в PK-колонку JOB_ID  строкового типа таблицы JOBS, использующий созданную 
процедуру GET_JOB_ID. 
Проверить работу триггера для операции INSERT, UPDATE. 
*/
CREATE OR REPLACE FUNCTION GET_JOB_ID (v_job_title VARCHAR2)
RETURN VARCHAR2
IS
str JOBS.JOB_TITLE%TYPE;
pos NUMBER(2);
job_id JOBS.JOB_ID%TYPE;
n Number (2);
BEGIN
  str := upper(substr(v_job_title,1,1));
  pos:=instr(v_job_title,' ');
  while pos > 0 loop
    str := str || '_' ||upper(substr(v_job_title,pos+1,1));
    pos := instr(v_job_title,' ', pos+1); 
  end loop;
  
  select J.JOB_ID into job_id
  from JOBS J
  where J.JOB_ID = str;
  
  select count(*) into n
  from JOBS J
  where J.JOB_ID like str||'%';
  str := str || '_' || n;
  RETURN str;
EXCEPTION
  when no_data_found then
  RETURN str;
END;
/

CREATE OR REPLACE TRIGGER TRIG_JOBS
	BEFORE INSERT OR UPDATE ON JOBS
	FOR EACH ROW
declare
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  :NEW.job_id:=GET_JOB_ID(:NEW.job_title);
  commit;
END;
/

alter table EMPLOYEES
drop constraint SYS_C007960;

alter table JOB_HISTORY
drop constraint SYS_C007969;

begin
for i in 1..20 loop
  insert into jobs (JOB_TITLE) values ('Junior Software Developer');
  commit;
end loop;
  update jobs
  set job_title = 'Oracle Big boss' 
  where job_title ='Accountant';
  commit;
end;
/
/*
Задание 6. Генерация PL/SQL-кода журналирующих триггеров 
Если  в  БД  существует  множество  таблиц,  которые  необходимо  журналировать,  то 
такой процесс выполнения 1-го заданий может оказаться трудоемким. 
Разработать  функцию  автоматического  создания  PL/SQL-кода  журналирующих 
триггеров для заданной таблицы, предполагая следующее: 
- название функции - GENERATE_LOGGING; 
- входной параметр функции – название журналируемой таблицы; 
- возвращаемое значение – строка PL/SQL-кода журналирующего триггера; 
- список  колонок  журналируемой  таблицы  формируется  на  основании 
динамического запроса к таблице USER_TAB_COLUMNS; 
- в  функции  создается  PL/SQL-код  журналирующего  триггера,  который 
выполняется через динамический запрос. 
Проверить  работу  функции  на  примере  таблицы  DEPARTMENTS,  сравнив 
полученный код с кодом из решения 1-го задания. 
*/

create or replace procedure GENERATE_LOGGING (tab_name VARCHAR2)
IS
TYPE rec_table is table of USER_TAB_COLUMNS%ROWTYPE;
tab1 rec_table:=rec_table();
str VARCHAR2(3000);
str1 VARCHAR2 (2000);
col NUMBER; --количество столбцов таблицы
len Varchar2(10); -- размер типов %CHAR%, NUMBER

BEGIN

SELECT count(*) into col FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = UPPER(tab_name);
tab1.extend(col);

SELECT *
BULK COLLECT INTO tab1 FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = UPPER(tab_name);

for i in tab1.first..tab1.last loop
  if tab1(i).data_type like '%CHAR%' then
     len :=  tab1(i).data_length;
     len:= ' (' || len || ')';
  elsif tab1(i).data_type = 'NUMBER' then
     if nvl(tab1(i).data_scale,0)=0 then
        len:=nvl(tab1(i).data_precision,1);
     else
        len:=tab1(i).data_precision || ', ' || tab1(i).data_scale;
     end if;
     len:= ' (' || len || ')';
  else
     len:=''; 
  end if;
 
  str:= str || 'old_' || tab1(i).column_name
            || '  ' || tab1(i).data_type || len || ', ' || chr(10)
            || 'new_' || tab1(i).column_name 
            || '  ' || tab1(i).data_type || len || ', ' || chr(10); 
end loop;
str:=substr(str,1,length(str)-1);

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE LOG_' || tab_name;
      EXCEPTION
         WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
               RAISE;
            END IF;
      END;

str:='
CREATE TABLE LOG_' || tab_name || chr(10) || '(' || chr(10) 
                         || str || chr(10) || 'OP_TYPE  CHAR(6), ' ||chr(10)||	
                         'USER_NAME	CHAR(20), ' || chr(10) ||	
                         'CHANGE_DATE  DATE' || chr(10) || ')';
execute immediate str;
DBMS_OUTPUT.PUT_LINE(str);

FOR i in tab1.first..tab1.last loop
    str1:= str1 || ':OLD.' || tab1(i).column_name || ', ' || ':NEW.' || tab1(i).column_name || ', ';
end loop;
str1:= '(' || str1 || 'OP_TYPE1, USER, SYSDATE)'; 
str1:= 'insert into LOG_' || tab_name || ' values ' || str1;

DBMS_OUTPUT.PUT_LINE('str1 = ' || str1);

str:= '
CREATE OR REPLACE TRIGGER LOG_' || tab_name || '	AFTER INSERT OR UPDATE OR DELETE ON ' || tab_name || '
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
	OP_TYPE1 LOG_' || tab_name || '.OP_TYPE%TYPE;
  str1 VARCHAR2 (2000);
  Type col_var is VARRAY (' || col || ') of USER_TAB_COLUMNS.COLUMN_NAME%TYPE;
  cols col_var;
BEGIN
  IF INSERTING THEN OP_TYPE1 := ''INSERT''; END IF;
	IF UPDATING THEN OP_TYPE1 := ''UPDATE'';  END IF;
	IF DELETING THEN OP_TYPE1 := ''DELETE''; END IF;
   
  ' || str1 || ';
  commit;
END;';
  
  EXECUTE IMMEDIATE str;
  DBMS_OUTPUT.PUT_LINE(str);

END;
/

execute GENERATE_LOGGING('employees');

execute GENERATE_LOGGING('countries');

update countries 
set country_name='Marocco)'
where country_name='Japan';

