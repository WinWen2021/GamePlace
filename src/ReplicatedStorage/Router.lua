local Router = {}

--get string length by utf-8
local function GetStringCount(str)
	local _,count = string.gsub(str, "[^\128-\193]", "")
	return count
end

--Transform string to char table by utf-8
local function GetStringChar(str)
	local temp = {}
	for uchar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
		temp[#temp+1] = uchar
	end
	return temp
end

--Transform string to table by utf-8
local function GetStringTableByDelimiter(str, delimiter)
	local char = GetStringChar(str) --%z:匹配0 *:表示0个至任意多个
	local temp = {}
	local subStr = ""
	for _, c in pairs(char) do
		if c == delimiter then
			table.insert(temp, subStr)
			subStr = ""
		else
			subStr = subStr .. c
		end
	end
	if subStr ~= "" then
		table.insert(temp, subStr)
		subStr = ""
	end
	return temp
end

--Public function

-- Get route from server or parent, will waiting and get instance till child loaded
-- basicRoute: the basic route, you can put the server name or parent instance
-- path: the target instance path
-- delimiter: You can customize your element separator, the default is "."
function Router:Wait(basicRoute, path, delimiter, isFind)
	assert(basicRoute, "Please confirm the basic route")
	local newInstance = basicRoute
	local newParentArray = nil
	if type(basicRoute) == "string" then
		newParentArray = GetStringTableByDelimiter(basicRoute, delimiter and delimiter or ".")
		if newParentArray and #newParentArray >=1 then
			newInstance = game:GetService(newParentArray[1])
			table.remove(newParentArray, 1)
			for _, subPath in pairs(newParentArray) do
				newInstance = subPath == "Parent" and newInstance.Parent or (
					isFind and newInstance:FindFirstChild(subPath) or newInstance:WaitForChild(subPath)
				)
			end
		end
	end
	if not path or path == "" then return newInstance end
	local newPathArray = GetStringTableByDelimiter(path, delimiter and delimiter or ".")
	if newPathArray and #newPathArray >=1 then
		for _, subPath in pairs(newPathArray) do
			newInstance = subPath == "Parent" and newInstance.Parent or (
				isFind and newInstance:FindFirstChild(subPath) or newInstance:WaitForChild(subPath)
			)
		end
	end
	return newInstance
end

-- Get route from server or parent, the diffrent to Router:Wait is Router:Find will find first child from basic route directy
-- basicRoute: the basic route, you can put the server name or parent instance
-- path: the target instance path
-- delimiter: You can customize your element separator, the default is "."
function Router:Find(basicRoute, path, delimiter)
	return Router:Wait(basicRoute, path, delimiter, true)
end

-- Get modulescript by router
function Router:Require(basicRoute, path, delimiter)
	return require(Router:Wait(basicRoute, path, delimiter))
end

-- Get local player in client
function Router:GetLocalPlayer()
	return game:GetService("Players").LocalPlayer
end

-- Get local player gui in client
function Router:GetLocalPlayerGui()
	local player = Router:GetLocalPlayer()
	assert(player, "The local player can be call by clien only")
	return player:WaitForChild("PlayerGui")
end

-- Check if the current reference is the client
function Router:IsClient()
	return Router:GetLocalPlayer() and true or false
end

-- Check if the current reference is the server
function Router:IsServer()
	return not Router:IsClient()
end

return Router
