SELECT CASE WHEN COUNT(distinct DocumentID) = COUNT(DocumentID)
THEN 'column values are unique' ELSE 'column values are NOT unique' END
FROM DatabaseName.Schema.Table;



SELECT (CASE WHEN COUNT(DISTINCT DocumentID) = COUNT(DocumentID) and
                  (COUNT(DocumentID) = COUNT(*) or COUNT(DocumentID) = COUNT(*) - 1)
             THEN 'All Unique'
             ELSE 'Duplicates'
        END)
FROM DatabaseName.Schema.Table t;