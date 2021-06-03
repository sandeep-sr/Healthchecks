<# 
   .Synopsis 
    This script will check SCCM client status,version & sitecode.
    If the site code is not cloudwiki1 it will assign/change to cloudwiki1
     
#>

Start-Transcript c:\temp\versionlog.txt

$r="Running"
$servers=get-content "C:\temps\servers.txt"

foreach($server in $servers)
{

  $sccmclientstatus=((Get-WmiObject Win32_Service -computername $server -ErrorAction silentlycontinue |Where-Object {$_.name -eq "ccmexec"}).state)

  if ($sccmclientstatus -eq $r)
  {
   $cversion=(Get-WMIObject -namespace "root\ccm" -ComputerName $server -class sms_client).clientversion
   write-host " $server - $cversion"
   $sccmclient =Get-WmiObject -ComputerName $server -list -Namespace root\ccm -Class SMS_client -ErrorAction silentlycontinue
   if (($sccmclient.getassignedsite()).ssitecode –eq "cloudwiki1") 
   { 
    Write-host "$server SCCM Site code is perfect"
   }

   else
   {
    $sccmclient.SetAssignedSite(“cloudwiki1”)
    Write-host "$server SCCM Site code is set successfully"
   }
  } 
  else
  {
   Write-host "Do Something to get client installed on $server :)" 
  }       
}

Stop-Transcript
