Get-Module -ListAvailable *vm*|Import-Module
$cred=Get-Credential
Connect-VIServer vcenter01 -Credential $cred
$deletevmlist=Get-Content C:\temp\stopvms.txt
foreach($vm in $deletevmlist)
{
 $vmstate=get-vm $vm
 if($vmstate.PowerState -eq "PoweredOn")
 {
  write-output ("$vm is powered-on hence stopping it")
  Stop-VM -VM $vm -Confirm:$false -RunAsync | Out-Null
  Start-Sleep 2
 }
}
﻿
