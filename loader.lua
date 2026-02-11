local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
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

-- ========== INIT KEYAUTH ==========
local initSuccess, initResult = initKeyAuth()
if not initSuccess then
    LocalPlayer:Kick("KeyAuth Error: " .. tostring(initResult))
    return
end

-- ========== CUSTOM KEY UI (MOBILE OPTIMIZED) ==========
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "XDHub_KeyAuth"
KeyGui.Parent = CoreGui
KeyGui.ResetOnSpawn = false

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 400, 0, 350)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
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
KeyBox.Size = UDim2.new(0.85, 0, 0, 50)
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
StatusLabel.Text = "Waiting for input..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 15
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = KeyFrame

local function setStatus(text, isError)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(100, 255, 100)
end

LoginButton.MouseButton1Click:Connect(function()
    local key = KeyBox.Text:gsub("%s", "")
    if key == "" then
        setStatus("❌ Please enter a key", true)
        return
    end
    
    setStatus("🔍 Verifying with KeyAuth...", false)
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

while not Authed do task.wait(0.1) end
task.wait(0.5)

-- ========== ARSENAL SILENT AIM (ACTUALLY WORKS) ==========
_G.SilentAim = {
    Enabled = true,
    TeamCheck = true,
    WallCheck = true,
    HitPart = "Head",
    FOV = 90,
    Prediction = 0.165,
    ShowFOV = false,
    FOVCircle = nil
}

-- Hook namecall for silent aim
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if _G.SilentAim.Enabled and method == "FindPartOnRayWithIgnoreList" and self:IsA("Camera") then
        local hit, pos, normal, material = __namecall(self, ...)
        
        local target = nil
        local closest = _G.SilentAim.FOV
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(_G.SilentAim.HitPart) then
                if not _G.SilentAim.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local part = player.Character[_G.SilentAim.HitPart]
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position + (part.Velocity * _G.SilentAim.Prediction))
                    
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
            return {target.Position + (target.Velocity * _G.SilentAim.Prediction)}, 
                   target.Position + (target.Velocity * _G.SilentAim.Prediction), 
                   Vector3.new(), 
                   Enum.Material.SmoothPlastic
        end
    end
    
    return __namecall(self, ...)
end)

-- FOV Circle
local function updateFOVCircle()
    if _G.SilentAim.FOVCircle then _G.SilentAim.FOVCircle:Destroy() end
    if not _G.SilentAim.ShowFOV then return end
    
    local circle = Drawing.new("Circle")
    circle.Visible = true
    circle.Radius = _G.SilentAim.FOV
    circle.Color = Color3.fromRGB(255, 100, 100)
    circle.Thickness = 1.5
    circle.Filled = false
    circle.NumSides = 60
    circle.Position = UserInputService:GetMouseLocation()
    
    _G.SilentAim.FOVCircle = circle
    
    task.spawn(function()
        while _G.SilentAim.ShowFOV and _G.SilentAim.FOVCircle do
            if _G.SilentAim.FOVCircle then
                _G.SilentAim.FOVCircle.Position = UserInputService:GetMouseLocation()
                _G.SilentAim.FOVCircle.Radius = _G.SilentAim.FOV
            end
            task.wait()
        end
    end)
end

-- ========== GUN MODS (ARSENAL SPECIFIC) ==========
local GunMods = {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InfiniteAmmo = false,
    InstantReload = false,
    AutoFire = false
}

-- Hook weapon functions
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if GunMods.NoRecoil and self:IsA("LocalScript") and key == "Recoil" then
        return 0
    end
    if GunMods.NoSpread and self:IsA("LocalScript") and key == "Spread" then
        return 0
    end
    if GunMods.RapidFire and self:IsA("LocalScript") and key == "FireRate" then
        return 0.01
    end
    if GunMods.InfiniteAmmo and self:IsA("IntValue") and key == "Value" and self.Name == "CurrentAmmo" then
        return 999
    end
    if GunMods.InstantReload and self:IsA("NumberValue") and key == "Value" and self.Name == "ReloadTime" then
        return 0.01
    end
    return oldIndex(self, key)
end)

-- ========== MOBILE/CONTROLLER AIMBOT ==========
local MobileAimbot = {
    Enabled = false,
    TargetPart = "Head",
    FOV = 90,
    Smoothness = 5
}

task.spawn(function()
    while task.wait() do
        if MobileAimbot.Enabled then
            local aiming = false
            
            -- Mobile touch check
            if UserInputService.TouchEnabled and #UserInputService:GetTouchInputs() > 0 then
                aiming = true
            end
            
            -- Controller check
            if UserInputService.GamepadEnabled then
                for _, gamepad in ipairs(UserInputService:GetConnectedGamepads()) do
                    if UserInputService:GetGamepadState(gamepad)[Enum.KeyCode.ButtonR2] then
                        aiming = true
                        break
                    end
                end
            end
            
            if aiming then
                local closest = nil
                local dist = MobileAimbot.FOV
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(MobileAimbot.TargetPart) then
                        local part = p.Character[MobileAimbot.TargetPart]
                        local pos, vis = Camera:WorldToViewportPoint(part.Position)
                        if vis then
                            local mp = UserInputService:GetMouseLocation()
                            local d = (Vector2.new(pos.X, pos.Y) - mp).Magnitude
                            if d < dist then
                                dist = d
                                closest = p
                            end
                        end
                    end
                end
                
                if closest and closest.Character and closest.Character:FindFirstChild(MobileAimbot.TargetPart) then
                    local tpos = closest.Character[MobileAimbot.TargetPart].Position
                    local clook = Camera.CFrame.LookVector
                    local tdir = (tpos - Camera.CFrame.Position).Unit
                    local sm = clook:Lerp(tdir, 1 / MobileAimbot.Smoothness)
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + sm)
                end
            end
        end
    end
end)

-- ========== FLY (FIXED FOR ARSENAL) ==========
local Fly = {Enabled = false, Speed = 50}
local flyConnection = nil

local function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    hum.PlatformStand = true
    
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    bg.CFrame = root.CFrame
    bg.Parent = root
    
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    bv.Parent = root
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not Fly.Enabled or not char or not root then
            return
        end
        
        local move = Vector3.new(0, 0, 0)
        local cf = Camera.CFrame
        
        -- Keyboard
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        
        -- Mobile/Controller
        if UserInputService.TouchEnabled then
            local touch = UserInputService:GetTouchInputs()
            if #touch > 0 then
                local screenPos = touch[#touch].Position
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local diff = screenPos - center
                
                if diff.X > 50 then move = move + cf.RightVector end
                if diff.X < -50 then move = move - cf.RightVector end
                if diff.Y > 50 then move = move - cf.LookVector end
                if diff.Y < -50 then move = move + cf.LookVector end
            end
        end
        
        bv.Velocity = move * Fly.Speed
        bg.CFrame = cf
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
            local bg = root:FindFirstChildOfClass("BodyGyro")
            if bg then bg:Destroy() end
            local bv = root:FindFirstChildOfClass("BodyVelocity")
            if bv then bv:Destroy() end
        end
        if hum then hum.PlatformStand = false end
    end
end

-- ========== HITBOX EXPANDER ==========
local Hitbox = {
    Enabled = false,
    Size = 25,
    Transparency = 7,
    TeamCheck = true
}
local HitboxData = {}

local function expandHitbox(player)
    if not player.Character then return end
    local parts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
    
    for _, partName in ipairs(parts) do
        local part = player.Character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            if not HitboxData[player] then HitboxData[player] = {} end
            if not HitboxData[player][partName] then
                HitboxData[player][partName] = {
                    Size = part.Size,
                    Transparency = part.Transparency,
                    CanCollide = part.CanCollide
                }
            end
            part.Size = Vector3.new(Hitbox.Size, Hitbox.Size, Hitbox.Size)
            part.Transparency = Hitbox.Transparency / 10
            part.CanCollide = false
        end
    end
end

local function resetHitbox(player)
    if HitboxData[player] then
        for partName, data in pairs(HitboxData[player]) do
            local part = player.Character and player.Character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.Size = data.Size
                part.Transparency = data.Transparency
                part.CanCollide = data.CanCollide
            end
        end
        HitboxData[player] = nil
    end
end

-- ========== ESP ==========
local ESP = {Enabled = false}
local ESPObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 100, 100)
    box.Thickness = 2
    box.Filled = false
    
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = false
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    nameLabel.Size = 16
    nameLabel.Center = true
    nameLabel.Outline = true
    
    local healthLabel = Drawing.new("Text")
    healthLabel.Visible = false
    healthLabel.Color = Color3.fromRGB(100, 255, 100)
    healthLabel.Size = 14
    healthLabel.Center = true
    healthLabel.Outline = true
    
    ESPObjects[player] = {box, nameLabel, healthLabel}
end

local function updateESP()
    for player, objs in pairs(ESPObjects) do
        local box, nameLabel, healthLabel = objs[1], objs[2], objs[3]
        
        if ESP.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local root = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local scale = 1 / (pos.Z * 0.1)
                local size = Vector2.new(40 * scale, 60 * scale)
                local position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                
                box.Visible = true
                box.Position = position
                box.Size = size
                
                nameLabel.Visible = true
                nameLabel.Position = Vector2.new(pos.X, position.Y - 20)
                nameLabel.Text = player.Name
                
                healthLabel.Visible = true
                healthLabel.Position = Vector2.new(pos.X, position.Y + size.Y + 5)
                healthLabel.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                
                if player.Team == LocalPlayer.Team then
                    box.Color = Color3.fromRGB(100, 255, 100)
                else
                    box.Color = Color3.fromRGB(255, 100, 100)
                end
            else
                box.Visible = false
                nameLabel.Visible = false
                healthLabel.Visible = false
            end
        else
            box.Visible = false
            nameLabel.Visible = false
            healthLabel.Visible = false
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do createESP(player) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(updateESP)

-- ========== TRIGGERBOT ==========
local Triggerbot = {Enabled = false, Delay = 0.05}

task.spawn(function()
    while task.wait() do
        if Triggerbot.Enabled and Authed then
            local target = Mouse.Target
            if target then
                local char = target.Parent
                if char and char:FindFirstChild("Humanoid") then
                    local player = Players:GetPlayerFromCharacter(char)
                    if player and player ~= LocalPlayer then
                        task.wait(Triggerbot.Delay)
                        mouse1click()
                    end
                end
            end
        end
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
local CombatTab = Window:CreateTab("Combat", 4483362458)
local RageTab = Window:CreateTab("Rage", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)

-- ========== COMBAT TAB ==========
CombatTab:CreateSection("Silent Aim")
CombatTab:CreateToggle({Name = "Enable Silent Aim", CurrentValue = true, Callback = function(v) _G.SilentAim.Enabled = v end})
CombatTab:CreateDropdown({Name = "Hitbox", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) _G.SilentAim.HitPart = v[1] end})
CombatTab:CreateSlider({Name = "FOV", Range = {30, 200}, Increment = 5, CurrentValue = 90, Callback = function(v) _G.SilentAim.FOV = v end})
CombatTab:CreateSlider({Name = "Prediction", Range = {0, 300}, Increment = 5, CurrentValue = 165, Callback = function(v) _G.SilentAim.Prediction = v / 1000 end})
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) _G.SilentAim.TeamCheck = v end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) _G.SilentAim.WallCheck = v end})
CombatTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) _G.SilentAim.ShowFOV = v updateFOVCircle() end})

CombatTab:CreateSection("Mobile/Controller Aimbot")
CombatTab:CreateToggle({Name = "Enable Touch Aim", CurrentValue = false, Callback = function(v) MobileAimbot.Enabled = v end})
CombatTab:CreateSlider({Name = "Smoothness", Range = {1, 15}, Increment = 1, CurrentValue = 5, Callback = function(v) MobileAimbot.Smoothness = v end})

CombatTab:CreateSection("Triggerbot")
CombatTab:CreateToggle({Name = "Enable Triggerbot", CurrentValue = false, Callback = function(v) Triggerbot.Enabled = v end})
CombatTab:CreateSlider({Name = "Delay (MS)", Range = {0, 200}, Increment = 10, CurrentValue = 50, Callback = function(v) Triggerbot.Delay = v / 1000 end})

CombatTab:CreateSection("Hitbox Expander")
CombatTab:CreateToggle({Name = "Enable Hitbox", CurrentValue = false, 
    Callback = function(v) 
        Hitbox.Enabled = v 
        if v then 
            for _, p in pairs(Players:GetPlayers()) do 
                if p ~= LocalPlayer then expandHitbox(p) end 
            end 
        else 
            for p,_ in pairs(HitboxData) do resetHitbox(p) end 
        end 
    end})
CombatTab:CreateSlider({Name = "Hitbox Size", Range = {15, 50}, Increment = 1, CurrentValue = 25, 
    Callback = function(v) 
        Hitbox.Size = v 
        if Hitbox.Enabled then 
            for _, p in pairs(Players:GetPlayers()) do 
                if p ~= LocalPlayer then expandHitbox(p) end 
            end 
        end 
    end})
CombatTab:CreateSlider({Name = "Transparency", Range = {0, 10}, Increment = 1, CurrentValue = 7, 
    Callback = function(v) 
        Hitbox.Transparency = v 
        if Hitbox.Enabled then 
            for _, p in pairs(Players:GetPlayers()) do 
                if p ~= LocalPlayer then expandHitbox(p) end 
            end 
        end 
    end})
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Hitbox.TeamCheck = v end})

-- ========== RAGE TAB ==========
RageTab:CreateSection("Gun Mods")
RageTab:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(v) GunMods.NoRecoil = v end})
RageTab:CreateToggle({Name = "No Spread", CurrentValue = false, Callback = function(v) GunMods.NoSpread = v end})
RageTab:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) GunMods.RapidFire = v end})
RageTab:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(v) GunMods.InfiniteAmmo = v end})
RageTab:CreateToggle({Name = "Instant Reload", CurrentValue = false, Callback = function(v) GunMods.InstantReload = v end})
RageTab:CreateToggle({Name = "Auto Fire", CurrentValue = false, Callback = function(v) GunMods.AutoFire = v end})

RageTab:CreateSection("Rage Features")
RageTab:CreateButton({Name = "Kill All (Rage)", Callback = function()
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
PlayerTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false,
    Callback = function(v) if v then LocalPlayer.Character.Humanoid.JumpPower = 100 end end})

-- ========== VISUALS TAB ==========
VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({Name = "Enable ESP", CurrentValue = false, Callback = function(v) ESP.Enabled = v end})
VisualsTab:CreateToggle({Name = "Box ESP", CurrentValue = true, Callback = function(v) end})
VisualsTab:CreateToggle({Name = "Name ESP", CurrentValue = true, Callback = function(v) end})
VisualsTab:CreateToggle({Name = "Health ESP", CurrentValue = true, Callback = function(v) end})

VisualsTab:CreateSection("World")
VisualsTab:CreateToggle({Name = "Full Bright", CurrentValue = false,
    Callback = function(v) game:GetService("Lighting").Brightness = v and 2 or 1 game:GetService("Lighting").GlobalShadows = not v end})
VisualsTab:CreateToggle({Name = "No Fog", CurrentValue = false,
    Callback = function(v) game:GetService("Lighting").FogEnd = v and 100000 or 100000 end})

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
    Content = string.format("Owner: @mqp6 / Poc\nCreated: 2/10/2026\nDiscord: discord.gg/rmpQfYtnWd\nVersion: 2.0\nMobile: %s\nController: %s",
        UserInputService.TouchEnabled and "Yes" or "No",
        UserInputService.GamepadEnabled and "Yes" or "No")
})

InfoTab:CreateButton({Name = "Copy Discord", Callback = function() if setclipboard then setclipboard("https://discord.gg/rmpQfYtnWd") Rayfield:Notify({Title = "Copied", Content = "Discord link copied", Duration = 2}) end end})
InfoTab:CreateButton({Name = "Rejoin Game", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end})

-- ========== FINAL ==========
Rayfield:Notify({Title = "✅ XD HUB Loaded", Content = "Welcome " .. (UserData and UserData.info and UserData.info.username or LocalPlayer.Name), Duration = 5})
