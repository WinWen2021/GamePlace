local TeleportAnim = {}

-- Declare local variables for Roblox Services
local TeleportService = game:GetService('TeleportService')
local UserInputService = game:GetService('UserInputService')
local StarterGui = game.StarterGui

-- Declare local variables
local forceField = Instance.new('ForceField')

local loadingScreen = nil

-- Hide default teleport GUI elements
TeleportService.CustomizedTeleportUI = true

function TeleportAnim.startTeleportAnim(player, teleportStr, teleportDuration)
	
	if not player then
		warn("请携带传送玩家")
		return
	end
	
	if loadingScreen then return end	--正在传送
	
	player.OnTeleport:Connect(function(teleportState)
		if teleportState == Enum.TeleportState.Failed then
			TeleportAnim.endTeleportAnim()
		end
	end)
	
	-- Create loading screen to fade in and pass with teleport function
	loadingScreen = Instance.new('ScreenGui', player.PlayerGui)
	local loadingScreenFrame = Instance.new('Frame', loadingScreen)
	loadingScreenFrame.Name = 'loadingScreenFrame'
	loadingScreenFrame.BackgroundColor3 = Color3.new(0,0,0)
	loadingScreenFrame.Size = UDim2.new(1,0,1,50)
	loadingScreenFrame.Position = UDim2.new(0,0,0,-50)
	loadingScreenFrame.Visible = false

	local textLabel = Instance.new("TextLabel", loadingScreenFrame)
	textLabel.Name = 'TextLabel'
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Size = UDim2.new(0.2,0,0.1,0)
	textLabel.Position = UDim2.new(0.4,0,0.45,0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Text = teleportStr.."..."

	-- Hide button, Core GUI, and mouse
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)	
	UserInputService.MouseIconEnabled = false	

	-- Activate force field to protect player during teleport
	forceField.Parent = player.Character	

	-- Show loading screen and fade it in
	loadingScreenFrame.Visible = true
	for i = 1, 0, -.05 do
		loadingScreenFrame.BackgroundTransparency = i
		wait()
	end
	loadingScreenFrame.BackgroundTransparency = 0

	--传送动画
	local run = 0
	local runTime = 0.3
	if not teleportDuration then
		teleportDuration = 30 --默认30秒
	end

	for i = 0, teleportDuration/runTime do
		wait(runTime)
		if run == 0 then
			textLabel.Text = teleportStr.."   "
		elseif run == 1 then
			textLabel.Text = teleportStr..".  "
		elseif run == 2 then
			textLabel.Text = teleportStr..".. "
		elseif run == 3 then
			textLabel.Text = teleportStr.."..."
		end
		run = run + 1
		if run == 4 then
			run = 0
		end
	end
	--传送时间过长，结束动画
	TeleportAnim.endTeleportAnim()
end

function TeleportAnim.endTeleportAnim()
	-- Disable force field
	forceField.Parent = nil

	-- Hide teleport GUI and show teleport button
	if loadingScreen then
		loadingScreen.Enabled = false
		loadingScreen:Destroy()
		loadingScreen = nil
	end
	-- Show Core GUI elements and mouse cursor
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	UserInputService.MouseIconEnabled = true		
end


return TeleportAnim
