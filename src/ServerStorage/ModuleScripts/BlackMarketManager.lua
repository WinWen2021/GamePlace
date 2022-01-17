local ShopManager = {}
local Router = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))

--server


--modelscript
local PlayerStorage = Router:Require("ServerStorage.PlayerStorage")
local PlayerManager = Router:Require(script.Parent, "PlayerDataManager")
local GameSettings = Router:Require(script.Parent, "GameSettings")
local TakeBagManager = Router:Require(script.Parent, "TakeBagManager")
local DisplayManager = Router:Require(script.Parent, "DisplayManager")

--event
local shopEvents = Router:Wait("ReplicatedStorage.Events.shop")
local GetShopGoods = Router:Wait(shopEvents, "GetShopGoods")
local BuyGoods = Router:Wait(shopEvents, "BuyGoods")
local UpdateTakeBag = Router:Wait(script.Parent, "TakeBagManager.UpdateTakeBag")
local GetNewTool = Router:Wait(script.Parent, "TakeBagManager.GetNewTool")

local PlayerMenus = {}
Router:Wait("Players").PlayerRemoving:Connect(function(player)
	PlayerMenus[player] = nil
end)


function getAmmoStorageData(BulletType)
	local ammos = PlayerStorage:GetStorageDataByType(PlayerStorage.Type.Ammo)
	for _, ammo in pairs(ammos) do
		if ammo.BulletType == BulletType then
			return ammo
		end
	end
end

function findHandWeapon(player)
	--手持武器
	for _, child in pairs(player.Character:GetChildren()) do
		if child:IsA("Tool") and child.ToolType and child.ToolType.Value == PlayerStorage.Type.Weapon then
			return child
		end
	end
	return nil
end

function onGetShopGoods(player)
	local Grenades = PlayerStorage:GetStorageDataByType(PlayerStorage.Type.Grenade)
	--购买一组手雷3个
	for _, grenade in pairs(Grenades) do
		grenade.Number = grenade.Number * GameSettings.GrenadeGroup
		grenade.Price = grenade.Price * GameSettings.GrenadeGroup
		grenade.BlackMarketPrice = grenade.BlackMarketPrice * GameSettings.GrenadeGroup
	end
	
	--菜单列表
	local Menu = {
		{Name = "武器", goods=PlayerStorage:GetStorageDataByType(PlayerStorage.Type.Weapon),},
		{Name = "手雷", goods=Grenades,},
	}
	PlayerMenus[player] = Menu
	
	local HandWeapon = findHandWeapon(player)
	local blackMarketPrice = 0
	if HandWeapon then
		local maxAmmo = HandWeapon.Configuration.AmmoTotalCapacity.Value
		local currentAmmo = HandWeapon.CurrentAmmo.Value
		local totalAmmo = HandWeapon.TotalAmmo.Value
		local xAmmo = maxAmmo - (totalAmmo + currentAmmo)
		
		if xAmmo > 0 then
			local weapon = PlayerStorage:GetStorageByIds({HandWeapon.ToolId.Value})[1]
			local ammo = getAmmoStorageData(weapon.BulletType)
			blackMarketPrice += ammo.BlackMarketPrice * xAmmo
			local goods = {Name = "手持武器弹药", Id=111, PriceType=PlayerStorage.PriceType.GOLD, BlackMarketPrice=blackMarketPrice}
			table.insert(Menu, goods)
		end
	end
	
	local PlayerWeapons = player:FindFirstChild("PlayerWeapons")
	if PlayerWeapons then
		for _, child in pairs(PlayerWeapons:GetChildren()) do
			if child:IsA("Tool") and child.ToolType and child.ToolType.Value == PlayerStorage.Type.Weapon then
				local maxAmmo = child.Configuration.AmmoTotalCapacity.Value
				local currentAmmo = child.CurrentAmmo.Value
				local totalAmmo = child.TotalAmmo.Value
				local xAmmo = maxAmmo - (totalAmmo + currentAmmo)
				if xAmmo > 0 then
					local weapon = PlayerStorage:GetStorageByIds({child.ToolId.Value})[1]
					local ammo = getAmmoStorageData(weapon.BulletType)
					blackMarketPrice += ammo.BlackMarketPrice * xAmmo
				end
				
			end
		end
	end
	if blackMarketPrice > 0 then
		local goods = {Name = "所有武器弹药", Id=112, PriceType=PlayerStorage.PriceType.GOLD, BlackMarketPrice=blackMarketPrice}
		table.insert(Menu, goods)
	end
	
	if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health < 100 then
		local goods = {Name = "恢复生命", Id=113, PriceType=PlayerStorage.PriceType.GOLD, BlackMarketPrice=100}
		table.insert(Menu, goods)
	end
	GetShopGoods:FireClient(player, Menu)
end

function onBuyGoodsFromBlackMarket(player, goods, acceptSecondPrice)
	local mGoods = nil
	for _, m in pairs(PlayerMenus[player]) do
		if m.Id == goods.Id then
			mGoods = m
			break
		elseif m.goods then
			for _, m2 in pairs(m.goods) do
				if m2.Id == goods.Id then
					mGoods = m2
				end
			end
		end
	end
	if not mGoods then
		DisplayManager:DisplayMessageNoticeToPlayer(player, "商品不存在")
		return
	end
	local TakeBagData = TakeBagManager:GetPlayerTakeBagData(player)

	
	--处理商品
	if mGoods.Id == 111 then
		local HandWeapon = findHandWeapon(player)
		if HandWeapon then
			if not paymentForBlackMarket(player, mGoods) then return end	--支付
			local maxAmmo = HandWeapon.Configuration.AmmoTotalCapacity.Value
			local currentAmmo = HandWeapon.CurrentAmmo.Value
			HandWeapon.TotalAmmo.Value = maxAmmo - currentAmmo
			DisplayManager:DisplayMessageNoticeToPlayer(player, "手持武器弹药已填充")
		end
		BuyGoods:FireClient(player, {isSuccess=true})
		
	elseif mGoods.Id == 112 then
		if not paymentForBlackMarket(player, mGoods) then return end	--支付
		local HandWeapon = findHandWeapon(player)
		if HandWeapon then
			local maxAmmo = HandWeapon.Configuration.AmmoTotalCapacity.Value
			local currentAmmo = HandWeapon.CurrentAmmo.Value
			HandWeapon.TotalAmmo.Value = maxAmmo - currentAmmo
		end
		local PlayerWeapons = player:FindFirstChild("PlayerWeapons")
		if PlayerWeapons then
			for _, child in pairs(PlayerWeapons:GetChildren()) do
				if child:IsA("Tool") and child.ToolType and child.ToolType.Value == PlayerStorage.Type.Weapon then
					local maxAmmo = child.Configuration.AmmoTotalCapacity.Value
					local currentAmmo = child.CurrentAmmo.Value
					child.TotalAmmo.Value = maxAmmo - currentAmmo
				end
			end
		end
		DisplayManager:DisplayMessageNoticeToPlayer(player, "所有武器弹药已填充")
		BuyGoods:FireClient(player, {isSuccess=true})
		
	elseif mGoods.Id == 113 then
		if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health < 100 then
			if not paymentForBlackMarket(player, mGoods) then return end	--支付
			player.Character.Humanoid.Health = 100
			DisplayManager:DisplayMessageNoticeToPlayer(player, "生命值已恢复")
		end
		
	elseif mGoods.Type == PlayerStorage.Type.Weapon then
		if #TakeBagData.Weapons >= (GameSettings.MaxWeapon + GameSettings.MaxBlackMarketWeapon) then
			DisplayManager:DisplayMessageNoticeToPlayer(player, "携带武器已达上限")
			return
		end
		for _, weapon in pairs(TakeBagData.Weapons) do
			if mGoods.Id == weapon.Id then
				DisplayManager:DisplayMessageNoticeToPlayer(player, "已拥有该武器，无需重复购买")
				return
			end
		end
		if not paymentForBlackMarket(player, mGoods) then return end	--支付
		mGoods = PlayerStorage:GetStorageByIds({mGoods.Id})[1]
		--table.insert(TakeBagData.Weapons, mGoods)
		--UpdateTakeBag:Fire(player)
		GetNewTool:Fire(player, mGoods)
		DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 ["..mGoods.Name.."]")
		
	elseif mGoods.Type == PlayerStorage.Type.Grenade then
		if not paymentForBlackMarket(player, mGoods) then return end	--支付
		--local isAdded = false
		--for _, grenade in pairs(TakeBagData.Grenades) do
		--	if mGoods.Id == grenade.Id then
		--		grenade.Number += mGoods.Number
		--		isAdded = true
		--	end
		--end
		--if not isAdded then
		--	mGoods = PlayerStorage:GetStorageByIds({mGoods.Id})[1]
		--	table.insert(TakeBagData.Grenades, mGoods)
		--end
		--UpdateTakeBag:Fire(player)
		
		GetNewTool:Fire(player, mGoods)
		DisplayManager:DisplayMessageNoticeToPlayer(player, "获得 ["..mGoods.Name.."] x"..mGoods.Number)
		
	end
	
	
end

function paymentForBlackMarket(player, goodsStorage)
	local isPaid = false
	local playerData = PlayerManager:GetPlayerData(player)
	if goodsStorage.PriceType == PlayerStorage.PriceType.GOLD then	--金币购买
		if playerData.Gold >= goodsStorage.BlackMarketPrice then 	--金币足够
			playerData.Gold -= goodsStorage.BlackMarketPrice	--支付金额
			player:FindFirstChild("Gold").Value = playerData.Gold
			isPaid = true
		else
			--计算金币差
			local xGold = goodsStorage.BlackMarketPrice - playerData.Gold	--金币差
			local bDiamond = math.ceil(xGold / GameSettings.DiamondExchangeGold)	--向上取整
			--需再次判断玩家是否拥有足够的钻石支付补充购买金额
			if playerData.Diamond >= bDiamond then
				playerData.Diamond -= bDiamond
				--玩家支付后金币 = 玩家原有金币 + 钻石兑换的金币 - 商品价格
				playerData.Gold = playerData.Gold + bDiamond * GameSettings.DiamondExchangeGold - goodsStorage.BlackMarketPrice	--支付金币
				player:FindFirstChild("Gold").Value = playerData.Gold
				player:FindFirstChild("Diamond").Value = playerData.Diamond
				
				DisplayManager:DisplayMessageNoticeToPlayer(player, "自动使用 [钻石 x"..bDiamond.."] 兑换购买")
			else
				--金币不够，钻石余额也不够，购买失败
				isPaid = false
				DisplayManager:DisplayMessageNoticeToPlayer(player, "金币不足")
			end
		end
	end
	return isPaid
end

--购买商品
function onBuyGoods(player, goods, acceptSecondPrice)
	local goodsStorages = PlayerStorage:GetStorageByIds({goods.Id})
	if not goodsStorages or #goodsStorages ~= 1 then
		BuyGoods:FireClient(player, {success=false, message="购买的商品不存在", goods=goods})
		return
	end

	local goodsStorage = goodsStorages[1]
	local playerData = PlayerManager:GetPlayerData(player)
	
	--如果商品包含唯一属性，则判断玩家是否已拥有商品，除金币钻石商品以外
	if PlayerManager:CheckPlayerOwnedGoods(player, goodsStorage) then
		BuyGoods:FireClient(player, {success=false, message="已拥有，无需再次购买", goods=goods})
		return
	end
	
	--检查是否有足够的货币购买
	if goodsStorage.PriceType == PlayerStorage.PriceType.GOLD then	--金币购买
		if playerData.Gold >= goodsStorage.Price then 	--金币足够
			playerData.Gold -= goodsStorage.Price	--支付金额
			player:FindFirstChild("Gold").Value = playerData.Gold
			PlayerManager:PlayerGetNewGoods(player, {goodsStorage})
			
			BuyGoods:FireClient(player, {success=true, message="购买成功", goods=goodsStorage})
		elseif acceptSecondPrice then	--金币不够，但接受钻石补充购买
			--计算金币差
			local xGold = goodsStorage.Price - playerData.Gold	--金币差
			local bDiamond = math.ceil(xGold / GameSettings.DiamondExchangeGold)	--向上取整
			--需再次判断玩家是否拥有足够的钻石支付补充购买金额
			if playerData.Diamond >= bDiamond then
				playerData.Diamond -= bDiamond
				--玩家支付后金币 = 玩家原有金币 + 钻石兑换的金币 - 商品价格
				playerData.Gold = playerData.Gold + bDiamond * GameSettings.DiamondExchangeGold - goodsStorage.Price	--支付金币
				player:FindFirstChild("Gold").Value = playerData.Gold
				player:FindFirstChild("Diamond").Value = playerData.Diamond
				PlayerManager:PlayerGetNewGoods(player, {goodsStorage})

				BuyGoods:FireClient(player, {success=true, message="购买成功", goods=goodsStorage})
			else
				--金币不够，钻石余额也不够，购买失败，客户端提示充值Robux
				BuyGoods:FireClient(player, {success=false, message="金币不足，请充值", rechargeGold=true, goods=goods})
			end
		else	--金币不够，如果钻石余额充足，则提示是否接受钻石补充购买，否则货币不够，购买失败，客户端提示充值Robux
			--计算金币差
			local xGold = goodsStorage.Price - playerData.Gold	--金币差
			local bDiamond = math.ceil(xGold / GameSettings.DiamondExchangeGold)	--向上取整
			--判断玩家是否拥有足够的钻石支付补充购买金额
			if playerData.Diamond >= bDiamond then
				BuyGoods:FireClient(player, {success=false, buyAgain=true, goods=goodsStorage,
					message="金币不足，是否使用 "..tostring(bDiamond).."钻石 兑换购买", })
			else
				--金币不够，钻石余额也不够，购买失败，客户端提示充值Robux
				BuyGoods:FireClient(player, {success=false, message="金币且钻石不足，请充值", rechargeDiamond=true, goods=goods})
			end
		end
		
	elseif goodsStorage.PriceType == PlayerStorage.PriceType.DIAMOND then	--钻石购买
		if playerData.Diamond >= goodsStorage.Price then 	--钻石足够
			playerData.Diamond -= goodsStorage.Price	--支付钻石
			player:FindFirstChild("Diamond").Value = playerData.Diamond
			PlayerManager:PlayerGetNewGoods(player, {goodsStorage})

			BuyGoods:FireClient(player, {success=true, message="购买成功", goods=goodsStorage})
		else
			--钻石余额不够，购买失败，客户端提示充值Robux
			BuyGoods:FireClient(player, {success=false, message="钻石不足，请充值", rechargeDiamond=true, goods=goods})
		end
		
	elseif goodsStorage.PriceType == PlayerStorage.PriceType.ROBUX then	--Robux购买
		BuyGoods:FireClient(player, {success=false, message="请直接使用ROBUX购买", goods=goods})
		
	else	--其他情况，信息异常
		BuyGoods:FireClient(player, {success=false, message="商品信息异常", goods=goods})
	end
end

GetShopGoods.OnServerEvent:Connect(onGetShopGoods)
BuyGoods.OnServerEvent:Connect(onBuyGoodsFromBlackMarket)


-------------------------------------------------------------------------------------------
----------------------------------------- 以下 ---------------------------------------------
---------------------------------- ROBUX 购买流程相关 ---------------------------------------
-------------------------------------------------------------------------------------------


local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- 此数据存储用于跟踪已成功处理的购买流程
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

----------------------------------------------------------------------
--自需内容处理
local productFunctions = function(receipt, player)
	--根据数据库Robux数据设置回调数据
	local RobuxGoods = PlayerStorage:GetAllStorageOfRobuxGoods()
	
	for _, goods in pairs(RobuxGoods) do
		--找到购买的商品
		if receipt.ProductId == goods.Path then
			--如果购买的是钻石
			if goods.Type == PlayerStorage.Type.Diamond then
				PlayerManager:PlayerGetNewGoods(player, {goods})
				BuyGoods:FireClient(player, {success=true, message="购买成功", goods=goods})
			
			--如果购买的是角色
			elseif goods.Type == PlayerStorage.Type.Character then
				
				
				
			--如果有其他Robux购买类型，后期扩充
				
			end
			
			
			return true
		end
	end
end

----------------------------------------------------------------------

----官方测试方法
---- 表格相关设置，含有产品 ID 和处理购买操作的函数
--local productFunctions = {}

---- ProductId 123123 的产品可以为玩家补满生命值
--productFunctions[123123] = function(receipt, player)
--	-- 玩家购买生命值回复所需的逻辑或编码（非固定）
--	if player.Character and player.Character:FindFirstChild("Humanoid") then
--		-- 将玩家的生命值补满
--		player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
--		-- 标识购买成功
--		return true
--	end
--end
---- ProductId 456456 的产品将为玩家提供 100 金币
--productFunctions[456456] = function(receipt, player)
--	-- 玩家购买 100 金币的逻辑或编码（非固定）
--	local stats = player:FindFirstChild("leaderstats")
--	local gold = stats and stats:FindFirstChild("Gold")
--	if gold then
--		gold.Value = gold.Value + 100
--		-- 标识购买成功
--		return true
--	end
--end

-- 核心 ‘ProcessReceipt’ 回调函数
local function processReceipt(receiptInfo)

	-- 检查数据存储，判断产品是否已经发放  
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	-- 如果购买流程被记录下来，则说明产品已发放
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end

	-- 找到服务器中进行购买的玩家
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- 玩家可能离开了游戏
		-- 玩家返回游戏时将会再次调用回调函数
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- 从上面的 ‘productFunctions’ 表格中查找处理函数
	--local handler = productFunctions[receiptInfo.ProductId]

	-- 调用处理函数并捕捉错误
	--local success, result = pcall(handler, receiptInfo, player)
	--直接调用，在方法内处理不同产品购买结果
	local success, result = pcall(productFunctions, receiptInfo, player)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- 在数据存储中记录好交易内容，确保同样的产品不会被再次发放
	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data:" .. errorMessage)
	end

	-- 重要：告知 Roblox 购买流程已被成功处理
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- 设置回调函数，这个设置只能由服务器上的一个脚本进行一次！ 
MarketplaceService.ProcessReceipt = processReceipt

-------------------------------------------------------------------------------------------
----------------------------------------- 以上 ---------------------------------------------
---------------------------------- ROBUX 购买流程相关 ---------------------------------------
-------------------------------------------------------------------------------------------

return ShopManager
