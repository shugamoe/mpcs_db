use jmcclellanDB;
source a3.sql;

-- Table that has top-line information on CMV Moderators and their cmv comments
CREATE TABLE CMV_Moderator AS
SELECT normal_cmvmc.author mod_name, COUNT(normal_cmvmc.author) cmv_comments, AVG(sub_id.subs_in) cmv_subs_commented_on
FROM CMV_Mod_Comment normal_cmvmc
JOIN (SELECT author, COUNT(DISTINCT(parent_submission_id)) subs_in
    FROM CMV_Mod_Comment
    GROUP BY author) as sub_id
ON normal_cmvmc.author = sub_id.author
GROUP BY normal_cmvmc.author;

-- Table that shows pairs of Redditors commenting on the same parent submission
SELECT c1.author, c2.author
FROM (STD_Comment JOIN
JOIN STD_Comment
ON c1.parent_submission_id = c2.parent_submission_id
AND c1.author < c2.author


