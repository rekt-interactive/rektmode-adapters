local RektModeManager = {}

local RektModeApi = require(script.Parent.Parent.RektModeApi)
local CONFIG = require(game.ServerStorage.CONFIG)
local PlayerRoleManager = require(script.Parent.PlayerRoleManager)
local GameStateManager = require(script.Parent.GameStateManager)

local MatchMakingMatch = require(script.Parent.Parent.MatchMakingMatch)
local MatchManager = require(script.Parent.MatchManager)


local timePlayedInterval = 20

local inited = false

local isTimePlayedProcess = false

function RektModeManager:Initialize()
	
	RektModeApi:Init(CONFIG.REKTMODE_API_KEY)	
	
	inited = true
	
end

function RektModeManager:ProcessTimePlayed(state)

	if not inited then return end
	
	isTimePlayedProcess = state
	
	spawn(function()

		while isTimePlayedProcess do	
			
			local timePlayedScores = {}
			
			for i, player in pairs(PlayerRoleManager.VictimOrder) do
				
				local playerTimePlayedScore = {
					user = {
						provider = 'roblox',
						id = player.UserId
					},
					score = {
						id = "5fd68f44-e8cd-4429-a90a-51157ea22d35",
						attributes = {
							{
								key = 'hours',
								value = timePlayedInterval/60/60
							}
						}
					}
				}
				
				table.insert(timePlayedScores, playerTimePlayedScore)
				
			end
			
			RektModeApi:SubmitScores(timePlayedScores)
			
			wait(timePlayedInterval)
			
		end

	end)

end


local function compareByScore(a, b)
	return a.Scores.RoundScores.Value > b.Scores.RoundScores.Value
end

function RektModeManager:ProcessMatchScores()
	
	if not inited then return end
	

	local matchScores = {}
	
	local sortedPlayers = {}
	
	for _, value in ipairs(PlayerRoleManager.VictimOrder) do
		table.insert(sortedPlayers, value)
	end
	
	table.sort(sortedPlayers, compareByScore)

	for i, player in pairs(sortedPlayers) do

		local playerMatchScore = {
			user = {
				provider = 'roblox',
				id = player.UserId
			},
			score = {
				id = "7e67ab4c-68b5-4650-9f45-1ef0a258446f",
				attributes = {
					--match_id = MatchMakingMatch.CurrentMatch.matchId,
					{ 
						key = "duration",
						value = (os.time() - MatchMakingMatch.CurrentMatch.createDate)/60/60
					},
					{ 
						key = "place",
						value = i
					},
					{
						key = "score",
						value = player.Scores.RoundScores.Value
					}
				}
			}
		}
		
		if i == 1  then

			table.insert(
				playerMatchScore.score.attributes,
				{
					key = "win",
					value = true
				}
			)
			
		end

		table.insert(matchScores, playerMatchScore)

	end

	RektModeApi:SubmitScores(matchScores)
	
end



function RektModeManager:ProcessRoundScores()

	if not inited then return end
	
	if #PlayerRoleManager.VictimOrder < CONFIG.MIN_PLAYERS_TO_SCORE then

		return

	end


	local roundScores = {}


	for i, player in pairs(PlayerRoleManager.VictimOrder) do
		
		local victim_kills = 0
		
		local victim_escapes = 0
		
		local victim_survivals = 0

		if GameStateManager.GameState.Value == GameStateManager.GameStates.VictimKilled and PlayerRoleManager.CurrentKiller() == player then
			
			victim_kills = 1
			
		elseif GameStateManager.GameState.Value == GameStateManager.GameStates.VictimEscaped and PlayerRoleManager.CurrentVictim() == player then
			
			victim_escapes = 1
			
		elseif GameStateManager.GameState.Value == GameStateManager.GameStates.RoundTimeElapsed and PlayerRoleManager.CurrentVictim() == player then
			
			victim_survivals = 1
			
		end 
		

		local playerRoundScore = {
			user = {
				provider = 'roblox',
				id = player.UserId
			},
			score = {
				id = "bb078150-b1af-4a04-9991-407cfadaf3d6",
				attributes = {
					{
						key = "duration",
						value = (os.time() - MatchManager.LastRoundStartTime)/60/60
					},
					{
						key = "scores",
						value = player.Scores.LastRoundScores.Value
					},
					{
						key = "victim_kills",
						value = victim_kills
					},
					{
						key = "victim_survivals",
						value = victim_survivals
					},
					{
						key = "victim_escapes",
						value = victim_escapes
					}
				}
			}
		}

		table.insert(roundScores, playerRoundScore)

	end
	
	if #roundScores == 0 then return end

	RektModeApi:SubmitScores(roundScores)

end

return RektModeManager
