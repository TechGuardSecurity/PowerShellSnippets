#importing the requests library
import requests
import pysftp

#api-endpoint
more=True
URL_use = URL = "https://api.hubapi.com/companies/v2/companies/paged?hapikey=xxxx&properties=name&limit=250" 
#while
while more:
# sending get request and saving the response as response object 
    r=requests.get(url=URL_use)
# extracting data in json format 
#data=r.text 
#OR
    data=r.json()
    #print(data)
    more = data['has-more']
    URL_use = URL + "&offset=" + str(data['offset'])
    #print(URL_use)
#for each company,
    for comp in data['companies']:
#extract these things:
        comp=comp['properties']
        print(comp)


#comp = data#['companies'][0]['properties']['name']['value']
#print(comp)
