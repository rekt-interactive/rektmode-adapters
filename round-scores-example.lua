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
						data = {
							hours = timePlayedInterval/60/60
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
	

	local timePlayedScores = {}
	
	local sortedPlayers = {}
	
	for _, value in ipairs(PlayerRoleManager.VictimOrder) do
		table.insert(sortedPlayers, value)
	end
	
	table.sort(sortedPlayers, compareByScore)

	for i, player in pairs(sortedPlayers) do

		local playerTimePlayedScore = {
			user = {
				provider = 'roblox',
				id = player.UserId
			},
			score = {
				id = "7e67ab4c-68b5-4650-9f45-1ef0a258446f",
				data = {
					--match_id = MatchMakingMatch.CurrentMatch.matchId,
					duration = (os.time() - MatchMakingMatch.CurrentMatch.createDate)/60/60,
					place = i,
					score = player.Scores.RoundScores.Value
				}
			}
		}
		
		if i == 1  then
			
			playerTimePlayedScore.score.data.win = true
			
		end

		table.insert(timePlayedScores, playerTimePlayedScore)

	end

	RektModeApi:SubmitScores(timePlayedScores)
	
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
				data = {
					duration = (os.time() - MatchManager.LastRoundStartTime)/60/60,
					scores = player.Scores.LastRoundScores.Value,
					victim_kills = victim_kills,
					victim_survivals = victim_survivals,
					victim_escapes = victim_escapes				
				}
			}
		}

		table.insert(roundScores, playerRoundScore)

	end
	
	if #roundScores == 0 then return end

	RektModeApi:SubmitScores(roundScores)

end

return RektModeManager
