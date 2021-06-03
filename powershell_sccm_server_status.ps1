$r="Running"
$servers=get-content "C:\temp\SCCM\servers.txt"

$Name = "SCCM_Serv.html"

$report = "C:\temp\SCCM\" + $Name

$header = "
                                <html>
                                <head>
                                <meta http-equiv='Content-Type' content='text/html'>
                                <title>SCCM Details</title>
                                <STYLE TYPE='text/css'>
                                <!--
                                td {
                                                font-family: candara;
                                                font-size: 14px;
                                                border-top: 1px solid #999999;
                                                border-right: 1px solid #999999;
                                                border-bottom: 1px solid #999999;
                                                border-left: 1px solid #999999;
                                                padding-top: 0px;
                                                padding-right: 0px;
                                                padding-bottom: 0px;
                                                padding-left: 0px;
                                   }
                                body {
                                                margin-left: 5px;
                                                margin-top: 5px;
                                                margin-right: 0px;
                                                margin-bottom: 10px;
                                                table {
                                                border: thin solid #000000;
                                     }
                                -->
                                </style>
                                </head>
                                <body>
                                <table width='100%'>
                                <tr bgcolor='#FAFCFC'>
                                <td colspan='7' height='25' align='center'>
                                <font face='candara' color='#3bb8e7' size='4'><strong>SCCM Details </strong></font>
                                </td>
                                </tr>
                                </table>
"

Add-Content $report $header

$tableHeader = "
<table width='100%'><tbody>
		                <tr bgcolor=#FAFCFC>

		        	<td width='auto' align='center'><strong>Host Name</strong></td>
                                <td width='auto' align='center'><strong>Status</strong></td>
		                <td width='auto' align='center'><strong>SCCM Client</strong></td>
		                <td width='auto' align='center'><strong>SiteCode</strong></td>
                                <td width='auto' align='center'><strong>AD Status</strong></td>
		                </tr>
"
Add-Content $report $tableHeader




foreach($server in $servers)
{
	$SCCM = " "
	$scom = " "
    	$state = " "
            
              #Test the sever connection for online/offline
              if (Test-Connection -ComputerName $server -ErrorAction silentlycontinue)
        
                {                
                   Write-host "$server is online"
                   
		               $state = "Online"
                   #$version=(Get-WmiObject -Class win32_operatingsystem -ComputerName $server).caption
                   $version="NA"
                   #Find the sccm clint status whether it's running/stopped
                   $sccmclientstatus=((Get-WmiObject Win32_Service -computername $server |Where-Object {$_.name -eq "ccmexec"}).state)
                   #if the sccm client status in Running procedd with the following steps
                   if ($sccmclientstatus -eq $r)
                   {
		                 Write-host "$server has SCCM client"
		                 #SCCM client is running so yes to variable to print in the screen
                     $SCCM = "Yes"
                     #find the client version and send it to a variable to print in the web
                     $cversion=(Get-WMIObject -namespace "root\ccm" -ComputerName $server -class sms_client).clientversion
                     #get the sccm client details to find the sitecode defined
                     $sccmclient =Get-WmiObject -ComputerName $server -list -Namespace root\ccm -Class SMS_client -ErrorAction silentlycontinue
                     $sccmsitecode=($sccmclient.getassignedsite()).ssitecode
                     $AD="NA"
                                      
                   } 

                   else
                   {
		                #if there is no sccm client print as No client and sitecode as NO
                    Write-host "$server have no SCCM client"
		                $SCCM = "No"
                    $state = "Online"
                    $AD="NA"
                    $sccmsitecode="NA"
                    $sccm="NA"
                   }
                 
		  
		     	}
				   
                                   
              else
               {
                

                try
                  {
                   #ping test connection is not successful check the computer name listed in AD or not 
                   $find=Get-ADComputer $server -ErrorAction Stop
                   # If computer name listed in AD Print as Yes and say computer state as Offiline
                   Write-host "$server is offline but listed in AD "
                   $state = "Offline"
                   $version="NA"
                   $AD="Yes"
                   $sccmsitecode="NA"
                   $sccm="NA"
                    
                  }
    
                  catch
                  {
                    ##ping test connection is not successful and not listed in AD 
                    Write-host "$server is offline and not listed in AD"
                    $state = "Offline"
                    $version="NA"
                    $AD="No"
                    $sccmsitecode="NA"
                    $sccm="NA"
                  }


                                   
               }  




			$dataRow = "
                    	 <tr>
                	      <td width='auto' align='center'>$server</td>
                        <td width='auto' align='center'>$state</td>
                        <td width='auto' align='center'>$sccm</td>
                        <td width='auto' align='center'>$sccmsitecode</td>
                        <td width='auto' align='center'>$AD</td>
                        </tr>
              "

   Add-Content $report $dataRow;


}

﻿
