local ResultManager = {}

local R = require(game:GetService("ReplicatedStorage"):WaitForChild("Router"))
local ResourcesManager = R:Require("ReplicatedStorage.Sole.Resources.ResourcesManager")
local TweenService = game:GetService("TweenService")

local Events = R:Wait("ReplicatedStorage.Events")
local DisplayEndResult = R:Wait(Events, "DisplayEndResult")
local Player = R:GetLocalPlayer()

local ScreenGui = R:Wait(R:GetLocalPlayerGui(), "ScreenGui")
local ResultFrame = R:Wait(ScreenGui, "ResultFrame")

local CloseBtn = R:Wait(ResultFrame, "CloseBtn")
local ResultTitle = R:Wait(ResultFrame, "ResultTitle")

local ResultGui = R:Wait(script.Parent.Parent, "Gui.ResultGui")
local RewardItemUi = R:Wait(ResultGui, "RewardItem")
local AdditionUi = R:Wait(ResultGui, "addition")
local RewardUi = R:Wait(ResultGui, "reward")

local Sound = R:Wait("ReplicatedStorage.Sound")

CloseBtn.MouseButton1Click:Connect(function()
	closeResult()
end)

function showResult()
	Sound.common.click:Play()
	ResultFrame.Visible = true
end

function closeResult()
	if ResultFrame.Visible then return end
	Sound.common.click:Play()
	ResultFrame.Visible = false
end

function OnEndResult(result)
	if result.IsWinner then
		ResultTitle.Text = "胜利"
		ResultTitle.TextColor3 = Color3.new(1, 0, 0) 
		Sound.male.male_you_win:Play()
	else
		if result.IsTie then
			ResultTitle.Text = "平局"
			ResultTitle.TextColor3 = Color3.new(0, 0, 1) 
		else
			ResultTitle.Text = "败北"
			ResultTitle.TextColor3 = Color3.new(0, 1, 0) 
		end
		Sound.male.male_you_lose:Play()
	end
	
	if result.RewardList then
		for _, rewards in pairs(result.RewardList) do
			local NewRewardItem = RewardItemUi:Clone()
			NewRewardItem.Title.Text = rewards.Title
			for _, reward in pairs(rewards.Rewards) do
				local NewRewardUi = RewardUi:Clone()
				ResourcesManager:SetGoodsImage(NewRewardUi.Icon, reward.TotalGoods)
				NewRewardUi.Title.Text = reward.TotalGoods.Number
				NewRewardUi.Parent = NewRewardItem.Rewards
			end
			if rewards.Additions then
				for _, addition in pairs(rewards.Additions) do
					local NewAdditionUi = AdditionUi:Clone()
					NewAdditionUi.Title.Text = addition.Title
					NewAdditionUi.Reward.Text = addition.Reward
					if addition.Color then
						local toColor = addition.Color
						local r = toColor.r - 0.5
						local g = toColor.g - 0.5
						local b = toColor.b - 0.5
						if r < 0 then r = 0 end
						if g < 0 then g = 0 end
						if b < 0 then b = 0 end
						toColor = Color3.new(r,g,b)
						--toColor = Color3.new(1,1,1)
						
						NewAdditionUi.Title.TextColor3 = toColor
						NewAdditionUi.Reward.TextColor3 = toColor
						
						local defaultT = NewAdditionUi.Title.Size
						local toSizeT = NewAdditionUi.Title.Size
						local xs = toSizeT.X.Scale
						local ys = toSizeT.Y.Scale + 0.05
						toSizeT = UDim2.new(xs,0,ys,0)
						local defaultR = NewAdditionUi.Reward.Size
						local toSizeR = NewAdditionUi.Reward.Size
						local xs = toSizeR.X.Scale
						local ys = toSizeR.Y.Scale + 0.05
						toSizeR = UDim2.new(xs,0,ys,0)
						
						local tTween = TweenService:Create(NewAdditionUi.Title, 
							TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), 
							{TextColor3 = addition.Color, Size = toSizeT})
						local rTween = TweenService:Create(NewAdditionUi.Reward, 
							TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), 
							{TextColor3 = addition.Color, Size = toSizeR})
						tTween:Play()
						rTween:Play()
					end
					NewAdditionUi.Parent = NewRewardItem.Additions
				end
			end
			NewRewardItem.Parent = ResultFrame.ContentFrame
		end
	end
	
	if result.TotalReward then
		for _, reward in pairs(result.TotalReward) do
			local NewRewardUi = RewardUi:Clone()
			ResourcesManager:SetGoodsImage(NewRewardUi.Icon, reward)
			NewRewardUi.Title.Text = reward.Number
			NewRewardUi.Parent = ResultFrame.TotalFrame.RewardItem.Rewards
		end
	end

	showResult()
end

DisplayEndResult.OnClientEvent:connect(OnEndResult)

local UserInputService = R:Wait("UserInputService")

local function onInputEnded(inputObject, gameProcessedEvent)
	-- 接着检查输入是否为键盘事件
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		--print("松开了一个按键：" .. inputObject.KeyCode.Name)
		if inputObject.KeyCode == Enum.KeyCode.Escape then
			closeResult()
		end
	end
end

UserInputService.InputEnded:Connect(onInputEnded)


return ResultManager
