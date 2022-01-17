local Toast = {}
Toast.__index = Toast
Toast.Enum = {
	Top = 1,
	Center = 2,
	Bottom = 3,
}
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

function Toast.new()
	local self = setmetatable({}, Toast)
	local player = game:GetService("Players").LocalPlayer
	assert(player, "Toast.new() can be call by client only")
	
	self.gui = Instance.new("ScreenGui", player:FindFirstChild("PlayerGui"))
	self.gui.Name = "ToastGui"
	self.gui.Enabled = false
	
	self.Duration = 1
	self.ContentSize = 50
	self.Position = Toast.Enum.Center
	self.DefaultColor = Color3.new(1,1,1)
	self.Color = self.DefaultColor
	
	local function createContentLable(content, size, color3, position)
		if not content then content = "TextLabel" end
		if not size or type(size) ~= "number" then size = 50 end
		if not color3 or not color3.r then color3 = self.DefaultColor end
		
		if position == Toast.Enum.Top then position = 0.1
		elseif position == Toast.Enum.Center then position = 0.45
		elseif position == Toast.Enum.Bottom then position = 0.9
		else position = 0.45
		end
		
		local newLable = Instance.new("TextLabel", self.gui)
		newLable.BackgroundTransparency = 1
		newLable.AnchorPoint = Vector2.new(0.5, 0.5)
		newLable.Position = UDim2.new(0.5,0,position,0)
		newLable.TextStrokeColor3 = Color3.new(0,0,0)
		newLable.TextStrokeTransparency = 0
		newLable.TextSize = size
		newLable.Text = content
		newLable.TextColor3 = color3 
		newLable.TextScaled = true
		
		if self.ContentLable then
			if type(self.ContentLable) ~= "table" then
				self.ContentLable = {self.ContentLable, }
			end
			table.insert(self.ContentLable, newLable)
			local contentTotalSize = 0
			for _, lable in pairs(self.ContentLable) do
				local lableSize = TextService:GetTextSize(lable.Text, lable.TextSize, 0, Vector2.new(5000,1000)) + Vector2.new(1,1)
				contentTotalSize += lableSize.X
			end
			local centerSize = contentTotalSize / 2
			local setSize = 0
			for index, lable in pairs(self.ContentLable) do
				local lableSize = TextService:GetTextSize(lable.Text, lable.TextSize, 0, Vector2.new(5000,1000)) + Vector2.new(1,1)
				lable.Size = UDim2.new(0,lableSize.X,0,lableSize.Y)
				lable.Position = UDim2.new(0.5, -(centerSize - setSize - lableSize.X / 2), position,0)
				setSize += lableSize.X
			end
		else
			local lableSize = TextService:GetTextSize(newLable.Text, newLable.TextSize, 0, Vector2.new(5000,1000)) + Vector2.new(1,1)
			newLable.Size = UDim2.new(0,lableSize.X,0,lableSize.Y)
			self.ContentLable = newLable
		end
		return newLable
	end
	local function removeContentLable()
		if not self.ContentLable then return end
		if type(self.ContentLable) ~= "table" then
			self.ContentLable:Destroy()
			self.ContentLable = nil
			return
		end
		for i=#self.ContentLable, 1, -1 do
			self.ContentLable[i]:Destroy()
		end
		self.ContentLable = nil
	end
	function self.setContent(content)
		if not content then return end
		self.Content = content
		return self
	end
	function self.setDuration(duration)
		if not duration then return end
		assert(type(duration)=="number", "Toast.setDuration accept number value only")
		self.Duration = duration
		return self
	end
	function self.setContentSize(size)
		if not size then return end
		assert(type(size)=="number", "Toast.setContentSize accept number value only")
		self.ContentSize = size or 50
		return self
	end
	function self.setDefaultColor(color3)
		if not color3 then return end
		assert(color3.r, "the color accept Color3Value only")
		self.DefaultColor = color3
		return self
	end
	function self.setColor(color3)
		if not color3 then return end
		if type(color3) == "table" then
			for _, color in pairs(color3) do
				if type(color) == "table" then
					for _, c in pairs(color) do
						assert(c.r, "the color accept Color3Value only")
					end
				else
					assert(color.r, "the color accept Color3Value only")
				end
			end
		else
			assert(color3.r, "the color accept Color3Value only")
		end
		self.Color = color3
		return self
	end
	function self.setPosition(position)
		if not position then return end
		local isP = false
		for _, p in pairs(Toast.Enum) do
			if p == position then
				isP = true
				self.Position = position
				break
			end
		end
		assert(isP, "the position accept Toast.Enum value only")
		return self
	end
	local _onStarted = function(index) end
	function self.setOnStarted(fun)
		assert(fun and type(fun) == "function", "Toast.setOnStart accept function only")
		_onStarted = fun
		return self
	end
	local _onComplated = function(index) end
	function self.setOnComplated(fun)
		assert(fun and type(fun) == "function", "Toast.setOnComplated accept function only")
		_onComplated = fun
		return self
	end
	local _onDestroy = function() end
	function self.setOnDestroy(fun)
		assert(fun and type(fun) == "function", "Toast.setOnDestroy accept function only")
		_onDestroy = fun
		return self
	end
	function self.show(content, duration, size, color3, position)
		assert(self.gui, "Toast destroyed, pls call new() to get a new instance")
		if content then self.setContent(content) end
		if duration then self.setDuration(duration) end
		if size then self.setContentSize(size) end
		if color3 then self.setColor(color3) end
		if position then self.setPosition(position) end
		assert(self.Content, "pls. set content")
		
		self.gui.Enabled = true
		
		coroutine.wrap(function()
			local contentArray = nil
			if type(self.Content) == "table" then
				contentArray = self.Content
			else 
				contentArray = {tostring(self.Content)}
			end
			for i, content in pairs(contentArray) do
				if not self.gui then return end
				if type(content) ~= "table" then
					content = {tostring(content)}
				end
				for ii, text in pairs(content) do
					local color = self.Color
					if type(color)=="table" then
						if color[i] then 
							if type(color[i])=="table" and color[i][ii] then
								color = color[i][ii] 
							else
								color = color[i]
							end
						end
					end
					createContentLable(text, self.ContentSize, color, self.Position)
				end
				_onStarted(i)
				
				--create animation
				local contentLable = self.ContentLable
				if type(contentLable) ~= "table" then
					contentLable = {contentLable}
				end
				for _, lable in pairs(contentLable)  do
					local defaultSize = lable.Size
					lable.Size = UDim2.new(0,0,0,0)
					lable.TextTransparency = 1
					TweenService:Create(lable, 
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), 
						{Size = defaultSize, TextTransparency = 0}):Play()
				end
				
				wait(self.Duration-0.1)
				for _, lable in pairs(contentLable)  do
					TweenService:Create(lable, 
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), 
						{Size = UDim2.new(0,0,0,0), TextTransparency = 1}):Play()
				end
				wait(0.1)
				
				_onComplated(i)
				removeContentLable()
			end
			self.destroy()
		end)()
		
		return self
	end
	function self.destroy()
		if not self.gui then return end
		_onDestroy()
		self.gui:Destroy()
		self.gui = nil
	end
	
	return self
end


return Toast
