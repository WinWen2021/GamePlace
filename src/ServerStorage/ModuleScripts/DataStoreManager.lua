local DataStoreManager = {}

DataStoreManager.DataType = {
	PlayerData = "PlayerData",
	TaskData = "TaskData"
}

local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore(DataStoreManager.DataType.PlayerData)
local TaskDataStore = DataStoreService:GetDataStore(DataStoreManager.DataType.TaskData)

function DataStoreManager:SaveDataToDataStore(player, dataType, dataValue)
	local playerId = player.UserId
	--if playerId <= 0 then return end

	local saveDataTillSucc = 3	--若是保存失败，重复保存次数
	local success = false
	local err = nil
	local save = function()
		if (dataType == DataStoreManager.DataType.PlayerData) then
			PlayerDataStore:SetAsync(playerId..":"..DataStoreManager.DataType.PlayerData, dataValue)
		elseif (dataType == DataStoreManager.DataType.TaskData) then
			TaskDataStore:SetAsync(playerId..":"..DataStoreManager.DataType.TaskData, dataValue)
		else
			local err = "存储数据类型错误"
			error(err)
			return false, err
		end
	end
	repeat
		success, err = pcall(save)
		saveDataTillSucc = saveDataTillSucc - 1
	until success or saveDataTillSucc <= 0

	if not success then
		print(err)
	end
	return success, err
end

function DataStoreManager:GetDataFromDataStore(player, dataType)
	local playerId = player.UserId
	--if playerId <= 0 then return end

	local dataValue = nil
	local saveDataTillSucc = 3
	local success = false
	local err = nil
	local get = function()
		if (dataType == DataStoreManager.DataType.PlayerData) then
			dataValue = PlayerDataStore:GetAsync(playerId..":"..DataStoreManager.DataType.PlayerData)
		elseif (dataType == DataStoreManager.DataType.TaskData) then
			dataValue = TaskDataStore:GetAsync(playerId..":"..DataStoreManager.DataType.TaskData)
		else
			local err = "存储数据类型错误"
			error(err)
			return false, err
		end
		
	end
	repeat
		success, err = pcall(get)
		saveDataTillSucc = saveDataTillSucc - 1
	until success or saveDataTillSucc <= 0

	if not success then
		print(err)
	end

	return dataValue, success, err
end

return DataStoreManager
