/*
������� 1 �������� �������� �������� �� �������� ������ � ������� 
���������  ����������  �������  1.2  ��  ������������  ������  7,  �������  ��������� 
PL/SQL-���� � �������� ���������, ��������, ���: 
- �������� ��������� � generate_emp; 
- ������� ���������� �������� ���������� �������� �����; 
- ������������ �������� �������� �������� FORALL. 
*/
CREATE OR REPLACE PROCEDURE generate_emp
	( 
                    num_of_rows IN NUMBER
	)
IS
   TYPE Employee IS TABLE OF Employees%ROWTYPE;
   emp_list Employee :=Employee();
BEGIN
  emp_list.extend(num_of_rows);
  FOR i IN 1..num_of_rows LOOP
    emp_list(i).employee_id := employee_id.nextval;
    emp_list(i).last_name := '1111RUDENKO_1' || i;
    emp_list(i).email := '1111@gmail.com_1' || i;
    emp_list(i).hire_date := to_date('01.01.2000','DD.MM.YYYY') + i;
    emp_list(i).job_id := 'ST_MAN';
  END LOOP;
  
  FORALL i IN 1..num_of_rows
  INSERT INTO employees VALUES 
    (emp_list(i).employee_id, null, emp_list(i).last_name, emp_list(i).email,  
     null, emp_list(i).hire_date, emp_list(i).job_id, 100, null, 100,90);
END;
/

begin
  generate_emp(5);
end;
/
/*
���� 2 �������� �������� ��������, ������� � �������. 
2. ������� ����� pkg_dept �� ���������� �������� �������������, ����������:
*/

CREATE OR REPLACE PACKAGE pkg_dept IS

FUNCTION drop_dept( dep_name VARCHAR2 )
RETURN NUMBER;

PROCEDURE change 
(old_dep_name IN VARCHAR2, new_dep_name IN VARCHAR2);

FUNCTION create_dept
(dep_name VARCHAR2, var_city VARCHAR2, country VARCHAR2, region VARCHAR2)
RETURN NUMBER;

END pkg_dept;
/


CREATE OR REPLACE PACKAGE BODY pkg_dept IS
--
/*  
2.1 ������� �������� ��������� �������������, ��������, ���: 
- �������� ������� � drop_dept; 
- ������� ���������� �������� �������� �������������;
- ������������  ��������  �  ���  ����������  �������������,  �  ����  �������������  � 
�������� ��������� �� ���������, �� ���������� -1 
*/
FUNCTION drop_dept( dep_name VARCHAR2 )
RETURN NUMBER
IS
dep varchar2(40);
dep_id number(4);

BEGIN
  select DEPARTMENT_NAME, DEPARTMENT_ID into dep, dep_id
  from departments
  where DEPARTMENT_NAME=dep_name;
  
  Execute immediate 'delete from DEPARTMENTS where DEPARTMENT_ID = ' || dep_id;
  return dep_id;
EXCEPTION
  when no_data_found then
    return -1;
END;
--
/*
2.2 ��������� ��������� �������� �������������, ��������, ���: 
- �������� ��������� - change; 
- �������� ����������� �������� ������ �������� �������������,  
����� �������� �������������; 
- ���������  ������  ���������  �����������  �������������  ��  ������  ���������  � 
����������  �������������  �  �����  ���������  �  ���  �������������  �������� 
��������������� ��������� �� ������ � ��������� ����������� ���� ������. 
*/

PROCEDURE change 
(old_dep_name IN VARCHAR2, new_dep_name IN VARCHAR2)
IS
o_dep_name departments.department_name%TYPE;
n_dep_name NUMBER(2);
my_exception EXCEPTION;
begin
  
  SELECT DEPARTMENT_NAME INTO o_dep_name FROM DEPARTMENTS
  WHERE DEPARTMENT_NAME=old_dep_name;
  
  SELECT count(DEPARTMENT_NAME) INTO n_dep_name FROM DEPARTMENTS
  WHERE DEPARTMENT_NAME=new_dep_name;
  
  if n_dep_name=1 then 
    raise my_exception;
  end if;  
  
  Update DEPARTMENTS
  set DEPARTMENT_NAME = new_dep_name
  where DEPARTMENT_NAME = old_dep_name;
  
  DBMS_OUTPUT.PUT_LINE('�������� ������������� ' || old_dep_name || ' ������� �������� �� ' || new_dep_name);

EXCEPTION
  when no_data_found then DBMS_OUTPUT.PUT_LINE('������������� � ��������� ' || old_dep_name || ' �� ����������');
  when my_exception then DBMS_OUTPUT.PUT_LINE('������������� � ��������� ' || new_dep_name || ' ��� ����������');
END;
--
/*
2.3 ������� �������� �������������, ��������, ���: 
- �������� ������� � create_dept; 
- ��������  �����������  ��������  ��������  �������������,  ��������  ������, 
�������� ������, �������� �������); 
- ������������ �������� - ����� ��� ���������� �������������; 
- ����  ��������  ������  �����������  �  �������  ��,  ������  ����  ������������ 
�������� �������� ����� �������� � �������; 
- ����  ��������  �������������  ���  ����  �  �������,  ��������  ���������  ��  ������ 
�Department already exists� � ��������� ����������� ���� ������. 
*/

FUNCTION create_dept
(dep_name VARCHAR2, var_city VARCHAR2, country VARCHAR2, region VARCHAR2)
RETURN NUMBER
IS
dep_id departments.department_id%TYPE;
loc_id locations.location_id%TYPE;
n_dep_name NUMBER(2);
my_exception EXCEPTION;
begin
  
  SELECT count(DEPARTMENT_NAME) INTO n_dep_name FROM DEPARTMENTS
  WHERE DEPARTMENT_NAME=dep_name;
  
  if n_dep_name=1 then 
    raise my_exception;
  end if;
  
  SELECT MAX(DEPARTMENT_ID)+10 INTO dep_id FROM DEPARTMENTS;
  
  begin
    select location_id into loc_id 
    from locations l
    join countries using (country_id)
    join regions using (region_id)
    where city = var_city and country_name = country and region_name = region;
  exception
    when no_data_found then
    SELECT MAX(LOCATION_ID)+100 INTO loc_id FROM LOCATIONS;
    INSERT INTO LOCATIONS (LOCATION_ID, CITY, COUNTRY_ID) 
        VALUES (loc_id, var_city, (select country_id from countries where country_name = country));
  end;
 
 INSERT INTO DEPARTMENTS(DEPARTMENT_ID, DEPARTMENT_NAME, LOCATION_ID) VALUES (dep_id, dep_name, loc_id);
 DBMS_OUTPUT.PUT_LINE ('������� ������������� � ������� ' || dep_id);
 return dep_id;
 
 EXCEPTION
  when my_exception then 
  DBMS_OUTPUT.PUT_LINE('������������� � ��������� ' || dep_name || ' ��� ����������');
  DBMS_OUTPUT.PUT_LINE ('������������ �� �������');
  RETURN 0;
END;
--
END pkg_dept;
/


--����� ������� � ��������� ������ pkg_dept
declare 
result Number(4);
begin
  DBMS_OUTPUT.PUT_LINE(pkg_dept.drop_dept('IT555'));
  pkg_dept.change('IT', 'NEW_IT');
  result := pkg_dept.create_dept ('PL_SQL', 'Tokyo', 'Japan', 'Asia');
end;
/


/*
3. ������� ����� pkg_emp �� ���������� �������� �����������, ����������:  
*/

CREATE OR REPLACE PACKAGE pkg_emp IS

  PROCEDURE change
  (emp_name VARCHAR2, prev_job VARCHAR2, prev_dep VARCHAR2, new_job VARCHAR2, new_dep VARCHAR2, new_salary NUMBER);

  TYPE Emp_List IS TABLE OF Employees%ROWTYPE;
  FUNCTION drop_emp (dep_name VARCHAR2)
  RETURN Emp_List;
  
END pkg_emp;
/


CREATE OR REPLACE PACKAGE BODY pkg_emp IS
--
/*
3.1 ��������� ��������� ���������� � ����������, ��������, ���: 
- �������� ��������� - change; 
- ��������  �����������  ��������:  ���  ����������,  ������  ��������  ���������, 
������ �������� �������������, ����� �������� ���������, ����� �������� �������������, 
����� ��������; 
- ���������  ������  ���������  �������  �����  ����������,  ���  ������  �������� 
���������, ������������� �, ���� ����� ���, ������ ��������������� ��������� �� ������ 
� ��������� ����������� ���� ������; 
- ���������  ������  �������  �����  ��������  ���������,  �������������  �  �������� 
���������� ������, ���� ��� ���������� �� ������. 
*/

PROCEDURE change
(emp_name VARCHAR2, prev_job VARCHAR2, prev_dep VARCHAR2, new_job VARCHAR2, new_dep VARCHAR2, new_salary NUMBER)
IS
prev_salary employees.salary%TYPE;
prev_job_id VARCHAR2(10);
new_job_id jobs.job_id%TYPE;
prev_dep_id NUMBER(4);
new_dep_id departments.department_id%TYPE;
BEGIN
prev_job_id := 'x';
prev_dep_id := 0;
prev_salary:=0;

  --��������� �� �������� ���������� � ������������� � �� id
  select job_id into prev_job_id from jobs
  where job_title = prev_job;
  
  select job_id into new_job_id from jobs
  where job_title = new_job;
  
  select department_id into prev_dep_id from departments
  where department_name = prev_dep;
  
  select department_id into new_dep_id from departments
  where department_name = new_dep;
  
  select salary into prev_salary from employees
  where job_id=prev_job_id and department_id=prev_dep_id and first_name=emp_name;
  
  -- ���������  ������  �������  �����  ��������  ���������,  �������������  �  �������� 
  -- ���������� ������, ���� ��� ���������� �� ������   
  if (prev_job=new_job and prev_dep = new_dep and prev_salary=new_salary) then 
    DBMS_OUTPUT.PUT_LINE('����� ������ �� ���������� �� ������ � ���������� �� ����� ���������');
    return;
  end if;
  
  UPDATE EMPLOYEES
  SET job_id = new_job_id, department_id = new_dep_id, salary = new_salary
  WHERE job_id = prev_job_id
    AND department_id = prev_dep_id
      AND first_name = emp_name;
  DBMS_OUTPUT.PUT_LINE('���������� ��������� �������'); 

EXCEPTION
 when no_data_found then 
 if prev_job_id = 'x' then
  DBMS_OUTPUT.PUT_LINE('��������� ' || prev_job || ' �� ����������');
 end if;
 if prev_dep_id = 0 then
  DBMS_OUTPUT.PUT_LINE('������������ ' || prev_dep || ' �� ����������');
  return;
 end if;
 if prev_salary = 0 then
  DBMS_OUTPUT.PUT_LINE('��������� � ������ ' || emp_name || 
        ' �� �������� � ������������ ' || prev_dep || ' �� ��������� ' || prev_job);
 end if;
END;

--
/*
3.2 ������� �������� ���� ����������� ��������� �������������, ��������, ���: 
- �������� ������� � drop_emp; 
- ������� ���������� �������� �������� �������������;
- ���� ���������� ������������� �� ����������, ������ ��������������� ��������� 
�� ������ � ��������� ����������� ���� ������; 
- ������������  ��������  -  ������  ���������  �����������  �  �������:  ��� 
����������, ��� ����������.
*/
FUNCTION drop_emp (dep_name VARCHAR2)
RETURN Emp_List AS 
e_emp_list Emp_List:=Emp_List();
dep_id Number(4);
num_of_rows NUMBER(4);
BEGIN

select department_id into dep_id from departments
where DEPARTMENT_NAME = dep_name;

select count(*) into num_of_rows from employees
where DEPARTMENT_ID=dep_id;

e_emp_list.extend(num_of_rows);

delete from employees
where department_id = dep_id
RETURNING employee_id, first_name, 
          LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID
BULK COLLECT INTO e_emp_list;

FOR i IN e_emp_list.FIRST .. e_emp_list.LAST
LOOP
    DBMS_OUTPUT.PUT_LINE('ID: '|| e_emp_list(i).employee_id || '  First_name: ' || e_emp_list(i).first_name);
END LOOP;

return e_emp_list;

EXCEPTION
  when no_data_found then DBMS_OUTPUT.PUT_LINE('������������� ' || dep_name || ' �� ����������');
  when others then  DBMS_OUTPUT.PUT_LINE('���-�� ����� �� ���');
END;

END pkg_emp;
/


