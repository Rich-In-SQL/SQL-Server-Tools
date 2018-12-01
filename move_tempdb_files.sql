--Find the location of the files currently 

SELECT mf.name [File Name], 
       mf.physical_name [Physical Name], 
       d.name AS [Database Name]
FROM sys.master_Files mf
     INNER JOIN sys.databases d ON d.database_id = mf.database_id
WHERE d.name = 'tempdb';

--Move this for all files for the database, mdf, ldf & ndf files

USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='tempdev',
    filename='D:\tempdb.mdf'
); --Filename is new location

USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='temp2',
    filename='D:\tempdb_mssql_2.ndf'
); --Filename is new location

USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='temp3',
    filename='D:\tempdb_mssql_3.ndf'
); --Filename is new location

USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='temp4',
    filename='D:\tempdb_mssql_4.ndf'
); --Filename is new location

USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='temp5',
    filename='D:\tempdb_mssql_5.ndf'
); --Filename is new location

USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='temp6',
    filename='D:\tempdb_mssql_6.ndf'
); --Filename is new location

USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='temp7',
    filename='D:\tempdb_mssql_7.ndf'
); --Filename is new location

USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='temp8',
    filename='D:\tempdb_mssql_8.ndf'
); --Filename is new location


USE master; --do this all from the master
ALTER DATABASE [tempdb]
MODIFY FILE 
(
	name='templog',
    filename='L:\templog_log.ldf'
); --Filename is new location

