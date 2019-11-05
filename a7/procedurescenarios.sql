-- (1)
-- Show that WipeAuthor Procedure works for author "[deleted]"
-- Note that deleted does not exist in all tables, but where this author exists
-- the database will not contain information on them (i.e. any deleted author) anymore
-- 3019
SELECT COUNT(*) FROM CMV_Comment
WHERE author = "[deleted]";

-- 1
SELECT COUNT(*) FROM CMV_Commentor
WHERE user_name = "[deleted]";

-- The rest of these will not include a deleted author (will have a count of 0)
-- due to the logic in the scraping procedure. I will include them here to
-- demonstrate the 0 count, but after the procedure is called I won't retype
-- them.
SELECT COUNT(*) FROM CMV_Mod_Comment
WHERE author = "[deleted]";

SELECT COUNT(*) FROM CMV_Moderator
WHERE mod_name = "[deleted]";

SELECT COUNT(*) FROM CMV_Sub_Author
WHERE user_name = "[deleted]";

SELECT COUNT(*) FROM CMV_Submission
WHERE author = "[deleted]";

SELECT COUNT(*) FROM CMV_Submission_Encounter
WHERE redditor1 = "[deleted]"
OR redditor2 = "[deleted]";

SELECT COUNT(*) FROM CMV_Comment_Encounter
WHERE redditor1 = "[deleted]"
OR redditor2 = "[deleted]";

SELECT COUNT(*) FROM STD_Comment
WHERE author = "[deleted]";

SELECT COUNT(*) FROM Submission
WHERE author = "[deleted]";


-- Call procedure
CALL WipeAuthor("[Deleted]");

-- Should have 0 count now
SELECT COUNT(*) FROM CMV_Comment
WHERE author = "[deleted]";

-- Also 0 count 
SELECT COUNT(*) FROM CMV_Commentor
WHERE user_name = "[deleted]";





-- (2)
-- First we see that no CMV_Sub_Authors are flagged
SELECT * FROM CMV_Sub_Author
WHERE flagged IS TRUE;

-- Let's flag author "whalemango"
CALL FlagAuthor("whalemango");

-- "whalemango" is now flagged
SELECT * FROM CMV_Sub_Author
WHERE flagged IS TRUE;




-- (3)
-- First we see that no CMV_Submissions are flagged
SELECT * FROM CMV_Submission
WHERE flagged is TRUE;

-- Let's flag submissions from January 1st 2017 to Februrary 2nd 2017.
CALL SelectSubmissionBetween("2017-01-01", "2017-02-01");

-- Now submissions with between these dates (inclusive) are flagged!
SELECT COUNT(*) 01_01_2017_to_02_01_2017 FROM CMV_Submission
WHERE flagged is TRUE;


-- (4)
-- First let's unflag all the CMV_Submissions
UPDATE CMV_Submission
SET flagged = FALSE;

-- Let's look for how many submissions have "Trump" in the title or
-- content
CALL SearchCMVWord("Trump");

SELECT COUNT(*) trump_in_cmv_sub FROM CMV_Submission
WHERE flagged is TRUE;

-- What's the title for one of these?
SELECT title FROM CMV_Submission
WHERE flagged is TRUE
ORDER BY title
LIMIT 1;


-- (5)
-- Unflag all CMV_Sub_Authors
UPDATE CMV_Sub_Author
SET flagged = FALSE;

-- Flag authors who have used "Trump" in a CMV_Submission and in a
-- comment or a submission of theirs.
CALL SearchCMVAuthWord("Trump");

-- How many are there?
SELECT * FROM CMV_Sub_Author
WHERE flagged IS TRUE;
