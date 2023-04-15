import urllib.request
import json
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from configparser import ConfigParser

"""
import os
import ssl
def allowSelfSignedHttps(allowed):
    # bypass the server certificate verification on client side
    if allowed and not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None):
        ssl._create_default_https_context = ssl._create_unverified_context

allowSelfSignedHttps(True) # this line is needed if you use self-signed certificate in your scoring service.
"""

#TODO: parameterise "data" using ArgParse 
#parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
#parser.add_argument("-tc", "--turnCount", type=int)
#parser.add_argument("-am0f", "--actor_move0_function", type=str)
#TODO: try autocomplete by GPT (alternatively accept TurnLog and extract from there)

# Request data goes here # https://docs.microsoft.com/azure/machine-learning/how-to-deploy-advanced-entry-script
data =  {
  "Inputs": {
    "data": [
      {
        "Column2": "example_value",
        "turnCount": 0,
        "winner.move0.function": "example_value",
        "winner.move0.baseDamage": 0,
        "winner.move0.type": "example_value",
        "winner.move0.category": 0,
        "winner.move0.accuracy": 0,
        "winner.move0.priority": 0,
        "winner.move1.function": "example_value",
        "winner.move1.baseDamage": 0,
        "winner.move1.type": "example_value",
        "winner.move1.category": 0,
        "winner.move1.accuracy": 0,
        "winner.move1.priority": 0,
        "winner.move2.function": "example_value",
        "winner.move2.baseDamage": 0,
        "winner.move2.type": "example_value",
        "winner.move2.category": 0,
        "winner.move2.accuracy": 0,
        "winner.move2.priority": 0,
        "winner.move3.function": "example_value",
        "winner.move3.baseDamage": 0,
        "winner.move3.type": "example_value",
        "winner.move3.category": 0,
        "winner.move3.accuracy": 0,
        "winner.move3.priority": 0,
        "winner.attack": 0,
        "winner.spatk": 0,
        "winner.spdef": 0,
        "winner.totalhp": 0,
        "winner.hp": 0,
        "winner.stages.attack": 0,
        "winner.stages.defense": 0,
        "winner.stages.spatk": 0,
        "winner.stages.spdef": 0,
        "winner.stages.speed": 0,
        "winner.stages.accuracy": 0,
        "winner.stages.evasion": 0,
        "looser.stages.attack": 0,
        "looser.stages.defense": 0,
        "looser.stages.spatk": 0,
        "looser.stages.spdef": 0,
        "looser.stages.speed": 0,
        "looser.stages.accuracy": 0,
        "looser.stages.evasion": 0
      }
    ]
  },
  "GlobalParameters": {
    "method": "predict"
  }
}

body = str.encode(json.dumps(data))

secrets = ConfigParser()
secrets_file = "ML\models\maram-ml-kpwft\sec.cfg" #".\sec.cfg"
secrets.read(secrets_file)

url = secrets.get('private', 'url')
api_key = secrets.get('private', 'api_key')
model_deployment = secrets.get('private', 'azureml-model-deployment') # The azureml-model-deployment header will force the request to go to a specific deployment.

if not api_key:
    raise Exception("A key should be provided to invoke the endpoint")

# Remove this header to have the request observe the endpoint traffic rules
headers = {'Content-Type':'application/json', 'Authorization':('Bearer '+ api_key), 'azureml-model-deployment': model_deployment}

req = urllib.request.Request(url, body, headers)

try:
    response = urllib.request.urlopen(req)   
    result = json.loads(response.read()).get("Results")[0]
    print(result)

except urllib.error.HTTPError as error:
    print("The request failed with status code: " + str(error.code))

    # Print the headers - they include the request ID and the timestamp, which are useful for debugging the failure
    print(error.info())
    print(error.read().decode("utf8", 'ignore'))
