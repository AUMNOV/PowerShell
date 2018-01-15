############################################################################## 
## Moss Services Monitoring
## Andrey Umnov 2017
############################################################################## 

# Define Server & Services Variable
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
# $json = (Get-Content "$($scriptPath)\ServiceList.json" -Raw) | ConvertFrom-Json
$json = (Get-Content "$($scriptPath)\Moss_Env.json" -Raw) | ConvertFrom-Json
# $ServerList = $json.Server_List
$ServerList = $json.Moss_Environments.Servers.ServerName | where { $_ -notlike "*pdn*" } # List of non prod servers
# $ServicesList = $json.Moss_Services 
$ServicesList = $json.Moss_Environments[0].Servers[0].Services
$report = "$($scriptPath)\report.htm"  
############################################################################## 

$checkrep = Test-Path "$($report)"  
If ($checkrep -like "True") 
{ Remove-Item "$($report)" } 
New-Item "$($report)" -type file 

################################ADD HTML Content############################# 

Add-Content $report "<html>"  
Add-Content $report "<head>"  
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"  
Add-Content $report '<title>Service Status Report</title>'  
add-content $report '<STYLE TYPE="text/css">'  
add-content $report  "<!--"  
add-content $report  "td {"  
add-content $report  "font-family: Tahoma;"  
add-content $report  "font-size: 11px;"  
add-content $report  "border-top: 1px solid #999999;"  
add-content $report  "border-right: 1px solid #999999;"  
add-content $report  "border-bottom: 1px solid #999999;"  
add-content $report  "border-left: 1px solid #999999;"  
add-content $report  "padding-top: 0px;"  
add-content $report  "padding-right: 0px;"  
add-content $report  "padding-bottom: 0px;"  
add-content $report  "padding-left: 0px;"  
add-content $report  "}"  
add-content $report  "body {"  
add-content $report  "margin-left: 5px;"  
add-content $report  "margin-top: 5px;"  
add-content $report  "margin-right: 0px;"  
add-content $report  "margin-bottom: 10px;"  
add-content $report  ""  
add-content $report  "table {"  
add-content $report  "border: thin solid #000000;"  
add-content $report  "}"  
add-content $report  "-->"  
add-content $report  "</style>"  
Add-Content $report "</head>"  
Add-Content $report "<body>"  
add-content $report  "<table width='80%'>"  
add-content $report  "<tr bgcolor='Lavender'>"  
add-content $report  "<td colspan='7' height='25' align='center'>"  
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Service Status Report</strong></font>"  
add-content $report  "</td>"  
add-content $report  "</tr>"  
add-content $report  "</table>"  

add-content $report  "<table width='80%'>"  
Add-Content $report "<tr bgcolor='IndianRed'>"  
Add-Content $report  "<td width='10%' align='center'><B>Server Name</B></td>"  
Add-Content $report "<td width='30%' align='center'><B>Service Name</B></td>"  
Add-Content $report  "<td width='10%' align='center'><B>Status</B></td>"  
Add-Content $report "</tr>"  

######################################################################################################## 

################################## Get Services Status ################################################# 

Function servicestatus ($serverlist, $serviceslist) 

{ 

foreach ($machineName in $serverlist)  

 {  
  foreach ($service in $serviceslist) 
     { 

      $serviceStatus = get-service -ComputerName $machineName -Name $service 

         if ($serviceStatus.status -eq "Running") { 

         Write-Host $machineName `t $serviceStatus.name `t $serviceStatus.status -ForegroundColor Green  
         $svcName = $serviceStatus.name  
         $svcState = $serviceStatus.status          
         Add-Content $report "<tr>"  
         Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B> $machineName</B></td>"  
         Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B>$svcName</B></td>"  
         Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>$svcState</B></td>"  
         Add-Content $report "</tr>"  

                                                   } 

            else  
                                                   {  
       Write-Host $machineName `t $serviceStatus.name `t $serviceStatus.status -ForegroundColor Red  
         $svcName = $serviceStatus.name  
         $svcState = $serviceStatus.status           
         Add-Content $report "<tr>"  
         Add-Content $report "<td bgcolor= 'GainsBoro' align=center>$machineName</td>"  
         Add-Content $report "<td bgcolor= 'GainsBoro' align=center>$svcName</td>"  
         Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>"  
         Add-Content $report "</tr>"  

                                                  }  

       }  

 }  

} 

############################################Call Function############################################# 

servicestatus $ServerList $ServicesList 

############################################Close HTMl Tables######################################### 

Add-content $report  "</table>"  
Add-Content $report "</body>"  
Add-Content $report "</html>"  

##################################################################################################### 
#############################################Send Email############################################## 
<#

Function Send-mail ($MailBody) { 
#Send email with the System.Net.Mail method
    $EmailFrom = "Moss Servers Monitor <dontreply@barclays.com>"
    $EmailTo = "andrey.umnov@barclayscapital.com"
    $SMTPServer = "mailhost.bzwint.com"
    $EmailSubject = "Moss services status report"  
#Send mail with output 
    $mailmessage = New-Object system.net.mail.mailmessage  
    $mailmessage.from = ($EmailFrom)  
    $mailmessage.To.add($EmailTo)
    $mailMessage.To.Add( "andrey.umnov@barclayscapital.com" )
    $mailmessage.Subject = $EmailSubject 
    $mailmessage.Body = $MailBody
    $mailmessage.IsBodyHTML = $true
    $mailmessage.Priority = [System.Net.Mail.MailPriority]::High 
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer,25)   
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("dontreply@barclays.com", "password"); 
    $SMTPClient.EnableSsl = $false  
    $SMTPClient.Send($mailmessage) 
    }
#>
 $Outputreport = Get-Content $report
  #Send email
Import-module "$($scriptPath)\MossMessaging_func.ps1" -Force
Send-mail $Outputreport "Moss services status report"
# if ($Outputreport.Contains("td bgcolor= 'Red'")) { Send-mail $Outputreport "Moss services status report"}
#####################################################################################################

# get-service -ComputerName moss-dev-1 -Name MossServiceInterface
#(Get-WmiObject -Class Win32_Service -filter "Name='W32Time'").StartMode
#(Get-WmiObject -Class Win32_Service -Filter "Name='W32Time'" -ComputerName moss-dev-1).StopService()