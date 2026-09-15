if tostring(game.GameId) ~= "10690360998" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _jfaTombOx"
local _G_ALIVE = "_ _jfaAliveOx"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

-- Kill old Obsidian JFA + old Oxidelib runs
do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub" or gui.Name == "JFALoading") then
                gui:Destroy()
            end
        end
    end)
    pcall(function()
        if LP then
            local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub" or gui.Name == "JFALoading") then
                    gui:Destroy()
                end
            end
        end
    end)
end

-- ================================================================
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_jfa.txt"
    local PUSL = nil

    local function pxLoad()
        if PUSL then return true end
        local okGet, src = pcall(function() return game:HttpGet(PUSL_LIB_URL) end)
        if not okGet or type(src) ~= "string" or #src == 0 then return false end
        local chunk = loadstring(src)
        if type(chunk) ~= "function" then return false end
        local okCall, lib = pcall(chunk)
        if not okCall or type(lib) ~= "table" or type(lib.configure) ~= "function" then return false end
        PUSL = lib
        local okCfg = pcall(function()
            PUSL.configure({
                serviceId = PUSL_SERVICE_ID,
                debug = false,
                kickOnDetect = false,
            })
        end)
        if not okCfg then PUSL = nil; return false end
        return true
    end

    local function ksReadStore()
        if type(isfile) == "function" and isfile(KEYSYSTEM_STORE_PATH) then
            local okData, data = pcall(readfile, KEYSYSTEM_STORE_PATH)
            if okData and type(data) == "string" then
                local key = string.gsub(string.sub(data, 1, 80), "%s+", "")
                if #key > 0 then return key end
            end
        end
        return nil
    end

    local function ksWriteStore(key)
        if type(writefile) == "function" then
            return pcall(writefile, KEYSYSTEM_STORE_PATH, tostring(key))
        end
        return false
    end

    local function ksValidate(key)
        if not pxLoad() then return false, "Could not load Panda library (check internet)" end
        for attempt = 1, 4 do
            local okCall, ok, reason = pcall(function() return PUSL.validateEx(tostring(key)) end)
            if not okCall then break end
            if ok then return true, "" end
            if reason == "INVALID_KEY" or reason == "NO_KEY" or reason == "NO_SERVICE" then
                return false, "Invalid / expired / wrong device key"
            end
            task.wait(attempt * 1.5)
        end
        return false, "Network / server error"
    end

    local function ksGetKeyLink()
        if not pxLoad() then return nil end
        local ok, link = pcall(function() return PUSL.getKeyUrl() end)
        if ok and type(link) == "string" and #link > 0 then return link end
        return nil
    end

    local function ksShowGate(onSuccess)
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
        local old = pg:FindFirstChild("JFAKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "JFAKeyGate"
        sc.ResetOnSpawn = false
        sc.IgnoreGuiInset = true
        sc.DisplayOrder = 998
        sc.Parent = pg

        local accent = Color3.fromRGB(120, 96, 255)
        local accent2 = Color3.fromRGB(180, 160, 255)

        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundColor3 = Color3.fromRGB(9, 10, 15)
        overlay.BackgroundTransparency = 0.1
        overlay.BorderSizePixel = 0
        overlay.Parent = sc

        local card = Instance.new("Frame")
        card.Name = "Card"
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.fromScale(0.5, 0.5)
        card.Size = UDim2.fromOffset(360, 330)
        card.BackgroundColor3 = Color3.fromRGB(18, 19, 27)
        card.BorderSizePixel = 0
        card.Parent = sc
        local cardc = Instance.new("UICorner"); cardc.CornerRadius = UDim.new(0, 16); cardc.Parent = card
        local cardStroke = Instance.new("UIStroke"); cardStroke.Color = accent; cardStroke.Transparency = 0.6; cardStroke.Thickness = 1; cardStroke.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 42)
        title.Position = UDim2.fromOffset(0, 20)
        title.BackgroundTransparency = 1
        title.Text = "Jump for Animals!"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 22
        title.TextColor3 = Color3.fromRGB(240, 242, 250)
        title.Parent = card
        local titleGrad = Instance.new("UIGradient"); titleGrad.Rotation = -8; titleGrad.Color = ColorSequence.new(accent, Color3.fromRGB(220, 235, 255)); titleGrad.Parent = title

        local subtitle = Instance.new("TextLabel")
        subtitle.Size = UDim2.new(1, 0, 0, 16)
        subtitle.Position = UDim2.fromOffset(0, 62)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = "Enter your key to unlock"
        subtitle.Font = Enum.Font.Gotham
        subtitle.TextSize = 12
        subtitle.TextColor3 = Color3.fromRGB(150, 155, 172)
        subtitle.Parent = card

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, -32, 0, 40)
        status.Position = UDim2.fromOffset(16, 78)
        status.BackgroundTransparency = 1
        status.Text = ""
        status.Font = Enum.Font.Gotham
        status.TextSize = 12
        status.TextColor3 = accent2
        status.TextWrapped = true
        status.Parent = card

        local keyBox = Instance.new("TextBox")
        keyBox.Name = "KeyBox"
        keyBox.Text = ""
        keyBox.AnchorPoint = Vector2.new(0.5, 0.5)
        keyBox.Position = UDim2.fromOffset(180, 152)
        keyBox.Size = UDim2.new(0, 312, 0, 42)
        keyBox.BackgroundColor3 = Color3.fromRGB(27, 29, 40)
        keyBox.BorderSizePixel = 0
        keyBox.Font = Enum.Font.GothamBold
        keyBox.TextSize = 16
        keyBox.TextColor3 = Color3.fromRGB(240, 242, 250)
        keyBox.ClearTextOnFocus = false
        keyBox.Parent = card
        local keyBoxc = Instance.new("UICorner"); keyBoxc.CornerRadius = UDim.new(0, 10); keyBoxc.Parent = keyBox

        local function makeButton(text, posX, color)
            local btn = Instance.new("TextButton")
            btn.AnchorPoint = Vector2.new(0.5, 0.5)
            btn.Position = UDim2.fromOffset(posX, 220)
            btn.Size = UDim2.new(0, 140, 0, 42)
            btn.BackgroundColor3 = color
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.GothamBold
            btn.Text = text
            btn.TextSize = 14
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = card
            local btnc = Instance.new("UICorner"); btnc.CornerRadius = UDim.new(0, 10); btnc.Parent = btn
            return btn
        end

        local getBtn = makeButton("Get Key", 90, accent)
        getBtn.Name = "GetKeyBtn"
        local verifyBtn = makeButton("Verify", 270, Color3.fromRGB(52, 58, 82))
        verifyBtn.Name = "VerifyBtn"

        local hint = Instance.new("TextLabel")
        hint.Size = UDim2.new(1, -32, 0, 30)
        hint.Position = UDim2.fromOffset(16, 268)
        hint.BackgroundTransparency = 1
        hint.Text = "Open the link, complete the ad, then paste your key."
        hint.Font = Enum.Font.Gotham
        hint.TextSize = 11
        hint.TextColor3 = Color3.fromRGB(120, 124, 140)
        hint.TextWrapped = true
        hint.Parent = card

        local done = false
        getBtn.MouseButton1Click:Connect(function()
            local link = ksGetKeyLink()
            if link then
                pcall(setclipboard, link)
                status.Text = "Get key link copied to clipboard."
            else
                status.Text = "Could not fetch get-key link."
            end
        end)
        verifyBtn.MouseButton1Click:Connect(function()
            if done then return end
            local key = string.gsub(keyBox.Text, "%s+", "")
            if key == "" then status.Text = "Enter your key first." return end
            status.Text = "Verifying..."
            task.spawn(function()
                local okVal, msg = ksValidate(key)
                if done then return end
                if okVal then
                    ksWriteStore(key)
                    status.Text = "Key verified."
                    done = true
                    task.wait(0.35)
                    sc:Destroy()
                    onSuccess()
                else
                    status.Text = "Failed: " .. msg
                end
            end)
        end)

        return sc
    end

    do
        local storeKey = ksReadStore()
        local unlocked = false
        if storeKey then
            local okVal = ksValidate(storeKey)
            if okVal then unlocked = true end
        end
        if not unlocked then
            local gateDone = false
            local gui = ksShowGate(function() gateDone = true end)

            while not gateDone do
                if rawget(_G, _G_TOMB) then
                    pcall(function() gui:Destroy() end)
                    return
                end
                task.wait(0.1)
            end
            if gui and gui.Parent then
                pcall(function() gui:Destroy() end)
            end
        end
    end
end

-- ================================================================
-- CONFIG
-- ================================================================
local Config = {
    autoTrain = false,
    autoCollect = false,
    collectDelay = 0.3,
    collectArea = "All",
    autoPlace = true,
    autoTpOpEgg = false,
    guardDropBlock = false,
    walkEnabled = false,
    walkSpeed = 50,
    jumpEnabled = false,
    jumpPower = 100,
    tpToHome = false,
    homeKey = Enum.KeyCode.Q,
}

local AREAS = { "All", "Celestial Heights", "Coral Reef", "Crystal Mines", "Desert", "Jungle", "Meadow", "Mystic Isles", "Prehistoric", "Savannah", "Winter" }

local AREA_POSITIONS = {
    ["Coral Reef"] = Vector3.new(0.6, 15, -196),
    ["Meadow"] = Vector3.new(0, -3, -133),
    ["Mystic Isles"] = Vector3.new(-2, 1702, -966),
    ["Prehistoric"] = Vector3.new(0.6, 2561, -1103),
    ["Celestial Heights"] = Vector3.new(-0.6, 3234, -1175),
    ["Savannah"] = Vector3.new(0, 4952, -1315),
    ["Winter"] = Vector3.new(0.6, 72, -336),
    ["Desert"] = Vector3.new(-0.6, 255, -478),
    ["Crystal Mines"] = Vector3.new(-0.6, 541, -617),
    ["Jungle"] = Vector3.new(-0.6, 906, -757),
}

local TELEPORT_AREAS = { "Coral Reef", "Meadow", "Mystic Isles", "Prehistoric", "Celestial Heights", "Savannah", "Winter", "Desert", "Crystal Mines", "Jungle" }

local originalWalkSpeed = 16
local originalJumpPower = 50
local homePosition = nil

-- ================================================================
-- HELPERS
-- ================================================================
local function getRemotes()
    return ReplicatedStorage:WaitForChild("Remotes", 10)
end

local function teleportTo(pos)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
end

-- ================================================================
-- GUARD DROP BLOCK
-- ================================================================
local guardDropHooked = false
local oldNamecall = nil

local function hookGuardDrop()
    if guardDropHooked then return end
    if not hookmetamethod or not getnamecallmethod then
        warn("[JFA] hookmetamethod not available")
        return
    end
    local Remotes = getRemotes()
    if not Remotes then return end
    local dropRemote = Remotes:FindFirstChild("DropEggRequest")
    if not dropRemote then return end
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Config.guardDropBlock and method == "FireServer" and self == dropRemote then
            return nil
        end
        return oldNamecall(self, ...)
    end))
    guardDropHooked = true
end

-- ================================================================
-- AUTO TRAIN
-- ================================================================
local function getSquatDetector()
    local plot = LP:FindFirstChild("Plot")
    if not plot then return nil end
    local plotVal = plot.Value
    if not plotVal then return nil end
    local squatZone = plotVal:FindFirstChild("SquatZone")
    if not squatZone then return nil end
    local floor = squatZone:FindFirstChild("Floor")
    if not floor then return nil end
    return floor:FindFirstChild("Detector")
end

local function autoTrainTick()
    if not Config.autoTrain then return end
    if LP:GetAttribute("IsSquatting") == true then return end

    local Remotes = getRemotes()
    if not Remotes then return end
    local squatReq = Remotes:FindFirstChild("SquatTrainingRequest")
    if not squatReq then return end

    local detector = getSquatDetector()
    if not detector then return end

    local tutorialStep = LP:GetAttribute("TutorialStep")
    if LP:GetAttribute("TutorialCompleted") ~= true
        and tutorialStep ~= "ReachTrain"
        and tutorialStep ~= "Train" then
        return
    end

    teleportTo(detector.Position)
    task.wait(0.1)
    squatReq:FireServer(detector)
end

local function stopTraining()
    if LP:GetAttribute("IsSquatting") == true then
        local Remotes = getRemotes()
        if Remotes then
            local stopReq = Remotes:FindFirstChild("StopSquattingRequest")
            if stopReq then
                pcall(function() stopReq:FireServer() end)
            end
        end
    end
end

local function autoSquatBonusTick()
    if not Config.autoTrain then return end
    if LP:GetAttribute("IsSquatting") ~= true then return end
    if LP:GetAttribute("SquatBonusAvailable") ~= true then return end

    local Remotes = getRemotes()
    if not Remotes then return end
    local bonusReq = Remotes:FindFirstChild("SquatBonusRequest")
    if not bonusReq then return end

    local version = tonumber(LP:GetAttribute("SquatBonusVersion")) or 0
    pcall(function() bonusReq:FireServer(version) end)
end

-- ================================================================
-- AUTO COLLECT EGGS
-- ================================================================
local function getPlotPosition()
    local plot = LP:FindFirstChild("Plot")
    if not plot then return nil end
    local plotVal = plot.Value
    if not plotVal then return nil end
    local settings = ReplicatedStorage:FindFirstChild("Settings")
    if settings then
        local eggs = settings:FindFirstChild("Eggs")
        if eggs then
            local ok, eggsMod = pcall(require, eggs)
            if ok and eggsMod.Placement then
                local region = plotVal:FindFirstChild(eggsMod.Placement.RegionName)
                if region and region:IsA("BasePart") then
                    return region.Position + Vector3.new(0, 3, 0)
                end
            end
        end
    end
    return plotVal.Position + Vector3.new(0, 3, 0)
end

local function getCarriedEggTool()
    local char = LP.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("IsEggTool") then
                return child
            end
        end
    end
    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("IsEggTool") then
                return child
            end
        end
    end
    return nil
end

local function autoCollectTick()
    if not Config.autoCollect then return end

    local carried = LP:GetAttribute("CarriedEggCount") or 0
    if carried > 0 then
        if Config.autoPlace then
            local plotPos = getPlotPosition()
            if plotPos then
                teleportTo(plotPos)
                task.wait(0.15)
                local tool = getCarriedEggTool()
                if tool then
                    local eggId = tool:GetAttribute("EggId")
                    if eggId then
                        local Remotes = getRemotes()
                        if Remotes then
                            local placeReq = Remotes:FindFirstChild("PlaceEggRequest")
                            if placeReq then
                                for i = 1, 3 do
                                    local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                                    pcall(function() placeReq:FireServer(eggId, plotPos + offset) end)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
        end
        return
    end

    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest = nil
    local nearDist = math.huge
    local nearPos = nil

    for _, att in ipairs(CollectionService:GetTagged("DynamicEggPrompt")) do
        if att:IsA("Attachment") then
            if Config.collectArea ~= "All" then
                local path = att:GetFullName()
                if not path:find("Stages%." .. Config.collectArea:gsub("%-", "%%-")) then
                    continue
                end
            end
            for _, prompt in ipairs(att:GetChildren()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Name == "CollectPrompt" then
                    local ov = att:FindFirstChild("EggRoot")
                    local target = ov and ov.Value
                    if not target then target = att:FindFirstAncestorOfClass("Model") end
                    if target then
                        local pos = target:IsA("BasePart") and target.Position or (target:IsA("Model") and target:GetPivot().Position or nil)
                        if pos then
                            local dist = (hrp.Position - pos).Magnitude
                            if dist < nearDist then
                                nearDist = dist
                                nearest = prompt
                                nearPos = pos
                            end
                        end
                    end
                end
            end
        end
    end

    if not nearest or not nearPos then return end

    teleportTo(nearPos)
    task.wait(0.2)
    nearest:InputHoldBegin()
    task.wait(nearest.HoldDuration + 0.5)
    nearest:InputHoldEnd()
    task.wait(Config.collectDelay)
end

-- ================================================================
-- SERVER HOP
-- ================================================================
local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    local ok, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if ok and result then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(result) end)
        if decodeOk and data and data.data then
            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        end
    end
    if #servers > 0 then
        local target = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, target, LP)
    else
        TeleportService:Teleport(placeId)
    end
end

-- ================================================================
-- WALKSPEED / JUMPOWER
-- ================================================================
local function applyStats(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Config.walkEnabled then
        hum.WalkSpeed = Config.walkSpeed
    end
    if Config.jumpEnabled then
        hum.JumpPower = Config.jumpPower
    end
end

-- ================================================================
-- OP EGG TRACKER
-- ================================================================
local opEggTpSent = false

local function getOpEggCountdown()
    local Map = workspace:FindFirstChild("Map")
    if not Map then return nil, false, false end
    local enabled = Map:GetAttribute("SecretSpawnEnabled")
    if enabled == false then return nil, false, false end
    local queued = Map:GetAttribute("SecretSpawnQueued")
    local endsAt = Map:GetAttribute("SecretSpawnEndsAt")
    local now = workspace:GetServerTimeNow()
    local remaining = endsAt and math.max(math.ceil(endsAt - now), 0) or 0
    return remaining, queued == true, true
end

local function opEggTick()
    if not Config.autoTpOpEgg then return end
    local remaining, queued, enabled = getOpEggCountdown()
    if not enabled then return end

    if remaining == 0 and not queued then
        if not opEggTpSent then
            local pos = AREA_POSITIONS["Prehistoric"]
            if pos then
                teleportTo(pos)
                opEggTpSent = true
            end
        end
    else
        opEggTpSent = false
    end
end

-- ================================================================
-- MAIN LOOP
-- ================================================================
task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        pcall(autoTrainTick)
        pcall(autoSquatBonusTick)
        pcall(autoCollectTick)
        pcall(opEggTick)
        task.wait(0.1)
    end
end)

LP.CharacterAdded:Connect(function(char)
    originalWalkSpeed = 16
    originalJumpPower = 50
    task.wait(0.5)
    applyStats(char)
end)

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        applyStats(LP.Character)
        task.wait(0.2)
    end
end)

-- ================================================================
-- TP TO HOME KEYBIND (Q)
-- ================================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.homeKey and Config.tpToHome then
        if homePosition then
            teleportTo(homePosition)
        end
    end
end)

-- ================================================================
-- UI — Oxidelib
-- ================================================================
local Library = nil
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library then return end

Library.ConfigFolder = "exlumiaa"

local logoId = nil
pcall(function()
    if isfile and isfile("exlumiaa_logo.png") then
        logoId = getcustomasset("exlumiaa_logo.png")
    end
end)

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Jump for Animals!",
    Size = UDim2.fromOffset(700, 490),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Jump for Animals!",
    LoadingFooter = "by Exlumiaa Hub",
    Logo = logoId,
    GuiName = "ExlumiaaHub",
})

if logoId then
    pcall(function()
        if Window.Logo then Window.Logo.Image = logoId end
        if Window.Watermark then Window.Watermark.Image = logoId end
    end)
end

-- ======================== HOME TAB ========================
local HomeTab = Window:AddTab({ Name = "Home", Icon = "home", Subtitle = "Info" })
local InfoSub = HomeTab:AddSubTab("Info")

InfoSub:AddSection("Player")
local labelHealth = InfoSub:AddLabel({ Text = "Health: -" })
local labelPos = InfoSub:AddLabel({ Text = "Pos: -" })
local labelWS = InfoSub:AddLabel({ Text = "WalkSpeed: -" })
local labelJP = InfoSub:AddLabel({ Text = "JumpPower: -" })

InfoSub:AddSection("Server")
InfoSub:AddLabel({ Text = "Place: " .. tostring(game.PlaceId) })
InfoSub:AddLabel({ Text = "Job: " .. tostring(game.JobId) })
local labelPing = InfoSub:AddLabel({ Text = "Ping: --" })
local labelPlayers = InfoSub:AddLabel({ Text = "Players: --" })
InfoSub:AddLabel({ Text = "by exlumiaa1" })

InfoSub:AddDivider()
local opEggLabel = InfoSub:AddLabel({ Text = "Divine Egg: loading..." })

-- Ping/pos/health updater
task.spawn(function()
    local avgMs = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        pcall(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                labelHealth:Set("Health: " .. ("%d/%d"):format(math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5)))
            end
            if hrp then
                local p = hrp.Position
                labelPos:Set(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
            end
            if hum then
                labelWS:Set("WalkSpeed: " .. ("%.1f"):format(hum.WalkSpeed))
                labelJP:Set("JumpPower: " .. ("%.1f"):format(hum.JumpPower))
            end
            local stats = game:GetService("Stats")
            local pingItem = stats.Network.ServerStatsItem["Data Ping"]
            avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
            labelPing:Set("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
            labelPlayers:Set("Players: " .. #Players:GetPlayers())

            local remaining, queued, enabled = getOpEggCountdown()
            if not enabled then
                opEggLabel:Set("Divine Egg: disabled")
            elseif queued then
                opEggLabel:Set("Divine Egg: NEXT RESTOCK!")
            elseif remaining and remaining > 0 then
                local m = math.floor(remaining / 60)
                local s = remaining % 60
                opEggLabel:Set(("Divine Egg: %dm %ds"):format(m, s))
            else
                opEggLabel:Set("Divine Egg: SPAWNED!")
            end
        end)
    end
end)

-- ======================== MAIN TAB ========================
local MainTab = Window:AddTab({ Name = "Main", Icon = "zap", Subtitle = "Farming" })
local FarmSub = MainTab:AddSubTab("Farm")
local MoveSub = MainTab:AddSubTab("Movement")
local TpSub = MainTab:AddSubTab("Teleport")
local GuardSub = MainTab:AddSubTab("Guard")

FarmSub:AddSection("Auto Train")
FarmSub:AddToggle({ Name = "Auto Squat Train", Default = Config.autoTrain, Flag = "jfa_train", Callback = function(s)
    Config.autoTrain = s
    if not s then pcall(stopTraining) end
end })
FarmSub:AddLabel({ Text = "Includes auto 2X bonus" })

FarmSub:AddDivider()

FarmSub:AddSection("Auto Collect Eggs")
FarmSub:AddToggle({ Name = "Auto Collect", Default = Config.autoCollect, Flag = "jfa_collect", Callback = function(s)
    Config.autoCollect = s
end })
FarmSub:AddDropdown({ Name = "Area", Options = AREAS, Default = Config.collectArea, Flag = "jfa_area", Callback = function(v)
    Config.collectArea = v
end })
FarmSub:AddSlider({ Name = "Collect Delay", Min = 1, Max = 20, Default = Config.collectDelay * 10, Suffix = "x0.1s", Flag = "jfa_collect_delay", Callback = function(v)
    Config.collectDelay = v / 10
end })
FarmSub:AddToggle({ Name = "Auto Place on Plot", Default = Config.autoPlace, Flag = "jfa_autoplace", Callback = function(s)
    Config.autoPlace = s
end })

MoveSub:AddSection("WalkSpeed")
MoveSub:AddToggle({ Name = "WalkSpeed", Default = Config.walkEnabled, Flag = "jfa_ws_toggle", Callback = function(s)
    Config.walkEnabled = s
    if not s then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = originalWalkSpeed end
    end
end })
MoveSub:AddSlider({ Name = "Speed", Min = 16, Max = 300, Default = Config.walkSpeed, Suffix = " studs/s", Flag = "jfa_ws_val", Callback = function(v)
    Config.walkSpeed = v
end })

MoveSub:AddDivider()

MoveSub:AddSection("JumpPower")
MoveSub:AddToggle({ Name = "Jump Power", Default = Config.jumpEnabled, Flag = "jfa_jp_toggle", Callback = function(s)
    Config.jumpEnabled = s
    if not s then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = originalJumpPower end
    end
end })
MoveSub:AddSlider({ Name = "Power", Min = 50, Max = 500, Default = Config.jumpPower, Suffix = " studs", Flag = "jfa_jp_val", Callback = function(v)
    Config.jumpPower = v
end })

GuardSub:AddSection("Guard")
GuardSub:AddToggle({ Name = "Guard Drop Block", Default = Config.guardDropBlock, Flag = "jfa_guard", Callback = function(s)
    Config.guardDropBlock = s
    if s then hookGuardDrop() end
end })

-- ======================== TELEPORT SUBTAB ========================
TpSub:AddSection("TP To Home")
TpSub:AddToggle({ Name = "TP To Home (Toggle Q)", Default = Config.tpToHome, Flag = "jfa_tphome", Callback = function(s)
    Config.tpToHome = s
    if s then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            homePosition = hrp.Position
        end
    end
end })
local homeLabel = TpSub:AddLabel({ Text = "Home: not set" })

TpSub:AddDivider()

TpSub:AddSection("Server Hop")
TpSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        Window:Notify({ Title = "Server Hop", Content = "Finding a new server...", Type = "info", Duration = 3 })
        task.spawn(function()
            local ok, err = pcall(serverHop)
            if not ok then
                Window:Notify({ Title = "Server Hop", Content = "Failed: " .. tostring(err), Type = "error", Duration = 5 })
            end
        end)
    end,
})

TpSub:AddDivider()

TpSub:AddSection("Teleport to Area")
local tpArea = "Meadow"
TpSub:AddDropdown({ Name = "Area", Options = TELEPORT_AREAS, Default = tpArea, Flag = "jfa_tparea", Callback = function(v)
    tpArea = v
end })
TpSub:AddButton({
    Name = "Teleport",
    Primary = false,
    Callback = function()
        local pos = AREA_POSITIONS[tpArea]
        if pos then teleportTo(pos) end
    end,
})

TpSub:AddDivider()
TpSub:AddSection("OP Egg Tracker")
TpSub:AddToggle({ Name = "Auto TP When Spawned", Default = Config.autoTpOpEgg, Flag = "jfa_opegg", Callback = function(s)
    Config.autoTpOpEgg = s
    opEggTpSent = false
end })

-- Home label updater
task.spawn(function()
    while true do
        task.wait(0.5)
        if rawget(_G, _G_TOMB) then break end
        if homeLabel then
            if homePosition then
                homeLabel:Set(("Home: %.0f, %.0f, %.0f"):format(homePosition.X, homePosition.Y, homePosition.Z))
            else
                homeLabel:Set("Home: not set")
            end
        end
    end
end)

-- ======================== SETTINGS TAB ========================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
local HopSub = SettingsTab:AddSubTab("Server Hop")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "jfa_config_selected",
    Callback = function(v) selectedConfig = v end,
})

local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
        configDropdown:Refresh()
    end
end

local configInput = ConfigSub:AddInput({
    Name = "Config Name",
    Default = "",
    Placeholder = "Enter config name...",
    Flag = "jfa_config_name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            Window:Notify({ Title = "Config", Content = "Enter a name first!", Type = "warning", Duration = 3 })
            return
        end
        local ok = Library:SaveConfig(name)
        if ok then
            refreshConfigList()
            Window:Notify({ Title = "Config", Content = "Saved: " .. name, Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Config", Content = "Save failed!", Type = "error", Duration = 3 })
        end
    end,
})

ConfigSub:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({ Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3 })
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            Window:Notify({ Title = "Config", Content = "Loaded: " .. selectedConfig, Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Config", Content = "Failed to load!", Type = "error", Duration = 3 })
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({ Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3 })
            return
        end
        Library:DeleteConfig(selectedConfig)
        selectedConfig = ""
        refreshConfigList()
        Window:Notify({ Title = "Config", Content = "Deleted config.", Type = "info", Duration = 3 })
    end,
})

HopSub:AddSection("Server Hop")
HopSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        Window:Notify({ Title = "Server Hop", Content = "Finding a new server...", Type = "info", Duration = 3 })
        task.spawn(function()
            local ok, err = pcall(serverHop)
            if not ok then
                Window:Notify({ Title = "Server Hop", Content = "Failed: " .. tostring(err), Type = "error", Duration = 5 })
            end
        end)
    end,
})

-- ================================================================
-- CLEANUP
-- ================================================================
local function teardown()
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_ALIVE, nil)
    pcall(stopTraining)
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = originalWalkSpeed
            hum.JumpPower = originalJumpPower
        end
    end
    if Window and type(Window.Destroy) == "function" then
        pcall(function() Window:Destroy() end)
    end
end

if STATE and STATE.onCleanup then
    STATE.onCleanup(teardown)
end

-- Load last config on startup (after UI exists)
pcall(function() Library:LoadConfig("default") end)