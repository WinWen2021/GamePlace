local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

-- Local Variables

local Events = R:Wait("ReplicatedStorage.Events")
local Player = R:GetLocalPlayer()
local ScreenGui = R:Wait(script.Parent, "Gui.ScreenGui")
local ShopGui = R:Wait(script.Parent, "Gui.ShopGui")
local TurnToBasePlaceGui = R:Wait(script.Parent, "Gui.TurnToBasePlaceGui")

game.StarterGui.ResetPlayerGuiOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ShopGui.Parent = Player:WaitForChild("PlayerGui")
TurnToBasePlaceGui.Parent = Player:WaitForChild("PlayerGui")

-- Game Services
local NotificationManager = R:Require(script, "NotificationManager")
local TimerManager = R:Require(script, "TimerManager")
local ResultManager = R:Require(script, "ResultManager")

local Toast = R:Require("ReplicatedStorage.ReplicatedModule.Toast")

local GameStartTransitionEvent = R:Wait(Events, "match.GameStartTransition")
local GameEndTransitionEvent = R:Wait(Events, "match.GameEndTransition")
local GameTimeUpNotice = R:Wait(Events, "match.GameTimeUpNotice")
local GameEnd = R:Wait(Events, "match.GameEnd")

local Sound = R:Wait("ReplicatedStorage.Sole.Sound")

local TimeUpToast = nil

GameStartTransitionEvent.OnClientEvent:Connect(function(duration)
	
	local content = {}
	for i=duration, 1, -1 do
		if i == duration then
			table.insert(content, "准备")
		elseif i==1 then
			--table.insert(content, "Go")
		else
			table.insert(content, tostring(i-1))
		end
	end
	
	Toast.new().setOnStarted(function(index)
		if index == 1 then
			Sound.male.male_ready:Play()
		elseif index == 2 then
			Sound.male.male_3:Play()
		elseif index == 3 then
			Sound.male.male_2:Play()
		elseif index == 4 then
			Sound.male.male_1:Play()
		end
	end)
	.show(content, 1, 50)
	wait(duration-1+0.1)
	Toast.new().setOnStarted(function(index)
		Sound.male.male_go:Play()
	end)
	.show("Go", 1, 80)
	
end)

GameTimeUpNotice.OnClientEvent:Connect(function(duration)

	local content = {}
	for i=duration, 0, -1 do
		if i == 0 then
			table.insert(content, " ")
		else
			table.insert(content, tostring(i))
		end
	end

	TimeUpToast = Toast.new().setOnStarted(function(index)
		if index == duration + 1 then
			Sound.common.countdown_end:Play()
		else
			Sound.common.countdown:Play()
		end
	end)
	.show(content, 1, 50)

end)

GameEnd.OnClientEvent:Connect(function(result)
	if TimeUpToast then
		TimeUpToast.destroy()
	end
	Toast.new().setOnStarted(function(index)
		if result and result.IsTimeUp then
			Sound.male.male_time_over:Play()
		else
			Sound.male.male_game_over:Play()
		end
	end)
	.show("游戏结束", 1.5, 50)
	wait(1.8)
	if result then
		local toast = Toast.new()
		if result.IsTie then
			toast.show("平局", 3, 80, Color3.new(0,0,1))
		else
			toast.show({{result.WinnerTeam.Name, "获胜"}}, 3, 80
			, {{result.WinnerTeam.TeamColor.Color, Color3.new(1,1,1)}})
		end
	end
	
end)
