local TeleportService = game:GetService("TeleportService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TeleportModule = {}

local RETRY_DELAY = 2
local MAX_WAIT = 10

--场景间传送
--targetPlaceID:场景ID
--playersTable:需要传送的玩家列表，可多玩家一起传送
--teleportOptions: 此为传递参数，需要调用Instance.new("TeleportOptions")创建TeleportOptions对象
--TeleportOptions对象参数说明：
--属性ShouldReserveServer：bool类型，ture表示传送到独立场景服务器，其他玩家禁止加入，反之允许其他玩家加入
--属性ReservedServerAccessCode：string类型，（具体用法待尝试使用，补充）
--属性ServerInstanceId：string类型，（具体用法待尝试使用，补充）
--方法GetTeleportData(): 返回存储在TeleportOptions实例中的传送数据TeleportOptions:SetTeleportData
--方法SetTeleportData(Variant teleportData): 设置传送玩家到目标位置(查API)
function TeleportModule.teleportWithRetry(targetPlaceID, playersTable, teleportOptions)
	local currentWait = 0

	local function doTeleport(players, options)
		if currentWait < MAX_WAIT then
			local success, errorMessage = pcall(function()
				return TeleportService:TeleportAsync(targetPlaceID, players, options)
			end)
			if not success then
				warn(errorMessage)
				-- 在定义的延迟后重试传送
				wait(RETRY_DELAY)
				currentWait = currentWait + RETRY_DELAY
				doTeleport(players, teleportOptions)
			end
		else
			return true
		end
	end

	TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
		if teleportResult ~= Enum.TeleportResult.Success then
			warn(errorMessage)
			-- 在定义的延迟后重试传送
			wait(RETRY_DELAY)
			currentWait = currentWait + RETRY_DELAY
			doTeleport({player}, teleportOptions)
		end
	end)
	
	-- 触发初始传送
	doTeleport(playersTable, teleportOptions)
end

--场景内传送
--params参数必须包含以下3个参数
--destination:	The Vector3 position to teleport the player to.
--faceAngle:	Angular direction character should face following teleportation, between -180 and 180.
--freeze:	Whether to temporarily "freeze" the character during teleportation, preventing movement or jumping.
function TeleportModule.teleportWithinPlace(humanoid, params)
	
	if not params then
		params = {
			destination = Vector3.new(0, 0, 0),--场景内位置
			faceAngle = 0,--传送后玩家朝向
			freeze = true--是否允许玩家在传送过程移动，默认true
		}
	end
	params.freeze = params.freeze or true --默认true
	
	local character = humanoid.Parent

	-- Freeze character during teleport if requested
	if params.freeze then
		TeleportModule.freezePlayer(humanoid)
	end

	-- Calculate height of root part from character base
	local rootPartY
	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		rootPartY = (humanoid.RootPart.Size.Y * 0.5) + humanoid.HipHeight
	else
		rootPartY = (humanoid.RootPart.Size.Y * 0.5) + humanoid.Parent.LeftLeg.Size.Y + humanoid.HipHeight
	end

	-- Teleport player and request content around location if applicable
	local position = CFrame.new(params.destination + Vector3.new(0, rootPartY, 0))
	local orientation = CFrame.Angles(0, math.rad(params.faceAngle), 0)
	if workspace.StreamingEnabled then
		local player = Players:GetPlayerFromCharacter(character)
		player:RequestStreamAroundAsync(params.destination)
	end
	character:SetPrimaryPartCFrame(position * orientation)

	-- Unfreeze character
	if params.freeze then
		TeleportModule.unfreezePlayer(humanoid)
	end
end

function TeleportModule.freezePlayer(humanoid)
	--humanoid:SetAttribute("DefaultWalkSpeed", humanoid.WalkSpeed)
	--humanoid:SetAttribute("DefaultJumpPower", humanoid.JumpPower)
	--humanoid.WalkSpeed = 0
	--humanoid.JumpPower = 0
	if not (humanoid and humanoid.Parent and humanoid.Parent.HumanoidRootPart) then return end
	local ins = Instance.new("BodyVelocity")
	ins.Name = "FreezeMove"
	ins.Parent = humanoid.Parent.HumanoidRootPart
	ins.MaxForce = Vector3.new(4000000000, 0, 400000000)
	ins.Velocity = Vector3.new(0, 0, 0)
end

function TeleportModule.unfreezePlayer(humanoid)
	--humanoid.WalkSpeed = humanoid:GetAttribute("DefaultWalkSpeed")
	--humanoid.JumpPower = humanoid:GetAttribute("DefaultJumpPower")
	if not (humanoid and humanoid.Parent and humanoid.Parent.HumanoidRootPart) then return end
	local FreezeMove = humanoid.Parent.HumanoidRootPart:FindFirstChild("FreezeMove")
	if FreezeMove then FreezeMove:Destroy() end
end


return TeleportModule