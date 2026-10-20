-- Exlumiaa Hub - Backseat Rally
-- Two client-side helpers:
--   Autopilot     - feeds the game's own AutoDrive into CarInput.Read (driver only)
--   Driver Map    - full-route minimap drawn on the right, since the driver's
--                   cockpit has no map screen (MapScreenController is co-driver only)
--
-- Race state (StageId, Progress, checkpoint) is server-set, so this only steers
-- and draws; it never grants progress.
--
-- CarController.LocalCar / LocalRole / GetChassis() / Recover() are the game's
-- own handles (PlayerScripts.Client.Init.Car).

-- Keyed on game.GameId, which for this experience is the universe id and covers
-- every place in it.
if tostring(game.GameId) ~= "10769543742" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local STATE = rawget(_G, "STATE") or (type(getgenv) == "function" and rawget(getgenv(), "STATE") or nil)

local _G_TOMB = "_ _brTomb"
local _G_ALIVE = "_ _brAlive"
local _G_GEN = "_ _brGen"
local _G_GUI = "_ _brGui"

pcall(cleardrawcache)

do
    local oldGui = rawget(_G, _G_GUI)
    if oldGui and oldGui.Parent then
        pcall(function() oldGui:Destroy() end)
    end
end
pcall(function()
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "Oxidelib") then gui:Destroy() end
        end
    end
end)

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
    rawset(_G, _G_GEN, (tonumber(rawget(_G, _G_GEN)) or 0) + 1)
end
local MY_GEN = tonumber(rawget(_G, _G_GEN))

local function isTomb()
    return rawget(_G, _G_TOMB) == true or tonumber(rawget(_G, _G_GEN)) ~= MY_GEN
end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumiaa Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_backseatrally.txt"
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
        local old = pg:FindFirstChild("BackseatRallyKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "BackseatRallyKeyGate"
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
        title.Text = "Backseat Rally"
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

local function onSignal(signal, fn)
    if STATE and type(STATE.connect) == "function" then
        STATE.connect(signal, fn)
    else
        signal:Connect(fn)
    end
end

-- ================================================================
-- UI LIBRARY
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

Library.ConfigFolder = "exlumiaa/backseatrally"

local saveQueued = false
local function queueSave()
    if saveQueued then return end
    saveQueued = true
    task.delay(1, function()
        saveQueued = false
        pcall(function() Library:SaveConfig("default") end)
    end)
end

local function autosaveWrap(sub)
    if type(sub) ~= "table" then return end
    for _, m in ipairs({ "AddToggle", "AddSlider", "AddDropdown", "AddInput" }) do
        local raw = sub[m]
        if type(raw) == "function" then
            sub[m] = function(self, opts)
                if type(opts) == "table" and type(opts.Callback) == "function" then
                    local cb = opts.Callback
                    opts.Callback = function(...)
                        local r = cb(...)
                        queueSave()
                        return r
                    end
                end
                return raw(self, opts)
            end
        end
    end
end

-- ================================================================
-- GAME MODULES
-- ================================================================
local function waitFor(parent, name, timeout)
    return parent and parent:WaitForChild(name, timeout or 20) or nil
end

local playerScripts = waitFor(LP, "PlayerScripts", 30)
local client = playerScripts and waitFor(playerScripts, "Client", 30)
local init = client and waitFor(client, "Init", 30)
if not init then return end

local function requireChild(parent, name)
    local child = waitFor(parent, name, 20)
    if not child then return nil end
    local ok, mod = pcall(require, child)
    return ok and mod or nil
end

local carFolder = waitFor(init, "Car", 20)
local shared = waitFor(ReplicatedStorage, "Shared", 30)
local core = shared and waitFor(shared, "Core", 30)

local CarController = requireChild(carFolder, "CarController")
local CarInput = requireChild(carFolder, "CarInput")
local AutoDrive = requireChild(carFolder, "AutoDrive")
local Route = requireChild(core, "Route")

if not (CarController and CarInput and AutoDrive and Route) then
    return
end

-- ================================================================
-- STAGES
-- ================================================================
local stageOptions = {}
local stageIdByName = {}
local stageNameById = {}

do
    local stageModule = shared and shared:FindFirstChild("Stages")
    local okStages, stages = pcall(function()
        return stageModule and require(stageModule) or nil
    end)
    local list = {}
    if okStages and type(stages) == "table" then
        for key, cfg in pairs(stages) do
            if type(cfg) == "table" then
                list[#list + 1] = {
                    id = tostring(cfg.Id or key),
                    name = tostring(cfg.Name or cfg.Id or key),
                    order = tonumber(cfg.Order) or 999,
                }
            end
        end
    elseif stageModule then
        for _, child in ipairs(stageModule:GetChildren()) do
            list[#list + 1] = { id = child.Name, name = child.Name, order = 999 }
        end
    end
    table.sort(list, function(a, b)
        if a.order ~= b.order then return a.order < b.order end
        return a.name < b.name
    end)
    for _, entry in ipairs(list) do
        stageOptions[#stageOptions + 1] = entry.name
        stageIdByName[entry.name] = entry.id
        stageNameById[entry.id] = entry.name
    end
end

local stageTravelRemote = nil
do
    local netFolder = shared and shared:FindFirstChild("RBXUtil")
    netFolder = netFolder and netFolder:FindFirstChild("Net")
    stageTravelRemote = netFolder and netFolder:FindFirstChild("RE/StageTravel")
end

-- ================================================================
-- AUTOPILOT
-- ================================================================
local Config = {
    autopilot = false,
    showMap = false,
    mapZoom = 1,
}

-- CarController calls CarInput.Read() once per physics step, so wrapping that
-- shared table is enough to steer without touching the chassis directly.
local originalRead = CarInput.Read
CarInput.Read = function(...)
    local state = originalRead(...)
    if not Config.autopilot or type(state) ~= "table" then
        return state
    end
    if LP:GetAttribute("KnockedOut") == true then
        return state
    end
    local car = CarController.LocalCar
    local chassis = CarController.GetChassis()
    if not car or CarController.LocalRole ~= "Driver" or not chassis then
        return state
    end
    local ok, drive = pcall(AutoDrive.Read, car, chassis)
    if not ok or type(drive) ~= "table" then
        return state
    end
    state.Throttle = math.clamp(drive.Throttle or 0, 0, 1)
    state.Brake = math.clamp(drive.Brake or 0, 0, 1)
    state.Steer = math.clamp(drive.Steer or 0, -1, 1)
    state.Handbrake = drive.Handbrake == true
    state.Analog = false
    if AutoDrive.Stuck then
        AutoDrive.Stuck = false
        pcall(CarController.Recover)
    end
    return state
end

-- ================================================================
-- DRIVER MAP (Drawing)
-- ================================================================
local DRAW_OBJECTS = {}
local mapCache = {
    stage = nil,
    route = nil,
    lines = {},
    corners = {},
    startDot = nil,
    finishDot = nil,
    panel = nil,
    panelStroke = nil,
    title = nil,
    viewportX = 0,
    viewportY = 0,
    lastIndex = nil,
    zoomed = false,
}
local mapElapsed = 0

local function addDrawing(className)
    local obj = Drawing.new(className)
    DRAW_OBJECTS[#DRAW_OBJECTS + 1] = obj
    return obj
end

local function clearDrawings()
    for _, obj in ipairs(DRAW_OBJECTS) do
        pcall(function()
            obj.Visible = false
            obj:Remove()
        end)
    end
    table.clear(DRAW_OBJECTS)
    mapCache.stage = nil
    mapCache.route = nil
    table.clear(mapCache.lines)
    table.clear(mapCache.corners)
    mapCache.startDot = nil
    mapCache.finishDot = nil
    mapCache.panel = nil
    mapCache.panelStroke = nil
    mapCache.title = nil
    mapCache.lastIndex = nil
    mapCache.zoomed = false
end

local function hideDrawings()
    for _, obj in ipairs(DRAW_OBJECTS) do
        obj.Visible = false
    end
end

-- Liang-Barsky: trims a screen-space segment to the map panel so a zoomed map
-- never draws over the game. Returns nil when the segment misses the box.
local function clipSegment(x1, y1, x2, y2, left, top, right, bottom)
    local dx, dy = x2 - x1, y2 - y1
    local t0, t1 = 0, 1
    if dx == 0 then
        if x1 < left or x1 > right then return nil end
    else
        local ra, rb = (left - x1) / dx, (right - x1) / dx
        if ra > rb then ra, rb = rb, ra end
        if ra > t0 then t0 = ra end
        if rb < t1 then t1 = rb end
        if t0 > t1 then return nil end
    end
    if dy == 0 then
        if y1 < top or y1 > bottom then return nil end
    else
        local ra, rb = (top - y1) / dy, (bottom - y1) / dy
        if ra > rb then ra, rb = rb, ra end
        if ra > t0 then t0 = ra end
        if rb < t1 then t1 = rb end
        if t0 > t1 then return nil end
    end
    return x1 + t0 * dx, y1 + t0 * dy, x1 + t1 * dx, y1 + t1 * dy
end

local MAP_MAX_SIZE = 280
local MAP_MIN_SIZE = 150
local MAP_PAD = 14

local function buildMap(stageId)
    clearDrawings()
    local ok, route = pcall(Route.Get, stageId)
    local camera = workspace.CurrentCamera
    if not ok or not route or not camera then return false end
    local viewport = camera.ViewportSize
    if viewport.X < 200 or viewport.Y < 200 then return false end

    mapCache.stage = stageId
    mapCache.route = route
    mapCache.viewportX = viewport.X
    mapCache.viewportY = viewport.Y

    local size = math.clamp(math.min(MAP_MAX_SIZE, viewport.X * 0.3, viewport.Y * 0.55), MAP_MIN_SIZE, MAP_MAX_SIZE)
    local boxX = viewport.X - size - 20
    local boxY = math.max(10, (viewport.Y - size) * 0.5)
    local inner = size - MAP_PAD * 2
    local spanX = math.max(route.Max.X - route.Min.X, 1)
    local spanZ = math.max(route.Max.Z - route.Min.Z, 1)
    local scale = math.min(inner / spanX, inner / spanZ)
    local originX = boxX + MAP_PAD + (inner - spanX * scale) * 0.5
    local originY = boxY + MAP_PAD + (inner - spanZ * scale) * 0.5

    local function toMap(x, z)
        return originX + (x - route.Min.X) * scale, originY + (z - route.Min.Z) * scale
    end
    mapCache.size = size
    mapCache.boxX = boxX
    mapCache.boxY = boxY
    mapCache.scale = scale
    mapCache.originX = originX
    mapCache.originY = originY

    local panel = addDrawing("Square")
    panel.Filled = true
    panel.Color = Color3.fromRGB(10, 12, 16)
    panel.Transparency = 0.35
    panel.Size = Vector2.new(size, size)
    panel.Position = Vector2.new(boxX, boxY)

    local panelStroke = addDrawing("Square")
    panelStroke.Filled = false
    panelStroke.Color = Color3.fromRGB(120, 200, 255)
    panelStroke.Transparency = 0.55
    panelStroke.Thickness = 1
    panelStroke.Size = Vector2.new(size, size)
    panelStroke.Position = Vector2.new(boxX, boxY)

    local title = addDrawing("Text")
    title.Text = stageNameById[stageId] or stageId
    title.Size = 14
    title.Color = Color3.fromRGB(230, 235, 245)
    title.Outline = true
    title.Position = Vector2.new(boxX, boxY - 18)

    mapCache.panel = panel
    mapCache.panelStroke = panelStroke
    mapCache.title = title

    -- The line pool is fixed at build time: at 1x it keeps these fit-all
    -- coordinates, above 1x updateMap rewrites them around the car each tick.
    local step = math.max(1, math.ceil(route.Count / 300))
    local index = 1
    while index < route.Count do
        local nextIndex = math.min(route.Count, index + step)
        local a = route.P[index]
        local b = route.P[nextIndex]
        if a and b then
            local ax, ay = toMap(a.X, a.Z)
            local bx, by = toMap(b.X, b.Z)
            local line = addDrawing("Line")
            line.From = Vector2.new(ax, ay)
            line.To = Vector2.new(bx, by)
            line.Color = Color3.fromRGB(225, 230, 240)
            line.Thickness = 2
            line.Transparency = 0.15
            mapCache.lines[#mapCache.lines + 1] = {
                line = line,
                a = a,
                b = b,
                from = Vector2.new(ax, ay),
                to = Vector2.new(bx, by),
            }
        end
        index = nextIndex
    end

    local startPoint = route.P[1]
    if startPoint then
        local startDot = addDrawing("Circle")
        startDot.Filled = true
        startDot.Radius = 4
        startDot.Color = Color3.fromRGB(70, 220, 120)
        mapCache.startDot = { dot = startDot, pos = startPoint }
    end

    local finishPoint = route.P[route.Count]
    if finishPoint then
        local finishDot = addDrawing("Circle")
        finishDot.Filled = true
        finishDot.Radius = 4
        finishDot.Color = Color3.fromRGB(255, 90, 90)
        mapCache.finishDot = { dot = finishDot, pos = finishPoint }
    end

    for _, corner in ipairs(route.Corners) do
        if #mapCache.corners >= 70 then break end
        local severity = tonumber(corner.Severity) or 6
        if severity < 6 then
            local distance = corner.Apex or corner.From
            if distance then
                local point = route:PointAt(distance)
                local dot = addDrawing("Circle")
                dot.Filled = true
                dot.Radius = 2
                dot.Color = Color3.fromRGB(255, 175, 60)
                dot.Transparency = 0.2
                mapCache.corners[#mapCache.corners + 1] = { dot = dot, pos = point }
            end
        end
    end

    local carDot = addDrawing("Circle")
    carDot.Filled = true
    carDot.Radius = 5
    carDot.Color = Color3.fromRGB(0, 220, 255)
    carDot.Visible = false

    local heading = addDrawing("Line")
    heading.Thickness = 2
    heading.Color = Color3.fromRGB(0, 220, 255)

    local progress = addDrawing("Text")
    progress.Text = ""
    progress.Size = 13
    progress.Color = Color3.fromRGB(230, 235, 245)
    progress.Outline = true
    progress.Position = Vector2.new(boxX, boxY + size + 4)

    mapCache.carDot = carDot
    mapCache.heading = heading
    mapCache.progress = progress

    hideDrawings()
    return true
end

local function updateMap()
    local car = CarController.LocalCar
    local role = CarController.LocalRole
    local part = car and car.PrimaryPart
    if not part or role ~= "Driver" then
        hideDrawings()
        mapCache.lastIndex = nil
        return
    end

    local stageId = car:GetAttribute("StageId")
    local camera = workspace.CurrentCamera
    if not stageId or not camera then
        hideDrawings()
        return
    end

    local viewport = camera.ViewportSize
    if not mapCache.route
        or mapCache.stage ~= stageId
        or mapCache.viewportX ~= viewport.X
        or mapCache.viewportY ~= viewport.Y
    then
        if not buildMap(stageId) then
            hideDrawings()
            return
        end
    end

    local route = mapCache.route
    local position = part.Position
    local nearestIndex, distance = route:Nearest(position, mapCache.lastIndex, 80, 160)
    mapCache.lastIndex = nearestIndex

    local roadPoint = route:PointAt(distance)
    local boxX, boxY, size = mapCache.boxX, mapCache.boxY, mapCache.size
    local left, top = boxX + 2, boxY + 2
    local right, bottom = boxX + size - 2, boxY + size - 2
    local zoom = math.max(1, Config.mapZoom or 1)
    local projectX, projectY

    if zoom > 1.01 then
        local centerX, centerY = boxX + size * 0.5, boxY + size * 0.5
        local factor = mapCache.scale * zoom
        local centerWorldX, centerWorldZ = roadPoint.X, roadPoint.Z

        for _, entry in ipairs(mapCache.lines) do
            local ax = centerX + (entry.a.X - centerWorldX) * factor
            local ay = centerY + (entry.a.Z - centerWorldZ) * factor
            local bx = centerX + (entry.b.X - centerWorldX) * factor
            local by = centerY + (entry.b.Z - centerWorldZ) * factor
            local x1, y1, x2, y2 = clipSegment(ax, ay, bx, by, left, top, right, bottom)
            if x1 then
                entry.line.From = Vector2.new(x1, y1)
                entry.line.To = Vector2.new(x2, y2)
                entry.line.Visible = true
            else
                entry.line.Visible = false
            end
        end

        projectX = function(wx) return centerX + (wx - centerWorldX) * factor end
        projectY = function(wz) return centerY + (wz - centerWorldZ) * factor end
        mapCache.zoomed = true
    else
        if mapCache.zoomed then
            for _, entry in ipairs(mapCache.lines) do
                entry.line.From = entry.from
                entry.line.To = entry.to
                entry.line.Visible = true
            end
            mapCache.zoomed = false
        end
        projectX = function(wx) return mapCache.originX + (wx - route.Min.X) * mapCache.scale end
        projectY = function(wz) return mapCache.originY + (wz - route.Min.Z) * mapCache.scale end
    end

    local function placeDot(entry)
        if not entry then return end
        local px, py = projectX(entry.pos.X), projectY(entry.pos.Z)
        entry.dot.Position = Vector2.new(px, py)
        entry.dot.Visible = px >= left and px <= right and py >= top and py <= bottom
    end
    placeDot(mapCache.startDot)
    placeDot(mapCache.finishDot)
    for _, corner in ipairs(mapCache.corners) do
        placeDot(corner)
    end

    local markerX, markerY = projectX(roadPoint.X), projectY(roadPoint.Z)

    local look = part.CFrame.LookVector
    local dirX, dirZ = look.X, look.Z
    local magnitude = math.sqrt(dirX * dirX + dirZ * dirZ)
    if magnitude > 0.001 then
        dirX, dirZ = dirX / magnitude, dirZ / magnitude
    end

    mapCache.carDot.Position = Vector2.new(markerX, markerY)
    mapCache.heading.From = Vector2.new(markerX, markerY)
    mapCache.heading.To = Vector2.new(markerX + dirX * 12, markerY + dirZ * 12)

    local text = string.format("%s  |  %.1f / %.1f km", stageNameById[stageId] or stageId, distance / 1000, route.Length / 1000)
    if zoom > 1.01 then
        text = text .. string.format("  |  %.1fx", zoom)
    end
    mapCache.progress.Text = text

    mapCache.panel.Visible = true
    mapCache.panelStroke.Visible = true
    mapCache.title.Visible = true
    mapCache.carDot.Visible = true
    mapCache.heading.Visible = true
    mapCache.progress.Visible = true
end

onSignal(RunService.Heartbeat, function(delta)
    if not Config.showMap or isTomb() then return end
    mapElapsed = mapElapsed + delta
    if mapElapsed < 0.05 then return end
    mapElapsed = 0
    updateMap()
end)

-- ================================================================
-- MENU
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Backseat Rally",
    Size = UDim2.fromOffset(540, 440),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Backseat Rally",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

pcall(function()
    local gui = Window:FindFirstChildOfClass("ScreenGui") or Library.ScreenGui
    if gui then rawset(_G, _G_GUI, gui) end
end)

local function notify(title, content, ntype)
    pcall(function()
        Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 })
    end)
end

local DrivingTab = Window:AddTab({ Name = "Driving", Icon = "car", Subtitle = "Auto" })
local AutoSub = DrivingTab:AddSubTab("Autopilot")
autosaveWrap(AutoSub)

AutoSub:AddSection("Autopilot")
AutoSub:AddToggle({
    Name = "Autopilot",
    Flag = "br_autopilot",
    Default = false,
    Callback = function(v)
        Config.autopilot = v
        if v then
            notify("Autopilot", "Sit in the driver seat and start a run.", "info")
        end
    end,
})

local MapSub = DrivingTab:AddSubTab("Map")
autosaveWrap(MapSub)

MapSub:AddSection("Driver Map")
MapSub:AddToggle({
    Name = "Show Map",
    Flag = "br_map",
    Default = false,
    Callback = function(v)
        Config.showMap = v
        if not v then hideDrawings() end
    end,
})
MapSub:AddSlider({
    Name = "Zoom",
    Min = 100,
    Max = 600,
    Default = 100,
    Suffix = "%",
    Flag = "br_map_zoom",
    Callback = function(v)
        Config.mapZoom = math.clamp(tonumber(v) or 100, 100, 600) / 100
    end,
})

local stageDropdown
if stageTravelRemote and #stageOptions > 0 then
    local StagesTab = Window:AddTab({ Name = "Stages", Icon = "map", Subtitle = "Travel" })
    local StagesSub = StagesTab:AddSubTab("Select")
    autosaveWrap(StagesSub)

    StagesSub:AddSection("Stage")
    stageDropdown = StagesSub:AddDropdown({
        Name = "Stage",
        Options = stageOptions,
        Default = stageOptions[1],
        Flag = "br_stage",
        Callback = function(v) end,
    })
    StagesSub:AddDivider()
    StagesSub:AddButton({
        Name = "Travel",
        Primary = true,
        Callback = function()
            local name = stageDropdown:Get()
            local stageId = name and stageIdByName[name]
            if not stageId then
                notify("Stages", "Pick a stage first!", "warning")
                return
            end
            if CarController.LocalCar then
                notify("Stages", "Exit the car first.", "warning")
                return
            end
            local ok = pcall(function()
                stageTravelRemote:FireServer("Go", stageId)
            end)
            if ok then
                notify("Stages", "Traveling to " .. name, "success")
            else
                notify("Stages", "Travel failed.", "error")
            end
        end,
    })
end

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
autosaveWrap(ConfigSub)

ConfigSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "br_config_selected",
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
    Flag = "br_config_name",
})

ConfigSub:AddDivider()
ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            notify("Config", "Enter a name first!", "warning")
            return
        end
        local ok = Library:SaveConfig(name)
        if ok then
            refreshConfigList()
            notify("Config", "Saved: " .. name, "success")
        else
            notify("Config", "Save failed.", "error")
        end
    end,
})
ConfigSub:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if selectedConfig == "" then
            notify("Config", "Pick a config first!", "warning")
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Load failed.", "error")
        end
    end,
})

ConfigSub:AddSection("About")
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })
ConfigSub:AddLabel({ Text = "Toggle Menu: RightShift" })

-- ================================================================
-- CLEANUP
-- ================================================================
local function cleanup()
    Config.autopilot = false
    Config.showMap = false
    pcall(function()
        CarInput.Read = originalRead
    end)
    clearDrawings()
    pcall(cleardrawcache)
    local gui = rawget(_G, _G_GUI)
    if gui and gui.Parent then
        pcall(function() gui:Destroy() end)
    end
    pcall(function() Library:Unload() end)
    rawset(_G, _G_ALIVE, nil)
end

if STATE and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(cleanup)
end

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

print("[ExlumiaaHub] Backseat Rally Hub loaded!")
