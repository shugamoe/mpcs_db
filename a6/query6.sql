-- In the Table CMV_Sub_Author, the scraping process to see how many deltas the
-- author awarded is bugged, so let's do a query to see how we could find this
-- out manually. 
SELECT author, SUM(deltas_from_author)
FROM CMV_Submission
GROUP BY author;


-- While we now know how many deltas an author awarded, we know that an author
-- can award more tha one delta in a submission, let's find out how many
-- submissions an author had where they gave a delta and how many submissions
-- that author had
SELECT cmvs.author, auth_info.cmv_submissions, COUNT(*) views_changed, (COUNT(*) / auth_info.cmv_submissions) frac_views_changed
FROM (SELECT * FROM CMV_Submission WHERE deltas_from_author > 0) cmvs
JOIN CMV_Sub_Author auth_info
ON cmvs.author = auth_info.user_name
GROUP BY cmvs.author;
-- You'll notice that at the bottom of the query, the user '_BlueSkies_' has
-- more view changed than changemyview posts. This revealed an error in my
-- scraping procedure which I will fix for the final project


-- The following query is sped up from 1.55 seconds to .05 seconds with the following index
-- For the CMV_Moderators, how many of them have made their own
-- CMV_Submissions?
SELECT cmvm.mod_name, COUNT(*) cmv_submissions
FROM CMV_Moderator cmvm
LEFT OUTER JOIN CMV_Submission cmvsa
ON cmvm.mod_name = cmvsa.author
GROUP BY cmvm.mod_name
ORDER BY COUNT(*) DESC;
-- Index
CREATE INDEX cmv_sub_author_names
ON CMV_Submission(author);
-- Rerun query
SELECT cmvm.mod_name, COUNT(*) cmv_submissions
FROM CMV_Moderator cmvm
LEFT OUTER JOIN CMV_Submission cmvsa
ON cmvm.mod_name = cmvsa.author
GROUP BY cmvm.mod_name
ORDER BY COUNT(*) DESC;


-- Find the CMV_Submission Authors whose CMV_Submissions have an average length
-- of over 2000 characters (about over 400 words).
SELECT author, AVG(CHAR_LENGTH(content)) avg_cars_in_view
FROM CMV_Submission
GROUP BY author
HAVING AVG(CHAR_LENGTH(content)) > 2000;



-- How many times have Redditors encountered other Redditors in a submission
-- This query is goes from 5 minutes 20 seconds to 4 minutes 42 seconds with the following index
CREATE INDEX sub_encounter_redditors
ON Redditor_Submission_Encounter(redditor1, redditor2);

SELECT encounter_users.user_name, COUNT(*)
FROM ((SELECT DISTINCT redditor1 user_name
        FROM Redditor_Submission_Encounter) UNION
    (SELECT DISTINCT redditor2 user_name 
        FROM Redditor_Submission_Encounter)) AS encounter_users
JOIN Redditor_Submission_Encounter rse
ON encounter_users.user_name = rse.redditor1
OR encounter_users.user_name = rse.redditor2
GROUP BY encounter_users.user_name;
