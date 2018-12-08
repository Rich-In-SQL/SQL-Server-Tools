--Create a role that will alow execute to any stored procedure added to the database past or preset. 
--Source: http://www.patrickkeisler.com/2012/10/grant-execute-permission-on-all-stored.html
USE [DatabaseName];
CREATE ROLE db_executor AUTHORIZATION [dbo]; 
GRANT EXECUTE ON SCHEMA::dbo TO db_executor;
--Add the user to the roles so that it can select and things. 
EXEC sp_addrolemember N'db_executor', LoginName;