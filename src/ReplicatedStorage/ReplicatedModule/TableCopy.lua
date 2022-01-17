local TableCopy = {}

--拷贝table数据，浅复制
function TableCopy:ShallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

--拷贝table数据，深复制，多重table复制
function TableCopy:DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = TableCopy:DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

return TableCopy
