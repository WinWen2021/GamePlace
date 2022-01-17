--R
local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

-- Services
local ServerStorage = R:Wait("ServerStorage")
local ReplicatedStorage = R:Wait("ReplicatedStorage")
local Players = R:Wait("Players")

-- Module Scripts
local moduleScripts = R:Wait(ServerStorage, "ModuleScripts")
local matchManager = R:Require(moduleScripts, "MatchManager")
local gameSettings = R:Require(moduleScripts, "GameSettings")
local PlayerManager = R:Require(moduleScripts, "PlayerManager")
local TeamManager = R:Require(moduleScripts, "TeamManager")
local displayManager = R:Require(moduleScripts, "DisplayManager")
local PlayerDataManager = R:Require(moduleScripts, "PlayerDataManager")
local TakeBagManager = R:Require(moduleScripts, "TakeBagManager")
local BlackMarketManager = R:Require(moduleScripts, "BlackMarketManager")

-- Events
local events = R:Wait(ServerStorage, "Events")
local matchEnd = R:Wait(events, "MatchEnd")

local ReplicatedStorageEvents = R:Wait(ReplicatedStorage, "Events")
local GameStartTransitionEvent = R:Wait(ReplicatedStorageEvents, "match.GameStartTransition")
local GameEndTransitionEvent = R:Wait(ReplicatedStorageEvents, "match.GameEndTransition")
local GameShowResult = R:Wait(ReplicatedStorageEvents, "match.GameShowResult")

-- Values
local GameValue = R:Wait(ReplicatedStorage, "Sole.GameValue")
local GameStatus = R:Wait(GameValue, "GameStatus")
local timeLeft = R:Wait(ReplicatedStorage, "Sole.DisplayValues.TimeLeft")

local function load(player)
	
	
end

local function save(player)
	PlayerDataManager:SavePlayer(player)
end


Players.PlayerAdded:Connect(function(player)
	print("服务器：玩家加入",player)
	load(player)

end)


--服务器停机，只有最后30秒时间保存数据
game:BindToClose(function()
	print("服务器停机")

	for _, player in ipairs(Players:GetPlayers()) do
		print("保存剩余玩家数据", player)
		coroutine.wrap(save)(player)
	end

end)


while true do
	--初始游戏状态为休息状态
	GameStatus.Value = gameSettings.GameStatus.Intermission
	repeat
		displayManager:DisplayMessageNotice("比赛开始需要至少等待"..tostring(gameSettings.minimumPlayers).."名玩家加入")
		--displayManager:DisplayMessageNotice("在此期间您可以在游戏内提前熟悉游戏场景")
		GameStatus.Value = gameSettings.GameStatus.Intermission
		for i = 1, gameSettings.intermissionDuration do
			timeLeft.Value = gameSettings.intermissionDuration - i
			wait(1)
		end
	until Players.NumPlayers >= gameSettings.minimumPlayers

	GameStatus.Value = gameSettings.GameStatus.Preparing
	--玩家准备
	matchManager.preparePlayer()
	
	GameStartTransitionEvent:FireAllClients(gameSettings.transitionTime)
	wait(gameSettings.transitionTime)
	
	GameStatus.Value = gameSettings.GameStatus.MatchStart
	matchManager.onStartMatch()
	GameStatus.Value = gameSettings.GameStatus.MatchRunning
	
	local endState = matchEnd.Event:Wait()
	
	GameStatus.Value = gameSettings.GameStatus.MatchEnd
	matchManager.onEndMatch(endState)
	
	GameStatus.Value = gameSettings.GameStatus.EndDuration
	GameEndTransitionEvent:FireAllClients(gameSettings.transitionTime)
	matchManager.cleanupMatch()
	wait(gameSettings.transitionTime)
	
	GameShowResult:FireAllClients(gameSettings.endResultDuration)
	matchManager.showMatchResult()
	wait(gameSettings.endResultDuration)
	
	--重置比赛
	matchManager.resetMatch()
	wait(gameSettings.transitionTime)
end





