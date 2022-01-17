--客户端配置文件
local Configuration = {}

Configuration.TeleportStr = "传送中"
Configuration.TeleportDuration = 30
Configuration.AutoTeleportToBasePlace = 15

Configuration.GamePlaceList = {
	BASE_PLACE = "BASE_PLACE",		--基地
}

Configuration.NoticeType = {
	MESSAGE = 1,
	ACTION = 2,
	TEAM = 3,
}

--价格购买类型
Configuration.PriceType = {
	GOLD = 1,
	DIAMOND = 2,
	ROBUX = 3,
}

--图片资源类型
Configuration.ImageType = {
	Image = 1,								--普通roblox图片资源，默认
	Viewport = 2,							--Viewport图片资源，Image为资源路径，使用需获得Viewpoint实例
}

--商品类型
Configuration.GoodsType = {
	Weapon = "Weapon",						--武器
	Grenade = "Grenade",					--手雷
	Ammo = "Ammo",							--弹药
	Equipment = "Equipment",				--装备
	Character = "Character",				--角色
	Gold = "Gold",							--金币
	Diamond = "Diamond",					--钻石
}

--仅做示例，几种Notice发送格式示例如下
Configuration.NoticeFormat = {
	{["NoticeType"]= Configuration.NoticeType.MESSAGE, ["Message"]="测试通知：游戏开始"},
	{["NoticeType"]= Configuration.NoticeType.ACTION, ["PlayerA"]={Name="Cloris",Team={TeamColor={Color=Color3.new(1,0,0)}}}, ["Action"]="击败", ["PlayerB"]={Name="Win",Team={TeamColor={Color=Color3.new(0,0,1)}}}},
	{["NoticeType"]= Configuration.NoticeType.TEAM, ["Team"]={Name="红队",TeamColor={Color=Color3.new(1,0,0)}}, ["Message"]="获得比赛胜利"}
}


return Configuration
