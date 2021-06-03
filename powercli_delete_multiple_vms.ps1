Get-Module -ListAvailable *vm*|Import-Module
$cred=Get-Credential
Connect-VIServer vcenter02 -Credential $cred
$deletevmlist=Get-Content C:\temp\delete.txt
foreach($deletevm in $deletevmlist)
{
 write-output ("$deletevm is deleting...")
 get-cluster cluster02|get-vm $deletevm |Remove-VM -DeletePermanently -Confirm:$false -RunAsync| out-null
 Start-Sleep 10
}
