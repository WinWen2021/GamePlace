local TakeBagManager = {}
local Router = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

--service
local ReplicatedStorage = Router:Wait("ReplicatedStorage")
local ServerStorage = Router:Wait("ServerStorage")

--module
local PlayerDataManager = Router:Require(script.Parent, "PlayerDataManager")
local PlayerStorage = Router:Require(ServerStorage, "PlayerStorage")
local ResourcesManager = Router:Require(ReplicatedStorage, "Sole.Resources.ResourcesManager")
local WeaponsSystem = Router:Require(ReplicatedStorage, "WeaponsSystem.WeaponsSystem")

--Events
local BagEvents = Router:Wait(ReplicatedStorage, "Events.bag")
local GetTakeBags = Router:Wait(BagEvents, "GetTakeBags")
local ChangeTools = Router:Wait(BagEvents, "ChangeTools")
local ToolUpdated = Router:Wait(BagEvents, "ToolUpdated")
local UpdateTakeBag = Router:Wait(script, "UpdateTakeBag")
local GetNewTool = Router:Wait(script, "GetNewTool")
local UnequipToolEvent = Router:Wait(script, "UnequipTool")
local RemoveTakeBag = Router:Wait(script, "RemoveTakeBag")
local RefreshTakeBag = Router:Wait(script, "RefreshTakeBag")

local TakeBagData = {}

function TakeBagManager:UpdatePlayerTakeBagData(player)
	GetTakeBags:FireClient(player, TakeBagManager:GetPlayerTakeBagData(player))
end

--获取玩家携带背包数据
function TakeBagManager:GetPlayerTakeBagData(player)
	if not TakeBagData[player.UserId] then
		local playerData = PlayerDataManager:GetPlayerData(player)
		local takebags = {}
		for key, data in pairs(playerData.TakeBag) do
			takebags[key] = {}
			if not data or #data == 0 then continue end
			takebags[key] = PlayerStorage:GetStorageByIds(data)
		end
		TakeBagData[player.UserId] = takebags
	end
	return TakeBagData[player.UserId]
end

function TakeBagManager:RefreshTakeBagData(player)
	--卸下已装备唯一手持工具
	UnequipTool(player)
	local PlayerWeapons = player:FindFirstChild("PlayerWeapons")
	if PlayerWeapons then PlayerWeapons:Destroy() end
end

--移除玩家携带背包数据
function TakeBagManager:RemovePlayerTakeBagData(player)
	if TakeBagData[player.UserId] then
		--卸下已装备唯一手持工具
		UnequipTool(player)
		TakeBagData[player.UserId] = nil
		GetTakeBags:FireClient(player)
	end
end

function ChangeToolsToPlayer(player, tool)
	if not tool then return end
	local isOwn = false
	--检查是否拥有
	if tool.Type == PlayerStorage.Type.Weapon then
		for key, weapon in pairs(TakeBagData[player.UserId].Weapons) do
			if tool.Id == weapon.Id then
				isOwn = true
				break
			end
		end
	elseif tool.Type == PlayerStorage.Type.Grenade then
		for id, grenade in pairs(TakeBagData[player.UserId].Grenades) do
			if tool.Id == grenade.Id and grenade.Number > 0 then
				isOwn = true
				break
			end
		end
	end
	if not isOwn then
		ChangeTools:FireClient(player, nil, {isSuccess=false, message="未拥有或已使用"})
		return
	end
	
	--卸下已装备唯一手持工具
	UnequipTool(player)
	
	--装备工具
	EquipTool(player, tool)
	
end

function EquipTool(player, tool)
	--装备工具
	local ToolInstance = ResourcesManager:GetResource(tool.Path):Clone()
	ToolInstance.Name = tool.Name
	local ToolId = Instance.new("NumberValue", ToolInstance)
	ToolId.Name = "ToolId"
	ToolId.Value = tool.Id
	local ToolNumber = Instance.new("StringValue", ToolInstance)
	ToolNumber.Name = "ToolType"
	ToolNumber.Value = tool.Type


	if tool.Type == PlayerStorage.Type.Weapon then
		local PlayerWeapons = player:FindFirstChild("PlayerWeapons")
		local weapons = PlayerWeapons and PlayerWeapons:FindFirstChild(tool.Name) or nil
		if weapons then
			--更新原有子弹
			local CurrentAmmo = ToolInstance:FindFirstChild("CurrentAmmo") or Instance.new("IntValue", ToolInstance)
			CurrentAmmo.Name = "CurrentAmmo"
			CurrentAmmo.Value = weapons.CurrentAmmo.Value
			local TotalAmmo = ToolInstance:FindFirstChild("TotalAmmo") or  Instance.new("IntValue", ToolInstance)
			TotalAmmo.Name = "TotalAmmo"
			TotalAmmo.Value = weapons.TotalAmmo.Value
			weapons:Destroy()
		end

		--将工具赋予玩家
		ToolInstance.Parent = player.Character
		ChangeTools:FireClient(player, tool, {isSuccess=true, message="切换成功"})

		--如果是手雷，此为消耗品，用完即扣
	elseif tool.Type == PlayerStorage.Type.Grenade then
		
		for index, grenade in pairs(TakeBagData[player.UserId].Grenades) do
			if grenade.Id == tool.Id then

				--将工具赋予玩家
				ToolInstance.Parent = player.Character
				ChangeTools:FireClient(player, tool, {isSuccess=true, message="切换成功"})
				
				grenade.Number -= 1
				if grenade.Number <= 0 then
					ToolUpdated:FireClient(player, "Remove", tool)
					table.remove(TakeBagData[player.UserId].Grenades, index)
				else
					ToolUpdated:FireClient(player, "Update", grenade)
				end
				break
			end
		end
	end
end

function UnequipTool(player)
	--卸下已装备唯一手持工具
	for _, child in pairs(player.Character:GetChildren()) do
		if child:IsA("Tool") then
			if child.ToolId then	--如果装备ID存在，说明此工具是我们给出的物品，可替换

				ChangeTools:FireClient(player, nil, {isSuccess=true, message="装备卸下"})
				
				--将使用过的武器存入玩家武器列表
				if child.ToolType.Value == PlayerStorage.Type.Weapon then
					local PlayerWeapons = player:FindFirstChild("PlayerWeapons")
					if not PlayerWeapons then
						PlayerWeapons = Instance.new("Folder", player)
						PlayerWeapons.Name = "PlayerWeapons"
					end
					child.Parent = PlayerWeapons
					break
				elseif child.ToolType.Value == PlayerStorage.Type.Grenade then

					--归还未使用的手雷
					local isNotFind = true
					for _, grenade in pairs(TakeBagData[player.UserId].Grenades) do
						if grenade.Id == child.ToolId.Value then
							isNotFind = false
							grenade.Number += 1
							ToolUpdated:FireClient(player, "Update", grenade)
							break
						end
					end
					if isNotFind then
						local grenade = PlayerStorage:GetStorageByIds({child.ToolId.Value})[1]
						grenade.Number = 1
						table.insert(TakeBagData[player.UserId].Grenades, grenade)
						ToolUpdated:FireClient(player, "Add", grenade)
					end
					local PlayerGrenades = player:FindFirstChild("PlayerGrenades")
					if not PlayerGrenades then
						PlayerGrenades = Instance.new("Folder", player)
						PlayerGrenades.Name = "PlayerGrenades"
					end
					child.Parent = PlayerGrenades
					child:Destroy()
					break
				end
			end
		end
	end
end

GetNewTool.Event:Connect(function (player, tool)
	if not tool then return end
	--如果是武器，直接增加
	if tool.Type == PlayerStorage.Type.Weapon then
		table.insert(TakeBagData[player.UserId].Weapons, tool)
		ToolUpdated:FireClient(player, "Add", tool)
		
	--如果是手雷，如果有，增加数量，如果无，增加工具
	elseif tool.Type == PlayerStorage.Type.Grenade then

		local isAdded = false
		for id, grenade in pairs(TakeBagData[player.UserId].Grenades) do
			if tool.Id == grenade.Id and grenade.Number > 0 then
				isAdded = true
				grenade.Number += tool.Number
				ToolUpdated:FireClient(player, "Update", grenade)
				break
			end
		end
		
		if not isAdded then
			table.insert(TakeBagData[player.UserId].Grenades, tool)
			ToolUpdated:FireClient(player, "Add", tool)
		end

	end
end)

ChangeTools.OnServerEvent:Connect(ChangeToolsToPlayer)
GetTakeBags.OnServerEvent:Connect(function(player)
	TakeBagManager:UpdatePlayerTakeBagData(player)
end)
UpdateTakeBag.Event:Connect(function(player)
	TakeBagManager:UpdatePlayerTakeBagData(player)
end)
UnequipToolEvent.Event:Connect(function(player)
	--卸下已装备唯一手持工具
	UnequipTool(player)
end)
RemoveTakeBag.Event:Connect(function(player)
	TakeBagManager:RemovePlayerTakeBagData(player)
end)
RefreshTakeBag.Event:Connect(function(player)
	TakeBagManager:RefreshTakeBagData(player)
end)

Router:Wait("Players").PlayerRemoving:Connect(function(player)
	TakeBagData[player.UserId] = nil
end)

return TakeBagManager
