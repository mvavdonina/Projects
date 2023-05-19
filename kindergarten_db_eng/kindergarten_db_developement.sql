/* Development of the database ‘Kindergarten’

Tasks:

- To create a database with all tables by the logical data model designed for a kindergarten. 
Relational model should be in the third normal form (3NF). 
- To fill up the tables with sample data (choosing optimal datatype for each column, using constraints, default values 
and generated columns where appropriate) and create all table relationships with primary and foreign keys.
- To alter all tables and add 'record_ts' field to each table, made it not null and set its default value to a current_date.
- To make the script rerunnable. */ 

-- Creating a new database.
CREATE DATABASE kindergarten;

-- Creating own schema for our database.
CREATE SCHEMA IF NOT EXISTS kgschema;


-- Let's start with 'group_levels' table as basic.
CREATE TABLE IF NOT EXISTS kgschema.group_levels( 
    group_level_id SERIAL PRIMARY KEY,  
	group_level_name varchar (20) NOT NULL UNIQUE,
    kid_age_1 INT NOT NULL CHECK (kid_age_1 >= 0), -- here we need to define age interval for a group_level
    kid_age_2 INT NOT NULL CHECK (kid_age_2 > kid_age_1)
); 
INSERT INTO kgschema.group_levels (group_level_name, kid_age_1, kid_age_2)
VALUES  ('youngest', 3, 4),
		('middle', 4, 5),
		('elder', 5, 6),
		('pre-school', 6, 7)
RETURNING *;


-- Let's create few groups. For beginning there will be one youngest, a couple of middle groups and one elder group with cute names after some flowers.
CREATE TABLE IF NOT EXISTS kgschema.groups (
	group_id SERIAL PRIMARY KEY,  
    group_level_id INT REFERENCES kgschema.group_levels ON DELETE SET NULL,  
	group_name varchar (20) NOT NULL UNIQUE, -- make it unique NOT TO mix up our groups
	room_id INT NOT NULL UNIQUE -- make it unique not TO put few GROUPS IN one room
);
INSERT INTO kgschema.groups (group_level_id, group_name, room_id)
VALUES  (
		(SELECT group_level_id 
		FROM kgschema.group_levels
		WHERE group_level_name = 'youngest'),
		'daisy', 11),
		(
		(SELECT group_level_id 
		FROM kgschema.group_levels
		WHERE group_level_name = 'middle'), 
		'bellflower', 12),
		(
		(SELECT group_level_id 
		FROM kgschema.group_levels
		WHERE group_level_name = 'middle'), 
		'tulip', 14),
		(
		(SELECT group_level_id 
		FROM kgschema.group_levels
		WHERE group_level_name = 'elder'), 
		'sunflower', 21)
RETURNING *;


-- Let's add our first kids.
CREATE TABLE IF NOT EXISTS kgschema.kids (
	kid_id SERIAL PRIMARY KEY,
	kid_name varchar (25) NOT NULL,
	kid_surname varchar (30) NOT NULL,
	kid_gender varchar NOT NULL CHECK (kid_gender IN ('male', 'female')), --to calculate girls and boys
	kid_dob DATE NOT NULL CHECK (kid_dob <= current_date), --may include kids, starting from their birth
	kid_doc varchar (30) NOT NULL UNIQUE, -- use here varchar as there could be litera in doc id
	group_id INT REFERENCES kgschema.groups ON DELETE SET NULL ON UPDATE CASCADE,
    add_info TEXT
);
INSERT INTO kgschema.kids (kid_name, kid_surname, kid_gender, kid_dob, kid_doc, group_id, add_info)
VALUES  ('giorgi', 'sharadze',	'male',	'09.06.2018', '78179138', 3, 'food allergy'),
		('maria', 'avdonyan', 'female',	'13.06.2017', '77999852', 4, 'plays accordion'),
		('anna', 'ivanova',	'female', '17.12.2019',	'77258147',	1, 'brought up by father'),
		('goga', 'manukidze',	'male', '24.01.2022',	'25785989',	null, 'came to apply in advance')
RETURNING *;


-- To move further we need to create addresses - let's start with cities. 
-- Our kindergarten is located in Batumi, Adjara, Georgia, so we will include Batumi and some other cities on the Black sea shore.
CREATE TABLE IF NOT EXISTS kgschema.cities (
	city_id SERIAL PRIMARY KEY,  
	city_name varchar (30) NOT NULL UNIQUE
);
INSERT INTO kgschema.cities (city_name)
VALUES  ('batumi'),
		('makhindjauri'),
		('chakvi'),
		('tsikhisdziri'),
		('kobuleti'),
		('poti'),
		('gonio'),
		('kvariati'),
		('sarpi'),
		('tbilisi')
RETURNING *;


--Insert main streets of Batumi, some of the names could be found in other cities as well.
CREATE TABLE IF NOT EXISTS kgschema.streets (
	street_id SERIAL PRIMARY KEY,  
	street_name varchar (30) NOT NULL UNIQUE 
);
INSERT INTO kgschema.streets (street_name)
VALUES  ('luka asatiani'),
		('asatiani'),
		('demetre tavdadebuli'),
		('bagrationi'),
		('vazha pshavela'),
		('сhavchavadze'),
		('pushkina'),
		('tsarya parnavaza'),
		('rustaveli'),
		('shartava'),
		('sherifa himshiashvili'),
		('davida agmashenebeli'),
		('akaki tsereteli'),
		('12th'),
		('26th may'),
		('19th april'),
		('8th march')	
RETURNING *;

-- To add some addresses.
CREATE TABLE IF NOT EXISTS kgschema.addresses (
	address_id SERIAL NOT NULL UNIQUE,
	city_id INT REFERENCES kgschema.cities ON DELETE SET NULL ON UPDATE CASCADE,
	street_id INT REFERENCES kgschema.streets ON DELETE SET NULL ON UPDATE CASCADE,
	house varchar (20),-- use here varchar because there could be also some litera
	PRIMARY KEY (city_id, street_id, house)
);
INSERT INTO kgschema.addresses (city_id, street_id, house)
VALUES  (1, 1, '127'),
		(2, 12, '15a'),
		(1, 7, '112'),
		(5, 6, '68')
RETURNING *;

-- To fill up info on parents.
CREATE TABLE IF NOT EXISTS kgschema.parents (
	parent_id SERIAL PRIMARY KEY,
	parent_name varchar (30) NOT NULL,
	parent_surname varchar (30) NOT NULL,
	parent_doc varchar (20) NOT NULL UNIQUE, -- use here varchar as there could be some litera in doc id
	parent_mobile varchar (20) NOT NULL, -- use here varchar TO be able TO use prefix and parentheses
	parent_tg varchar (30),
	parent_email varchar (40),
	address_id INT REFERENCES kgschema.addresses (address_id) ON DELETE SET NULL ON UPDATE CASCADE,
	apartment varchar (10),
    add_info TEXT
);
INSERT INTO kgschema.parents (parent_name, parent_surname, parent_doc, parent_mobile, parent_tg, parent_email, address_id, apartment, add_info)
VALUES  ('doman', 'sharadze',	'781791303', '995555111111', 'doma78', 'doma@gmail.net', 2, NULL, 'father, hotel business'),
		('tamta', 'sharadze',	'781791290', '995555111112', NULL, null, 2, NULL, 'mother, housewife'),
		('sabri', 'sharadze',	'781791282', '995555111113', 'sabri00', null, 2, NULL, 'brother, can bring and pick up'),
		('lola', 'avdonyan', '727771919', '995555474630', 'emanuka', 'emanuka@mail.net', 1, 10, 'mother, expat, works remotely'),
		('sergei', 'ramusev', '727839514', '995591301683', 'sramusev', 'sramusev@mail.net', 1, 10, 'mothers spouse,  can bring and pick up'),
		('inna', 'ivanova',	'711234567', '995591050607', 'gingercat', 'gingercat@gmail.net', 3, 5, 'sister, stomatologist, can bring and pick up'),
		('dmitriy', 'ivanov',	'711234569', '995591050608', 'divanovd', 'divanovd@gmail.net', 3, 5, 'father, developer'),
		('leyla', 'manukidze',	'105258649', '995555555566', 'roseup', 'rosesaway@yahoo.net', 4, NULL, 'mother')
RETURNING *;

-- To create connections between parents and kids.
CREATE TABLE IF NOT EXISTS kgschema.kids_parents (
	kid_parent_id SERIAL UNIQUE NOT NULL,
	kid_id INT REFERENCES kgschema.kids (kid_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	parent_id INT REFERENCES kgschema.parents (parent_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY (kid_id, parent_id)
);
INSERT INTO kgschema.kids_parents (kid_id, parent_id)
VALUES  (1, 1),
		(1, 2),
		(1, 3),
		(2, 4),
		(2, 5),
		(3, 6),
		(3, 7),
		(4, 8)
RETURNING *;

-- Let's create some services in our kindergarten.
CREATE TABLE IF NOT EXISTS kgschema.services (
	service_id SERIAL PRIMARY KEY,  
	service_name varchar (20) NOT NULL UNIQUE
);
INSERT INTO kgschema.services (service_name)
VALUES  ('childcare'),
		('education'),
		('medical'),
		('kitchen'),
		('maintenance'),
		('management')
RETURNING *;

-- To create jobs.
CREATE TABLE IF NOT EXISTS kgschema.jobs (
	job_id SERIAL PRIMARY KEY,  
	job_name varchar (40) NOT NULL UNIQUE,
	wage_per_shift NUMERIC,
	service_id INT REFERENCES kgschema.services ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO kgschema.jobs (job_name, wage_per_shift, service_id)
VALUES  ('tutor', 60, 1),
		('nursemaid', 40, 1),
		('music_theatre_teacher', 70, 2),
		('speech_therapist', 50, 2),
		('teacher', 60, 2),
		('librarian', 25, 2),
		('doctor', 70, 3),
		('medical_nurse', 50, 3),
		('cook', 60, 4),
		('dish_washer', 20, 4),
		('technical_specialist', 35, 5),
		('keeper/janitor', 35, 5),
		('cleaning_worker', 20, 5),
		('director', 75, 6),
		('manager', 50, 6),
		('accountant', 60, 6),
		('nursemaid_full_day', 60, 1)
RETURNING *;


-- To define some norms for number of childcare employees per group depending on the group_level.
CREATE TABLE IF NOT EXISTS kgschema.group_levels_jobs (
	group_level_id INT REFERENCES kgschema.group_levels ON DELETE RESTRICT ON UPDATE CASCADE, --as bridge table - row is removed if one of foreign keys is removed
	job_id INT REFERENCES kgschema.jobs ON DELETE RESTRICT ON UPDATE CASCADE,
	employees_number INT,
	PRIMARY KEY (group_level_id, job_id)
);

-- for youngest group_level - two tutors and two nursmaids (work in pair a tutor and a nursemaid by 6 hrs shifts)
INSERT INTO kgschema.group_levels_jobs (group_level_id, job_id, employees_number)
VALUES (
		(SELECT group_level_id 
		FROM kgschema.group_levels
			WHERE group_level_name = 'youngest'), 
		(SELECT job_id
		FROM kgschema.jobs
			WHERE job_name = 'tutor'), 
		2),
		(
		(SELECT group_level_id 
		FROM kgschema.group_levels
			WHERE group_level_name = 'youngest'), 
		(SELECT job_id
		FROM kgschema.jobs
			WHERE job_name = 'nursemaid'), 
		2)
RETURNING *;	

-- for middle group_level - two tutors (change each other by 6 hrs shifts) and one nursmaid (work 8 hrs shift) - as kids are expected to be able 
-- to dress on and off and eat themselves
INSERT INTO kgschema.group_levels_jobs (group_level_id, job_id, employees_number)
VALUES (
		(SELECT group_level_id 
		FROM kgschema.group_levels
			WHERE group_level_name = 'middle'), 
		(SELECT job_id
		FROM kgschema.jobs
			WHERE job_name = 'tutor'), 
		2),
		(
		(SELECT group_level_id 
		FROM kgschema.group_levels
			WHERE group_level_name = 'middle'), 
		(SELECT job_id
		FROM kgschema.jobs
			WHERE job_name = 'nursemaid'), 
		1)
RETURNING *;	

-- the same for elder group_level - 2 tutors and 1 nursemaid
INSERT INTO kgschema.group_levels_jobs (group_level_id, job_id, employees_number)
VALUES (
		(SELECT group_level_id 
		FROM kgschema.group_levels
			WHERE group_level_name = 'elder'), 
		(SELECT job_id
		FROM kgschema.jobs
			WHERE job_name = 'tutor'), 
		2),
		(
		(SELECT group_level_id 
		FROM kgschema.group_levels
			WHERE group_level_name = 'elder'), 
		(SELECT job_id
		FROM kgschema.jobs
			WHERE job_name = 'nursemaid'), 
		1)
RETURNING *;	

-- the same for pre-school group_level - 2 tutors and 1 nursemaid
INSERT INTO kgschema.group_levels_jobs (group_level_id, job_id, employees_number)
VALUES (
		(SELECT group_level_id 
		FROM kgschema.group_levels
			WHERE group_level_name = 'pre-school'), 
		(SELECT job_id
		FROM kgschema.jobs
			WHERE job_name = 'tutor'), 
		2),
		(
		(SELECT group_level_id 
		FROM kgschema.group_levels
			WHERE group_level_name = 'pre-school'), 
		(SELECT job_id
		FROM kgschema.jobs
			WHERE job_name = 'nursemaid'), 
		1)
RETURNING *;


-- To create a table for employees
CREATE TABLE IF NOT EXISTS kgschema.personnel (
	employee_id SERIAL PRIMARY KEY,  
	employee_name varchar (30) NOT NULL,
	employee_surname varchar (30) NOT NULL,
	employee_dob DATE NOT NULL CHECK ((current_date - employee_dob)/365 >= 18), --light check of employee's majority
	employee_doc varchar (20) NOT NULL UNIQUE, -- use here varchart as there could be some litera in doc id
	employee_education TEXT NOT NULL,
	employee_mobile varchar (20) NOT NULL, -- use here varchar TO be able TO use prefix and parentheses
	employee_tg varchar (30),
	employee_email varchar (40) NOT NULL,
	job_id INT REFERENCES kgschema.jobs ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO kgschema.personnel (employee_name, employee_surname, employee_dob, employee_doc, employee_education, employee_mobile, employee_tg, employee_email, job_id)
VALUES ('petr', 'bagrationi', '1970-01-01', '781751303', 'higher pedagogical', '995555158111', 'bagrationi', 'bagrationi@gmail.net', 14),
		('raisa', 'bagrationi', '1975-01-01', '781751309', 'higher economics', '995555158112', 'obagrationi', 'obagrationi@gmail.net', 15),
		('kira', 'bagrationi', '1997-03-08', '781759999', 'bachelor pedagogical', '995555158118', 'kpbagrationi', 'kpbagrationi@gmail.net', 1),		
		('alla', 'ivanova', '1990-02-28', '111111587', 'master pedagogical', '995591158112', 'oia', 'oia@yahoo.net', 1),
		('dasha', 'petrosyan', '1998-08-08', '793514968', 'bachelor pedagogical', '995591444556', 'ddd88', 'ddd88@mail.net', 1),
		('lola', 'kvalishvili', '2003-02-15', '779856324', 'secondary, student', '995555626232', 'lola', 'lola@yahoo.net', 2),
		('manana', 'petrosyan', '1998-08-08', '793514568', 'bachelor pedagogical', '995591444557', 'mmm88', 'mmm88@mail.net', 1),
		('abdumalik', 'ravozi', '1985-02-15', '778856324', 'higher technical', '995555222553', 'stranger', 'stranger@yahoo.net', 1),
		('nunuka', 'volya', '1999-08-08', '793914968', 'bachelor pedagogical', '995591444551', 'nunuka', 'nunuka@mail.net', 2),
		('ramiza', 'dadelyan', '1969-05-15', '857496224', 'higher psychological', '995591222553', 'dadelyan', 'dadelyan@mail.net', 1),
		('alex', 'dadashvili', '1995-02-15', '778856326', 'higher technical', '995555222555', 'dadashvili', 'dadashvili@yahoo.net', 1),
		('larisa', 'kripeli', '1999-05-15', '857494477', 'secindary medical', '995591225453', 'kripeli', 'kripeli@mail.net', 17),
		('frunzik', 'dadelyan', '1968-05-27', '857876224', 'higher technical', '995591222558', 'fdadelyan', 'fdadelyan@mail.net', 11),
		('eteri', 'rabli', '1982-05-13', '857216224', 'higher medical', '995591258553', 'rabli', 'rabli@mail.net', 7),
		('marika', 'rabli', '1983-06-08', '857216220', 'secondary', '995591258550', 'mrabli', 'mrabli@mail.net', 9)
RETURNING *;


-- Creating additional table (absent in the model) with holidays not-working days in Georgia according to https://publicholidays.me/georgia/2023-dates/
CREATE TABLE IF NOT EXISTS kgschema.pub_hldays (
	hlday_date varchar (10),
	hlday_name varchar (50),
	PRIMARY KEY (hlday_date, hlday_name)
);
INSERT INTO kgschema.pub_hldays (hlday_date, hlday_name)
VALUES  ('01-01', 'new year day'),
		('01-02', 'new year holiday'),
		('01-07', 'orthodox christmas'),
		('01-19', 'orthodox epiphany'),
		('03-03', 'mother day'),
		('03-08', 'international women day'),
		('04-09', 'independence restoration day'),
		('05-09', 'victory day'),
		('05-12', 'saint andrew the first called day'),
		('05-26', 'independence day'),
		('08-28', 'saint maria day'),
		('10-14', 'svetitskhovloba'),
		('11-23', 'saint georgiy day')
RETURNING *;


-- To create a table with shifts - here we include 6 hrs shifts and 8(+1) hrs shift
CREATE TABLE IF NOT EXISTS kgschema.shifts (
	shift_id SERIAL UNIQUE NOT NULL,
	start_time timestamp,
	end_time timestamp GENERATED ALWAYS AS 
		(CASE WHEN extract (HOUR FROM start_time)=9 THEN start_time + '9 hour' 
		ELSE start_time + '6 hour' END) STORED, -- define different shift length for two-shifts-jobs (6 hrs) and one-shift-jobs (8+1 hrs from 9 am till 6 pm)
	PRIMARY KEY (start_time, end_time)
);
INSERT INTO kgschema.shifts (start_time)
SELECT *
FROM (
select generate_series (timestamp '2023-01-01 08:00:00', timestamp '2023-12-31 20:00:00', interval '6 hour') AS ts -- generating 6 hrs shifts start_time
UNION
select generate_series (timestamp '2023-01-01 09:00:00', timestamp '2023-12-31 18:00:00', interval '1 day') AS ts -- generating 8 hrs shifts start_time
ORDER BY ts
) AS subq -- here we make a trick generating series of shift-starts for 6 hrs shift and 8 hrs (once a day) shift within 2023 YEAR AND uniting them
	WHERE EXTRACT (isodow FROM ts) IN (1, 2, 3, 4, 5) -- sorting out only working days
	AND	  EXTRACT (HOUR FROM ts) >= 08 -- only daytime
	AND	  EXTRACT (HOUR FROM ts) < 20 -- only daytime
	AND	  to_char (ts, 'mm-dd') NOT IN (SELECT hlday_date FROM kgschema.pub_hldays) -- not on holidays
;
SELECT * FROM kgschema.shifts LIMIT 10;

-- To distribute the childcare employees by our groups.
CREATE TABLE IF NOT EXISTS kgschema.groups_employees (
	group_id INT REFERENCES kgschema.GROUPS (group_id) ON DELETE RESTRICT ON UPDATE CASCADE, --as bridge table - row is removed if one of foreign keys is removed
	employee_id INT REFERENCES kgschema.personnel (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY (group_id, employee_id)
);
INSERT INTO kgschema.groups_employees (group_id, employee_id)
VALUES  (1, 3),
		(1, 5),
		(1, 6),
		(1, 9),
		(2, 4),
		(2, 7),
		(2, 12),
		(3, 8),
		(3, 10),
		(4, 11)		
RETURNING *;
-- here we may understand that we have not enough tutors and nursemaids yet


CREATE TABLE IF NOT EXISTS kgschema.shifts_personnel (
	shift_id INT REFERENCES kgschema.shifts (shift_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	employee_id INT REFERENCES kgschema.personnel (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	working_shift bool NOT NULL,
	PRIMARY KEY (shift_id, employee_id)
);
-- here we put childcare employees by shifts manually as we don't have yet a rule who can work on which shifts
INSERT INTO kgschema.shifts_personnel (shift_id, employee_id, working_shift)
VALUES  (55, 3, true),
		(60, 3, true),
		(61, 3, true),
		(66, 3, true),
		(67, 3, true),
		(55, 6, true),
		(60, 6, true),
		(61, 6, true),
		(66, 6, true),
		(67, 6, true),
		(57, 5, true),
		(58, 5, true),
		(63, 5, true),
		(64, 5, true),
		(69, 5, true),
		(57, 9, true),
		(58, 9, true),
		(63, 9, true),
		(64, 9, true),
		(69, 9, true),
		(55, 4, true),
		(60, 4, true),
		(61, 4, true),
		(66, 4, true),
		(67, 4, true),
		(55, 7, true),
		(60, 7, true),
		(61, 7, true),
		(66, 7, true),
		(67, 7, true),
		(56, 12, true),
		(59, 12, true),
		(62, 12, true),
		(65, 12, true),
		(68, 12, true) -- fulfilling for a one wk for only the childcare service for a while
RETURNING *;


/*Alter all tables and add 'record_ts' field to each table. Make it not null and set its default value to current_date. Check that the value
has been set for existing rows.*/
		
ALTER TABLE IF EXISTS kgschema.group_levels ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.group_levels;

ALTER TABLE IF EXISTS kgschema.groups ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.groups;

ALTER TABLE IF EXISTS kgschema.kids ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.kids;

ALTER TABLE IF EXISTS kgschema.cities ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.cities;

ALTER TABLE IF EXISTS kgschema.streets ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.streets;

ALTER TABLE IF EXISTS kgschema.addresses ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.addresses;

ALTER TABLE IF EXISTS kgschema.parents ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.parents;

ALTER TABLE IF EXISTS kgschema.kids_parents ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.kids_parents;

ALTER TABLE IF EXISTS kgschema.services ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.services;

ALTER TABLE IF EXISTS kgschema.jobs ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.jobs;

ALTER TABLE IF EXISTS kgschema.group_levels_jobs ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.group_levels_jobs;

ALTER TABLE IF EXISTS kgschema.personnel ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.personnel;

ALTER TABLE IF EXISTS kgschema.shifts ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.shifts LIMIT 50;

ALTER TABLE IF EXISTS kgschema.groups_employees ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.groups_employees;

ALTER TABLE IF EXISTS kgschema.shifts_personnel ADD COLUMN record_ts timestamp NOT NULL DEFAULT current_date;
SELECT * FROM kgschema.shifts_personnel LIMIT 50;


-- To add 'DROP TABLE' to make scripts rerunnable:

DROP TABLE IF EXISTS kgschema.group_levels CASCADE;

DROP TABLE IF EXISTS kgschema.GROUPS CASCADE;

DROP TABLE IF EXISTS kgschema.kids CASCADE;

DROP TABLE IF EXISTS kgschema.cities CASCADE;

DROP TABLE IF EXISTS kgschema.streets CASCADE;

DROP TABLE IF EXISTS kgschema.addresses CASCADE;

DROP TABLE IF EXISTS kgschema.parents CASCADE;

DROP TABLE IF EXISTS kgschema.kids_parents;

DROP TABLE IF EXISTS kgschema.services CASCADE;

DROP TABLE IF EXISTS kgschema.jobs CASCADE;

DROP TABLE IF EXISTS kgschema.group_levels_jobs;

DROP TABLE IF EXISTS kgschema.personnel CASCADE;

DROP TABLE IF EXISTS kgschema.shifts CASCADE;

DROP TABLE IF EXISTS kgschema.groups_employees;

DROP TABLE IF EXISTS kgschema.shifts_personnel;

DROP TABLE IF EXISTS kgschema.pub_hldays;

-- End of the script.