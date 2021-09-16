import requests
r = requests.post('https://gea.esac.esa.int/tap-server/tap/sync', headers={'Content-Type':'application/x-www-form-urlencoded'}, data={'request':'getCapabilities'})
print (r.text)
