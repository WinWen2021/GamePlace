local TeleportManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportFolder = ReplicatedStorage:WaitForChild("Teleport")
local TurnToBasePlaceEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("TurnToBasePlaceEvent")
local Configuration = require(ReplicatedStorage:WaitForChild("ReplicatedModule"):WaitForChild("Configuration"))
local gameSettings = require(game:GetService("ServerStorage"):WaitForChild("ModuleScripts"):WaitForChild("GameSettings"))
local TeleportEvent = game.ReplicatedStorage.Events:WaitForChild("TeleportEvent")

-- Require teleport module
local TeleportModule = require(TeleportFolder:WaitForChild("TeleportModule"))

TurnToBasePlaceEvent.OnServerEvent:Connect(function(player, gamePlace)
	--print("服务器获得玩家请求开始游戏", gamePlace)
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid and not humanoid:GetAttribute("Teleporting") then
		TeleportManager.onTeleportPlayers({player}, gameSettings.GamePlaceID[gamePlace])
	end
end)

function TeleportManager.onTeleportPlayersToBasePlace(players)
	TeleportManager.onTeleportPlayers(players, gameSettings.GamePlaceID["BASE_PLACE"])
	TeleportEvent:FireAllClients()
end

function TeleportManager.onTeleportPlayers(players, placeID)
	for _, player in pairs(players) do
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid and not humanoid:GetAttribute("Teleporting") then
			humanoid:SetAttribute("Teleporting", true)
			--禁止玩家移动
			TeleportModule.freezePlayer(humanoid)
		end
	end

	delay(Configuration.TeleportDuration, function()
		for _, player in pairs(players) do
			local humanoid = player.Character:FindFirstChild("Humanoid")

			if humanoid and humanoid:GetAttribute("Teleporting") then
				print("恢复玩家传送状态")
				TeleportModule.unfreezePlayer(humanoid)
				humanoid:SetAttribute("Teleporting", nil)
			end
		end
	end)

	--传送玩家
	-- Teleport the player to a reserved server
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ShouldReserveServer = false

	local teleportResult = TeleportModule.teleportWithRetry(placeID, players, teleportOptions)
end

return TeleportManager