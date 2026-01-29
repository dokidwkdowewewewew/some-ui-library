--!strict
--!native
--!optimize 2

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Library = {}

local screenGui = nil
local mainFrame = nil
local sidebar = nil
local contentFrame = nil
local currentSection = nil

local dragging = false
local dragStart = nil
local startPos = nil

local theme = {
	background = Color3.fromRGB(15, 15, 15),
	secondary = Color3.fromRGB(25, 25, 25),
	border = Color3.fromRGB(40, 40, 40),
	accent = Color3.fromRGB(255, 85, 85),
	text = Color3.fromRGB(255, 255, 255),
	textDark = Color3.fromRGB(150, 150, 150),
}

local function create(class, props)
	local obj = Instance.new(class)
	for k, v in props do
		if k ~= "Parent" then
			obj[k] = v
		end
	end
	if props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

function Library:CreateWindow(config)
	config = config or {}
	local title = config.Name or "UI"
	
	screenGui = create("ScreenGui", {
		Name = "CustomUI",
		Parent = game.CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	})
	
	mainFrame = create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 650, 0, 400),
		Position = UDim2.new(0.5, -325, 0.5, -200),
		BackgroundColor3 = theme.background,
		BorderColor3 = theme.border,
		BorderSizePixel = 1,
		Parent = screenGui,
	})
	
	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = theme.secondary,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})
	
	create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = theme.text,
		Font = Enum.Font.Code,
		TextSize = 14,
		Parent = titleBar,
	})
	
	sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 50, 1, -35),
		Position = UDim2.new(0, 0, 0, 35),
		BackgroundColor3 = theme.secondary,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})
	
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0),
		Parent = sidebar,
	})
	
	contentFrame = create("ScrollingFrame", {
		Name = "Content",
		Size = UDim2.new(1, -50, 1, -35),
		Position = UDim2.new(0, 50, 0, 35),
		BackgroundColor3 = theme.background,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = mainFrame,
	})
	
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = contentFrame,
	})
	
	create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = contentFrame,
	})
	
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	
	titleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	local Window = {}
	local tabIndex = 0
	
	function Window:CreateTab(config)
		config = config or {}
		local name = config.Name or "Tab"
		local icon = config.Icon or "🐱"
		
		tabIndex = tabIndex + 1
		local currentTabIndex = tabIndex
		
		local btn = create("TextButton", {
			Name = name,
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = theme.secondary,
			BorderSizePixel = 0,
			Text = icon,
			TextColor3 = theme.textDark,
			Font = Enum.Font.Code,
			TextSize = 20,
			LayoutOrder = currentTabIndex,
			Parent = sidebar,
		})
		
		local section = create("Frame", {
			Name = name,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false,
			LayoutOrder = currentTabIndex,
			Parent = contentFrame,
		})
		
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
			Parent = section,
		})
		
		btn.MouseButton1Click:Connect(function()
			for _, child in contentFrame:GetChildren() do
				if child:IsA("Frame") then
					child.Visible = false
				end
			end
			section.Visible = true
			currentSection = section
			
			for _, child in sidebar:GetChildren() do
				if child:IsA("TextButton") then
					child.TextColor3 = theme.textDark
				end
			end
			btn.TextColor3 = theme.accent
		end)
		
		if not currentSection then
			section.Visible = true
			currentSection = section
			btn.TextColor3 = theme.accent
		end
		
		local Tab = {}
		local sectionIndex = 0
		
		function Tab:CreateSection(config)
			config = config or {}
			local sectionTitle = config.Name or "Section"
			
			sectionIndex = sectionIndex + 1
			local currentSectionIndex = sectionIndex
			
			local group = create("Frame", {
				Name = sectionTitle,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = currentSectionIndex,
				Parent = section,
			})
			
			create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = tostring(sectionTitle):upper(),
				TextColor3 = theme.text,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 0,
				Parent = group,
			})
			
			local container = create("Frame", {
				Name = "Container",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Parent = group,
			})
			
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
				Parent = container,
			})
			
			create("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				Parent = container,
			})
			
			local Section = {}
			local elementIndex = 0
			
			local function getNextOrder()
				elementIndex = elementIndex + 1
				return elementIndex
			end
			
			function Section:CreateButton(config)
				config = config or {}
				local btnName = config.Name or "Button"
				local callback = config.Callback or function() end
				
				local btnFrame = create("TextButton", {
					Name = btnName,
					Size = UDim2.new(1, 0, 0, 25),
					BackgroundColor3 = theme.secondary,
					BorderColor3 = theme.border,
					BorderSizePixel = 1,
					Text = btnName,
					TextColor3 = theme.text,
					Font = Enum.Font.Code,
					TextSize = 11,
					LayoutOrder = getNextOrder(),
					Parent = container,
				})
				
				btnFrame.MouseButton1Click:Connect(callback)
			end
			
			function Section:CreateToggle(config)
				config = config or {}
				local toggleName = config.Name or "Toggle"
				local default = config.CurrentValue or false
				local callback = config.Callback or function() end
				
				local toggleFrame = create("Frame", {
					Name = toggleName,
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1,
					LayoutOrder = getNextOrder(),
					Parent = container,
				})
				
				local checkbox = create("Frame", {
					Size = UDim2.new(0, 12, 0, 12),
					Position = UDim2.new(0, 0, 0.5, -6),
					BackgroundColor3 = default and theme.accent or Color3.fromRGB(15, 15, 15),
					BorderColor3 = theme.accent,
					BorderSizePixel = 1,
					Parent = toggleFrame,
				})
				
				create("TextLabel", {
					Size = UDim2.new(1, -20, 1, 0),
					Position = UDim2.new(0, 20, 0, 0),
					BackgroundTransparency = 1,
					Text = toggleName,
					TextColor3 = theme.text,
					Font = Enum.Font.Code,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = toggleFrame,
				})
				
				local btn = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					Parent = toggleFrame,
				})
				
				local state = default
				btn.MouseButton1Click:Connect(function()
					state = not state
					checkbox.BackgroundColor3 = state and theme.accent or Color3.fromRGB(15, 15, 15)
					callback(state)
				end)
				
				return {
					SetValue = function(self, v)
						state = v
						checkbox.BackgroundColor3 = state and theme.accent or Color3.fromRGB(15, 15, 15)
					end
				}
			end
			
			function Section:CreateSlider(config)
				config = config or {}
				local sliderName = config.Name or "Slider"
				local min = config.Min or 0
				local max = config.Max or 100
				local default = config.CurrentValue or 50
				local callback = config.Callback or function() end
				
				local sliderFrame = create("Frame", {
					Name = sliderName,
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundTransparency = 1,
					LayoutOrder = getNextOrder(),
					Parent = container,
				})
				
				create("TextLabel", {
					Size = UDim2.new(1, -60, 0, 15),
					BackgroundTransparency = 1,
					Text = sliderName,
					TextColor3 = theme.text,
					Font = Enum.Font.Code,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = sliderFrame,
				})
				
				local valueLabel = create("TextLabel", {
					Size = UDim2.new(0, 50, 0, 15),
					Position = UDim2.new(1, -50, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(default),
					TextColor3 = theme.textDark,
					Font = Enum.Font.Code,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = sliderFrame,
				})
				
				local sliderBg = create("Frame", {
					Size = UDim2.new(1, 0, 0, 4),
					Position = UDim2.new(0, 0, 1, -10),
					BackgroundColor3 = theme.secondary,
					BorderSizePixel = 0,
					Parent = sliderFrame,
				})
				
				local sliderFill = create("Frame", {
					Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
					BackgroundColor3 = theme.accent,
					BorderSizePixel = 0,
					Parent = sliderBg,
				})
				
				local value = default
				local draggingSlider = false
				
				local function update(input)
					local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
					value = math.floor(min + (max - min) * relX)
					sliderFill.Size = UDim2.new(relX, 0, 1, 0)
					valueLabel.Text = tostring(value)
					callback(value)
				end
				
				sliderBg.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = true
						update(input)
					end
				end)
				
				sliderBg.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = false
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
						update(input)
					end
				end)
			end
			
			function Section:CreateDropdown(config)
				config = config or {}
				local dropdownName = config.Name or "Dropdown"
				local options = config.Options or {"Option1"}
				local default = config.CurrentOption or options[1]
				local callback = config.Callback or function() end
				
				local dropdownFrame = create("Frame", {
					Name = dropdownName,
					Size = UDim2.new(1, 0, 0, 25),
					BackgroundTransparency = 1,
					LayoutOrder = getNextOrder(),
					ClipsDescendants = false,
					Parent = container,
				})
				
				local btn = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 25),
					BackgroundColor3 = theme.secondary,
					BorderColor3 = theme.border,
					BorderSizePixel = 1,
					Text = dropdownName .. ": " .. default,
					TextColor3 = theme.text,
					Font = Enum.Font.Code,
					TextSize = 11,
					Parent = dropdownFrame,
				})
				
				local list = create("Frame", {
					Size = UDim2.new(1, 0, 0, #options * 22),
					Position = UDim2.new(0, 0, 1, 2),
					BackgroundColor3 = theme.secondary,
					BorderColor3 = theme.border,
					BorderSizePixel = 1,
					Visible = false,
					ZIndex = 10,
					Parent = dropdownFrame,
				})
				
				create("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 0),
					Parent = list,
				})
				
				local selected = default
				
				for i, option in options do
					local optBtn = create("TextButton", {
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundColor3 = theme.secondary,
						BorderSizePixel = 0,
						Text = option,
						TextColor3 = option == selected and theme.accent or theme.text,
						Font = Enum.Font.Code,
						TextSize = 10,
						LayoutOrder = i,
						Parent = list,
					})
					
					optBtn.MouseButton1Click:Connect(function()
						selected = option
						btn.Text = dropdownName .. ": " .. option
						list.Visible = false
						
						for _, child in list:GetChildren() do
							if child:IsA("TextButton") then
								child.TextColor3 = child.Text == selected and theme.accent or theme.text
							end
						end
						
						callback(option)
					end)
				end
				
				btn.MouseButton1Click:Connect(function()
					list.Visible = not list.Visible
				end)
			end
			
			function Section:CreateLabel(config)
				config = config or {}
				local text = config.Text or "Label"
				
				create("TextLabel", {
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = theme.textDark,
					Font = Enum.Font.Code,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = getNextOrder(),
					Parent = container,
				})
			end
			
			function Section:CreateDivider()
				create("Frame", {
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = theme.border,
					BorderSizePixel = 0,
					LayoutOrder = getNextOrder(),
					Parent = container,
				})
			end
			
			return Section
		end
		
		return Tab
	end
	
	function Window:Destroy()
		if screenGui then
			screenGui:Destroy()
		end
	end
	
	return Window
end

function Library:Notify(config)
	config = config or {}
	local title = config.Title or "Notification"
	local content = config.Content or ""
	local duration = config.Duration or 3
	
	if not screenGui then return end
	
	local notif = create("Frame", {
		Size = UDim2.new(0, 250, 0, 60),
		Position = UDim2.new(1, -260, 1, -70),
		BackgroundColor3 = theme.secondary,
		BorderColor3 = theme.border,
		BorderSizePixel = 1,
		Parent = screenGui,
	})
	
	create("TextLabel", {
		Size = UDim2.new(1, -10, 0, 20),
		Position = UDim2.new(0, 5, 0, 5),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = theme.accent,
		Font = Enum.Font.Code,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = notif,
	})
	
	create("TextLabel", {
		Size = UDim2.new(1, -10, 0, 30),
		Position = UDim2.new(0, 5, 0, 25),
		BackgroundTransparency = 1,
		Text = content,
		TextColor3 = theme.text,
		Font = Enum.Font.Code,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = notif,
	})
	
	task.spawn(function()
		task.wait(duration)
		notif:Destroy()
	end)
end

return Library
