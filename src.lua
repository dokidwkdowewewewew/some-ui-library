--!strict
--!native
--!optimize 2
-- Loader Script with Authentication

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Variables
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Authentication credentials (Change these!)
local CORRECT_USERNAME = "admin"
local CORRECT_PASSWORD = "password123"

-- Loader Library
local Loader = {}

function Loader:tween(...)
    TweenService:Create(...):Play()
end

function Loader:create(object, properties, parent)
    local obj = Instance.new(object)
    for i, v in properties do
        obj[i] = v
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

function Loader:set_draggable(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
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
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Create Loader UI
function Loader:create_loader()
    local ScreenGui = self:create("ScreenGui", {
        Name = "LoaderUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true
    })
    
    if syn then
        syn.protect_gui(ScreenGui)
    end
    
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main Loader Frame
    local Main = self:create("ImageButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderColor3 = Color3.fromRGB(78, 93, 234),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 400, 0, 350),
        Image = "http://www.roblox.com/asset/?id=7300333488",
        AutoButtonColor = false,
        Modal = true,
        Active = true,
        Selectable = true
    }, ScreenGui)
    
    self:set_draggable(Main)
    
    -- Title
    local Title = self:create("TextLabel", {
        Name = "Title",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 15),
        Size = UDim2.new(0, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Ubuntu,
        Text = "PRIVATE LOADER",
        TextColor3 = Color3.fromRGB(84, 101, 255),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        RichText = true
    }, Main)
    
    -- Subtitle
    local Subtitle = self:create("TextLabel", {
        Name = "Subtitle",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 45),
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Ubuntu,
        Text = "Enter credentials to access",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    }, Main)
    
    -- Username Field Container
    local UsernameContainer = self:create("Frame", {
        Name = "UsernameContainer",
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderColor3 = Color3.fromRGB(30, 30, 30),
        Position = UDim2.new(0.5, -150, 0, 100),
        Size = UDim2.new(0, 300, 0, 35)
    }, Main)
    
    local UsernameLabel = self:create("TextLabel", {
        Name = "UsernameLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -7),
        Size = UDim2.new(0, 80, 0, 14),
        Font = Enum.Font.Ubuntu,
        Text = "Username:",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, UsernameContainer)
    
    local UsernameBox = self:create("TextBox", {
        Name = "UsernameBox",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 95, 0, 8),
        Size = UDim2.new(0, 195, 0, 19),
        Font = Enum.Font.Ubuntu,
        PlaceholderText = "Enter username",
        PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
        Text = "",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    }, UsernameContainer)
    
    -- Password Field Container
    local PasswordContainer = self:create("Frame", {
        Name = "PasswordContainer",
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderColor3 = Color3.fromRGB(30, 30, 30),
        Position = UDim2.new(0.5, -150, 0, 155),
        Size = UDim2.new(0, 300, 0, 35)
    }, Main)
    
    local PasswordLabel = self:create("TextLabel", {
        Name = "PasswordLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -7),
        Size = UDim2.new(0, 80, 0, 14),
        Font = Enum.Font.Ubuntu,
        Text = "Password:",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, PasswordContainer)
    
    local PasswordBox = self:create("TextBox", {
        Name = "PasswordBox",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 95, 0, 8),
        Size = UDim2.new(0, 195, 0, 19),
        Font = Enum.Font.Ubuntu,
        PlaceholderText = "Enter password",
        PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
        Text = "",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    }, PasswordContainer)
    
    PasswordBox.TextTruncate = Enum.TextTruncate.AtEnd
    PasswordBox.TextTransparency = 0
    
    local ShowPassword = self:create("TextButton", {
        Name = "ShowPassword",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 265, 0.5, -7),
        Size = UDim2.new(0, 25, 0, 14),
        Font = Enum.Font.Ubuntu,
        Text = "👁",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center
    }, PasswordContainer)
    
    ShowPassword.MouseEnter:Connect(function()
        self:tween(ShowPassword, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
    end)
    
    ShowPassword.MouseLeave:Connect(function()
        self:tween(ShowPassword, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(150, 150, 150)
        })
    end)
    
    local passwordVisible = false
    ShowPassword.MouseButton1Down:Connect(function()
        passwordVisible = not passwordVisible
        if passwordVisible then
            PasswordBox.TextTransparency = 0
            ShowPassword.Text = "👁"
        else
            PasswordBox.TextTransparency = 0
            ShowPassword.Text = "👁"
        end
    end)
    
    -- Login Button
    local LoginButton = self:create("TextButton", {
        Name = "LoginButton",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Position = UDim2.new(0.5, 0, 0, 210),
        Size = UDim2.new(0, 200, 0, 35),
        AutoButtonColor = false,
        Font = Enum.Font.Ubuntu,
        Text = "LOGIN",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 16
    }, Main)
    
    -- Status Label
    local StatusLabel = self:create("TextLabel", {
        Name = "StatusLabel",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 260),
        Size = UDim2.new(0, 300, 0, 20),
        Font = Enum.Font.Ubuntu,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 50, 50),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false
    }, Main)
    
    -- Loading Animation
    local LoadingContainer = self:create("Frame", {
        Name = "LoadingContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -100, 0, 290),
        Size = UDim2.new(0, 200, 0, 30),
        Visible = false
    }, Main)
    
    local LoadingText = self:create("TextLabel", {
        Name = "LoadingText",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Ubuntu,
        Text = "LOADING",
        TextColor3 = Color3.fromRGB(84, 101, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center
    }, LoadingContainer)
    
    local LoadingDots = self:create("TextLabel", {
        Name = "LoadingDots",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 55, 0, 0),
        Size = UDim2.new(0, 30, 0, 20),
        Font = Enum.Font.Ubuntu,
        Text = "...",
        TextColor3 = Color3.fromRGB(84, 101, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, LoadingContainer)
    
    -- Button hover effects
    LoginButton.MouseEnter:Connect(function()
        self:tween(LoginButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
    end)
    
    LoginButton.MouseLeave:Connect(function()
        self:tween(LoginButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(150, 150, 150)
        })
    end)
    
    LoginButton.MouseButton1Down:Connect(function()
        LoginButton.BorderColor3 = Color3.fromRGB(84, 101, 255)
        self:tween(LoginButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BorderColor3 = Color3.fromRGB(0, 0, 0)
        })
    end)
    
    -- Login function
    local loginAttempts = 0
    local MAX_ATTEMPTS = 3
    
    local function attemptLogin()
        local username = UsernameBox.Text
        local password = PasswordBox.Text
        
        -- Clear previous status
        StatusLabel.Visible = false
        
        -- Validate credentials
        if username == CORRECT_USERNAME and password == CORRECT_PASSWORD then
            -- Success
            LoginButton.Visible = false
            UsernameContainer.Visible = false
            PasswordContainer.Visible = false
            Subtitle.Visible = false
            LoadingContainer.Visible = true
            
            -- Animate loading dots
            local dotCount = 0
            local connection
            connection = RunService.Heartbeat:Connect(function()
                dotCount = (dotCount + 1) % 4
                local dots = string.rep(".", dotCount)
                LoadingDots.Text = dots
            end)
            
            -- Simulate loading delay
            task.wait(1)
            
            -- Load the actual library
            local success, err = pcall(function()
                -- Load the library from GitHub
                local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dokidwkdowewewewew/some-ui-library/refs/heads/main/src.lua"))()
                
                -- Create example UI (you can customize this)
                local menu = library.new("Private Script Loaded", "Configs")
                local tab = menu.new_tab("http://www.roblox.com/asset/?id=6031302937")
                local section = tab.new_section("Main")
                local sector = section.new_sector("Features", "Left")
                
                sector.element("Toggle", "Example Toggle", {
                    default = {Toggle = true}
                }, function(value)
                    print("Toggle:", value.Toggle)
                end)
                
                sector.element("Slider", "Example Slider", {
                    default = {default = 50, min = 0, max = 100}
                }, function(value)
                    print("Slider:", value.Slider)
                end)
                
                sector.element("Button", "Example Button", {}, function()
                    print("Button clicked!")
                end)
                
                -- Show success message
                LoadingText.Text = "SUCCESS!"
                LoadingDots.Text = ""
                LoadingText.TextColor3 = Color3.fromRGB(50, 255, 50)
                
                task.wait(0.5)
                
                -- Destroy loader
                ScreenGui:Destroy()
            end)
            
            if not success then
                StatusLabel.Text = "Error loading script: " .. err
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                StatusLabel.Visible = true
                LoadingContainer.Visible = false
                LoginButton.Visible = true
                UsernameContainer.Visible = true
                PasswordContainer.Visible = true
                Subtitle.Visible = true
            end
            
            if connection then
                connection:Disconnect()
            end
            
        else
            -- Failed
            loginAttempts += 1
            StatusLabel.Text = "Invalid credentials"
            StatusLabel.Visible = true
            
            -- Shake animation for wrong password
            local startPos = Main.Position
            for i = 1, 5 do
                local offset = i % 2 == 0 and 5 or -5
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + offset, startPos.Y.Scale, startPos.Y.Offset)
                task.wait(0.03)
            end
            Main.Position = startPos
            
            if loginAttempts >= MAX_ATTEMPTS then
                StatusLabel.Text = "Too many attempts. Closing..."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                LoginButton.Visible = false
                
                task.wait(2)
                ScreenGui:Destroy()
            end
        end
    end
    
    -- Connect login button
    LoginButton.MouseButton1Click:Connect(attemptLogin)
    
    -- Enter key to submit
    UsernameBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            PasswordBox:CaptureFocus()
        end
    end)
    
    PasswordBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            attemptLogin()
        end
    end)
    
    return ScreenGui
end

-- Initialize loader
Loader:create_loader()

-- Return loader for external use if needed
return Loader
