SELECT name,type_desc,is_disabled, create_date
FROM master.sys.server_principals
WHERE IS_SRVROLEMEMBER ('sysadmin',name) = 1
ORDER BY name