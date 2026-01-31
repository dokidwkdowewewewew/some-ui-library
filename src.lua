--!strict
--!native
--!optimize 2

local TweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local USERNAME = "admin"
local PASSWORD = "password123"

local function tween(instance, info, props)
	TweenService:Create(instance, info, props):Play()
end

local function create(class, props, parent)
	local obj = Instance.new(class)
	for key, value in props do
		obj[key] = value
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

local function makeDraggable(frame)
	local dragging = false
	local dragStart = Vector2.zero
	local startPos = UDim2.new()
	
	local function updatePosition(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	uis.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updatePosition(input)
		end
	end)
end

local function createLoader()
	local gui = create("ScreenGui", {
		Name = "loader",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		IgnoreGuiInset = true,
	})
	
	if syn then
		syn.protect_gui(gui)
	end
	
	gui.Parent = game:GetService("CoreGui")
	
	local main = create("ImageButton", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderColor3 = Color3.fromRGB(78, 93, 234),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 400, 0, 300),
		Image = "http://www.roblox.com/asset/?id=7300333488",
		AutoButtonColor = false,
		Modal = true,
		Active = true,
	}, gui)
	
	makeDraggable(main)
	
	create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 15),
		Size = UDim2.new(0, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.Ubuntu,
		Text = "AUTHENTICATION",
		TextColor3 = Color3.fromRGB(84, 101, 255),
		TextSize = 18,
	}, main)
	
	create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 45),
		Size = UDim2.new(0, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.Ubuntu,
		Text = "Enter credentials",
		TextColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 13,
	}, main)
	
	local usernameFrame = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BorderColor3 = Color3.fromRGB(30, 30, 30),
		Position = UDim2.new(0.5, -140, 0, 90),
		Size = UDim2.new(0, 280, 0, 30),
	}, main)
	
	local usernameBox = create("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -16, 1, 0),
		Font = Enum.Font.Ubuntu,
		PlaceholderText = "Username",
		PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
		Text = "",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	}, usernameFrame)
	
	local passwordFrame = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BorderColor3 = Color3.fromRGB(30, 30, 30),
		Position = UDim2.new(0.5, -140, 0, 135),
		Size = UDim2.new(0, 280, 0, 30),
	}, main)
	
	local passwordBox = create("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -16, 1, 0),
		Font = Enum.Font.Ubuntu,
		PlaceholderText = "Password",
		PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
		Text = "",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	}, passwordFrame)
	
	local loginBtn = create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Position = UDim2.new(0.5, 0, 0, 185),
		Size = UDim2.new(0, 180, 0, 30),
		AutoButtonColor = false,
		Font = Enum.Font.Ubuntu,
		Text = "LOGIN",
		TextColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 14,
	}, main)
	
	local status = create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 230),
		Size = UDim2.new(1, -20, 0, 20),
		Font = Enum.Font.Ubuntu,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 80, 80),
		TextSize = 13,
		Visible = false,
	}, main)
	
	local loading = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, -50, 0, 250),
		Size = UDim2.new(0, 100, 0, 30),
		Visible = false,
	}, main)
	
	local loadText = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.Ubuntu,
		Text = "LOADING",
		TextColor3 = Color3.fromRGB(84, 101, 255),
		TextSize = 13,
	}, loading)
	
	loginBtn.MouseEnter:Connect(function()
		tween(loginBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
	end)
	
	loginBtn.MouseLeave:Connect(function()
		tween(loginBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
	end)
	
	loginBtn.MouseButton1Down:Connect(function()
		loginBtn.BorderColor3 = Color3.fromRGB(84, 101, 255)
		tween(loginBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(0, 0, 0)})
	end)
	
	local attempts = 0
	
	local function authenticate()
		local user = usernameBox.Text
		local pass = passwordBox.Text
		
		status.Visible = false
		
		if user == USERNAME and pass == PASSWORD then
			loginBtn.Visible = false
			usernameFrame.Visible = false
			passwordFrame.Visible = false
			loading.Visible = true
			
			local dots = 0
			local conn = rs.Heartbeat:Connect(function()
				dots = (dots + 1) % 4
				loadText.Text = "LOADING" .. string.rep(".", dots)
			end)
			
			task.delay(1.5, function()
				conn:Disconnect()
				gui:Destroy()
				
				local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dokidwkdowewewewew/some-ui-library/refs/heads/main/src.lua"))()
				if not library then
					warn("library load failed")
					return
				end
				
				local menu = library.new("lemon.lua v2.3", "lemon/configs/")
				local tab = menu.new_tab("rbxassetid://80095920402450")
				local section = tab.new_section("Main")
				local sector = section.new_sector("Features", "Left")
				
				sector.element("Toggle", "Example Toggle", {default = {Toggle = true}}, function(v)
					print("Toggle:", v.Toggle)
				end)
				
				sector.element("Slider", "Example Slider", {default = {default = 50, min = 0, max = 100}}, function(v)
					print("Slider:", v.Slider)
				end)
				
				sector.element("Button", "Example Button", {}, function()
					print("Button clicked")
				end)
			end)
		else
			attempts += 1
			status.Text = "Invalid credentials"
			status.Visible = true
			
			local pos = main.Position
			for i = 1, 5 do
				main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + (i % 2 == 0 and 5 or -5), pos.Y.Scale, pos.Y.Offset)
				task.wait(0.03)
			end
			main.Position = pos
			
			if attempts >= 3 then
				status.Text = "Too many attempts"
				loginBtn.Visible = false
				task.delay(2, function()
					gui:Destroy()
				end)
			end
		end
	end
	
	loginBtn.MouseButton1Click:Connect(authenticate)
	
	usernameBox.FocusLost:Connect(function(enter)
		if enter then
			passwordBox:CaptureFocus()
		end
	end)
	
	passwordBox.FocusLost:Connect(function(enter)
		if enter then
			authenticate()
		end
	end)
end

createLoader()
