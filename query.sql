-- Queries for ASsignment 3, Julian McClellan
USE jmcclellanDB;

-- Find the the author and score of the 10 highest scoring CMV_Submissions
SELECT DISTINCT(author), score FROM (
    SELECT * FROM (
    SELECT * FROM CMV_Submission
    ORDER BY score DESC
    LIMIT 10
    ) AS t1
) AS t2;

-- Find the distinct authors of CMV_Submissions, and the titles of these submissions 
-- where the authors gave one or more deltAS 
SELECT DISTINCT(author), title
FROM CMV_Submission
WHERE deltAS_from_author > 0;

-- Find the average of some vars of CMV_Submissions
SELECT AVG(view_description), AVG(score), AVG(total_comments),
       AVG(deltas_from_author), AVG(cmv_mod_comments)
FROM (SELECT CHAR_LENGTH(content) AS view_description,
    score,
    total_comments,
    deltas_from_author,
    cmv_mod_comments
    FROM CMV_Submission) 
AS t1;

-- Find the 5 most active moderator (moderator with the most comments in CMV)
-- (#1 Should be delta bot)
SELECT * 
FROM (
    SELECT author, COUNT(*) as coms
    FROM CMV_Mod_Comment
    GROUP BY author
    ORDER BY coms DESC
    LIMIT 5
) AS t1;

-- Find the title of the 5 CMV_Submission with the most total_comments 
SELECT title, total_comments FROM (
    SELECT * FROM (
    SELECT * FROM CMV_Submission
    ORDER BY total_comments DESC
    LIMIT 5
    ) AS t1
) as t2;

-- Find the CMV_Sub_Authors with the most regular (Non-CMV) Submissions
SELECT author, COUNT(*) AS num_std_subs 
FROM Submission
GROUP BY author
ORDER BY num_std_subs DESC;




