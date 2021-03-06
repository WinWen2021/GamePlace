local MatchManager = {}

local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

-- Services
local ServerStorage = R:Wait("ServerStorage")
local ReplicatedStorage = R:Wait("ReplicatedStorage")

-- Module Scripts
local moduleScripts = R:Wait(ServerStorage, "ModuleScripts")
local playerManager = R:Require(moduleScripts, "PlayerManager")
local teamManager = R:Require(moduleScripts, "TeamManager")
local gameSettings = R:Require("ServerStorage.Sole.GameSettings")
local displayManager = R:Require(moduleScripts, "DisplayManager")
local timer = R:Require(moduleScripts, "Timer")

-- Events
local Event = R:Require("ReplicatedStorage.EventManager")
local matchEnd = Event.ServerEvent.Match.MatchEnd
local matchStart = Event.ServerEvent.Match.MatchStart

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
	displayManager:DisplayMessageNotice("????????????")
	displayManager:DisplayMessageNotice("?????????????????????1????????????1???")
	displayManager:DisplayMessageNotice("????????????"..gameSettings.Score_To_Win.."??????????????????????????????")
end

function MatchManager.onEndMatch(endState)

	if endState == gameSettings.endStates.FoundWinner then
		local winnerTeam = teamManager:GetWinnerTeam()
		GameEnd:FireAllClients({IsTie = false, WinnerTeam=winnerTeam})
		
	elseif endState == gameSettings.endStates.TimerUp then
		teamManager:OnTimeUp()
		local winnerTeam, secondWinnerTeam = teamManager:GetWinnerTeam()
		if secondWinnerTeam then--????????????????????????????????????
			GameEnd:FireAllClients({IsTie = true, IsTimeUp = true})
		else
			GameEnd:FireAllClients({IsTie = false, IsTimeUp = true, WinnerTeam=winnerTeam})
		end
	else
		print("??????????????????")
		GameEnd:FireAllClients({IsTie = false})
	end
end

function MatchManager.cleanupMatch()
	--???????????????????????????
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
