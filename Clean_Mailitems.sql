USE MSDB;
GO

DECLARE @DeleteBeforeDate DateTime 
SELECT @DeleteBeforeDate = DATEADD(d,-30, GETDATE())
EXEC sysmail_delete_mailitems_sp @sent_before = @DeleteBeforeDate
EXEC sysmail_delete_log_sp @logged_before = @DeleteBeforeDate