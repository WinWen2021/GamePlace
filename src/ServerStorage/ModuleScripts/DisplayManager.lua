local DisplayManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

local Configuration = require(ReplicatedStorage:WaitForChild("ReplicatedModule"):WaitForChild("Configuration"))
local Event = R:Require("ReplicatedStorage.EventManager")

--Event
local Events = game.ReplicatedStorage.Events
local DisplayNotification = Events.DisplayNotification
local DisplayTimerInfo = Events.DisplayTimerInfo
local DisplayScore = Events.DisplayScore
local DisplayEndResult = Events.DisplayEndResult

-- Public Functions

function DisplayManager:DisplayNotification(notice)
	DisplayNotification:FireAllClients(notice)
end

function DisplayManager:DisplayMessageNotice(message)
	local notice = {}
	notice.NoticeType = Configuration.NoticeType.MESSAGE
	notice.Message = message
	DisplayNotification:FireAllClients(notice)
end
function DisplayManager:DisplayActionNotice(playerA, action, PlayerB)
	local notice = {}
	notice.NoticeType = Configuration.NoticeType.ACTION
	notice.PlayerA = playerA
	notice.Action = action
	notice.PlayerB = PlayerB
	DisplayNotification:FireAllClients(notice)
end
function DisplayManager:DisplaySingleActionNotice(playerA, action)
	--此notice利用操作notice显示
	local notice = {}
	notice.NoticeType = Configuration.NoticeType.ACTION
	notice.PlayerA = playerA
	notice.Action = "拿下"
	local actionColor = Color3.new(1,1,1)
	--判断拿下几杀
	if action == 1 then
		action = "第一滴血"
		actionColor = Color3.new(1,0,0)
	elseif action == 2 then
		action = "双杀"
	elseif action == 3 then
		action = "三杀"
	elseif action == 4 then
		action = "四杀"
	elseif action == 5 then
		action = "五杀"
	else
		return
	end
	notice.PlayerB = {
		Name = action,
		Team = {TeamColor={Color = actionColor}}
	}
	DisplayNotification:FireAllClients(notice)
end
--玩家被分配入团队
function DisplayManager:DisplayAssignNotice(playerA)
	--此notice利用操作notice显示
	local notice = {}
	notice.NoticeType = Configuration.NoticeType.ACTION
	notice.PlayerA = playerA
	notice.Action = "被分配入"
	local actionColor = Color3.new(1,1,1)
	
	notice.PlayerB = {
		Name = playerA.Team.Name,
		Team = {TeamColor={Color = playerA.Team.TeamColor.Color}}
	}
	DisplayNotification:FireAllClients(notice)
end
function DisplayManager:DisplayTeamNotice(team, message)
	local notice = {}
	notice.NoticeType = Configuration.NoticeType.TEAM
	notice.Team = team
	notice.Message = message
	DisplayNotification:FireAllClients(notice)
end

function DisplayManager:DisplayNotificationToPlayer(player, notice)
	DisplayNotification:FireClient(player, notice)
end
function DisplayManager:DisplayMessageNoticeToPlayer(player, message)
	local notice = {}
	notice.NoticeType = Configuration.NoticeType.MESSAGE
	notice.Message = message
	DisplayNotification:FireClient(player, notice)
end


function DisplayManager:UpdateTimerInfo(isIntermission, waitingForPlayers)
	DisplayTimerInfo:FireAllClients(isIntermission, waitingForPlayers)
end

function DisplayManager:UpdateScore(team, score)
	DisplayScore:FireAllClients(team, score)
end

function DisplayManager:DisplayEndResult(player, result)
	--DisplayEndResult:FireClient(player, {["GameGold"]=2000,["TeamGold"]=600,["KillGold"]=1000})
	DisplayEndResult:FireClient(player, result)
end












return DisplayManager
