#import vmware powershell modules
Get-Module *vm*|import-module
#Connect to vCenter
connect-viserver vcentername.thecloudwiki.com -ea silentlycontinue
#Get the VM details
$vm=(Get-View -ViewType "Virtualmachine" -Filter @{"Runtime.PowerState" ="poweredOn";"Config.GuestFullName"=".*windows*.*"}).name
$percentWarning = 15;
$percentWarning = 15;
$percentCritcal = 10;
$percent50 = 50;
$percent90 = 90;
$redColor = "#FF0000"
$greenColor = "#B2D0B4"
$whiteColor = "#FFFFFF"
$orangeColor = "#FBB917"
#Path to save the output HTML file
$Path = "C:\ScriptScheduled\";
#Name of the HTML file
$Name = "Capacity Report_$(get-date -format ddMMyyyyhhmmss).html";
$i = 0;
#Today date
$todaydate = get-date -Format "MM-dd-yyyy hh:mm"

$todayMidnight = (Get-Date -Hour 0 -Minute 0 -Second 0).AddMinutes(-1)
$workingDays = “Monday”,”Tuesday”,”Wednesday”,”Thursday”,”Friday”
$dayStart = New-Object DateTime(1,1,1,8,00,0) # 05:00 AM (Take into account EST)
$dayEnd = New-Object DateTime(1,1,1,19,00,0) # 06:00 PM
$date = Get-Date

$capacityreport = $Path + $Name

$header = "
		<html>
		<head>
		<meta http-equiv='Content-Type' content='text/html'>
		<title>DiskSpace Report</title>
		<STYLE TYPE='text/css'>
		<!--
		td {
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
		<font face='candara' color='#3bb8e7' size='4'><strong> Capacity Report__$todaydate (Last 90days) </strong></font>
		</td>
		</tr>
		</table>
"
 Add-Content $capacityreport $header


 $tableHeader = "
 <table width='100%'><tbody>
      	<tr bgcolor=#FAFCFC>
        <td width='auto' align='center'><strong>Server</strong></td>
        <td width='auto' align='center'><strong>CPU Usage</strong></td>
	    <td width='auto' align='center'><strong>Memory Usage</strong></td>
        <td width='auto' align='center'><strong>CPU Max</strong></td>
        <td width='auto' align='center'><strong>Memory Max (Avg in a day)</strong></td>
        <td width='auto' align='center'><strong>C:\ Free Space in %</strong></td>
        <td width='auto' align='center'><strong>C:\ Free Space in GB</strong></td>
	</tr>
"
Add-Content $capacityreport $tableHeader
 
foreach($Vmi in $vm)
{
#CPU & Memroy average in working hours and only on weekedays
$cpuavg=[Math]::Round((((Get-Stat -Entity $Vmi -Stat cpu.usage.average -Start $todayMidnight.AddDays(-90) -Finish $todayMidnight.AddDays(-1) |Where-Object {$workingDays -contains $_.Timestamp.DayOfWeek}).value)|Measure-Object -Average).Average,2)
$memavg=[Math]::Round((((Get-Stat -Entity $Vmi -Stat mem.usage.average -Start $todayMidnight.AddDays(-90) -Finish $todayMidnight.AddDays(-1) |Where-Object {$workingDays -contains $_.Timestamp.DayOfWeek}).value)|Measure-Object -Average).Average,2)
#CPU & Memroy maximum in working hours and only on weekedays
$cpumax=[Math]::Round(((Get-Stat -Entity $Vmi -Stat cpu.usagemhz.Average -Start $todayMidnight.AddDays(-90) -Finish $todayMidnight.AddDays(-1) | Measure-Object Value -Maximum).Maximum),2)
$memmax=[Math]::Round(((Get-Stat -Entity $Vmi -Stat mem.usage.Average -Start $todayMidnight.AddDays(-90) -Finish $todayMidnight.AddDays(-1) | Measure-Object Value -Maximum).Maximum),2)
# Get the Freespace details those machines
 try
 {
  $size=Get-WmiObject Win32_LogicalDisk -ComputerName $Vmi -Filter "DeviceID='C:'" |Foreach-Object {$_.size}

  $freespace=Get-WmiObject Win32_LogicalDisk -ComputerName $Vmi -Filter "DeviceID='C:'" |Foreach-Object {$_.FreeSpace}
              
  $freespaceGB= [Math]::Round(($freespace)/(1024*1024*1024),2)	            

  $percentFree = [Math]::Round(($freespace / $size) * 100, 2);
                
 }

 catch
 {
  $freespaceGB="NA"
  $percentFree ="NA"
 }
                
 $color = $whiteColor;
 if($percentFree -lt $percentWarning)      
 {
   $color = $orangeColor	
 }

 if($percentFree -lt $percentCritcal)
 {
  $color = $redColor
 }  
 $color0 = $whiteColor;
 $color1 = $whiteColor;
 if($cpuavg -lt $percent50)      
 {
  $color0 = $greenColor	
 }
 if($cpuavg -gt $percent90)
 {
  color0 = $redColor
 }  
 if($memavg -lt $percent50)      
 {
  $color1 = $greenColor	
 }
 if($memavg -gt $percent90)
 {
  $color1 = $redColor
 }  


 $dataRow = "
   <tr>
      <td width='auto' align='center'><strong>$vmi</strong></td>
      <td width='auto' bgcolor=`'$color0`' align='center'>$cpuavg</td>
      <td width='auto' bgcolor=`'$color1`' align='center'>$memavg</td>
      <td width='auto' align='center'>$cpumax Mhz</td>
      <td width='auto' bgcolor=`'$color1`' align='center'>$memmax</td>
      <td width='auto' bgcolor=`'$color`' align='center'>$percentFree</td>
      <td width='auto' bgcolor=`'$color`' align='center'>$freespaceGB</td>
   </tr>
            "

Add-Content $capacityreport $dataRow;
  
 $i++		
}

if ($i -gt 0)
{
   
  #send mail to the groups / members in the team		
	$smtpServer = "ProvideSMTPName"
	$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
	$msg = New-Object Net.Mail.MailMessage
	$msg.To.Add("mail@thecloudwiki.com")
  $msg.To.Add("operations@thecloudwiki.com")
	$msg.From = "from@thecloudwiki.com"
	$msg.Subject = " Capacity Report for last 90 days_generated on_$(get-date -format ddMMyyyy)"
  $msg.IsBodyHTML = $true
  $msg.Body = get-content $capacityreport
	$smtp.Send($msg)
  $body = ""
    
  }


﻿
