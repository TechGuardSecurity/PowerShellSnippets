$more=1
$tab = [char]9
$properties = ('name','contact_name','contact_email')
$headers=''
$url_list =''

#create url to query
#example
#https://api.hubapi.com/companies/v2/companies/paged?hapikey=xxx&properties=name&limit=250
$baseurl = "https://api.hubapi.com/companies/v2/companies/paged?hapikey=xxx" # + "& ......
foreach ($prop in $properties){
    #Create URL

    $url_list = $url_list + "&properties=$prop"
}
$URL_use = $URL = $baseurl + $url_list + "&limit=250"
$fileName = "tempFile.txt"
$csvFile = "Company Report.csv"

#create file and 
#list properties to use as headers
for($i=0;$i -lt $properties.Length; $i++){
    if(!($i.Equals(0))){
        $headers=$headers + "," + $properties[$i]
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

        foreach ($prop in $properties){
            foreach ($key in $comp){
                if(!$content){
                    $content = $key.$prop.value
                }
                else{
                    $content = $content + "," + $key.$prop.value
                }
                echo ($prop + "`t`t`t " + $key.$prop.value)
            }
            
        }$content | out-file -filepath  $fileName -noclobber -append
        $content= ''
        #echo ''
    }    
}

#convert txt to csv and delete txt
import-csv $fileName -delimiter "," | export-csv $csvFile -NoType
Remove-item $fileName
