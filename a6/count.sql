SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.TABLES
WHERE table_name IN ('CMV_Comment', 'CMV_Commentor', 'CMV_Mod_Comment', 'CMV_Moderator', 'CMV_Sub_Author', 'CMV_Submission', 'Redditor_Comment_Encounter', 'Redditor_Submission_Encounter', 'STD_Comment', 'Submission');
