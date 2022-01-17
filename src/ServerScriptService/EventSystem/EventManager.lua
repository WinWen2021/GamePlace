local EventManager = {}
EventManager.__index = EventManager
local self = setmetatable({}, EventManager)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local IsServer = not game:GetService("Players").LocalPlayer

local Events = require(script:WaitForChild("Events"))

self.RemoteEvent = {}
if IsServer then
	self.ServerEvent = {}
else
	self.ClientEvent = {}
end

local eventSystemInitialize = false

function initializeEventSystem()
	if not eventSystemInitialize then
		local RemoteEventFolder = ReplicatedStorage:FindFirstChild("RemoteEventSystem") or Instance.new("Folder")
		RemoteEventFolder.Name = "RemoteEventSystem"
		RemoteEventFolder.Parent = ReplicatedStorage
		local BindableEventFolder = nil
		if (IsServer) then
			BindableEventFolder = ServerScriptService:FindFirstChild("BindableEventSystem") or Instance.new("Folder")
			BindableEventFolder.Name = "BindableEventSystem"
			BindableEventFolder.Parent = ServerScriptService
		else
			BindableEventFolder = ReplicatedStorage:FindFirstChild("BindableEventSystem") or Instance.new("Folder")
			BindableEventFolder.Name = "BindableEventSystem"
			BindableEventFolder.Parent = ReplicatedStorage
		end
		
		if Events.RemoteEvent then
			initRemoteEvent(RemoteEventFolder, Events.RemoteEvent)
		end
		
		if (IsServer and Events.ServerEvent) or (not IsServer and Events.ClientEvent) then
			local events = IsServer and Events.ServerEvent or Events.ClientEvent
			initBindableEvent(BindableEventFolder, events)
		end
	end
end

function initRemoteEvent(folder, events, pond)
	if not pond then pond = self.RemoteEvent end
	for key, name in pairs(events) do
		if type(name) == "table" then
			if IsServer then
				local newFolder = Instance.new("Folder")
				newFolder.Name = key
				newFolder.Parent = folder
				pond[key] = {}
				initRemoteEvent(newFolder, name, pond[key])
			else
				local newFolder = folder:FindFirstChild(key)
				pond[key] = {}
				initRemoteEvent(newFolder, name, pond[key])
			end
		else
			if IsServer then
				assert(type(name)=="string", "RemoteEvent accept string type only")
				assert(not folder:FindFirstChild(name), "the name of \""..name.."\" RemoteEvent existed")
				local event = Instance.new("RemoteEvent")
				event.Name = name
				event.Parent = folder
				pond[name] = event
			else
				local event = folder:FindFirstChild(name)
				pond[name] = event
			end
		end
	end
end

function initBindableEvent(folder, events, pond)
	if not pond then 
		pond = IsServer and self.ServerEvent or self.ClientEvent
	end
	for key, name in pairs(events) do
		if type(name) == "table" then
			local newFolder = Instance.new("Folder")
			newFolder.Name = key
			newFolder.Parent = folder
			initBindableEvent(folder, name, pond[key])
		else
			assert(type(name)=="string", (IsServer and "ServerEvent" or "ClientEvent")..
				" accept string type only")
			assert(not folder:FindFirstChild(name), "the name of \""..name.."\" "..
				(IsServer and "ServerEvent" or "ClientEvent").." existed")
			local event = Instance.new("BindableEvent")
			event.Name = name
			event.Parent = folder
			pond[name] = event
		end
	end
end

initializeEventSystem()

return self
