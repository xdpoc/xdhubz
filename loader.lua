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
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local PlaceId = game.PlaceId
local JobId = game.JobId

local GameData = {
    Current = "Universal",
    Arsenal = {286090429, 142823239, 4123456789, 1304584327, 5602055394},
    DaHood = {7213776334, 2788229376, 12132143254, 5421072413, 4483381587},
    PhantomForces = {292439477, 13212453678, 9827675351, 6111083092},
    Rivals = {4483381587, 2713886045, 606849621, 9192908196, 1537690962},
    WildWest = {2116556182, 4819812387, 9014234901, 3358904356},
    BreakIn = {1322096432, 8849316423, 2134789654, 5734111098},
    BedWars = {6872265039, 8562821213, 11021538791, 9012348765},
    MM2 = {142823239, 3144011132, 4895768901, 2345678901},
    Jailbreak = {606849621, 4567891230, 7891234560, 3456789012}
}

for name, ids in pairs(GameData) do
    if name ~= "Current" then
        for _, id in ipairs(ids) do
            if PlaceId == id then
                GameData.Current = name
                break
            end
        end
    end
end

local Offsets = {
    Universal = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "CurrentAmmo", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    Arsenal = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "CurrentAmmo", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    DaHood = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "Ammo", FireRate = "Firerate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    PhantomForces = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "AmmoCount", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    Rivals = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "CurrentAmmo", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    WildWest = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "Ammo", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    BreakIn = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "CurrentAmmo", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    BedWars = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "Ammo", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    MM2 = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "CurrentAmmo", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"},
    Jailbreak = {SilentAimHook = "FindPartOnRayWithIgnoreList", Damage = "Damage", Ammo = "Ammo", FireRate = "FireRate", Recoil = "Recoil", Spread = "Spread", Reload = "ReloadTime"}
}

local Offset = Offsets[GameData.Current] or Offsets.Universal

local Settings = {
    SilentAim = {Enabled = false, HitPart = "Head", FOV = 90, Prediction = 0.165, TeamCheck = true, WallCheck = true, ShowFOV = false, AutoPrediction = false},
    Aimlock = {Enabled = false, Smoothness = 5, TargetPart = "Head", Key = Enum.UserInputType.MouseButton2, Holding = false, ThirdPerson = false},
    Triggerbot = {Enabled = false, Delay = 0.05, IgnoreFriends = true, IgnoreTeam = true, WallCheck = false},
    Hitbox = {Enabled = false, Size = 2.5, Transparency = 0.7, TeamCheck = true, Color = Color3.fromRGB(255,0,0)},
    InfiniteAmmo = {Enabled = false},
    NoRecoil = {Enabled = false},
    NoSpread = {Enabled = false},
    RapidFire = {Enabled = false},
    InstantReload = {Enabled = false},
    DamageMultiplier = {Enabled = false, Value = 1},
    AutoShoot = {Enabled = false, Delay = 0.1},
    Wallbang = {Enabled = false, Penetration = 100},
    BulletTracers = {Enabled = false, Color = Color3.fromRGB(255,255,0), Thickness = 1.5},
    AntiAim = {Enabled = false, Pitch = 0, Yaw = 0, SpinSpeed = 10, Jitter = false},
    AirStuck = {Enabled = false, Key = Enum.KeyCode.V},
    DoubleTap = {Enabled = false, Delay = 0.05},
    AutoReload = {Enabled = false},
    NoSway = {Enabled = false},
    NoCameraRecoil = {Enabled = false},
    AutoFire = {Enabled = false},
    Fly = {Enabled = false, Speed = 50, MobileJoystick = false, AntiKick = false},
    Noclip = {Enabled = false},
    Speed = {Enabled = false, Amount = 32},
    Jump = {Enabled = false, Amount = 75},
    InfiniteJump = {Enabled = false},
    AirJump = {Enabled = false},
    Float = {Enabled = false, Height = 10},
    AntiFall = {Enabled = false},
    Spinbot = {Enabled = false, Speed = 10},
    BHop = {Enabled = false, AutoJump = false},
    CFrameTeleport = {Enabled = false, Speed = 50},
    LongJump = {Enabled = false, Power = 100},
    HighJump = {Enabled = false, Power = 100},
    WaterWalk = {Enabled = false},
    WallClimb = {Enabled = false, Speed = 16},
    AirStrafing = {Enabled = false},
    AutoSprint = {Enabled = false},
    NoSlowdown = {Enabled = false},
    Glide = {Enabled = false, Speed = 10},
    Teleport = {Enabled = false, Key = Enum.KeyCode.T},
    ESP = {
        Enabled = false, Box = true, BoxColor = Color3.fromRGB(255,100,100), BoxOutline = true,
        Name = true, NameColor = Color3.fromRGB(255,255,255),
        Health = true, HealthColor = Color3.fromRGB(100,255,100),
        Distance = true, DistanceColor = Color3.fromRGB(200,200,200),
        Tracer = false, TracerColor = Color3.fromRGB(255,255,255), TracerStart = "Bottom",
        HeadDot = false, HeadDotColor = Color3.fromRGB(255,0,0), HeadDotSize = 4,
        Weapon = true, WeaponColor = Color3.fromRGB(255,255,0),
        Skeleton = false, SkeletonColor = Color3.fromRGB(255,255,255),
        Chams = false, ChamsColor = Color3.fromRGB(0,255,255), ChamsTransparency = 0.5,
        Glow = false, GlowColor = Color3.fromRGB(0,255,255), GlowTransparency = 0.5,
        Box3D = false, Box3DColor = Color3.fromRGB(255,100,100),
        CornerBox = false, CornerBoxColor = Color3.fromRGB(255,255,255),
        HealthBar = false, HealthBarColor = Color3.fromRGB(100,255,100),
        ArmorBar = false, ArmorBarColor = Color3.fromRGB(0,150,255),
        Rank = false, RankColor = Color3.fromRGB(255,255,0),
        Platform = false, PlatformColor = Color3.fromRGB(200,200,200),
        TeamID = false, TeamIDColor = Color3.fromRGB(255,255,255),
        Highlight = false, HighlightColor = Color3.fromRGB(255,255,0)
    },
    Crosshair = {Enabled = false, Color = Color3.fromRGB(255,255,255), Size = 10, Gap = 5, Thickness = 2, Dot = false, Outline = true, Shape = "Cross"},
    FOVChanger = {Enabled = false, Amount = 90, ThirdPerson = false, Distance = 10},
    NoFlash = {Enabled = false},
    NoGun = {Enabled = false},
    NoViewmodel = {Enabled = false},
    NightVision = {Enabled = false, Brightness = 0.5},
    ThermalVision = {Enabled = false, Color = Color3.fromRGB(255,100,0)},
    FullBright = {Enabled = false},
    World = {
        FullBright = {Enabled = false},
        NoFog = {Enabled = false},
        NoShadows = {Enabled = false},
        Ambient = {Enabled = false, Color = Color3.fromRGB(127,127,127)},
        Sky = {Enabled = false, ID = 0},
        Time = {Enabled = false, Hour = 12},
        Water = {Enabled = false, Transparency = 0.5, Color = Color3.fromRGB(0,150,255)},
        AntiLag = {Enabled = false, LowGraphics = false},
        NoTexture = {Enabled = false},
        Wireframe = {Enabled = false},
        XRay = {Enabled = false, Transparency = 0.5},
        Rainbow = {Enabled = false, Speed = 1}
    },
    GodMode = {Enabled = false},
    AntiAfk = {Enabled = false},
    AutoFarm = {Enabled = false, Type = "Gun"},
    AutoCollect = {Enabled = false, Radius = 50},
    NoFallDamage = {Enabled = false},
    ForceField = {Enabled = false},
    AntiVoid = {Enabled = false},
    AutoRespawn = {Enabled = false},
    AutoWin = {Enabled = false},
    AntiKick = {Enabled = false},
    AntiBan = {Enabled = false},
    AntiReport = {Enabled = false},
    SpoofUsername = {Enabled = false, Name = ""},
    SpoofDisplayName = {Enabled = false, Name = ""},
    FriendCheck = {Enabled = false},
    ClanSpoof = {Enabled = false, Tag = ""},
    AutoStr = {Enabled = false, Message = ""},
    ChatSpammer = {Enabled = false, Message = "", Delay = 1},
    AutoBuy = {Enabled = false, Item = ""},
    AutoEquip = {Enabled = false, Item = ""},
    AutoSell = {Enabled = false},
    AutoTrade = {Enabled = false},
    Dupe = {Enabled = false},
    Rejoin = {Enabled = false, Key = Enum.KeyCode.R},
    ServerHop = {Enabled = false, Key = Enum.KeyCode.H},
    Arsenal = {AutoKill = false, AutoWin = false, ForceField = false, InfiniteStamina = false, NoKnockback = false, NoSlowness = false, AutoReload = false, AutoSwap = false, AutoGun = false, NoScope = false, AutoSpin = false},
    DaHood = {SilentAim = false, Aimlock = false, Triggerbot = false, InfiniteAmmo = false, NoRecoil = false, RapidFire = false, GodMode = false, AutoFarm = false, AutoCollect = false, AutoStr = false, AutoBuy = false, AutoEquip = false, AutoSell = false, Dupe = false},
    PhantomForces = {SilentAim = false, Aimlock = false, Triggerbot = false, InfiniteAmmo = false, NoRecoil = false, NoSpread = false, RapidFire = false, NoSway = false, NoCameraRecoil = false},
    Rivals = {SilentAim = false, Aimlock = false, Triggerbot = false, InfiniteAmmo = false, NoRecoil = false, NoSpread = false, RapidFire = false},
    WildWest = {SilentAim = false, Aimlock = false, Triggerbot = false, InfiniteAmmo = false, NoRecoil = false},
    BreakIn = {ESP = false, Hitbox = false, Fly = false, Noclip = false, Speed = false, InfiniteJump = false, NoFallDamage = false, AutoCollect = false},
    BedWars = {SilentAim = false, Aimlock = false, Triggerbot = false, ESP = false, Hitbox = false, Fly = false, AntiVoid = false, AutoFarm = false},
    MM2 = {ESP = false, Hitbox = false, Fly = false, Noclip = false, Speed = false, InfiniteJump = false, AutoWin = false, AutoCollect = false},
    Jailbreak = {SilentAim = false, Aimlock = false, Triggerbot = false, ESP = false, Hitbox = false, Fly = false, Noclip = false, Speed = false, InfiniteJump = false, AutoFarm = false, AutoCollect = false}
}

local SilentAimHook
SilentAimHook = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if Settings.SilentAim.Enabled and method == Offset.SilentAimHook and self:IsA("Camera") then
        local target = nil
        local closest = Settings.SilentAim.FOV
        local mousePos = UserInputService:GetMouseLocation()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.SilentAim.HitPart) then
                if not Settings.SilentAim.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local part = p.Character[Settings.SilentAim.HitPart]
                    if Settings.SilentAim.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                        local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                        if hit and not hit:IsDescendantOf(p.Character) then goto continue end
                    end
                    local screen, onScreen = Camera:WorldToViewportPoint(part.Position + (part.Velocity * Settings.SilentAim.Prediction))
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
            local pos = target.Position + (target.Velocity * Settings.SilentAim.Prediction)
            return {pos}, pos, Vector3.new(), Enum.Material.SmoothPlastic
        end
    end
    return SilentAimHook(self, ...)
end)

local IndexHook
IndexHook = hookmetamethod(game, "__index", function(self, key)
    if Settings.NoRecoil.Enabled then
        if self:IsA("LocalScript") and tostring(key):match(Offset.Recoil) then return 0 end
        if self:IsA("NumberValue") and self.Name:match(Offset.Recoil) and key == "Value" then return 0 end
    end
    if Settings.NoSpread.Enabled then
        if self:IsA("LocalScript") and tostring(key):match(Offset.Spread) then return 0 end
        if self:IsA("NumberValue") and self.Name:match(Offset.Spread) and key == "Value" then return 0 end
    end
    if Settings.RapidFire.Enabled then
        if self:IsA("LocalScript") and tostring(key):match(Offset.FireRate) then return 0.01 end
        if self:IsA("NumberValue") and self.Name:match(Offset.FireRate) and key == "Value" then return 0.01 end
    end
    if Settings.InfiniteAmmo.Enabled and self:IsA("IntValue") and self.Name == Offset.Ammo and key == "Value" then return 999 end
    if Settings.InstantReload.Enabled and self:IsA("NumberValue") and self.Name == Offset.Reload and key == "Value" then return 0.01 end
    if Settings.DamageMultiplier.Enabled and self:IsA("NumberValue") and self.Name == Offset.Damage and key == "Value" then return IndexHook(self, key) * Settings.DamageMultiplier.Value end
    if Settings.GodMode.Enabled and self:IsA("IntValue") and self.Name == "Health" and key == "Value" then return 100 end
    return IndexHook(self, key)
end)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.SilentAim.FOV
FOVCircle.Color = Color3.fromRGB(255,100,100)
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
    if FlyConnection then FlyConnection:Disconnect() end
    FlyConnection = nil
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root then
            if FlyBodyGyro then FlyBodyGyro:Destroy() end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
            FlyBodyGyro = nil
            FlyBodyVelocity = nil
        end
        if hum then hum.PlatformStand = false end
    end
end

local HitboxHighlights = {}
local function CreateHitbox(p)
    if p == LocalPlayer then return end
    if HitboxHighlights[p] then pcall(function() HitboxHighlights[p]:Destroy() end) end
    local h = Instance.new("Highlight")
    h.Name = "XDHub_Hitbox"
    h.Adornee = p.Character
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = Settings.Hitbox.Color
    h.FillTransparency = Settings.Hitbox.Transparency
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.OutlineTransparency = 0.5
    h.Parent = CoreGui
    HitboxHighlights[p] = h
end
local function RemoveHitbox(p)
    if HitboxHighlights[p] then
        pcall(function() HitboxHighlights[p]:Destroy() end)
        HitboxHighlights[p] = nil
    end
end
local function UpdateHitboxes()
    if not Settings.Hitbox.Enabled then
        for p,_ in pairs(HitboxHighlights) do RemoveHitbox(p) end
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not Settings.Hitbox.TeamCheck or p.Team ~= LocalPlayer.Team then
                if not HitboxHighlights[p] then
                    CreateHitbox(p)
                else
                    local h = HitboxHighlights[p]
                    h.FillColor = Settings.Hitbox.Color
                    h.FillTransparency = Settings.Hitbox.Transparency
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
        if Settings.Hitbox.Enabled and (not Settings.Hitbox.TeamCheck or p.Team ~= LocalPlayer.Team) then
            CreateHitbox(p)
        end
    end)
end)
Players.PlayerRemoving:Connect(RemoveHitbox)

local ESPObjects = {}
local SkeletonJoints = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}
local function CreateESP(p)
    if p == LocalPlayer then return end
    local o = {}
    o.Box = Drawing.new("Square")
    o.Box.Visible = false
    o.Box.Color = Settings.ESP.BoxColor
    o.Box.Thickness = 1.5
    o.Box.Filled = false
    o.BoxOutline = Drawing.new("Square")
    o.BoxOutline.Visible = false
    o.BoxOutline.Color = Color3.fromRGB(0,0,0)
    o.BoxOutline.Thickness = 3
    o.BoxOutline.Filled = false
    o.Name = Drawing.new("Text")
    o.Name.Visible = false
    o.Name.Color = Settings.ESP.NameColor
    o.Name.Size = 16
    o.Name.Center = true
    o.Name.Outline = true
    o.Health = Drawing.new("Text")
    o.Health.Visible = false
    o.Health.Color = Settings.ESP.HealthColor
    o.Health.Size = 14
    o.Health.Center = true
    o.Health.Outline = true
    o.Distance = Drawing.new("Text")
    o.Distance.Visible = false
    o.Distance.Color = Settings.ESP.DistanceColor
    o.Distance.Size = 12
    o.Distance.Center = true
    o.Distance.Outline = true
    o.Tracer = Drawing.new("Line")
    o.Tracer.Visible = false
    o.Tracer.Color = Settings.ESP.TracerColor
    o.Tracer.Thickness = 1.5
    o.HeadDot = Drawing.new("Circle")
    o.HeadDot.Visible = false
    o.HeadDot.Color = Settings.ESP.HeadDotColor
    o.HeadDot.Radius = Settings.ESP.HeadDotSize
    o.HeadDot.Filled = true
    o.HeadDot.NumSides = 16
    o.Weapon = Drawing.new("Text")
    o.Weapon.Visible = false
    o.Weapon.Color = Settings.ESP.WeaponColor
    o.Weapon.Size = 12
    o.Weapon.Center = true
    o.Weapon.Outline = true
    o.Skeleton = {}
    for i = 1, 14 do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Color = Settings.ESP.SkeletonColor
        l.Thickness = 1.5
        table.insert(o.Skeleton, l)
    end
    ESPObjects[p] = o
end
local function UpdateESP()
    if not Settings.ESP.Enabled then
        for p, o in pairs(ESPObjects) do
            for _, obj in pairs(o) do
                if type(obj) == "table" then
                    for _, l in pairs(obj) do
                        l.Visible = false
                    end
                else
                    if obj.Visible ~= nil then
                        obj.Visible = false
                    end
                end
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
                local boxColor = p.Team == LocalPlayer.Team and Color3.fromRGB(100,255,100) or Settings.ESP.BoxColor
                if Settings.ESP.Box and Settings.ESP.BoxOutline then
                    o.BoxOutline.Visible = true
                    o.BoxOutline.Position = boxPos - Vector2.new(1,1)
                    o.BoxOutline.Size = Vector2.new(w+2, h+2)
                else
                    o.BoxOutline.Visible = false
                end
                if Settings.ESP.Box then
                    o.Box.Visible = true
                    o.Box.Position = boxPos
                    o.Box.Size = Vector2.new(w, h)
                    o.Box.Color = boxColor
                else
                    o.Box.Visible = false
                end
                if Settings.ESP.Name then
                    o.Name.Visible = true
                    o.Name.Position = Vector2.new(pos.X, boxPos.Y - 20)
                    o.Name.Text = p.Name
                    o.Name.Color = Settings.ESP.NameColor
                else
                    o.Name.Visible = false
                end
                if Settings.ESP.Health and hum then
                    o.Health.Visible = true
                    o.Health.Position = Vector2.new(pos.X, boxPos.Y + h + 5)
                    o.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    o.Health.Color = Settings.ESP.HealthColor
                else
                    o.Health.Visible = false
                end
                if Settings.ESP.Distance then
                    o.Distance.Visible = true
                    o.Distance.Position = Vector2.new(pos.X, boxPos.Y + h + 25)
                    o.Distance.Text = math.floor(dist) .. "s"
                    o.Distance.Color = Settings.ESP.DistanceColor
                else
                    o.Distance.Visible = false
                end
                if Settings.ESP.Tracer then
                    o.Tracer.Visible = true
                    if Settings.ESP.TracerStart == "Bottom" then
                        o.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    elseif Settings.ESP.TracerStart == "Center" then
                        o.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    else
                        o.Tracer.From = UserInputService:GetMouseLocation()
                    end
                    o.Tracer.To = Vector2.new(pos.X, pos.Y)
                    o.Tracer.Color = Settings.ESP.TracerColor
                else
                    o.Tracer.Visible = false
                end
                if Settings.ESP.HeadDot and head then
                    o.HeadDot.Visible = true
                    o.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                    o.HeadDot.Color = Settings.ESP.HeadDotColor
                    o.HeadDot.Radius = Settings.ESP.HeadDotSize
                else
                    o.HeadDot.Visible = false
                end
                if Settings.ESP.Weapon then
                    o.Weapon.Visible = true
                    o.Weapon.Position = Vector2.new(pos.X, boxPos.Y - 40)
                    local tool = p.Character:FindFirstChildOfClass("Tool")
                    o.Weapon.Text = tool and tool.Name or "None"
                    o.Weapon.Color = Settings.ESP.WeaponColor
                else
                    o.Weapon.Visible = false
                end
                if Settings.ESP.Skeleton then
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
                                o.Skeleton[i].Color = Settings.ESP.SkeletonColor
                            else
                                o.Skeleton[i].Visible = false
                            end
                        else
                            o.Skeleton[i].Visible = false
                        end
                    end
                else
                    for _, l in pairs(o.Skeleton) do
                        l.Visible = false
                    end
                end
            else
                o.Box.Visible = false
                o.BoxOutline.Visible = false
                o.Name.Visible = false
                o.Health.Visible = false
                o.Distance.Visible = false
                o.Tracer.Visible = false
                o.HeadDot.Visible = false
                o.Weapon.Visible = false
                for _, l in pairs(o.Skeleton) do
                    l.Visible = false
                end
            end
        else
            o.Box.Visible = false
            o.BoxOutline.Visible = false
            o.Name.Visible = false
            o.Health.Visible = false
            o.Distance.Visible = false
            o.Tracer.Visible = false
            o.HeadDot.Visible = false
            o.Weapon.Visible = false
            for _, l in pairs(o.Skeleton) do
                l.Visible = false
            end
        end
    end
end
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        for _, obj in pairs(ESPObjects[p]) do
            if type(obj) == "table" then
                for _, l in pairs(obj) do
                    pcall(function() l:Remove() end)
                end
            else
                pcall(function() obj:Remove() end)
            end
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
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = OriginalBrightness
        Lighting.GlobalShadows = OriginalGlobalShadows
        Lighting.Ambient = OriginalAmbient
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
end

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

RunService.RenderStepped:Connect(function()
    if Settings.SilentAim.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.SilentAim.FOV
    else
        FOVCircle.Visible = false
    end
    if Settings.Aimlock.Enabled and Settings.Aimlock.Holding then
        local target = nil
        local closest = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.Aimlock.TargetPart) then
                if not Settings.SilentAim.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local part = p.Character[Settings.Aimlock.TargetPart]
                    local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screen.X, screen.Y) - UserInputService:GetMouseLocation()).Magnitude
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
            local smooth = current:Lerp(targetDir, 1 / Settings.Aimlock.Smoothness)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + smooth)
        end
    end
end)

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

if Settings.AntiAfk.Enabled then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.Fly.Enabled then
        StopFly()
        task.wait(0.1)
        StartFly()
    end
    if Settings.Hitbox.Enabled then
        UpdateHitboxes()
    end
end)

RunService.Stepped:Connect(function()
    if Settings.Noclip.Enabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
    if Settings.Speed.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed.Amount
    end
    if Settings.Jump.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Settings.Jump.Amount
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

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
local TabGame = Window:CreateTab(GameData.Current, 4483362458)

TabCombat:CreateSection("Silent Aim")
local saenabled = TabCombat:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.SilentAim.Enabled = v end})
local sahitbox = TabCombat:CreateDropdown({Name = "Hitbox", Options = {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) Settings.SilentAim.HitPart = v[1] end})
local safov = TabCombat:CreateSlider({Name = "FOV", Range = {30,200}, Increment = 5, CurrentValue = 90, Callback = function(v) Settings.SilentAim.FOV = v end})
local sapred = TabCombat:CreateSlider({Name = "Prediction", Range = {0,300}, Increment = 5, CurrentValue = 165, Callback = function(v) Settings.SilentAim.Prediction = v / 1000 end})
local sateam = TabCombat:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Settings.SilentAim.TeamCheck = v end})
local sawall = TabCombat:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) Settings.SilentAim.WallCheck = v end})
local safovcircle = TabCombat:CreateToggle({Name = "Show FOV", CurrentValue = false, Callback = function(v) Settings.SilentAim.ShowFOV = v end})

TabCombat:CreateSection("Aimlock")
local alenabled = TabCombat:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Aimlock.Enabled = v end})
local alsmooth = TabCombat:CreateSlider({Name = "Smoothness", Range = {1,15}, Increment = 1, CurrentValue = 5, Callback = function(v) Settings.Aimlock.Smoothness = v end})
local altarget = TabCombat:CreateDropdown({Name = "Target", Options = {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(v) Settings.Aimlock.TargetPart = v[1] end})

TabCombat:CreateSection("Triggerbot")
local tbenabled = TabCombat:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Triggerbot.Enabled = v end})
local tbdelay = TabCombat:CreateSlider({Name = "Delay (ms)", Range = {0,200}, Increment = 10, CurrentValue = 50, Callback = function(v) Settings.Triggerbot.Delay = v / 1000 end})

TabCombat:CreateSection("Hitbox Expander")
local hbenabled = TabCombat:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Hitbox.Enabled = v; if v then UpdateHitboxes() else for p,_ in pairs(HitboxHighlights) do RemoveHitbox(p) end end end})
local hbsize = TabCombat:CreateSlider({Name = "Size", Range = {1,5}, Increment = 0.1, CurrentValue = 2.5, Callback = function(v) Settings.Hitbox.Size = v end})
local hbtrans = TabCombat:CreateSlider({Name = "Transparency", Range = {0,1}, Increment = 0.1, CurrentValue = 0.7, Callback = function(v) Settings.Hitbox.Transparency = v; if Settings.Hitbox.Enabled then UpdateHitboxes() end end})
local hbteam = TabCombat:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Settings.Hitbox.TeamCheck = v; if Settings.Hitbox.Enabled then UpdateHitboxes() end end})
local hbcolor = TabCombat:CreateColorPicker({Name = "Color", CurrentValue = Color3.fromRGB(255,0,0), Callback = function(v) Settings.Hitbox.Color = v; if Settings.Hitbox.Enabled then UpdateHitboxes() end end})

TabCombat:CreateSection("Gun Mods")
local iatenabled = TabCombat:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(v) Settings.InfiniteAmmo.Enabled = v end})
local nrenabled = TabCombat:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(v) Settings.NoRecoil.Enabled = v end})
local nspenabled = TabCombat:CreateToggle({Name = "No Spread", CurrentValue = false, Callback = function(v) Settings.NoSpread.Enabled = v end})
local rfenabled = TabCombat:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) Settings.RapidFire.Enabled = v end})
local irenabled = TabCombat:CreateToggle({Name = "Instant Reload", CurrentValue = false, Callback = function(v) Settings.InstantReload.Enabled = v end})
local dmenabled = TabCombat:CreateToggle({Name = "Damage Multiplier", CurrentValue = false, Callback = function(v) Settings.DamageMultiplier.Enabled = v end})
local dmvalue = TabCombat:CreateSlider({Name = "Damage Amount", Range = {1,10}, Increment = 1, CurrentValue = 1, Callback = function(v) Settings.DamageMultiplier.Value = v end})

TabMovement:CreateSection("Fly")
local flyenabled = TabMovement:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.Fly.Enabled = v; if v then StartFly() else StopFly() end end})
local flyspeed = TabMovement:CreateSlider({Name = "Speed", Range = {10,150}, Increment = 5, CurrentValue = 50, Callback = function(v) Settings.Fly.Speed = v end})

TabMovement:CreateSection("Movement")
local nclenabled = TabMovement:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Settings.Noclip.Enabled = v end})
local spdenabled = TabMovement:CreateToggle({Name = "Speed", CurrentValue = false, Callback = function(v) Settings.Speed.Enabled = v end})
local spdvalue = TabMovement:CreateSlider({Name = "Speed Amount", Range = {16,250}, Increment = 1, CurrentValue = 32, Callback = function(v) Settings.Speed.Amount = v end})
local jmpenabled = TabMovement:CreateToggle({Name = "Jump Power", CurrentValue = false, Callback = function(v) Settings.Jump.Enabled = v end})
local jmpvalue = TabMovement:CreateSlider({Name = "Jump Amount", Range = {50,250}, Increment = 1, CurrentValue = 75, Callback = function(v) Settings.Jump.Amount = v end})
local ijpenabled = TabMovement:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Settings.InfiniteJump.Enabled = v end})

TabVisuals:CreateSection("ESP")
local espenabled = TabVisuals:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) Settings.ESP.Enabled = v end})
local espbox = TabVisuals:CreateToggle({Name = "Box", CurrentValue = true, Callback = function(v) Settings.ESP.Box = v end})
local espboxoutline = TabVisuals:CreateToggle({Name = "Box Outline", CurrentValue = true, Callback = function(v) Settings.ESP.BoxOutline = v end})
local espboxcolor = TabVisuals:CreateColorPicker({Name = "Box Color", CurrentValue = Color3.fromRGB(255,100,100), Callback = function(v) Settings.ESP.BoxColor = v end})
local espname = TabVisuals:CreateToggle({Name = "Name", CurrentValue = true, Callback = function(v) Settings.ESP.Name = v end})
local espnamecolor = TabVisuals:CreateColorPicker({Name = "Name Color", CurrentValue = Color3.fromRGB(255,255,255), Callback = function(v) Settings.ESP.NameColor = v end})
local esphealth = TabVisuals:CreateToggle({Name = "Health", CurrentValue = true, Callback = function(v) Settings.ESP.Health = v end})
local esphealthcolor = TabVisuals:CreateColorPicker({Name = "Health Color", CurrentValue = Color3.fromRGB(100,255,100), Callback = function(v) Settings.ESP.HealthColor = v end})
local espdistance = TabVisuals:CreateToggle({Name = "Distance", CurrentValue = true, Callback = function(v) Settings.ESP.Distance = v end})
local espdistancecolor = TabVisuals:CreateColorPicker({Name = "Distance Color", CurrentValue = Color3.fromRGB(200,200,200), Callback = function(v) Settings.ESP.DistanceColor = v end})
local espweapon = TabVisuals:CreateToggle({Name = "Weapon", CurrentValue = true, Callback = function(v) Settings.ESP.Weapon = v end})
local espweaponcolor = TabVisuals:CreateColorPicker({Name = "Weapon Color", CurrentValue = Color3.fromRGB(255,255,0), Callback = function(v) Settings.ESP.WeaponColor = v end})
local esptracer = TabVisuals:CreateToggle({Name = "Tracer", CurrentValue = false, Callback = function(v) Settings.ESP.Tracer = v end})
local esptracercolor = TabVisuals:CreateColorPicker({Name = "Tracer Color", CurrentValue = Color3.fromRGB(255,255,255), Callback = function(v) Settings.ESP.TracerColor = v end})
local espheaddot = TabVisuals:CreateToggle({Name = "Head Dot", CurrentValue = false, Callback = function(v) Settings.ESP.HeadDot = v end})
local espheaddotcolor = TabVisuals:CreateColorPicker({Name = "Head Dot Color", CurrentValue = Color3.fromRGB(255,0,0), Callback = function(v) Settings.ESP.HeadDotColor = v end})
local espskeleton = TabVisuals:CreateToggle({Name = "Skeleton", CurrentValue = false, Callback = function(v) Settings.ESP.Skeleton = v end})
local espskeletoncolor = TabVisuals:CreateColorPicker({Name = "Skeleton Color", CurrentValue = Color3.fromRGB(255,255,255), Callback = function(v) Settings.ESP.SkeletonColor = v end})

TabWorld:CreateSection("Lighting")
local wfb = TabWorld:CreateToggle({Name = "Full Bright", CurrentValue = false, Callback = function(v) Settings.World.FullBright.Enabled = v; UpdateWorld() end})
local wnf = TabWorld:CreateToggle({Name = "No Fog", CurrentValue = false, Callback = function(v) Settings.World.NoFog.Enabled = v; UpdateWorld() end})
local wns = TabWorld:CreateToggle({Name = "No Shadows", CurrentValue = false, Callback = function(v) Settings.World.NoShadows.Enabled = v; UpdateWorld() end})

TabMisc:CreateSection("Player")
local gm = TabMisc:CreateToggle({Name = "God Mode", CurrentValue = false, Callback = function(v) Settings.GodMode.Enabled = v end})
local afk = TabMisc:CreateToggle({Name = "Anti AFK", CurrentValue = false, Callback = function(v) Settings.AntiAfk.Enabled = v; if v then LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end end})

if GameData.Current == "Arsenal" then
    TabGame:CreateSection("Arsenal")
    TabGame:CreateToggle({Name = "Auto Kill", CurrentValue = false, Callback = function(v) Settings.Arsenal.AutoKill = v end})
    TabGame:CreateToggle({Name = "Auto Win", CurrentValue = false, Callback = function(v) Settings.Arsenal.AutoWin = v end})
    TabGame:CreateToggle({Name = "Force Field", CurrentValue = false, Callback = function(v) Settings.Arsenal.ForceField = v end})
    TabGame:CreateToggle({Name = "Infinite Stamina", CurrentValue = false, Callback = function(v) Settings.Arsenal.InfiniteStamina = v end})
    TabGame:CreateToggle({Name = "No Knockback", CurrentValue = false, Callback = function(v) Settings.Arsenal.NoKnockback = v end})
    TabGame:CreateToggle({Name = "No Slowness", CurrentValue = false, Callback = function(v) Settings.Arsenal.NoSlowness = v end})
    TabGame:CreateToggle({Name = "Auto Reload", CurrentValue = false, Callback = function(v) Settings.Arsenal.AutoReload = v end})
    TabGame:CreateToggle({Name = "No Scope", CurrentValue = false, Callback = function(v) Settings.Arsenal.NoScope = v end})
end

if GameData.Current == "DaHood" then
    TabGame:CreateSection("Da Hood")
    TabGame:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) Settings.DaHood.SilentAim = v end})
    TabGame:CreateToggle({Name = "Aimlock", CurrentValue = false, Callback = function(v) Settings.DaHood.Aimlock = v end})
    TabGame:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) Settings.DaHood.Triggerbot = v end})
    TabGame:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(v) Settings.DaHood.InfiniteAmmo = v end})
    TabGame:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(v) Settings.DaHood.NoRecoil = v end})
    TabGame:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) Settings.DaHood.RapidFire = v end})
    TabGame:CreateToggle({Name = "God Mode", CurrentValue = false, Callback = function(v) Settings.DaHood.GodMode = v end})
    TabGame:CreateToggle({Name = "Auto Farm", CurrentValue = false, Callback = function(v) Settings.DaHood.AutoFarm = v end})
    TabGame:CreateToggle({Name = "Auto Str", CurrentValue = false, Callback = function(v) Settings.DaHood.AutoStr = v end})
end

if GameData.Current == "PhantomForces" then
    TabGame:CreateSection("Phantom Forces")
    TabGame:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) Settings.PhantomForces.SilentAim = v end})
    TabGame:CreateToggle({Name = "Aimlock", CurrentValue = false, Callback = function(v) Settings.PhantomForces.Aimlock = v end})
    TabGame:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) Settings.PhantomForces.Triggerbot = v end})
    TabGame:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(v) Settings.PhantomForces.InfiniteAmmo = v end})
    TabGame:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(v) Settings.PhantomForces.NoRecoil = v end})
    TabGame:CreateToggle({Name = "No Spread", CurrentValue = false, Callback = function(v) Settings.PhantomForces.NoSpread = v end})
    TabGame:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) Settings.PhantomForces.RapidFire = v end})
    TabGame:CreateToggle({Name = "No Sway", CurrentValue = false, Callback = function(v) Settings.PhantomForces.NoSway = v end})
end

if GameData.Current == "Rivals" then
    TabGame:CreateSection("Rivals")
    TabGame:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) Settings.Rivals.SilentAim = v end})
    TabGame:CreateToggle({Name = "Aimlock", CurrentValue = false, Callback = function(v) Settings.Rivals.Aimlock = v end})
    TabGame:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) Settings.Rivals.Triggerbot = v end})
    TabGame:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Callback = function(v) Settings.Rivals.InfiniteAmmo = v end})
    TabGame:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(v) Settings.Rivals.NoRecoil = v end})
    TabGame:CreateToggle({Name = "No Spread", CurrentValue = false, Callback = function(v) Settings.Rivals.NoSpread = v end})
    TabGame:CreateToggle({Name = "Rapid Fire", CurrentValue = false, Callback = function(v) Settings.Rivals.RapidFire = v end})
end

if GameData.Current == "BreakIn" then
    TabGame:CreateSection("Break In")
    TabGame:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) Settings.BreakIn.ESP = v end})
    TabGame:CreateToggle({Name = "Hitbox", CurrentValue = false, Callback = function(v) Settings.BreakIn.Hitbox = v end})
    TabGame:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) Settings.BreakIn.Fly = v end})
    TabGame:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Settings.BreakIn.Noclip = v end})
    TabGame:CreateToggle({Name = "Speed", CurrentValue = false, Callback = function(v) Settings.BreakIn.Speed = v end})
    TabGame:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Settings.BreakIn.InfiniteJump = v end})
end

if GameData.Current == "BedWars" then
    TabGame:CreateSection("BedWars")
    TabGame:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) Settings.BedWars.SilentAim = v end})
    TabGame:CreateToggle({Name = "Aimlock", CurrentValue = false, Callback = function(v) Settings.BedWars.Aimlock = v end})
    TabGame:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) Settings.BedWars.Triggerbot = v end})
    TabGame:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) Settings.BedWars.ESP = v end})
    TabGame:CreateToggle({Name = "Hitbox", CurrentValue = false, Callback = function(v) Settings.BedWars.Hitbox = v end})
    TabGame:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) Settings.BedWars.Fly = v end})
    TabGame:CreateToggle({Name = "Anti Void", CurrentValue = false, Callback = function(v) Settings.BedWars.AntiVoid = v end})
end

if GameData.Current == "MM2" then
    TabGame:CreateSection("MM2")
    TabGame:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) Settings.MM2.ESP = v end})
    TabGame:CreateToggle({Name = "Hitbox", CurrentValue = false, Callback = function(v) Settings.MM2.Hitbox = v end})
    TabGame:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) Settings.MM2.Fly = v end})
    TabGame:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Settings.MM2.Noclip = v end})
    TabGame:CreateToggle({Name = "Speed", CurrentValue = false, Callback = function(v) Settings.MM2.Speed = v end})
    TabGame:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Settings.MM2.InfiniteJump = v end})
    TabGame:CreateToggle({Name = "Auto Win", CurrentValue = false, Callback = function(v) Settings.MM2.AutoWin = v end})
end

if GameData.Current == "Jailbreak" then
    TabGame:CreateSection("Jailbreak")
    TabGame:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) Settings.Jailbreak.SilentAim = v end})
    TabGame:CreateToggle({Name = "Aimlock", CurrentValue = false, Callback = function(v) Settings.Jailbreak.Aimlock = v end})
    TabGame:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) Settings.Jailbreak.Triggerbot = v end})
    TabGame:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) Settings.Jailbreak.ESP = v end})
    TabGame:CreateToggle({Name = "Hitbox", CurrentValue = false, Callback = function(v) Settings.Jailbreak.Hitbox = v end})
    TabGame:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) Settings.Jailbreak.Fly = v end})
    TabGame:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Settings.Jailbreak.Noclip = v end})
    TabGame:CreateToggle({Name = "Speed", CurrentValue = false, Callback = function(v) Settings.Jailbreak.Speed = v end})
    TabGame:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Settings.Jailbreak.InfiniteJump = v end})
end

TabInfo:CreateSection("Account")
TabInfo:CreateParagraph({
    Title = "Your Information",
    Content = string.format("User: %s\nGame: %s\nMobile: %s\nScript: Unnamed XD Hub", 
        LocalPlayer.Name, 
        GameData.Current, 
        UserInputService.TouchEnabled and "Yes" or "No")
})
TabInfo:CreateSection("Unnamed XD Hub")
TabInfo:CreateParagraph({
    Title = "About",
    Content = "Owner: @mqp6 / Poc\nVersion: 5.0.0\nDiscord: discord.gg/rmpQfYtnWd\nGames: 9 Supported\nFeatures: 150+"
})
TabInfo:CreateButton({Name = "Copy Discord", Callback = function() if setclipboard then setclipboard("https://discord.gg/rmpQfYtnWd"); Rayfield:Notify({Title = "Copied", Content = "Discord link copied", Duration = 2}) end end})
TabInfo:CreateButton({Name = "Rejoin", Callback = function() TeleportService:Teleport(PlaceId, LocalPlayer) end})

Rayfield:Notify({Title = "Unnamed XD Hub", Content = "Loaded | " .. GameData.Current, Duration = 5})
