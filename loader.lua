-- xdhubz - Universal Script
-- Version: 2.0
-- Games: Arsenal, Rivals, Da Hood

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source'))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local PlaceId = game.PlaceId
local Game = "Universal"

local GameDetection = {
    Arsenal = {286090429, 142823239, 4123456789, 1304584327, 5602055394},
    Rivals = {4483381587, 2713886045, 606849621, 9192908196, 1537690962},
    DaHood = {7213776334, 2788229376, 12132143254, 5421072413}
}

for name, ids in pairs(GameDetection) do
    for _, id in ipairs(ids) do
        if PlaceId == id then Game = name end
    end
end

local Window = Rayfield:CreateWindow({
    Name = "xdhubz | " .. Game,
    LoadingTitle = "xdhubz",
    LoadingSubtitle = "Arsenal • Rivals • Da Hood",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "xdhubz",
        FileName = "config"
    },
    Discord = {
        Enabled = true,
        Invite = "rmpQfYtnWd",
        RememberJoins = true
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local GameTab = Window:CreateTab(Game, 4483362458)

local Settings = {
    SilentAim = {Enabled = false, HitPart = "Head", FOV = 90, Prediction = 0.165, TeamCheck = true, WallCheck = true, ShowFOV = false},
    Aimlock = {Enabled = false, Smoothness = 5, TargetPart = "Head", Key = Enum.UserInputType.MouseButton2, Holding = false},
    Triggerbot = {Enabled = false, Delay = 0.05},
    Hitbox = {Enabled = false, Size = 2.5, Transparency = 0.7, TeamCheck = true, Color = Color3.fromRGB(255,0,0)},
    ESP = {Enabled = false, Box = true, BoxColor = Color3.fromRGB(255,100,100), Name = true, Health = true, Distance = true, Tracer = false, HeadDot = false},
    Fly = {Enabled = false, Speed = 50},
    Noclip = {Enabled = false},
    Speed = {Enabled = false, Amount = 32},
    Jump = {Enabled = false, Amount = 75},
    InfiniteJump = {Enabled = false},
    World = {FullBright = false, NoFog = false, NoShadows = false}
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.SilentAim.FOV
FOVCircle.Color = Color3.fromRGB(255,100,100)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Transparency = 0.7

-- ESP Objects
local ESPObjects = {}

local function CreateESP(p)
    if p == LocalPlayer then return end
    local o = {}
    o.Box = Drawing.new("Square"); o.Box.Visible = false; o.Box.Color = Settings.ESP.BoxColor; o.Box.Thickness = 1.5; o.Box.Filled = false
    o.Name = Drawing.new("Text"); o.Name.Visible = false; o.Name.Color = Color3.fromRGB(255,255,255); o.Name.Size = 16; o.Name.Center = true; o.Name.Outline = true
    o.Health = Drawing.new("Text"); o.Health.Visible = false; o.Health.Color = Color3.fromRGB(100,255,100); o.Health.Size = 14; o.Health.Center = true; o.Health.Outline = true
    o.Distance = Drawing.new("Text"); o.Distance.Visible = false; o.Distance.Color = Color3.fromRGB(200,200,200); o.Distance.Size = 12; o.Distance.Center = true; o.Distance.Outline = true
    o.Tracer = Drawing.new("Line"); o.Tracer.Visible = false; o.Tracer.Color = Color3.fromRGB(255,255,255); o.Tracer.Thickness = 1.5
    o.HeadDot = Drawing.new("Circle"); o.HeadDot.Visible = false; o.HeadDot.Color = Color3.fromRGB(255,0,0); o.HeadDot.Radius = 4; o.HeadDot.Filled = true; o.HeadDot.NumSides = 16
    ESPObjects[p] = o
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p) 
    if ESPObjects[p] then
        for _, obj in pairs(ESPObjects[p]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[p] = nil 
    end 
end)

-- Fly System
local FlyBodyGyro, FlyBodyVelocity, FlyConnection
local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    hum.PlatformStand = true
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e4,9e4,9e4)
    FlyBodyGyro.CFrame = root.CFrame
    FlyBodyGyro.Parent = root
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.new(0,0,0)
    FlyBodyVelocity.MaxForce = Vector3.new(9e4,9e4,9e4)
    FlyBodyVelocity.Parent = root
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Fly.Enabled or not char or not root then return end
        local move = Vector3.new(0,0,0)
        local cf = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        FlyBodyVelocity.Velocity = move * Settings.Fly.Speed
        FlyBodyGyro.CFrame = cf
    end)
end
local function StopFly()
    if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
    local char = LocalPlayer.Character
    if char then
        if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy(); FlyBodyVelocity = nil end
        if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
    end
end

-- Utility
local function GetClosestPlayer()
    local closest, closestDist = nil, Settings.SilentAim.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.SilentAim.HitPart) then
            if not Settings.SilentAim.TeamCheck or p.Team ~= LocalPlayer.Team then
                local part = p.Character[Settings.SilentAim.HitPart]
                local screen, onScreen = Camera:WorldToViewportPoint(part.Position + (part.Velocity * Settings.SilentAim.Prediction))
                if onScreen then
                    local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                    if dist < closestDist then closestDist, closest = dist, part end
                end
            end
        end
    end
    return closest
end

-- Input
UserInputService.InputBegan:Connect(function(i)
    if Settings.Aimlock.Enabled and (i.UserInputType == Settings.Aimlock.Key or i.KeyCode == Enum.KeyCode[tostring(Settings.Aimlock.Key)]) then
        Settings.Aimlock.Holding = true
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Settings.Aimlock.Key or i.KeyCode == Enum.KeyCode[tostring(Settings.Aimlock.Key)] then
        Settings.Aimlock.Holding = false
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- FOV
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
        for p, o in pairs(ESPObjects) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                local root = p.Character.HumanoidRootPart
                local hum = p.Character.Humanoid
                local head = p.Character:FindFirstChild("Head")
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                
                if onScreen and hum.Health > 0 then
                    local scale = 1 / (pos.Z * 0.1)
                    local w = math.clamp(35 * scale, 25, 80)
                    local h = math.clamp(60 * scale, 40, 140)
                    local boxPos = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    local boxColor = p.Team == LocalPlayer.Team and Color3.fromRGB(100,255,100) or Settings.ESP.BoxColor
                    
                    if Settings.ESP.Box then
                        o.Box.Visible = true
                        o.Box.Position = boxPos
                        o.Box.Size = Vector2.new(w, h)
                        o.Box.Color = boxColor
                    else o.Box.Visible = false end
                    
                    if Settings.ESP.Name then
                        o.Name.Visible = true
                        o.Name.Position = Vector2.new(pos.X, boxPos.Y - 20)
                        o.Name.Text = p.Name
                    else o.Name.Visible = false end
                    
                    if Settings.ESP.Health then
                        o.Health.Visible = true
                        o.Health.Position = Vector2.new(pos.X, boxPos.Y + h + 5)
                        o.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    else o.Health.Visible = false end
                    
                    if Settings.ESP.Distance then
                        o.Distance.Visible = true
                        o.Distance.Position = Vector2.new(pos.X, boxPos.Y + h + 25)
                        o.Distance.Text = math.floor(dist) .. " studs"
                    else o.Distance.Visible = false end
                    
                    if Settings.ESP.Tracer then
                        o.Tracer.Visible = true
                        o.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        o.Tracer.To = Vector2.new(pos.X, pos.Y)
                    else o.Tracer.Visible = false end
                    
                    if Settings.ESP.HeadDot and head then
                        o.HeadDot.Visible = true
                        o.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                    else o.HeadDot.Visible = false end
                else
                    o.Box.Visible = false
                    o.Name.Visible = false
                    o.Health.Visible = false
                    o.Distance.Visible = false
                    o.Tracer.Visible = false
                    o.HeadDot.Visible = false
                end
            end
        end
    else
        for p, o in pairs(ESPObjects) do
            o.Box.Visible = false
            o.Name.Visible = false
            o.Health.Visible = false
            o.Distance.Visible = false
            o.Tracer.Visible = false
            o.HeadDot.Visible = false
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
                    local p = Players:GetPlayerFromCharacter(char)
                    if p and p ~= LocalPlayer then
                        if not Settings.SilentAim.TeamCheck or p.Team ~= LocalPlayer.Team then
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
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        if Settings.Speed.Enabled then hum.WalkSpeed = Settings.Speed.Amount end
        if Settings.Jump.Enabled then hum.JumpPower = Settings.Jump.Amount end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Character Spawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.Fly.Enabled then
        StopFly()
        task.wait(0.1)
        StartFly()
    end
end)

-- World
local Lighting = game:GetService("Lighting")
task.spawn(function()
    while task.wait(0.5) do
        if Settings.World.FullBright then
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255,255,255)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0,0,0)
        end
        if Settings.World.NoFog then Lighting.FogEnd = 100000 else Lighting.FogEnd = 1000 end
        if Settings.World.NoShadows then Lighting.GlobalShadows = false end
    end
end)

-- ========== UI ==========

MainTab:CreateParagraph({
    Title = "xdhubz • 2026",
    Content = string.format("Game: %s\nUser: %s\nStatus: Loaded", Game, LocalPlayer.Name)
})

-- Combat Tab
CombatTab:CreateSection("Silent Aim")
CombatTab:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.SilentAim.Enabled = v end})
CombatTab:CreateDropdown({Name = "Hitbox", Options = {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) Settings.SilentAim.HitPart = v[1] end})
CombatTab:CreateSlider({Name = "FOV", Range = {30,200}, Increment = 5, CurrentValue = 90, Callback = function(v) Settings.SilentAim.FOV = v end})
CombatTab:CreateSlider({Name = "Prediction", Range = {0,300}, Increment = 5, CurrentValue = 165, Callback = function(v) Settings.SilentAim.Prediction = v / 1000 end})
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Settings.SilentAim.TeamCheck = v end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) Settings.SilentAim.WallCheck = v end})
CombatTab:CreateToggle({Name = "Show FOV", CurrentValue = false, Callback = function(v) Settings.SilentAim.ShowFOV = v end})

CombatTab:CreateSection("Aimlock")
CombatTab:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Aimlock.Enabled = v end})
CombatTab:CreateSlider({Name = "Smoothness", Range = {1,15}, Increment = 1, CurrentValue = 5, Callback = function(v) Settings.Aimlock.Smoothness = v end})
CombatTab:CreateDropdown({Name = "Target", Options = {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) Settings.Aimlock.TargetPart = v[1] end})

CombatTab:CreateSection("Triggerbot")
CombatTab:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Triggerbot.Enabled = v end})
CombatTab:CreateSlider({Name = "Delay (ms)", Range = {0,200}, Increment = 10, CurrentValue = 50, Callback = function(v) Settings.Triggerbot.Delay = v / 1000 end})

-- Player Tab
PlayerTab:CreateSection("Fly")
PlayerTab:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Fly.Enabled = v; if v then StartFly() else StopFly() end end})
PlayerTab:CreateSlider({Name = "Speed", Range = {10,150}, Increment = 5, CurrentValue = 50, Callback = function(v) Settings.Fly.Speed = v end})

PlayerTab:CreateSection("Movement")
PlayerTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Settings.Noclip.Enabled = v end})
PlayerTab:CreateToggle({Name = "Speed", CurrentValue = false, Callback = function(v) Settings.Speed.Enabled = v end})
PlayerTab:CreateSlider({Name = "Speed Amount", Range = {16,250}, Increment = 1, CurrentValue = 32, Callback = function(v) Settings.Speed.Amount = v end})
PlayerTab:CreateToggle({Name = "Jump Power", CurrentValue = false, Callback = function(v) Settings.Jump.Enabled = v end})
PlayerTab:CreateSlider({Name = "Jump Amount", Range = {50,250}, Increment = 1, CurrentValue = 75, Callback = function(v) Settings.Jump.Amount = v end})
PlayerTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Settings.InfiniteJump.Enabled = v end})

-- Visuals Tab
VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.ESP.Enabled = v end})
VisualsTab:CreateToggle({Name = "Box", CurrentValue = true, Callback = function(v) Settings.ESP.Box = v end})
VisualsTab:CreateColorPicker({Name = "Box Color", CurrentValue = Color3.fromRGB(255,100,100), Callback = function(v) Settings.ESP.BoxColor = v end})
VisualsTab:CreateToggle({Name = "Name", CurrentValue = true, Callback = function(v) Settings.ESP.Name = v end})
VisualsTab:CreateToggle({Name = "Health", CurrentValue = true, Callback = function(v) Settings.ESP.Health = v end})
VisualsTab:CreateToggle({Name = "Distance", CurrentValue = true, Callback = function(v) Settings.ESP.Distance = v end})
VisualsTab:CreateToggle({Name = "Tracer", CurrentValue = false, Callback = function(v) Settings.ESP.Tracer = v end})
VisualsTab:CreateToggle({Name = "Head Dot", CurrentValue = false, Callback = function(v) Settings.ESP.HeadDot = v end})

VisualsTab:CreateSection("World")
VisualsTab:CreateToggle({Name = "Full Bright", CurrentValue = false, Callback = function(v) Settings.World.FullBright = v end})
VisualsTab:CreateToggle({Name = "No Fog", CurrentValue = false, Callback = function(v) Settings.World.NoFog = v end})
VisualsTab:CreateToggle({Name = "No Shadows", CurrentValue = false, Callback = function(v) Settings.World.NoShadows = v end})

-- Misc Tab
MiscTab:CreateSection("Settings")
MiscTab:CreateButton({Name = "Destroy UI", Callback = function() Window:Destroy() end})
MiscTab:CreateButton({Name = "Rejoin", Callback = function() game:GetService("TeleportService"):Teleport(PlaceId, LocalPlayer) end})

-- Game Specific Tab
if Game == "Arsenal" then
    GameTab:CreateSection("Arsenal Features")
    GameTab:CreateToggle({Name = "Auto Kill", CurrentValue = false})
    GameTab:CreateToggle({Name = "Auto Kill All", CurrentValue = false})
    GameTab:CreateToggle({Name = "No Scope", CurrentValue = false})
elseif Game == "Rivals" then
    GameTab:CreateSection("Rivals Features")
    GameTab:CreateToggle({Name = "Auto Farm", CurrentValue = false})
    GameTab:CreateToggle({Name = "Infinite Spin", CurrentValue = false})
    GameTab:CreateToggle({Name = "Auto GK", CurrentValue = false})
elseif Game == "DaHood" then
    GameTab:CreateSection("Da Hood Features")
    GameTab:CreateToggle({Name = "Auto Farm", CurrentValue = false})
    GameTab:CreateToggle({Name = "Anti Stomp", CurrentValue = false})
    GameTab:CreateToggle({Name = "Desync", CurrentValue = false})
end

Rayfield:Notify({
    Title = "xdhubz",
    Content = Game .. " script loaded!",
    Duration = 5
})
