-- Find the subreddits of the submissions made by CMV Submission Authors
-- before their latest CMV submission
SELECT sub.author, sub.subreddit, COUNT(*) subs_before_latest_cmv
FROM Submission sub, (SELECT * FROM (
    SELECT author, MAX(date_utc) date_utc
    FROM CMV_Submission
    GROUP BY author, subreddit
    ) as t1) AS cmvs
WHERE cmvs.date_utc > sub.date_utc
AND cmvs.author = sub.author
GROUP BY sub.author, sub.subreddit;


-- Find the subreddits of the submissions made by CMV Submission Authors
-- before their latest CMV submission, but only if these submissions have
-- higher scores than their latest CMV_Submission
SELECT sub.author, sub.subreddit, COUNT(*) subs_before_latest_cmv
FROM Submission sub, (SELECT * FROM (
    SELECT author, MAX(date_utc) date_utc, score
    FROM CMV_Submission
    GROUP BY author, subreddit, score
    ) as t1) AS cmvs
WHERE cmvs.date_utc > sub.date_utc
AND cmvs.author = sub.author
AND cmvs.score < sub.score
GROUP BY sub.author, sub.subreddit;


-- Find the CMV_Submission authors who comment on the same subreddit
-- Turns out r/AskReddit is the common place where these people comment
SELECT c1.author, c2.author, c1.subreddit
FROM STD_Comment c1, STD_Comment c2
WHERE c1.subreddit = c2.subreddit
AND c1.author > c2.author;

-- Find the subreddits in which CMV_Submision authors who post submissions on
-- the same subreddit
SELECT s1.subreddit
FROM Submission s1, Submission s2
WHERE s1.subreddit = s2.subreddit
AND s1.author > s2.author
GROUP BY s1.subreddit;


-- Find the unique cmv_moderators  (and how many times they commented) who
-- commented on all the CMV Submission by the user 'ineedfreedom'
SELECT DISTINCT mod_com.author, COUNT(*)
FROM CMV_Mod_Comment mod_com,
    (SELECT * FROM
        (SELECT reddit_id
            FROM CMV_Submission
            WHERE author = 'ineedfreedom') as t1) as freedom_subs
WHERE mod_com.parent_submission_id = freedom_subs.reddit_id
GROUP BY mod_com.author;


-- Find all the authors of comments and submissions by CMV_Submission authors
-- with a score of 100 or over on either one of their comments or their submissions
-- (Note that only CMV_Submission authors have any Submissions or Comments)
SELECT c.author
FROM STD_Comment c, Submission s
WHERE c.score > 100
OR s.score > 100;
