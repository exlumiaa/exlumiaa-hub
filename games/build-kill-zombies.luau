if tostring(game.GameId) ~= "10741654282" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local STATE = rawget(_G, "STATE") or (type(getgenv) == "function" and rawget(getgenv(), "STATE") or nil)

local _G_TOMB = "_ _bkzTomb"
local _G_ALIVE = "_ _bkzAlive"
local _G_GEN = "_ _bkzGen"
local _G_GUI = "_ _bkzGui"

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
local function onSignal(signal, fn)
    if STATE and type(STATE.connect) == "function" then
        STATE.connect(signal, fn)
    else
        signal:Connect(fn)
    end
end

-- ================================================================

-- ================================================================
-- CONFIG
-- ================================================================
local Config = {
    speedBoost = false,
    speedValue = 4,
    noFuel = false,
    autoDrive = false,
    autoDriveSpeed = 100,
    teleportToCar = false,
    damageBoost = false,
    damageValue = 5,
    healthBoost = false,
    healthValue = 500,
    autoCrush = false,
    fuelCollect = false,
    espEnabled = false,
    espBox = true,
    espName = true,
    espDistance = true,
    espMaxDist = 400,
    autoSkill = false,
    autoQuest = false,
    autoBoss = false,
}

-- ================================================================
-- HELPERS
-- ================================================================
local function myCar()
    local cars = workspace:FindFirstChild("Cars")
    if not cars then return nil end
    for _, c in ipairs(cars:GetChildren()) do
        if c:GetAttribute("OwnerUserId") == LP.UserId then return c end
    end
    return nil
end

local function carChassis(car)
    if not car then return nil end
    return car:FindFirstChild("Chassis") or car.PrimaryPart
end

local Packets = nil
do
    local ok, res = pcall(function()
        return require(ReplicatedStorage.Packages.Packets)
    end)
    Packets = ok and res or nil
end

local function runAxisOf(car)
    if not car then return Vector3.new(1, 0, 0) end
    local ax = car:GetAttribute("RunAxis")
    if type(ax) == "Vector3" and ax.Magnitude > 0 then
        return ax.Unit
    end
    return Vector3.new(1, 0, 0)
end

local function spawnCar()
    if not Packets then return false, "Packets unavailable" end
    pcall(function() Packets.SpawnCar:Fire() end)
    local t = tick()
    while tick() - t < 5 do
        if myCar() then return true end
        task.wait(0.2)
    end
    return false, "Car did not spawn"
end

local function despawnCar()
    if not Packets then return false, "Packets unavailable" end
    pcall(function() Packets.DespawnCar:Fire() end)
    return true
end

-- ================================================================
-- CAR STATS
-- ================================================================
local baseAttrs = nil

-- TopSpeed, Accel and Turn are recomputed by the server from the placed parts,
-- so writing them is pointless. DragFactor is NOT recomputed and is the real
-- speed cap multiplier (cap = TopSpeed * DragFactor * MiniEventsConfig.SpeedMult).
local function applyCarStats()
    local car = myCar()
    if not car then
        baseAttrs = nil
        return
    end
    if not baseAttrs then
        baseAttrs = { DragFactor = car:GetAttribute("DragFactor") }
    end

    if Config.speedBoost then
        car:SetAttribute("DragFactor", Config.speedValue)
    elseif baseAttrs.DragFactor ~= nil then
        car:SetAttribute("DragFactor", baseAttrs.DragFactor)
    else
        car:SetAttribute("DragFactor", nil)
    end

    if Config.noFuel then
        car:SetAttribute("Fuel", 15)
        car:SetAttribute("NitroFuel", 1)
        car:SetAttribute("FuelFrozen", false)
    end

    if Config.damageBoost then
        car:SetAttribute("TotalDamageExtra", Config.damageValue)
    end

    if Config.healthBoost then
        car:SetAttribute("TotalHealthExtra", Config.healthValue)
    end
end

-- ================================================================
-- PACKETS
-- ================================================================
local function getPackets()
    local ok, p = pcall(function() return require(ReplicatedStorage.Packages.Packets) end)
    return ok and p or nil
end

-- ================================================================
-- ZOMBIES
-- ================================================================
local function zombieFolder()
    return workspace:FindFirstChild("ClientZombies")
end

local function eachZombie(fn)
    local f = zombieFolder()
    if not f then return end
    for _, z in ipairs(f:GetChildren()) do
        if z:IsA("Model") then
            local root = z:FindFirstChild("HumanoidRootPart")
            if root then fn(z, root) end
        end
    end
end

local function nearestZombie(fromPos, maxDist)
    local best, bestDist = nil, maxDist or math.huge
    eachZombie(function(z, root)
        local d = (root.Position - fromPos).Magnitude
        if d < bestDist then
            best, bestDist = z, d
        end
    end)
    return best, bestDist
end

-- ================================================================
-- FUEL (boss fight only)
-- ================================================================
local fuelTargets = {}

local function onFuelSpawned(id, pos)
    fuelTargets[id] = pos
end

local function onFuelRemoved(id)
    fuelTargets[id] = nil
end

local function nearestFuel(fromPos, maxDist)
    local bestId, bestPos, bestDist = nil, nil, maxDist or math.huge
    for id, pos in pairs(fuelTargets) do
        local d = (pos - fromPos).Magnitude
        if d < bestDist then
            bestId, bestPos, bestDist = id, pos, d
        end
    end
    return bestId, bestPos, bestDist
end

-- ================================================================
-- AUTO DRIVE
-- ================================================================
local autoDriveConn = nil

local function stopAutoDrive()
    if autoDriveConn then
        pcall(function() autoDriveConn:Disconnect() end)
        autoDriveConn = nil
    end
end

local driveActive = false

local function driveWanted()
    return Config.autoDrive or Config.autoCrush or Config.fuelCollect
end

local function startAutoDrive()
    stopAutoDrive()
    driveActive = true
    autoDriveConn = RunService.Heartbeat:Connect(function()
        if isTomb() then
            stopAutoDrive()
            return
        end
        if not driveWanted() then
            stopAutoDrive()
            return
        end
        local car = myCar()
        local chassis = carChassis(car)
        if not chassis then return end
        local pos = chassis.Position
        local speed = Config.autoDriveSpeed

        -- the server clamps velocity to TopSpeed * DragFactor, so lift the
        -- cap while driving or the car gets stopped dead every frame
        local topSpeed = tonumber(car:GetAttribute("TopSpeed")) or 24
        local needed = speed / math.max(1, topSpeed)
        if (tonumber(car:GetAttribute("DragFactor")) or 0) < needed then
            car:SetAttribute("DragFactor", needed + 1)
        end

        -- fuel pickups only exist during a boss fight, so they win over everything
        if Config.fuelCollect then
            local _, fuelPos = nearestFuel(pos, 800)
            if fuelPos then
                local dir = (fuelPos - pos)
                if dir.Magnitude > 0.01 then
                    chassis.AssemblyLinearVelocity = dir.Unit * speed
                end
                return
            end
        end

        if Config.autoCrush then
            local _, zDist = nearestZombie(pos, 200)
            if zDist then
                chassis.AssemblyLinearVelocity = runAxisOf(car) * speed
                return
            end
        end

        chassis.AssemblyLinearVelocity = runAxisOf(car) * speed
    end)
end

local function syncAutoDrive()
    if driveWanted() then
        if not driveActive then startAutoDrive() end
    else
        if driveActive then stopAutoDrive() end
    end
end

-- ================================================================
-- ESP
-- ================================================================
local espObjects = {}

local function clearESP()
    for k, v in pairs(espObjects) do
        pcall(function() v.Parent = nil end)
    end
    espObjects = {}
end

local function updateESP()
    if not Config.espEnabled then
        if next(espObjects) then clearESP() end
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local live = {}

    eachZombie(function(z, root)
        local screen, onScreen = cam:WorldToViewportPoint(root.Position)
        if onScreen and screen.Z > 0 then
            local dist = (root.Position - cam.CFrame.Position).Magnitude
            if dist <= Config.espMaxDist then
                live[z] = true
                local entry = espObjects[z]
                if not entry then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ExlumiaaESP"
                    bb.Adornee = root
                    bb.Size = UDim2.fromOffset(200, 40)
                    bb.StudsOffset = Vector3.new(0, 3.2, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = Config.espMaxDist + 100
                    bb.Parent = z
                    local name = Instance.new("TextLabel")
                    name.Name = "Name"
                    name.Size = UDim2.fromScale(1, 0.5)
                    name.BackgroundTransparency = 1
                    name.Font = Enum.Font.GothamBold
                    name.TextSize = 13
                    name.TextColor3 = Color3.fromRGB(255, 90, 90)
                    name.TextStrokeTransparency = 0.4
                    name.Text = ""
                    name.Parent = bb
                    local distL = Instance.new("TextLabel")
                    distL.Name = "Dist"
                    distL.Size = UDim2.fromScale(1, 0.5)
                    distL.Position = UDim2.fromScale(0, 0.5)
                    distL.BackgroundTransparency = 1
                    distL.Font = Enum.Font.Gotham
                    distL.TextSize = 12
                    distL.TextColor3 = Color3.fromRGB(255, 220, 120)
                    distL.TextStrokeTransparency = 0.4
                    distL.Text = ""
                    distL.Parent = bb
                    local hl = Instance.new("Highlight")
                    hl.Name = "ExlumiaaHL"
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(255, 70, 70)
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = z
                    entry = { bb = bb, name = name, dist = distL, hl = hl }
                    espObjects[z] = entry
                end
                entry.name.Text = Config.espName and z.Name or ""
                entry.dist.Text = Config.espDistance and ("%.0f studs"):format(dist) or ""
                entry.hl.Enabled = Config.espBox
            end
        end
    end)

    for k in pairs(espObjects) do
        if not live[k] then
            pcall(function() espObjects[k].bb:Destroy() end)
            pcall(function() espObjects[k].hl:Destroy() end)
            espObjects[k] = nil
        end
    end
end

-- ================================================================
-- AUTOMATION
-- ================================================================
local lastSkillSync = 0
local lastQuestSync = 0
local lastBoss = 0
local questState = nil
local skillState = nil
local currentConfig = "default"

local function skillById()
    local ok, cfg = pcall(function() return require(ReplicatedStorage.Shared.Data.SkillConfig) end)
    if not ok or not cfg then return nil end
    return cfg.ById
end

local function ownedSet()
    local set = {}
    if type(skillState) == "string" then
        local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(skillState) end)
        if ok and type(decoded) == "table" then
            for _, v in ipairs(decoded) do set[tostring(v)] = true end
        end
    end
    return set
end

local function cashValue()
    local ls = LP:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local cv = ls:FindFirstChild("💵 Cash") or ls:FindFirstChild("Cash")
    return tonumber(cv and cv.Value) or 0
end

local function trySkills()
    local P = getPackets()
    if not P then return end
    if tick() - lastSkillSync > 20 then
        lastSkillSync = tick()
        pcall(function() P.RequestSkills:Fire() end)
        task.wait(0.5)
    end
    local byId = skillById()
    if type(byId) ~= "table" then return end
    local owned = ownedSet()
    local cash = cashValue()

    -- cheapest first so the parent chain unlocks in order
    local queue = {}
    for _, s in pairs(byId) do
        if type(s) == "table" and type(s.Id) == "string" then
            local id = s.Id
            local cost = tonumber(s.Cost) or 0
            local parent = type(s.Parent) == "string" and s.Parent or ""
            -- skip the skill-tree layout nodes, they are not purchasable
            local isNode = not (string.match(id, "_root$") or string.match(id, "_portal$")
                or s.Title == "Back" or s.Title == "Start")
            if isNode and not owned[id] and cost <= cash and (parent == "" or owned[parent]) then
                queue[#queue + 1] = { id = id, cost = cost }
            end
        end
    end
    table.sort(queue, function(a, b) return a.cost < b.cost end)

    for _, item in ipairs(queue) do
        if tick() - lastSkillSync > 8 then break end
        owned[item.id] = true
        pcall(function() P.BuySkill:Fire(item.id) end)
        task.wait(0.4)
    end
end

local function questConfig()
    local ok, cfg = pcall(function() return require(ReplicatedStorage.Shared.Data.QuestConfig) end)
    if not ok or not cfg then return nil end
    return cfg.Quests
end

local function tryQuests()
    local P = getPackets()
    if not P then return end
    if tick() - lastQuestSync > 10 then
        lastQuestSync = tick()
        pcall(function() P.RequestQuests:Fire() end)
        task.wait(0.5)
    end
    if type(questState) ~= "string" then return end
    local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(questState) end)
    if not ok or type(data) ~= "table" then return end
    local quests = questConfig()
    if type(quests) ~= "table" then return end

    local claimed = {}
    for _, v in pairs(data.Claimed or {}) do claimed[tostring(v)] = true end
    local progress = data.Progress or {}

    -- QuestConfig Stat names map to lowercase keys in the progress payload
    for _, q in ipairs(quests) do
        if type(q) == "table" and type(q.Id) == "string" and not claimed[q.Id] then
            local stat = string.lower(tostring(q.Stat or ""))
            local have = tonumber(progress[stat]) or 0
            local goal = tonumber(q.Goal) or math.huge
            if have >= goal then
                pcall(function() P.ClaimQuest:Fire(q.Id) end)
                claimed[q.Id] = true
                task.wait(0.4)
            end
        end
    end
end

local function tryBoss()
    if not Config.autoBoss then return end
    local P = getPackets()
    if not P then return end
    if tick() - lastBoss < 20 then return end
    lastBoss = tick()
    pcall(function() P.BossSync:Fire() end)
end

-- ================================================================
-- SIGNAL WIRING
-- ================================================================
task.spawn(function()
    local P = getPackets()
    if not P then return end
    local function link(packet, fn)
        pcall(function()
            if packet and packet.OnClientEvent then
                packet.OnClientEvent:Connect(fn)
            end
        end)
    end
    link(P.FuelSpawned, onFuelSpawned)
    link(P.FuelRemoved, onFuelRemoved)
    link(P.FuelCollected, onFuelRemoved)
    link(P.QuestsChanged, function(s) questState = s end)
    link(P.SkillsChanged, function(s) skillState = s end)
    link(P.ZombieDied, function() end)
    link(P.BossSpawned, function()
        if Config.autoBoss then
            task.delay(2, function()
                local pk = getPackets()
                if pk then pcall(function() pk.JoinBattle:Fire() end) end
            end)
        end
    end)
end)

task.spawn(function()
    while true do
        if isTomb() then break end
        task.wait(0.1)
        pcall(updateESP)
    end
end)

task.spawn(function()
    while true do
        if isTomb() then break end
        if Config.autoSkill then pcall(trySkills) end
        if Config.autoQuest then pcall(tryQuests) end
        if Config.autoBoss then pcall(tryBoss) end
        pcall(syncAutoDrive)
        task.wait(1)
    end
end)

-- ================================================================
-- MAIN LOOP
-- ================================================================
task.spawn(function()
    while true do
        if isTomb() then break end
        pcall(applyCarStats)
        task.wait(0.1)
    end
end)

-- ================================================================
-- TELEPORT
-- ================================================================
local function teleportToCar()
    local car = myCar()
    local chassis = carChassis(car)
    if not chassis then return false, "No car deployed" end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then return true end
    local seat = nil
    if car then
        for _, d in ipairs(car:GetDescendants()) do
            if d:IsA("Seat") then
                seat = d
                break
            end
        end
    end
    if not seat then return false, "No seat found" end
    local cf = seat.CFrame * CFrame.new(0, 3, 0)
    local ok, err = pcall(function()
        hum.Sit = true
        hum:MoveTo(cf.Position)
        hum.SeatPart = seat
    end)
    if not ok then return false, tostring(err) end
    return true
end

local function teleportToOrigin()
    local car = myCar()
    local chassis = carChassis(car)
    if not chassis then return false, "No car deployed" end
    local origin = car:GetAttribute("RunOrigin")
    if type(origin) ~= "Vector3" then return false, "No RunOrigin" end
    local target = origin + Vector3.new(0, 3, 0)
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        pcall(function() hum.Sit = false end)
    end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false, "No character" end
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(target)
    end)
    return true
end


-- ================================================================
-- UI â€” Oxidelib
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

Library.ConfigFolder = "exlumiaa/bkillzombies"

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

Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Build and Kill Zombies",
    Size = UDim2.fromOffset(700, 490),
    Scale = 1.1,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Build and Kill Zombies",
    LoadingFooter = "by Exlumiaa Hub",
    StatusText = "Exlumiaa Hub is ready",
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


-- ================================================================
-- SERVER HOP
-- ================================================================
local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    local ok, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if ok and result then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(result) end)
        if decodeOk and data and data.data then
            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        end
    end
    if #servers > 0 then
        local target = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, target, LP)
    else
        TeleportService:Teleport(placeId)
    end
end

-- ================================================================

-- ================================================================
-- UI TABS
-- ================================================================
local HomeTab = Window:AddTab({ Name = "Home", Icon = "home", Subtitle = "Info" })
local InfoSub = HomeTab:AddSubTab("Info")
autosaveWrap(InfoSub)

InfoSub:AddSection("Player")
local labelHealth = InfoSub:AddLabel({ Text = "Health: -" })
local labelPos = InfoSub:AddLabel({ Text = "Pos: -" })
local labelCash = InfoSub:AddLabel({ Text = "Cash: -" })
local labelDistance = InfoSub:AddLabel({ Text = "Distance: -" })

InfoSub:AddSection("Car")
local labelCar = InfoSub:AddLabel({ Text = "Car: not deployed" })
local labelTopSpeed = InfoSub:AddLabel({ Text = "TopSpeed: -" })
local labelCarHealth = InfoSub:AddLabel({ Text = "Car Health: -" })
local labelFuel = InfoSub:AddLabel({ Text = "Fuel: -" })
local labelVel = InfoSub:AddLabel({ Text = "Velocity: -" })

InfoSub:AddSection("Server")
InfoSub:AddLabel({ Text = "Place: " .. tostring(game.PlaceId) })
InfoSub:AddLabel({ Text = "Job: " .. tostring(game.JobId) })
local labelPing = InfoSub:AddLabel({ Text = "Ping: --" })
local labelPlayers = InfoSub:AddLabel({ Text = "Players: --" })
InfoSub:AddLabel({ Text = "by Exlumiaa Hub" })

task.spawn(function()
    local avgMs = 0
    while true do
        task.wait(0.5)
        if isTomb() then break end
        pcall(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                labelHealth:Set("Health: " .. ("%d/%d"):format(math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5)))
            end
            if root then
                local p = root.Position
                labelPos:Set(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
            end
            local ls = LP:FindFirstChild("leaderstats")
            if ls then
                local cash = ls:FindFirstChild("💵 Cash") or ls:FindFirstChild("Cash")
                if cash then labelCash:Set("Cash: " .. tostring(cash.Value)) end
                local dist = ls:FindFirstChild("⭐ Distance") or ls:FindFirstChild("Distance")
                if dist then labelDistance:Set("Distance: " .. tostring(dist.Value)) end
            end
            local car = myCar()
            if car then
                labelCar:Set("Car: deployed")
                labelTopSpeed:Set("TopSpeed: " .. tostring(car:GetAttribute("TopSpeed")))
                labelCarHealth:Set("Car Health: " .. tostring(car:GetAttribute("CarHealth")))
                labelFuel:Set("Fuel: " .. tostring(car:GetAttribute("Fuel")))
                local ch = carChassis(car)
                labelVel:Set("Velocity: " .. (ch and ("%.0f"):format(ch.AssemblyLinearVelocity.Magnitude) or "-"))
            else
                labelCar:Set("Car: not deployed")
                labelTopSpeed:Set("TopSpeed: -")
                labelCarHealth:Set("Car Health: -")
                labelFuel:Set("Fuel: -")
                labelVel:Set("Velocity: -")
            end
            local stats = game:GetService("Stats")
            local pingItem = stats.Network.ServerStatsItem["Data Ping"]
            avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
            labelPing:Set("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
            labelPlayers:Set("Players: " .. #Players:GetPlayers())
        end)
    end
end)

-- ================================================================
-- MAIN TAB
-- ================================================================
local MainTab = Window:AddTab({ Name = "Main", Icon = "zap", Subtitle = "Cheats" })
local SpeedSub = MainTab:AddSubTab("Speed")
local CarSub = MainTab:AddSubTab("Car")

SpeedSub:AddSection("Speed Boost")
SpeedSub:AddToggle({
    Name = "Speed Boost",
    Default = Config.speedBoost,
    Flag = "bkz_speed",
    Callback = function(s)
        Config.speedBoost = s
        if not s then baseAttrs = nil end
        pcall(applyCarStats)
    end,
})
SpeedSub:AddSlider({
    Name = "Speed Multiplier",
    Min = 1,
    Max = 6,
    Default = Config.speedValue,
    Suffix = "x",
    Flag = "bkz_speedval",
    Callback = function(v)
        Config.speedValue = v
        pcall(applyCarStats)
    end,
})
SpeedSub:AddLabel({ Text = "Raises the speed cap via DragFactor" })
SpeedSub:AddLabel({ Text = "6x and above crashes the car" })

SpeedSub:AddDivider()

SpeedSub:AddSection("Auto Drive")
SpeedSub:AddToggle({
    Name = "Auto Drive",
    Default = Config.autoDrive,
    Flag = "bkz_autodrive",
    Callback = function(s)
        Config.autoDrive = s
        pcall(syncAutoDrive)
    end,
})
SpeedSub:AddSlider({
    Name = "Drive Speed",
    Min = 24,
    Max = 130,
    Default = Config.autoDriveSpeed,
    Suffix = "",
    Flag = "bkz_drivespeed",
    Callback = function(v)
        Config.autoDriveSpeed = v
    end,
})
SpeedSub:AddLabel({ Text = "Drives the car along the run axis" })
SpeedSub:AddLabel({ Text = "Above ~130 the car crashes" })

CarSub:AddSection("Car")
CarSub:AddToggle({
    Name = "No Fuel Drain",
    Default = Config.noFuel,
    Flag = "bkz_nofuel",
    Callback = function(s)
        Config.noFuel = s
    end,
})

CarSub:AddDivider()

CarSub:AddSection("Actions")
CarSub:AddButton({
    Name = "Deploy Car",
    Primary = true,
    Callback = function()
        task.spawn(function()
            local ok, err = spawnCar()
            if ok then
                notify("Car", "Car deployed", "success")
            else
                notify("Car", tostring(err), "error")
            end
        end)
    end,
})
CarSub:AddButton({
    Name = "Despawn Car",
    Callback = function()
        task.spawn(function()
            local ok, err = despawnCar()
            if ok then
                notify("Car", "Car despawned", "success")
            else
                notify("Car", tostring(err), "error")
            end
        end)
    end,
})
CarSub:AddButton({
    Name = "Teleport To Car",
    Callback = function()
        local ok, err = teleportToCar()
        if ok then
            notify("Teleport", "Teleported to car", "success")
        else
            notify("Teleport", tostring(err), "error")
        end
    end,
})
CarSub:AddButton({
    Name = "Teleport To Start",
    Callback = function()
        local ok, err = teleportToOrigin()
        if ok then
            notify("Teleport", "Teleported to start", "success")
        else
            notify("Teleport", tostring(err), "error")
        end
    end,
})
CarSub:AddLabel({ Text = "by Exlumiaa Hub" })

CarSub:AddDivider()

CarSub:AddSection("Combat")
CarSub:AddToggle({
    Name = "Damage Boost",
    Default = Config.damageBoost,
    Flag = "bkz_damage",
    Callback = function(s) Config.damageBoost = s end,
})
CarSub:AddSlider({
    Name = "Damage Multiplier",
    Min = 0,
    Max = 50,
    Default = Config.damageValue,
    Suffix = "x",
    Flag = "bkz_damageval",
    Callback = function(v) Config.damageValue = v end,
})
CarSub:AddLabel({ Text = "1 = +100% damage" })

CarSub:AddDivider()

CarSub:AddSection("Survival")
CarSub:AddToggle({
    Name = "Health Boost",
    Default = Config.healthBoost,
    Flag = "bkz_health",
    Callback = function(s) Config.healthBoost = s end,
})
CarSub:AddSlider({
    Name = "Health Extra",
    Min = 0,
    Max = 5000,
    Default = Config.healthValue,
    Suffix = "",
    Flag = "bkz_healthval",
    Callback = function(v) Config.healthValue = v end,
})

CarSub:AddDivider()

CarSub:AddSection("Auto")
CarSub:AddToggle({
    Name = "Auto Crush",
    Default = Config.autoCrush,
    Flag = "bkz_crush",
    Callback = function(s)
        Config.autoCrush = s
        pcall(syncAutoDrive)
    end,
})
CarSub:AddLabel({ Text = "Keeps the car driving through zombies" })

CarSub:AddToggle({
    Name = "Fuel Collect",
    Default = Config.fuelCollect,
    Flag = "bkz_fuel",
    Callback = function(s)
        Config.fuelCollect = s
        pcall(syncAutoDrive)
    end,
})
CarSub:AddLabel({ Text = "Chases fuel drops during boss fights" })

-- ================================================================
-- VISUALS TAB
-- ================================================================
local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local ESPSub = VisualTab:AddSubTab("Zombies")

ESPSub:AddSection("ESP")
ESPSub:AddToggle({
    Name = "Zombie ESP",
    Default = Config.espEnabled,
    Flag = "bkz_esp",
    Callback = function(s)
        Config.espEnabled = s
        if not s then pcall(clearESP) end
    end,
})
ESPSub:AddToggle({
    Name = "Box",
    Default = Config.espBox,
    Flag = "bkz_espbox",
    Callback = function(s) Config.espBox = s end,
})
ESPSub:AddToggle({
    Name = "Name",
    Default = Config.espName,
    Flag = "bkz_espname",
    Callback = function(s) Config.espName = s end,
})
ESPSub:AddToggle({
    Name = "Distance",
    Default = Config.espDistance,
    Flag = "bkz_espdist",
    Callback = function(s) Config.espDistance = s end,
})
ESPSub:AddSlider({
    Name = "Max Distance",
    Min = 50,
    Max = 1500,
    Default = Config.espMaxDist,
    Suffix = "",
    Flag = "bkz_espmax",
    Callback = function(v) Config.espMaxDist = v end,
})
ESPSub:AddLabel({ Text = "by Exlumiaa Hub" })

-- ================================================================
-- AUTOMATION TAB
-- ================================================================
local AutoTab = Window:AddTab({ Name = "Automation", Icon = "zap", Subtitle = "Auto" })
local AutoSub = AutoTab:AddSubTab("Farming")

AutoSub:AddSection("Progression")
AutoSub:AddToggle({
    Name = "Auto Buy Skills",
    Default = Config.autoSkill,
    Flag = "bkz_autoskill",
    Callback = function(s) Config.autoSkill = s end,
})
AutoSub:AddToggle({
    Name = "Auto Claim Quests",
    Default = Config.autoQuest,
    Flag = "bkz_autoquest",
    Callback = function(s) Config.autoQuest = s end,
})

AutoSub:AddDivider()

AutoSub:AddSection("Boss")
AutoSub:AddToggle({
    Name = "Auto Join Boss",
    Default = Config.autoBoss,
    Flag = "bkz_autoboss",
    Callback = function(s) Config.autoBoss = s end,
})
AutoSub:AddLabel({ Text = "by Exlumiaa Hub" })

-- ================================================================
-- SETTINGS TAB
-- ================================================================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")

ConfigSub:AddSection("Config")
ConfigSub:AddInput({
    Name = "Config Name",
    Placeholder = "default",
    Default = "default",
    Flag = "bkz_configname",
    Callback = function(v) currentConfig = (v ~= "" and v or "default") end,
})
ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        pcall(function() Library:SaveConfig(currentConfig) end)
        notify("Config", "Saved: " .. currentConfig, "success")
    end,
})
ConfigSub:AddButton({
    Name = "Load Config",
    Callback = function()
        local ok = pcall(function() Library:LoadConfig(currentConfig) end)
        notify("Config", ok and ("Loaded: " .. currentConfig) or "Load failed", ok and "success" or "error")
    end,
})
ConfigSub:AddButton({
    Name = "Delete Config",
    Callback = function()
        local ok = pcall(function() Library:DeleteConfig(currentConfig) end)
        notify("Config", ok and ("Deleted: " .. currentConfig) or "Delete failed", ok and "success" or "error")
    end,
})

ConfigSub:AddDivider()

ConfigSub:AddSection("Server")
ConfigSub:AddButton({
    Name = "Server Hop",
    Callback = function()
        notify("Server Hop", "Finding a new server...", "info")
        task.spawn(function()
            local ok, err = pcall(serverHop)
            if not ok then
                notify("Server Hop", "Failed: " .. tostring(err), "error")
            end
        end)
    end,
})
ConfigSub:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end,
})

ConfigSub:AddDivider()

ConfigSub:AddSection("About")
ConfigSub:AddLabel({ Text = "Exlumiaa Hub" })
ConfigSub:AddLabel({ Text = "Build and Kill Zombies" })
ConfigSub:AddLabel({ Text = "Place: " .. tostring(game.PlaceId) })
ConfigSub:AddLabel({ Text = "Toggle: Right Shift" })
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })


-- ================================================================
-- EVENTS / CLEANUP
-- ================================================================
local function teardown()
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_ALIVE, nil)
    pcall(stopAutoDrive)
    pcall(clearESP)
    pcall(function()
        local car = myCar()
        if car and baseAttrs then
            if baseAttrs.TopSpeed then car:SetAttribute("TopSpeed", baseAttrs.TopSpeed) end
            if baseAttrs.Accel then car:SetAttribute("Accel", baseAttrs.Accel) end
        end
        if car then
            car:SetAttribute("TotalDamageExtra", 0)
            car:SetAttribute("TotalHealthExtra", 0)
        end
    end)
    pcall(function()
        if Window and type(Window.Destroy) == "function" then
            Window:Destroy()
        end
    end)
end

if STATE and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(teardown)
end

if Config.autoDrive or Config.autoCrush or Config.fuelCollect then
    task.spawn(startAutoDrive)
end

