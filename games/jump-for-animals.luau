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
            PUSL.configure({ serviceId = PUSL_SERVICE_ID, debug = false, kickOnDetect = false })
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
        if not pxLoad() then return false, "Could not load key library" end
        for attempt = 1, 4 do
            local okCall, ok, reason = pcall(function() return PUSL.validateEx(tostring(key)) end)
            if not okCall then break end
            if ok then return true, "" end
            if reason == "INVALID_KEY" or reason == "NO_KEY" or reason == "NO_SERVICE" then
                return false, "Invalid / expired key"
            end
            task.wait(attempt * 1.5)
        end
        return false, "Network error, try again"
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
        subtitle.Text = "Exlumia Hub - Enter your key"
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
    trainDelay = 0.75,
    autoCollect = false,
    collectDelay = 0.3,
    autoPlace = true,
    guardDropBlock = false,
    walkEnabled = false,
    walkSpeed = 50,
    guiKey = Enum.KeyCode.RightShift,
}

local originalWalkSpeed = 16
local Library = nil
local healthLabel, posLabel, wsLabel, pingLabel, playerCountLabel

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

    local prompts = getEggPrompts()
    if #prompts == 0 then return end

    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    table.sort(prompts, function(a, b)
        local aPart = a.Parent
        local bPart = b.Parent
        if not aPart or not bPart then return false end
        local aPos = aPart:IsA("BasePart") and aPart.Position or (aPart:IsA("Model") and aPart:GetPivot().Position or Vector3.zero)
        local bPos = bPart:IsA("BasePart") and bPart.Position or (bPart:IsA("Model") and bPart:GetPivot().Position or Vector3.zero)
        return (hrp.Position - aPos).Magnitude < (hrp.Position - bPos).Magnitude
    end)

    local prompt = prompts[1]
    if prompt then
        local eggPart = prompt.Parent
        if eggPart then
            local eggPos = eggPart:IsA("BasePart") and eggPart.Position or (eggPart:IsA("Model") and eggPart:GetPivot().Position or nil)
            if eggPos then
                teleportTo(eggPos)
                task.wait(0.1)
            end
        end
        prompt:InputHoldBegin()
        task.wait(0.6)
        prompt:InputHoldEnd()
        task.wait(Config.collectDelay)
    end
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

-- ========== WalkSpeed ==========
local function applyWalkSpeed(char)
    if Config.walkEnabled and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Config.walkSpeed
        end
    end
end

-- ========== Main Loops ==========
task.spawn(function()
    while true do
        if rawget(_G, _G_KEY) then break end
        pcall(autoTrainTick)
        pcall(autoCollectTick)
        task.wait(0.1)
    end
end)

LP.CharacterAdded:Connect(function(char)
    originalWalkSpeed = 16
    task.wait(0.5)
    applyWalkSpeed(char)
end)

task.spawn(function()
    while true do
        if rawget(_G, _G_KEY) then break end
        applyWalkSpeed(LP.Character)
        task.wait(0.2)
    end
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

if Library then
    local Window = Library:CreateWindow({
        Title = "Jump for Animals! - Exlumia Hub",
        Footer = "by exlumiaa1",
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

    local ServerSection = HomeTab:AddRightGroupbox("Server")
    ServerSection:AddLabel("Place: " .. tostring(game.PlaceId))
    ServerSection:AddLabel("Job: " .. tostring(game.JobId))
    pingLabel = ServerSection:AddLabel("Ping: --")
    playerCountLabel = ServerSection:AddLabel("Players: --")
    ServerSection:AddLabel("by exlumiaa1")

    local MainTab = Window:AddTab("Main", "settings")

    local TrainSection = MainTab:AddLeftGroupbox("Auto Train")
    TrainSection:AddToggle("AutoTrain", {
        Text = "Auto Squat Train",
        Default = Config.autoTrain,
        Callback = function(s)
            Config.autoTrain = s
            if not s then pcall(stopTraining) end
        end,
    })

    local CollectSection = MainTab:AddLeftGroupbox("Auto Collect Eggs")
    CollectSection:AddToggle("AutoCollect", {
        Text = "Auto Collect",
        Default = Config.autoCollect,
        Callback = function(s)
            Config.autoCollect = s
        end,
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
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
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

    local HopSection = MainTab:AddRightGroupbox("Server Hop")
    HopSection:AddButton({
        Text = "Server Hop",
        Callback = serverHop,
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
                local stats = game:GetService("Stats")
                local pingItem = stats.Network.ServerStatsItem["Data Ping"]
                avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
                pingLabel:SetText("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
                playerCountLabel:SetText("Players: " .. #Players:GetPlayers())
            end
        end
    end)

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
        if hum then hum.WalkSpeed = originalWalkSpeed end
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
