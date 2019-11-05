-- Find the average length of regular Submissions for a CMV Submission author
-- if they awarded at least one delta
SELECT AVG(CHAR_LENGTH(s.content)) avg_sub_length, cmvs.author
FROM Submission s, CMV_Submission cmvs
WHERE s.author = cmvs.author
GROUP BY cmvs.author
HAVING AVG(cmvs.deltas_from_author > 0);


-- Find out how many submissions a CMV_Submission author has if they have
-- awarded at least one delta
SELECT COUNT(*) num_subs, cmvs.author
FROM Submission s, CMV_Submission cmvs
WHERE s.author = cmvs.author
GROUP BY cmvs.author
HAVING AVG(cmvs.deltas_from_author > 0);


-- For each CMV_Submission author, find out the maximum number of comments they
-- posted on their own CMV_Submissions where they awarded a delta
-- (These numbers are rather low, I expect a bug in my scraping procedure. A
-- modification procedure to remove bad data is seen ahead)
SELECT MAX(author_comments), author
FROM CMV_Submission
WHERE deltas_from_author > 0
GROUP BY author;


-- Find the average number of total replies each CMV_Submission author 
-- receives per CMV_Submission
SELECT AVG(direct_comments), COUNT(*) num_cmv_subs, author
FROM CMV_Submission
GROUP BY author;


-- Find what fraction of CMV_Submissions a CMV_author has where a delta
-- is awarded from someone besides themselves, and they did not award a delta
SELECT AVG(deltas_from_other), author
FROM CMV_Submission
WHERE deltas_from_author = 0 -- Given the dataset size this line has no effect
GROUP BY author;             -- on the results

-- Find average length of all direct responses to CMV_Submissions by CMV Author
SELECT AVG(CHAR_LENGTH(cmvc.content)) avg_response_length, 
    cmvs.author cmv_sub_author
FROM CMV_Comment cmvc, CMV_Submission cmvs
WHERE cmvc.parent_submission_id = cmvs.reddit_id
AND ISNULL(parent_comment_id) -- Ensures that it is a direct response
GROUP BY cmvs.author;



