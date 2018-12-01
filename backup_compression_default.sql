EXEC sp_configure 'backup compression default', 1 ;  
RECONFIGURE WITH OVERRIDE ;  
GO

SELECT value   
FROM sys.configurations   
WHERE name = 'backup compression default' ;  
GO  