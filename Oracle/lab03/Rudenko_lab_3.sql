/*
Создание SQL-запросов 
2.1 Выборка данных 
1.  Выполнить  запрос,  который  получает  фамилии  сотрудников  и  их  E-mail  адреса  в 
полном формате: значение атрибута E-mail + "@Netcracker.com" 
*/

SELECT last_name, email || '@Netcracker.com' as "Email"
FROM employees;

/*Результат:
LAST_NAME	Email
King	SKING@Netcracker.com
Kochhar	NKOCHHAR@Netcracker.com
De Haan	LDEHAAN@Netcracker.com
Hunold	AHUNOLD@Netcracker.com
Ernst	BERNST@Netcracker.com
Austin	DAUSTIN@Netcracker.com
Pataballa	VPATABAL@Netcracker.com
Lorentz	DLORENTZ@Netcracker.com
Greenberg	NGREENBE@Netcracker.com
Faviet	DFAVIET@Netcracker.com
*/

/*
2. Выполнить запрос, который: 
- получает фамилию сотрудников и их зарплату; 
- зарплата превышает 15000$. 
*/

SELECT last_name, salary
FROM employees
WHERE salary>15000;

/*Результат:
LAST_NAME	SALARY
King	24000
Kochhar	17000
De Haan	17000
*/

/*
3.  Выполнить  запрос,  который  получает  фамилии  сотрудников,  зарплату,  комиссионные, 
их зарплату за год с учетом комиссионных. 
*/

SELECT last_name, salary, COMMISSION_PCT, 12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees;

/*Результат:
LAST_NAME	SALARY	COMMISSION_PCT	Annual salary + comission
King	24000		          288000
Kochhar	17000		          204000
De Haan	17000		          204000
Hunold	9000		          108000
Ernst	6000		          72000
Austin	4800		          57600
Pataballa	4800		          57600
Lorentz	4200		          50400
Greenberg	12000		          144000
Faviet	9000		          108000
*/

/*
2.2 Работа со множествами 
1. Выполнить запрос, который: 
- получает для каждого сотрудника cтроку в формате 
'Dear '+A+ '  ' + B + ’! ' + ‘ Your salary = ‘ + C,
где  A  =  {‘Mr.’,’Mrs.’}  –  сокращенный  вариант  обращения  к  мужчине  или  женщине  
(предположить, что женщиной являются все сотрудницы, имя которых заканчивается на букву 
‘a’ или ‘e’)  
B – фамилия сотрудника; 
C – годовая зарплата с учетом комиссионных сотрудника 
*/

/*Добавил в вывод имя сотрудника для возможности протестировать запрос*/
SELECT 'Dear ' || 'Mrs ' || last_name || ' ' || first_name || '! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where first_name like '%a' or first_name like '%e'
Union
SELECT 'Dear ' || 'Mr ' || last_name || ' ' ||first_name ||'! Your salary = ' || 
12*(SALARY+NVL(COMMISSION_PCT,0)) AS "Annual salary + comission"
FROM employees
where first_name not like '%a' and first_name not like '%e';

/*Результат:
Annual salary + comission
Dear Mr Abel Ellen Your salary = 132003.6
Dear Mr Ande Sundar Your salary = 76801.2
Dear Mr Austin David Your salary = 57600
Dear Mr Baer Hermann Your salary = 120000
Dear Mr Baida Shelli Your salary = 34800
Dear Mr Banda Amit Your salary = 74401.2
Dear Mr Bates Elizabeth Your salary = 87601.8
Dear Mr Bell Sarah Your salary = 48000
Dear Mr Bernstein David Your salary = 114003
Dear Mr Bloom Harrison Your salary = 120002.4
.....
Dear Mrs Atkinson Mozhe Your salary = 33600
Dear Mrs Bissot Laura Your salary = 39600
Dear Mrs Cambrault Nanette Your salary = 90002.4
Dear Mrs Dellinger Julia Your salary = 40800
Dear Mrs Doran Louise Your salary = 90003.6
Dear Mrs Ernst Bruce Your salary = 72000
Dear Mrs Greene Danielle Your salary = 114001.8
Dear Mrs Hutton Alyssa Your salary = 105603
Dear Mrs Jones Vance Your salary = 33600
Dear Mrs King Janette Your salary = 120004.2
*/

/*
2.3 Операции соединения таблиц 
1. Выполнить запрос, который: 
- получает названия подразделений; 
- подразделения расположены в городе Seattle. 
*/
select department_name, city
from DEPARTMENTS, LOCATIONS
where DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and city='Seattle';
/*Результат:
DEPARTMENT_NAME	CITY
Administration	Seattle
Purchasing	Seattle
Executive	Seattle
Finance	Seattle
Accounting	Seattle
Treasury	Seattle
Corporate Tax	Seattle
Control And Credit	Seattle
Shareholder Services	Seattle
Benefits	Seattle
*/

/*
2. Выполнить запрос, который: 
- получает фамилию, должность, номер подразделения сотрудников 
- сотрудники работают в городе Toronto. 
*/
select last_name, job_title, employees.department_id, city
from EMPLOYEES, JOBS, DEPARTMENTS, LOCATIONS
where EMPLOYEES.JOB_ID=JOBS.JOB_ID and 
      DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and 
      city='Toronto';
/*Результат:
LAST_NAME	JOB_TITLE	DEPARTMENT_ID	CITY
King	President	90	Toronto
Kochhar	Administration Vice President	90	Toronto
De Haan	Administration Vice President	90	Toronto
Hunold	Programmer	60	Toronto
Ernst	Programmer	60	Toronto
Austin	Programmer	60	Toronto
Pataballa	Programmer	60	Toronto
Lorentz	Programmer	60	Toronto
Greenberg	Finance Manager	100	Toronto
Faviet	Accountant	100	Toronto
*/

/*
3. Выполнить запрос, который: 
- получает номер и фамилию сотрудника, номер и фамилию его менеджера 
- для сотрудников без менеджеров выводить фамилию менеджера в виде «No manager». 
*/
select E1.EMPLOYEE_ID, E1.LAST_NAME, E2.EMPLOYEE_ID as Manager_ID, NVL(E2.LAST_NAME, 'No manager') as Manager_last_name
from EMPLOYEES E1, EMPLOYEES E2
where E1.MANAGER_ID=E2.EMPLOYEE_ID(+);
/*Результат:
EMPLOYEE_ID	LAST_NAME	MANAGER_ID	MANAGER_LAST_NAME
201	Hartstein	100	King
149	Zlotkey	100	King
148	Cambrault	100	King
147	Errazuriz	100	King
146	Partners	100	King
145	Russell	100	King
124	Mourgos	100	King
123	Vollman	100	King
122	Kaufling	100	King
121	Fripp	100	King
*/

/*
4. Выполнить запрос, который: 
- получает  номер и название подразделений; 
- подразделения расположены в стране UNITED STATES OF AMERICA 
- в подразделениях не должно быть сотрудников. 
*/
select department_id, department_name, country_name
from DEPARTMENTS, LOCATIONS, COUNTRIES
where DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID and
      LOCATIONS.COUNTRY_ID = COUNTRIES.COUNTRY_ID
      and country_name = 'United States of America' and DEPARTMENTS.MANAGER_ID is NULL;
/*Результат:
DEPARTMENT_ID	DEPARTMENT_NAME	COUNTRY_NAME
120	Treasury	United States of America
130	Corporate Tax	United States of America
140	Control And Credit	United States of America
150	Shareholder Services	United States of America
160	Benefits	United States of America
170	Manufacturing	United States of America
180	Construction	United States of America
190	Contracting	United States of America
200	Operations	United States of America
210	IT Support	United States of America
*/

/*
2.4 Агрегация данных 
1. Выполнить запрос, который: 
- получает кол-во сотрудников в каждом подразделении; 
- кол-во сотрудников не должно быть меньше 2; 
*/
select EMPLOYEES.DEPARTMENT_ID, department_name, count(*) Number_of_employees
from EMPLOYEES, DEPARTMENTS
where EMPLOYEES.DEPARTMENT_ID=DEPARTMENTS.DEPARTMENT_ID
group by EMPLOYEES.DEPARTMENT_ID, department_name
having count(*)>2;
/*Результат:
DEPARTMENT_ID	DEPARTMENT_NAME	NUMBER_OF_EMPLOYEES
100	Finance	6
50	Shipping	45
90	Executive	3
30	Purchasing	6
60	IT	5
80	Sales	34
*/

/*
2. Выполнить запрос, который: 
- получает названия должностей и среднюю зарплату по должности; 
- должность должна быть связана с управлением, т.е. содержать слово Manager; 
- средняя зарплата не должна быть менее 10 тысяч. 
*/
select job_title, avg(salary) Average_salary
from EMPLOYEES, JOBS
where EMPLOYEES.JOB_ID=JOBS.JOB_ID
group by job_title
having (job_title like '%Manager%') and avg(salary)>10000;
/*Результат:
JOB_TITLE	AVERAGE_SALARY
Accounting Manager	12000
Finance Manager	12000
Purchasing Manager	11000
Sales Manager	12200
Marketing Manager	13000
*/

/*
3. Выполнить запрос, который: 
- получает кол-во сотрудников в каждом подразделении; 
- последней строкой ответа на запрос должно быть общее кол-во сотрудников.
*/
select department_name, count(*) Number_of_employees
from EMPLOYEES, DEPARTMENTS
where EMPLOYEES.DEPARTMENT_ID=DEPARTMENTS.DEPARTMENT_ID
group by rollup(department_name);
/*Результат:
DEPARTMENT_NAME	NUMBER_OF_EMPLOYEES
Accounting	2
Administration	1
Executive	3
Finance	6
Human Resources	1
IT	5
Marketing	2
Public Relations	1
Purchasing	6
Sales	34
Shipping	45
	106
*/