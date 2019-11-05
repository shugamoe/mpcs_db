-- (1) (Database Modification)
-- Deletes all record of an author from the all relevant tables
-- (If an author commented on a cmv_submission then their comment is still
-- counted in the number of comments though. Also, I won't be erasing
-- information from CMV_Submission_Edited_Log since I won't be using that
-- table anyway.)
DROP PROCEDURE IF EXISTS WipeAuthor;
DELIMITER |
CREATE PROCEDURE WipeAuthor(
    IN target_author VARCHAR(20))
    BEGIN
        DELETE FROM CMV_Comment
        WHERE author = target_author;
        DELETE FROM CMV_Commentor
        WHERE user_name = target_author;
        DELETE FROM CMV_Mod_Comment
        WHERE author = target_author;
        DELETE FROM CMV_Moderator
        WHERE mod_name = target_author;
        DELETE FROM CMV_Sub_Author
        WHERE user_name = target_author;
        DELETE FROM CMV_Submission
        WHERE author = target_author;
        DELETE FROM Redditor_Comment_Encounter
        WHERE redditor1 = target_author
        OR redditor2 = target_author;
        DELETE FROM Redditor_Submission_Encounter
        WHERE redditor1 = target_author
        OR redditor2 = target_author;
        DELETE FROM STD_Comment
        WHERE author = target_author;
        DELETE FROM Submission
        WHERE author = target_author;
    END |
DELIMITER ;


-- (2) (Database Modification)
-- Thinking ahead towards the web app a little bit, a user might want to "flag"
-- interesting authors. Thus, I add a "flagged" Boolean for CMV_Sub_Author and a stored procedure
-- to easily let a user flag an author.
ALTER TABLE CMV_Sub_Author
ADD flagged BOOLEAN DEFAULT FALSE;

DROP PROCEDURE IF EXISTS FlagAuthor;
DELIMITER |
CREATE PROCEDURE FlagAuthor(
    IN target_author VARCHAR(20))
    BEGIN
        UPDATE CMV_Sub_Author
        SET flagged = TRUE
        WHERE user_name = target_author;
    END |
DELIMITER ;

-- (3)
-- The app user may also want to select CMV_submissions made between certain dates,
-- perhaps they think that certain world events (elections, shootings, etc.)
-- had an effect on the content of the CMV Submissions. Either way we'll use a similar sort of
-- "flagging" system as before but with the date selection criteria complicating things a bit.
ALTER TABLE CMV_Submission
ADD flagged BOOLEAN DEFAULT FALSE;
DROP PROCEDURE IF EXISTS SelectSubmissionBetween;
DELIMITER |
CREATE PROCEDURE SelectSubmissionBetween(
    IN start_date DATE,
    IN end_date DATE)
    BEGIN
        UPDATE CMV_Submission
        SET flagged = TRUE
        WHERE from_unixtime(date_utc) <= end_date
        AND from_unixtime(date_utc) >= start_date;
    END |
DELIMITER ;


-- (4)
-- The app user might want to select certain CMV_Submissions containing a
-- certain wordmysql s
DROP PROCEDURE IF EXISTS SearchCMVWord;
DELIMITER |
CREATE PROCEDURE SearchCMVWord(
    IN word VARCHAR(255))
    BEGIN
        SET @search = CONCAT('%', word, '%');
        UPDATE CMV_Submission
        SET flagged = TRUE
        WHERE content LIKE @search
        OR title LIKE @search;
    END |
DELIMITER ;


-- (5)
-- On a similar note, the user might want to flag authors
-- that has used a word in a cmv_submission AND one of their old
-- submissions or comments
DROP PROCEDURE IF EXISTS SearchCMVAuthWord;
DELIMITER |
CREATE PROCEDURE SearchCMVAuthWord(
    IN word VARCHAR(255))
    BEGIN
        SET @search = CONCAT('%', word, '%');
        UPDATE CMV_Sub_Author
        SET flagged = TRUE
        WHERE user_name IN (
            SELECT cmvs.author
            FROM CMV_Submission cmvs, STD_Comment stdc, Submission sub
            WHERE (cmvs.content LIKE @search OR cmvs.title LIKE @search)
            AND (stdc.content LIKE @search OR sub.title LIKE @search OR sub.content LIKE @search));
    END |
DELIMITER ;



