--Этап 1 Выполнение сложных SELECT-запросов. 

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
/*			
President
Administration Vice President
Programmer
Finance Manager
Accountant
Purchasing Manager
Purchasing Clerk
Stock Manager
Stock Clerk
Sales Manager
*/

/*
2. Выполнить запрос, который: 
- получает фамилию сотрудников и их зарплату; 
-  размер  зарплаты  сотрудников  должен  быть  больше  средней  зарплаты  сотрудников, 
работающих в Европе. 
*/
select last_name, salary
from employees e
where salary >    (select avg(salary) 
                  from employees e, departments d, locations l, countries c, regions r
                  where e.department_id = d.department_id
                  and   d.location_id= l.location_id
                  and   l.country_id = c.country_id
                  and   c.region_id = r.region_id
                  and   r.region_name = 'Europe');
                  
/*
King	24000
Kochhar	17000
De Haan	17000
Hunold	9000
Greenberg	12000
Faviet	9000
Raphaely	11000
Russell	14000
Partners	13500
Errazuriz	12000
Cambrault	11000
Zlotkey	10500
*/

/*
3. Выполнить запрос, который: 
- получает название подразделений; 
- в указанных подразделениях средняя зарплата сотрудников должна быть больше средней 
зарплаты сотрудников по всем подразделениям. 
*/

SELECT d.DEPARTMENT_NAME, AVG(e.SALARY) as Average_Salary
FROM DEPARTMENTS d JOIN employees e USING (department_id)
GROUP BY d.DEPARTMENT_NAME
HAVING AVG(e.salary) = (SELECT MAX(AVG(e.SALARY)) FROM employees GROUP BY d.DEPARTMENT_NAME);

/*
Accounting	10150
Odessa Office	110
Executive	          13150
IT	          5760
Purchasing	4150
Shipping	          3475.555555555555555555555555555555555556
Finance	          8600
Sales	          8955.882352941176470588235294117647058824
Marketing	          9500
*/

/*
4. Выполнить запрос, который получает название страны с минимальным количеством 
сотрудников по сравнению с другими странами. 
*/

SELECT c.COUNTRY_NAME, count(*) as "Number of Employees"
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
/*
Ukraine	1          
*/

/*
5. Выполнить запрос, который получает фамилию сотрудника с самым большим доходом 
за все время работы в организации. 
*/

SELECT E.LAST_NAME, round(MONTHS_BETWEEN (SYSDATE, E.HIRE_DATE)*E.SALARY,0) as TOTAL_MONEY
FROM EMPLOYEES E
where round(MONTHS_BETWEEN (SYSDATE, E.HIRE_DATE)*E.SALARY,0) = 
    (SELECT MAX(round(MONTHS_BETWEEN (SYSDATE, E.HIRE_DATE)*E.SALARY,0))
     FROM EMPLOYEES E);
     
/*
King	8297608
*/

/*
6.  Выполнить  запрос,  который  получает  список  стран  и  подразделений,  в  которых  не 
работают сотрудники. 
*/

--Без вложенного запроса как-то так

SELECT c.country_name
FROM COUNTRIES c 
LEFT JOIN LOCATIONS l USING (country_id)
LEFT JOIN DEPARTMENTS d USING (location_id)
LEFT JOIN EMPLOYEES e USING (department_id)
GROUP BY c.COUNTRY_NAME
HAVING count(e.EMPLOYEE_ID) = 0
Union all
SELECT d.DEPARTMENT_NAME
FROM DEPARTMENTS d
LEFT JOIN EMPLOYEES e USING (department_id)
GROUP BY d.DEPARTMENT_NAME
HAVING count(e.EMPLOYEE_ID) = 0;

/*        
Brazil
Zimbabwe
Denmark
Zambia
China
India
Nigeria
...
Netherlands
Mexico

Administration
Treasury
...
Control And Credit
IT Helpdesk
*/

/*
7. Выполнить запрос, который получает: 
- название подразделения 
- сумму окладов сотрудников подразделения; 
-  процент,  который  сумма  окладов  сотрудников  подразделения  составляет  от  суммы 
окладов всех сотрудников компании; 
- если в подразделении нет сотрудников, то считать, что сумма их окладов равна нулю.
*/

SELECT D.DEPARTMENT_NAME, sum(nvl(salary,0)) as "Total_Dep_Money", 
       round(sum(nvl(salary,0))/(select sum(salary) from EMPLOYEES)*100,2) as "% from total money"
FROM DEPARTMENTS D LEFT JOIN EMPLOYEES E USING (department_id)
GROUP BY D.DEPARTMENT_NAME
order by 2 DESC;

/*
Sales	                    304500	44.03
Shipping	                    156400	22.62
Executive	                    78900	11.41
Finance	                    51600	7.46
IT	                    28800	4.16
Purchasing          	24900	3.6
Accounting          	20300	2.94
Marketing	                    19000	2.75
Odessa Office                 110	0.02
Retail Sales        	0	0
Recruiting	          0	0
*/

--Этап 2 Выполнение запросов со сложной модификацией данных. 

/*
1.  Используя  одну  INSERT-команду,  зарегистрировать  нового  сотрудника  с  Вашей 
фамилией и предпочитаемой Вами зарплатой, который будет работать: 
- на должности Software Developer; 
- в стране Ukraine; 
- в городе Odessa; 
- в подразделении NC Office. 
Остальные необходимые для внесения данные выбрать самостоятельно. 
*/
DROP SEQUENCE deptno;
DROP SEQUENCE empno ;
DROP SEQUENCE locat ;
CREATE SEQUENCE deptno start with 500 increment by 10;
CREATE SEQUENCE empno start with 8000;
CREATE SEQUENCE locat start with 3300 increment by 100;
INSERT ALL
  INTO countries values ('UA', 'Ukraine', 1)
  into locations values (locat.nextval, 'Schevchenko', 65022, 'Odessa', 'South', 'UA')
  INTO departments (department_id, department_name, location_id)
    VALUES (deptno.nextval, 'Odessa Office', locat.currval) 
  into jobs values ('SW_DEV', 'Software developer', 1000, 900)
  INTO employees VALUES (empno.nextval, null, 'RUDENKO', '@gmail.com',  null, sysdate, 'SW_DEV', 100, null, 100, deptno.currval)
SELECT *
		FROM dual;

/*
2. Ликвидировать страны, в которых не работают сотрудники. 
*/
DELETE 
FROM COUNTRIES c
WHERE c.COUNTRY_NAME IN
                      (
                      SELECT c.COUNTRY_NAME
                      FROM COUNTRIES c 
                      LEFT JOIN LOCATIONS l USING (country_id)
                      LEFT JOIN DEPARTMENTS d USING (location_id)
                      LEFT JOIN EMPLOYEES e USING (department_id)
                      GROUP BY c.COUNTRY_NAME
                      HAVING count(e.EMPLOYEE_ID) = 0
                      )
;
/*
3.  Сотруднику,  который  дольше  всех  работает  в  подразделении  с  самой  низкой  средней 
зарплатой, увеличить комиссионные на 10% 
*/
UPDATE EMPLOYEES
SET SALARY=1.1*SALARY
WHERE EMPLOYEE_ID = 
                    (
                    SELECT E.employee_id
                    FROM EMPLOYEES E
                    WHERE E.DEPARTMENT_ID = (select department_id
                                            from EMPLOYEES
                                            group by DEPARTMENT_ID
                                            having avg(salary) = (select min(avg(salary))
                                                                 from EMPLOYEES
                                                                 group by DEPARTMENT_ID))
                    AND (SYSDATE - E.HIRE_DATE) = (SELECT  MAX(SYSDATE - EE.HIRE_DATE) 
                                                   FROM EMPLOYEES EE
                                                   WHERE EE.DEPARTMENT_ID=E.DEPARTMENT_ID
                                                   )
                    );
/*
4.  Перевести  всех  сотрудников  из  подразделения  с  самым  низким  количеством 
сотрудников в подразделение с самой высокой средней зарплатой. 
*/
UPDATE EMPLOYEES
SET DEPARTMENT_ID = (SELECT department_id from departments where 
                        department_name =(SELECT D.DEPARTMENT_NAME
                                          FROM EMPLOYEES E JOIN DEPARTMENTS D USING (department_id)
                                          GROUP BY D.DEPARTMENT_NAME
                                          HAVING avg(salary) = (SELECT max(avg(salary))
                                                                FROM EMPLOYEES E JOIN DEPARTMENTS D USING (department_id)
                                                                GROUP BY D.DEPARTMENT_NAME)))
WHERE DEPARTMENT_ID IN (SELECT department_id from departments where 
                        department_name IN (SELECT D.DEPARTMENT_NAME
                                           FROM EMPLOYEES E JOIN DEPARTMENTS D USING (department_id)
                                           GROUP BY D.DEPARTMENT_NAME
                                           HAVING count(*) = (SELECT min(count(*))
                                                              FROM EMPLOYEES E JOIN DEPARTMENTS D USING (department_id)
                                                              GROUP BY D.DEPARTMENT_NAME)));

--Этап 3 Выполнение иерархических запросов 

/* 
1. Выполнить запрос на получение названий подразделений, фамилий с учетом иерархии 
подчинения, начиная с руководителей.
*/

SELECT d.department_name, e.last_name 
FROM employees e left join departments d on (e.department_id = d.department_id)
START WITH e.manager_id is null
CONNECT BY prior e.employee_id = e.manager_id 
ORDER SIBLINGS BY e.last_name;

/*
Executive	King
Sales	Cambrault
Sales	Bates
Sales	Bloom
Sales	Fox
Sales	Kumar
Sales	Ozer
Sales	Smith
Executive	De Haan
IT	Hunold
*/

/*
2. Выполнить запрос на получение названий подразделений, фамилий с учетом иерархии 
подчинения, начиная с подчиненных. 
*/

SELECT d.department_name, e.last_name 
FROM employees e left join departments d on (e.department_id = d.department_id)
START WITH e.EMPLOYEE_ID not in (select ee.manager_id from employees ee where ee.MANAGER_ID is not null)
CONNECT BY prior e.manager_id = e.EMPLOYEE_ID;

/*
IT	Ernst
IT	Hunold
Executive	De Haan
Executive	King
IT	Austin
IT	Hunold
Executive	De Haan
Executive	King
IT	Pataballa
IT	Hunold
*/

--Или так графически

SELECT lpad('.', 8*(level-1), '.') || e.LAST_NAME AS "Hierarchy", d.DEPARTMENT_NAME
FROM employees e left join departments d on (e.department_id = d.department_id)
START WITH e.EMPLOYEE_ID not in (select ee.manager_id from employees ee where ee.MANAGER_ID is not null)
CONNECT BY prior e.manager_id = e.EMPLOYEE_ID;

/*
Ernst	                    IT
........Hunold	          IT
................De Haan	Executive
........................King	Executive
Austin	                    IT
........Hunold	          IT
................De Haan	Executive
........................King	Executive
Pataballa	                    IT
........Hunold	          IT
................De Haan	Executive
........................King	Executive
*/

/*
3.  Выполнить  запрос  на  получение  фамилии  сотрудника,  номера  и  названия 
подразделения,  где  он  работает,  номер  узла  иерархии  и  имен  всех  его  менеджеров  через  /. 
Внутри  одного  уровня  иерархии  сотрудники  должны  быть  отсортированы  по  названиям 
подразделения. 
*/

SELECT  e.last_name, d.DEPARTMENT_ID, d.department_name, LEVEL, SYS_CONNECT_BY_PATH(
              (select ee.last_name from employees ee where ee.employee_id = e.manager_id), '/') as Managers
FROM employees e left join departments d on (e.department_id = d.department_id)
START WITH e.EMPLOYEE_ID not in (select ee.manager_id from employees ee where ee.MANAGER_ID is not null)
CONNECT BY prior e.manager_id = e.EMPLOYEE_ID;

/*
Ernst	60	IT	1	/Hunold
Hunold	60	IT	2	/Hunold/De Haan
De Haan	90	Executive	3	/Hunold/De Haan/King
King	90	Executive	4	/Hunold/De Haan/King/
Austin	60	IT	1	/Hunold
Hunold	60	IT	2	/Hunold/De Haan
De Haan	90	Executive	3	/Hunold/De Haan/King
King	90	Executive	4	/Hunold/De Haan/King/
Pataballa	60	IT	1	/Hunold
Hunold	60	IT	2	/Hunold/De Haan
*/
/*
4. Выполнить запрос на получение: 
- календаря на предыдущий, текущий и следующий месяц текущего года 
- формат вывода: номер дня в месяце (две цифры), полное название месяца, 
-  по  каждому  месяцу  количество  возвращаемых  строк  должно  точно  соответствовать 
количеству дней в месяце.
*/
SELECT TO_CHAR(add_months(TRUNC(SYSDATE,'MM'),-1)+rownum-1
             , 'DD fmMONTH'
             , 'NLS_DATE_LANGUAGE=AMERICAN') AS d
FROM dual
CONNECT BY ROWNUM <= TO_CHAR(LAST_DAY(SYSDATE), 'DD')
                      + TO_CHAR(LAST_DAY(LAST_DAY(SYSDATE)+1), 'DD')
                      + TO_CHAR(LAST_DAY(TRUNC(SYSDATE,'mm')-1), 'DD');
                      
/*
01 OCTOBER
02 OCTOBER
03 OCTOBER
04 OCTOBER
05 OCTOBER
06 OCTOBER
07 OCTOBER
08 OCTOBER
09 OCTOBER
10 OCTOBER
11 OCTOBER
12 OCTOBER
13 OCTOBER
14 OCTOBER
15 OCTOBER
16 OCTOBER
17 OCTOBER
18 OCTOBER
19 OCTOBER
20 OCTOBER
21 OCTOBER
22 OCTOBER
23 OCTOBER
24 OCTOBER
25 OCTOBER
26 OCTOBER
27 OCTOBER
28 OCTOBER
29 OCTOBER
30 OCTOBER
31 OCTOBER
01 NOVEMBER
02 NOVEMBER
03 NOVEMBER
04 NOVEMBER
05 NOVEMBER
06 NOVEMBER
07 NOVEMBER
08 NOVEMBER
09 NOVEMBER
10 NOVEMBER
11 NOVEMBER
12 NOVEMBER
13 NOVEMBER
14 NOVEMBER
15 NOVEMBER
16 NOVEMBER
17 NOVEMBER
18 NOVEMBER
19 NOVEMBER
20 NOVEMBER
21 NOVEMBER
22 NOVEMBER
23 NOVEMBER
24 NOVEMBER
25 NOVEMBER
26 NOVEMBER
27 NOVEMBER
28 NOVEMBER
29 NOVEMBER
30 NOVEMBER
01 DECEMBER
02 DECEMBER
03 DECEMBER
04 DECEMBER
05 DECEMBER
06 DECEMBER
07 DECEMBER
08 DECEMBER
09 DECEMBER
10 DECEMBER
11 DECEMBER
12 DECEMBER
13 DECEMBER
14 DECEMBER
15 DECEMBER
16 DECEMBER
17 DECEMBER
18 DECEMBER
19 DECEMBER
20 DECEMBER
21 DECEMBER
22 DECEMBER
23 DECEMBER
24 DECEMBER
25 DECEMBER
26 DECEMBER
27 DECEMBER
28 DECEMBER
29 DECEMBER
30 DECEMBER
31 DECEMBER
*/