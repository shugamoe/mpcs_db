-- Alter column
-- For the table CMV_Sub_Author, let's rename comments and submissions
-- std_comments, std_submissions to have some consistency between
-- this table's attributes and the name of the STD_Comment table
ALTER TABLE CMV_Sub_Author
CHANGE comments std_comments int(11);


ALTER TABLE CMV_Sub_Author
CHANGE submissions std_submissions int(11);


-- Add column
-- Will add a column to indicate the number of unique subreddits
-- the user has posted or commented in (default 1 since they have submitted a
    -- view to changemyview)
ALTER TABLE CMV_Sub_Author
ADD unique_subreddit_particip int(4) DEFAULT 0;


-- Drop column
-- For the mod comment we aren't too interested in the subreddit because
-- we know it already (it's changemyview)
ALTER TABLE CMV_Mod_Comment
DROP subreddit;
