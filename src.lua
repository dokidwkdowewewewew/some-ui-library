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
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, -22, 0, 30),
		Font = Enum.Font.Ubuntu,
		Text = library_title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
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

						function element:add_color_picker(picker_data)
							picker_data = picker_data or {}
							local picker = {}
							picker.value = picker_data.default or Color3.fromRGB(255, 255, 255)
							picker.callback = picker_data.callback or function() end

							local DisplayFrame = library:create("Frame", {
								BackgroundColor3 = picker.value,
								BorderColor3 = Color3.new(0, 0, 0),
								Size = UDim2.new(0, 28, 0, 14),
								Position = UDim2.new(1, -32, 0, 2),
								ZIndex = 6,
								Parent = ToggleButton,
							})

							local PickerOuter = library:create("Frame", {
								Name = "ColorPicker",
								BackgroundColor3 = Color3.new(0, 0, 0),
								BorderColor3 = Color3.new(0, 0, 0),
								Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
								Size = UDim2.fromOffset(200, 225),
								Visible = false,
								ZIndex = 15,
								Parent = ScreenGui,
							})

							DisplayFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
								PickerOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18)
							end)

							local PickerInner = library:create("Frame", {
								BackgroundColor3 = Color3.fromRGB(15, 15, 15),
								BorderColor3 = Color3.fromRGB(30, 30, 30),
								BorderMode = Enum.BorderMode.Inset,
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 16,
								Parent = PickerOuter,
							})

							local SatVibOuter = library:create("Frame", {
								BorderColor3 = Color3.new(0, 0, 0),
								Position = UDim2.new(0, 4, 0, 4),
								Size = UDim2.new(0, 175, 0, 175),
								ZIndex = 17,
								Parent = PickerInner,
							})

							local SatVibInner = library:create("Frame", {
								BackgroundColor3 = Color3.fromRGB(15, 15, 15),
								BorderColor3 = Color3.fromRGB(30, 30, 30),
								BorderMode = Enum.BorderMode.Inset,
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 18,
								Parent = SatVibOuter,
							})

							local SatVibMap = library:create("ImageLabel", {
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 18,
								Image = "rbxassetid://4155801252",
								Parent = SatVibInner,
							})

							local Cursor = library:create("ImageLabel", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Size = UDim2.new(0, 6, 0, 6),
								BackgroundTransparency = 1,
								Image = "http://www.roblox.com/asset/?id=9619665977",
								ImageColor3 = Color3.new(0, 0, 0),
								ZIndex = 19,
								Parent = SatVibMap,
							})

							library:create("ImageLabel", {
								Size = UDim2.new(0, 4, 0, 4),
								Position = UDim2.new(0, 1, 0, 1),
								BackgroundTransparency = 1,
								Image = "http://www.roblox.com/asset/?id=9619665977",
								ZIndex = 20,
								Parent = Cursor,
							})

							local HueOuter = library:create("Frame", {
								BorderColor3 = Color3.new(0, 0, 0),
								Position = UDim2.new(0, 183, 0, 4),
								Size = UDim2.new(0, 13, 0, 175),
								ZIndex = 17,
								Parent = PickerInner,
							})

							local HueInner = library:create("Frame", {
								BackgroundColor3 = Color3.new(1, 1, 1),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 18,
								Parent = HueOuter,
							})

							local HueCursor = library:create("Frame", {
								BackgroundColor3 = Color3.new(1, 1, 1),
								AnchorPoint = Vector2.new(0, 0.5),
								BorderColor3 = Color3.new(0, 0, 0),
								Size = UDim2.new(1, 0, 0, 1),
								ZIndex = 18,
								Parent = HueInner,
							})

							local sequence = {}
							for hue = 0, 1, 0.1 do
								table.insert(sequence, ColorSequenceKeypoint.new(hue, Color3.fromHSV(hue, 1, 1)))
							end

							library:create("UIGradient", {
								Color = ColorSequence.new(sequence),
								Rotation = 90,
								Parent = HueInner,
							})

							local HexBox = library:create("TextBox", {
								BackgroundColor3 = Color3.fromRGB(25, 25, 25),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								Position = UDim2.fromOffset(4, 183),
								Size = UDim2.new(0.5, -6, 0, 18),
								Font = Enum.Font.Ubuntu,
								PlaceholderText = "Hex",
								Text = "#FFFFFF",
								TextColor3 = Color3.fromRGB(200, 200, 200),
								TextSize = 12,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = 20,
								Parent = PickerInner,
							})

							library:create("UIPadding", {
								PaddingLeft = UDim.new(0, 4),
								Parent = HexBox,
							})

							local RgbBox = library:create("TextBox", {
								BackgroundColor3 = Color3.fromRGB(25, 25, 25),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								Position = UDim2.new(0.5, 2, 0, 183),
								Size = UDim2.new(0.5, -6, 0, 18),
								Font = Enum.Font.Ubuntu,
								PlaceholderText = "RGB",
								Text = "255, 255, 255",
								TextColor3 = Color3.fromRGB(200, 200, 200),
								TextSize = 12,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = 20,
								Parent = PickerInner,
							})

							library:create("UIPadding", {
								PaddingLeft = UDim.new(0, 4),
								Parent = RgbBox,
							})

							local CopyBtn = library:create("TextButton", {
								BackgroundColor3 = Color3.fromRGB(25, 25, 25),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								Position = UDim2.fromOffset(4, 205),
								Size = UDim2.new(1, -8, 0, 16),
								Font = Enum.Font.Ubuntu,
								Text = "Copy Hex",
								TextColor3 = Color3.fromRGB(150, 150, 150),
								TextSize = 12,
								ZIndex = 20,
								Parent = PickerInner,
							})

							local h, s, v = 1, 1, 1

							local function update_display()
								local color = Color3.fromHSV(h, s, v)
								picker.value = color
								DisplayFrame.BackgroundColor3 = color
								SatVibMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
								Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
								HueCursor.Position = UDim2.new(0, 0, h, 0)
								HexBox.Text = "#" .. color:ToHex()
								RgbBox.Text = string.format("%d, %d, %d", 
									math.floor(color.R * 255),
									math.floor(color.G * 255),
									math.floor(color.B * 255)
								)
								picker.callback(color)
							end

							SatVibMap.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 then
									while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
										local minX = SatVibMap.AbsolutePosition.X
										local maxX = minX + SatVibMap.AbsoluteSize.X
										local minY = SatVibMap.AbsolutePosition.Y
										local maxY = minY + SatVibMap.AbsoluteSize.Y
										s = math.clamp((mouse.X - minX) / (maxX - minX), 0, 1)
										v = 1 - math.clamp((mouse.Y - minY) / (maxY - minY), 0, 1)
										update_display()
										rs.RenderStepped:Wait()
									end
								end
							end)

							HueInner.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 then
									while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
										local minY = HueInner.AbsolutePosition.Y
										local maxY = minY + HueInner.AbsoluteSize.Y
										h = math.clamp((mouse.Y - minY) / (maxY - minY), 0, 1)
										update_display()
										rs.RenderStepped:Wait()
									end
								end
							end)

							HexBox.FocusLost:Connect(function()
								local success, result = pcall(Color3.fromHex, HexBox.Text)
								if success then
									h, s, v = Color3.toHSV(result)
									update_display()
								end
							end)

							RgbBox.FocusLost:Connect(function()
								local r, g, b = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
								if r and g and b then
									h, s, v = Color3.toHSV(Color3.fromRGB(r, g, b))
									update_display()
								end
							end)

							CopyBtn.MouseButton1Click:Connect(function()
								if setclipboard then
									setclipboard(picker.value:ToHex())
								end
							end)

							DisplayFrame.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 then
									PickerOuter.Visible = not PickerOuter.Visible
								end
							end)

							uis.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 and PickerOuter.Visible then
									local pos = PickerOuter.AbsolutePosition
									local size = PickerOuter.AbsoluteSize
									if mouse.X < pos.X or mouse.X > pos.X + size.X or
										mouse.Y < pos.Y or mouse.Y > pos.Y + size.Y then
										PickerOuter.Visible = false
									end
								end
							end)

							h, s, v = Color3.toHSV(picker.value)
							update_display()

							return picker
						end

					elseif type == "Dropdown" then
						Border.Size = Border.Size + UDim2.new(0, 0, 0, 35)
						value = {Dropdown = default and default.default or ""}

						local options = data.options or {}
						local multi = data.multi or false

						if multi then
							value.Dropdown = {}
						end

						local DropdownFrame = library:create("Frame", {
							Name = "Dropdown",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 35),
						}, Container)

						local DropdownText = library:create("TextLabel", {
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 9, 0, 3),
							Size = UDim2.new(1, -18, 0, 12),
							Font = Enum.Font.Ubuntu,
							Text = text,
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
						}, DropdownFrame)

						local DropdownButton = library:create("TextButton", {
							BackgroundColor3 = Color3.fromRGB(25, 25, 25),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							Position = UDim2.new(0, 9, 0, 18),
							Size = UDim2.new(0, 252, 0, 16),
							AutoButtonColor = false,
							Font = Enum.Font.Ubuntu,
							Text = multi and "..." or (value.Dropdown or "..."),
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 13,
							ZIndex = 6,
						}, DropdownFrame)

						local Arrow = library:create("TextLabel", {
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -14, 0, 0),
							Size = UDim2.new(0, 14, 1, 0),
							Font = Enum.Font.Ubuntu,
							Text = "v",
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 12,
							ZIndex = 7,
							Parent = DropdownButton,
						})

						local ListOuter = library:create("Frame", {
							BackgroundColor3 = Color3.new(0, 0, 0),
							BorderColor3 = Color3.new(0, 0, 0),
							Position = UDim2.fromOffset(DropdownButton.AbsolutePosition.X, DropdownButton.AbsolutePosition.Y + 18),
							Size = UDim2.fromOffset(252, 0),
							Visible = false,
							ZIndex = 20,
							Parent = ScreenGui,
						})

						DropdownButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
							ListOuter.Position = UDim2.fromOffset(DropdownButton.AbsolutePosition.X, DropdownButton.AbsolutePosition.Y + 18)
						end)

						local ListInner = library:create("Frame", {
							BackgroundColor3 = Color3.fromRGB(15, 15, 15),
							BorderColor3 = Color3.fromRGB(30, 30, 30),
							BorderMode = Enum.BorderMode.Inset,
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 21,
							Parent = ListOuter,
						})

						local Scrolling = library:create("ScrollingFrame", {
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 1, 0),
							CanvasSize = UDim2.new(0, 0, 0, 0),
							ScrollBarThickness = 3,
							ScrollBarImageColor3 = Color3.fromRGB(84, 101, 255),
							ZIndex = 21,
							Parent = ListInner,
						})

						library:create("UIListLayout", {
							Parent = Scrolling,
						})

						local function update_text()
							if multi then
								local selected = {}
								for option, enabled in value.Dropdown do
									if enabled then
										table.insert(selected, option)
									end
								end
								DropdownButton.Text = #selected > 0 and table.concat(selected, ", ") or "..."
							else
								DropdownButton.Text = value.Dropdown or "..."
							end
						end

						local function build_list()
							for _, child in Scrolling:GetChildren() do
								if not child:IsA("UIListLayout") then
									child:Destroy()
								end
							end

							local count = 0
							for _, option in options do
								count += 1
								local OptionBtn = library:create("TextButton", {
									BackgroundColor3 = Color3.fromRGB(15, 15, 15),
									BorderColor3 = Color3.fromRGB(30, 30, 30),
									Size = UDim2.new(1, 0, 0, 18),
									Font = Enum.Font.Ubuntu,
									Text = option,
									TextColor3 = Color3.fromRGB(150, 150, 150),
									TextSize = 13,
									TextXAlignment = Enum.TextXAlignment.Left,
									ZIndex = 22,
									Parent = Scrolling,
								})

								library:create("UIPadding", {
									PaddingLeft = UDim.new(0, 4),
									Parent = OptionBtn,
								})

								local function update_option()
									local selected = multi and value.Dropdown[option] or value.Dropdown == option
									OptionBtn.TextColor3 = selected and Color3.fromRGB(84, 101, 255) or Color3.fromRGB(150, 150, 150)
								end

								OptionBtn.MouseButton1Click:Connect(function()
									if multi then
										value.Dropdown[option] = not value.Dropdown[option]
									else
										value.Dropdown = option
										ListOuter.Visible = false
										for _, btn in Scrolling:GetChildren() do
											if btn:IsA("TextButton") then
												btn.TextColor3 = Color3.fromRGB(150, 150, 150)
											end
										end
									end
									update_option()
									update_text()
									do_callback()
								end)

								OptionBtn.MouseEnter:Connect(function()
									if not (multi and value.Dropdown[option] or value.Dropdown == option) then
										OptionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
									end
								end)

								OptionBtn.MouseLeave:Connect(function()
									update_option()
								end)

								update_option()
							end

							Scrolling.CanvasSize = UDim2.new(0, 0, 0, count * 18)
							local height = math.min(count * 18, 144)
							ListOuter.Size = UDim2.fromOffset(252, height)
						end

						DropdownButton.MouseButton1Click:Connect(function()
							ListOuter.Visible = not ListOuter.Visible
							if ListOuter.Visible then
								build_list()
							end
						end)

						DropdownButton.MouseEnter:Connect(function()
							library:tween(DropdownText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)})
							library:tween(DropdownButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)})
						end)

						DropdownButton.MouseLeave:Connect(function()
							library:tween(DropdownText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)})
							library:tween(DropdownButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)})
						end)

						uis.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 and ListOuter.Visible then
								local pos = ListOuter.AbsolutePosition
								local size = ListOuter.AbsoluteSize
								if mouse.X < pos.X or mouse.X > pos.X + size.X or
									mouse.Y < pos.Y or mouse.Y > pos.Y + size.Y then
									if mouse.X < DropdownButton.AbsolutePosition.X or 
										mouse.X > DropdownButton.AbsolutePosition.X + DropdownButton.AbsoluteSize.X or
										mouse.Y < DropdownButton.AbsolutePosition.Y or
										mouse.Y > DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y then
										ListOuter.Visible = false
									end
								end
							end
						end)

						function element:set_value(new_value)
							value = new_value or value
							menu.values[tab.tab_num][section_name][sector_name][flag] = value
							update_text()
							do_callback()
						end

						function element:refresh(new_options)
							options = new_options
							if not multi then
								value.Dropdown = ""
							else
								value.Dropdown = {}
							end
							update_text()
						end

						update_text()

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
