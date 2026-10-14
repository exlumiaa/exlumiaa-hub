if tostring(game.GameId) ~= "10766138478" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _seTomb"
local _G_GEN = "_ _seGen"

do
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_GEN, (rawget(_G, _G_GEN) or 0) + 1)
end

local _gen = rawget(_G, _G_GEN)
local function _alive()
    return rawget(_G, _G_GEN) == _gen
end

local CONNS = {}
do
    local old = rawget(_G, "_ _seConns")
    if type(old) == "table" then
        for _, c in ipairs(old) do
            pcall(function() c:Disconnect() end)
        end
    end
    rawset(_G, "_ _seConns", CONNS)
end

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Oxidelib" or gui.Name == "ExlumiaaHub" or gui.Name == "Obsidian") then
                gui:Destroy()
            end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Oxidelib" or gui.Name == "ExlumiaaHub" or gui.Name == "Obsidian") then
                gui:Destroy()
            end
        end
    end)
end

do
    pcall(function()
        for _, desc in ipairs(workspace:GetDescendants()) do
            if (desc.Name == "_SEESP" and desc:IsA("Highlight")) or (desc.Name == "_SEESPV" and desc:IsA("BillboardGui")) then
                desc:Destroy()
            end
        end
    end)
end

-- =============================================================
-- KEY SYSTEM
-- =============================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_strengtheggs.txt"
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
        local old = pg:FindFirstChild("StrengthEggsKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "StrengthEggsKeyGate"
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
        title.Text = "Plus 1 Strength for Eggs"
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
                if not _alive() then
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
    autoGate = false,
    autoRebirth = false,
    autoPickup = false,
    autoPlace = false,
    autoEquipBest = false,
    autoSell = false,
    autoIndex = false,
    antiAFK = false,
    tp_to_plot_q = false,
    espMutation = false,
}
rawset(_G, "_strengthEggsConfig", Config)

local notifyHub
local Library -- assigned in the UI section; loops read flags through it

-- ================================================================
-- CORE: remotes
-- ================================================================
local RemotesFolder
do
    local sm = ReplicatedStorage:WaitForChild("SharedModules", 10)
    local net = sm and sm:WaitForChild("Network", 10)
    RemotesFolder = net and net:WaitForChild("Remotes", 10)
end

local function getRemote(name)
    if not RemotesFolder then return nil end
    local r = RemotesFolder:FindFirstChild(name)
    if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
        return r
    end
    return nil
end

local function fireRemote(name, ...)
    local r = getRemote(name)
    if not r then return false end
    if r:IsA("RemoteEvent") then
        r:FireServer(...)
        return true
    elseif r:IsA("RemoteFunction") then
        local args = table.pack(...)
        task.spawn(function()
            pcall(function() r:InvokeServer(table.unpack(args, 1, args.n)) end)
        end)
        return true
    end
    return false
end

local function invokeRemote(name, ...)
    local r = getRemote(name)
    if not r or not r:IsA("RemoteFunction") then return nil end
    local args = table.pack(...)
    local ok, res = pcall(function() return r:InvokeServer(table.unpack(args, 1, args.n)) end)
    if ok then return res end
    return nil
end

-- ================================================================
-- FLAG READERS: the UI toggle is the source of truth.
-- Config only mirrors it, so a stale Config (config load, re-run)
-- can never desync what the user sees from what the loops do.
-- ================================================================
local function flagVal(name, key)
    if Library then
        local ok, v = pcall(function() return Library:GetFlag(name) end)
        if ok and v ~= nil then return v end
    end
    return Config[key]
end

local function flagOn(name, key)
    return flagVal(name, key) == true
end

-- Shared with the train loop: while Auto Gate is walking to a gate,
-- training must not PivotTo the char back to the zone or fight MoveTo.
local gateBusy = false

-- Gate break order (SharedVariables.ZONE_ORDERS, spawn-world map).
local ZONE_GATE_ORDER = {
    "Forest", "Beach", "Desert", "Arctic", "Volcano", "Void",
    "Cloudlands", "Deep Ocean", "Ancient Egypt", "Redlands",
}

-- Position of the training (level-up) zone on your own plot.
-- The zone model is built client-side by the TrainingZones script;
-- fall back to BaseRef * PlotOffset while it is not built yet.
local function findZonePosition()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local owner = plot:FindFirstChild("owner")
        if owner and owner.Value == LP.Name then
            local zoneModel = plot:FindFirstChild("LevelUpTouchZone")
            local corners = zoneModel and zoneModel:FindFirstChild("Corners")
            local zone = corners and corners:FindFirstChild("Zone")
            if zone then return zone.Position end
            local baseRef = plot:GetAttribute("BaseRef")
            local models = ReplicatedStorage:FindFirstChild("SharedAssets")
            models = models and models:FindFirstChild("Models")
            local tpl = models and models:FindFirstChild("LevelUpZoneTemplate")
            local offset = tpl and tpl:GetAttribute("PlotOffset")
            if baseRef and offset then
                local cf = baseRef * offset
                if typeof(cf) == "CFrame" then return cf.Position end
                if typeof(cf) == "Vector3" then return cf end
            end
            return nil
        end
    end
    return nil
end

-- ================================================================
-- HOOK: AUTO BUBBLE POP (part of Auto Train)
-- Pops free training bubbles automatically while Auto Train runs.
-- The game spawns bubbles client-side from "Training Bubble Spawn"
-- payloads {id, kind, ...}. Paid tiers (SharedVariables.TRAINING_BUBBLES
-- .Tiers = x50 / x1000) prompt a Robux purchase, so we never touch
-- those. Pop = fire "Training Bubble Pop" with the id; the server
-- answers with "Training Bubble Reward" (strength).
-- NOTE: _G._Lib is not visible from the executor, so read Tiers by
-- requiring SharedVariables directly, with a hardcoded fallback.
-- ================================================================
do
    local spawnRem = getRemote("Training Bubble Spawn")
    local popRem = getRemote("Training Bubble Pop")
    local FALLBACK_PAID_KINDS = { x50 = true, x1000 = true }
    local function isPaidKind(kind)
        local ok, tiers = pcall(function()
            local mod = ReplicatedStorage.SharedModules.Shared.SharedVariables
            local data = require(mod)
            return data and data.TRAINING_BUBBLES and data.TRAINING_BUBBLES.Tiers
        end)
        if ok and type(tiers) == "table" then
            return tiers[kind] ~= nil
        end
        return FALLBACK_PAID_KINDS[kind] == true
    end
    if spawnRem and popRem then
        local conn = spawnRem.OnClientEvent:Connect(function(payload)
            if not flagOn("se_auto_train", "autoTrain") then return end
            if type(payload) ~= "table" or payload.id == nil then return end
            if isPaidKind(payload.kind) then return end
            task.delay(math.random(50, 250) / 1000, function()
                if _alive() then pcall(function() popRem:FireServer(payload.id) end) end
            end)
        end)
        table.insert(CONNS, conn)
    end
end

-- ================================================================
-- LOOP: AUTO TRAIN (TP to your plot's training zone, then train)
-- ================================================================
local lastZoneTp = 0
task.spawn(function()
    while _alive() do
        if flagOn("se_auto_train", "autoTrain") and not gateBusy then
            local holding = LP:GetAttribute("holdingFriend")
            if not holding then
                if not LP:GetAttribute("InTrainingZone") and (os.clock() - lastZoneTp) > 1.5 then
                    local zonePos = findZonePosition()
                    if zonePos then
                        lastZoneTp = os.clock()
                        pcall(function()
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char:PivotTo(CFrame.new(zonePos.X, 3.5, zonePos.Z))
                            end
                        end)
                    end
                end
                pcall(function() fireRemote("Activate Dumbell") end)
            end
        end
        task.wait(0.65)
    end
end)

-- ================================================================
-- LOOP: AUTO GATE BREAK
-- Find the gate still active on the CLIENT (health bar visible /
-- GeneratedGateVoxel set), not the desynced server Gate States.
-- Walk (MoveTo) to the gate, face it, unequip Tool. The game's
-- Heartbeat puncher auto-fires Damage Gate within 16 studs when facing.
-- ================================================================
task.spawn(function()
    local lastFind = 0
    local targetName = nil
    local lastMove = 0
    while _alive() do
        local wantGate = flagOn("se_auto_gate", "autoGate")
        if wantGate then
            if os.clock() - lastFind > 1.5 then
                lastFind = os.clock()
                targetName = nil
                local gatesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Gates")
                if gatesFolder then
                    -- Pick the first gate in order that is still active on client
                    for _, name in ipairs(ZONE_GATE_ORDER) do
                        local g = gatesFolder:FindFirstChild(name)
                        if g then
                            -- Client considers it done if: Generated empty OR no active voxel
                            local blocks = g:FindFirstChild("Blocks")
                            local gen = blocks and blocks:FindFirstChild("Generated")
                            local active = false
                            if gen then
                                for _, v in ipairs(gen:GetChildren()) do
                                    if v:GetAttribute("GeneratedGateVoxel") then
                                        active = true
                                        break
                                    end
                                end
                            end
                            if active then
                                targetName = name
                                break
                            end
                        end
                    end
                end
            end
        else
            targetName = nil
        end
        gateBusy = targetName ~= nil
        if targetName then
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 and LP:GetAttribute("holdingFriend") ~= true then
                local backpack = LP:FindFirstChildOfClass("Backpack")
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") and backpack then
                        pcall(function() tool.Parent = backpack end)
                    end
                end
                local gate = workspace.Map.Gates:FindFirstChild(targetName)
                -- Target the LOWEST active layer (leftover in front of gate), not Main center
                local blocks = gate and gate:FindFirstChild("Blocks")
                local gen = blocks and blocks:FindFirstChild("Generated")
                local target = nil
                local lowestLayer = math.huge
                if gen then
                    for _, v in ipairs(gen:GetChildren()) do
                        if v:GetAttribute("GeneratedGateVoxel") then
                            local n = tonumber(v.Name:match("Layer_(%d+)"))
                            if n and n < lowestLayer then
                                lowestLayer = n
                                target = v
                            end
                        end
                    end
                end
                target = target or (gate and gate:FindFirstChild("Main"))
                if target then
                    local dist = (hrp.Position - target.Position).Magnitude
                    if dist > 12 then
                        if os.clock() - lastMove > 0.8 then
                            lastMove = os.clock()
                            pcall(function() hum:MoveTo(target.Position) end)
                        end
                    else
                        pcall(function()
                            hrp.CFrame = CFrame.lookAt(
                                hrp.Position,
                                Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z)
                            )
                        end)
                    end
                end
            end
        end
        task.wait(0.35)
    end
end)

-- ================================================================
-- LOOP: AUTO REBIRTH
-- ================================================================
task.spawn(function()
    while _alive() do
        if flagOn("se_auto_rebirth", "autoRebirth") then
            pcall(function() fireRemote("Rebirth") end)
        end
        task.wait(2)
    end
end)

-- ================================================================
-- LOOP: AUTO EQUIP BEST
-- ================================================================
task.spawn(function()
    while _alive() do
        if flagOn("se_auto_equip", "autoEquipBest") then
            pcall(function() fireRemote("Equip Best") end)
        end
        task.wait(1.5)
    end
end)

-- ================================================================
-- LOOP: AUTO SELL
-- ================================================================
task.spawn(function()
    while _alive() do
        if flagOn("se_auto_sell", "autoSell") then
            pcall(function() fireRemote("Sell All Friends") end)
        end
        task.wait(1.2)
    end
end)

-- ================================================================
-- LOOP: AUTO CLAIM INDEX
-- ================================================================
task.spawn(function()
    while _alive() do
        if flagOn("se_auto_index", "autoIndex") then
            pcall(function() invokeRemote("Claim All Index Rewards") end)
        end
        task.wait(3)
    end
end)

-- ================================================================
-- LOOP: ANTI AFK
-- ================================================================
task.spawn(function()
    while _alive() do
        if flagOn("se_antiafk", "antiAFK") then
            pcall(function() fireRemote("AFK Idle Reset Request") end)
        end
        task.wait(600)
    end
end)

-- ================================================================
-- LOOP: ESP MUTATION
-- CollectionService tag "mutation_X" on Decals inside
-- Live.Friends (eggs) and Live.PlayerFriends.<name> (friends).
-- Highlight + label with mutation name, color from MutationColors gradient.
-- ================================================================
task.spawn(function()
    local CollectionService = game:GetService("CollectionService")
    local MUT_NAMES = {
        "Shiny", "Golden", "Rainbow", "Cursed", "Huge", "Lava", "Neon", "Robot",
        "Money", "Electrified", "Festive", "Diamond", "Taco", "Slimey", "Toxic",
        "Cosmic", "Pollinated", "Gingerbread", "Party", "Hacked", "Watermelon",
        "Bubble", "Candy", "Frozen", "Galactic", "Glitched", "Pizza", "Easter",
        "Evil", "Holy", "Gatito", "Summer", "Acid", "Splashy", "Circus",
        "Bloodlit", "Backrooms", "Swamp", "Extinct", "Spooky", "YinYang",
        "Dreamy", "Volcanic", "Dragon", "Ruby", "Sakura", "Shadow", "Demon",
        "Strawberry",
    }
    local mutColor = {}
    local function colorFor(name)
        local c = mutColor[name]
        if c then return c end
        c = Color3.fromRGB(255, 120, 255)
        pcall(function()
            local folder = ReplicatedStorage:WaitForChild("SharedAssets"):WaitForChild("UI"):WaitForChild("MutationColors")
            local g = folder:FindFirstChild(name)
            if g and g:IsA("UIGradient") then
                local kps = g.Color.Keypoints
                if #kps > 0 then c = kps[math.ceil(#kps / 2)].Value end
            end
        end)
        mutColor[name] = c
        return c
    end
    local function resolveTarget(inst)
        local p = inst
        while p and p.Parent do
            local par = p.Parent
            if par.Name == "Friends" then return p end
            if par.Parent and par.Parent.Name == "PlayerFriends" then return p end
            if par == workspace then return nil end
            p = par
        end
        return nil
    end
    while _alive() do
        if flagOn("se_esp_mutation", "espMutation") then
            pcall(function()
                local want = {}
                for _, mut in ipairs(MUT_NAMES) do
                    local ok, tagged = pcall(function()
                        return CollectionService:GetTagged("mutation_" .. mut)
                    end)
                    if ok and tagged then
                        for _, inst in ipairs(tagged) do
                            if inst:IsDescendantOf(workspace) then
                                local target = resolveTarget(inst)
                                if target and not want[target] then
                                    want[target] = mut
                                end
                            end
                        end
                    end
                end
                for model, mutName in pairs(want) do
                    local color = colorFor(mutName)
                    local h = model:FindFirstChild("_SEESP")
                    if not h then
                        h = Instance.new("Highlight")
                        h.Name = "_SEESP"
                        h.FillTransparency = 0.85
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = model
                    end
                    h.Adornee = model
                    h.FillColor = color
                    h.OutlineColor = color
                    local bb = model:FindFirstChild("_SEESPV")
                    if not bb then
                        bb = Instance.new("BillboardGui")
                        bb.Name = "_SEESPV"
                        bb.Size = UDim2.new(0, 160, 0, 22)
                        bb.AlwaysOnTop = true
                        bb.MaxDistance = 700
                        bb.StudsOffset = Vector3.new(0, 8, 0)
                        bb.Parent = model
                        local lbl = Instance.new("TextLabel")
                        lbl.Name = "Main"
                        lbl.Size = UDim2.fromScale(1, 1)
                        lbl.BackgroundTransparency = 1
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 14
                        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lbl.TextStrokeTransparency = 0.35
                        lbl.Parent = bb
                    end
                    local lbl = bb:FindFirstChild("Main")
                    if lbl then
                        local txt = string.upper(mutName)
                        if lbl.Text ~= txt then lbl.Text = txt end
                        if lbl.TextColor3 ~= color then lbl.TextColor3 = color end
                    end
                end
                for _, inst in ipairs(workspace:GetDescendants()) do
                    if inst.Name == "_SEESP" and inst:IsA("Highlight") then
                        local ad = inst.Adornee
                        if not ad or not want[ad] or not ad.Parent then
                            inst:Destroy()
                        end
                    elseif inst.Name == "_SEESPV" and inst:IsA("BillboardGui") then
                        local par = inst.Parent
                        if not par or not want[par] then
                            inst:Destroy()
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- ================================================================
-- UI
-- ================================================================
local OxidelibUrl = "https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"
Library = loadstring(game:HttpGet(OxidelibUrl))()

Library.ConfigFolder = "exlumia/strengtheggs"

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
    for _, m in ipairs({ "AddToggle", "AddSlider", "AddDropdown", "AddMultiDropdown", "AddInput" }) do
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

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "+1 Strength for Eggs",
    Title = "Exlumiaa Hub",
    Logo = 72522294315389,
    Folder = "exlumia",
    ToggleKey = Enum.KeyCode.RightShift,
    AllowMultiple = false,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 Strength for Eggs",
    LoadingFooter = "by Exlumiaa Hub",
    StatusText = "Exlumiaa Hub ready",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then
            v:Destroy()
        end
    end
end)

notifyHub = function(opts)
    local ok, err = pcall(function() Window:Notify(opts) end)
    if not ok then warn("[StrengthEggs] notify failed: " .. tostring(err)) end
end

local HomeTab = Window:AddTab({ Name = "Home", Icon = "home", Subtitle = "Info" })
local MainTab = Window:AddTab({ Name = "Main", Icon = "bolt", Subtitle = "Auto Features" })
local RewardsTab = Window:AddTab({ Name = "Rewards", Icon = "gift", Subtitle = "Claims" })
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "person", Subtitle = "Local Player" })
local VisualsTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })

local HomeSub = HomeTab:AddSubTab("Info")
local TrainSub = MainTab:AddSubTab("Train")
local AnimalsSub = MainTab:AddSubTab("Animals")
local ClaimsSub = RewardsTab:AddSubTab("Claims")
local TpSub = PlayerTab:AddSubTab("Movement")
local ESPSub = VisualsTab:AddSubTab("ESP")
local ConfigSub = SettingsTab:AddSubTab("Config")
local HopSub = SettingsTab:AddSubTab("Server")
for _, sub in ipairs({ TrainSub, AnimalsSub, ClaimsSub, TpSub, ESPSub, ConfigSub, HopSub }) do
    autosaveWrap(sub)
end

HomeSub:AddSection("Player")
local labelStrength = HomeSub:AddLabel({ Text = "Strength: --" })
local labelMoney = HomeSub:AddLabel({ Text = "Money: --" })
local labelRebirth = HomeSub:AddLabel({ Text = "Rebirth: --" })
local labelZone = HomeSub:AddLabel({ Text = "Training Zone: --" })

HomeSub:AddSection("Game")
HomeSub:AddLabel({ Text = "GameId: " .. tostring(game.GameId) })
HomeSub:AddLabel({ Text = "PlaceId: " .. tostring(game.PlaceId) })

HomeSub:AddSection("Server")
HomeSub:AddLabel({ Text = "JobId: " .. string.sub(tostring(game.JobId), 1, 20) .. "..." })
HomeSub:AddButton({
    Name = "Copy JobId",
    Callback = function()
        pcall(setclipboard, tostring(game.JobId))
        Window:Notify({ Title = "Copied", Content = "JobId copied!", Type = "success", Duration = 3 })
    end,
})

task.spawn(function()
    while _alive() do
        task.wait(1)
        pcall(function()
            local ls = LP:FindFirstChild("leaderstats")
            local str = ls and ls:FindFirstChild("Strength")
            local mon = ls and ls:FindFirstChild("Money")
            local reb = ls and ls:FindFirstChild("Rebirth")
            if str then labelStrength:Set("Strength: " .. tostring(str.Value)) end
            if mon then labelMoney:Set("Money: " .. tostring(mon.Value)) end
            if reb then labelRebirth:Set("Rebirth: " .. tostring(reb.Value)) end
            if labelZone then labelZone:Set("Training Zone: " .. (LP:GetAttribute("InTrainingZone") and "IN" or "OUT")) end
        end)
    end
end)

TrainSub:AddSection("Training")
TrainSub:AddToggle({ Name = "Auto Train", Description = "Fires the dumbell action automatically", Default = false, Flag = "se_auto_train", Callback = function(v)
    Config.autoTrain = v
end })

TrainSub:AddSection("Progress")
TrainSub:AddToggle({ Name = "Auto Gate Break", Description = "Damage gates automatically", Default = false, Flag = "se_auto_gate", Callback = function(v)
    Config.autoGate = v
end })
TrainSub:AddToggle({ Name = "Auto Rebirth", Description = "Rebirth as soon as eligible", Default = false, Flag = "se_auto_rebirth", Callback = function(v)
    Config.autoRebirth = v
end })

AnimalsSub:AddSection("Collection")
AnimalsSub:AddToggle({ Name = "Auto Pickup Egg", Description = "Pick up eggs / animals from the map", Default = false, Flag = "se_auto_pickup", Callback = function(v)
    Config.autoPickup = v
end })
-- LOOP: AUTO PICKUP EGG
task.spawn(function()
    while _alive() do
        if Config.autoPickup then
            pcall(function()
                local LP = game.Players.LocalPlayer
                local char = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local egg = nil
                local bestD = 9999
                -- Find the nearest egg in Live.Friends
                for _, m in ipairs(workspace.Live.Friends:GetChildren()) do
                    local rp = m:FindFirstChild("RootPart")
                    local pr = rp and rp:FindFirstChild("StealPromptAttach")
                    if rp and pr then
                        local d = (rp.Position - char.Position).Magnitude
                        if d < bestD then bestD, egg = d, m end
                    end
                end
                if egg then
                    local rp = egg:FindFirstChild("RootPart")
                    local pr = rp and rp:FindFirstChild("StealPromptAttach")
                    if pr then
                        -- Trigger prompt hold begin (hold duration 0.1s)
                        pr:InputHoldBegin()
                        task.wait(0.2)
                        pr:InputHoldEnd()
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)
AnimalsSub:AddToggle({ Name = "Auto Place Egg", Description = "Place carried eggs on your plot", Default = false, Flag = "se_auto_place", Callback = function(v)
    Config.autoPlace = v
end })
-- LOOP: AUTO PLACE EGG
-- Place Friend:Fire(friendId, localX, localZ) — local coords relatif ke plot Base
task.spawn(function()
    local lastPlace = 0
    while _alive() do
        if flagOn("se_auto_place", "autoPlace") and (os.clock() - lastPlace) > 1.5 then
            lastPlace = os.clock()
            pcall(function()
                local data = invokeRemote("Data: Get")
                if type(data) ~= "table" or not data.InventoryFriends then return end
                -- Find own plot
                local plots = workspace:FindFirstChild("Plots")
                local myPlot = nil
                if plots then
                    for _, v in ipairs(plots:GetChildren()) do
                        local owner = v:FindFirstChild("owner")
                        if owner and owner.Value == LP.Name then myPlot = v break end
                    end
                end
                local base = myPlot and myPlot:FindFirstChild("Base")
                if not base then return end
                -- Place all friends in inventory
                for id, _ in pairs(data.InventoryFriends) do
                    -- Posisi random dalam plot (offset relatif Base)
                    local lx = math.random(-12, 12)
                    local lz = math.random(-12, 12)
                    fireRemote("Place Friend", tostring(id), lx, lz)
                    task.wait(0.3)
                end
            end)
        end
        task.wait(1)
    end
end)
AnimalsSub:AddToggle({ Name = "Auto Equip Best", Description = "Keep your best animals equipped", Default = false, Flag = "se_auto_equip", Callback = function(v)
    Config.autoEquipBest = v
end })

AnimalsSub:AddSection("Selling")
AnimalsSub:AddToggle({ Name = "Auto Sell", Description = "Sell all animals automatically", Default = false, Flag = "se_auto_sell", Callback = function(v)
    Config.autoSell = v
end })

ClaimsSub:AddSection("Index")
ClaimsSub:AddToggle({ Name = "Auto Claim Index", Description = "Claim all index rewards automatically", Default = false, Flag = "se_auto_index", Callback = function(v)
    Config.autoIndex = v
end })

ClaimsSub:AddSection("AFK")
ClaimsSub:AddToggle({ Name = "Anti AFK", Description = "Keeps your session alive", Default = false, Flag = "se_antiafk", Callback = function(v)
    Config.antiAFK = v
end })

TpSub:AddSection("Plot")
local function getMyPlot()
    local ok, plot = pcall(function()
        if _G.MyPlot then return _G.MyPlot end
        local plots = workspace:FindFirstChild("Plots")
        if plots then
            for _, v in ipairs(plots:GetChildren()) do
                local owner = v:FindFirstChild("owner")
                if owner and owner.Value == LP.Name then return v end
            end
        end
    end)
    if ok then return plot end
end
TpSub:AddButton({ Name = "Teleport to Plot", Primary = false, Callback = function()
    local char = LP.Character
    if not char then
        Window:Notify({ Title = "Teleport", Content = "No character!", Type = "warning", Duration = 3 })
        return
    end
    local plot = getMyPlot()
    local base = plot and plot:FindFirstChild("Base")
    if base then
        char:PivotTo(base.CFrame * CFrame.new(0, 5, 0))
        Window:Notify({ Title = "Teleport", Content = "Teleported to your plot", Type = "success", Duration = 3 })
    else
        Window:Notify({ Title = "Teleport", Content = "Plot not found!", Type = "error", Duration = 3 })
    end
end })

TpSub:AddToggle({ Name = "Q Key to Plot", Description = "Press Q anytime to teleport to your plot", Default = false, Flag = "se_tp_plot_q", Callback = function(v)
    Config.tp_to_plot_q = v
end })
-- Q key handler (always connected, checks flag)
do
    local uis = game:GetService("UserInputService")
    local lastQ = 0
    local conn = uis.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode ~= Enum.KeyCode.Q then return end
        if not Config.tp_to_plot_q then return end
        if uis:GetFocusedTextBox() then return end
        if os.clock() - lastQ < 0.3 then return end
        lastQ = os.clock()
        local char = LP.Character
        if not char then return end
        -- Turn off auto train + auto gate: set BOTH Library flag AND Config
        Config.autoTrain = false
        Config.autoGate = false
        pcall(function() Library:SetFlag("se_auto_train", false) end)
        pcall(function() Library:SetFlag("se_auto_gate", false) end)
        gateBusy = true
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() end
        task.wait(0.2)
        local plot = getMyPlot()
        local base = plot and plot:FindFirstChild("Base")
        if base then
            char:PivotTo(base.CFrame * CFrame.new(0, 5, 0))
            Window:Notify({ Title = "Teleport", Content = "Teleported to plot (Q)", Type = "success", Duration = 2 })
        end
        task.wait(0.5)
        gateBusy = false
    end)
    table.insert(CONNS, conn)
end

local function clearMutationESP()
    pcall(function()
        for _, inst in ipairs(workspace:GetDescendants()) do
            if (inst.Name == "_SEESP" and inst:IsA("Highlight")) or (inst.Name == "_SEESPV" and inst:IsA("BillboardGui")) then
                inst:Destroy()
            end
        end
    end)
end
ESPSub:AddSection("Mutations")
ESPSub:AddToggle({ Name = "ESP Mutations", Description = "Highlight + label mutation names (Golden, Diamond, etc)", Default = false, Flag = "se_esp_mutation", Callback = function(v)
    Config.espMutation = v
    if not v then clearMutationESP() end
end })

ConfigSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({ Name = "Saved Configs", Options = {}, Default = "", Flag = "cfg_sel", Callback = function(v) selectedConfig = v end })
local function refreshConfigList() local c = Library:ListConfigs() if configDropdown then configDropdown:SetOptions(c); configDropdown:Refresh() end end
local configInput = ConfigSub:AddInput({ Name = "Config Name", Default = "", Placeholder = "Enter config name...", Flag = "cfg_name" })
ConfigSub:AddDivider()
ConfigSub:AddButton({ Name = "Save Config", Primary = true, Callback = function()
    local name = configInput:Get() if not name or name == "" then Window:Notify({Title="Config",Content="Enter a name!",Type="warning",Duration=3}) return end
    if Library:SaveConfig(name) then refreshConfigList(); Window:Notify({Title="Config",Content="Saved: "..name,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end })
ConfigSub:AddButton({ Name = "Load Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then Window:Notify({Title="Config",Content="Select config!",Type="warning",Duration=3}) return end
    if Library:LoadConfig(selectedConfig) then refreshConfigList(); Window:Notify({Title="Config",Content="Loaded: "..selectedConfig,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end })
ConfigSub:AddButton({ Name = "Delete Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then return end
    Library:DeleteConfig(selectedConfig); local old = selectedConfig; selectedConfig = ""; refreshConfigList()
    Window:Notify({Title="Config",Content="Deleted: "..old,Type="info",Duration=3})
end })

HopSub:AddSection("Server")
HopSub:AddButton({ Name = "Server Hop", Primary = true, Callback = function()
    Window:Notify({Title="Server Hop",Content="Finding new server...",Type="info",Duration=3})
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
end })

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

if notifyHub then
    notifyHub({ Title = "Exlumiaa Hub", Content = "+1 Strength for Eggs loaded (v1)", Type = "success", Duration = 4 })
end
