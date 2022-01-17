local PlayerManager = {}

local Router = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

local ServerScriptService = Router:Wait("ServerScriptService")
local ReplicatedStorage = Router:Wait("ReplicatedStorage")
local Players = Router:Wait("Players")

--module
local GameManager = script.Parent
local Configuration = Router:Require(ReplicatedStorage, "ReplicatedModule.Configuration")
local DisplayManager = Router:Require(script.Parent, "DisplayManager")
local GameSettings = Router:Require("ServerStorage.Sole.GameSettings")
local PlayerStorage = Router:Require("ServerStorage.PlayerStorage")
local TableCopy = Router:Require(ReplicatedStorage, "ReplicatedModule.TableCopy")
local DataStoreManager = Router:Require(script.Parent, "DataStoreManager")


--Event
local Events = Router:Wait(ReplicatedStorage, "Events")
local GetTakeBags = Router:Wait(Events, "bag.GetTakeBags")
local UpdateTakeBag = Router:Wait("ServerStorage.ModuleScripts.TakeBagManager.UpdateTakeBag")

--local
local ActivePlayers = {}				--游戏内活跃玩家
local ActivePlayerStoreDatas = {}	--游戏内玩家的重要储存数据

function onPlayerAdd(player)
	print("服务器加载玩家数据", player)
	
	--获取玩家储存数据
	local playerStoreData = GetPlayerDataFromDataStore(player)
	
	--增加玩家金币数据
	local Gold = Instance.new("NumberValue", player)
	Gold.Name = "Gold"
	Gold.Value = playerStoreData.Gold
	--增加玩家钻石数据
	local Diamond = Instance.new("NumberValue", player)
	Diamond.Name = "Diamond"
	Diamond.Value = playerStoreData.Diamond
	
	playerStoreData.CurrentLoginDate = os.time()		--玩家本次登录时间
	
	--保存玩家储存数据
	ActivePlayers[player.UserId] = player
	ActivePlayerStoreDatas[player.UserId] = playerStoreData
	
	--UpdateTakeBag:Fire(player)
end

--玩家获得金币
function PlayerManager:PlayerGetGold(player, golds, disableNotice)
	local playerData = PlayerManager:GetPlayerData(player)
	playerData.Gold += golds
	player:FindFirstChild("Gold").Value = playerData.Gold
	if disableNotice then return end
	DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 金币 x"..golds)
end

--玩家获得钻石
function PlayerManager:PlayerGetDiamond(player, diamonds, disableNotice)
	local playerData = PlayerManager:GetPlayerData(player)
	playerData.Diamond += diamonds
	player:FindFirstChild("Diamond").Value = playerData.Diamond
	if disableNotice then return end
	DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 钻石 x"..diamonds)

end

--玩家获得新商品
function PlayerManager:PlayerGetNewGoods(player, goodsList, disableNotice)
	assert(player, "Player can't nil")
	assert(#goodsList >= 1, "Player can't get nil")
	
	local playerData = PlayerManager:GetPlayerData(player)
	for _, goods in pairs(goodsList) do
		
		--如果商品包含唯一属性，则判断玩家是否已拥有商品，
		if PlayerManager:CheckPlayerOwnedGoods(player, goods) then	--判断玩家是否已经拥有该商品
			playerData.Diamond += GameSettings.OwnedGoodsExchangeDiamond
			player:FindFirstChild("Diamond").Value = playerData.Diamond
			DisplayManager:DisplayMessageNoticeToPlayer(player, "已拥有 ["..goods.Name.."]，自动兑换成钻石")
			DisplayManager:DisplayMessageNoticeToPlayer(player, "获得钻石 x"..GameSettings.OwnedGoodsExchangeDiamond)
			continue
		end
		
		if goods.Type==PlayerStorage.Type.Gold then		--获得金币
			playerData.Gold += goods.Number
			player:FindFirstChild("Gold").Value = playerData.Gold
			if disableNotice then continue end
			DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 "..goods.Name.." x"..goods.Number)
			
		elseif goods.Type==PlayerStorage.Type.Diamond then		--获得钻石
			playerData.Diamond += goods.Number
			player:FindFirstChild("Diamond").Value = playerData.Diamond
			if disableNotice then continue end
			DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 "..goods.Name.." x"..goods.Number)
			
		elseif goods.Type==PlayerStorage.Type.Weapon then		--获得武器
			table.insert(playerData.Bag.Weapons, goods.Id)
			if disableNotice then continue end
			DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 ["..goods.Name.."]")
			
		elseif goods.Type==PlayerStorage.Type.Grenade then		--获得手雷
			table.insert(playerData.Bag.Grenades, goods.Id)
			if disableNotice then continue end
			DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 ["..goods.Name.."]")
			
		elseif goods.Type==PlayerStorage.Type.Ammo then		--获得弹药
			table.insert(playerData.Bag.Ammos, goods.Id)
			if disableNotice then continue end
			DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 ["..goods.Name.."]")

		elseif goods.Type==PlayerStorage.Type.Equipment then		--获得装备
			table.insert(playerData.Bag.Equipments, goods.Id)
			if disableNotice then continue end
			DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 ["..goods.Name.."]")
			
		elseif goods.Type==PlayerStorage.Type.Character then		--获得角色
			table.insert(playerData.Bag.Characters, goods.Id)
			if disableNotice then continue end
			DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 ["..goods.Name.."]")
		end
	end
	
end

--检查玩家是否拥有
function PlayerManager:CheckPlayerOwnedGoods(player, goods)
	--如果商品包含唯一属性，则判断玩家是否已拥有商品，
	if goods.Unique then
		local playerData = PlayerManager:GetPlayerData(player)
		for _, playerBag in pairs(playerData.Bag) do
			for _, id in pairs(playerBag) do
				if id == goods.Id then
					return true
				end
			end
		end
	end
	return false
end

--public
function PlayerManager:GetPlayerData(player)
	return ActivePlayerStoreDatas[player.UserId]
end

function PlayerManager:GetActivePlayers()
	return ActivePlayers
end


function onPlayerRemover(player)
	--print("服务器：玩家移除",player)
	local playerData = PlayerManager:GetPlayerData(player)
	if not playerData then return end
	--记录
	playerData.LastLoginDate = playerData.CurrentLoginDate		--玩家上一次登录时间
	playerData.LastLeaveDate = os.time()						--玩家上一次离开时间

	coroutine.wrap(save)(player)
end


--保存玩家储存数据
--异步调用
function save(player)
	ActivePlayers[player.UserId] = nil--移除活跃玩家数据
	local succ, err 
	local count = 1
	repeat
		succ, err = PlayerManager:SavePlayer(player)
		if succ then
			ActivePlayerStoreDatas[player.UserId] = nil
		else
			wait(6 + count * 2)
		end
		count = count + 1
	until succ or count > 3
end
function PlayerManager:SavePlayer(player)
	local playerData = PlayerManager:GetPlayerData(player)
	if not playerData then return end
	--深复制玩家数据，进行保存
	local newCopidPlayerData = TableCopy:DeepCopy(playerData)
	return SavePlayerDataToDataStore(player, newCopidPlayerData)
end


--只用于新玩家初始化玩家数据
function initPlayerData()
	local PlayerData = {}
	PlayerData.Gold = 0							--玩家金币
	PlayerData.Diamond = 0						--玩家钻石
	PlayerData.Bag = {							--玩家背包
		Weapons = {},					--武器
		Grenades = {},					--手雷
		Ammos = {},				--弹药
		Equipments = {},				--装备	
		Characters = {},				--角色
	}							
	PlayerData.TakeBag = {						--玩家携带背包
		Weapons = {},					--武器
		Grenades = {},					--手雷
		Ammos = {},				--弹药
		Equipments = {},				--装备	
		Characters = {},				--角色
	}						
	PlayerData.NewPlayerGift = true				--新玩家注册礼
	PlayerData.RegisterDate = os.time()			--玩家注册时间
	PlayerData.CurrentLoginDate = os.time()		--玩家本次登录时间
	PlayerData.LastLoginDate = os.time()		--玩家上一次登录时间
	PlayerData.LastLeaveDate = os.time()		--玩家上一次离开时间

	return PlayerData
end

function GetPlayerDataFromDataStore(player)
	--获得玩家数据
	local playerData, success = DataStoreManager:GetDataFromDataStore(player, DataStoreManager.DataType.PlayerData)
	--判断是否为新玩家
	if success and (not playerData or not playerData.RegisterDate) then
		playerData = initPlayerData() -- 初始玩家数据
	end
	return playerData
end

function SavePlayerDataToDataStore(player, playerData)
	local success, err = DataStoreManager:SaveDataToDataStore(player, DataStoreManager.DataType.PlayerData, playerData)
	if not success then --如果保存数据失败，再保存一遍
		print("数据保存失败，重新保存", player, playerData)
		success, err = DataStoreManager:SaveDataToDataStore(player, DataStoreManager.DataType.PlayerData, playerData)
	end
	return success, err
end

Players.PlayerAdded:Connect(onPlayerAdd)
Players.PlayerRemoving:Connect(onPlayerRemover)

return PlayerManager
