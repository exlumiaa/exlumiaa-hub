if tostring(game.GameId) ~= "9534705677" then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local STATE = STATE

local ES = nil
do
    local ok, m = pcall(require, ReplicatedStorage:WaitForChild("Remote"):WaitForChild("EntityService"))
    if ok and type(m) == "table" then ES = m end
end

local _G_TOMB = "_ _arcFpsTomb"
local _G_ALIVE = "_ _arcFpsAlive"
local _G_GEN = "_ _arcFpsGen"
local _G_GUI = "_ _arcFpsGui"

pcall(cleardrawcache)

do
    local oldGui = rawget(_G, _G_GUI)
    if oldGui and oldGui.Parent then
        pcall(function() oldGui:Destroy() end)
    end
end

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name == "ExlumiaaHub" then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name == "ExlumiaaHub" then gui:Destroy() end
        end
    end)
end

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
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_sniper.txt"
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
        local old = pg:FindFirstChild("SniperArenaKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "SniperArenaKeyGate"
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
        title.Text = "Sniper Arena"
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

Library.ConfigFolder = "exlumiaa/arcadefps"

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

local Config = {
    espEnabled = false,
    espBox = true,
    espFill = false,
    espName = true,
    espDistance = true,
    espHealthbar = true,
    espTracer = false,
    espSkeleton = false,
    espHeadDot = false,
    espChams = false,
    espTeamCheck = true,
    espSelf = false,
    espMaxDist = 1500,
    aimEnabled = false,
    aimFov = 150,
    aimSmooth = 5,
    aimPred = true,
    aimPredPct = 16,
    aimPart = "Head",
    silentEnabled = false,
    fovCircle = true,
    aimWallCheck = true,
}

local ENEMY_COLOR = Color3.fromRGB(255, 0, 80)
local SELF_COLOR = Color3.fromRGB(0, 255, 120)
local NEUTRAL_COLOR = Color3.fromRGB(255, 255, 255)

local drawCache = {}

local function newDrawing(class, props)
    local d = Drawing.new(class)
    for k, v in pairs(props) do
        d[k] = v
    end
    return d
end

local function createDrawings()
    return {
        boxOutline1 = newDrawing("Line", { Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0) }),
        boxOutline2 = newDrawing("Line", { Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0) }),
        boxOutline3 = newDrawing("Line", { Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0) }),
        boxOutline4 = newDrawing("Line", { Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0) }),
        box1 = newDrawing("Line", { Visible = false, Thickness = 1.5 }),
        box2 = newDrawing("Line", { Visible = false, Thickness = 1.5 }),
        box3 = newDrawing("Line", { Visible = false, Thickness = 1.5 }),
        box4 = newDrawing("Line", { Visible = false, Thickness = 1.5 }),
        snap1 = newDrawing("Line", { Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.4 }),
        snap2 = newDrawing("Line", { Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.4 }),
        fill = newDrawing("Quad", { Visible = false, Thickness = 1, Filled = true, Transparency = 0.12 }),
        tracerOutline = newDrawing("Line", { Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0) }),
        tracer = newDrawing("Line", { Visible = false, Thickness = 1.5 }),
        name = newDrawing("Text", { Visible = false, Size = 14, Center = true, Outline = true, Font = 2 }),
        dist = newDrawing("Text", { Visible = false, Size = 12, Center = true, Outline = true, Font = 2 }),
        healthBg = newDrawing("Quad", { Visible = false, Thickness = 0, Filled = true }),
        healthFg = newDrawing("Quad", { Visible = false, Thickness = 0, Filled = true }),
        healthText = newDrawing("Text", { Visible = false, Size = 11, Center = false, Outline = true, Font = 2 }),
        headDot = newDrawing("Circle", { Visible = false, Radius = 4, Filled = true }),
        headDotOutline = newDrawing("Circle", { Visible = false, Radius = 6, Filled = false, Thickness = 1.5 }),
        skelOut = {},
        skel = {},
    }
end

local function initSkeletonLines(d)
    for i = 1, 12 do
        d.skelOut[i] = newDrawing("Line", { Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0) })
        d.skel[i] = newDrawing("Line", { Visible = false, Thickness = 1.5 })
    end
end

local function removeDrawings(cache)
    if not cache then return end
    for _, v in pairs(cache) do
        pcall(function()
            if typeof(v) == "Instance" then
                v:Destroy()
            elseif v.Remove then
                v:Remove()
            end
        end)
    end
end

local function hideDrawings(cache)
    if not cache then return end
    for _, v in pairs(cache) do
        pcall(function()
            if typeof(v) == "Instance" then
                if v.Parent then v:Destroy() end
            elseif v.Visible ~= nil then
                v.Visible = false
            end
        end)
    end
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Radius = Config.aimFov
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7

local FOVCircleOutline = Drawing.new("Circle")
FOVCircleOutline.Thickness = 3
FOVCircleOutline.Radius = Config.aimFov
FOVCircleOutline.Filled = false
FOVCircleOutline.Visible = false
FOVCircleOutline.Color = Color3.new(0, 0, 0)
FOVCircleOutline.Transparency = 0.5

local function isTeammate(player)
    if not Config.espTeamCheck then return false end
    local lt = LP.Team
    local rt = player.Team
    if lt ~= nil and rt ~= nil and lt == rt then return true end
    if LP:GetAttribute("combatPaused") == true then return false end
    local okv, res = pcall(function()
        local ent = ES and ES.FetchEntity and ES.FetchEntity(player.Character)
        if ent and ES.LocalEntity then
            return ES.LocalEntity:IsFriendly(ent) == true
        end
        return false
    end)
    return okv and res == true
end

local function getPlayerColor(player)
    if player == LP then return SELF_COLOR end
    if isTeammate(player) then return NEUTRAL_COLOR end
    return ENEMY_COLOR
end

local npcList = {}
local npcScanTime = 0

local function refreshNpcs()
    local now = os.clock()
    if now - npcScanTime < 0.5 then return end
    npcScanTime = now
    local list = {}
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Humanoid") then
                local m = d.Parent
                if m and m:IsA("Model") and m:FindFirstChild("HumanoidRootPart")
                    and Players:GetPlayerFromCharacter(m) == nil then
                    list[#list + 1] = m
                end
            end
        end
    end)
    npcList = list
end

local function enumerateTargets()
    refreshNpcs()
    local out = {}
    for _, player in ipairs(Players:GetPlayers()) do
        out[#out + 1] = { ref = player, player = player, char = player.Character, name = player.DisplayName }
    end
    for _, npc in ipairs(npcList) do
        if npc.Parent then
            out[#out + 1] = { ref = npc, player = nil, char = npc, name = npc.Name }
        end
    end
    return out
end

local function getBoundingBox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return nil end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end

    local rootPos = hrp.Position
    local topPos = head.Position + Vector3.new(0, 0.6, 0)
    local botPos = rootPos - Vector3.new(0, 3, 0)

    local topScreen, topOnScreen = Camera:WorldToViewportPoint(topPos)
    local botScreen, botOnScreen = Camera:WorldToViewportPoint(botPos)

    if not topOnScreen and not botOnScreen then return nil end

    local topY = topScreen.Y
    local botY = botScreen.Y
    local centerX = (topScreen.X + botScreen.X) / 2
    local height = math.abs(botY - topY)
    local width = height * 0.4

    local tl = Vector2.new(centerX - width / 2, topY)
    local tr = Vector2.new(centerX + width / 2, topY)
    local bl = Vector2.new(centerX - width / 2, botY)
    local br = Vector2.new(centerX + width / 2, botY)

    return {
        topLeft = tl,
        topRight = tr,
        botLeft = bl,
        botRight = br,
        top = Vector2.new(centerX, topY),
        bot = Vector2.new(centerX, botY),
        center = Vector2.new(centerX, (topY + botY) / 2),
        width = width,
        height = height,
        head = head,
        hrp = hrp,
        hum = hum,
    }
end

local function updateESP(entry)
    local key = entry.ref
    if not Config.espEnabled or isTomb() then
        if drawCache[key] then
            removeDrawings(drawCache[key])
            drawCache[key] = nil
        end
        return
    end

    if entry.player == LP and not Config.espSelf then
        if drawCache[key] then
            removeDrawings(drawCache[key])
            drawCache[key] = nil
        end
        return
    end

    if entry.player and isTeammate(entry.player) then
        if drawCache[key] then
            removeDrawings(drawCache[key])
            drawCache[key] = nil
        end
        return
    end

    local char = entry.char
    if not char or not char.Parent then
        if drawCache[key] then
            removeDrawings(drawCache[key])
            drawCache[key] = nil
        end
        return
    end

    local bb = getBoundingBox(char)
    if not bb then
        hideDrawings(drawCache[key])
        return
    end

    if bb.hum.Health <= 0 then
        hideDrawings(drawCache[key])
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist > Config.espMaxDist then
        if drawCache[key] then
            removeDrawings(drawCache[key])
            drawCache[key] = nil
        end
        return
    end

    if not drawCache[key] then
        drawCache[key] = createDrawings()
        initSkeletonLines(drawCache[key])
    end
    local d = drawCache[key]
    local col = entry.player and getPlayerColor(entry.player) or ENEMY_COLOR

    local tl, tr, bl, br = bb.topLeft, bb.topRight, bb.botLeft, bb.botRight

    if Config.espBox then
        d.boxOutline1.From = tl; d.boxOutline1.To = tr; d.boxOutline1.Visible = true
        d.boxOutline2.From = bl; d.boxOutline2.To = br; d.boxOutline2.Visible = true
        d.boxOutline3.From = tl; d.boxOutline3.To = bl; d.boxOutline3.Visible = true
        d.boxOutline4.From = tr; d.boxOutline4.To = br; d.boxOutline4.Visible = true

        d.box1.From = tl; d.box1.To = tr; d.box1.Color = col; d.box1.Visible = true
        d.box2.From = bl; d.box2.To = br; d.box2.Color = col; d.box2.Visible = true
        d.box3.From = tl; d.box3.To = bl; d.box3.Color = col; d.box3.Visible = true
        d.box4.From = tr; d.box4.To = br; d.box4.Color = col; d.box4.Visible = true

        local snapLen = math.clamp(bb.width * 0.15, 6, 16)
        d.snap1.From = tl + Vector2.new(0, snapLen); d.snap1.To = tl + Vector2.new(snapLen, snapLen); d.snap1.Visible = true
        d.snap2.From = tr + Vector2.new(0, snapLen); d.snap2.To = tr + Vector2.new(-snapLen, snapLen); d.snap2.Visible = true
    else
        for i = 1, 4 do d["box" .. i].Visible = false; d["boxOutline" .. i].Visible = false end
        d.snap1.Visible = false; d.snap2.Visible = false
    end

    if Config.espFill then
        d.fill.PointA = bb.topLeft; d.fill.PointB = bb.topRight
        d.fill.PointC = bb.botRight; d.fill.PointD = bb.botLeft
        d.fill.Color = col; d.fill.Visible = true
    else
        d.fill.Visible = false
    end

    if Config.espTracer then
        local bottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        d.tracer.From = bottom; d.tracer.To = bb.center; d.tracer.Color = col; d.tracer.Visible = true
        d.tracerOutline.From = bottom; d.tracerOutline.To = bb.center; d.tracerOutline.Visible = true
    else
        d.tracer.Visible = false; d.tracerOutline.Visible = false
    end

    if Config.espName then
        d.name.Position = Vector2.new(bb.center.X, bb.topLeft.Y - 18)
        d.name.Text = entry.name
        d.name.Color = col
        d.name.Visible = true
    else
        d.name.Visible = false
    end

    if Config.espDistance then
        d.dist.Position = Vector2.new(bb.center.X, bb.botLeft.Y + 6)
        d.dist.Text = math.floor(dist) .. "m"
        d.dist.Color = col
        d.dist.Visible = true
    else
        d.dist.Visible = false
    end

    if Config.espHealthbar then
        local hum = bb.hum
        local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local barW = 3
        local barH = bb.height
        local barX = bb.topLeft.X - barW - 6
        local barTopY = bb.topLeft.Y
        local barBotY = bb.botLeft.Y
        local fillY = barBotY - (barH * hp)

        d.healthBg.PointA = Vector2.new(barX, barTopY)
        d.healthBg.PointB = Vector2.new(barX + barW, barTopY)
        d.healthBg.PointC = Vector2.new(barX + barW, barBotY)
        d.healthBg.PointD = Vector2.new(barX, barBotY)
        d.healthBg.Color = Color3.new(0, 0, 0)
        d.healthBg.Visible = true

        local hpColor = hp > 0.6 and Color3.fromRGB(0, 255, 100) or hp > 0.3 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 50, 50)
        d.healthFg.PointA = Vector2.new(barX, barBotY)
        d.healthFg.PointB = Vector2.new(barX + barW, barBotY)
        d.healthFg.PointC = Vector2.new(barX + barW, fillY)
        d.healthFg.PointD = Vector2.new(barX, fillY)
        d.healthFg.Color = hpColor
        d.healthFg.Visible = true

        d.healthText.Position = Vector2.new(barX - 2, fillY - 6)
        d.healthText.Text = tostring(math.floor(hp * 100))
        d.healthText.Color = hpColor
        d.healthText.Visible = true
    else
        d.healthBg.Visible = false; d.healthFg.Visible = false; d.healthText.Visible = false
    end

    if Config.espHeadDot and bb.head then
        local headPos, onScreen = Camera:WorldToViewportPoint(bb.head.Position + Vector3.new(0, 0.5, 0))
        if onScreen then
            d.headDot.Position = Vector2.new(headPos.X, headPos.Y)
            d.headDot.Color = col
            d.headDot.Visible = true
            d.headDotOutline.Position = Vector2.new(headPos.X, headPos.Y)
            d.headDotOutline.Color = col
            d.headDotOutline.Visible = true
        else
            d.headDot.Visible = false; d.headDotOutline.Visible = false
        end
    else
        d.headDot.Visible = false; d.headDotOutline.Visible = false
    end

    if Config.espSkeleton then
        local function drawBone(idx, a, b)
            if not a or not b then d.skel[idx].Visible = false; d.skelOut[idx].Visible = false; return end
            local pA, vA = Camera:WorldToViewportPoint(a.Position)
            local pB, vB = Camera:WorldToViewportPoint(b.Position)
            if not vA or not vB then d.skel[idx].Visible = false; d.skelOut[idx].Visible = false; return end
            d.skel[idx].From = Vector2.new(pA.X, pA.Y); d.skel[idx].To = Vector2.new(pB.X, pB.Y); d.skel[idx].Color = col; d.skel[idx].Visible = true
            d.skelOut[idx].From = Vector2.new(pA.X, pA.Y); d.skelOut[idx].To = Vector2.new(pB.X, pB.Y); d.skelOut[idx].Visible = true
        end
        local head = char:FindFirstChild("Head")
        local neck = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        local root = char:FindFirstChild("HumanoidRootPart")
        local lArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local rArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        local lLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
        local rLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
        local torso = char:FindFirstChild("LowerTorso") or neck
        drawBone(1, head, neck)
        drawBone(2, neck, root)
        drawBone(3, neck, lArm)
        drawBone(4, neck, rArm)
        drawBone(5, torso, lLeg)
        drawBone(6, torso, rLeg)
        for i = 7, 12 do d.skel[i].Visible = false; d.skelOut[i].Visible = false end
    else
        for i = 1, 12 do d.skel[i].Visible = false; d.skelOut[i].Visible = false end
    end

    if Config.espChams then
        if not d.chamsHighlight or not d.chamsHighlight.Parent then
            local h = Instance.new("Highlight")
            h.Name = "_ArcadeChams"
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
            d.chamsHighlight = h
        end
        d.chamsHighlight.FillColor = col
        d.chamsHighlight.OutlineColor = col
        d.chamsHighlight.Enabled = true
    elseif d.chamsHighlight then
        pcall(function() d.chamsHighlight:Destroy() end)
        d.chamsHighlight = nil
    end
end

local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Exclude

local function getAimTargetPart(entry)
    local char = entry.char
    if not char then return nil end
    local part = char:FindFirstChild(Config.aimPart)
    if not part then
        part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    end
    return part
end

local function isValidTarget(entry)
    if entry.player == LP then return false end
    if entry.player and isTeammate(entry.player) then return false end
    local char = entry.char
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function hasLOS(entry, part)
    if not Config.aimWallCheck then return true end
    local char = entry.char
    if not char then return false end
    local filter = {}
    if LP.Character then filter[#filter + 1] = LP.Character end
    losParams.FilterDescendantsInstances = filter
    local origin = Camera.CFrame.Position
    local res = workspace:Raycast(origin, part.Position - origin, losParams)
    if not res then return true end
    return res.Instance:IsDescendantOf(char) or res.Instance == part
end

local function getClosestTarget()
    local closest = nil
    local closestDist = Config.aimFov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, entry in ipairs(enumerateTargets()) do
        if not isValidTarget(entry) then continue end

        local part = getAimTargetPart(entry)
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        if not hasLOS(entry, part) then continue end

        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist < closestDist then
            closestDist = screenDist
            closest = entry
        end
    end

    return closest
end

local function resolveAimPos(entry)
    local part = getAimTargetPart(entry)
    if not part then return nil end
    local aimPos = part.Position
    if Config.aimPred then
        local char = entry.char
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            aimPos = aimPos + hrp.Velocity * (Config.aimPredPct / 100)
        end
    end
    return aimPos
end

local CS = nil
do
    local ok, m = pcall(require, ReplicatedStorage:WaitForChild("Remote"):WaitForChild("CombatService"))
    if ok and type(m) == "table" then
        CS = m
    end
end

local ORIG_KEY = "_ _arcFpsOrig"

local function redirectShot(args)
    local target = getClosestTarget()
    local aimPos = target and resolveAimPos(target)
    if not aimPos then
        getgenv()._cap = { t = os.clock(), redirected = false, cam = workspace.CurrentCamera.CFrame.LookVector }
        return
    end
    local startPos = args.Start
    if typeof(startPos) == "CFrame" then
        startPos = startPos.Position
    end
    args.Direction = (aimPos - startPos).Unit
    args.Spread = 0
    pcall(function()
        local char = target.char
        local ent = ES and ES.FetchEntity and ES.FetchEntity(char)
        if ent then
            args.Target = ent.Instance
            args.TargetPos = char:GetPivot():PointToObjectSpace(aimPos)
            args.TargetHeadshot = Config.aimPart == "Head"
        else
            args.Target = nil
            args.TargetPos = nil
            args.TargetHeadshot = nil
        end
    end)
    getgenv()._cap = {
        t = os.clock(),
        redirected = true,
        dir = args.Direction,
        start = startPos,
        aimPos = aimPos,
        tgtName = target.name,
        cam = workspace.CurrentCamera.CFrame.LookVector,
    }
end

local hookedFns = {}

local function wrapCombat()
    if not CS then return end
    getgenv()._wrapN = 0
    local useOverride = STATE ~= nil and type(STATE.override) == "function"
    local store = nil
    if not useOverride then
        store = rawget(_G, ORIG_KEY)
        if type(store) ~= "table" then
            store = {}
            rawset(_G, ORIG_KEY, store)
        end
    end
    for _, name in ipairs({ "InvokeAction", "FireAction", "FireUnreliableAction" }) do
        local base = CS[name]
        if type(base) ~= "function" then continue end
        local wrapped = false
        if type(hookfunction) == "function" then
            local orig
            local ok = pcall(function()
                orig = hookfunction(base, function(weapon, action, args)
                    getgenv()._wrapN = (getgenv()._wrapN or 0) + 1
                    if Config.silentEnabled and not isTomb()
                        and typeof(args) == "table"
                        and typeof(args.Direction) == "Vector3"
                        and (typeof(args.Start) == "Vector3" or typeof(args.Start) == "CFrame") then
                        pcall(redirectShot, args)
                    end
                    return orig(weapon, action, args)
                end)
            end)
            if ok and type(orig) == "function" then
                hookedFns[name] = { target = base, original = orig }
                wrapped = true
            end
        end
        if not wrapped then
            local wrapper = function(weapon, action, args)
                getgenv()._wrapN = (getgenv()._wrapN or 0) + 1
                if Config.silentEnabled and not isTomb()
                    and typeof(args) == "table"
                    and typeof(args.Direction) == "Vector3"
                    and (typeof(args.Start) == "Vector3" or typeof(args.Start) == "CFrame") then
                    pcall(redirectShot, args)
                end
                return base(weapon, action, args)
            end
            if useOverride then
                STATE.override(CS, name, wrapper)
            else
                store[name] = base
                CS[name] = wrapper
            end
        end
    end
end

local function unwrapCombat()
    for name, h in pairs(hookedFns) do
        pcall(function() hookfunction(h.target, h.original) end)
    end
    hookedFns = {}
    local store = rawget(_G, ORIG_KEY)
    if type(store) == "table" and type(CS) == "table" then
        for name, base in pairs(store) do
            if type(base) == "function" then
                pcall(function() CS[name] = base end)
            end
        end
    end
    rawset(_G, ORIG_KEY, nil)
end

wrapCombat()

local function cleanup()
    rawset(_G, _G_TOMB, true)
    task.wait(0.1)
    for _, cache in pairs(drawCache) do
        removeDrawings(cache)
    end
    drawCache = {}
    pcall(function() FOVCircle:Remove() end)
    pcall(function() FOVCircleOutline:Remove() end)
    unwrapCombat()
    pcall(cleardrawcache)
    local gui = rawget(_G, _G_GUI)
    if gui and gui.Parent then
        pcall(function() gui:Destroy() end)
    end
    rawset(_G, _G_ALIVE, nil)
end

if STATE and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(cleanup)
end

task.spawn(function()
    while not isTomb() do
        pcall(function()
            Camera = workspace.CurrentCamera
            if not Config.espEnabled then
                for _, cache in pairs(drawCache) do
                    removeDrawings(cache)
                end
                drawCache = {}
                return
            end
            local alive = {}
            for _, entry in ipairs(enumerateTargets()) do
                alive[entry.ref] = true
                pcall(updateESP, entry)
            end
            for k, cache in pairs(drawCache) do
                if not alive[k] then
                    removeDrawings(cache)
                    drawCache[k] = nil
                end
            end
        end)
        task.wait(0.016)
    end
end)

onSignal(Players.PlayerRemoving, function(player)
    if drawCache[player] then
        removeDrawings(drawCache[player])
        drawCache[player] = nil
    end
end)

onSignal(RunService.RenderStepped, function()
    if isTomb() then return end
    pcall(function()
        Camera = workspace.CurrentCamera
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local showFov = Config.fovCircle and (Config.aimEnabled or Config.silentEnabled)
        FOVCircle.Position = center
        FOVCircle.Radius = Config.aimFov
        FOVCircle.Visible = showFov
        FOVCircleOutline.Position = center
        FOVCircleOutline.Radius = Config.aimFov
        FOVCircleOutline.Visible = showFov

        if not Config.aimEnabled then return end

        local target = getClosestTarget()
        if not target then return end
        local aimPos = resolveAimPos(target)
        if not aimPos then return end

        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.lookAt(camPos, aimPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / math.max(1, Config.aimSmooth))
    end)
end)

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "[Arcade] Beginner",
    Size = UDim2.fromOffset(540, 460),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "[Arcade] Beginner",
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

local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local VisualSub = VisualTab:AddSubTab("Players")
autosaveWrap(VisualSub)

VisualSub:AddSection("ESP")
VisualSub:AddToggle({
    Name = "ESP Enabled",
    Flag = "af_esp_enabled",
    Default = false,
    Callback = function(v) Config.espEnabled = v end,
})
VisualSub:AddToggle({
    Name = "Box",
    Flag = "af_esp_box",
    Default = true,
    Callback = function(v) Config.espBox = v end,
})
VisualSub:AddToggle({
    Name = "Fill",
    Flag = "af_esp_fill",
    Default = false,
    Callback = function(v) Config.espFill = v end,
})
VisualSub:AddToggle({
    Name = "Name",
    Flag = "af_esp_name",
    Default = true,
    Callback = function(v) Config.espName = v end,
})
VisualSub:AddToggle({
    Name = "Distance",
    Flag = "af_esp_distance",
    Default = true,
    Callback = function(v) Config.espDistance = v end,
})
VisualSub:AddToggle({
    Name = "Health Bar",
    Flag = "af_esp_health",
    Default = true,
    Callback = function(v) Config.espHealthbar = v end,
})
VisualSub:AddToggle({
    Name = "Tracer",
    Flag = "af_esp_tracer",
    Default = false,
    Callback = function(v) Config.espTracer = v end,
})
VisualSub:AddToggle({
    Name = "Skeleton",
    Flag = "af_esp_skeleton",
    Default = false,
    Callback = function(v) Config.espSkeleton = v end,
})
VisualSub:AddToggle({
    Name = "Head Dot",
    Flag = "af_esp_headdot",
    Default = false,
    Callback = function(v) Config.espHeadDot = v end,
})
VisualSub:AddToggle({
    Name = "Chams",
    Flag = "af_esp_chams",
    Default = false,
    Callback = function(v) Config.espChams = v end,
})
VisualSub:AddToggle({
    Name = "Team Check",
    Flag = "af_esp_teamcheck",
    Default = true,
    Callback = function(v) Config.espTeamCheck = v end,
})
VisualSub:AddToggle({
    Name = "Self ESP",
    Flag = "af_esp_self",
    Default = false,
    Callback = function(v) Config.espSelf = v end,
})
VisualSub:AddSlider({
    Name = "Max Distance",
    Min = 100,
    Max = 3000,
    Default = 1500,
    Suffix = " studs",
    Flag = "af_esp_maxdist",
    Callback = function(v) Config.espMaxDist = v end,
})

local CombatTab = Window:AddTab({ Name = "Combat", Icon = "crosshair", Subtitle = "Aim" })
local CombatSub = CombatTab:AddSubTab("Aimbot")
autosaveWrap(CombatSub)

CombatSub:AddSection("Aimbot")
CombatSub:AddToggle({
    Name = "Aimbot",
    Flag = "af_aim_enabled",
    Default = false,
    Callback = function(v) Config.aimEnabled = v end,
})
CombatSub:AddToggle({
    Name = "Wall Check",
    Flag = "af_aim_wallcheck",
    Default = true,
    Callback = function(v) Config.aimWallCheck = v end,
})
CombatSub:AddToggle({
    Name = "Show FOV Circle",
    Flag = "af_fov_circle",
    Default = true,
    Callback = function(v) Config.fovCircle = v end,
})
CombatSub:AddSlider({
    Name = "FOV",
    Min = 50,
    Max = 500,
    Default = 150,
    Suffix = " px",
    Flag = "af_aim_fov",
    Callback = function(v) Config.aimFov = v end,
})
CombatSub:AddSlider({
    Name = "Smoothing",
    Min = 1,
    Max = 20,
    Default = 5,
    Flag = "af_aim_smooth",
    Callback = function(v) Config.aimSmooth = v end,
})
CombatSub:AddDropdown({
    Name = "Target Part",
    Options = { "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso" },
    Default = "Head",
    Flag = "af_aim_part",
    Callback = function(v)
        if type(v) == "string" then Config.aimPart = v end
    end,
})
CombatSub:AddToggle({
    Name = "Prediction",
    Flag = "af_aim_pred",
    Default = true,
    Callback = function(v) Config.aimPred = v end,
})
CombatSub:AddSlider({
    Name = "Prediction Amount",
    Min = 0,
    Max = 50,
    Default = 16,
    Suffix = "%",
    Flag = "af_aim_predpct",
    Callback = function(v) Config.aimPredPct = v end,
})

CombatSub:AddSection("Silent Aim")
CombatSub:AddToggle({
    Name = "Silent Aim",
    Flag = "af_silent_enabled",
    Default = false,
    Callback = function(v) Config.silentEnabled = v end,
})
CombatSub:AddLabel({ Text = "Bullets steer to the nearest target inside FOV" })
CombatSub:AddLabel({ Text = "Shares aimbot FOV and prediction settings" })

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
autosaveWrap(ConfigSub)

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "af_config_selected",
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
    Flag = "af_config_name",
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
            notify("Config", "Save failed!", "error")
        end
    end,
})

ConfigSub:AddButton({
    Name = "Load Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning")
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Failed to load!", "error")
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning")
            return
        end
        Library:DeleteConfig(selectedConfig)
        local old = selectedConfig
        selectedConfig = ""
        refreshConfigList()
        notify("Config", "Deleted: " .. old, "info")
    end,
})

ConfigSub:AddDivider()
ConfigSub:AddSection("Info")
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })
ConfigSub:AddLabel({ Text = "Toggle Menu: RightShift" })

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

print("[ExlumiaaHub] Arcade FPS Hub loaded!")
