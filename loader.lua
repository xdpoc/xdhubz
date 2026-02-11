--[=[
    Unnamed XD Hub
    Owner: @mqp6 / Poc
    Version: 4.0.0
    Games: Rivals, Da Hood, Phantom Forces, Arsenal, Universal
    Executors: Delta (Primary), Hydrogen, CodeX, Arceus X
]=]

--//////////////////////////////////////////////////////////////////
--//                          SERVICES                             //
--//////////////////////////////////////////////////////////////////
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")
local Network = game:GetService("NetworkClient")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

--//////////////////////////////////////////////////////////////////
--//                        VARIABLES                              //
--//////////////////////////////////////////////////////////////////
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local PlaceId = game.PlaceId
local JobId = game.JobId

local StartTime = tick()
local SessionId = HttpService:GenerateGUID(false)

local UserData = nil
local Authed = false
local SelectedUI = "Rayfield"

--//////////////////////////////////////////////////////////////////
--//                    DISCORD WEBHOOKS                           //
--//////////////////////////////////////////////////////////////////
local Webhooks = {
    Logs = "https://discord.com/api/webhooks/1355834963881885806/9aXZV1Mp3QFlQ38FBC4Fon4oVfcO-3cOJV4AdN1wZfWhTRaZhlZzPZ4j0WZzPZ4j0W",
    Alerts = "https://discord.com/api/webhooks/1355834963881885806/9aXZV1Mp3QFlQ38FBC4Fon4oVfcO-3cOJV4AdN1wZfWhTRaZhlZzPZ4j0WZzPZ4j0W"
}

--//////////////////////////////////////////////////////////////////
--//                      KEYAUTH CONFIG                          //
--//////////////////////////////////////////////////////////////////
local KeyAuth = {
    Name = "XD HUB",
    OwnerId = "eDjLQhPvrs",
    Version = "4.0",
    SessionId = "",
    Endpoint = "https://keyauth.win/api/1.1/"
}

--//////////////////////////////////////////////////////////////////
--//                        GAME DETECTION                        //
--//////////////////////////////////////////////////////////////////
local GameData = {
    Current = "Universal",
    PlaceIds = {
        Rivals = {4483381587, 2713886045, 606849621, 9192908196},
        DaHood = {7213776334, 2788229376, 12132143254},
        PhantomForces = {292439477, 13212453678},
        Arsenal = {286090429, 142823239, 4123456789}
    },
    Offsets = {
        Universal = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "CurrentAmmo",
            FireRate = "FireRate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime",
            Gravity = "Gravity"
        },
        Rivals = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "CurrentAmmo",
            FireRate = "FireRate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime",
            Gravity = "Gravity"
        },
        DaHood = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "Ammo",
            FireRate = "Firerate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime",
            Gravity = "Gravity"
        },
        PhantomForces = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "AmmoCount",
            FireRate = "FireRate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime",
            Gravity = "Gravity"
        },
        Arsenal = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "CurrentAmmo",
            FireRate = "FireRate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime",
            Gravity = "Gravity"
        }
    }
}

local function DetectGame()
    for name, ids in pairs(GameData.PlaceIds) do
        for _, id in ipairs(ids) do
            if PlaceId == id then
                GameData.Current = name
                return name
            end
        end
    end
    GameData.Current = "Universal"
    return "Universal"
end
DetectGame()

local Offsets = GameData.Offsets[GameData.Current]

--//////////////////////////////////////////////////////////////////
--//                    HELPER FUNCTIONS                          //
--//////////////////////////////////////////////////////////////////
local function EncodeURL(str)
    str = tostring(str)
    str = str:gsub(" ", "%%20")
    str = str:gsub("&", "%%26")
    str = str:gsub("%+", "%%2B")
    str = str:gsub("%/", "%%2F")
    str = str:gsub("%?", "%%3F")
    str = str:gsub("%=", "%%3D")
    return str
end

local function GetHWID()
    local success, result = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if success then
        return result
    else
        return "HWID_ERROR_" .. HttpService:GenerateGUID(false)
    end
end
local HWID = GetHWID()

local function GetJoinLink()
    return "https://www.roblox.com/Game/PlaceExperience?placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId
end

local function GetProfileLink(userId)
    return "https://www.roblox.com/users/" .. tostring(userId) .. "/profile"
end

--//////////////////////////////////////////////////////////////////
--//                    DISCORD LOGGER                             //
--//////////////////////////////////////////////////////////////////
local function SendWebhook(webhookType, data)
    task.spawn(function()
        pcall(function()
            local webhookUrl = Webhooks[webhookType] or Webhooks.Logs
            if webhookUrl == "" or not webhookUrl then return end
            
            local userId = LocalPlayer.UserId
            local displayName = LocalPlayer.DisplayName
            local username = LocalPlayer.Name
            local profileLink = GetProfileLink(userId)
            local joinLink = GetJoinLink()
            local gameInfo = MarketplaceService:GetProductInfo(PlaceId, Enum.InfoType.Asset)
            local gameName = gameInfo and gameInfo.Name or "Unknown"
            
            local embed = {
                title = "🛡️ Unnamed XD Hub | " .. tostring(webhookType),
                color = webhookType == "Logs" and 5763719 or 16711680,
                fields = {
                    {name = "User", value = string.format("[%s (@%s)](%s)", displayName, username, profileLink), inline = true},
                    {name = "User ID", value = tostring(userId), inline = true},
                    {name = "HWID", value = HWID, inline = false},
                    {name = "Game", value = string.format("%s (%d)", gameName, PlaceId), inline = true},
                    {name = "Server", value = string.format("[Join](%s)", joinLink), inline = true},
                    {name = "Key", value = data.key or "N/A", inline = false},
                    {name = "Session", value = SessionId, inline = false}
                },
                footer = {text = os.date("!%Y-%m-%d %H:%M:%S UTC")},
                timestamp = DateTime.now():ToIsoDate()
            }
            
            if data.type == "execute" then
                embed.title = "✅ Execution Success"
                embed.fields[#embed.fields+1] = {name = "Script Version", value = KeyAuth.Version, inline = true}
                embed.fields[#embed.fields+1] = {name = "Load Time", value = string.format("%.2fs", tick() - StartTime), inline = true}
            elseif data.type == "auth" then
                embed.title = "🔑 Authentication"
                embed.color = 15844367
                embed.fields[#embed.fields+1] = {name = "Status", value = data.success and "Success" or "Failed", inline = true}
                if data.username then
                    embed.fields[#embed.fields+1] = {name = "KeyAuth User", value = data.username, inline = true}
                end
            elseif data.type == "error" then
                embed.title = "⚠️ Script Error"
                embed.color = 15548997
                embed.fields[#embed.fields+1] = {name = "Error", value = data.message or "Unknown", inline = false}
            end
            
            local payload = {
                username = "XD Hub Logger",
                avatar_url = "https://cdn.discordapp.com/embed/avatars/0.png",
                embeds = {embed}
            }
            
            HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
        end)
    end)
end

--//////////////////////////////////////////////////////////////////
--//                    KEYAUTH FUNCTIONS                         //
--//////////////////////////////////////////////////////////////////
local function KeyAuthInit()
    local url = KeyAuth.Endpoint .. "?name=" .. EncodeURL(KeyAuth.Name) .. "&ownerid=" .. EncodeURL(KeyAuth.OwnerId) .. "&type=init&ver=" .. EncodeURL(KeyAuth.Version)
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return false, "Connection failed" end
    local success2, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not success2 or not data then return false, "Invalid response" end
    if data.success then
        KeyAuth.SessionId = data.sessionid
        return true, data.sessionid
    end
    return false, data.message or "Init failed"
end

local function KeyAuthLicense(key)
    if not key or key:gsub("%s", "") == "" then return false, "No key entered" end
    local url = KeyAuth.Endpoint .. "?name=" .. EncodeURL(KeyAuth.Name) .. "&ownerid=" .. EncodeURL(KeyAuth.OwnerId) .. "&type=license&key=" .. EncodeURL(key) .. "&ver=" .. EncodeURL(KeyAuth.Version) .. "&sessionid=" .. EncodeURL(KeyAuth.SessionId)
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return false, "Connection failed" end
    local success2, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not success2 or not data then return false, "Invalid response" end
    if data.success then
        UserData = data
        Authed = true
        SendWebhook("Logs", {type = "auth", success = true, key = key, username = data.info and data.info.username})
        return true, data
    end
    SendWebhook("Logs", {type = "auth", success = false, key = key, message = data.message})
    return false, data.message or "Invalid key"
end

--//////////////////////////////////////////////////////////////////
--//                      UI SELECTION                            //
--//////////////////////////////////////////////////////////////////
local UI = {
    Selected = "Rayfield",
    Custom = {
        ScreenGui = nil,
        MainFrame = nil,
        Dragging = {false, nil, nil, nil},
        Open = true,
        ToggleKey = Enum.KeyCode.RightShift
    }
}

local function CreateCustomUI()
    if UI.Custom.ScreenGui then pcall(function() UI.Custom.ScreenGui:Destroy() end) end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "UnnamedXDHub_UI"
    sg.Parent = CoreGui
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 9999
    sg.IgnoreGuiInset = true
    UI.Custom.ScreenGui = sg
    
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 450, 0, 550)
    main.Position = UDim2.new(0.5, -225, 0.5, -275)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg
    UI.Custom.MainFrame = main
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(45, 45, 55)
    stroke.Parent = main
    
    local titlebar = Instance.new("Frame")
    titlebar.Size = UDim2.new(1, 0, 0, 45)
    titlebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    titlebar.BorderSizePixel = 0
    titlebar.Parent = main
    
    local titlecorner = Instance.new("UICorner")
    titlecorner.CornerRadius = UDim.new(0, 10)
    titlecorner.Parent = titlebar
    
    local titletext = Instance.new("TextLabel")
    titletext.Size = UDim2.new(1, -50, 1, 0)
    titletext.Position = UDim2.new(0, 15, 0, 0)
    titletext.BackgroundTransparency = 1
    titletext.Text = "Unnamed XD Hub | " .. GameData.Current
    titletext.TextColor3 = Color3.fromRGB(255, 255, 255)
    titletext.TextSize = 18
    titletext.TextXAlignment = Enum.TextXAlignment.Left
    titletext.Font = Enum.Font.GothamBold
    titletext.Parent = titlebar
    
    local closebtn = Instance.new("TextButton")
    closebtn.Size = UDim2.new(0, 30, 0, 30)
    closebtn.Position = UDim2.new(1, -40, 0, 7.5)
    closebtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
    closebtn.BorderSizePixel = 0
    closebtn.Text = "X"
    closebtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closebtn.TextSize = 18
    closebtn.Font = Enum.Font.GothamBold
    closebtn.Parent = titlebar
    closebtn.MouseButton1Click:Connect(function() sg.Enabled = not sg.Enabled end)
    
    local closecorner = Instance.new("UICorner")
    closecorner.CornerRadius = UDim.new(0, 6)
    closecorner.Parent = closebtn
    
    local tabholder = Instance.new("Frame")
    tabholder.Size = UDim2.new(1, 0, 0, 45)
    tabholder.Position = UDim2.new(0, 0, 0, 45)
    tabholder.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    tabholder.BorderSizePixel = 0
    tabholder.Parent = main
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 1, -110)
    container.Position = UDim2.new(0, 10, 0, 100)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    container.BorderSizePixel = 0
    container.Parent = main
    
    local containercorner = Instance.new("UICorner")
    containercorner.CornerRadius = UDim.new(0, 8)
    containercorner.Parent = container
    
    local tabs = {
        {Name = "Combat", Color = Color3.fromRGB(65, 105, 225)},
        {Name = "Movement", Color = Color3.fromRGB(80, 200, 120)},
        {Name = "Visuals", Color = Color3.fromRGB(255, 170, 70)},
        {Name = "World", Color = Color3.fromRGB(170, 120, 255)},
        {Name = "Misc", Color = Color3.fromRGB(255, 100, 100)}
    }
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tab.Name .. "Tab"
        btn.Size = UDim2.new(0, 85, 0, 35)
        btn.Position = UDim2.new(0, 5 + ((i-1) * 90), 0, 5)
        btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
        btn.BorderSizePixel = 0
        btn.Text = tab.Name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 15
        btn.Font = Enum.Font.Gotham
        btn.Parent = tabholder
        
        local btncorner = Instance.new("UICorner")
        btncorner.CornerRadius = UDim.new(0, 6)
        btncorner.Parent = btn
        
        local content = Instance.new("ScrollingFrame")
        content.Name = tab.Name .. "Content"
        content.Size = UDim2.new(1, -20, 1, -20)
        content.Position = UDim2.new(0, 10, 0, 10)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = Color3.fromRGB(65, 105, 225)
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.Visible = i == 1
        content.Parent = container
        
        btn.MouseButton1Click:Connect(function()
            for _, c in pairs(container:GetChildren()) do
                if c:IsA("ScrollingFrame") then c.Visible = false end
            end
            content.Visible = true
            for _, b in pairs(tabholder:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
                    b.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            btn.BackgroundColor3 = tab.Color
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
    
    UI.Custom.ToggleKey = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == UI.Custom.ToggleKey then
            sg.Enabled = not sg.Enabled
        end
    end)
    
    return sg
end

--//////////////////////////////////////////////////////////////////
--//                    SETTINGS TABLE                            //
--//////////////////////////////////////////////////////////////////
local Settings = {
    Combat = {
        SilentAim = {Enabled = false, HitPart = "Head", FOV = 90, Prediction = 0.165, TeamCheck = true, WallCheck = true, ShowFOV = false},
        Aimlock = {Enabled = false, Smoothness = 5, TargetPart = "Head", Key = Enum.UserInputType.MouseButton2, Holding = false},
        Triggerbot = {Enabled = false, Delay = 0.05, IgnoreFriends = true},
        Hitbox = {Enabled = false, Size = 2.5, Transparency = 0.7, TeamCheck = true, Color = Color3.fromRGB(255, 0, 0)},
        InfiniteAmmo = {Enabled = false},
        NoRecoil = {Enabled = false},
        NoSpread = {Enabled = false},
        RapidFire = {Enabled = false},
        InstantReload = {Enabled = false},
        DamageMultiplier = {Enabled = false, Value = 1},
        AutoShoot = {Enabled = false},
        Wallbang = {Enabled = false}
    },
    Movement = {
        Fly = {Enabled = false, Speed = 50, MobileJoystick = false},
        Noclip = {Enabled = false},
        Speed = {Enabled = false, Amount = 32},
        Jump = {Enabled = false, Amount = 75},
        InfiniteJump = {Enabled = false},
        AirJump = {Enabled = false},
        Float = {Enabled = false},
        AntiFall = {Enabled = false},
        Spinbot = {Enabled = false, Speed = 10},
        BHop = {Enabled = false}
    },
    Visuals = {
        ESP = {
            Enabled = false, Box = true, BoxColor = Color3.fromRGB(255, 100, 100), BoxOutline = true,
            Name = true, NameColor = Color3.fromRGB(255, 255, 255),
            Health = true, HealthColor = Color3.fromRGB(100, 255, 100),
            Distance = true, DistanceColor = Color3.fromRGB(200, 200, 200),
            Tracer = false, TracerColor = Color3.fromRGB(255, 255, 255),
            HeadDot = false, HeadDotColor = Color3.fromRGB(255, 0, 0),
            Weapon = true, WeaponColor = Color3.fromRGB(255, 255, 0),
            Skeleton = false, SkeletonColor = Color3.fromRGB(255, 255, 255),
            Chams = false, ChamsColor = Color3.fromRGB(0, 255, 255),
            Glow = false, GlowColor = Color3.fromRGB(0, 255, 255)
        },
        HitboxVisual = {Enabled = false, Color = Color3.fromRGB(255, 0, 0), Transparency = 0.5},
        BulletTracers = {Enabled = false, Color = Color3.fromRGB(255, 255, 0)},
        Crosshair = {Enabled = false, Color = Color3.fromRGB(255, 255, 255), Size = 10, Gap = 5}
    },
    World = {
        FullBright = {Enabled = false},
        NoFog = {Enabled = false},
        NoShadows = {Enabled = false},
        Ambient = {Enabled = false, Color = Color3.fromRGB(127, 127, 127)},
        Sky = {Enabled = false, ID = 0},
        Time = {Enabled = false, Hour = 12},
        Water = {Enabled = false, Transparency = 0.5},
        AntiLag = {Enabled = false}
    },
    Misc = {
        GodMode = {Enabled = false},
        AntiAfk = {Enabled = false},
        AutoFarm = {Enabled = false},
        AutoCollect = {Enabled = false},
        NoFallDamage = {Enabled = false},
        NoClipThroughWalls = {Enabled = false},
        AlwaysDay = {Enabled = false},
        AlwaysClear = {Enabled = false},
        ForceField = {Enabled = false},
        AntiVoid = {Enabled = false}
    }
}

--//////////////////////////////////////////////////////////////////
--//                      SILENT AIM HOOK                         //
--//////////////////////////////////////////////////////////////////
local SilentAimHook
SilentAimHook = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if Settings.Combat.SilentAim.Enabled and method == Offsets.SilentAimHook and self:IsA("Camera") then
        local target = nil
        local closest = Settings.Combat.SilentAim.FOV
        local mousePos = UserInputService:GetMouseLocation()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.Combat.SilentAim.HitPart) then
                if not Settings.Combat.SilentAim.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local part = player.Character[Settings.Combat.SilentAim.HitPart]
                    if Settings.Combat.SilentAim.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                        local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                        if hit and not hit:IsDescendantOf(player.Character) then goto continue end
                    end
                    local screen, onScreen = Camera:WorldToViewportPoint(part.Position + (part.Velocity * Settings.Combat.SilentAim.Prediction))
                    if onScreen then
                        local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
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
            local pos = target.Position + (target.Velocity * Settings.Combat.SilentAim.Prediction)
            return {pos}, pos, Vector3.new(), Enum.Material.SmoothPlastic
        end
    end
    return SilentAimHook(self, ...)
end)

--//////////////////////////////////////////////////////////////////
--//                    INDEX HOOK (GUN MODS)                     //
--//////////////////////////////////////////////////////////////////
local IndexHook
IndexHook = hookmetamethod(game, "__index", function(self, key)
    if Settings.Combat.NoRecoil.Enabled then
        if self:IsA("LocalScript") and tostring(key):match(Offsets.Recoil) then return 0 end
        if self:IsA("NumberValue") and self.Name:match(Offsets.Recoil) and key == "Value" then return 0 end
    end
    if Settings.Combat.NoSpread.Enabled then
        if self:IsA("LocalScript") and tostring(key):match(Offsets.Spread) then return 0 end
        if self:IsA("NumberValue") and self.Name:match(Offsets.Spread) and key == "Value" then return 0 end
    end
    if Settings.Combat.RapidFire.Enabled then
        if self:IsA("LocalScript") and tostring(key):match(Offsets.FireRate) then return 0.01 end
        if self:IsA("NumberValue") and self.Name:match(Offsets.FireRate) and key == "Value" then return 0.01 end
    end
    if Settings.Combat.InfiniteAmmo.Enabled and self:IsA("IntValue") and self.Name == Offsets.Ammo and key == "Value" then
        return 999
    end
    if Settings.Combat.InstantReload.Enabled and self:IsA("NumberValue") and self.Name == Offsets.Reload and key == "Value" then
        return 0.01
    end
    if Settings.Combat.DamageMultiplier.Enabled and self:IsA("NumberValue") and self.Name == Offsets.Damage and key == "Value" then
        return IndexHook(self, key) * Settings.Combat.DamageMultiplier.Value
    end
    if Settings.Misc.GodMode.Enabled and self:IsA("IntValue") and self.Name == "Health" and key == "Value" then
        return 100
    end
    return IndexHook(self, key)
end)

--//////////////////////////////////////////////////////////////////
--//                      FOV CIRCLE                              //
--//////////////////////////////////////////////////////////////////
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.Combat.SilentAim.FOV
FOVCircle.Color = Color3.fromRGB(255, 100, 100)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Transparency = 0.7

--//////////////////////////////////////////////////////////////////
--//                      FLY SYSTEM                              //
--//////////////////////////////////////////////////////////////////
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
    FlyBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    FlyBodyGyro.CFrame = root.CFrame
    FlyBodyGyro.Parent = root
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    FlyBodyVelocity.Parent = root
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Movement.Fly.Enabled or not char or not root then return end
        local move = Vector3.new(0, 0, 0)
        local cf = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        if UserInputService.TouchEnabled and Settings.Movement.Fly.MobileJoystick then
            local touches = UserInputService:GetTouchInputs()
            if #touches > 0 then
                local touch = touches[#touches]
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local diff = touch.Position - center
                if diff.X > 50 then move = move + cf.RightVector end
                if diff.X < -50 then move = move - cf.RightVector end
                if diff.Y > 50 then move = move - cf.LookVector end
                if diff.Y < -50 then move = move + cf.LookVector end
            end
        end
        FlyBodyVelocity.Velocity = move * Settings.Movement.Fly.Speed
        FlyBodyGyro.CFrame = cf
    end)
end

local function StopFly()
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root then
            if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
        end
        if hum then hum.PlatformStand = false end
    end
end

--//////////////////////////////////////////////////////////////////
--//                      NOCLIP / SPEED / JUMP                   //
--//////////////////////////////////////////////////////////////////
RunService.Stepped:Connect(function()
    if Settings.Movement.Noclip.Enabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    if Settings.Movement.Speed.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Movement.Speed.Amount
    end
    if Settings.Movement.Jump.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Settings.Movement.Jump.Amount
    end
end)

--//////////////////////////////////////////////////////////////////
--//                      INFINITE JUMP                           //
--//////////////////////////////////////////////////////////////////
UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfiniteJump.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--//////////////////////////////////////////////////////////////////
--//                      HITBOX EXPANDER                         //
--//////////////////////////////////////////////////////////////////
local HitboxHighlights = {}

local function CreateHitbox(player)
    if player == LocalPlayer then return end
    if HitboxHighlights[player] then pcall(function() HitboxHighlights[player]:Destroy() end) end
    local highlight = Instance.new("Highlight")
    highlight.Name = "XDHub_Hitbox"
    highlight.Adornee = player.Character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Settings.Combat.Hitbox.Color
    highlight.FillTransparency = Settings.Combat.Hitbox.Transparency
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = CoreGui
    HitboxHighlights[player] = highlight
end

local function RemoveHitbox(player)
    if HitboxHighlights[player] then pcall(function() HitboxHighlights[player]:Destroy() end) HitboxHighlights[player] = nil end
end

local function UpdateHitboxes()
    if not Settings.Combat.Hitbox.Enabled then
        for p,_ in pairs(HitboxHighlights) do RemoveHitbox(p) end
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not Settings.Combat.Hitbox.TeamCheck or p.Team ~= LocalPlayer.Team then
                if not HitboxHighlights[p] then
                    CreateHitbox(p)
                else
                    local h = HitboxHighlights[p]
                    h.FillColor = Settings.Combat.Hitbox.Color
                    h.FillTransparency = Settings.Combat.Hitbox.Transparency
                    h.Adornee = p.Character
                end
            else
                RemoveHitbox(p)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.Combat.Hitbox.Enabled and (not Settings.Combat.Hitbox.TeamCheck or p.Team ~= LocalPlayer.Team) then
            CreateHitbox(p)
        end
    end)
end)
Players.PlayerRemoving:Connect(RemoveHitbox)

--//////////////////////////////////////////////////////////////////
--//                      ESP SYSTEM                              //
--//////////////////////////////////////////////////////////////////
local ESPObjects = {}
local SkeletonJoints = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local function CreateESP(p)
    if p == LocalPlayer then return end
    local o = {}
    o.Box = Drawing.new("Square"); o.Box.Visible = false; o.Box.Color = Settings.Visuals.ESP.BoxColor; o.Box.Thickness = 1.5; o.Box.Filled = false
    o.BoxOutline = Drawing.new("Square"); o.BoxOutline.Visible = false; o.BoxOutline.Color = Color3.fromRGB(0,0,0); o.BoxOutline.Thickness = 3; o.BoxOutline.Filled = false
    o.Name = Drawing.new("Text"); o.Name.Visible = false; o.Name.Color = Settings.Visuals.ESP.NameColor; o.Name.Size = 16; o.Name.Center = true; o.Name.Outline = true
    o.Health = Drawing.new("Text"); o.Health.Visible = false; o.Health.Color = Settings.Visuals.ESP.HealthColor; o.Health.Size = 14; o.Health.Center = true; o.Health.Outline = true
    o.Distance = Drawing.new("Text"); o.Distance.Visible = false; o.Distance.Color = Settings.Visuals.ESP.DistanceColor; o.Distance.Size = 12; o.Distance.Center = true; o.Distance.Outline = true
    o.Tracer = Drawing.new("Line"); o.Tracer.Visible = false; o.Tracer.Color = Settings.Visuals.ESP.TracerColor; o.Tracer.Thickness = 1.5
    o.HeadDot = Drawing.new("Circle"); o.HeadDot.Visible = false; o.HeadDot.Color = Settings.Visuals.ESP.HeadDotColor; o.HeadDot.Radius = 4; o.HeadDot.Filled = true; o.HeadDot.NumSides = 16
    o.Weapon = Drawing.new("Text"); o.Weapon.Visible = false; o.Weapon.Color = Settings.Visuals.ESP.WeaponColor; o.Weapon.Size = 12; o.Weapon.Center = true; o.Weapon.Outline = true
    o.Skeleton = {}
    for i = 1, 15 do local line = Drawing.new("Line"); line.Visible = false; line.Color = Settings.Visuals.ESP.SkeletonColor; line.Thickness = 1.5; table.insert(o.Skeleton, line) end
    ESPObjects[p] = o
end

local function UpdateESP()
    if not Settings.Visuals.ESP.Enabled then
        for p, o in pairs(ESPObjects) do
            for _, obj in pairs(o) do
                if type(obj) == "table" then for _, l in pairs(obj) do l.Visible = false end
                elseif obj.Visible ~= nil then obj.Visible = false end
            end
        end
        return
    end
    for p, o in pairs(ESPObjects) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character.Humanoid
            local head = p.Character:FindFirstChild("Head")
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if onScreen then
                local scale = 1 / (pos.Z * 0.1)
                local w = math.clamp(35 * scale, 25, 80)
                local h = math.clamp(60 * scale, 40, 140)
                local boxPos = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                local boxColor = p.Team == LocalPlayer.Team and Color3.fromRGB(100,255,100) or Settings.Visuals.ESP.BoxColor
                if Settings.Visuals.ESP.Box and Settings.Visuals.ESP.BoxOutline then
                    o.BoxOutline.Visible = true
                    o.BoxOutline.Position = boxPos - Vector2.new(1,1)
                    o.BoxOutline.Size = Vector2.new(w+2, h+2)
                else o.BoxOutline.Visible = false end
                if Settings.Visuals.ESP.Box then
                    o.Box.Visible = true
                    o.Box.Position = boxPos
                    o.Box.Size = Vector2.new(w, h)
                    o.Box.Color = boxColor
                else o.Box.Visible = false end
                if Settings.Visuals.ESP.Name then
                    o.Name.Visible = true
                    o.Name.Position = Vector2.new(pos.X, boxPos.Y - 20)
                    o.Name.Text = p.Name
                    o.Name.Color = Settings.Visuals.ESP.NameColor
                else o.Name.Visible = false end
                if Settings.Visuals.ESP.Health and hum then
                    o.Health.Visible = true
                    o.Health.Position = Vector2.new(pos.X, boxPos.Y + h + 5)
                    o.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    o.Health.Color = Settings.Visuals.ESP.HealthColor
                else o.Health.Visible = false end
                if Settings.Visuals.ESP.Distance then
                    o.Distance.Visible = true
                    o.Distance.Position = Vector2.new(pos.X, boxPos.Y + h + 25)
                    o.Distance.Text = math.floor(dist) .. "s"
                    o.Distance.Color = Settings.Visuals.ESP.DistanceColor
                else o.Distance.Visible = false end
                if Settings.Visuals.ESP.Tracer then
                    o.Tracer.Visible = true
                    o.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    o.Tracer.To = Vector2.new(pos.X, pos.Y)
                    o.Tracer.Color = Settings.Visuals.ESP.TracerColor
                else o.Tracer.Visible = false end
                if Settings.Visuals.ESP.HeadDot and head then
                    o.HeadDot.Visible = true
                    o.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                    o.HeadDot.Color = Settings.Visuals.ESP.HeadDotColor
                else o.HeadDot.Visible = false end
                if Settings.Visuals.ESP.Weapon then
                    o.Weapon.Visible = true
                    o.Weapon.Position = Vector2.new(pos.X, boxPos.Y - 40)
                    local tool = p.Character:FindFirstChildOfClass("Tool")
                    o.Weapon.Text = tool and tool.Name or "None"
                    o.Weapon.Color = Settings.Visuals.ESP.WeaponColor
                else o.Weapon.Visible = false end
                if Settings.Visuals.ESP.Skeleton then
                    for i, joints in ipairs(SkeletonJoints) do
                        local p1 = p.Character:FindFirstChild(joints[1])
                        local p2 = p.Character:FindFirstChild(joints[2])
                        if p1 and p2 then
                            local pos1, v1 = Camera:WorldToViewportPoint(p1.Position)
                            local pos2, v2 = Camera:WorldToViewportPoint(p2.Position)
                            if v1 and v2 then
                                o.Skeleton[i].Visible = true
                                o.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                o.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                o.Skeleton[i].Color = Settings.Visuals.ESP.SkeletonColor
                            else o.Skeleton[i].Visible = false end
                        else o.Skeleton[i].Visible = false end
                    end
                else for _, l in pairs(o.Skeleton) do l.Visible = false end end
            else
                o.Box.Visible = false; o.BoxOutline.Visible = false; o.Name.Visible = false; o.Health.Visible = false
                o.Distance.Visible = false; o.Tracer.Visible = false; o.HeadDot.Visible = false; o.Weapon.Visible = false
                for _, l in pairs(o.Skeleton) do l.Visible = false end
            end
        else
            o.Box.Visible = false; o.BoxOutline.Visible = false; o.Name.Visible = false; o.Health.Visible = false
            o.Distance.Visible = false; o.Tracer.Visible = false; o.HeadDot.Visible = false; o.Weapon.Visible = false
            for _, l in pairs(o.Skeleton) do l.Visible = false end
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        for _, obj in pairs(ESPObjects[p]) do
            if type(obj) == "table" then for _, l in pairs(obj) do pcall(function() l:Remove() end) end
            else pcall(function() obj:Remove() end) end
        end
        ESPObjects[p] = nil
    end
end)
RunService.RenderStepped:Connect(UpdateESP)

--//////////////////////////////////////////////////////////////////
--//                      WORLD VISUALS                           //
--//////////////////////////////////////////////////////////////////
local OriginalBrightness = Lighting.Brightness
local OriginalFogEnd = Lighting.FogEnd
local OriginalGlobalShadows = Lighting.GlobalShadows
local OriginalAmbient = Lighting.Ambient
local OriginalColorShiftBottom = Lighting.ColorShift_Bottom
local OriginalColorShiftTop = Lighting.ColorShift_Top

local function UpdateWorld()
    if Settings.World.FullBright.Enabled then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.ColorShift_Bottom = Color3.fromRGB(255,255,255)
        Lighting.ColorShift_Top = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = OriginalBrightness
        Lighting.GlobalShadows = OriginalGlobalShadows
        Lighting.Ambient = OriginalAmbient
        Lighting.ColorShift_Bottom = OriginalColorShiftBottom
        Lighting.ColorShift_Top = OriginalColorShiftTop
    end
    if Settings.World.NoFog.Enabled then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = OriginalFogEnd
    end
    if Settings.World.NoShadows.Enabled then
        Lighting.GlobalShadows = false
    elseif not Settings.World.FullBright.Enabled then
        Lighting.GlobalShadows = OriginalGlobalShadows
    end
    if Settings.World.Ambient.Enabled then
        Lighting.Ambient = Settings.World.Ambient.Color
    end
    if Settings.World.Time.Enabled then
        Lighting.ClockTime = Settings.World.Time.Hour
    end
end

--//////////////////////////////////////////////////////////////////
--//                      AIMLOCK / INPUT                         //
--//////////////////////////////////////////////////////////////////
UserInputService.InputBegan:Connect(function(i)
    if Settings.Combat.Aimlock.Enabled and (i.UserInputType == Settings.Combat.Aimlock.Key or i.KeyCode == Enum.KeyCode[tostring(Settings.Combat.Aimlock.Key)]) then
        Settings.Combat.Aimlock.Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Settings.Combat.Aimlock.Key or i.KeyCode == Enum.KeyCode[tostring(Settings.Combat.Aimlock.Key)] then
        Settings.Combat.Aimlock.Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Combat.SilentAim.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.Combat.SilentAim.FOV
    else FOVCircle.Visible = false end
    if Settings.Combat.Aimlock.Enabled and Settings.Combat.Aimlock.Holding then
        local target = nil
        local closest = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.Combat.Aimlock.TargetPart) then
                if not Settings.Combat.SilentAim.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local part = p.Character[Settings.Combat.Aimlock.TargetPart]
                    local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screen.X, screen.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < closest then closest = dist; target = part end
                    end
                end
            end
        end
        if target then
            local current = Camera.CFrame.LookVector
            local targetDir = (target.Position - Camera.CFrame.Position).Unit
            local smooth = current:Lerp(targetDir, 1 / Settings.Combat.Aimlock.Smoothness)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + smooth)
        end
    end
end)

--//////////////////////////////////////////////////////////////////
--//                      TRIGGERBOT                              //
--//////////////////////////////////////////////////////////////////
task.spawn(function()
    while task.wait() do
        if Settings.Combat.Triggerbot.Enabled then
            local target = Mouse.Target
            if target then
                local char = target.Parent
                if char and char:FindFirstChild("Humanoid") then
                    local p = Players:GetPlayerFromCharacter(char)
                    if p and p ~= LocalPlayer then
                        if not Settings.Combat.SilentAim.TeamCheck or p.Team ~= LocalPlayer.Team then
                            task.wait(Settings.Combat.Triggerbot.Delay)
                            mouse1click()
                        end
                    end
                end
            end
        end
    end
end)

--//////////////////////////////////////////////////////////////////
--//                      ANTI AFK                                //
--//////////////////////////////////////////////////////////////////
if Settings.Misc.AntiAfk.Enabled then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

--//////////////////////////////////////////////////////////////////
--//                      RESPAWN HANDLER                         //
--//////////////////////////////////////////////////////////////////
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.Movement.Fly.Enabled then StopFly(); task.wait(0.1); StartFly() end
    if Settings.Combat.Hitbox.Enabled then UpdateHitboxes() end
end)

--//////////////////////////////////////////////////////////////////
--//                      KEYAUTH INIT                            //
--//////////////////////////////////////////////////////////////////
local initSuccess, initMsg = KeyAuthInit()
if not initSuccess then
    LocalPlayer:Kick("KeyAuth Error: " .. tostring(initMsg))
    return
end

--//////////////////////////////////////////////////////////////////
--//                      UI SELECTION DIALOG                     //
--//////////////////////////////////////////////////////////////////
local SelectionGui = Instance.new("ScreenGui")
SelectionGui.Name = "XDHub_UI_Selector"
SelectionGui.Parent = CoreGui
SelectionGui.ResetOnSpawn = false
SelectionGui.DisplayOrder = 10000

local SelectionFrame = Instance.new("Frame")
SelectionFrame.Size = UDim2.new(0, 400, 0, 250)
SelectionFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Active = true
SelectionFrame.Draggable = true
SelectionFrame.Parent = SelectionGui

local SelCorner = Instance.new("UICorner")
SelCorner.CornerRadius = UDim.new(0, 10)
SelCorner.Parent = SelectionFrame

local SelTitle = Instance.new("TextLabel")
SelTitle.Size = UDim2.new(1, 0, 0, 50)
SelTitle.Position = UDim2.new(0, 0, 0, 15)
SelTitle.BackgroundTransparency = 1
SelTitle.Text = "Select Your UI"
SelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SelTitle.TextSize = 24
SelTitle.Font = Enum.Font.GothamBold
SelTitle.Parent = SelectionFrame

local SelSub = Instance.new("TextLabel")
SelSub.Size = UDim2.new(1, 0, 0, 30)
SelSub.Position = UDim2.new(0, 0, 0, 65)
SelSub.BackgroundTransparency = 1
SelSub.Text = "Choose your preferred interface"
SelSub.TextColor3 = Color3.fromRGB(180, 180, 180)
SelSub.TextSize = 16
SelSub.Font = Enum.Font.Gotham
SelSub.Parent = SelectionFrame

local RayfieldBtn = Instance.new("TextButton")
RayfieldBtn.Size = UDim2.new(0.4, 0, 0, 45)
RayfieldBtn.Position = UDim2.new(0.1, 0, 0, 120)
RayfieldBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
RayfieldBtn.BorderSizePixel = 0
RayfieldBtn.Text = "Rayfield UI"
RayfieldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RayfieldBtn.TextSize = 18
RayfieldBtn.Font = Enum.Font.GothamBold
RayfieldBtn.Parent = SelectionFrame

local RayfieldCorner = Instance.new("UICorner")
RayfieldCorner.CornerRadius = UDim.new(0, 8)
RayfieldCorner.Parent = RayfieldBtn

local CustomBtn = Instance.new("TextButton")
CustomBtn.Size = UDim2.new(0.4, 0, 0, 45)
CustomBtn.Position = UDim2.new(0.5, 20, 0, 120)
CustomBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
CustomBtn.BorderSizePixel = 0
CustomBtn.Text = "Custom UI"
CustomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CustomBtn.TextSize = 18
CustomBtn.Font = Enum.Font.GothamBold
CustomBtn.Parent = SelectionFrame

local CustomCorner = Instance.new("UICorner")
CustomCorner.CornerRadius = UDim.new(0, 8)
CustomCorner.Parent = CustomBtn

local StatusSel = Instance.new("TextLabel")
StatusSel.Size = UDim2.new(1, 0, 0, 30)
StatusSel.Position = UDim2.new(0, 0, 0, 190)
StatusSel.BackgroundTransparency = 1
StatusSel.Text = "Loading KeyAuth..."
StatusSel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusSel.TextSize = 14
StatusSel.Font = Enum.Font.Gotham
StatusSel.Parent = SelectionFrame

--//////////////////////////////////////////////////////////////////
--//                      KEYAUTH UI                              //
--//////////////////////////////////////////////////////////////////
local AuthGui = Instance.new("ScreenGui")
AuthGui.Name = "XDHub_KeyAuth"
AuthGui.Parent = CoreGui
AuthGui.ResetOnSpawn = false
AuthGui.DisplayOrder = 9999
AuthGui.Enabled = false

local AuthFrame = Instance.new("Frame")
AuthFrame.Size = UDim2.new(0, 420, 0, 380)
AuthFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
AuthFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
AuthFrame.BorderSizePixel = 0
AuthFrame.Active = true
AuthFrame.Draggable = true
AuthFrame.Parent = AuthGui

local AuthCorner = Instance.new("UICorner")
AuthCorner.CornerRadius = UDim.new(0, 10)
AuthCorner.Parent = AuthFrame

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 60)
AuthTitle.Position = UDim2.new(0, 0, 0, 20)
AuthTitle.BackgroundTransparency = 1
AuthTitle.Text = "Unnamed XD Hub"
AuthTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthTitle.TextSize = 28
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.Parent = AuthFrame

local AuthSub = Instance.new("TextLabel")
AuthSub.Size = UDim2.new(1, 0, 0, 30)
AuthSub.Position = UDim2.new(0, 0, 0, 80)
AuthSub.BackgroundTransparency = 1
AuthSub.Text = "🔐 Verified Services & Keyauth.cc"
AuthSub.TextColor3 = Color3.fromRGB(180, 180, 180)
AuthSub.TextSize = 15
AuthSub.Font = Enum.Font.Gotham
AuthSub.Parent = AuthFrame

local AuthInput = Instance.new("TextBox")
AuthInput.Size = UDim2.new(0.85, 0, 0, 55)
AuthInput.Position = UDim2.new(0.5, -175, 0, 140)
AuthInput.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
AuthInput.BorderSizePixel = 0
AuthInput.PlaceholderText = "Enter License Key"
AuthInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
AuthInput.Text = ""
AuthInput.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthInput.TextSize = 18
AuthInput.Font = Enum.Font.Gotham
AuthInput.ClearTextOnFocus = false
AuthInput.Parent = AuthFrame

local AuthInputCorner = Instance.new("UICorner")
AuthInputCorner.CornerRadius = UDim.new(0, 8)
AuthInputCorner.Parent = AuthInput

local AuthButton = Instance.new("TextButton")
AuthButton.Size = UDim2.new(0.85, 0, 0, 55)
AuthButton.Position = UDim2.new(0.5, -175, 0, 210)
AuthButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
AuthButton.BorderSizePixel = 0
AuthButton.Text = "LOGIN"
AuthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthButton.TextSize = 20
AuthButton.Font = Enum.Font.GothamBold
AuthButton.Parent = AuthFrame

local AuthBtnCorner = Instance.new("UICorner")
AuthBtnCorner.CornerRadius = UDim.new(0, 8)
AuthBtnCorner.Parent = AuthButton

local AuthStatus = Instance.new("TextLabel")
AuthStatus.Size = UDim2.new(1, 0, 0, 30)
AuthStatus.Position = UDim2.new(0, 0, 0, 280)
AuthStatus.BackgroundTransparency = 1
AuthStatus.Text = "Initializing..."
AuthStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
AuthStatus.TextSize = 14
AuthStatus.Font = Enum.Font.Gotham
AuthStatus.Parent = AuthFrame

local AuthHwid = Instance.new("TextLabel")
AuthHwid.Size = UDim2.new(0.85, 0, 0, 30)
AuthHwid.Position = UDim2.new(0.5, -175, 0, 330)
AuthHwid.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
AuthHwid.BorderSizePixel = 0
AuthHwid.Text = "HWID: " .. HWID
AuthHwid.TextColor3 = Color3.fromRGB(140, 140, 150)
AuthHwid.TextSize = 12
AuthHwid.Font = Enum.Font.Gotham
AuthHwid.Parent = AuthFrame

local AuthHwidCorner = Instance.new("UICorner")
AuthHwidCorner.CornerRadius = UDim.new(0, 6)
AuthHwidCorner.Parent = AuthHwid

local function UpdateAuthStatus(text, isError)
    AuthStatus.Text = text
    if isError == true then AuthStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif isError == false then AuthStatus.TextColor3 = Color3.fromRGB(80, 255, 80)
    else AuthStatus.TextColor3 = Color3.fromRGB(255, 200, 0) end
end

--//////////////////////////////////////////////////////////////////
--//                      UI SELECTION LOGIC                      //
--//////////////////////////////////////////////////////////////////
RayfieldBtn.MouseButton1Click:Connect(function()
    SelectedUI = "Rayfield"
    SelectionGui:Destroy()
    AuthGui.Enabled = true
    UpdateAuthStatus("Connected - Enter your key", nil)
end)

CustomBtn.MouseButton1Click:Connect(function()
    SelectedUI = "Custom"
    SelectionGui:Destroy()
    AuthGui.Enabled = true
    UpdateAuthStatus("Connected - Enter your key", nil)
end)

--//////////////////////////////////////////////////////////////////
--//                      KEYAUTH LOGIC                           //
--//////////////////////////////////////////////////////////////////
AuthButton.MouseButton1Click:Connect(function()
    local key = AuthInput.Text:gsub("%s", "")
    if key == "" then
        UpdateAuthStatus("Please enter a key", true)
        return
    end
    UpdateAuthStatus("Verifying...", nil)
    AuthButton.Text = "..."
    AuthButton.Active = false
    task.spawn(function()
        local success, result = KeyAuthLicense(key)
        if success then
            UpdateAuthStatus("Verified! Loading...", false)
            AuthButton.Text = "✓"
            task.wait(0.8)
            AuthGui:Destroy()
            Authed = true
        else
            UpdateAuthStatus(tostring(result), true)
            AuthButton.Text = "LOGIN"
            AuthButton.Active = true
        end
    end)
end)

AuthInput.FocusLost:Connect(function(enter)
    if enter then AuthButton.MouseButton1Click:Fire() end
end)

while not Authed do task.wait() end
task.wait(0.5)

--//////////////////////////////////////////////////////////////////
--//                      LOAD SELECTED UI                        //
--//////////////////////////////////////////////////////////////////
SendWebhook("Logs", {type = "execute", key = "Authenticated"})

if SelectedUI == "Rayfield" then
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    local Window = Rayfield:CreateWindow({
        Name = "Unnamed XD Hub | " .. GameData.Current,
        LoadingTitle = "Unnamed XD Hub",
        LoadingSubtitle = "by @mqp6 / Poc",
        ConfigurationSaving = {Enabled = true, FolderName = "UnnamedXDHub", FileName = "Config"},
        Discord = {Enabled = true, Invite = "rmpQfYtnWd", RememberJoins = true},
        KeySystem = false
    })
    
    local TabCombat = Window:CreateTab("Combat", 4483362458)
    local TabMovement = Window:CreateTab("Movement", 4483362458)
    local TabVisuals = Window:CreateTab("Visuals", 4483362458)
    local TabWorld = Window:CreateTab("World", 4483362458)
    local TabMisc = Window:CreateTab("Misc", 4483362458)
    local TabInfo = Window:CreateTab("Info", 4483362458)
    
    TabCombat:CreateSection("Silent Aim")
    TabCombat:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Combat.SilentAim.Enabled = v end})
    TabCombat:CreateDropdown({Name = "Hitbox", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) Settings.Combat.SilentAim.HitPart = v[1] end})
    TabCombat:CreateSlider({Name = "FOV", Range = {30,200}, Increment = 5, CurrentValue = 90, Callback = function(v) Settings.Combat.SilentAim.FOV = v end})
    TabCombat:CreateSlider({Name = "Prediction", Range = {0,300}, Increment = 5, CurrentValue = 165, Callback = function(v) Settings.Combat.SilentAim.Prediction = v / 1000 end})
    TabCombat:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Settings.Combat.SilentAim.TeamCheck = v end})
    TabCombat:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) Settings.Combat.SilentAim.WallCheck = v end})
    TabCombat:CreateToggle({Name = "Show FOV", CurrentValue = false, Callback = function(v) Settings.Combat.SilentAim.ShowFOV = v end})
    
    TabCombat:CreateSection("Aimlock")
    TabCombat:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Combat.Aimlock.Enabled = v end})
    TabCombat:CreateSlider({Name = "Smoothness", Range = {1,15}, Increment = 1, CurrentValue = 5, Callback = function(v) Settings.Combat.Aimlock.Smoothness = v end})
    TabCombat:CreateDropdown({Name = "Target", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) Settings.Combat.Aimlock.TargetPart = v[1] end})
    
    TabCombat:CreateSection("Triggerbot")
    TabCombat:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Combat.Triggerbot.Enabled = v end})
    TabCombat:CreateSlider({Name = "Delay (ms)", Range = {0,200}, Increment = 10, CurrentValue = 50, Callback = function(v) Settings.Combat.Triggerbot.Delay = v / 1000 end})
    
    TabCombat:CreateSection("Hitbox")
    TabCombat:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Combat.Hitbox.Enabled = v; if v then UpdateHitboxes() else for p,_ in pairs(HitboxHighlights) do RemoveHitbox(p) end end end})
    TabCombat:CreateSlider({Name = "Size", Range = {1,5}, Increment = 0.1, CurrentValue = 2.5, Callback = function(v) Settings.Combat.Hitbox.Size = v end})
    TabCombat:CreateSlider({Name = "Transparency", Range = {0,1}, Increment = 0.1, CurrentValue = 0.7, Callback = function(v) Settings.Combat.Hitbox.Transparency = v; if Settings.Combat.Hitbox.Enabled then UpdateHitboxes() end end})
    TabCombat:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Settings.Combat.Hitbox.TeamCheck = v; if Settings.Combat.Hitbox.Enabled then UpdateHitboxes() end end})
    TabCombat:CreateColorPicker({Name = "Color", CurrentValue = Color3.fromRGB(255,0,0), Callback = function(v) Settings.Combat.Hitbox.Color = v; if Settings.Combat.Hitbox.Enabled then UpdateHitboxes() end end})
    
    TabCombat:CreateSection("Gun Mods")
    TabCombat:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(v) Settings.Combat.InfiniteAmmo.Enabled = v end})
    TabCombat:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(v) Settings.Combat.NoRecoil.Enabled = v end})
    TabCombat:CreateToggle({Name = "No Spread", CurrentValue = false, Callback = function(v) Settings.Combat.NoSpread.Enabled = v end})
    TabCombat:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) Settings.Combat.RapidFire.Enabled = v end})
    TabCombat:CreateToggle({Name = "Instant Reload", CurrentValue = false, Callback = function(v) Settings.Combat.InstantReload.Enabled = v end})
    TabCombat:CreateToggle({Name = "Damage Multiplier", CurrentValue = false, Callback = function(v) Settings.Combat.DamageMultiplier.Enabled = v end})
    TabCombat:CreateSlider({Name = "Damage Amount", Range = {1,10}, Increment = 1, CurrentValue = 1, Callback = function(v) Settings.Combat.DamageMultiplier.Value = v end})
    
    TabMovement:CreateSection("Fly")
    TabMovement:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Movement.Fly.Enabled = v; if v then StartFly() else StopFly() end end})
    TabMovement:CreateSlider({Name = "Speed", Range = {10,150}, Increment = 5, CurrentValue = 50, Callback = function(v) Settings.Movement.Fly.Speed = v end})
    TabMovement:CreateToggle({Name = "Mobile Joystick", CurrentValue = false, Callback = function(v) Settings.Movement.Fly.MobileJoystick = v end})
    
    TabMovement:CreateSection("Movement")
    TabMovement:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Settings.Movement.Noclip.Enabled = v end})
    TabMovement:CreateToggle({Name = "Speed", CurrentValue = false, Callback = function(v) Settings.Movement.Speed.Enabled = v end})
    TabMovement:CreateSlider({Name = "Speed Amount", Range = {16,250}, Increment = 1, CurrentValue = 32, Callback = function(v) Settings.Movement.Speed.Amount = v end})
    TabMovement:CreateToggle({Name = "Jump Power", CurrentValue = false, Callback = function(v) Settings.Movement.Jump.Enabled = v end})
    TabMovement:CreateSlider({Name = "Jump Amount", Range = {50,250}, Increment = 1, CurrentValue = 75, Callback = function(v) Settings.Movement.Jump.Amount = v end})
    TabMovement:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Settings.Movement.InfiniteJump.Enabled = v end})
    
    TabVisuals:CreateSection("ESP")
    TabVisuals:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Visuals.ESP.Enabled = v end})
    TabVisuals:CreateToggle({Name = "Box", CurrentValue = true, Callback = function(v) Settings.Visuals.ESP.Box = v end})
    TabVisuals:CreateToggle({Name = "Box Outline", CurrentValue = true, Callback = function(v) Settings.Visuals.ESP.BoxOutline = v end})
    TabVisuals:CreateColorPicker({Name = "Box Color", CurrentValue = Color3.fromRGB(255,100,100), Callback = function(v) Settings.Visuals.ESP.BoxColor = v end})
    TabVisuals:CreateToggle({Name = "Name", CurrentValue = true, Callback = function(v) Settings.Visuals.ESP.Name = v end})
    TabVisuals:CreateColorPicker({Name = "Name Color", CurrentValue = Color3.fromRGB(255,255,255), Callback = function(v) Settings.Visuals.ESP.NameColor = v end})
    TabVisuals:CreateToggle({Name = "Health", CurrentValue = true, Callback = function(v) Settings.Visuals.ESP.Health = v end})
    TabVisuals:CreateColorPicker({Name = "Health Color", CurrentValue = Color3.fromRGB(100,255,100), Callback = function(v) Settings.Visuals.ESP.HealthColor = v end})
    TabVisuals:CreateToggle({Name = "Distance", CurrentValue = true, Callback = function(v) Settings.Visuals.ESP.Distance = v end})
    TabVisuals:CreateColorPicker({Name = "Distance Color", CurrentValue = Color3.fromRGB(200,200,200), Callback = function(v) Settings.Visuals.ESP.DistanceColor = v end})
    TabVisuals:CreateToggle({Name = "Weapon", CurrentValue = true, Callback = function(v) Settings.Visuals.ESP.Weapon = v end})
    TabVisuals:CreateColorPicker({Name = "Weapon Color", CurrentValue = Color3.fromRGB(255,255,0), Callback = function(v) Settings.Visuals.ESP.WeaponColor = v end})
    TabVisuals:CreateToggle({Name = "Tracer", CurrentValue = false, Callback = function(v) Settings.Visuals.ESP.Tracer = v end})
    TabVisuals:CreateColorPicker({Name = "Tracer Color", CurrentValue = Color3.fromRGB(255,255,255), Callback = function(v) Settings.Visuals.ESP.TracerColor = v end})
    TabVisuals:CreateToggle({Name = "Head Dot", CurrentValue = false, Callback = function(v) Settings.Visuals.ESP.HeadDot = v end})
    TabVisuals:CreateColorPicker({Name = "Head Dot Color", CurrentValue = Color3.fromRGB(255,0,0), Callback = function(v) Settings.Visuals.ESP.HeadDotColor = v end})
    TabVisuals:CreateToggle({Name = "Skeleton", CurrentValue = false, Callback = function(v) Settings.Visuals.ESP.Skeleton = v end})
    TabVisuals:CreateColorPicker({Name = "Skeleton Color", CurrentValue = Color3.fromRGB(255,255,255), Callback = function(v) Settings.Visuals.ESP.SkeletonColor = v end})
    
    TabWorld:CreateSection("Lighting")
    TabWorld:CreateToggle({Name = "Full Bright", CurrentValue = false, Callback = function(v) Settings.World.FullBright.Enabled = v; UpdateWorld() end})
    TabWorld:CreateToggle({Name = "No Fog", CurrentValue = false, Callback = function(v) Settings.World.NoFog.Enabled = v; UpdateWorld() end})
    TabWorld:CreateToggle({Name = "No Shadows", CurrentValue = false, Callback = function(v) Settings.World.NoShadows.Enabled = v; UpdateWorld() end})
    
    TabMisc:CreateSection("Player")
    TabMisc:CreateToggle({Name = "God Mode", CurrentValue = false, Callback = function(v) Settings.Misc.GodMode.Enabled = v end})
    TabMisc:CreateToggle({Name = "Anti AFK", CurrentValue = false, Callback = function(v) Settings.Misc.AntiAfk.Enabled = v end})
    
    TabInfo:CreateSection("Account")
    TabInfo:CreateParagraph({
        Title = "Your Information",
        Content = string.format("User: %s\nGame: %s\nHWID: %s\nMobile: %s", LocalPlayer.Name, GameData.Current, HWID:sub(1,8).."...", UserInputService.TouchEnabled and "Yes" or "No")
    })
    TabInfo:CreateSection("Unnamed XD Hub")
    TabInfo:CreateParagraph({
        Title = "About",
        Content = "Owner: @mqp6 / Poc\nVersion: 4.0.0\nDiscord: discord.gg/rmpQfYtnWd"
    })
    TabInfo:CreateButton({Name = "Copy Discord", Callback = function() if setclipboard then setclipboard("https://discord.gg/rmpQfYtnWd"); Rayfield:Notify({Title = "Copied", Content = "Discord link copied", Duration = 2}) end end})
    
    Rayfield:Notify({Title = "Unnamed XD Hub", Content = "Loaded | " .. GameData.Current, Duration = 5})
else
    CreateCustomUI()
end

SendWebhook("Logs", {type = "execute", key = "Authenticated", username = UserData and UserData.info and UserData.info.username})
