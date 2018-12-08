SELECT @@SERVERNAME,(SELECT ars.role_desc
							FROM 
								sys.dm_hadr_availability_replica_states AS ars INNER JOIN
								sys.availability_groups AS ag ON ars.group_id = ag.group_id
							WHERE ag.name = '' and  ars.is_local = 1)

SELECT Total,name FROM 
(
SELECT COUNT(h.job_ID) as Total,j.name 

FROM msdb..sysjobhistory h

INNER JOIN msdb..sysjobs j ON
	h.job_id = j.job_id

GROUP BY j.name

) x
ORDER BY Total DESC