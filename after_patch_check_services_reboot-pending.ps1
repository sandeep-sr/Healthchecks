#Author : Sandeep S R
#This Scripts help in checking minimum required things are working after a patch reboot
#those includes pssession,any services running without service account are not starting , automatic services which are in stopped state,
#if the server is pending for a reboot for various reasons , a good html report
#copy the server details into servers.txt and create required folders based on the scripts lines to run without error 


$servers=get-content C:\servers.txt

 $Path = "C:\Patchreports\";
$Name = "yourowndomain After patchreport Check_$(get-date -format ddMMyyyyhhmmss).html";
$patchreport = $Path + $Name
$redColor = "#FF0000"
$orangeColor = "#FBB917"
$whiteColor = "#FFFFFF"
$maroonColor= "#800000"
$i = 0;
$todaydate = get-date -Format "MM-dd-yyyy hh:mm"
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -OpenTimeout 15000

 function get-uptime{
[Cmdletbinding()]
param($servername)
            $lb=(Get-WmiObject -Class win32_operatingsystem -ComputerName $servername).lastbootuptime
            $lbt=[system.management.managementdatetimeconverter]::todatetime($lb)
            $upt=(get-date)-($lbt)
            $formatted=("$($upt.days)Days $($upt.Hours)Hours $($upt.Minutes)Min")           
            Write-Output "$formatted"   }


$header = "
		<html>
		<head>
		<meta http-equiv='Content-Type' content='text/html'>
		<title>After patch Report</title>
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
		<font face='candara' color='#3bb8e7' size='4'><strong>yourowndomain After patchreport Check for $todaydate </strong></font>
		</td>
		</tr>
		</table>
"
 Add-Content $patchreport $header
 $tableHeader = "
 <table width='100%'><tbody>
      	<tr bgcolor=#FAFCFC>
        <td width='auto' align='center'><strong>Server Name</strong></td>
        <td width='auto' align='center'><strong>Status</strong></td>
	    <td width='auto' align='center'><strong>CCM Reboot</strong></td>
	    <td width='auto' align='center'><strong>Update Reboot</strong></td>
    	<td width='auto' align='center'><strong>Normal Reboot</strong></td>
	    <td width='auto' align='center'><strong>Auto Services</strong></td>
	    <td width='auto' align='center'><strong>Service Acoount</strong></td>
        <td width='auto' align='center'><strong>PS</strong></td>
        <td width='auto' align='center'><strong>RDP</strong></td>
        <td width='auto' align='center'><strong>Uptime</strong></td>

	</tr>
"
Add-Content $patchreport $tableHeader
 
  
 ForEach ($server in $Servers)
	{	

        $tconnection=Test-Connection -quiet -ComputerName $server
        
        if ($tconnection -eq "True") 
        {
         #write-output " $server - online"
         $connectivity = "online"
         #$utime=get-uptime $server
         #write-output " $server Uptime --> $utime"       
         $testSession = New-PSSession -SessionOption $sessionOption -Computer $server
         if(-not($testSession))
         {
          #Write-output "$server inaccessible!"
          $pscheck="Fail"
          $color2 = $redColor          
          $connectivity="online"
          #$color0=$redColor
          $ccmr="Fail"
          $aupdater="Fail"
          $rpendr="Fail"
          $autoservu="Fail"
          $serviceaccu="Fail"
          $RDPS="Fail"

        }
        
         else
         {
          #Write-Output "$server is accessible!"
          Remove-PSSession $testSession
          $pscheck="OK"
          $color2 = $whiteColor
          $ccmcheck=(Invoke-WmiMethod -ComputerName $server -Namespace root\ccm\clientsdk -Class CCM_ClientUtilities -Name DetermineIfRebootPending -ErrorAction SilentlyContinue).RebootPending
         If($ccmcheck -eq "True")
         {
          #Write-Output " $server - requires a reboot through SCCm"
          $ccmr="Yes"     
         } else {$ccmr="-"}
         $aupdate =Invoke-command -ComputerName $server {Get-Item "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" } -ErrorAction SilentlyContinue
         
         if($aupdate -ne $null) 
         {
          #Write-Output " $server - requires a reboot through Update"
          $aupdater="Yes"
         } else {$aupdater="-"}
         $rpend=Invoke-Command -ComputerName $server {Get-ChildItem "HKLM:Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"} -ErrorAction SilentlyContinue
         
         if ($rpend -ne $null) 
         {
          #Write-Output " $server - requires a reboot through normal" 
          $rpendr="Yes"
         } else {$rpendr="-"}
         
         $autoserv=(Get-WmiObject -Class Win32_Service -ComputerName $server | Where-Object {$_.State -ccontains "Stopped" -and $_.StartMode -ccontains "Auto" -and $_.name -notmatch "clr_opti*" -and $_.name -notmatch "shellhw*" -and $_.name -notmatch "sppsvc"}).displayname
         if ($autoserv -eq $null){$autoservu="Fine"} else{$autoservu=$autoserv}
         $serviceacc=(Get-WmiObject -Class Win32_Service -ComputerName $server|Where-Object {(($_.startname -like "*yourowndomain*") -and ($_.startmode -notlike "*Disable*")) -and ($_.State -like "*stopped*") }).Displayname
         if ($serviceacc -eq $null){$serviceaccu="Fine"} else{$serviceaccu=$serviceacc}
         $utime=get-uptime $server
         try{
           $socket = New-Object Net.Sockets.TcpClient($server, 3389)
           if($socket -eq $null){
                 $RDP=$false
                 $RDPS="Fail"
                 $color3 = $redColor
           }
           else{
                 $RDP = $true
                 $socket.close()
                 $RDPS="OK"
                 $color3 = $whiteColor
           }
        }
        catch{
                 $RDP = $false
                 $RDPS="Fail"
                 $color3 = $redColor
             }
     

         }
        } 
        
        else
        {
          #Write-Output " $Server - Offline "
          $connectivity="offline"
          #$color0=$redColor
          $ccmr="-"
          $aupdater="-"
          $rpendr="-"
          $autoserv="-"
          $serviceacc="-"
          $pscheck="-"
          $RDPS="-"
	  $utime="-"
        }
     
     $dataRow = "
		       <tr>
                 <td width='auto' align='center'><strong>$server</strong></td>
                 <td width='auto' bgcolor='$color0' align='center'><strong>$connectivity</strong></td>
	             <td width='auto' align='center'><strong>$ccmr</strong></td>
	             <td width='auto' align='center'><strong>$aupdater</strong></td>
	             <td width='auto' align='center'><strong>$rpendr</strong></td>
	             <td width='auto' align='center'><strong>$autoservu</strong></td>
	             <td width='auto' align='center'><strong>$serviceaccu</strong></td>
                 <td width='auto' bgcolor='$color2' align='center'><strong>$pscheck</strong></td>
                 <td width='auto' bgcolor='$color3' align='center'><strong>$RDPS</strong></td>
                 <td width='auto' align='center'><strong>$utime</strong></td>
                 </tr>"
                 Add-Content $patchreport $dataRow;
        $i++
      }


          
if ($i -gt 0)
{
   
        		
		$smtpServer = "smtprelay.yourowndomain.com"
		$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
		$msg = New-Object Net.Mail.MailMessage
		$msg.To.Add("dl-team@yourowndomain.com")
		$msg.From = "yourowndomainpatchreports@yourowndomain.com"
		$msg.Subject = "yourowndomain After patchreport Check_$(get-date -format ddMMyyyyhhmmss).html"
        $msg.IsBodyHTML = $true
        $msg.Body = get-content $patchreport
		$smtp.Send($msg)
        $body = ""
    
  }

