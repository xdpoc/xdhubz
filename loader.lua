-- xdhubz - Universal Script
-- Version: 2.1
-- Games: Arsenal, Rivals, Da Hood

-- Try multiple UI library sources
local UI = nil
local UI_SOURCES = {
    "https://raw.githubusercontent.com/linemaster2/Rayfield/main/source", -- Backup mirror
    "https://raw.githubusercontent.com/Mstudio45/Rayfield/main/source", -- Another mirror
    "https://raw.githubusercontent.com/7rebex/Rayfield/main/source" -- Another mirror
}

local success = false
for _, url in ipairs(UI_SOURCES) do
    pcall(function()
        UI = loadstring(game:HttpGet(url))()
        if UI then success = true end
    end)
    if success then break end
end

-- If all Rayfield mirrors fail, use OwlHub as fallback
if not success then
    UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"))()
end

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Game Detection
local PlaceId = game.PlaceId
local Game = "Universal"

local GameDetection = {
    Arsenal = {286090429, 142823239, 4123456789, 1304584327, 5602055394},
    Rivals = {4483381587, 2713886045, 606849621, 9192908196, 1537690962},
    DaHood = {7213776334, 2788229376, 12132143254, 5421072413}
}

for name, ids in pairs(GameDetection) do
    for _, id in ipairs(ids) do
        if PlaceId == id then 
            Game = name 
            break
        end
    end
end

-- Create Window based on which UI loaded
local Window
if UI.CreateWindow then -- OwlHub
    Window = UI:CreateWindow({
        Name = "xdhubz | " .. Game,
        Description = "Arsenal • Rivals • Da Hood",
        Theme = "Default",
        Folder = "xdhubz"
    })
else -- Rayfield
    Window = UI:CreateWindow({
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
end

-- Create Tabs (UI agnostic)
local Tabs = {}

if UI.CreateWindow then -- OwlHub
    Tabs.Main = Window:AddTab("Main")
    Tabs.Combat = Window:AddTab("Combat")
    Tabs.Player = Window:AddTab("Player")
    Tabs.Visuals = Window:AddTab("Visuals")
    Tabs.Misc = Window:AddTab("Misc")
    Tabs.GameSpecific = Window:AddTab(Game)
else -- Rayfield
    Tabs.Main = Window:CreateTab("Main", 4483362458)
    Tabs.Combat = Window:CreateTab("Combat", 4483362458)
    Tabs.Player = Window:CreateTab("Player", 4483362458)
    Tabs.Visuals = Window:CreateTab("Visuals", 4483362458)
    Tabs.Misc = Window:CreateTab("Misc", 4483362458)
    Tabs.GameSpecific = Window:CreateTab(Game, 4483362458)
end

-- Settings Storage
local Settings = {
    SilentAim = {Enabled = false, HitPart = "Head", FOV = 90, Prediction = 0.165, TeamCheck = true, WallCheck = true, ShowFOV = false},
    Aimlock = {Enabled = false, Smoothness = 5, TargetPart = "Head", Key = Enum.UserInputType.MouseButton2, Holding = false},
    Triggerbot = {Enabled = false, Delay = 0.05},
    Hitbox = {Enabled = false, Size = 2.5, Transparency = 0.7, TeamCheck = true, Color = Color3.fromRGB(255,0,0)},
    InfiniteAmmo = {Enabled = false},
    NoRecoil = {Enabled = false},
    NoSpread = {Enabled = false},
    RapidFire = {Enabled = false},
    InstantReload = {Enabled = false},
    DamageMultiplier = {Enabled = false, Value = 1},
    Fly = {Enabled = false, Speed = 50},
    Noclip = {Enabled = false},
    Speed = {Enabled = false, Amount = 32},
    Jump = {Enabled = false, Amount = 75},
    InfiniteJump = {Enabled = false},
    ESP = {Enabled = false, Box = true, BoxColor = Color3.fromRGB(255,100,100), Name = true, Health = true, Distance = true, Weapon = true, Tracer = false, HeadDot = false, Skeleton = false, BoxOutline = true},
    World = {FullBright = {Enabled = false}, NoFog = {Enabled = false}, NoShadows = {Enabled = false}},
    GodMode = {Enabled = false},
    AntiAfk = {Enabled = false},
    NoFallDamage = {Enabled = false}
}

-- Game Specific Features
local GameFeatures = {
    Arsenal = {
        AutoKill = {Enabled = false, Range = 80},
        AutoKillAll = {Enabled = false},
        AutoFarm = {Enabled = false},
        NoScope = {Enabled = false},
        AutoReload = {Enabled = false},
        InfiniteStamina = {Enabled = false},
        NoKnockback = {Enabled = false}
    },
    Rivals = {
        AutoFarm = {Enabled = false},
        InfiniteSpin = {Enabled = false},
        AutoGK = {Enabled = false},
        SpeedBoost = {Enabled = false, Multiplier = 3},
        JumpBoost = {Enabled = false, Multiplier = 3}
    },
    DaHood = {
        AutoFarm = {Enabled = false},
        AutoCollect = {Enabled = false, Radius = 50},
        AutoStr = {Enabled = false, Message = ""},
        AntiStomp = {Enabled = false},
        Desync = {Enabled = false}
    }
}

-- Game Offsets
local Offsets = {
    Arsenal = {
        SilentAimHook = "FindPartOnRayWithIgnoreList",
        Ammo = "CurrentAmmo",
        FireRate = "FireRate",
        Recoil = "Recoil",
        Spread = "Spread"
    },
    Rivals = {
        SilentAimHook = "FindPartOnRayWithIgnoreList",
        Ammo = "CurrentAmmo",
        FireRate = "FireRate",
        Recoil = "Recoil",
        Spread = "Spread"
    },
    DaHood = {
        SilentAimHook = "FindPartOnRayWithIgnoreList",
        Ammo = "Ammo",
        FireRate = "Firerate",
        Recoil = "Recoil",
        Spread = "Spread"
    }
}

local Offset = Offsets[Game] or Offsets.Arsenal
local CurrentGameFeatures = GameFeatures[Game] or {}

-- Utility Functions
local Utility = {
    IsAlive = function(character)
        return character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") and character.Humanoid.Health > 0
    end,
    
    GetClosestPlayer = function(ignoreTeam, maxDistance, targetPart)
        local closest, closestDist = nil, maxDistance or math.huge
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Utility.IsAlive(player.Character) then
                local part = player.Character:FindFirstChild(targetPart or "Head")
                if part and (not ignoreTeam or player.Team ~= LocalPlayer.Team) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = {Player = player, Part = part, Position = part.Position}
                        end
                    end
                end
            end
        end
        
        return closest, closestDist
    end
}

-- Silent Aim Hook
local SilentAimHook
local hook_success, hook_error = pcall(function()
    SilentAimHook = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if Settings.SilentAim.Enabled and method == Offset.SilentAimHook and self:IsA("Camera") then
            local closest = Utility.GetClosestPlayer(Settings.SilentAim.TeamCheck, Settings.SilentAim.FOV, Settings.SilentAim.HitPart)
            
            if closest then
                local part = closest.Part
                local prediction = part.Velocity * Settings.SilentAim.Prediction
                local targetPos = part.Position + prediction
                
                if Settings.SilentAim.WallCheck then
                    local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 500)
                    local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                    if hit and not hit:IsDescendantOf(closest.Player.Character) then
                        return SilentAimHook(self, ...)
                    end
                end
                
                return {targetPos}, targetPos, Vector3.new(), Enum.Material.SmoothPlastic
            end
        end
        
        return SilentAimHook(self, ...)
    end)
end)

-- Index Hook
local IndexHook
pcall(function()
    IndexHook = hookmetamethod(game, "__index", function(self, key)
        if type(key) == "string" then
            if Settings.NoRecoil.Enabled and self:IsA("LocalScript") and key:find(Offset.Recoil or "") then
                return 0
            end
            if Settings.NoSpread.Enabled and self:IsA("LocalScript") and key:find(Offset.Spread or "") then
                return 0
            end
            if Settings.RapidFire.Enabled and self:IsA("LocalScript") and key:find(Offset.FireRate or "") then
                return 0.01
            end
            if Settings.InfiniteAmmo.Enabled and self:IsA("IntValue") and self.Name == Offset.Ammo and key == "Value" then
                return 999
            end
            if Settings.InstantReload.Enabled and self:IsA("NumberValue") and self.Name == "ReloadTime" and key == "Value" then
                return 0.01
            end
            if Settings.DamageMultiplier.Enabled and self:IsA("NumberValue") and self.Name == "Damage" and key == "Value" then
                return IndexHook(self, key) * Settings.DamageMultiplier.Value
            end
            if Settings.GodMode.Enabled and self:IsA("IntValue") and self.Name == "Health" and key == "Value" then
                return 100
            end
        end
        
        return IndexHook(self, key)
    end)
end)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.SilentAim.FOV
FOVCircle.Color = Color3.fromRGB(255,100,100)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Transparency = 0.7

-- Fly System
local FlySystem = {
    BodyGyro = nil,
    BodyVelocity = nil,
    Connection = nil,
    
    Start = function()
        local character = LocalPlayer.Character
        if not Utility.IsAlive(character) then return end
        
        local root = character.HumanoidRootPart
        local humanoid = character.Humanoid
        
        humanoid.PlatformStand = true
        
        FlySystem.BodyGyro = Instance.new("BodyGyro")
        FlySystem.BodyGyro.P = 9e4
        FlySystem.BodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
        FlySystem.BodyGyro.CFrame = root.CFrame
        FlySystem.BodyGyro.Parent = root
        
        FlySystem.BodyVelocity = Instance.new("BodyVelocity")
        FlySystem.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlySystem.BodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
        FlySystem.BodyVelocity.Parent = root
        
        FlySystem.Connection = RunService.Heartbeat:Connect(function()
            if not Settings.Fly.Enabled or not Utility.IsAlive(character) then
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
            
            FlySystem.BodyVelocity.Velocity = move * Settings.Fly.Speed
            FlySystem.BodyGyro.CFrame = cf
        end)
    end,
    
    Stop = function()
        if FlySystem.Connection then
            FlySystem.Connection:Disconnect()
            FlySystem.Connection = nil
        end
        
        local character = LocalPlayer.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if FlySystem.BodyGyro then
                FlySystem.BodyGyro:Destroy()
                FlySystem.BodyGyro = nil
            end
            
            if FlySystem.BodyVelocity then
                FlySystem.BodyVelocity:Destroy()
                FlySystem.BodyVelocity = nil
            end
            
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
}

-- Hitbox System
local HitboxSystem = {
    Highlights = {},
    
    Create = function(player)
        if player == LocalPlayer then return end
        if not Utility.IsAlive(player.Character) then return end
        
        HitboxSystem.Remove(player)
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "xdhubz_Hitbox"
        highlight.Adornee = player.Character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Settings.Hitbox.Color
        highlight.FillTransparency = Settings.Hitbox.Transparency
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.5
        highlight.Parent = CoreGui
        
        HitboxSystem.Highlights[player] = highlight
    end,
    
    Remove = function(player)
        if HitboxSystem.Highlights[player] then
            pcall(function()
                HitboxSystem.Highlights[player]:Destroy()
            end)
            HitboxSystem.Highlights[player] = nil
        end
    end,
    
    UpdateAll = function()
        if not Settings.Hitbox.Enabled then
            for player, _ in pairs(HitboxSystem.Highlights) do
                HitboxSystem.Remove(player)
            end
            return
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Utility.IsAlive(player.Character) then
                local isValid = not Settings.Hitbox.TeamCheck or player.Team ~= LocalPlayer.Team
                
                if isValid then
                    if HitboxSystem.Highlights[player] then
                        local highlight = HitboxSystem.Highlights[player]
                        highlight.FillColor = Settings.Hitbox.Color
                        highlight.FillTransparency = Settings.Hitbox.Transparency
                        highlight.Adornee = player.Character
                    else
                        HitboxSystem.Create(player)
                    end
                else
                    HitboxSystem.Remove(player)
                end
            end
        end
    end
}

-- ESP System
local ESPSystem = {
    Objects = {},
    SkeletonJoints = {
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
    },
    
    Create = function(player)
        if player == LocalPlayer then return end
        
        local objects = {}
        
        -- Box
        objects.Box = Drawing.new("Square")
        objects.Box.Visible = false
        objects.Box.Color = Settings.ESP.BoxColor
        objects.Box.Thickness = 1.5
        objects.Box.Filled = false
        
        -- Box Outline
        objects.BoxOutline = Drawing.new("Square")
        objects.BoxOutline.Visible = false
        objects.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        objects.BoxOutline.Thickness = 3
        objects.BoxOutline.Filled = false
        
        -- Name
        objects.Name = Drawing.new("Text")
        objects.Name.Visible = false
        objects.Name.Color = Color3.fromRGB(255, 255, 255)
        objects.Name.Size = 16
        objects.Name.Center = true
        objects.Name.Outline = true
        
        -- Health
        objects.Health = Drawing.new("Text")
        objects.Health.Visible = false
        objects.Health.Color = Color3.fromRGB(100, 255, 100)
        objects.Health.Size = 14
        objects.Health.Center = true
        objects.Health.Outline = true
        
        -- Distance
        objects.Distance = Drawing.new("Text")
        objects.Distance.Visible = false
        objects.Distance.Color = Color3.fromRGB(200, 200, 200)
        objects.Distance.Size = 12
        objects.Distance.Center = true
        objects.Distance.Outline = true
        
        -- Tracer
        objects.Tracer = Drawing.new("Line")
        objects.Tracer.Visible = false
        objects.Tracer.Color = Color3.fromRGB(255, 255, 255)
        objects.Tracer.Thickness = 1.5
        
        -- Head Dot
        objects.HeadDot = Drawing.new("Circle")
        objects.HeadDot.Visible = false
        objects.HeadDot.Color = Color3.fromRGB(255, 0, 0)
        objects.HeadDot.Radius = 4
        objects.HeadDot.Filled = true
        objects.HeadDot.NumSides = 16
        
        -- Weapon
        objects.Weapon = Drawing.new("Text")
        objects.Weapon.Visible = false
        objects.Weapon.Color = Color3.fromRGB(255, 255, 0)
        objects.Weapon.Size = 12
        objects.Weapon.Center = true
        objects.Weapon.Outline = true
        
        -- Skeleton
        objects.Skeleton = {}
        for i = 1, #ESPSystem.SkeletonJoints do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Color = Color3.fromRGB(255, 255, 255)
            line.Thickness = 1.5
            table.insert(objects.Skeleton, line)
        end
        
        ESPSystem.Objects[player] = objects
    end,
    
    Remove = function(player)
        if ESPSystem.Objects[player] then
            for _, object in pairs(ESPSystem.Objects[player]) do
                if type(object) == "table" then
                    for _, line in pairs(object) do
                        pcall(function() line:Remove() end)
                    end
                else
                    pcall(function() object:Remove() end)
                end
            end
            ESPSystem.Objects[player] = nil
        end
    end,
    
    Update = function()
        if not Settings.ESP.Enabled then
            for player, objects in pairs(ESPSystem.Objects) do
                for _, object in pairs(objects) do
                    if type(object) == "table" then
                        for _, line in pairs(object) do
                            line.Visible = false
                        end
                    elseif object.Visible ~= nil then
                        object.Visible = false
                    end
                end
            end
            return
        end
        
        for player, objects in pairs(ESPSystem.Objects) do
            if Utility.IsAlive(player.Character) then
                local root = player.Character.HumanoidRootPart
                local humanoid = player.Character.Humanoid
                local head = player.Character:FindFirstChild("Head")
                
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local headPos = head and Camera:WorldToViewportPoint(head.Position) or rootPos
                local distance = (root.Position - Camera.CFrame.Position).Magnitude
                
                if onScreen then
                    local scale = 1 / (rootPos.Z * 0.1)
                    local width = math.clamp(35 * scale, 25, 80)
                    local height = math.clamp(60 * scale, 40, 140)
                    local boxPos = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                    local boxColor = player.Team == LocalPlayer.Team and Color3.fromRGB(100, 255, 100) or Settings.ESP.BoxColor
                    
                    -- Box
                    if Settings.ESP.Box then
                        objects.Box.Visible = true
                        objects.Box.Position = boxPos
                        objects.Box.Size = Vector2.new(width, height)
                        objects.Box.Color = boxColor
                    else
                        objects.Box.Visible = false
                    end
                    
                    -- Box Outline
                    if Settings.ESP.BoxOutline and Settings.ESP.Box then
                        objects.BoxOutline.Visible = true
                        objects.BoxOutline.Position = boxPos - Vector2.new(1, 1)
                        objects.BoxOutline.Size = Vector2.new(width + 2, height + 2)
                    else
                        objects.BoxOutline.Visible = false
                    end
                    
                    -- Name
                    if Settings.ESP.Name then
                        objects.Name.Visible = true
                        objects.Name.Position = Vector2.new(rootPos.X, boxPos.Y - 20)
                        objects.Name.Text = player.Name
                    else
                        objects.Name.Visible = false
                    end
                    
                    -- Health
                    if Settings.ESP.Health and humanoid then
                        objects.Health.Visible = true
                        objects.Health.Position = Vector2.new(rootPos.X, boxPos.Y + height + 5)
                        objects.Health.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        objects.Health.Color = Color3.fromRGB(100, 255, 100)
                    else
                        objects.Health.Visible = false
                    end
                    
                    -- Distance
                    if Settings.ESP.Distance then
                        objects.Distance.Visible = true
                        objects.Distance.Position = Vector2.new(rootPos.X, boxPos.Y + height + 25)
                        objects.Distance.Text = math.floor(distance) .. " studs"
                    else
                        objects.Distance.Visible = false
                    end
                    
                    -- Tracer
                    if Settings.ESP.Tracer then
                        objects.Tracer.Visible = true
                        objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        objects.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    else
                        objects.Tracer.Visible = false
                    end
                    
                    -- Head Dot
                    if Settings.ESP.HeadDot and head then
                        objects.HeadDot.Visible = true
                        objects.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                    else
                        objects.HeadDot.Visible = false
                    end
                    
                    -- Weapon
                    if Settings.ESP.Weapon then
                        objects.Weapon.Visible = true
                        objects.Weapon.Position = Vector2.new(rootPos.X, boxPos.Y - 40)
                        local tool = player.Character:FindFirstChildOfClass("Tool")
                        objects.Weapon.Text = tool and tool.Name or "None"
                    else
                        objects.Weapon.Visible = false
                    end
                    
                    -- Skeleton
                    if Settings.ESP.Skeleton then
                        for i, joints in ipairs(ESPSystem.SkeletonJoints) do
                            local part1 = player.Character:FindFirstChild(joints[1])
                            local part2 = player.Character:FindFirstChild(joints[2])
                            
                            if part1 and part2 then
                                local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                                
                                if vis1 and vis2 then
                                    objects.Skeleton[i].Visible = true
                                    objects.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                    objects.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                else
                                    objects.Skeleton[i].Visible = false
                                end
                            else
                                objects.Skeleton[i].Visible = false
                            end
                        end
                    else
                        for _, line in pairs(objects.Skeleton) do
                            line.Visible = false
                        end
                    end
                else
                    -- Hide all if off screen
                    objects.Box.Visible = false
                    objects.BoxOutline.Visible = false
                    objects.Name.Visible = false
                    objects.Health.Visible = false
                    objects.Distance.Visible = false
                    objects.Tracer.Visible = false
                    objects.HeadDot.Visible = false
                    objects.Weapon.Visible = false
                    for _, line in pairs(objects.Skeleton) do
                        line.Visible = false
                    end
                end
            else
                -- Hide all if dead
                objects.Box.Visible = false
                objects.BoxOutline.Visible = false
                objects.Name.Visible = false
                objects.Health.Visible = false
                objects.Distance.Visible = false
                objects.Tracer.Visible = false
                objects.HeadDot.Visible = false
                objects.Weapon.Visible = false
                for _, line in pairs(objects.Skeleton) do
                    line.Visible = false
                end
            end
        end
    end
}

-- World Effects
local WorldEffects = {
    OriginalBrightness = Lighting.Brightness,
    OriginalFogEnd = Lighting.FogEnd,
    OriginalGlobalShadows = Lighting.GlobalShadows,
    OriginalAmbient = Lighting.Ambient,
    OriginalOutdoorAmbient = Lighting.OutdoorAmbient,
    
    Update = function()
        -- Full Bright
        if Settings.World.FullBright.Enabled then
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = WorldEffects.OriginalBrightness
            Lighting.GlobalShadows = WorldEffects.OriginalGlobalShadows
            Lighting.Ambient = WorldEffects.OriginalAmbient
            Lighting.OutdoorAmbient = WorldEffects.OriginalOutdoorAmbient
        end
        
        -- No Fog
        if Settings.World.NoFog.Enabled then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = WorldEffects.OriginalFogEnd
        end
        
        -- No Shadows
        if Settings.World.NoShadows.Enabled then
            Lighting.GlobalShadows = false
        elseif not Settings.World.FullBright.Enabled then
            Lighting.GlobalShadows = WorldEffects.OriginalGlobalShadows
        end
    end
}

-- Anti-AFK
local AntiAfkSystem = {
    Connection = nil,
    
    Start = function()
        if AntiAfkSystem.Connection then
            AntiAfkSystem.Connection:Disconnect()
        end
        
        AntiAfkSystem.Connection = LocalPlayer.Idled:Connect(function()
            if Settings.AntiAfk.Enabled then
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    end,
    
    Stop = function()
        if AntiAfkSystem.Connection then
            AntiAfkSystem.Connection:Disconnect()
            AntiAfkSystem.Connection = nil
        end
    end
}

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    ESPSystem.Create(player)
end

-- Initialize Anti-AFK
AntiAfkSystem.Start()

-- Connections
Players.PlayerAdded:Connect(function(player)
    ESPSystem.Create(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.Hitbox.Enabled then
            HitboxSystem.UpdateAll()
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    ESPSystem.Remove(player)
    HitboxSystem.Remove(player)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    
    if Settings.Fly.Enabled then
        FlySystem.Stop()
        task.wait(0.1)
        FlySystem.Start()
    end
    
    if Settings.Hitbox.Enabled then
        HitboxSystem.UpdateAll()
    end
end)

-- Input handling for aimlock
UserInputService.InputBegan:Connect(function(input)
    if Settings.Aimlock.Enabled then
        if input.UserInputType == Settings.Aimlock.Key or input.KeyCode == Enum.KeyCode[tostring(Settings.Aimlock.Key)] then
            Settings.Aimlock.Holding = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.Aimlock.Key or input.KeyCode == Enum.KeyCode[tostring(Settings.Aimlock.Key)] then
        Settings.Aimlock.Holding = false
    end
end)

-- RenderStepped loop
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
        local closest = Utility.GetClosestPlayer(Settings.SilentAim.TeamCheck, math.huge, Settings.Aimlock.TargetPart)
        if closest then
            local targetPos = closest.Part.Position
            local currentLook = Camera.CFrame.LookVector
            local targetDir = (targetPos - Camera.CFrame.Position).Unit
            local smooth = currentLook:Lerp(targetDir, 1 / Settings.Aimlock.Smoothness)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + smooth)
        end
    end
    
    -- Update ESP
    ESPSystem.Update()
end)

-- Stepped loop for movement
RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    
    if Utility.IsAlive(character) then
        local humanoid = character.Humanoid
        
        -- Noclip
        if Settings.Noclip.Enabled then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        -- Speed
        if Settings.Speed.Enabled then
            humanoid.WalkSpeed = Settings.Speed.Amount
        end
        
        -- Jump Power
        if Settings.Jump.Enabled then
            humanoid.JumpPower = Settings.Jump.Amount
        end
    end
end)

-- Triggerbot
task.spawn(function()
    while task.wait() do
        if Settings.Triggerbot.Enabled then
            local target = Mouse.Target
            if target then
                local character = target.Parent
                if character and character:FindFirstChild("Humanoid") then
                    local player = Players:GetPlayerFromCharacter(character)
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

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump.Enabled and Utility.IsAlive(LocalPlayer.Character) then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- World Effects Update loop
task.spawn(function()
    while task.wait(0.5) do
        WorldEffects.Update()
    end
end)

-- ==================== UI CREATION ====================
-- (UI Agnostic implementation)

-- Main Tab
if Tabs.Main.CreateParagraph then -- Rayfield
    Tabs.Main:CreateParagraph({
        Title = "xdhubz • 2026",
        Content = string.format(
            "Game: %s\nUser: %s\nMobile: %s\nStatus: Loaded",
            Game,
            LocalPlayer.Name,
            UserInputService.TouchEnabled and "Yes" or "No"
        )
    })
elseif Tabs.Main.AddParagraph then -- OwlHub
    Tabs.Main:AddParagraph({
        Title = "xdhubz • 2026",
        Content = string.format(
            "Game: %s\nUser: %s\nMobile: %s\nStatus: Loaded",
            Game,
            LocalPlayer.Name,
            UserInputService.TouchEnabled and "Yes" or "No"
        )
    })
end

-- Helper function for UI creation
local function AddToggle(tab, name, default, callback)
    if tab.CreateToggle then -- Rayfield
        tab:CreateToggle({
            Name = name,
            CurrentValue = default,
            Callback = callback
        })
    elseif tab.AddToggle then -- OwlHub
        tab:AddToggle({
            Name = name,
            Default = default,
            Callback = callback
        })
    end
end

local function AddSlider(tab, name, min, max, default, callback)
    if tab.CreateSlider then -- Rayfield
        tab:CreateSlider({
            Name = name,
            Range = {min, max},
            Increment = (max - min) / 100,
            CurrentValue = default,
            Callback = callback
        })
    elseif tab.AddSlider then -- OwlHub
        tab:AddSlider({
            Name = name,
            Min = min,
            Max = max,
            Default = default,
            Callback = callback
        })
    end
end

local function AddDropdown(tab, name, options, default, callback)
    if tab.CreateDropdown then -- Rayfield
        tab:CreateDropdown({
            Name = name,
            Options = options,
            CurrentOption = {default},
            Callback = function(v) callback(v[1]) end
        })
    elseif tab.AddDropdown then -- OwlHub
        tab:AddDropdown({
            Name = name,
            Options = options,
            Default = default,
            Callback = callback
        })
    end
end

local function AddColorPicker(tab, name, default, callback)
    if tab.CreateColorPicker then -- Rayfield
        tab:CreateColorPicker({
            Name = name,
            CurrentValue = default,
            Callback = callback
        })
    elseif tab.AddColorPicker then -- OwlHub
        tab:AddColorPicker({
            Name = name,
            Default = default,
            Callback = callback
        })
    end
end

local function AddButton(tab, name, callback)
    if tab.CreateButton then -- Rayfield
        tab:CreateButton({
            Name = name,
            Callback = callback
        })
    elseif tab.AddButton then -- OwlHub
        tab:AddButton({
            Name = name,
            Callback = callback
        })
    end
end

local function AddSection(tab, name)
    if tab.CreateSection then -- Rayfield
        tab:CreateSection(name)
    elseif tab.AddSection then -- OwlHub
        tab:AddSection(name)
    end
end

-- Combat Tab
AddSection(Tabs.Combat, "Silent Aim")
AddToggle(Tabs.Combat, "Enabled", false, function(v) Settings.SilentAim.Enabled = v end)
AddDropdown(Tabs.Combat, "Hitbox", {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, "Head", function(v) Settings.SilentAim.HitPart = v end)
AddSlider(Tabs.Combat, "FOV", 30, 200, 90, function(v) Settings.SilentAim.FOV = v end)
AddSlider(Tabs.Combat, "Prediction", 0, 300, 165, function(v) Settings.SilentAim.Prediction = v / 1000 end)
AddToggle(Tabs.Combat, "Team Check", true, function(v) Settings.SilentAim.TeamCheck = v end)
AddToggle(Tabs.Combat, "Wall Check", true, function(v) Settings.SilentAim.WallCheck = v end)
AddToggle(Tabs.Combat, "Show FOV", false, function(v) Settings.SilentAim.ShowFOV = v end)

AddSection(Tabs.Combat, "Aimlock")
AddToggle(Tabs.Combat, "Enabled", false, function(v) Settings.Aimlock.Enabled = v end)
AddSlider(Tabs.Combat, "Smoothness", 1, 15, 5, function(v) Settings.Aimlock.Smoothness = v end)
AddDropdown(Tabs.Combat, "Target", {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, "Head", function(v) Settings.Aimlock.TargetPart = v end)

AddSection(Tabs.Combat, "Triggerbot")
AddToggle(Tabs.Combat, "Enabled", false, function(v) Settings.Triggerbot.Enabled = v end)
AddSlider(Tabs.Combat, "Delay (ms)", 0, 200, 50, function(v) Settings.Triggerbot.Delay = v / 1000 end)

AddSection(Tabs.Combat, "Hitbox Expander")
AddToggle(Tabs.Combat, "Enabled", false, function(v)
    Settings.Hitbox.Enabled = v
    if v then
        HitboxSystem.UpdateAll()
    else
        for player, _ in pairs(HitboxSystem.Highlights) do
            HitboxSystem.Remove(player)
        end
    end
end)
AddSlider(Tabs.Combat, "Size", 1, 5, 2.5, function(v) Settings.Hitbox.Size = v end)
AddSlider(Tabs.Combat, "Transparency", 0, 1, 0.7, function(v)
    Settings.Hitbox.Transparency = v
    if Settings.Hitbox.Enabled then
        HitboxSystem.UpdateAll()
    end
end)
AddToggle(Tabs.Combat, "Team Check", true, function(v)
    Settings.Hitbox.TeamCheck = v
    if Settings.Hitbox.Enabled then
        HitboxSystem.UpdateAll()
    end
end)
AddColorPicker(Tabs.Combat, "Color", Color3.fromRGB(255,0,0), function(v)
    Settings.Hitbox.Color = v
    if Settings.Hitbox.Enabled then
        HitboxSystem.UpdateAll()
    end
end)

AddSection(Tabs.Combat, "Gun Mods")
AddToggle(Tabs.Combat, "Infinite Ammo", false, function(v) Settings.InfiniteAmmo.Enabled = v end)
AddToggle(Tabs.Combat, "No Recoil", false, function(v) Settings.NoRecoil.Enabled = v end)
AddToggle(Tabs.Combat, "No Spread", false, function(v) Settings.NoSpread.Enabled = v end)
AddToggle(Tabs.Combat, "Rapid Fire", false, function(v) Settings.RapidFire.Enabled = v end)
AddToggle(Tabs.Combat, "Instant Reload", false, function(v) Settings.InstantReload.Enabled = v end)
AddToggle(Tabs.Combat, "Damage Multiplier", false, function(v) Settings.DamageMultiplier.Enabled = v end)
AddSlider(Tabs.Combat, "Damage Amount", 1, 10, 1, function(v) Settings.DamageMultiplier.Value = v end)

-- Player Tab
AddSection(Tabs.Player, "Fly")
AddToggle(Tabs.Player, "Enabled", false, function(v)
    Settings.Fly.Enabled = v
    if v then
        FlySystem.Start()
    else
        FlySystem.Stop()
    end
end)
AddSlider(Tabs.Player, "Speed", 10, 150, 50, function(v) Settings.Fly.Speed = v end)

AddSection(Tabs.Player, "Movement")
AddToggle(Tabs.Player, "Noclip", false, function(v) Settings.Noclip.Enabled = v end)
AddToggle(Tabs.Player, "Speed", false, function(v) Settings.Speed.Enabled = v end)
AddSlider(Tabs.Player, "Speed Amount", 16, 250, 32, function(v) Settings.Speed.Amount = v end)
AddToggle(Tabs.Player, "Jump Power", false, function(v) Settings.Jump.Enabled = v end)
AddSlider(Tabs.Player, "Jump Amount", 50, 250, 75, function(v) Settings.Jump.Amount = v end)
AddToggle(Tabs.Player, "Infinite Jump", false, function(v) Settings.InfiniteJump.Enabled = v end)

AddSection(Tabs.Player, "Misc")
AddToggle(Tabs.Player, "Anti-AFK", false, function(v)
    Settings.AntiAfk.Enabled = v
    if v then
        AntiAfkSystem.Start()
    else
        AntiAfkSystem.Stop()
    end
end)
AddToggle(Tabs.Player, "No Fall Damage", false, function(v) Settings.NoFallDamage.Enabled = v end)

-- Visuals Tab
AddSection(Tabs.Visuals, "ESP")
AddToggle(Tabs.Visuals, "Enabled", false, function(v) Settings.ESP.Enabled = v end)
AddToggle(Tabs.Visuals, "Box", true, function(v) Settings.ESP.Box = v end)
AddToggle(Tabs.Visuals, "Box Outline", true, function(v) Settings.ESP.BoxOutline = v end)
AddColorPicker(Tabs.Visuals, "Box Color", Color3.fromRGB(255,100,100), function(v) Settings.ESP.BoxColor = v end)
AddToggle(Tabs.Visuals, "Name", true, function(v) Settings.ESP.Name = v end)
AddToggle(Tabs.Visuals, "Health", true, function(v) Settings.ESP.Health = v end)
AddToggle(Tabs.Visuals, "Distance", true, function(v) Settings.ESP.Distance = v end)
AddToggle(Tabs.Visuals, "Weapon", true, function(v) Settings.ESP.Weapon = v end)
AddToggle(Tabs.Visuals, "Tracer", false, function(v) Settings.ESP.Tracer = v end)
AddToggle(Tabs.Visuals, "Head Dot", false, function(v) Settings.ESP.HeadDot = v end)
AddToggle(Tabs.Visuals, "Skeleton", false, function(v) Settings.ESP.Skeleton = v end)

AddSection(Tabs.Visuals, "World")
AddToggle(Tabs.Visuals, "Full Bright", false, function(v)
    Settings.World.FullBright.Enabled = v
    WorldEffects.Update()
end)
AddToggle(Tabs.Visuals, "No Fog", false, function(v)
    Settings.World.NoFog.Enabled = v
    WorldEffects.Update()
end)
AddToggle(Tabs.Visuals, "No Shadows", false, function(v)
    Settings.World.NoShadows.Enabled = v
    WorldEffects.Update()
end)

-- Misc Tab
AddSection(Tabs.Misc, "Settings")
AddButton(Tabs.Misc, "Destroy UI", function()
    if Window:Destroy then
        Window:Destroy()
    elseif Window:Delete then
        Window:Delete()
    end
end)

AddButton(Tabs.Misc, "Rejoin Game", function()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(PlaceId, LocalPlayer)
end)

AddButton(Tabs.Misc, "Server Hop", function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    
    local servers = {}
    local req = request or http_request or syn and syn.request
    
    if req then
        local cursor = ""
        local placeInfo = game:GetService("MarketplaceService"):GetProductInfo(PlaceId)
        local maxPlayers = placeInfo.MaxPlayers or 30
        
        repeat
            local response = req({
                Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100&cursor=%s", PlaceId, cursor),
                Method = "GET"
            })
            
            local data = HttpService:JSONDecode(response.Body)
            
            for _, server in ipairs(data.data) do
                if server.playing < maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            
            cursor = data.nextPageCursor
        until not cursor or #servers >= 10
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            if Window:Notification then
                Window:Notification({
                    Title = "Server Hop",
                    Content = "No servers available!",
                    Duration = 5
                })
            end
        end
    else
        if Window:Notification then
            Window:Notification({
                Title = "Server Hop",
                Content = "Executor doesn't support HTTP requests!",
                Duration = 5
            })
        end
    end
end)

-- Game Specific Tab
if Game == "Arsenal" then
    AddSection(Tabs.GameSpecific, "Arsenal Features")
    AddToggle(Tabs.GameSpecific, "Auto Kill", false, function(v) CurrentGameFeatures.AutoKill.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "Auto Kill All", false, function(v) CurrentGameFeatures.AutoKillAll.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "Auto Farm", false, function(v) CurrentGameFeatures.AutoFarm.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "No Scope", false, function(v) CurrentGameFeatures.NoScope.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "Auto Reload", false, function(v) CurrentGameFeatures.AutoReload.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "Infinite Stamina", false, function(v) CurrentGameFeatures.InfiniteStamina.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "No Knockback", false, function(v) CurrentGameFeatures.NoKnockback.Enabled = v end)
    
elseif Game == "Rivals" then
    AddSection(Tabs.GameSpecific, "Rivals Features")
    AddToggle(Tabs.GameSpecific, "Auto Farm", false, function(v) CurrentGameFeatures.AutoFarm.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "Infinite Spin", false, function(v) CurrentGameFeatures.InfiniteSpin.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "Auto GK", false, function(v) CurrentGameFeatures.AutoGK.Enabled = v end)
    AddSlider(Tabs.GameSpecific, "Speed Boost", 1, 5, 3, function(v) 
        CurrentGameFeatures.SpeedBoost.Multiplier = v
        CurrentGameFeatures.SpeedBoost.Enabled = true
    end)
    AddSlider(Tabs.GameSpecific, "Jump Boost", 1, 5, 3, function(v)
        CurrentGameFeatures.JumpBoost.Multiplier = v
        CurrentGameFeatures.JumpBoost.Enabled = true
    end)
    
elseif Game == "DaHood" then
    AddSection(Tabs.GameSpecific, "Da Hood Features")
    AddToggle(Tabs.GameSpecific, "Auto Farm", false, function(v) CurrentGameFeatures.AutoFarm.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "Auto Collect", false, function(v) CurrentGameFeatures.AutoCollect.Enabled = v end)
    AddSlider(Tabs.GameSpecific, "Collect Radius", 10, 100, 50, function(v) CurrentGameFeatures.AutoCollect.Radius = v end)
    AddToggle(Tabs.GameSpecific, "Anti Stomp", false, function(v) CurrentGameFeatures.AntiStomp.Enabled = v end)
    AddToggle(Tabs.GameSpecific, "Desync", false, function(v) CurrentGameFeatures.Desync.Enabled = v end)
    
    if Tabs.GameSpecific.CreateTextBox then -- Rayfield
        Tabs.GameSpecific:CreateTextBox({
            Name = "Auto Str Message",
            PlaceholderText = "Enter message",
            Callback = function(v) CurrentGameFeatures.AutoStr.Message = v end
        })
    elseif Tabs.GameSpecific.AddTextBox then -- OwlHub
        Tabs.GameSpecific:AddTextBox({
            Name = "Auto Str Message",
            Placeholder = "Enter message",
            Callback = function(v) CurrentGameFeatures.AutoStr.Message = v end
        })
    end
    
    AddToggle(Tabs.GameSpecific, "Auto Str", false, function(v) CurrentGameFeatures.AutoStr.Enabled = v end)
end

-- Notification
if Window:Notification then
    Window:Notification({
        Title = "xdhubz",
        Content = string.format("%s script loaded successfully!", Game),
        Duration = 5
    })
elseif Window:Notify then
    Window:Notify({
        Title = "xdhubz",
        Content = string.format("%s script loaded successfully!", Game),
        Duration = 5
    })
end

print(string.format("[xdhubz] %s script loaded successfully! UI: %s", Game, UI.CreateWindow and "OwlHub" or "Rayfield"))
