if tostring(game.GameId) ~= "10684750879" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _lfHubTomb9"
local _G_ALIVE = "_ _lfHubAlive9"
local _G_GEN = "_ _lfHubGen9"

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
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_lootforge.txt"
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
        local old = pg:FindFirstChild("LootForgeKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "LootForgeKeyGate"
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
        title.Text = "+1 Loot To Forge"
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

local function isTomb()
    return rawget(_G, _G_TOMB) == true or tonumber(rawget(_G, _G_GEN)) ~= MY_GEN
end

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

Library.ConfigFolder = "exlumiaa"

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

local function safeRequire(path)
    local obj = ReplicatedStorage
    for part in path:gmatch("[^.]+") do
        obj = obj:FindFirstChild(part)
        if not obj then return nil end
    end
    local ok, res = pcall(require, obj)
    return ok and res or nil
end

local CU = safeRequire("Utils.CommunicationUtils")
if not CU then return end

local function remE(cat, name)
    local ok, res = pcall(CU.TryGetRemoteEvent, cat, name)
    return ok and res or nil
end

local function remF(cat, name)
    local ok, res = pcall(CU.TryGetRemoteFunction, cat, name)
    return ok and res or nil
end

local function bindE(cat, name)
    local ok, res = pcall(CU.TryGetBindableEvent, cat, name)
    return ok and res or nil
end

local ForgeRF = remF("Forge", "ForgeRF")
local RebirthRE = remE("Rebirth", "TryRebirthRE")
local OfflineRE = remE("Offline", "TryClaimOfflineRewardRE")
local CodeRF = remF("Code", "TryUseCodeRF")
local ATKOnceBE = bindE("Attack", "ATKOnceBE")

local TrainCTRL = safeRequire("CTRL.TrainCTRL")
local TrainAreaHelper = safeRequire("Config.TrainArea.Helper")
local RebirthHelper = safeRequire("Config.Rebirth.Helper")
local UpgradeHelper = safeRequire("Config.Upgrade.Helper")
local UpgradeData = safeRequire("LocalData.UpgradeData")
local BackpackData = safeRequire("LocalData.BackpackData")
local DungeonData = safeRequire("LocalData.DungeonData")
local OnlineData = safeRequire("LocalData.OnlineData")
local PotionData = safeRequire("LocalData.PotionData")
local PemData = safeRequire("LocalData.PemData")
local LeftInfoGUI = safeRequire("GuiUtils.LeftInfoGUI")
local CFrameUtils = safeRequire("Utils.CFrameUtils")
local PotionConfig = safeRequire("Config.Potion.Config")
local OnlineReward = safeRequire("Config.Online.Reward")
local DamageUtils = safeRequire("SkillSystemNew.Utils.DamageUtils")

local Eco = LP:WaitForChild("Eco", 10)

local function ecoVal(name)
    if not Eco then return 0 end
    local v = Eco:FindFirstChild(name)
    if v then return v.Value or 0 end
    return 0
end

local Config = {
    autoTrain = false,
    autoOre = false,
    autoForge = false,
    forgeType = "Weapon",
    autoDungeon = false,
    autoRebirth = false,
    autoUpgrade = false,
    autoSell = false,
    sellOres = false,
    claimOnline = false,
    claimOffline = false,
    claimDaily = false,
    redeemCodes = false,
    autoPotion = false,
    atk360 = false,
    atkRadius = 25,
}

local forgeNext = 0
local dungeonNext = 0
local rebirthNext = 0
local offlineNext = 0
local dailyNext = 0
local nextCodeAttempt = 0
local claimPending = nil
local lastClaimAction = 0
local potionNext = {}
local heldPrompts = setmetatable({}, { __mode = "k" })

if DamageUtils and type(DamageUtils.AOEDamage_Self) == "function" then
    local origKey = "_ _lfAtkOrig"
    local orig = rawget(_G, origKey)
    if type(orig) ~= "function" then
        orig = DamageUtils.AOEDamage_Self
        rawset(_G, origKey, orig)
    end
    DamageUtils.AOEDamage_Self = function(c, skillName, phase, cfg, extra)
        if Config.atk360 and type(skillName) == "string" and skillName:find("ATK", 1, true) and type(cfg) == "table" then
            local r = tonumber(Config.atkRadius) or 25
            if r < 5 then r = 5 end
            cfg = {
                Size = Vector3.new(r * 2, r * 2, r * 2),
                Shape = Enum.PartType.Ball,
                Offset = Vector3.new(0, 0, 0),
                Scale = 1,
            }
        end
        return orig(c, skillName, phase, cfg, extra)
    end
end

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "+1 Loot To Forge",
    Size = UDim2.fromOffset(540, 460),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 Loot To Forge",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

local function notify(title, content, ntype)
    pcall(function()
        Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 })
    end)
end

local function bestTrainArea()
    if not TrainAreaHelper then return 1 end
    local rebirth = ecoVal("rebirth")
    local best = 1
    for id = 1, 11 do
        local ok, need = pcall(TrainAreaHelper.GetNeedRebirth, id)
        if ok and need and rebirth >= need then
            local allowed = true
            if id >= 9 then
                local okP, pem = false, false
                if PemData and PemData.isHavePem then
                    okP, pem = pcall(PemData.isHavePem, "AutoTrainArea_" .. id)
                end
                allowed = okP and pem and true or false
            end
            if allowed then best = id end
        end
    end
    return best
end

local HomeTab = Window:AddTab({ Name = "Home", Icon = "home", Subtitle = "Info" })
local HomeSub = HomeTab:AddSubTab("Info")
autosaveWrap(HomeSub)

HomeSub:AddSection("Stats")
local labelCoin = HomeSub:AddLabel({ Text = "Coin: --" })
local labelLevel = HomeSub:AddLabel({ Text = "Level: --" })
local labelRebirth = HomeSub:AddLabel({ Text = "Rebirth: --" })
local labelOre = HomeSub:AddLabel({ Text = "Ore Pack: --" })

HomeSub:AddSection("Status")
local labelDungeon = HomeSub:AddLabel({ Text = "Dungeon: Idle" })
local labelTrain = HomeSub:AddLabel({ Text = "Train: Off" })

HomeSub:AddSection("Server")
HomeSub:AddButton({
    Name = "Copy JobId",
    Callback = function()
        pcall(setclipboard, tostring(game.JobId))
        notify("Copied", "JobId copied!", "success")
    end,
})

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "pickaxe", Subtitle = "Train & Ore" })
local FarmSub = FarmTab:AddSubTab("Features")
autosaveWrap(FarmSub)

FarmSub:AddSection("Training")
FarmSub:AddToggle({
    Name = "Auto Train",
    Flag = "lf_auto_train",
    Default = false,
    Callback = function(v)
        Config.autoTrain = v
        if not v then
            pcall(function() LP:SetAttribute("AutoTrainAreaID", nil) end)
        end
    end,
})
FarmSub:AddLabel({ Text = "Automatically picks the best area for your rebirth" })

FarmSub:AddSection("Ore & Forge")
FarmSub:AddToggle({
    Name = "Auto Collect Ore",
    Flag = "lf_auto_ore",
    Default = false,
    Callback = function(v) Config.autoOre = v end,
})
FarmSub:AddToggle({
    Name = "Auto Forge",
    Flag = "lf_auto_forge",
    Default = false,
    Callback = function(v) Config.autoForge = v end,
})
local forgeDropdown = FarmSub:AddDropdown({
    Name = "Forge Type",
    Options = { "Weapon", "Armor" },
    Default = Config.forgeType,
    Flag = "lf_forge_type",
    Callback = function(v)
        if v == "Weapon" or v == "Armor" then Config.forgeType = v end
    end,
})
FarmSub:AddLabel({ Text = "Forge runs when you have 4+ ores" })

FarmSub:AddSection("Attack")
FarmSub:AddToggle({
    Name = "360Â° Wide Attack",
    Flag = "lf_atk_360",
    Default = false,
    Callback = function(v) Config.atk360 = v end,
})
FarmSub:AddSlider({
    Name = "Attack Radius",
    Min = 10,
    Max = 100,
    Default = 25,
    Suffix = " studs",
    Flag = "lf_atk_radius",
    Callback = function(v) Config.atkRadius = v end,
})
FarmSub:AddLabel({ Text = "Hits in every direction around your character" })

local DungeonTab = Window:AddTab({ Name = "Dungeon", Icon = "swords", Subtitle = "Combat" })
local DungeonSub = DungeonTab:AddSubTab("Features")
autosaveWrap(DungeonSub)

DungeonSub:AddSection("Dungeon")
DungeonSub:AddToggle({
    Name = "Auto Dungeon",
    Flag = "lf_auto_dungeon",
    Default = false,
    Callback = function(v) Config.autoDungeon = v end,
})
DungeonSub:AddToggle({
    Name = "Auto Claim Daily Ticket",
    Flag = "lf_claim_daily",
    Default = false,
    Callback = function(v) Config.claimDaily = v end,
})
DungeonSub:AddLabel({ Text = "Enters the latest round automatically + auto attack" })

local ProgressTab = Window:AddTab({ Name = "Progress", Icon = "trending-up", Subtitle = "Growth" })
local ProgressSub = ProgressTab:AddSubTab("Features")
autosaveWrap(ProgressSub)

ProgressSub:AddSection("Rebirth")
ProgressSub:AddToggle({
    Name = "Auto Rebirth",
    Flag = "lf_auto_rebirth",
    Default = false,
    Callback = function(v) Config.autoRebirth = v end,
})

ProgressSub:AddSection("Upgrades")
ProgressSub:AddToggle({
    Name = "Auto Buy Upgrades",
    Flag = "lf_auto_upgrade",
    Default = false,
    Callback = function(v) Config.autoUpgrade = v end,
})
ProgressSub:AddLabel({ Text = "Buys Luck / OrePack / Train while coin is enough" })

ProgressSub:AddSection("Sell")
ProgressSub:AddToggle({
    Name = "Auto Sell Gear",
    Flag = "lf_auto_sell",
    Default = false,
    Callback = function(v) Config.autoSell = v end,
})
ProgressSub:AddToggle({
    Name = "Auto Sell Ores",
    Flag = "lf_sell_ores",
    Default = false,
    Callback = function(v) Config.sellOres = v end,
})
ProgressSub:AddLabel({ Text = "Materials (tickets) are never sold" })

local RewardsTab = Window:AddTab({ Name = "Rewards", Icon = "gift", Subtitle = "Claim" })
local RewardsSub = RewardsTab:AddSubTab("Features")
autosaveWrap(RewardsSub)

RewardsSub:AddSection("Claims")
RewardsSub:AddToggle({
    Name = "Auto Claim Online Reward",
    Flag = "lf_claim_online",
    Default = false,
    Callback = function(v) Config.claimOnline = v end,
})
RewardsSub:AddToggle({
    Name = "Auto Claim Offline Reward",
    Flag = "lf_claim_offline",
    Default = false,
    Callback = function(v) Config.claimOffline = v end,
})
RewardsSub:AddToggle({
    Name = "Auto Redeem Codes",
    Flag = "lf_redeem_codes",
    Default = false,
    Callback = function(v) Config.redeemCodes = v end,
})

RewardsSub:AddSection("Potion")
RewardsSub:AddToggle({
    Name = "Auto Use Potion",
    Flag = "lf_auto_potion",
    Default = false,
    Callback = function(v) Config.autoPotion = v end,
})

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
autosaveWrap(ConfigSub)

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "lf_config_selected",
    Callback = function(v) selectedConfig = v end,
})

local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
        configDropdown:Refresh()
    end
end

local configInput = ConfigSub:AddInput({
    Name = "Config Name",
    Default = "",
    Placeholder = "Enter config name...",
    Flag = "lf_config_name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            notify("Config", "Enter a name first!", "warning")
            return
        end
        local ok = Library:SaveConfig(name)
        if ok then
            refreshConfigList()
            notify("Config", "Saved: " .. name, "success")
        else
            notify("Config", "Save failed!", "error")
        end
    end,
})

ConfigSub:AddButton({
    Name = "Load Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning")
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Failed to load!", "error")
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning")
            return
        end
        Library:DeleteConfig(selectedConfig)
        local old = selectedConfig
        selectedConfig = ""
        refreshConfigList()
        notify("Config", "Deleted: " .. old, "info")
    end,
})

ConfigSub:AddDivider()
ConfigSub:AddSection("Info")
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })
ConfigSub:AddLabel({ Text = "Toggle Menu: RightShift" })

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

local function trainSync()
    if not Config.autoTrain then return end
    local want = bestTrainArea()
    local cur = LP:GetAttribute("AutoTrainAreaID")
    local running = false
    if TrainCTRL then
        local okR, r = pcall(TrainCTRL.GetIsAutoing)
        running = okR and r or false
    end
    if cur == want and running then return end
    local okArea = false
    pcall(function()
        local f1 = workspace:FindFirstChild("CanAttackFolder")
        local f2 = f1 and f1:FindFirstChild("TrainArea")
        okArea = f2 ~= nil and f2:FindFirstChild("Train_" .. want) ~= nil
    end)
    if not okArea then return end
    if cur ~= nil then
        pcall(function() LP:SetAttribute("AutoTrainAreaID", nil) end)
        task.wait(0.1)
    end
    pcall(function() LP:SetAttribute("AutoTrainAreaID", want) end)
end

local function oreTick()
    if not Config.autoOre or not LeftInfoGUI then return end
    local okP, pack = pcall(LeftInfoGUI.GetOrePack)
    local okM, cap = pcall(UpgradeData.GetMaxNum, "OrePack")
    if okP and okM and pack and cap and cap > 0 and pack >= cap then return end
    local oc = workspace:FindFirstChild("OreCache")
    if not oc then return end
    local now = tick()
    for _, d in ipairs(oc:GetDescendants()) do
        if d:IsA("ProximityPrompt") and now >= (heldPrompts[d] or 0) then
            heldPrompts[d] = now + 1.5
            pcall(function()
                d.MaxDistance = 9999
                d:InputHoldBegin()
            end)
            task.delay(0.6, function()
                pcall(function() d:InputHoldEnd() end)
            end)
        end
    end
end

local function forgeTick()
    if not Config.autoForge or not ForgeRF then return end
    local now = tick()
    if now < forgeNext then return end
    local okD, data = pcall(BackpackData.GetData)
    if not okD or not data or not data.have then return end
    local stacks = {}
    for uuid, item in pairs(data.have) do
        if item.Type == "Ore" then
            stacks[#stacks + 1] = { uuid = uuid, n = tonumber(item.Number) or 1 }
        end
    end
    if #stacks == 0 then
        forgeNext = now + 3
        return
    end
    table.sort(stacks, function(a, b) return a.n > b.n end)
    local list, total = {}, 0
    for i = 1, math.min(#stacks, 4) do
        list[stacks[i].uuid] = stacks[i].n
        total = total + stacks[i].n
    end
    if total < 4 then
        forgeNext = now + 3
        return
    end
    local ok, res = pcall(function()
        return ForgeRF:InvokeServer({ ConfigType = Config.forgeType, UUIDList = list })
    end)
    if ok and res then
        forgeNext = now + 3
        notify("Forge", "Forged " .. Config.forgeType .. "!", "success")
    else
        forgeNext = now + 2
    end
end

local function dungeonEnter()
    if not Config.autoDungeon or not DungeonData then return end
    if LP:GetAttribute("Dungeoning") then return end
    local now = tick()
    if now < dungeonNext then return end
    dungeonNext = now + 6
    local round = 1
    pcall(function() round = DungeonData.GetMaxRound() + 1 end)
    local ok, res = pcall(DungeonData.TryIntoDungeon, round)
    if ok and res then
        notify("Dungeon", "Entered round " .. tostring(round), "success")
    end
end

local function dungeonCombat()
    if not Config.autoDungeon then return end
    if not LP:GetAttribute("Dungeoning") then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end
    local best, bestPivot = nil, nil
    pcall(function()
        local ef = workspace:FindFirstChild("EnemyFolder")
        if not ef then return end
        for _, e in ipairs(ef:GetChildren()) do
            if not e:GetAttribute("Dead") then
                local pp = e.PrimaryPart
                if pp then
                    local d = (pp.Position - hrp.Position).Magnitude
                    if not best or d < best then
                        best = d
                        if e:IsA("Model") then
                            bestPivot = e:GetPivot()
                        else
                            bestPivot = CFrame.new(pp.Position)
                        end
                    end
                end
            end
        end
    end)
    if not bestPivot then return end
    if CFrameUtils then
        pcall(function()
            char:PivotTo(CFrameUtils.FaceToCF(char:GetPivot(), bestPivot))
        end)
    end
    if best and best > 10 then
        pcall(function() hum:MoveTo(bestPivot.Position) end)
    end
    if ATKOnceBE then
        pcall(function() ATKOnceBE:Fire() end)
    end
end

local function rebirthTick()
    if not Config.autoRebirth or not RebirthHelper or not RebirthRE then return end
    local now = tick()
    if now < rebirthNext then return end
    local rebirth = ecoVal("rebirth")
    local level = ecoVal("level")
    local okM, isMax = pcall(RebirthHelper.CheckIsMax, rebirth)
    if okM and isMax then return end
    local okN, need = pcall(RebirthHelper.GetNeedLevel, rebirth + 1)
    if okN and need and need > 0 and level >= need then
        pcall(function() RebirthRE:FireServer() end)
        rebirthNext = now + 3
        notify("Rebirth", "Rebirth triggered!", "success")
    end
end

local upgradeIds = { "Luck", "OrePack", "Train" }

local function upgradeTick()
    if not Config.autoUpgrade or not UpgradeData or not UpgradeHelper then return end
    local coin = ecoVal("coin")
    for _, id in ipairs(upgradeIds) do
        local okL, level = pcall(UpgradeData.GetLevel, id)
        if okL and level then
            local okM, isMax = pcall(UpgradeHelper.CheckIsMax, id, level)
            if not (okM and isMax) then
                local okP, price = pcall(UpgradeHelper.GetPrice, id, level + 1)
                if okP and price and price > 0 and coin >= price then
                    pcall(UpgradeData.UpgradeOnce, id)
                    return
                end
            end
        end
    end
end

local function sellTick()
    if not Config.autoSell and not Config.sellOres then return end
    if not BackpackData then return end
    local okD, data = pcall(BackpackData.GetData)
    if not okD or not data or not data.have then return end
    for uuid, item in pairs(data.have) do
        local typ = item.Type
        local sell
        if typ == "Ore" then
            sell = Config.sellOres
        else
            sell = Config.autoSell and typ ~= "Material"
        end
        if sell then
            local okE, equipped = pcall(BackpackData.IsEquipedUUID, uuid)
            if not (okE and equipped) then
                pcall(BackpackData.TrySellItem, uuid, 9999)
                return
            end
        end
    end
end

local CODES = { "30000CCU", "20000CCU", "50000CCU" }
local codeQueue = {}

local function claimsTick()
    local now = tick()
    if claimPending then
        if claimPending.kind == "online" then
            local okD, data = pcall(OnlineData.GetData)
            local acked = okD and type(data) == "table" and data.Reward
                and (data.Reward[claimPending.key] or data.Reward[tostring(claimPending.key)])
            if acked then
                claimPending = nil
            elseif now >= claimPending.deadline then
                claimPending = nil
            else
                return
            end
        elseif claimPending.kind == "daily" then
            local ok, claimed = pcall(DungeonData.CheckTodayClaimed)
            if ok and claimed then
                claimPending = nil
            elseif now >= claimPending.deadline or not ok then
                claimPending = nil
            else
                return
            end
        else
            claimPending = nil
        end
    end
    if now - lastClaimAction < 0.4 then return end
    if Config.claimOnline and OnlineData and OnlineReward then
        local okD, data = pcall(OnlineData.GetData)
        local okT, times = pcall(OnlineData.GetOnlineTimes)
        if okD and okT and type(data) == "table" then
            local bestKey, bestN = nil, math.huge
            for key, cfg in pairs(OnlineReward) do
                local claimed = data.Reward and (data.Reward[key] or data.Reward[tostring(key)])
                if not claimed and times >= (tonumber(cfg.Time) or 0) then
                    local n = tonumber(key)
                    if n and n < bestN then
                        bestKey, bestN = key, n
                    end
                end
            end
            if bestKey then
                pcall(OnlineData.TryClaim, bestKey)
                claimPending = { kind = "online", key = bestKey, deadline = now + 4 }
                lastClaimAction = now
                return
            end
        end
    end
    if Config.claimOffline and OfflineRE and now >= offlineNext then
        offlineNext = now + 60
        lastClaimAction = now
        pcall(function() OfflineRE:FireServer() end)
        return
    end
    if Config.claimDaily and DungeonData and now >= dailyNext then
        dailyNext = now + 30
        lastClaimAction = now
        local ok, claimed = pcall(DungeonData.CheckTodayClaimed)
        if ok and not claimed then
            pcall(DungeonData.TryClaimDailyDunTic)
            claimPending = { kind = "daily", deadline = now + 4 }
        end
        return
    end
    if Config.redeemCodes and CodeRF and now >= nextCodeAttempt then
        if #codeQueue == 0 then
            for i = #CODES, 1, -1 do
                table.insert(codeQueue, CODES[i])
            end
        end
        local code = table.remove(codeQueue)
        pcall(CodeRF.InvokeServer, CodeRF, code)
        if #codeQueue == 0 then
            nextCodeAttempt = now + 120
        else
            nextCodeAttempt = now + 0.6
        end
        lastClaimAction = now
        return
    end
    if Config.autoPotion and PotionConfig and PotionData then
        for name in pairs(PotionConfig) do
            if now >= (potionNext[name] or 0) then
                potionNext[name] = now + 280
                lastClaimAction = now
                pcall(PotionData.UsePotion, name, 1)
                return
            end
        end
    end
end

task.spawn(function()
    while not isTomb() do
        pcall(trainSync)
        pcall(forgeTick)
        pcall(dungeonEnter)
        pcall(rebirthTick)
        pcall(upgradeTick)
        pcall(sellTick)
        pcall(claimsTick)
        pcall(function()
            labelCoin:Set("Coin: " .. tostring(math.floor(ecoVal("coin"))))
            labelLevel:Set("Level: " .. tostring(ecoVal("level")))
            labelRebirth:Set("Rebirth: " .. tostring(ecoVal("rebirth")))
            local pack = LeftInfoGUI and LeftInfoGUI.GetOrePack() or 0
            local cap = UpgradeData and UpgradeData.GetMaxNum("OrePack") or 0
            labelOre:Set("Ore Pack: " .. tostring(pack) .. "/" .. tostring(cap))
            local dung = LP:GetAttribute("Dungeoning")
            labelDungeon:Set("Dungeon: " .. (dung and "In Combat" or "Idle"))
            local area = LP:GetAttribute("AutoTrainAreaID")
            labelTrain:Set("Train: " .. (area and ("Area " .. tostring(area)) or "Off"))
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while not isTomb() do
        pcall(oreTick)
        pcall(dungeonCombat)
        task.wait(0.25)
    end
end)

print("[ExlumiaaHub] Loot To Forge Hub loaded!")