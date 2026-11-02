-- Exlumiaa Hub - Throw Food For Animals
-- Server-authoritative: every value lives in ReplicatedStorage.PlayerData, so
-- nothing here grants currency. This hub only drives the game's own remotes.
--
-- Verified live:
--   Throw_Start -> Throw_Resolve(power 0..1) -> Throw_Complete  (Complete blocks
--   for the flight time, so one throw costs ~flight + 1.6s server cooldown)
--   Training_Start / Training_Stop, Training_Bonus event -> Training_TapBonus(standId)
--   Stand_Upgrade (near the pull-up upgrade sign), Plot_UpgradeFence (near fence sign)
--   Plot_SellAnimal(id) -> {Ok, Money}, Plot_EquipBest()
--   Shop_Buy(index), Shop_Equip(index)
--
-- The game anchors the character to its launch line before a throw, so the hub
-- teleports there, waits for the server to register the new position, then fires.

if tostring(game.GameId) ~= "10766972131" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _tffaTomb"
local _G_ALIVE = "_ _tffaAlive"
local _G_CONFIG = "_ _tffaConfig"

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

-- ================================================================
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_tffa.txt"
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
        local old = pg:FindFirstChild("TFFAKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "TFFAKeyGate"
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
        title.Text = "Throw Food For Animals!"
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
    autoThrow = false,
    autoTrain = false,
    autoBonus = true,
    farmMode = "Throw Only",
    trainTime = 45,
    autoPlace = false,
    autoSell = false,
    sellRarityIdx = 0,
    sellIncome = 0,
    keepMutated = true,
    autoStand = false,
    autoFence = false,
    autoFood = false,
    reserve = 0,
    antiAfk = true,
}
rawset(_G, _G_CONFIG, Config)

-- ================================================================
-- Modules
-- ================================================================
local DC
for _ = 1, 60 do
    local ok, mod = pcall(function()
        return require(LP.PlayerScripts.Client.Controllers.DataController)
    end)
    if ok and mod then DC = mod; break end
    task.wait(0.5)
end
if not DC then return end

local Remotes, GameConfig, AnimalEconomy, RarityConfig, FoodsConfig, StandsConfig, FenceConfig
local okMods = pcall(function()
    Remotes = require(ReplicatedStorage.Shared.Remotes)
    GameConfig = require(ReplicatedStorage.Config.GameConfig)
    AnimalEconomy = require(ReplicatedStorage.Config.AnimalEconomy)
    RarityConfig = require(ReplicatedStorage.Config.RarityConfig)
    FoodsConfig = require(ReplicatedStorage.Config.FoodsConfig)
    StandsConfig = require(ReplicatedStorage.Config.StandsConfig)
    FenceConfig = require(ReplicatedStorage.Config.FenceConfig)
end)
if not okMods or not Remotes then return end

task.spawn(function() pcall(function() DC:WaitForReady() end) end)

-- ================================================================
-- Helpers
-- ================================================================
local function inv(...)
    local args = table.pack(...)
    local ok, ret = pcall(function() return Remotes.Invoke(table.unpack(args, 1, args.n)) end)
    if not ok then return { Ok = false, Reason = "Error" } end
    return ret or {}
end

local function num(v)
    v = tonumber(v)
    if not v then return 0 end
    return v
end

local function money() return num(DC:Get("Money")) end
local function standLevel() return num(DC:Get("Stand")) end
local function fenceLevel() return num(DC:Get("FenceLevel")) end
local function isTraining() return LP:GetAttribute("Training") == true end

local function hp()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function plotPivot()
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(tostring(LP:GetAttribute("PlotIndex") or 1))
    if not plot then return Vector3.new(0, 2, 22.5) end
    local ok, cf = pcall(function() return plot:GetPivot() end)
    return ok and cf.Position or Vector3.new(0, 2, 22.5)
end

-- Returns true if the character was moved. The caller waits for replication.
local function teleport(pos, lookAt)
    local h = hp()
    if not h then return false end
    h.AssemblyLinearVelocity = Vector3.zero
    h.AssemblyAngularVelocity = Vector3.zero
    h.CFrame = lookAt and CFrame.lookAt(pos, lookAt) or CFrame.new(pos)
    return true
end

local function linePos()
    local launch = GameConfig.Throw.LaunchPosition
    return Vector3.new(launch.X, 5.5, launch.Z)
end

local function trainPos()
    return plotPivot() + GameConfig.Plot.TrainingSpotOffset + Vector3.new(0, 3, 0)
end

local function standPos()
    local p = plotPivot()
    local btn = p + GameConfig.Plot.UpgradeButtonOffset
    local spot = p + GameConfig.Plot.TrainingSpotOffset
    local dir = Vector3.new(btn.X - spot.X, 0, btn.Z - spot.Z)
    dir = dir.Magnitude > 0.1 and dir.Unit or Vector3.new(0, 0, -1)
    return btn + dir * 3.8 + Vector3.new(0, 3, 0), btn + Vector3.new(0, 4, 0)
end

local function fencePos()
    return plotPivot() + FenceConfig.SignOffset + Vector3.new(0, 3, 0)
end

local function shopPos()
    return plotPivot() + GameConfig.Plot.ShopCircleOffset + Vector3.new(0, 3, 0)
end

local function rarityNames()
    local out = {}
    for _, v in ipairs(RarityConfig.List or {}) do
        local name = type(v) == "table" and (v.Name or v.Rarity) or tostring(v)
        if name and name ~= "" then out[#out + 1] = name end
    end
    return out
end

local function rarityIndex(name)
    for i, v in ipairs(RarityConfig.List or {}) do
        local n = type(v) == "table" and (v.Name or v.Rarity) or tostring(v)
        if n == name then return i end
    end
    return 99
end

local function ownedFoods()
    local out = {}
    local owned = DC:Get("OwnedFoods") or {}
    for k, v in pairs(owned) do
        local idx = tonumber(k)
        if idx and v then out[idx] = true end
    end
    return out
end

local function bestFood()
    local best = 1
    for idx in pairs(ownedFoods()) do
        if idx > best then best = idx end
    end
    return best
end

local function animals()
    return DC:Get("Animals") or {}
end

local function animalInfo(entry)
    local info = AnimalEconomy.Get(entry.ModelName) or {}
    return num(info.Income), tostring(info.Rarity or "Common")
end

-- ================================================================
-- Sell
-- ================================================================
local function sellCandidates()
    local out = {}
    for id, entry in pairs(animals()) do
        if entry.Placed ~= true then
            local inc, rarity = animalInfo(entry)
            local mutated = entry.Mutation ~= nil and entry.Mutation ~= ""
            local keep = Config.keepMutated and mutated
            local match = (Config.sellRarityIdx > 0 and rarityIndex(rarity) <= Config.sellRarityIdx)
                or (Config.sellIncome > 0 and inc < Config.sellIncome)
            if match and not keep then
                out[#out + 1] = { Id = id, Income = inc }
            end
        end
    end
    table.sort(out, function(a, b) return a.Income < b.Income end)
    return out
end

local function doSell()
    local list = sellCandidates()
    for i, item in ipairs(list) do
        if i > 12 then break end
        if not inv("Plot_SellAnimal", item.Id).Ok then break end
        task.wait(0.12)
    end
    return #list
end

-- ================================================================
-- Upgrade / shop
-- ================================================================
local function doStand()
    local nextStand = StandsConfig.Get(standLevel() + 1)
    if not nextStand then return end
    if money() < num(nextStand.Price) + Config.reserve then return end
    local pos, look = standPos()
    if teleport(pos, look) then task.wait(1.1) end
    inv("Stand_Upgrade")
    task.wait(0.7)
end

local function doFence()
    local nextFence = FenceConfig.Get(fenceLevel() + 1)
    if not nextFence then return end
    if money() < num(nextFence.Price) + Config.reserve then return end
    if teleport(fencePos()) then task.wait(1.1) end
    inv("Plot_UpgradeFence")
    task.wait(0.7)
end

local function doFood()
    local best = bestFood()
    local nextFood = FoodsConfig.Get(best + 1)
    if nextFood and money() >= num(nextFood.Price) + Config.reserve then
        if teleport(shopPos()) then task.wait(1.0) end
        if inv("Shop_Buy", best + 1).Ok then
            task.wait(0.3)
            best = bestFood()
        end
    end
    if num(DC:Get("EquippedFood")) ~= best then
        inv("Shop_Equip", best)
    end
end

-- ================================================================
-- Throw
-- ================================================================
local function stopTraining()
    if isTraining() then
        inv("Training_Stop")
        task.wait(0.6)
    end
end

local lastThrowModel = "-"
local lastThrowArea = 0

local function doThrow()
    stopTraining()
    local started = false
    for attempt = 1, 5 do
        if not Config.autoThrow then return false end
        teleport(linePos())
        task.wait(attempt == 1 and 1.2 or 0.7)
        local start = inv("Throw_Start")
        if start.Ok then started = true; break end
        if start.Reason == "Busy" then
            task.wait(3)
        elseif start.Reason == "Cooldown" then
            task.wait(1.8)
        else
            task.wait(0.9)
        end
    end
    if not started then return false end

    local resolved = inv("Throw_Resolve", 1)
    if not resolved.Ok then
        inv("Throw_Cancel")
        task.wait(1.2)
        return false
    end
    lastThrowModel = tostring(resolved.ModelName or "-")
    lastThrowArea = num(resolved.AreaIndex)

    local flight = num(resolved.FlightTime) > 0 and num(resolved.FlightTime) or 2
    task.wait(flight + 0.25)
    inv("Throw_Complete")
    task.wait(GameConfig.Throw.Cooldown + 0.2)
    return true
end

-- ================================================================
-- Train
-- ================================================================
local function doTrain(duration)
    local startedAt = os.clock()
    if not isTraining() then
        teleport(trainPos())
        task.wait(1.1)
        inv("Training_Start")
        task.wait(0.6)
        if not isTraining() then
            inv("Training_Start")
            task.wait(0.6)
        end
    end
    while os.clock() - startedAt < duration do
        local mode = Config.farmMode
        if not Config.autoTrain or (mode ~= "Train Only" and mode ~= "Both") then break end
        if not isTraining() then
            teleport(trainPos())
            task.wait(0.9)
            inv("Training_Start")
        end
        task.wait(0.3)
    end
    inv("Training_Stop")
    task.wait(0.5)
end

--Bonus bubbles are server-timed; claim instantly from the event thread.
Remotes.Event("Training_Bonus").OnClientEvent:Connect(function(standId)
    if not Config.autoBonus then return end
    if not Config.autoTrain and Config.farmMode ~= "Both" then return end
    inv("Training_TapBonus", standId)
end)

-- ================================================================
-- Anti AFK
-- ================================================================
LP.Idled:Connect(function()
    if not Config.antiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ================================================================
-- UI
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Throw Food For Animals",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Throw Food For Animals",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then v:Destroy() end
    end
end)

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "crosshair", Subtitle = "Throw & Train" })
local FarmSub = FarmTab:AddSubTab("Features")

FarmSub:AddSection("Throws")
FarmSub:AddToggle({
    Name = "Auto Perfect Throw",
    Flag = "tffa_throw",
    Default = false,
    Callback = function(v) Config.autoThrow = v end,
})

FarmSub:AddSection("Training")
FarmSub:AddToggle({
    Name = "Auto Train",
    Flag = "tffa_train",
    Default = false,
    Callback = function(v) Config.autoTrain = v end,
})
FarmSub:AddToggle({
    Name = "Auto Tap Bonus (x2)",
    Flag = "tffa_bonus",
    Default = true,
    Callback = function(v) Config.autoBonus = v end,
})

FarmSub:AddSection("Farm Mode")
FarmSub:AddDropdown({
    Name = "Mode",
    Flag = "tffa_mode",
    Options = { "Throw Only", "Train Only" },
    Default = "Throw Only",
    Callback = function(v) Config.farmMode = v end,
})
FarmSub:AddSlider({
    Name = "Train Time",
    Flag = "tffa_traintime",
    Min = 10,
    Max = 300,
    Default = 45,
    Suffix = "s",
    Callback = function(v) Config.trainTime = v end,
})
local statusLabel = FarmSub:AddLabel({ Text = "Idle" })

local AnimalsTab = Window:AddTab({ Name = "Animals", Icon = "inventory", Subtitle = "Place & Sell" })
local AnimalsSub = AnimalsTab:AddSubTab("Features")

AnimalsSub:AddSection("Plot")
AnimalsSub:AddToggle({
    Name = "Auto Place Best",
    Flag = "tffa_place",
    Default = false,
    Callback = function(v) Config.autoPlace = v end,
})

AnimalsSub:AddSection("Auto Sell (unplaced)")
AnimalsSub:AddToggle({
    Name = "Auto Sell",
    Flag = "tffa_sell",
    Default = false,
    Callback = function(v) Config.autoSell = v end,
})
do
    local rarities = { "Off" }
    for _, name in ipairs(rarityNames()) do rarities[#rarities + 1] = name end
    AnimalsSub:AddDropdown({
        Name = "Sell Rarity",
        Flag = "tffa_sellrarity",
        Options = rarities,
        Default = "Off",
        Callback = function(v)
            Config.sellRarityIdx = v == "Off" and 0 or rarityIndex(v)
        end,
    })
end
do
    local labels = { "Off", "10K", "100K", "1M", "10M", "100M", "1B", "10B", "100B", "1T", "10T", "100T", "1Qa" }
    local values = { 0, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11, 1e12, 1e13, 1e14, 1e15 }
    AnimalsSub:AddDropdown({
        Name = "Sell Below Income",
        Flag = "tffa_sellincome",
        Options = labels,
        Default = "Off",
        Callback = function(v)
            for i, label in ipairs(labels) do
                if label == v then Config.sellIncome = values[i]; return end
            end
            Config.sellIncome = 0
        end,
    })
end
AnimalsSub:AddToggle({
    Name = "Keep Mutated",
    Flag = "tffa_keepmut",
    Default = true,
    Callback = function(v) Config.keepMutated = v end,
})
AnimalsSub:AddButton({
    Name = "Sell Now",
    Callback = function()
        local n = doSell()
        Library:Notify({ Title = "Auto Sell", Content = "Sold " .. tostring(n) .. " animal(s)", Duration = 4 })
    end,
})

local UpgradeTab = Window:AddTab({ Name = "Upgrades", Icon = "coin", Subtitle = "Shop" })
local UpgradeSub = UpgradeTab:AddSubTab("Features")

UpgradeSub:AddSection("Training Bar & Plot")
UpgradeSub:AddToggle({
    Name = "Auto Upgrade Training Bar",
    Flag = "tffa_stand",
    Default = false,
    Callback = function(v) Config.autoStand = v end,
})
UpgradeSub:AddToggle({
    Name = "Auto Upgrade Plot (Fence)",
    Flag = "tffa_fence",
    Default = false,
    Callback = function(v) Config.autoFence = v end,
})

UpgradeSub:AddSection("Food")
UpgradeSub:AddToggle({
    Name = "Auto Buy Food",
    Flag = "tffa_food",
    Default = false,
    Callback = function(v) Config.autoFood = v end,
})
do
    local labels = { "Off", "100K", "1M", "10M", "100M", "1B", "10B", "100B", "1T", "10T", "100T", "1Qa" }
    local values = { 0, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11, 1e12, 1e13, 1e14, 1e15 }
    UpgradeSub:AddDropdown({
        Name = "Money Reserve",
        Flag = "tffa_reserve",
        Options = labels,
        Default = "Off",
        Callback = function(v)
            for i, label in ipairs(labels) do
                if label == v then Config.reserve = values[i]; return end
            end
            Config.reserve = 0
        end,
    })
end

local MiscTab = Window:AddTab({ Name = "Misc", Icon = "settings", Subtitle = "Utility" })
local MiscSub = MiscTab:AddSubTab("Features")
MiscSub:AddSection("Utility")
MiscSub:AddToggle({
    Name = "Anti AFK",
    Flag = "tffa_afk",
    Default = true,
    Callback = function(v) Config.antiAfk = v end,
})

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Flag = "tffa_configdrop",
    Callback = function(v) selectedConfig = v end,
})

local function refreshConfigList()
    local configs = Library:ListConfigs()
    configDropdown:SetOptions(configs)
end

local configInput = ConfigSub:AddInput({
    Name = "Config Name",
    Flag = "tffa_configname",
    PlaceholderText = "Enter config name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Callback = function()
        local name = configInput.Value
        if not name or name == "" then
            Window:Notify({ Title = "Config", Content = "Enter a name first!", Type = "warning", Duration = 3 })
            return
        end
        local ok = Library:SaveConfig(name)
        if ok then
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
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({ Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3 })
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            Window:Notify({ Title = "Config", Content = "Loaded: " .. selectedConfig, Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Config", Content = "Failed to load!", Type = "error", Duration = 3 })
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
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
local phase = "throw"
local lastPlace, lastSellCheck, lastFood, lastStand, lastFence, lastStatus = 0, 0, 0, 0, 0, 0

task.spawn(function()
    pcall(function() DC:WaitForReady() end)
    while rawget(_G, _G_TOMB) ~= true do
        local now = os.clock()

        if Config.autoFood and now - lastFood > 6 then
            lastFood = now
            doFood()
        end
        if Config.autoStand and now - lastStand > 8 then
            lastStand = now
            doStand()
        end
        if Config.autoFence and now - lastFence > 8 then
            lastFence = now
            doFence()
        end
        if Config.autoPlace and now - lastPlace > 8 then
            lastPlace = now
            inv("Plot_EquipBest")
        end
        if Config.autoSell and now - lastSellCheck > 8 then
            lastSellCheck = now
            doSell()
        end

        local mode = Config.farmMode
        if mode == "Train Only" then
            if Config.autoTrain then
                if now - lastStatus > 0.5 then
                    lastStatus = now
                    statusLabel:Set("Training")
                end
                doTrain(1e9)
            else
                task.wait(0.4)
            end
        else
            if Config.autoThrow then
                lastStatus = now
                statusLabel:Set("Throwing · perfect power")
                local okThrow = doThrow()
                statusLabel:Set(okThrow and ("Caught " .. lastThrowModel .. " · area " .. tostring(lastThrowArea)) or "Throw failed")
            else
                if now - lastStatus > 0.5 then
                    lastStatus = now
                    statusLabel:Set("Idle")
                end
                task.wait(0.4)
            end
        end
    end
end)
