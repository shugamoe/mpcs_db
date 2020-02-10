USE zfreemanDB;

SELECT DISTINCT Runner.runnerName, age, yearsRunning, raceName
FROM Runner, Results
WHERE place = 1
AND Results.runnerName = Runner.runnerName;

SELECT DISTINCT Likes.raceName
FROM Registrations, Likes
WHERE Registrations.raceName = 'Boston Marathon'
AND Likes.runnerName = Registrations.runnerName;

SELECT A.raceName, B.raceName
FROM Likes AS A, Likes AS B
WHERE A.runnerName = B.runnerName
-- AND A.raceName != B.raceName
AND A.raceName > B.raceName;

SELECT Runner.runnerName
FROM Runner, Registrations
WHERE Runner.favRace = Registrations.raceName
AND Registrations.runnerName = Runner.runnerName;

SELECT DISTINCT r1.runnerName
FROM Results r1, Results r2
WHERE r1.runnerName = r2.runnerName
AND r1.place = r2.place
AND r1.raceName > r2.raceName;

SELECT DISTINCT r1.runnerName
FROM Results r1, Results r2, Results r3
WHERE r1.runnerName = r2.runnerName
AND r2.runnerName = r3.runnerName
AND r1.place = r2.place
AND r2.place = r3.place
AND r1.raceName > r2.raceName
AND r2.raceName > r3.raceName;

SELECT runnerName
FROM Results
WHERE raceName = 'NYC Marathon' 
AND place =	(SELECT place
			FROM Results
			WHERE runnerName = 'Rita Jeptoo'
			AND raceName = 'Chicago Marathon');


SELECT raceName, registrationCap
FROM Race
WHERE raceName IN (SELECT raceName
					FROM Likes 
					WHERE runnerName = 'Meb Keflezighi');

SELECT Race.raceName, registrationCap
FROM Race, Likes
WHERE Race.raceName = Likes.raceName
AND runnerName = 'Meb Keflezighi';

SELECT raceName
FROM Race r
WHERE NOT EXISTS (SELECT *	
			FROM Race	
			WHERE raceCountry = r.raceCountry				
            AND raceName != r.raceName);

SELECT raceName
FROM Race
WHERE registrationCap >= ALL(SELECT registrationCap FROM Race);

SELECT raceName
FROM Race
WHERE registrationCap > ANY(SELECT registrationCap 
							FROM Race 
                            WHERE raceCountry = 'USA')
AND registrationCap < ANY(SELECT registrationCap 
							FROM Race 
                            WHERE raceCountry = "USA")
AND raceCountry = 'USA';

(SELECT 	runnerName
FROM 		Results
WHERE	place = 1
AND 		raceName LIKE '%marathon%')
UNION ALL
(SELECT 	runnerName
FROM 		Registrations
WHERE 	raceName = 'Chicago Marathon');

SELECT place-- AVG(place)
FROM Results
WHERE runnerName = 'Tera Moody';


SELECT COUNT(DISTINCT place)
FROM Results
WHERE runnerName = 'Rita Jeptoo';

SELECT runnerName, MAX(place)
FROM Results
GROUP BY runnerName;

SELECT raceName, place, runnerName
FROM Results
WHERE runnerName = 'Dean Karnazes' 
AND place = (SELECT MIN(place)
				FROM Results
				WHERE runnerName = 'Dean Karnazes');

SELECT raceName, MIN(place)
FROM Results
WHERE runnerName = 'Dean Karnazes';

SELECT AVG(registrationCap), runnerName
FROM Registrations, Race
WHERE Registrations.raceName = Race.raceName
GROUP BY runnerName;

-- Find the average place of runners that have either finished 
-- at least 3 races or have been running for more than 20 years
SELECT r.runnerName, AVG(place)
FROM Results r
GROUP BY r.runnerName
HAVING COUNT(place) >= 3 
	OR r.runnerName IN (SELECT runnerName 
						FROM Runner 
						WHERE yearsRunning > 20);

SELECT runnerName, COUNT(place) TotalRacesFinished
FROM Results
WHERE place <= 10
GROUP BY runnerName
HAVING COUNT(place) >= 3;

-- Having examples not shown in class
SELECT runnerName, COUNT(raceName) AS TotalRaces
FROM Registrations
GROUP BY runnerName
HAVING COUNT(raceName) > 2
ORDER BY TotalRaces DESC;

SELECT reg.runnerName, COUNT(raceName) AS TotalRaces
FROM Registrations reg, Runner run
WHERE reg.runnerName = run.runnerName
AND run.age > 35
GROUP BY reg.runnerName
HAVING COUNT(raceName) > 2
ORDER BY TotalRaces DESC;	

-- Running Buddies
CREATE TABLE PotentialRunningBuddies (
	name VARCHAR(50),
    raceName VARCHAR(50)
);

DROP TABLE PotentialRunningBuddies;
INSERT INTO PotentialRunningBuddies
(SELECT DISTINCT B.runnerName, B.raceName
FROM Likes A, Likes B
WHERE 	A.runnerName = 'Zach Freeman'
AND 	B.runnerName != 'Zach Freeman'
AND 	A.raceName = B.raceName);

SELECT * FROM PotentialRunningBuddies;

-- 
DELETE FROM Runner;



