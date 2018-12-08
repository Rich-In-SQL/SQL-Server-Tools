CREATE PROCEDURE p_Database_Register

AS

DECLARE 
@ProductVersion nvarchar(128),
@ProductVersionMajor nvarchar(128),
@ProductVersionMinor nvarchar(128),
@Port varchar(10)

SET @ProductVersion = CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128));

SELECT 
@ProductVersionMajor = SUBSTRING(@ProductVersion, 1,CHARINDEX('.', @ProductVersion) + 1 ),
@ProductVersionMinor = PARSENAME(CONVERT(varchar(32), @ProductVersion), 2);

SET @Port = (SELECT TOP 1 local_tcp_port FROM SYS.DM_EXEC_CONNECTIONS Con WHERE session_id = @@SPID AND local_tcp_port IS NOT NULL);


CREATE TABLE #DBInfo (
	[Id] INT IDENTITY(1,1),
	[ParentObject] VARCHAR(255),
	[Object] VARCHAR(255),
	[Field] VARCHAR(255),
	[Value] VARCHAR(255)
)

CREATE TABLE #CheckDB(
	[DatabaseName] VARCHAR(255),
	[LastDBCCCHeckDB_RunDate] VARCHAR(255)
)

EXECUTE SP_MSFOREACHDB'INSERT INTO #DBInfo Execute (''DBCC DBINFO ( ''''?'''') WITH TABLERESULTS'');
INSERT INTO #CheckDB (DatabaseName) SELECT [Value] FROM #DBInfo WHERE Field IN (''dbi_dbname'');
UPDATE #CheckDB SET LastDBCCCHeckDB_RunDate=(SELECT TOP 1 [Value] FROM #DBInfo WHERE Field IN (''dbi_dbccLastKnownGood'')) where LastDBCCCHeckDB_RunDate is NULL;
TRUNCATE TABLE #DBInfo';

--Availability groups were only introduced in 2012 
IF @ProductVersionMajor >= '11.0'

BEGIN

	SELECT 
	@@SERVERNAME as ServerName,
	CASE WHEN @@servicename = 'MSSQLSERVER'  THEN 'INSTANCE,' + CAST(@Port as varchar) ELSE @@SERVICENAME + ',' + CAST(@Port as varchar) END AS 'InstanceName',
	d.name as DatabaseName,
	mf.physical_name,
	CASE WHEN mf.type_desc = 'ROWS' THEN 'Database File' WHEN mf.type_desc = 'LOG' THEN 'Log File' END AS [FilePath],
	d.compatibility_level,
	CASE WHEN d.is_read_only = 1 THEN 'Read Only' ELSE 'Read/Write' END AS [Mode],
	d.recovery_model_desc as 'RecoveryModel',
	CASE WHEN mf.is_percent_growth = 1 THEN 'Yes' ELSE 'No' END AS 'Percentage_Growth',
	@ProductVersion as ProductVersion,
	SSV.MajorVersionName,
	SSV.MinorVersionName,
	SSV.Branch,
	cdb.LastDBCCCHeckDB_RunDate as Last_Check_DB,
	CASE WHEN d.is_auto_shrink_on = 1 THEN 'Enabled' ELSE 'Disabled' END as AutoShrink,
	CASE WHEN drs.synchronization_state_desc IS NOT NULL THEN 'Yes' ELSE 'No' END AS [Replicated]

	FROM sys.databases d

	INNER JOIN sys.master_files mf ON
	mf.database_id = d.database_id

	INNER JOIN sys.dm_hadr_database_replica_states drs ON drs.database_id = d.database_id AND is_local = 1

	INNER JOIN #CheckDB CDB ON CDB.DatabaseName = d.name

	LEFT JOIN [Utility].[dbo].[SqlServerVersions] SSV ON SSV.MinorVersionNumber = @ProductVersionMinor

	WHERE d.database_id > 4

END

ELSE

BEGIN

	SELECT 
	@@SERVERNAME as ServerName,
	CASE WHEN @@servicename = 'MSSQLSERVER'  THEN 'INSTANCE,' + CAST(@Port as varchar) ELSE @@SERVICENAME + ',' + CAST(@Port as varchar) END AS 'InstanceName',
	d.name as DatabaseName,
	mf.physical_name,
	CASE WHEN mf.type_desc = 'ROWS' THEN 'Database File' WHEN mf.type_desc = 'LOG' THEN 'Log File' END AS [FilePath],
	d.compatibility_level,
	CASE WHEN d.is_read_only = 1 THEN 'Read Only' ELSE 'Read/Write' END AS [Mode],
	d.recovery_model_desc as 'RecoveryModel',
	CASE WHEN mf.is_percent_growth = 1 THEN 'Yes' ELSE 'No' END AS 'Percentage_Growth',
	@ProductVersion as ProductVersion,
	SSV.MajorVersionName,
	SSV.MinorVersionName,
	SSV.Branch,
	cdb.LastDBCCCHeckDB_RunDate as Last_Check_DB,
	CASE WHEN d.is_auto_shrink_on = 1 THEN 'Enabled' ELSE 'Disabled' END as AutoShrink,
	'Availability Not Supported' AS synchronization_state_desc

	FROM sys.databases d

	INNER JOIN sys.master_files mf ON
	mf.database_id = d.database_id

	INNER JOIN #CheckDB CDB ON CDB.DatabaseName = d.name

	LEFT JOIN [Utility].[dbo].[SqlServerVersions] SSV ON SSV.MinorVersionNumber = @ProductVersionMinor

	WHERE d.database_id > 4

END;

WITH BackupSched (JobName,Occurance, ScheduleType, Frequency, Enabled)

AS 

(

SELECT AJI.JobName,AJSI.Occurrence,AJSI.ScheduleType,AJSI.Frequency,AJI.[IsEnabled]      
  FROM [Utility].[DBA].[vw_Agent_Job_Information] AJI
  INNER JOIN [Utility].[DBA].[vw_Agent_Job_Sched_Info] AJSI ON AJSI.ScheduleID = AJI.JobScheduleID
  WHERE JobStartStepName LIKE '%Full' OR JobStartStepName LIKE '%Log'

)

SELECT * FROM BackupSched

DROP TABLE #DBInfo
DROP TABLE #CheckDB