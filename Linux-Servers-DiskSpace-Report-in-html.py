#Author : Sandeep S R 
#Disspace.py script will run from a windows machine and get thedisk usage details of all linux servers mentioned in the text file hat.txt(Ex: C:/Scripts/)
#text file should be place in the directory from where python file being executed
#Script creates html file with formatted output and sends a mail to teams mentioned in the you array
#used paramiko to connect(SSH) servers
#in smtp relay , please enter your company's SMTP IP or FQDN
#enter from address in 'me' and To address in 'you'
#sqlite3 module is not required a this moment 
#offline servers will be ignored and the servernames will display in a text file attached to the mail


import paramiko
import sqlite3
import webbrowser
import os
import smtplib
import datetime

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

me = "yourowndomainUnixreports@yourowndomain.com"
#you = [ 'dl-team1@yourmydomain.com','dl-team2@yourmydomain.com']
you = "janam.sandeep@gmail.com"
today = datetime.date.today()

msg = MIMEMultipart('alternative')
msg['Subject'] = "mydomain UNIX Servers Diskspace report  " +str(today)
msg['From'] = me
msg['To'] = you

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
f = open("c:/Scripts/hat.txt")
#next = f.readlines()
f1 = open('testhtml.html','w')

html = """<html><table width='100%'>
        <STYLE TYPE='text/css'>
        <!--
        td {
            font-family: candara;
            font-size: 13px;
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
        <table width='100%'>
        <tr bgcolor='#F9F7F6'>
        <td colspan='7' height='25' align='center'>
        <font face='candara' color='#3bb8e7' size='4'><strong>yourownmydomain Linux Physical Servers DiskSpace Report  """ +str(today)+ """ </strong></font></br>
        <font face='candara' color='#3bb8e7' size='1'><strong>Offline servers will be ignored from the list</strong></font>
        </td>
        </tr>
        </table>
        <table width='100%'><tbody>
        <tr bgcolor=#F9F7F6>
        <td width='5%' align='center'> <font color='#AF4611'><strong>Server Name</strong></td>
            <td width='5%' align='center'> <font color='#AF4611'><strong>File System</strong></td>
            <td width='5%' align='center'> <font color='#AF4611'><strong>Drive Size</strong></td>
            <td width='5%' align='center'><font color='#AF4611'><strong>UsedSpace</strong></td>
            <td width='5%' align='center'><font color='#AF4611'><strong>FreeSpace</strong></td>
            <td width='7%' align='center'><font color='#AF4611'><strong>Percentage of usedspace</strong></td>
            <td width='7%' align='center'><font color='#AF4611'><strong>Mount Point</strong></td>
        </tr>"""
for server in f.read().split('\n'):
    #print(line) 
    HOST_UP  = True if os.system("ping -n 1 " + server) is 0 else False
    #print HOST_UP
    if HOST_UP == True:  
        try:
          ssh.connect(server, username='username', password='password')
        except paramiko.SSHException:
          print "Connection Failed"
        stdin,stdout,stderr = ssh.exec_command("df -PH|column -t")
        list = []
        for line in stdout.readlines()[1:]:
          #next(line)
          list.append(line)
        #print list        

        for l in list:
            ll = l.split()
            html += "<tr>"
            html += "<td>" + server +"</td>"
            for word in ll:
                print word
                html += "<td align='center'>{}</td>".format(word)
            html += "</tr>"

html += "</table></html>"
f1.write(html)
f1.close()
f.close()

part2 = MIMEText(html, 'html')
msg.attach(part2)
s = smtplib.SMTP('smtprelay.yourownmydomain.com')
s.sendmail(me, you, msg.as_string())
s.quit()
webbrowser.open_new_tab('testhtml.html')
