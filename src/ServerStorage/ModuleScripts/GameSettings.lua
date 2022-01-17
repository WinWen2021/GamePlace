local GameSettings = {}

-- Game Variables
GameSettings.intermissionDuration = 60
GameSettings.matchDuration = 60 * 5
GameSettings.minimumPlayers = 2
GameSettings.maximumPlayers = 20
GameSettings.transitionTime = 5			--过渡时间
GameSettings.endResultDuration = 15		--最终结果显示时间，游戏比赛结束后最大停留时间
GameSettings.playerCanReSpawn = true	--设置是否允许玩家重生，继续场内游戏
GameSettings.HitTeams = false			--设置是否允许伤害队友
GameSettings.Score_To_Win = 20			--游戏胜利分数

GameSettings.MaxWeapon = 3				--最大携带武器数量
GameSettings.MaxBlackMarketWeapon = 3	--最大黑市武器购买数量
GameSettings.GrenadeGroup = 4			--购买手雷每组数量

GameSettings.GamePlaceList = {
	BASE_PLACE = "BASE_PLACE",		--基地
}

GameSettings.GamePlaceID = {
	BASE_PLACE = 7749274691,		--基地
}

GameSettings.GameStatus = {
	Intermission = 10,
	Preparing = 20,
	MatchStart = 30,
	MatchRunning = 40,
	MatchEnd = 50,
	EndDuration = 60,
}

-- Possible ways that the game can end.
GameSettings.endStates = {
	TimerUp = "TimerUp",
	FoundWinner = "FoundWinner"
}

-- 排行榜分数
GameSettings.leaderstats = {
	SCORE_KILL = "KILL",
	SCORE_DEATH = "DEATH",
	SCORE_ASSIST = "ASSIST"
}

return GameSettings
