-- xdhubz | Arsenal Only
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source'))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Check if we're in Arsenal
local PlaceId = game.PlaceId
local ArsenalIds = {286090429, 142823239, 4123456789, 1304584327, 5602055394}
local IsArsenal = false

for _, id in ipairs(ArsenalIds) do
    if PlaceId == id then
        IsArsenal = true
        break
    end
end

if not IsArsenal then
    Rayfield:Notify({
        Title = "xdhubz",
        Content = "This script is for Arsenal only!",
        Duration = 5
    })
    return
end

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "xdhubz | Arsenal",
    LoadingTitle = "xdhubz",
    LoadingSubtitle = "Arsenal Cheat",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "xdhubz",
        FileName = "arsenal_config"
    },
    KeySystem = false
})

-- Tabs
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Settings
local Settings = {
    SilentAim = {Enabled = false, HitPart = "Head", FOV = 90, Prediction = 0.165, TeamCheck = true, WallCheck = true, ShowFOV = false},
    Aimlock = {Enabled = false, Smoothness = 5, Key = Enum.UserInputType.MouseButton2, Holding = false},
    Triggerbot = {Enabled = false, Delay = 0.05},
    Fly = {Enabled = false, Speed = 50},
    Noclip = {Enabled = false},
    Speed = {Enabled = false, Amount = 32},
    Jump = {Enabled = false, Amount = 75},
    InfiniteJump = {Enabled = false},
    ESP = {Enabled = false, Box = true, Name = true, Health = true, Distance = true},
    NoRecoil = {Enabled = false},
    InfiniteAmmo = {Enabled = false},
    RapidFire = {Enabled = false}
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 100, 100)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Transparency = 0.7

-- ESP
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Thickness = 1.5
    esp.Box.Filled = false
    
    esp.Name = Drawing.new("Text")
    esp.Name.Visible = false
    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    
    esp.Health = Drawing.new("Text")
    esp.Health.Visible = false
    esp.Health.Size = 14
    esp.Health.Center = true
    esp.Health.Outline = true
    esp.Health.Color = Color3.fromRGB(100, 255, 100)
    
    esp.Distance = Drawing.new("Text")
    esp.Distance.Visible = false
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    
    ESPObjects[player] = esp
end

for _, player in pairs(Players:GetPlayers()) do CreateESP(player) end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end)

-- Fly System
local BodyGyro, BodyVelocity, FlyConnection

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    hum.PlatformStand = true
    
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    BodyGyro.CFrame = root.CFrame
    BodyGyro.Parent = root
    
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    BodyVelocity.Parent = root
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Fly.Enabled or not char then return end
        
        local move = Vector3.new(0, 0, 0)
        local cf = Camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        
        BodyVelocity.Velocity = move * Settings.Fly.Speed
        BodyGyro.CFrame = cf
    end)
end

local function StopFly()
    if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
    if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end
    if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity = nil end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

-- Utility
local function GetClosestPlayer()
    local closest, closestDist = nil, Settings.SilentAim.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.SilentAim.HitPart) then
            if not Settings.SilentAim.TeamCheck or player.Team ~= LocalPlayer.Team then
                local part = player.Character[Settings.SilentAim.HitPart]
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position + (part.Velocity * Settings.SilentAim.Prediction))
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    
    return closest
end

-- Input for aimlock
UserInputService.InputBegan:Connect(function(input)
    if Settings.Aimlock.Enabled and input.UserInputType == Settings.Aimlock.Key then
        Settings.Aimlock.Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.Aimlock.Key then
        Settings.Aimlock.Holding = false
    end
end)

-- Main render loop
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    if Settings.SilentAim.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.SilentAim.FOV
    else
        FOVCircle.Visible = false
    end
    
    -- Aimlock
    if Settings.Aimlock.Enabled and Settings.Aimlock.Holding then
        local target = GetClosestPlayer()
        if target then
            local targetPos = target.Position + (target.Velocity * Settings.SilentAim.Prediction)
            local currentLook = Camera.CFrame.LookVector
            local targetDir = (targetPos - Camera.CFrame.Position).Unit
            local smooth = currentLook:Lerp(targetDir, 1 / Settings.Aimlock.Smoothness)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + smooth)
        end
    end
    
    -- ESP
    if Settings.ESP.Enabled then
        for player, esp in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local root = player.Character.HumanoidRootPart
                local hum = player.Character.Humanoid
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                
                if onScreen and hum.Health > 0 then
                    local scale = 1 / (pos.Z * 0.1)
                    local w = math.clamp(35 * scale, 25, 80)
                    local h = math.clamp(60 * scale, 40, 140)
                    local boxPos = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    
                    if Settings.ESP.Box then
                        esp.Box.Visible = true
                        esp.Box.Position = boxPos
                        esp.Box.Size = Vector2.new(w, h)
                        esp.Box.Color = player.Team == LocalPlayer.Team and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
                    else
                        esp.Box.Visible = false
                    end
                    
                    if Settings.ESP.Name then
                        esp.Name.Visible = true
                        esp.Name.Position = Vector2.new(pos.X, boxPos.Y - 20)
                        esp.Name.Text = player.Name
                    else
                        esp.Name.Visible = false
                    end
                    
                    if Settings.ESP.Health then
                        esp.Health.Visible = true
                        esp.Health.Position = Vector2.new(pos.X, boxPos.Y + h + 5)
                        esp.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    else
                        esp.Health.Visible = false
                    end
                    
                    if Settings.ESP.Distance then
                        esp.Distance.Visible = true
                        esp.Distance.Position = Vector2.new(pos.X, boxPos.Y + h + 25)
                        esp.Distance.Text = math.floor(dist) .. " studs"
                    else
                        esp.Distance.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                    esp.Distance.Visible = false
                end
            end
        end
    else
        for player, esp in pairs(ESPObjects) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            esp.Distance.Visible = false
        end
    end
end)

-- Triggerbot
task.spawn(function()
    while task.wait() do
        if Settings.Triggerbot.Enabled then
            local target = Mouse.Target
            if target then
                local char = target.Parent
                if char and char:FindFirstChild("Humanoid") then
                    local player = Players:GetPlayerFromCharacter(char)
                    if player and player ~= LocalPlayer then
                        if not Settings.SilentAim.TeamCheck or player.Team ~= LocalPlayer.Team then
                            task.wait(Settings.Triggerbot.Delay)
                            mouse1click()
                        end
                    end
                end
            end
        end
    end
end)

-- Movement
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        
        if Settings.Noclip.Enabled then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
        
        if Settings.Speed.Enabled then
            hum.WalkSpeed = Settings.Speed.Amount
        end
        
        if Settings.Jump.Enabled then
            hum.JumpPower = Settings.Jump.Amount
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.Fly.Enabled then
        StopFly()
        task.wait(0.1)
        StartFly()
    end
end)

-- Gun mods (Arsenal specific)
local function FindGunScript()
    for _, v in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
        if v:IsA("LocalScript") and v.Name == "GunScript" then
            return v
        end
    end
    return nil
end

-- No Recoil
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if Settings.NoRecoil.Enabled and self:IsA("LocalScript") and tostring(key):find("Recoil") then
        return 0
    end
    if Settings.InfiniteAmmo.Enabled and self:IsA("IntValue") and self.Name == "CurrentAmmo" and key == "Value" then
        return 999
    end
    if Settings.RapidFire.Enabled and self:IsA("NumberValue") and self.Name == "FireRate" and key == "Value" then
        return 0.01
    end
    return oldIndex(self, key)
end)

-- ========== UI ==========

-- Aimbot Tab
AimbotTab:CreateSection("Silent Aim")
AimbotTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(v) Settings.SilentAim.Enabled = v end
})
AimbotTab:CreateDropdown({
    Name = "Hitbox",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(v) Settings.SilentAim.HitPart = v[1] end
})
AimbotTab:CreateSlider({
    Name = "FOV",
    Range = {30, 200},
    Increment = 5,
    CurrentValue = 90,
    Callback = function(v) Settings.SilentAim.FOV = v end
})
AimbotTab:CreateSlider({
    Name = "Prediction",
    Range = {0, 300},
    Increment = 5,
    CurrentValue = 165,
    Callback = function(v) Settings.SilentAim.Prediction = v / 1000 end
})
AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v) Settings.SilentAim.TeamCheck = v end
})
AimbotTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Callback = function(v) Settings.SilentAim.WallCheck = v end
})
AimbotTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = false,
    Callback = function(v) Settings.SilentAim.ShowFOV = v end
})

AimbotTab:CreateSection("Aimlock")
AimbotTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(v) Settings.Aimlock.Enabled = v end
})
AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 15},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) Settings.Aimlock.Smoothness = v end
})

AimbotTab:CreateSection("Triggerbot")
AimbotTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(v) Settings.Triggerbot.Enabled = v end
})
AimbotTab:CreateSlider({
    Name = "Delay (ms)",
    Range = {0, 200},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(v) Settings.Triggerbot.Delay = v / 1000 end
})

-- Player Tab
PlayerTab:CreateSection("Fly")
PlayerTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(v)
        Settings.Fly.Enabled = v
        if v then
            StartFly()
        else
            StopFly()
        end
    end
})
PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {10, 150},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) Settings.Fly.Speed = v end
})

PlayerTab:CreateSection("Movement")
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v) Settings.Noclip.Enabled = v end
})
PlayerTab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Callback = function(v) Settings.Speed.Enabled = v end
})
PlayerTab:CreateSlider({
    Name = "Speed Amount",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 32,
    Callback = function(v) Settings.Speed.Amount = v end
})
PlayerTab:CreateToggle({
    Name = "Jump Power",
    CurrentValue = false,
    Callback = function(v) Settings.Jump.Enabled = v end
})
PlayerTab:CreateSlider({
    Name = "Jump Amount",
    Range = {50, 250},
    Increment = 1,
    CurrentValue = 75,
    Callback = function(v) Settings.Jump.Amount = v end
})
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v) Settings.InfiniteJump.Enabled = v end
})

-- Visuals Tab
VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(v) Settings.ESP.Enabled = v end
})
VisualsTab:CreateToggle({
    Name = "Box",
    CurrentValue = true,
    Callback = function(v) Settings.ESP.Box = v end
})
VisualsTab:CreateToggle({
    Name = "Name",
    CurrentValue = true,
    Callback = function(v) Settings.ESP.Name = v end
})
VisualsTab:CreateToggle({
    Name = "Health",
    CurrentValue = true,
    Callback = function(v) Settings.ESP.Health = v end
})
VisualsTab:CreateToggle({
    Name = "Distance",
    CurrentValue = true,
    Callback = function(v) Settings.ESP.Distance = v end
})

-- Misc Tab
MiscTab:CreateSection("Gun Mods")
MiscTab:CreateToggle({
    Name = "No Recoil",
    CurrentValue = false,
    Callback = function(v) Settings.NoRecoil.Enabled = v end
})
MiscTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Callback = function(v) Settings.InfiniteAmmo.Enabled = v end
})
MiscTab:CreateToggle({
    Name = "Rapid Fire",
    CurrentValue = false,
    Callback = function(v) Settings.RapidFire.Enabled = v end
})

MiscTab:CreateSection("Utility")
MiscTab:CreateButton({
    Name = "Destroy UI",
    Callback = function() Window:Destroy() end
})
MiscTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(PlaceId, LocalPlayer)
    end
})

-- Notification
Rayfield:Notify({
    Title = "xdhubz",
    Content = "Arsenal script loaded!",
    Duration = 3
})

print("[xdhubz] Arsenal script loaded")
