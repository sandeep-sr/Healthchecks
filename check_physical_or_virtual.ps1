
$servers=Get-Content C:\scripts\serverlist.txt

foreach ($server in $servers)
{

$model=(Get-WmiObject -Class win32_computersystem -ComputerName $server).model

if($model.toupper().contains("VIRTUAL"))
      {
            write-output "$server is Virtual"
      }
      Else
      {
            write-output "$server is Physical"
      }

}