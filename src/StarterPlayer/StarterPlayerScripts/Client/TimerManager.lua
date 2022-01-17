local TimerManager = {}

local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))
local ScreenGui = R:Wait(R:GetLocalPlayerGui(), "ScreenGui")

-- Services
local ReplicatedStorage = R:Wait("ReplicatedStorage")
-- Display Values used to update Player GUI
local displayValues = R:Wait(ReplicatedStorage, "Sole.DisplayValues")
local TimeLeft = R:Wait(displayValues, "TimeLeft")

local Timer = R:Wait(ScreenGui, "ScoreFrame.Timer")
local Events = R:Wait(ReplicatedStorage, "Events")
local DisplayTimerInfo = R:Wait(Events, "DisplayTimerInfo")

-- Local Functions
local function OnTimeChanged(newValue)
	local currentTime = math.max(0, newValue)
	local minutes = math.floor(currentTime / 60)-- % 60
	local seconds = math.floor(currentTime) % 60
	Timer.Text = string.format("%02d:%02d", minutes, seconds)
end

local function OnDisplayTimerInfo(intermission, waitingForPlayers)
	Timer.Intermission.Visible = intermission
	Timer.WaitingForPlayers.Visible = waitingForPlayers
end

-- Event Binding
TimeLeft.Changed:connect(OnTimeChanged)
DisplayTimerInfo.OnClientEvent:connect(OnDisplayTimerInfo)

return TimerManager
