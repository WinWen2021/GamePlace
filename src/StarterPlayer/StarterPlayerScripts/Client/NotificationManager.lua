local NotificationManager = {}

local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))
local ScreenGui = R:Wait(R:GetLocalPlayerGui(), "ScreenGui")

--Module
local NoticeFrameManager = R:Require(ScreenGui, "Notification.NotificationFrame.NoticeFrameManager")

-- Local Variables
local ScoreFrame = R:Wait(ScreenGui, "ScoreFrame")
local Events = R:Wait("ReplicatedStorage.Events")
local DisplayNotification = R:Wait(Events, "DisplayNotification")
local DisplayScore = R:Wait(Events, "DisplayScore")
local Player = R:GetLocalPlayer()

-- Local Functions
local function OnDisplayNotification(notice)
	--print("通知：", notice)
	NoticeFrameManager:addNotice(notice)
end

local function OnScoreChange(team, score)
	ScoreFrame[tostring(team)].Text = score
end


-- Event Bindings
DisplayNotification.OnClientEvent:connect(OnDisplayNotification)
DisplayScore.OnClientEvent:connect(OnScoreChange)

return NotificationManager
