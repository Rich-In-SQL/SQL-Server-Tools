CREATE PROCEDURE RestoreDB 

@FileName nvarchar(MAX),
@DatabaseName nvarchar(255) 

AS 

BEGIN

DECLARE 
    @RestoreSQL Nvarchar(MAX),
    @DefaultData nvarchar(max),
    @DefaultLog nvarchar(max),
    @DataLogicalName nvarchar(128),
    @LogLogicalName nvarchar(128) --https://stackoverflow.com/questions/2511502/sql-server-restore-filelistonly-resultset#4018782

DECLARE @fileListTable TABLE (
        [ID] INT IDENTITY(1, 1),
        [LogicalName] NVARCHAR(128),
        [PhysicalName] NVARCHAR(260),
        [Type] CHAR(1),
        [FileGroupName] NVARCHAR(128),
        [Size] NUMERIC(20, 0),
        [MaxSize] NUMERIC(20, 0),
        [FileID] BIGINT,
        [CreateLSN] NUMERIC(25, 0),
        [DropLSN] NUMERIC(25, 0),
        [UniqueID] UNIQUEIDENTIFIER,
        [ReadOnlyLSN] NUMERIC(25, 0),
        [ReadWriteLSN] NUMERIC(25, 0),
        [BackupSizeInBytes] BIGINT,
        [SourceBlockSize] INT,
        [FileGroupID] INT,
        [LogGroupGUID] UNIQUEIDENTIFIER,
        [DifferentialBaseLSN] NUMERIC(25, 0),
        [DifferentialBaseGUID] UNIQUEIDENTIFIER,
        [IsReadOnly] BIT,
        [IsPresent] BIT,
        [TDEThumbprint] VARBINARY(32),
        -- remove this column if using SQL 2005
        [SnapshotURL] NVARCHAR(360)
    )

INSERT INTO @fileListTable EXEC(
        'RESTORE FILELISTONLY FROM DISK =''' + @FileName + ''''
    )

SET @DataLogicalName = (
        SELECT LogicalName
        FROM @fileListTable
        WHERE Type = 'D'
    )

SET @LogLogicalName = (
        SELECT LogicalName
        FROM @fileListTable
        WHERE Type = 'L'
    )

SET @DefaultData = (
        SELECT CAST(
                SERVERPROPERTY('InstanceDefaultDataPath') as nvarchar(MAX)
            )
    )

SET @DefaultLog = (
        SELECT CAST(
                SERVERPROPERTY('InstanceDefaultLogPath') as nvarchar(MAX)
            )
    )

SET @RestoreSQL = 'RESTORE DATABASE ' + QUOTENAME(@DatabaseName) + ' FROM  DISK =''' + @FileName + ''' WITH  FILE = 1,' + 'MOVE ' + '''' + @DataLogicalName + '''' + ' TO ''' + @DefaultData + @DatabaseName + '.mdf'',' + 'MOVE ' + '''' + @LogLogicalName + '''' + ' TO ''' + @DefaultLog + @DatabaseName + '_log.ldf'',' + 'NOUNLOAD' --Uncomment for testing
    --SELECT @RestoreSQL
    EXEC (@RestoreSQL)

END 
IF EXISTS(
    SELECT name
    FROM sys.databases
    WHERE name = @DatabaseName
) 

BEGIN
    SELECT 'Database ' + QUOTENAME(@DatabaseName) + ' restored sucessfully'
END
ELSE 
BEGIN
    SELECT 'Database ' + QUOTENAME(@DatabaseName) + ' didn''t restore'
END