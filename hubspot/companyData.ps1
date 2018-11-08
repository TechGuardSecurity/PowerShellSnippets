$more=1
$URL_use = $URL = "https://api.hubapi.com/companies/v2/companies/paged?hapikey=xxxx&properties=name&limit=250" 
while ($more){
    $r = Invoke-WebRequest $URL_use
    $data = $r.content
    $data = $data | Convertfrom-Json
    $more = $data.'has-more'
    $URL_use = $url + "&offset=" + $data.offset
    foreach ($comp in $data.companies){
        $comp = $comp.properties
        echo $comp
    }    
}
