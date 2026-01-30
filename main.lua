--!strict
--!native
--!optimize 2

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dokidwkdowewewewew/some-ui-library/refs/heads/main/src.lua"))()
if not library then
	error("failed somehow? github down?")
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local mathFloor = math.floor
local mathRad = math.rad
local mathCos = math.cos
local mathSin = math.sin
local mathAtan2 = math.atan2
-- === DEBUG LOGGER ===
local DEBUG_BUFFER = {}
local function DPRINT(...)
	local msg = table.concat(
		table.pack(...),
		" "
	)
	table.insert(DEBUG_BUFFER, msg)
	print(msg)
end

local function DUMP_DEBUG()
	local full = table.concat(DEBUG_BUFFER, "\n")
	print("===== SKIN DEBUG DUMP START =====")
	print(full)
	print("===== SKIN DEBUG DUMP END =====")

	-- executor clipboard support (safe)
	pcall(function()
		setclipboard(full)
	end)

	return full
end

local colorMap = {
	Red = Color3.fromRGB(255, 0, 0),
	DarkRed = Color3.fromRGB(100, 0, 0),
	Green = Color3.fromRGB(0, 255, 0),
	DarkGreen = Color3.fromRGB(0, 80, 0),
	Blue = Color3.fromRGB(0, 0, 255),
	Yellow = Color3.fromRGB(255, 255, 0),
	Orange = Color3.fromRGB(255, 165, 0),
	DarkOrange = Color3.fromRGB(140, 70, 0),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0)
}

local cfg = {
	aimEnabled = false,
	aimSmooth = 0.15,
	aimFOV = 200,
	aimVisCheck = false,
	aimKey = Enum.KeyCode.E,
	silentAimEnabled = false,
	silentWallcheck = false,
	autoShoot = false,
	espEnabled = false,
	espBoxType = "corners",
	espBoxes = true,
	espBoxOutline = true,
	espBoxOutlineColor = colorMap.Black,
	espBoxColor = colorMap.White,
	espBoxFill = true,
	espBoxFillColor = colorMap.White,
	espBoxFillTransparency = 0.9,
	espNames = true,
	espNamesColor = colorMap.White,
	espState = true,
	espStateColor = colorMap.Orange,
	espTracers = false,
	espTracerColor = colorMap.White,
	espHealth = true,
	espHealthOffset = 15,
	espHealthTopColor = colorMap.DarkGreen,
	espHealthMidColor = colorMap.DarkOrange,
	espHealthBottomColor = colorMap.DarkRed,
	espDistance = true,
	espDistanceColor = colorMap.White,
	espSkeleton = false,
	espSkeletonColor = colorMap.White,
	espTeamCheck = true,
	espScale = 1.5,
	espProximityArrows = false,
	espProximityArrowsDistance = 500,
	espProximityArrowsSize = 20,
	boxWallEnabled = false,
	boxWallColor = Color3.fromRGB(0, 255, 127),
	fovEnabled = false,
	fovColor = Color3.fromRGB(255, 255, 255),
	fovSize = 200,
	bhopEnabled = false,
	flashDisable = false,
	smokeRemove = false,
	smokeColor = colorMap.White,
	smokeTransparency = 0.95,
	skinChangerEnabled = false,
	bulletTracerEnabled = false,
	bulletTracerColor = colorMap.White,
	bulletTracerTransparency = 0.5,
	bulletTracerDuration = 1,
	cameraFOV = 70,
	thirdPersonEnabled = false,
	thirdPersonDistance = 10,
	spinbotEnabled = false,
	spinbotSpeed = 10
}

local conns = {}
local bulletTracers = {}
local espObjects = {}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Filled = false
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Transparency = 1

local TRIANGLE_ANGLE = mathRad(45)
local ESP_RED_COLOR = Color3.fromRGB(192, 57, 43)
local ESP_GREEN_COLOR = Color3.fromRGB(39, 174, 96)

local cameraPosition
local cameraCFrame
local viewportSize
local viewportSizeCenter

local function w2s(p)
	local s, v = Camera:WorldToViewportPoint(p)
	return Vector2.new(s.X, s.Y), v, s.Z
end

local function isEnem(p)
	if p == LocalPlayer then return false end
	if not cfg.espTeamCheck then return true end
	local t1 = LocalPlayer:GetAttribute("Team")
	local t2 = p:GetAttribute("Team")
	if not t1 or not t2 or t1 == "Spectators" or t2 == "Spectators" then return false end
	return t1 ~= t2
end

local function isVisible(target)
	if not cfg.aimVisCheck then return true end
	local char = LocalPlayer.Character
	if not char then return false end
	local origin = Camera.CFrame.Position
	local direction = (target.Position - origin)
	local ray = Ray.new(origin, direction)
	local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {char})
	return hit and hit:IsDescendantOf(target.Parent)
end

local function getHealthColor(percent)
	if percent >= 0.5 then
		local s = (percent - 0.5) * 2
		return cfg.espHealthMidColor:Lerp(cfg.espHealthTopColor, s)
	else
		local s = percent * 2
		return cfg.espHealthBottomColor:Lerp(cfg.espHealthMidColor, s)
	end
end

local function getHumanoidState(hum)
	if not hum or hum.Health <= 0 then return "Dead" end
	local s = hum:GetState()
	if s == Enum.HumanoidStateType.Seated then return "Seated"
	elseif s == Enum.HumanoidStateType.Climbing then return "Climbing"
	elseif s == Enum.HumanoidStateType.Swimming then return "Swimming"
	elseif s == Enum.HumanoidStateType.Jumping then return "Jumping"
	elseif s == Enum.HumanoidStateType.Freefall then return "Falling"
	elseif s == Enum.HumanoidStateType.Running or s == Enum.HumanoidStateType.RunningNoPhysics then
		return hum.MoveDirection.Magnitude > 0.1 and "Walking" or "Idle"
	elseif s == Enum.HumanoidStateType.FallingDown then
		return hum.FloorMaterial == Enum.Material.Air and "Falling" or "Idle"
	elseif s == Enum.HumanoidStateType.Ragdoll then return "Ragdoll"
	end
	return hum.MoveDirection.Magnitude > 0.1 and "Walking" or "Idle"
end

local function createBulletTracer(origin, endpoint)
	if not cfg.bulletTracerEnabled then return end
	
	local tracer = Drawing.new("Line")
	tracer.From = w2s(origin)
	tracer.To = w2s(endpoint)
	tracer.Color = cfg.bulletTracerColor
	tracer.Thickness = 2
	tracer.Transparency = 1 - cfg.bulletTracerTransparency
	tracer.Visible = true
	
	table.insert(bulletTracers, {
		line = tracer,
		startTime = tick()
	})
	
	task.delay(cfg.bulletTracerDuration, function()
		if tracer then
			tracer:Remove()
		end
	end)
end

local EntityESP = {}
EntityESP.__index = EntityESP

function EntityESP.new(player)
	local self = setmetatable({}, EntityESP)
	
	self.player = player
	self.visible = false
	
	self.arrow = Drawing.new("Triangle")
	self.arrow.Visible = false
	self.arrow.Thickness = 0
	self.arrow.Filled = true
	self.arrow.Color = Color3.fromRGB(255, 255, 255)
	
	self.name = Drawing.new("Text")
	self.name.Visible = false
	self.name.Center = true
	self.name.Outline = true
	self.name.Size = 13
	self.name.Color = Color3.fromRGB(255, 255, 255)
	
	self.box = Drawing.new("Square")
	self.box.Visible = false
	self.box.Thickness = 1
	self.box.Filled = false
	self.box.Color = Color3.fromRGB(255, 255, 255)
	
	self.healthBg = Drawing.new("Square")
	self.healthBg.Visible = false
	self.healthBg.Filled = false
	self.healthBg.Thickness = 1
	self.healthBg.Color = Color3.fromRGB(255, 255, 255)
	
	self.healthBar = Drawing.new("Square")
	self.healthBar.Visible = false
	self.healthBar.Filled = true
	self.healthBar.Color = Color3.fromRGB(0, 255, 0)
	
	self.tracer = Drawing.new("Line")
	self.tracer.Visible = false
	self.tracer.Color = Color3.fromRGB(255, 255, 255)
	
	return self
end

function EntityESP:GetOffsetTrianglePosition(closestPoint, radiusOfDegree)
	local scalarSize = cfg.espProximityArrowsSize
	local scalarPointAX, scalarPointAY = scalarSize, scalarSize
	local scalarPointBX, scalarPointBY = -scalarSize, -scalarSize
	
	local cosOfRadius, sinOfRadius = mathCos(radiusOfDegree), mathSin(radiusOfDegree)
	local closestPointX, closestPointY = closestPoint.X, closestPoint.Y
	
	local sameBCCos = (closestPointX + scalarPointBX * cosOfRadius)
	local sameBCSin = (closestPointY + scalarPointBX * sinOfRadius)
	
	local sameACSin = (scalarPointAY * sinOfRadius)
	local sameACCos = (scalarPointAY * cosOfRadius)
	
	local pointX1 = (closestPointX + scalarPointAX * cosOfRadius) - sameACSin
	local pointY1 = closestPointY + (scalarPointAX * sinOfRadius) + sameACCos
	
	local pointX2 = sameBCCos - (scalarPointBY * sinOfRadius)
	local pointY2 = sameBCSin + (scalarPointBY * cosOfRadius)
	
	local pointX3 = sameBCCos - sameACSin
	local pointY3 = sameBCSin + sameACCos
	
	return Vector2.new(mathFloor(pointX1), mathFloor(pointY1)), Vector2.new(mathFloor(pointX2), mathFloor(pointY2)), Vector2.new(mathFloor(pointX3), mathFloor(pointY3))
end

function EntityESP:Update()
	local player = self.player
	if not player or not player.Parent then
		return self:Hide()
	end
	
	local char = player.Character
	if not char then
		return self:Hide()
	end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then
		return self:Hide()
	end
	
	local isTeamMate = not isEnem(player)
	if isTeamMate and cfg.espTeamCheck then
		return self:Hide()
	end
	
	local rootPos = hrp.Position
	local distance = (rootPos - cameraPosition).Magnitude
	
	local headPos, onScreen, depth = w2s(rootPos + Vector3.new(0, 3, 0))
	local espColor = isTeamMate and Color3.fromRGB(0, 255, 0) or cfg.espBoxColor
	
	if cfg.espProximityArrows and not onScreen and distance < cfg.espProximityArrowsDistance then
		local vectorUnit
		
		if depth < 0 then
			vectorUnit = -(Vector2.new(headPos.X, headPos.Y) - viewportSizeCenter).Unit
		else
			vectorUnit = (Vector2.new(headPos.X, headPos.Y) - viewportSizeCenter).Unit
		end
		
		local degreeOfCorner = -mathAtan2(vectorUnit.X, vectorUnit.Y) - TRIANGLE_ANGLE
		local closestPoint = viewportSizeCenter + vectorUnit * cfg.espProximityArrowsSize
		
		local pointA, pointB, pointC = self:GetOffsetTrianglePosition(closestPoint, degreeOfCorner)
		
		self.arrow.PointA = pointA
		self.arrow.PointB = pointB
		self.arrow.PointC = pointC
		self.arrow.Color = espColor
		self.arrow.Visible = true
	else
		self.arrow.Visible = false
	end
	
	if not onScreen then
		return self:Hide(true)
	end
	
	self.visible = true
	
	if cfg.espNames then
		local text = player.Name
		if cfg.espDistance then
			text = text .. " [" .. mathFloor(distance) .. "m]"
		end
		if cfg.espState then
			text = text .. "\n" .. getHumanoidState(hum)
		end
		
		self.name.Text = text
		self.name.Position = Vector2.new(headPos.X, headPos.Y)
		self.name.Color = cfg.espNamesColor
		self.name.Visible = true
	else
		self.name.Visible = false
	end
	
	if cfg.espBoxes then
		local footPos = w2s(rootPos - Vector3.new(0, 3, 0))
		
		local height = (footPos.Y - headPos.Y) * cfg.espScale
		local width = height / 2
		
		local x = headPos.X - width / 2
		local y = headPos.Y
		
		self.box.Size = Vector2.new(width, height)
		self.box.Position = Vector2.new(x, y)
		self.box.Color = espColor
		self.box.Visible = true
		
		if cfg.espHealth then
			local barWidth = 4
			local barX = x - 6
			
			self.healthBg.Size = Vector2.new(barWidth, height)
			self.healthBg.Position = Vector2.new(barX, y)
			self.healthBg.Color = Color3.fromRGB(0, 0, 0)
			self.healthBg.Visible = true
			
			local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			local barHeight = height * healthPercent
			
			self.healthBar.Size = Vector2.new(barWidth, barHeight)
			self.healthBar.Position = Vector2.new(barX, y + (height - barHeight))
			self.healthBar.Color = getHealthColor(healthPercent)
			self.healthBar.Visible = true
		else
			self.healthBg.Visible = false
			self.healthBar.Visible = false
		end
	else
		self.box.Visible = false
		self.healthBg.Visible = false
		self.healthBar.Visible = false
	end
	
	if cfg.espTracers then
		self.tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
		self.tracer.To = Vector2.new(headPos.X, headPos.Y)
		self.tracer.Color = cfg.espTracerColor
		self.tracer.Visible = true
	else
		self.tracer.Visible = false
	end
end

function EntityESP:Hide(bypassArrow)
	if not bypassArrow then
		self.arrow.Visible = false
	end
	
	if not self.visible then return end
	self.visible = false
	
	self.name.Visible = false
	self.box.Visible = false
	self.tracer.Visible = false
	self.healthBg.Visible = false
	self.healthBar.Visible = false
end

function EntityESP:Destroy()
	self.arrow:Remove()
	self.name:Remove()
	self.box:Remove()
	self.healthBg:Remove()
	self.healthBar:Remove()
	self.tracer:Remove()
end

local function createESP(player)
	if player == LocalPlayer then return end
	if espObjects[player] then return end
	
	espObjects[player] = EntityESP.new(player)
end

local function removeESP(player)
	local esp = espObjects[player]
	if esp then
		esp:Destroy()
		espObjects[player] = nil
	end
end

for _, player in Players:GetPlayers() do
	createESP(player)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

local function getClosestPlayerSilent()
	local target, closestDist = nil, math.huge
	for _, p in Players:GetPlayers() do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
			if p.Team ~= LocalPlayer.Team then
				if not cfg.silentWallcheck or isVisible(p.Character.Head) then
					local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
					if onScreen then
						local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
						if dist < closestDist then
							closestDist = dist
							target = p
						end
					end
				end
			end
		end
	end
	return target
end

local function getTarget()
	local closest = nil
	local minDist = cfg.aimFOV

	for _, p in Players:GetPlayers() do
		if isEnem(p) and p.Character then
			local head = p.Character:FindFirstChild("Head")
			if head and isVisible(head) then
				local screenPos, onScreen = w2s(head.Position)
				if onScreen then
					local mouse = UserInputService:GetMouseLocation()
					local dist = (screenPos - mouse).Magnitude
					if dist < minDist then
						minDist = dist
						closest = p
					end
				end
			end
		end
	end

	return closest
end

local function setupBhop()
	if conns.bhop then
		conns.bhop:Disconnect()
		conns.bhop = nil
	end
	if cfg.bhopEnabled then
		conns.bhop = RunService.Heartbeat:Connect(function()
			local c = LocalPlayer.Character
			if c then
				local h = c:FindFirstChild("Humanoid")
				if h and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					if h.FloorMaterial ~= Enum.Material.Air then
						h.Jump = true
					end
				end
			end
		end)
	end
end

local function setupFlash()
	if conns.flash then
		conns.flash:Disconnect()
		conns.flash = nil
	end
	if cfg.flashDisable then
		conns.flash = RunService.Heartbeat:Connect(function()
			local g = LocalPlayer.PlayerGui:FindFirstChild("FlashbangEffect")
			if g then
				g.Enabled = false
			end
			local e = Lighting:FindFirstChild("FlashbangColorCorrection")
			if e then
				e.Enabled = false
			end
		end)
	end
end

local function setupSmoke()
	if conns.smoke then
		conns.smoke:Disconnect()
		conns.smoke = nil
	end
	if cfg.smokeRemove then
		conns.smoke = RunService.Heartbeat:Connect(function()
			if Workspace:FindFirstChild("Debris") then
				for _, f in Workspace.Debris:GetChildren() do
					if f.Name:match("Voxel") then
						for _, pt in f:GetChildren() do
							if pt:IsA("BasePart") then
								pt.Transparency = cfg.smokeTransparency
								pt.Color = cfg.smokeColor
							end
						end
					end
				end
			end
		end)
	end
end

local function setupThirdPerson()
	if conns.thirdPerson then
		conns.thirdPerson:Disconnect()
		conns.thirdPerson = nil
	end
	if cfg.thirdPersonEnabled then
		Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		conns.thirdPerson = RunService.RenderStepped:Connect(function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
				local hum = char.Humanoid
				local hrp = char.HumanoidRootPart
				
				if hum.Health > 0 then
					local offset = hrp.CFrame.LookVector * -cfg.thirdPersonDistance
					offset = offset + Vector3.new(0, 2, 0)
					Camera.CFrame = CFrame.new(hrp.Position + offset, hrp.Position)
				end
			end
		end)
	else
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character.Humanoid
		end
	end
end

local spinbotAngle = 0
local realAngle = 0
local fakeAngle = 0

local function setupSpinbot()
	if conns.spinbot then
		conns.spinbot:Disconnect()
		conns.spinbot = nil
	end
	
	if cfg.spinbotEnabled then
		conns.spinbot = RunService.Heartbeat:Connect(function(dt)
			local char = LocalPlayer.Character
			if not char then return end
			
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			
			if not hrp or not humanoid then return end

			humanoid.AutoRotate = false
			
			realAngle = realAngle + (cfg.spinbotSpeed * dt * 60)
			realAngle = realAngle % 360

			fakeAngle = realAngle

			local rotation = CFrame.Angles(0, math.rad(fakeAngle), 0)
			hrp.CFrame = CFrame.new(hrp.Position) * rotation
		end)
	end
end

local function setupFOV()
	Camera.FieldOfView = cfg.cameraFOV
end

local lastShotTime = 0
local shotCooldown = 0.05

local function detectShot()
	if not cfg.bulletTracerEnabled then return end
	
	local currentTime = tick()
	if currentTime - lastShotTime < shotCooldown then return end
	
	local char = LocalPlayer.Character
	if not char then return end
	
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return end
	
	lastShotTime = currentTime
	
	local origin = Camera.CFrame.Position
	local direction = Camera.CFrame.LookVector * 1000
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {char}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = Workspace:Raycast(origin, direction, raycastParams)
	local endpoint = result and result.Position or (origin + direction)
	
	createBulletTracer(origin, endpoint)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		detectShot()
	end
end)

local Debris = Workspace:WaitForChild("Debris")
if Debris then
	Debris.ChildAdded:Connect(function(child)
		if not cfg.bulletTracerEnabled then return end
		
		if child.Name:match("Bullet") or child.Name:match("Tracer") or child:IsA("Folder") then
			task.delay(0.01, function()
				for _, obj in child:GetChildren() do
					if obj:IsA("BasePart") and obj.Name:match("Bullet") then
						local origin = Camera.CFrame.Position
						local endPos = obj.Position
						createBulletTracer(origin, endPos)
						break
					end
				end
			end)
		end
	end)
end

local weaponSkins = {}
local selectedWeapon = "None"
local selectedSkin = "None"
local selectedCondition = "Factory New"

local conditions = {"Factory New", "Minimal Wear", "Field-Tested", "Well-Worn", "Battle-Scarred"}

local function loadWeaponSkins()
	weaponSkins = {}
	
	pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local skinsFolder = ReplicatedStorage:FindFirstChild("Assets")
		if skinsFolder then skinsFolder = skinsFolder:FindFirstChild("Skins") end
		
		if not skinsFolder then 
			warn("[SKIN] no skins folder found")
			return 
		end
		
		warn("[SKIN] loading from:", skinsFolder:GetFullName())
		
		for _, weaponFolder in skinsFolder:GetChildren() do
			if weaponFolder:IsA("Folder") then
				local skins = {}
				
				for _, skinFolder in weaponFolder:GetChildren() do
					if skinFolder:IsA("Folder") then
						table.insert(skins, skinFolder.Name)
					end
				end
				
				if #skins > 0 then
					table.sort(skins)
					weaponSkins[weaponFolder.Name] = skins
					warn("[SKIN] weapon:", weaponFolder.Name)
					for _, skin in skins do
						warn("[SKIN]   - skin:", skin)
					end
				end
			end
		end
		
		warn("[SKIN] total weapons loaded:", #weaponSkins)
	end)
end

local function applySkin(weaponName, skinName, condition)
	if not cfg.skinChangerEnabled then 
		warn("[SKIN] skinchanger disabled")
		return 
	end
	if skinName == "None" or weaponName == "None" then 
		warn("[SKIN] weapon or skin is None")
		return 
	end
	
	warn("[SKIN] === trying to apply ===")
	warn("[SKIN] weapon:", weaponName)
	warn("[SKIN] skin:", skinName)
	warn("[SKIN] condition:", condition)
	
	pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		
		local skinPath = ReplicatedStorage:FindFirstChild("Assets")
		if skinPath then skinPath = skinPath:FindFirstChild("Skins") end
		if skinPath then skinPath = skinPath:FindFirstChild(weaponName) end
		if skinPath then 
			warn("[SKIN] found weapon folder:", skinPath:GetFullName())
			skinPath = skinPath:FindFirstChild(skinName) 
		end
		if skinPath then 
			warn("[SKIN] found skin folder:", skinPath:GetFullName())
			skinPath = skinPath:FindFirstChild("Camera") 
		end
		if skinPath then 
			warn("[SKIN] found camera folder:", skinPath:GetFullName())
			skinPath = skinPath:FindFirstChild(condition) 
		end
		
		if not skinPath then 
			warn("[SKIN] skin path not found")
			return 
		end
		
		warn("[SKIN] full skin path:", skinPath:GetFullName())
		warn("[SKIN] children in skin path:")
		for _, child in skinPath:GetChildren() do
			warn("[SKIN]   -", child.Name, child.ClassName)
		end
		
		local weaponModel = Camera:FindFirstChild(weaponName)
		if not weaponModel then 
			warn("[SKIN] weapon model not found in camera")
			warn("[SKIN] camera children:")
			for _, child in Camera:GetChildren() do
				warn("[SKIN] -", child.Name)
			end
			return 
		end
		
		warn("[SKIN] found weapon model:", weaponModel:GetFullName())
		warn("[SKIN] children in weapon model:")
		for _, child in weaponModel:GetChildren() do
			warn("[SKIN]   -", child.Name, child.ClassName)
			if child.Name == "Weapon Model" then
				warn("[SKIN]   ^^^ THIS IS THE WEAPON MODEL, class:", child.ClassName)
			end
		end
		
		local weaponParts = weaponModel:FindFirstChild("Weapon Model")
		if not weaponParts then
			warn("[SKIN] trying descendants search for Weapon Model")
			weaponParts = weaponModel:FindFirstChild("Weapon Model", true)
		end
		
		if not weaponParts then
			warn("[SKIN] weapon model folder not found, trying to apply directly to weapon model descendants")
			
			local applied = 0
			for _, surfaceAppearance in skinPath:GetChildren() do
				if surfaceAppearance:IsA("SurfaceAppearance") then
					local partName = surfaceAppearance.Name
					local targetPart = weaponModel:FindFirstChild(partName, true)
					
					if targetPart and targetPart:IsA("BasePart") then
						for _, child in targetPart:GetChildren() do
							if child:IsA("SurfaceAppearance") then
								child:Destroy()
							end
						end
						
						local clone = surfaceAppearance:Clone()
						clone.Parent = targetPart
						applied = applied + 1
						warn("[SKIN] applied", partName, "to", targetPart:GetFullName())
					else
						warn("[SKIN] part not found:", partName)
					end
				end
			end
			
			warn("[SKIN] applied", applied, "textures")
			return
		end
		
		warn("[SKIN] found weapon parts folder:", weaponParts:GetFullName())
		warn("[SKIN] applying textures...")
		
		local applied = 0
		for _, surfaceAppearance in skinPath:GetChildren() do
			if surfaceAppearance:IsA("SurfaceAppearance") then
				local partName = surfaceAppearance.Name
				local targetPart = weaponParts:FindFirstChild(partName, true)
				
				if targetPart and targetPart:IsA("BasePart") then
					for _, child in targetPart:GetChildren() do
						if child:IsA("SurfaceAppearance") then
							child:Destroy()
						end
					end
					
					local clone = surfaceAppearance:Clone()
					clone.Parent = targetPart
					applied = applied + 1
					warn("[SKIN] applied", partName, "to", targetPart:GetFullName())
				else
					warn("[SKIN] part not found:", partName)
				end
			end
		end
		
		warn("[SKIN] applied", applied, "textures")
	end)
end

local function monitorWeaponChanges()
	if conns.skinMonitor then
		conns.skinMonitor:Disconnect()
	end
	
	if not cfg.skinChangerEnabled then return end
	
	warn("[SKIN] starting weapon monitor")
	
	conns.skinMonitor = Camera.ChildAdded:Connect(function(child)
		if not cfg.skinChangerEnabled then return end
		
		warn("[SKIN] camera child added:", child.Name)
		
		task.wait(0.1)
		
		if selectedWeapon ~= "None" and selectedSkin ~= "None" then
			warn("[SKIN] checking if", child.Name, "matches", selectedWeapon)
			if child.Name == selectedWeapon then
				warn("[SKIN] match found, applying skin")
				applySkin(selectedWeapon, selectedSkin, selectedCondition)
			end
		end
	end)
end

local function initializeSkinChanger()
	warn("[SKIN] initializing skinchanger")
	loadWeaponSkins()
	monitorWeaponChanges()
	warn("[SKIN] initialization complete")
end

initializeSkinChanger()

RunService.RenderStepped:Connect(function()
	cameraPosition = Camera.CFrame.Position
	cameraCFrame = Camera.CFrame
	viewportSize = Camera.ViewportSize
	viewportSizeCenter = viewportSize / 2
	
	for i = #bulletTracers, 1, -1 do
		local tracerData = bulletTracers[i]
		if tick() - tracerData.startTime >= cfg.bulletTracerDuration then
			if tracerData.line then
				tracerData.line:Remove()
			end
			table.remove(bulletTracers, i)
		end
	end
	
	if cfg.espEnabled then
		for _, esp in espObjects do
			esp:Update()
		end
	else
		for _, esp in espObjects do
			esp:Hide()
		end
	end

	local shouldAim = false
	if cfg.aimEnabled then
		shouldAim = UserInputService:IsKeyDown(cfg.aimKey)
	end

	if shouldAim then
		local target = getTarget()
		if target and target.Character then
			local head = target.Character:FindFirstChild("Head")
			if head then
				local targetPos = head.Position
				local currentCF = Camera.CFrame
				local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
				
				Camera.CFrame = currentCF:Lerp(targetCF, cfg.aimSmooth)
			end
		end
	end
	
	if cfg.silentAimEnabled and cfg.autoShoot then
		local target = getClosestPlayerSilent()
		if target and mouse1click then
			mouse1click()
		end
	end

	if cfg.fovEnabled and cfg.aimEnabled then
		local mouse = UserInputService:GetMouseLocation()
		fovCircle.Position = mouse
		fovCircle.Radius = cfg.fovSize
		fovCircle.Color = cfg.fovColor
		fovCircle.Visible = true
	else
		fovCircle.Visible = false
	end
end)

local menu = library.new("lemon.lua v2.3", "lemon/configs/")

local combat_tab = menu.new_tab("rbxassetid://672174396")
local visuals_tab = menu.new_tab("rbxassetid://672174396")
local misc_tab = menu.new_tab("rbxassetid://672174396")

local combat_section = combat_tab.new_section("Combat")

local softaim_sector = combat_section.new_sector("Soft Aim (Hold E)", "Left")

softaim_sector.element("Toggle", "Enable Soft Aim", {default = {Toggle = false}}, function(value)
	cfg.aimEnabled = value.Toggle
end)

softaim_sector.element("Slider", "Smoothness", {default = {default = 15, min = 1, max = 100}}, function(value)
	cfg.aimSmooth = value.Slider / 100
end)

softaim_sector.element("Slider", "FOV", {default = {default = 200, min = 50, max = 500}}, function(value)
	cfg.aimFOV = value.Slider
	cfg.fovSize = value.Slider
end)

softaim_sector.element("Toggle", "Visible Check", {default = {Toggle = false}}, function(value)
	cfg.aimVisCheck = value.Toggle
end)

local fov_sector = combat_section.new_sector("FOV Circle", "Right")

fov_sector.element("Toggle", "Show FOV Circle", {default = {Toggle = false}}, function(value)
	cfg.fovEnabled = value.Toggle
end)

local visuals_section = visuals_tab.new_section("Visuals")
local esp_sector = visuals_section.new_sector("ESP", "Left")

esp_sector.element("Toggle", "Enable ESP", {default = {Toggle = false}}, function(value)
	cfg.espEnabled = value.Toggle
end)

esp_sector.element("Toggle", "Boxes", {default = {Toggle = true}}, function(value)
	cfg.espBoxes = value.Toggle
end)

esp_sector.element("Toggle", "Names", {default = {Toggle = true}}, function(value)
	cfg.espNames = value.Toggle
end)

esp_sector.element("Toggle", "Distance", {default = {Toggle = true}}, function(value)
	cfg.espDistance = value.Toggle
end)

esp_sector.element("Toggle", "State", {default = {Toggle = true}}, function(value)
	cfg.espState = value.Toggle
end)

esp_sector.element("Toggle", "Tracers", {default = {Toggle = false}}, function(value)
	cfg.espTracers = value.Toggle
end)

esp_sector.element("Toggle", "Health Bars", {default = {Toggle = true}}, function(value)
	cfg.espHealth = value.Toggle
end)

esp_sector.element("Toggle", "Team Check", {default = {Toggle = true}}, function(value)
	cfg.espTeamCheck = value.Toggle
end)

esp_sector.element("Slider", "ESP Scale", {default = {default = 150, min = 100, max = 200}}, function(value)
	cfg.espScale = value.Slider / 100
end)

esp_sector.element("Toggle", "Proximity Arrows", {default = {Toggle = false}}, function(value)
	cfg.espProximityArrows = value.Toggle
end)

esp_sector.element("Slider", "Arrow Distance", {default = {default = 500, min = 100, max = 1000}}, function(value)
	cfg.espProximityArrowsDistance = value.Slider
end)

esp_sector.element("Slider", "Arrow Size", {default = {default = 20, min = 10, max = 50}}, function(value)
	cfg.espProximityArrowsSize = value.Slider
end)

local world_sector = visuals_section.new_sector("World", "Right")

world_sector.element("Toggle", "No Flash", {default = {Toggle = false}}, function(value)
	cfg.flashDisable = value.Toggle
	setupFlash()
end)

world_sector.element("Toggle", "Remove Smoke", {default = {Toggle = false}}, function(value)
	cfg.smokeRemove = value.Toggle
	setupSmoke()
end)

world_sector.element("Slider", "Smoke Transparency", {default = {default = 95, min = 0, max = 100}}, function(value)
	cfg.smokeTransparency = value.Slider / 100
end)

local bullet_sector = visuals_section.new_sector("Bullet Tracer", "Right")

bullet_sector.element("Toggle", "Enable Tracer", {default = {Toggle = false}}, function(value)
	cfg.bulletTracerEnabled = value.Toggle
end)

bullet_sector.element("Slider", "Transparency", {default = {default = 50, min = 0, max = 100}}, function(value)
	cfg.bulletTracerTransparency = value.Slider / 100
end)

bullet_sector.element("Slider", "Duration", {default = {default = 10, min = 1, max = 50}}, function(value)
	cfg.bulletTracerDuration = value.Slider / 10
end)

local colors_section = visuals_tab.new_section("Colors")
local esp_colors = colors_section.new_sector("ESP Colors", "Left")

esp_colors.element("Slider", "Box R", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espBoxColor = Color3.fromRGB(value.Slider, cfg.espBoxColor.G * 255, cfg.espBoxColor.B * 255)
end)

esp_colors.element("Slider", "Box G", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espBoxColor = Color3.fromRGB(cfg.espBoxColor.R * 255, value.Slider, cfg.espBoxColor.B * 255)
end)

esp_colors.element("Slider", "Box B", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espBoxColor = Color3.fromRGB(cfg.espBoxColor.R * 255, cfg.espBoxColor.G * 255, value.Slider)
end)

esp_colors.element("Slider", "Name R", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espNamesColor = Color3.fromRGB(value.Slider, cfg.espNamesColor.G * 255, cfg.espNamesColor.B * 255)
end)

esp_colors.element("Slider", "Name G", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espNamesColor = Color3.fromRGB(cfg.espNamesColor.R * 255, value.Slider, cfg.espNamesColor.B * 255)
end)

esp_colors.element("Slider", "Name B", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espNamesColor = Color3.fromRGB(cfg.espNamesColor.R * 255, cfg.espNamesColor.G * 255, value.Slider)
end)

esp_colors.element("Slider", "Tracer R", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espTracerColor = Color3.fromRGB(value.Slider, cfg.espTracerColor.G * 255, cfg.espTracerColor.B * 255)
end)

esp_colors.element("Slider", "Tracer G", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espTracerColor = Color3.fromRGB(cfg.espTracerColor.R * 255, value.Slider, cfg.espTracerColor.B * 255)
end)

esp_colors.element("Slider", "Tracer B", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.espTracerColor = Color3.fromRGB(cfg.espTracerColor.R * 255, cfg.espTracerColor.G * 255, value.Slider)
end)

local other_colors = colors_section.new_sector("Other Colors", "Right")

other_colors.element("Slider", "FOV R", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.fovColor = Color3.fromRGB(value.Slider, cfg.fovColor.G * 255, cfg.fovColor.B * 255)
end)

other_colors.element("Slider", "FOV G", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.fovColor = Color3.fromRGB(cfg.fovColor.R * 255, value.Slider, cfg.fovColor.B * 255)
end)

other_colors.element("Slider", "FOV B", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.fovColor = Color3.fromRGB(cfg.fovColor.R * 255, cfg.fovColor.G * 255, value.Slider)
end)

other_colors.element("Slider", "Bullet R", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.bulletTracerColor = Color3.fromRGB(value.Slider, cfg.bulletTracerColor.G * 255, cfg.bulletTracerColor.B * 255)
end)

other_colors.element("Slider", "Bullet G", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.bulletTracerColor = Color3.fromRGB(cfg.bulletTracerColor.R * 255, value.Slider, cfg.bulletTracerColor.B * 255)
end)

other_colors.element("Slider", "Bullet B", {default = {default = 255, min = 0, max = 255}}, function(value)
	cfg.bulletTracerColor = Color3.fromRGB(cfg.bulletTracerColor.R * 255, cfg.bulletTracerColor.G * 255, value.Slider)
end)

local misc_section = misc_tab.new_section("Misc")

local movement_sector = misc_section.new_sector("Movement", "Left")

movement_sector.element("Toggle", "Bunny Hop", {default = {Toggle = false}}, function(value)
	cfg.bhopEnabled = value.Toggle
	setupBhop()
end)

movement_sector.element("Toggle", "Third Person", {default = {Toggle = false}}, function(value)
	cfg.thirdPersonEnabled = value.Toggle
	setupThirdPerson()
end)

movement_sector.element("Slider", "Third Person Distance", {default = {default = 10, min = 5, max = 30}}, function(value)
	cfg.thirdPersonDistance = value.Slider
end)

movement_sector.element("Toggle", "Spinbot", {default = {Toggle = false}}, function(value)
	cfg.spinbotEnabled = value.Toggle
	setupSpinbot()
end)

movement_sector.element("Slider", "Spinbot Speed", {default = {default = 10, min = 1, max = 50}}, function(value)
	cfg.spinbotSpeed = value.Slider
end)

local camera_sector = misc_section.new_sector("Camera", "Left")

camera_sector.element("Slider", "Field of View", {default = {default = 70, min = 60, max = 120}}, function(value)
	cfg.cameraFOV = value.Slider
	setupFOV()
end)


local skin_sector = misc_section.new_sector("Skin Changer", "Right")

local skinDropdown = nil
local selectedWeapon = "None"
local selectedSkin = "None"
local selectedCondition = "Factory New"


skin_sector.element("Toggle", "Enable Skin Changer", {
	default = { Toggle = false }
}, function(value)
	cfg.skinChangerEnabled = value.Toggle

	if value.Toggle then
		initializeSkinChanger()
	else
		if conns.skinMonitor then
			conns.skinMonitor:Disconnect()
			conns.skinMonitor = nil
		end
	end
end)

local weaponList = { "None" }
for weaponName in pairs(weaponSkins) do
	table.insert(weaponList, weaponName)
end
table.sort(weaponList)


local function rebuildSkinDropdown(skins)
	if skinDropdown and skinDropdown.Destroy then
		skinDropdown:Destroy()
	end

	print("[SKIN][UI] Rebuilding skin dropdown")

	skinDropdown = skin_sector.element(
		"Dropdown",
		"Skin",
		{ options = skins, default = "None" },
		function(value)
			selectedSkin = value.Dropdown
			print("[SKIN][UI] Skin selected:", selectedSkin)

			if selectedWeapon ~= "None" and selectedSkin ~= "None" then
				applySkin(selectedWeapon, selectedSkin, selectedCondition)
			end
		end
	)
end

rebuildSkinDropdown({ "None" })


skin_sector.element("Dropdown", "Weapon", {
	options = weaponList,
	default = "None"
}, function(value)
	selectedWeapon = value.Dropdown
	selectedSkin = "None"

	print("[SKIN][UI] Weapon selected:", selectedWeapon)

	local skinsForWeapon = { "None" }

	if selectedWeapon ~= "None" then
		local skins = weaponSkins[selectedWeapon]

		if skins then

			for _, skin in ipairs(skins) do
				table.insert(skinsForWeapon, skin)
			end
		else
		end
	end

	table.sort(skinsForWeapon)

	for _, s in ipairs(skinsForWeapon) do
		print("  -", s)
	end

	rebuildSkinDropdown(skinsForWeapon)
end)

skin_sector.element("Dropdown", "Condition", {
	options = conditions,
	default = "Factory New"
}, function(value)
	selectedCondition = value.Dropdown

	if selectedWeapon ~= "None" and selectedSkin ~= "None" then
		applySkin(selectedWeapon, selectedSkin, selectedCondition)
	end
end)


skin_sector.element("Button", "Unload Script", {}, function()
	for _, esp in pairs(espObjects) do
		esp:Destroy()
	end

	for _, t in pairs(bulletTracers) do
		if t.line then
			t.line:Remove()
		end
	end

	for _, c in pairs(conns) do
		if c then
			c:Disconnect()
		end
	end

	fovCircle:Remove()
end)
