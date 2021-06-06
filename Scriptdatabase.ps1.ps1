function Export-DatabaseScripts {
    

    #Defining parameters for Servername, Databasename and path
    [CmdletBinding()]
    param(
            [Parameter(ValueFromPipelineByPropertyName=$true)]
            [string]$ServerName,
            [Parameter(ValueFromPipelineByPropertyName=$true)]
            [string]$DatabaseName,
            [Parameter(ValueFromPipelineByPropertyName=$true)]
            [string]$ObjectName,
            [Parameter(Mandatory=$false)]
            [string]$OutputPath
    )
   
    BEGIN {
        # Set the output path
        if ( $OutputPath -eq '' ) {
                Write-Error "The 'OutputPath' parameter was not specified, and the environment variable 'DatabaseObjectScripts' either does not exist, or contains an invalid path." -ErrorAction Stop
            }
    
        # Load needed assemblies
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMOExtended")| Out-Null;

        #Tracking time
        $StartTime = get-date
    }

    PROCESS {
        
        #Specify target server and databases.
        Write-Host "Connecting to server: " -NoNewline
        $SMOserver = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "$ServerName"
        $SMOServer.ConnectionContext.ConnectTimeout = 2 #Keep it short to fail fast
           
                try {
                    $SMOServer.ConnectionContext.Connect()
                    $LastServer = $ServerName
                } catch {
                    Write-Error "Unable to connect to instance: $($ServerName)" -ErrorAction Stop
                }
           
            Write-Host "Connected" -ForegroundColor Green
  
        #Connecting to database
        $Db = $SMOserver.Databases[$databasename]
       
       
        #Write-Host "Object Type: $($TypeFolder)"
        #Build this portion of the directory structure out here.  Remove the existing directory and its contents first.
        $OutputPath = $Outputpath + "\" + $Servername + "\" + $DatabaseName

        New-Item -Type directory -Path "$outputpath" -Force -ErrorAction SilentlyContinue | Out-Null

        #Create directory structure
        $DatabaseObjects += $db.Tables
        $DatabaseObjects += $db.UserDefinedFunctions
        $DatabaseObjects += $db.UserDefinedTableTypes
        $DatabaseObjects += $db.StoredProcedures
        $DatabaseObjects += $db.Sequences
        $DatabaseObjects += $db.Triggers
        $DatabaseObjects += $db.Constraints
        $DatabaseObjects += $db.Views
        $DatabaseObjects += $db.Triggers
       
        #Schemas to exclude
        $SchemasToExclude = @("sys", "guest", "INFORMATION_SCHEMA")

        Write-Host "Creating Directory structure and scripting schemas"
        $scriptr = new-object ('Microsoft.SqlServer.Management.Smo.Scripter') ($SMOserver)
        foreach ($Schema in $db.Schemas) {
           
            $TypeFolder='Schemas'
            $schemaname = $Schema.Name.Replace("[", "").Replace("]", "")
            write-host 'Looping schemas..' $schemaname  

            IF ($schemastoexclude.Contains($schemaname) -OR $schemaname -MATCH 'db_' -OR $schemaname -MATCH 'GOTOAUCTIONS' -OR $schemaname -MATCH 'NT AUTHORITY')
                {write-host 'skipping system schema' $schemaname}
           
            ELSE
            {

       
                if ((Test-Path -Path "$outputpath\$TypeFolder") -eq "true") {
                    Write-Host "Creating path $outputpath\$TypeFolder $ScriptThis"
                    } else {
                    new-item -type directory -name "$TypeFolder"-path "$outputpath"
                    }

               
                    Write-Host "Creating schema folder $schemaname "

                    if ((Test-Path -Path "$outputpath\$schemaname") -eq "true") {
                        Write-Host "Scripting Out $outputpath\$schemaname $schemaname"
                    } else {
                        new-item -type directory -name "$schemaname"-path "$outputpath"
                    }

                    $scriptr.Options.FileName = $outputpath  + '\' + $TypeFolder + '\' + $Schema.Name.Replace("[", "").Replace("]", "") + ".sql"
               
                    #Scripting schema object
                    If ($schemaname -ne 'dbo'){
                        $scriptr.Script($Schema)
                    }
       
                    Write-Host "Scripting objects in database..."
       
                    foreach ($ScriptThis in $DatabaseObjects | Where-Object { $_.schema -eq $schemaname  -and -not $_.IsSystemObject}) {
                        $scriptr = new-object ('Microsoft.SqlServer.Management.Smo.Scripter') ($SMOserver)
                        $scriptr.Options.AppendToFile = $False
                        $scriptr.Options.ScriptSchema = $True
                        $scriptr.Options.AllowSystemObjects = $False
                        $scriptr.Options.ClusteredIndexes = $True
                        $scriptr.Options.DriAllConstraints = $True
                        $scriptr.Options.ScriptDrops = $False
                        $scriptr.Options.IncludeIfNotExists = $False
                        $scriptr.Options.IncludeHeaders = $False
                        $scriptr.Options.ToFileOnly = $True
                        $scriptr.Options.Indexes = $True
                        $scriptr.Options.Permissions = $False
                        $scriptr.Options.WithDependencies = $False
                        $scriptr.Options.IncludeDatabaseContext = $True
                        $scriptr.Options.Triggers = $True
                        $scriptr.Options.EnforceScriptingOptions = $True
                        $scriptr.options.ExtendedProperties = $true
                        

                        $TypeFolder= $ScriptThis.GetType().Name
                        $ObjectParentFolder = $outputpath + "\" + $schemaname + "\"
                        #write-host "ObjectParentFolder" $ObjectParentFolder
                        $ObjectFolder =  $TypeFolder
                        #write-host "ObjectFolder" $ObjectFolder
                     
                        if ((Test-Path -Path "$ObjectParentFolder\$ObjectFolder") -eq "true") {
                            Write-Host "Scripting Out $ObjectFolder $ScriptThis"
                        } else {
                            new-item -type directory -name "$ObjectFolder"-path "$ObjectParentFolder"
                        }
                   
                   
                        $scriptr.Options.FileName = $ObjectParentFolder + '\' + $ObjectFolder + '\' + $schemaname + "." + $ScriptThis.Name.Replace("[", "").Replace("]", "") + ".sql"
                        write-host $scriptr.options.Filename
                   

                        $Filescripted = $Scriptr.options.Filename
                        $scriptr.Script($ScriptThis)
                       
                        #(Get-Content $Filescripted) -replace '[[\]]', '' | Out-File -FilePath $Filescripted -Encoding ascii
                        $fixscripts = "StoredProcedure", "View", "UserDefinedFunction"
                        
                        IF ($ObjectFolder -IN $fixscripts) {
                           #$R.Replace((Get-Content $Filescripted -Encoding ascii -Raw),"`nCREATE OR ALTER ",1)
                            (Get-Content $Filescripted) -replace '^\s*CREATE\s*PROCEDURE', 'CREATE OR ALTER PROCEDURE' | Out-File -FilePath $Filescripted -Encoding ascii
                            (Get-Content $Filescripted) -replace '^\s*CREATE\s*VIEW(?!OR)', 'CREATE OR ALTER VIEW' | Out-File -FilePath $Filescripted -Encoding ascii
                            (Get-Content $Filescripted) -replace '^\s*CREATE\s*FUNCTION(?!OR)', 'CREATE OR ALTER FUNCTION' | Out-File -FilePath $Filescripted -Encoding ascii
                           
                           
                         }
                    } #foreach object

               
                    [System.GC]::Collect()
                } #If to exclude system schemas                        
            }#looping entire database for directory structure

      }# end of process

   END {
        $endtime = get-date
        Write-Host "==============================" -ForegroundColor White
        write-host "Started: $($starttime)" -ForegroundColor Magenta
        write-host "  Ended: $($endtime)" -ForegroundColor Yellow
        write-host "Elapsed: $(($endtime - $starttime).TotalSeconds)s" -ForegroundColor Green
        Write-Host "==============================" -ForegroundColor White
    }
} #main loop




