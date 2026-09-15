if tostring(game.GameId) ~= "903807016" then return end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_erlc.txt"

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
        local old = pg:FindFirstChild("ErlcKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "ErlcKeyGate"
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
        title.Text = "Exlumiaa Hub"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 22
        title.TextColor3 = Color3.fromRGB(240, 242, 250)
        title.Parent = card
        local titleGrad = Instance.new("UIGradient"); titleGrad.Rotation = -8; titleGrad.Color = ColorSequence.new(accent, Color3.fromRGB(220, 235, 255)); titleGrad.Parent = title

        local subtitle = Instance.new("TextLabel")
        subtitle.Size = UDim2.new(1, 0, 0, 16)
        subtitle.Position = UDim2.fromOffset(0, 62)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = "ERLC - Enter your key to unlock"
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
                task.wait(0.1)
            end
            if gui and gui.Parent then
                pcall(function() gui:Destroy() end)
            end
        end
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local localTeam = LP.Team and LP.Team.Name or ""

local _G_TOMB = "_ _erlcOxTomb"
local _G_ALIVE = "_ _erlcOxAlive"

-- Nuke ALL orphaned Drawing objects from previous runs
pcall(cleardrawcache)

-- Destroy old GUIs (Obsidian + previous Oxidelib runs)
do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub") then
                gui:Destroy()
            end
        end
    end)
    pcall(function()
        for _, gui in ipairs(LP:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub") then
                gui:Destroy()
            end
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
end

-- ========== Config ==========
local Config = {
    enabled = false,
    box = true,
    fillBox = false,
    name = true,
    distance = true,
    healthbar = true,
    tracer = false,
    skeleton = false,
    headDot = false,
    chams = false,
    outline = true,
    role = false,
    vehicle = false,
    teamCheck = false,
    teamColors = true,
    selfESP = false,
    maxDist = 2000,
    -- Aimbot
    aimEnabled = false,
    aimFov = 150,
    aimSmooth = 5,
    aimPrediction = true,
    aimPredFactor = 0.15,
    noRecoil = false,
    infStamina = false,
    aimTargetPart = "Head",
    aimTeamCheck = true,
}

local TEAM_COLORS = {
    Police = Color3.fromRGB(0, 120, 255),
    Sheriff = Color3.fromRGB(220, 200, 150),
    Fire = Color3.fromRGB(255, 60, 40),
    DOT = Color3.fromRGB(255, 160, 40),
    Civilian = Color3.fromRGB(180, 180, 180),
}

local ENEMY_COLOR = Color3.fromRGB(255, 0, 80)
local SELF_COLOR = Color3.fromRGB(0, 255, 120)
local NEUTRAL_COLOR = Color3.fromRGB(255, 255, 255)

-- ========== Drawing Cache ==========
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
        boxOutline1 = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        boxOutline2 = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        boxOutline3 = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        boxOutline4 = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        box1 = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        box2 = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        box3 = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        box4 = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        snap1 = newDrawing("Line", {Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.4}),
        snap2 = newDrawing("Line", {Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.4}),
        fill = newDrawing("Quad", {Visible = false, Thickness = 1, Filled = true, Transparency = 0.12}),
        tracerOutline = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        tracer = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        name = newDrawing("Text", {Visible = false, Size = 14, Center = true, Outline = true, Font = 2}),
        dist = newDrawing("Text", {Visible = false, Size = 12, Center = true, Outline = true, Font = 2}),
        healthBg = newDrawing("Quad", {Visible = false, Thickness = 0, Filled = true}),
        healthFg = newDrawing("Quad", {Visible = false, Thickness = 0, Filled = true}),
        healthText = newDrawing("Text", {Visible = false, Size = 11, Center = false, Outline = true, Font = 2}),
        headDot = newDrawing("Circle", {Visible = false, Radius = 4, Filled = true}),
        headDotOutline = newDrawing("Circle", {Visible = false, Radius = 6, Filled = false, Thickness = 1.5}),
        skelOut = {}, skel = {},
    }
end

local function initSkeletonLines(d)
    for i = 1, 12 do
        d.skelOut[i] = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)})
        d.skel[i] = newDrawing("Line", {Visible = false, Thickness = 1.5})
    end
end

local function removeDrawings(cache)
    for _, v in pairs(cache) do
        if typeof(v) == "Instance" then
            v:Destroy()
        elseif v.Remove then
            v:Remove()
        end
    end
end

local function hideDrawings(cache)
    if not cache then return end
    for _, v in pairs(cache) do
        if typeof(v) == "Instance" then
            v:Destroy()
        elseif v.Visible ~= nil then
            v.Visible = false
        end
    end
end

-- ========== Aimbot ==========
local TARGET_PARTS = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = Config.aimFov
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7

local FOVCircleOutline = Drawing.new("Circle")
FOVCircleOutline.Thickness = 3
FOVCircleOutline.NumSides = 64
FOVCircleOutline.Radius = Config.aimFov
FOVCircleOutline.Filled = false
FOVCircleOutline.Visible = false
FOVCircleOutline.Color = Color3.new(0, 0, 0)
FOVCircleOutline.Transparency = 0.5

local aimTarget = nil
local recoilZeroed = false

local function disconnectRecoil()
    recoilZeroed = false
end

local function getAimTargetPart(player)
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild(Config.aimTargetPart)
end

local function isAimEnemy(player)
    if player == LP then return false end
    if Config.aimTeamCheck and player.Team == LP.Team then return false end
    return true
end

local function getClosestPlayer()
    local closest = nil
    local closestDist = Config.aimFov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if not isAimEnemy(player) then continue end
        local part = getAimTargetPart(player)
        if not part then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist < closestDist then
            closestDist = screenDist
            closest = player
        end
    end

    return closest
end

local function startRecoilCounter()
    if recoilZeroed then return end
    recoilZeroed = true
    local folder = game.ReplicatedStorage.Shared:FindFirstChild("WeaponStats")
    if not folder then
        folder = game.ReplicatedStorage.Shared:FindFirstChild("UsableStats")
    end
    if folder then
        for _, v in folder:GetChildren() do
            if v:IsA("ModuleScript") then
                local ok, stats = pcall(require, v)
                if ok and type(stats) == "table" then
                    if stats.CameraKickMax then stats.CameraKickMax = Vector3.new(0, 0, 0) end
                    if stats.CameraKickMin then stats.CameraKickMin = Vector3.new(0, 0, 0) end
                    if stats.CameraAimKickMax then stats.CameraAimKickMax = Vector3.new(0, 0, 0) end
                    if stats.CameraAimKickMin then stats.CameraAimKickMin = Vector3.new(0, 0, 0) end
                    if stats.RecoilPatternX then stats.RecoilPatternX = Vector2.new(0, 0) end
                    if stats.RecoilPatternY then stats.RecoilPatternY = Vector2.new(0, 0) end
                    if stats.RecoilPatternZ then stats.RecoilPatternZ = Vector2.new(0, 0) end
                end
            end
        end
    end
end

local function getPlayerColor(player)
    if player == LP then return SELF_COLOR end
    if Config.teamCheck and player.Team == LP.Team then return NEUTRAL_COLOR end
    if Config.teamColors and player.Team then
        return TEAM_COLORS[player.Team.Name] or NEUTRAL_COLOR
    end
    return ENEMY_COLOR
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
        topLeft = tl, topRight = tr, botLeft = bl, botRight = br,
        top = Vector2.new(centerX, topY), bot = Vector2.new(centerX, botY),
        center = Vector2.new(centerX, (topY + botY) / 2),
        width = width, height = height, head = head, hrp = hrp, hum = hum,
    }
end

local function updateESP(player)
    if not Config.enabled then
        if drawCache[player] then removeDrawings(drawCache[player]); drawCache[player] = nil end
        return
    end
    if player == LP and not Config.selfESP then
        if drawCache[player] then removeDrawings(drawCache[player]); drawCache[player] = nil end
        return
    end
    if Config.teamCheck and player.Team == LP.Team then
        if drawCache[player] then removeDrawings(drawCache[player]); drawCache[player] = nil end
        return
    end

    local char = player.Character
    if not char then
        if drawCache[player] then removeDrawings(drawCache[player]); drawCache[player] = nil end
        return
    end

    local bb = getBoundingBox(char)
    if not bb then hideDrawings(drawCache[player]); return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist > Config.maxDist then
        if drawCache[player] then removeDrawings(drawCache[player]); drawCache[player] = nil end
        return
    end

    if not drawCache[player] then
        drawCache[player] = createDrawings()
        initSkeletonLines(drawCache[player])
    end
    local d = drawCache[player]
    local col = getPlayerColor(player)
    local tl, tr, bl, br = bb.topLeft, bb.topRight, bb.botLeft, bb.botRight

    -- Full Box
    if Config.box then
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
        for i = 1, 4 do d["box"..i].Visible = false; d["boxOutline"..i].Visible = false end
        d.snap1.Visible = false; d.snap2.Visible = false
    end

    -- Fill Box
    if Config.fillBox then
        d.fill.PointA = bb.topLeft; d.fill.PointB = bb.topRight
        d.fill.PointC = bb.botRight; d.fill.PointD = bb.botLeft
        d.fill.Color = col; d.fill.Visible = true
    else
        d.fill.Visible = false
    end

    -- Tracer
    if Config.tracer then
        local bottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        d.tracer.From = bottom; d.tracer.To = bb.center; d.tracer.Color = col; d.tracer.Visible = true
        d.tracerOutline.From = bottom; d.tracerOutline.To = bb.center; d.tracerOutline.Visible = true
    else
        d.tracer.Visible = false; d.tracerOutline.Visible = false
    end

    -- Name
    if Config.name then
        d.name.Position = Vector2.new(bb.center.X, bb.topLeft.Y - 18)
        d.name.Text = player.DisplayName
        d.name.Color = col; d.name.Visible = true
    else
        d.name.Visible = false
    end

    -- Distance
    if Config.distance then
        d.dist.Position = Vector2.new(bb.center.X, bb.botLeft.Y + 6)
        d.dist.Text = math.floor(dist) .. "m"
        d.dist.Color = col; d.dist.Visible = true
    else
        d.dist.Visible = false
    end

    -- Healthbar
    if Config.healthbar then
        local hum = bb.hum
        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
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
        d.healthText.Text = math.floor(hp * 100)
        d.healthText.Color = hpColor
        d.healthText.Visible = true
    else
        d.healthBg.Visible = false; d.healthFg.Visible = false; d.healthText.Visible = false
    end

    -- Head Dot
    if Config.headDot and bb.head then
        local headPos, onScreen = Camera:WorldToViewportPoint(bb.head.Position + Vector3.new(0, 0.5, 0))
        if onScreen then
            d.headDot.Position = Vector2.new(headPos.X, headPos.Y)
            d.headDot.Color = col; d.headDot.Visible = true
            d.headDotOutline.Position = Vector2.new(headPos.X, headPos.Y)
            d.headDotOutline.Color = col; d.headDotOutline.Visible = true
        else
            d.headDot.Visible = false; d.headDotOutline.Visible = false
        end
    else
        d.headDot.Visible = false; d.headDotOutline.Visible = false
    end

    -- Skeleton
    if Config.skeleton then
        local function worldToScreen(pos)
            local s, v = Camera:WorldToViewportPoint(pos)
            return Vector2.new(s.X, s.Y), v
        end
        local function getPart(name)
            return char:FindFirstChild(name)
        end
        local function drawBone(idx, a, b)
            if not a or not b then d.skel[idx].Visible = false; d.skelOut[idx].Visible = false; return end
            local pA, vA = Camera:WorldToViewportPoint(a.Position)
            local pB, vB = Camera:WorldToViewportPoint(b.Position)
            if not vA or not vB then d.skel[idx].Visible = false; d.skelOut[idx].Visible = false; return end
            local from = Vector2.new(pA.X, pA.Y)
            local to = Vector2.new(pB.X, pB.Y)
            d.skel[idx].From = from; d.skel[idx].To = to; d.skel[idx].Color = col; d.skel[idx].Visible = true
            d.skelOut[idx].From = from; d.skelOut[idx].To = to; d.skelOut[idx].Visible = true
        end
        local head = getPart("Head")
        local neck = getPart("UpperTorso") or getPart("Torso")
        local root = getPart("HumanoidRootPart")
        local lArm = getPart("Left Arm") or getPart("LeftUpperArm")
        local rArm = getPart("Right Arm") or getPart("RightUpperArm")
        local lLeg = getPart("Left Leg") or getPart("LeftUpperLeg")
        local rLeg = getPart("Right Leg") or getPart("RightUpperLeg")
        local torso = getPart("LowerTorso") or neck
        drawBone(1, head, neck)
        drawBone(2, neck, root)
        drawBone(3, neck, lArm)
        drawBone(4, neck, rArm)
        drawBone(5, torso, lLeg)
        drawBone(6, torso, rLeg)
    else
        for i = 1, 12 do d.skel[i].Visible = false; d.skelOut[i].Visible = false end
    end

    -- Role/Job
    if Config.role then
        if not d.roleText then
            d.roleText = newDrawing("Text", {Visible = false, Size = 11, Center = true, Outline = true, Font = 2})
        end
        local roleName = player.Team and player.Team.Name or "None"
        d.roleText.Position = Vector2.new(bb.center.X, bb.topLeft.Y - 30)
        d.roleText.Text = roleName
        d.roleText.Color = col; d.roleText.Visible = true
    else
        if d.roleText then d.roleText.Visible = false end
    end

    -- Chams
    if not Config.chams and d.chamsHighlight then
        d.chamsHighlight:Destroy()
        d.chamsHighlight = nil
    elseif Config.chams then
        if not d.chamsHighlight then
            local h = Instance.new("Highlight")
            h.Name = "_ERLCChams"
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
            d.chamsHighlight = h
        end
        d.chamsHighlight.FillColor = col
        d.chamsHighlight.OutlineColor = col
        d.chamsHighlight.Enabled = true
    end
end

-- ========== Vehicle ESP ==========
local vehicleDrawCache = {}

local function updateVehicleESP()
    if not Config.vehicle then
        for v, cache in pairs(vehicleDrawCache) do
            for _, drawing in pairs(cache) do
                if drawing.Remove then drawing:Remove() end
            end
        end
        vehicleDrawCache = {}
        return
    end

    local function createVehicleDrawings()
        return {
            boxOutline1 = newDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0)}),
            boxOutline2 = newDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0)}),
            boxOutline3 = newDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0)}),
            boxOutline4 = newDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0)}),
            box1 = newDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(0, 200, 255)}),
            box2 = newDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(0, 200, 255)}),
            box3 = newDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(0, 200, 255)}),
            box4 = newDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(0, 200, 255)}),
            name = newDrawing("Text", {Visible = false, Size = 13, Center = true, Outline = true, Font = 2}),
            dist = newDrawing("Text", {Visible = false, Size = 11, Center = true, Outline = true, Font = 2}),
        }
    end

    local function getVehicleBB(veh)
        local cf = veh:GetPivot()
        local size = Vector3.new(0, 0, 0)
        pcall(function()
            for _, part in veh:GetDescendants() do
                if part:IsA("BasePart") then
                    local ps = part.Size
                    local px = math.abs(part.CFrame:VectorToObjectSpace(cf.Position).X) + ps.X / 2
                    size = Vector3.new(math.max(size.X, px), math.max(size.Y, ps.Y), math.max(size.Z, ps.Z))
                end
            end
        end)
        if size == Vector3.new(0, 0, 0) then size = Vector3.new(5, 3, 8) end

        local topPos = cf.Position + Vector3.new(0, size.Y / 2 + 0.5, 0)
        local botPos = cf.Position - Vector3.new(0, 0.5, 0)
        local topS, topV = Camera:WorldToViewportPoint(topPos)
        local botS, botV = Camera:WorldToViewportPoint(botPos)
        if not topV and not botV then return nil end

        local topY = topS.Y; local botY = botS.Y
        local centerX = (topS.X + botS.X) / 2
        local height = math.abs(botY - topY)
        local width = height * 0.6

        return {
            topLeft = Vector2.new(centerX - width / 2, topY),
            topRight = Vector2.new(centerX + width / 2, topY),
            botLeft = Vector2.new(centerX - width / 2, botY),
            botRight = Vector2.new(centerX + width / 2, botY),
            center = Vector2.new(centerX, (topY + botY) / 2),
        }
    end

    local currentVehicles = {}
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
            local veh = obj:FindFirstAncestorOfClass("Model")
            if veh and not currentVehicles[veh] then
                currentVehicles[veh] = true
            end
        end
    end

    for v, cache in pairs(vehicleDrawCache) do
        if not currentVehicles[v] then
            for _, drawing in pairs(cache) do
                if drawing.Remove then drawing:Remove() end
            end
            vehicleDrawCache[v] = nil
        end
    end

    for veh in currentVehicles do
        local bb = getVehicleBB(veh)
        if not bb then
            if vehicleDrawCache[veh] then
                for _, drawing in pairs(vehicleDrawCache[veh]) do
                    if drawing.Visible ~= nil then drawing.Visible = false end
                end
            end
            continue
        end

        local dist = (Camera.CFrame.Position - veh:GetPivot().Position).Magnitude
        if dist > Config.maxDist then
            if vehicleDrawCache[veh] then
                for _, drawing in pairs(vehicleDrawCache[veh]) do
                    if drawing.Visible ~= nil then drawing.Visible = false end
                end
            end
            continue
        end

        if not vehicleDrawCache[veh] then
            vehicleDrawCache[veh] = createVehicleDrawings()
        end
        local d = vehicleDrawCache[veh]
        local vCol = Color3.fromRGB(0, 200, 255)

        local tl, tr, bl, br = bb.topLeft, bb.topRight, bb.botLeft, bb.botRight
        d.boxOutline1.From = tl; d.boxOutline1.To = tr; d.boxOutline1.Visible = true
        d.boxOutline2.From = bl; d.boxOutline2.To = br; d.boxOutline2.Visible = true
        d.boxOutline3.From = tl; d.boxOutline3.To = bl; d.boxOutline3.Visible = true
        d.boxOutline4.From = tr; d.boxOutline4.To = br; d.boxOutline4.Visible = true
        d.box1.From = tl; d.box1.To = tr; d.box1.Visible = true
        d.box2.From = bl; d.box2.To = br; d.box2.Visible = true
        d.box3.From = tl; d.box3.To = bl; d.box3.Visible = true
        d.box4.From = tr; d.box4.To = br; d.box4.Visible = true

        local vehName = veh.Name
        d.name.Position = Vector2.new(bb.center.X, bb.topLeft.Y - 16)
        d.name.Text = vehName; d.name.Color = vCol; d.name.Visible = true
        d.dist.Position = Vector2.new(bb.center.X, bb.botLeft.Y + 4)
        d.dist.Text = math.floor(dist) .. "m"; d.dist.Color = vCol; d.dist.Visible = true
    end
end

-- ========== Cleanup ==========
local function cleanup()
    rawset(_G, _G_TOMB, true)
    task.wait(0.1)
    for player, cache in pairs(drawCache) do
        removeDrawings(cache)
    end
    drawCache = {}
    for v, cache in pairs(vehicleDrawCache) do
        for _, drawing in pairs(cache) do
            if drawing.Remove then drawing:Remove() end
        end
    end
    vehicleDrawCache = {}
    disconnectRecoil()
    pcall(function() FOVCircle:Remove() end)
    pcall(function() FOVCircleOutline:Remove() end)
    rawset(_G, _G_ALIVE, nil)
end

if STATE then
    STATE.onCleanup(cleanup)
end

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

-- Config persistence folder
Library.ConfigFolder = "exlumiaa"

-- Logo via getcustomasset. normalizeAssetId in Oxidelib mangles rbxasset://
-- URIs (turns them into rbxassetid://7), so set the ImageLabels directly.
local logoId = nil
pcall(function()
    if isfile and isfile("exlumiaa_logo.png") then
        logoId = getcustomasset("exlumiaa_logo.png")
    end
end)

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "ERLC",
    Size = UDim2.fromOffset(700, 490),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "ERLC",
    LoadingFooter = "by Exlumiaa Hub",
    Logo = logoId,
    GuiName = "ExlumiaaHub",
})

-- Override the (mangled) logo with the real getcustomasset content
if logoId then
    pcall(function()
        if Window.Logo then Window.Logo.Image = logoId end
        if Window.Watermark then Window.Watermark.Image = logoId end
    end)
    -- Loading-screen images already exist at creation; they were built with
    -- the mangled id, so nothing more to fix there.
end

-- ======================== HOME TAB ========================
local HomeTab = Window:AddTab({Name = "Home", Icon = "home", Subtitle = "Info"})
local InfoSub = HomeTab:AddSubTab("Info")

InfoSub:AddSection("Player")
local labelPlayers = InfoSub:AddLabel({Text = "Players: " .. #Players:GetPlayers()})
local labelFPS = InfoSub:AddLabel({Text = "FPS: --"})
local labelPing = InfoSub:AddLabel({Text = "Ping: --"})
local labelPos = InfoSub:AddLabel({Text = "Pos: --"})

InfoSub:AddSection("Server")
InfoSub:AddLabel({Text = "Place: " .. tostring(game.PlaceId)})
InfoSub:AddLabel({Text = "Job: " .. tostring(game.JobId)})
local hwid = "N/A"
pcall(function() hwid = gethwid() end)
InfoSub:AddLabel({Text = "HWID: " .. string.sub(hwid, 1, 20) .. "..."})
InfoSub:AddButton({
    Name = "Copy HWID",
    Primary = false,
    Callback = function()
        pcall(setclipboard, hwid)
        Window:Notify({Title = "HWID", Content = "HWID copied!", Type = "success", Duration = 3})
    end,
})

InfoSub:AddDivider()

InfoSub:AddSection("Discord")
InfoSub:AddLabel({Text = "Join our Discord!"})
InfoSub:AddButton({
    Name = "Copy Invite",
    Primary = false,
    Callback = function()
        local ok = pcall(setclipboard, "https://discord.gg/aKxnSwhRxx")
        Window:Notify({
            Title = "Discord",
            Content = ok and "Invite link copied!" or "Copy failed",
            Type = ok and "success" or "error",
            Duration = 3,
        })
    end,
})

-- Ping updater
task.spawn(function()
    local avgPing = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        pcall(function()
            local stats = game:GetService("Stats")
            local pi = stats.Network.ServerStatsItem["Data Ping"]
            avgPing = avgPing * 0.8 + pi:GetValue() * 0.2
            labelPing:Set("Ping: " .. math.floor(avgPing + 0.5) .. "ms")
            labelPlayers:Set("Players: " .. #Players:GetPlayers())
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                labelPos:Set(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
            end
        end)
    end
end)

-- FPS Counter
task.spawn(function()
    local lastTick = tick()
    local frames = 0
    while true do
        if rawget(_G, _G_TOMB) then break end
        frames += 1
        if tick() - lastTick >= 1 then
            labelFPS:Set("FPS: " .. frames)
            frames = 0
            lastTick = tick()
        end
        task.wait()
    end
end)

-- ======================== VISUAL TAB ========================
local VisualTab = Window:AddTab({Name = "Visual", Icon = "eye", Subtitle = "ESP"})
local EspSub = VisualTab:AddSubTab("ESP")
local OptSub = VisualTab:AddSubTab("Options")

EspSub:AddSection("ESP Elements")
EspSub:AddToggle({Name = "Enable ESP", Default = Config.enabled, Flag = "esp_enabled", Callback = function(s) Config.enabled = s end})
EspSub:AddToggle({Name = "Box", Default = Config.box, Flag = "esp_box", Callback = function(s) Config.box = s end})
EspSub:AddToggle({Name = "Fill Box", Default = Config.fillBox, Flag = "esp_fill", Callback = function(s) Config.fillBox = s end})
EspSub:AddToggle({Name = "Name", Default = Config.name, Flag = "esp_name", Callback = function(s) Config.name = s end})
EspSub:AddToggle({Name = "Distance", Default = Config.distance, Flag = "esp_dist", Callback = function(s) Config.distance = s end})
EspSub:AddToggle({Name = "Healthbar", Default = Config.healthbar, Flag = "esp_hpbar", Callback = function(s) Config.healthbar = s end})
EspSub:AddToggle({Name = "Tracer", Default = Config.tracer, Flag = "esp_tracer", Callback = function(s) Config.tracer = s end})
EspSub:AddToggle({Name = "Head Dot", Default = Config.headDot, Flag = "esp_hdot", Callback = function(s) Config.headDot = s end})
EspSub:AddToggle({Name = "Chams", Default = Config.chams, Flag = "esp_chams", Callback = function(s) Config.chams = s end})
EspSub:AddToggle({Name = "Outline", Default = Config.outline, Flag = "esp_outline", Callback = function(s) Config.outline = s end})
EspSub:AddToggle({Name = "Skeleton", Default = Config.skeleton, Flag = "esp_skeleton", Callback = function(s) Config.skeleton = s end})
EspSub:AddToggle({Name = "Role/Job", Default = Config.role, Flag = "esp_role", Callback = function(s) Config.role = s end})
EspSub:AddToggle({Name = "Vehicle ESP", Default = Config.vehicle, Flag = "esp_vehicle", Callback = function(s) Config.vehicle = s end})

OptSub:AddSection("Settings")
OptSub:AddToggle({Name = "Team Check", Default = Config.teamCheck, Flag = "esp_teamcheck", Callback = function(s) Config.teamCheck = s end})
OptSub:AddToggle({Name = "Team Based Colors", Default = Config.teamColors, Flag = "esp_teamcolors", Callback = function(s) Config.teamColors = s end})
OptSub:AddToggle({Name = "Self ESP", Default = Config.selfESP, Flag = "esp_selfesp", Callback = function(s) Config.selfESP = s end})
OptSub:AddSlider({Name = "Max Distance", Min = 100, Max = 5000, Default = Config.maxDist, Suffix = "m", Flag = "esp_maxdist", Callback = function(v) Config.maxDist = v end})

OptSub:AddDivider()
OptSub:AddSection("Team Colors")
OptSub:AddLabel({Text = "Police: Blue"})
OptSub:AddLabel({Text = "Sheriff: Beige"})
OptSub:AddLabel({Text = "Fire: Red"})
OptSub:AddLabel({Text = "DOT: Orange"})
OptSub:AddLabel({Text = "Civilian: Gray"})

-- ======================== AIMBOT TAB ========================
local AimTab = Window:AddTab({Name = "Aimbot", Icon = "crosshair", Subtitle = "Aimbot"})
local AimMain = AimTab:AddSubTab("Aimbot")
local AimOpt = AimTab:AddSubTab("Options")

AimMain:AddSection("Aimbot")
AimMain:AddToggle({Name = "Enable Aimbot", Default = Config.aimEnabled, Flag = "aim_enabled", Callback = function(s) Config.aimEnabled = s end})
AimMain:AddToggle({Name = "Prediction", Default = Config.aimPrediction, Flag = "aim_pred", Callback = function(s) Config.aimPrediction = s end})
AimMain:AddSlider({Name = "FOV Radius", Min = 50, Max = 500, Default = Config.aimFov, Flag = "aim_fov", Callback = function(v) Config.aimFov = v end})
AimMain:AddSlider({Name = "Smoothness", Min = 1, Max = 20, Default = Config.aimSmooth, Flag = "aim_smooth", Callback = function(v) Config.aimSmooth = v end})
AimMain:AddSlider({Name = "Prediction Factor", Min = 0, Max = 100, Default = Config.aimPredFactor * 100, Suffix = "%", Flag = "aim_predfactor", Callback = function(v) Config.aimPredFactor = v / 100 end})

AimOpt:AddSection("Options")
AimOpt:AddToggle({Name = "Team Check", Default = Config.aimTeamCheck, Flag = "aim_teamcheck", Callback = function(s) Config.aimTeamCheck = s end})
AimOpt:AddToggle({Name = "No Recoil", Default = Config.noRecoil, Flag = "aim_norecoil", Callback = function(s)
    Config.noRecoil = s
    if s then startRecoilCounter() else disconnectRecoil() end
end})
AimOpt:AddDropdown({Name = "Target Part", Options = TARGET_PARTS, Default = Config.aimTargetPart, Flag = "aim_targetpart", Callback = function(v) Config.aimTargetPart = v end})

AimOpt:AddDivider()
AimOpt:AddSection("Target Part Info")
AimOpt:AddLabel({Text = "Head - Headshot"})
AimOpt:AddLabel({Text = "HumanoidRootPart - Center mass"})
AimOpt:AddLabel({Text = "UpperTorso - Upper body"})
AimOpt:AddLabel({Text = "LowerTorso - Lower body"})

-- ======================== PLAYER TAB ========================
local PlayerTab = Window:AddTab({Name = "Player", Icon = "user", Subtitle = "Player Mods"})
local PlayerSub = PlayerTab:AddSubTab("Player Mods")

PlayerSub:AddSection("Player")
local staminaWSC = nil
local origRemoveLayer = nil
local staminaConn = nil

PlayerSub:AddToggle({Name = "Infinity Stamina", Default = Config.infStamina, Flag = "inf_stamina", Callback = function(s)
    Config.infStamina = s
    if s then
        if not staminaWSC then
            local ok, wsc = pcall(require, game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WalkSpeedController"))
            if ok and wsc then
                staminaWSC = wsc
                local mt = getmetatable(wsc)
                local idx = mt and rawget(mt, "__index")
                if type(idx) == "table" and idx.removeLayer then
                    origRemoveLayer = idx.removeLayer
                    idx.removeLayer = function(self, layerId)
                        if layerId == "Sprint" and Config.infStamina then return end
                        return origRemoveLayer(self, layerId)
                    end
                end
            end
        end
        if not staminaConn then
            staminaConn = RunService.Heartbeat:Connect(function()
                if not Config.infStamina then return end
                local char = LP.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                hum.JumpPower = 50
                local ok, wsc = pcall(require, game.ReplicatedStorage.Modules.WalkSpeedController)
                if ok and wsc then
                    if not wsc:getLayerById("Sprint") then
                        local mt = getmetatable(wsc)
                        local idx = mt and rawget(mt, "__index")
                        if idx and idx.addLayer then
                            wsc:addLayer("Sprint", idx.Priority.Movement, idx.Modifier.Set, 23)
                        end
                    end
                end
            end)
        end
    else
        if staminaConn then staminaConn:Disconnect(); staminaConn = nil end
        if staminaWSC then
            local mt = getmetatable(staminaWSC)
            local idx = mt and rawget(mt, "__index")
            if type(idx) == "table" and origRemoveLayer then
                idx.removeLayer = origRemoveLayer
            end
            staminaWSC = nil
            origRemoveLayer = nil
        end
    end
end})

PlayerSub:AddButton({
    Name = "Reset JumpPower",
    Primary = false,
    Callback = function()
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end,
})

-- ======================== SETTINGS TAB ========================
local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})
local ConfigSub = SettingsTab:AddSubTab("Config")
local HopSub = SettingsTab:AddSubTab("Server Hop")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "config_selected",
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
    Flag = "config_name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            Window:Notify({Title = "Config", Content = "Enter a name first!", Type = "warning", Duration = 3})
            return
        end
        local ok = Library:SaveConfig(name)
        if ok then
            refreshConfigList()
            Window:Notify({Title = "Config", Content = "Saved: " .. name, Type = "success", Duration = 3})
        else
            Window:Notify({Title = "Config", Content = "Save failed!", Type = "error", Duration = 3})
        end
    end,
})

ConfigSub:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3})
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            Window:Notify({Title = "Config", Content = "Loaded: " .. selectedConfig, Type = "success", Duration = 3})
        else
            Window:Notify({Title = "Config", Content = "Failed to load!", Type = "error", Duration = 3})
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3})
            return
        end
        Library:DeleteConfig(selectedConfig)
        local old = selectedConfig
        selectedConfig = ""
        refreshConfigList()
        Window:Notify({Title = "Config", Content = "Deleted: " .. old, Type = "info", Duration = 3})
    end,
})

HopSub:AddSection("Server Hop")
HopSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        Window:Notify({Title = "Server Hop", Content = "Finding a new server...", Type = "info", Duration = 3})
        local ok, err = pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        end)
        if not ok then
            Window:Notify({Title = "Server Hop", Content = "Failed: " .. tostring(err), Type = "error", Duration = 5})
        end
    end,
})

-- Load last config on startup
pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

-- ======================== LOOPS ========================

-- ESP Loop
task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        task.wait(0.016)
        pcall(function()
            Camera = workspace.CurrentCamera
            for _, player in ipairs(Players:GetPlayers()) do
                pcall(updateESP, player)
            end
            pcall(updateVehicleESP)
        end)
    end
end)

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if rawget(_G, _G_TOMB) then return end
    Camera = workspace.CurrentCamera

    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Config.aimFov
    FOVCircleOutline.Position = mousePos
    FOVCircleOutline.Radius = Config.aimFov
    FOVCircle.Visible = Config.aimEnabled
    FOVCircleOutline.Visible = Config.aimEnabled

    if not Config.aimEnabled then
        aimTarget = nil
        disconnectRecoil()
        return
    end

    aimTarget = getClosestPlayer()

    if not aimTarget then
        disconnectRecoil()
        return
    end

    local part = getAimTargetPart(aimTarget)
    if not part then
        disconnectRecoil()
        return
    end

    local aimPos = part.Position
    if Config.aimPrediction then
        local hrp = aimTarget.Character and aimTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            aimPos = aimPos + hrp.Velocity * Config.aimPredFactor
        end
    end

    local camPos = Camera.CFrame.Position
    local targetCF = CFrame.lookAt(camPos, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Config.aimSmooth)

    if Config.noRecoil then
        if not recoilZeroed then startRecoilCounter() end
    else
        disconnectRecoil()
    end
end)

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(player)
    if drawCache[player] then
        removeDrawings(drawCache[player])
        drawCache[player] = nil
    end
    if aimTarget == player then
        aimTarget = nil
    end
end)

-- Handle respawn
LP.CharacterAdded:Connect(function()
    task.wait(1)
    localTeam = LP.Team and LP.Team.Name or ""
end)
