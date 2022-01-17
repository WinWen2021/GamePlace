local Utils = {}

function Utils:FreezePlayer(player)
	Utils:FreezePlayerWalk(player)
	Utils:FreezePlayerJump(player)
end

function Utils:UnfreezePlayer(player)
	Utils:UnfreezePlayerWalk(player)
	Utils:UnfreezePlayerJump(player)
end


function Utils:FreezePlayerMove(player)
	if not (player and player.Character and player.Character.HumanoidRootPart) then return end
	local ins = Instance.new("BodyVelocity")
	ins.Name = "FreezeMove"
	ins.Parent = player.Character.HumanoidRootPart
	ins.MaxForce = Vector3.new(4000000000, 0, 400000000)
	ins.Velocity = Vector3.new(0, 0, 0)
end
function Utils:UnfreezePlayerMove(player)
	if not (player and player.Character and player.Character.HumanoidRootPart) then return end
	local FreezeMove = player.Character.HumanoidRootPart:FindFirstChild("FreezeMove")
	if FreezeMove then FreezeMove:Destroy() end
end

function Utils:FreezePlayerWalk(player)
	if player and player.Character and player.Character.Humanoid then
		local humanoid = player.Character.Humanoid
		humanoid:SetAttribute("DefaultWalkSpeed", humanoid.WalkSpeed)
		humanoid.WalkSpeed = 0
	end
end
function Utils:UnfreezePlayerWalk(player)
	if player and player.Character and player.Character.Humanoid then
		local humanoid = player.Character.Humanoid
		if humanoid.WalkSpeed == 0 and humanoid:GetAttribute("DefaultWalkSpeed") then
			humanoid.WalkSpeed = humanoid:GetAttribute("DefaultWalkSpeed")
		end
	end
end

function Utils:FreezePlayerJump(player)
	if player and player.Character and player.Character.Humanoid then
		local humanoid = player.Character.Humanoid
		humanoid:SetAttribute("DefaultJumpPower", humanoid.JumpPower)
		humanoid.JumpPower = 0
	end
end
function Utils:UnfreezePlayerJump(player)
	if player and player.Character and player.Character.Humanoid then
		local humanoid = player.Character.Humanoid
		if humanoid.JumpPower == 0 and humanoid:GetAttribute("DefaultJumpPower") then
			humanoid.JumpPower = humanoid:GetAttribute("DefaultJumpPower")
		end
	end
end

return Utils
