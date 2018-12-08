SELECT @@VERSION,@@SERVERNAME,d.name as [DB_Name],d.compatibility_level,mf.name, physical_name AS current_file_location

FROM sys.master_files mf
inner join sys.databases d ON d.database_id = mf.database_id
where d.name NOT IN ('master','tempdb','model','msdb')