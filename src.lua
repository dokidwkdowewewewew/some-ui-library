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

local function makeSquare(parent, size, color, filled)
	return create("Frame", {
		Size = UDim2.new(0, size, 0, size),
		BackgroundColor3 = filled and color or Color3.fromRGB(15, 15, 15),
		BorderColor3 = color,
		BorderSizePixel = 1,
		Parent = parent,
	})
end

function Library:CreateWindow(config)
	config = config or {}
	local title = config.Name or "UI"
	
	screenGui = create("ScreenGui", {
		Name = "CustomUI",
		Parent = game.CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
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
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = contentFrame,
	})
	
	create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
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
	
	function Window:CreateTab(config)
		config = config or {}
		local name = config.Name or "Tab"
		local icon = config.Icon or "🐱"
		
		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = theme.secondary,
			BorderSizePixel = 0,
			Text = icon,
			TextColor3 = theme.textDark,
			Font = Enum.Font.Code,
			TextSize = 20,
			Parent = sidebar,
		})
		
		local section = create("Frame", {
			Name = name,
			Size = UDim2.new(1, -20, 0, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = contentFrame,
		})
		
		create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = section,
		})
		
		btn.MouseButton1Click:Connect(function()
			if currentSection then
				currentSection.Visible = false
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
		
		function Tab:CreateSection(config)
			config = config or {}
			local title = config.Name or "Section"
			
			local group = create("Frame", {
				Name = title,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = section,
			})
			
			create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = tostring(title):upper(),
				TextColor3 = theme.text,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = group,
			})
			
			local container = create("Frame", {
				Name = "Container",
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = group,
			})
			
			create("UIListLayout", {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = container,
			})
			
			local Section = {}
			
			function Section:CreateButton(config)
				config = config or {}
				local name = config.Name or "Button"
				local callback = config.Callback or function() end
				
				local btnFrame = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 25),
					BackgroundColor3 = theme.secondary,
					BorderColor3 = theme.border,
					BorderSizePixel = 1,
					Text = name,
					TextColor3 = theme.text,
					Font = Enum.Font.Code,
					TextSize = 11,
					Parent = container,
				})
				
				btnFrame.MouseButton1Click:Connect(callback)
			end
			
			function Section:CreateToggle(config)
				config = config or {}
				local name = config.Name or "Toggle"
				local default = config.CurrentValue or false
				local callback = config.Callback or function() end
				
				local toggleFrame = create("Frame", {
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1,
					Parent = container,
				})
				
				local checkbox = makeSquare(toggleFrame, 12, theme.accent, default)
				checkbox.Position = UDim2.new(0, 0, 0.5, -6)
				
				create("TextLabel", {
					Size = UDim2.new(1, -20, 1, 0),
					Position = UDim2.new(0, 20, 0, 0),
					BackgroundTransparency = 1,
					Text = name,
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
				local name = config.Name or "Slider"
				local min = config.Min or 0
				local max = config.Max or 100
				local default = config.CurrentValue or 50
				local callback = config.Callback or function() end
				
				local sliderFrame = create("Frame", {
					Size = UDim2.new(1, 0, 0, 35),
					BackgroundTransparency = 1,
					Parent = container,
				})
				
				create("TextLabel", {
					Size = UDim2.new(1, 0, 0, 15),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = theme.text,
					Font = Enum.Font.Code,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = sliderFrame,
				})
				
				local sliderBg = create("Frame", {
					Size = UDim2.new(1, -60, 0, 3),
					Position = UDim2.new(0, 0, 0, 23),
					BackgroundColor3 = theme.secondary,
					BorderSizePixel = 0,
					Parent = sliderFrame,
				})
				
				local sliderFill = create("Frame", {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = theme.accent,
					BorderSizePixel = 0,
					Parent = sliderBg,
				})
				
				local valueLabel = create("TextLabel", {
					Size = UDim2.new(0, 50, 0, 15),
					Position = UDim2.new(1, -50, 0, 18),
					BackgroundTransparency = 1,
					Text = tostring(default),
					TextColor3 = theme.textDark,
					Font = Enum.Font.Code,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = sliderFrame,
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
				
				sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			end
			
			function Section:CreateDropdown(config)
				config = config or {}
				local name = config.Name or "Dropdown"
				local options = config.Options or {"Option1"}
				local default = config.CurrentOption or options[1]
				local callback = config.Callback or function() end
				
				local dropdownFrame = create("Frame", {
					Size = UDim2.new(1, 0, 0, 25),
					BackgroundTransparency = 1,
					Parent = container,
				})
				
				local btn = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = theme.secondary,
					BorderColor3 = theme.border,
					BorderSizePixel = 1,
					Text = name .. ": " .. default,
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
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = list,
				})
				
				local selected = default
				
				for _, option in options do
					local optBtn = create("TextButton", {
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundColor3 = theme.secondary,
						BorderSizePixel = 0,
						Text = option,
						TextColor3 = option == selected and theme.accent or theme.text,
						Font = Enum.Font.Code,
						TextSize = 10,
						Parent = list,
					})
					
					optBtn.MouseButton1Click:Connect(function()
						selected = option
						btn.Text = name .. ": " .. option
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
					Parent = container,
				})
			end
			
			function Section:CreateDivider()
				create("Frame", {
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = theme.border,
					BorderSizePixel = 0,
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
