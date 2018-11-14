######################################################
#
#   Techguard Security
#   Programed by: Nathan Layfield
#   Retrieve company list from HubSpot.  Combine list
#   based on spcified properties and create CSV.
#   Upload to SFTP server
#
######################################################

#store cred file and powershell file in same directory

#allow running of scripts. 
#set-executionpolicy remotesigned
#powershell.exe -noprofile -executionpolicy bypass -file .\script.ps1

#run this as admin to install ssh
#install-module ssh-posh



$more=1
$tab = [char]9
$sortfield = 'eula_signed'
$properties = ('name','eula_signed','contact_email')
$headers=''
$url_list =''
$delimiter = '|'
$date = (get-date).tostring('MM-dd-yyyy')

#Company Specifics:
$remoteComputer = "192.168.1.1"
$port = 22
$remote = "/remote/path"
$user = "user"
$hapikey = "hubspot-api-key-xxxxxxxx"



#create secure password file
#read-host -assecurestring | convertfrom-securestring | out-file cred.txt
if (!$cred){
    $pass = get-content cred.txt | convertto-securestring
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$pass
}

#need to set the location of the script
$fileName = "tempFile.txt"
$csvFile = "Company Report.csv $date.csv" "

#create url to query
#example
#https://api.hubapi.com/companies/v2/companies/paged?hapikey=$hapikey&properties=name&properties=eula_signed&limit=250
$baseurl = "https://api.hubapi.com/companies/v2/companies/paged?hapikey=$hapikey" # + "& ......
foreach ($prop in $properties){
    #Create URL

    $url_list = $url_list + "&properties=$prop"
}
$URL_use = $URL = $baseurl + $url_list + "&limit=250"


#create file and 
#list properties to use as headers
for($i=0;$i -lt $properties.Length; $i++){
    if(!($i.Equals(0))){
        $headers=$headers + $delimiter + $properties[$i]
    }
    else{
        $headers = $properties[$i]
    }
}

#use the constructed url
#to query hubspot
#output to txt file
$headers | out-file -filepath  $fileName
while ($more){
    $r = Invoke-WebRequest $URL_use
    $data = $r.content
    $data = $data | Convertfrom-Json
    $more = $data.'has-more'
    $URL_use = $url + "&offset=" + $data.offset
    foreach ($comp in $data.companies){
        $comp = $comp.properties
        #only include companies where specific field is used
        if($comp.$sortfield.value -eq 'Yes'){
            foreach ($prop in $properties){
                foreach ($key in $comp){
                    if(!$content){
                        $content = $key.$prop.value
                    }
                    else{
                        $content = $content + $delimiter + $key.$prop.value
                    }
                    #echo ($prop + "`t`t`t " + $key.$prop.value)
                }
            }
            
        }
        
        $content | out-file -filepath  $fileName -noclobber -append
        $content= ''
        #echo ''
    }    
}

#convert txt to csv and delete txt
import-csv $fileName -delimiter $delimiter | export-csv $csvFile -NoType
Remove-item $fileName

#SFTP connection and transfer
New-SFTPSession -ComputerName $remoteComputer -port $port -Credential $cred
$session =  $sftpSessions.sessionid
Set-SFTPFile -sessionid $session -remotepath $remote -localfile test
Remove-SFTPSession -Index $session
