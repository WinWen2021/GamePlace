local PlayerStorage = {}

--价格购买类型
PlayerStorage.PriceType = {
	GOLD = 1,								--金币
	DIAMOND = 2,							--钻石
	ROBUX = 3,								--Robux
}

--图片资源类型
PlayerStorage.ImageType = {
	Image = 1,								--普通roblox图片资源，默认
	Viewport = 2,							--Viewport图片资源，Image为资源路径，使用需获得Viewpoint实例
}

--商品类型
PlayerStorage.Type = {
	Weapon = "Weapon",						--武器
	Grenade = "Grenade",					--手雷
	Ammo = "Ammo",							--弹药
	Equipment = "Equipment",				--装备
	Character = "Character",				--角色
	Gold = "Gold",							--金币
	Diamond = "Diamond",					--钻石
}

--武器子弹类型
PlayerStorage.BulletType = {
	BT1 = "BT1",		
	BT2 = "BT2",		
	BT3 = "BT3",		
	BT4 = "BT4",		
	BT5 = "BT5",		
	BT6 = "BT6",		
	BT7 = "BT7",		
	BT8 = "BT8",		
	BT9 = "BT9",
}


--商品数据
PlayerStorage.Storage = {
	
	--武器 1
	{Id=100001, Type=PlayerStorage.Type.Weapon, Name="自动手枪", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=8888, BlackMarketPrice=588, Path="Weapons.自动手枪", BulletType=PlayerStorage.BulletType.BT1, Image="rbxassetid://8037979448", Unique=true, },
	{Id=100002, Type=PlayerStorage.Type.Weapon, Name="冲锋枪", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=12888, BlackMarketPrice=688, Path="Weapons.冲锋枪", BulletType=PlayerStorage.BulletType.BT2, Image="rbxassetid://8037983927", Unique=true, },
	{Id=100003, Type=PlayerStorage.Type.Weapon, Name="十字弩", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=18888, BlackMarketPrice=888, Path="Weapons.十字弩", BulletType=PlayerStorage.BulletType.BT3, Image="rbxassetid://8037979746", Unique=true, },
	{Id=100004, Type=PlayerStorage.Type.Weapon, Name="突击步枪", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=38888, BlackMarketPrice=2888, Path="Weapons.突击步枪", BulletType=PlayerStorage.BulletType.BT4, Image="rbxassetid://8037979588", Unique=true, },
	{Id=100005, Type=PlayerStorage.Type.Weapon, Name="散弹枪", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=58888, BlackMarketPrice=4888, Path="Weapons.散弹枪", BulletType=PlayerStorage.BulletType.BT5, Image="rbxassetid://8037979882", Unique=true, },
	{Id=100006, Type=PlayerStorage.Type.Weapon, Name="榴弹枪", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=88888, BlackMarketPrice=6888, Path="Weapons.榴弹枪", BulletType=PlayerStorage.BulletType.BT6, Image="rbxassetid://8037979984", Unique=true, },
	{Id=100007, Type=PlayerStorage.Type.Weapon, Name="磁轨炮", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=118888, BlackMarketPrice=8888, Path="Weapons.磁轨炮", BulletType=PlayerStorage.BulletType.BT7, Image="rbxassetid://8037980371", Unique=true, },
	{Id=100008, Type=PlayerStorage.Type.Weapon, Name="狙击步枪", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=128888, BlackMarketPrice=9888, Path="Weapons.狙击步枪", BulletType=PlayerStorage.BulletType.BT8, Image="rbxassetid://8037980101", Unique=true, },
	{Id=100009, Type=PlayerStorage.Type.Weapon, Name="火箭筒", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=128888, BlackMarketPrice=9888, Path="Weapons.火箭筒", BulletType=PlayerStorage.BulletType.BT9, Image="rbxassetid://8037980240", Unique=true, },
	
	--手雷 21
	{Id=210001, Type=PlayerStorage.Type.Grenade, Name="MK2 手榴弹", Number=1, MaximumNumber=5, PriceType=PlayerStorage.PriceType.GOLD, Price=100, BlackMarketPrice=100, Path="Grenades.MK2 手榴弹", Image="rbxassetid://8305371486",},
	{Id=210002, Type=PlayerStorage.Type.Grenade, Name="MK6 烟雾弹", Number=1, MaximumNumber=5, PriceType=PlayerStorage.PriceType.GOLD, Price=88, BlackMarketPrice=88, Path="Grenades.M18 烟雾弹", Image="rbxassetid://8305371670",},

	--弹药 22
	{Id=220001, Type=PlayerStorage.Type.Ammo, Name="BT1", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=2, BlackMarketPrice=2, BulletType=PlayerStorage.BulletType.BT1, Image="rbxassetid://8037979448", },
	{Id=220002, Type=PlayerStorage.Type.Ammo, Name="BT2", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=3, BlackMarketPrice=3, BulletType=PlayerStorage.BulletType.BT2, Image="rbxassetid://8037983927", },
	{Id=220003, Type=PlayerStorage.Type.Ammo, Name="BT3", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=2, BlackMarketPrice=2, BulletType=PlayerStorage.BulletType.BT3, Image="rbxassetid://8037979746", },
	{Id=220004, Type=PlayerStorage.Type.Ammo, Name="BT4", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=3, BlackMarketPrice=3, BulletType=PlayerStorage.BulletType.BT4, Image="rbxassetid://8037979588", },
	{Id=220005, Type=PlayerStorage.Type.Ammo, Name="BT5", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=10, BlackMarketPrice=10, BulletType=PlayerStorage.BulletType.BT5, Image="rbxassetid://8037979882", },
	{Id=220006, Type=PlayerStorage.Type.Ammo, Name="BT6", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=10, BlackMarketPrice=10, BulletType=PlayerStorage.BulletType.BT6, Image="rbxassetid://8037979984", },
	{Id=220007, Type=PlayerStorage.Type.Ammo, Name="BT7", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=10, BlackMarketPrice=10, BulletType=PlayerStorage.BulletType.BT7, Image="rbxassetid://8037980371", },
	{Id=220008, Type=PlayerStorage.Type.Ammo, Name="BT8", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=15, BlackMarketPrice=15, BulletType=PlayerStorage.BulletType.BT8, Image="rbxassetid://8037980101", },
	{Id=220009, Type=PlayerStorage.Type.Ammo, Name="BT9", Number=1, PriceType=PlayerStorage.PriceType.GOLD, Price=50, BlackMarketPrice=50, BulletType=PlayerStorage.BulletType.BT9, Image="rbxassetid://8037980240", },

	--装备 3
	
	--金币 4	
	{Id=400001, Type=PlayerStorage.Type.Gold, Name="金币", Number=10000, PriceType=PlayerStorage.PriceType.DIAMOND, Price=100, Path=nil, Image="rbxassetid://8172249926",},
	{Id=400002, Type=PlayerStorage.Type.Gold, Name="金币", Number=20000, PriceType=PlayerStorage.PriceType.DIAMOND, Price=200, Path=nil, Image="rbxassetid://8172249926",},
	{Id=400003, Type=PlayerStorage.Type.Gold, Name="金币", Number=41800, PriceType=PlayerStorage.PriceType.DIAMOND, Price=400, Path=nil, Image="rbxassetid://8172249714",},
	{Id=400004, Type=PlayerStorage.Type.Gold, Name="金币", Number=88000, PriceType=PlayerStorage.PriceType.DIAMOND, Price=800, Path=nil, Image="rbxassetid://8172249471",},
	{Id=400005, Type=PlayerStorage.Type.Gold, Name="金币", Number=138000, PriceType=PlayerStorage.PriceType.DIAMOND, Price=1200, Path=nil, Image="rbxassetid://8172249167",},
	{Id=400006, Type=PlayerStorage.Type.Gold, Name="金币", Number=288000, PriceType=PlayerStorage.PriceType.DIAMOND, Price=2400, Path=nil, Image="rbxassetid://8172248930",},
	{Id=400007, Type=PlayerStorage.Type.Gold, Name="金币", Number=428000, PriceType=PlayerStorage.PriceType.DIAMOND, Price=3600, Path=nil, Image="rbxassetid://8172248434",},
	{Id=400008, Type=PlayerStorage.Type.Gold, Name="金币", Number=588000, PriceType=PlayerStorage.PriceType.DIAMOND, Price=4800, Path=nil, Image="rbxassetid://8172248434",},
	
	--钻石 5	
	{Id=500001, Type=PlayerStorage.Type.Diamond, Name="钻石", Number=100, PriceType=PlayerStorage.PriceType.ROBUX, Price=10, Path=1228642300, Image="rbxassetid://8172276216",},
	{Id=500002, Type=PlayerStorage.Type.Diamond, Name="钻石", Number=600, PriceType=PlayerStorage.PriceType.ROBUX, Price=60, Path=1228642319, Image="rbxassetid://8172275953",},
	{Id=500003, Type=PlayerStorage.Type.Diamond, Name="钻石", Number=4750, PriceType=PlayerStorage.PriceType.ROBUX, Price=450, Path=1228642351, Image="rbxassetid://8172275707",},
	{Id=500004, Type=PlayerStorage.Type.Diamond, Name="钻石", Number=7150, PriceType=PlayerStorage.PriceType.ROBUX, Price=680, Path=1228642403, Image="rbxassetid://8172275421",},
	{Id=500005, Type=PlayerStorage.Type.Diamond, Name="钻石", Number=12400, PriceType=PlayerStorage.PriceType.ROBUX, Price=1180, Path=1228642436, Image="rbxassetid://8172275212",},
	{Id=500006, Type=PlayerStorage.Type.Diamond, Name="钻石", Number=21000, PriceType=PlayerStorage.PriceType.ROBUX, Price=1980, Path=1228642460, Image="rbxassetid://8172274974",},
	{Id=500007, Type=PlayerStorage.Type.Diamond, Name="钻石", Number=36900, PriceType=PlayerStorage.PriceType.ROBUX, Price=3480, Path=1228642483, Image="rbxassetid://8172274671",},
	{Id=500008, Type=PlayerStorage.Type.Diamond, Name="钻石", Number=68680, PriceType=PlayerStorage.PriceType.ROBUX, Price=6480, Path=1228642512, Image="rbxassetid://8172274410",},

}

--创建新的储存对象，对象数据为参考字段，如需定义，请填充字段值
function PlayerStorage:NewStorage()
	local newstorage = {
		Id=0, 
		Type=nil, 
		Name="", 
		Number = 0, 
		PriceType=nil, 
		Price=0, 
		Path=nil, 
		Image=nil,
	}
	return newstorage
end

--创建金币储存对象
--参数number：金币数量
function PlayerStorage:NewGoldStorage(number)
	local newstorage = {
		Id=0, 
		Type=PlayerStorage.Type.Gold, 
		Name="金币", 
		Number = number, 
		PriceType=PlayerStorage.PriceType.DIAMOND, 
		Price=0, 
		Path=nil, 
		Image="rbxassetid://8172249926",
	}
	if number < 10 then
		newstorage.Image = "rbxassetid://8172250100"
	elseif number < 500 then
		newstorage.Image = "rbxassetid://8172249926"
	elseif number < 1000 then
		newstorage.Image = "rbxassetid://8172249714"
	elseif number < 5000 then
		newstorage.Image = "rbxassetid://8172249471"
	elseif number < 10000 then
		newstorage.Image = "rbxassetid://8172249167"
	elseif number < 50000 then
		newstorage.Image = "rbxassetid://8172248930"
	else
		newstorage.Image = "rbxassetid://8172248434"
	end

	return newstorage
end

--创建钻石储存对象
--参数number：钻石数量
function PlayerStorage:NewDiamondStorage(number)
	local newstorage = {
		Id=0, 
		Type=PlayerStorage.Type.Diamond, 
		Name="钻石", 
		Number = number, 
		PriceType=PlayerStorage.PriceType.ROBUX, 
		Price=0, 
		Path=nil, 
		Image="rbxassetid://8162401454",
	}
	
	if number < 10 then
		newstorage.Image = "rbxassetid://8172276216"
	elseif number < 200 then
		newstorage.Image = "rbxassetid://8172275953"
	elseif number < 500 then
		newstorage.Image = "rbxassetid://8172275707"
	elseif number < 1000 then
		newstorage.Image = "rbxassetid://8172275421"
	elseif number < 2000 then
		newstorage.Image = "rbxassetid://8172275212"
	else
		newstorage.Image = "rbxassetid://8172274974"
	end

	return newstorage
end

--拷贝table数据，浅复制
local function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

--拷贝table数据，深复制，多重table复制
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function PlayerStorage:GetStorageDataByType(storageType)
	assert(storageType, "StorageType is nil")
	local storageData = nil
	for _, storage in pairs(PlayerStorage.Storage) do
		if storage.Type == storageType then
			if not storageData then storageData = {} end
			local newStorage = shallowCopy(storage)
			table.insert(storageData, newStorage)
		end
	end
	return storageData
end

function PlayerStorage:GetStorageByIds(ids)
	assert(type(ids) == "table", "ids is not a table")
	local datas = nil

	for _, data in pairs(PlayerStorage.Storage) do
		for _, id in pairs(ids) do
			if id == data.Id then
				if not datas then datas = {} end
				local newStorage = shallowCopy(data)
				table.insert(datas, newStorage)
			end
		end
	end
	return datas
end

function PlayerStorage:GetAllStorageOfRobuxGoods()
	
	local storageData = nil
	for _, storage in pairs(PlayerStorage.Storage) do
		if storage.PriceType == PlayerStorage.PriceType.ROBUX then
			if not storageData then storageData = {} end
			local newStorage = shallowCopy(storage)
			table.insert(storageData, newStorage)
		end
	end
	return storageData
end


return PlayerStorage
