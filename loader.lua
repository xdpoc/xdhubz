local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- ========== KEYAUTH CONFIG ==========
-- DOUBLE CHECK THESE ON YOUR DASHBOARD
local KeyAuthApp = "XD HUB"  -- Must match EXACTLY
local KeyAuthOwner = "eDjLQhPvrs"  -- Your owner ID
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

-- ========== INITIALIZE KEYAUTH FIRST ==========
local initSuccess, initResult = initKeyAuth()
if not initSuccess then
    LocalPlayer:Kick("KeyAuth Error: " .. tostring(initResult))
    return
end

print("✅ KeyAuth Init Success - SessionID: " .. SessionID)

-- ========== LOAD RAYFIELD ==========
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ========== CUSTOM KEY UI (SIMPLE, WORKS 100%) ==========
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "XDHub_KeyAuth"
KeyGui.Parent = CoreGui

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 400, 0, 300)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
KeyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KeyGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = KeyFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "XD HUB | License Verification"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = KeyFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 30)
Subtitle.Position = UDim2.new(0, 0, 0, 60)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "🔐 Keys validated through Verified Services & Keyauth.cc"
Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
Subtitle.TextSize = 14
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 45)
KeyBox.Position = UDim2.new(0.5, -160, 0, 110)
KeyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Enter your license key"
KeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 16
KeyBox.Font = Enum.Font.Gotham
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = KeyFrame

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 6)
KeyBoxCorner.Parent = KeyBox

local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(0.8, 0, 0, 45)
LoginButton.Position = UDim2.new(0.5, -160, 0, 170)
LoginButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
LoginButton.BorderSizePixel = 0
LoginButton.Text = "LOGIN"
LoginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginButton.TextSize = 18
LoginButton.Font = Enum.Font.GothamBold
LoginButton.Parent = KeyFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = LoginButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 230)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Waiting for input..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = KeyFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Visible = false
CloseButton.Parent = KeyFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- ========== KEY LOGIC ==========
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
while not Authed do
    task.wait(0.1)
end

-- ========== LOAD MAIN HUB ==========
task.wait(0.3)

-- ========== WELCOME NOTIFICATION ==========
StarterGui:SetCore("SendNotification", {
    Title = "XD HUB Arsenal",
    Text = "Working on Mobile & PC | Welcome " .. (UserData and UserData.info and UserData.info.username or LocalPlayer.Name),
    Duration = 6
})

-- ========== ADVANCETECH FUNCTIONS ==========

-- FLY SYSTEM
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

-- HITBOX SYSTEM
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
    player.CharacterRemoving:Connect(function() restorePart(player) end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in pairs(Players:GetPlayers()) do onPlayerAdded(player) end

-- TRIGGERBOT
local triggerbot = {enabled = false, delay = 0.1}

-- SILENT AIM
local silentAim = nil
local silentAimLoaded = false

-- ========== CREATE RAYFIELD WINDOW ==========
local Window = Rayfield:CreateWindow({
    Name = "XD HUB | " .. (UserData and UserData.info and UserData.info.username or LocalPlayer.Name),
    LoadingTitle = "XD HUB Arsenal",
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
    KeySystem = false
})

-- ========== BUILD UI ==========
local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)

-- MAIN TAB
MainTab:CreateSection("Hitbox Expansion")

MainTab:CreateToggle({
    Name = "Enable Hitbox",
    CurrentValue = false,
    Callback = function(v)
        hitbox.enabled = v
        if v then updateHitboxes() else for p,_ in pairs(hitbox_original_properties) do restorePart(p) end end
    end
})

MainTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {10, 50},
    Increment = 1,
    CurrentValue = 21,
    Callback = function(v) hitbox.size = v if hitbox.enabled then updateHitboxes() end end
})

MainTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 10},
    Increment = 1,
    CurrentValue = 6,
    Callback = function(v) hitbox.transparency = v if hitbox.enabled then updateHitboxes() end end
})

MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Callback = function(v) hitbox.teamCheck = v if hitbox.enabled then updateHitboxes() end end
})

MainTab:CreateToggle({
    Name = "No Collision",
    CurrentValue = false,
    Callback = function(v) hitbox.noCollision = v if hitbox.enabled then updateHitboxes() end end
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
    Callback = function(v) if silentAim and silentAimLoaded then silentAim.WallCheck = v end end
})

MainTab:CreateToggle({
    Name = "Prediction",
    CurrentValue = false,
    Callback = function(v) if silentAim and silentAimLoaded then silentAim.Prediction.Enabled = v end end
})

MainTab:CreateSlider({
    Name = "Prediction Amount",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) if silentAim and silentAimLoaded then silentAim.Prediction.Amount = v / 1000 end end
})

MainTab:CreateToggle({
    Name = "FOV Circle",
    CurrentValue = false,
    Callback = function(v) if silentAim and silentAimLoaded then silentAim.FovSettings.Visible = v end end
})

MainTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(v) if silentAim and silentAimLoaded then silentAim.Fov = v end end
})

MainTab:CreateSection("Triggerbot")

MainTab:CreateToggle({
    Name = "Enable Triggerbot",
    CurrentValue = false,
    Callback = function(v) triggerbot.enabled = v end
})

MainTab:CreateSlider({
    Name = "Trigger Delay (ms)",
    Range = {0, 300},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(v) triggerbot.delay = v / 1000 end
})

-- PLAYER TAB
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
    end
})

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        flyState.enabled = v
        if v then startFly() else endFly() end
    end
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 150},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) flyState.speed = v end
})

-- VISUALS TAB
VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({
    Name = "ESP (Coming Soon)",
    CurrentValue = false,
    Callback = function(v) Rayfield:Notify({Title = "ESP", Content = "Coming in next update", Duration = 2}) end
})

-- INFO TAB
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
        "Owner: @mqp6 / Poc\nCreated: 2/10/2026\nDiscord: discord.gg/rmpQfYtnWd\nVersion: 1.0\nMobile: %s",
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

-- TRIGGERBOT LOOP
task.spawn(function()
    while task.wait() do
        if triggerbot.enabled and Authed then
            local m = LocalPlayer:GetMouse()
            if m.Target then
                local c = m.Target.Parent
                if c and c:FindFirstChild("Humanoid") then
                    local p = Players:GetPlayerFromCharacter(c)
                    if p and p ~= LocalPlayer then
                        task.wait(triggerbot.delay)
                        mouse1click()
                    end
                end
            end
        end
    end
end)

-- FINAL
Rayfield:Notify({
    Title = "✅ XD HUB Loaded",
    Content = "Welcome " .. (UserData and UserData.info and UserData.info.username or LocalPlayer.Name),
    Duration = 5
})
