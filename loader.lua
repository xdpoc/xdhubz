local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========== KEYAUTH CONFIG ==========
local KeyAuthApp = "XD HUB"
local KeyAuthOwner = "eDjLQhPvrs"
local KeyAuthVersion = "1.0"
local SessionID = ""
local UserData = nil
local Authed = false

-- ========== LOAD RAYFIELD ==========
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ========== KEYAUTH FUNCTIONS ==========
local function enc(s)
    s = tostring(s)
    s = s:gsub(" ", "%%20")
    s = s:gsub("&", "%%26")
    s = s:gsub("%+", "%%2B")
    s = s:gsub("%/", "%%2F")
    return s
end

local function init()
    local url = "https://keyauth.win/api/1.1/?name=" .. enc(KeyAuthApp) .. "&ownerid=" .. enc(KeyAuthOwner) .. "&type=init&ver=" .. enc(KeyAuthVersion)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok then return false, "Connection failed" end
    local ok2, dat = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or not dat then return false, "Bad response" end
    if dat.success then
        SessionID = dat.sessionid
        return true
    else
        return false, dat.message or "Init failed"
    end
end

local function checkLicense(k)
    if not k or k:gsub("%s", "") == "" then return false, "No key entered" end
    local url = "https://keyauth.win/api/1.1/?name=" .. enc(KeyAuthApp) .. "&ownerid=" .. enc(KeyAuthOwner) .. "&type=license&key=" .. enc(k) .. "&ver=" .. enc(KeyAuthVersion) .. "&sessionid=" .. enc(SessionID)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok then return false, "Connection failed" end
    local ok2, dat = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or not dat then return false, "Bad response" end
    if dat.success then
        UserData = dat
        Authed = true
        return true, dat
    else
        return false, dat.message or "Invalid key"
    end
end

-- ========== INITIALIZE KEYAUTH ==========
local initok, initmsg = init()
if not initok then
    LocalPlayer:Kick("Auth Error: " .. initmsg)
    return
end

-- ========== CREATE WINDOW WITH KEY SYSTEM ==========
local Window = Rayfield:CreateWindow({
    Name = "XD HUB",
    LoadingTitle = "XD HUB",
    LoadingSubtitle = "by @mqp6 / Poc",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "XDHub",
        FileName = "Settings"
    },
    Discord = {
        Enabled = true,
        Invite = "rmpQfYtnWd",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "XD HUB Verification",
        Subtitle = "Enter License Key",
        Note = "🔐 Keys are validated through Verified Services & Keyauth.cc",
        FileName = "XDHub_License",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"dummy"}
    }
})

-- ========== OVERRIDE KEY CHECK ==========
task.spawn(function()
    task.wait(1)
    local ks = nil
    if Rayfield and Rayfield.KeySystem then ks = Rayfield.KeySystem end
    if not ks then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "CheckKey") and type(v.CheckKey) == "function" then
                ks = v
                break
            end
        end
    end
    if ks then
        ks.CheckKey = function(key)
            if not key or key == "" then
                Rayfield:Notify({Title = "Error", Content = "Enter key", Duration = 3})
                return false
            end
            Rayfield:Notify({Title = "Verifying", Content = "Checking KeyAuth...", Duration = 2})
            local good, msg = checkLicense(key)
            if good then
                if ks.SaveKey then pcall(function() ks:SaveKey(key) end) end
                local name = UserData and UserData.info and UserData.info.username or LocalPlayer.Name
                pcall(function() Window:UpdateName("XD HUB | " .. name) end)
                Rayfield:Notify({Title = "Verified", Content = "Welcome " .. name, Duration = 4})
                return true
            else
                Rayfield:Notify({Title = "Invalid", Content = msg or "Bad key", Duration = 4})
                return false
            end
        end
    end
end)

-- ========== WAIT FOR AUTH ==========
while not Authed do task.wait(0.1) end

-- ========== WELCOME NOTIFICATION ==========
StarterGui:SetCore("SendNotification", {
    Title = "XD HUB Arsenal",
    Text = "Working on Mobile & PC",
    Duration = 6
})

StarterGui:SetCore("SendNotification", {
    Title = "Made By:",
    Text = "@mqp6 / Poc",
    Duration = 6
})

-- ========== PORTERD ADVANCETECH FUNCTIONS ==========

-- 1. FLY SYSTEM (from AdvanceTech)
local flyState = {enabled = false, speed = 50}
local c, h, bv, bav, cam, flying
local buttons = {W = false, S = false, A = false, D = false, Moving = false}

local function startFly()
    if not LocalPlayer.Character or not LocalPlayer.Character.Head or flying then return end
    c = LocalPlayer.Character
    h = c.Humanoid
    h.PlatformStand = true
    cam = Workspace:WaitForChild('Camera')
    bv = Instance.new("BodyVelocity")
    bav = Instance.new("BodyAngularVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(10000,10000,10000)
    bv.P = 1000
    bav.AngularVelocity = Vector3.new(0,0,0)
    bav.MaxTorque = Vector3.new(10000,10000,10000)
    bav.P = 1000
    bv.Parent = c.Head
    bav.Parent = c.Head
    flying = true
    h.Died:Connect(function() flying = false end)
end

local function endFly()
    if not LocalPlayer.Character or not flying then return end
    h.PlatformStand = false
    bv:Destroy()
    bav:Destroy()
    flying = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    for i, _ in pairs(buttons) do
        if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
            buttons[i] = true
            buttons.Moving = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    local a = false
    for i, _ in pairs(buttons) do
        if i ~= "Moving" then
            if input.KeyCode == Enum.KeyCode[i] then buttons[i] = false end
            if buttons[i] then a = true end
        end
    end
    buttons.Moving = a
end)

local function setVec(vec)
    return vec * (flyState.speed / vec.Magnitude)
end

RunService.Heartbeat:Connect(function(step)
    if flying and c and c.PrimaryPart then
        local p = c.PrimaryPart.Position
        local cf = cam.CFrame
        local ax, ay, az = cf:ToEulerAnglesXYZ()
        c:SetPrimaryPartCFrame(CFrame.new(p.x, p.y, p.z) * CFrame.Angles(ax, ay, az))
        if buttons.Moving then
            local t = Vector3.new()
            if buttons.W then t = t + (setVec(cf.LookVector)) end
            if buttons.S then t = t - (setVec(cf.LookVector)) end
            if buttons.A then t = t - (setVec(cf.RightVector)) end
            if buttons.D then t = t + (setVec(cf.RightVector)) end
            c:TranslateBy(t * step)
        end
    end
end)

-- 2. HITBOX SYSTEM (from AdvanceTech)
local hitbox = {
    enabled = false,
    size = 21,
    transparency = 6,
    teamCheck = false,
    noCollision = false
}
local hitbox_original_properties = {}
local defaultBodyParts = {"UpperTorso", "Head", "HumanoidRootPart"}

local function savedPart(player, part)
    if not hitbox_original_properties[player] then hitbox_original_properties[player] = {} end
    if not hitbox_original_properties[player][part.Name] then
        hitbox_original_properties[player][part.Name] = {
            CanCollide = part.CanCollide,
            Transparency = part.Transparency,
            Size = part.Size
        }
    end
end

local function restorePart(player)
    if hitbox_original_properties[player] then
        for partName, props in pairs(hitbox_original_properties[player]) do
            local part = player.Character and player.Character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.CanCollide = props.CanCollide
                part.Transparency = props.Transparency
                part.Size = props.Size
            end
        end
        hitbox_original_properties[player] = nil
    end
end

local function findPart(player, partName)
    if not player.Character then return nil end
    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name:lower():match(partName:lower()) then
            return part
        end
    end
    return nil
end

local function extendHitbox(player)
    for _, partName in ipairs(defaultBodyParts) do
        local part = player.Character and (player.Character:FindFirstChild(partName) or findPart(player, partName))
        if part and part:IsA("BasePart") then
            savedPart(player, part)
            part.CanCollide = not hitbox.noCollision
            part.Transparency = hitbox.transparency / 10
            part.Size = Vector3.new(hitbox.size, hitbox.size, hitbox.size)
        end
    end
end

local function isEnemy(player)
    if not hitbox.teamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

local function updateHitboxes()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if isEnemy(v) then
                extendHitbox(v)
            else
                restorePart(v)
            end
        end
    end
end

local function onCharacterAdded()
    task.wait(0.1)
    if hitbox.enabled then updateHitboxes() end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(function()
        restorePart(player)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in pairs(Players:GetPlayers()) do onPlayerAdded(player) end

-- 3. TRIGGERBOT
local triggerbot = {enabled = false, delay = 0.1}

-- 4. SILENT AIM MODULE (from AdvanceTech - commented but we'll add the loader)
local silentAim = nil
local silentAimLoaded = false

-- ========== BUILD UI ==========
pcall(function()
    local name = UserData and UserData.info and UserData.info.username or LocalPlayer.Name
    Window:UpdateName("XD HUB | " .. name)
end)

local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)

-- ===== MAIN TAB =====
MainTab:CreateSection("Hitbox Expansion")

MainTab:CreateToggle({
    Name = "Enable Hitbox",
    CurrentValue = false,
    Callback = function(v)
        hitbox.enabled = v
        if v then
            updateHitboxes()
        else
            for player, _ in pairs(hitbox_original_properties) do
                restorePart(player)
            end
        end
        Rayfield:Notify({Title = "Hitbox", Content = v and "On" or "Off", Duration = 1})
    end
})

MainTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {10, 50},
    Increment = 1,
    CurrentValue = 21,
    Callback = function(v)
        hitbox.size = v
        if hitbox.enabled then updateHitboxes() end
    end
})

MainTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 10},
    Increment = 1,
    CurrentValue = 6,
    Callback = function(v)
        hitbox.transparency = v
        if hitbox.enabled then updateHitboxes() end
    end
})

MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Callback = function(v)
        hitbox.teamCheck = v
        if hitbox.enabled then updateHitboxes() end
    end
})

MainTab:CreateToggle({
    Name = "No Collision",
    CurrentValue = false,
    Callback = function(v)
        hitbox.noCollision = v
        if hitbox.enabled then updateHitboxes() end
    end
})

MainTab:CreateSection("Silent Aim")

MainTab:CreateToggle({
    Name = "Load Silent Aim",
    CurrentValue = false,
    Callback = function(v)
        if v and not silentAimLoaded then
            pcall(function()
                silentAim = loadstring(game:HttpGet("https://raw.githubusercontent.com/YellowGregs/Loadstring/refs/heads/main/Arsenal_Silent-Aim.luau"))()
                silentAim.Enabled = true
                silentAimLoaded = true
                Rayfield:Notify({Title = "Silent Aim", Content = "Loaded", Duration = 2})
            end)
        elseif not v and silentAimLoaded then
            silentAim.Enabled = false
            silentAimLoaded = false
            Rayfield:Notify({Title = "Silent Aim", Content = "Unloaded", Duration = 2})
        end
    end
})

MainTab:CreateDropdown({
    Name = "Body Parts",
    Options = {"Head", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Random"},
    CurrentOption = {"Head"},
    Callback = function(v)
        if silentAim and silentAimLoaded then
            if v[1] == "Random" then
                silentAim.UseRandomPart = true
                silentAim.BodyParts = {"Head", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
            else
                silentAim.UseRandomPart = false
                silentAim.BodyParts = {v[1]}
            end
        end
    end
})

MainTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Callback = function(v)
        if silentAim and silentAimLoaded then silentAim.WallCheck = v end
    end
})

MainTab:CreateToggle({
    Name = "Prediction",
    CurrentValue = false,
    Callback = function(v)
        if silentAim and silentAimLoaded then silentAim.Prediction.Enabled = v end
    end
})

MainTab:CreateSlider({
    Name = "Prediction Amount",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        if silentAim and silentAimLoaded then silentAim.Prediction.Amount = v / 1000 end
    end
})

MainTab:CreateToggle({
    Name = "FOV Circle",
    CurrentValue = false,
    Callback = function(v)
        if silentAim and silentAimLoaded then silentAim.FovSettings.Visible = v end
    end
})

MainTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(v)
        if silentAim and silentAimLoaded then silentAim.Fov = v end
    end
})

MainTab:CreateSection("Triggerbot")

MainTab:CreateToggle({
    Name = "Enable Triggerbot",
    CurrentValue = false,
    Callback = function(v)
        triggerbot.enabled = v
        Rayfield:Notify({Title = "Triggerbot", Content = v and "On" or "Off", Duration = 1})
    end
})

MainTab:CreateSlider({
    Name = "Trigger Delay (ms)",
    Range = {0, 300},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(v)
        triggerbot.delay = v / 1000
    end
})

-- ===== PLAYER TAB =====
PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = v
            end
        end)
    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 250},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = v
            end
        end)
    end
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        if v then
            RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
        Rayfield:Notify({Title = "Noclip", Content = v and "On" or "Off", Duration = 1})
    end
})

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        flyState.enabled = v
        if v then startFly() else endFly() end
        Rayfield:Notify({Title = "Fly", Content = v and "On" or "Off", Duration = 1})
    end
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 150},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        flyState.speed = v
    end
})

-- ===== VISUALS TAB =====
VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({
    Name = "ESP (Coming Soon)",
    CurrentValue = false,
    Callback = function(v)
        Rayfield:Notify({Title = "ESP", Content = "Coming in next update", Duration = 2})
    end
})

-- ===== INFO TAB =====
InfoTab:CreateSection("Account")
InfoTab:CreateParagraph({
    Title = "Your Information",
    Content = string.format(
        "Username: %s\nEmail: %s\nExpires: %s\nPlan: %s",
        (UserData and UserData.info and UserData.info.username) or LocalPlayer.Name,
        (UserData and UserData.info and UserData.info.email) or "N/A",
        (UserData and UserData.info and UserData.info.expires) or "Lifetime",
        (UserData and UserData.info and UserData.info.subscription) or "Premium"
    )
})

InfoTab:CreateSection("XD HUB")
InfoTab:CreateParagraph({
    Title = "About",
    Content = string.format(
        "Owner: @mqp6 / Poc\nCreated: 2/10/2026\nDiscord: discord.gg/rmpQfYtnWd\nVersion: 1.0\nMobile: %s\nKeyAuth: Connected",
        UserInputService.TouchEnabled and "Yes" or "No"
    )
})

InfoTab:CreateButton({
    Name = "Copy Discord",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/rmpQfYtnWd")
            Rayfield:Notify({Title = "Copied", Content = "Discord link copied", Duration = 2})
        end
    end
})

InfoTab:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

-- ========== TRIGGERBOT LOOP ==========
task.spawn(function()
    while wait() do
        if triggerbot.enabled and Authed then
            local m = LocalPlayer:GetMouse()
            if m.Target then
                local c = m.Target.Parent
                if c and c:FindFirstChild("Humanoid") then
                    local p = Players:GetPlayerFromCharacter(c)
                    if p and p ~= LocalPlayer then
                        wait(triggerbot.delay)
                        mouse1click()
                    end
                end
            end
        end
    end
end)

-- ========== FINAL NOTIFICATION ==========
Rayfield:Notify({
    Title = "XD HUB Loaded",
    Content = "Welcome " .. (UserData and UserData.info and UserData.info.username or LocalPlayer.Name),
    Duration = 5
})
