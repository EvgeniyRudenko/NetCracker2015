/* 
Создание таблиц
*/

CREATE TABLE employees   (
	employee_id     NUMBER    (4) ,
	firstName       NVARCHAR2 (30),
	lastName        NVARCHAR2 (30),
	hire_date       DATE          ,
	job_id          NVARCHAR2 (10) ,
	salary          NUMBER    (5) ,
	comission       NUMBER    (2) ,
	manager_id      NUMBER    (4) ,
	department_id   NUMBER    (4)  
);

CREATE TABLE departments (
	department_id   NUMBER    (4) ,  
	name            NVARCHAR2 (30),
	manager_id      NUMBER    (4) ,
	location_id     NUMBER    (4) 
);

CREATE TABLE locations    (
	location_id     NUMBER    (4) ,  
	country_id      NUMBER    (4) , 
	city            NVARCHAR2 (30),
	street          NVARCHAR2 (30)
);

CREATE TABLE countries   (
	country_id      NUMBER    (4) ,  
	name            NVARCHAR2 (30),
	region_id       NUMBER    (4) 
);

CREATE TABLE regions     (  
	region_id       NUMBER    (4) ,  
	name            NVARCHAR2 (30)
);

CREATE TABLE jobs        (  
	job_id          NVARCHAR2 (10),  
	title           NVARCHAR2 (30)
);

/* 
создание ограничений целостности типа "Первичный ключ"
*/

ALTER TABLE employees     ADD CONSTRAINT employees_pk   PRIMARY KEY (employee_id);

ALTER TABLE departments   ADD CONSTRAINT departments_pk PRIMARY KEY (department_id);

ALTER TABLE locations     ADD CONSTRAINT locations_pk   PRIMARY KEY (location_id);

ALTER TABLE countries     ADD CONSTRAINT countries_pk   PRIMARY KEY (country_id);

ALTER TABLE regions       ADD CONSTRAINT regions_pk     PRIMARY KEY (region_id);

ALTER TABLE jobs          ADD CONSTRAINT jobs_pk        PRIMARY KEY (job_id);

/* 
создание ограничений целостности типа "Внешний ключ"
*/

ALTER TABLE employees ADD CONSTRAINT employees_fk1
	FOREIGN KEY (job_id) REFERENCES jobs(job_id);
	
ALTER TABLE employees ADD CONSTRAINT employees_fk2
	FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE employees ADD CONSTRAINT employees_fk3
	FOREIGN KEY (department_id) REFERENCES departments(department_id);
	
	
ALTER TABLE departments ADD CONSTRAINT departments_fk1
	FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
	
ALTER TABLE departments ADD CONSTRAINT departments_fk2
	FOREIGN KEY (location_id) REFERENCES locations(location_id);
	
	
ALTER TABLE locations ADD CONSTRAINT locations_fk
	FOREIGN KEY (country_id) REFERENCES countries(country_id);
	
	
ALTER TABLE countries ADD CONSTRAINT countries_fk
	FOREIGN KEY (region_id) REFERENCES regions(region_id);
	
/*
Пример создания ограничения целостности типа "Потенциальный ключ"
Будем считать, что по нашей бизнес логике расположение представительств компании в ондом городе и на одной улице неуместно
*/

ALTER TABLE locations MODIFY (city NOT NULL);
ALTER TABLE locations MODIFY (street NOT NULL);
ALTER TABLE locations ADD CONSTRAINT locations_addkey UNIQUE (city,street);

/*
Пример создания ограничение целостности типа Check
*/

ALTER TABLE employees ADD CONSTRAINT firstName_not_empty
	CHECK ( TRIM(firstName) IS NOT NULL );
	
ALTER TABLE employees ADD CONSTRAINT lastName_not_empty
	CHECK ( TRIM(lastName) IS NOT NULL );