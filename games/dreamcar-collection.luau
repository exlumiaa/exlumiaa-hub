if tostring(game.GameId) ~= "10667357873" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _dreamcarTomb"
local _G_ALIVE = "_ _dreamcarAlive"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
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
    local ok = pcall(function()
        if rawget(_G, "_dreamcarBWHooked") then return end
        local bw = require(ReplicatedStorage.Shared.Packages.ByteNet.process.bufferWriter)
        local orig
        orig = hookfunction(bw.load, function(p1)
            if p1 == nil then
                p1 = {cursor = 0, size = 256, references = {}, buff = buffer.create(256)}
            end
            return orig(p1)
        end)
        rawset(_G, "_dreamcarBWHooked", true)
    end)
    if not ok then warn("[DreamCar] bufferWriter hook failed") end
end

-- ================================================================
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_dreamcar.txt"
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
        local old = pg:FindFirstChild("DreamCarKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "DreamCarKeyGate"
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
        title.Text = "Dream Car Collection"
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

local RARITY_ORDER = {
    "Common", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Prismatic",
    "Sacred", "Secret", "Godly", "Cosmic", "Apex", "Primordial", "Eternal",
}

local TIER_ORDER = {
    "Common", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Prismatic",
    "Sacred", "Secret", "Godly", "Cosmic", "Apex", "Primordial",
}

local Config = {
    autoSpawnCrates = false,
    autoPlaceCrates = false,
    autoOpenCrates = false,
    autoSellCrates = false,
    sellRarities = {},
    buyTiers = {},
    autoLaunch = false,
    autoShift = false,
    autoNitro = false,
    unlimitedNitro = false,
    autoRebirth = false,
    autoQuest = false,
    autoDaily = false,
    autoFreeReward = false,
    autoUpgrades = false,
    autoClean = false,
    walkSpeed = 16,
    walkSpeedEnabled = false,
    jumpPower = 50,
    jumpPowerEnabled = false,
    espEnabled = false,
    espNames = true,
    espDistance = true,
    espHighlight = true,
}
for _, rarity in ipairs(RARITY_ORDER) do
    Config.sellRarities[rarity] = (rarity == "Common" or rarity == "Rare")
end
for _, tier in ipairs(TIER_ORDER) do
    Config.buyTiers[tier] = (tier == "Common" or tier == "Rare")
end
rawset(_G, "_dreamcarConfig", Config)

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getNet()
    local ok, net = pcall(function() return require(ReplicatedStorage.Networking) end)
    return ok and net or nil
end

local function getPlayerContainer()
    local ok, PDS = pcall(function() return require(ReplicatedStorage.Shared.Managers.PlayerDataShared) end)
    if not ok then return nil end
    local ok2, container = PDS.PlayerDataContainers:WaitForObject(LP):await()
    return ok2 and container or nil
end

local function getCash()
    local c = getPlayerContainer()
    if not c then return 0 end
    local ok, v = pcall(function() return c:GetValue("Cash") end)
    return ok and tonumber(v) or 0
end

local function getRebirths()
    local c = getPlayerContainer()
    if not c then return 0 end
    local ok, v = pcall(function() return c:GetValue("Rebirths") end)
    return ok and tonumber(v) or 0
end

local function safeSend(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[DreamCar] send failed: "..tostring(err)) end
    return ok
end

-- ========== CRATE AUTOMATION ==========
local lastCrateSync = 0
local crateSequence = 0
local crateQueue = {}
local crateFlushing = false

local function queueCrateToggle(key, tier, enabled)
    local id = key .. ":" .. (tier or "")
    crateQueue[id] = {
        key = key,
        tier = tier or "",
        enabled = enabled and true or false,
    }
end

local function flushCrateQueue()
    if crateFlushing then return end
    local net = getNet()
    if not net then return end
    if next(crateQueue) == nil then return end
    crateFlushing = true
    task.spawn(function()
        while next(crateQueue) ~= nil do
            if rawget(_G, _G_TOMB) then break end
            local id, payload = next(crateQueue)
            crateQueue[id] = nil
            crateSequence = crateSequence + 1
            payload.sequence = crateSequence
            safeSend(function()
                net.LuckyBlock.SetAutomation.send(payload)
            end)
            task.wait(0.15)
        end
        crateFlushing = false
        lastCrateSync = tick()
    end)
end

local function syncCrateAutomation()
    for _, tier in ipairs(TIER_ORDER) do
        queueCrateToggle("BuyTier", tier, Config.buyTiers[tier] == true)
    end

    for _, rarity in ipairs(RARITY_ORDER) do
        queueCrateToggle("SellRarity", rarity, Config.sellRarities[rarity] == true)
    end

    queueCrateToggle("AutoSellIncludePacks", "", true)
    queueCrateToggle("AutoSpawn", "", Config.autoSpawnCrates)
    queueCrateToggle("AutoPlace", "", Config.autoPlaceCrates)
    queueCrateToggle("AutoOpen", "", Config.autoOpenCrates)
    queueCrateToggle("AutoSell", "", Config.autoSellCrates)
    queueCrateToggle("WaitToAfford", "", true)
    queueCrateToggle("ClaimAllToBuy", "", true)
    queueCrateToggle("QuickOpen", "", true)

    flushCrateQueue()
end

local function setCratePaused(paused)
    local net = getNet()
    if not net then return end
    safeSend(function() net.LuckyBlock.SetAutomationPaused.send(paused) end)
end

local function crateWantsRun()
    return Config.autoSpawnCrates
        or Config.autoPlaceCrates
        or Config.autoOpenCrates
        or Config.autoSellCrates
end

local function applyCrateState()
    pcall(syncCrateAutomation)
    pcall(function() setCratePaused(not crateWantsRun()) end)
end

local lastPlaceCrate = 0
local placeCrateBusy = false

local function findCrateTool()
    local ch = LP:FindFirstChild("Backpack")
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and string.find(t.Name, "Lucky Crate", 1, true) then
                return t
            end
        end
    end
    local char = LP.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and string.find(t.Name, "Lucky Crate", 1, true) then
                return t
            end
        end
    end
    return nil
end

local function findOwnedPlot()
    for _, j in ipairs(CollectionService:GetTagged("Plot")) do
        if j:IsA("Model") and j:IsDescendantOf(workspace) then
            if j:GetAttribute("OwnerUserId") == LP.UserId or j:GetAttribute("Owner") == LP.Name then
                return j
            end
        end
    end
    return nil
end

local function getPlacedCratePositions(plot)
	local out = {}
	local folder = plot and plot:FindFirstChild("PlacedLuckyBlocks")
	if not folder then return out end
	for _, m in ipairs(folder:GetChildren()) do
		if m:IsA("Model") then
			local root = m:FindFirstChild("RootPart") or m.PrimaryPart
			if root then
				table.insert(out, root.Position)
			end
		end
	end
	return out
end

local function isTooCloseToPlaced(worldPos, placed, minDist)
	for _, p in ipairs(placed) do
		local d = Vector3.new(worldPos.X - p.X, 0, worldPos.Z - p.Z).Magnitude
		if d < minDist then
			return true
		end
	end
	return false
end

local function isObstructed(excludeRoot, worldPos)
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {excludeRoot, LP.Character}
    local plot = findOwnedPlot()
    if plot then
        local floor = plot:FindFirstChild("FloorTarget") or plot:FindFirstChild("FloorTarget", true)
        if floor then table.insert(exclude, floor) end
    end
    params.FilterDescendantsInstances = exclude
    local box = CFrame.new(worldPos + Vector3.new(0, 1.5, 0))
    for _, part in ipairs(workspace:GetPartBoundsInBox(box, Vector3.new(4.5, 4, 4.5), params)) do
        if part.CanCollide then
            return true
        end
        if part:FindFirstAncestor("PlacedLuckyBlocks") then
            return true
        end
    end
    return false
end

local MIN_CRATE_SPACING = 7.5

local function buildPlaceCandidates(hrp, surface, halfX, halfZ)
	local look = hrp.CFrame.LookVector
	local unit = Vector3.new(look.X, 0, look.Z)
	if unit.Magnitude < 0.001 then unit = Vector3.new(0, 0, -1) end
	unit = unit.Unit
	local right = Vector3.new(-unit.Z, 0, unit.X)
	local candidates = {}
	for ring = 1, 6 do
		local r = 4.5 + (ring - 1) * 2.4
		local steps = math.max(8, ring * 6)
		for i = 0, steps - 1 do
			local ang = (i / steps) * math.pi * 2
			local fwd = math.cos(ang) * r
			local side = math.sin(ang) * r
			local target = hrp.Position + unit * fwd + right * side
			local localPos = surface:PointToObjectSpace(target)
			if math.abs(localPos.X) <= halfX and math.abs(localPos.Z) <= halfZ then
				local worldPos = surface:PointToWorldSpace(Vector3.new(localPos.X, 0.5, localPos.Z))
				table.insert(candidates, {
					pos = worldPos,
					dist = (worldPos - hrp.Position).Magnitude,
					unit = unit,
				})
			end
		end
	end
	table.sort(candidates, function(a, b) return a.dist < b.dist end)
	return candidates
end

local function tryPlaceCrate()
    if not Config.autoPlaceCrates then return end
    if placeCrateBusy then return end
    if tick() - lastPlaceCrate < 1.2 then return end

    local net = getNet()
    local hum = getHum()
    local hrp = getHRP()
    if not net or not hum or not hrp then return end

    local plot = findOwnedPlot()
    if not plot then return end
    local floor = plot:FindFirstChild("FloorTarget") or plot:FindFirstChild("FloorTarget", true)
    if not floor or not floor:IsA("BasePart") then return end

    local tool = findCrateTool()
    if not tool then return end
    local blockId = tostring(tool:GetAttribute("LuckyBlockId") or "")
    if blockId == "" then return end

    placeCrateBusy = true
    lastPlaceCrate = tick()

    pcall(function()
        if tool.Parent ~= LP.Character then
            hum:EquipTool(tool)
            local t0 = os.clock()
            while tool.Parent ~= LP.Character and os.clock() - t0 < 1.2 do
                task.wait(0.05)
            end
        end
        if tool.Parent ~= LP.Character then return end
        task.wait(0.2)

        local surface = floor.CFrame * CFrame.new(0, floor.Size.Y * 0.5, 0)
        local halfX = math.max(0, floor.Size.X * 0.5 - 3)
        local halfZ = math.max(0, floor.Size.Z * 0.5 - 3)
        local placed = getPlacedCratePositions(plot)
        local candidates = buildPlaceCandidates(hrp, surface, halfX, halfZ)

        local result
        local conn
        conn = net.LuckyBlock.PlaceResult.listen(function(p)
            if p.blockId == blockId then
                result = p
            end
        end)

        for _, cand in ipairs(candidates) do
            if rawget(_G, _G_TOMB) then break end
            local worldPos = cand.pos
            if cand.dist <= 18
                and not isObstructed(floor, worldPos)
                and not isTooCloseToPlaced(worldPos, placed, MIN_CRATE_SPACING)
            then
                local objLook = surface:VectorToObjectSpace(cand.unit)
                local yaw = math.atan2(-objLook.X, -objLook.Z)
                result = nil
                safeSend(function()
                    net.LuckyBlock.PlaceRequest.send({blockId = blockId, position = worldPos, yaw = yaw})
                end)
                local t1 = os.clock()
                while not result and os.clock() - t1 < 2.5 do
                    if rawget(_G, _G_TOMB) then break end
                    task.wait(0.08)
                end
                if result and result.reason == "" then
                    table.insert(placed, worldPos)
                    break
                end
                if result and (result.reason == "placed_limit" or result.reason == "no_plot") then
                    break
                end
            end
        end

        pcall(function()
            if conn and type(conn) == "userdata" and conn.Disconnect then
                conn:Disconnect()
            end
        end)
        pcall(function()
            if tool.Parent == LP.Character then
                hum:UnequipTools()
            end
        end)
    end)

    placeCrateBusy = false
end

-- ========== AUTO CLEAN ==========
local cleanSession = nil
local cleanListenerReady = false
local cleanBusy = false
local cleanLastStart = 0
local cleanSprayInput = nil

local function getShineUtil()
    local ok, m = pcall(function() return require(ReplicatedStorage.Shared.Utility.CarShineUtil) end)
    return ok and m or nil
end

local function getCleaningCtrl()
    local ok, m = pcall(function()
        local ctrl = require(ReplicatedStorage.Client.UI.Systems.CleaningController)
        pcall(function() ctrl.Start() end)
        return ctrl
    end)
    return ok and m or nil
end

local function findCleaningTool()
    local ch = LP:FindFirstChild("Backpack")
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("CleaningTool") == true then
                return t
            end
        end
    end
    local char = LP.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("CleaningTool") == true then
                return t
            end
        end
    end
    return nil
end

local function findDisplayModel(carId)
    for _, j in ipairs(CollectionService:GetTagged("Plot")) do
        if j:IsA("Model") and j:IsDescendantOf(workspace)
            and (j:GetAttribute("OwnerUserId") == LP.UserId or j:GetAttribute("Owner") == LP.Name)
        then
            for _, child in ipairs(j:GetChildren()) do
                if child:IsA("Model")
                    and child:GetAttribute("CleaningDisplayCar") == true
                    and child:GetAttribute("FavoriteCarDisplay") ~= true
                    and child:GetAttribute("ClientCollectionDisplay") ~= true
                    and tostring(child:GetAttribute("CleaningCarId") or "") == tostring(carId or "")
                then
                    return child
                end
            end
        end
    end
    return nil
end

local function pickEligibleCar()
    local shine = getShineUtil()
    local c = getPlayerContainer()
    if not shine or not c then return nil end
    local ok, cars = pcall(function() return c:GetValue("Cars") end)
    if not ok or type(cars) ~= "table" then return nil end
    local slots = c:GetValue("CarSlots")
    local rebirths = c:GetValue("Rebirths")
    for id, data in pairs(cars) do
        if type(id) == "string" and type(data) == "table" then
            local okE, eligible = pcall(function()
                return shine.IsInCollection(id, slots, rebirths)
                    and shine.HasWashablePanels(data)
                    and not shine.IsCarShiny(data)
            end)
            if okE and eligible then return id end
        end
    end
    return nil
end

local function ensureCleanListener()
    if cleanListenerReady then return end
    local net = getNet()
    if not net or not net.Cleaning or not net.Cleaning.SessionState then return end
    cleanListenerReady = true
    net.Cleaning.SessionState.listen(function(p)
        if type(p) ~= "table" then return end
        local ev = tostring(p.event or "")
        if ev == "Started" then
            cleanSession = {
                mode = tostring(p.mode or "Manual"),
                carId = tostring(p.carId or ""),
                stage = tostring(p.stage or "Foam"),
                startedAt = tick(),
            }
        elseif ev == "Stage" and cleanSession then
            cleanSession.stage = tostring(p.stage or cleanSession.stage)
        elseif ev == "Completed" or ev == "Stopped" then
            cleanSession = nil
        end
    end)
end

local function faceDisplay(model)
    local hrp = getHRP()
    if not hrp or not model then return end
    local ok, pos = pcall(function()
        local cf = model:GetBoundingBox()
        return cf.Position
    end)
    if not ok or not pos then return end
    local target = Vector3.new(pos.X, hrp.Position.Y, pos.Z)
    local dist = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
    if dist > 0.5 then
        hrp.CFrame = CFrame.lookAt(hrp.Position, target)
    end
end

local function collectAimTargets(model, stage)
    local targets = {}
    if not model then return targets end
    if stage == "Rinse" then
        local foam = model:FindFirstChild("LocalCleaningFoam")
        if foam then
            for _, d in ipairs(foam:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("CleaningFoam") == true then
                    table.insert(targets, d)
                end
            end
        end
    end
    if #targets == 0 then
        local shine = getShineUtil()
        if shine then
            local ok, panels = pcall(function() return shine.GetPanels(model) end)
            if ok and type(panels) == "table" then
                for _, p in ipairs(panels) do
                    if p:IsA("BasePart") then
                        table.insert(targets, p)
                    end
                end
            end
        end
        if #targets == 0 then
            for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") and string.lower(d.Name) == "shiny" then
                    table.insert(targets, d)
                end
            end
        end
    end
    return targets
end

local function getLiveSession(ctrl)
    if not ctrl or not ctrl._BeginSprayInput then return nil end
    local ok, s = pcall(debug.getupvalue, ctrl._BeginSprayInput, 1)
    if ok and type(s) == "table" then return s end
    return nil
end

local function syncLiveClean(ctrl)
    if not ctrl or not cleanSession then return nil end
    local live = getLiveSession(ctrl)
    if live then
        cleanSession.stage = tostring(live.stage or cleanSession.stage)
        return live
    end
    return nil
end

local function ensureRinseCanQuery(model)
    if not model then return end
    local foam = model:FindFirstChild("LocalCleaningFoam")
    if not foam then return end
    for _, d in ipairs(foam:GetDescendants()) do
        if d:IsA("BasePart") and d:GetAttribute("CleaningFoam") == true
            and d:GetAttribute("CleaningRinsePending") ~= true
        then
            pcall(function() d.CanQuery = true end)
        end
    end
end

local function repairLiveSession(live, model)
    if not live then return end
    pcall(function()
        if model and (not live.model or not live.model:IsDescendantOf(workspace)) then
            live.model = model
        end
        if live.foamFolder and live.model and live.foamFolder.Parent ~= live.model
            and live.model:IsDescendantOf(workspace)
        then
            live.foamFolder.Parent = live.model
        end
        if live.ready == false and live.model and live.model:IsDescendantOf(workspace)
            and live.foamFolder and live.foamFolder.Parent == live.model
        then
            live.ready = true
        end
    end)
end

local function nearestTarget(targets, origin)
    local best, bestD
    for _, t in ipairs(targets) do
        if t.Parent then
            local d = (t.Position - origin).Magnitude
            if not bestD or d < bestD then
                best, bestD = t, d
            end
        end
    end
    return best, bestD
end

local function aimAtSurface(part)
    local cam = workspace.CurrentCamera
    if not cam or not part or not part.Parent then return false end
    local cf = part.CFrame
    local half = part.Size * 0.5
    local toCam = cam.CFrame.Position - part.Position
    local localToCam = cf:VectorToObjectSpace(toCam)
    local ax, ay, az = math.abs(localToCam.X), math.abs(localToCam.Y), math.abs(localToCam.Z)
    local margin = 0.82
    local u = (math.random() * 2 - 1) * half.X * margin
    local v = (math.random() * 2 - 1) * half.Y * margin
    local w = (math.random() * 2 - 1) * half.Z * margin
    local localPos
    if ax >= ay and ax >= az then
        localPos = Vector3.new((localToCam.X >= 0 and half.X or -half.X), v, w)
    elseif ay >= az then
        localPos = Vector3.new(u, (localToCam.Y >= 0 and half.Y or -half.Y), w)
    else
        localPos = Vector3.new(u, v, (localToCam.Z >= 0 and half.Z or -half.Z))
    end
    local vp = cam:WorldToViewportPoint(cf:PointToWorldSpace(localPos))
    if vp.Z < 0 then return false end
    local insetX, insetY = 0, 0
    pcall(function()
        local inset = game:GetService("GuiService"):GetGuiInset()
        insetX, insetY = inset.X, inset.Y
    end)
    local sx, sy = vp.X - insetX, vp.Y - insetY
    if not cleanSprayInput then
        cleanSprayInput = {
            UserInputType = Enum.UserInputType.Touch,
            Position = Vector3.new(sx, sy, 0),
            KeyCode = Enum.KeyCode.Unknown,
        }
    else
        cleanSprayInput.Position = Vector3.new(sx, sy, 0)
    end
    return true
end

local function endCleanSpray()
    if not cleanSprayInput then return end
    local ctrl = getCleaningCtrl()
    if ctrl then
        pcall(function() ctrl._EndSprayInput(cleanSprayInput) end)
        local live = getLiveSession(ctrl)
        if live and live.sprayInput == cleanSprayInput then
            pcall(function() ctrl._EndSprayInput(live.sprayInput) end)
        end
    end
    cleanSprayInput = nil
end

local function ensureSpraying(ctrl, model)
    if not ctrl then return false end
    if not cleanSprayInput then return false end
    local session = getLiveSession(ctrl)
    if not session then return false end
    repairLiveSession(session, model)
    local liveInput = session.sprayInput
    if session.spraying and liveInput == cleanSprayInput then
        pcall(function() ctrl._ChangeSprayInput(cleanSprayInput) end)
        return true
    end
    if liveInput and liveInput ~= cleanSprayInput then
        pcall(function() ctrl._EndSprayInput(liveInput) end)
    elseif liveInput == cleanSprayInput and not session.spraying then
        pcall(function() ctrl._EndSprayInput(cleanSprayInput) end)
    end
    pcall(function() ctrl._BeginSprayInput(cleanSprayInput) end)
    session = getLiveSession(ctrl)
    if session and session.spraying and session.sprayInput == cleanSprayInput then
        return true
    end
    return session and session.spraying == true
end

local function approachModel(model)
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum or not model then return end
    local ok, pos = pcall(function()
        local cf = model:GetBoundingBox()
        return cf.Position
    end)
    if not ok or not pos then return end
    local flat = Vector3.new(pos.X - hrp.Position.X, 0, pos.Z - hrp.Position.Z)
    if flat.Magnitude > 11 then
        local dest = Vector3.new(pos.X - flat.Unit.X * 8, hrp.Position.Y, pos.Z - flat.Unit.Z * 8)
        hum:MoveTo(dest)
        local t0 = tick()
        while tick() - t0 < 3 do
            if rawget(_G, _G_TOMB) then return end
            local d = (Vector3.new(pos.X - hrp.Position.X, 0, pos.Z - hrp.Position.Z)).Magnitude
            if d <= 11 then break end
            task.wait(0.1)
        end
    end
    faceDisplay(model)
end

local function runManualClean()
    local ctrl = getCleaningCtrl()
    if not ctrl or not cleanSession then return end

    local tool, model
    local t0 = tick()
    while tick() - t0 < 15 and cleanSession and Config.autoClean do
        if rawget(_G, _G_TOMB) then return end
        tool = findCleaningTool()
        model = findDisplayModel(cleanSession.carId)
        if tool and model then break end
        task.wait(0.3)
    end
    if not tool or not model or not cleanSession then return end

    local hum = getHum()
    if not hum then return end
    if tool.Parent ~= LP.Character then
        hum:EquipTool(tool)
        local t1 = tick()
        while tool.Parent ~= LP.Character and tick() - t1 < 2 do
            task.wait(0.05)
        end
    end
    if tool.Parent ~= LP.Character then return end

    approachModel(model)
    task.wait(0.3)

    while cleanSession and Config.autoClean do
        if rawget(_G, _G_TOMB) then break end

        syncLiveClean(ctrl)
        repairLiveSession(getLiveSession(ctrl), model)

        local equipped = findCleaningTool()
        if not equipped then break end
        if equipped.Parent ~= LP.Character then
            hum:EquipTool(equipped)
            task.wait(0.3)
        end

        if not model.Parent then
            model = findDisplayModel(cleanSession.carId)
            if not model then break end
            approachModel(model)
        end

        if cleanSession.stage == "Rinse" then
            ensureRinseCanQuery(model)
        end

        local targets = collectAimTargets(model, cleanSession.stage)
        if #targets == 0 then
            if not cleanSprayInput then
                local hrp = getHRP()
                if hrp then
                    local cf = model:GetBoundingBox()
                    local cam = workspace.CurrentCamera
                    if cam then
                        local vp = cam:WorldToViewportPoint(cf.Position)
                        if vp.Z > 0 then
                            local insetX, insetY = 0, 0
                            pcall(function()
                                local inset = game:GetService("GuiService"):GetGuiInset()
                                insetX, insetY = inset.X, inset.Y
                            end)
                            cleanSprayInput = {
                                UserInputType = Enum.UserInputType.Touch,
                                Position = Vector3.new(vp.X - insetX, vp.Y - insetY, 0),
                                KeyCode = Enum.KeyCode.Unknown,
                            }
                        end
                    end
                end
            end
            ensureSpraying(ctrl, model)
            task.wait(0.15)
        else
            local hrp = getHRP()
            local origin = hrp and hrp.Position or Vector3.zero
            local part
            if cleanSession.stage == "Rinse" then
                part = nearestTarget(targets, origin)
                if part then
                    local d = (part.Position - origin).Magnitude
                    if d > 14 then
                        local flat = Vector3.new(part.Position.X - origin.X, 0, part.Position.Z - origin.Z)
                        if flat.Magnitude > 0.5 and hum then
                            local dest = Vector3.new(
                                part.Position.X - flat.Unit.X * 7,
                                origin.Y,
                                part.Position.Z - flat.Unit.Z * 7
                            )
                            hum:MoveTo(dest)
                            task.wait(0.12)
                        end
                        faceDisplay(model)
                    end
                end
            else
                part = targets[math.random(1, #targets)]
            end
            if part and part.Parent and aimAtSurface(part) and cleanSprayInput then
                ensureSpraying(ctrl, model)
            else
                ensureSpraying(ctrl, model)
            end
        end

        task.wait(0.05)
    end

    endCleanSpray()
end

local function tryStartClean()
    if cleanBusy then return end
    if cleanSession then
        if Config.autoClean and cleanSession.mode == "Manual" then
            cleanBusy = true
            pcall(runManualClean)
            cleanBusy = false
        end
        return
    end
    if tick() - cleanLastStart < 5 then return end

    local net = getNet()
    if not net then return end
    ensureCleanListener()
    getCleaningCtrl()

    local carId = pickEligibleCar()
    if not carId then return end

    cleanBusy = true
    cleanLastStart = tick()

    safeSend(function()
        net.Cleaning.RequestStart.send({mode = "Auto", carId = carId})
    end)
    local t0 = tick()
    while tick() - t0 < 2.5 and not cleanSession and Config.autoClean do
        if rawget(_G, _G_TOMB) then break end
        task.wait(0.1)
    end

    if not cleanSession and Config.autoClean then
        safeSend(function()
            net.Cleaning.RequestStart.send({mode = "Manual", carId = carId})
        end)
        t0 = tick()
        while tick() - t0 < 3 and not cleanSession and Config.autoClean do
            if rawget(_G, _G_TOMB) then break end
            task.wait(0.1)
        end
    end

    if cleanSession and Config.autoClean then
        if cleanSession.mode == "Manual" then
            pcall(runManualClean)
            while cleanSession and Config.autoClean do
                if rawget(_G, _G_TOMB) then break end
                task.wait(0.5)
                pcall(runManualClean)
            end
        else
            while cleanSession and Config.autoClean do
                if rawget(_G, _G_TOMB) then break end
                task.wait(1)
            end
        end
    end

    endCleanSpray()
    cleanBusy = false
end

local function stopAutoClean()
    Config.autoClean = false
    if cleanSession then
        local net = getNet()
        if net then
            safeSend(function() net.Cleaning.RequestStop.send({}) end)
        end
    end
    endCleanSpray()
end

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        if Config.autoClean then
            pcall(tryStartClean)
        end
        task.wait(2)
    end
end)

-- ========== AUTO RACE ==========
local raceCtrl, raceCfg, racePerform, raceSend
local raceDepsReady = false
local lastRaceLaunch = 0
local lastRaceShift = 0
local raceShiftWaitStart = nil
local lastRaceNitro = 0
local raceNitroHeld = false
local raceNitroReleaseAt = 0
local lastRaceRoundKey = nil
local NITRO_FAKE_INPUT = {UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.E}
local setNitroHeldFn = nil
local nitroAmountIdx = nil

local function resolveNitroUpvalue()
    if nitroAmountIdx then return true end
    if type(filtergc) ~= "function" then return false end
    local ok, fn = pcall(function()
        return filtergc("function", { Name = "setNitroHeld" }, true)
    end)
    if not ok or type(fn) ~= "function" then return false end
    setNitroHeldFn = fn
    for i = 1, 16 do
        local okV, v = pcall(debug.getupvalue, fn, i)
        if okV and type(v) == "number" and v >= 0 and v <= 1 then
            nitroAmountIdx = i
            return true
        end
    end
    return false
end

local function forceNitroFull()
    if not (setNitroHeldFn and nitroAmountIdx) then return end
    pcall(debug.setupvalue, setNitroHeldFn, nitroAmountIdx, 1)
end

local function resolveRaceDeps()
    if raceDepsReady then return true end
    if type(filtergc) ~= "function" then return false end
    local ok1, ctrl = pcall(function()
        return require(ReplicatedStorage.Client.UI.Systems.DragRaceController)
    end)
    local ok2, cfg = pcall(function()
        return require(ReplicatedStorage.GAMEPLAY.DragRaceConfig)
    end)
    if not ok1 or not ctrl or not ok2 or not cfg then return false end
    raceCtrl = ctrl
    raceCfg = cfg
    local okP, pfn = pcall(function()
        return filtergc("function", { Name = "performRaceInput" }, true)
    end)
    racePerform = okP and pfn or nil
    local okS, sfn = pcall(function()
        return filtergc("function", { Name = "sendInput", Constants = { "RaceInput" } }, true)
    end)
    raceSend = okS and sfn or nil
    raceDepsReady = (raceCtrl ~= nil and raceCfg ~= nil and racePerform ~= nil and raceSend ~= nil)
    return raceDepsReady
end

local function getRaceState()
    if not raceSend then return nil end
    local ok, race = pcall(debug.getupvalue, raceSend, 1)
    if ok and type(race) == "table" then return race end
    return nil
end

local function getLocalRacer(race)
    if type(race) ~= "table" or type(race.players) ~= "table" then return nil end
    for _, p in ipairs(race.players) do
        if tonumber(p.userId) == LP.UserId then return p end
    end
    return nil
end

local function releaseRaceInputs()
    if not raceCtrl then return end
    if raceNitroHeld then
        pcall(function() raceCtrl._setNitroInput(NITRO_FAKE_INPUT, false) end)
        raceNitroHeld = false
    end
    pcall(function()
        if raceCtrl._revHeld then raceCtrl._setRevHeld(false) end
    end)
end

local function tryAutoRace()
    if not (Config.autoLaunch or Config.autoShift or Config.autoNitro or Config.unlimitedNitro) then
        releaseRaceInputs()
        raceShiftWaitStart = nil
        return
    end
    if not resolveRaceDeps() then return end
    if Config.unlimitedNitro then pcall(resolveNitroUpvalue) end

    local race = getRaceState()
    if not race then
        raceShiftWaitStart = nil
        releaseRaceInputs()
        return
    end

    local racer = getLocalRacer(race)
    if not racer or racer.finishedAt or racer.active == false then
        raceShiftWaitStart = nil
        releaseRaceInputs()
        return
    end

    local phase = race.phase
    if phase ~= "Countdown" and phase ~= "Race" then
        raceShiftWaitStart = nil
        releaseRaceInputs()
        return
    end

    local now = workspace:GetServerTimeNow()
    local startAt = tonumber(race.startAt) or 0

    local roundKey = tostring(race.currentRound) .. "|" .. tostring(race.lobbyId)
    if roundKey ~= lastRaceRoundKey then
        lastRaceRoundKey = roundKey
        raceShiftWaitStart = nil
        lastRaceShift = 0
        lastRaceLaunch = 0
        lastRaceNitro = 0
    end

    local shiftOpen = racer.shiftRequired == true
    if shiftOpen and raceNitroHeld then
        pcall(function() raceCtrl._setNitroInput(NITRO_FAKE_INPUT, false) end)
        raceNitroHeld = false
    end

    if Config.autoLaunch then
        if phase == "Countdown" and now < startAt then
            pcall(function()
                if not raceCtrl._revHeld then raceCtrl._setRevHeld(true) end
            end)
        else
            pcall(function()
                if raceCtrl._revHeld then raceCtrl._setRevHeld(false) end
            end)
        end

        if racer.launched ~= true and now >= startAt then
            local t = tick()
            if t - lastRaceLaunch >= 0.04 then
                lastRaceLaunch = t
                pcall(function() racePerform(nil) end)
            end
        end
    elseif raceCtrl._revHeld then
        pcall(function() raceCtrl._setRevHeld(false) end)
    end

    if Config.autoShift then
        if shiftOpen then
            if not raceShiftWaitStart then raceShiftWaitStart = tick() end
            local gear = tonumber(racer.currentGear) or raceCtrl._normalizePredictedCurrentGear()
            gear = math.clamp(tonumber(gear) or 1, 1, #raceCfg.GearMaxSpeeds)
            local maxSpd = raceCfg.GearMaxSpeeds[gear]
            local serverRatio = tonumber(racer.gearSpeedRatio) or 0
            local predRatio = (tonumber(raceCtrl._predictedSpeed) or 0) / math.max(0.001, maxSpd)
            local ratio = serverRatio > 0 and serverRatio or predRatio
            local waited = tick() - raceShiftWaitStart
            local doShift = false
            if ratio >= raceCfg.ShiftPerfectRatio or ratio >= raceCfg.RedlineSpeedRatio then
                doShift = true
            elseif waited >= 0.85 and ratio >= raceCfg.ShiftOptimalRatio then
                doShift = true
            elseif waited >= (raceCfg.ShiftWindowSeconds or 2.6) then
                doShift = true
            end
            if doShift and tick() - lastRaceShift >= 0.12 then
                lastRaceShift = tick()
                raceShiftWaitStart = nil
                pcall(function() raceCtrl._performShiftUp() end)
            end
        else
            raceShiftWaitStart = nil
        end
    else
        raceShiftWaitStart = nil
    end

    if Config.unlimitedNitro or Config.autoNitro then
        if Config.unlimitedNitro and not shiftOpen then
            forceNitroFull()
        end

        if racer.launched ~= true then
            if raceNitroHeld then releaseRaceInputs() end
            return
        end

        local moneyUntil = math.max(
            tonumber(racer.moneyShiftUntil) or 0,
            tonumber(raceCtrl._predictedMoneyShiftUntil) or 0
        )
        local lockUntil = tonumber(racer.accelerationLockedUntil) or 0
        local unlimited = Config.unlimitedNitro == true
        local locked = now < lockUntil or now < moneyUntil

        if raceNitroHeld then
            if locked then
                pcall(function() raceCtrl._setNitroInput(NITRO_FAKE_INPUT, false) end)
                raceNitroHeld = false
            elseif not unlimited and now >= raceNitroReleaseAt then
                pcall(function() raceCtrl._setNitroInput(NITRO_FAKE_INPUT, false) end)
                raceNitroHeld = false
            end
            if raceNitroHeld then return end
        end

        if shiftOpen or locked then return end
        if not unlimited and tick() - lastRaceNitro < 0.25 then return end

        local allow = false
        if unlimited then
            forceNitroFull()
            allow = true
        else
            local amount = tonumber(racer.nitro) or 0
            allow = amount >= (raceCfg.NitroMinActivation or 0.33)
        end

        if allow then
            lastRaceNitro = tick()
            pcall(function() raceCtrl._setNitroInput(NITRO_FAKE_INPUT, true) end)
            raceNitroHeld = true
            raceNitroReleaseAt = now + (raceCfg.NitroDurationSeconds or 3)
        end
    elseif raceNitroHeld then
        releaseRaceInputs()
    end
end

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        if Config.autoLaunch or Config.autoShift or Config.autoNitro or Config.unlimitedNitro then
            pcall(tryAutoRace)
            task.wait(0.04)
        else
            task.wait(0.25)
        end
    end
end)

-- ========== AUTO QUEST ==========
local questSyncData = nil
local lastQuestClaim = 0

local function requestQuestSync()
    local net = getNet()
    if not net then return end
    safeSend(function() net.Quests.RequestSync.send({}) end)
end

local function listenQuestSync()
    local net = getNet()
    if not net then return end
    local ok = pcall(function()
        net.Quests.Sync.listen(function(data)
            if typeof(data) == "table" then
                questSyncData = data
            end
        end)
    end)
    return ok
end

local function claimCompletedQuests()
    if not questSyncData then return end
    local net = getNet()
    if not net then return end
    if tick() - lastQuestClaim < 3 then return end

    local claimed = false
    local function scanQuests(periodData, periodName)
        if not periodData or not periodData.quests then return end
        local period = periodData.period or periodName
        for id, quest in pairs(periodData.quests) do
            if type(quest) == "table" and quest.completed and not quest.claimed then
                local questId = quest.id or id
                safeSend(function()
                    net.Quests.ClaimRequest.send({period = period, questId = questId})
                end)
                claimed = true
            end
        end
    end

    scanQuests(questSyncData.daily, "Daily")
    scanQuests(questSyncData.achievements, "Achievements")

    if claimed then
        lastQuestClaim = tick()
        task.delay(2, requestQuestSync)
    end
end

-- ========== AUTO REBIRTH ==========
local lastRebirth = 0

local function tryRebirth()
    if tick() - lastRebirth < 5 then return end
    local net = getNet()
    if not net then return end

    local ok, Reb = pcall(function() return require(ReplicatedStorage.GAMEPLAY.Economy.Rebirths) end)
    if not ok then return end

    local rebirths = getRebirths()
    local cash = getCash()

    local ok2, nextLevel = pcall(function() return Reb.GetNextLevel(rebirths) end)
    if not ok2 or not nextLevel then return end

    local cost = tonumber(nextLevel.Cost) or 0
    if cash >= cost then
        lastRebirth = tick()
        safeSend(function() net.Rebirth.Request.send({version = 1}) end)
    end
end

-- ========== AUTO DAILY ==========
local lastDailyClaim = 0

local function tryClaimDaily()
    if tick() - lastDailyClaim < 10 then return end
    local net = getNet()
    if not net then return end
    for day = 1, 7 do
        safeSend(function() net.PlayerData.ClaimDailyReward.send({day = day}) end)
    end
    lastDailyClaim = tick()
end

-- ========== AUTO FREE REWARD ==========
local lastFreeReward = 0

local function tryFreeReward()
    if tick() - lastFreeReward < 60 then return end
    local net = getNet()
    if not net then return end
    lastFreeReward = tick()
    safeSend(function() net.FreeReward.LaunchRequest.send({source = "menu_closed"}) end)
    task.delay(8, function()
        local n = getNet()
        if n then
            safeSend(function() n.FreeReward.ClaimRequest.send({source = "menu_closed"}) end)
        end
    end)
end

-- ========== AUTO UPGRADES ==========
local lastUpgrade = 0
local UPGRADE_IDS = {"RollLuck", "MutationLuck", "MaxItems", "HatchTimeSpeed", "OfflineEarning", "PlayerSpeed"}

local function tryUpgrades()
    if tick() - lastUpgrade < 10 then return end
    local net = getNet()
    if not net then return end
    lastUpgrade = tick()
    for _, id in ipairs(UPGRADE_IDS) do
        safeSend(function()
            net.Upgrades.BuyRequest.send({id = id, buyAll = true})
        end)
    end
end

-- ========== MAIN LOOPS ==========
local crateWasActive = false
task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end

        local active = crateWantsRun()
        if active then
            if tick() - lastCrateSync > 30 and not crateFlushing then
                pcall(syncCrateAutomation)
            end
            pcall(function() setCratePaused(false) end)
            pcall(tryPlaceCrate)
        elseif crateWasActive then
            pcall(syncCrateAutomation)
            pcall(function() setCratePaused(true) end)
        end
        crateWasActive = active

        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end

        if Config.autoQuest then
            pcall(claimCompletedQuests)
            if tick() % 30 < 3 then pcall(requestQuestSync) end
        end

        if Config.autoRebirth then pcall(tryRebirth) end
        if Config.autoDaily then pcall(tryClaimDaily) end
        if Config.autoFreeReward then pcall(tryFreeReward) end
        if Config.autoUpgrades then pcall(tryUpgrades) end

        task.wait(3)
    end
end)

-- ========== ESP ==========
local ESPObjects = {}

local function createESP(player)
    if ESPObjects[player] then return end
    if player == LP then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 100, 100)
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = workspace
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(180, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 2000
    billboard.Enabled = false
    billboard.Parent = game:GetService("CoreGui")
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.4
    nameLabel.Parent = billboard
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 12)
    distLabel.Position = UDim2.new(0, 0, 0, 16)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 11
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0.4
    distLabel.Parent = billboard
    ESPObjects[player] = {highlight = highlight, billboard = billboard, nameLabel = nameLabel, distLabel = distLabel}
end

local function removeESP(player)
    local objs = ESPObjects[player]
    if objs then
        pcall(function() objs.highlight:Destroy() end)
        pcall(function() objs.billboard:Destroy() end)
        ESPObjects[player] = nil
    end
end

local function updateESP(player)
    if not Config.espEnabled or player == LP then removeESP(player); return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not myHRP then removeESP(player); return end
    if not ESPObjects[player] then createESP(player) end
    local objs = ESPObjects[player]
    local dist = (myHRP.Position - hrp.Position).Magnitude
    objs.highlight.Enabled = Config.espHighlight
    objs.highlight.Parent = char
    objs.billboard.Enabled = true
    objs.billboard.Adornee = hrp
    objs.nameLabel.Text = player.DisplayName or player.Name
    objs.nameLabel.Visible = Config.espNames
    objs.distLabel.Text = math.floor(dist) .. "m"
    objs.distLabel.Visible = Config.espDistance
end

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        task.wait(0.2)
        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                pcall(updateESP, player)
            end
        end)
    end
end)

-- ========== UI ==========
local OxidelibUrl = "https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"
local Library = loadstring(game:HttpGet(OxidelibUrl))()
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Dream Car Collection",
    Title = "Exlumiaa Hub",
    Logo = 72522294315389,
    Folder = "exlumia",
    ToggleKey = Enum.KeyCode.RightShift,
    AllowMultiple = false,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Dream Car Collection",
    LoadingFooter = "by Exlumiaa Hub",
    StatusText = "Exlumiaa Hub ready",
    GuiName = "ExlumiaaHub",
})

local MainTab = Window:AddTab({Name = "Main", Icon = "agriculture", Subtitle = "Main Features"})
local PlayerTab = Window:AddTab({Name = "Player", Icon = "person", Subtitle = "Local Player"})
local VisualTab = Window:AddTab({Name = "Visuals", Icon = "eye", Subtitle = "ESP"})
local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})

local FarmSub = MainTab:AddSubTab("Crate Farm")
local RaceSub = MainTab:AddSubTab("Race")
local CleaningSub = MainTab:AddSubTab("Cleaning")
local RewardsSub = MainTab:AddSubTab("Rewards")
RaceSub:AddSection("Race Automation")
RaceSub:AddToggle({Name = "Auto Launch", Description = "Rev hold + perfect launch", Default = false, Callback = function(v)
    Config.autoLaunch = v
    if not v then pcall(function()
        if raceCtrl and raceCtrl._revHeld then raceCtrl._setRevHeld(false) end
    end) end
end})
RaceSub:AddToggle({Name = "Auto Shift", Description = "Ideal-timed gear shifts", Default = false, Callback = function(v)
    Config.autoShift = v
    if not v then raceShiftWaitStart = nil end
end})
RaceSub:AddToggle({Name = "Auto Nitro", Description = "Auto nitro when ready", Default = false, Callback = function(v)
    Config.autoNitro = v
    if not v then pcall(releaseRaceInputs) end
end})
RaceSub:AddToggle({Name = "Unlimited Nitro", Description = "Force full nitro, no drain", Default = false, Callback = function(v)
    Config.unlimitedNitro = v
    if v then pcall(resolveNitroUpvalue) else pcall(releaseRaceInputs) end
end})

FarmSub:AddSection("Auto Spawn")
FarmSub:AddToggle({Name = "Auto Spawn Crates", Default = false, Callback = function(v)
    Config.autoSpawnCrates = v
    applyCrateState()
end})
local defaultBuy = {}
for _, tier in ipairs(TIER_ORDER) do
    if Config.buyTiers[tier] then
        defaultBuy[#defaultBuy + 1] = tier
    end
end
FarmSub:AddMultiDropdown({
    Name = "Crates to Buy",
    Description = "Pick crate tiers to auto-buy",
    Options = TIER_ORDER,
    Default = defaultBuy,
    Searchable = false,
    MaxVisible = 6,
    Callback = function(sel)
        local picked = {}
        if type(sel) == "table" then
            for _, tier in ipairs(sel) do
                picked[tier] = true
            end
        end
        for _, tier in ipairs(TIER_ORDER) do
            Config.buyTiers[tier] = picked[tier] == true
        end
        if crateWantsRun() then pcall(syncCrateAutomation) end
    end,
})

FarmSub:AddSection("Auto Place / Open")
FarmSub:AddToggle({Name = "Auto Place Crates", Default = false, Callback = function(v)
    Config.autoPlaceCrates = v
    applyCrateState()
end})
FarmSub:AddToggle({Name = "Auto Open Crates", Default = false, Callback = function(v)
    Config.autoOpenCrates = v
    applyCrateState()
end})

FarmSub:AddSection("Auto Sell")
FarmSub:AddToggle({Name = "Auto Sell Crates", Default = false, Callback = function(v)
    Config.autoSellCrates = v
    applyCrateState()
end})
local defaultSell = {}
for _, rarity in ipairs(RARITY_ORDER) do
    if Config.sellRarities[rarity] then
        defaultSell[#defaultSell + 1] = rarity
    end
end
FarmSub:AddMultiDropdown({
    Name = "Sell Rarities",
    Description = "Pick rarities to auto-sell",
    Options = RARITY_ORDER,
    Default = defaultSell,
    Searchable = false,
    MaxVisible = 6,
    Callback = function(sel)
        local picked = {}
        if type(sel) == "table" then
            for _, rarity in ipairs(sel) do
                picked[rarity] = true
            end
        end
        for _, rarity in ipairs(RARITY_ORDER) do
            Config.sellRarities[rarity] = picked[rarity] == true
        end
        if crateWantsRun() then pcall(syncCrateAutomation) end
    end,
})

RewardsSub:AddSection("Auto Rewards")
RewardsSub:AddToggle({Name = "Auto Rebirth", Default = false, Callback = function(v) Config.autoRebirth = v end})
RewardsSub:AddToggle({Name = "Auto Claim Quests", Default = false, Callback = function(v)
    Config.autoQuest = v; if v then pcall(requestQuestSync); pcall(listenQuestSync) end
end})
RewardsSub:AddToggle({Name = "Auto Daily Reward", Default = false, Callback = function(v) Config.autoDaily = v end})
RewardsSub:AddToggle({Name = "Auto Free Reward", Default = false, Callback = function(v) Config.autoFreeReward = v end})
RewardsSub:AddToggle({Name = "Auto Buy Upgrades", Default = false, Callback = function(v) Config.autoUpgrades = v end})

CleaningSub:AddSection("Cleaning")
CleaningSub:AddToggle({Name = "Auto Clean", Description = "Clean shiny cars for gems", Default = false, Callback = function(v)
    if v then
        Config.autoClean = true
    else
        stopAutoClean()
    end
end})

local PlayerSub = PlayerTab:AddSubTab("Movement")
PlayerSub:AddSection("Speed")
PlayerSub:AddToggle({Name = "WalkSpeed", Default = false, Callback = function(v)
    Config.walkSpeedEnabled = v; local hum = getHum() if hum then hum.WalkSpeed = v and Config.walkSpeed or 16 end
end})
PlayerSub:AddSlider({Name = "Speed Value", Min = 16, Max = 200, Default = 16, Rounding = 0, Callback = function(v)
    Config.walkSpeed = v; if Config.walkSpeedEnabled then local hum = getHum() if hum then hum.WalkSpeed = v end end
end})
PlayerSub:AddSection("Jump")
PlayerSub:AddToggle({Name = "JumpPower", Default = false, Callback = function(v)
    Config.jumpPowerEnabled = v; local hum = getHum() if hum then hum.UseJumpPower = true; hum.JumpPower = v and Config.jumpPower or 50 end
end})
PlayerSub:AddSlider({Name = "Jump Value", Min = 50, Max = 200, Default = 50, Rounding = 0, Callback = function(v)
    Config.jumpPower = v; if Config.jumpPowerEnabled then local hum = getHum() if hum then hum.UseJumpPower = true; hum.JumpPower = v end end
end})

local ESPSub = VisualTab:AddSubTab("ESP")
ESPSub:AddSection("Players")
ESPSub:AddToggle({Name = "ESP Enabled", Default = false, Callback = function(v)
    Config.espEnabled = v; if not v then for _, objs in pairs(ESPObjects) do objs.highlight.Enabled = false; objs.billboard.Enabled = false end end
end})
ESPSub:AddToggle({Name = "Show Names", Default = true, Callback = function(v) Config.espNames = v end})
ESPSub:AddToggle({Name = "Show Distance", Default = true, Callback = function(v) Config.espDistance = v end})
ESPSub:AddToggle({Name = "Show Highlight", Default = true, Callback = function(v) Config.espHighlight = v end})

local SettingsSub = SettingsTab:AddSubTab("Config")
SettingsSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = SettingsSub:AddDropdown({Name = "Saved Configs", Options = {}, Default = "", Flag = "cfg_sel", Callback = function(v) selectedConfig = v end})
local function refreshConfigList() local c = Library:ListConfigs() if configDropdown then configDropdown:SetOptions(c); configDropdown:Refresh() end end
local configInput = SettingsSub:AddInput({Name = "Config Name", Default = "", Placeholder = "Enter config name...", Flag = "cfg_name"})
SettingsSub:AddDivider()
SettingsSub:AddButton({Name = "Save Config", Primary = true, Callback = function()
    local name = configInput:Get() if not name or name == "" then Window:Notify({Title="Config",Content="Enter a name!",Type="warning",Duration=3}) return end
    if Library:SaveConfig(name) then refreshConfigList(); Window:Notify({Title="Config",Content="Saved: "..name,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end})
SettingsSub:AddButton({Name = "Load Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then Window:Notify({Title="Config",Content="Select config!",Type="warning",Duration=3}) return end
    if Library:LoadConfig(selectedConfig) then refreshConfigList(); Window:Notify({Title="Config",Content="Loaded: "..selectedConfig,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end})
SettingsSub:AddButton({Name = "Delete Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then return end
    Library:DeleteConfig(selectedConfig); local old = selectedConfig; selectedConfig = ""; refreshConfigList()
    Window:Notify({Title="Config",Content="Deleted: "..old,Type="info",Duration=3})
end})

local ServerSub = SettingsTab:AddSubTab("Server")
ServerSub:AddSection("Server")
ServerSub:AddButton({Name = "Server Hop", Primary = true, Callback = function()
    Window:Notify({Title="Server Hop",Content="Finding new server...",Type="info",Duration=3})
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
end})

task.spawn(function()
    local function scrub(root)
        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("TextLabel") then
                local t = v.Text
                if t:find("Oxidelib is ready") or t:find("Exlumiaa Hub is ready") then
                    v.Text = ""
                elseif t == "Oxidelib" then
                    v.Text = "Exlumiaa Hub"
                elseif t:find("Oxidelib") then
                    v.Text = (t:gsub("Oxidelib", "Exlumiaa Hub"))
                end
            end
        end
    end
    for _ = 1, 20 do
        task.wait(0.5)
        pcall(function() scrub(game:GetService("CoreGui")) end)
        pcall(function()
            local pg = LP:FindFirstChild("PlayerGui")
            if pg then scrub(pg) end
        end)
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        if Config.walkSpeedEnabled then hum.WalkSpeed = Config.walkSpeed end
        if Config.jumpPowerEnabled then hum.UseJumpPower = true; hum.JumpPower = Config.jumpPower end
    end
end)

Players.PlayerRemoving:Connect(function(player) removeESP(player) end)
pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)
pcall(listenQuestSync)

print("[Dream Car Collection Hub] Loaded!")