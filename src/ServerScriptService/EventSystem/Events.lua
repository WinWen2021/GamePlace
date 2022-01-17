local Events = {}

Events.RemoteEvent = {
	"DisplayEndResult",
	"DisplayNotification",
	"DisplayScore",
	"DisplayTimerInfo",
	"TeleportEvent",
	"TurnToBasePlaceEvent",
	Bag = {
		"ChangeTools",
		"GetBags",
		"GetTakeBags",
		"Remove",
		"Take",
		"ToolUpdated",
	},
	Match = {
		"GameEnd",
		"GameEndTransition",
		"GameShowResult",
		"GameStartTransition",
		"GameTimeUpNotice",
	},
	Shop = {
		"BuyGoods",
		"GetShopGoods",
	},
}

Events.ServerEvent = {
	Match = {
		"MatchEnd",
		"MatchStart",
	},
	TakeBagEvents = {
		"GetNewTool",
		"RefreshTakeBag",
		"RemoveTakeBag",
		"UnequipTool",
		"UpdateTakeBag",
	},
}

Events.ClientEvent = {
	"Test6",
}

return Events
