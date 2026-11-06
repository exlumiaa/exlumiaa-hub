-- Exlumiaa Hub - +1 Spider Arm
-- Universe 10771997908 (place 117734411290994)
-- Mechanics verified live:
--   Training: stand on a rig -> server grants XP every ~0.5s (TrainNet "trained")
--             bubbles arrive as TrainNet "bubble", pop with TrainNet("pop", id);
--             each pop stacks an XP boost (up to x10) for 15s
--   Rebirth:  RebirthNet("rebirth") at level 10 + 10*Rebirths, +50% training each
--   Daily:    RewardNet("daily"); DailyTime holds the last claim time
--   Spin:     SpiderNet("spin") free when now >= SpiderSpinAt
--   Boxes:    SpiderNet("open", "Spider", count) costs 1 key + 1 box each
--   Revive:   StoreNet("revive") with ReviveTokens
-- Robux rigs (Inferno+) are deliberately not used.

if tostring(game.GameId) ~= "10771997908" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _psaTomb"
local _G_ALIVE = "_ _psaAlive"
local _G_CONFIG = "_ _psaConfig"

if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_plus_1_spider_arm.txt"
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
        local old = pg:FindFirstChild("Plus1SpiderArmKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "Plus1SpiderArmKeyGate"
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
        title.Text = "+1 Spider Arm"
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
    _G._hubKeyValidated = true
end

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.6)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "ExlumiaaHUD") then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        for _, gui in ipairs(pg and pg:GetChildren() or {}) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "ExlumiaaHUD") then gui:Destroy() end
        end
    end)
end

local Library = nil
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 80 do
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library then return end
Library.ConfigFolder = "exlumiaa"

local Config = {
    autoTrain = false,
    autoPop = true,
    targetLevel = 0,
    autoRebirth = false,
    autoDaily = false,
    autoSpin = false,
    autoBoxes = false,
    autoRevive = false,
    autoRevive = false,
    antiAfk = true,
    hud = true,
    fullbright = false,
    unlimitedGrip = false,
}
rawset(_G, _G_CONFIG, Config)

local Armature = ReplicatedStorage:WaitForChild("Armature", 20)
if not Armature then return end
local TrainNet = Armature:WaitForChild("TrainNet", 10)
local RewardNet = Armature:WaitForChild("RewardNet", 10)
local RebirthNet = Armature:WaitForChild("RebirthNet", 10)
local StoreNet = Armature:WaitForChild("StoreNet", 10)
local SpiderNet = Armature:WaitForChild("SpiderNet", 10)
if not (TrainNet and RewardNet and RebirthNet and StoreNet and SpiderNet) then return end

-- Grip is client-side in the Driver module: updateGrip drains it and calls
-- slip() at zero. Keeping it topped up means no slip, i.e. unlimited grip.
local DriverModule = nil
pcall(function() DriverModule = require(Armature:WaitForChild("Driver", 10)) end)

local gripPatched, gripOriginal = false, nil
local function setUnlimitedGrip(on)
    if not DriverModule or type(DriverModule.updateGrip) ~= "function" then return end
    if on and not gripPatched then
        gripOriginal = DriverModule.updateGrip
        DriverModule.updateGrip = function(self, dt)
            if self.deployed and not self.outClock and self.root and not self:inLobby(self.root.Position) then
                self.grip = self:gripCap()
                self.spent = false
                if self.solver then self.solver.noGrip = false end
            end
            return gripOriginal(self, dt)
        end
        gripPatched = true
    elseif not on and gripPatched then
        DriverModule.updateGrip = gripOriginal
        gripPatched = false
    end
end

-- ================================================================
-- Helpers
-- ================================================================
local function char() return LP.Character end
local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
local function root()
    local c = char()
    return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) or nil
end
local function alive()
    local h = hum()
    return h ~= nil and h.Health > 0 and root() ~= nil
end
local function num(v)
    v = tonumber(v)
    return type(v) == "number" and v or 0
end
local function now() return workspace:GetServerTimeNow() end

local function fire(remote, ...)
    if remote and remote:IsA("RemoteEvent") then
        local args = table.pack(...)
        pcall(function() remote:FireServer(table.unpack(args, 1, args.n)) end)
    end
end

local function tp(pos)
    local r = root()
    if not r then return false end
    pcall(function() r.CFrame = CFrame.new(pos) end)
    return true
end

local function level() return num(LP:GetAttribute("Level")) end
local function rebirths() return num(LP:GetAttribute("Rebirths")) end
local function rebirthNeed() return 10 + 10 * rebirths() end

-- ================================================================
-- Training stations (non-Robux only)
-- ================================================================
local STATIONS = {
    { Name = "Scrap", Rig = "ScrapRig", Rebirths = 0 },
    { Name = "Steel", Rig = "SteelRig", Rebirths = 2 },
    { Name = "Turbo", Rig = "TurboRig", Rebirths = 4 },
    { Name = "Plasma", Rig = "PlasmaRig", Rebirths = 6 },
}

local function stationPad(rigName)
    local map = workspace:FindFirstChild("Map")
    local lobby = map and map:FindFirstChild("Lobby")
    local features = lobby and lobby:FindFirstChild("Features")
    local training = features and features:FindFirstChild("Training")
    local stations = training and training:FindFirstChild("Stations")
    local rig = stations and stations:FindFirstChild(rigName)
    return rig and rig:FindFirstChild("Pad")
end

local function bestStation()
    local rebs = rebirths()
    local best = STATIONS[1]
    for _, s in ipairs(STATIONS) do
        if rebs >= s.Rebirths then best = s end
    end
    return best
end

local function warpToRig()
    local s = bestStation()
    local pad = stationPad(s.Rig)
    if not pad then return false end
    return tp(pad.Position + Vector3.new(0, 3, 0))
end

-- ================================================================
-- Core automation
-- ================================================================
local busy = false
local lastWarp = 0
local lastRebirth = 0
local lastDaily = 0
local lastSpin = 0
local lastBox = 0
local lastRevive = 0

local function trainTick()
    if busy or not alive() then return end
    local lvl = level()
    if Config.autoRebirth and lvl >= rebirthNeed() and os.clock() - lastRebirth > 8 then
        lastRebirth = os.clock()
        busy = true
        fire(RebirthNet, "rebirth")
        task.wait(2.5)
        lastWarp = 0
        busy = false
        return
    end
    if not Config.autoTrain then return end
    if Config.targetLevel > 0 and lvl >= Config.targetLevel then return end
    local s = bestStation()
    local training = tostring(LP:GetAttribute("Training") or "")
    if training == "" or training ~= s.Name then
        if os.clock() - lastWarp > 2.5 then
            lastWarp = os.clock()
            warpToRig()
        end
    end
end

local function rewardTick()
    if not alive() then return end
    local t = now()
    if Config.autoDaily and os.clock() - lastDaily > 10 then
        local dailyAt = num(LP:GetAttribute("DailyTime"))
        if dailyAt == 0 or t >= dailyAt + 86400 then
            lastDaily = os.clock()
            fire(RewardNet, "daily")
        end
    end
    if Config.autoSpin and os.clock() - lastSpin > 5 then
        local spinAt = num(LP:GetAttribute("SpiderSpinAt"))
        if num(LP:GetAttribute("SpiderSpins")) > 0 or t >= spinAt then
            lastSpin = os.clock()
            fire(SpiderNet, "spin")
        end
    end
    if Config.autoBoxes and os.clock() - lastBox > 4 then
        local boxes = LP:GetAttribute("SpiderBoxes")
        local count = 0
        if type(boxes) == "table" then count = num(boxes.Spider) elseif type(boxes) == "string" then
            local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(boxes) end)
            if ok and type(decoded) == "table" then count = num(decoded.Spider) end
        end
        if count > 0 and num(LP:GetAttribute("SpiderKeys")) > 0 then
            lastBox = os.clock()
            fire(SpiderNet, "open", "Spider", 1)
        end
    end
    if Config.autoRevive and os.clock() - lastRevive > 5 then
        local h = hum()
        if num(LP:GetAttribute("ReviveTokens")) > 0 and h and h.Health <= 0 then
            lastRevive = os.clock()
            fire(StoreNet, "revive")
        end
    end
end

local function nearestCheckpoint()
    return nil
end

local function checkpointTick() end

-- Auto-pop bubbles: the server sends the id, we answer like the game's UI does.
local function onTrainEvent(kind, id)
    if kind == "bubble" and Config.autoPop then
        local bubbleId = id
        task.delay(0.35, function()
            if Config.autoPop and rawget(_G, _G_TOMB) ~= true then
                fire(TrainNet, "pop", bubbleId)
            end
        end)
    end
end
TrainNet.OnClientEvent:Connect(onTrainEvent)

-- ================================================================
-- Space hold for climbing
-- ================================================================
local climbHeld = false
local function setClimb(on)
    if on == climbHeld then return end
    climbHeld = on
    pcall(function()
        if on then keypress(0x20) else keyrelease(0x20) end
    end)
end

-- ================================================================
-- Fullbright
-- ================================================================
local fbSaved = nil
local function setFullbright(on)
    if on and not fbSaved then
        fbSaved = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ExposureCompensation = Lighting.ExposureCompensation,
        }
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(150, 150, 150)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        Lighting.ExposureCompensation = 0.2
    elseif not on and fbSaved then
        for k, v in pairs(fbSaved) do Lighting[k] = v end
        fbSaved = nil
    end
end

-- ================================================================
-- Anti AFK
-- ================================================================
LP.Idled:Connect(function()
    if not Config.antiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ================================================================
-- HUD
-- ================================================================
local hud = nil
do
    local ok = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "ExlumiaaHUD"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        local parent = game:GetService("CoreGui")
        gui.Parent = parent
        local label = Instance.new("TextLabel")
        label.Name = "Stats"
        label.Size = UDim2.fromOffset(250, 74)
        label.Position = UDim2.fromOffset(14, 14)
        label.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        label.BackgroundTransparency = 0.25
        label.TextColor3 = Color3.fromRGB(235, 235, 240)
        label.Font = Enum.Font.Code
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Text = ""
        label.Parent = gui
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingTop = UDim.new(0, 6)
        pad.Parent = label
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        hud = { gui = gui, label = label }
    end)
    if not ok then hud = nil end
end

local function updateHud()
    if not hud then return end
    hud.gui.Enabled = Config.hud
    if not Config.hud then return end
    local boxes = LP:GetAttribute("SpiderBoxes")
    local boxCount = 0
    if type(boxes) == "table" then boxCount = num(boxes.Spider) elseif type(boxes) == "string" then
        local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(boxes) end)
        if ok and type(decoded) == "table" then boxCount = num(decoded.Spider) end
    end
    local training = tostring(LP:GetAttribute("Training") or "")
    hud.label.Text = string.format(
        "LEVEL %d   XP %d\nWINS %d   REBIRTHS %d (need Lv %d)\nRIG %s   %s\nKEYS %d   BOXES %d   SPINS %d",
        level(), math.floor(num(LP:GetAttribute("XP"))),
        math.floor(num(LP:GetAttribute("Wins"))), rebirths(), rebirthNeed(),
        bestStation().Name, training ~= "" and ("TRAINING " .. training) or "idle",
        math.floor(num(LP:GetAttribute("SpiderKeys"))), boxCount,
        math.floor(num(LP:GetAttribute("SpiderSpins")))
    )
end

-- ================================================================
-- Main loop
-- ================================================================
task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        local ok, err = pcall(function()
            trainTick()
            rewardTick()
            checkpointTick()
            updateHud()
            if Config.fullbright ~= (fbSaved ~= nil) then setFullbright(Config.fullbright) end
            if Config.unlimitedGrip ~= gripPatched then setUnlimitedGrip(Config.unlimitedGrip) end
        end)
        if not ok then warn("[Spider] loop: " .. tostring(err)) end
        task.wait(0.5)
    end
    setClimb(false)
    setUnlimitedGrip(false)
    setFullbright(false)
    if hud then hud.gui:Destroy() end
end)

-- ================================================================
-- UI
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "+1 Spider Arm",
    Size = UDim2.fromOffset(520, 420),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 Spider Arm",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then v:Destroy() end
    end
end)

local TrainTab = Window:AddTab({ Name = "Main", Icon = "bolt", Subtitle = "Features" })
local TrainSub = TrainTab:AddSubTab("Features")

TrainSub:AddSection("Training")
TrainSub:AddToggle({
    Name = "Auto Train",
    Flag = "psa_train",
    Default = false,
    Callback = function(v) Config.autoTrain = v end,
})
TrainSub:AddToggle({
    Name = "Auto Pop Bubbles",
    Flag = "psa_pop",
    Default = true,
    Callback = function(v) Config.autoPop = v end,
})
TrainSub:AddToggle({
    Name = "Auto Rebirth",
    Flag = "psa_rebirth",
    Default = false,
    Callback = function(v) Config.autoRebirth = v end,
})
TrainSub:AddToggle({
    Name = "Unlimited Grip",
    Flag = "psa_grip",
    Default = false,
    Callback = function(v) Config.unlimitedGrip = v end,
})

local RewardTab = Window:AddTab({ Name = "Rewards", Icon = "gift", Subtitle = "Daily & Boxes" })
local RewardSub = RewardTab:AddSubTab("Features")

RewardSub:AddSection("Rewards")
RewardSub:AddToggle({
    Name = "Auto Daily",
    Flag = "psa_daily",
    Default = false,
    Callback = function(v) Config.autoDaily = v end,
})
RewardSub:AddToggle({
    Name = "Auto Spin",
    Flag = "psa_spin",
    Default = false,
    Callback = function(v) Config.autoSpin = v end,
})
RewardSub:AddToggle({
    Name = "Auto Open Boxes",
    Flag = "psa_boxes",
    Default = false,
    Callback = function(v) Config.autoBoxes = v end,
})
RewardSub:AddToggle({
    Name = "Auto Revive",
    Flag = "psa_revive",
    Default = false,
    Callback = function(v) Config.autoRevive = v end,
})

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Utility" })
local SettingsSub = SettingsTab:AddSubTab("Features")

SettingsSub:AddSection("Utility")
SettingsSub:AddToggle({
    Name = "Anti AFK",
    Flag = "psa_afk",
    Default = true,
    Callback = function(v) Config.antiAfk = v end,
})
SettingsSub:AddToggle({
    Name = "Stats HUD",
    Flag = "psa_hud",
    Default = true,
    Callback = function(v) Config.hud = v end,
})
SettingsSub:AddToggle({
    Name = "Fullbright / No Fog",
    Flag = "psa_fullbright",
    Default = false,
    Callback = function(v) Config.fullbright = v end,
})
SettingsSub:AddSection("Config")
local configDropdown = SettingsSub:AddDropdown({
    Name = "Saved Configs",
    Flag = "psa_config_selected",
    Options = {},
    Default = "",
    Callback = function(v) selectedConfig = v end,
})
local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
        configDropdown:Refresh()
    end
end
local configInput = SettingsSub:AddInput({
    Name = "Config Name",
    Flag = "psa_config_name",
    Default = "",
    Placeholder = "Enter config name...",
})
SettingsSub:AddDivider()
SettingsSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            pcall(function() Window:Notify({ Title = "Config", Content = "Enter a name first!", Duration = 3 }) end)
            return
        end
        if Library:SaveConfig(name) then
            refreshConfigList()
            pcall(function() Window:Notify({ Title = "Config", Content = "Saved: " .. name, Duration = 3 }) end)
        else
            pcall(function() Window:Notify({ Title = "Config", Content = "Save failed.", Duration = 3 }) end)
        end
    end,
})
SettingsSub:AddButton({
    Name = "Load Config",
    Callback = function()
        local selected = configDropdown:Get()
        if not selected or selected == "" then
            pcall(function() Window:Notify({ Title = "Config", Content = "Select a config first!", Duration = 3 }) end)
            return
        end
        if Library:LoadConfig(selected) then
            refreshConfigList()
            pcall(function() Window:Notify({ Title = "Config", Content = "Loaded: " .. selected, Duration = 3 }) end)
        else
            pcall(function() Window:Notify({ Title = "Config", Content = "Load failed.", Duration = 3 }) end)
        end
    end,
})

pcall(function() Library:LoadConfig("default") end)

pcall(function()
    Window:Notify({
        Title = "Exlumiaa Hub loaded",
        Content = "Press RightShift to toggle. Turn on Auto Train in the Train tab.",
    })
end)
