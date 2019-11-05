-- insert single tuple (2)
-- Insert a dummy tuple into Submission (inserting really won't be used)
INSERT INTO Submission
VALUES('69', '1461110400', 'shugamoe', 'r/GlobalOffensive',
    FALSE, 'How do I get good?', 'I am bad, how to get good?',
    '0', '0', '0', '0', '69427');

INSERT INTO CMV_Mod_Comment
VALUES('69',
    '1461110400',
    '69555',
    'master_mod',
    'r/changemyview',
    FALSE,
    'I am bad, how to get good?',
    '696969',
    '0', '0', '0', '0', '69527');

-- insert subquery (2)
-- All CMV_Mod_Comments are technically Comments, so we put them in here
-- (They aren't "standard" comments though)
INSERT INTO STD_Comment
(SELECT * FROM CMV_Mod_Comment);

-- All CMV_Comments are technically Comments, so we put them in here
-- We make sure to select only the parts of them in common with STD_Comments
-- tho
-- (They aren't "standard" comments though)
INSERT INTO STD_Comment
(SELECT score, date_utc, reddit_id, author, subreddit, edited, content,
    parent_submission_id, replies, author_children, total_children, 
    unique_repliers, parent_comment_id
    FROM CMV_Comment as cmvc
    WHERE cmvc.reddit_id NOT IN (
        SELECT reddit_id
        FROM STD_Comment)
);


-- delete (2)
-- Delete the submission and then the comment I previously inserted
DELETE FROM Submission
WHERE reddit_id = '69427';


DELETE FROM STD_Comment
WHERE reddit_id = '69555';


-- Also delete 'AutoModerator' from CMV_Sub_Author and CMV_Submission,
-- it's a moderation bot, not a person
DELETE FROM CMV_Sub_Author
WHERE user_name = 'AutoModerator';


DELETE FROM CMV_Submission
WHERE author = 'AutoModerator';


-- update (2)

-- Update the CMV_Submissions where deltas_from_author > 0 but author_comments
-- < deltas_from_author. Each delta from author should be considered an
-- author_comment. This should make the data slightly more accurate
-- until I can fix the scraping procedure.
UPDATE CMV_Submission
SET author_comments = author_comments + deltas_from_author
WHERE deltas_from_author > 0
AND author_comments < deltas_from_author;


-- We'll add 1 to the score of comments that have 0 as a score since
-- Reddit has been known to use "data fuzzing" that doesn't give an accurate
-- score for comments
UPDATE STD_Comment
SET score = 1
WHERE score = 0;
