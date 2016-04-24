/*
������� 1 �������������� ������������� ����������� ���������� �������� 
�  ����������  ������������  �������  ����������  ����  ���������  ���������� 
������������������� ��� PK-��������� ������ � ��� ������������ �������. � Oracle 11XE
�����������  �����������  ���������  ����������  (sequence),  �������������  ���������� 
���������  ��������  �  ������  �����������  ������  ��,  ���  �������  ��  �������������� 
������� ��������� ������� �� ��������� ������������ �������� PK-���������. 
������� ��������� PL/SQL-����, ���������������� ���� ������� �� ������ �����: 
- �������� ������� ���������� � �� � ������ ������� ��������� �������� ��� ������ 
Departments,  Employees,  ���������  ������  ��  �������  select  sequence_name  from 
user_sequences where sequence_name = '��������_�_�������_��������';
- ���� ���������� ��� ����������, ���������� ������� �������� �����������; 
- �����������  �������������  ��������  ��������������  �������������  �  ������� 
Departments  � ��������������  ���������� � ������� Employees; 
- �������� ����������� � ������ �������� ���������� ��������, ������������ �� 1 
���������� ������������ ��������. 
*/
            
DECLARE
  s_name varchar2(30);
  max_emp departments.department_ID%TYPE;
BEGIN
  begin
  select max(DEPARTMENT_ID) 
  into max_emp 
  from DEPARTMENTS; 
  exception
    when others then
       RAISE_APPLICATION_ERROR(-20100, 'Error'); 
  end;
  
  SELECT sequence_name
  INTO s_name
  FROM SYS.USER_SEQUENCES
  WHERE SEQUENCE_NAME = 'DEPT_ID';

  EXECUTE IMMEDIATE 'drop sequence dept_id';
  EXECUTE IMMEDIATE 'create sequence dept_id start with ' || max_emp + 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN 
       EXECUTE IMMEDIATE 'create sequence dept_id start with ' || max_emp + 1;
END;
/

DECLARE
  s_name varchar2(30);
  max_emp employees.employee_ID%TYPE;
BEGIN
  begin
  select max(EMPLOYEE_ID) 
  into max_emp 
  from EMPLOYEES; 
  exception
    when others then
       RAISE_APPLICATION_ERROR(-20100, 'Error'); 
  end;
  
  SELECT sequence_name
  INTO s_name
  FROM SYS.USER_SEQUENCES
  WHERE SEQUENCE_NAME = 'EMPLOYEE_ID';

  EXECUTE IMMEDIATE 'drop sequence employee_id';
  EXECUTE IMMEDIATE 'create sequence employee_id start with ' || (max_emp + 1);
EXCEPTION
  WHEN NO_DATA_FOUND THEN 
       EXECUTE IMMEDIATE 'create sequence employee_id start with ' || (max_emp + 1);
END; 
/*
������� 2 �������� �������� ��������� � ��  
�����  ���  ����������  ������������  ������������������,  ������,  ��������������� 
������������,  ����������  ������������  �������  �  �����������  �����,  �����������  � 
�������� ���������� �� ������������ (�����, ������, �������� ). ��� ����� ������������ 
���������� ������������� (�����������) �����. 
2.1 ��� ������������ ������������� �������� ��� ������ ������ �� ������������� 
��� �������� (��������) ��������� �������� ��������� ������. 
 �������  ������  ����  INSERT  ALL  ��  ��������������  �����������  �  ��  10000 
�����������, �������� ���������: 
- ��� ��������������� ���������� ������������ ���������; 
- ���,  �������  ����������  ������������  ���  ����  ���,  �������  +  �������� 
����������; 
- ����� ���������� ������������ ��� ���� ��� + �������� ����������; 
- ���� ���������� ������������ ��� �01.01.2000� + �������� ����������; 
- ��������� �������� ������� - ������������, �� �� �������������� ������������ 
�����������. 
*/

INSERT ALL
INTO employees VALUES 
     (employee_id.nextval, null, 'RUDENKO' || rn, '@gmail.com' || rn,  
     null, to_date('01.01.2000','DD.MM.YYYY') + rn, 'ST_MAN', 100, null, 100,90)  
SELECT rownum as rn FROM dual
CONNECT BY level <= 10000;
/

/*
2.2 ���������� ������� ��������� ��������� ������� ����������. 
�������    ���������  PL/SQL-����,  �������������  ��������������  �  ��  10000 
�����������, �������� ������� �� ������� 2.1
*/

--��� ��������� ������ �� ���������� sequence employee_id �� ������ 1.1

BEGIN
FOR i IN 1..10000 LOOP
    INSERT
    INTO employees VALUES 
    (employee_id.nextval, null, 'RUDENKO_1' || i, '@gmail.com_1' || i,  
     null, to_date('01.01.2000','DD.MM.YYYY') + i, 'ST_MAN', 100, null, 100,90);
     END LOOP;	
END;
/

/*
������� 3 ��������� ���������� 
3.1 � ������� 1-�� ������� �������� PL/SQL-��� ���, ����� �� ���� ������������� 
��������� ������� ����������� � ��. 
*/

-- �������: ������ ������ ������� � ����� EXCEPTION

DECLARE
  s_name varchar2(30);
  max_emp departments.department_ID%TYPE;
BEGIN
  begin
  select max(DEPARTMENT_ID) 
  into max_emp 
  from DEPARTMENTS; 
  exception
    when others then
       RAISE_APPLICATION_ERROR(-20100, 'Error'); 
  end;

  EXECUTE IMMEDIATE 'drop sequence dept_id';
  EXECUTE IMMEDIATE 'create sequence dept_id start with ' || (max_emp + 1);
EXCEPTION
  WHEN OTHERS THEN 
       EXECUTE IMMEDIATE 'create sequence dept_id start with ' || (max_emp + 1);
END;
/

DECLARE
  s_name varchar2(30);
  max_emp employees.employee_ID%TYPE;
BEGIN
  begin
  select max(EMPLOYEE_ID) 
  into max_emp 
  from EMPLOYEES; 
  exception
    when others then
       RAISE_APPLICATION_ERROR(-20100, 'Error'); 
  end;

  EXECUTE IMMEDIATE 'drop sequence employee_id';
  EXECUTE IMMEDIATE 'create sequence employee_id start with ' || (max_emp + 1);
EXCEPTION
  WHEN OTHERS THEN 
       EXECUTE IMMEDIATE 'create sequence employee_id start with ' || (max_emp + 1);
END;
/

/*
3.2 � ������� ������� 2.2 �������� �������� ����������� �����������: 
-  ��������  ����������  ��  �������  �����������,  ����������  ����������� 
����������� UNIQUE, � ������� ������ ���� � Login Ivanov already exists�; 
- �������� ������������� �������� � ������� ������ ���� �Salary = -10. But salary 
must be >= 0� 
������  ���������  �  PL/SQL-���,  ����������  �  ������������  ��������� 
����������. 
*/
DECLARE
  loop_var Number(3);
BEGIN
      INSERT
      INTO employees VALUES 
      (employee_id.nextval, null, 'RUDENKO1', '@gmail.com1',  
       null, to_date('01.01.2000','DD.MM.YYYY'), 'ST_MAN', 100, null, 100,90);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
         RAISE_APPLICATION_ERROR(-20555, 'Login @gmail.com1 already exists');
END;
/

DECLARE
  loop_var Number(3);
BEGIN
      INSERT
      INTO employees VALUES 
      (employee_id.nextval, null, '1111RUDENKO1', '@1111gmail.com1',  
       null, to_date('01.01.2000','DD.MM.YYYY'), 'ST_MAN', -10, null, 100,90);
EXCEPTION
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20555, 'Salary = -10. But salary must be >= 0');
END;
/
/*
������� 4 ������ � ��������� 
������� �������� ���������� � ���� PL/SQL-����: 
1) �������� ������ ��������������� �������������, � ������� ���� ����������; 
2) �������� ������ ����������� 2-�� �� ������ �������������; 
3) ��������� ����������� � 3-� �� ������ �������������
4) ��������� ������ � ����������� � ������� job_history 
*/

declare

  cursor c1 is
              select distinct DEPARTMENT_ID
              from DEPARTMENTS JOIN EMPLOYEES using (department_id);
  dep_from  c1%ROWTYPE;
  dep_where c1%ROWTYPE;

begin

  open c1;
  fetch c1 into dep_from;
  fetch c1 into dep_from;
  fetch c1 into dep_where;
  close c1;
  
  for dep_rec in (SELECT E.EMPLOYEE_ID, E.HIRE_DATE, SYSDATE, E.JOB_ID, E.DEPARTMENT_ID
                  FROM EMPLOYEES E
                  WHERE E.DEPARTMENT_ID=dep_from.department_id) loop
                  INSERT INTO JOB_HISTORY VALUES dep_rec;
                  UPDATE EMPLOYEES
                  SET DEPARTMENT_ID = dep_where.department_id
                  WHERE DEPARTMENT_ID = dep_rec.department_id;      
  end loop;

end;
/


/*
������� 5 ������������ ������� 
�������  ���������  PL/SQL-����,  �������  �������������  �������������� 
������������� Oracle � ������ �������: 
- ����� ������������� ��������� � ������� ����������� �� ������� employees; 
- ������ ������������ ��� ����� ���������; 
- ������������  �����  �����������  ���������������  �����  �����  �  �������,  �.�. 
������������� ����������� ������� GRANT CONNECT TO ������������; 
- ������������-����������, ����������� �� ���������, ��������� � ����������� ( � 
��������  ���������  ����  �����  manager  ),  ������������  �����  ���������  ���������,  �.�. 
������������� ����������� ������� GRANT RESOURCE TO ������������; 
*/

/*

disconnect

connect system/1234

grant create user, connect, resource to lab7 with admin option;

disconnect

connect lab7/123

*/

DECLARE
    CURSOR c1 IS
		SELECT E.EMAIL, E.Employee_id, J.JOB_ID , J.JOB_TITLE
		FROM EMPLOYEES E JOIN JOBS J on (J.JOB_ID = E.JOB_ID)
    where E.EMPLOYEE_ID < 206;
BEGIN
  FOR emp_rec IN c1 LOOP
		EXECUTE IMMEDIATE 'Create user ' || emp_rec.email || ' identified by ' || emp_rec.employee_id;
    EXECUTE IMMEDIATE 'Grant connect to ' || emp_rec.email;	
    IF INSTR(emp_rec.JOB_TITLE,'Manager')<>0 THEN
       EXECUTE IMMEDIATE 'Grant resource to ' || emp_rec.email;	
    END IF;
    END LOOP;
END;
/


-- ��� ����� �� ���� ������� �������

DECLARE
	CURSOR c1 IS
		SELECT U.USERNAME
		FROM SYS.ALL_USERS U
    where TRUNC(U.CREATED) = TRUNC(sysdate);
BEGIN
  FOR emp_rec IN c1 LOOP
		EXECUTE IMMEDIATE 'Drop user ' || emp_rec.username || ' cascade';
  END LOOP;
END;
/