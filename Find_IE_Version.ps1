#Author : Sandeep S R
#Script can be used to find IE version from machines 
#IE versions numbering sits in different places in registry else it became bit bigger 

$servers=Get-Content C:\scripts\serverlist.txt
 
foreach( $server in  $servers){
 
$key=invoke-command -computername $server {get-itemproperty -Path "HKLM:SOFTWARE\Microsoft\Internet Explorer"}
 
if($key -match "svcVersion"){ 

$version=Invoke-Command -ComputerName $server {(Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Internet Explorer").svcVersion}
$versplit=$version.split(".")[0]
write-output " $server - IE $versplit "

 } 
 
else {

$version=Invoke-Command -ComputerName $server {(Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Internet Explorer").Version}
$versplit=$version.split(".")[0]
write-output " $server - IE $versplit " 

 }
 
} 

