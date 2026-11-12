-- Survive Your Ideas — Auto Write / OP Word List
-- Game: 10769671316 (places 77900175935766 / 109001332046330)
-- Key system: Panda Auth (exlumiaa).

if tostring(game.GameId) ~= "10769671316" and tostring(game.PlaceId) ~= "77900175935766" and tostring(game.PlaceId) ~= "109001332046330" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

local GEN = (tonumber(getgenv().__ugcAutoWriteGen) or 0) + 1
getgenv().__ugcAutoWriteGen = GEN

local function stale()
    return tonumber(getgenv().__ugcAutoWriteGen) ~= GEN
end

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "UGCKeyGate") then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        for _, gui in ipairs(pg and pg:GetChildren() or {}) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "UGCKeyGate") then gui:Destroy() end
        end
    end)
end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_ugc.txt"
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
        local old = pg:FindFirstChild("UGCKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "UGCKeyGate"
        sc.ResetOnSpawn = false
        sc.IgnoreGuiInset = true
        sc.DisplayOrder = 998
        sc.Parent = pg

        local accent = Color3.fromRGB(180, 120, 255)
        local accent2 = Color3.fromRGB(220, 190, 255)

        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
        overlay.BackgroundTransparency = 0.1
        overlay.BorderSizePixel = 0
        overlay.Parent = sc

        local card = Instance.new("Frame")
        card.Name = "Card"
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.fromScale(0.5, 0.5)
        card.Size = UDim2.fromOffset(360, 330)
        card.BackgroundColor3 = Color3.fromRGB(20, 16, 30)
        card.BorderSizePixel = 0
        card.Parent = sc
        local cardc = Instance.new("UICorner"); cardc.CornerRadius = UDim.new(0, 16); cardc.Parent = card
        local cardStroke = Instance.new("UIStroke"); cardStroke.Color = accent; cardStroke.Transparency = 0.6; cardStroke.Thickness = 1; cardStroke.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 42)
        title.Position = UDim2.fromOffset(0, 20)
        title.BackgroundTransparency = 1
        title.Text = "Survive Your Ideas: Enhanced"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 22
        title.TextColor3 = Color3.fromRGB(248, 242, 255)
        title.Parent = card
        local titleGrad = Instance.new("UIGradient"); titleGrad.Rotation = -8; titleGrad.Color = ColorSequence.new(accent, Color3.fromRGB(235, 215, 255)); titleGrad.Parent = title

        local subtitle = Instance.new("TextLabel")
        subtitle.Size = UDim2.new(1, 0, 0, 16)
        subtitle.Position = UDim2.fromOffset(0, 62)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = "Enter your key to unlock"
        subtitle.Font = Enum.Font.Gotham
        subtitle.TextSize = 12
        subtitle.TextColor3 = Color3.fromRGB(165, 150, 185)
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
        keyBox.BackgroundColor3 = Color3.fromRGB(30, 24, 44)
        keyBox.BorderSizePixel = 0
        keyBox.Font = Enum.Font.GothamBold
        keyBox.TextSize = 16
        keyBox.TextColor3 = Color3.fromRGB(248, 242, 255)
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
        getBtn.TextColor3 = Color3.fromRGB(12, 6, 24)
        local verifyBtn = makeButton("Verify", 270, Color3.fromRGB(56, 44, 80))
        verifyBtn.Name = "VerifyBtn"

        local hint = Instance.new("TextLabel")
        hint.Size = UDim2.new(1, -32, 0, 30)
        hint.Position = UDim2.fromOffset(16, 268)
        hint.BackgroundTransparency = 1
        hint.Text = "Open the link, complete the ad, then paste your key."
        hint.Font = Enum.Font.Gotham
        hint.TextSize = 11
        hint.TextColor3 = Color3.fromRGB(130, 115, 150)
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
                if stale() then
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

local WORDS = {
    "dragon", "blackhole", "supernova", "meteor", "asteroid", "comet", "nuke",
    "atomic", "hydrogen", "tsunami", "tornado", "hurricane", "earthquake",
    "volcano", "eruption", "lava", "magma", "blizzard", "thunderstorm",
    "lightning", "sandstorm", "acidrain", "flood", "wildfire", "apocalypse",
    "cataclysm", "armageddon", "doomsday", "extinction", "god", "titan",
    "leviathan", "kraken", "hydra", "phoenix", "grimreaper", "death", "void",
    "galaxy", "universe", "portal", "blackout", "eclipse", "singularity",
    "quantum", "antimatter", "plasma", "laser", "railgun", "mech", "robot",
    "cyborg", "alien", "ufo", "invasion", "army", "swarm", "clone", "giant",
    "colossus", "behemoth", "fortress", "shield", "forcefield", "medkit",
    "jetpack", "grappler", "timefreeze", "timestop", "freeze", "iceage",
    "inferno", "hellfire", "firestorm", "storm", "cyclone", "twister",
    "quake", "sinkhole", "avalanche", "landslide", "monsoon", "typhoon",
    "waterspout", "whirlpool", "maelstrom", "abyss", "nightmare", "shadow",
    "demon", "angel", "spirit", "zombie", "vampire", "werewolf", "dinosaur",
    "trex", "raptor", "megalodon", "sharknado", "piranha",
}

local function clean(word)
    local s = tostring(word or "")
    s = s:gsub("%s+", "")
    s = s:sub(1, 20)
    return s
end

local LobbyRemotes = ReplicatedStorage:FindFirstChild("LobbyRemotes")
local SuggestWord = LobbyRemotes and LobbyRemotes:FindFirstChild("SuggestWord")
local WriterRemotes = ReplicatedStorage:FindFirstChild("WriterRemotes")
local SubmitWord = WriterRemotes and WriterRemotes:FindFirstChild("SubmitWord")

local function remote(path)
    local node = ReplicatedStorage
    for _, part in ipairs(path) do
        node = node and node:FindFirstChild(part)
        if not node then return nil end
    end
    return node
end

local ItemsReq = remote({"Items", "Remotes", "Request"})
local MasteryReq = remote({"Mastery", "Remotes", "Request"})
local MetaReq = remote({"MetaWords", "Remotes", "Request"})
local CodesRedeem = remote({"Codes", "Redeem"})
local GroupReward = remote({"LobbyRemotes", "GroupReward"})
local SetSprint = remote({"SprintRemotes", "SetSprint"})

local function sendChat(word)
    local channels = TextChatService:FindFirstChild("TextChannels")
    local general = channels and channels:FindFirstChild("RBXGeneral")
    if not general then return false, "No chat channel" end
    local ok, err = pcall(function() return general:SendAsync(word) end)
    return ok, ok and "sent" or tostring(err)
end

local function sendSuggest(word)
    if SuggestWord then
        local ok, res = pcall(function() return SuggestWord:InvokeServer(word) end)
        return ok and res == "ok", tostring(res)
    end
    if SubmitWord then
        local ok, err = pcall(function() SubmitWord:FireServer(word) end)
        return ok, ok and "sent" or tostring(err)
    end
    return false, "No suggest remote"
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

Library.ConfigFolder = "exlumiaa/ugc"

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Survive Your Ideas: Auto Write",
    Size = UDim2.fromOffset(500, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Survive Your Ideas",
    LoadingFooter = "Auto Write",
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

local Tab = Window:AddTab({Name = "Words", Icon = "pencil", Subtitle = "Auto Write"})
local Sub = Tab:AddSubTab("Send")

Sub:AddSection("OP Word")
local selected = WORDS[1]

local customInput = Sub:AddInput({
    Name = "Custom Word",
    Default = "",
    Placeholder = "Type a word (overrides dropdown)",
    Flag = "ugc_custom_word",
})

local status = Sub:AddLabel({Text = "Ready."})

local method = "Chat"
Sub:AddDropdown({
    Name = "Method",
    Options = {"Chat", "Suggest", "Chat + Suggest"},
    Default = "Chat",
    Flag = "ugc_method",
    Callback = function(v) method = v end,
})

local function getInput()
    local ok, text = pcall(function() return customInput:Get() end)
    if ok and text and text ~= "" then return clean(text) end
    return nil
end

local function doSend(word, silent)
    word = clean(word)
    if word == "" then return false, "Empty word" end
    local results = {}
    if method == "Chat" or method == "Chat + Suggest" then
        local ok, msg = sendChat(word)
        table.insert(results, "chat:" .. tostring(msg))
        if not silent then
            status:Set("Sent to chat: " .. word .. " (" .. tostring(msg) .. ")")
        end
        if not ok and method == "Chat" then return false, table.concat(results, " | ") end
    end
    if method == "Suggest" or method == "Chat + Suggest" then
        local ok, msg = sendSuggest(word)
        table.insert(results, "suggest:" .. tostring(msg))
        if not silent then
            status:Set("Suggested: " .. word .. " (" .. tostring(msg) .. ")")
        end
        if not ok and method == "Suggest" then return false, table.concat(results, " | ") end
    end
    return true, table.concat(results, " | ")
end

local nextWord

Sub:AddButton({
    Name = "Send Word",
    Primary = true,
    Callback = function()
        local word = getInput() or nextWord()
        local ok, msg = doSend(word)
        if not ok then status:Set("Failed: " .. tostring(msg)) end
    end,
})

Sub:AddButton({
    Name = "Suggest Word",
    Callback = function()
        local word = getInput() or nextWord()
        local ok, msg = sendSuggest(word)
        status:Set((ok and "Suggested: " or "Suggest failed: ") .. word .. " (" .. tostring(msg) .. ")")
    end,
})

Sub:AddSection("Auto Write")
local autoOn = false
local autoToken = 0
local interval = 2
local cycle = true
local randomMode = false
local index = 1

nextWord = function()
    if randomMode then
        return WORDS[math.random(1, #WORDS)]
    end
    if not cycle then
        return getInput() or selected
    end
    local word = WORDS[index]
    index = index % #WORDS + 1
    return word
end

local function setAuto(on)
    autoOn = on
    autoToken = autoToken + 1
    local my = autoToken
    if not on then
        status:Set("Auto write stopped.")
        return
    end
    status:Set("Auto write started.")
    task.spawn(function()
        task.wait(0.5)
        while autoOn and autoToken == my and not stale() do
            local word = nextWord()
            local ok, msg = doSend(word, true)
            status:Set((ok and "Auto: " or "Auto failed: ") .. tostring(word) .. " (" .. tostring(msg) .. ")")
            task.wait(interval)
        end
    end)
end

Sub:AddToggle({
    Name = "Auto Write",
    Flag = "ugc_auto",
    Default = false,
    Callback = function(v) setAuto(v) end,
})

Sub:AddSlider({
    Name = "Interval",
    Min = 1,
    Max = 10,
    Default = 2,
    Suffix = " s",
    Flag = "ugc_interval",
    Callback = function(v) interval = v end,
})

Sub:AddToggle({
    Name = "Cycle Words",
    Flag = "ugc_cycle",
    Default = true,
    Callback = function(v) cycle = v end,
})

Sub:AddToggle({
    Name = "Random Word",
    Flag = "ugc_random",
    Default = false,
    Callback = function(v) randomMode = v end,
})

local SurvivalTab = Window:AddTab({Name = "Survival", Icon = "shield", Subtitle = "God Mode"})
local SurvivalSub = SurvivalTab:AddSubTab("Health")

local godOn = false
local godToken = 0

local function setGod(on)
    godOn = on
    godToken = godToken + 1
    local my = godToken
    if not on then return end
    task.spawn(function()
        while godOn and godToken == my and not stale() do
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = 1e9
                hum.Health = 1e9
            end
            task.wait(0.2)
        end
    end)
end

SurvivalSub:AddSection("Health")
SurvivalSub:AddToggle({
    Name = "God Mode",
    Flag = "ugc_god",
    Default = false,
    Callback = function(v) setGod(v) end,
})
local FarmTab = Window:AddTab({Name = "Farm", Icon = "hammer", Subtitle = "Auto"})
local FarmSub = FarmTab:AddSubTab("Items")

local function cash()
    local ls = LP:FindFirstChild("leaderstats")
    local c = ls and ls:FindFirstChild("Cash")
    return c and tonumber(c.Value) or 0
end

local function afterReserve(pct)
    local c = cash()
    return c - c * (pct / 100)
end

local spinOn = false
local spinToken = 0
local spinInterval = 3
local spinReserve = 0

local function setSpin(on)
    spinOn = on
    spinToken = spinToken + 1
    local my = spinToken
    if not on then return end
    task.spawn(function()
        while spinOn and spinToken == my and not stale() do
            if ItemsReq and afterReserve(spinReserve) >= 10000 then
                pcall(function() ItemsReq:InvokeServer("spin") end)
            end
            task.wait(spinInterval)
        end
    end)
end

FarmSub:AddSection("Item Spin")
FarmSub:AddToggle({
    Name = "Auto Spin",
    Flag = "ugc_spin",
    Default = false,
    Callback = function(v) setSpin(v) end,
})
FarmSub:AddSlider({
    Name = "Spin Interval",
    Min = 1,
    Max = 15,
    Default = 3,
    Suffix = " s",
    Flag = "ugc_spin_interval",
    Callback = function(v) spinInterval = v end,
})
FarmSub:AddSlider({
    Name = "Cash Reserve",
    Min = 0,
    Max = 90,
    Default = 0,
    Suffix = " %",
    Flag = "ugc_spin_reserve",
    Callback = function(v) spinReserve = v end,
})

local MASTERY_IDS = {"tornado", "tsunami", "nuke", "black_hole", "monster", "dinosaur", "gojo", "hero", "earthquake", "kill"}

local function claimMastery()
    if not MasteryReq then return false, "No mastery remote" end
    for _, id in ipairs(MASTERY_IDS) do
        pcall(function() MasteryReq:InvokeServer("claim", id) end)
        task.wait(0.2)
    end
    return true
end

local masteryOn = false
local masteryToken = 0

local function setMastery(on)
    masteryOn = on
    masteryToken = masteryToken + 1
    local my = masteryToken
    if not on then return end
    task.spawn(function()
        while masteryOn and masteryToken == my and not stale() do
            if (tonumber(LP:GetAttribute("MasteryReady")) or 0) > 0 then
                claimMastery()
            end
            task.wait(20)
        end
    end)
end

FarmSub:AddSection("Mastery")
FarmSub:AddToggle({
    Name = "Auto Claim Mastery",
    Flag = "ugc_mastery",
    Default = false,
    Callback = function(v) setMastery(v) end,
})
FarmSub:AddButton({
    Name = "Claim Mastery Now",
    Callback = function()
        local ok, err = claimMastery()
        status:Set(ok and "Mastery claims sent." or ("Mastery: " .. tostring(err)))
    end,
})

local META_WORDS = {
    {id = "double", cost = 250000},
    {id = "secret", cost = 250000},
    {id = "lag", cost = 400000},
    {id = "undo", cost = 400000},
    {id = "ghost", cost = 500000},
    {id = "jackpot", cost = 750000},
}
local metaOn = false
local metaToken = 0
local metaReserve = 0

local function buyMeta()
    if not MetaReq then return false, "No meta remote" end
    for _, w in ipairs(META_WORDS) do
        if afterReserve(metaReserve) >= w.cost then
            pcall(function() MetaReq:InvokeServer("buy", w.id) end)
            task.wait(0.3)
        end
    end
    return true
end

local function setMeta(on)
    metaOn = on
    metaToken = metaToken + 1
    local my = metaToken
    if not on then return end
    task.spawn(function()
        while metaOn and metaToken == my and not stale() do
            buyMeta()
            task.wait(10)
        end
    end)
end

FarmSub:AddSection("Meta Words (Cash)")
FarmSub:AddToggle({
    Name = "Auto Buy Cash Words",
    Flag = "ugc_meta",
    Default = false,
    Callback = function(v) setMeta(v) end,
})
FarmSub:AddSlider({
    Name = "Meta Cash Reserve",
    Min = 0,
    Max = 90,
    Default = 0,
    Suffix = " %",
    Flag = "ugc_meta_reserve",
    Callback = function(v) metaReserve = v end,
})
FarmSub:AddButton({
    Name = "Buy Cash Words Now",
    Callback = function()
        local ok, err = buyMeta()
        status:Set(ok and "Meta word buys sent." or ("Meta: " .. tostring(err)))
    end,
})

FarmSub:AddSection("Codes")
local codesInput = FarmSub:AddInput({
    Name = "Codes (comma separated)",
    Default = "",
    Placeholder = "code1, code2",
    Flag = "ugc_codes",
})
FarmSub:AddButton({
    Name = "Redeem Codes",
    Callback = function()
        if not CodesRedeem then status:Set("No Codes.Redeem remote.") return end
        local text = codesInput:Get() or ""
        local n = 0
        for code in string.gmatch(text, "[^,%s]+") do
            pcall(function() CodesRedeem:InvokeServer(code) end)
            n = n + 1
            task.wait(0.4)
        end
        status:Set("Redeemed " .. n .. " code(s).")
    end,
})

local UtilTab = Window:AddTab({Name = "Utility", Icon = "settings", Subtitle = "QoL"})
local UtilSub = UtilTab:AddSubTab("Character")

local sprintOn = false
local function setSprint(on)
    sprintOn = on
    if SetSprint then pcall(function() SetSprint:FireServer(on) end) end
end

UtilSub:AddSection("Movement")
UtilSub:AddToggle({
    Name = "Auto Sprint",
    Flag = "ugc_sprint",
    Default = false,
    Callback = function(v) setSprint(v) end,
})

local stamOn = false
local stamToken = 0
local function setStamina(on)
    stamOn = on
    stamToken = stamToken + 1
    local my = stamToken
    if not on then return end
    task.spawn(function()
        while stamOn and stamToken == my and not stale() do
            pcall(function() LP:SetAttribute("Stamina", 100) end)
            RunService.RenderStepped:Wait()
        end
    end)
end
UtilSub:AddToggle({
    Name = "Infinite Stamina",
    Flag = "ugc_stamina",
    Default = false,
    Callback = function(v) setStamina(v) end,
})

local afkOn = false
local afkConn = nil
local function setAfk(on)
    afkOn = on
    if afkConn then afkConn:Disconnect(); afkConn = nil end
    if on then
        afkConn = LP.Idled:Connect(function()
            if not afkOn or stale() then return end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end
end

UtilSub:AddSection("Session")
UtilSub:AddToggle({
    Name = "Anti-AFK",
    Flag = "ugc_afk",
    Default = false,
    Callback = function(v) setAfk(v) end,
})
UtilSub:AddButton({
    Name = "Claim Group Reward",
    Callback = function()
        if not GroupReward then status:Set("No GroupReward remote.") return end
        local ok, res = pcall(function() return GroupReward:InvokeServer("claim") end)
        status:Set(ok and ("Group reward: " .. tostring(res)) or ("Group reward failed: " .. tostring(res)))
    end,
})
UtilSub:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(game.JobId), LP) end)
    end,
})
UtilSub:AddButton({
    Name = "Server Hop",
    Callback = function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end,
})

pcall(function() Library:LoadConfig("default") end)

local function getState()
    return {
        auto = autoOn,
        interval = interval,
        method = method,
        random = randomMode,
        god = godOn,
        spin = spinOn,
        mastery = masteryOn,
        meta = metaOn,
        sprint = sprintOn,
        stamina = stamOn,
        afk = afkOn,
    }
end

getgenv()._ugcAutoWrite = {
    words = WORDS,
    sendChat = sendChat,
    sendSuggest = sendSuggest,
    doSend = doSend,
    state = { auto = autoOn, interval = interval, method = method, random = randomMode, god = godOn, spin = spinOn, mastery = masteryOn, meta = metaOn, sprint = sprintOn, stamina = stamOn, afk = afkOn },
    getState = getState,
    setGod = setGod,
    setRandom = function(v) randomMode = v end,
    nextWord = nextWord,
    setSpin = setSpin,
    setMastery = setMastery,
    claimMastery = claimMastery,
    setMeta = setMeta,
    buyMeta = buyMeta,
    setSprint = setSprint,
    setStamina = setStamina,
    setAfk = setAfk,
}

print("[ExlumiaaHub] Survive Your Ideas Auto Write loaded")
