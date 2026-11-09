-- Exlumiaa Hub - Night Rider
-- Universe 10770284142 (place 71335623205843)
-- Verified live:
--   Drive.step(bike, state, input, dt) is the per-frame bike physics step.
--   BikeClient.forced replaces the whole input table the client sends to the
--   server (throttle, brake, steer), so it is the only place that can steer.
--   Motorcycle.Shared.Road exposes the highway spline: project(pos)->s,d,
--   point(s,d), laneD(side,lane), frame(s), half (road half width).
--   input.wheelieRate is rad/s and is added by BikeClient; overriding it steers a wheelie.
--   Config.Crash.FallOff disables wipeouts; Stunt("knock") and TrafficHit can be blocked.
--   Stunts UI fires Stunt:FireServer("wheelie", secs) by itself while a wheelie is held,
--   so a held wheelie pays without faking events.
--   Daily: Action("daily") only when GetData().daily.ready.
--   Quests: Action("claim", mode, id); mode is "daily" or "second".
--   Garage: Action("buy", bikeKey) / ("sell", bikeKey); prices from BikeCatalog.Bikes.
--   Travel: NightRiderMenu.Menu:InvokeServer("teleport", destination, true).

if tostring(game.GameId) ~= "10770284142" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _nrTomb"
local _G_ALIVE = "_ _nrAlive"
local _G_CONFIG = "_ _nrConfig"
local _G_STEP = "_ _nrStepHooked"

do
    if rawget(_G, _G_ALIVE) == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.6)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "ExlumiaaHUD") then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        for _, gui in ipairs(pg and pg:GetChildren() or {}) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "ExlumiaaHUD") then gui:Destroy() end
        end
    end)
end

local Library = nil
task.spawn(function()
    for _ = 1, 3 do
        local ok, ret = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"))()
        end)
        if ok and ret then
            Library = ret
            break
        end
        task.wait(1)
    end
end)
for _ = 1, 80 do
    if Library ~= nil then break end
    task.wait(0.25)
end
-- The menu is optional: a stalled GitHub fetch must not take auto ride down with it.
local HasUI = Library ~= nil
if not HasUI then warn("[NightRider] Oxidelib fetch failed, running without the menu") end
if HasUI then Library.ConfigFolder = "exlumiaa" end

local Config = {
    build = "1.2.0",
    autoRide = false,
    rideSpeed = 70,
    autoWheelie = true,
    wheelieTarget = 30,
    neverCrash = true,
    noBust = true,
    autoEscape = false,
    autoDaily = true,
    autoQuests = true,
    autoBuy = false,
    buyReserve = 0,
    antiAfk = true,
    hud = true,
}
rawset(_G, _G_CONFIG, Config)

local RS = ReplicatedStorage
local GameShared = RS:WaitForChild("GameShared", 20)
local Motorcycle = RS:WaitForChild("Motorcycle", 20)
if not (GameShared and Motorcycle) then return end

local Remotes = GameShared:WaitForChild("Remotes", 10)
local GetData = Remotes:FindFirstChild("GetData")
local Action = Remotes:FindFirstChild("Action")
local Stunt = Remotes:FindFirstChild("Stunt")
if not (GetData and Action and Stunt) then return end

local BikeCatalog = nil
pcall(function()
    local mod = require(GameShared:WaitForChild("BikeCatalog", 10))
    BikeCatalog = mod and mod.Bikes or mod
end)

local MotorcycleConfig = nil
pcall(function()
    MotorcycleConfig = require(Motorcycle:WaitForChild("Config", 10))
end)
local Drive = nil
pcall(function()
    Drive = require(Motorcycle.Shared:WaitForChild("Drive", 10))
end)
local Road = nil
pcall(function()
    Road = require(Motorcycle.Shared:WaitForChild("Road", 10))
end)
local BikeClient = nil
pcall(function()
    BikeClient = require(Motorcycle.Client:WaitForChild("BikeClient", 10))
end)
local Cops = nil
pcall(function()
    Cops = require(Motorcycle.Client:WaitForChild("Cops", 10))
end)

local diag = {
    road = Road ~= nil,
    bikeClient = BikeClient ~= nil,
    drive = Drive ~= nil,
    ticks = 0,
    mounted = 0,
}
rawset(_G, "_ _nrDiag", diag)

-- ================================================================
-- Helpers
-- ================================================================
local function num(v)
    v = tonumber(v)
    return type(v) == "number" and v or 0
end
local function now() return workspace:GetServerTimeNow() end
local function fired(name, ...)
    if Action then
        local args = table.pack(...)
        pcall(function() Action:InvokeServer(table.unpack(args, 1, args.n)) end)
    end
end
local function bikeState()
    if not BikeClient then return nil end
    local ok, cur = pcall(function() return BikeClient.current() end)
    if ok and cur then return cur end
    return nil
end
local function mph()
    local cur = bikeState()
    return cur and cur.state and num(cur.state.speed) * 0.62636 or 0
end

-- The bike only accelerates from real input, so hold the keys a player would.
-- Executor keypress/keyrelease die when the window loses focus; VirtualInputManager
-- still lands, but the game ignores keys while its own u196 focus flag is set.
-- Poking the WindowFocused handlers clears that flag.
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local function refocus()
    pcall(function()
        for _, c in ipairs(getconnections(UIS.WindowFocused)) do
            if type(c.Function) == "function" then pcall(c.Function) end
        end
    end)
end
local function sendKey(code, down)
    pcall(function()
        if down then refocus() end
        VIM:SendKeyEvent(down, code, false, game)
    end)
end
local holdW = false
local lastEnter = 0
local lastMountTry = 0
local lastPos = nil
local lastPosTime = 0
local function findBike()
    for _, m in ipairs(workspace:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("Owner") == LP.UserId then
            local ch = m:FindFirstChild("Chassis")
            if ch then return m, ch end
        end
    end
    return nil, nil
end
local function properlyMounted()
    local bike, ch = findBike()
    if not bike then return false end
    return bike:GetAttribute("Rider") == LP.UserId and bike:GetAttribute("Parked") ~= true
end
local function rideTick()
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    local ok = h ~= nil and h.Health > 0
    -- The menu parks the bike in its own scene until Enter. Press it for the player.
    if Config.autoRide and LP:GetAttribute("InMenu") == true and os.clock() - lastEnter > 2 then
        lastEnter = os.clock()
        sendKey(Enum.KeyCode.Return, true)
        task.delay(0.1, function() sendKey(Enum.KeyCode.Return, false) end)
    end
    -- Auto-mount: if on foot, get to the bike and fire its RidePrompt.
    if Config.autoRide and ok and LP:GetAttribute("InMenu") ~= true and not properlyMounted() then
        if os.clock() - lastMountTry > 2 then
            lastMountTry = os.clock()
            local bike, ch = findBike()
            if bike and ch then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - ch.Position).Magnitude > 50 then
                    pcall(function() hrp.CFrame = CFrame.new(ch.Position + Vector3.new(4, 2, 0)) end)
                end
                local prompt = bike:FindFirstChild("RidePrompt", true)
                if prompt then pcall(fireproximityprompt, prompt) end
            end
        end
    end
    -- Steering and throttle are written every frame in driveTick; this loop only
    -- gets the player onto the bike (Enter from the menu, RidePrompt on foot).
end

-- ================================================================
-- Auto ride: the client sends {throttle, brake, steer, ...} to the server
-- every 1/InputRate seconds, so steering only exists here. Off the highway
-- the bike merges into the near lane; on it, it holds that lane at the
-- cruise speed.
-- ================================================================
local forced = { throttle = 0, brake = 0, rear = 0, steer = 0, lean = 0, rider = true }
local rideSide = nil
local rideDir = nil
local stuckT = 0
local lastHeading = nil
local function wrapAngle(a)
    return (a + math.pi) % (2 * math.pi) - math.pi
end
local function releaseDrive()
    if BikeClient and BikeClient.forced then BikeClient.forced = nil end
    rideSide = nil
    rideDir = nil
    stuckT = 0
    lastHeading = nil
end
local function driveTick(dt)
    local dg = rawget(_G, "_ _nrDiag")
    if dg then dg.ticks = dg.ticks + 1 end
    if not (BikeClient and Road) then return end
    local cur = (rawget(_G, "_ _nrConfig") or Config).autoRide and bikeState() or nil
    local ch = cur and cur.bike and cur.bike.chassis
    if not (ch and cur.state) then
        if dg then
            dg.autoRide = Config.autoRide
            dg.reason = (not cur) and "no-current" or (not ch and "no-chassis" or "no-state")
        end
        releaseDrive()
        stuckT = 0
        return
    end
    if dg then dg.mounted = dg.mounted + 1 end

    local pos = ch.Position
    local s, d = Road.project(pos)
    local spd = math.abs(num(cur.state.speed)) * 0.62636
    local look = ch.CFrame.LookVector
    local aim, cap

    if math.abs(d) > 62 then
        -- Off the highway (spawn deck, station, grass): merge into the near
        -- outer lane. Aiming at the centreline would drive into the median.
        aim = Road.point(s, Road.laneD(d >= 0 and 1 or -1, 4))
        cap = 28
        rideSide = nil
        rideDir = nil
    else
        local _, fwd = Road.frame(s)
        if not rideDir then
            rideDir = (look.X * fwd.X + look.Z * fwd.Z) >= 0 and 1 or -1
        end
        if not rideSide then
            rideSide = d >= 0 and 1 or -1
        end
        local ahead = math.clamp(25 + spd * 0.6, 25, 80)
        aim = Road.point(s + rideDir * ahead, Road.laneD(rideSide, 4))
        cap = Config.rideSpeed
    end

    local flat = Vector3.new(aim.X - pos.X, 0, aim.Z - pos.Z)
    local heading = math.atan2(look.X, look.Z)
    local yawRate = 0
    if lastHeading and dt and dt > 0 then
        yawRate = wrapAngle(heading - lastHeading) / dt
    end
    lastHeading = heading
    local steer = 0
    if flat.Magnitude > 1 then
        -- The bike answers a steer input with a lot of yaw, so damp it with the
        -- measured yaw rate or it snakes across the lanes.
        local err = wrapAngle(math.atan2(flat.X, flat.Z) - heading)
        steer = math.clamp(err - yawRate * 0.45, -0.55, 0.55)
    end

    forced.steer = steer
    forced.lean = 0
    forced.rear = 0
    if spd > cap + 4 then
        forced.throttle = 0
        forced.brake = 0.7
    elseif spd > cap then
        forced.throttle = 0.15
        forced.brake = 0
    else
        forced.throttle = 1
        forced.brake = 0
    end

    -- Pressed against a wall (median, guard rail): stop pushing and unwind the steer.
    if spd < 3 and forced.throttle > 0 then
        stuckT = stuckT + (dt or 0.016)
    else
        stuckT = 0
    end
    if stuckT > 2 then
        forced.throttle = 0
        forced.brake = 0.6
        forced.steer = -steer
    end
    BikeClient.forced = forced
    local dg2 = rawget(_G, "_ _nrDiag")
    if dg2 then dg2.set = (dg2.set or 0) + 1 end
end

local driveWarned = false
game:GetService("RunService").Heartbeat:Connect(function(dt)
    if rawget(_G, _G_TOMB) == true then
        releaseDrive()
        return
    end
    local ok, err = pcall(driveTick, dt)
    if not ok then
        local dg = rawget(_G, "_ _nrDiag")
        if dg then dg.err = tostring(err) end
        if not driveWarned then
            driveWarned = true
            warn("[NightRider] drive " .. tostring(err))
        end
    end
end)

local function stagger()
    -- dim range so traffic/cops are visible before they hit you
    if Config.neverCrash and MotorcycleConfig and MotorcycleConfig.Crash then
        local c = MotorcycleConfig.Crash
        c.FallOff = false
        c.ForceFallOff = false
        c.Wipeout = false
        c.Wobble = false
        if type(c.DeathWobble) == "table" then c.DeathWobble.Enabled = false end
    end
end

-- ================================================================
-- Drive.step hook: auto ride + perfect wheelie (installed once per process)
-- ================================================================
if Drive and type(Drive.step) == "function" then
    local prev = rawget(_G, _G_STEP)
    if type(prev) ~= "function" or Drive.step ~= prev then
        local original = Drive.step
        local step
        step = function(bike, state, input, dt)
        local cfg = rawget(_G, _G_CONFIG)
        if cfg and input and state then
            local speed = num(state.speed) * 0.62636
            if cfg.autoWheelie and state.grounded ~= false and speed >= 55 then
                local deg = math.deg(num(state.wheelie))
                local rate = math.deg(num(input.wheelieRate))
                local want = math.clamp((cfg.wheelieTarget - deg) * 3.5 - rate * 0.15, -70, 70)
                input.wheelieRate = math.rad(want)
                input.throttle = math.max(num(input.throttle), 0.4)
                input.brake = 0
            end
        end
        return original(bike, state, input, dt)
        end
        Drive.step = step
        rawset(_G, _G_STEP, step)
    end
end

-- ================================================================
-- Crash / knock blocking
-- ================================================================
local CrashRemote = Motorcycle.Remotes and Motorcycle.Remotes:FindFirstChild("Crash")
local TrafficHit = Motorcycle.Remotes and Motorcycle.Remotes:FindFirstChild("TrafficHit")

do
    local hook = rawget(_G, "hookmetamethod")
    if type(hook) == "function" then
        local ok, old = pcall(function()
            local orig
            orig = hook(game, "__namecall", function(self, ...)
                local cfg = rawget(_G, _G_CONFIG)
                local method = getnamecallmethod()
                if cfg and cfg.neverCrash and method == "FireServer" then
                    if self == Stunt then
                        local first = ...
                        if first == "knock" then return end
                    elseif self == TrafficHit or self == CrashRemote then
                        return
                    end
                end
                return orig(self, ...)
            end)
            return orig
        end)
        local _ = ok and old
    end
end

-- ================================================================
-- Cops: no bust / auto escape
-- ================================================================
task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        local ok = pcall(function()
            local s = Cops and Cops.state
            if s then
                if Config.noBust then s.bust = 0 end
                if Config.autoEscape then s.evade = 5 end
            end
        end)
        local _ = ok
        task.wait(0.2)
    end
end)

-- ================================================================
-- State cache (GetData)
-- ================================================================
local cache = {}
local lastFetch = 0
local fetching = false
local function refresh(force)
    if fetching then return end
    if not force and os.clock() - lastFetch < 12 then return end
    fetching = true
    task.spawn(function()
        local ok, data = pcall(function() return GetData:InvokeServer() end)
        if ok and type(data) == "table" then
            cache = data
            lastFetch = os.clock()
        end
        fetching = false
    end)
end

local function ownedSet()
    local set = {}
    local owned = cache.owned
    if type(owned) == "table" then
        for k, v in pairs(owned) do
            if type(k) == "number" then set[v] = true else set[k] = true end
        end
    end
    return set
end

-- ================================================================
-- Rewards / garage automation
-- ================================================================
local lastDaily = 0
local lastBuy = 0
local questTried = {}

local function rewardTick()
    refresh()
    if Config.autoDaily and cache.daily and cache.daily.ready and os.clock() - lastDaily > 8 then
        lastDaily = os.clock()
        fired("daily")
        refresh(true)
    end
    if Config.autoQuests and cache.quests then
        for mode, group in pairs(cache.quests) do
            local list = type(group) == "table" and (group.items or group) or nil
            if type(list) == "table" then
                for key, entry in pairs(list) do
                    if type(entry) == "table" then
                        local id = entry.id or key
                        local claimed = entry.claimed == true
                        local stamp = questTried[mode .. ":" .. tostring(id)]
                        if not claimed and (not stamp or os.clock() - stamp > 60) then
                            questTried[mode .. ":" .. tostring(id)] = os.clock()
                            fired("claim", mode, id)
                        end
                    end
                end
            end
        end
    end
end

local function garageTick()
    if not Config.autoBuy or not BikeCatalog then return end
    if os.clock() - lastBuy < 8 then return end
    local cash = num(LP:GetAttribute("Cash"))
    local owned = ownedSet()
    local bestKey, bestPrice = nil, math.huge
    for key, info in pairs(BikeCatalog) do
        local price = type(info) == "table" and num(info.price) or 0
        if not owned[key] and price > 0 and price < bestPrice then
            bestKey, bestPrice = key, price
        end
    end
    if bestKey and cash - Config.buyReserve >= bestPrice then
        lastBuy = os.clock()
        fired("buy", bestKey)
        refresh(true)
    end
end

-- ================================================================
-- Main loop
-- ================================================================
task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        local ok, err = pcall(function()
            stagger()
            rewardTick()
            garageTick()
            rideTick()
        end)
        if not ok then warn("[NightRider] " .. tostring(err)) end
        task.wait(0.5)
    end
    pcall(releaseDrive)
    pcall(function() sendKey(Enum.KeyCode.W, false) end)
end)

LP.Idled:Connect(function()
    if not Config.antiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ================================================================
-- HUD
-- ================================================================
local hud = nil
do
    local ok = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "ExlumiaaHUD"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = game:GetService("CoreGui")
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromOffset(240, 76)
        label.Position = UDim2.fromOffset(14, 14)
        label.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        label.BackgroundTransparency = 0.25
        label.TextColor3 = Color3.fromRGB(235, 235, 240)
        label.Font = Enum.Font.Code
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Text = ""
        label.Parent = gui
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingTop = UDim.new(0, 6)
        pad.Parent = label
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        hud = { gui = gui, label = label }
    end)
    if not ok then hud = nil end
end

task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        local ok = pcall(function()
            if not hud then return end
            hud.gui.Enabled = Config.hud
            if not Config.hud then return end
            local run = LP:GetAttribute("RunActive") == true
            hud.label.Text = string.format(
                "CASH $%d   LEVEL %d\nXP %d/%d   %s\n%s   %.0f mph",
                math.floor(num(LP:GetAttribute("Cash"))),
                math.floor(num(LP:GetAttribute("Level"))),
                math.floor(num(LP:GetAttribute("XP"))),
                math.floor(num(LP:GetAttribute("XPNext"))),
                tostring(LP:GetAttribute("Rank") or ""),
                run and ("RUN x" .. tostring(LP:GetAttribute("RunMult") or 1)) or "not riding",
                mph()
            )
        end)
        local _ = ok
        task.wait(0.5)
    end
    if hud then hud.gui:Destroy() end
    if Config.autoEscape then Config.autoEscape = false end
end)

-- ================================================================
-- UI
-- ================================================================
if HasUI then
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Night Rider",
    Size = UDim2.fromOffset(520, 420),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Night Rider",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then v:Destroy() end
    end
end)

local RideTab = Window:AddTab({ Name = "Ride", Icon = "bolt", Subtitle = "Auto ride & stunts" })
local RideSub = RideTab:AddSubTab("Features")

RideSub:AddSection("Driving")
RideSub:AddToggle({
    Name = "Auto Ride",
    Flag = "nr_ride",
    Default = false,
    Callback = function(v) Config.autoRide = v end,
})
RideSub:AddSlider({
    Name = "Cruise Speed",
    Flag = "nr_speed",
    Min = 30,
    Max = 120,
    Default = 70,
    Suffix = " mph",
    Callback = function(v) Config.rideSpeed = v end,
})
RideSub:AddToggle({
    Name = "Perfect Wheelie",
    Flag = "nr_wheelie",
    Default = true,
    Callback = function(v) Config.autoWheelie = v end,
})
RideSub:AddSlider({
    Name = "Wheelie Angle",
    Flag = "nr_wangle",
    Min = 15,
    Max = 55,
    Default = 30,
    Suffix = "°",
    Callback = function(v) Config.wheelieTarget = v end,
})
RideSub:AddParagraph({
    Title = "Stunt income",
    Text = "Hold a clean wheelie above 55 mph and the game pays its own stunt rewards. No fake events are sent.",
})

RideSub:AddSection("Safety")
RideSub:AddToggle({
    Name = "Never Crash",
    Flag = "nr_crash",
    Default = true,
    Callback = function(v) Config.neverCrash = v end,
})
RideSub:AddToggle({
    Name = "No Bust",
    Flag = "nr_bust",
    Default = true,
    Callback = function(v) Config.noBust = v end,
})
RideSub:AddToggle({
    Name = "Auto Escape",
    Flag = "nr_escape",
    Default = false,
    Callback = function(v) Config.autoEscape = v end,
})

local RewardTab = Window:AddTab({ Name = "Rewards", Icon = "gift", Subtitle = "Daily & quests" })
local RewardSub = RewardTab:AddSubTab("Features")

RewardSub:AddSection("Rewards")
RewardSub:AddToggle({
    Name = "Auto Daily",
    Flag = "nr_daily",
    Default = true,
    Callback = function(v) Config.autoDaily = v end,
})
RewardSub:AddToggle({
    Name = "Auto Claim Quests",
    Flag = "nr_quests",
    Default = true,
    Callback = function(v) Config.autoQuests = v end,
})
RewardSub:AddButton({
    Name = "Claim Daily Now",
    Callback = function()
        fired("daily")
        refresh(true)
    end,
})
RewardSub:AddButton({
    Name = "Claim Quests Now",
    Callback = function()
        refresh(true)
        task.wait(0.6)
        if cache.quests then
            for mode, group in pairs(cache.quests) do
                local list = type(group) == "table" and (group.items or group) or nil
                for key, entry in pairs(type(list) == "table" and list or {}) do
                    if type(entry) == "table" then fired("claim", mode, entry.id or key) end
                end
            end
        end
    end,
})
RewardSub:AddParagraph({
    Title = "Group reward",
    Text = "The $15k group reward needs membership: roblox.com/groups/43749958. Join once, then claim it in the game's rewards menu.",
})

local GarageTab = Window:AddTab({ Name = "Garage", Icon = "star", Subtitle = "Bikes" })
local GarageSub = GarageTab:AddSubTab("Features")

GarageSub:AddSection("Dealership")
GarageSub:AddToggle({
    Name = "Auto Buy Next Bike",
    Flag = "nr_autobuy",
    Default = false,
    Callback = function(v) Config.autoBuy = v end,
})
GarageSub:AddSlider({
    Name = "Cash Reserve",
    Flag = "nr_reserve",
    Min = 0,
    Max = 2000000,
    Default = 0,
    Callback = function(v) Config.buyReserve = v end,
})
GarageSub:AddButton({
    Name = "Buy Next Affordable Bike",
    Callback = function()
        garageTick()
    end,
})
GarageSub:AddParagraph({
    Title = "Note",
    Text = "Auto buy only purchases bikes you do not own, cheapest first. Selling is left to the in-game garage so you cannot lose your only bike.",
})

local TravelTab = Window:AddTab({ Name = "Travel", Icon = "running", Subtitle = "Fast travel" })
local TravelSub = TravelTab:AddSubTab("Features")

local DESTINATIONS = {
    { name = "Main / Spawn", id = "Main" },
    { name = "City", id = "Station14_R" },
    { name = "Coast", id = "Station01_R" },
    { name = "Forest", id = "Station03_R" },
    { name = "Mountain", id = "Station04_R" },
    { name = "Farm", id = "Station07_R" },
    { name = "Industrial", id = "Station09_R" },
    { name = "Suburban", id = "Station11_R" },
}

TravelSub:AddSection("Fast Travel")
TravelSub:AddDropdown({
    Name = "Destination",
    Flag = "nr_dest",
    Options = (function()
        local list = {}
        for _, d in ipairs(DESTINATIONS) do list[#list + 1] = d.name end
        return list
    end)(),
    Default = "City",
    Callback = function(v) Config.destination = v end,
})
TravelSub:AddButton({
    Name = "Teleport",
    Callback = function()
        local target = nil
        for _, d in ipairs(DESTINATIONS) do
            if d.name == (Config.destination or "City") then target = d.id end
        end
        local rf = RS:FindFirstChild("NightRiderMenu")
        if rf and rf:FindFirstChild("Menu") and target then
            pcall(function() rf.Menu:InvokeServer("teleport", target, true) end)
        end
    end,
})

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Utility" })
local SettingsSub = SettingsTab:AddSubTab("Features")

SettingsSub:AddSection("Utility")
SettingsSub:AddToggle({
    Name = "Anti AFK",
    Flag = "nr_afk",
    Default = true,
    Callback = function(v) Config.antiAfk = v end,
})
SettingsSub:AddToggle({
    Name = "Stats HUD",
    Flag = "nr_hud",
    Default = true,
    Callback = function(v) Config.hud = v end,
})
SettingsSub:AddButton({
    Name = "Show Stats",
    Callback = function()
        refresh(true)
        task.wait(0.5)
        pcall(function()
            Window:Notify({
                Title = "Night Rider",
                Content = string.format(
                    "Cash $%d  ·  Level %d  ·  XP %d/%d  ·  Daily day %d  ·  Bikes %d",
                    math.floor(num(LP:GetAttribute("Cash"))),
                    math.floor(num(LP:GetAttribute("Level"))),
                    math.floor(num(LP:GetAttribute("XP"))),
                    math.floor(num(LP:GetAttribute("XPNext"))),
                    math.floor(num(cache.daily and cache.daily.day)),
                    (function()
                        local n = 0
                        for _ in pairs(ownedSet()) do n = n + 1 end
                        return n
                    end)()
                ),
            })
        end)
    end,
})

pcall(function()
    Window:Notify({
        Title = "Exlumiaa Hub loaded",
        Content = "Press RightShift to toggle. Turn on Auto Ride and hold a wheelie.",
    })
end)

end
