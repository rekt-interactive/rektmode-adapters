local RektModeApi = {}

local HttpService = game:GetService("HttpService")

local ENVS = {
	PROD = {
		BASE_URL = 'https://api.rektmode.gg'
	},
	DEV = {
		BASE_URL = 'https://null-network-backend-stage-bsu3j.ondigitalocean.app'
	},
	LOCAL = {
		BASE_URL = 'http://localhost:8000'
	}
}

local ENV = 'PROD'

local ApiKey = nil

function RektModeApi:Init(apiKey, env)
	
	ApiKey = apiKey
	
	ENV = env or ENV		
	
end

function RektModeApi:SubmitScores(scores)
	
	print('rektmode scores: ', scores)
	
	local response = HttpService:RequestAsync({
		Url = ENVS[ENV].BASE_URL..'/v1/scores', -- This website helps debug HTTP requests
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
			["x-api-key"] = ApiKey
		},
		Body = HttpService:JSONEncode({
			scores = scores
		}),
	})

	if response.Success then
		print("Scores Submit successStatus code:", response.StatusCode, response.StatusMessage)
		--print("Scores Submit Response body:\n", response.Body)
		return response.Body
	else
		print("Scores Submit request failed:", response.StatusCode, response.StatusMessage)
		return nil
	end
	
end

return RektModeApi
