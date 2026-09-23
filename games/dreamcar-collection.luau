if tostring(game.GameId) ~= "10667357873" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local RARITY_ORDER = {
    "Common", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Prismatic",
    "Sacred", "Secret", "Godly", "Cosmic", "Apex", "Primordial", "Eternal",
}

local Config = {
    autoCrateFarm = false,
    autoSpawnCrates = false,
    autoOpenCrates = false,
    autoSellCrates = false,
    sellRarities = {},
    autoRebirth = false,
    autoQuest = false,
    autoDaily = false,
    autoFreeReward = false,
    autoUpgrades = false,
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
    local okLB, LB = pcall(function() return require(ReplicatedStorage.GAMEPLAY.Economy.LuckyBlocks) end)
    if okLB and LB.Order then
        for _, tier in ipairs(LB.Order) do
            queueCrateToggle("BuyTier", tier, true)
        end
    end

    for _, rarity in ipairs(RARITY_ORDER) do
        queueCrateToggle("SellRarity", rarity, Config.sellRarities[rarity] == true)
    end

    queueCrateToggle("AutoSellIncludePacks", "", true)
    queueCrateToggle("AutoSpawn", "", Config.autoSpawnCrates)
    queueCrateToggle("AutoOpen", "", Config.autoOpenCrates)
    queueCrateToggle("AutoSell", "", Config.autoSellCrates)
    queueCrateToggle("AutoPlace", "", true)
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
task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end

        if Config.autoCrateFarm or Config.autoSpawnCrates or Config.autoOpenCrates or Config.autoSellCrates then
            if tick() - lastCrateSync > 30 and not crateFlushing then
                pcall(syncCrateAutomation)
            end
            pcall(function() setCratePaused(false) end)
        end

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
    Title = "Dream Car Collection",
    Logo = 72522294315389,
    Folder = "exlumia",
    ToggleKey = Enum.KeyCode.RightShift,
    AllowMultiple = false,
})

local FarmTab = Window:AddTab({Name = "Farm", Icon = "agriculture", Subtitle = "Auto Farm"})
local PlayerTab = Window:AddTab({Name = "Player", Icon = "person", Subtitle = "Local Player"})
local VisualTab = Window:AddTab({Name = "Visuals", Icon = "eye", Subtitle = "ESP"})
local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})

local FarmSub = FarmTab:AddSubTab("Crate Farm")
FarmSub:AddSection("Crate Automation")
FarmSub:AddToggle({Name = "Auto Crate Farm (Master)", Default = false, Callback = function(v)
    Config.autoCrateFarm = v
    if v then pcall(syncCrateAutomation); pcall(function() setCratePaused(false) end)
    else pcall(function() setCratePaused(true) end) end
end})
FarmSub:AddToggle({Name = "Auto Spawn Crates", Default = false, Callback = function(v)
    Config.autoSpawnCrates = v; if Config.autoCrateFarm then pcall(syncCrateAutomation) end
end})
FarmSub:AddToggle({Name = "Auto Open Crates", Default = false, Callback = function(v)
    Config.autoOpenCrates = v; if Config.autoCrateFarm then pcall(syncCrateAutomation) end
end})
FarmSub:AddToggle({Name = "Auto Sell Crates", Default = false, Callback = function(v)
    Config.autoSellCrates = v; if Config.autoCrateFarm then pcall(syncCrateAutomation) end
end})
FarmSub:AddDivider()
FarmSub:AddSection("Sell Rarities")
for _, rarity in ipairs(RARITY_ORDER) do
    FarmSub:AddToggle({
        Name = "Sell " .. rarity,
        Default = Config.sellRarities[rarity] == true,
        Callback = function(v)
            Config.sellRarities[rarity] = v
            if Config.autoCrateFarm then pcall(syncCrateAutomation) end
        end,
    })
end
FarmSub:AddDivider()
FarmSub:AddButton({Name = "Sync Now", Primary = false, Callback = function() pcall(syncCrateAutomation) end})

local RewardsSub = FarmTab:AddSubTab("Rewards")
RewardsSub:AddSection("Auto Rewards")
RewardsSub:AddToggle({Name = "Auto Rebirth", Default = false, Callback = function(v) Config.autoRebirth = v end})
RewardsSub:AddToggle({Name = "Auto Claim Quests", Default = false, Callback = function(v)
    Config.autoQuest = v; if v then pcall(requestQuestSync); pcall(listenQuestSync) end
end})
RewardsSub:AddToggle({Name = "Auto Daily Reward", Default = false, Callback = function(v) Config.autoDaily = v end})
RewardsSub:AddToggle({Name = "Auto Free Reward", Default = false, Callback = function(v) Config.autoFreeReward = v end})
RewardsSub:AddToggle({Name = "Auto Buy Upgrades", Default = false, Callback = function(v) Config.autoUpgrades = v end})
RewardsSub:AddDivider()
RewardsSub:AddButton({Name = "Claim Quests Now", Primary = true, Callback = function()
    pcall(requestQuestSync); task.wait(1); pcall(claimCompletedQuests)
end})
RewardsSub:AddButton({Name = "Rebirth Now", Primary = false, Callback = function() pcall(tryRebirth) end})

local StatusSub = FarmTab:AddSubTab("Status")
StatusSub:AddSection("Player Status")
local statusLabel = StatusSub:AddLabel("Cash: loading...")
local rebirthLabel = StatusSub:AddLabel("Rebirths: loading...")
StatusSub:AddDivider()
StatusSub:AddButton({Name = "Refresh Status", Primary = false, Callback = function()
    statusLabel:Set("Cash: $"..string.format("%.0f", getCash()))
    rebirthLabel:Set("Rebirths: "..getRebirths())
end})
task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        pcall(function()
            statusLabel:Set("Cash: $"..string.format("%.0f", getCash()))
            rebirthLabel:Set("Rebirths: "..getRebirths())
        end)
        task.wait(5)
    end
end)

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
    task.wait(1)
    for _, v in ipairs(game:GetService("CoreGui"):GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:find("Oxidelib is ready") then v.Text = "" end
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