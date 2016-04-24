/*
������� 1. �������������� DML-�������� 
����������� �������� ������������ DML-��������, ����������� ��� �������� � 
���������������, �������� ��������� ��������: 
- ������� ������� � ������ LOG_DEPARTMENTS. ��������� ������� ������ 
��������: ��� ������������, ��� ��������, ���� ���������� ��������, ��������, 
���������� ������ � ����� ��������. 
- ������� ������� ��������������. 
��������� ������ �������� �������������� ��� �������� INSERT, UPDATE, DELETE.
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
������� 2. �������������� ��������� ������������� �������� PK-������� 
�  ����������  ������������  �������  ����������  ����  ���������  ���������� 
�������������������  (SEQUENCE)  ���  PK-���������  ������.  ��������,  ���  �  Oracle  11XE
����������� �����������: 
1) ���������  ����������,  �������������  ����������  ���������  ��������  �  ������ 
�����������  ������  ��,  ���  �������  ��  ��������������  �������  ���������  �������  �� 
��������� ������������ �������� PK-���������; 
2) �������� ��������� ���������� � ������ DEFAULT �������� ������� ������ ��� 
���������������  ��������  ����������������  ��������  �  �������,  ���  �������  �� 
������������ �������� ������� ������� ��������� NEXTVAL � INSERT-�������. 
������� 2.1 �������� 2-� ���������� ���������� ������������, ����������� ������� 
���������������  ��������  ����������������  ��������  �  PK-�������  ��������������  ���� 
������� EMPLOYEES � DEPARTMENTS. 
���������  ������  ��������  ���  ��������  INSERT  �  �������  EMPLOYEES  � 
DEPARTMENTS.�������  
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
2.2  ��������  1-�  ����������  ����������  ������������,  �  �����  ��������� 
�������������  �  4-�  �������  7-�  ������������  ������  ���������  PL/SQL-����  �� 
���������������  ��������  �����������  �������������  ��������  PK-�������,  ������� 
�������� ��������� � ������ �������: 
- �������� ��������� � CREATE_SEQUENCE; 
- ������� ��������� ���������: ��� �������, ��� PK-�������; 
- �  ����  ���������  ������������  ������������  ������,  ����������  PL/SQL-��� 
��������, ������ �������� ������ � ������� ������� 1.1 
��������� ������ ��������� ��� ������ EMPLOYEES � DEPARTMENTS.
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
������� 3. ����������� ������� ������ ����������� ����������� ������ 
����������� ������� ����������� ����������� �� ������� ������������� �������� 
�����������, ������� ������������ ������ ������� � ������ ������ ������������ 
������������� � ���������, �� ������� �������� ���������.  
����������� ����������� � ������ ��������� ��������: 
- ������� ������� SALARIES � ������������� �� ��������� �����������, 
����������: COUNTRY_NAME, JOB_TITLE, SALARY_MIN, SALARY_MAX. ��������� 
������� ����� ��������� ��������; 
- ������� ������� �� �������� ���������� ����������� �����������. 
��������� ������ �������� ��� �������� INSERT, UPDATE. 
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
  /* ���� ����� ����� ��������� ������ ��� ������, 
	��� ����������� �� ����������� �������������, 
	����������� �������������� ��������, 
	� �������� ����������. */
	IF (:NEW.SALARY < MIN_SALARY OR :NEW.SALARY > MAX_SALARY) THEN 
    RAISE SALARY_OUT_OF_RANGE;
	END IF;
EXCEPTION
	-- ��������� ���������� �� ������������� �������� ������ ����������
	WHEN SALARY_OUT_OF_RANGE THEN
		RAISE_APPLICATION_ERROR(-20300, '����� ' || :NEW.SALARY || 
				' ��� ��������� ��� ��������� ' || v_job_title || ' � ������ ' || v_country_name || 
				' ��� ��������� ' || :NEW.FIRST_NAME || ' ' || :NEW.LAST_NAME);
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20301, 
				'�������� ����������� ������������� ' || v_job_title);
END;
/

update employees
set salary = 2000
where employee_id=135;


/*
������� 4. �������������� ������������� (����������� ������) 
��������� ������� ������� ������� �������� ����������� � ������ ������������� 
�� ������ �������������� ���������������� �������. 
4.1 ������� ������ �� ��������� ������������ �������� ����������� � ������ 
������������� 
4.2 ������� ������� MAX_DEPART_SALARY �� ���������� ����� �������. 
4.3 ������� ������� �� ��������������� ������������ ����������� ���� ������� � 
����������� ������� �����������. 
��������� ������ �������� ��� �������� INSERT, UPDATE, DELETE.
*/
drop table MAX_DEPART_SALARY; 
CREATE TABLE MAX_DEPART_SALARY AS
  select department_id dept_id, max(salary) max_salary
  from departments d LEFT join employees e using (department_id)
  group by department_id;
 
  
--��� ��� ��� �������� ����������, �� �� ������, ��� ��������� ����

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
������� 5. �������������� ��������� ��������� �������� PK-������� 
���������  PK-�������  ������  ��  ��  ������������  ������  ��������  ��������� 
��������, ��� �� ��������� ��������� ����������. �������� ����� ������� �������� ������� 
JOBS � �� ������� JOI_ID.����������� ������� ��������� �������� ������� JOB_ID , ����������� ���������: 
- �������� ������� GET_JOB_ID; 
- ������� �������� ������� � ������ �� ��������� ������� JOB_TITLE; 
- ��������  �������  JOB_ID  ��������  ��  ��������  JOB_TITLE  ���  ����������� 
������ ���� ���� �� �������� ������� � ������������ �_�, ��������, Shipping Clerk = S_C
- ��� ��������� � ����� ������ ���� ���� ������������� ������������ �������: 
o INSTR( string, substring, start_position); 
o SUBSTR( string, start_position, length); 
- ����� ������������ �������� ��������� ��� �� ������������ � ��; 
- ���� ���������� �������� �� �������� ����������, ��������� � ���� �����. 
�����������  �������  ���������������  ��������  ���  ���������  ���������������� 
�������� � PK-������� JOB_ID  ���������� ���� ������� JOBS, ������������ ��������� 
��������� GET_JOB_ID. 
��������� ������ �������� ��� �������� INSERT, UPDATE. 
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
������� 6. ��������� PL/SQL-���� ������������� ��������� 
����  �  ��  ����������  ���������  ������,  �������  ����������  �������������,  �� 
����� ������� ���������� 1-�� ������� ����� ��������� ����������. 
�����������  �������  ���������������  ��������  PL/SQL-����  ������������� 
��������� ��� �������� �������, ����������� ���������: 
- �������� ������� - GENERATE_LOGGING; 
- ������� �������� ������� � �������� ������������� �������; 
- ������������ �������� � ������ PL/SQL-���� �������������� ��������; 
- ������  �������  �������������  �������  �����������  ��  ��������� 
������������� ������� � ������� USER_TAB_COLUMNS; 
- �  �������  ���������  PL/SQL-���  ��������������  ��������,  ������� 
����������� ����� ������������ ������. 
���������  ������  �������  ��  �������  �������  DEPARTMENTS,  ������� 
���������� ��� � ����� �� ������� 1-�� �������. 
*/

create or replace procedure GENERATE_LOGGING (tab_name VARCHAR2)
IS
TYPE rec_table is table of USER_TAB_COLUMNS%ROWTYPE;
tab1 rec_table:=rec_table();
str VARCHAR2(3000);
str1 VARCHAR2 (2000);
col NUMBER; --���������� �������� �������
len Varchar2(10); -- ������ ����� %CHAR%, NUMBER

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

