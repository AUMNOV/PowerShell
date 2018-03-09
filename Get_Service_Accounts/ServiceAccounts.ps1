# Get SQL Service Accounts
 
Write-Host Script is working... 

$RemoteComputers = Get-Content -path "\\uefafssql01.uefa.local\SQL_DATA\DBA_tools\ServiceAccounts\servers.txt"

$results = @()
ForEach ($Computer in $RemoteComputers)
{
     Try
         {
       $results += Invoke-Command -ComputerName $Computer -ErrorAction Stop -ScriptBlock {Get-WmiObject win32_service | where {$_.Caption -like “SQL*”} | select PSComputerName, DisplayName, Name, State, StartName }
                  }
     Catch
         {
             Add-Content \\uefafssql01.uefa.local\SQL_DATA\DBA_tools\ServiceAccounts\Unavailable-Computers.txt $Computer
         }
} 

#Write-Host $results
#$results | out-file "\\uefafssql01.uefa.local\SQL_DATA\DBA_tools\ServiceAccounts\Services.txt"
$results | export-csv -Append "\\uefafssql01.uefa.local\SQL_DATA\DBA_tools\ServiceAccounts\Services.csv"
