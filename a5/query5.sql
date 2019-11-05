-- Queries for assignment 5

-- Compare the average number of direct comments
-- responsive versus less responsive authors but had similar
-- total_comment numbers (within 10)
SELECT AVG(lr.direct_comments) avg_less_responsive_direct_comments, AVG(r.direct_comments) avg_responsive_direct_comments
FROM (SELECT *
    FROM CMV_Submission WHERE author IN (SELECT user_name from cmv_auth_responsive)) as r
JOIN (SELECT *
    FROM CMV_Submission WHERE author IN (SELECT user_name from cmv_auth_less_responsive)) lr
ON lr.direct_comments - r.direct_comments <= 10;


-- For CMV Submission authors with submission history before
-- their only CMV submission, what was the number
-- of submissions they had before their first cmv sub?
CREATE TEMPORARY TABLE cmv_auth_whistory_first_cmv_sub_date AS
SELECT author, MIN(date_utc) first_cmv_sub_utc, COUNT(author) num_cmv_subs
FROM CMV_Submission
WHERE author IN (SELECT user_name from CMV_Sub_Author)
GROUP BY author;

SELECT fcmv.author, COUNT(*) subs_before_first_cmv_sub
FROM cmv_auth_whistory_first_cmv_sub_date AS fcmv
JOIN Submission sub
ON fcmv.first_cmv_sub_utc > sub.date_utc
AND fcmv.author = sub.author
GROUP BY author, num_cmv_subs
HAVING num_cmv_subs = 1
ORDER BY COUNT(*) DESC;


-- Of all the Redditors that have posted a comment on the same submission,
-- which of those Redditors are actually CMV_Sub_Authors and what are there
-- statistics for submissions, comments, and cmv versions of these?  We will do
-- a full outter join of the users in Redditor_Submission_Encounter with
-- CMV_Sub_Author
SELECT DISTINCT * FROM
((SELECT DISTINCT redditor1 user_name
        FROM Redditor_Submission_Encounter) UNION
    (SELECT DISTINCT redditor2 user_name 
        FROM Redditor_Submission_Encounter)) AS encounter_users
LEFT OUTER JOIN CMV_Sub_Author
USING (user_name);


-- For the 10 authors who posted submission on the greatest unique
-- number of subreddits, what subreddits did they post comments to and how many
-- comments did they all post to these subreddits?
CREATE TEMPORARY TABLE cmv_auth_unique_subs
SELECT t2.author, t2.subreddits_submitted_to
FROM (
    SELECT t1.author author, COUNT(*) subreddits_submitted_to
    FROM
    (SELECT author, COUNT(*) submissions_to_subreddit
    FROM Submission GROUP BY author, subreddit) as t1
    GROUP BY t1.author
) as t2
ORDER BY subreddits_submitted_to DESC
LIMIT 10;

SELECT subreddit, COUNT(*) num_coms
FROM STD_Comment
WHERE author IN (SELECT author 
    FROM cmv_auth_unique_subs)
GROUP BY subreddit;


-- Get the titles of all the CMV submissions that Redditors encountered each other in,
-- as long as the CMV Submission didn't have any deltas_from_author
SELECT title
FROM Redditor_Submission_Encounter rse
JOIN CMV_Submission cmvs
ON cmvs.reddit_id = rse.parent_submission_id
GROUP BY title;


-- For CMV_Sub_Authors that didn't give a delta, how many total comments did
-- they receive on average for their CMV Submissions when they didn't respond
-- (only for authors with more than one CMV Submission)
SELECT no_delt.user_name, AVG(total_comments), COUNT(*) cmv_subs
FROM cmv_auth_no_delta no_delt
JOIN CMV_Submission cmvs
ON no_delt.user_name = cmvs.author
WHERE cmvs.author_comments = 0
GROUP BY no_delt.user_name
HAVING COUNT(*) > 1;


-- What are the subreddits that Redditors have both commented in and
-- submitted to, and how many times has an author commented and submitted to these subreddits
-- at least once?
SELECT c.subreddit, COUNT(*) at_least_one_auth_com_and_sub
FROM (SELECT DISTINCT author, subreddit FROM Submission) s
JOIN (SELECT DISTINCT author, subreddit FROM STD_Comment) c
USING (author, subreddit)
GROUP BY c.subreddit
ORDER BY COUNT(*) DESC;


-- For Redditors who have commented under the same parent comment, who are the
-- authors of these parent comments? Who wrote more than 2 comments where
-- other Redditors encountered each other? 
SELECT author, SUM(pairs_encountering_under_comment) encounter_comments_written
FROM (
    SELECT author, COUNT(*) pairs_encountering_under_comment
    FROM Redditor_Comment_Encounter rce
    JOIN ((SELECT author, reddit_id FROM STD_Comment) UNION 
            (SELECT author, reddit_id FROM CMV_Comment)) com_authors
    ON rce.parent_comment_id = com_authors.reddit_id
    GROUP BY author, rce.parent_comment_id) t3
WHERE author != "[deleted]"
GROUP BY author
HAVING encounter_comments_written > 1
ORDER BY encounter_comments_written DESC;


-- For the CMV_Moderator with the comments, who are the Redditor's who has
-- received the most comments from them in their CMV Submissions, how many CMV
-- submissions do these Redditors have?
CREATE TEMPORARY TABLE cmv_mod_most_coms AS
SELECT mod_name
FROM CMV_Moderator
ORDER BY cmv_comments DESC
LIMIT 1;

SELECT cmvs.author, COUNT(*) coms_from_moderator_with_most_comments, AVG(cmvsa.cmv_submissions) cmv_submissions
FROM cmv_mod_most_coms most_com
JOIN CMV_Mod_Comment mod_com
ON most_com.mod_name = mod_com.author
JOIN CMV_Submission cmvs
ON cmvs.reddit_id = mod_com.parent_submission_id
JOIN CMV_Sub_Author cmvsa
ON cmvs.author = cmvsa.user_name 
GROUP BY cmvs.author
ORDER BY COUNT(*) DESC;


-- For the CMV_Commentor that commented on the most submissions that is not a
-- moderator, what are the titles of the CMV Submissions they commented on?
CREATE TEMPORARY TABLE cmv_most_coms_no_mod AS
SELECT user_name
FROM CMV_Commentor
WHERE user_name NOT IN (SELECT mod_name FROM CMV_Moderator)
AND user_name != "[deleted]"
ORDER BY cmv_comments DESC
LIMIT 1;

SELECT DISTINCT cmvs.title 
FROM cmv_most_coms_no_mod mc
JOIN CMV_Comment cmvc
ON mc.user_name = cmvc.author
JOIN CMV_Submission cmvs
ON cmvc.parent_submission_id = cmvs.reddit_id;




