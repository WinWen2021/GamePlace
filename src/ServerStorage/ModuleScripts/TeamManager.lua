local TeamManager = {}
TeamManager.__index = TeamManager
local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

--Roblox Services
local Teams = R:Wait("Teams")
local Players = R:Wait("Players")

--Game Services
local ServerStorage = R:Wait("ServerStorage")
local ReplicatedStorage = R:Wait("ReplicatedStorage")

local WeaponsSystemFolder = R:Wait(ReplicatedStorage, "WeaponsSystem")
local WeaponsSystem = R:Require(WeaponsSystemFolder, "WeaponsSystem")

-- Modules
local moduleScripts = R:Wait(ServerStorage, "ModuleScripts")
local gameSettings = R:Require("ServerStorage.Sole.GameSettings")
local DisplayManager = R:Require(moduleScripts, "DisplayManager")
local PlayerStorage = R:Require(ServerStorage, "PlayerStorage")
local PlayerDataManager = R:Require(moduleScripts, "PlayerDataManager")

local TableCopy = R:Require(ReplicatedStorage, "ReplicatedModule.TableCopy")

--Model
local spawnLocations = R:Wait(workspace, "SpawnLocations.Teams")

-- Events
local Event = R:Require("ReplicatedStorage.EventManager")
local matchEnd = Event.ServerEvent.Match.MatchEnd

--Local Value
local TeamPlayers = {}
local TeamScores = {}
local TeamSpawns = {}
local WinnerTeam = nil
local SecondWinnerTeam = nil --平局的情况下出现第二赢家
local GameResult = nil

--Function

function TeamManager:initTeam()
	--Initialization
	WinnerTeam = nil
	SecondWinnerTeam = nil
	GameResult = nil
	
	for _, team in ipairs(Teams:GetTeams()) do
		TeamPlayers[team] = {}
		TeamScores[team] = 0
		TeamSpawns[team] = {}
	end

	for _, spawnLocation in ipairs(spawnLocations:GetChildren()) do
		for _, team in ipairs(Teams:GetTeams()) do
			if team.TeamColor == spawnLocation.TeamColor then
				--将所有同颜色的出生点放入一个Team里面
				table.insert(TeamSpawns[team],spawnLocation)
			end
		end
	end
end

TeamManager:initTeam()

function TeamManager:GetWinnerTeam()
	return WinnerTeam, SecondWinnerTeam
end

function TeamManager:OnTimeUp()
	--检测是否有队伍获胜
	local isWin, winTeam = TeamManager:HasTeamWin()
	if isWin then
		WinnerTeam = winTeam
		TeamManager:OnTeamWin(winTeam)
		return
	end
	--如果没有规则胜利的队伍，则分数多的队伍获胜
	local maxScoreTeam = nil
	local isCompared = false
	for team, score in pairs(TeamScores) do
		if not maxScoreTeam then
			maxScoreTeam = team
			continue
		end
		if maxScoreTeam and score > TeamScores[maxScoreTeam] then
			maxScoreTeam = team
			isCompared = true
		end
	end
	WinnerTeam = maxScoreTeam

	--如果没有分数多的队伍，则平局，寻找第二赢家
	local secondScoreTeam = nil
	if not isCompared then
		for team, score in pairs(TeamScores) do
			if maxScoreTeam == team then continue end
			if not secondScoreTeam then
				secondScoreTeam = team
				continue
			end
			if secondScoreTeam and score > TeamScores[secondScoreTeam] then
				secondScoreTeam = team
				isCompared = true
			end
		end
	end
	SecondWinnerTeam = secondScoreTeam
	--计算玩家得分
	TeamManager:OnTeamWin(WinnerTeam, SecondWinnerTeam and true or false)
	
end

--队伍得分
function TeamManager:TeamScoreAddedByPlayer(player, score)
	local team = TeamManager:GetTeamFromColor(player.TeamColor)
	TeamScores[team] = TeamScores[team] + score
	DisplayManager:UpdateScore(team, TeamScores[team])
	--检测是否有队伍获胜
	local isWin, winTeam = TeamManager:HasTeamWin()
	if isWin then
		WinnerTeam = winTeam
		--通知比赛结束
		matchEnd:Fire(gameSettings.endStates.FoundWinner)
		
		TeamManager:OnTeamWin(winTeam)
	end
end

function TeamManager:OnTeamWin(winTeam, isTie)
	if not isTie then isTie = false end--是否平局
	
	--发送游戏结束显示结果
	for _, players in pairs(TeamPlayers) do
		for _, player in pairs(players) do
			local isWinTeam = false
			if not isTie then
				isWinTeam = winTeam.TeamColor == player.TeamColor
			end
			local gameresult = settlementPlayer(player, isWinTeam, isTie)
			if gameresult then
				if not GameResult then
					GameResult = {}
				end
				GameResult[player] = gameresult
				savePlayerRewardData(player, gameresult.TotalReward)
			end
			--DisplayManager:DisplayEndResult(player, gameresult)
		end 
	end
end

function savePlayerRewardData(player, rewardData)
	for _, reward in pairs(rewardData) do
		if reward.Type == PlayerStorage.Type.Gold then
			PlayerDataManager:PlayerGetGold(player, reward.Number, true)
		elseif reward.Type == PlayerStorage.Type.Diamond then
			PlayerDataManager:PlayerGetDiamond(player, reward.Number, true)
		else
			--若有其他装备，再处理
		end
	end
end

function getGoldGoods(number)
	local goods = PlayerStorage:NewGoldStorage(100)
	goods.Number = number
	return goods
end
function getDiamondGoods(number)
	local goods = PlayerStorage:NewDiamondStorage(100)
	goods.Number = number
	return goods
end

function settlementPlayer(player, isWinner, isTie)
	if not isTie then isTie = false end--是否平局
	local playerTeam = TeamManager:GetTeamFromColor(player.TeamColor)
	if not playerTeam then return nil end
	
	local gameresult = {}
	gameresult.IsWinner = isWinner
	gameresult.IsTie = isTie
	
	local rewardList = {
		GameReward = {
			Title = "游戏奖励",
			Rewards = {
				{
					BasisGoods = getGoldGoods(1000),
					TotalGoods = getGoldGoods(1000),
				},
				{
					BasisGoods = getDiamondGoods(10),
					TotalGoods = getDiamondGoods(10),
				},	},
		},
		TeamReward = {
			Title = "团队奖励",
			Rewards = {
				{
					BasisGoods = getGoldGoods(100 * (#TeamPlayers[playerTeam])),
					TotalGoods = getGoldGoods(100 * (#TeamPlayers[playerTeam])),
				},	},
		},
		KillReward = {
			Title = "击败奖励",
			Rewards = {
				{
					BasisGoods = getGoldGoods(20),
					TotalGoods = getGoldGoods(0),
				}	},
		},
	}
	--计算奖励
	
	local Leaderstats = player:FindFirstChild("leaderstats")
	local SCORE_KILL = Leaderstats:FindFirstChild(gameSettings.leaderstats.SCORE_KILL)
	local SCORE_DEATH = Leaderstats:FindFirstChild(gameSettings.leaderstats.SCORE_DEATH)
	
	local otherTeamScore = 0
	local playerTeamScore = 0
	for team, score in pairs(TeamScores) do
		if team == playerTeam then
			playerTeamScore = score
			continue
		end
		otherTeamScore += score
	end
	if playerTeamScore == 0 then playerTeamScore = 1 end	--避免除0
	if otherTeamScore == 0 then otherTeamScore = 1 end		--避免除0

	local rate = SCORE_KILL.Value / playerTeamScore - SCORE_DEATH.Value / otherTeamScore
	if rate > 0 then
		local addition = {}
		addition.Title = "贡献"
		addition.Reward = "+" .. (rate*100) .."%"
		addition.Color = Color3.new(1, 0, 1) 
		if not rewardList.TeamReward.Additions then rewardList.TeamReward.Additions = {} end
		table.insert(rewardList.TeamReward.Additions, addition)
		for _, reward in pairs(rewardList.TeamReward.Rewards) do
			reward.TotalGoods.Number += reward.BasisGoods.Number * rate
		end
	end
	
	if SCORE_KILL.Value > 0 then
		local addition = {}
		addition.Title = "击败"
		addition.Reward = "x" .. SCORE_KILL.Value
		addition.Color = Color3.new(0, 0, 1) 
		if not rewardList.KillReward.Additions then rewardList.KillReward.Additions = {} end
		table.insert(rewardList.KillReward.Additions, addition)
		for _, reward in pairs(rewardList.KillReward.Rewards) do
			reward.TotalGoods.Number += reward.BasisGoods.Number * SCORE_KILL.Value
		end
	end
	
	--获得胜利，所有奖励翻倍
	if isWinner then
		local addition = {}
		addition.Title = "胜利"
		addition.Reward = "x2"
		addition.Color = Color3.new(1, 0, 0) 
		for _, rewards in pairs(rewardList) do
			if not rewards.Additions then rewards.Additions = {} end
			table.insert(rewards.Additions, addition)
			for _, reward in pairs(rewards.Rewards) do
				reward.TotalGoods.Number = reward.TotalGoods.Number * 2
			end
		end
	end
	
	gameresult.RewardList = rewardList
	
	gameresult.TotalReward = {}
	for _, rewards in pairs(rewardList) do
		for _, reward in pairs(rewards.Rewards) do
			local isAdd = false
			for _, total in pairs(gameresult.TotalReward) do
				if reward.TotalGoods.Type == total.Type then
					total.Number += reward.TotalGoods.Number
					isAdd = true
					break
				end
			end
			if not isAdd then
				table.insert(gameresult.TotalReward, TableCopy:DeepCopy(reward.TotalGoods))
			end
		end
	end
	
	return gameresult
end

function TeamManager:GetGameResult()
	return GameResult
end

function TeamManager:ResetTeamScore()
	for _, team in ipairs(Teams:GetTeams()) do
		TeamScores[team] = 0
		DisplayManager:UpdateScore(team, TeamScores[team])
	end
end

function TeamManager:GetTeamPlayers(team)
	if team then
		return TeamPlayers[team]
	end
	return TeamPlayers
end


--根据团队颜色获得团队
function TeamManager:GetTeamFromColor(teamColor)
	for _, team in ipairs(Teams:GetTeams()) do
		if team.TeamColor == teamColor then
			return team
		end
	end
	return nil
end

--重置玩家队伍状态为最初始状态
function TeamManager:ResetTeam(player, respawnLocation)
	
	TeamManager:RemovePlayer(player)
	player.Neutral = true
	if respawnLocation  then
		player.RespawnLocation = respawnLocation
	end
	
end

--检测是否有队伍胜利
function TeamManager:HasTeamWin()
	for team, score in pairs(TeamScores) do
		if score >= gameSettings.Score_To_Win then
			return true, team
		end
	end
	return false, nil
end

function TeamManager:AssignPlayerToTeam(player)
	
	local smallestTeam
	local lowestcount = math.huge
	for team, playerList in pairs(TeamPlayers) do
		if #playerList < lowestcount then
			smallestTeam = team
			lowestcount = #playerList
		end
	end
	--设置玩家队伍
	table.insert(TeamPlayers[smallestTeam], player)
	player.Neutral = false
	player.TeamColor = smallestTeam.TeamColor
	--设置玩家队伍出生点
	local spawnLocation = TeamManager:GetSpawnLocationFromColor(smallestTeam)
	player.RespawnLocation = spawnLocation
	
	return smallestTeam.TeamColor
end

--根据队伍颜色获取队伍出生点，默认随机队伍出生点，whichSpawn可设置第几个出生点
function TeamManager:GetSpawnLocationFromColor(teamColor, whichSpawn)
	if not whichSpawn then
		whichSpawn = math.random(#TeamSpawns[teamColor])
	end
	return TeamSpawns[teamColor][whichSpawn]
end

function TeamManager:RemovePlayer(player)
	local team = TeamManager:GetTeamFromColor(player.TeamColor)
	
	if not team then return end --没有找到团队
	
	local teamTable = TeamPlayers[team]
	for i = 1, #teamTable  do
		if teamTable[i] == player then
			table.remove(teamTable, i)
			break
		end
	end 
end

--重新随机分配队伍
function TeamManager:ShuffleTeams()
	for	_, team in ipairs(Teams:GetTeams()) do
		TeamPlayers[team] = {}
	end
	local players = Players:GetPlayers()
	while #players > 0 do
		local rIndex = math.random(1, #players)
		local player = table.remove(players, rIndex)
		TeamManager:AssignPlayerToTeam(player)
	end
end

WeaponsSystem.setGetTeamCallback(function(player)
	if not gameSettings.HitTeams then
		return TeamManager:GetTeamFromColor(player.TeamColor)
	end
	return 0
end)



return TeamManager
