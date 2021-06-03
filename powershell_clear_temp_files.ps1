#This script can be used to to clear un used space of C:\ in windows servers
#once the task is completed it will send a mail to the added in $msg.To.Add
#please update your own smtp server address
#enter the servers suppose to release un-used space in 123.txt file (ex--c:\temp\123.txt)
#Create a folder named Cleanupreports in C:\temp
#Script assumes delprof is already installd in all the servers



$Path = "C:\temp\Cleanupreports\"
$Name = "Cleanup before patching servers_$(get-date -format ddMMyyyyhhmmss).html";
$cleanupreport = $Path + $Name
$i=0;

$header = "
		<html>
		<head>
		<meta http-equiv='Content-Type' content='text/html'>
		<title>C Drive Cleanup</title>
		<STYLE TYPE='text/css'>
		<!--
		tr {
			font-family: candara;
			font-size: 14px;
                        border-top: 1px solid #999999;
			border-right: 1px solid #999999;
			border-bottom: 1px solid #999999;
			border-left: 1px solid #999999;
			padding-top: 0px;
			padding-right: 0px;
			padding-bottom: 0px;
			padding-left: 0px;
			
		   }

        td {
			font-family: candara;
			font-size: 14px;
            
						
		   }
        
        th {
			font-family: candara;
			font-size: 14px;
                        border-top: 1px solid #999999;			
			border-bottom: 1px solid #999999;
						
		   }


		body {
			margin-left: 5px;
			margin-top: 5px;
			margin-right: 0px;
			margin-bottom: 10px;
			table {
			border: thin solid #000000;
		     }
		-->
		</style>
		</head>
		<body>
		<table width='100%'>
		<tr bgcolor='#FAFCFC'>
		<td colspan='7' height='25' align='center'>
		<font face='candara' color='#3bb8e7' size='4'><strong>C Drive Cleanup $todaydate </strong></font>
		</td>
		</tr>
		</table>
"
 Add-Content $cleanupreport $header
 $tableHeader = "
 <table width='100%'><tbody>
      	<tr bgcolor=#FAFCFC>
        <td width='auto' align='center'><strong>C:\ Cleanup Report</strong></td>

	</tr>
"
Add-Content $cleanupreport $tableHeader

$servers=get-content C:\temp\123.txt
$serv="IMAService"

foreach($server in $servers)
{
$x1=$x2=$x3=$x4=$x5=$x6=$x7=$x8=$x9=$x10=$nulll
 $tconnection=Test-Connection -quiet -ComputerName $server
 if ($tconnection -eq "True")
 {
 Write-Host "Now am on $server"
 $X0 = Write-Output "$Server is Reachable "
 $freespacebeforecleanup=[math]::Round(((Get-WmiObject Win32_LogicalDisk -ComputerName $server -Filter "DeviceID='C:'" |Foreach-Object {$_.FreeSpace})/(1024*1024*1024)),2)
 $x1=write-output "$server  C:\ size is $freespacebeforecleanup GB before cleanup"
 $uprofiles=(Get-ChildItem -Path \\$server\c$\users).name
 $ccmpath="\\$server\c$\Windows\ccmcache"
 #clear ccmcache
 $version=(Get-WmiObject -Class win32_operatingsystem -ComputerName $server).caption
 $x2=Write-Output "It'a Windows $version box"
 Invoke-Command -ComputerName $server -ScriptBlock { 
 $resource=New-Object -ComObject "UIResource.UIResourceMgr"
 $cacheInfo=$resource.GetCacheInfo()
 $cacheinfo.GetCacheElements()  |foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}}
 Start-Sleep 5
if((Test-Path -Path $ccmpath) -ne $null)
{
 $X3=Write-Output "By using UI ResourceManager , Unable to delete the CCMCache files hence proceeding with recursive delete"
 Get-ChildItem $ccmpath |Remove-Item -Recurse -Force -ErrorAction silentlycontinue
 $X4=Write-Output "Hope It's done now.."
}
 
 if($version.contains("2003"))
 {
  $X5=Write-Output " Since it's a Windows 2003 box deleting only Windows\temp"
  $wintemp="\\$server\c$\Windows\Temp"
  Get-ChildItem $wintemp |Remove-Item -Recurse -Force -ErrorAction silentlycontinue

 }
 else
 {
 $servname=(Get-Service -ComputerName $server -Name IMAService).name
 #if server is a Citrix installed , use delprof to delete profiles older than 2days
 if($servname -eq $serv)
 {
    $X7=Write-Output " Since Citrix Installed in this machine , Using Delprof deleting profiles which are older than 0 days"
    Invoke-Command -ComputerName $SERVER -ScriptBlock {delprof /q /i /d:0}
    $X8=Write-Output "OK, Profile Deletion now completed"
 }
 #if server is not part of Citrix , find the profiles and remove temp & wincache details as well temp
 else
 {
  $X9=Write-Output "OK, Am not a citrix box, so remove temp files from User profiles also"
  foreach($uprofile in $uprofiles)
  {
  $uprofile=$uprofile.trim()
  $temp="\\$server\c$\users\$uprofile\AppData\Local\Temp"
  if($temp -ne $null){  
  Get-ChildItem $temp |Remove-Item -Recurse -Force -ErrorAction silentlycontinue
  }}
  $wintemp="\\$server\c$\Windows\Temp"
  Get-ChildItem $wintemp |Remove-Item -Recurse -Force -ErrorAction Ignore
 }
}
$freespace=[math]::Round(((Get-WmiObject Win32_LogicalDisk -ComputerName $server -Filter "DeviceID='C:'" |Foreach-Object {$_.FreeSpace})/(1024*1024*1024)),2)
$X10=write-output "$server cleanup is completed and the C:\ size is $freespace GB"
}

else
{
$X0 = "$server is not reachable through WMI , Please check the box"
$X1=$null
$X2=$null
$X3=$null
$X4=$null
$X5=$null
$X7=$null
$X8=$null
$X9=$null
$X10=$null
}

$dataRow = "
		       <tr>
                 

                 <tr width='auto' align='center'><td></td></tr>
                 <tr width='auto' align='center'><td>$server</td></tr>
                 <tr width='auto' align='center'><td>______________________________________</td></tr>             
                 <tr width='auto' align='center'><td></td></tr>
                 <tr width='auto' align='center'><td>$X1</td></tr>
                 <tr width='auto' align='center'><td>$X2</td></tr>
                 <tr width='auto' align='center'><td>$X3</td></tr>
                 <tr width='auto' align='center'><td>$X4</td></tr>
                 <tr width='auto' align='center'><td>$X5</td></tr>
                 <tr width='auto' align='center'><td>$X7</td></tr>
                 <tr width='auto' align='center'><td>$X8</td></tr>
                 <tr width='auto' align='center'><td>$X9</td></tr>
                 <tr width='auto' align='center'><td>$X10</td></tr>
                 <tr width='auto' align='center'><td></td></tr>
                 <tr width='auto' align='center'><td>______________________________________</td></tr>   
                 </tr>


		     "

   Add-Content $cleanupreport $dataRow;

$i++
 
 
}

if($i -gt 0)
{
        		
	$smtpServer = "smtprelay.yourowndomain.com"
	$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
	$msg = New-Object Net.Mail.MailMessage
	$msg.To.Add("sandeep.sr@yourowndomain.com")
  $msg.To.Add("dl-team@yourowndomain.com")
  $msg.From = "yourowndomaincleanupreports@yourowndomain.com"
	$msg.Subject = "Cleanup before patching servers_$(get-date -format ddMMyyyy)"
  $msg.IsBodyHTML = $true
  $msg.Body = get-content $cleanupreport
	$smtp.Send($msg)
  $body = ""
}   
﻿
