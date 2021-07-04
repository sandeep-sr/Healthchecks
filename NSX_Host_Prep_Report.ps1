<#

   .Synopsis
    find the clusters are not in ready state 

  .Note
   Copy the vcenter names into a text file named "vcenter" and place it into C:\temp before executing the script


#>
Get-Module -listavailable *vm*|Import-Module
Get-Module -listavailable *nsx*|Import-Module
$cred=Get-Credential
$redColor = "#FF0000"
$greenColor = "#B2D0B4"
$whiteColor = "#FFFFFF"
$orangeColor = "#FBB917"
$Path = "C:\temp\";
$Name = "NSX_Host_Prep_Report_$(get-date -format ddMMyyyyhhmmss).html";
$i = 0;
$todaydate = get-date -Format "MM-dd-yyyy hh:mm"
$CLUSTERS=$null


$hprep = $Path + $Name

$header = "
		<html>
		<head>
		<meta http-equiv='Content-Type' content='text/html'>
		<title>Host Prep</title>
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
		<table width='50%'>
		<tr bgcolor='#FAFCFC'>
		<td colspan='7' height='25' >
		<font face='candara' color='#3bb8e7' size='4' ><strong>NSX Host Prep Report_$todaydate</strong></font>
		</td>
		</tr>
		</table>
"
 Add-Content $hprep $header


 $tableHeader = "
 <table width='50%' align='center'><tbody>
      	<tr bgcolor=#FAFCFC>
        <td width='auto' align='center' color='#3bb8e7'><strong>Cluster</strong></td>
        <td width='auto' align='center' color='#3bb8e7'><strong>Host Preparation</strong></td>
        
	</tr>
"
Add-Content $hprep $tableHeader
$VCENTERS=Get-Content C:\temp\Vcenter.txt
foreach($VC in $VCENTERS)
{
 Connect-VIServer $VC -Credential $cred -ErrorAction Stop
 $CLUSTERS=(Get-View -ViewType ComputeResource).Name
 $NSX_MRS=(Get-View ExtensionManager).ExtensionList | Where {$_.Key -match "com.vmware.vShieldManager"}
 foreach($NSX_M in $NSX_MRS)
 {
  [string]$NSX_URL =$NSX_M.Client.Url
  $NSX_URL_INDEX=$NSX_URL.Substring(8)
  $NSX_IP=$NSX_URL.Substring(8,$NSX_URL_INDEX.IndexOf(":",0))

  Connect-NsxServer $NSX_IP -Username admin -Password "Enter the password"
  foreach($CLUSTER in $CLUSTERS)
  {
   $STATUS=(Get-NsxClusterStatus -Cluster (Get-Cluster $CLUSTER)|?{$_.featureId - "hostprep"}).status
   if($STATUS -match "RED")
   {
     $HSTAT= "Not Ready"
     $dataRow = "
		       <tr>
                <td width='auto' align='center'>$CLUSTER</td>
                <td width='auto' align='center'>$HSTAT</td>
               </tr>
              "
    Add-Content $hprep $dataRow;
   } 
    
  }
 }
 Disconnect-NsxServer $NSX_M -Confirm:$false
 Disconnect-VIServer -Server $VC -Force -WarningAction SilentlyContinue -Confirm:$false

		

    $smtpServer = "mailserver DNS Name"
  	$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
	  $msg = New-Object Net.Mail.MailMessage
	  $msg.To.Add("Mail ID 1")
    $msg.To.Add("Mail ID 2")
    $msg.From = "from which mail id we have to send alerts"
    $msg.Subject = "NSX Host Prep Report_$(get-date -format ddMMyyyy)"
    $msg.IsBodyHTML = $true
    $msg.Body = get-content $capacityreport
	  $smtp.Send($msg)
    $body = ""

}
