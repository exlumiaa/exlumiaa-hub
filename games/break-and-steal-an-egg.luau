if tostring(game.GameId) ~= "10765288803" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _bstTomb"
local _G_GEN = "_ _bstGen"

do
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_GEN, (rawget(_G, _G_GEN) or 0) + 1)
end

local _gen = rawget(_G, _G_GEN)
local function _alive()
    return rawget(_G, _G_GEN) == _gen
end

do
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.W, false, game)
    end)
    pcall(function()
        game:GetService("RunService"):UnbindFromRenderStep("BSE_AUTOAIM")
    end)
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
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst.Name == "_BSESP" then pcall(function() inst:Destroy() end) end
    end
end

-- ================================================================
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_breakandsteal.txt"
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
        local old = pg:FindFirstChild("BreakStealKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "BreakStealKeyGate"
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
        title.Text = "Break and Steal an Egg"
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
    autoBreak = false,
    breakZones = {},
    autoSell = false,
    autoClaim = false,
    autoUpgradePlot = false,
    autoPlace = false,
    autoHatch = false,
    autoTreadmill = false,
    autoShop = false,
    batAura = false,
    espEggs = false,
    espAnimals = false,
    speedOn = false,
    speedVal = 60,
    antiAFK = false,
    tpKeyQ = true,
}
rawset(_G, "_breakStealConfig", Config)

local function zoneSetFromList(sel)
    local set = {}
    if type(sel) == "table" then
        for _, name in ipairs(sel) do
            local n = tonumber((tostring(name):match("^Zone (%d+)")))
            if n then set[n] = true end
        end
    end
    return set
end

local ZONE_LABELS = { "Zone 1 (Common)", "Zone 2 (Uncommon)", "Zone 3 (Rare)", "Zone 4 (Epic)", "Zone 5 (Legendary)", "Zone 6 (Mythic)", "Zone 7 (Divine)", "Zone 8 (Cosmic)", "Zone 9 (Secret)" }

local notifyHub

local function getRemote(name)
    local r = ReplicatedStorage:FindFirstChild(name)
    if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction") or r:IsA("UnreliableRemoteEvent")) then
        return r
    end
    return nil
end

local function fireRS(name, ...)
    local r = getRemote(name)
    if r and r:IsA("RemoteEvent") then
        r:FireServer(...)
        return true
    end
    return false
end

local function getOwnPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, p in ipairs(plots:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == LP.UserId then
            return p
        end
    end
    return nil
end

local function getChar()
    local c = LP.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then
        return c, hrp, hum
    end
    return nil
end

local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local wHeld = false
local function pressW()
    if not wHeld then
        wHeld = true
        pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game) end)
    end
end
local function releaseW()
    if wHeld then
        wHeld = false
        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game) end)
    end
end

local aiming = false
local aimTarget = nil
local function setAim(pos)
    aimTarget = pos
    if not aiming then
        aiming = true
        pcall(function()
            RunService:BindToRenderStep("BSE_AUTOAIM", Enum.RenderPriority.Camera.Value + 1, function()
                local t = aimTarget
                local cam = workspace.CurrentCamera
                if t and cam then
                    local cp = cam.CFrame.Position
                    cam.CFrame = CFrame.lookAt(cp, Vector3.new(t.X, cp.Y, t.Z))
                end
            end)
        end)
    end
end
local function clearAim()
    aimTarget = nil
    if aiming then
        aiming = false
        pcall(function() RunService:UnbindFromRenderStep("BSE_AUTOAIM") end)
    end
end
local function stopTravel()
    releaseW()
    clearAim()
end
local function kbBlocked()
    local ok, tb = pcall(function() return game:GetService("UserInputService"):GetFocusedTextBox() end)
    return ok and tb ~= nil
end

local tpToken = 0
local tpBusy = false
local function stagedTeleport(dest, hop, interval)
    if not dest then return end
    tpToken = tpToken + 1
    local myToken = tpToken
    tpBusy = true
    task.spawn(function()
        local HOP = hop or 300
        local INT = interval or 1.2
        local steps = 0
        while _alive() and myToken == tpToken do
            steps = steps + 1
            if steps > 12 then
                if myToken == tpToken then tpBusy = false end
                if notifyHub then
                    notifyHub({ Title = "Teleport", Content = "Kept getting pulled back - teleport failed", Type = "warning", Duration = 3 })
                end
                return
            end
            local char, hrp = getChar()
            if not char then
                if myToken == tpToken then tpBusy = false end
                return
            end
            local pos = hrp.Position
            local delta = dest - pos
            local dist = delta.Magnitude
            if dist < 12 then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                if myToken == tpToken then tpBusy = false end
                return
            end
            local step
            if dist <= HOP then
                step = dest
            else
                step = pos + delta.Unit * HOP
            end
            local rot = hrp.CFrame - pos
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(step) * rot
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            task.wait(INT)
        end
        if myToken == tpToken then tpBusy = false end
    end)
end

local function isLiveEgg(p)
    return p.Parent ~= nil and p:IsA("BasePart")
        and not p:GetAttribute("Broken")
        and not p:GetAttribute("Hatching")
        and not p:GetAttribute("Despawning")
end

local function nearestLiveEgg(pos, maxDist, unfiltered)
    local allow
    if not unfiltered then
        allow = type(Config.breakZones) == "table" and Config.breakZones or {}
    end
    local best, bestD = nil, maxDist or math.huge
    for _, p in ipairs(CollectionService:GetTagged("BreakableEgg")) do
        if isLiveEgg(p) then
            local zi = tonumber(p:GetAttribute("ZoneIndex"))
            if (not allow) or (zi and allow[zi]) then
                local d = (p.Position - pos).Magnitude
                if d < bestD then
                    best, bestD = p, d
                end
            end
        end
    end
    return best, bestD
end

local function heldAnimalTool(char)
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and CollectionService:HasTag(t, "AnimalTool") then
            return t
        end
    end
    return nil
end

local function plotCapacity(plot)
    local placed = plot:GetAttribute("AnimalsPlaced") or 0
    local maxA = plot:GetAttribute("MaxAnimals")
    if not maxA then
        local ok, cfg = pcall(function() return require(ReplicatedStorage.Shared.PlotUpgradeConfig) end)
        if ok and cfg and cfg.Capacity then
            pcall(function()
                maxA = cfg.Capacity(plot:GetAttribute("PlotLevel") or 1)
            end)
        end
    end
    return placed, maxA or 999
end

local placeCounter = math.random(1, 5000)

-- ================================================================
-- LOOP: AUTO BREAK
-- ================================================================
task.spawn(function()
    local lastHit = 0
    local lastEquip = 0
    while _alive() do
        if Config.autoBreak and not Config.autoTreadmill and not tpBusy then
            pcall(function()
                local char, hrp, hum = getChar()
                if char and not heldAnimalTool(char) then
                    local egg, d = nearestLiveEgg(hrp.Position, 100000)
                    if egg then
                        if d > 6.5 then
                            if kbBlocked() then
                                stopTravel()
                            else
                                setAim(egg.Position)
                                pressW()
                            end
                        else
                            stopTravel()
                            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(egg.Position.X, hrp.Position.Y, egg.Position.Z))
                            local bp = LP:FindFirstChild("Backpack")
                            local held = char:FindFirstChild("Pickaxe")
                            if not held and bp and bp:FindFirstChild("Pickaxe") and os.clock() - lastEquip > 0.6 then
                                lastEquip = os.clock()
                                hum:EquipTool(bp:FindFirstChild("Pickaxe"))
                                held = char:FindFirstChild("Pickaxe")
                            end
                            if held and os.clock() - lastHit >= 0.4 then
                                lastHit = os.clock()
                                if fireRS("EggHitRequest", egg) then
                                    pcall(function()
                                        local sfx = held:FindFirstChild("Handle")
                                        sfx = sfx and sfx:FindFirstChild("PickaxeSwoosh")
                                    end)
                                end
                            end
                        end
                    else
                        stopTravel()
                        task.wait(1)
                    end
                else
                    stopTravel()
                end
            end)
        else
            stopTravel()
        end
        task.wait(0.15)
    end
    stopTravel()
end)

-- ================================================================
-- LOOP: AUTO SELL (animals in backpack when plot is full)
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoSell then
            pcall(function()
                local rf = getRemote("BackpackSellRemote")
                if rf and rf:IsA("RemoteFunction") then
                    local plot = getOwnPlot()
                    if plot then
                        local placed, maxA = plotCapacity(plot)
                        if placed >= maxA then
                            local list = {}
                            for _, t in ipairs(LP.Backpack:GetChildren()) do
                                if t:IsA("Tool") and CollectionService:HasTag(t, "AnimalTool") then
                                    table.insert(list, t)
                                end
                            end
                            if #list > 0 then
                                rf:InvokeServer(list)
                                if notifyHub then
                                    notifyHub({ Title = "Auto Sell", Content = "Sold " .. #list .. " animals (plot full)", Type = "info", Duration = 3 })
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- ================================================================
-- LOOP: AUTO CLAIM INDEX REWARD
-- ================================================================
task.spawn(function()
    local lastClaim = 0
    local function scanReady(t, names, depth)
        if type(t) ~= "table" or depth > 3 then return end
        for k, v in pairs(t) do
            if v == "Ready" and type(k) == "string" then
                table.insert(names, k)
            elseif type(v) == "table" then
                scanReady(v, names, depth + 1)
            end
        end
    end
    pcall(function()
        local r = getRemote("IndexRemote")
        if r and r:IsA("RemoteEvent") then
            r.OnClientEvent:Connect(function(t1, t2)
                if t1 ~= "State" or not Config.autoClaim then return end
                local names = {}
                scanReady(t2, names, 1)
                if #names > 0 and os.clock() - lastClaim >= 5 then
                    lastClaim = os.clock()
                    pcall(function()
                        for _, name in ipairs(names) do
                            r:FireServer("Claim", name)
                        end
                    end)
                end
            end)
        end
    end)
    while _alive() do
        if Config.autoClaim then
            pcall(function()
                local r = getRemote("IndexRemote")
                if r and r:IsA("RemoteEvent") then
                    r:FireServer("Get", nil)
                end
            end)
        end
        task.wait(10)
    end
end)

-- ================================================================
-- LOOP: AUTO UPGRADE PLOT
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoUpgradePlot then
            pcall(function()
                fireRS("UpgradePlotRequest")
            end)
        end
        task.wait(5)
    end
end)

-- ================================================================
-- LOOP: AUTO SHOP (PICKAXE + TRAIL)
-- ================================================================
task.spawn(function()
    local PickaxeConfig, TrailsConfig
    local function ensureConfigs()
        if not PickaxeConfig then
            local ok, m = pcall(function() return require(ReplicatedStorage.Shared.PickaxeConfig) end)
            if ok and type(m) == "table" then PickaxeConfig = m end
        end
        if not TrailsConfig then
            local ok, m = pcall(function() return require(ReplicatedStorage.Shared.TrailsConfig) end)
            if ok and type(m) == "table" then TrailsConfig = m end
        end
        return PickaxeConfig ~= nil and TrailsConfig ~= nil
    end
    local function parseIds(s)
        local set = {}
        if type(s) == "string" then
            for token in string.gmatch(s, "[^,]+") do
                local n = tonumber(token)
                if n then set[n] = true end
            end
        end
        return set
    end
    local lastFire = 0
    while _alive() do
        if Config.autoShop and ensureConfigs() then
            pcall(function()
                local cash = LP:GetAttribute("Cash")
                if typeof(cash) ~= "number" then return end
                if os.clock() - lastFire < 1.5 then return end
                -- pickaxe: owned set
                local owned = { [PickaxeConfig.DefaultTier] = true }
                local tier = LP:GetAttribute("PickaxeTier")
                if typeof(tier) == "number" then owned[tier] = true end
                for id in pairs(parseIds(LP:GetAttribute("OwnedPickaxes"))) do owned[id] = true end
                local maxPick = PickaxeConfig.DefaultTier
                for id in pairs(owned) do
                    if id > maxPick then maxPick = id end
                end
                -- find highest affordable tier (same logic as the game shop)
                local buyTier
                for i, entry in ipairs(PickaxeConfig.Tiers) do
                    if i > maxPick and not owned[i] and (entry.Price or 0) <= cash then
                        if buyTier == nil or i > buyTier then buyTier = i end
                    end
                end
                if buyTier then
                    lastFire = os.clock()
                    fireRS("PickaxeShopRequest", "Buy", buyTier)
                    return
                end
                if typeof(tier) ~= "number" or tier ~= maxPick then
                    lastFire = os.clock()
                    fireRS("PickaxeShopRequest", "Equip", maxPick)
                    return
                end
                -- trail
                local tOwned = parseIds(LP:GetAttribute("OwnedTrails"))
                local maxTrail = 0
                for id in pairs(tOwned) do
                    if id > maxTrail then maxTrail = id end
                end
                local buyTrail
                for _, entry in ipairs(TrailsConfig.Trails) do
                    if entry.Id > maxTrail and not tOwned[entry.Id] and (entry.Price or 0) <= cash then
                        if buyTrail == nil or entry.Id > buyTrail then buyTrail = entry.Id end
                    end
                end
                if buyTrail then
                    lastFire = os.clock()
                    fireRS("TrailShopRequest", "Buy", buyTrail)
                    return
                end
                local equipped = LP:GetAttribute(TrailsConfig.EquippedAttribute)
                if maxTrail > 0 and (typeof(equipped) ~= "number" or equipped ~= maxTrail) then
                    lastFire = os.clock()
                    fireRS("TrailShopRequest", "Equip", maxTrail)
                end
            end)
        end
        task.wait(5)
    end
end)

-- ================================================================
-- LOOP: AUTO PLACE (place animals on own plot)
-- ================================================================
task.spawn(function()
    local lastAttempt = 0
    while _alive() do
        if Config.autoPlace then
            pcall(function()
                local char, hrp, hum = getChar()
                if char then
                    local tool = heldAnimalTool(char)
                    if tool then
                        local plot = getOwnPlot()
                        local hb = plot and plot:FindFirstChild("Hitbox")
                        if plot and hb and hb:IsA("BasePart") and not plot:GetAttribute("RestoringPets") then
                            local placed, maxA = plotCapacity(plot)
                            if placed < maxA and os.clock() - lastAttempt >= 1.2 then
                                local maxDist = 40
                                pcall(function()
                                    maxDist = require(ReplicatedStorage.Shared.AnimalPlacementConfig).MaxPlaceDistance or maxDist
                                end)
                                local half = hb.Size * 0.5
                                local off = Vector3.new(
                                    (math.random() * 2 - 1) * half.X * 0.7,
                                    hb.Size.Y * 0.25,
                                    (math.random() * 2 - 1) * half.Z * 0.7
                                )
                                local target = hb.CFrame * off
                                local dist = (Vector3.new(target.X, 0, target.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
                                if dist <= maxDist then
                                    lastAttempt = os.clock()
                                    placeCounter = placeCounter + 1
                                    fireRS("PlaceAnimalRemote", tool, target, placeCounter)
                                else
                                    hum:MoveTo(hb.Position)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.25)
    end
end)

-- ================================================================
-- LOOP: AUTO HATCH & SKIP (eggs in inventory)
-- ================================================================
task.spawn(function()
    local lastHatch = 0
    while _alive() do
        if Config.autoHatch then
            pcall(function()
                if os.clock() - lastHatch >= 3 then
                    lastHatch = os.clock()
                    fireRS("MergeMachineRemote", "SkipAll")
                end
                local bp = LP:FindFirstChild("Backpack")
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") and CollectionService:HasTag(t, "MergeEggTool") then
                            local eggId = t:GetAttribute("EggId")
                            if eggId then
                                fireRS("MergeMachineRemote", "HatchEgg", eggId)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- ================================================================
-- LOOP: AUTO TREADMILL
-- ================================================================
local function getTreadmillPos(plot)
    if not plot then return nil end
    local beltModels = {}
    for _, d in ipairs(plot:GetDescendants()) do
        local lower = string.lower(d.Name)
        if d:IsA("Model") and string.find(lower, "treadmill") and not string.find(lower, "board") then
            table.insert(beltModels, d)
        end
    end
    for _, m in ipairs(beltModels) do
        local hitbox = m:FindFirstChild("Hitbox")
        if hitbox and hitbox:IsA("BasePart") then
            return hitbox.Position - Vector3.new(0, 1.1, 0)
        end
    end
    if beltModels[1] then
        return beltModels[1]:GetPivot().Position + Vector3.new(0, 1, 0)
    end
    return nil
end

task.spawn(function()
    local wasOn = false
    while _alive() do
        if Config.autoTreadmill then
            wasOn = true
            pcall(function()
                local char, hrp = getChar()
                if char and not heldAnimalTool(char) then
                    local pos = getTreadmillPos(getOwnPlot())
                    if pos and (hrp.Position - pos).Magnitude > 10 and not tpBusy then
                        stagedTeleport(pos + Vector3.new(0, 2, 0))
                    end
                end
            end)
        elseif wasOn then
            wasOn = false
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("TreadmillSessionRemote")
                if r and r:IsA("RemoteEvent") then
                    r:FireServer()
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ================================================================
-- LOOP: BAT KILL AURA (auto swing at nearest player)
-- ================================================================
task.spawn(function()
    local BatTargeting
    local lastSwing = 0
    local wasOn = false
    while _alive() do
        if Config.batAura then
            wasOn = true
            pcall(function()
                if not BatTargeting then
                    local ok, m = pcall(function() return require(ReplicatedStorage.Shared.BatTargeting) end)
                    if ok and type(m) == "table" then BatTargeting = m end
                end
                if not BatTargeting then return end
                local char, hrp, hum = getChar()
                if not char then return end
                local bat = char:FindFirstChild("Bat")
                if not bat then
                    local bp = LP:FindFirstChild("Backpack")
                    bat = bp and bp:FindFirstChild("Bat")
                    if bat and hum then
                        hum:EquipTool(bat)
                        return
                    end
                    return
                end
                local rem = ReplicatedStorage:FindFirstChild("BatHitRequest")
                if not rem or not rem:IsA("RemoteEvent") then return end
                local now = tick()
                if now - lastSwing < 0.75 then return end
                local target = BatTargeting.SelectClosestTarget(LP, hrp.Position, 20)
                if target then
                    local tc = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                    if tc then
                        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(tc.Position.X, hrp.Position.Y, tc.Position.Z))
                    end
                    lastSwing = now
                    rem:FireServer(target)
                end
            end)
        elseif wasOn then
            wasOn = false
        end
        task.wait(0.25)
    end
end)

-- ================================================================
-- LOOP: ESP
-- ================================================================
local function makeESP(adornee, color)
    local h = Instance.new("Highlight")
    h.Name = "_BSESP"
    h.FillColor = color
    h.FillTransparency = 0.82
    h.OutlineColor = color
    h.OutlineTransparency = 0.1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = adornee
    h.Parent = adornee
    return h
end

local function fmtMoney(n)
    n = math.floor((n or 0) + 0.5)
    local abs = math.abs(n)
    local suffix, div = "", 1
    if abs >= 1e12 then suffix, div = "T", 1e12
    elseif abs >= 1e9 then suffix, div = "B", 1e9
    elseif abs >= 1e6 then suffix, div = "M", 1e6
    elseif abs >= 1e3 then suffix, div = "K", 1e3
    else return tostring(n) end
    local v = n / div
    local s = if v >= 100 then string.format("%.0f", v) else string.format("%.1f", v)
    return (s:gsub("%.0$", "")) .. suffix
end

local function ensureValueTag(inst)
    local bb = inst:FindFirstChild("_BSESPV")
    if bb then return bb end
    bb = Instance.new("BillboardGui")
    bb.Name = "_BSESPV"
    bb.Size = UDim2.new(0, 150, 0, 34)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 500
    bb.Parent = inst
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Main"
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(255, 220, 90)
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextStrokeTransparency = 0.35
    lbl.Text = ""
    lbl.Parent = bb
    return bb
end

task.spawn(function()
    local EGG_COLOR = Color3.fromRGB(80, 255, 120)
    local ANIMAL_COLOR = Color3.fromRGB(255, 200, 60)
    local BSC
    while _alive() do
        pcall(function()
            if not BSC then
                local ok, m = pcall(function() return require(ReplicatedStorage.Shared.BackpackSellConfig) end)
                if ok and type(m) == "table" and type(m.EggValue) == "function" then BSC = m end
            end
            local want = {}
            if Config.espEggs then
                for _, p in ipairs(CollectionService:GetTagged("BreakableEgg")) do
                    if isLiveEgg(p) then want[p] = true end
                end
            end
            if Config.espAnimals then
                local ap = workspace:FindFirstChild("AnimalPickups")
                if ap then
                    for _, m in ipairs(ap:GetChildren()) do
                        want[m] = true
                    end
                end
            end
            for inst in pairs(want) do
                if inst.Parent and not inst:FindFirstChild("_BSESP") then
                    local isEgg = inst:IsA("BasePart")
                    makeESP(inst, if isEgg then EGG_COLOR else ANIMAL_COLOR)
                end
                if inst:IsA("BasePart") and want[inst] and inst:FindFirstChild("_BSESP") then
                    local et = inst:GetAttribute("EggType")
                    if et and BSC then
                        local bb = ensureValueTag(inst)
                        bb.StudsOffset = Vector3.new(0, inst.Size.Y / 2 + 1.5, 0)
                        local lbl = bb:FindFirstChild("Main")
                        if lbl then
                            local val
                            pcall(function()
                                val = BSC.EggValue(et, inst:GetAttribute("WeightKg"))
                            end)
                            local txt = if typeof(val) == "number" then "$" .. fmtMoney(val) .. "  " .. et else tostring(et)
                            if lbl.Text ~= txt then lbl.Text = txt end
                        end
                    end
                end
            end
            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst.Name == "_BSESP" and inst:IsA("Highlight") then
                    local ad = inst.Adornee
                    if not ad or not want[ad] or ad.Parent == nil then
                        inst:Destroy()
                    end
                elseif inst.Name == "_BSESPV" and inst:IsA("BillboardGui") then
                    local par = inst.Parent
                    if not par or not want[par] then
                        inst:Destroy()
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- ================================================================
-- LOOP: WALKSPEED + ANTI-AFK
-- ================================================================
task.spawn(function()
    local wasOn = false
    local function gameMappedSpeed()
        local ok, v = pcall(function()
            return require(ReplicatedStorage.Shared.SpeedConfig).SpeedPowerToWalkSpeed(LP:GetAttribute("SpeedPower") or 10)
        end)
        if ok and type(v) == "number" then return v end
        return nil
    end
    local creatures = {}
    local nextScan = 0
    local function refreshCreatures()
        creatures = {}
        local zb = workspace:FindFirstChild("Build") and workspace.Build:FindFirstChild("ZoneBuilds")
        if not zb then return end
        for _, d in ipairs(zb:GetDescendants()) do
            if d:IsA("Model") then
                local hum = d:FindFirstChildOfClass("Humanoid")
                local hrp = d:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
                    table.insert(creatures, hrp)
                end
            end
        end
    end
    local function nearCreature(pos)
        local best = math.huge
        for i = #creatures, 1, -1 do
            local cr = creatures[i]
            if not cr.Parent then
                table.remove(creatures, i)
            else
                local d = (Vector3.new(cr.Position.X, 0, cr.Position.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
                if d < best then best = d end
            end
        end
        return best
    end
    while _alive() do
        pcall(function()
            local char, hrp, hum = getChar()
            if char and hum then
                if Config.speedOn then
                    local target = math.clamp(Config.speedVal, 16, 200)
                    local now = os.clock()
                    if now >= nextScan then
                        nextScan = now + 5
                        refreshCreatures()
                    end
                    if #creatures > 0 and nearCreature(hrp.Position) < 110 then
                        target = math.min(target, 100)
                    end
                    if math.abs(hum.WalkSpeed - target) > 0.5 then
                        hum.WalkSpeed = target
                    end
                    wasOn = true
                elseif wasOn then
                    wasOn = false
                    local mapped = gameMappedSpeed()
                    if mapped then
                        hum.WalkSpeed = math.clamp(mapped, 16, 200)
                    end
                end
            end
        end)
        task.wait(0.15)
    end
end)

task.spawn(function()
    while _alive() do
        if Config.antiAFK then
            pcall(function()
                local char, hrp, hum = getChar()
                if char then
                    hum.Jump = true
                end
            end)
        end
        task.wait(12)
    end
end)

-- ================================================================
-- UI
-- ================================================================
local OxidelibUrl = "https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"
local Library = loadstring(game:HttpGet(OxidelibUrl))()

Library.ConfigFolder = "exlumiaa/breakandsteal"

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
    BrandSubtitle = "Break and Steal an Egg",
    Title = "Exlumiaa Hub",
    Logo = 72522294315389,
    Folder = "exlumia",
    ToggleKey = Enum.KeyCode.RightShift,
    AllowMultiple = false,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Break and Steal an Egg",
    LoadingFooter = "by Exlumiaa Hub",
    StatusText = "Exlumiaa Hub ready",
    GuiName = "ExlumiaaHub",
})

notifyHub = function(opts)
    local ok, err = pcall(function() Window:Notify(opts) end)
    if not ok then warn("[BreakSteal] notify failed: " .. tostring(err)) end
end

local MainTab = Window:AddTab({ Name = "Main", Icon = "agriculture", Subtitle = "Auto Features" })
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "person", Subtitle = "Local Player" })
local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })

local FarmSub = MainTab:AddSubTab("Farm")
local BaseSub = MainTab:AddSubTab("Base")
local RewardSub = MainTab:AddSubTab("Rewards")
local BatSub = MainTab:AddSubTab("Bat")
local PlayerSub = PlayerTab:AddSubTab("Movement")
local TpSub = PlayerTab:AddSubTab("Teleport")
local ESPSub = VisualTab:AddSubTab("ESP")
for _, sub in ipairs({ FarmSub, BaseSub, RewardSub, BatSub, PlayerSub, TpSub, ESPSub }) do
    autosaveWrap(sub)
end

FarmSub:AddSection("Egg Loop")
FarmSub:AddToggle({ Name = "Auto Break", Description = "Break the nearest egg automatically", Default = false, Flag = "bs_auto_break", Callback = function(v)
    Config.autoBreak = v
    if v and Config.autoTreadmill then
        Config.autoTreadmill = false
        if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Treadmill turned off (conflicts with Auto Break)", Type = "warning", Duration = 3 }) end
    end
    if v and Config.batAura then
        Config.batAura = false
        if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Swing turned off (conflicts with Auto Break)", Type = "warning", Duration = 3 }) end
    end
end })
FarmSub:AddMultiDropdown({
    Name = "Break Zones",
    Description = "Zones Auto Break will mine (none selected = off)",
    Options = ZONE_LABELS,
    Default = {},
    MaxVisible = 5,
    Flag = "bs_break_zones",
    Callback = function(sel)
        Config.breakZones = zoneSetFromList(sel)
    end,
})
FarmSub:AddToggle({ Name = "Auto Hatch & Skip", Description = "Skip growth + hatch eggs in inventory", Default = false, Flag = "bs_auto_hatch", Callback = function(v)
    Config.autoHatch = v
end })

BaseSub:AddSection("Base")
BaseSub:AddToggle({ Name = "Auto Place", Description = "Place animals on your own plot", Default = false, Flag = "bs_auto_place", Callback = function(v)
    Config.autoPlace = v
end })
BaseSub:AddToggle({ Name = "Auto Treadmill", Description = "Stand on your own treadmill", Default = false, Flag = "bs_auto_treadmill", Callback = function(v)
    Config.autoTreadmill = v
    if v and Config.autoBreak then
        Config.autoBreak = false
        if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Break turned off (conflicts with Auto Treadmill)", Type = "warning", Duration = 3 }) end
    end
end })
BaseSub:AddToggle({ Name = "Auto Sell", Description = "Sell animals when the plot is full", Default = false, Flag = "bs_auto_sell", Callback = function(v)
    Config.autoSell = v
end })
BaseSub:AddToggle({ Name = "Auto Upgrade Plot", Description = "Keep upgrading the plot when cash is enough", Default = false, Flag = "bs_auto_upgrade", Callback = function(v)
    Config.autoUpgradePlot = v
end })
BaseSub:AddSection("Shop")
BaseSub:AddToggle({ Name = "Auto Shop", Description = "Buy & equip the highest affordable pickaxe + trail", Default = false, Flag = "bs_auto_shop", Callback = function(v)
    Config.autoShop = v
end })

RewardSub:AddSection("Claim")
RewardSub:AddToggle({ Name = "Auto Claim Reward", Description = "Claim ready Index (collection) rewards", Default = false, Flag = "bs_auto_claim", Callback = function(v)
    Config.autoClaim = v
    if v then
        task.spawn(function()
            pcall(function()
                local r = getRemote("IndexRemote")
                if r and r:IsA("RemoteEvent") then r:FireServer("Get", nil) end
            end)
        end)
    end
end })

BatSub:AddSection("Kill Aura")
BatSub:AddToggle({ Name = "Auto Swing", Description = "Auto hit the nearest player with the bat (close range)", Default = false, Flag = "bs_auto_swing", Callback = function(v)
    Config.batAura = v
    if v then
        if Config.autoBreak then
            Config.autoBreak = false
            if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Break turned off (conflicts with Auto Swing)", Type = "warning", Duration = 3 }) end
        end
    end
end })

PlayerSub:AddSection("Speed")
PlayerSub:AddToggle({ Name = "WalkSpeed", Description = "Keep speed value close to your natural game speed", Default = false, Flag = "bs_walkspeed", Callback = function(v)
    Config.speedOn = v
end })
PlayerSub:AddSlider({ Name = "Speed Value", Min = 16, Max = 200, Default = 60, Rounding = 0, Flag = "bs_speed_val", Callback = function(v)
    Config.speedVal = v
end })
PlayerSub:AddSection("Anti AFK")
PlayerSub:AddToggle({ Name = "Anti-AFK", Description = "Jump periodically to avoid kicks", Default = false, Flag = "bs_antiafk", Callback = function(v)
    Config.antiAFK = v
end })

TpSub:AddSection("Teleport")
local function tpToBase()
    pcall(function()
        local char = getChar()
        local plot = getOwnPlot()
        if char and plot then
            local dest = nil
            local sp = plot:FindFirstChild("SpawnPoint")
            if sp and sp:IsA("BasePart") then
                dest = sp.Position + Vector3.new(0, 3, 0)
            else
                local hb = plot:FindFirstChild("Hitbox")
                if hb then
                    dest = hb.Position + Vector3.new(0, 5, 0)
                end
            end
            if dest then
                stagedTeleport(dest, 350, 1.2)
            end
        end
    end)
end
TpSub:AddButton({ Name = "Teleport to Base", Primary = false, Callback = function()
    tpToBase()
end })
TpSub:AddToggle({ Name = "Q Key to Base", Description = "Press Q anytime to teleport back to base", Default = true, Flag = "bs_tp_q", Callback = function(v)
    Config.tpKeyQ = v
end })
TpSub:AddButton({ Name = "Teleport to Nearest Egg", Primary = false, Callback = function()
    pcall(function()
        local char, hrp = getChar()
        if char then
            local egg = nearestLiveEgg(hrp.Position, 100000, true)
            if egg then
                stagedTeleport(egg.Position + Vector3.new(0, 3, 0))
            elseif notifyHub then
                notifyHub({ Title = "Teleport", Content = "No live eggs found", Type = "warning", Duration = 3 })
            end
        end
    end)
end })
TpSub:AddButton({ Name = "Teleport to Egg Machine", Primary = false, Callback = function()
    pcall(function()
        local char = getChar()
        local em = workspace:FindFirstChild("EggMachine")
        if char and em then
            stagedTeleport(em:GetPivot().Position + Vector3.new(0, 4, 0))
        end
    end)
end })
TpSub:AddSection("Zone")
local selectedZone = ""
TpSub:AddDropdown({
    Name = "Zone",
    Description = "Which zone to teleport to",
    Options = ZONE_LABELS,
    Default = "",
    Flag = "bs_tp_zone",
    Callback = function(v) selectedZone = v end,
})
TpSub:AddButton({
    Name = "Teleport to Zone",
    Primary = true,
    Callback = function()
        if not selectedZone or selectedZone == "" then
            if notifyHub then notifyHub({ Title = "Teleport", Content = "Select a zone first!", Type = "warning", Duration = 3 }) end
            return
        end
        local n = selectedZone:match("^Zone (%d+)")
        pcall(function()
            local char, hrp = getChar()
            local build = workspace:FindFirstChild("Build")
            local zoneBuilds = build and build:FindFirstChild("ZoneBuilds")
            local zone = zoneBuilds and zoneBuilds:FindFirstChild("Zone" .. tostring(n))
            if char and zone and hrp then
                local zp = zone:GetPivot().Position
                local from = hrp.Position
                local full = (zp - from).Magnitude
                local target = zp + Vector3.new(0, 5, 0)
                if full > 100 then
                    target = from + (zp - from).Unit * (full - 60) + Vector3.new(0, 5, 0)
                end
                stagedTeleport(target, 300, 1.2)
                if notifyHub then notifyHub({ Title = "Teleport", Content = "Teleporting to " .. selectedZone, Type = "success", Duration = 3 }) end
            elseif notifyHub then
                notifyHub({ Title = "Teleport", Content = "Zone not found", Type = "error", Duration = 3 })
            end
        end)
    end,
})

do
    local UIS = game:GetService("UserInputService")
    local lastQ = 0
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Q and Config.tpKeyQ then
            if os.clock() - lastQ > 0.3 and not UIS:GetFocusedTextBox() then
                lastQ = os.clock()
                tpToBase()
            end
        end
    end)
end

ESPSub:AddSection("ESP")
ESPSub:AddToggle({ Name = "ESP Eggs", Description = "Highlight + label value & egg type", Default = false, Flag = "bs_esp_eggs", Callback = function(v)
    Config.espEggs = v
    if not v then
        for _, inst in ipairs(workspace:GetDescendants()) do
            if (inst.Name == "_BSESP" and inst:IsA("Highlight")) or (inst.Name == "_BSESPV" and inst:IsA("BillboardGui")) then
                inst:Destroy()
            end
        end
    end
end })
ESPSub:AddToggle({ Name = "ESP Animals", Description = "Highlight wild animals you can steal", Default = false, Flag = "bs_esp_animals", Callback = function(v)
    Config.espAnimals = v
    if not v then
        local ap = workspace:FindFirstChild("AnimalPickups")
        if ap then
            for _, m in ipairs(ap:GetChildren()) do
                local h = m:FindFirstChild("_BSESP")
                if h then h:Destroy() end
            end
        end
    end
end })

local SettingsSub = SettingsTab:AddSubTab("Config")
autosaveWrap(SettingsSub)
SettingsSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = SettingsSub:AddDropdown({ Name = "Saved Configs", Options = {}, Default = "", Flag = "cfg_sel", Callback = function(v) selectedConfig = v end })
local function refreshConfigList() local c = Library:ListConfigs() if configDropdown then configDropdown:SetOptions(c); configDropdown:Refresh() end end
local configInput = SettingsSub:AddInput({ Name = "Config Name", Default = "", Placeholder = "Enter config name...", Flag = "cfg_name" })
SettingsSub:AddDivider()
SettingsSub:AddButton({ Name = "Save Config", Primary = true, Callback = function()
    local name = configInput:Get() if not name or name == "" then Window:Notify({Title="Config",Content="Enter a name!",Type="warning",Duration=3}) return end
    if Library:SaveConfig(name) then refreshConfigList(); Window:Notify({Title="Config",Content="Saved: "..name,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end })
SettingsSub:AddButton({ Name = "Load Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then Window:Notify({Title="Config",Content="Select config!",Type="warning",Duration=3}) return end
    if Library:LoadConfig(selectedConfig) then refreshConfigList(); Window:Notify({Title="Config",Content="Loaded: "..selectedConfig,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end })
SettingsSub:AddButton({ Name = "Delete Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then return end
    Library:DeleteConfig(selectedConfig); local old = selectedConfig; selectedConfig = ""; refreshConfigList()
    Window:Notify({Title="Config",Content="Deleted: "..old,Type="info",Duration=3})
end })

local ServerSub = SettingsTab:AddSubTab("Server")
ServerSub:AddSection("Server")
ServerSub:AddButton({ Name = "Server Hop", Primary = true, Callback = function()
    Window:Notify({Title="Server Hop",Content="Finding new server...",Type="info",Duration=3})
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
end })

pcall(function() Library:LoadConfig("default") end)
pcall(function()
    Config.breakZones = zoneSetFromList(Library:GetFlag("bs_break_zones"))
end)
pcall(refreshConfigList)

if notifyHub then
    notifyHub({ Title = "Exlumiaa Hub", Content = "Break and Steal an Egg loaded (v1)", Type = "success", Duration = 4 })
end
