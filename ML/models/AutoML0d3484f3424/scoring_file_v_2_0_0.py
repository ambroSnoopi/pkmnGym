# ---------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# ---------------------------------------------------------
import json
import logging
import os
import pickle
#import sklearn
import numpy as np
import pandas as pd
import joblib

import azureml.automl.core
from azureml.automl.core.shared import logging_utilities, log_server
from azureml.telemetry import INSTRUMENTATION_KEY
#import azureml.automl.runtime

from inference_schema.schema_decorators import input_schema, output_schema
from inference_schema.parameter_types.numpy_parameter_type import NumpyParameterType
from inference_schema.parameter_types.pandas_parameter_type import PandasParameterType
from inference_schema.parameter_types.standard_py_parameter_type import StandardPythonParameterType

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

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

logging.basicConfig(
        level = logging.INFO,
        filename = "ML\models\AutoML0d3484f3424\scoring.log",
        #encoding="utf-8",
        format = "%(asctime)-15s %(levelname)-8s %(message)s"
    )
logger = logging.getLogger('local')
logger.info(f'##################### Starting Execution with args={args}')

data = [{
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
      }]
input = {'data': data}

data_sample = PandasParameterType(pd.DataFrame({"Column2": pd.Series(["example_value"], dtype="object"), "turnCount": pd.Series([0], dtype="int8"), "winner.move0.function": pd.Series(["example_value"], dtype="object"), "winner.move0.baseDamage": pd.Series([0], dtype="int16"), "winner.move0.type": pd.Series(["example_value"], dtype="object"), "winner.move0.category": pd.Series([0], dtype="int8"), "winner.move0.accuracy": pd.Series([0], dtype="int8"), "winner.move0.priority": pd.Series([0], dtype="int8"), "winner.move1.function": pd.Series(["example_value"], dtype="object"), "winner.move1.baseDamage": pd.Series([0.0], dtype="float32"), "winner.move1.type": pd.Series(["example_value"], dtype="object"), "winner.move1.category": pd.Series([0.0], dtype="float32"), "winner.move1.accuracy": pd.Series([0.0], dtype="float32"), "winner.move1.priority": pd.Series([0.0], dtype="float32"), "winner.move2.function": pd.Series(["example_value"], dtype="object"), "winner.move2.baseDamage": pd.Series([0.0], dtype="float32"), "winner.move2.type": pd.Series(["example_value"], dtype="object"), "winner.move2.category": pd.Series([0.0], dtype="float32"), "winner.move2.accuracy": pd.Series([0.0], dtype="float32"), "winner.move2.priority": pd.Series([0.0], dtype="float32"), "winner.move3.function": pd.Series(["example_value"], dtype="object"), "winner.move3.baseDamage": pd.Series([0.0], dtype="float32"), "winner.move3.type": pd.Series(["example_value"], dtype="object"), "winner.move3.category": pd.Series([0.0], dtype="float32"), "winner.move3.accuracy": pd.Series([0.0], dtype="float32"), "winner.move3.priority": pd.Series([0.0], dtype="float32"), "winner.attack": pd.Series([0], dtype="int16"), "winner.spatk": pd.Series([0], dtype="int16"), "winner.spdef": pd.Series([0], dtype="int16"), "winner.totalhp": pd.Series([0], dtype="int16"), "winner.hp": pd.Series([0], dtype="int16"), "winner.stages.attack": pd.Series([0], dtype="int8"), "winner.stages.defense": pd.Series([0], dtype="int8"), "winner.stages.spatk": pd.Series([0], dtype="int8"), "winner.stages.spdef": pd.Series([0], dtype="int8"), "winner.stages.speed": pd.Series([0], dtype="int8"), "winner.stages.accuracy": pd.Series([0], dtype="int8"), "winner.stages.evasion": pd.Series([0], dtype="int8"), "looser.stages.attack": pd.Series([0], dtype="int8"), "looser.stages.defense": pd.Series([0], dtype="int8"), "looser.stages.spatk": pd.Series([0], dtype="int8"), "looser.stages.spdef": pd.Series([0], dtype="int8"), "looser.stages.speed": pd.Series([0], dtype="int8"), "looser.stages.accuracy": pd.Series([0], dtype="int8"), "looser.stages.evasion": pd.Series([0], dtype="int8")}))
input_sample = StandardPythonParameterType({'data': data_sample})
method_sample = StandardPythonParameterType("predict")
sample_global_params = StandardPythonParameterType({"method": method_sample})

result_sample = NumpyParameterType(np.array([0]))
output_sample = StandardPythonParameterType({'Results':result_sample})

#try:
#    log_server.enable_telemetry(INSTRUMENTATION_KEY)
#    log_server.set_verbosity('INFO')
#    logger = logging.getLogger('azureml.automl.core.scoring_script_v2')
#except:
#    pass

def init():
    global model
    # This name is model.id of model that we want to deploy deserialize the model file back into a sklearn model
    model_path = os.path.join(os.path.abspath( os.path.dirname( __file__ ) ), 'model.pkl')
    path = os.path.normpath(model_path)
    path_split = path.split(os.sep)
    log_server.update_custom_dimensions({'model_name': path_split[-3], 'model_version': path_split[-2]})
    try:
        logger.info("Loading model from path.")
        model = joblib.load(model_path)
        logger.info("Loading successful.")
    except Exception as e:
        logging_utilities.log_traceback(e, logger)
        raise


@input_schema('GlobalParameters', sample_global_params, convert_to_provided_type=False)
@input_schema('Inputs', input_sample)
@output_schema(output_sample)
def run(Inputs, GlobalParameters={"method": "predict"}):
    data = Inputs['data']
    if GlobalParameters.get("method", None) == "predict_proba":
        result = model.predict_proba(data)
    elif GlobalParameters.get("method", None) == "predict":
        result = model.predict(data)
    else:
        raise Exception(f"Invalid predict method argument received. GlobalParameters: {GlobalParameters}")
    if isinstance(result, pd.DataFrame):
        result = result.values
    return {'Results':result.tolist()}

init()
r = run(input)
print(r.get("Results")[0])
logger.info(f'##################### Finished Execution with result={r}')