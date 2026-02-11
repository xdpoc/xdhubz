local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== KEYAUTH CONFIG ==========
local KeyAuthApp = "XD HUB"
local KeyAuthOwner = "eDjLQhPvrs"
local KeyAuthVersion = "1.0"
local SessionID = ""
local UserData = nil
local Authed = false

-- ========== URL ENCODE ==========
local function enc(s)
    s = tostring(s)
    s = s:gsub(" ", "%%20")
    s = s:gsub("&", "%%26")
    s = s:gsub("%+", "%%2B")
    s = s:gsub("%/", "%%2F")
    return s
end

-- ========== CREATE KEY UI IMMEDIATELY ==========
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "XDHub_KeyAuth"
KeyGui.Parent = CoreGui
KeyGui.ResetOnSpawn = false
KeyGui.DisplayOrder = 999
KeyGui.IgnoreGuiInset = true

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 400, 0, 380)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -190)
KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KeyGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = KeyFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Position = UDim2.new(0, 0, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "XD HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 30
Title.Font = Enum.Font.GothamBold
Title.Parent = KeyFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 40)
Subtitle.Position = UDim2.new(0, 0, 0, 70)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "🔐 Verified Services & Keyauth.cc"
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
Subtitle.TextSize = 16
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 55)
KeyBox.Position = UDim2.new(0.5, -170, 0, 130)
KeyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Enter your license key"
KeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 18
KeyBox.Font = Enum.Font.Gotham
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = KeyFrame

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 8)
KeyBoxCorner.Parent = KeyBox

local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(0.85, 0, 0, 55)
LoginButton.Position = UDim2.new(0.5, -170, 0, 200)
LoginButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
LoginButton.BorderSizePixel = 0
LoginButton.Text = "LOGIN"
LoginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginButton.TextSize = 20
LoginButton.Font = Enum.Font.GothamBold
LoginButton.Parent = KeyFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = LoginButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 270)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "🔄 Initializing KeyAuth..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.TextSize = 15
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = KeyFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Visible = true
CloseButton.Parent = KeyFrame
CloseButton.MouseButton1Click:Connect(function() 
    KeyGui:Destroy()
    LocalPlayer:Kick("Authentication cancelled")
end)

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local HWIDBox = Instance.new("TextLabel")
HWIDBox.Size = UDim2.new(0.85, 0, 0, 30)
HWIDBox.Position = UDim2.new(0.5, -170, 0, 310)
HWIDBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
HWIDBox.BorderSizePixel = 0
HWIDBox.Text = "HWID: " .. game:GetService("RbxAnalyticsService"):GetClientId()
HWIDBox.TextColor3 = Color3.fromRGB(150, 150, 150)
HWIDBox.TextSize = 12
HWIDBox.Font = Enum.Font.Gotham
HWIDBox.Parent = KeyFrame

local HWIDCorner = Instance.new("UICorner")
HWIDCorner.CornerRadius = UDim.new(0, 6)
HWIDCorner.Parent = HWIDBox

local function setStatus(text, isError)
    StatusLabel.Text = text
    if isError then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif text:find("✅") then
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif text:find("🔄") then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- ========== KEYAUTH INIT ==========
local function initKeyAuth()
    local url = "https://keyauth.win/api/1.1/?name=" .. enc(KeyAuthApp) .. "&ownerid=" .. enc(KeyAuthOwner) .. "&type=init&ver=" .. enc(KeyAuthVersion)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if not success then return false, "Connection failed" end
    local success2, data = pcall(function() return HttpService:JSONDecode(result) end)
    if not success2 or not data then return false, "Invalid response" end
    if data.success then
        SessionID = data.sessionid
        return true, data.sessionid
    else
        return false, data.message or "Init failed"
    end
end

-- ========== KEYAUTH LICENSE CHECK ==========
local function checkLicense(key)
    if not key or key == "" then return false, "No key entered" end
    local url = "https://keyauth.win/api/1.1/?name=" .. enc(KeyAuthApp) .. "&ownerid=" .. enc(KeyAuthOwner) .. "&type=license&key=" .. enc(key) .. "&ver=" .. enc(KeyAuthVersion) .. "&sessionid=" .. enc(SessionID)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if not success then return false, "Connection failed" end
    local success2, data = pcall(function() return HttpService:JSONDecode(result) end)
    if not success2 or not data then return false, "Invalid response" end
    if data.success then
        UserData = data
        Authed = true
        return true, data
    else
        return false, data.message or "Invalid key"
    end
end

-- ========== RUN KEYAUTH INIT IN BACKGROUND ==========
task.spawn(function()
    local initSuccess, initResult = initKeyAuth()
    if initSuccess then
        setStatus("✅ Connected - Enter your key", false)
    else
        setStatus("❌ Init failed: " .. tostring(initResult), true)
    end
end)

-- ========== LOGIN BUTTON LOGIC ==========
LoginButton.MouseButton1Click:Connect(function()
    local key = KeyBox.Text:gsub("%s", "")
    if key == "" then
        setStatus("❌ Please enter a key", true)
        return
    end
    
    if SessionID == "" then
        setStatus("❌ Still initializing...", true)
        return
    end
    
    setStatus("🔄 Verifying with KeyAuth...", false)
    LoginButton.Text = "..."
    LoginButton.Active = false
    
    task.spawn(function()
        local success, result = checkLicense(key)
        if success then
            setStatus("✅ Key verified! Loading hub...", false)
            task.wait(0.5)
            KeyGui:Destroy()
            Authed = true
        else
            setStatus("❌ " .. tostring(result), true)
            LoginButton.Text = "LOGIN"
            LoginButton.Active = true
        end
    end)
end)

KeyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        LoginButton.MouseButton1Click:Fire()
    end
end)

-- ========== WAIT FOR AUTH ==========
while not Authed do task.wait(0.1) end
task.wait(0.5)

-- ========== ACTUAL WORKING SILENT AIM (HOOK METHOD) ==========
_G.SilentAim = {
    Enabled = true,
    TeamCheck = true,
    WallCheck = true,
    HitPart = "Head",
    FOV = 90,
    Prediction = 0.165,
    ShowFOV = false,
    FOVCircle = nil,
    Aimlock = false,
    AimlockKey = Enum.UserInputType.MouseButton2
}

-- Arsenal-specific silent aim hook
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if _G.SilentAim.Enabled and method == "FindPartOnRayWithIgnoreList" and self:IsA("Camera") then
        local hit, pos, normal, material = __namecall(self, ...)
        
        if Rayfield and Rayfield.Flags and Rayfield.Flags.UIEnabled == true then
            return __namecall(self, ...)
        end
        
        local target = nil
        local closest = _G.SilentAim.FOV
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(_G.SilentAim.HitPart) then
                if not _G.SilentAim.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local part = player.Character[_G.SilentAim.HitPart]
                    
                    if _G.SilentAim.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                        local hitPart, hitPos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                        if hitPart and not hitPart:IsDescendantOf(player.Character) then
                            goto continue
                        end
                    end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position + (part.Velocity * _G.SilentAim.Prediction))
                    
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closest then
                            closest = dist
                            target = part
                        end
                    end
                    
                    ::continue::
                end
            end
        end
        
        if target then
            local hitPos = target.Position + (target.Velocity * _G.SilentAim.Prediction)
            return {hitPos}, hitPos, Vector3.new(), Enum.Material.SmoothPlastic
        end
    end
    
    return __namecall(self, ...)
end)

-- ========== FOV CIRCLE ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = _G.SilentAim.FOV
FOVCircle.Color = Color3.fromRGB(255, 100, 100)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Transparency = 0.7

RunService.RenderStepped:Connect(function()
    if _G.SilentAim.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = _G.SilentAim.FOV
    else
        FOVCircle.Visible = false
    end
end)

-- ========== GUN MODS ==========
local GunMods = {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InfiniteAmmo = false,
    InstantReload = false,
    AutoFire = false,
    DamageMultiplier = 1
}

local __index
__index = hookmetamethod(game, "__index", function(self, key)
    if GunMods.NoRecoil and self:IsA("LocalScript") and tostring(key):match("Recoil") then
        return 0
    end
    if GunMods.NoSpread and self:IsA("LocalScript") and tostring(key):match("Spread") then
        return 0
    end
    if GunMods.RapidFire and self:IsA("LocalScript") and tostring(key):match("FireRate") then
        return 0.01
    end
    if GunMods.InfiniteAmmo and self:IsA("IntValue") and self.Name == "CurrentAmmo" and key == "Value" then
        return 999
    end
    if GunMods.InstantReload and self:IsA("NumberValue") and self.Name == "ReloadTime" and key == "Value" then
        return 0.01
    end
    if GunMods.DamageMultiplier > 1 and self:IsA("NumberValue") and self.Name == "Damage" and key == "Value" then
        local old = __index(self, key)
        return old * GunMods.DamageMultiplier
    end
    return __index(self, key)
end)

-- ========== FLY ==========
local Fly = {Enabled = false, Speed = 50}
local flyConnection = nil
local flyBodyGyro, flyBodyVelocity = nil, nil

local function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    hum.PlatformStand = true
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    flyBodyVelocity.Parent = root
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not Fly.Enabled or not char or not root then
            return
        end
        
        local move = Vector3.new(0, 0, 0)
        local cf = Camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        
        if UserInputService.TouchEnabled then
            local touches = UserInputService:GetTouchInputs()
            if #touches >= 2 then
                local avgX = (touches[1].Position.X + touches[2].Position.X) / 2
                local avgY = (touches[1].Position.Y + touches[2].Position.Y) / 2
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local diff = Vector2.new(avgX, avgY) - center
                
                if diff.X > 30 then move = move + cf.RightVector end
                if diff.X < -30 then move = move - cf.RightVector end
                if diff.Y > 30 then move = move - cf.LookVector end
                if diff.Y < -30 then move = move + cf.LookVector end
            end
        end
        
        flyBodyVelocity.Velocity = move * Fly.Speed
        flyBodyGyro.CFrame = cf
    end)
end

local function disableFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root then
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        end
        if hum then hum.PlatformStand = false end
    end
end

-- ========== HITBOX EXPANDER (BOXES) ==========
local Hitbox = {
    Enabled = false,
    Size = 2.5,
    Transparency = 0.7,
    TeamCheck = true,
    Color = Color3.fromRGB(255, 0, 0)
}
local HitboxHighlights = {}

local function createHitbox(player)
    if player == LocalPlayer then return end
    if HitboxHighlights[player] then
        pcall(function() HitboxHighlights[player]:Destroy() end)
        HitboxHighlights[player] = nil
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "XDHub_Hitbox"
    highlight.Adornee = player.Character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Hitbox.Color
    highlight.FillTransparency = Hitbox.Transparency
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = CoreGui
    HitboxHighlights[player] = highlight
end

local function removeHitbox(player)
    if HitboxHighlights[player] then
        pcall(function() HitboxHighlights[player]:Destroy() end)
        HitboxHighlights[player] = nil
    end
end

local function updateHitboxes()
    if not Hitbox.Enabled then
        for player, _ in pairs(HitboxHighlights) do
            removeHitbox(player)
        end
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not Hitbox.TeamCheck or player.Team ~= LocalPlayer.Team then
                if not HitboxHighlights[player] then
                    createHitbox(player)
                else
                    local h = HitboxHighlights[player]
                    h.FillColor = Hitbox.Color
                    h.FillTransparency = Hitbox.Transparency
                    h.Adornee = player.Character
                end
            else
                removeHitbox(player)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Hitbox.Enabled and (not Hitbox.TeamCheck or player.Team ~= LocalPlayer.Team) then
            createHitbox(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeHitbox(player)
end)

-- ========== FULL ESP ==========
local ESP = {
    Enabled = false,
    Box = true,
    BoxColor = Color3.fromRGB(255, 100, 100),
    BoxOutline = true,
    Name = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    Health = true,
    HealthColor = Color3.fromRGB(100, 255, 100),
    Distance = true,
    DistanceColor = Color3.fromRGB(200, 200, 200),
    Tracer = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    HeadDot = false,
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    Weapon = true,
    WeaponColor = Color3.fromRGB(255, 255, 0),
    Skeleton = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255)
}
local ESPObjects = {}

local skeletonJoints = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local objects = {}
    
    objects.Box = Drawing.new("Square")
    objects.Box.Visible = false
    objects.Box.Color = ESP.BoxColor
    objects.Box.Thickness = 1.5
    objects.Box.Filled = false
    
    objects.BoxOutline = Drawing.new("Square")
    objects.BoxOutline.Visible = false
    objects.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    objects.BoxOutline.Thickness = 3
    objects.BoxOutline.Filled = false
    
    objects.Name = Drawing.new("Text")
    objects.Name.Visible = false
    objects.Name.Color = ESP.NameColor
    objects.Name.Size = 16
    objects.Name.Center = true
    objects.Name.Outline = true
    
    objects.Health = Drawing.new("Text")
    objects.Health.Visible = false
    objects.Health.Color = ESP.HealthColor
    objects.Health.Size = 14
    objects.Health.Center = true
    objects.Health.Outline = true
    
    objects.Distance = Drawing.new("Text")
    objects.Distance.Visible = false
    objects.Distance.Color = ESP.DistanceColor
    objects.Distance.Size = 12
    objects.Distance.Center = true
    objects.Distance.Outline = true
    
    objects.Tracer = Drawing.new("Line")
    objects.Tracer.Visible = false
    objects.Tracer.Color = ESP.TracerColor
    objects.Tracer.Thickness = 1.5
    
    objects.HeadDot = Drawing.new("Circle")
    objects.HeadDot.Visible = false
    objects.HeadDot.Color = ESP.HeadDotColor
    objects.HeadDot.Radius = 4
    objects.HeadDot.Filled = true
    objects.HeadDot.NumSides = 16
    
    objects.Weapon = Drawing.new("Text")
    objects.Weapon.Visible = false
    objects.Weapon.Color = ESP.WeaponColor
    objects.Weapon.Size = 12
    objects.Weapon.Center = true
    objects.Weapon.Outline = true
    
    objects.Skeleton = {}
    for i = 1, 15 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = ESP.SkeletonColor
        line.Thickness = 1.5
        table.insert(objects.Skeleton, line)
    end
    
    ESPObjects[player] = objects
end

local function updateESP()
    if not ESP.Enabled then
        for player, objs in pairs(ESPObjects) do
            for _, obj in pairs(objs) do
                if type(obj) == "table" and obj.Visible ~= nil then
                    for _, line in pairs(obj) do
                        if line.Visible ~= nil then line.Visible = false end
                    end
                elseif obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
        end
        return
    end
    
    for player, objs in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local root = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid
            local head = player.Character:FindFirstChild("Head")
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            
            if onScreen then
                local scale = 1 / (pos.Z * 0.1)
                local width = math.clamp(35 * scale, 25, 80)
                local height = math.clamp(60 * scale, 40, 140)
                local boxPos = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                
                local boxColor = (player.Team == LocalPlayer.Team) and Color3.fromRGB(100, 255, 100) or ESP.BoxColor
                
                if ESP.Box and ESP.BoxOutline then
                    objs.BoxOutline.Visible = true
                    objs.BoxOutline.Position = boxPos - Vector2.new(1, 1)
                    objs.BoxOutline.Size = Vector2.new(width + 2, height + 2)
                else
                    objs.BoxOutline.Visible = false
                end
                
                if ESP.Box then
                    objs.Box.Visible = true
                    objs.Box.Position = boxPos
                    objs.Box.Size = Vector2.new(width, height)
                    objs.Box.Color = boxColor
                else
                    objs.Box.Visible = false
                end
                
                if ESP.Name then
                    objs.Name.Visible = true
                    objs.Name.Position = Vector2.new(pos.X, boxPos.Y - 20)
                    objs.Name.Text = player.Name
                    objs.Name.Color = ESP.NameColor
                else
                    objs.Name.Visible = false
                end
                
                if ESP.Health and hum then
                    objs.Health.Visible = true
                    objs.Health.Position = Vector2.new(pos.X, boxPos.Y + height + 5)
                    objs.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    objs.Health.Color = ESP.HealthColor
                else
                    objs.Health.Visible = false
                end
                
                if ESP.Distance then
                    objs.Distance.Visible = true
                    objs.Distance.Position = Vector2.new(pos.X, boxPos.Y + height + 25)
                    objs.Distance.Text = math.floor(dist) .. " studs"
                    objs.Distance.Color = ESP.DistanceColor
                else
                    objs.Distance.Visible = false
                end
                
                if ESP.Tracer then
                    objs.Tracer.Visible = true
                    objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    objs.Tracer.To = Vector2.new(pos.X, pos.Y)
                    objs.Tracer.Color = ESP.TracerColor
                else
                    objs.Tracer.Visible = false
                end
                
                if ESP.HeadDot and head then
                    objs.HeadDot.Visible = true
                    objs.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                    objs.HeadDot.Color = ESP.HeadDotColor
                else
                    objs.HeadDot.Visible = false
                end
                
                if ESP.Weapon then
                    objs.Weapon.Visible = true
                    objs.Weapon.Position = Vector2.new(pos.X, boxPos.Y - 40)
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    objs.Weapon.Text = tool and tool.Name or "None"
                    objs.Weapon.Color = ESP.WeaponColor
                else
                    objs.Weapon.Visible = false
                end
                
                if ESP.Skeleton then
                    for i, joints in ipairs(skeletonJoints) do
                        local part1 = player.Character:FindFirstChild(joints[1])
                        local part2 = player.Character:FindFirstChild(joints[2])
                        if part1 and part2 then
                            local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                            local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                            if vis1 and vis2 then
                                objs.Skeleton[i].Visible = true
                                objs.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                objs.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                objs.Skeleton[i].Color = ESP.SkeletonColor
                            else
                                objs.Skeleton[i].Visible = false
                            end
                        else
                            objs.Skeleton[i].Visible = false
                        end
                    end
                else
                    for _, line in pairs(objs.Skeleton) do
                        line.Visible = false
                    end
                end
            else
                objs.Box.Visible = false
                objs.BoxOutline.Visible = false
                objs.Name.Visible = false
                objs.Health.Visible = false
                objs.Distance.Visible = false
                objs.Tracer.Visible = false
                objs.HeadDot.Visible = false
                objs.Weapon.Visible = false
                for _, line in pairs(objs.Skeleton) do
                    line.Visible = false
                end
            end
        else
            objs.Box.Visible = false
            objs.BoxOutline.Visible = false
            objs.Name.Visible = false
            objs.Health.Visible = false
            objs.Distance.Visible = false
            objs.Tracer.Visible = false
            objs.HeadDot.Visible = false
            objs.Weapon.Visible = false
            for _, line in pairs(objs.Skeleton) do
                line.Visible = false
            end
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do createESP(player) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if type(obj) == "table" then
                for _, line in pairs(obj) do
                    pcall(function() line:Remove() end)
                end
            else
                pcall(function() obj:Remove() end)
            end
        end
        ESPObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(updateESP)

-- ========== WORLD VISUALS ==========
local World = {
    FullBright = false,
    NoFog = false,
    NoShadows = false
}

local originalBrightness = Lighting.Brightness
local originalFogEnd = Lighting.FogEnd
local originalGlobalShadows = Lighting.GlobalShadows
local originalAmbient = Lighting.Ambient
local originalColorShift_Bottom = Lighting.ColorShift_Bottom
local originalColorShift_Top = Lighting.ColorShift_Top

local function updateWorld()
    if World.FullBright then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = originalBrightness
        Lighting.GlobalShadows = originalGlobalShadows
        Lighting.Ambient = originalAmbient
        Lighting.ColorShift_Bottom = originalColorShift_Bottom
        Lighting.ColorShift_Top = originalColorShift_Top
    end
    
    if World.NoFog then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = originalFogEnd
    end
    
    if World.NoShadows then
        Lighting.GlobalShadows = false
    elseif not World.FullBright then
        Lighting.GlobalShadows = originalGlobalShadows
    end
end

-- ========== AIMLOCK ==========
local Aimlock = {
    Enabled = false,
    Smoothness = 5,
    TargetPart = "Head"
}

local Holding = false
UserInputService.InputBegan:Connect(function(input)
    if _G.SilentAim.Aimlock then
        if input.UserInputType == _G.SilentAim.AimlockKey or input.KeyCode == Enum.KeyCode[_G.SilentAim.AimlockKey] then
            Holding = true
        end
    end
    if Aimlock.Enabled then
        if input.UserInputType == Enum.UserInputType.Touch then
            Holding = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == _G.SilentAim.AimlockKey or input.KeyCode == Enum.KeyCode[_G.SilentAim.AimlockKey] then
        Holding = false
    end
    if input.UserInputType == Enum.UserInputType.Touch then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Aimlock.Enabled and Holding then
        if Rayfield and Rayfield.Flags and Rayfield.Flags.UIEnabled == true then return end
        
        local target = nil
        local closest = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimlock.TargetPart) then
                if not _G.SilentAim.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local part = player.Character[Aimlock.TargetPart]
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < closest then
                            closest = dist
                            target = part
                        end
                    end
                end
            end
        end
        
        if target then
            local current = Camera.CFrame.LookVector
            local targetDir = (target.Position - Camera.CFrame.Position).Unit
            local smoothDir = current:Lerp(targetDir, 1 / Aimlock.Smoothness)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + smoothDir)
        end
    end
end)

-- ========== TRIGGERBOT ==========
local Triggerbot = {Enabled = false, Delay = 0.05}

task.spawn(function()
    while task.wait() do
        if Triggerbot.Enabled and Authed then
            local uiOpen = false
            if Rayfield and Rayfield.Flags then
                uiOpen = Rayfield.Flags.UIEnabled == true
            end
            
            if not uiOpen then
                local target = Mouse.Target
                if target then
                    local char = target.Parent
                    if char and char:FindFirstChild("Humanoid") then
                        local player = Players:GetPlayerFromCharacter(char)
                        if player and player ~= LocalPlayer then
                            if not _G.SilentAim.TeamCheck or player.Team ~= LocalPlayer.Team then
                                task.wait(Triggerbot.Delay)
                                mouse1click()
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ========== UNLOCK AFTER DEATH ==========
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Fly.Enabled then
        disableFly()
        task.wait(0.1)
        enableFly()
    end
    if Hitbox.Enabled then
        updateHitboxes()
    end
end)

-- ========== LOAD RAYFIELD UI ==========
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "XD HUB | " .. (UserData and UserData.info and UserData.info.username or LocalPlayer.Name),
    LoadingTitle = "XD HUB Arsenal",
    LoadingSubtitle = "by @mqp6 / Poc",
    ConfigurationSaving = {Enabled = true, FolderName = "XDHub", FileName = "Settings"},
    Discord = {Enabled = true, Invite = "rmpQfYtnWd", RememberJoins = true},
    KeySystem = false
})

-- ========== TABS ==========
local SilentAimTab = Window:CreateTab("Silent Aim", 4483362458)
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local RageTab = Window:CreateTab("Rage", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local HitboxTab = Window:CreateTab("Hitbox", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local WorldTab = Window:CreateTab("World", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)

-- ========== SILENT AIM TAB ==========
SilentAimTab:CreateSection("Silent Aim")
SilentAimTab:CreateToggle({Name = "Enable Silent Aim", CurrentValue = true, Callback = function(v) _G.SilentAim.Enabled = v end})
SilentAimTab:CreateDropdown({Name = "Target Part", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) _G.SilentAim.HitPart = v[1] end})
SilentAimTab:CreateSlider({Name = "FOV", Range = {30, 200}, Increment = 5, CurrentValue = 90, Callback = function(v) _G.SilentAim.FOV = v end})
SilentAimTab:CreateSlider({Name = "Prediction", Range = {0, 300}, Increment = 5, CurrentValue = 165, Callback = function(v) _G.SilentAim.Prediction = v / 1000 end})
SilentAimTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) _G.SilentAim.TeamCheck = v end})
SilentAimTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) _G.SilentAim.WallCheck = v end})
SilentAimTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) _G.SilentAim.ShowFOV = v end})

-- ========== AIMBOT TAB ==========
AimbotTab:CreateSection("Aimlock")
AimbotTab:CreateToggle({Name = "Enable Aimlock", CurrentValue = false, Callback = function(v) _G.SilentAim.Aimlock = v Aimlock.Enabled = v end})
AimbotTab:CreateDropdown({Name = "Aimlock Key", Options = {"MouseButton2", "E", "Q", "Shift", "Control", "Alt", "Touch"}, CurrentOption = {"MouseButton2"}, Callback = function(v)
    if v[1] == "Touch" then _G.SilentAim.AimlockKey = Enum.UserInputType.Touch else _G.SilentAim.AimlockKey = Enum.KeyCode[v[1]] end end})
AimbotTab:CreateSlider({Name = "Smoothness", Range = {1, 15}, Increment = 1, CurrentValue = 5, Callback = function(v) Aimlock.Smoothness = v end})
AimbotTab:CreateDropdown({Name = "Target Part", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) Aimlock.TargetPart = v[1] end})

-- ========== RAGE TAB ==========
RageTab:CreateSection("Gun Mods")
RageTab:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(v) GunMods.NoRecoil = v end})
RageTab:CreateToggle({Name = "No Spread", CurrentValue = false, Callback = function(v) GunMods.NoSpread = v end})
RageTab:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) GunMods.RapidFire = v end})
RageTab:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(v) GunMods.InfiniteAmmo = v end})
RageTab:CreateToggle({Name = "Instant Reload", CurrentValue = false, Callback = function(v) GunMods.InstantReload = v end})
RageTab:CreateSlider({Name = "Damage Multiplier", Range = {1, 10}, Increment = 1, CurrentValue = 1, Callback = function(v) GunMods.DamageMultiplier = v end})

RageTab:CreateSection("Triggerbot")
RageTab:CreateToggle({Name = "Enable Triggerbot", CurrentValue = false, Callback = function(v) Triggerbot.Enabled = v end})
RageTab:CreateSlider({Name = "Trigger Delay (MS)", Range = {0, 200}, Increment = 10, CurrentValue = 50, Callback = function(v) Triggerbot.Delay = v / 1000 end})

RageTab:CreateSection("Nuke")
RageTab:CreateButton({Name = "Kill All Players", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.Health = 0
        end
    end
    Rayfield:Notify({Title = "Rage", Content = "Killed all players", Duration = 2})
end})

-- ========== PLAYER TAB ==========
PlayerTab:CreateSection("Movement")
PlayerTab:CreateSlider({Name = "WalkSpeed", Range = {16, 250}, Increment = 1, CurrentValue = 16,
    Callback = function(v) pcall(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end) end})
PlayerTab:CreateSlider({Name = "JumpPower", Range = {50, 250}, Increment = 1, CurrentValue = 50,
    Callback = function(v) pcall(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end) end})
PlayerTab:CreateToggle({Name = "Noclip", CurrentValue = false,
    Callback = function(v) if v then RunService.Stepped:Connect(function() if LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end end})
PlayerTab:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) Fly.Enabled = v if v then enableFly() else disableFly() end end})
PlayerTab:CreateSlider({Name = "Fly Speed", Range = {10, 150}, Increment = 5, CurrentValue = 50, Callback = function(v) Fly.Speed = v end})

-- ========== HITBOX TAB ==========
HitboxTab:CreateSection("Hitbox Expander")
HitboxTab:CreateToggle({Name = "Enable Hitbox Boxes", CurrentValue = false, Callback = function(v) Hitbox.Enabled = v if v then updateHitboxes() else for player,_ in pairs(HitboxHighlights) do removeHitbox(player) end end end})
HitboxTab:CreateSlider({Name = "Box Size", Range = {1, 5}, Increment = 0.1, CurrentValue = 2.5, Callback = function(v) Hitbox.Size = v end})
HitboxTab:CreateSlider({Name = "Transparency", Range = {0, 1}, Increment = 0.1, CurrentValue = 0.7, Callback = function(v) Hitbox.Transparency = v if Hitbox.Enabled then updateHitboxes() end end})
HitboxTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Hitbox.TeamCheck = v if Hitbox.Enabled then updateHitboxes() end end})
HitboxTab:CreateColorPicker({Name = "Box Color", CurrentValue = Color3.fromRGB(255, 0, 0), Callback = function(v) Hitbox.Color = v if Hitbox.Enabled then updateHitboxes() end end})

-- ========== ESP TAB ==========
ESPTab:CreateSection("Master")
ESPTab:CreateToggle({Name = "Enable ESP", CurrentValue = false, Callback = function(v) ESP.Enabled = v end})

ESPTab:CreateSection("Box")
ESPTab:CreateToggle({Name = "Show Box", CurrentValue = true, Callback = function(v) ESP.Box = v end})
ESPTab:CreateToggle({Name = "Box Outline", CurrentValue = true, Callback = function(v) ESP.BoxOutline = v end})
ESPTab:CreateColorPicker({Name = "Box Color", CurrentValue = Color3.fromRGB(255, 100, 100), Callback = function(v) ESP.BoxColor = v end})

ESPTab:CreateSection("Info")
ESPTab:CreateToggle({Name = "Show Name", CurrentValue = true, Callback = function(v) ESP.Name = v end})
ESPTab:CreateColorPicker({Name = "Name Color", CurrentValue = Color3.fromRGB(255, 255, 255), Callback = function(v) ESP.NameColor = v end})
ESPTab:CreateToggle({Name = "Show Health", CurrentValue = true, Callback = function(v) ESP.Health = v end})
ESPTab:CreateColorPicker({Name = "Health Color", CurrentValue = Color3.fromRGB(100, 255, 100), Callback = function(v) ESP.HealthColor = v end})
ESPTab:CreateToggle({Name = "Show Distance", CurrentValue = true, Callback = function(v) ESP.Distance = v end})
ESPTab:CreateColorPicker({Name = "Distance Color", CurrentValue = Color3.fromRGB(200, 200, 200), Callback = function(v) ESP.DistanceColor = v end})
ESPTab:CreateToggle({Name = "Show Weapon", CurrentValue = true, Callback = function(v) ESP.Weapon = v end})
ESPTab:CreateColorPicker({Name = "Weapon Color", CurrentValue = Color3.fromRGB(255, 255, 0), Callback = function(v) ESP.WeaponColor = v end})

ESPTab:CreateSection("Visuals")
ESPTab:CreateToggle({Name = "Show Tracer", CurrentValue = false, Callback = function(v) ESP.Tracer = v end})
ESPTab:CreateColorPicker({Name = "Tracer Color", CurrentValue = Color3.fromRGB(255, 255, 255), Callback = function(v) ESP.TracerColor = v end})
ESPTab:CreateToggle({Name = "Show Head Dot", CurrentValue = false, Callback = function(v) ESP.HeadDot = v end})
ESPTab:CreateColorPicker({Name = "Head Dot Color", CurrentValue = Color3.fromRGB(255, 0, 0), Callback = function(v) ESP.HeadDotColor = v end})
ESPTab:CreateToggle({Name = "Show Skeleton", CurrentValue = false, Callback = function(v) ESP.Skeleton = v end})
ESPTab:CreateColorPicker({Name = "Skeleton Color", CurrentValue = Color3.fromRGB(255, 255, 255), Callback = function(v) ESP.SkeletonColor = v end})

-- ========== WORLD TAB ==========
WorldTab:CreateSection("Lighting")
WorldTab:CreateToggle({Name = "Full Bright", CurrentValue = false, Callback = function(v) World.FullBright = v updateWorld() end})
WorldTab:CreateToggle({Name = "No Fog", CurrentValue = false, Callback = function(v) World.NoFog = v updateWorld() end})
WorldTab:CreateToggle({Name = "No Shadows", CurrentValue = false, Callback = function(v) World.NoShadows = v updateWorld() end})

-- ========== INFO TAB ==========
InfoTab:CreateSection("Account")
InfoTab:CreateParagraph({
    Title = "Your Information",
    Content = string.format("Username: %s\nEmail: %s\nExpires: %s\nPlan: %s",
        (UserData and UserData.info and UserData.info.username) or LocalPlayer.Name,
        (UserData and UserData.info and UserData.info.email) or "N/A",
        (UserData and UserData.info and UserData.info.expires) or "Lifetime",
        (UserData and UserData.info and UserData.info.subscription) or "Premium")
})

InfoTab:CreateSection("XD HUB")
InfoTab:CreateParagraph({
    Title = "About",
    Content = string.format("Owner: @mqp6 / Poc\nCreated: 2/10/2026\nDiscord: discord.gg/rmpQfYtnWd\nVersion: 3.0\nMobile: %s\nController: %s",
        UserInputService.TouchEnabled and "Yes" or "No",
        UserInputService.GamepadEnabled and "Yes" or "No")
})

InfoTab:CreateButton({Name = "Copy Discord", Callback = function() if setclipboard then setclipboard("https://discord.gg/rmpQfYtnWd") Rayfield:Notify({Title = "Copied", Content = "Discord link copied", Duration = 2}) end end})
InfoTab:CreateButton({Name = "Rejoin Game", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end})

-- ========== FINAL ==========
Rayfield:Notify({
    Title = "✅ XD HUB Loaded",
    Content = "Welcome " .. (UserData and UserData.info and UserData.info.username or LocalPlayer.Name),
    Duration = 5
})
