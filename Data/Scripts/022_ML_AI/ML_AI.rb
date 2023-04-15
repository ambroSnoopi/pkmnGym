require 'socket'

# Interface to a trained ML Model
#TODO: This is W.I.P.!
class ML_AI

    ONLINE_AI       = true #Setting::ONLINE_AI

    ONLINE_MOVE_AI  = 'maram-ml-kpwft.northeurope.inference.ml.azure.com'
    API_KEY         = 'i0d8pBfcE0hXEMVDQLJXRaNg81iS1hxy' 
    DEPLOYMENT      = 'automl0d3484f3424-1'

    LOCAL_MOVE_AI   = 'ML/models/dummy/echo-score.py'

    ML_AI_DICT      = {
        'online' => {
            'action' =>{},
            'move'   => {'url' => 'https://maram-ml-kpwft.northeurope.inference.ml.azure.com/score',
                            'api_key' => 'i0d8pBfcE0hXEMVDQLJXRaNg81iS1hxy', #TODO: use secrets file
                            'deployment' => 'automl0d3484f3424-1'},
            'switch' => {}},
        'local'  => {
            'action' =>{},
            'move'   => {'url' => 'ML/models/dummy/echo-score.py'},
            'switch' => {}}
        }

    def initialize(online=ONLINE_AI)
        @online = online
    end



    def self.runTest(data = "{}")
        #if @online
        #TODO: transform into string
        data =  '{
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
          }'
            body = data

            header = "Content-Type: application/json, Authorization: Bearer #{API_KEY}, azureml-model-deployment: automl0d3484f3424-1\r\n"
            
            socket = TCPSocket.open(ONLINE_MOVE_AI, 443)
            socket.puts "POST score/ HTTPS/1.1\r\n"
            socket.puts header
            #socket.puts "\r\n"
            socket.puts body
            socket.puts "\r\n"

            response = ''
            while line = s.gets
              puts line.chop
                #response << line.chop
            end
            #echoln response
            socket.close
            return response
        #end
    end

    def self.testSocket

        # Parse the URL to get the host and path
        host = 'www.google.com'
        port = 80

        s = TCPSocket.open(host, port)
        s.puts "GET / HTTP/1.1\r\n"
        s.puts "\r\n"

        while line = s.gets
            puts line.chop
        end

        s.close

        # Print the response to the console
        echoln response
    end

    def self.testBingGPT
      require 'socket'

data =  '{
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
          }'

# Send the HTTP request
socket = TCPSocket.open('maram-ml-kpwft.northeurope.inference.ml.azure.com', 443)
request = "POST maram-ml-kpwft.northeurope.inference.ml.azure.com HTTP/1.1\r\n"
request += "Host: maram-ml-kpwft.northeurope.inference.ml.azure.com\r\n"
request += "Content-Type: application/json\r\n"
#request += "Content-Type: application/x-www-form-urlencoded\r\n"
request += "Authorization: Bearer i0d8pBfcE0hXEMVDQLJXRaNg81iS1hxy\r\n"
request += "azureml-model-deployment: automl0d3484f3424-1"
#request += "Content-Length: #{data.bytesize}\r\n"
request += "\r\n"
request += data
socket.print(request)

# Get the response
response = ""
while line = socket.gets
  response += line
end

# Close the socket
socket.close

puts response


# Parse the response
headers, body = response.split("\r\n\r\n")
response_data = JSON.parse(body)

# Print the response
puts response_data
    end
end

