/******* BACKUP DATABASE *********/

BACKUP DATABASE [Test] 
TO DISK = N'C:\' 
WITH COPY_ONLY, 
NOFORMAT, 
NOINIT,  
NAME = N'Backup Set name', 
SKIP, 
NOREWIND, 
NOUNLOAD,  
STATS = 5


/******* RESTORE DATABASE *********/

USE [master]
RESTORE DATABASE [Test] 
FROM DISK = N'C:\' WITH FILE = 1,  
MOVE N'DatabaseName' TO N'Q:\Test.mdf',  
MOVE N'DatabaseName_log' TO N'N:\Test_1.ldf',  
NOUNLOAD,  
STATS = 5
