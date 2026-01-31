--!strict
--!native
--!optimize 2

local library = {}

local TweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local text_service = game:GetService("TextService")
local http = game:GetService("HttpService")
local local_player = game:GetService("Players").LocalPlayer
local mouse = local_player:GetMouse()

function library:tween(...)
	TweenService:Create(...):Play()
end

function library:create(object, properties, parent)
	local obj = Instance.new(object)
	for i, v in properties do
		obj[i] = v
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

function library:get_text_size(...)
	return text_service:GetTextSize(...)
end

function library:set_draggable(gui)
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function library.new(library_title, cfg_location)
	local menu = {}
	menu.values = {}
	menu.open = true

	if cfg_location and not isfolder(cfg_location) then
		makefolder(cfg_location)
	end

	local ScreenGui = library:create("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Name = "unknown",
		IgnoreGuiInset = true,
	})

	if syn then
		syn.protect_gui(ScreenGui)
	end

	ScreenGui.Parent = game:GetService("CoreGui")

	uis.InputBegan:Connect(function(key)
		if key.KeyCode ~= Enum.KeyCode.Insert then return end

		ScreenGui.Enabled = not ScreenGui.Enabled
		menu.open = ScreenGui.Enabled

		while ScreenGui.Enabled do
			uis.MouseIconEnabled = true
			rs.RenderStepped:Wait()
		end
	end)

	local Main = library:create("ImageButton", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderColor3 = Color3.fromRGB(78, 93, 234),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 700, 0, 500),
		Image = "http://www.roblox.com/asset/?id=7300333488",
		AutoButtonColor = false,
		Modal = true,
	}, ScreenGui)

	library:set_draggable(Main)
local Title = library:create("TextLabel", {
	Name = "Title",
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, 0, 0, 6),
	Size = UDim2.new(0, 0, 0, 30), -- 👈 no full-width
	AutomaticSize = Enum.AutomaticSize.X, -- 👈 key part
	Font = Enum.Font.Ubuntu,
	Text = library_title,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	RichText = true,
}, Main)



	local TabButtons = library:create("Frame", {
		Name = "TabButtons",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 41),
		Size = UDim2.new(0, 76, 0, 447),
	}, Main)

	library:create("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, TabButtons)

	local Tabs = library:create("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 102, 0, 42),
		Size = UDim2.new(0, 586, 0, 446),
	}, Main)

	local is_first_tab = true
	local selected_tab
	local tab_num = 1

	function menu.new_tab(tab_image)
		local tab = {tab_num = tab_num}
		menu.values[tab_num] = {}
		tab_num = tab_num + 1

		local TabButton = library:create("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 76, 0, 90),
			Text = "",
		}, TabButtons)

		local TabImage = library:create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 32, 0, 32),
			Image = tab_image,
			ImageColor3 = Color3.fromRGB(100, 100, 100),
		}, TabButton)

		local Tab = library:create("Frame", {
			Name = "Tab",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
		}, Tabs)

		local TabSections = library:create("Frame", {
			Name = "TabSections",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			ClipsDescendants = true,
		}, Tab)

		library:create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}, TabSections)

		local TabFrames = library:create("Frame", {
			Name = "TabFrames",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 29),
			Size = UDim2.new(1, 0, 0, 418),
		}, Tab)

		if is_first_tab then
			is_first_tab = false
			selected_tab = TabButton
			TabImage.ImageColor3 = Color3.fromRGB(84, 101, 255)
			Tab.Visible = true
		end

		TabButton.MouseButton1Down:Connect(function()
			if selected_tab == TabButton then return end

			for _, TButtons in TabButtons:GetChildren() do
				if not TButtons:IsA("TextButton") then continue end
				library:tween(TButtons.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)})
			end
			for _, Tab in Tabs:GetChildren() do
				Tab.Visible = false
			end
			Tab.Visible = true
			selected_tab = TabButton
			library:tween(TabImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(84, 101, 255)})
		end)

		TabButton.MouseEnter:Connect(function()
			if selected_tab == TabButton then return end
			library:tween(TabImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 255, 255)})
		end)

		TabButton.MouseLeave:Connect(function()
			if selected_tab == TabButton then return end
			library:tween(TabImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)})
		end)

		local is_first_section = true
		local num_sections = 0
		local selected_section

		function tab.new_section(section_name)
			local section = {}
			num_sections += 1
			menu.values[tab.tab_num][section_name] = {}

			local SectionButton = library:create("TextButton", {
				Name = "SectionButton",
				BackgroundTransparency = 1,
				Size = UDim2.new(1 / num_sections, 0, 1, 0),
				Font = Enum.Font.Ubuntu,
				Text = section_name,
				TextColor3 = Color3.fromRGB(100, 100, 100),
				TextSize = 15,
			}, TabSections)

			for _, SectionButtons in TabSections:GetChildren() do
				if SectionButtons:IsA("UIListLayout") then continue end
				SectionButtons.Size = UDim2.new(1 / num_sections, 0, 1, 0)
			end

			SectionButton.MouseEnter:Connect(function()
				if selected_section == SectionButton then return end
				library:tween(SectionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
			end)

			SectionButton.MouseLeave:Connect(function()
				if selected_section == SectionButton then return end
				library:tween(SectionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(100, 100, 100)})
			end)

			local SectionDecoration = library:create("Frame", {
				Name = "SectionDecoration",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 27),
				Size = UDim2.new(1, 0, 0, 1),
				Visible = false,
			}, SectionButton)

			library:create("UIGradient", {
				Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 33, 38)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(81, 97, 243)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 33, 38))
				},
			}, SectionDecoration)

			local SectionFrame = library:create("Frame", {
				Name = "SectionFrame",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Visible = false,
			}, TabFrames)

			local Left = library:create("Frame", {
				Name = "Left",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 0, 14),
				Size = UDim2.new(0, 282, 0, 395),
			}, SectionFrame)

			library:create("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 12),
			}, Left)

			local Right = library:create("Frame", {
				Name = "Right",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 298, 0, 14),
				Size = UDim2.new(0, 282, 0, 395),
			}, SectionFrame)

			library:create("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 12),
			}, Right)

			SectionButton.MouseButton1Down:Connect(function()
				for _, SectionButtons in TabSections:GetChildren() do
					if SectionButtons:IsA("UIListLayout") then continue end
					library:tween(SectionButtons, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(100, 100, 100)})
					SectionButtons.SectionDecoration.Visible = false
				end
				for _, TabFrame in TabFrames:GetChildren() do
					if not TabFrame:IsA("Frame") then continue end
					TabFrame.Visible = false
				end

				selected_section = SectionButton
				SectionFrame.Visible = true
				library:tween(SectionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(84, 101, 255)})
				SectionDecoration.Visible = true
			end)

			if is_first_section then
				is_first_section = false
				selected_section = SectionButton
				SectionButton.TextColor3 = Color3.fromRGB(84, 101, 255)
				SectionDecoration.Visible = true
				SectionFrame.Visible = true
			end

			function section.new_sector(sector_name, sector_side)
				local sector = {}
				local actual_side = sector_side == "Right" and Right or Left
				menu.values[tab.tab_num][section_name][sector_name] = {}

				local Border = library:create("Frame", {
					BackgroundColor3 = Color3.fromRGB(5, 5, 5),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					Size = UDim2.new(1, 0, 0, 20),
				}, actual_side)

				local Container = library:create("Frame", {
					BackgroundColor3 = Color3.fromRGB(10, 10, 10),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
				}, Border)

				library:create("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, Container)

				library:create("UIPadding", {
					PaddingTop = UDim.new(0, 12),
				}, Container)

				library:create("TextLabel", {
					Name = "Title",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0, -8),
					Size = UDim2.new(1, 0, 0, 15),
					Font = Enum.Font.Ubuntu,
					Text = sector_name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
				}, Border)

				function sector.element(type, text, data, callback, c_flag)
					text = text or type
					data = data or {}
					callback = callback or function() end

					local value = {}
					local flag = c_flag and text .. " " .. c_flag or text
					menu.values[tab.tab_num][section_name][sector_name][flag] = value

					local function do_callback()
						menu.values[tab.tab_num][section_name][sector_name][flag] = value
						callback(value)
					end

					local default = data.default

					local element = {}

					if type == "Toggle" then
						Border.Size = Border.Size + UDim2.new(0, 0, 0, 18)
						value = {Toggle = default and default.Toggle or false}

						local ToggleButton = library:create("TextButton", {
							Name = "Toggle",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 18),
							Text = "",
						}, Container)

						local ToggleFrame = library:create("Frame", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundColor3 = Color3.fromRGB(30, 30, 30),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							Position = UDim2.new(0, 9, 0.5, 0),
							Size = UDim2.new(0, 9, 0, 9),
						}, ToggleButton)

						local ToggleText = library:create("TextLabel", {
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 27, 0, 5),
							Size = UDim2.new(0, 200, 0, 9),
							Font = Enum.Font.Ubuntu,
							Text = text,
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
						}, ToggleButton)

						local mouse_in = false

						function element:set_value(new_value)
							value = new_value or value
							menu.values[tab.tab_num][section_name][sector_name][flag] = value

							if value.Toggle then
								library:tween(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(84, 101, 255)})
								library:tween(ToggleText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
							else
								library:tween(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
								if not mouse_in then
									library:tween(ToggleText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
								end
							end

							do_callback()
						end

						ToggleButton.MouseEnter:Connect(function()
							mouse_in = true
							if value.Toggle then return end
							library:tween(ToggleText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
						end)

						ToggleButton.MouseLeave:Connect(function()
							mouse_in = false
							if value.Toggle then return end
							library:tween(ToggleText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
						end)

						ToggleButton.MouseButton1Down:Connect(function()
							element:set_value({Toggle = not value.Toggle})
						end)

						element:set_value(value)
					elseif type == "Slider" then
						Border.Size = Border.Size + UDim2.new(0, 0, 0, 35)
						value = {Slider = default and default.default or 0}

						local min, max = default and default.min or 0, default and default.max or 100

						local Slider = library:create("Frame", {
							Name = "Slider",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 35),
						}, Container)

						local SliderText = library:create("TextLabel", {
							Name = "SliderText",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 9, 0, 6),
							Size = UDim2.new(0, 200, 0, 9),
							Font = Enum.Font.Ubuntu,
							Text = text,
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
						}, Slider)

						local SliderButton = library:create("TextButton", {
							Name = "SliderButton",
							BackgroundColor3 = Color3.fromRGB(25, 25, 25),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							Position = UDim2.new(0, 9, 0, 20),
							Size = UDim2.new(0, 260, 0, 10),
							AutoButtonColor = false,
							Text = "",
						}, Slider)

						local SliderFrame = library:create("Frame", {
							Name = "SliderFrame",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Size = UDim2.new(0, 0, 1, 0),
						}, SliderButton)

						library:create("UIGradient", {
							Color = ColorSequence.new{
								ColorSequenceKeypoint.new(0, Color3.fromRGB(79, 95, 239)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 67, 163))
							},
							Rotation = 90,
						}, SliderFrame)

						local SliderValue = library:create("TextLabel", {
							Name = "SliderValue",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 69, 0, 6),
							Size = UDim2.new(0, 200, 0, 9),
							Font = Enum.Font.Ubuntu,
							Text = value.Slider,
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Right,
						}, Slider)

						local is_sliding = false
						local mouse_in = false

						Slider.MouseEnter:Connect(function()
							library:tween(SliderText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
							library:tween(SliderValue, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
							mouse_in = true
						end)

						Slider.MouseLeave:Connect(function()
							if not is_sliding then
								library:tween(SliderText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
								library:tween(SliderValue, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
							end
							mouse_in = false
						end)

						SliderButton.MouseButton1Down:Connect(function()
							is_sliding = true

							local function update()
								SliderFrame.Size = UDim2.new(0, math.clamp(mouse.X - SliderFrame.AbsolutePosition.X, 0, 260), 1, 0)
								local val = math.floor((((max - min) / 260) * SliderFrame.AbsoluteSize.X) + min)
								if val ~= value.Slider then
									SliderValue.Text = val
									value.Slider = val
									do_callback()
								end
							end

							update()

							local move_connection = mouse.Move:Connect(update)
							local release_connection

							release_connection = uis.InputEnded:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 then
									is_sliding = false
									if not mouse_in then
										library:tween(SliderText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
										library:tween(SliderValue, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
									end
									move_connection:Disconnect()
									release_connection:Disconnect()
								end
							end)
						end)

						function element:set_value(new_value)
							value = new_value or value
							menu.values[tab.tab_num][section_name][sector_name][flag] = value

							local new_size = (value.Slider - min) / (max - min)
							SliderFrame.Size = UDim2.new(new_size, 0, 1, 0)
							SliderValue.Text = value.Slider
							do_callback()
						end

						element:set_value(value)
					elseif type == "Button" then
						Border.Size = Border.Size + UDim2.new(0, 0, 0, 30)

						local ButtonFrame = library:create("Frame", {
							Name = "ButtonFrame",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 30),
						}, Container)

						local Button = library:create("TextButton", {
							Name = "Button",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(25, 25, 25),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(0, 215, 0, 20),
							AutoButtonColor = false,
							Font = Enum.Font.Ubuntu,
							Text = text,
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 14,
						}, ButtonFrame)

						Button.MouseEnter:Connect(function()
							library:tween(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
						end)

						Button.MouseLeave:Connect(function()
							library:tween(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
						end)

						Button.MouseButton1Down:Connect(function()
							Button.BorderColor3 = Color3.fromRGB(84, 101, 255)
							library:tween(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(0, 0, 0)})
							do_callback()
						end)
					end

					return element
				end

				return sector
			end

			return section
		end

		return tab
	end

	return menu
end

return library
