CREATE TABLE #t1 (
ID INT IDENTITY(1,1) NOT NULL,
TableName nvarchar(255),
SchemaName nvarchar(255)
)

CREATE TABLE #t2 (
TableName nvarchar(255),
SchemaName nvarchar(255)
)

INSERT INTO #t1 (TableName,SchemaName)
SELECT O.name,SC.name
FROM sys.all_objects O
INNER JOIN sys.schemas SC ON SC.schema_id = O.schema_id

DECLARE @Counter INT
SET @Counter = 1

DECLARE @MaxID int
Set @MaxID = (SELECT MAX(ID) FROM #t1)

WHILE @Counter <= @MaxID

BEGIN

INSERT INTO #t2 (TableName,SchemaName)
SELECT TableName,SchemaName FROM #t1
WHERE TableName LIKE '%[' + CHAR(27)+ '-' +CHAR(31)+']%' COLLATE Latin1_General_100_BIN2 AND ID = @Counter

SET @Counter = @Counter + 1

END

SELECT * FROM #t2

DROP TABLE #t1,#t2