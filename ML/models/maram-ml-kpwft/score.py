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

parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument("-tc", "--turnCount", type=int)
parser.add_argument("-am0f", "--actor_move0_function", type=str)
parser.add_argument("-am0bd", "--actor_move0_baseDamage", type=int)
parser.add_argument("-am0t", "--actor_move0_type", type=str)
parser.add_argument("-am0c", "--actor_move0_category", type=int)
parser.add_argument("-am0a", "--actor_move0_accuracy", type=int)
parser.add_argument("-am0p", "--actor_move0_priority", type=int)
parser.add_argument("-am1f", "--actor_move1_function", type=str)
parser.add_argument("-am1bd", "--actor_move1_baseDamage", type=int)
parser.add_argument("-am1t", "--actor_move1_type", type=str)
parser.add_argument("-am1c", "--actor_move1_category", type=int)
parser.add_argument("-am1a", "--actor_move1_accuracy", type=int)
parser.add_argument("-am1p", "--actor_move1_priority", type=int)
parser.add_argument("-am2f", "--actor_move2_function", type=str)
parser.add_argument("-am2bd", "--actor_move2_baseDamage", type=int)
parser.add_argument("-am2t", "--actor_move2_type", type=str)
parser.add_argument("-am2c", "--actor_move2_category", type=int)
parser.add_argument("-am2a", "--actor_move2_accuracy", type=int)
parser.add_argument("-am2p", "--actor_move2_priority", type=int)
parser.add_argument("-am3f", "--actor_move3_function", type=str)
parser.add_argument("-am3bd", "--actor_move3_baseDamage", type=int)
parser.add_argument("-am3t", "--actor_move3_type", type=str)
parser.add_argument("-am3c", "--actor_move3_category", type=int)
parser.add_argument("-am3a", "--actor_move3_accuracy", type=int)
parser.add_argument("-am3p", "--actor_move3_priority", type=int)
parser.add_argument("-aa", "--actor_attack", type=int)
parser.add_argument("-asp", "--actor_spatk", type=int)
parser.add_argument("-asd", "--actor_spdef", type=int)
parser.add_argument("-athp", "--actor_totalhp", type=int)
parser.add_argument("-ahp", "--actor_hp", type=int)
parser.add_argument("-asatt", "--actor_stages_attack", type=int)
parser.add_argument("-asdef", "--actor_stages_defense", type=int)
parser.add_argument("-asspa", "--actor_stages_spatk", type=int)
parser.add_argument("-asspd", "--actor_stages_spdef", type=int)
parser.add_argument("-asspe", "--actor_stages_speed", type=int)
parser.add_argument("-asa", "--actor_stages_accuracy", type=int)
parser.add_argument("-ase", "--actor_stages_evasion", type=int)
parser.add_argument("-osatt", "--opponent_stages_attack", type=int)
parser.add_argument("-osdef", "--opponent_stages_defense", type=int)
parser.add_argument("-osspa", "--opponent_stages_spatk", type=int)
parser.add_argument("-osspd", "--opponent_stages_spdef", type=int)
parser.add_argument("-osspe", "--opponent_stages_speed", type=int)
parser.add_argument("-osa", "--opponent_stages_accuracy", type=int)
parser.add_argument("-ose", "--opponent_stages_evasion", type=int)
args = vars(parser.parse_args())

# Request data goes here # https://docs.microsoft.com/azure/machine-learning/how-to-deploy-advanced-entry-script
data =  {
  "Inputs": {
    "data": [
      {
        "Column2": "example_value",
        "turnCount": args["turnCount"],
        "winner.move0.function": args["actor_move0_function"],
        "winner.move0.baseDamage": args["actor_move0_baseDamage"],
        "winner.move0.type": args["actor_move0_type"],
        "winner.move0.category": args["actor_move0_category"],
        "winner.move0.accuracy": args["actor_move0_accuracy"],
        "winner.move0.priority": args["actor_move0_priority"],
        "winner.move1.function": args["actor_move1_function"],
        "winner.move1.baseDamage": args["actor_move1_baseDamage"],
        "winner.move1.type": args["actor_move1_type"],
        "winner.move1.category": args["actor_move1_category"],
        "winner.move1.accuracy": args["actor_move1_accuracy"],
        "winner.move1.priority": args["actor_move1_priority"],
        "winner.move2.function": args["actor_move2_function"],
        "winner.move2.baseDamage": args["actor_move2_baseDamage"],
        "winner.move2.type": args["actor_move2_type"],
        "winner.move2.category": args["actor_move2_category"],
        "winner.move2.accuracy": args["actor_move2_accuracy"],
        "winner.move2.priority": args["actor_move2_priority"],
        "winner.move3.function": args["actor_move3_function"],
        "winner.move3.baseDamage": args["actor_move3_baseDamage"],
        "winner.move3.type": args["actor_move3_type"],
        "winner.move3.category": args["actor_move3_category"],
        "winner.move3.accuracy": args["actor_move3_accuracy"],
        "winner.move3.priority": args["actor_move3_priority"],
        "winner.attack": args["actor_attack"],
        "winner.spatk": args["actor_spatk"],
        "winner.spdef": args["actor_spdef"],
        "winner.totalhp": args["actor_totalhp"],
        "winner.hp": args["actor_hp"],
        "winner.stages.attack": args["actor_stages_attack"],
        "winner.stages.defense": args["actor_stages_defense"],
        "winner.stages.spatk": args["actor_stages_spatk"],
        "winner.stages.spdef": args["actor_stages_spdef"],
        "winner.stages.speed": args["actor_stages_speed"],
        "winner.stages.accuracy": args["actor_stages_accuracy"],
        "winner.stages.evasion": args["actor_stages_evasion"],
        "looser.stages.attack": args["opponent_stages_attack"],
        "looser.stages.defense": args["opponent_stages_defense"],
        "looser.stages.spatk": args["opponent_stages_spatk"],
        "looser.stages.spdef": args["opponent_stages_spdef"],
        "looser.stages.speed": args["opponent_stages_speed"],
        "looser.stages.accuracy": args["opponent_stages_accuracy"],
        "looser.stages.evasion": args["opponent_stages_evasion"]
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
