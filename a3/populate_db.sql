USE jmcclellanDB;

-- Of the remaining CMV_Submissions, Submissions, and Comments, 
-- select 20 random ones by the 16 authors in CMV_Sub_Author
DELETE FROM CMV_Submission
WHERE reddit_id NOT IN (
    SELECT * FROM (
        SELECT reddit_id FROM CMV_Submission WHERE author IN (
            SELECT author from CMV_Submission) 
        ORDER BY RAND()
        LIMIT 20)
    as t);

DELETE FROM Submission
WHERE reddit_id NOT IN (
    SELECT * FROM (
        SELECT reddit_id FROM Submission WHERE author IN (
            SELECT author from CMV_Submission) 
        ORDER BY RAND()
        LIMIT 20)
    as t);

DELETE FROM STD_Comment
WHERE reddit_id NOT IN (
    SELECT * FROM (
        SELECT reddit_id FROM STD_Comment WHERE author IN (
            SELECT author from CMV_Submission) 
        ORDER BY RAND()
        LIMIT 20)
    as t);

-- Select 20 CMV_Comment that are children of the current CMV_Submissions
DELETE FROM CMV_Comment
WHERE reddit_id NOT IN (
    SELECT * FROM (
        SELECT reddit_id FROM CMV_Comment WHERE parent_submission_id IN (
            SELECT reddit_id from CMV_Submission) 
        ORDER BY RAND()
        LIMIT 20)
    as t);

-- Select 20 CMV_Mod_Comment that are children of the current CMV_Submissions
DELETE FROM CMV_Mod_Comment
WHERE reddit_id NOT IN (
    SELECT * FROM (
        SELECT reddit_id FROM CMV_Mod_Comment
        WHERE parent_submission_id IN (
            SELECT reddit_id FROM CMV_Submission
        )
        LIMIT 20)
    as t);
