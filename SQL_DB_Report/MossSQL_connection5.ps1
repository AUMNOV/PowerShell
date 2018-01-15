# MS SQL Database Report

$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$json = (Get-Content "$($scriptPath)\Moss_Env.json" -Raw) | ConvertFrom-Json
$DBList = $json.Moss_Environments.DB_ConnectionString
# $SqlQuery = "SELECT TOP 5 *  FROM [RNA_MOSS_UAT1].[Moss].[Maps];"
$SqlQuery = Get-Content "$($scriptPath)\PS_Query.sql"

Remove-item "$($scriptPath)\Test_db.html"
$Result = @() 

# CSS Style for table
$HtmlHead = '<style>
    body {
        background-color: white;
        font-family:      "Calibri";
    }
    table {
        border-width:     1px;
        border-style:     solid;
        border-color:     black;
        border-collapse:  collapse;
    }
    th {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: #98C6F3;
    }
    td {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: White;
    }
    tr {
        text-align:       left;
    }
</style>'

$Header = "<HTML><TITLE>Moss Database Report</TITLE><BODY background-color:peachpuff><font color =""#99000"" face=""Microsoft Tai le"">
<H2> Moss Database Report "+ $(Get-Date) + " </H2></font>" >> "$($scriptPath)\Test_db.html"



  Foreach($DBs in $DBList) { 
Write-Host $DBs.Split(';')[0,1]
#####
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $DBs
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) | Out-Null
$SqlConnection.Close()
#####
$DataSet.Tables[0] | Format-Table -Auto | out-file -append "$($scriptPath)\PS_Query_out.csv"
#$DataSet.Tables | Format-Table | Select-Object -expand Rows |ConvertTo-HTML -As Table -head $DBs.Split(';')[1] –body "<H2>iApp RDC Usage Stats as of $(Get-Date)</H2> " | Out-File "$($scriptPath)\Test_db.html"
$DataSet.Tables[0] | Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors |
ConvertTo-HTML -As Table -Head $HtmlHead -body "<H3> $($DBs.Split(';')[0,1]) </H3>" | Out-File -append "$($scriptPath)\Test_db.html"

 } 
 

$Outputreport = "<HTML><TITLE>Moss Databases Report </TITLE><BODY background-color:peachpuff><font color =""#99000"" face=""Microsoft Tai le""><H2> Moss Databases Report - "+ $(Get-Date) + " </H2></font><Table border=1 cellpadding=0 cellspacing=0><TR bgcolor=gray align=center><TD><B>URL</B></TD><TD><B>StatusCode</B></TD><TD><B>StatusDescription</B></TD><TD><B>ResponseLength</B></TD><TD><B>TimeTaken</B></TD></TR>" 
    Foreach($Entry in $Result) 
    { 
            if ($Entry.StatusCode -ne "200") { $Outputreport += "<TR bgcolor=red>"  } 
            else { $Outputreport += "<TR>" } 
        
        $Outputreport += "<TD>$($Entry.uri)</TD><TD align=center>$($Entry.StatusCode)</TD><TD align=center>$($Entry.StatusDescription)</TD><TD align=center>$($Entry.ResponseLength)</TD><TD align=center>$($Entry.timetaken)</TD></TR>" 
    } 
    $Outputreport += "</Table></BODY></HTML>" 

######## Bottom Line
$dbcount = (get-content "$($scriptPath)\Test_db.html" | select-string -pattern "FILE_SIZE_MB").length
$Header = "<HTML><TITLE>Reported Databases</TITLE><BODY background-color:peachpuff><font color =""#99000"" face=""Microsoft Tai le"">
<H3> Databases: "+ $dbcount +" from "+ $DBList.count+"</H3></font>" >> "$($scriptPath)\Test_db.html"
########


# Output to HTML
#$Outputreport | out-file "$($scriptPath)\Test_db.html"
 Invoke-Expression "$($scriptPath)\Test_db.html"

 
<#
################

$a = "<style>"
$a = $a + "BODY{background-color:peachpuff;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:PaleGoldenrod}"
$a = $a + "</style>"

$DataSet.Tables[0] | ConvertTo-HTML -head $a -body "<H2>Service Information</H2>" | Out-File "$($scriptPath)\PS_Query_out.htm"
Invoke-Expression "$($scriptPath)\PS_Query_out.htm"

#>

#Send email
$MessageBody = Get-Content "$($scriptPath)\Test_db.html"

Import-module "$($scriptPath)\MossMessaging_func.ps1" -Force
Send-mail $MessageBody "Moss databases status report"
 
