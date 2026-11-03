-- Exlumiaa Hub - Bug Evolution
-- Server-authoritative: stats live in Player attributes. This hub only moves the
-- character, drives the game's own remotes, and draws ESP.
--
-- Verified from the client scripts:
--   Attack:FireServer(targetModel)    target = Creature / Breakable model
--   Evolve:InvokeServer()             gated by Level >= NextStageLevel
--   PickTrait:FireServer(1..3)        offer arrives on TraitOffer.OnClientEvent
--   SetSprint:FireServer(bool)
--   SetFlying:FireServer(bool)        only for species with CanFly
--   RequestSpawn:FireServer("Respawn" / "Revive")
--   Rewards:InvokeServer("ClaimPlaytime")
--   Orbs are untagged Parts in workspace.Orbs, picked up on touch.

if tostring(game.GameId) ~= "10769957062" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _bugEvoTomb"
local _G_ALIVE = "_ _bugEvoAlive"
local _G_CONFIG = "_ _bugEvoConfig"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.6)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_bug_evolution.txt"
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
        local old = pg:FindFirstChild("BugEvolutionKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "BugEvolutionKeyGate"
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
        title.Text = "Bug Evolution"
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
    autoFarm = false,
    farmMode = "Bugs & Breakables",
    autoCorpse = false,
    autoOrbs = false,
    orbPriority = "Nearest",
    farmRadius = 300,
    orbRadius = 300,
    autoEvolve = false,
    autoTrait = false,
    traitPref = "XP Gain",
    autoRespawn = false,
    autoRewards = false,
    antiAfk = true,
    autoSprint = false,
    infiniteSprint = false,
    fly = false,
    flySpeed = 45,
    espBugs = false,
    espBreak = false,
    espOrbs = false,
    espPlayers = false,
    espTracers = false,
    espRange = 250,
    fullbright = false,
}
rawset(_G, _G_CONFIG, Config)

-- ================================================================
-- Modules / remotes
-- ================================================================
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then return end

local Shared = ReplicatedStorage:FindFirstChild("Shared")
local TraitDefs = nil
if Shared then
    pcall(function() TraitDefs = require(Shared.TraitDefs) end)
end

local function fire(name, ...)
    local r = Remotes:FindFirstChild(name)
    if r and r:IsA("RemoteEvent") then
        local args = table.pack(...)
        pcall(function() r:FireServer(table.unpack(args, 1, args.n)) end)
    end
end

local function invoke(name, ...)
    local r = Remotes:FindFirstChild(name)
    if r and r:IsA("RemoteFunction") then
        local args = table.pack(...)
        local ok, a, b = pcall(function() return r:InvokeServer(table.unpack(args, 1, args.n)) end)
        if ok then return a, b end
    end
    return nil, nil
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
    return LP:GetAttribute("Alive") == true and h ~= nil and h.Health > 0 and root() ~= nil
end
local function num(v)
    v = tonumber(v)
    return v or 0
end
local function partOf(model)
    return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
end
local function radiusOf(model)
    return num(model:GetAttribute("Radius")) * math.max(1, num(model:GetAttribute("Scale")) or 1)
end

local function teleport(pos, lookAt)
    local h = root()
    if not h then return false end
    h.AssemblyLinearVelocity = Vector3.zero
    h.AssemblyAngularVelocity = Vector3.zero
    h.CFrame = lookAt and CFrame.lookAt(pos, lookAt) or CFrame.new(pos)
    return true
end

local function approach(model)
    local p = partOf(model)
    local h = root()
    if not p or not h then return false end
    local target = p.Position
    local flat = Vector3.new(target.X - h.Position.X, 0, target.Z - h.Position.Z)
    local dir = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
    local dist = radiusOf(model) + 2.6
    return teleport(target - dir * dist + Vector3.new(0, 2.2, 0), target)
end

local function nearest(list, valid, maxDist)
    local h = root()
    if not h then return nil end
    local best, bestD = nil, maxDist
    for _, inst in ipairs(list) do
        if inst.Parent and valid(inst) then
            local p = partOf(inst)
            if p then
                local d = (p.Position - h.Position).Magnitude
                if d < bestD then
                    bestD = d
                    best = inst
                end
            end
        end
    end
    return best, bestD
end

local function nearestOrb(maxDist)
    local folder = workspace:FindFirstChild("Orbs")
    local h = root()
    if not folder or not h then return nil end
    local best, bestD = nil, maxDist
    for _, orb in ipairs(folder:GetChildren()) do
        if orb:IsA("BasePart") then
            local d = (orb.Position - h.Position).Magnitude
            if d < bestD then
                bestD = d
                best = orb
            end
        end
    end
    return best, bestD
end

local function bestOrbByXP(maxDist)
    local folder = workspace:FindFirstChild("Orbs")
    local h = root()
    if not folder or not h then return nil end
    local best, bestScore = nil, -1
    for _, orb in ipairs(folder:GetChildren()) do
        if orb:IsA("BasePart") then
            local d = (orb.Position - h.Position).Magnitude
            if d <= maxDist then
                local score = num(orb:GetAttribute("XP")) * 1000 - d
                if score > bestScore then
                    bestScore = score
                    best = orb
                end
            end
        end
    end
    return best
end

local function isBug(inst)
    if inst:GetAttribute("IsPlayer") or inst:GetAttribute("Corpse") then return false end
    local h = inst:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0
end
local function isCorpse(inst)
    return inst:GetAttribute("Corpse") == true and partOf(inst) ~= nil
end
local function isBreakable(inst)
    return partOf(inst) ~= nil and num(inst:GetAttribute("HP")) > 0
end

local function setFreeSprint(on)
    local c = char()
    if not c then return end
    if on then
        if c:GetAttribute("BugEvoFreeSprint") ~= true then
            c:SetAttribute("BugEvoOldFreeSprint", c:GetAttribute("FreeSprint") == true)
            c:SetAttribute("BugEvoFreeSprint", true)
        end
        c:SetAttribute("FreeSprint", true)
    elseif c:GetAttribute("BugEvoFreeSprint") == true then
        c:SetAttribute("FreeSprint", c:GetAttribute("BugEvoOldFreeSprint") == true)
        c:SetAttribute("BugEvoFreeSprint", false)
    end
end

setFreeSprint(false)

-- ================================================================
-- Auto farm
-- ================================================================
local lastCorpseAttack = 0
local lastSprint = false
local farmFlip = false

local function doCorpse()
    local corpse = nearest(CollectionService:GetTagged("Creature"), isCorpse, Config.farmRadius)
    if not corpse then return false end
    if os.clock() - lastCorpseAttack < 0.4 then return true end
    approach(corpse)
    task.wait(0.12)
    lastCorpseAttack = os.clock()
    fire("Attack", corpse)
    return true
end

local function doOrbs()
    local orb
    if Config.orbPriority == "Largest XP" then
        orb = bestOrbByXP(Config.orbRadius)
    else
        orb = nearestOrb(Config.orbRadius)
    end
    if not orb then return false end
    teleport(orb.Position)
    return true
end

local function doTarget()
    local h = root()
    if not h then return false end
    local mode = Config.farmMode
    local bug, brk
    if mode ~= "Orbs Only" then
        if mode ~= "Breakables" then
            bug = nearest(CollectionService:GetTagged("Creature"), isBug, Config.farmRadius)
        end
        if mode ~= "Bugs" then
            brk = nearest(CollectionService:GetTagged("Breakable"), isBreakable, Config.farmRadius)
        end
    end

    local target, bestD
    if bug then target, bestD = bug, (partOf(bug).Position - h.Position).Magnitude end
    if brk then
        local d = (partOf(brk).Position - h.Position).Magnitude
        if not target or d < bestD then target = brk end
    end
    if not target then return false end

    approach(target)
    return true
end

local function setAutoAttack(on)
    pcall(function()
        local Controls = require(LP.PlayerScripts.Client.Controls)
        if Controls and Controls.SetAutoAttack then Controls.SetAutoAttack(on == true) end
    end)
end

-- ================================================================
-- Auto evolve / respawn / rewards
-- ================================================================
local lastEvolve, lastRespawn, lastReward = 0, 0, 0
local evolveFailUntil = 0

local function doEvolve()
    local now = os.clock()
    if now < evolveFailUntil or now - lastEvolve < 2 then return end
    if LP:GetAttribute("Transforming") then return end
    local level = num(LP:GetAttribute("Level"))
    local need = num(LP:GetAttribute("NextStageLevel"))
    local stage = num(LP:GetAttribute("Stage"))
    local maxStage = num(LP:GetAttribute("StageCount"))
    if need <= 0 or level < need or (maxStage > 0 and stage >= maxStage) then return end

    lastEvolve = now
    local ok, msg = invoke("Evolve")
    if ok ~= true then
        evolveFailUntil = now + 10
        if type(msg) == "string" and msg ~= "" then print("[BugEvo] Evolve:", msg) end
    end
end

local function doRespawn()
    if LP:GetAttribute("Alive") ~= false then return end
    if os.clock() - lastRespawn < 2 then return end
    lastRespawn = os.clock()
    fire("RequestSpawn", "Respawn")
end

local function doRewards()
    if os.clock() - lastReward < 25 then return end
    lastReward = os.clock()
    invoke("Rewards", "ClaimPlaytime")
end

-- ================================================================
-- Trait picker
-- ================================================================
local function traitScore(id)
    if not TraitDefs then return 0 end
    local ok, t = pcall(function() return TraitDefs.Get(id) end)
    if not ok or type(t) ~= "table" then return 0 end
    local b = t.Bonus or {}
    local pref = Config.traitPref
    local s = 0
    if pref == "XP Gain" then
        s = num(b.XPGain) * 200
    elseif pref == "Offensive" then
        s = num(b.Damage) * 160 + num(b.AttackSpeed) * 120 + num(b.Reach) * 80 + num(b.Crit) * 60
    elseif pref == "Defensive" then
        s = num(b.Health) * 160 + num(b.DamageReduction) * 200 + num(b.Lifesteal) * 120 + num(b.Healing) * 100
    else
        s = num(b.Speed) * 160 + num(b.Stamina) * 100 + num(b.SprintCost) * -60
    end
    for _, v in pairs(b) do
        if num(v) < 0 then s = s + num(v) * 60 end
    end
    return s
end

local connections = {}

pcall(function()
    connections[#connections + 1] = Remotes.TraitOffer.OnClientEvent:Connect(function(offer)
        if not Config.autoTrait or type(offer) ~= "table" then return end
        task.delay(0.35, function()
            if not Config.autoTrait then return end
            local best, bestScore = 1, -math.huge
            for i, id in ipairs(offer) do
                local s = traitScore(id)
                if s > bestScore then
                    bestScore = s
                    best = i
                end
            end
            fire("PickTrait", best)
        end)
    end)
end)

-- ================================================================
-- Anti AFK
-- ================================================================
connections[#connections + 1] = LP.Idled:Connect(function()
    if not Config.antiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ================================================================
-- Fly
-- ================================================================
local flyVel, flyAttach, flyAlign = nil, nil, nil

local function stopFly()
    if flyVel then flyVel:Destroy() end
    if flyAlign then flyAlign:Destroy() end
    if flyAttach then flyAttach:Destroy() end
    flyVel, flyAlign, flyAttach = nil, nil, nil
    local c, h = char(), hum()
    if h then
        h.PlatformStand = false
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Freefall) end)
    end
    if c then c:SetAttribute("Flying", false) end
    fire("SetFlying", false)
end

local function startFly()
    local c, h, r = char(), hum(), root()
    if not c or not h or not r then return false end
    stopFly()
    flyAttach = Instance.new("Attachment")
    flyAttach.Name = "BugEvoFly"
    flyAttach.Parent = r
    flyVel = Instance.new("LinearVelocity")
    flyVel.Attachment0 = flyAttach
    flyVel.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVel.MaxForce = math.huge
    flyVel.VectorVelocity = Vector3.zero
    flyVel.Parent = r
    flyAlign = Instance.new("AlignOrientation")
    flyAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyAlign.Attachment0 = flyAttach
    flyAlign.MaxTorque = math.huge
    flyAlign.Responsiveness = 18
    flyAlign.CFrame = CFrame.lookAt(Vector3.zero, workspace.CurrentCamera.CFrame.LookVector)
    flyAlign.Parent = r
    h.PlatformStand = true
    c:SetAttribute("Flying", true)
    fire("SetFlying", true)
    return true
end

-- ================================================================
-- Fullbright
-- ================================================================
local oldLight = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local oldAtmosphereDensity = atmosphere and atmosphere.Density or 0

local function setFullbright(on)
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.Ambient = Color3.fromRGB(140, 140, 140)
        Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
        if atmosphere then atmosphere.Density = 0 end
    else
        Lighting.Brightness = oldLight.Brightness
        Lighting.ClockTime = oldLight.ClockTime
        Lighting.FogEnd = oldLight.FogEnd
        Lighting.Ambient = oldLight.Ambient
        Lighting.OutdoorAmbient = oldLight.OutdoorAmbient
        if atmosphere then atmosphere.Density = oldAtmosphereDensity end
    end
end

-- ================================================================
-- ESP (Drawing only: safe from the hub GUI capability wall)
-- ================================================================
local esp = {}
local fullbrightOn = false

local function getESP(inst)
    local e = esp[inst]
    if e then return e end
    local t, l
    local ok = pcall(function()
        t = Drawing.new("Text")
        t.Size = 13
        t.Center = true
        t.Outline = true
        t.OutlineColor = Color3.new(0, 0, 0)
        if Drawing.Fonts then t.Font = Drawing.Fonts.Plex end
        t.Visible = false
        l = Drawing.new("Line")
        l.Thickness = 1
        l.Transparency = 0.6
        l.Visible = false
    end)
    if not ok or not t or not l then
        if t then t:Remove() end
        if l then l:Remove() end
        return nil
    end
    e = { text = t, line = l }
    esp[inst] = e
    return e
end

local function destroyESP(inst)
    local e = esp[inst]
    if e then
        pcall(function() e.text:Remove() end)
        pcall(function() e.line:Remove() end)
        esp[inst] = nil
    end
end

local function clearESP()
    local list = {}
    for inst in pairs(esp) do list[#list + 1] = inst end
    for _, inst in ipairs(list) do destroyESP(inst) end
end

local function updateESP()
    local cam = workspace.CurrentCamera
    local r = root()
    if not cam or not r then
        clearESP()
        return
    end
    local vp = cam.ViewportSize
    local bottom = Vector2.new(vp.X / 2, vp.Y)
    local seen = {}
    local any = Config.espBugs or Config.espBreak or Config.espOrbs or Config.espPlayers

    local function show(inst, pos, label, color, height, tracer)
        if not inst.Parent then return end
        local sp, onScreen = cam:WorldToViewportPoint(pos + Vector3.new(0, height or 2, 0))
        local e = getESP(inst)
        if not e then return end
        if not onScreen or sp.Z <= 0 then
            e.text.Visible = false
            e.line.Visible = false
            return
        end
        seen[inst] = true
        e.text.Text = label
        e.text.Position = Vector2.new(sp.X, sp.Y)
        e.text.Color = color
        e.text.Visible = true
        e.line.From = bottom
        e.line.To = Vector2.new(sp.X, sp.Y)
        e.line.Color = color
        e.line.Visible = Config.espTracers and tracer ~= false
    end

    if any then
        if Config.espBugs then
            for _, inst in ipairs(CollectionService:GetTagged("Creature")) do
                if inst.Parent and not inst:GetAttribute("IsPlayer") then
                    local p = partOf(inst)
                    local h = inst:FindFirstChildOfClass("Humanoid")
                    if p and h then
                        local d = (p.Position - r.Position).Magnitude
                        if d <= Config.espRange then
                            local maxH = h.MaxHealth > 0 and h.MaxHealth or 1
                            local hp = math.clamp(math.floor(h.Health / maxH * 100), 0, 100)
                            local corpse = inst:GetAttribute("Corpse") == true
                            local label = (corpse and "[Corpse] " or "") .. tostring(inst:GetAttribute("BugId") or inst.Name)
                                .. "  " .. (corpse and "" or (hp .. "%  ")) .. math.floor(d) .. "m"
                            show(inst, p.Position, label, corpse and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 170, 60), radiusOf(inst) * 1.6 + 1.5)
                        end
                    end
                end
            end
        end
        if Config.espBreak then
            for _, inst in ipairs(CollectionService:GetTagged("Breakable")) do
                local p = partOf(inst)
                if inst.Parent and p then
                    local d = (p.Position - r.Position).Magnitude
                    if d <= Config.espRange then
                        local hp = num(inst:GetAttribute("HP"))
                        local maxH = math.max(1, num(inst:GetAttribute("MaxHP")))
                        local label = tostring(inst:GetAttribute("BreakId") or inst.Name)
                            .. "  " .. math.floor(hp / maxH * 100) .. "%  "
                            .. math.floor(d) .. "m  +" .. math.floor(num(inst:GetAttribute("XP"))) .. "xp"
                        show(inst, p.Position, label, Color3.fromRGB(90, 240, 255), radiusOf(inst) * 1.6 + 2)
                    end
                end
            end
        end
        if Config.espOrbs then
            local folder = workspace:FindFirstChild("Orbs")
            if folder then
                local near = {}
                local orbRange = math.min(Config.espRange, 80)
                for _, orb in ipairs(folder:GetChildren()) do
                    if orb:IsA("BasePart") then
                        local d = (orb.Position - r.Position).Magnitude
                        if d <= orbRange then near[#near + 1] = { orb = orb, d = d } end
                    end
                end
                table.sort(near, function(a, b) return a.d < b.d end)
                for i = 1, math.min(#near, 15) do
                    local entry = near[i]
                    local xp = num(entry.orb:GetAttribute("XP"))
                    local col = xp >= 18 and Color3.fromRGB(255, 110, 220)
                        or (xp >= 6 and Color3.fromRGB(255, 220, 90) or Color3.fromRGB(140, 255, 180))
                    show(entry.orb, entry.orb.Position, "Orb +" .. math.floor(xp) .. "  " .. math.floor(entry.d) .. "m", col, 2, false)
                end
            end
        end
        if Config.espPlayers then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP then
                    local c = pl.Character
                    local p = c and c:FindFirstChild("HumanoidRootPart")
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if p and h and h.Health > 0 then
                        local d = (p.Position - r.Position).Magnitude
                        if d <= Config.espRange then
                            local lvl = num(pl:GetAttribute("Level"))
                            local stage = tostring(pl:GetAttribute("StageName") or pl:GetAttribute("StageId") or "")
                            local label = pl.Name .. "  Lv" .. lvl .. (stage ~= "" and (" " .. stage) or "")
                                .. "  " .. math.floor(h.Health / math.max(1, h.MaxHealth) * 100) .. "%  " .. math.floor(d) .. "m"
                            show(p, p.Position, label, Color3.fromRGB(255, 120, 120), 4)
                        end
                    end
                end
            end
        end
    end

    local remove = nil
    for inst, e in pairs(esp) do
        if not seen[inst] then
            e.text.Visible = false
            e.line.Visible = false
            if not inst.Parent then
                remove = remove or {}
                remove[#remove + 1] = inst
            end
        end
    end
    if remove then
        for _, inst in ipairs(remove) do destroyESP(inst) end
    end
end

task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        if fullbrightOn ~= Config.fullbright then
            fullbrightOn = Config.fullbright
            setFullbright(fullbrightOn)
        end
        updateESP()
        task.wait(0.12)
    end
    clearESP()
    setFullbright(false)
end)

-- ================================================================
-- Heartbeat: sprint / fly
-- ================================================================
connections[#connections + 1] = RunService.Heartbeat:Connect(function()
    if rawget(_G, _G_TOMB) == true then return end
    local c, h = char(), hum()
    if not c or not h then return end

    if Config.infiniteSprint and alive() then
        setFreeSprint(true)
        LP:SetAttribute("Stamina", num(LP:GetAttribute("MaxStamina")) > 0 and num(LP:GetAttribute("MaxStamina")) or 100)
        LP:SetAttribute("Exhausted", false)
    else
        setFreeSprint(false)
        if Config.autoSprint then
            local want = h.MoveDirection.Magnitude > 0.05
            if want ~= lastSprint then
                lastSprint = want
                fire("SetSprint", want)
            end
        end
    end

    if Config.fly then
        if not alive() then
            if flyVel then stopFly() end
        elseif not flyVel then
            startFly()
        else
            local cam = workspace.CurrentCamera
            local fwd = (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
                - (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
            local side = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0)
                - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
            local flat = cam.CFrame.LookVector * Vector3.new(1, 0, 1)
            flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
            local dir = (flat * fwd + cam.CFrame.RightVector * side)
            if dir.Magnitude > 1 then dir = dir.Unit end
            local vel = dir * Config.flySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, Config.flySpeed * 0.8, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, Config.flySpeed * 0.8, 0) end
            flyVel.VectorVelocity = vel
            flyAlign.CFrame = CFrame.lookAt(Vector3.zero, cam.CFrame.LookVector)
        end
    elseif flyVel then
        stopFly()
    end
end)

-- ================================================================
-- UI
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Bug Evolution",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Bug Evolution",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then v:Destroy() end
    end
end)

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "crosshair", Subtitle = "Farm & Evolve" })
local FarmSub = FarmTab:AddSubTab("Features")

FarmSub:AddSection("Farm")
FarmSub:AddToggle({
    Name = "Auto Farm",
    Flag = "be_farm",
    Default = false,
    Callback = function(v)
        Config.autoFarm = v
        if v then setAutoAttack(true) end
    end,
})
FarmSub:AddDropdown({
    Name = "Farm Mode",
    Flag = "be_farmmode",
    Options = { "Bugs & Breakables", "Bugs", "Breakables", "Orbs Only", "Balanced" },
    Default = "Bugs & Breakables",
    Callback = function(v) Config.farmMode = v end,
})
FarmSub:AddSlider({
    Name = "Farm Radius",
    Flag = "be_farmradius",
    Min = 50,
    Max = 1000,
    Default = 300,
    Suffix = "m",
    Callback = function(v) Config.farmRadius = v end,
})
FarmSub:AddToggle({
    Name = "Auto Eat Corpses",
    Flag = "be_corpse",
    Default = false,
    Callback = function(v) Config.autoCorpse = v end,
})

FarmSub:AddSection("Orbs")
FarmSub:AddToggle({
    Name = "Auto Collect Orbs",
    Flag = "be_orbs",
    Default = false,
    Callback = function(v) Config.autoOrbs = v end,
})
FarmSub:AddDropdown({
    Name = "Orb Priority",
    Flag = "be_orbprio",
    Options = { "Nearest", "Largest XP" },
    Default = "Nearest",
    Callback = function(v) Config.orbPriority = v end,
})
FarmSub:AddSlider({
    Name = "Orb Radius",
    Flag = "be_orbradius",
    Min = 50,
    Max = 1000,
    Default = 300,
    Suffix = "m",
    Callback = function(v) Config.orbRadius = v end,
})

FarmSub:AddSection("Evolve & Traits")
FarmSub:AddToggle({
    Name = "Auto Evolve",
    Flag = "be_evolve",
    Default = false,
    Callback = function(v) Config.autoEvolve = v end,
})
FarmSub:AddToggle({
    Name = "Auto Pick Trait",
    Flag = "be_trait",
    Default = false,
    Callback = function(v) Config.autoTrait = v end,
})
FarmSub:AddDropdown({
    Name = "Trait Preference",
    Flag = "be_traitpref",
    Options = { "XP Gain", "Offensive", "Defensive", "Movement" },
    Default = "XP Gain",
    Callback = function(v) Config.traitPref = v end,
})

FarmSub:AddSection("Utility")
FarmSub:AddToggle({
    Name = "Auto Respawn",
    Flag = "be_respawn",
    Default = false,
    Callback = function(v) Config.autoRespawn = v end,
})
FarmSub:AddToggle({
    Name = "Auto Claim Playtime",
    Flag = "be_rewards",
    Default = false,
    Callback = function(v) Config.autoRewards = v end,
})
FarmSub:AddToggle({
    Name = "Anti AFK",
    Flag = "be_afk",
    Default = true,
    Callback = function(v) Config.antiAfk = v end,
})

local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local VisualSub = VisualTab:AddSubTab("Features")

VisualSub:AddSection("ESP")
VisualSub:AddToggle({
    Name = "ESP Bugs",
    Flag = "be_espbugs",
    Default = false,
    Callback = function(v) Config.espBugs = v end,
})
VisualSub:AddToggle({
    Name = "ESP Breakables",
    Flag = "be_espbreak",
    Default = false,
    Callback = function(v) Config.espBreak = v end,
})
VisualSub:AddToggle({
    Name = "ESP Orbs",
    Flag = "be_esporbs",
    Default = false,
    Callback = function(v) Config.espOrbs = v end,
})
VisualSub:AddToggle({
    Name = "ESP Players",
    Flag = "be_espplayers",
    Default = false,
    Callback = function(v) Config.espPlayers = v end,
})
VisualSub:AddToggle({
    Name = "Tracers",
    Flag = "be_tracers",
    Default = false,
    Callback = function(v) Config.espTracers = v end,
})
VisualSub:AddSlider({
    Name = "ESP Range",
    Flag = "be_esprange",
    Min = 50,
    Max = 1000,
    Default = 250,
    Suffix = "m",
    Callback = function(v) Config.espRange = v end,
})

VisualSub:AddSection("World")
VisualSub:AddToggle({
    Name = "Fullbright / No Fog",
    Flag = "be_fullbright",
    Default = false,
    Callback = function(v) Config.fullbright = v end,
})

local PlayerTab = Window:AddTab({ Name = "Player", Icon = "running", Subtitle = "Movement" })
local PlayerSub = PlayerTab:AddSubTab("Features")

PlayerSub:AddSection("Sprint")
PlayerSub:AddToggle({
    Name = "Auto Sprint",
    Flag = "be_sprint",
    Default = false,
    Callback = function(v)
        Config.autoSprint = v
        if not v and not Config.infiniteSprint then fire("SetSprint", false) end
    end,
})
PlayerSub:AddToggle({
    Name = "Infinite Sprint",
    Flag = "be_inf",
    Default = false,
    Callback = function(v)
        Config.infiniteSprint = v
        if not v then
            setFreeSprint(false)
            fire("SetSprint", false)
        end
    end,
})

PlayerSub:AddSection("Fly")
PlayerSub:AddToggle({
    Name = "Fly (local)",
    Flag = "be_fly",
    Default = false,
    Callback = function(v)
        Config.fly = v
        if v then
            if not startFly() then Config.fly = false end
        else
            stopFly()
        end
    end,
})
PlayerSub:AddSlider({
    Name = "Fly Speed",
    Flag = "be_flyspeed",
    Min = 20,
    Max = 200,
    Default = 45,
    Callback = function(v) Config.flySpeed = v end,
})

PlayerSub:AddSection("Info")
PlayerSub:AddButton({
    Name = "Show Stats",
    Callback = function()
        Window:Notify({
            Title = "Stats",
            Content = string.format(
                "Level %s  ·╖  XP %s/%s  ·╖  Stage %s  ·╖  Coins %s  ·╖  Zone %s",
                tostring(LP:GetAttribute("Level")),
                tostring(LP:GetAttribute("XP")),
                tostring(LP:GetAttribute("XPNeed")),
                tostring(LP:GetAttribute("StageName")),
                tostring(LP:GetAttribute("Coins")),
                tostring(LP:GetAttribute("Zone") or "-")
            ),
            Type = "info",
            Duration = 6,
        })
    end,
})

-- ================================================================
-- Settings
-- ================================================================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
ConfigSub:AddSection("Config")

local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Flag = "be_configdrop",
    Callback = function(v) selectedConfig = v end,
})
local configInput = ConfigSub:AddInput({
    Name = "Config Name",
    Flag = "be_configname",
    PlaceholderText = "Enter config name",
})

local function refreshConfigList()
    configDropdown:SetOptions(Library:ListConfigs())
end

ConfigSub:AddDivider()
ConfigSub:AddButton({
    Name = "Save Config",
    Callback = function()
        local name = configInput.Value
        if not name or name == "" then
            Window:Notify({ Title = "Config", Content = "Enter a name first!", Type = "warning", Duration = 3 })
            return
        end
        if Library:SaveConfig(name) then
            refreshConfigList()
            Window:Notify({ Title = "Config", Content = "Saved: " .. name, Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Config", Content = "Save failed!", Type = "error", Duration = 3 })
        end
    end,
})
ConfigSub:AddButton({
    Name = "Load Config",
    Callback = function()
        if selectedConfig == "" then
            Window:Notify({ Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3 })
            return
        end
        if Library:LoadConfig(selectedConfig) then
            Window:Notify({ Title = "Config", Content = "Loaded: " .. selectedConfig, Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Config", Content = "Failed to load!", Type = "error", Duration = 3 })
        end
    end,
})
ConfigSub:AddButton({
    Name = "Delete Config",
    Callback = function()
        if selectedConfig == "" then
            Window:Notify({ Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3 })
            return
        end
        Library:DeleteConfig(selectedConfig)
        selectedConfig = ""
        refreshConfigList()
        Window:Notify({ Title = "Config", Content = "Deleted config.", Type = "info", Duration = 3 })
    end,
})
refreshConfigList()

-- ================================================================
-- Worker
-- ================================================================
task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        if alive() and not LP:GetAttribute("Transforming") then
            if Config.autoEvolve then doEvolve() end
            if Config.autoRewards then doRewards() end

            local did = false
            if Config.autoFarm then
                farmFlip = not farmFlip
                if Config.farmMode == "Orbs Only" then
                    did = doOrbs()
                elseif Config.farmMode == "Balanced" then
                    did = farmFlip and doTarget() or doOrbs()
                else
                    did = doTarget()
                end
            end
            if not did and Config.autoCorpse then did = doCorpse() end
            if not did and Config.autoOrbs then did = doOrbs() end
        end

        if Config.autoRespawn then doRespawn() end

        task.wait((Config.autoFarm or Config.autoOrbs or Config.autoCorpse) and 0.2 or 0.4)
    end
end)

task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do task.wait(0.1) end
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    setFreeSprint(false)
end)
