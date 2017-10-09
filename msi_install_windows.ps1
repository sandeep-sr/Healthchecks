<# 
   .Synopsis 
    This script will be used to install msi file client in windows server 2003/2008
     
#>

# Read the server names in to a variable
$servers=Get-Content C:\serverlist.txt
$source= "Enter msi file folder path"
$dest=
# rund the installation for each server from the variable
foreach($server in $servers)

{

 $trendin = ((gwmi -Class win32_service -ComputerName $server -Filter "name ='servicename'").status)

  if($trendin -eq "ok")
    
    {

       Write-Host "---------------------$server has msi file installed---------------------"
      
    }

    else

    {

       Write-Host "---------------------$server doesn't contains software , Proceeding with msi file Installation---------------------"

       $dest = "C:\Windows\temp\software"

       #test if the 'C:\Windows\temp\software' is present in the server
       $testp= Invoke-Command -ComputerName $server {Test-Path -Path "C:\windows\temp\software" -PathType Container}

       #if the 'C:\Windows\temp\software' directory already present return as exists , else create in the C:\Windows\temp
        if ($testp -eq "True")

        {
    
            Write-Host "$dest already exists" 
     
        }

        else

        { 
    
            Invoke-Command -ComputerName $server { New-Item -Path "C:\Windows\temp\software"  -ItemType directory -Force}
     
        }

        # read the server operating system
        $version=(Get-WmiObject -Class win32_operatingsystem -ComputerName $server).caption

        # if it's windows server 2008 then copy the files to the 'C:\Windows\temp\software' directory in the server
        if($version.contains("2008"))

        {
  
            Copy-Item -Path "$source\*.*" -Destination "\\$server\c$\windows\temp\software" -Recurse -Force
  
            #install the msi file using msiexec in silent mode
            ([WMICLASS]”\\$server\ROOT\CIMV2:win32_process”).Create("msiexec.exe /i C:\Windows\temp\software\Agent-Core-Windows-XXXXXX.x86_64.msi /qn /passive")
  
        }

        # if it's windows server 2003 then copy the files to the 'C:\software' directory in the server
        elseif($version.contains("2003"))

        {
  
            Copy-Item -Path "$source\*.*" -Destination "\\$server\c$\windows\temp\software" -Recurse -Force
  
            # install the msi file using msiexec in silent mode
            ([WMICLASS]”\\$server\ROOT\CIMV2:win32_process”).Create("msiexec.exe /i C:\Windows\temp\software\Agent-Core-Windows-XXXXX.i386.msi /qn /passive")
  
         }

    }

     
}