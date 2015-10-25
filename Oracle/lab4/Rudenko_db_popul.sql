/*
���� 1. �������� ������������� (VIEW) c ������������� ���������� ( ������ �� ) 
��������� ��������� ������ �� � ������ ���������� ������������ ��� ������ old_db (�����-
������� hr_create.sql � hr_popul.sql) 
1.1. � ������ �� ������� ������������� � ������������� ���������� � ���������� ��������. 
(��������! ���� ��� �������� ������������� ��������� ������, ��������� � �������, �� �� 
����� ������������ system ���������� ���������: GRANT CREATE VIEW TO ���_������������;) 
1.1.1 ������� �������������, �������: 
-  ��������  �������  �����������  �  ����������  �������,  ���������  �  �������  �����  �� 
������; 
-  �������  �����������  �����������  ���:  ������  �����  �  �������  ��������,  ���������  -  � 
������; 
- ���������� ������� ��������� �� ���������� ������; 
- ������������� ����������� �� �������� ������� ������. 
��������� ������ � ���������� �������������. 
*/

create view FIRST as 
select INITCAP(last_name) as Last_name, round(months_between(sysdate, hire_date)) as Months
from employees
order by Months Desc;

select * from FIRST;

/*
LAST_NAME                     MONTHS
------------------------- ----------
King                             345
Whalen                           337
Kochhar                          313
Hunold                           309
Ernst                            293
De Haan                          273
Mavris                           261
Baer                             261
Higgins                          261
Gietz                            261
Faviet                           254
Greenberg                        254
Raphaely                         250
*/

/*
1.1.2. ������� �������������, �������: 
- �������� �������, ����� �����������; 
-  ��������  ���  �����������  ��������  �  ��������  "Tax",  �������  ������������  ���  0.4%  �� 
������ ����� ������ ��� Programmer, 0.3% �� ������ ����� ������ ���Accountant, 0.2% �� ������ 
����� ������ ��� Sales Manager 0.1% �� ������ ����� ������ ��� Administration Assistant. 
��������� ������ � ���������� �������������. 
*/
create view SECOND as
select last_name, first_name, decode (job_title,'Programmer',0.4,
                                                 'Accountant',0.3,
                                                 'Sales Manager',0.2,
                                                 'Administration Assistant',0.1,
                                                 0)/100*round(months_between(sysdate, hire_date))*salary as Tax 
from employees join jobs using (job_id);

select * from SECOND;
/*
LAST_NAME                 FIRST_NAME                  TAX
------------------------- -------------------- ----------
King                      Steven                        0
Kochhar                   Neena                         0
De Haan                   Lex                           0
Hunold                    Alexander                 11124
Ernst                     Bruce                      7032
Austin                    David                      4320
Pataballa                 Valli                    4070,4
Lorentz                   Diana                      3360
Greenberg                 Nancy                         0
Faviet                    Daniel                     6858
Chen                      John                     5338,2
Sciarra                   Ismael                   5012,7
Urman                     Jose Manuel              4937,4
Popp                      Luis                       3933
Raphaely                  Den                           0
Khoo                      Alexander                     0
*/

/*
1.1.3. ������� �������������, �������: 
-  ��������  �������  �����������  �  ����������  ��������  ����  (�������,  �����������)  � 
������� �� ���������� �� ������; 
- ���������� ��������� � ����� 1999 ����. 
��������� ������ � ���������� �������������. 
*/

/*������ ���������� � ������� � SQL developer ��-�� ������� ��� ������ � �������*/
create view THIRD (last_name, first_name, Free_Days, hire_date, today) as
select last_name, first_name, 
(decode(
        mod(TO_CHAR(hire_date,'d')+mod(trunc(sysdate-hire_date),7),7),
        0,1,
        1,2,
        0) + trunc((sysdate-hire_date)/7)*2), hire_date, sysdate
from employees
where to_char(hire_date,'mm.yyyy') = '03.1999';

select * from THIRD;

/*
LAST_NAME                 FIRST_NAME            FREE_DAYS HIRE_DAT TODAY
------------------------- -------------------- ---------- -------- --------
Greene                    Danielle                   1730 19.03.99 17.10.15
Bates                     Elizabeth                  1728 24.03.99 17.10.15
Jones                     Vance                      1730 17.03.99 17.10.15
*/


/*
���� 2. ��������� ���������� ������ ��, �������� ������ � �������� ( ����� �� ) 
0. ��������� ��������� ����� �� � ������ ���������� ������������ ��� ������ new_db. 

/*
2.1.  ���  ����  ������  �����  ��  �������  ����������  ������������������,  �������������� 
�������������� �������� ����� �������� �������, �������� � ��������� ����. 

/*
drop sequence employee_id ;
drop sequence department_id;
drop sequence location_id;
drop sequence country_id;
drop sequence region_id;
*/


Create sequence employee_id start with 555;
Create sequence department_id start with 333;
Create sequence location_id start with 111;
Create sequence country_id start with 77;
Create sequence region_id start with 99;

/*
Sequence EMPLOYEE_ID created.


Sequence DEPARTMENT_ID created.


Sequence LOCATION_ID created.


Sequence COUNTRY_ID created.

Sequence REGION_ID created.
*/

/*
2.2. ��� ������ ������� ����� �� ������� 2 ������� �� �������� ������(������ ��� ������).  
*/

/*
INSERT INTO jobs VALUES (job_id.nextval, 'Manager');
INSERT INTO jobs VALUES (job_id.nextval, 'Programmer');

INSERT INTO regions VALUES (region_id.nextval, 'Australia');
INSERT INTO regions VALUES (region_id.nextval, 'North America');

INSERT INTO countries VALUES (country_id.nextval, 'Australia',1);
INSERT INTO countries VALUES (country_id.nextval, 'Canada',2);

INSERT INTO locations VALUES (location_id.nextval, 1,'Sydney','MainStreet');
INSERT INTO locations VALUES (location_id.nextval, 2,'Toronto','LongStreet');

INSERT INTO departments VALUES (department_id.nextval, 'HR',1,1);
INSERT INTO departments VALUES (department_id.nextval, 'Logistic',2,2);

INSERT INTO employees VALUES (employee_id.nextval, 'Big','Boss',sysdate-2000,1,6000,null,null,1);
INSERT INTO employees VALUES (employee_id.nextval, 'John','Doe',sysdate,2,6000,null,1,2);
INSERT INTO employees VALUES (employee_id.nextval, 'Jane','Doe',sysdate,1,4500,null,1,1);
*/

INSERT INTO jobs VALUES ('NEW_M', 'NEW_Manager');
INSERT INTO jobs VALUES ('NEW_IT', 'NEW_Programmer');

INSERT INTO regions VALUES (region_id.nextval, 'Australia');
INSERT INTO regions VALUES (region_id.nextval, 'North America');

INSERT INTO countries VALUES (country_id.nextval, 'Australia',99);
INSERT INTO countries VALUES (country_id.nextval, 'Canada',100);

INSERT INTO locations VALUES (location_id.nextval, 77,'Sydney','MainStreet');
INSERT INTO locations VALUES (location_id.nextval, 78,'Toronto','LongStreet');

alter table departments drop constraint departments_fk1;

INSERT INTO departments VALUES (department_id.nextval, 'HR',556,111);
INSERT INTO departments VALUES (department_id.nextval, 'Logistic',557,112);

alter table employees drop constraint employees_fk1;
alter table employees drop constraint employees_fk2;

INSERT INTO employees VALUES (employee_id.nextval, 'Big','Boss',sysdate-2000,'NEW_M',6000,null,null,333);
INSERT INTO employees VALUES (employee_id.nextval, 'John','Doe',sysdate-1,'NEW_M',6000,null,555,333);
INSERT INTO employees VALUES (employee_id.nextval, 'Jane','Doe',sysdate-1,'NEW_IT',4500,null,555,334);

ALTER TABLE departments ADD CONSTRAINT departments_fk1
	FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
	
ALTER TABLE employees ADD CONSTRAINT employees_fk1
	FOREIGN KEY (job_id) REFERENCES jobs(job_id);
	
ALTER TABLE employees ADD CONSTRAINT employees_fk2
	FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

/*
1 row inserted.


1 row inserted.


1 row inserted.


1 row inserted.


1 row inserted.


1 row inserted.


1 row inserted.


1 row inserted.

Table DEPARTMENTS altered.


1 row inserted.


1 row inserted.


Table EMPLOYEES altered.


Table EMPLOYEES altered.


1 row inserted.


1 row inserted.


1 row inserted.


Table DEPARTMENTS altered.

Table EMPLOYEES altered.


Table EMPLOYEES altered.
*/

/*
2.3. ��������� ������� �� �������� ���� ��������� � ��. 
*/

commit;

/*
2.4. ��� ����� �� ������, ���������� ����������� ����������� �������� �����, ��������� 
�������  ��  ���������  ��������  �������  ��������  �����  ��  ��������,  �������������  �  ������� 
���������� ����� ��������������� �������. ��������� ������� ���� �� �������� ���������. 
*/

update COUNTRIES
set region_id = 15
where name = 'Canada';

/*
update COUNTRIES
set region_id = 15
where name = 'Canada'
Error report -
SQL Error: ORA-02291: integrity constraint (NEW_DB.COUNTRIES_FK) violated - parent key not found
02291. 00000 - "integrity constraint (%s.%s) violated - parent key not found"
*Cause:    A foreign key value has no matching primary key value.
*Action:   Delete the foreign key or add a matching primary key.
*/

/*
2.5. ��� ����� �� ������, ���������� ����������� ����������� ���������� �����, ��������� 
������� �� ��������� �������� ������� ���������� ����� �� ��������, ������������� � ������� 
�������� ����� ��������������� �������. ��������� ������� ���� �� �������� ���������. 
*/
update COUNTRIES
set country_id = 12
where name = 'Canada';
/*
update COUNTRIES
set country_id = 12
where name = 'Canada'
Error report -
SQL Error: ORA-02292: integrity constraint (NEW_DB.LOCATIONS_FK) violated - child record found
02292. 00000 - "integrity constraint (%s.%s) violated - child record found"
*Cause:    attempted to delete a parent key value that had a foreign
           dependency.
*Action:   delete dependencies first then parent or disable constraint.
*/

/*
2.6. ��� ����� �� ������, ���������� ����������� ����������� ���������� �����, ��������� 
����  �������  ��  ��������  ������  ��  ���������  �������  ����������  �����,  ��������������  � 
������� �������� ����� ��������������� �������. ��������� ������� ���� �� ���������. 
*/

delete from employees
where employee_id = 557;

/*
delete from employees
where employee_id = 557
Error report -
SQL Error: ORA-02292: integrity constraint (NEW_DB.DEPARTMENTS_FK1) violated - child record found
02292. 00000 - "integrity constraint (%s.%s) violated - child record found"
*Cause:    attempted to delete a parent key value that had a foreign
           dependency.
*Action:   delete dependencies first then parent or disable constraint.
*/

/*
2.7.  ���  �����  ��  ������  ��������  �����������  �����������  ��������  �����, 
�������������� ��������� ��������. ��������� ������� 2.6 ��� ���������� �������. 
*/

alter table employees
drop constraint employees_fk1;

ALTER TABLE employees ADD CONSTRAINT employees_fk1
	FOREIGN KEY (job_id) REFERENCES jobs(job_id) on delete cascade;
  
alter table departments
drop constraint departments_fk1;

ALTER TABLE departments ADD CONSTRAINT departments_fk1
	FOREIGN KEY (manager_id) REFERENCES employees(employee_id) on delete cascade;

delete from employees
where employee_id = 557;

/*
1 row deleted.
*/
	
/*
2.8. ��������� ������� �� ������ (������) �������� �������� �� ������ 2.6 
*/
rollback;

/*
���� 3. ������� �������� ��������� �� 
� ������ �� ��������� ��������� ��������. 
3.1. ��������� ������������ �� 5% ���� ������������� (Programmer), ������� ����������� 
����� 20 ���. 
*/
UPDATE employees
	SET commission_pct = nvl(commission_pct,0)+0.05
		WHERE (job_id ='IT_PROG') and round(months_between(sysdate, hire_date))>240;
commit;
/*
3.2  �������  ����  �����������  (�������  ��  �������),  �������  �����������  �����  20  ���  �� 
��������� Shipping Clerk. ����� ��������� ��������� ���������� �� �����������  ����������� � 
��������� ������� employee_drop, ������� �������� ����� �� ���������, ��� � ������� employee.  
��� �������� ������� ������������ ����������� ���� CREATE TABLE � AS SELECT � 
���������  ��������  �������������  �������  �������  �  ��������  ��  ����������  ��  ������  �� 
������. 
��� �������� ��������� �������� �������� ��������� ����������. 
*/

create table employee_drop as 
SELECT * 
from employees
WHERE (job_id ='SH_CLERK') and round(months_between(sysdate, hire_date))>210;

delete from employees
WHERE (job_id ='SH_CLERK') and round(months_between(sysdate, hire_date))>210;

commit;

/*
���� 4. ������� ������ � �������������� � ����������� �� ������ �� � ����� �� 
���������  �������  ������  ��  ������  ������  ��  �  �������  �����  ��.  ������������ 
��������� ������� �������� �� ��������: 
INSERT INTO NEW_DB.�������_�����_�� (������� ����� ��) 
SELECT �. FROM OLD_DB.�������_������_�� �; 
���������� ������ ��������� ���� ������� � �������� ������ ��, ��������� �������: 
GRANT SELECT ON OLD_DB.�������_������_�� TO NEW_DB;
��� �������� �������� � ���� ����� ����������. 
*/


grant select on old_db.jobs to new_db;
grant select on old_db.regions to new_db;
grant select on old_db.locations to new_db;
grant select on old_db.countries to new_db;
grant select on old_db.departments to new_db;
grant select on old_db.employees to new_db;


alter table jobs
modify (title nvarchar2(40));

insert into jobs
select old_db.jobs.job_id, old_db.jobs.JOB_TITLE from old_db.jobs;

insert into regions
select * from OLD_DB.REGIONS;

/*
insert into countries
select * from OLD_DB.COUNTRIES;
���� ������ �� ����������
 |
 |
 \/
����� ������� �������� ������ ����������, �� � ���� ����, ��� ��� �������� ����� ����� ������ ���� country_id � ������ ��� Number, � � ����� ������� ��� char, 
������� ������ �������� ����� ����������� ���������
*/

commit;
/*

19 rows inserted.

4 rows inserted.

*/
