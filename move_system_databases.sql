SELECT name, physical_name
FROM sys.master_files
WHERE database_id = DB_ID(N'model');
GO

USE master; --do this all from the master
ALTER DATABASE [msdb]
MODIFY FILE 
(
	name='MSDBData',
    filename='S:\MSDBData.mdf'
); --Filename is new location


USE master; --do this all from the master
ALTER DATABASE [msdb]
MODIFY FILE 
(
	name='MSDBLog',
    filename='S:\MSDBLog.ldf'
); --Filename is new location


/*** MOVE MODEL **/

SELECT name, physical_name
FROM sys.master_files
WHERE database_id = DB_ID(N'model');
GO

USE master; --do this all from the master
ALTER DATABASE [model]
MODIFY FILE 
(
	name='modeldev',
    filename='S:\model.mdf'
); --Filename is new location


USE master; --do this all from the master
ALTER DATABASE [model]
MODIFY FILE 
(
	name='modellog',
    filename='S:\modellog.ldf'
); --Filename is new location