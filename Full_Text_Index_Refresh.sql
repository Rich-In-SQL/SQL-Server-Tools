EXEC sp_fulltext_recycle_crawl_log @ftcat = 'FullTextLog1'
EXEC sp_fulltext_recycle_crawl_log @ftcat = 'FullTextLog2'

SELECT * FROM sys.fulltext_catalogs

USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', REG_SZ, N'C:\Backups'
GO