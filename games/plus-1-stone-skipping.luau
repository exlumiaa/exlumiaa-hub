if tostring(game.GameId) ~= "10765298801" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _ssTomb"
local _G_GEN = "_ _ssGen"

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
    local old = rawget(_G, "_ _ssConns")
    if type(old) == "table" then
        for _, c in ipairs(old) do
            pcall(function() c:Disconnect() end)
        end
    end
    rawset(_G, "_ _ssConns", CONNS)
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

-- ================================================================
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_stoneskipping.txt"
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
        local old = pg:FindFirstChild("StoneSkipKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "StoneSkipKeyGate"
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
        title.Text = "+1 Stone Skipping"
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
    autoThrow = false,
    autoPractice = false,
    autoRebirth = false,
    autoGift = false,
    autoPotion = false,
    autoHatch = false,
    hatchEgg = "Any",
}
rawset(_G, "_stoneSkipConfig", Config)

local notifyHub

-- ================================================================
-- CORE: remote, API table, state
-- ================================================================
local net = ReplicatedStorage:WaitForChild("SkippingNetwork", 10)
local ev = net and net:WaitForChild("Event", 5)

local State = {}
local lastReject = nil
local lastPracticeZone = nil

if ev and ev:IsA("RemoteEvent") then
    CONNS[#CONNS + 1] = ev.OnClientEvent:Connect(function(action, payload)
        if action == "State" and type(payload) == "table" then
            for k, v in pairs(payload) do
                State[k] = v
            end
        elseif type(payload) == "table" then
            if action == "Notice" then
                if payload.Success == false then
                    lastReject = { msg = tostring(payload.Message or ""), t = os.clock() }
                end
            elseif action == "PracticeStarted" and payload.UserId == LP.UserId then
                State.Activity = "Practice"
                lastPracticeZone = payload.ZoneId
            elseif action == "PracticeStopped" and payload.UserId == LP.UserId then
                State.Activity = "Idle"
            elseif action == "GiftRewardResult" and payload.Success then
                if notifyHub then
                    notifyHub({ Title = "+1 Stone Skipping", Content = tostring(payload.Message or "Reward claimed!"), Type = "success", Duration = 3 })
                end
            end
        end
    end)
end

local rq = net and net:FindFirstChild("Request")
local lastSyncReq = 0
local function requestSync()
    if not rq or os.clock() - lastSyncReq < 6 then return end
    lastSyncReq = os.clock()
    pcall(function() rq:FireServer("Sync", nil) end)
end

local API
local function ensureAPI()
    if API and type(API.BeginThrow) == "function" then return API end
    local ok, res = pcall(function()
        return filtergc("table", { Keys = { "BeginThrow", "ClaimGift", "UsePotion", "Rebirth" } }, true)
    end)
    if ok and type(res) == "table" then
        API = res
        return API
    end
    return nil
end

requestSync()

local GameBalance, GiftRewardsMod
local function ensureMods()
    if not GameBalance then
        pcall(function() GameBalance = require(ReplicatedStorage.Shared.Config.GameBalance) end)
    end
    if not GiftRewardsMod then
        pcall(function() GiftRewardsMod = require(ReplicatedStorage.Shared.Util.GiftRewards) end)
    end
    return GameBalance ~= nil, GiftRewardsMod ~= nil
end

local WorldMapMod
local passOwned = {}
local function passOwnedOnce(id)
    local v = passOwned[id]
    if v ~= nil then return v end
    local ok, owns = pcall(function()
        return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LP.UserId, id)
    end)
    if ok and type(owns) == "boolean" then
        passOwned[id] = owns
        return owns
    end
    return false
end

local function getPracticeZones()
    if not WorldMapMod then
        local ok, m = pcall(function() return require(ReplicatedStorage.Shared.Util.WorldMap) end)
        if not ok or type(m) ~= "table" then return nil end
        WorldMapMod = m
    end
    local ok, cfg = pcall(WorldMapMod.GetConfig, LP)
    if not ok or type(cfg) ~= "table" or type(cfg.Practice) ~= "table" then return nil end
    ensureMods()
    local pr = cfg.Practice
    local passes = GameBalance and GameBalance.TrainingPasses or {}
    local list = {}
    for name, bonus in pairs(pr.ZoneBonuses or {}) do
        if type(bonus) == "number" then
            list[#list + 1] = {
                name = name,
                req = tonumber((pr.ZoneRequiredRebirths or {})[name]) or 0,
                bonus = bonus,
                passId = tonumber(passes[name]) or nil,
            }
        end
    end
    table.sort(list, function(a, b) return a.bonus > b.bonus end)
    return { worldId = tostring(cfg.Id), list = list }
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

local function worldRoot()
    local sw = workspace:FindFirstChild("SkippingWorlds")
    if not sw then return nil end
    local attr = LP:GetAttribute("SkippingWorld")
    if attr then
        local w = sw:FindFirstChild(attr)
        if w then return w end
    end
    local kids = sw:GetChildren()
    return kids[1]
end

local function launchZonePart()
    local w = worldRoot()
    return w and w:FindFirstChild("LaunchZone")
end

local function trainingStand(zoneName)
    local w = worldRoot()
    local tz = w and w:FindFirstChild("TrainingZones")
    local z = tz and tz:FindFirstChild(zoneName)
    if not z then return nil end
    return z:FindFirstChild("TrainingStand")
end

local function partPos(p)
    if p:IsA("BasePart") then return p.Position end
    return p:GetPivot().Position
end

local eggOptions
local function ensureEggOptions()
    if eggOptions then return eggOptions end
    local opts = { "Any" }
    local ok, Worlds = pcall(function() return require(ReplicatedStorage.Shared.Config.Worlds) end)
    if ok and type(Worlds) == "table" and type(Worlds.Definitions) == "table" then
        local seen, list = {}, {}
        for _, def in ipairs(Worlds.Definitions) do
            for _, id in ipairs(def.EggIds or {}) do
                if type(id) == "string" and not seen[id] then
                    seen[id] = true
                    list[#list + 1] = id
                end
            end
        end
        table.sort(list)
        for _, id in ipairs(list) do
            opts[#opts + 1] = id
        end
    end
    eggOptions = opts
    return opts
end

-- ================================================================
-- LOOP: AUTO THROW
-- ================================================================
task.spawn(function()
    local lastTP = 0
    while _alive() do
        if Config.autoThrow and not Config.autoPractice then
            pcall(function()
                local api = ensureAPI()
                local char, hrp = getChar()
                local lz = launchZonePart()
                if api and char and hrp and lz then
                    local pos = partPos(lz)
                    if (hrp.Position - pos).Magnitude > 6 and os.clock() - lastTP > 1 then
                        lastTP = os.clock()
                        char:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
                    end
                    if State.Activity == "Idle" then
                        api.BeginThrow()
                    end
                end
            end)
        end
        task.wait(0.4)
    end
end)

-- ================================================================
-- LOOP: AUTO PRACTICE (probe zones best -> worst for my rebirths)
-- ================================================================
task.spawn(function()
    local zonesCache = nil
    local lastPickRebirths = nil
    local notifiedZone = nil
    local notifiedFail = nil
    while _alive() do
        if Config.autoPractice and not Config.autoThrow then
            pcall(function()
                local zones = getPracticeZones()
                if not zones or #zones.list == 0 then return end
                if not zonesCache or zonesCache.worldId ~= zones.worldId then
                    zonesCache = zones
                    lastPickRebirths = nil
                end
                local reb = tonumber(State.Rebirths) or 0
                local practicing = State.Activity == "Practice"
                if practicing and reb == lastPickRebirths then return end
                local pick = nil
                for _, z in ipairs(zonesCache.list) do
                    if reb >= z.req then
                        if not z.passId or passOwnedOnce(z.passId) then
                            pick = z
                            break
                        end
                    end
                end
                if not pick then return end
                lastPickRebirths = reb
                local stand = trainingStand(pick.name)
                local char = getChar()
                if not stand or not char then return end
                local rejectBefore = lastReject
                char:PivotTo(CFrame.new(partPos(stand) + Vector3.new(0, 3, 0)))
                local t0 = os.clock()
                local rejectMsg = nil
                while os.clock() - t0 < 3 do
                    if not _alive() or not Config.autoPractice or Config.autoThrow then return end
                    if State.Activity == "Practice" then
                        local zid = lastPracticeZone or pick.name
                        if notifiedZone ~= zid then
                            notifiedZone = zid
                            if notifyHub then
                                notifyHub({ Title = "+1 Stone Skipping", Content = "Training at " .. tostring(zid), Type = "success", Duration = 3 })
                            end
                        end
                        return
                    end
                    if lastReject ~= rejectBefore then
                        rejectMsg = lastReject.msg
                    end
                    task.wait(0.3)
                end
                local failKey = pick.name .. "@" .. reb
                if notifiedFail ~= failKey then
                    notifiedFail = failKey
                    if notifyHub then
                        notifyHub({ Title = "+1 Stone Skipping", Content = "Cannot train at " .. pick.name .. (rejectMsg and (": " .. rejectMsg) or ""), Type = "warning", Duration = 4 })
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- ================================================================
-- LOOP: AUTO REBIRTH
-- ================================================================
task.spawn(function()
    local lastAttempt = 0
    local prevRebirths = tonumber(State.Rebirths) or 0
    while _alive() do
        pcall(function()
            local reb = tonumber(State.Rebirths) or 0
            if reb ~= prevRebirths then
                if reb > prevRebirths and prevRebirths > 0 and notifyHub then
                    notifyHub({ Title = "+1 Stone Skipping", Content = "Rebirth complete (x" .. reb .. ")", Type = "success", Duration = 3 })
                end
                prevRebirths = reb
            end
            if Config.autoRebirth then
                local api = ensureAPI()
                if not api then return end
                local lvl = tonumber(State.Level)
                local nextLvl = tonumber(State.NextRebirthLevel)
                local act = State.Activity
                if lvl and nextLvl and lvl >= nextLvl and (act == "Idle" or act == "Practice") and os.clock() - lastAttempt > 3 then
                    lastAttempt = os.clock()
                    api.Rebirth(reb)
                end
            end
        end)
        task.wait(2)
    end
end)

-- ================================================================
-- LOOP: AUTO CLAIM PLAYTIME REWARD
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoGift then
            pcall(function()
                local okB, okG = ensureMods()
                local api = ensureAPI()
                if not (okB and okG and api) then return end
                if type(State.GiftClaimed) ~= "table" then requestSync() return end
                local now = workspace:GetServerTimeNow()
                local count = #GameBalance.GiftRewards.Rewards
                for i = 1, count do
                    local ok, r = pcall(GiftRewardsMod.GetReward, State, i, now, GameBalance.GiftRewards)
                    if ok and r == "Ready" then
                        api.ClaimGift(i)
                        task.wait(0.5)
                    end
                end
            end)
        end
        task.wait(4)
    end
end)

-- ================================================================
-- LOOP: AUTO USE POTIONS
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoPotion then
            pcall(function()
                local api = ensureAPI()
                if not api then return end
                if type(State.Potions) ~= "table" then requestSync() return end
                local now = workspace:GetServerTimeNow()
                local boosts = State.BoostExpiresAt or {}
                for id, count in pairs(State.Potions or {}) do
                    if type(count) == "number" and count > 0 then
                        local exp = tonumber(boosts[id]) or 0
                        if now >= exp then
                            api.UsePotion(id)
                            task.wait(1.2)
                            return
                        end
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- ================================================================
-- LOOP: AUTO HATCH EGG
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoHatch then
            pcall(function()
                local api = ensureAPI()
                if not api then return end
                if type(State.Eggs) ~= "table" then requestSync() return end
                local sel = Config.hatchEgg
                if sel and sel ~= "" and sel ~= "Any" then
                    local c = tonumber(State.Eggs[sel]) or 0
                    if c > 0 then
                        local started = api.HatchInventoryEgg(sel)
                        if started then
                            task.wait(3)
                        end
                    end
                    return
                end
                for id, count in pairs(State.Eggs or {}) do
                    if type(count) == "number" and count > 0 then
                        local started = api.HatchInventoryEgg(id)
                        if started then
                            task.wait(3)
                        end
                        return
                    end
                end
            end)
        end
        task.wait(2.5)
    end
end)

-- ================================================================
-- UI
-- ================================================================
local OxidelibUrl = "https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"
local Library = loadstring(game:HttpGet(OxidelibUrl))()

Library.ConfigFolder = "exlumia/stoneskipping"

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
    BrandSubtitle = "+1 Stone Skipping",
    Title = "Exlumiaa Hub",
    Logo = 72522294315389,
    Folder = "exlumia",
    ToggleKey = Enum.KeyCode.RightShift,
    AllowMultiple = false,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 Stone Skipping",
    LoadingFooter = "by Exlumiaa Hub",
    StatusText = "Exlumiaa Hub ready",
    GuiName = "ExlumiaaHub",
})

notifyHub = function(opts)
    local ok, err = pcall(function() Window:Notify(opts) end)
    if not ok then warn("[StoneSkip] notify failed: " .. tostring(err)) end
end

local MainTab = Window:AddTab({ Name = "Main", Icon = "bolt", Subtitle = "Auto Features" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })

local AutoSub = MainTab:AddSubTab("Automation")
autosaveWrap(AutoSub)

AutoSub:AddSection("Throw & Practice")
AutoSub:AddToggle({ Name = "Auto Throw", Description = "Throw stones automatically", Default = false, Flag = "ss_auto_throw", Callback = function(v)
    Config.autoThrow = v
    if v and Config.autoPractice then
        Config.autoPractice = false
        if notifyHub then notifyHub({ Title = "+1 Stone Skipping", Content = "Auto Practice turned off (conflicts with Auto Throw)", Type = "warning", Duration = 3 }) end
    end
end })
AutoSub:AddToggle({ Name = "Auto Practice", Description = "Train at the best zone for your rebirths", Default = false, Flag = "ss_auto_practice", Callback = function(v)
    Config.autoPractice = v
    if v and Config.autoThrow then
        Config.autoThrow = false
        if notifyHub then notifyHub({ Title = "+1 Stone Skipping", Content = "Auto Throw turned off (conflicts with Auto Practice)", Type = "warning", Duration = 3 }) end
    end
end })

AutoSub:AddSection("Progress")
AutoSub:AddToggle({ Name = "Auto Rebirth", Description = "Rebirth as soon as eligible", Default = false, Flag = "ss_auto_rebirth", Callback = function(v)
    Config.autoRebirth = v
end })

AutoSub:AddSection("Rewards")
AutoSub:AddToggle({ Name = "Auto Claim Reward", Description = "Claim ready playtime gifts", Default = false, Flag = "ss_auto_gift", Callback = function(v)
    Config.autoGift = v
end })
AutoSub:AddToggle({ Name = "Auto Use Potions", Description = "Use potions when no boost is active", Default = false, Flag = "ss_auto_potion", Callback = function(v)
    Config.autoPotion = v
end })
AutoSub:AddToggle({ Name = "Auto Hatch Egg", Description = "Hatch eggs from your inventory", Default = false, Flag = "ss_auto_hatch", Callback = function(v)
    Config.autoHatch = v
end })
AutoSub:AddDropdown({ Name = "Egg to Hatch", Description = "Egg used by Auto Hatch (Any = first available)", Options = ensureEggOptions(), Default = "Any", Flag = "ss_hatch_egg", Callback = function(v)
    Config.hatchEgg = v
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
pcall(refreshConfigList)

if notifyHub then
    notifyHub({ Title = "Exlumiaa Hub", Content = "+1 Stone Skipping loaded (v1)", Type = "success", Duration = 4 })
end
