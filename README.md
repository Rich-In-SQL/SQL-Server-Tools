SQL Server Tools
-----------------

This is a collection of Microsoft SQL Server Scripts that I use on a daily basis when managing SQL Server, I have added them to this repo to track the changes and to make the code available to other developers and database administrators who may need a soloution for some of the functions they provide. 

### Availability Group Checkup ###

### Backup Compression Default ###

The T-SQL Syntax for setting backups to be compressed by default

### Change Default File Locations ###

The T-SQL Syntax for changing the default file locations of the MDF and LDF files when a database is created

This will require a reboot of the SQL Server Engine to take effect

### Clarion Date ###

From time to time I will come across an application that uses Clarion date to store date related timestamps, this T-SQL will convert that clarion value into a SQL Date Time value.

### Database Mail Running Check ###

This script first came about when the database mail service on one of the instances I manage kept stopping, it will check if the Database Mail service is running, if not it will start it. 

I have this setup as a daily SQL Agent Job but it can be ran manually. 

### Move Database Files ###

### Move System Databases ###

### Move tempdb files ###

If you want to move the tempdb MDF & LDF files, this T-SQL script will help you do that.

### SQL Server Date Functions ###

Manipulating SQL Server dates is the one thing I find myself heading to google for the most, this is a collection of date manipulation examples.

This script is supported by a [blog post](https://www.codenameowl.com/dates/)
