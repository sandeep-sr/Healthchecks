<#
   .Synopsis
    Unassign all users mappings from a specific pool 

   .Details required to run the script
     1) Enter the Portal URL for $tenanturl
     2) Enter Credentials information in $ADCredentials section which need below inputs
     3) You will get a prompt to input pool id of the vm's 
        
    .Limitations
      1) This script can run against one pool at a time 
      2) This script is for static pool assignments only, not to be used for floating since floating pools we will assign the group
    
#>

#input the PORTAL URL & Domain
$tenanturl= "xxx.theclouldwiki.com"
$taaddress = "https://" + $tenanturl + "/"
$dtlogin= "dt-rest/v100/system/authenticate/credentials"
$auth = @()
$ADCredentials = @()
#provide AD Creadentials Plain text
$ADCredentials ='
{
    "type":"CREDENTIALS",
    "username":"SuperAdminUser",
    "password":"SuperAdminUserPassword",
    "domain":"Domain",
    "usernameModifiable":false
}
'
$taauthadderessuri= $taaddress+$dtlogin

try 
{
 #Create Initial auth request and this will used run further api calls
 $auth = Invoke-WebRequest –Uri $taauthadderessuri –Method Post -Headers @{"Content-Type" ="application/json"} –Body $ADCredentials  –ErrorAction stop
} 
catch
{
 Write-Host -ForegroundColor Red -BackgroundColor Black "Error with Active Directory login, please check credentials."	
 return
}
#Get the auth headers for future API calls
if($auth.headers.Authorization)
{
 Write-Host -ForegroundColor Green "Active Directory login successful."
 $loginauth = $auth.headers.Authorization
 $csrfheader = $auth.headers.'x-dt-csrf-header'
}
#Pull Assignments information
$poolsuri = ($taaddress + "dt-rest/v100/pool/manager/pools")
$poolsinfojson = Invoke-RestMethod -Uri $poolsuri -Method Get -Headers @{"Accept"="application/json";"Authorization"="$loginauth"}
foreach ($poolinfo in $poolsinfojson)
{
 foreach ($pooldetails in $poolinfo) { foreach ($poolformat in $pooldetails) {write-host -ForegroundColor Cyan $poolformat.id --> $poolformat.name}}
}
write-host -ForegroundColor DarkCyan "======================================================================================"
$pool_id = Read-Host  "Enter the pool id where we have to remove all mappings"
write-host -ForegroundColor DarkCyan "======================================================================================"
#Get the user mappings from the pool mentioned above
$uservmmappinguri = ($taaddress + "dt-rest/v100/infrastructure/pool/desktop/" + $pool_id + "/user/desktop/mappings")
$uservmmappingjson = Invoke-RestMethod -Uri $uservmmappinguri -Method Get -Headers @{"Accept"="application/json";"Authorization"="$loginauth"}
#To remove user mappings we need user VM patternid and user guid
foreach ($mappingusers in $uservmmappingjson) 
{  
 foreach ($mappinguser in $mappingusers)
 { 
  foreach ($eachpattern in $mappinguser) 
  {
   $user_id = $eachpattern.DtUser.id
   $user_loginname = $eachpattern.DtUser.loginname
   $staticpattern_name = $eachpattern.DtStaticDesktopPattern.name
   $staticpattern_id = $eachpattern.DtStaticDesktopPattern.id
   Write-Host -ForegroundColor White "$user_loginname - $user_id - $staticpattern_name - $staticpattern_id"
   write-host -ForegroundColor Yellow "proceeding with above mapping removal"
   try 
   {
    #Unassign the user from specific vm pattern   
    $unassignuri = ($taaddress + "dt-rest/v100/infrastructure/pattern/static/" + $staticpattern_id + "/remove/user/" + $user_id)
    Invoke-RestMethod -Uri $unassignuri -Method PUT -Headers @{"x-dt-csrf-header"="$csrfheader";"Authorization"="$loginauth"} 
    write-host -ForegroundColor Green "Removal of nmapping for $user_loginname --> $staticpattern_name is succeded on $pool_id"     
   }
   catch 
   {
    write-host -ForegroundColor RED "Removal of mapping for $user_loginname --> $staticpattern_name failed"
   }
  write-host -ForegroundColor Cyan "======================================================================================"
 }
}
}

