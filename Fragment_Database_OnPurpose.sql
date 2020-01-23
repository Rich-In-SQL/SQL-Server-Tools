CREATE DATABASE FragMe;
GO

USE FragMe;
GO

-- Create the 10MB filler table at the 'front' of the data file
CREATE TABLE [FillerTable] (
    [c1] INT IDENTITY,
    [c2] CHAR (8000) DEFAULT 'filler');
GO

-- Fill up the filler table
INSERT INTO [FillerTable] DEFAULT VALUES;
GO 1280

-- Create the production table, which will be 'after' the filler table in the data file
CREATE TABLE [ProdTable] (
    [c1] INT IDENTITY,
    [c2] CHAR (8000) DEFAULT 'production');
CREATE CLUSTERED INDEX [prod_cl] ON [ProdTable] ([c1]);
GO

INSERT INTO [ProdTable] DEFAULT VALUES;
GO 6222345

-- Check the fragmentation of the production table
SELECT
    [avg_fragmentation_in_percent]
FROM sys.dm_db_index_physical_stats (
    DB_ID (N'FragMe'), OBJECT_ID (N'ProdTable'), 1, NULL, 'LIMITED');
GO

-- Drop the filler table, creating 10MB of free space at the 'front' of the data file
DROP TABLE [FillerTable];
GO

-- Shrink the database
DBCC SHRINKDATABASE (FragMe);
GO

-- Check the index fragmentation again
SELECT
    [avg_fragmentation_in_percent]
FROM sys.dm_db_index_physical_stats (
    DB_ID (N'FragMe'), OBJECT_ID (N'ProdTable'), 1, NULL, 'LIMITED');
GO

ALTER INDEX [prod_cl] ON [dbo].[ProdTable] reorganize