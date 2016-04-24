/*
Задание 1 Автоматическая инициализация генераторов уникальных значений 
В  предыдущих  лабораторных  работах  необходимо  было  создавать  генераторы 
последовательностей для PK-атрибутов таблиц с уже заполненными данными. В Oracle 11XE
отсутствует  возможность  создавать  генераторы  (sequence),  автоматически  проставляя 
начальные  значения  с  учетом  содержимого  таблиц  БД,  что  требует  от  администратора 
вручную выполнять запросы на получение максимальных значений PK-атрибутов. 
Создать анонимный PL/SQL-блок, автоматизирующий этот процесс на основе шагов: 
- проверка наличия генератора в БД с учетом заранее известных названий для таблиц 
Departments,  Employees,  используя  запрос  по  шаблону  select  sequence_name  from 
user_sequences where sequence_name = 'название_в_верхнем_регистре';
- если генераторы уже существуют, выполнение команды удаления генераторов; 
- определение  максимального  значения  идентификатора  подразделения  в  таблице 
Departments  и идентификатора  сотрудника в таблице Employees; 
- создание генераторов с учетом смещений начального значения, превышающего на 1 
полученные максимальные значения. 
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
Задание 2 Массовое внесение изменений в БД  
Часто  для  проведения  тестирования  производительности,  иногда,  функционального 
тестирования,  необходимо  использовать  таблицы  с  количеством  строк,  соизмеримым  с 
реальным состоянием на производстве (сотни, тысячи, миллионы ). Для этого используются 
генераторы искусственных (суррогатных) строк. 
2.1 При рассмотрении иерархических запросов был указан способ их использования 
для массовой (пакетной) генерации значений атрибутов таблиц. 
 Создать  запрос  типа  INSERT  ALL  по  автоматической  регистрации  в  БД  10000 
сотрудников, учитывая следующее: 
- для идентификаторов сотрудника использовать генератор; 
- имя,  фамилия  сотрудника  определяется  как  Ваше  имя,  фамилия  +  значение 
генератора; 
- логин сотрудника определяется как Ваше имя + значение генератора; 
- дата зачисления определяется как ‘01.01.2000’ + значение генератора; 
- остальные значения колонок - произвольные, но не противоречащие ограничениям 
целостности. 
*/

INSERT ALL
INTO employees VALUES 
     (employee_id.nextval, null, 'RUDENKO' || rn, '@gmail.com' || rn,  
     null, to_date('01.01.2000','DD.MM.YYYY') + rn, 'ST_MAN', 100, null, 100,90)  
SELECT rownum as rn FROM dual
CONNECT BY level <= 10000;
/

/*
2.2 Предыдущее решение позволяет создавать простые генераторы. 
Создать    анонимный  PL/SQL-блок,  автоматически  регистрирующий  в  БД  10000 
сотрудников, учитывая условия из задания 2.1
*/

--тут выполнили скрипт по обновлению sequence employee_id из пункта 1.1

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
Задание 3 Обработка исключений 
3.1 В решение 1-го задания изменить PL/SQL-код так, чтобы не было необходимости 
проверять наличие генераторов в БД. 
*/

-- решение: просто меняем условие в блоке EXCEPTION

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
3.2 В решение задания 2.2 добавить контроль ограничений целостности: 
-  внесения  дубликатов  по  логинам  сотрудников,  нарушающих  ограничение 
целостности UNIQUE, с выводом ошибки типа “ Login Ivanov already exists”; 
- внесения отрицательной зарплаты с выводом ошибки типа “Salary = -10. But salary 
must be >= 0” 
Внести  изменения  в  PL/SQL-код,  приходящий  к  срабатыванию  указанных 
исключений. 
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
Задание 4 Работа с курсорами 
Описать операции транзакции в виде PL/SQL-кода: 
1) получить список идентификаторов подразделений, в которых есть сотрудники; 
2) получить список сотрудников 2-го по списку подразделения; 
3) перевести сотрудников в 3-е по списку подразделение
4) сохранить данные о сотрудниках в таблице job_history 
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
Задание 5 Динамические запросы 
Создать  анонимный  PL/SQL-блок,  который  автоматически  зарегистрирует 
пользователей Oracle с учетом условий: 
- имена пользователей совпадают с логинам сотрудников из таблицы employees; 
- пароль генерируется как любая константа; 
- пользователю  после  регистрации  предоставляется  право  входа  в  систему,  т.е. 
автоматически выполняется команда GRANT CONNECT TO пользователь; 
- пользователю-сотруднику, работающему на должности, связанной с управлением ( в 
названии  должности  есть  слово  manager  ),  предоставить  право  управлять  ресурсами,  т.е. 
автоматически выполняется команда GRANT RESOURCE TO пользователь; 
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


-- так можно их всех красиво удалить

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