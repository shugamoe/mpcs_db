-- (1)
-- Trigger that enforces an attribute constraint
-- When inserting a new cmv_commentor, ensure that cmv_comments >= cmv_subs_commented_on
DROP TRIGGER IF EXISTS CMV_Commentor_Comments_geq_Sub_Trigger;
DELIMITER |
CREATE TRIGGER CMV_Commentor_Comments_geq_Sub_Trigger
BEFORE INSERT ON CMV_Commentor
FOR EACH ROW
BEGIN
    IF (NEW.cmv_comments < NEW.cmv_subs_commented_on) THEN
        SIGNAL SQLSTATE '23000' SET MESSAGE_TEXT = "More subs commented on then comments, impossible!";
    END IF;
END; |
DELIMITER ;

-- (2)
-- Trigger that logs table changes in a log table
-- First let's create our log table this table will tell us at what time we
-- inserted a CMV_Submission into the CMV_Submission Table, but only if
-- the submission was "edited".
DROP TABLE IF EXISTS CMV_Submission_Edited_Log;
CREATE TABLE CMV_Submission_Edited_Log (
    reddit_id VARCHAR(7),
    insert_date_utc INT(11),
    PRIMARY KEY (reddit_id, insert_date_utc) -- We'll make this redundant in trigger (3)
);

DROP TRIGGER IF EXISTS CMV_Submission_Edited_Trigger;
DELIMITER |
CREATE TRIGGER CMV_Submission_Edited_Trigger
BEFORE INSERT ON CMV_Submission
FOR EACH ROW
BEGIN
    IF NEW.edited IS TRUE THEN
        SET @cur_time = UNIX_TIMESTAMP(CURTIME());
        INSERT INTO CMV_Submission_Edited_Log
        VALUES(NEW.reddit_id, @cur_time);
    END IF;
END; |
DELIMITER ;

-- (3)
-- Let's have this trigger be on the CMV_Submission_Edited_Log. Maybe we only
-- want to track the latest time we have inserted that submission.
DROP TRIGGER IF EXISTS CMV_Submission_Edited_Update;
DELIMITER |
CREATE TRIGGER CMV_Submission_Edited_Update
AFTER INSERT ON CMV_Submission
FOR EACH ROW
BEGIN
    IF NEW.edited IS TRUE THEN
        SET @cur_time = UNIX_TIMESTAMP(CURTIME());
        DELETE FROM CMV_Submission_Edited_Log
        WHERE (reddit_id = NEW.reddit_id)
        AND (insert_date_utc < @cur_time);
    END IF;
END; |
DELIMITER ;
