if tostring(game.GameId) ~= "903807016" then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer
local localTeam = LP.Team and LP.Team.Name or ""

local _G_TOMB = "_ _erlcEspTomb"
local _G_ALIVE = "_ _erlcEspAlive"
local _G_LIB = "_ _erlcEspLib"
local _G_GUI = "_ _erlcEspGui"

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
    teamCheck = false,
    teamColors = true,
    selfESP = false,
    maxDist = 2000,
    guiKey = Enum.KeyCode.RightShift,
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
        -- Full box (4 lines + outline)
        boxOutline1 = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        boxOutline2 = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        boxOutline3 = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        boxOutline4 = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        box1 = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        box2 = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        box3 = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        box4 = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        -- Snap lines (corner connectors)
        snap1 = newDrawing("Line", {Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.4}),
        snap2 = newDrawing("Line", {Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.4}),
        -- Fill
        fill = newDrawing("Quad", {Visible = false, Thickness = 1, Filled = true, Transparency = 0.12}),
        -- Tracer
        tracerOutline = newDrawing("Line", {Visible = false, Thickness = 4, Color = Color3.new(0, 0, 0)}),
        tracer = newDrawing("Line", {Visible = false, Thickness = 1.5}),
        -- Name
        name = newDrawing("Text", {Visible = false, Size = 14, Center = true, Outline = true, Font = 2}),
        -- Distance
        dist = newDrawing("Text", {Visible = false, Size = 12, Center = true, Outline = true, Font = 2}),
        -- Healthbar
        healthBg = newDrawing("Quad", {Visible = false, Thickness = 0, Filled = true}),
        healthFg = newDrawing("Quad", {Visible = false, Thickness = 0, Filled = true}),
        healthText = newDrawing("Text", {Visible = false, Size = 11, Center = false, Outline = true, Font = 2}),
        -- Head Dot
        headDot = newDrawing("Circle", {Visible = false, Radius = 4, Filled = true}),
        headDotOutline = newDrawing("Circle", {Visible = false, Radius = 6, Filled = false, Thickness = 1.5}),
    }
end

local function destroyDrawings(cache)
    for _, v in pairs(cache) do
        if typeof(v) == "Instance" then
            v:Destroy()
        elseif type(v) == "table" and v.Remove then
            v:Remove()
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

local function updateESP(player)
    if not Config.enabled then
        if drawCache[player] then
            for _, v in pairs(drawCache[player]) do
                if typeof(v) == "Instance" then v:Destroy()
                elseif type(v) == "table" and v.Remove then v.Visible = false end
            end
            drawCache[player] = nil
        end
        return
    end

    if player == LP and not Config.selfESP then
        if drawCache[player] then
            for _, v in pairs(drawCache[player]) do
                if typeof(v) == "Instance" then v:Destroy()
                elseif type(v) == "table" and v.Remove then v.Visible = false end
            end
            drawCache[player] = nil
        end
        return
    end

    if Config.teamCheck and player.Team == LP.Team then
        if drawCache[player] then
            for _, v in pairs(drawCache[player]) do
                if typeof(v) == "Instance" then v:Destroy()
                elseif type(v) == "table" and v.Remove then v.Visible = false end
            end
            drawCache[player] = nil
        end
        return
    end

    local char = player.Character
    if not char then
        if drawCache[player] then
            for _, v in pairs(drawCache[player]) do
                if typeof(v) == "Instance" then v:Destroy()
                elseif type(v) == "table" and v.Remove then v.Visible = false end
            end
            drawCache[player] = nil
        end
        return
    end

    local bb = getBoundingBox(char)
    if not bb then
        if drawCache[player] then
            for _, v in pairs(drawCache[player]) do v.Visible = false end
        end
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist > Config.maxDist then
        if drawCache[player] then
            for _, v in pairs(drawCache[player]) do
                if typeof(v) == "Instance" then v:Destroy()
                elseif type(v) == "table" and v.Remove then v.Visible = false end
            end
            drawCache[player] = nil
        end
        return
    end

    if not drawCache[player] then
        drawCache[player] = createDrawings()
    end
    local d = drawCache[player]
    local col = getPlayerColor(player)

    local tl, tr, bl, br = bb.topLeft, bb.topRight, bb.botLeft, bb.botRight

    -- Full Box
    if Config.box then
        local tl, tr, bl, br = bb.topLeft, bb.topRight, bb.botLeft, bb.botRight

        -- Outline
        d.boxOutline1.From = tl; d.boxOutline1.To = tr; d.boxOutline1.Visible = true
        d.boxOutline2.From = bl; d.boxOutline2.To = br; d.boxOutline2.Visible = true
        d.boxOutline3.From = tl; d.boxOutline3.To = bl; d.boxOutline3.Visible = true
        d.boxOutline4.From = tr; d.boxOutline4.To = br; d.boxOutline4.Visible = true

        -- Colored box
        d.box1.From = tl; d.box1.To = tr; d.box1.Color = col; d.box1.Visible = true
        d.box2.From = bl; d.box2.To = br; d.box2.Color = col; d.box2.Visible = true
        d.box3.From = tl; d.box3.To = bl; d.box3.Color = col; d.box3.Visible = true
        d.box4.From = tr; d.box4.To = br; d.box4.Color = col; d.box4.Visible = true

        -- Snap lines (small horizontal lines from corners inward)
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
        d.name.Color = col
        d.name.Visible = true
    else
        d.name.Visible = false
    end

    -- Distance
    if Config.distance then
        d.dist.Position = Vector2.new(bb.center.X, bb.botLeft.Y + 6)
        d.dist.Text = math.floor(dist) .. "m"
        d.dist.Color = col
        d.dist.Visible = true
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

    -- Glow
    if Config.glow and bb.head then
        local headPos, onScreen = Camera:WorldToViewportPoint(bb.head.Position + Vector3.new(0, 0.5, 0))
        if onScreen then
            d.glow.Position = Vector2.new(headPos.X, headPos.Y)
            d.glow.Color = col
            d.glow.Visible = true
        else
            d.glow.Visible = false
        end
    else
        d.glow.Visible = false
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

local function cleanup()
    rawset(_G, _G_TOMB, true)
    task.wait(0.3)
    for player, cache in pairs(drawCache) do
        destroyDrawings(cache)
    end
    drawCache = {}
    rawset(_G, _G_ALIVE, nil)
    rawset(_G, _G_LIB, nil)
    rawset(_G, _G_GUI, nil)
end

-- ========== UI ==========
local Library = nil
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

if not Library then return end

-- Apply JewHack theme
Library.Scheme.BackgroundColor = Color3.fromRGB(10, 10, 10)
Library.Scheme.MainColor = Color3.fromRGB(18, 18, 18)
Library.Scheme.AccentColor = Color3.fromRGB(255, 0, 100)
Library.Scheme.OutlineColor = Color3.fromRGB(35, 35, 35)
Library.Scheme.FontColor = Color3.new(1, 1, 1)

local Window = Library:CreateWindow({
    Title = "ERLC ESP",
    Footer = "by Exlumiaa Hub",
    AutoShow = true,
    Center = true,
    Resizable = true,
    CornerRadius = 4,
    ToggleKeybind = Config.guiKey,
})

local VisualTab = Window:AddTab("Visual", "eye")

local EspSection = VisualTab:AddLeftGroupbox("ESP Elements")
EspSection:AddToggle("Enabled", {
    Text = "Enable ESP",
    Default = Config.enabled,
    Callback = function(s) Config.enabled = s end,
})
EspSection:AddToggle("Box", {
    Text = "Box",
    Default = Config.box,
    Callback = function(s) Config.box = s end,
})
EspSection:AddToggle("FillBox", {
    Text = "Fill Box",
    Default = Config.fillBox,
    Callback = function(s) Config.fillBox = s end,
})
EspSection:AddToggle("Name", {
    Text = "Name",
    Default = Config.name,
    Callback = function(s) Config.name = s end,
})
EspSection:AddToggle("Distance", {
    Text = "Distance",
    Default = Config.distance,
    Callback = function(s) Config.distance = s end,
})
EspSection:AddToggle("Healthbar", {
    Text = "Healthbar",
    Default = Config.healthbar,
    Callback = function(s) Config.healthbar = s end,
})
EspSection:AddToggle("Tracer", {
    Text = "Tracer",
    Default = Config.tracer,
    Callback = function(s) Config.tracer = s end,
})
EspSection:AddToggle("HeadDot", {
    Text = "Head Dot",
    Default = Config.headDot,
    Callback = function(s) Config.headDot = s end,
})
EspSection:AddToggle("Chams", {
    Text = "Chams",
    Default = Config.chams,
    Callback = function(s) Config.chams = s end,
})
EspSection:AddToggle("Outline", {
    Text = "Outline",
    Default = Config.outline,
    Callback = function(s) Config.outline = s end,
})

local OptSection = VisualTab:AddRightGroupbox("Options")
OptSection:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = Config.teamCheck,
    Callback = function(s) Config.teamCheck = s end,
})
OptSection:AddToggle("TeamColors", {
    Text = "Team Based Colors",
    Default = Config.teamColors,
    Callback = function(s) Config.teamColors = s end,
})
OptSection:AddToggle("SelfESP", {
    Text = "Self ESP",
    Default = Config.selfESP,
    Callback = function(s) Config.selfESP = s end,
})
OptSection:AddSlider("MaxDist", {
    Text = "Max Distance",
    Default = Config.maxDist,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = "m",
    Callback = function(v) Config.maxDist = v end,
})
OptSection:AddLabel("")
OptSection:AddLabel("Team Colors:")
OptSection:AddLabel("  Police: Blue")
OptSection:AddLabel("  Sheriff: Beige")
OptSection:AddLabel("  Fire: Red")
OptSection:AddLabel("  DOT: Orange")
OptSection:AddLabel("  Civilian: Gray")

-- Home Tab
local HomeTab = Window:AddTab("Home", "home")
local PlayerSection = HomeTab:AddLeftGroupbox("Player")
local labelPlayers = PlayerSection:AddLabel("Players: " .. #Players:GetPlayers())
local labelFPS = PlayerSection:AddLabel("FPS: --")
PlayerSection:AddLabel("by Exlumiaa Hub")

-- Discord Section
local DISCORD_LINK = "https://discord.gg/aKxnSwhRxx"
local DiscordSection = HomeTab:AddRightGroupbox("Discord")
DiscordSection:AddLabel("Join our Discord!")
DiscordSection:AddButton({
    Text = "Copy Invite",
    Func = function()
        local ok = pcall(setclipboard, DISCORD_LINK)
        Library:Notify({
            Title = "Discord",
            Description = ok and "Invite link copied!" or "Copy failed",
            Time = 3,
        })
    end,
})

-- Main Loop
task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        task.wait(0.016)
        pcall(function()
            Camera = workspace.CurrentCamera
            for _, player in ipairs(Players:GetPlayers()) do
                pcall(updateESP, player)
            end
            labelPlayers:SetText("Players: " .. #Players:GetPlayers())
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
            labelFPS:SetText("FPS: " .. frames)
            frames = 0
            lastTick = tick()
        end
        task.wait()
    end
end)

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(player)
    if drawCache[player] then
        destroyDrawings(drawCache[player])
        drawCache[player] = nil
    end
end)

-- Handle respawn
LP.CharacterAdded:Connect(function()
    task.wait(1)
    localTeam = LP.Team and LP.Team.Name or ""
end)

rawset(_G, _G_LIB, Library)
rawset(_G, _G_GUI, Library.ScreenGui)
