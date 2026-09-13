local JFA_GAME_ID = 10690360998
if tostring(game.GameId) ~= tostring(JFA_GAME_ID) then
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local _G_KEY = "_ _jfaTomb"
local _G_ALIVE = "_ _jfaAlive"
local _G_LIB = "_ _jfaLib"
local _G_GUI = "_ _jfaGui"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_KEY, true)
        task.wait(0.6)
    end
    rawset(_G, _G_KEY, false)
    rawset(_G, _G_ALIVE, true)
end

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
        if not okCfg then PUSL = nil return false end
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
        keyBox.Font = Enum.Font.GothamSemibold
        keyBox.TextSize = 16
        keyBox.TextColor3 = Color3.fromRGB(240, 242, 250)
        keyBox.PlaceholderText = ""
        keyBox.PlaceholderColor3 = Color3.fromRGB(110, 114, 130)
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
                if rawget(_G, _G_KEY) then
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
    guiKey = Enum.KeyCode.RightShift,
    homeKey = Enum.KeyCode.Q,
}

local AREAS = {"All", "Celestial Heights", "Coral Reef", "Crystal Mines", "Desert", "Jungle", "Meadow", "Mystic Isles", "Prehistoric", "Savannah", "Winter"}

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

local TELEPORT_AREAS = {"Coral Reef", "Meadow", "Mystic Isles", "Prehistoric", "Celestial Heights", "Savannah", "Winter", "Desert", "Crystal Mines", "Jungle"}

local originalWalkSpeed = 16
local originalJumpPower = 50
local homePosition = nil
local Library = nil
local healthLabel, posLabel, wsLabel, jpLabel, pingLabel, playerCountLabel

local SETTINGS_PATH = "ExlumiaHub/jfa_settings.json"

local function saveSettings()
    local data = {
        autoTrain = Config.autoTrain,
        autoCollect = Config.autoCollect,
        collectArea = Config.collectArea,
        autoPlace = Config.autoPlace,
        autoTpOpEgg = Config.autoTpOpEgg,
        guardDropBlock = Config.guardDropBlock,
        walkEnabled = Config.walkEnabled,
        walkSpeed = Config.walkSpeed,
        jumpEnabled = Config.jumpEnabled,
        jumpPower = Config.jumpPower,
        tpToHome = Config.tpToHome,
    }
    if homePosition then
        data.homeX = homePosition.X
        data.homeY = homePosition.Y
        data.homeZ = homePosition.Z
    end
    if type(writefile) == "function" then
        pcall(writefile, SETTINGS_PATH, game:GetService("HttpService"):JSONEncode(data))
    end
end

local function loadSettings()
    if type(isfile) ~= "function" or not isfile(SETTINGS_PATH) then return false end
    local ok, raw = pcall(readfile, SETTINGS_PATH)
    if not ok or type(raw) ~= "string" then return false end
    local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
    if not ok2 or type(data) ~= "table" then return false end
    for k, v in pairs(data) do
        if Config[k] ~= nil then
            Config[k] = v
        end
    end
    if data.homeX and data.homeY and data.homeZ then
        homePosition = Vector3.new(data.homeX, data.homeY, data.homeZ)
    end
    return true
end

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

-- ========== Guard Drop Block ==========
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

-- ========== Auto Train ==========
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

-- ========== Auto Squat Bonus (2X Multiplier) ==========
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

-- ========== Auto Collect Eggs ==========
local function getEggPrompts()
    local prompts = {}
    for _, tag in ipairs({"DynamicEggPrompt", "DynamicProximityPrompt"}) do
        for _, obj in ipairs(CollectionService:GetTagged(tag)) do
            if obj:IsA("Attachment") or obj:IsA("BasePart") then
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("ProximityPrompt") and child.Enabled then
                        table.insert(prompts, child)
                    end
                end
            end
        end
    end
    return prompts
end

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

-- ========== Server Hop ==========
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

-- ========== WalkSpeed & JumpPower ==========
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

-- ========== TP To Home ==========
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.homeKey and Config.tpToHome then
        if homePosition then
            teleportTo(homePosition)
        end
    end
end)

-- ========== OP Egg Tracker ==========
local opEggLabel = nil
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

-- ========== Main Loops ==========
task.spawn(function()
    while true do
        if rawget(_G, _G_KEY) then break end
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
        if rawget(_G, _G_KEY) then break end
        applyStats(LP.Character)
        task.wait(0.2)
    end
end)

-- ========== Loading Splash ==========
local splashGui = Instance.new("ScreenGui")
splashGui.Name = "JFALoading"
splashGui.ResetOnSpawn = false
splashGui.IgnoreGuiInset = true
splashGui.DisplayOrder = 997
splashGui.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("CoreGui")

local splashOverlay = Instance.new("Frame")
splashOverlay.Size = UDim2.fromScale(1, 1)
splashOverlay.BackgroundColor3 = Color3.fromRGB(9, 10, 15)
splashOverlay.BackgroundTransparency = 0.1
splashOverlay.BorderSizePixel = 0
splashOverlay.Parent = splashGui

local splashCard = Instance.new("Frame")
splashCard.AnchorPoint = Vector2.new(0.5, 0.5)
splashCard.Position = UDim2.fromScale(0.5, 0.5)
splashCard.Size = UDim2.fromOffset(320, 180)
splashCard.BackgroundColor3 = Color3.fromRGB(18, 19, 27)
splashCard.BorderSizePixel = 0
splashCard.Parent = splashGui
Instance.new("UICorner", splashCard).CornerRadius = UDim.new(0, 16)
local cardStroke = Instance.new("UIStroke", splashCard)
cardStroke.Color = Color3.fromRGB(120, 96, 255)
cardStroke.Transparency = 0.6
cardStroke.Thickness = 1

local splashTitle = Instance.new("TextLabel")
splashTitle.Size = UDim2.new(1, 0, 0, 36)
splashTitle.Position = UDim2.fromOffset(0, 24)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "Jump for Animals!"
splashTitle.Font = Enum.Font.GothamBold
splashTitle.TextSize = 22
splashTitle.TextColor3 = Color3.fromRGB(240, 242, 250)
splashTitle.Parent = splashCard
Instance.new("UIGradient", splashTitle).Color = ColorSequence.new(Color3.fromRGB(120, 96, 255), Color3.fromRGB(220, 235, 255))

local splashStatus = Instance.new("TextLabel")
splashStatus.Size = UDim2.new(1, -40, 0, 16)
splashStatus.Position = UDim2.fromOffset(20, 72)
splashStatus.BackgroundTransparency = 1
splashStatus.Text = "Loading..."
splashStatus.Font = Enum.Font.Gotham
splashStatus.TextSize = 12
splashStatus.TextColor3 = Color3.fromRGB(150, 155, 172)
splashStatus.Parent = splashCard

local splashBarBg = Instance.new("Frame")
splashBarBg.Size = UDim2.new(1, -40, 0, 8)
splashBarBg.Position = UDim2.fromOffset(20, 100)
splashBarBg.BackgroundColor3 = Color3.fromRGB(27, 29, 40)
splashBarBg.BorderSizePixel = 0
splashBarBg.Parent = splashCard
Instance.new("UICorner", splashBarBg).CornerRadius = UDim.new(0, 4)

local splashBarFill = Instance.new("Frame")
splashBarFill.Size = UDim2.new(0, 0, 1, 0)
splashBarFill.BackgroundColor3 = Color3.fromRGB(120, 96, 255)
splashBarFill.BorderSizePixel = 0
splashBarFill.Parent = splashBarBg
Instance.new("UICorner", splashBarFill).CornerRadius = UDim.new(0, 4)

local splashFooter = Instance.new("TextLabel")
splashFooter.Size = UDim2.new(1, 0, 0, 14)
splashFooter.Position = UDim2.fromOffset(0, 124)
splashFooter.BackgroundTransparency = 1
splashFooter.Text = "by Exlumiaa Hub"
splashFooter.Font = Enum.Font.Gotham
splashFooter.TextSize = 11
splashFooter.TextColor3 = Color3.fromRGB(100, 104, 120)
splashFooter.Parent = splashCard

local splashDots = ""
local splashDone = false
task.spawn(function()
    local totalSteps = 10
    local stepTime = 0.15
    for i = 1, totalSteps do
        if not splashGui.Parent then break end
        local dots = string.rep(".", (i - 1) % 4 + 1)
        splashStatus.Text = "Loading" .. dots
        local pct = i / totalSteps
        local tween = game:GetService("TweenService"):Create(splashBarFill, TweenInfo.new(stepTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(pct, 0, 1, 0)})
        tween:Play()
        task.wait(stepTime)
    end
    splashStatus.Text = "Ready!"
    splashDone = true
end)

-- ========== Obsidian UI ==========
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil then break end
    task.wait(0.25)
end

while not splashDone and splashGui.Parent do
    task.wait(0.1)
end

task.wait(0.3)
local ts = game:GetService("TweenService")
local tw = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
ts:Create(splashOverlay, tw, {BackgroundTransparency = 1}):Play()
ts:Create(splashCard, tw, {BackgroundTransparency = 1}):Play()
ts:Create(splashTitle, tw, {TextTransparency = 1}):Play()
ts:Create(splashStatus, tw, {TextTransparency = 1}):Play()
ts:Create(splashFooter, tw, {TextTransparency = 1}):Play()
ts:Create(splashBarFill, tw, {BackgroundTransparency = 1}):Play()
ts:Create(splashBarBg, tw, {BackgroundTransparency = 1}):Play()
ts:Create(cardStroke, tw, {Transparency = 1}):Play()
task.wait(0.4)
splashGui:Destroy()

if Library then
    loadSettings()
    local Window = Library:CreateWindow({
        Title = "Jump for Animals!",
        Footer = "by Exlumiaa Hub",
        AutoShow = true,
        Center = true,
        Resizable = true,
        CornerRadius = 6,
        ToggleKeybind = Config.guiKey,
    })

    local HomeTab = Window:AddTab("Home", "home")
    local PlayerSection = HomeTab:AddLeftGroupbox("Player")
    healthLabel = PlayerSection:AddLabel("Health: -")
    posLabel = PlayerSection:AddLabel("Pos: -")
    wsLabel = PlayerSection:AddLabel("WalkSpeed: -")
    jpLabel = PlayerSection:AddLabel("JumpPower: -")

    local ServerSection = HomeTab:AddRightGroupbox("Server")
    ServerSection:AddLabel("Place: " .. tostring(game.PlaceId))
    ServerSection:AddLabel("Job: " .. tostring(game.JobId))
    pingLabel = ServerSection:AddLabel("Ping: --")
    playerCountLabel = ServerSection:AddLabel("Players: --")
    ServerSection:AddLabel("by exlumiaa1")

    local MainTab = Window:AddTab("Main", "zap")

    local TrainSection = MainTab:AddLeftGroupbox("Auto Train")
    TrainSection:AddToggle("AutoTrain", {
        Text = "Auto Squat Train",
        Default = Config.autoTrain,
        Callback = function(s)
            Config.autoTrain = s
            if not s then pcall(stopTraining) end
        end,
    })
    TrainSection:AddLabel("Includes auto 2X bonus")

    local CollectSection = MainTab:AddLeftGroupbox("Auto Collect Eggs")
    CollectSection:AddToggle("AutoCollect", {
        Text = "Auto Collect",
        Default = Config.autoCollect,
        Callback = function(s)
            Config.autoCollect = s
        end,
    })
    CollectSection:AddDropdown("CollectArea", {
        Text = "Area",
        Values = AREAS,
        Default = Config.collectArea,
        Callback = function(v) Config.collectArea = v end,
    })
    CollectSection:AddToggle("AutoPlace", {
        Text = "Auto Place on Plot",
        Default = Config.autoPlace,
        Callback = function(s)
            Config.autoPlace = s
        end,
    })

    local GuardSection = MainTab:AddRightGroupbox("Guard")
    GuardSection:AddToggle("GuardDropBlock", {
        Text = "Guard Drop Block",
        Default = Config.guardDropBlock,
        Callback = function(s)
            Config.guardDropBlock = s
            if s then hookGuardDrop() end
        end,
    })

    local WalkSection = MainTab:AddRightGroupbox("WalkSpeed")
    WalkSection:AddToggle("Walkspeed", {
        Text = "WalkSpeed",
        Default = Config.walkEnabled,
        Callback = function(s)
            Config.walkEnabled = s
            if not s then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = originalWalkSpeed end
            end
        end,
    })
    WalkSection:AddSlider("WalkSpeedValue", {
        Text = "Speed",
        Default = Config.walkSpeed,
        Min = 16,
        Max = 300,
        Rounding = 0,
        Suffix = " studs/s",
        Callback = function(v) Config.walkSpeed = v end,
    })

    local JumpSection = MainTab:AddRightGroupbox("JumpPower")
    JumpSection:AddToggle("JumpPower", {
        Text = "Jump Power",
        Default = Config.jumpEnabled,
        Callback = function(s)
            Config.jumpEnabled = s
            if not s then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = originalJumpPower end
            end
        end,
    })
    JumpSection:AddSlider("JumpPowerValue", {
        Text = "Power",
        Default = Config.jumpPower,
        Min = 50,
        Max = 500,
        Rounding = 0,
        Suffix = " studs",
        Callback = function(v) Config.jumpPower = v end,
    })

    local HomeSection = MainTab:AddLeftGroupbox("TP To Home")
    HomeSection:AddToggle("TpToHome", {
        Text = "TP To Home (Toggle Q)",
        Default = Config.tpToHome,
        Callback = function(s)
            Config.tpToHome = s
            if s then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    homePosition = hrp.Position
                end
            end
        end,
    })
    local homeLabel = HomeSection:AddLabel("Home: not set")
    task.spawn(function()
        while true do
            task.wait(0.5)
            if rawget(_G, "_ _jfaTomb") then break end
            if homeLabel then
                if homePosition then
                    homeLabel:SetText(("Home: %.0f, %.0f, %.0f"):format(homePosition.X, homePosition.Y, homePosition.Z))
                else
                    homeLabel:SetText("Home: not set")
                end
            end
        end
    end)

    local HopSection = MainTab:AddRightGroupbox("Server Hop")
    HopSection:AddButton({
        Text = "Server Hop",
        Callback = serverHop,
    })

    local tpArea = "Meadow"
    local TpAreaSection = MainTab:AddLeftGroupbox("Teleport to Area")
    TpAreaSection:AddDropdown("TpArea", {
        Text = "Area",
        Values = TELEPORT_AREAS,
        Default = tpArea,
        Callback = function(v) tpArea = v end,
    })
    TpAreaSection:AddButton({
        Text = "Teleport",
        Callback = function()
            local pos = AREA_POSITIONS[tpArea]
            if pos then teleportTo(pos) end
        end,
    })

    local OpEggSection = MainTab:AddRightGroupbox("OP Egg Tracker")
    opEggLabel = OpEggSection:AddLabel("Divine Egg: loading...")
    OpEggSection:AddToggle("AutoTpOpEgg", {
        Text = "Auto TP When Spawned",
        Default = Config.autoTpOpEgg,
        Callback = function(s) Config.autoTpOpEgg = s; opEggTpSent = false end,
    })

    task.spawn(function()
        local avgMs = 0
        while true do
            if rawget(_G, _G_KEY) then break end
            task.wait(0.5)
            if Library and healthLabel then
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum then
                    healthLabel:SetText("Health: " .. ("%d/%d"):format(math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5)))
                end
                if hrp then
                    local p = hrp.Position
                    posLabel:SetText(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
                end
                if hum then
                    wsLabel:SetText("WalkSpeed: " .. ("%.1f"):format(hum.WalkSpeed))
                end
                if hum then
                    jpLabel:SetText("JumpPower: " .. ("%.1f"):format(hum.JumpPower))
                end
                local stats = game:GetService("Stats")
                local pingItem = stats.Network.ServerStatsItem["Data Ping"]
                avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
                pingLabel:SetText("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
                playerCountLabel:SetText("Players: " .. #Players:GetPlayers())
            end
            if opEggLabel then
                local remaining, queued, enabled = getOpEggCountdown()
                if not enabled then
                    opEggLabel:SetText("Divine Egg: disabled")
                elseif queued then
                    opEggLabel:SetText("Divine Egg: NEXT RESTOCK!")
                elseif remaining and remaining > 0 then
                    local m = math.floor(remaining / 60)
                    local s = remaining % 60
                    opEggLabel:SetText(("Divine Egg: %dm %ds"):format(m, s))
                else
                    opEggLabel:SetText("Divine Egg: SPAWNED!")
                end
            end
        end
    end)

    local SettingsTab = Window:AddTab("Settings", "settings")
    local SaveSection = SettingsTab:AddLeftGroupbox("Save / Load")
    SaveSection:AddButton({
        Text = "Save Settings",
        Callback = function()
            saveSettings()
            Library:Notify({Title = "Settings", Content = "Settings saved!", Duration = 2})
        end,
    })
    SaveSection:AddButton({
        Text = "Load Settings",
        Callback = function()
            local ok = loadSettings()
            if ok then
                Library:Notify({Title = "Settings", Content = "Settings loaded!", Duration = 2})
            else
                Library:Notify({Title = "Settings", Content = "No saved settings found.", Duration = 2})
            end
        end,
    })
    SaveSection:AddButton({
        Text = "Reset to Default",
        Callback = function()
            if type(delfile) == "function" and type(isfile) == "function" and isfile(SETTINGS_PATH) then
                pcall(delfile, SETTINGS_PATH)
            end
            Library:Notify({Title = "Settings", Content = "Saved settings deleted.", Duration = 2})
        end,
    })

    rawset(_G, _G_LIB, Library)
    rawset(_G, _G_GUI, Library.ScreenGui)
end

-- ========== Cleanup ==========
local function teardown()
    rawset(_G, _G_KEY, true)
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
    local lib = rawget(_G, _G_LIB)
    if lib and type(lib.Unload) == "function" then
        pcall(lib.Unload, lib)
    else
        local gui = rawget(_G, _G_GUI)
        if gui then pcall(function() gui:Destroy() end) end
    end
    rawset(_G, _G_LIB, nil)
    rawset(_G, _G_GUI, nil)
end

if STATE and STATE.onCleanup then
    STATE.onCleanup(teardown)
end
