if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- ==================== CONFIG ====================
local BASE_URL = "https://raw.githubusercontent.com/ysron56/exlumiaa-hub/main/"
local PUSL_SERVICE_ID = "exlumiaa"
local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
local KEYSTORE_PATH = "ExlumiaHub/panda_key.txt"

-- ==================== GAME TABLE ====================
local GAMES = {
    [10503838245] = "games/pop-bubbles.luau",
}

-- ==================== PANDA AUTH ====================
local PUSL = nil

local function pxLoad()
    if PUSL then return true end
    local okGet, src = pcall(function()
        return game:HttpGet(PUSL_LIB_URL)
    end)
    if not okGet or type(src) ~= "string" or #src == 0 then
        return false
    end
    local chunk = loadstring(src)
    if type(chunk) ~= "function" then return false end
    local okCall, lib = pcall(chunk)
    if not okCall or type(lib) ~= "table" or type(lib.configure) ~= "function" then
        return false
    end
    PUSL = lib
    local okCfg = pcall(function()
        PUSL.configure({
            serviceId = PUSL_SERVICE_ID,
            debug = false,
            kickOnDetect = false,
        })
    end)
    if not okCfg then
        PUSL = nil
        return false
    end
    return true
end

local function keyReadStore()
    if type(isfile) == "function" and isfile(KEYSTORE_PATH) then
        local okData, data = pcall(readfile, KEYSTORE_PATH)
        if okData and type(data) == "string" then
            local key = string.gsub(string.sub(data, 1, 80), "%s+", "")
            if #key > 0 then return key end
        end
    end
    return nil
end

local function keyWriteStore(key)
    if type(writefile) == "function" then
        return pcall(writefile, KEYSTORE_PATH, tostring(key))
    end
    return false
end

local function keyValidate(key)
    if not pxLoad() then
        return false, "Could not load key library"
    end
    for attempt = 1, 4 do
        local okCall, ok, reason = pcall(function()
            return PUSL.validateEx(tostring(key))
        end)
        if not okCall then break end
        if ok then return true, "" end
        if reason == "INVALID_KEY" or reason == "NO_KEY" or reason == "NO_SERVICE" then
            return false, "Invalid / expired key"
        end
        task.wait(attempt * 1.5)
    end
    return false, "Network error, try again"
end

local function getKeyUrl()
    if not pxLoad() then return nil end
    local ok, link = pcall(function()
        return PUSL.getKeyUrl()
    end)
    if ok and type(link) == "string" and #link > 0 then
        return link
    end
    return nil
end

-- ==================== KEY GATE GUI ====================
local function showKeyGate(onSuccess)
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("ExlumiaKeyGate")
    if old then old:Destroy() end

    local sc = Instance.new("ScreenGui")
    sc.Name = "ExlumiaKeyGate"
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
    card.Size = UDim2.fromOffset(380, 340)
    card.BackgroundColor3 = Color3.fromRGB(18, 19, 27)
    card.BorderSizePixel = 0
    card.Parent = sc
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = accent
    cardStroke.Transparency = 0.6
    cardStroke.Thickness = 1

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 42)
    title.Position = UDim2.fromOffset(0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Exlumia Hub"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(240, 242, 250)
    title.Parent = card
    local tg = Instance.new("UIGradient", title)
    tg.Rotation = -8
    tg.Color = Sequence.new(accent, Color3.fromRGB(220, 235, 255))

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 16)
    subtitle.Position = UDim2.fromOffset(0, 62)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "One key, all scripts"
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
    keyBox.Position = UDim2.fromOffset(190, 155)
    keyBox.Size = UDim2.new(0, 332, 0, 42)
    keyBox.BackgroundColor3 = Color3.fromRGB(27, 29, 40)
    keyBox.BorderSizePixel = 0
    keyBox.Font = Enum.Font.GothamSemibold
    keyBox.TextSize = 16
    keyBox.TextColor3 = Color3.fromRGB(240, 242, 250)
    keyBox.PlaceholderText = ""
    keyBox.PlaceholderColor3 = Color3.fromRGB(110, 114, 130)
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = card
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 10)

    local function makeButton(text, posX, color)
        local btn = Instance.new("TextButton")
        btn.AnchorPoint = Vector2.new(0.5, 0.5)
        btn.Position = UDim2.fromOffset(posX, 225)
        btn.Size = UDim2.new(0, 150, 0, 42)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = card
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        return btn
    end

    local getBtn = makeButton("Get Key", 100, accent)
    getBtn.Name = "GetKeyBtn"
    local verifyBtn = makeButton("Verify", 280, Color3.fromRGB(52, 58, 82))
    verifyBtn.Name = "VerifyBtn"

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, -32, 0, 30)
    hint.Position = UDim2.fromOffset(16, 275)
    hint.BackgroundTransparency = 1
    hint.Text = "Open the link, complete the ad, then paste your key."
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 11
    hint.TextColor3 = Color3.fromRGB(120, 124, 140)
    hint.TextWrapped = true
    hint.Parent = card

    local function setStatus(msg, color)
        status.Text = msg
        status.TextColor3 = color or accent2
    end

    local validating = false
    verifyBtn.MouseButton1Click:Connect(function()
        if validating then return end
        local key = keyBox.Text
        if not key or #key < 4 then
            setStatus("Paste your key first", Color3.fromRGB(255, 100, 100))
            return
        end
        validating = true
        verifyBtn.Text = "Verifying..."
        setStatus("Checking key...", accent2)
        local ok, err = keyValidate(key)
        if ok then
            keyWriteStore(key)
            setStatus("Key valid! Loading...", Color3.fromRGB(100, 255, 120))
            task.wait(0.5)
            sc:Destroy()
            _G._hubKeyValidated = true
            onSuccess()
        else
            setStatus(err, Color3.fromRGB(255, 100, 100))
        end
        validating = false
        verifyBtn.Text = "Verify"
    end)

    getBtn.MouseButton1Click:Connect(function()
        local link = getKeyUrl()
        if link then
            if setclipboard then
                setclipboard(link)
                setStatus("Link copied! Open in browser.", accent2)
            else
                setStatus("Open: " .. link, accent2)
            end
        else
            setStatus("Could not get key link", Color3.fromRGB(255, 100, 100))
        end
    end)
end

-- ==================== GAME LOADER ====================
local function loadGameScript(gameId)
    local path = GAMES[gameId]
    if not path then
        warn("[Exlumia] Game not supported: " .. gameId)
        return false
    end
    local url = BASE_URL .. path
    local ok, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(src) ~= "string" or #src == 0 then
        warn("[Exlumia] Failed to fetch script: " .. url)
        return false
    end
    local chunk = loadstring(src)
    if type(chunk) ~= "function" then
        warn("[Exlumia] Failed to compile script")
        return false
    end
    local okRun, err = pcall(chunk)
    if not okRun then
        warn("[Exlumia] Script error: " .. tostring(err))
        return false
    end
    return true
end

-- ==================== MAIN ====================
local gameId = game.GameId
local gamePath = GAMES[gameId]

if not gamePath then
    warn("[Exlumia] This game is not supported yet. GameId: " .. gameId)
    return
end

local savedKey = keyReadStore()

local function go()
    _G._hubKeyValidated = true
    loadGameScript(gameId)
end

if savedKey then
    local ok, err = keyValidate(savedKey)
    if ok then
        go()
        return
    end
end

showKeyGate(go)
