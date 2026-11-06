-- Exlumiaa Hub - Steal A Pet And Ride It!
-- Verified live on universe 10769315427 (place 95168737547508, v437):
--   Steal: ProximityPrompt on cage Root (tag StealPrompt), fireproximityprompt()
--          -> Player attribute CarryingCage; cage item appears in Player.Cages
--   Place: PlaceCage:FireServer(cage.Name, stall.Index) within ~30 studs of the pen
--   Open:  OpenCage:FireServer(cage.Name) after cage.ReadyAt (os.time), near its stall
--          -> pet appears in Player.Pets after ~4s reveal
--   Cash:  no remote; touch plot.CashPad.Button to collect plot.CashWaiting
--   Pens:  plot.Barn.Stalls.StallN (Index, Owned), PetSpot attachment
--
-- SAFE MODE (anti-cheat): no CFrame teleport, no WalkSpeed edit, no fly.
-- The account was kicked for "cheating (speed hacking)" after long CFrame
-- teleports (server tracks Fly/Air/Speed strikes per player, DataConfig
-- AntiCheat). Movement now goes through the game's own systems:
-- walking + riding pets, MoveTo with humanoid physics.

if tostring(game.GameId) ~= "10769315427" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _saprTomb"
local _G_ALIVE = "_ _saprAlive"
local _G_CONFIG = "_ _saprConfig"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.6)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
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
    safeMode = true,
    autoFarm = false,
    cageFilter = "Rare+",
    farmBiome = "Auto",
    autoTrain = false,
    trainUntil = 0,
    autoTap = true,
    autoRide = true,
    autoPlaceOpen = true,
    autoCash = false,
    cashMin = 1000,
    safeZoneTp = false,
    autoUpgrade = false,
    autoBuy = false,
    buyReserve = 0,
    buyStats = { Treadmill = true, PetCash = true, Gems = true, Hatch = true, PetLuck = true, RunSpeed = true },
    autoFuse = false,
    autoSell = false,
    sellBelow = 50,
    keepBest = 2,
    autoTime = false,
    autoIndex = false,
    autoDaily = false,
    autoRebirth = false,
    espCages = false,
    espMinRarity = "Rare+",
    espBosses = false,
    espPlayers = false,
    espCash = false,
    tracers = false,
    espRange = 600,
    fullbright = false,
    antiAfk = true,
}
rawset(_G, _G_CONFIG, Config)

-- ================================================================
-- Remotes and shared config
-- ================================================================
local Shared = ReplicatedStorage:FindFirstChild("Shared")
local Remotes = Shared and Shared:FindFirstChild("Remotes")
if not Remotes then return end

local CageCfg = nil
pcall(function() CageCfg = require(Shared.Config.CageConfig) end)

local KIND_ORDER = {
    Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5, Cosmic = 6,
    Secret = 7, Eternal = 8, Divine = 9, Infinity = 10, Astral = 11, Omega = 12,
}

local function kindOrder(kind)
    local c = CageCfg and CageCfg.Cages and CageCfg.Cages[kind]
    return (c and c.Order) or KIND_ORDER[kind] or 0
end

local function kindColor(kind)
    local c = CageCfg and CageCfg.Cages and CageCfg.Cages[kind]
    if c and typeof(c.Color) == "Color3" then return c.Color end
    return Color3.fromRGB(210, 210, 210)
end

local function fire(name, ...)
    local r = Remotes:FindFirstChild(name)
    if r and r:IsA("RemoteEvent") then
        local args = table.pack(...)
        pcall(function() r:FireServer(table.unpack(args, 1, args.n)) end)
    end
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
    return h ~= nil and h.Health > 0 and root() ~= nil
end

local function num(v)
    v = tonumber(v)
    v = type(v) == "number" and v or 0
    return v
end

-- Humanoid physics movement only, except the opt-in safe-zone hop below.
local function moveToGoal(target, timeout, checkStuck)
    local h, r = hum(), root()
    if not h or not r or not target then return false end
    -- shortcut: 60-stud client hop inside the safe zone, unverified against server AC (2nd strike = ban)
    if Config.safeZoneTp and LP:GetAttribute("InSafeZone") == true
        and not LP:GetAttribute("CarryingCage") then
        local flat = Vector3.new(target.X - r.Position.X, 0, target.Z - r.Position.Z)
        if flat.Magnitude <= 60 then
            local dest = target + Vector3.new(0, 3, 0)
            pcall(function() r.CFrame = CFrame.new(dest) end)
            task.wait(0.15)
            return true
        end
    end
    local start = os.clock()
    local lastPos, stuckSince = r.Position, start
    while rawget(_G, _G_TOMB) ~= true do
        h, r = hum(), root()
        if not h or not r or h.Health <= 0 then return false end
        local delta = target - r.Position
        local flat = Vector3.new(delta.X, 0, delta.Z)
        local dist = flat.Magnitude
        if dist <= 5 and delta.Y < 7 then return true end
        if os.clock() - start > (timeout or 30) then return false end
        if dist > 4 then
            pcall(function() h:MoveTo(target) end)
        else
            pcall(function() h:MoveTo(Vector3.new(target.X, r.Position.Y, target.Z)) end)
        end
        if checkStuck then
            if (r.Position - lastPos).Magnitude < 1.2 then
                if os.clock() - stuckSince > 1.4 then
                    pcall(function() h.Jump = true end)
                    stuckSince = os.clock()
                end
            else
                lastPos = r.Position
                stuckSince = os.clock()
            end
        end
        task.wait(0.1)
    end
    return false
end

local function waitUntil(pred, timeout, step)
    local start = os.clock()
    while rawget(_G, _G_TOMB) ~= true do
        if pred() then return true end
        if timeout and (os.clock() - start) > timeout then return false end
        task.wait(step or 0.25)
    end
    return false
end

local function getPlots()
    local hub = workspace:FindFirstChild("Hub")
    return hub and hub:FindFirstChild("Plots") or nil
end

local function myPlot()
    local plots = getPlots()
    if not plots then return nil end
    for _, p in ipairs(plots:GetChildren()) do
        if tostring(p:GetAttribute("OwnerUserId")) == tostring(LP.UserId) then return p end
    end
end

local function stallsOf(plot)
    local barn = plot:FindFirstChild("Barn")
    return barn and barn:FindFirstChild("Stalls") or nil
end

local function stallByIndex(plot, idx)
    local stalls = stallsOf(plot)
    if not stalls then return nil end
    for _, stall in ipairs(stalls:GetChildren()) do
        if tonumber(stall:GetAttribute("Index")) == idx then return stall end
    end
end

-- A pen is used when a placed cage says Stall=<index>, or a pet's Home CFrame
-- sits on that pen's PetSpot.
local function penUsage(plot)
    local used = {}
    local function mark(cage)
        local s = tonumber(cage:GetAttribute("Stall"))
        if s then used[s] = true end
    end
    local cf = plot:FindFirstChild("Cages")
    if cf then for _, c in ipairs(cf:GetChildren()) do mark(c) end end
    local inv = LP:FindFirstChild("Cages")
    if inv then for _, c in ipairs(inv:GetChildren()) do mark(c) end end

    local pets = plot:FindFirstChild("Pets")
    local stalls = stallsOf(plot)
    if pets and stalls then
        for _, pet in ipairs(pets:GetChildren()) do
            local home = pet:GetAttribute("Home")
            if typeof(home) == "CFrame" then
                local bestIdx, bestD = nil, 6
                for _, stall in ipairs(stalls:GetChildren()) do
                    local spot = stall:FindFirstChild("PetSpot")
                    if spot then
                        local d = (spot.WorldPosition - home.Position).Magnitude
                        if d < bestD then bestD, bestIdx = d, tonumber(stall:GetAttribute("Index")) end
                    end
                end
                if bestIdx then used[bestIdx] = true end
            end
        end
    end
    return used
end

local function freePen(plot)
    local stalls = stallsOf(plot)
    if not stalls then return nil end
    local used = penUsage(plot)
    local best = nil
    for _, stall in ipairs(stalls:GetChildren()) do
        local idx = tonumber(stall:GetAttribute("Index"))
        if stall:GetAttribute("Owned") and idx and not used[idx] then
            if not best or idx < best then best = idx end
        end
    end
    return best
end

-- Ride / train / shop pass uses PetConfig pets and player attributes.
local PetConfig = nil
pcall(function() PetConfig = require(Shared.Config.PetConfig) end)

local QualityCfg, TreadmillCfg, RebirthCfg, TimeCfg, TalismanCfg
pcall(function() QualityCfg = require(Shared.Config.QualityConfig) end)
pcall(function() TreadmillCfg = require(Shared.Config.TreadmillConfig) end)
pcall(function() RebirthCfg = require(Shared.Config.RebirthConfig) end)
pcall(function() TimeCfg = require(Shared.Config.TimeRewardConfig) end)
pcall(function() TalismanCfg = require(Shared.Config.TalismanConfig) end)

local function isLimited(kind)
    local list = PetConfig and PetConfig.LimitedPets
    if type(list) ~= "table" then return false end
    if list[kind] ~= nil then return true end
    for _, v in ipairs(list) do
        if v == kind then return true end
    end
    return false
end

local function petIncome(pet)
    local info = PetConfig and PetConfig.Pets and PetConfig.Pets[pet:GetAttribute("Kind")]
    if not info then return 0 end
    local mult = 1
    if QualityCfg and QualityCfg.GetIncome then
        local ok, v = pcall(function() return QualityCfg.GetIncome(pet:GetAttribute("Quality")) end)
        if ok and tonumber(v) then mult = tonumber(v) end
    end
    return num(info.Income) * mult
end

local function petRide(kind)
    local info = PetConfig and PetConfig.Pets and PetConfig.Pets[kind]
    return (info and num(info.RideSpeed)) or 1
end

local function bestRidePet()
    local pets = LP:FindFirstChild("Pets")
    if not pets then return nil, 0 end
    local best, bestRide = nil, 0
    for _, pet in ipairs(pets:GetChildren()) do
        local rs = petRide(pet:GetAttribute("Kind"))
        if rs > bestRide then best, bestRide = pet, rs end
    end
    return best, bestRide
end

local function rideBest()
    if LP:GetAttribute("RidingPet") or LP:GetAttribute("CarryingCage") then return end
    local best, _ = bestRidePet()
    if best then fire("RidePet", best.Name) end
end

local function dismount()
    if LP:GetAttribute("RidingPet") then fire("RidePet") end
end

local function treadmillBelt()
    local plot = myPlot()
    local tm = plot and plot:FindFirstChild("Treadmill")
    local belt = tm and tm:FindFirstChild("Belt")
    return belt
end

local FILTERS = {
    ["Nearest"] = 0, ["All"] = 0, ["Rare+"] = 2, ["Epic+"] = 3, ["Legendary+"] = 4,
    ["Mythic+"] = 5, ["Cosmic+"] = 6, ["Secret+"] = 7,
}

local function findTargetCage()
    local h = root()
    local paths = workspace:FindFirstChild("Paths")
    if not h or not paths then return nil end
    local minOrder = FILTERS[Config.cageFilter] or 0
    local biome = Config.farmBiome
    local best, bestD, bestPos = nil, math.huge, nil

    for _, path in ipairs(paths:GetChildren()) do
        local idx = tonumber(string.match(path.Name, "%d+"))
        if idx and (biome == "Auto" or biome == tostring(idx)) then
            local cf = path:FindFirstChild("Cages")
            if cf then
                for _, cage in ipairs(cf:GetChildren()) do
                    if cage:IsA("Model") then
                        local rp = cage.PrimaryPart or cage:FindFirstChild("Root")
                        local kind = cage:GetAttribute("Kind")
                        if rp and kind and kindOrder(kind) >= minOrder then
                            local d = (rp.Position - h.Position).Magnitude
                            if d < bestD then bestD, best, bestPos = d, cage, rp.Position end
                        end
                    end
                end
            end
        end
    end
    if not best then return nil end
    local rp = best.PrimaryPart or best:FindFirstChild("Root")
    local prompt = rp and rp:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then prompt = best:FindFirstChildOfClass("ProximityPrompt") end
    return best, prompt, bestPos
end

local lastSteal = 0
local function stealOnce()
    if os.clock() - lastSteal < 1.5 then return false end
    local cage, prompt, pos = findTargetCage()
    if not cage or not prompt or not prompt.Enabled then return false end
    lastSteal = os.clock()

    if LP:GetAttribute("OnTreadmill") then fire("LeaveTreadmill") end
    moveToGoal(pos, 45, true)
    if LP:GetAttribute("RidingPet") then dismount() task.wait(0.2) end
    pcall(fireproximityprompt, prompt)
    local got = waitUntil(function() return LP:GetAttribute("CarryingCage") ~= nil end, 3)
    if got and not LP:GetAttribute("RidingPet") then
        -- boss is chasing now: ride back instantly, no waits
        rideBest()
    end
    return got
end

-- ================================================================
-- Place / open
-- ================================================================
local function placeInventory(plot)
    local inv = LP:FindFirstChild("Cages")
    if not inv then return false end
    for _, cage in ipairs(inv:GetChildren()) do
        local idx = freePen(plot)
        if not idx then return false end
        local stall = stallByIndex(plot, idx)
        local spot = stall and stall:FindFirstChild("PetSpot")
        if spot then moveToGoal(spot.WorldPosition, 15, true) end
        fire("PlaceCage", cage.Name, idx)
        task.wait(0.45)
        return true
    end
    return false
end

local function openReadyCages(plot)
    local cf = plot:FindFirstChild("Cages")
    if not cf then return false end
    local now = os.time()
    for _, cage in ipairs(cf:GetChildren()) do
        local readyAt = tonumber(cage:GetAttribute("ReadyAt"))
        if readyAt and now >= readyAt then
            local stall = stallByIndex(plot, tonumber(cage:GetAttribute("Stall")))
            local spot = stall and stall:FindFirstChild("PetSpot")
            local rp = cage.PrimaryPart or cage:FindFirstChild("Root")
            local target = spot and spot.WorldPosition or (rp and rp.Position)
            if target then
                moveToGoal(target, 15, true)
                fire("OpenCage", cage.Name)
                task.wait(0.4)
            end
            return true
        end
    end
    return false
end

-- ================================================================
-- Safe farm loop: train -> steal -> return -> place/open -> cash
-- ================================================================
local busy = false

local function pcallBusy(fn)
    busy = true
    local ok, err = pcall(fn)
    busy = false
    if not ok then warn("[SAFE] farm error: " .. tostring(err)) end
    return ok
end

local function cashWaiting()
    local plot = myPlot()
    return plot and num(plot:GetAttribute("CashWaiting")) or 0
end

local function plotGoal()
    local plot = myPlot()
    local pad = plot and plot:FindFirstChild("CashPad")
    return pad and pad:FindFirstChild("Button")
end

local function sellZone()
    local hub = workspace:FindFirstChild("Hub")
    local shops = hub and hub:FindFirstChild("Shops")
    local shop = shops and shops:FindFirstChild("SellShop")
    return shop and shop:FindFirstChild("Zone")
end

-- Escape immediately: ride if not mounted, no delays.
local function returnHome()
    if not LP:GetAttribute("RidingPet") then rideBest() task.wait(0.1) end
    local btn = plotGoal()
    if not btn then return false end
    local pos = btn.Position + Vector3.new(0, 3, 0)
    moveToGoal(pos, 30, true)
    return true
end

local function collectCash()
    if cashWaiting() < Config.cashMin then return false end
    local btn = plotGoal()
    if not btn then return false end
    moveToGoal(btn.Position + Vector3.new(0, 2, 0), 20, true)
    task.wait(0.4)
    moveToGoal(btn.Position + Vector3.new(6, 3, 0), 10, false)
    return true
end

local function trainStep()
    if LP:GetAttribute("RidingPet") then dismount() end
    if LP:GetAttribute("CarryingCage") then return false end
    local belt = treadmillBelt()
    if not belt then return false end
    if LP:GetAttribute("OnTreadmill") then
        task.wait(0.5)
        return true
    end
    moveToGoal(belt.Position + Vector3.new(0, 1.5, 0), 20, true)
    waitUntil(function() return LP:GetAttribute("OnTreadmill") end, 4)
    task.wait(0.4)
    return LP:GetAttribute("OnTreadmill") == true
end

local function isHeld()
    local inv = LP:FindFirstChild("Cages")
    return LP:GetAttribute("CarryingCage") ~= nil or (inv and #inv:GetChildren() > 0)
end

task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        local ok, err = pcall(function()
            if busy or not Config.autoFarm or not alive() then return end
            local plot = myPlot()
            if not plot then return end

            if Config.autoTrain and not isHeld()
                and (Config.trainUntil <= 0 or num(LP:GetAttribute("Speed")) < Config.trainUntil) then
                pcallBusy(trainStep)
                return
            end

            if isHeld() then
                -- escape first, then place/open/cash on home soil
                pcallBusy(returnHome)
                if Config.autoPlaceOpen then
                    pcallBusy(function()
                        openReadyCages(plot)
                        placeInventory(plot)
                    end)
                end
                if Config.autoCash then pcallBusy(collectCash) end
                return
            end

            if Config.autoPlaceOpen then
                if openReadyCages(plot) then return end
                if placeInventory(plot) then return end
            end

            if Config.autoCash then
                if collectCash() then return end
            end

            if Config.autoRide and not LP:GetAttribute("RidingPet") then
                rideBest()
                task.wait(0.3)
            end

            pcallBusy(stealOnce)
        end)
        if not ok then warn("[SAFE] farm error: " .. tostring(err)) end
        task.wait(0.5)
    end
end)

-- ================================================================
-- Auto train standalone (farm loop keeps it while farming)
-- ================================================================
task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        if Config.autoTrain and not Config.autoFarm and not busy and alive() and not isHeld()
            and (Config.trainUntil <= 0 or num(LP:GetAttribute("Speed")) < Config.trainUntil) then
            pcallBusy(trainStep)
        end
        task.wait(1)
    end
end)

-- ================================================================
-- Auto collect cash
-- ================================================================
task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        if Config.autoCash and not busy and alive() and not Config.autoFarm then
            collectCash()
        end
        task.wait(1)
    end
end)

-- ================================================================
-- Automation: upgrade, talismans, fuse, sell, rewards, rebirth
-- ================================================================
local FuseOdds = nil
pcall(function() FuseOdds = require(Shared:FindFirstChild("FuseOdds")) end)

local lastUpgrade, lastBuy, lastFuse, lastSell, lastTime, lastIndex, lastRebirth = 0, 0, 0, 0, 0, 0, 0

local function autoUpgradeStep()
    if not TreadmillCfg or os.clock() - lastUpgrade < 2 then return false end
    local plot = myPlot()
    if not plot then return false end
    local level = tonumber(plot:GetAttribute("TreadmillLevel")) or 1
    local cost = TreadmillCfg.UpgradeCost and TreadmillCfg.UpgradeCost[level + 1]
    if not cost or num(LP:GetAttribute("Cash")) < num(cost) then return false end
    lastUpgrade = os.clock()
    fire("UpgradeTreadmill")
    return true
end

local function ownsTalisman(key)
    local folder = LP:FindFirstChild("Talismans")
    return folder ~= nil and folder:FindFirstChild(key) ~= nil
end

local function autoBuyStep()
    if not TalismanCfg or not TalismanCfg.Talismans or os.clock() - lastBuy < 1.5 then return false end
    local gems = num(LP:GetAttribute("Gems"))
    local reserve = num(Config.buyReserve)
    if gems <= reserve then return false end
    local world = tonumber(LP:GetAttribute("BestWorld")) or 1
    local pick, pickOrder = nil, nil
    for key, info in pairs(TalismanCfg.Talismans) do
        if Config.buyStats[info.Stat] and not ownsTalisman(key) then
            local price = num(info.Price)
            local open = true
            pcall(function() open = TalismanCfg.IsOpenFor(key, world) end)
            if open and price > 0 and gems >= price + reserve then
                local order = num(info.Order)
                if not pickOrder or order < pickOrder then pick, pickOrder = key, order end
            end
        end
    end
    if not pick then return false end
    lastBuy = os.clock()
    fire("BuyTalisman", pick)
    return true
end

local function autoFuseStep()
    if os.clock() - lastFuse < 6 then return false end
    local pets = LP:FindFirstChild("Pets")
    if not pets then return false end
    local groups = {}
    for _, pet in ipairs(pets:GetChildren()) do
        local kind = pet:GetAttribute("Kind")
        local info = PetConfig and PetConfig.Pets and PetConfig.Pets[kind]
        local quality = pet:GetAttribute("Quality")
        local ladderOk = true
        if FuseOdds and QualityCfg and quality then
            local ok, ladder = pcall(function() return FuseOdds.GetLadder(kind) end)
            if ok and type(ladder) == "table" and QualityCfg.Get then
                local q = QualityCfg.Get(quality)
                ladderOk = not q or num(q.Order) < #ladder
            end
        end
        if info and pet:GetAttribute("Stall") == nil and pet:GetAttribute("Locked") ~= true
            and pet:GetAttribute("Favorite") ~= true and not isLimited(kind) and ladderOk then
            groups[kind] = groups[kind] or {}
            table.insert(groups[kind], pet)
        end
    end
    for _, list in pairs(groups) do
        if #list >= 3 then
            lastFuse = os.clock()
            fire("FusePets", list[1].Name, list[2].Name, list[3].Name)
            return true
        end
    end
    return false
end

local function autoSellStep()
    local pets = LP:FindFirstChild("Pets")
    if not pets or os.clock() - lastSell < 4 then return false end
    local list = {}
    for _, pet in ipairs(pets:GetChildren()) do
        local kind = pet:GetAttribute("Kind")
        if PetConfig and PetConfig.Pets and PetConfig.Pets[kind]
            and pet:GetAttribute("Locked") ~= true and pet:GetAttribute("Favorite") ~= true
            and not isLimited(kind) then
            list[#list + 1] = {
                pet = pet,
                income = petIncome(pet),
                stall = tonumber(pet:GetAttribute("Stall")),
            }
        end
    end
    table.sort(list, function(a, b) return a.income > b.income end)
    local keep = math.max(0, math.floor(Config.keepBest))
    local low = {}
    for i = keep + 1, #list do
        if list[i].income <= Config.sellBelow then low[#low + 1] = list[i] end
    end
    if #low == 0 then return false end

    local pulled = false
    for _, e in ipairs(low) do
        if e.stall then
            fire("StorePet", e.stall)
            pulled = true
        end
    end
    if pulled then task.wait(1.2) end

    local ids = {}
    for _, e in ipairs(low) do
        if e.pet.Parent then ids[#ids + 1] = e.pet.Name end
    end
    if #ids == 0 then return false end

    local zone = sellZone()
    if zone and root() and (root().Position - zone.Position).Magnitude > 10 then
        moveToGoal(zone.Position + Vector3.new(0, 1, 0), 45, true)
        if (root() and (root().Position - zone.Position).Magnitude or 99) > 12 then return false end
    end
    lastSell = os.clock()
    fire("SellItems", ids, nil)
    return true
end

local function autoTimeStep()
    if not TimeCfg or not TimeCfg.Rewards or os.clock() - lastTime < 5 then return false end
    local since = tonumber(LP:GetAttribute("PlaySince"))
    if not since then return false end
    local played = num(LP:GetAttribute("PlayBase")) + (workspace:GetServerTimeNow() - since)
    local claimed = {}
    for n in tostring(LP:GetAttribute("TimeClaimed") or ""):gmatch("%d+") do claimed[tonumber(n)] = true end
    for i, reward in ipairs(TimeCfg.Rewards) do
        if not claimed[i] and played >= num(reward.Minutes) * 60 then
            lastTime = os.clock()
            fire("ClaimTimeReward", i)
            return true
        end
    end
    return false
end

local function autoIndexStep()
    if os.clock() - lastIndex < 60 then return false end
    lastIndex = os.clock()
    fire("ClaimAllIndexRewards")
    return true
end

local function autoRebirthStep()
    if not RebirthCfg or os.clock() - lastRebirth < 5 then return false end
    if LP:GetAttribute("CarryingCage") then return false end
    local nextIndex = (tonumber(LP:GetAttribute("Rebirths")) or 0) + 1
    local world = tonumber(LP:GetAttribute("BestWorld")) or 1
    local ok, cost = pcall(function() return RebirthCfg.GetCost(nextIndex, world) end)
    if not ok or not tonumber(cost) then return false end
    if num(LP:GetAttribute("Cash")) < num(cost) then return false end
    lastRebirth = os.clock()
    fire("Rebirth")
    task.wait(2)
    return true
end

task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        if alive() and not busy then
            local ok, err = pcall(function()
                if Config.autoUpgrade then autoUpgradeStep() end
                if Config.autoBuy then autoBuyStep() end
                if Config.autoFuse then autoFuseStep() end
                if Config.autoTime then autoTimeStep() end
                if Config.autoIndex then autoIndexStep() end
                if Config.autoDaily and LP:GetAttribute("DailyReady") == true then
                    fire("ClaimDaily")
                    task.wait(1.5)
                end
                if Config.autoRebirth then autoRebirthStep() end
            end)
            if not ok then warn("[SAFE] auto error: " .. tostring(err)) end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        if Config.autoSell and alive() and not busy then pcallBusy(autoSellStep) end
        task.wait(2)
    end
end)

-- ================================================================
-- Anti AFK
-- ================================================================
local connections = {}
connections[#connections + 1] = LP.Idled:Connect(function()
    if not Config.antiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Training bubble: the game offers a tap boost, reply once.
local tapRemote = Remotes:FindFirstChild("TapBoost")
if tapRemote and tapRemote:IsA("RemoteEvent") then
    connections[#connections + 1] = tapRemote.OnClientEvent:Connect(function(kind, id)
        if not Config.autoTap or kind ~= "Offer" or id == nil then return end
        task.delay(0.2, function() fire("TapBoost", id) end)
    end)
end

-- Drop listeners once a newer build takes over (Config table is replaced).
task.spawn(function()
    while rawget(_G, _G_CONFIG) == Config and rawget(_G, _G_TOMB) ~= true do task.wait(0.5) end
    for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
end)

-- ================================================================
-- Safe mode: movement only via game systems (walk + ride), no Fly/WalkSpeed
-- ================================================================

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
-- ESP (Drawing only)
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
    local any = Config.espCages or Config.espBosses or Config.espPlayers or Config.espCash
    local minOrder = FILTERS[Config.espMinRarity] or 0

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
        e.line.Visible = Config.tracers and tracer ~= false
    end

    if any then
        if Config.espCages then
            local paths = workspace:FindFirstChild("Paths")
            if paths then
                local near = {}
                for _, path in ipairs(paths:GetChildren()) do
                    local cf = path:FindFirstChild("Cages")
                    if cf then
                        for _, cage in ipairs(cf:GetChildren()) do
                            if cage:IsA("Model") then
                                local rp = cage.PrimaryPart or cage:FindFirstChild("Root")
                                local kind = cage:GetAttribute("Kind")
                                if rp and kind and kindOrder(kind) >= minOrder then
                                    local d = (rp.Position - r.Position).Magnitude
                                    if d <= Config.espRange then
                                        near[#near + 1] = { cage = cage, pos = rp.Position, kind = kind, d = d }
                                    end
                                end
                            end
                        end
                    end
                end
                table.sort(near, function(a, b) return a.d < b.d end)
                -- cap: hundreds of cages x Drawing text/line was memory heavy
                for i = 1, math.min(#near, 40) do
                    local e = near[i]
                    show(e.cage, e.pos, tostring(e.kind) .. "  " .. math.floor(e.d) .. "m", kindColor(e.kind), 4, false)
                end
            end
        end

        if Config.espBosses then
            for _, boss in ipairs(CollectionService:GetTagged("Boss")) do
                if boss.Parent then
                    local rp = boss.PrimaryPart or boss:FindFirstChild("Root")
                    if rp then
                        local d = (rp.Position - r.Position).Magnitude
                        if d <= Config.espRange then
                            local state = tostring(boss:GetAttribute("State") or "?")
                            local label = "BOSS " .. tostring(boss:GetAttribute("Kind") or boss.Name) .. " [" .. state .. "]  " .. math.floor(d) .. "m"
                            local col = state == "Chase" and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(255, 190, 80)
                            show(boss, rp.Position, label, col, 6, false)
                        end
                    end
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
                            local carry = pl:GetAttribute("CarryingCage")
                            local label = pl.Name .. (carry and ("  [" .. tostring(carry) .. "]") or "") .. "  " .. math.floor(d) .. "m"
                            show(p, p.Position, label, Color3.fromRGB(255, 120, 120), 4, true)
                        end
                    end
                end
            end
        end

        if Config.espCash then
            local plot = myPlot()
            local pad = plot and plot:FindFirstChild("CashPad")
            local btn = pad and pad:FindFirstChild("Button")
            if btn then
                local waiting = tonumber(plot:GetAttribute("CashWaiting")) or 0
                if waiting > 0 then
                    local d = (btn.Position - r.Position).Magnitude
                    if d <= Config.espRange then
                        show(btn, btn.Position, "Cash $" .. math.floor(waiting), Color3.fromRGB(120, 255, 150), 4, true)
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
        task.wait(0.2)
    end
    clearESP()
    setFullbright(false)
end)

-- ================================================================
-- UI
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Steal A Pet",
    Size = UDim2.fromOffset(520, 420),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Steal A Pet And Ride It",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then v:Destroy() end
    end
end)

local BIOMES = { "Auto" }
for i = 1, 20 do BIOMES[#BIOMES + 1] = tostring(i) end

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "crosshair", Subtitle = "Steal & Open" })
local FarmSub = FarmTab:AddSubTab("Features")

FarmSub:AddSection("Safe Farm")
FarmSub:AddToggle({
    Name = "Auto Farm (Safe)",
    Flag = "sapr_farm",
    Default = false,
    Callback = function(v) Config.autoFarm = v end,
})
FarmSub:AddToggle({
    Name = "TP Inside Safe Zone",
    Flag = "sapr_safezone_tp",
    Default = false,
    Callback = function(v) Config.safeZoneTp = v end,
})
FarmSub:AddDropdown({
    Name = "Cage Filter",
    Flag = "sapr_filter",
    Options = { "Nearest", "Rare+", "Epic+", "Legendary+", "Mythic+", "Cosmic+", "Secret+" },
    Default = "Rare+",
    Callback = function(v) Config.cageFilter = v end,
})
FarmSub:AddDropdown({
    Name = "Farm Biome",
    Flag = "sapr_biome",
    Options = BIOMES,
    Default = "Auto",
    Callback = function(v) Config.farmBiome = v end,
})
FarmSub:AddToggle({
    Name = "Auto Train",
    Flag = "sapr_train",
    Default = false,
    Callback = function(v) Config.autoTrain = v end,
})
FarmSub:AddToggle({
    Name = "Auto Tap Bubble",
    Flag = "sapr_tap",
    Default = true,
    Callback = function(v) Config.autoTap = v end,
})
FarmSub:AddSlider({
    Name = "Stop Training At Speed (0 = never)",
    Flag = "sapr_trainuntil",
    Min = 0,
    Max = 1000000,
    Default = 0,
    Callback = function(v) Config.trainUntil = v end,
})
FarmSub:AddToggle({
    Name = "Auto Ride",
    Flag = "sapr_ride",
    Default = true,
    Callback = function(v) Config.autoRide = v end,
})

FarmSub:AddSection("Cages")
FarmSub:AddToggle({
    Name = "Auto Place & Open",
    Flag = "sapr_place",
    Default = true,
    Callback = function(v) Config.autoPlaceOpen = v end,
})
FarmSub:AddButton({
    Name = "Show Stats",
    Callback = function()
        local plot = myPlot()
        local inv = LP:FindFirstChild("Cages")
        local pets = LP:FindFirstChild("Pets")
        Window:Notify({
            Title = "Stats",
            Content = string.format(
                "Cash %s  ·  Speed %s  ·  Rebirths %s  ·  Cages %d  ·  Pets %d  ·  Pad %s",
                tostring(math.floor(tonumber(LP:GetAttribute("Cash")) or 0)),
                tostring(math.floor(tonumber(LP:GetAttribute("Speed")) or 0)),
                tostring(LP:GetAttribute("Rebirths") or 0),
                inv and #inv:GetChildren() or 0,
                pets and #pets:GetChildren() or 0,
                plot and tostring(math.floor(tonumber(plot:GetAttribute("CashWaiting")) or 0)) or "?"
            ),
        })
    end,
})

FarmSub:AddSection("Cash")
FarmSub:AddToggle({
    Name = "Auto Collect Cash",
    Flag = "sapr_cash",
    Default = false,
    Callback = function(v) Config.autoCash = v end,
})
FarmSub:AddSlider({
    Name = "Collect Above",
    Flag = "sapr_cashmin",
    Min = 0,
    Max = 50000,
    Default = 1000,
    Suffix = "$",
    Callback = function(v) Config.cashMin = v end,
})

local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local VisualSub = VisualTab:AddSubTab("Features")

VisualSub:AddSection("ESP")
VisualSub:AddToggle({
    Name = "ESP Cages",
    Flag = "sapr_esp_cages",
    Default = false,
    Callback = function(v) Config.espCages = v end,
})
VisualSub:AddDropdown({
    Name = "Min Rarity",
    Flag = "sapr_esp_min",
    Options = { "All", "Rare+", "Epic+", "Legendary+", "Mythic+" },
    Default = "Rare+",
    Callback = function(v) Config.espMinRarity = v end,
})
VisualSub:AddToggle({
    Name = "ESP Bosses",
    Flag = "sapr_esp_boss",
    Default = false,
    Callback = function(v) Config.espBosses = v end,
})
VisualSub:AddToggle({
    Name = "ESP Players",
    Flag = "sapr_esp_players",
    Default = false,
    Callback = function(v) Config.espPlayers = v end,
})
VisualSub:AddToggle({
    Name = "ESP Cash Pad",
    Flag = "sapr_esp_cash",
    Default = false,
    Callback = function(v) Config.espCash = v end,
})
VisualSub:AddToggle({
    Name = "Tracers",
    Flag = "sapr_tracers",
    Default = false,
    Callback = function(v) Config.tracers = v end,
})
VisualSub:AddSlider({
    Name = "ESP Range",
    Flag = "sapr_esp_range",
    Min = 100,
    Max = 2000,
    Default = 600,
    Suffix = "m",
    Callback = function(v) Config.espRange = v end,
})

VisualSub:AddSection("World")
VisualSub:AddToggle({
    Name = "Fullbright / No Fog",
    Flag = "sapr_fullbright",
    Default = false,
    Callback = function(v) Config.fullbright = v end,
})

local PlayerTab = Window:AddTab({ Name = "Player", Icon = "running", Subtitle = "Safe movement" })
local PlayerSub = PlayerTab:AddSubTab("Features")

PlayerSub:AddSection("Safe Movement")
PlayerSub:AddButton({
    Name = "Dismount",
    Callback = function() dismount() end,
})
PlayerSub:AddButton({
    Name = "Ride Best Pet",
    Callback = function() rideBest() end,
})
PlayerSub:AddButton({
    Name = "Leave Treadmill",
    Callback = function() fire("LeaveTreadmill") end,
})
PlayerSub:AddSection("Utility")
PlayerSub:AddToggle({
    Name = "Anti AFK",
    Flag = "sapr_afk",
    Default = true,
    Callback = function(v) Config.antiAfk = v end,
})

-- Travel UI removed (safe mode): teleport causes speed-hacking kicks.
-- Use Ride Best Pet + walking; no teleport buttons.

local AutoTab = Window:AddTab({ Name = "Automation", Icon = "zap", Subtitle = "Upgrades & Rewards" })
local AutoSub = AutoTab:AddSubTab("Features")

AutoSub:AddSection("Treadmill")
AutoSub:AddToggle({
    Name = "Auto Upgrade Treadmill",
    Flag = "sapr_upgrade",
    Default = false,
    Callback = function(v) Config.autoUpgrade = v end,
})

AutoSub:AddSection("Talismans")
AutoSub:AddToggle({
    Name = "Auto Buy Talismans",
    Flag = "sapr_buy",
    Default = false,
    Callback = function(v) Config.autoBuy = v end,
})
AutoSub:AddSlider({
    Name = "Keep Gems",
    Flag = "sapr_gemreserve",
    Min = 0,
    Max = 50000,
    Default = 0,
    Callback = function(v) Config.buyReserve = v end,
})
local BUY_STATS = {
    { Key = "Treadmill", Label = "Training (Treadmill)" },
    { Key = "PetCash", Label = "Wealth (PetCash)" },
    { Key = "Gems", Label = "Gems" },
    { Key = "Hatch", Label = "Hatch" },
    { Key = "PetLuck", Label = "Luck (PetLuck)" },
    { Key = "RunSpeed", Label = "Swift (RunSpeed)" },
}
for _, stat in ipairs(BUY_STATS) do
    AutoSub:AddToggle({
        Name = stat.Label,
        Flag = "sapr_buy_" .. stat.Key,
        Default = true,
        Callback = function(v) Config.buyStats[stat.Key] = v end,
    })
end

AutoSub:AddSection("Pets")
AutoSub:AddToggle({
    Name = "Auto Fuse Pets",
    Flag = "sapr_fuse",
    Default = false,
    Callback = function(v) Config.autoFuse = v end,
})
AutoSub:AddToggle({
    Name = "Auto Sell Pets",
    Flag = "sapr_sell",
    Default = false,
    Callback = function(v) Config.autoSell = v end,
})
AutoSub:AddSlider({
    Name = "Sell Below Income",
    Flag = "sapr_sellbelow",
    Min = 0,
    Max = 10000,
    Default = 50,
    Suffix = "/s",
    Callback = function(v) Config.sellBelow = v end,
})
AutoSub:AddSlider({
    Name = "Keep Best Pets",
    Flag = "sapr_keepbest",
    Min = 0,
    Max = 10,
    Default = 2,
    Callback = function(v) Config.keepBest = v end,
})

AutoSub:AddSection("Rewards")
AutoSub:AddToggle({
    Name = "Auto Daily Reward",
    Flag = "sapr_daily",
    Default = false,
    Callback = function(v) Config.autoDaily = v end,
})
AutoSub:AddToggle({
    Name = "Auto Playtime Rewards",
    Flag = "sapr_time",
    Default = false,
    Callback = function(v) Config.autoTime = v end,
})
AutoSub:AddToggle({
    Name = "Auto Index Rewards",
    Flag = "sapr_index",
    Default = false,
    Callback = function(v) Config.autoIndex = v end,
})
AutoSub:AddToggle({
    Name = "Auto Rebirth",
    Flag = "sapr_rebirth",
    Default = false,
    Callback = function(v) Config.autoRebirth = v end,
})
