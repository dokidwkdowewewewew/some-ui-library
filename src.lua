-- // Load Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Eazvy/UILibs/refs/heads/main/Librarys/Obelus/Example"))()

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // Variables
local espEnabled = false
local bhopEnabled = false
local highlightEnabled = false
local espObjects = {}
local highlightObjects = {}
local connections = {}

-- // Functions
local function getPlayerTeam(player)
    return player:GetAttribute("Team")
end

local function isEnemy(player)
    if player == LocalPlayer then return false end
    local localTeam = getPlayerTeam(LocalPlayer)
    local playerTeam = getPlayerTeam(player)
    
    if not localTeam or not playerTeam then return false end
    if localTeam == "Spectators" or playerTeam == "Spectators" then return false end
    
    return localTeam ~= playerTeam
end

-- // BHop System
local function setupBHop()
    if connections.bhop then
        connections.bhop:Disconnect()
        connections.bhop = nil
    end
    
    if bhopEnabled then
        connections.bhop = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local hum = char:FindFirstChild("Humanoid")
            if not hum then return end
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                if hum.FloorMaterial ~= Enum.Material.Air then
                    hum.Jump = true
                end
            end
        end)
    end
end

-- // ESP System
local function createESP(player)
    if not player.Character then return end
    if espObjects[player] then return end
    
    local char = player.Character
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    
    -- Create Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.Code
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard
    
    -- Create Distance Label
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Font = Enum.Font.Code
    distLabel.TextSize = 12
    distLabel.Parent = billboard
    
    espObjects[player] = {billboard = billboard, distLabel = distLabel}
    
    -- Update distance
    local updateConnection = RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
        distLabel.Text = math.floor(distance) .. " studs"
    end)
    
    espObjects[player].connection = updateConnection
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].billboard then
            espObjects[player].billboard:Destroy()
        end
        if espObjects[player].connection then
            espObjects[player].connection:Disconnect()
        end
        espObjects[player] = nil
    end
end

local function updateESP()
    -- Clear all ESP
    for player, _ in pairs(espObjects) do
        removeESP(player)
    end
    
    if not espEnabled then return end
    
    -- Create ESP for enemies
    for _, player in pairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character then
            createESP(player)
        end
    end
end

-- // Highlight System
local function createHighlight(player)
    if not player.Character then return end
    if highlightObjects[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255, 85, 85)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    
    highlightObjects[player] = highlight
end

local function removeHighlight(player)
    if highlightObjects[player] then
        highlightObjects[player]:Destroy()
        highlightObjects[player] = nil
    end
end

local function updateHighlights()
    -- Clear all highlights
    for player, _ in pairs(highlightObjects) do
        removeHighlight(player)
    end
    
    if not highlightEnabled then return end
    
    -- Create highlights for enemies
    for _, player in pairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character then
            createHighlight(player)
        end
    end
end

-- // Player Events
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        wait(0.5) -- Wait for character to fully load
        if espEnabled and isEnemy(player) then
            createESP(player)
        end
        if highlightEnabled and isEnemy(player) then
            createHighlight(player)
        end
    end)
end

local function onPlayerRemoving(player)
    removeESP(player)
    removeHighlight(player)
end

-- Setup for existing players
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Setup for new players
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- // Create Window
local window = library:Window({name = "<font color=\"#AA55EB\">Game Menu</font> | " .. os.date("%b %d %Y")})

-- // Create Pages
local mainPage = window:Page({Name = "Main"})
local visualsPage = window:Page({Name = "Visuals"})
local miscPage = window:Page({Name = "Misc"})

-- // Main Tab - Movement Section
local movementSection = mainPage:Section({Name = "Movement", Side = "Right", size = 150})

movementSection:Toggle({
    Name = "Bunny Hop", 
    Default = false, 
    Callback = function(value)
        bhopEnabled = value
        setupBHop()
        if value then
            print("[BHop] Enabled - Hold SPACE to auto-jump")
        else
            print("[BHop] Disabled")
        end
    end
})

movementSection:Label({Name = "Hold SPACE to bhop", Offset = 16})

-- // Visuals Tab - ESP Section
local espSection = visualsPage:Section({Name = "Player ESP", size = 200})

espSection:Toggle({
    Name = "Enable ESP", 
    Default = false, 
    Callback = function(value)
        espEnabled = value
        updateESP()
    end
})

espSection:Toggle({
    Name = "Highlight Players", 
    Default = false, 
    Callback = function(value)
        highlightEnabled = value
        updateHighlights()
    end
})

espSection:Label({Name = "Shows enemy players only", Offset = 16})

local visualSettingsSection = visualsPage:Section({Name = "Visual Settings", Side = "Right", size = 150})

visualSettingsSection:Button({
    Name = "Refresh ESP", 
    Callback = function()
        updateESP()
        updateHighlights()
        print("[ESP] Refreshed")
    end
})

-- // Misc Tab
local infoSection = miscPage:Section({Name = "Information", size = 150})

infoSection:Label({Name = "Press RightShift to toggle UI"})
infoSection:Label({Name = "Game: CS-style Game", Offset = 16})

local utilitySection = miscPage:Section({Name = "Utilities", Side = "Right", size = 150})

utilitySection:Button({
    Name = "Destroy Menu", 
    Callback = function()
        -- Cleanup
        for _, connection in pairs(connections) do
            if connection then connection:Disconnect() end
        end
        for player, _ in pairs(espObjects) do
            removeESP(player)
        end
        for player, _ in pairs(highlightObjects) do
            removeHighlight(player)
        end
        
        -- Destroy GUI
        if game:GetService("CoreGui"):FindFirstChild("obleus") then
            game:GetService("CoreGui"):FindFirstChild("obleus"):Destroy()
        end
        
        print("[Menu] Destroyed")
    end
})

-- // Set Main Page as Active
mainPage:Turn(true)

print("[Menu] Loaded Successfully!")
