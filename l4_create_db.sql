USE jmcclellanDB;

DROP TABLE IF EXISTS Runner;
CREATE TABLE Runner(
runnerName varchar(50) PRIMARY KEY,
age int,
yearsRunning int,
favRace varchar(50));

DROP TABLE IF EXISTS Race;
CREATE TABLE Race(
raceName varchar(50) PRIMARY KEY,
distance decimal(5,1),
raceCountry char(3),
registrationCap int);

DROP TABLE IF EXISTS AgeGroup;
CREATE TABLE AgeGroup(
ageGroupCode char(4) UNIQUE,
ageGroupDesc varchar(15),
ageGroupMin int,
ageGroupMax int,
PRIMARY KEY(ageGroupCode));

DROP TABLE IF EXISTS Results;
CREATE TABLE Results(
raceName varchar(50),
runnerName varchar(50),
place int,
ageGroup char(4),
PRIMARY KEY(raceName, runnerName));

DROP TABLE IF EXISTS Likes;
CREATE TABLE Likes(
	raceName varchar(50),
	runnerName varchar(50),
	PRIMARY KEY(raceName, runnerName));

DROP TABLE IF EXISTS Registrations;
CREATE TABLE Registrations(
raceName varchar(50),
runnerName varchar(50),
PRIMARY KEY(raceName, runnerName));

INSERT INTO Runner
VALUES
('Dean Karnazes',	53,	25,	'Badwater Ultramarathon'),
('Tera Moody',		34,	16,	'Shamrock Shuffle'),
('Kara Goucher',	36,	20,	'London Marathon'),
('Meb Keflezighi',	39,	25,	'NYC Marathon'),
('Ryan Hall',		32,	16,	'Shamrock Shuffle'),
('Zach Freeman',	32,	16,	'Chicago Marathon'),
('Rita Jeptoo',		34, 24, 'Chicago Marathon'),
('Deena Kastor',	42, 22, 'Chicago Marathon'),
('Jay Freeman',		68, 18, 'Big Sur International Marathon'),
('Galen Rupp',		31, 15, 'Chicago Marathon'),
('Jordan Hasay',	26, 13, 'Chicago Marathon'); 

INSERT INTO Race
VALUES
('Athens Marathon',			26.2, 	'GRE',	30000),
('Badwater Ultramarathon',	135,	'USA', 	1500),
('Big Sur International Marathon',	26.2, 'USA',	25000),
('Boston Marathon',			26.2,	'USA',	35000),
('Chicago Marathon',		26.2,	'USA',	45000),
('Frozen Gnome',			6.2,	'USA',	250),
('London Marathon',			26.2,	'GBR',	35000),
('NYC Marathon',			26.2,	'USA',	50000),
('Shamrock Shuffle',		4.9,	'USA',	45000),
('Climb Hot Springs',		7,		'USA',	100);

INSERT INTO AgeGroup
VALUES
('0019','19 and under',	0,19),
('2029','20-29',		20,29),
('3039','30-39',		30,39),
('4049','40-49',		40,49),
('5059','50-59',		50,59),
('6069','60-69',		60,69),
('7079','70-79',		70,79),
('8099','80 and up',	80,99);


INSERT INTO Results
VALUES
('Athens Marathon',		'Ryan Hall',		3, '3039'),
('London Marathon',		'Ryan Hall',		3, '3039'),
('Shamrock Shuffle',	'Tera Moody',		1, '3039'),
('NYC Marathon',		'Meb Keflezighi',	1, '3039'),
('Chicago Marathon',	'Kara Goucher',		6, '3039'),
('Chicago Marathon', 	'Meb Keflezighi',	2, '3039'),
('NYC Marathon',		'Kara Goucher',		3, '3039'),
('Boston Marathon',		'Rita Jeptoo',		1, '3039'),
('Chicago Marathon',	'Rita Jeptoo',		1, '3039'),
('Athens Marathon',		'Dean Karnazes',	350, '5059'),
('Big Sur International Marathon',		'Dean Karnazes',	350, '5059'),
('Big Sur International Marathon',		'Jay Freeman',	98, '6069'),
('Frozen Gnome',		'Dean Karnazes',	350, '5059'),
('Badwater Ultramarathon',		'Dean Karnazes',	200, '5059'),
('Frozen Gnome',		'Tera Moody',		28, '3039'),
('London Marathon',		'Tera Moody',		31, '3039'),
('NYC Marathon',		'Rita Jeptoo',		5,  '3039'),
('NYC Marathon',		'Ryan Hall',		15, '3039'),
('Chicago Marathon',	'Jordan Hasay',		3,	'2029');

INSERT INTO Likes
VALUES
('Athens Marathon',		'Zach Freeman'),
('Boston Marathon',		'Meb Keflezighi'),
('Chicago Marathon',	'Meb Keflezighi'),
('NYC Marathon',		'Meb Keflezighi'),
('Big Sur International Marathon',	'Zach Freeman'),
('Frozen Gnome',		'Zach Freeman'),
('Frozen Gnome',		'Dean Karnazes'),
('Shamrock Shuffle',	'Tera Moody'),
('Shamrock Shuffle',	'Kara Goucher'),
('Shamrock Shuffle',	'Zach Freeman'),
('Chicago Marathon',	'Rita Jeptoo');

INSERT INTO Registrations
VALUES
('Athens Marathon',		'Zach Freeman'),
('Athens Marathon',		'Tera Moody'),
('Boston Marathon',		'Rita Jeptoo'),
('Chicago Marathon',	'Meb Keflezighi'),
('NYC Marathon',		'Meb Keflezighi'),
('Big Sur International Marathon',	'Zach Freeman'),
('Big Sur International Marathon',	'Jay Freeman'),
('Frozen Gnome',		'Zach Freeman'),
('Shamrock Shuffle',	'Tera Moody'),
('Boston Marathon',		'Meb Keflezighi'),
('NYC Marathon',		'Rita Jeptoo'),
('Chicago Marathon',	'Galen Rupp');
