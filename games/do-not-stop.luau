-- Do Not Stop — Exlumiaa Hub
-- Game: 10772946647 (lobby 116779912472448, routes 107530102033104 / Map02-07 / Endless)
-- Key system: Panda Auth (exlumiaa).

local PLACES = {
    [116779912472448] = "Lobby",
    [107530102033104] = "Do Not Stop",
    [73944063866340] = "Map 02",
    [81271298082422] = "Map 03",
    [76065553551463] = "Map 04",
    [111081709255588] = "Map 05",
    [137070863487426] = "Map 06",
    [129862496496546] = "Map 07",
    [98531913151071] = "Endless",
}
if not PLACES[game.PlaceId] and tostring(game.GameId) ~= "10772946647" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local LOBBY = 116779912472448

local GEN = (tonumber(getgenv().__route1610Gen) or 0) + 1
getgenv().__route1610Gen = GEN

local function stale()
    return tonumber(getgenv().__route1610Gen) ~= GEN
end

local function cleanupGui(name)
    pcall(function()
        local cg = game:GetService("CoreGui")
        for _, gui in ipairs(cg:GetChildren()) do
            if gui.Name == name then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        for _, gui in ipairs(pg and pg:GetChildren() or {}) do
            if gui.Name == name then gui:Destroy() end
        end
    end)
end
cleanupGui("ExlumiaaHub")
cleanupGui("Route1610HUD")
cleanupGui("DNSKeyGate")

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_dns.txt"
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
        local old = pg:FindFirstChild("DNSKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "DNSKeyGate"
        sc.ResetOnSpawn = false
        sc.IgnoreGuiInset = true
        sc.DisplayOrder = 998
        sc.Parent = pg

        local accent = Color3.fromRGB(255, 176, 58)
        local accent2 = Color3.fromRGB(255, 214, 150)

        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundColor3 = Color3.fromRGB(12, 10, 7)
        overlay.BackgroundTransparency = 0.1
        overlay.BorderSizePixel = 0
        overlay.Parent = sc

        local card = Instance.new("Frame")
        card.Name = "Card"
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.fromScale(0.5, 0.5)
        card.Size = UDim2.fromOffset(360, 330)
        card.BackgroundColor3 = Color3.fromRGB(22, 18, 12)
        card.BorderSizePixel = 0
        card.Parent = sc
        local cardc = Instance.new("UICorner"); cardc.CornerRadius = UDim.new(0, 16); cardc.Parent = card
        local cardStroke = Instance.new("UIStroke"); cardStroke.Color = accent; cardStroke.Transparency = 0.6; cardStroke.Thickness = 1; cardStroke.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 42)
        title.Position = UDim2.fromOffset(0, 20)
        title.BackgroundTransparency = 1
        title.Text = "Do Not Stop: Enhanced"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 22
        title.TextColor3 = Color3.fromRGB(255, 246, 235)
        title.Parent = card
        local titleGrad = Instance.new("UIGradient"); titleGrad.Rotation = -8; titleGrad.Color = ColorSequence.new(accent, accent2); titleGrad.Parent = title

        local subtitle = Instance.new("TextLabel")
        subtitle.Size = UDim2.new(1, 0, 0, 16)
        subtitle.Position = UDim2.fromOffset(0, 62)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = "Enter your key to unlock"
        subtitle.Font = Enum.Font.Gotham
        subtitle.TextSize = 12
        subtitle.TextColor3 = Color3.fromRGB(175, 160, 138)
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
        keyBox.BackgroundColor3 = Color3.fromRGB(34, 28, 20)
        keyBox.BorderSizePixel = 0
        keyBox.Font = Enum.Font.GothamBold
        keyBox.TextSize = 16
        keyBox.TextColor3 = Color3.fromRGB(255, 246, 235)
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
        getBtn.TextColor3 = Color3.fromRGB(20, 12, 2)
        local verifyBtn = makeButton("Verify", 270, Color3.fromRGB(62, 50, 34))
        verifyBtn.Name = "VerifyBtn"

        local hint = Instance.new("TextLabel")
        hint.Size = UDim2.new(1, -32, 0, 30)
        hint.Position = UDim2.fromOffset(16, 268)
        hint.BackgroundTransparency = 1
        hint.Text = "Open the link, complete the ad, then paste your key."
        hint.Font = Enum.Font.Gotham
        hint.TextSize = 11
        hint.TextColor3 = Color3.fromRGB(140, 125, 102)
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
                    _G._hubKeyValidated = true
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
            if okVal then
                unlocked = true
                _G._hubKeyValidated = true
            end
        end
        if not unlocked then
            local gateDone = false
            local gui = ksShowGate(function() gateDone = true end)

            while not gateDone do
                if stale() then
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

local Shared = ReplicatedStorage:FindFirstChild("Shared")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

local function getRun()
    local runs = workspace:FindFirstChild("Runs")
    return runs and runs:FindFirstChild(tostring(LP.UserId))
end

local function getChassis()
    local cars = workspace:FindFirstChild("Cars")
    local car = cars and cars:FindFirstChild("Car_" .. tostring(LP.UserId))
    return car and car:FindFirstChild("Chassis")
end

local S = {
    autoRun = false,
    drive = false,
    autoRetry = true,
    speedCap = 126,
    esp = false,
    hud = true,
    lastStart = 0,
    runs = 0,
    finishes = 0,
    caught = 0,
    creditsStart = nil,
    creditsGain = 0,
    startedAt = os.clock(),
}

local function fireStart(retry)
    local rem = Remotes and Remotes:FindFirstChild("StartRun")
    if not rem then return false end
    local ok = pcall(function() rem:FireServer(retry == true) end)
    if ok then S.lastStart = os.clock() end
    return ok
end

local ctrl = { lastAng = 0, speed = 0, vmax = 0, lat = 0, s = 0, look = 0, lastMove = 0, recoverUntil = 0 }

-- ================================================================
-- ROAD PATH
-- ================================================================
local RoadPath, path, finishS
do
    local ok, err = pcall(function()
        local cfg = Shared and Shared:FindFirstChild("Config")
        local rules = Shared and Shared:FindFirstChild("Rules")
        local World = cfg and cfg:FindFirstChild("World")
        local Road = rules and rules:FindFirstChild("RoadPath")
        local RunCfg = cfg and cfg:FindFirstChild("Run")
        if not (World and Road) then return end
        RoadPath = require(Road)
        local worldOk, world = pcall(require, World)
        if not worldOk or type(world) ~= "table" then return end
        path = RoadPath.build(world)
        if RunCfg then
            local runOk, runData = pcall(require, RunCfg)
            if runOk and type(runData) == "table" then
                finishS = tonumber(runData.FinishS)
            end
        end
    end)
    if not ok then path = nil end
end
finishS = finishS or 8360

local function pointAt(s, lateral)
    if not path then return nil end
    return RoadPath.pointAt(path, s, lateral or 0)
end

-- ================================================================
-- AUTO DRIVE
-- ================================================================
local Input = nil
do
    local client = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("Client")
    local mod = client and client:FindFirstChild("Input")
    if mod then
        local ok, res = pcall(require, mod)
        if ok and type(res) == "table" and type(res.setOverride) == "function" then
            Input = res
        end
    end
end

local CURVE_STEPS = { 40, 80, 140, 200 }

local function driveTick()
    local run = getRun()
    if not run or run:GetAttribute("State") ~= "Driving" then return 0, 0, 0, false end
    local ch = getChassis()
    if not ch or not path then return 0, 1, 0, false end

    local now = os.clock()
    local s = run:GetAttribute("CarS") or 0
    local pos = ch.Position
    local _, lat = RoadPath.project(path, pos.X, pos.Z)
    lat = tonumber(lat) or 0
    local speed = ch.AssemblyLinearVelocity.Magnitude

    if ctrl.recoverUntil > now then
        ctrl.speed = speed
        return 0, 1, -math.sign(lat), false
    end
    if speed < 3 then
        if now - (ctrl.lastMove or now) > 2.5 then
            ctrl.recoverUntil = now + 1.4
            ctrl.lastMove = now
            ctrl.lastAng = 0
        end
    else
        ctrl.lastMove = now
    end

    local _, _, _, f0x, f0z = pointAt(s)
    if not f0x then return 0, 1, 0, false end
    local k = 0
    for _, d in ipairs(CURVE_STEPS) do
        local _, _, _, f1x, f1z = pointAt(s + d)
        local bend = math.acos(math.clamp(f0x * f1x + f0z * f1z, -1, 1))
        if bend / d > k then k = bend / d end
    end

    local vmax = math.clamp(math.sqrt(50 / math.max(k, 0.0004)), 40, S.speedCap)
    if math.abs(lat) > 9 then vmax = math.min(vmax, 80) end

    local look = math.clamp(18 + speed * 0.5, 26, 78)
    local tx, ty, tz = pointAt(s + look)
    local rel = ch.CFrame:PointToObjectSpace(Vector3.new(tx, ty, tz))
    local ang = math.atan2(rel.X, -rel.Z)
    local dAng = ang - ctrl.lastAng
    ctrl.lastAng = ang

    local steer = math.clamp(ang * 2.1 + dAng * 3.5, -1, 1)
    local throttle = speed < vmax and 1 or 0
    local brake = speed > vmax + 12 and 1 or 0

    ctrl.speed, ctrl.vmax, ctrl.lat, ctrl.s, ctrl.look = speed, vmax, lat, s, look
    return throttle, brake, steer, false
end

local function installOverride()
    if not Input then return false end
    Input.setOverride(function()
        if stale() or not S.drive then return 0, 0, 0, false end
        return driveTick()
    end)
    return true
end

local function clearOverride()
    if Input then pcall(function() Input.setOverride(nil) end) end
end

local function setDrive(on)
    S.drive = on and true or false
    ctrl.lastAng = 0
    if S.drive then
        if not installOverride() then
            S.drive = false
            return false, "Input module not found"
        end
    else
        clearOverride()
    end
    return true
end

-- ================================================================
-- RUN LOOP
-- ================================================================
local function setAutoRun(on)
    S.autoRun = on and true or false
    if S.autoRun and not S.drive then setDrive(true) end
    if not S.autoRun then setDrive(false) end
end

local lastState = nil
local LobbyModule
local lastPadWalk = 0

local function lobbyQueue()
    if game.PlaceId ~= LOBBY then return false end
    if not LobbyModule then
        pcall(function() LobbyModule = require(LP.PlayerScripts.Client.Lobby) end)
    end
    if not LobbyModule then return false end

    local lobby = LobbyModule.state and LobbyModule.state.lobby
    if not lobby then
        local pads = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Pads")
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if pads and hrp and hum and os.clock() - lastPadWalk > 2 then
            lastPadWalk = os.clock()
            local best, bestD = nil, math.huge
            for _, model in ipairs(pads:GetChildren()) do
                local part = model:FindFirstChildWhichIsA("BasePart")
                if part then
                    local d = (part.Position - hrp.Position).Magnitude
                    if d < bestD then best, bestD = part, d end
                end
            end
            if best and bestD > 6 then
                hum:MoveTo(best.Position + Vector3.new(0, 3, 0))
            end
        end
        return false
    end

    local rem = Remotes and Remotes:FindFirstChild("LobbyRequest")
    if not rem then return false end
    pcall(function() rem:FireServer("Start") end)
    S.lastStart = os.clock()
    return true
end

local function tickRunLoop()
    local run = getRun()
    if not run then
        if S.autoRun and os.clock() - S.lastStart > 8 then lobbyQueue() end
        return
    end
    local state = run:GetAttribute("State")
    local now = os.clock()

    if state ~= lastState then
        if state == "Finished" then
            S.finishes += 1
            S.runs += 1
        elseif state == "Caught" then
            S.caught += 1
            S.runs += 1
        end
        lastState = state
    end

    if not S.autoRun then return end
    if now - S.lastStart < 3 then return end

    if state == "Idle" or state == "Finished" then
        fireStart(false)
    elseif state == "Caught" then
        local retries = tonumber(run:GetAttribute("Retries")) or 0
        if S.autoRetry and retries < 2 then
            fireStart(true)
        else
            fireStart(false)
        end
    end
end

-- ================================================================
-- ESP
-- ================================================================
local MONSTERS = { Watcher = true, Scarecrow = true, Runner = true, Intruder = true }
local espGuiName = "R1610ESP"

local function clearEsp()
    local root = workspace:FindFirstChild("ClientMonsters")
    if not root then return end
    for _, d in ipairs(root:GetDescendants()) do
        if d.Name == espGuiName then d:Destroy() end
    end
end

local function refreshEsp()
    local root = workspace:FindFirstChild("ClientMonsters")
    if not root then return end
    local cam = workspace.CurrentCamera
    local origin = cam and cam.CFrame.Position or Vector3.zero
    for _, model in ipairs(root:GetChildren()) do
        if MONSTERS[model.Name] then
            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if part then
                local gui = part:FindFirstChild(espGuiName)
                if S.esp then
                    if not gui then
                        gui = Instance.new("BillboardGui")
                        gui.Name = espGuiName
                        gui.AlwaysOnTop = true
                        gui.Size = UDim2.fromOffset(150, 32)
                        gui.StudsOffset = Vector3.new(0, 3.5, 0)
                        gui.MaxDistance = 600
                        local label = Instance.new("TextLabel")
                        label.Name = "Tag"
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.Font = Enum.Font.Code
                        label.TextSize = 15
                        label.TextColor3 = Color3.fromRGB(255, 186, 66)
                        label.TextStrokeTransparency = 0.25
                        label.Text = model.Name
                        label.Parent = gui
                        gui.Parent = part
                    end
                    local dist = (part.Position - origin).Magnitude
                    gui.Tag.Text = string.format("%s  %dm", model.Name, math.floor(dist))
                elseif gui then
                    gui:Destroy()
                end
            end
        end
    end
end

-- ================================================================
-- HUD
-- ================================================================
local hud, hudLabels
local function buildHud()
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "Route1610HUD"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 4
    gui.Parent = pg

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0, 1)
    panel.Position = UDim2.new(0, 16, 1, -16)
    panel.Size = UDim2.fromOffset(196, 104)
    panel.BackgroundColor3 = Color3.fromRGB(16, 13, 10)
    panel.BackgroundTransparency = 0.22
    panel.BorderSizePixel = 0
    panel.Parent = gui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = panel
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 176, 58)
    stroke.Transparency = 0.55
    stroke.Thickness = 1
    stroke.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 16)
    title.Position = UDim2.fromOffset(8, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(255, 176, 58)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "DO NOT STOP"
    title.Parent = panel

    local rows = { "SPEED", "DIST", "GAP", "STATE", "CREDITS" }
    hudLabels = {}
    for i, name in ipairs(rows) do
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = UDim2.new(1, -16, 0, 15)
        label.Position = UDim2.fromOffset(8, 24 + (i - 1) * 15)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Code
        label.TextSize = 12
        label.TextColor3 = Color3.fromRGB(238, 232, 222)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = name .. "  --"
        label.Parent = panel
        hudLabels[name] = label
    end

    hud = gui
    return gui
end

local function updateHud()
    if not hudLabels then return end
    if not S.hud then
        if hud then hud.Enabled = false end
        return
    end
    if hud then hud.Enabled = true end
    local run = getRun()
    local state = run and run:GetAttribute("State") or "Lobby"
    local s = run and tonumber(run:GetAttribute("CarS")) or 0
    local runnerS = run and tonumber(run:GetAttribute("RunnerS"))
    local active = run and run:GetAttribute("RunnerActive") == true
    local gap = (active and runnerS) and (runnerS - s) or nil
    local credits = tonumber(LP:GetAttribute("Credits")) or 0

    hudLabels.SPEED.Text = string.format("SPEED   %d", math.floor(ctrl.speed))
    hudLabels.DIST.Text = string.format("DIST    %d / %d", math.floor(s), math.floor(finishS))
    if gap then
        hudLabels.GAP.Text = string.format("GAP     %+d", math.floor(gap))
        hudLabels.GAP.TextColor3 = gap < 30 and Color3.fromRGB(255, 96, 82) or Color3.fromRGB(238, 232, 222)
    else
        hudLabels.GAP.Text = "GAP     --"
        hudLabels.GAP.TextColor3 = Color3.fromRGB(150, 142, 130)
    end
    hudLabels.STATE.Text = "STATE   " .. tostring(state)
    hudLabels.CREDITS.Text = string.format("CREDITS %d", credits)
end

-- ================================================================
-- GARAGE (lobby only)
-- ================================================================
local KNOWN_CODES = { "RELEASE", "DONOTSTOP", "ROUTE1610", "LASTSTOP" }

local CAR_LEVELS = {}
pcall(function()
    local cfg = Shared and Shared:FindFirstChild("Config")
    local prog = cfg and cfg:FindFirstChild("Progression")
    if prog then
        local data = require(prog)
        if type(data) == "table" and type(data.Cars) == "table" then
            CAR_LEVELS = data.Cars
        end
    end
end)

local function garageAsk(action, arg)
    local g = Remotes and Remotes:FindFirstChild("Garage")
    if not g then return nil, "no Garage remote" end
    local done, res = false, nil
    task.spawn(function()
        local ok, value = pcall(function() return g:InvokeServer(action, arg) end)
        res = ok and value or ("ERR " .. tostring(value))
        done = true
    end)
    local t0 = os.clock()
    while not done and os.clock() - t0 < 8 do
        if stale() then return nil, "unloaded" end
        task.wait(0.1)
    end
    if not done then return nil, "no answer" end
    return res
end

local function redeem(code)
    if game.PlaceId ~= LOBBY then return false, "Codes only work in the lobby" end
    code = string.upper(string.gsub(tostring(code or ""), "%s+", ""))
    if code == "" then return false, "Empty code" end
    local res, err = garageAsk("redeem", code)
    if not res then return false, err end
    if type(res) == "table" then
        return res.ok == true, tostring(res.why or res.msg or res.ok)
    end
    return false, tostring(res)
end

local function equipBestCar()
    local res, err = garageAsk("state")
    if type(res) ~= "table" then return false, tostring(err or res) end
    local level = tonumber(res.level) or 0
    local best, bestLevel = nil, -1
    for id, lv in pairs(CAR_LEVELS) do
        lv = tonumber(lv)
        if lv and lv <= level and lv > bestLevel then
            best, bestLevel = id, lv
        end
    end
    if not best then return false, "no car unlocked" end
    if type(res.equip) == "table" and res.equip.car == best then
        return true, best .. " already equipped"
    end
    local out = garageAsk("equip", { kind = "car", id = best })
    if type(out) == "table" then
        return out.ok == true, tostring(out.why or out.ok)
    end
    return false, tostring(out)
end

local function openCrates()
    local res, err = garageAsk("state")
    if type(res) ~= "table" then return false, tostring(err or res) end
    local list = res.crates
    if type(list) ~= "table" or #list == 0 then return false, "no crates to open" end
    local opened = 0
    for _, crate in ipairs(list) do
        local id = type(crate) == "table" and (crate.Id or crate.id) or crate
        if id then
            garageAsk("open", id)
            opened += 1
            task.wait(1.5)
        end
    end
    return true, "opened " .. opened
end

-- ================================================================
-- UI
-- ================================================================
local Library = nil
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil or stale() then break end
    task.wait(0.25)
end
if not Library or stale() then return end

Library.ConfigFolder = "exlumiaa/do-not-stop"

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Do Not Stop",
    Size = UDim2.fromOffset(500, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Do Not Stop",
    LoadingFooter = "Auto Drive",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then
            v:Destroy()
        end
    end
end)

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "car", Subtitle = "Auto Run" })
local Farm = FarmTab:AddSubTab("Run")

local status

Farm:AddSection("Run")
Farm:AddToggle({
    Name = "Auto Run",
    Flag = "r1610_autorun",
    Default = false,
    Callback = function(v) setAutoRun(v) end,
})
Farm:AddToggle({
    Name = "Auto Drive",
    Flag = "r1610_drive",
    Default = false,
    Callback = function(v)
        local ok, err = setDrive(v)
        if not ok then status:Set("Auto Drive failed: " .. tostring(err)) end
    end,
})
Farm:AddToggle({
    Name = "Auto Retry (free only)",
    Flag = "r1610_retry",
    Default = true,
    Callback = function(v) S.autoRetry = v and true or false end,
})
Farm:AddSlider({
    Name = "Speed Cap",
    Min = 60,
    Max = 135,
    Default = 126,
    Suffix = " studs/s",
    Flag = "r1610_speed",
    Callback = function(v) S.speedCap = v end,
})

Farm:AddSection("Manual")
Farm:AddButton({
    Name = "Start Run",
    Primary = true,
    Callback = function()
        local ok = fireStart(false)
        status:Set(ok and "Run start sent." or "No StartRun remote.")
    end,
})
Farm:AddButton({
    Name = "Leave Run",
    Callback = function()
        local rem = Remotes and Remotes:FindFirstChild("LeaveRun")
        if rem then pcall(function() rem:FireServer() end) end
    end,
})

Farm:AddSection("Status")
status = Farm:AddLabel({ Text = "Idle." })

local GarageTab = Window:AddTab({ Name = "Garage", Icon = "wrench", Subtitle = "Codes" })
local Garage = GarageTab:AddSubTab("Codes")

Garage:AddSection("Codes")
local codeInput = Garage:AddInput({
    Name = "Code",
    Default = "",
    Placeholder = "Type a code",
    Flag = "r1610_code",
})
local garageStatus = Garage:AddLabel({ Text = game.PlaceId == LOBBY and "Ready." or "Garage answers in the lobby only." })

Garage:AddButton({
    Name = "Redeem Code",
    Primary = true,
    Callback = function()
        local ok, text = pcall(function() return codeInput:Get() end)
        local code = ok and text or ""
        if code == "" then
            garageStatus:Set("Type a code first.")
            return
        end
        garageStatus:Set("Redeeming " .. code .. "...")
        local done, msg = redeem(code)
        garageStatus:Set((done and "OK: " or "Failed: ") .. tostring(msg))
    end,
})

Garage:AddButton({
    Name = "Redeem All Known",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Codes only work in the lobby.")
            return
        end
        task.spawn(function()
            for _, code in ipairs(KNOWN_CODES) do
                if stale() then return end
                garageStatus:Set("Redeeming " .. code .. "...")
                local done, msg = redeem(code)
                garageStatus:Set(code .. ": " .. (done and "OK" or tostring(msg)))
                task.wait(2.5)
            end
        end)
    end,
})

Garage:AddSection("Garage")
Garage:AddButton({
    Name = "Load Profile",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Garage answers in the lobby only.")
            return
        end
        garageStatus:Set("Asking the garage...")
        local res, err = garageAsk("state")
        if not res then
            garageStatus:Set("Failed: " .. tostring(err))
            return
        end
        if type(res) == "table" then
            garageStatus:Set(string.format("Level %s | %s credits", tostring(res.level), tostring(res.credits)))
        else
            garageStatus:Set("Answer: " .. tostring(res))
        end
    end,
})

Garage:AddSection("Freebies")
Garage:AddButton({
    Name = "Claim Group Reward",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Lobby only.")
            return
        end
        garageStatus:Set("Claiming group reward...")
        local res, err = garageAsk("group")
        if type(res) == "table" then
            garageStatus:Set((res.ok and "OK" or "Failed: " .. tostring(res.why)))
        else
            garageStatus:Set(tostring(err or res))
        end
    end,
})
Garage:AddButton({
    Name = "Open All Crates",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Lobby only.")
            return
        end
        garageStatus:Set("Opening crates...")
        local ok, msg = openCrates()
        garageStatus:Set((ok and "OK: " or "Failed: ") .. tostring(msg))
    end,
})
Garage:AddButton({
    Name = "Equip Best Car",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Lobby only.")
            return
        end
        local ok, msg = equipBestCar()
        garageStatus:Set((ok and "OK: " or "Failed: ") .. tostring(msg))
    end,
})

local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local Visual = VisualTab:AddSubTab("World")

Visual:AddSection("World")
Visual:AddToggle({
    Name = "Monster ESP",
    Flag = "r1610_esp",
    Default = false,
    Callback = function(v)
        S.esp = v and true or false
        if not S.esp then clearEsp() end
    end,
})
Visual:AddToggle({
    Name = "HUD",
    Flag = "r1610_hud",
    Default = true,
    Callback = function(v)
        S.hud = v and true or false
        if hud then hud.Enabled = S.hud end
    end,
})

Visual:AddSection("Info")
Visual:AddLabel({ Text = "Monster ESP tags Watcher / Scarecrow / Runner / Intruder." })
Visual:AddLabel({ Text = "HUD shows speed, road distance, runner gap, credits." })

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Misc" })
local Settings = SettingsTab:AddSubTab("Session")

Settings:AddSection("Session")
local sessionLabel = Settings:AddLabel({ Text = "0 runs | 0 finishes | 0 caught" })

Settings:AddButton({
    Name = "Refresh Stats",
    Callback = function()
        sessionLabel:Set(string.format("%d runs | %d finishes | %d caught", S.runs, S.finishes, S.caught))
    end,
})

Settings:AddButton({
    Name = "Unload Script",
    Callback = function()
        getgenv().__route1610Gen = (tonumber(getgenv().__route1610Gen) or 0) + 1
        clearOverride()
        clearEsp()
        cleanupGui("ExlumiaaHub")
        cleanupGui("Route1610HUD")
    end,
})

-- ================================================================
-- LOOP
-- ================================================================
buildHud()

local acc = 0
local espAcc = 0
RunService.Heartbeat:Connect(function(dt)
    if stale() then return end
    acc += dt
    espAcc += dt
    if acc >= 0.4 then
        acc = 0
        tickRunLoop()
        updateHud()
        local credits = tonumber(LP:GetAttribute("Credits"))
        if credits then
            if S.creditsStart == nil then S.creditsStart = credits end
            S.creditsGain = credits - S.creditsStart
        end
    end
    if espAcc >= 0.3 then
        espAcc = 0
        if S.esp then refreshEsp() end
    end
end)

LP.OnTeleport:Connect(function()
    clearOverride()
    clearEsp()
end)

getgenv()._route1610 = {
    getState = function()
        return {
            autoRun = S.autoRun,
            drive = S.drive,
            autoRetry = S.autoRetry,
            speedCap = S.speedCap,
            esp = S.esp,
            hud = S.hud,
            runs = S.runs,
            finishes = S.finishes,
            caught = S.caught,
            credits = tonumber(LP:GetAttribute("Credits")),
            hasPath = path ~= nil,
            hasInput = Input ~= nil,
            ctrl = { speed = ctrl.speed, vmax = ctrl.vmax, lat = ctrl.lat, s = ctrl.s },
        }
    end,
    setAutoRun = setAutoRun,
    setDrive = setDrive,
    setSpeed = function(v) S.speedCap = tonumber(v) or S.speedCap end,
    setEsp = function(v)
        S.esp = v and true or false
        if not S.esp then clearEsp() end
    end,
    startRun = fireStart,
    redeem = redeem,
    garage = garageAsk,
    equipBestCar = equipBestCar,
    openCrates = openCrates,
    clearOverride = clearOverride,
}

print("[ExlumiaaHub] Do Not Stop loaded | path=" .. tostring(path ~= nil) .. " input=" .. tostring(Input ~= nil))
