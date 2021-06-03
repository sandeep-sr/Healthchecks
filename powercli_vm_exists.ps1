Get-Module -ListAvailable *vm*|Import-Module
$cred=Get-Credential
Connect-VIServer vcenter01 -Credential $cred
$vms=Get-Content C:\temp\vmcheck.txt
foreach($vm in $vms)
{
  $exsists=Get-Cluster cluster02|get-vm $vm -ErrorAction SilentlyContinue
  if($exsists){
  Write-Output "$vm exist" }
  else{
  Write-Output "$vm not exists" }
