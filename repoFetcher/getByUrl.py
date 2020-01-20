import sys
#from .access_token import access_token
import requests

access_token = {  # TODO
    "access_token": "f6856730bcbbed4cdc90a27292613b22de653af7"
}

url = sys.argv[1]

response = requests.get(url=url, params=access_token)
print(response.text)
