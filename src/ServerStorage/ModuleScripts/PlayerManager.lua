local PlayerManager = {}

local Router = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

-- Services
local Players = Router:Wait("Players")
local ServerStorage = Router:Wait("ServerStorage")
local ReplicatedStorage = Router:Wait("ReplicatedStorage")

local WeaponsSystem = Router:Require(ReplicatedStorage, "WeaponsSystem.WeaponsSystem")

-- Modules
local moduleScripts = Router:Wait(ServerStorage, "ModuleScripts")
local gameSettings = Router:Require("ServerStorage.Sole.GameSettings")
local teamManager = Router:Require(moduleScripts, "TeamManager")
local DisplayManager = Router:Require(moduleScripts, "DisplayManager")

local TeleportManager = Router:Require(moduleScripts, "TeleportManager")
local Utils = Router:Require(ReplicatedStorage, "ReplicatedModule.Utils")

-- Events
local events = Router:Wait(ServerStorage, "Events")
local matchEnd = Router:Wait(events, "MatchEnd")

-- Variables
local lobbySpawn = Router:Wait("Workspace.SpawnLocations.Lobby.StartSpawn")

-- Values
local displayValues = Router:Wait(ReplicatedStorage, "Sole.DisplayValues")
local playersLeft = Router:Wait(displayValues, "PlayersLeft")
local GameStatus = Router:Wait(ReplicatedStorage, "Sole.GameValue.GameStatus")

local UpdateTakeBag = Router:Wait(script.Parent, "TakeBagManager.UpdateTakeBag")
local UnequipToolEvent = Router:Wait(script.Parent, "TakeBagManager.UnequipTool")
local RefreshTakeBag = Router:Wait(script.Parent, "TakeBagManager.RefreshTakeBag")
local RemoveTakeBag = Router:Wait(script.Parent, "TakeBagManager.RemoveTakeBag")

local ActivePlayers = {}
local isFirstBlood = true --第一滴血是否还存在

function PlayerManager.initPlayer()
	ActivePlayers = {}
	isFirstBlood = true
end

local function checkPlayerCount()
	if #Players:GetPlayers() == 0 then
		matchEnd:Fire(gameSettings.endStates.FoundWinner)
		print("游戏中已无玩家，重置游戏")
	end
end

local function removeActivePlayer(player)
	for playerKey, whichPlayer in pairs(ActivePlayers) do
		if whichPlayer == player then
			table.remove(ActivePlayers, playerKey)
			--playersLeft.Value = #ActivePlayers
			checkPlayerCount()
		end
	end
end

--玩家重生
local function onCharacterAdded(character)
	--禁止玩家解体
	local Humanoid = character:FindFirstChild("Humanoid")
	Humanoid.BreakJointsOnDeath = false
	
	local player = Players:GetPlayerFromCharacter(character)
	--print("分配武器")
	UpdateTakeBag:Fire(player)
	
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		if not gameSettings.playerCanReSpawn then --如果不支持玩家重生，则送死亡的玩家返回大厅
			--返回城镇
		end
		wait(1)
		character:Destroy()
	end)
end

local function preparePlayer(player)
	--player.RespawnLocation = whichSpawn
	teamManager:AssignPlayerToTeam(player)
	
	--设置玩家排行榜
	PlayerManager.setPlayerLeaderstats(player, 0, 0)
	
	RefreshTakeBag:Fire(player)
	--UnequipToolEvent:Fire(player)
	player:LoadCharacter()
end

--玩家中途掉线或退出
local function OnPlayerRemoving(player)
	
	--更新游戏内玩家数量
	playersLeft.Value = #Players:GetPlayers()
	
	--玩家掉线或退出，保持该玩家所获得的分数，维持游戏平衡
	removeActivePlayer(player)
	--如果游戏正在比赛中，则通知团队成员，队友离开
	if GameStatus.Value == gameSettings.GameStatus.MatchRunning then
		local teamPlayers = teamManager:GetTeamPlayers(teamManager:GetTeamFromColor(player.TeamColor))
		for _, tplayer in pairs(teamPlayers) do
			DisplayManager:DisplayMessageNoticeToPlayer(tplayer, "您的队友 ["..player.Name.."] 退出了游戏")
		end
	end
end

local function onPlayerJoin(player)
	
	--更新游戏内玩家数量
	playersLeft.Value = #Players:GetPlayers()
	player.CharacterAdded:Connect(onCharacterAdded)
	
	local GameStatus = GameStatus.Value
	--游戏正在准备阶段，玩家可服从系统安排
	if GameStatus <= gameSettings.GameStatus.Preparing then
		DisplayManager:DisplayMessageNotice("欢迎 ["..player.Name.."] 加入游戏")
		DisplayManager:DisplayMessageNoticeToPlayer(player, "请等待其他玩家加入")
		DisplayManager:DisplayMessageNoticeToPlayer(player, "在此期间您可以在游戏内提前熟悉游戏场景")
		
		player.RespawnLocation = lobbySpawn

		--设置玩家排行榜
		PlayerManager.setPlayerLeaderstats(player, 0, 0)
	--游戏正在进行中，指派队伍
	elseif GameStatus <= gameSettings.GameStatus.MatchRunning then
		
		DisplayManager:DisplayMessageNotice("欢迎 ["..player.Name.."] 加入游戏")
		PlayerManager.insertPlayerToMatch(player)
		DisplayManager:DisplayAssignNotice(player)
		
	--游戏已结束，通知玩家返回，加入下一场游戏
	elseif GameStatus <= gameSettings.GameStatus.EndDuration then
		DisplayManager:DisplayMessageNoticeToPlayer(player, "对不起，你来晚了，本局比赛已结束！")
		DisplayManager:DisplayMessageNoticeToPlayer(player, "请返回基地，重新加入下一局比赛。")
		player.RespawnLocation = lobbySpawn
	end
	
end

--中途加入玩家
function PlayerManager.insertPlayerToMatch(player)

	table.insert(ActivePlayers,player)
	preparePlayer(player)
	
	--playersLeft.Value = #ActivePlayers
end

function PlayerManager.sendPlayersToMatch()
	
	for playerKey, player in pairs(Players:GetPlayers()) do
		table.insert(ActivePlayers,player)
		preparePlayer(player)
		
		Utils:FreezePlayerMove(player)
	end

	--playersLeft.Value = #ActivePlayers
end
function PlayerManager.matchStarted()
	for playerKey, player in pairs(Players:GetPlayers()) do
		Utils:UnfreezePlayerMove(player)
	end
	
end
function PlayerManager.matchEnded()
	for playerKey, player in pairs(Players:GetPlayers()) do
		Utils:FreezePlayerMove(player)
	end

end
function PlayerManager.showGameResult()
	for playerKey, player in pairs(Players:GetPlayers()) do
		Utils:UnfreezePlayerMove(player)
		RemoveTakeBag:Fire(player)
	end
	local GameResult = teamManager:GetGameResult()
	if not GameResult then return end
	for player, result in pairs(GameResult) do
		DisplayManager:DisplayEndResult(player, result)
	end
end

function PlayerManager.resetPlayers()
	PlayerManager.initPlayer()
	teamManager:ResetTeamScore()
	
	--将所有玩家清场
	TeleportManager.onTeleportPlayersToBasePlace(Players:GetPlayers())
end

--设置玩家排行榜分数
function newPlayerLeaderstats(player)

	--创建分数
	local Leaderstats = Instance.new("IntValue", player)
	Leaderstats.Name = "leaderstats"
	
	local SCORE_KILL = Instance.new("IntValue", Leaderstats)
	SCORE_KILL.Name = gameSettings.leaderstats.SCORE_KILL
	SCORE_KILL.Value = 0
	
	local SCORE_DEATH = Instance.new("IntValue", Leaderstats)
	SCORE_DEATH.Name = gameSettings.leaderstats.SCORE_DEATH
	SCORE_DEATH.Value = 0
	return Leaderstats
end

--设置玩家排行榜分数
function PlayerManager.setPlayerLeaderstats(player, killScore, deathScore, stack)

	local Leaderstats = player:FindFirstChild("leaderstats")
	
	if not Leaderstats then
		Leaderstats = newPlayerLeaderstats(player)
	end
	
	local SCORE_KILL = Leaderstats:FindFirstChild(gameSettings.leaderstats.SCORE_KILL)
	local SCORE_DEATH = Leaderstats:FindFirstChild(gameSettings.leaderstats.SCORE_DEATH)
	
	if stack then
		SCORE_KILL.Value = SCORE_KILL.Value + (killScore or 0)
		SCORE_DEATH.Value = SCORE_DEATH.Value + (deathScore or 0)
	else
		SCORE_KILL.Value = killScore
		SCORE_DEATH.Value = deathScore
	end
end

function PlayerManager.removePlayerLeaderstats(player)
	local Leaderstats = player:FindFirstChild("leaderstats")
	if not Leaderstats then return end
	local SCORE_KILL = Leaderstats:FindFirstChild(gameSettings.leaderstats.SCORE_KILL)
	local SCORE_DEATH = Leaderstats:FindFirstChild(gameSettings.leaderstats.SCORE_DEATH)
	SCORE_KILL.Value = 0
	SCORE_DEATH.Value = 0
end

function PlayerManager.addPlayerKillScore(player, killScore)
	PlayerManager.setPlayerLeaderstats(player, killScore, 0, true)
	--击杀分数为团队有效分数
	teamManager:TeamScoreAddedByPlayer(player, killScore)
end

function PlayerManager.addPlayerDeathScore(player, deathScore)
	PlayerManager.setPlayerLeaderstats(player, 0, deathScore, true)
end

--玩家受到手雷伤害回调
local GrenadeDoDamage = Router:Wait("ServerStorage.Events.GrenadeDoDamage")
GrenadeDoDamage.Event:Connect(function(target, amount, damageType, dealer)
	--onDamage(nil, target, amount, damageType, dealer, nil, nil)
	if target:IsA("Humanoid") then
		if target.Health <= 0 then return end--已经死亡的玩家不再收到伤害
		--if target.Parent.Name == dealer.Name then return end	--如果是自己攻击自己，不受伤害
		if GameStatus.Value == gameSettings.GameStatus.MatchRunning then
			target:TakeDamage(amount)	--只有在游戏比赛中可以发生伤害
		end
		if target.Health <= 0 then--玩家受伤害后死亡
			onPlayerDamageDaeth(nil, target, amount, damageType, dealer)
		end
	end
end)

--玩家受到武器攻击回调
function onDamageCallback(system, target, amount, damageType, dealer, hitInfo, damageData)
	--onDamage(system, target, amount, damageType, dealer, hitInfo, damageData)
	if target:IsA("Humanoid") then
		if target.Health <= 0 then return end--已经死亡的玩家不再收到伤害
		if target.Parent.Name == dealer.Name then return end	--如果是自己攻击自己，不受伤害
		if GameStatus.Value == gameSettings.GameStatus.MatchRunning then
			target:TakeDamage(amount)	--只有在游戏比赛中可以发生伤害
		end
		if target.Health <= 0 then--玩家受伤害后死亡
			onPlayerDamageDaeth(system, target, amount, damageType, dealer, hitInfo, damageData)
		end
	end
end

--玩家受到攻击死亡
function onPlayerDamageDaeth(system, target, amount, damageType, dealer, hitInfo, damageData)
	
	local targetPlayer = nil
	local killerPlayer = nil
	
	for playerKey, whichPlayer in pairs(ActivePlayers) do
		if whichPlayer == dealer then
			killerPlayer = whichPlayer
		end
		if whichPlayer.Name == target.Parent.Name then
			targetPlayer = whichPlayer
		end
		if targetPlayer and killerPlayer then break end
	end
	
	--显示击败测试NPC
	if killerPlayer and not targetPlayer and target.Parent.Name == "TestNPC" then
		DisplayManager:DisplayActionNotice(killerPlayer, "击败", target.Parent)
		isPlayerGetFirstBlood(killerPlayer)
		PlayerManager.addPlayerKillScore(killerPlayer, 1)
	end
	
	if targetPlayer and killerPlayer and targetPlayer ~= killerPlayer then 
		--先通知
		DisplayManager:DisplayActionNotice(killerPlayer, "击败", targetPlayer)
		isPlayerGetFirstBlood(killerPlayer)
		PlayerManager.addPlayerKillScore(killerPlayer, 1)
		PlayerManager.addPlayerDeathScore(targetPlayer, 1)
	end
	
end

function isPlayerGetFirstBlood(player)
	if isFirstBlood then
		DisplayManager:DisplaySingleActionNotice(player, 1)
		isFirstBlood = false
	end
end


--设置武器系统玩家受到攻击回调
WeaponsSystem.setDamageCallback(onDamageCallback)
Players.PlayerAdded:Connect(onPlayerJoin)
Players.PlayerRemoving:connect(OnPlayerRemoving)

return PlayerManager
