SELECT author
FROM CMV_Submission
GROUP BY author
HAVING COUNT(*) = (SELECT MAX(num_subs)
    FROM (SELECT COUNT(*) num_subs
        FROM CMV_Submission
        GROUP BY author) as t1);

-- Selecting users who follow exactly the same users as Slenderpman
CREATE VIEW sp_info AS
SELECT redditor1
FROM Redditor_Submission_Encounter
WHERE redditor2 = 'Slenderpman';

SELECT u.redditor2
FROM Redditor_Submission_Encounter u
WHERE u.redditor1 IN (SELECT redditor1 FROM sp_info)
GROUP BY redditor2
HAVING COUNT(*) = (SELECT COUNT(*) FROM sp_info); 
