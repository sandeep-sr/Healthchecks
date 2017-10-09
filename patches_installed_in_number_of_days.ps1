#Author : Sandeep S R
#scripts get the hotfixs installed in a machine between DateA & DateB
#once the script executed it creates a file with server name in temp folder with details
#place the list of servers in serverlist.txt
#As an example i have made 35days prior

$DateA=(get-date).AddDays(-35)
$DateB=Get-Date
$servers=Get-Content C:\serverlist.txt
foreach($server in $servers){
$hfix=Get-HotFix -ComputerName $server|Where {$_.InstalledOn -gt $DateA -AND $_.InstalledOn -lt $DateB } | sort InstalledOn
if($hfix -eq $null){Write-Output "No updates installed in last 7 days" | out-file C:\temp\$server.txt}
else{Write-Output "$hfix"
$hfix|out-file C:\temp\$server.txt}

}

