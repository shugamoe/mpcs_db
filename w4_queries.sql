USE jmcclellanDB;
source l4_create_db.sql

-- "Find all races that have 'Marathon' in the name and are not held
-- in the USA
SELECT *
FROM Race
WHERE raceName LIKE '%marathon%'
AND raceCountry != 'USA';


-- Find the name, age, and years running of all runners who have
-- run races
SELECT DISTINCT Runner.runnerName, age, yearsRunning, raceName
-- ^ Don't need to treat DISTINCT like a function, it applies 
-- to everything in the SELECT statement
FROM Runner, Results
WHERE place = 1
AND Results.runnerName = Runner.runnerName;


-- Find the races that people who registered for Bost-marathon liked
SELECT DISTINCT Likes.raceName
FROM Registrations, Likes
WHERE Registrations.raceName = 'Boston Marathon'
AND Likes.runnerName = Registrations.runnerName;

-- Find all pairs of different races liked by the same runner
SELECT A.raceName, B.raceName
FROM Likes A, Likes B -- This applies a cross product
WHERE A.runnerName = B.runnerName
AND A.raceName > B.raceName; -- This line prevents repeats


-- Find all runners that are registered for their favorite race
SELECT DISTINCT A.runnerName
FROM Runner A, Registrations B
WHERE A.favRace = B.raceName
AND A.runnerName = B.runnerName;


-- Find all runners that finished two different races in the same
-- place
SELECT DISTINCT A.runnerName, A.place
FROM Results A, Results B
WHERE A.raceName != B.raceName
AND A.runnerName = B.runnerName
AND A.place = B.place;


-- Find all runners that finished three different races in the same
-- place
SELECT DISTINCT A.runnerName, A.place
FROM Results A, Results B, Results C
WHERE A.raceName != B.raceName
AND B.raceName != C.raceName
AND A.place = B.place
AND B.place = C.place
AND A.runnerName = B.runnerName
AND B.runnerName = C.runnerName;


-- Find the runner finished the NYC Marathon in the same place as Rita
-- Jeptoo finished the Chicago Marathon
SELECT runnerName
FROM Results 
WHERE raceName = 'NYC Marathon'
AND place = (
    SELECT place
    FROM Results -- Internal subquery can refer to exernal one, but not
    WHERE runnerName = 'Rita Jeptoo' -- vice-versa
    AND raceName = 'Chicago Marathon');


-- Find the name and registration cap of all races that Meb likes
SELECT raceName, registrationCap
FROM Race 
WHERE raceName IN
    (SELECT raceName
    FROM Likes
    WHERE runnerName = 'Meb Keflezighi');


-- Find the races in the Race table that are the unique race in their
-- country
SELECT raceName
FROM Race r
WHERE NOT EXISTS (SELECT *
    FROM Race
    WHERE raceCountry = r.raceCountry -- refs outer query
    AND raceName != r.raceName); -- ^ "A correlated subquery"


-- Select race with highest registrationCap
SELECT raceName, registrationCap
FROM Race
WHERE registrationCap >= ALL(
    SELECT registrationCap
    FROM Race
);

-- Find the USA races with neither the highest nor lowest registrationCap
SELECT raceName, raceCountry
FROM Race
WHERE registrationCap > ANY(
    SELECT registrationCap
    FROM Race
    WHERE raceCountry = 'USA'
)
AND registrationCap < ANY(
    SELECT registrationCap
    FROM Race
    WHERE raceCountry = 'USA'
)
AND raceCountry = 'USA';


-- Find the runners that have won marathons or that are registered for the
-- Chicago Marathon
(SELECT runnerName
    FROM Results
    WHERE place = 1
    AND raceName LIKE '%marathon')
UNION
(SELECT runnerName
    FROM Registrations
    WHERE raceName = 'Chicago Marathon');


-- Find all different distances of races
SELECT DISTINCT distance
FROM Race;


-- Find the average finishing place for Tera Moody
SELECT AVG(place)
FROM Results
WHERE runnerName = 'Tera Moody';


-- Find unique places Rita Jeptoo has finished in
SELECT COUNT(place)
FROM Results
WHERE runnerName = 'Rita Jeptoo';


-- Find the worst place for each runner
SELECT runnerName, MAX(place) worst_place
FROM Results
GROUP BY runnerName;

-- Find the lowest place, and which race it was for Dean Karnazes
SELECT raceName, place, runnerName
FROM Results
WHERE place = (SELECT MIN(place)
    FROM Results
    WHERE runnerName = 'Dean Karnazes')
AND runnerName = 'Dean Karnazes';

-- For every runner find the avg registrationCap of the races they are
-- registered for
SELECT runnerName, AVG(registrationCap)
FROM Registrations, Race
WHERE Registrations.raceName = Race.raceName
GROUP BY runnerName;


-- HAVING eg. (HAVING filters after data is grouped)
-- Find the average places of runners have either finished at least 3 races
-- or have been running for at least 20 years
SELECT r.runnerName, AVG(place)
FROM Results r
GROUP BY r.runnerName
HAVING COUNT(place) >= 3
    OR r.runnerName IN (SELECT runnerName 
                        FROM Runner
                        WHERE yearsRunning > 20);


-- Find all runners that have finished three or more races in the top 10
SELECT runnerName, COUNT(*) total_races_finished
FROM Results
WHERE place <= 10
GROUP BY runnerName
HAVING COUNT(*) >= 3;


-- Find all runners registered for more than 2 races
SELECT runnerName, COUNT(*) as total_races_finished
FROM Registrations
GROUP BY runnerName
HAVING COUNT(*) > 2;
