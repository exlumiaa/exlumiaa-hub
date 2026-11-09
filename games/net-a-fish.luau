-- Net a Fish — Exlumiaa Hub
-- game.GameId 10771053183 (place 93898234979111)
-- Key system: Panda Auth (exlumiaa). No ESP.

if tostring(game.GameId) ~= "10771053183" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _nafHubTomb1"
local _G_GEN = "_ _nafHubGen"
local _G_COUNTER = "_ _nafHubCounter"

rawset(_G, _G_TOMB, true)

local MY_GEN = (tonumber(rawget(_G, _G_COUNTER)) or 0) + 1
rawset(_G, _G_COUNTER, MY_GEN)
rawset(_G, _G_GEN, MY_GEN)

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "NetAFishKeyGate") then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "NetAFishKeyGate") then gui:Destroy() end
        end
    end)
end

local function isStale()
    return tonumber(rawget(_G, _G_GEN)) ~= MY_GEN
end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_naf.txt"
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
        local old = pg:FindFirstChild("NetAFishKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "NetAFishKeyGate"
        sc.ResetOnSpawn = false
        sc.IgnoreGuiInset = true
        sc.DisplayOrder = 998
        sc.Parent = pg

        local accent = Color3.fromRGB(90, 200, 255)
        local accent2 = Color3.fromRGB(170, 230, 255)

        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
        overlay.BackgroundTransparency = 0.1
        overlay.BorderSizePixel = 0
        overlay.Parent = sc

        local card = Instance.new("Frame")
        card.Name = "Card"
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.fromScale(0.5, 0.5)
        card.Size = UDim2.fromOffset(360, 330)
        card.BackgroundColor3 = Color3.fromRGB(16, 21, 32)
        card.BorderSizePixel = 0
        card.Parent = sc
        local cardc = Instance.new("UICorner"); cardc.CornerRadius = UDim.new(0, 16); cardc.Parent = card
        local cardStroke = Instance.new("UIStroke"); cardStroke.Color = accent; cardStroke.Transparency = 0.6; cardStroke.Thickness = 1; cardStroke.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 42)
        title.Position = UDim2.fromOffset(0, 20)
        title.BackgroundTransparency = 1
        title.Text = "Net a Fish: Enhanced"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 22
        title.TextColor3 = Color3.fromRGB(240, 248, 255)
        title.Parent = card
        local titleGrad = Instance.new("UIGradient"); titleGrad.Rotation = -8; titleGrad.Color = ColorSequence.new(accent, Color3.fromRGB(220, 245, 255)); titleGrad.Parent = title

        local subtitle = Instance.new("TextLabel")
        subtitle.Size = UDim2.new(1, 0, 0, 16)
        subtitle.Position = UDim2.fromOffset(0, 62)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = "Enter your key to unlock"
        subtitle.Font = Enum.Font.Gotham
        subtitle.TextSize = 12
        subtitle.TextColor3 = Color3.fromRGB(150, 165, 185)
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
        keyBox.BackgroundColor3 = Color3.fromRGB(24, 31, 45)
        keyBox.BorderSizePixel = 0
        keyBox.Font = Enum.Font.GothamBold
        keyBox.TextSize = 16
        keyBox.TextColor3 = Color3.fromRGB(240, 248, 255)
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
        getBtn.TextColor3 = Color3.fromRGB(8, 16, 26)
        local verifyBtn = makeButton("Verify", 270, Color3.fromRGB(46, 58, 84))
        verifyBtn.Name = "VerifyBtn"

        local hint = Instance.new("TextLabel")
        hint.Size = UDim2.new(1, -32, 0, 30)
        hint.Position = UDim2.fromOffset(16, 268)
        hint.BackgroundTransparency = 1
        hint.Text = "Open the link, complete the ad, then paste your key."
        hint.Font = Enum.Font.Gotham
        hint.TextSize = 11
        hint.TextColor3 = Color3.fromRGB(120, 132, 150)
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
                if isStale() then
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

local Library = nil
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library then return end

Library.ConfigFolder = "exlumiaa/netafish"

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then return end

local ThrowNet = Remotes:WaitForChild("ThrowNet", 30)
local ReelIn = Remotes:WaitForChild("ReelIn", 30)
local ResolveCatch = Remotes:WaitForChild("ResolveCatch", 30)
local CatchReady = Remotes:WaitForChild("CatchReady", 30)
local BuyItem = Remotes:WaitForChild("BuyItem", 30)
local RebirthRequest = Remotes:WaitForChild("RebirthRequest", 30)
local BestSetup = Remotes:WaitForChild("BestSetup", 30)
local CollectPadReq = Remotes:WaitForChild("CollectPadReq", 30)
local GetData = Remotes:WaitForChild("GetData", 30)
local GoHome = Remotes:WaitForChild("GoHome", 30)
local Rewards = Remotes:WaitForChild("Rewards", 30)
local Contracts = Remotes:WaitForChild("Contracts", 30)
local Challenge = Remotes:WaitForChild("Challenge", 30)
local Potions = Remotes:WaitForChild("Potions", 30)

local okFS, FishingShared = pcall(function()
    return require(ReplicatedStorage:WaitForChild("FishingShared", 30))
end)
if not okFS or type(FishingShared) ~= "table" then return end

local Map = workspace:WaitForChild("Map", 30)
local Bases = Map and Map:WaitForChild("Bases", 30)
if not Bases then return end

local State = {
    autoThrow = false,
    returnDock = true,
    autoReel = false,
    waitFull = true,
    reelAfter = 25,
    autoCatch = false,
    keepNew = true,
    keepMut = true,
    keepPerfect = true,
    keepRarity = 3,
    keepValue = 0,
    autoUpgrade = false,
    autoNet = false,
    autoRebirth = false,
    autoBest = false,
    autoCollect = false,
    autoPotion = false,
    autoContracts = false,
    autoChallenges = false,
    autoRewards = false,
    antiAfk = false,
    throwInterval = 0.7,
    reelInterval = 0.8,
    catchDelay = 0.35,
    upgradeInterval = 3,
    collectInterval = 6,
    claimInterval = 15,
    bestInterval = 30,
    rebirthInterval = 6,
    reservePct = 0,
    debug = false,
}

local Window = nil

local function notify(title, content, typ)
    if not Window then return end
    pcall(function()
        Window:Notify({Title = title, Content = content, Type = typ or "info", Duration = 4})
    end)
end

local function dbg(...)
    if State.debug then
        print("[NAF]", ...)
    end
end

local tokens = {}
local lastMsg = {}

local function setLoop(key, enabled, fn, getInterval)
    State[key] = enabled
    tokens[key] = (tokens[key] or 0) + 1
    local myToken = tokens[key]
    if not enabled then
        lastMsg[key] = nil
        return
    end
    task.spawn(function()
        task.wait(0.15)
        while State[key] and tokens[key] == myToken and not isStale() do
            local pok, ok, msg = pcall(fn)
            if not pok then
                ok, msg = false, tostring(ok)
            end
            if ok then
                lastMsg[key] = nil
            elseif msg and msg ~= lastMsg[key] then
                lastMsg[key] = msg
                notify("Net a Fish", msg, "warning")
            end
            local iv = tonumber(getInterval()) or 5
            task.wait(iv > 0 and iv or 1)
        end
    end)
end

local function getChar()
    local c = LP.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if h and r and h.Health > 0 then return c, h, r end
    return nil
end

local function myBase()
    for _, b in ipairs(Bases:GetChildren()) do
        if b:GetAttribute("OwnerUserId") == LP.UserId then return b end
    end
end

local function onDock(b)
    local _, _, r = getChar()
    if not (b and r) then return false end
    if not b:FindFirstChild("Dock") and not b:FindFirstChild("Floor") then return true end
    local ok, res = pcall(function()
        return FishingShared.OnOwnDock(b, r.Position)
    end)
    return ok and res == true
end

local function goDock(b)
    local _, _, r = getChar()
    if not r then return false end
    local part = b:FindFirstChild("Dock") or b:FindFirstChild("Floor")
    if not part then return false end
    local cf = nil
    if part:IsA("BasePart") then
        cf = part.CFrame
    elseif part:IsA("Model") then
        cf = part:GetPivot()
    end
    if not cf then return false end
    r.CFrame = cf * CFrame.new(0, 4, 0)
    return true
end

local saveCache, saveAt = nil, 0

local function getSave(force)
    if not force and saveCache and os.clock() - saveAt < 8 then return saveCache end
    local ok, data = pcall(function() return GetData:InvokeServer() end)
    if ok and type(data) == "table" then
        saveCache = data
        saveAt = os.clock()
        return data
    end
    return saveCache
end

local function leaderstat(name)
    local ls = LP:FindFirstChild("leaderstats")
    local v = ls and ls:FindFirstChild(name)
    return v and v.Value
end

-- ==================== FARM ====================

local function doThrow()
    local b = myBase()
    if not b then return false, "No base found" end
    if b:GetAttribute("NetState") ~= "Idle" then return true end
    local _, _, r = getChar()
    if not r then return false, "Character not ready" end
    if not onDock(b) then
        if not State.returnDock then return false, "Not on your dock" end
        if not goDock(b) then return false, "Could not reach your dock" end
        task.wait(0.35)
        if not onDock(b) then return false, "Not on your dock" end
    end
    ThrowNet:FireServer()
    dbg("throw")
    return true
end

local function doReel()
    local b = myBase()
    if not b then return false, "No base found" end
    local st = b:GetAttribute("NetState")
    if st ~= "Out" and st ~= "Fishing" then return true end
    local count = tonumber(b:GetAttribute("NetCount")) or 0
    local cap = tonumber(b:GetAttribute("NetCap")) or 1
    local full = count >= cap
    if State.waitFull and not full then return true end
    if not full then
        local t0 = tonumber(b:GetAttribute("NetT0"))
        if t0 and (workspace:GetServerTimeNow() - t0) < State.reelAfter then return true end
    end
    ReelIn:FireServer()
    dbg("reel", count, cap)
    return true
end

local function hideCatch()
    local pg = LP:FindFirstChild("PlayerGui")
    local gui = pg and pg:FindFirstChild("CatchUI")
    if not gui then return end
    local panel = gui:FindFirstChild("CatchPanel")
    if panel then panel.Visible = false end
    local backdrop = gui:FindFirstChild("Backdrop")
    if backdrop then backdrop.Visible = false end
end

CatchReady.OnClientEvent:Connect(function(list)
    if not State.autoCatch or type(list) ~= "table" then return end
    task.delay(State.catchDelay, function()
        if not State.autoCatch or isStale() then return end
        local decisions = {}
        for _, f in ipairs(list) do
            local d = "sell"
            if (State.keepNew and f.new) or (State.keepMut and f.mu) or (State.keepPerfect and f.perfect) then
                d = "keep"
            elseif (tonumber(f.r) or 0) >= State.keepRarity then
                d = "keep"
            elseif State.keepValue > 0 and (tonumber(f.v) or 0) >= State.keepValue then
                d = "keep"
            end
            if f.uid ~= nil then
                decisions[tostring(f.uid)] = d
            end
        end
        local ok = pcall(function() ResolveCatch:FireServer(decisions) end)
        if ok then
            task.wait(0.15)
            hideCatch()
            dbg("catch resolved", #list)
        else
            notify("Auto Catch", "ResolveCatch failed", "error")
        end
    end)
end)

local function doUpgrade()
    local save = getSave()
    if not save then return false, "Profile not ready" end
    local cash = tonumber(save.Cash) or 0
    local budget = cash - cash * (State.reservePct / 100)
    local pick, pickCost = nil, nil
    for _, u in ipairs(FishingShared.Upgrades) do
        if not u.Hidden then
            local lvl = tonumber(save.Upgrades and save.Upgrades[u.Id]) or 0
            local max = tonumber(u.Max) or 0
            if lvl < max then
                local ok = FishingShared.UpgradeLevelOk(save, u, lvl + 1)
                if ok then
                    local cost = tonumber(FishingShared.UpgradeCost(u.Id, lvl)) or math.huge
                    if cost <= budget and (not pickCost or cost < pickCost) then
                        pick, pickCost = u, cost
                    end
                end
            end
        end
    end
    if pick then
        BuyItem:FireServer("Upgrade", pick.Id)
        dbg("upgrade", pick.Id, pickCost)
    end
    return true
end

local function doNet()
    local save = getSave()
    if not save then return false, "Profile not ready" end
    local tier = tonumber(save.NetTier) or 1
    local nextId = tier + 1
    local net = FishingShared.Nets[nextId]
    if not net then return true end
    if not FishingShared.NetRebirthOk(save, nextId) then return true end
    local cash = tonumber(save.Cash) or 0
    local cost = tonumber(net.Cost) or math.huge
    if cash - cash * (State.reservePct / 100) >= cost then
        BuyItem:FireServer("Net", nextId)
        dbg("net", nextId, cost)
    end
    return true
end

local lastRebirth = 0

local function doRebirth()
    if os.clock() - lastRebirth < 6 then return true end
    local save = getSave()
    if not save then return false, "Profile not ready" end
    if (tonumber(save.Rebirths) or 0) >= (FishingShared.MaxRebirth or 50) then return true end
    if FishingShared.CanRebirth(save) then
        lastRebirth = os.clock()
        RebirthRequest:FireServer()
        dbg("rebirth")
    end
    return true
end

local function doBest()
    BestSetup:FireServer()
    dbg("best setup")
    return true
end

local function doCollect()
    local b = myBase()
    if not b then return false, "No base found" end
    local peds = b:FindFirstChild("Pedestals")
    if not peds then return true end
    local _, _, r = getChar()
    if not r then return false, "Character not ready" end
    local origin = r.CFrame
    local moved = false
    for _, ped in ipairs(peds:GetChildren()) do
        local collect = ped:FindFirstChild("Collect")
        local pad = collect and collect:FindFirstChild("Pad")
        local slot = ped:GetAttribute("Slot")
        if pad and pad:IsA("BasePart") and slot ~= nil then
            local anchor = collect:FindFirstChild("LabelAnchor")
            local info = anchor and anchor:FindFirstChild("CollectInfo")
            local amount = info and info:FindFirstChild("Amount")
            local text = amount and amount.Text
            if text and text ~= "" and text ~= "$0" then
                r.CFrame = pad.CFrame + Vector3.new(0, 3, 0)
                moved = true
                task.wait(0.12)
                pcall(function() CollectPadReq:FireServer(slot) end)
                task.wait(0.08)
            end
        end
    end
    if moved then r.CFrame = origin end
    return true
end

local function setAutoPotion(on)
    pcall(function() Potions:InvokeServer("auto", on) end)
end

local afkConn = nil

local function setAntiAfk(on)
    State.antiAfk = on
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
    if on then
        afkConn = LP.Idled:Connect(function()
            if not State.antiAfk or isStale() then return end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end
end

-- ==================== PROGRESS ====================

local function doContracts()
    local ok, st = pcall(function() return Contracts:InvokeServer("state") end)
    if not ok or type(st) ~= "table" or type(st.list) ~= "table" then
        return false, "Contracts unavailable"
    end
    for i, c in ipairs(st.list) do
        if c.k ~= "wait" and (tonumber(c.p) or 0) >= (tonumber(c.goal) or math.huge) then
            pcall(function() Contracts:InvokeServer("claim", i) end)
            task.wait(0.25)
        end
    end
    return true
end

local function doChallenges()
    local ok, st = pcall(function() return Challenge:InvokeServer("state") end)
    if not ok or type(st) ~= "table" or type(st.tiers) ~= "table" then
        return false, "Challenges unavailable"
    end
    for i, t in ipairs(st.tiers) do
        if t.done and not t.claimed then
            pcall(function() Challenge:InvokeServer("claim", i) end)
            task.wait(0.25)
        end
    end
    return true
end

local function doIndexRewards()
    local save = getSave()
    if not save then return false, "Profile not ready" end
    local done = FishingShared.IndexPagesDone(save)
    local claimed = FishingShared.IndexPagesClaimed(save)
    local claimedSet = {}
    for _, page in ipairs(claimed) do claimedSet[page] = true end
    for _, page in ipairs(done) do
        if not claimedSet[page] then
            pcall(function() Rewards:InvokeServer("claimPage", page) end)
            task.wait(0.25)
        end
    end
    return true
end

-- ==================== WORLD ====================

local function teleportToBase(name)
    local b = Bases:FindFirstChild(name)
    if not b then return false, "Base not found" end
    local _, _, r = getChar()
    if not r then return false, "Character not ready" end
    local part = b:FindFirstChild("Dock") or b:FindFirstChild("Floor")
    local cf = nil
    if part and part:IsA("BasePart") then
        cf = part.CFrame
    elseif part and part:IsA("Model") then
        cf = part:GetPivot()
    else
        local okPivot, pivot = pcall(function() return b:GetPivot() end)
        cf = okPivot and pivot or nil
    end
    if not cf then return false, "No safe spot" end
    r.CFrame = cf * CFrame.new(0, 6, 0)
    return true
end

-- ==================== UI ====================

Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Net a Fish: Enhanced",
    Size = UDim2.fromOffset(520, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Net a Fish: Enhanced",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then
            v:Destroy()
        end
    end
end)

local HomeTab = Window:AddTab({Name = "Home", Icon = "home", Subtitle = "Info"})
local HomeSub = HomeTab:AddSubTab("Info")

HomeSub:AddSection("Player")
local labelPlayers = HomeSub:AddLabel({Text = "Players: --"})
local labelCash = HomeSub:AddLabel({Text = "Cash: --"})
local labelIncome = HomeSub:AddLabel({Text = "$/sec: --"})
local labelRebirths = HomeSub:AddLabel({Text = "Rebirths: --"})
local labelPearls = HomeSub:AddLabel({Text = "Pearls: --"})

HomeSub:AddSection("Net")
local labelNetState = HomeSub:AddLabel({Text = "State: --"})
local labelNetCount = HomeSub:AddLabel({Text = "Net: -- / --"})
local labelNetTier = HomeSub:AddLabel({Text = "Net tier: --"})
local labelDock = HomeSub:AddLabel({Text = "On dock: --"})

HomeSub:AddSection("Game")
HomeSub:AddLabel({Text = "GameId: " .. tostring(game.GameId)})
HomeSub:AddLabel({Text = "PlaceId: " .. tostring(game.PlaceId)})
HomeSub:AddLabel({Text = "Toggle menu: RightControl"})

local FarmTab = Window:AddTab({Name = "Farm", Icon = "hammer", Subtitle = "Auto"})
local FarmSub = FarmTab:AddSubTab("Fishing")

FarmSub:AddSection("Auto Fishing")
FarmSub:AddToggle({
    Name = "Auto Throw",
    Flag = "naf_autothrow",
    Default = false,
    Callback = function(v) setLoop("autoThrow", v, doThrow, function() return State.throwInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto Reel",
    Flag = "naf_autoreel",
    Default = false,
    Callback = function(v) setLoop("autoReel", v, doReel, function() return State.reelInterval end) end,
})
FarmSub:AddToggle({
    Name = "Wait Until Net Full",
    Flag = "naf_waitfull",
    Default = true,
    Callback = function(v) State.waitFull = v end,
})
FarmSub:AddToggle({
    Name = "Return to Dock",
    Flag = "naf_returndock",
    Default = true,
    Callback = function(v) State.returnDock = v end,
})
FarmSub:AddSlider({
    Name = "Throw Interval",
    Min = 0.3,
    Max = 3,
    Default = 0.7,
    Suffix = " s",
    Flag = "naf_throw_interval",
    Callback = function(v) State.throwInterval = v end,
})
FarmSub:AddSlider({
    Name = "Reel After",
    Min = 5,
    Max = 180,
    Default = 25,
    Suffix = " s",
    Flag = "naf_reel_after",
    Callback = function(v) State.reelAfter = v end,
})

FarmSub:AddSection("Auto Catch")
FarmSub:AddToggle({
    Name = "Auto Catch",
    Flag = "naf_autocatch",
    Default = false,
    Callback = function(v)
        State.autoCatch = v
        if v then
            notify("Auto Catch", "Decisions will be sent automatically.", "info")
        end
    end,
})
FarmSub:AddToggle({
    Name = "Keep New Species",
    Flag = "naf_keep_new",
    Default = true,
    Callback = function(v) State.keepNew = v end,
})
FarmSub:AddToggle({
    Name = "Keep Mutated",
    Flag = "naf_keep_mut",
    Default = true,
    Callback = function(v) State.keepMut = v end,
})
FarmSub:AddToggle({
    Name = "Keep Perfect",
    Flag = "naf_keep_perfect",
    Default = true,
    Callback = function(v) State.keepPerfect = v end,
})
FarmSub:AddSlider({
    Name = "Keep Rarity >=",
    Min = 1,
    Max = 20,
    Default = 3,
    Flag = "naf_keep_rarity",
    Callback = function(v) State.keepRarity = v end,
})
FarmSub:AddSlider({
    Name = "Keep Value >=",
    Min = 0,
    Max = 1000000,
    Default = 0,
    Suffix = " $",
    Flag = "naf_keep_value",
    Callback = function(v) State.keepValue = v end,
})

FarmSub:AddSection("Auto Upgrade")
FarmSub:AddToggle({
    Name = "Auto Upgrade",
    Flag = "naf_autoupgrade",
    Default = false,
    Callback = function(v) setLoop("autoUpgrade", v, doUpgrade, function() return State.upgradeInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto Net",
    Flag = "naf_autonet",
    Default = false,
    Callback = function(v) setLoop("autoNet", v, doNet, function() return State.upgradeInterval end) end,
})
FarmSub:AddSlider({
    Name = "Cash Reserve",
    Min = 0,
    Max = 90,
    Default = 0,
    Suffix = " %",
    Flag = "naf_reserve",
    Callback = function(v) State.reservePct = v end,
})
FarmSub:AddSlider({
    Name = "Upgrade Interval",
    Min = 1,
    Max = 30,
    Default = 3,
    Suffix = " s",
    Flag = "naf_upgrade_interval",
    Callback = function(v) State.upgradeInterval = v end,
})

FarmSub:AddSection("Auto Progress")
FarmSub:AddToggle({
    Name = "Auto Rebirth",
    Flag = "naf_autorebirth",
    Default = false,
    Callback = function(v) setLoop("autoRebirth", v, doRebirth, function() return State.rebirthInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto Equip Best",
    Flag = "naf_autobest",
    Default = false,
    Callback = function(v) setLoop("autoBest", v, doBest, function() return State.bestInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto Collect Pads",
    Flag = "naf_autocollect",
    Default = false,
    Callback = function(v) setLoop("autoCollect", v, doCollect, function() return State.collectInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto-Buy Potions",
    Flag = "naf_autopotion",
    Default = false,
    Callback = function(v)
        State.autoPotion = v
        setAutoPotion(v)
    end,
})
FarmSub:AddToggle({
    Name = "Anti AFK",
    Flag = "naf_antiafk",
    Default = false,
    Callback = function(v) setAntiAfk(v) end,
})

local ProgressTab = Window:AddTab({Name = "Progress", Icon = "list", Subtitle = "Claims"})
local ProgressSub = ProgressTab:AddSubTab("Claims")

ProgressSub:AddSection("Quests")
ProgressSub:AddToggle({
    Name = "Auto Contracts",
    Flag = "naf_contracts",
    Default = false,
    Callback = function(v) setLoop("autoContracts", v, doContracts, function() return State.claimInterval end) end,
})
ProgressSub:AddToggle({
    Name = "Auto Today's Challenge",
    Flag = "naf_challenges",
    Default = false,
    Callback = function(v) setLoop("autoChallenges", v, doChallenges, function() return State.claimInterval end) end,
})
ProgressSub:AddToggle({
    Name = "Auto Index Rewards",
    Flag = "naf_rewards",
    Default = false,
    Callback = function(v) setLoop("autoRewards", v, doIndexRewards, function() return State.claimInterval end) end,
})
ProgressSub:AddSlider({
    Name = "Claim Interval",
    Min = 5,
    Max = 120,
    Default = 15,
    Suffix = " s",
    Flag = "naf_claim_interval",
    Callback = function(v) State.claimInterval = v end,
})

ProgressSub:AddSection("Now")
ProgressSub:AddButton({
    Name = "Claim Contracts Now",
    Callback = function()
        local ok, err = doContracts()
        notify("Contracts", ok and "Checked." or tostring(err), ok and "success" or "warning")
    end,
})
ProgressSub:AddButton({
    Name = "Claim Today's Challenge Now",
    Callback = function()
        local ok, err = doChallenges()
        notify("Today's Challenge", ok and "Checked." or tostring(err), ok and "success" or "warning")
    end,
})
ProgressSub:AddButton({
    Name = "Claim Index Rewards Now",
    Callback = function()
        local ok, err = doIndexRewards()
        notify("Index Rewards", ok and "Checked." or tostring(err), ok and "success" or "warning")
    end,
})

local WorldTab = Window:AddTab({Name = "World", Icon = "map", Subtitle = "Travel"})
local WorldSub = WorldTab:AddSubTab("Teleport")

WorldSub:AddSection("Your Base")
WorldSub:AddButton({
    Name = "Teleport to Dock",
    Primary = true,
    Callback = function()
        local b = myBase()
        if b and goDock(b) then
            notify("Teleport", "Back on your dock.", "success")
        else
            notify("Teleport", "Could not find your dock.", "error")
        end
    end,
})
WorldSub:AddButton({
    Name = "Go Home",
    Callback = function()
        pcall(function() GoHome:FireServer() end)
        notify("Teleport", "GoHome sent.", "info")
    end,
})

WorldSub:AddSection("Bases")
local baseNames = {}
for _, b in ipairs(Bases:GetChildren()) do
    table.insert(baseNames, b.Name)
end
table.sort(baseNames)
local selectedBase = baseNames[1] or ""
WorldSub:AddDropdown({
    Name = "Base",
    Options = baseNames,
    Default = selectedBase,
    Flag = "naf_base_target",
    Callback = function(v) selectedBase = v end,
})
WorldSub:AddButton({
    Name = "Teleport to Base",
    Callback = function()
        local ok, err = teleportToBase(selectedBase)
        notify("Teleport", ok and ("Moved to " .. selectedBase) or tostring(err), ok and "success" or "error")
    end,
})

WorldSub:AddSection("Server")
WorldSub:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        notify("Rejoin", "Rejoining...", "info")
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(game.JobId), LP)
        end)
    end,
})
WorldSub:AddButton({
    Name = "Server Hop",
    Callback = function()
        notify("Server Hop", "Finding a new server...", "info")
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
    end,
})

local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})
local MiscSub = SettingsTab:AddSubTab("Misc")
local ConfigSub = SettingsTab:AddSubTab("Config")

MiscSub:AddSection("Debug")
MiscSub:AddToggle({
    Name = "Debug Log",
    Flag = "naf_debug",
    Default = false,
    Callback = function(v) State.debug = v end,
})
MiscSub:AddLabel({Text = "Toggle menu: RightControl"})

ConfigSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "naf_config_selected",
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
    Flag = "naf_config_name",
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
        if Library:SaveConfig(name) then
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
        if Library:LoadConfig(selectedConfig) then
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
        selectedConfig = ""
        refreshConfigList()
        notify("Config", "Deleted.", "info")
    end,
})

-- ==================== HUD ====================

task.spawn(function()
    while not isStale() do
        task.wait(1)
        pcall(function()
            labelPlayers:Set("Players: " .. #Players:GetPlayers())
            labelCash:Set("Cash: " .. tostring(leaderstat("Cash") or 0))
            labelIncome:Set("$/sec: " .. tostring(leaderstat("$/sec") or 0))
            labelRebirths:Set("Rebirths: " .. tostring(leaderstat("Rebirths") or 0))
            labelPearls:Set("Pearls: " .. tostring(LP:GetAttribute("Pearls") or 0))
            local b = myBase()
            if b then
                local count = tonumber(b:GetAttribute("NetCount")) or 0
                local cap = tonumber(b:GetAttribute("NetCap")) or 0
                labelNetState:Set("State: " .. tostring(b:GetAttribute("NetState")))
                labelNetCount:Set(("Net: %d / %d"):format(count, cap))
                labelNetTier:Set("Net tier: " .. tostring(b:GetAttribute("NetTier")))
                labelDock:Set("On dock: " .. (onDock(b) and "yes" or "no"))
            else
                labelNetState:Set("State: no base")
            end
        end)
    end
end)

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

getgenv()._naf = {
    state = State,
    myBase = myBase,
    getSave = getSave,
    throw = doThrow,
    reel = doReel,
    upgrade = doUpgrade,
    net = doNet,
    rebirth = doRebirth,
    collect = doCollect,
    contracts = doContracts,
    challenges = doChallenges,
    indexRewards = doIndexRewards,
    teleportToBase = teleportToBase,
}

print("[ExlumiaaHub] Net a Fish loaded")
