--说明：将此Script放入ServerScriptService中
--您可以使用 require(game:GetService("ReplicatedStorage"):WaitForChild("EventManager")) 获得EventManager
print("EventSystem")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local EventManager = script:WaitForChild("EventManager")
local Events = script:WaitForChild("Events")

if ServerScriptService:FindFirstChild("EventSystem") == nil then
	script.Parent = ServerScriptService
end

if ReplicatedStorage:FindFirstChild("EventManager") == nil then
	EventManager.Parent = ReplicatedStorage
	Events.Parent = EventManager
	require(EventManager)
end

