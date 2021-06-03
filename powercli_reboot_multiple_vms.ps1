Get-Module -ListAvailable *vm*|Import-Module
$cred=Get-Credential
connect-viserver vcenter01 -Credential $cred
$vmlist=Get-Content C:\temp\rebootvms.txt
foreach ($vm in $vmlist)
{
 get-cluster cluster02|get-vm $vm | Restart-VM -Confirm:$false
 start-Sleep 2
 Write-Output "$vm has been rebooted"
}
