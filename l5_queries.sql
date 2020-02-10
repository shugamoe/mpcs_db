USE zfreemanDB;

SELECT A.runnerName, B.runnerName, A.raceName
FROM Likes A, Likes B
WHERE A.raceName = B.raceName
AND A.runnerName > B.runnerName;

SELECT A.runnerName, B.runnerName, A.raceName
FROM Likes A 
JOIN Likes B ON A.raceName = B.raceName
WHERE A.runnerName > B.runnerName;

-- pairs of runners who like the same race & race name
SELECT A.runnerName, B.runnerName, raceName
FROM Likes A 
JOIN Likes B USING (raceName)
WHERE A.runnerName > B.runnerName;

SELECT A.runnerName, B.runnerName, C.runnerName, A.raceName 
FROM Likes A 
JOIN Likes B ON A.raceName = B.raceName
JOIN Likes C ON B.raceName = C.raceName
WHERE A.runnerName > B.runnerName
AND B.runnerName > C.runnerName;

SELECT runnerName, raceName
FROM Likes
NATURAL JOIN Registrations;

SELECT runnerName, raceName
FROM Likes
INNER JOIN Registrations USING (raceName, runnerName);

SELECT Likes.runnerName, Likes.raceName
FROM Likes
INNER JOIN Registrations ON Registrations.raceName = Likes.raceName
						AND Registrations.runnerName = Likes.runnerName;

-- runners who finished a race they like (and the distance of the race)
SELECT runnerName, raceName, distance
FROM Results 
NATURAL JOIN Likes
NATURAL JOIN Race;

SELECT Likes.*, Race.distance, Race.raceCountry, Race.RegistrationCap
FROM Likes
INNER JOIN Race ON Likes.raceName = Race.raceName;

SELECT r.runnerName AS runner, l.raceName AS likedRace
FROM Runner r LEFT OUTER JOIN Likes l
ON r.runnerName = l.runnerName;

SELECT r.runnerName AS runner, l.raceName AS likedRace
FROM Runner r LEFT OUTER JOIN Likes l
ON r.runnerName = l.runnerName
WHERE l.raceName IS NULL;

-- Find all runners (along with the race name and their finishing place) 
-- who have a finish in a better (lower) position than Ryan Hall’s best finish.
SELECT runnerName, raceName, place
FROM Results
WHERE place < (SELECT MIN(place)
				FROM Results
				WHERE runnerName = 'Ryan Hall');

-- Find all runners that place, on average, 
-- better (lower) than the average place of Kara Goucher.
SELECT Runner.*
FROM (SELECT AVG(place) AS avgplace, runnerName
		FROM Results
		GROUP BY runnerName) AveragePlace, Runner
WHERE AveragePlace.runnerName = Runner.runnerName
AND avgplace < (SELECT AVG(place)
					FROM Results
					WHERE runnerName = 'Kara Goucher');

-- all races longer distance than average distance of race's in that country
SELECT raceName, distance
FROM Race
INNER JOIN (SELECT AVG(distance) AS avgDistance, raceCountry
			FROM Race
            GROUP BY raceCountry) AverageDistance
            USING (raceCountry)
            -- ON Race.raceCountry = AverageDistance.raceCountry
WHERE distance > avgDistance;


-- find all runners who have finished all races Kara Goucher has finished
SELECT runnerName
FROM (SELECT raceName
		FROM Results
        WHERE runnerName = 'Kara Goucher') KaraRaces
INNER JOIN Results ON KaraRaces.raceName = Results.raceName
WHERE runnerName != 'Kara Goucher'
GROUP BY runnerName
HAVING COUNT(*) = (SELECT COUNT(*) 
					FROM Results 
					WHERE runnerName = 'Kara Goucher');

CREATE TEMPORARY TABLE KaraRaces AS
SELECT raceName
FROM Results
WHERE runnerName = 'Kara Goucher';

-- DROP TABLE KaraRaces
    
-- INSERT INTO KaraRaces
-- VALUES ('SAFE MODE!!!!');

SELECT *
FROM KaraRaces;
    
CREATE TEMPORARY TABLE KaraRaces2 AS
SELECT *
FROM KaraRaces;

SELECT runnerName
FROM KaraRaces
INNER JOIN Results ON KaraRaces.raceName = Results.raceName
WHERE runnerName != 'Kara Goucher'
GROUP BY runnerName
HAVING COUNT(*) = (SELECT COUNT(*) 
					FROM KaraRaces2);

-- CREATE VIEW DROP VIEW AgeResults
CREATE VIEW AgeResults AS
SELECT r.runnerName, r.raceName, r.place, run.age AS currentAge, ag.ageGroupDesc
FROM Results r
INNER JOIN Runner run ON r.runnerName = run.runnerName
INNER JOIN AgeGroup ag ON r.ageGroup = ag.ageGroupCode;

-- SELECT from VIEW
SELECT *
FROM AgeResults;

SELECT currentAge, ageGroupDesc
FROM AgeResults
WHERE runnerName = 'Dean Karnazes'
AND raceName = 'Badwater Ultramarathon';

SHOW ENGINES;


SELECT *
FROM Likes;

UPDATE Runner
SET runnerName = 'Cheata Jeptoo'
WHERE runnerName = 'Rita Jeptoo';

DELETE FROM Runner
WHERE runnerName = 'Cheata Jeptoo';

CREATE TEMPORARY TABLE TemporaryTableIndexTest 
(testID INTEGER NOT NULL AUTO_INCREMENT, 
runnerName VARCHAR(50),
favRace VARCHAR(50),
distance INT,
PRIMARY KEY(testID), 
INDEX(testID))
SELECT runnerName, favRace, distance
FROM Runner r
INNER JOIN Race ON r.favRace = Race.raceName;

SELECT * 
FROM TemporaryTableIndexTest;

SELECT *
FROM Runner LEFT OUTER JOIN Registrations
ON Runner.runnerName = Registrations.runnerName;

SELECT *
FROM Runner 
WHERE EXISTS (SELECT runnerName 
				FROM Registrations
				WHERE Runner.runnerName = Registrations.runnerName);
OR NOT EXISTS (SELECT runnerName 
				FROM Registrations
				WHERE Runner.runnerName = Registrations.runnerName);
