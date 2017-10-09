#Author : Sandeep S R
#scripts takes input of user id's and determine if it's enabled or disabled and stores the data into disabled/enabled.txt

Import-Module Active*
$userdata=get-content C:\users.txt
foreach($user in $userdata)
{

try
{
  $Disabled=(Get-ADUser -Identity $user).Enabled
  if($Disabled -match "False")
  {
    Write-Output "$user is disabled"
    Write-Output "$user"|Out-File C:\Disabled.txt -Append
  }
 elseif($Disabled -match "True")
 {
     Write-Output "$user is enabled"
    Write-Output "$user"|Out-File C:\enabled.txt -Append
 }
 else
 {
  Write-Output "either a contact/no account exists"
  Write-Output "$user"|Out-File C:\conno.txt -Append
 
 }
 
}

  catch
  {
  Write-Output "$user is contact"
  Write-Output "$user"|Out-File C:\contact.txt -Append
  }
}