Import-Module Active*
$userdata=get-content c:\temp\useraccounts.txt
foreach($user in $userdata)
{

try
{
  $Disabled=(Get-ADUser -Identity $user).Enabled
  if($Disabled -match "False")
  {
    Write-Output "$user is disabled"
    Write-Output "$user"|Out-File c:\temp\Disabled.txt -Append
  }
 elseif($Disabled -match "True")
 {
    Write-Output "$user is exists"
    Write-Output "$user"|Out-File c:\temp\enabled.txt -Append
 }
 else
 {
    Write-Output "either a contact/account not exists"
    Write-Output "$user"|Out-File c:\temp\conno.txt -Append
 
 }
 
}

catch
{
  Write-Output "$user is contact"
  Write-Output "$user"|Out-File c:\temp\contact.txt -Append
}
}
