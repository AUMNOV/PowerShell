<#Send email with the Send-MailMessage method
if ($Outputreport.Contains("<TR bgcolor=red>")) {
$smtp = "mailhost.bzwint.com"
$to = "user@mail.com"
$from = "Moss Servers Monitor <dontreply@mail.com>"
$subject = "URL Monitoring Result for Mass Moss servers"  
$body = $Outputreport
send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high 
} #>

Function Send-mail ($MessageBody, $EmailSubject){ 
#Send email with the System.Net.Mail method
    $EmailFrom = "Moss-Maint Server <dontreply@mail.com>"
    $EmailTo = "team@mail.com"
    $SMTPServer = "mailhost.bzwint.com"
    # $EmailSubject = "URL Monitoring Result"  
#Send mail with output 
    $mailmessage = New-Object system.net.mail.mailmessage  
    $mailmessage.from = ($EmailFrom)  
    $mailmessage.To.add($EmailTo)
    $mailMessage.To.Add( "RnAMOSSCoreEnvironm@internal.barclayscapital.com" )
    $mailmessage.Subject = $EmailSubject 
    $mailmessage.Body = $MessageBody 
    $mailmessage.IsBodyHTML = $true
    $mailmessage.Priority = [System.Net.Mail.MailPriority]::High 
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer,25)   
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("dontreply@barclays.com", "password"); 
    $SMTPClient.EnableSsl = $false  
    $SMTPClient.Send($mailmessage) 
    }

 # Send-mail "Body text" "Subj"