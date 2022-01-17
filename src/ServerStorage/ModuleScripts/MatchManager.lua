local MatchManager = {}

local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

-- Services
local ServerStorage = R:Wait("ServerStorage")
local ReplicatedStorage = R:Wait("ReplicatedStorage")

-- Module Scripts
local moduleScripts = R:Wait(ServerStorage, "ModuleScripts")
local playerManager = R:Require(moduleScripts, "PlayerManager")
local teamManager = R:Require(moduleScripts, "TeamManager")
local gameSettings = R:Require(moduleScripts, "GameSettings")
local displayManager = R:Require(moduleScripts, "DisplayManager")
local timer = R:Require(moduleScripts, "Timer")

-- Events
local events = R:Wait(ServerStorage, "Events")
local matchStart = R:Wait(events, "MatchStart")
local matchEnd = R:Wait(events, "MatchEnd")

local GameEnd = R:Wait(ReplicatedStorage, "Events.match.GameEnd")
local GameTimeUpNotice = R:Wait(ReplicatedStorage, "Events.match.GameTimeUpNotice")

-- Values
local displayValues = R:Wait(ReplicatedStorage, "Sole.DisplayValues")
local timeLeft = R:Wait(displayValues, "TimeLeft")

-- Creates a new timer object to be used to keep track of match time. 
local myTimer = timer.new()

-- Local Functions
local function stopTimer()
	myTimer:stop()
end

local function timeUp()
	matchEnd:Fire(gameSettings.endStates.TimerUp)
end

local function startTimer()
	myTimer:start(gameSettings.matchDuration)
	myTimer.finished:Connect(timeUp)	
	local isNoticed = false

	while myTimer:isRunning() do
		-- Adding +1 makes sure the timer display ends at 1 instead of 0. 
		timeLeft.Value = (math.floor(myTimer:getTimeLeft()))
		-- By not setting the time for wait, it offers more accurate looping  
		if timeLeft.Value == 10 and not isNoticed then 
			isNoticed = true
			GameTimeUpNotice:FireAllClients(timeLeft.Value)
		end
		wait()
	end
	isNoticed = false
end

-- Module Functions
function MatchManager.prepareGame()
	matchStart:Fire()
end

function MatchManager.preparePlayer()
	playerManager.sendPlayersToMatch()
end

function MatchManager.onStartMatch()
	MatchManager.prepareGame()
	playerManager.matchStarted()
	displayManager:DisplayMessageNotice("比赛开始")
	displayManager:DisplayMessageNotice("每击败敌方团队1名玩家得1分")
	displayManager:DisplayMessageNotice("优先获得"..gameSettings.Score_To_Win.."分的团队取得比赛胜利")
end

function MatchManager.onEndMatch(endState)

	if endState == gameSettings.endStates.FoundWinner then
		local winnerTeam = teamManager:GetWinnerTeam()
		GameEnd:FireAllClients({IsTie = false, WinnerTeam=winnerTeam})
		
	elseif endState == gameSettings.endStates.TimerUp then
		teamManager:OnTimeUp()
		local winnerTeam, secondWinnerTeam = teamManager:GetWinnerTeam()
		if secondWinnerTeam then--如果有第二玩家，说明平局
			GameEnd:FireAllClients({IsTie = true, IsTimeUp = true})
		else
			GameEnd:FireAllClients({IsTie = false, IsTimeUp = true, WinnerTeam=winnerTeam})
		end
	else
		print("比赛异常结束")
		GameEnd:FireAllClients({IsTie = false})
	end
end

function MatchManager.cleanupMatch()
	--比赛结束，清理比赛
	playerManager.matchEnded()
end

function MatchManager.showMatchResult()
	playerManager.showGameResult()
end

function MatchManager.resetMatch()
	teamManager:initTeam()
	playerManager.resetPlayers()
	
end


matchStart.Event:Connect(startTimer)
matchEnd.Event:Connect(stopTimer)

return MatchManager
