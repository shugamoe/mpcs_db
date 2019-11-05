-- Views for assignment 5
-- Develop and test at least 3 views


-- View which filters CMV_Sub_Author down to those who did not award a delta,
DROP VIEW IF EXISTS cmv_auth_gave_delta;
DROP VIEW IF EXISTS cmv_auth_no_delta;
CREATE VIEW cmv_auth_no_delta AS
SELECT *
FROM CMV_Sub_Author
WHERE deltas_awarded = 0;


-- View which filters CMV_Sub_Authors to keep only those that have submission history
-- before their first CMV Submission
DROP VIEW IF EXISTS cmv_auth_whistory;
CREATE VIEW cmv_auth_whistory AS
SELECT * FROM
CMV_Sub_Author
WHERE user_name IN
    (SELECT DISTINCT Submission.author
        FROM Submission,
            (SELECT MIN(date_utc) date_utc, author
                FROM CMV_Submission
                GROUP BY CMV_Submission.author) as first_cmv_subs
        WHERE Submission.date_utc < first_cmv_subs.date_utc);

-- View which selects only those CMV_Sub_Author who have participated in each
-- their CMV_Submissions at least once
DROP VIEW IF EXISTS cmv_auth_responsive;
CREATE VIEW cmv_auth_responsive AS
SELECT * FROM
CMV_Sub_Author
WHERE user_name IN
    (SELECT author
        FROM CMV_Submission
        GROUP BY author
        HAVING AVG(author_comments) > 0);

-- EXTRA
-- View which selects only those CMV_Sub_Author who have not participated in their
-- CMV_Submissions
DROP VIEW IF EXISTS cmv_auth_less_responsive;
CREATE VIEW cmv_auth_less_responsive AS
SELECT * FROM
CMV_Sub_Author
WHERE user_name IN
    (SELECT author
        FROM CMV_Submission
        GROUP BY author
        HAVING AVG(author_comments) = 0);

