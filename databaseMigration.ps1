#############
### SETUP ###
#############

#Username of someone whom has access to both the source and destination, prerably system admin level permissions.
$User = "user"

#Store the credentials for the life of the session so we don't have to re-type them for every command that is run.
$Credentials = Get-Credential $User -Message "Please enter your password!"

#This is used to store backups used by Copy-DbaDatabase, backups here are deleted automatically once the move is completed.
$NetworkShare = "\\shared\location\Migration"

#This is the location used when adding the database to the availability group
$SharedLocation = "\\shared\location"

#Where you want to move from, it doesnt matter if this is the primary or the secondary, the script will figure it out. 
$Source = "S-SQL01"

#The name of the availability group you are moving from
$SourceAG = "SQLTEST"

#Would you like to set the source databases to offline after they are copied?
$SourceDbOffline = 1

#Where you are moving to, it doesnt matter if this is the primary or the secondary, the script will figure it out. 
$Destination = "S-SQL03"

#The name of the availability group you are moving to
$DestinationAG = "SQLTEST"

#Do we want to run this script in test mode? $true or $false 
$WhatIfPreference = $true

#Logfile settings
$logroot = "C:\"
$logfolder = "migration"
$logfilename = "migration.txt"
$logdir = $logroot + $logfolder

###################
### DONT CHANGE ###
###################

Function Write-Log
{
    [CmdletBinding()]

    Param
    (
    [Parameter(Mandatory=$True)]
    [string]
    $logstring,

    [Parameter(Mandatory=$True)]
    [string]
    $logdir,

    [Parameter(Mandatory=$True)]
    [string]
    $filename

    )
    
    if(!(Test-Path -Path $logdir))
    {
        New-Item -ItemType Directory -Path $logdir -Force
    }   
        
    $fullpath = $logdir + "\" + $logfilename   
    Add-Content $fullpath -Value $logstring
} 

#Give me the primary member of the availability group $SourceAG where we want to get the databases and objects from
$PrimarySrc = Get-DbaAvailabilityGroup -SqlInstance $Source -AvailabilityGroup $SourceAG -SqlCredential $Credentials | Select-Object -ExpandProperty PrimaryReplicaServerName

#Give me the primary member of the availability group $DestinationAG where we want to restore the databases and objects to
$PrimaryDst = Get-DbaAvailabilityGroup -SqlInstance $Destination -AvailabilityGroup $DestinationAG -SqlCredential $Credentials | Select-Object -ExpandProperty PrimaryReplicaServerName

#The names of all the databases, excluding system databases and also excluding any that are not accessible
$Databases = Get-DbaDatabase -SqlInstance $PrimarySrc -SqlCredential $Credentials -ExcludeSystem -OnlyAccessible | Select-Object -ExpandProperty name

#The names of all the linked servers on the source
$LinkedServers = Get-DbaLinkedServer -SqlInstance $PrimarySrc -SqlCredential $Credentials | Select-Object -ExpandProperty name

#The names of all the logings on the source excluding any that are system logins and any in the exclusion filter
$Logins = Get-DbaLogin $PrimarySrc -SqlCredential $Credentials -ExcludeSystemLogin -ExcludeFilter '##*','NT *'  | Select-Object -ExpandProperty name

#The name of all the SQL Agent Jobs, disabled jobs are excluded as are any jobs listed in the Exclusion flag
$AgentJobs = Get-DbaAgentJob -SqlInstance $PrimarySrc -SqlCredential $Credentials -ExcludeDisabledJobs -ExcludeJob "CommandLog Cleanup" | Select-Object -ExpandProperty name 

#WIP - Working on getting the secondary automatically
$DstSecondarySrvrs =  Get-DbaAgReplica -SqlInstance $PrimaryDst -SqlCredential $Credentials | Where-Object Role -eq "Secondary" | Select-Object -ExpandProperty name 

################
### THE WORK ###
################

#Time Stamp the beginning
Write-Host (Get-Date -Format "dd-MM-yyyy HH:mm:ss") "Migration from" $PrimarySrc "to" $PrimaryDst "has started" -ForegroundColor Yellow 

foreach ($Database in $Databases)
{
    try 
    {   
        Write-Host (Get-Date -Format HH:mm:ss) "Copying database" $Database "from" $PrimarySrc "to" $PrimaryDst -ForegroundColor Grey        

        #Copy each database from the source to the destination using Backup & Restore which will take a COPYONLY backup and place it in the specified $NetworkShare, this command is forced, if the object already exists it will be overwritte - The database engine on both the source and destination will need access to the $NetworkShare to prevent this failing       
        Copy-DbaDatabase -Source $PrimarySrc -Destination $PrimaryDst -Database $Database -SourceSqlCredential $Credentials -DestinationSqlCredential $Credentials -BackupRestore -NetworkShare $NetworkShare -Force 
        
        #If the user has selected to set source databases to offline after the copy is complete
        if($SourceDbOffline -eq 1)
        {
            try {

                Write-Host (Get-Date -Format HH:mm:ss) "Setting database" $Database "on" $PrimarySrc "to offline" -ForegroundColor Grey

                #Set the database on the source to offline, this is a forced command, any active connections will be dropped.            
                Set-DbaDbState -SqlInstance $PrimarySrc -Database $Database -SqlCredential $Credentials -Offline -Force
                
            }
            catch {

                Write-Host (Get-Date -Format HH:mm:ss) "Database" $Database "on" $PrimarySrc " was not set to offline" -ForegroundColor Red
                Write-Log -logstring "Database $Database on $PrimarySrc was not set to offline" -logdir $logdir -filename $logfilename
                
            }             
        }

        Write-Host (Get-Date -Format HH:mm:ss) "Database" $Database "has been added to" $PrimaryDst -ForegroundColor Green        

    } catch 
    {
        Write-Host (Get-Date -Format HH:mm:ss) "Database" $Database "has not been added to" $PrimaryDst -ForegroundColor Red
        Write-Log -logstring "Database $Database has not been added to $PrimaryDst" -logdir $logdir -filename $logfilename
    }

    Remove-Variable -Name Database
}

foreach ($Login in $Logins)
{
    try 
    {
        Write-Host (Get-Date -Format HH:mm:ss) "Copying SQL login" $Login "from" $PrimarySrc "to" $PrimaryDst -ForegroundColor Grey
        
        #Copy logins from the source to the destination primary nodes, this is a forced command, if the login already exists it will be dropped and re-created. SIDS are carried.         
        Copy-DbaLogin -Source $PrimarySrc -Destination $PrimaryDst -DestinationSqlCredential $Credentials -SourceSqlCredential $Credentials -Login $Login -Force 
        
        Write-Host (Get-Date -Format HH:mm:ss) "SQL Login" $Login "has been added to" $PrimaryDst -ForegroundColor Green
        
    } catch 
    {
        Write-Host (Get-Date -Format HH:mm:ss) "SQL Login" $Login "has not been added to" $PrimaryDst -ForegroundColor Red
        Write-Log -logstring "SQL Login $Login has not been added to $PrimaryDst" -logdir $logdir -filename $logfilename
    }

    #Here we need to add logins on all the secondary replicas 
    foreach ($DstSecondarySrvr in $DstSecondarySrvrs)
    {
        try 
        {
            Write-Host (Get-Date -Format HH:mm:ss) "Copying SQL login" $Login "from" $PrimaryDst "to" $DstSecondarySrvr -ForegroundColor Grey            

            #Copy all logins from the destination to the secondary destination member, this is a forced command, if the login already exists it will be dropped and re-created. SIDS are carried. 
            Copy-DbaLogin -Source $PrimaryDst -Destination $DstSecondarySrvr -SourceSqlCredential $Credentials -DestinationSqlCredential $Credentials -Login $Login -Force 
            
            Write-Host (Get-Date -Format HH:mm:ss) "SQL Login" $Login "has been added to" $DstSecondarySrvr -ForegroundColor Green 

        } catch 
        {
            Write-Host (Get-Date -Format HH:mm:ss) "SQL Login" $Login "has not been added to" $DstSecondarySrvr -ForegroundColor Red 
            Write-Log -logstring "SQL Login $Login has not been added to $DstSecondarySrvr" -logdir $logdir -filename $logfilename
        }
    }

    Remove-Variable -Name login
    Remove-Variable -Name DstSecondarySrvr
}

foreach($Database in $Databases)
{
    #Check if $Database already exists on the destination node this will exclude system databases and will only check if the database is accessible. 
    $DatabaseInExistance = Get-Dbadatabase -SqlInstance $PrimaryDst -SqlCredential $Credentials -ExcludeSystem -OnlyAccessible -database $Database | Select-Object -ExpandProperty name

    #If the database exists on the destination primary we can start
    #Reason: If the value passed in $Database does not exist on the $PrimaryDst the add to availability group command will fail so we will just check it and skip if it isn't there.
    if($null -ne $DatabaseInExistance)
    {
        try 
        {
            Write-Host (Get-Date -Format HH:mm:ss) "Adding database" $Database "to" $PrimaryDst "in availability group" $DestinationAG "using" $SharedLocation "for backup" -ForegroundColor Grey

            #Add $Database to the availability group $DestinationAG using the $SharedLocation, this will throw a confirmation for each database in the collection - The database engine on both the source and destination will need access to the $SharedLocation to prevent this command from failing
            Add-DbaAgDatabase -SqlInstance $PrimaryDst -AvailabilityGroup $DestinationAG -Database $Database -SharedPath $SharedLocation -SqlCredential $Credentials -Confirm 
            
            Write-Host (Get-Date -Format HH:mm:ss) "Database" $Database "added to availabiltiy group" $DestinationAG "on" $PrimaryDst -ForegroundColor Green
            
        } catch
        {
            Write-Host (Get-Date -Format HH:mm:ss) "Database" $Database "was not added to availabiltiy group" $DestinationAG -ForegroundColor Red
            Write-Log -logstring "Database $Database was not added to availabiltiy group $DestinationAG" -logdir $logdir -filename $logfilename
        }
        
    } else
    {
        Write-Host (Get-Date -Format HH:mm:ss) "Database" $Database "cant be added to availability group" $DestinationAG "becuase it doesnt exist" -ForegroundColor Red        
    }

    Remove-Variable -Name Database
}

foreach ($LinkedServer in $LinkedServers)
{
    try 
    {   
        Write-Host (Get-Date -Format HH:mm:ss) "Adding linked server" $LinkedServer "to" $PrimaryDst "from" $PrimarySrc -ForegroundColor Grey

        #Add the linked server in $LinkedServer to the $PrimaryDst, this is a forced command, if the linked server already exists it will be dropped and re-created, also the user will be prompted for each item in the collection
        Copy-DbaLinkedServer -Source $PrimarySrc -Destination $PrimaryDst -SourceSqlCredential $Credentials -DestinationSqlCredential $Credentials -LinkedServer $LinkedServer -Force -Confirm 
        
        Write-Host (Get-Date -Format HH:mm:ss) "Linked Server" $LinkedServer "has been added to" $PrimaryDst -ForegroundColor Green 
       

    } catch
    {
        Write-Host (Get-Date -Format HH:mm:ss) "Linked Server" $LinkedServer "has not been added to" $PrimaryDst -ForegroundColor Red
        Write-Log -logstring "Linked Server $LinkedServer has not been added to $PrimaryDst" -logdir $logdir -filename $logfilename
    }
    
    Remove-Variable -Name LinkedServer
}

foreach ($AgentJob in $AgentJobs)
{
    try 
    { 
        Write-Host (Get-Date -Format HH:mm:ss) "Adding SQL Agent Job" $AgentJob "to" $PrimaryDst "from" $PrimarySrc -ForegroundColor Grey
        
        
        #Add the agent job in $AgentJob to the $PrimaryDst, this is a forced command, if the linked server already exists it will be dropped and re-created
        Copy-DbaAgentJob -Source $PrimarySrc -Destination $PrimaryDst -SourceSqlCredential $Credentials -DestinationSqlCredential $Credentials -Job $AgentJob -Force         

        Write-Host (Get-Date -Format HH:mm:ss) "SQL Agent Job" $AgentJob "has been added to" $PrimaryDst -ForegroundColor Green
        

    } catch
    {
        Write-Host (Get-Date -Format HH:mm:ss) "SQL Agent Job" $AgentJob "has not been added to" $PrimaryDst -ForegroundColor Red
        Write-Log -logstring "SQL Agent Job $AgentJob has not been added to $PrimaryDst" -logdir $logdir -filename $logfilename
    }

    Remove-Variable -Name AgentJob
}

#Here we need to bring any secondary replicas that are members of the target availability group in line with the primary
foreach ($DstSecondarySrvr in $DstSecondarySrvrs)
{

    Write-Host (Get-Date -Format HH:mm:ss) "Bringing" $DstSecondarySrvr "up to date with" $PrimaryDst -ForegroundColor Yellow

    foreach ($AgentJob in $AgentJobs)
    {
        try 
        {  
            Write-Host (Get-Date -Format HH:mm:ss) "Adding SQL Agent Job" $AgentJob "to" $DstSecondarySrvr "from" $PrimarySrc -ForegroundColor Grey

            #Add the agent job in $AgentJob to the $DstSecondarySrvr, this is a forced command, if the linked server already exists it will be dropped and re-created
            Copy-DbaAgentJob -Source $PrimarySrc -Destination $DstSecondarySrvr -SourceSqlCredential $Credentials -DestinationSqlCredential $Credentials  -Job $AgentJob -Force 
            
            #Disable the SQL Agent Job now that we are done with it
            Set-DbaAgentJob -SqlInstance $PrimarySrc -SqlCredential $Credentials -Job $AgentJob -Disabled -Force 

            Write-Host (Get-Date -Format HH:mm:ss) "SQL Agent Job" $AgentJob "has been added to" $DstSecondarySrvr -ForegroundColor Green

        } catch 
        {
            Write-Host (Get-Date -Format HH:mm:ss) "SQL Agent Job" $AgentJob "has not been added to" $DstSecondarySrvr -ForegroundColor Red
            Write-Log -logstring "SQL Agent Job $AgentJob has not been added to $DstSecondarySrvr" -logdir $logdir -filename $logfilename
        }

        Remove-Variable -Name AgentJob
    }

    foreach ($LinkedServer in $LinkedServers)
    {
        try 
        { 
            Write-Host (Get-Date -Format HH:mm:ss) "Adding Linked Server" $LinkedServer "to" $DstSecondarySrvr "from" $PrimarySrc -ForegroundColor Grey
            
            
            #Add the linked server in $LinkedServer to the $DstSecondarySrvr, this is a forced command, if the linked server already exists it will be dropped and re-created, also the user will be prompted for each item in the collection 
            Copy-DbaLinkedServer -Source $PrimarySrc -Destination $DstSecondarySrvr -DestinationSqlCredential $Credentials -SourceSqlCredential $Credentials -LinkedServer $LinkedServer -Force -Confirm 

            Write-Host (Get-Date -Format HH:mm:ss) "Linked Server" $LinkedServer "has been added to" $DstSecondarySrvr -ForegroundColor Green
            

        } catch
        {
            Write-Host (Get-Date -Format HH:mm:ss) "Linked Server" $LinkedServer "has not been added" $PrimaryDst -ForegroundColor Red  
            Write-Log -logstring "Linked Server $LinkedServer has not been added $PrimaryDst" -logdir $logdir -filename $logfilename
        }

        Remove-Variable -Name LinkedServer
    }

    Remove-Variable -Name DstSecondarySrvr
}

#Time Stamp the end of the script operation.
Write-Host (Get-Date -Format "dd-MM-yyyy HH:mm:ss") "Migration from" $PrimarySrc "to" $PrimaryDst "is complete" -ForegroundColor Green