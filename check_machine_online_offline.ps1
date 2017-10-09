#Author : Sandeep S R
#Simple script to check whether the server is online or offline
#copy server hotname/ip in missing.txt

$servers=Get-Content C:\temp\missing.txt

foreach($server in $servers)
{

$ts=Test-Connection -ComputerName $server -Count 3 -Quiet

if($ts -eq "True"){
Write-Output "$server - online"
}

else
{
Write-Output "$server - offline"
}


}