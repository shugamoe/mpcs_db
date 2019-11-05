-- Scenario that doesn't activate trigger (1) 
INSERT INTO CMV_Commentor
VALUES("t1_no_activate", 5, 5);
-- We see that this tuple is in the table 
SELECT user_name 
FROM CMV_Commentor
WHERE user_name = "t1_no_activate";


-- Scenario that does activate trigger (1)
INSERT INTO CMV_Commentor(user_name, cmv_comments, cmv_subs_commented_on)
VALUES("t1_activate", 3, 5);
-- The trigger activation should have raised an error to prevent the insertion
-- so we won't see the username
SELECT user_name 
FROM CMV_Commentor
WHERE user_name = "t1_activate";




-- Scenario that doesn't activate trigger (2)
-- We do not log this change 
INSERT INTO CMV_Submission
VALUES(0, 12345, "s117", "t2_no_activate", "r/changemyview", FALSE, "Dogs aren't cats. CMV",
    "Dogs are clearly dogs.", 0, 0, 0, 0, 0, 0, 0);
-- Should be nothing in the log table
SELECT * FROM CMV_Submission_Edited_Log;

-- Scenario that does activate trigger (2)
-- We will log this change since the submission is edited
INSERT INTO CMV_Submission
VALUES(0, 12345, "s118", "t2_activate", "r/changemyview", TRUE, "Louis C.K. is the best. CMV",
    "Louis C.K, damn, love that guy.", 0, 0, 0, 0, 0, 0, 0);
-- Should be something in the log table (s118)
SELECT * FROM CMV_Submission_Edited_Log;


-- Scenario that doesn't activate trigger (3)
-- No need to delete anything from CMV_Submission_Edited_Log since this is a
-- new submission (reddit_id)
INSERT INTO CMV_Submission
VALUES(0, 12345, "s119", "t3_no_activate", "r/changemyview", TRUE, "Cheese is the best. CMV",
    "Cheese is from cows, end of story.", 0, 0, 0, 0, 0, 0, 0);
-- Should be something in the log table (s118, s119)
SELECT * FROM CMV_Submission_Edited_Log;


-- Scenario that does activate trigger (3)
-- We have to change the primary key of CMV_Submission to a composite one for this to work,
-- this is no big deal though. If there was a full system to track repeated scraping of the 
-- data, the date_utc would change if the post was in fact edited
ALTER TABLE CMV_Submission DROP PRIMARY KEY, ADD PRIMARY KEY(date_utc, reddit_id);
INSERT INTO CMV_Submission
VALUES(0, 123456, "s118", "t3_activate", "r/changemyview", TRUE, "Louis C.K is the worst. CMV",
    "Louis C.K. abused his powa.", 0, 0, 0, 0, 0, 0, 0);
-- We see that the insert_date_utc for s118 is a bigger number (newer date)
-- than there was previously 
SELECT * FROM CMV_Submission_Edited_Log;
