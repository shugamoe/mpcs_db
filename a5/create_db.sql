source a5.sql;

-- Table that has top-line information on CMV Moderators and their cmv comments
DROP TABLE IF EXISTS CMV_Moderator;
CREATE TABLE CMV_Moderator AS
SELECT DISTINCT normal_cmvmc.author mod_name, COUNT(normal_cmvmc.author) cmv_comments, sub_id.subs_in cmv_subs_commented_on
FROM CMV_Mod_Comment normal_cmvmc
JOIN (SELECT author, COUNT(DISTINCT(parent_submission_id)) subs_in
    FROM CMV_Mod_Comment
    GROUP BY author) as sub_id
ON normal_cmvmc.author = sub_id.author
GROUP BY normal_cmvmc.author;


-- Table that shows pairs of Redditors commenting on the same parent submission
-- First create the table with information from STD_Comment, then add information
-- from CMV_Mod_Comment 

-- Although this information is derived from other tables, the join of STD_Comment and CMV_Comment
-- onto themselves is actually rather time consuming, so it makes sense from a time-saving
-- perspective to have these tables created separately.
DROP TABLE IF EXISTS Redditor_Submission_Encounter;
CREATE TABLE Redditor_Submission_Encounter AS
SELECT c1.author redditor1, c2.author redditor2, c1.parent_submission_id parent_submission_id, c1.subreddit subreddit
FROM STD_Comment c1
JOIN STD_Comment c2
ON c1.parent_submission_id = c2.parent_submission_id
AND c1.author != '[deleted]'
AND c2.author != '[deleted]'
AND c1.author < c2.author;

INSERT INTO Redditor_Submission_Encounter
SELECT c1.author redditor1, c2.author redditor2, c1.parent_submission_id parent_submission_id, c1.subreddit subreddit
FROM CMV_Comment c1
JOIN CMV_Comment c2
ON c1.parent_submission_id = c2.parent_submission_id
-- AND c1.author != '[deleted]'
-- AND c2.author != '[deleted]'
AND c1.author < c2.author;


-- Table that shows pairs of Redditors commenting on the same parent comment
-- First create the table with information from STD_Comment, then add information
-- from CMV_Mod_Comment 
DROP TABLE IF EXISTS Redditor_Comment_Encounter;
CREATE TABLE Redditor_Comment_Encounter AS
SELECT c1.author redditor1, c2.author redditor2, c1.parent_comment_id parent_comment_id, c1.subreddit subreddit
FROM STD_Comment c1
JOIN STD_Comment c2
ON c1.parent_comment_id = c2.parent_comment_id
AND c1.author != '[deleted]'
AND c2.author != '[deleted]'
AND c1.author < c2.author;


INSERT INTO Redditor_Comment_Encounter
SELECT c1.author redditor1, c2.author redditor2, c1.parent_comment_id parent_comment_id, c1.subreddit subreddit
FROM CMV_Comment c1
JOIN CMV_Comment c2
ON c1.parent_comment_id = c2.parent_comment_id
AND c1.author != '[deleted]'
AND c2.author != '[deleted]'
AND c1.author < c2.author;


-- Table that tracks the statistics of commentors on CMV posts
CREATE TABLE CMV_Commentor AS
SELECT normal_cmvmc.author user_name, COUNT(normal_cmvmc.author) cmv_comments, AVG(sub_id.subs_in) cmv_subs_commented_on
FROM CMV_Mod_Comment normal_cmvmc
JOIN (SELECT author, COUNT(DISTINCT(parent_submission_id)) subs_in
    FROM CMV_Comment
    GROUP BY author) as sub_id
ON normal_cmvmc.author = sub_id.author
GROUP BY normal_cmvmc.author;

-- Get the non moderator comments
INSERT INTO CMV_Commentor
SELECT normal_cmvmc.author user_name, COUNT(normal_cmvmc.author) cmv_comments, AVG(sub_id.subs_in) cmv_subs_commented_on
FROM CMV_Comment normal_cmvmc
JOIN (SELECT author, COUNT(DISTINCT(parent_submission_id)) subs_in
    FROM CMV_Comment
    GROUP BY author) as sub_id
ON normal_cmvmc.author = sub_id.author
GROUP BY normal_cmvmc.author;

-- The AVG in the select statement will make the column a float when we don't need to
ALTER TABLE CMV_Commentor
MODIFY COLUMN cmv_subs_commented_on INT;

