DECLARE @ClarionDate INT = 76734
DECLARE @SqlDateTime DATETIME 

-- Convert the clarion DATE into and SQL DateTime
SET @SqlDateTime = DateAdd(day, @ClarionDate  - 4, '1801-01-01') 

SELECT @SqlDateTime AS 'SQL Date Time'

-- Now convert it back from and SQL DateTime to a Clarion Date
SET @ClarionDate = DateDiff(day, DateAdd(day, -4, '1801-01-01'), @SqlDateTime)
SELECT @ClarionDate AS 'Clarion Date'