local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local PlaceId = game.PlaceId
local JobId = game.JobId
local StartTime = tick()
local SessionId = HttpService:GenerateGUID(false)
local Authed = false
local SelectedUI = "Rayfield"
local UserData = nil

local Webhooks = {
    Logs = "https://discord.com/api/webhooks/1355834963881885806/9aXZV1Mp3QFlQ38FBC4Fon4oVfcO-3cOJV4AdN1wZfWhTRaZhlZzPZ4j0WZzPZ4j0W",
    Alerts = "https://discord.com/api/webhooks/1355834963881885806/9aXZV1Mp3QFlQ38FBC4Fon4oVfcO-3cOJV4AdN1wZfWhTRaZhlZzPZ4j0WZzPZ4j0W"
}

local Polsec = {
    ApiId = "663c8b17a5da0", -- YOUR GETPOLSEC API ID
    ApiHash = "bafb8b3edfe55e35d383130d74f3a32d", -- YOUR GETPOLSEC API HASH
    ApiUrl = "https://getpolsec.com/api/v1/",
    SessionToken = "",
    UserData = nil
}

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
            Reload = "ReloadTime"
        },
        Rivals = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "CurrentAmmo",
            FireRate = "FireRate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime"
        },
        DaHood = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "Ammo",
            FireRate = "Firerate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime"
        },
        PhantomForces = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "AmmoCount",
            FireRate = "FireRate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime"
        },
        Arsenal = {
            SilentAimHook = "FindPartOnRayWithIgnoreList",
            Damage = "Damage",
            Ammo = "CurrentAmmo",
            FireRate = "FireRate",
            Recoil = "Recoil",
            Spread = "Spread",
            Reload = "ReloadTime"
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
    local s, r = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    return s and r or "HWID_ERROR_" .. HttpService:GenerateGUID(false)
end
local HWID = GetHWID()

local function GetJoinLink()
    return "https://www.roblox.com/Game/PlaceExperience?placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId
end

local function GetProfileLink(userId)
    return "https://www.roblox.com/users/" .. tostring(userId) .. "/profile"
end

local function SendWebhook(webhookType, data)
    task.spawn(function()
        pcall(function()
            local url = Webhooks[webhookType] or Webhooks.Logs
            if url == "" or not url then return end
            local uid = LocalPlayer.UserId
            local dn = LocalPlayer.DisplayName
            local un = LocalPlayer.Name
            local pl = GetProfileLink(uid)
            local jl = GetJoinLink()
            local gi = MarketplaceService:GetProductInfo(PlaceId, Enum.InfoType.Asset)
            local gn = gi and gi.Name or "Unknown"
            local embed = {
                title = webhookType == "Logs" and "✅ Execution Success" or "⚠️ Alert",
                color = webhookType == "Logs" and 5763719 or 16711680,
                fields = {
                    {name = "User", value = string.format("[%s (@%s)](%s)", dn, un, pl), inline = true},
                    {name = "User ID", value = tostring(uid), inline = true},
                    {name = "HWID", value = HWID, inline = false},
                    {name = "Game", value = string.format("%s (%d)", gn, PlaceId), inline = true},
                    {name = "Server", value = string.format("[Join](%s)", jl), inline = true},
                    {name = "Key", value = data.key or "N/A", inline = false},
                    {name = "Session", value = SessionId, inline = false},
                    {name = "Load Time", value = string.format("%.2fs", tick() - StartTime), inline = true}
                },
                footer = {text = os.date("!%Y-%m-%d %H:%M:%S UTC")},
                timestamp = DateTime.now():ToIsoDate()
            }
            if data.username then
                embed.fields[#embed.fields+1] = {name = "Polsec User", value = data.username, inline = true}
            end
            if data.expiry then
                embed.fields[#embed.fields+1] = {name = "Expiry", value = data.expiry, inline = true}
            end
            local payload = {
                username = "XD Hub Logger",
                avatar_url = "https://cdn.discordapp.com/embed/avatars/0.png",
                embeds = {embed}
            }
            HttpService:PostAsync(url, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
        end)
    end)
end

local function PolsecRequest(endpoint, data)
    local url = Polsec.ApiUrl .. endpoint
    data = data or {}
    data.api_id = Polsec.ApiId
    data.api_hash = Polsec.ApiHash
    if Polsec.SessionToken ~= "" then
        data.session_token = Polsec.SessionToken
    end
    local encoded = HttpService:JSONEncode(data)
    local s, r = pcall(function()
        return game:HttpPost(url, encoded, Enum.HttpContentType.ApplicationJson)
    end)
    if not s then
        return false, "Connection failed"
    end
    local s2, d = pcall(function()
        return HttpService:JSONDecode(r)
    end)
    if not s2 or not d then
        return false, "Invalid response"
    end
    if d.success then
        return true, d
    else
        return false, d.message or "Request failed"
    end
end

local function PolsecInit()
    local s, d = PolsecRequest("init", {
        hwid = HWID,
        place_id = PlaceId,
        job_id = JobId
    })
    if s then
        Polsec.SessionToken = d.session_token
        return true, d
    else
        return false, d
    end
end

local function PolsecLicense(key)
    local s, d = PolsecRequest("license", {
        key = key,
        hwid = HWID
    })
    if s then
        Polsec.UserData = d
        Authed = true
        UserData = {
            info = {
                username = d.username or LocalPlayer.Name,
                expiry = d.expiry or "Lifetime",
                subscription = d.plan or "Premium"
            }
        }
        SendWebhook("Logs", {
            key = key,
            username = d.username,
            expiry = d.expiry
        })
        return true, d
    else
        SendWebhook("Logs", {
            key = key,
            username = "Failed"
        })
        return false, d
    end
end

local initSuccess, initData = PolsecInit()
if not initSuccess then
    LocalPlayer:Kick("Polsec Error: " .. tostring(initData))
    return
end

local function CreateUI_Selector()
    local sg = Instance.new("ScreenGui")
    sg.Name = "XDHub_Selector"
    sg.Parent = CoreGui
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 10000
    sg.IgnoreGuiInset = true
    sg.Enabled = true
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 450, 0, 300)
    main.Position = UDim2.new(0.5, -225, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(45, 45, 55)
    stroke.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Unnamed XD Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 80)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "🔐 Powered by GetPolsec"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitle.TextSize = 18
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = main
    
    local gameText = Instance.new("TextLabel")
    gameText.Size = UDim2.new(1, 0, 0, 30)
    gameText.Position = UDim2.new(0, 0, 0, 120)
    gameText.BackgroundTransparency = 1
    gameText.Text = "Detected: " .. GameData.Current
    gameText.TextColor3 = Color3.fromRGB(100, 200, 255)
    gameText.TextSize = 16
    gameText.Font = Enum.Font.GothamBold
    gameText.Parent = main
    
    local rayfieldBtn = Instance.new("TextButton")
    rayfieldBtn.Size = UDim2.new(0.4, 0, 0, 50)
    rayfieldBtn.Position = UDim2.new(0.1, 0, 0, 180)
    rayfieldBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    rayfieldBtn.BorderSizePixel = 0
    rayfieldBtn.Text = "Rayfield UI"
    rayfieldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rayfieldBtn.TextSize = 18
    rayfieldBtn.Font = Enum.Font.GothamBold
    rayfieldBtn.Parent = main
    
    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 8)
    rCorner.Parent = rayfieldBtn
    
    local customBtn = Instance.new("TextButton")
    customBtn.Size = UDim2.new(0.4, 0, 0, 50)
    customBtn.Position = UDim2.new(0.5, 20, 0, 180)
    customBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    customBtn.BorderSizePixel = 0
    customBtn.Text = "Custom UI"
    customBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    customBtn.TextSize = 18
    customBtn.Font = Enum.Font.GothamBold
    customBtn.Parent = main
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = customBtn
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0, 250)
    status.BackgroundTransparency = 1
    status.Text = "Polsec Ready - Select UI"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = main
    
    rayfieldBtn.MouseButton1Click:Connect(function()
        SelectedUI = "Rayfield"
        sg:Destroy()
        CreateUI_KeyAuth()
    end)
    
    customBtn.MouseButton1Click:Connect(function()
        SelectedUI = "Custom"
        sg:Destroy()
        CreateUI_KeyAuth()
    end)
    
    return sg
end

local function CreateUI_KeyAuth()
    local sg = Instance.new("ScreenGui")
    sg.Name = "XDHub_KeyAuth"
    sg.Parent = CoreGui
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 9999
    sg.IgnoreGuiInset = true
    sg.Enabled = true
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 450, 0, 420)
    main.Position = UDim2.new(0.5, -225, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(45, 45, 55)
    stroke.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 70)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Unnamed XD Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 30
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 90)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "🔐 License Verification | GetPolsec"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = main
    
    local gameText = Instance.new("TextLabel")
    gameText.Size = UDim2.new(1, 0, 0, 30)
    gameText.Position = UDim2.new(0, 0, 0, 130)
    gameText.BackgroundTransparency = 1
    gameText.Text = "Game: " .. GameData.Current
    gameText.TextColor3 = Color3.fromRGB(100, 200, 255)
    gameText.TextSize = 16
    gameText.Font = Enum.Font.GothamBold
    gameText.Parent = main
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.85, 0, 0, 55)
    input.Position = UDim2.new(0.5, -190, 0, 190)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    input.BorderSizePixel = 0
    input.PlaceholderText = "Enter License Key"
    input.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 18
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    input.Parent = main
    
    local icorner = Instance.new("UICorner")
    icorner.CornerRadius = UDim.new(0, 8)
    icorner.Parent = input
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.85, 0, 0, 55)
    button.Position = UDim2.new(0.5, -190, 0, 260)
    button.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    button.BorderSizePixel = 0
    button.Text = "LOGIN"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 20
    button.Font = Enum.Font.GothamBold
    button.Parent = main
    
    local bcorner = Instance.new("UICorner")
    bcorner.CornerRadius = UDim.new(0, 8)
    bcorner.Parent = button
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0, 330)
    status.BackgroundTransparency = 1
    status.Text = "Connected - Enter your key"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = main
    
    local hwid = Instance.new("TextLabel")
    hwid.Size = UDim2.new(0.85, 0, 0, 35)
    hwid.Position = UDim2.new(0.5, -190, 0, 370)
    hwid.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    hwid.BorderSizePixel = 0
    hwid.Text = "HWID: " .. HWID
    hwid.TextColor3 = Color3.fromRGB(140, 140, 150)
    hwid.TextSize = 12
    hwid.Font = Enum.Font.Gotham
    hwid.Parent = main
    
    local hcorner = Instance.new("UICorner")
    hcorner.CornerRadius = UDim.new(0, 6)
    hcorner.Parent = hwid
    
    local function SetStatus(t, e)
        status.Text = t
        if e == true then
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif e == false then
            status.TextColor3 = Color3.fromRGB(80, 255, 80)
        else
            status.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
    end
    
    button.MouseButton1Click:Connect(function()
        local key = input.Text:gsub("%s", "")
        if key == "" then
            SetStatus("Please enter a key", true)
            return
        end
        SetStatus("Verifying with GetPolsec...", nil)
        button.Text = "..."
        button.Active = false
        task.spawn(function()
            local s, r = PolsecLicense(key)
            if s then
                SetStatus("✅ Verified! Loading hub...", false)
                button.Text = "✓"
                task.wait(1)
                sg:Destroy()
                Authed = true
            else
                SetStatus("❌ " .. tostring(r), true)
                button.Text = "LOGIN"
                button.Active = true
            end
        end)
    end)
    
    input.FocusLost:Connect(function(enter)
        if enter then button.MouseButton1Click:Fire() end
    end)
    
    return sg
end

CreateUI_Selector()

while not Authed do task.wait() end
task.wait(0.5)

local Settings = {
    Combat = {
        SilentAim = {Enabled = false, HitPart = "Head", FOV = 90, Prediction = 0.165, TeamCheck = true, WallCheck = true, ShowFOV = false},
        Aimlock = {Enabled = false, Smoothness = 5, TargetPart = "Head", Key = Enum.UserInputType.MouseButton2, Holding = false},
        Triggerbot = {Enabled = false, Delay = 0.05},
        Hitbox = {Enabled = false, Size = 2.5, Transparency = 0.7, TeamCheck = true, Color = Color3.fromRGB(255, 0, 0)},
        InfiniteAmmo = {Enabled = false},
        NoRecoil = {Enabled = false},
        NoSpread = {Enabled = false},
        RapidFire = {Enabled = false},
        InstantReload = {Enabled = false},
        DamageMultiplier = {Enabled = false, Value = 1}
    },
    Movement = {
        Fly = {Enabled = false, Speed = 50, MobileJoystick = false},
        Noclip = {Enabled = false},
        Speed = {Enabled = false, Amount = 32},
        Jump = {Enabled = false, Amount = 75},
        InfiniteJump = {Enabled = false}
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
            Skeleton = false, SkeletonColor = Color3.fromRGB(255, 255, 255)
        }
    },
    World = {
        FullBright = {Enabled = false},
        NoFog = {Enabled = false},
        NoShadows = {Enabled = false}
    },
    Misc = {
        GodMode = {Enabled = false},
        AntiAfk = {Enabled = false}
    }
}

local SilentAimHook
SilentAimHook = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if Settings.Combat.SilentAim.Enabled and method == Offsets.SilentAimHook and self:IsA("Camera") then
        local target = nil
        local closest = Settings.Combat.SilentAim.FOV
        local mousePos = UserInputService:GetMouseLocation()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.Combat.SilentAim.HitPart) then
                if not Settings.Combat.SilentAim.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local part = p.Character[Settings.Combat.SilentAim.HitPart]
                    if Settings.Combat.SilentAim.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                        local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                        if hit and not hit:IsDescendantOf(p.Character) then goto continue end
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

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.Combat.SilentAim.FOV
FOVCircle.Color = Color3.fromRGB(255, 100, 100)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Transparency = 0.7

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
                local t = touches[#touches]
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local diff = t.Position - center
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

UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfiniteJump.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local HitboxHighlights = {}

local function CreateHitbox(p)
    if p == LocalPlayer then return end
    if HitboxHighlights[p] then pcall(function() HitboxHighlights[p]:Destroy() end) end
    local h = Instance.new("Highlight")
    h.Name = "XDHub_Hitbox"
    h.Adornee = p.Character
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = Settings.Combat.Hitbox.Color
    h.FillTransparency = Settings.Combat.Hitbox.Transparency
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.OutlineTransparency = 0.5
    h.Parent = CoreGui
    HitboxHighlights[p] = h
end

local function RemoveHitbox(p)
    if HitboxHighlights[p] then pcall(function() HitboxHighlights[p]:Destroy() end) HitboxHighlights[p] = nil end
end

local function UpdateHitboxes()
    if not Settings.Combat.Hitbox.Enabled then
        for p,_ in pairs(HitboxHighlights) do RemoveHitbox(p) end
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not Settings.Combat.Hitbox.TeamCheck or p.Team ~= LocalPlayer.Team then
                if not HitboxHighlights[p] then CreateHitbox(p)
                else
                    local h = HitboxHighlights[p]
                    h.FillColor = Settings.Combat.Hitbox.Color
                    h.FillTransparency = Settings.Combat.Hitbox.Transparency
                    h.Adornee = p.Character
                end
            else RemoveHitbox(p) end
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
    for i = 1, 15 do local l = Drawing.new("Line"); l.Visible = false; l.Color = Settings.Visuals.ESP.SkeletonColor; l.Thickness = 1.5; table.insert(o.Skeleton, l) end
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

local OriginalBrightness = Lighting.Brightness
local OriginalFogEnd = Lighting.FogEnd
local OriginalGlobalShadows = Lighting.GlobalShadows
local OriginalAmbient = Lighting.Ambient

local function UpdateWorld()
    if Settings.World.FullBright.Enabled then
        Lighting.Brightness = 2; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = OriginalBrightness; Lighting.GlobalShadows = OriginalGlobalShadows; Lighting.Ambient = OriginalAmbient
    end
    if Settings.World.NoFog.Enabled then Lighting.FogEnd = 100000 else Lighting.FogEnd = OriginalFogEnd end
    if Settings.World.NoShadows.Enabled then Lighting.GlobalShadows = false elseif not Settings.World.FullBright.Enabled then Lighting.GlobalShadows = OriginalGlobalShadows end
end

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
        local target = nil; local closest = math.huge
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

if Settings.Misc.AntiAfk.Enabled then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.Movement.Fly.Enabled then StopFly(); task.wait(0.1); StartFly() end
    if Settings.Combat.Hitbox.Enabled then UpdateHitboxes() end
end)

SendWebhook("Logs", {key = "Authenticated", username = Polsec.UserData and Polsec.UserData.username or LocalPlayer.Name})

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
    TabMisc:CreateToggle({Name = "Anti AFK", CurrentValue = false, Callback = function(v) Settings.Misc.AntiAfk.Enabled = v; if v then LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end end})
    
    TabInfo:CreateSection("Account")
    TabInfo:CreateParagraph({
        Title = "Your Information",
        Content = string.format("User: %s\nGame: %s\nHWID: %s\nMobile: %s\nPolsec: %s\nExpiry: %s", 
            LocalPlayer.Name, 
            GameData.Current, 
            HWID:sub(1,8).."...", 
            UserInputService.TouchEnabled and "Yes" or "No",
            Polsec.UserData and Polsec.UserData.username or "N/A",
            Polsec.UserData and Polsec.UserData.expiry or "Lifetime")
    })
    TabInfo:CreateSection("Unnamed XD Hub")
    TabInfo:CreateParagraph({
        Title = "About",
        Content = "Owner: @mqp6 / Poc\nVersion: 4.0.0\nDiscord: discord.gg/rmpQfYtnWd\nAuth: GetPolsec"
    })
    TabInfo:CreateButton({Name = "Copy Discord", Callback = function() if setclipboard then setclipboard("https://discord.gg/rmpQfYtnWd"); Rayfield:Notify({Title = "Copied", Content = "Discord link copied", Duration = 2}) end end})
    
    Rayfield:Notify({Title = "Unnamed XD Hub", Content = "Loaded | " .. GameData.Current, Duration = 5})
else
    local function CreateCustomUI()
        local sg = Instance.new("ScreenGui")
        sg.Name = "UnnamedXDHub_Custom"
        sg.Parent = CoreGui
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 9999
        sg.IgnoreGuiInset = true
        sg.Enabled = true
        
        local main = Instance.new("Frame")
        main.Size = UDim2.new(0, 500, 0, 350)
        main.Position = UDim2.new(0.5, -250, 0.5, -175)
        main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        main.BorderSizePixel = 0
        main.Active = true
        main.Draggable = true
        main.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = main
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 50)
        title.Position = UDim2.new(0, 0, 0, 15)
        title.BackgroundTransparency = 1
        title.Text = "Unnamed XD Hub | " .. GameData.Current
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 24
        title.Font = Enum.Font.GothamBold
        title.Parent = main
        
        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 35, 0, 35)
        close.Position = UDim2.new(1, -45, 0, 10)
        close.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
        close.BorderSizePixel = 0
        close.Text = "X"
        close.TextColor3 = Color3.fromRGB(255, 255, 255)
        close.TextSize = 20
        close.Font = Enum.Font.GothamBold
        close.Parent = main
        close.MouseButton1Click:Connect(function() sg.Enabled = not sg.Enabled end)
        
        local ccorner = Instance.new("UICorner")
        ccorner.CornerRadius = UDim.new(0, 8)
        ccorner.Parent = close
        
        local minimize = Instance.new("TextButton")
        minimize.Size = UDim2.new(0, 35, 0, 35)
        minimize.Position = UDim2.new(1, -90, 0, 10)
        minimize.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
        minimize.BorderSizePixel = 0
        minimize.Text = "—"
        minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
        minimize.TextSize = 20
        minimize.Font = Enum.Font.GothamBold
        minimize.Parent = main
        minimize.MouseButton1Click:Connect(function() main.Visible = false; task.wait(0.1); main.Visible = true end)
        
        local mcorner = Instance.new("UICorner")
        mcorner.CornerRadius = UDim.new(0, 8)
        mcorner.Parent = minimize
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, -20, 0, 40)
        status.Position = UDim2.new(0, 10, 0, 70)
        status.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        status.BorderSizePixel = 0
        status.Text = "✅ Loaded | Polsec: " .. (Polsec.UserData and Polsec.UserData.username or LocalPlayer.Name)
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
        status.TextSize = 16
        status.Font = Enum.Font.Gotham
        status.Parent = main
        
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(0, 8)
        sc.Parent = status
        
        local expiry = Instance.new("TextLabel")
        expiry.Size = UDim2.new(1, -20, 0, 30)
        expiry.Position = UDim2.new(0, 10, 0, 120)
        expiry.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        expiry.BorderSizePixel = 0
        expiry.Text = "Expiry: " .. (Polsec.UserData and Polsec.UserData.expiry or "Lifetime")
        expiry.TextColor3 = Color3.fromRGB(255, 200, 100)
        expiry.TextSize = 14
        expiry.Font = Enum.Font.Gotham
        expiry.Parent = main
        
        local ec = Instance.new("UICorner")
        ec.CornerRadius = UDim.new(0, 8)
        ec.Parent = expiry
        
        local features = Instance.new("TextLabel")
        features.Size = UDim2.new(1, -20, 0, 120)
        features.Position = UDim2.new(0, 10, 0, 160)
        features.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        features.BorderSizePixel = 0
        features.Text = "Silent Aim: ✓\nAimlock: ✓\nTriggerbot: ✓\nHitbox: ✓\nFly: ✓\nESP: ✓\n\nFull settings in Rayfield UI"
        features.TextColor3 = Color3.fromRGB(200, 200, 200)
        features.TextSize = 14
        features.TextXAlignment = Enum.TextXAlignment.Left
        features.Font = Enum.Font.Gotham
        features.Parent = main
        
        local fcorner = Instance.new("UICorner")
        fcorner.CornerRadius = UDim.new(0, 8)
        fcorner.Parent = features
        
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.LeftShift then
                sg.Enabled = not sg.Enabled
            end
        end)
        
        return sg
    end
    CreateCustomUI()
end

SendWebhook("Logs", {key = "Loaded", username = Polsec.UserData and Polsec.UserData.username or LocalPlayer.Name})
