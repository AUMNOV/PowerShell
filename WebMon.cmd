@Echo off
Echo Script is running...
Echo [%date%, %time%] >> C:\DBA\WebMon.log
C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe C:\DBA\Web_Mon.ps1 >> C:\DBA\WebMon.log
Echo: >> C:\DBA\WebMon.log
