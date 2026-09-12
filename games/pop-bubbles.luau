local PB_GAME_ID = 10503838245
if tostring(game.GameId) ~= tostring(PB_GAME_ID) then
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _pbCollectorTomb"
local _G_ALIVE = "_ _pbCollectorAlive"
local _G_LIB = "_ _pbCollectorLib"
local _G_GUI = "_ _pbCollectorGui"
local _G_ATTACK = "_ _pbAimlessAttack"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.6)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

if not _G._hubKeyValidated then
local PUSL_SERVICE_ID = "exlumiaa"
local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
local KEYSYSTEM_STORE_PATH = "PBCollector/panda_key_popbubbles.txt"

local PUSL = nil

local function pxLoad()
    if PUSL then
        return true
    end
    local okGet, src = pcall(function()
        return game:HttpGet(PUSL_LIB_URL)
    end)
    if not okGet or type(src) ~= "string" or #src == 0 then
        return false
    end
    local chunk = loadstring(src)
    if type(chunk) ~= "function" then
        return false
    end
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

local function ksReadStore()
    if type(isfile) == "function" and isfile(KEYSYSTEM_STORE_PATH) then
        local okData, data = pcall(readfile, KEYSYSTEM_STORE_PATH)
        if okData and type(data) == "string" then
            local key = string.gsub(string.sub(data, 1, 80), "%s+", "")
            if #key > 0 then
                return key
            end
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
    if not pxLoad() then
        return false, "Could not load Panda library (check internet)"
    end
    for attempt = 1, 4 do
        local okCall, ok, reason = pcall(function()
            return PUSL.validateEx(tostring(key))
        end)
        if not okCall then
            break
        end
        if ok then
            return true, ""
        end
        if reason == "INVALID_KEY" or reason == "NO_KEY" or reason == "NO_SERVICE" then
            return false, "Invalid / expired / wrong device key"
        end
        task.wait(attempt * 1.5)
    end
    return false, "Network / server error"
end

local function ksGetKeyLink()
    if not pxLoad() then
        return nil
    end
    local ok, link = pcall(function()
        return PUSL.getKeyUrl()
    end)
    if ok and type(link) == "string" and #link > 0 then
        return link
    end
    return nil
end

local function ksShowGate(onSuccess)
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("PBKeyGate")
    if old then
        old:Destroy()
    end

    local sc = Instance.new("ScreenGui")
    sc.Name = "PBKeyGate"
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
    local cardc = Instance.new("UICorner")
    cardc.CornerRadius = UDim.new(0, 16)
    cardc.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = accent
    cardStroke.Transparency = 0.6
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 42)
    title.Position = UDim2.fromOffset(0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Pop Bubbles Collector"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(240, 242, 250)
    title.Parent = card
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Rotation = -8
    titleGrad.Color = ColorSequence.new(accent, Color3.fromRGB(220, 235, 255))
    titleGrad.Parent = title

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
    keyBox.Font = Enum.Font.GothamSemibold
    keyBox.TextSize = 16
    keyBox.TextColor3 = Color3.fromRGB(240, 242, 250)
    keyBox.PlaceholderText = ""
    keyBox.PlaceholderColor3 = Color3.fromRGB(110, 114, 130)
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = card
    local keyBoxc = Instance.new("UICorner")
    keyBoxc.CornerRadius = UDim.new(0, 10)
    keyBoxc.Parent = keyBox

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
        local btnc = Instance.new("UICorner")
        btnc.CornerRadius = UDim.new(0, 10)
        btnc.Parent = btn
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
        if done then
            return
        end
        local key = string.gsub(keyBox.Text, "%s+", "")
        if key == "" then
            status.Text = "Enter your key first."
            return
        end
        status.Text = "Verifying..."
        task.spawn(function()
            local okVal, msg = ksValidate(key)
            if done then
                return
            end
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
        if okVal then
            unlocked = true
        end
    end
    if not unlocked then
        local gateDone = false
        local gui = ksShowGate(function()
            gateDone = true
        end)
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

local originalWalkSpeed = 16

local Config = {
    autoCollect = true,
    useTeleport = true,
    snapCamera = true,
    collectWait = 0.12,
    walkEnabled = false,
    walkSpeed = 120,
    guiKey = Enum.KeyCode.RightShift,
    collectKey = Enum.KeyCode.RightControl,
    cycleEnabled = true,
    cycleOn = 5,
    cycleOff = 5,
    aimlessAttack = true,
    tripleShot = false,
}

local autoAttackPatched = false
local origConeTest = nil

local function applyAimlessPatch()
    if autoAttackPatched then
        return true
    end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("AutoThrowController"))
    end)
    if not ok then
        return false
    end
    local cls = mod.AutoThrowController
    if type(cls) ~= "table" then
        return false
    end
    if origConeTest == nil then
        origConeTest = cls.buildConeTest
    end
    cls.buildConeTest = function(self, origin)
        if not workspace.CurrentCamera then
            return nil
        end
        return function()
            return true
        end
    end
    autoAttackPatched = true
    rawset(_G, _G_ATTACK, true)
    return true
end

local function removeAimlessPatch()
    if not autoAttackPatched then
        return
    end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("AutoThrowController"))
    end)
    if ok and mod.AutoThrowController and origConeTest then
        mod.AutoThrowController.buildConeTest = origConeTest
    end
    origConeTest = nil
    autoAttackPatched = false
    rawset(_G, _G_ATTACK, nil)
end

local cycleStart = tick()

local triplePatched = false
local origThrowFn = nil
local tripleSpreadDeg = 3

local function applyTriplePatch()
    if triplePatched then
        return true
    end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("WeaponController"))
    end)
    if not ok then
        return false
    end
    local cls = mod.WeaponController
    local inst = cls and cls.getInstance and cls:getInstance()
    if type(inst) ~= "table" or type(inst.throw) ~= "function" then
        return false
    end
    if origThrowFn == nil then
        origThrowFn = inst.throw
    end
    local spreadRad = math.rad(tripleSpreadDeg)
    local uid = LP.UserId
    inst.throw = function(self, manual, ...)
        local okCall, result = pcall(origThrowFn, self, manual, ...)
        if not Config.tripleShot then
            return okCall and result or nil
        end
        local root = self.cachedRoot
        if root then
            local okT, tp = pcall(function()
                return self:getTargetPosition(root, false, manual)
            end)
            if okT and typeof(tp) == "Vector3" then
                local off = tp - root.Position
                local dir = off.Magnitude > 0.001 and off.Unit or nil
                if dir then
                    local pivot = CFrame.new(root.Position, root.Position + dir)
                    for _, side in ipairs({ 1, -1 }) do
                        local newUnit = (pivot * CFrame.Angles(0, side * spreadRad, 0)).LookVector
                        local id = ("%*_%*"):format(uid, tick() + 0.001 * side)
                        pcall(function()
                            self.remote:FireServer(newUnit, id, false)
                        end)
                    end
                end
            end
        end
        return okCall and result or nil
    end
    triplePatched = true
    return true
end

local function removeTriplePatch()
    if not triplePatched then
        return
    end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("WeaponController"))
    end)
    local cls = ok and mod.WeaponController or nil
    local inst = cls and cls.getInstance and cls:getInstance() or nil
    if inst and origThrowFn then
        inst.throw = origThrowFn
    end
    origThrowFn = nil
    triplePatched = false
end

local autoThrowForced = false
local attackMode = nil
local attackSync = nil

local function getWeaponMods()
    local okAT, atMod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("AutoThrowController"))
    end)
    local okWC, wcMod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("WeaponController"))
    end)
    if not okAT or not okWC then
        return nil, nil
    end
    return atMod, wcMod
end

local function startAttackEngine()
    local atMod, wcMod = getWeaponMods()
    if not atMod or not wcMod then
        return false
    end
    local at = atMod.AutoThrowController:getInstance()
    local wc = wcMod.WeaponController:getInstance()
    if type(at) ~= "table" or type(wc) ~= "table" then
        return false
    end
    at:setEnabledState(true)
    if not at.targetingConnection then
        at:startTargetingLoop()
    end
    wc:setAutoThrow(true, function()
        return at:getAutoThrowTarget()
    end)
    autoThrowForced = true
    return true
end

local function stopAttackEngine()
    if not autoThrowForced then
        return
    end
    local atMod, wcMod = getWeaponMods()
    if atMod and atMod.AutoThrowController then
        local at = atMod.AutoThrowController:getInstance()
        if type(at) == "table" then
            at:setEnabledState(false)
            at:stopTargetingLoop()
        end
    end
    if wcMod and wcMod.WeaponController then
        local wc = wcMod.WeaponController:getInstance()
        if type(wc) == "table" then
            wc:setAutoThrow(false)
        end
    end
    autoThrowForced = false
end

local function applyAttackEngine()
    local ok = true
    if Config.aimlessAttack then
        Config.tripleShot = false
        removeTriplePatch()
        ok = pcall(applyAimlessPatch)
        ok = startAttackEngine() and ok
        attackMode = "aimless"
    elseif Config.tripleShot then
        ok = pcall(applyAimlessPatch)
        ok = pcall(applyTriplePatch) and ok
        ok = startAttackEngine() and ok
        attackMode = "triple"
    else
        removeAimlessPatch()
        removeTriplePatch()
        stopAttackEngine()
        attackMode = nil
    end
    if attackSync then
        pcall(attackSync, ok, attackMode)
    end
    return ok
end

task.spawn(function()
    if Config.tripleShot and Config.aimlessAttack then
        Config.tripleShot = false
    end
    task.wait(1.5)
    if rawget(_G, _G_TOMB) then
        return
    end
    pcall(applyAttackEngine)
end)

local collectedCount = 0

local dropLabel = nil
local collectedLabel = nil
local wsLabel = nil
local healthLabel = nil
local studsLabel = nil
local pingLabel = nil
local cycleLabel = nil

local function getHrp()
    local char = LP.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getDropPositions()
    local uid = LP.UserId
    local suffix = "Drops_" .. uid
    local found = {}
    for _, folder in ipairs(workspace:GetChildren()) do
        if folder:IsA("Folder") and string.sub(folder.Name, -string.len(suffix)) == suffix and string.sub(folder.Name, 1, 5) == "Local" then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    local ok, piv = pcall(function()
                        return model:GetPivot().Position
                    end)
                    if ok and piv then
                        found[#found + 1] = { id = model.Name, pos = piv, model = model }
                    end
                end
            end
        end
    end
    return found
end

local lastSeen = {}

local function scanCollect()
    local list = getDropPositions()
    local tpCount = 0
    local seen = {}
    for _, d in ipairs(list) do
        seen[d.id] = true
    end
    for id in pairs(lastSeen) do
        if not seen[id] then
            collectedCount += 1
        end
    end
    lastSeen = {}
    for _, d in ipairs(list) do
        lastSeen[d.id] = true
    end

    local hrp = getHrp()
    local cam = workspace.CurrentCamera
    if not hrp or not cam then
        return #list, 0
    end

    if Config.useTeleport then
        for _, d in ipairs(list) do
            if rawget(_G, _G_TOMB) then
                break
            end
            local hrpNow = getHrp()
            if not hrpNow then
                break
            end
            local cur = hrpNow.Position
            if (cur - d.pos).Magnitude > 12 then
                tpCount += 1
                hrpNow.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrpNow.CFrame = CFrame.new(d.pos.X, d.pos.Y + 3, d.pos.Z)
                if Config.snapCamera and cam then
                    cam.CFrame = CFrame.lookAt(d.pos + Vector3.new(0, 6, 0), d.pos)
                end
                task.wait(Config.collectWait)
            end
        end
    end

    return #list, tpCount
end

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then
            break
        end
        if Config.autoCollect then
            local ok, err = pcall(function()
                local cycleActive = true
                if Config.cycleEnabled then
                    local period = Config.cycleOn + Config.cycleOff
                    local elapsed = (tick() - cycleStart) % period
                    cycleActive = elapsed < Config.cycleOn
                end
                if cycleLabel then
                    cycleLabel:SetText("Status: " .. (cycleActive and "collecting" or "waiting"))
                end
                if cycleActive then
                    local n, tp = scanCollect()
                    rawset(_G, "_ _pbCollectorTicks", (rawget(_G, "_ _pbCollectorTicks") or 0) + 1)
                    rawset(_G, "_ _pbCollectorLast", ("drops=%d tp=%d active=true"):format(n, tp))
                if dropLabel then
                    dropLabel:SetText("Drops: " .. tostring(n))
                end
                    if collectedLabel then
                        collectedLabel:SetText("Collected: " .. tostring(collectedCount))
                    end
                else
                    rawset(_G, "_ _pbCollectorLast", "waiting")
                end
            end)
            if not ok then
                rawset(_G, "_ _pbCollectorErr", tostring(err))
            end
        end
        task.wait(0.1)
    end
end)

local loaderDone = false

do
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("PBCollectorLoader")
    if old then old:Destroy() end

    local sc = Instance.new("ScreenGui")
    sc.Name = "PBCollectorLoader"
    sc.ResetOnSpawn = false
    sc.IgnoreGuiInset = true
    sc.DisplayOrder = 999
    sc.Parent = pg

    local accent = Color3.fromRGB(120, 96, 255)
    local accent2 = Color3.fromRGB(180, 160, 255)

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(9, 10, 15)
    overlay.BackgroundTransparency = 0.15
    overlay.BorderSizePixel = 0
    overlay.Parent = sc

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(380, 230)
    card.BackgroundColor3 = Color3.fromRGB(18, 19, 27)
    card.BorderSizePixel = 0
    card.Parent = sc
    local cardc = Instance.new("UICorner")
    cardc.CornerRadius = UDim.new(0, 16)
    cardc.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = accent
    cardStroke.Transparency = 0.65
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 44)
    title.Position = UDim2.fromOffset(0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Pop Bubbles Collector"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(240, 242, 250)
    title.Parent = card
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Rotation = -8
    titleGrad.Color = ColorSequence.new(accent, Color3.fromRGB(220, 235, 255))
    titleGrad.Parent = title

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 18)
    subtitle.Position = UDim2.fromOffset(0, 68)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Loading libraries"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextColor3 = Color3.fromRGB(150, 155, 172)
    subtitle.Parent = card

    local spinner = Instance.new("Frame")
    spinner.Size = UDim2.fromOffset(60, 60)
    spinner.Position = UDim2.new(0.5, -30, 0, 96)
    spinner.BackgroundTransparency = 1
    spinner.Parent = card
    local segs = {}
    for i = 1, 12 do
        local s = Instance.new("Frame")
        s.AnchorPoint = Vector2.new(0.5, 0.5)
        local ang = math.rad((i - 1) * 30)
        s.Position = UDim2.fromOffset(30 + math.cos(ang) * 25, 30 + math.sin(ang) * 25)
        s.Size = UDim2.fromOffset(5, 5)
        s.BackgroundColor3 = accent2
        s.BorderSizePixel = 0
        s.Parent = spinner
        local sc2 = Instance.new("UICorner")
        sc2.CornerRadius = UDim.new(1, 0)
        sc2.Parent = s
        segs[i] = s
    end

    local barBg = Instance.new("Frame")
    barBg.AnchorPoint = Vector2.new(0.5, 0.5)
    barBg.Position = UDim2.fromOffset(190, 172)
    barBg.Size = UDim2.fromOffset(320, 10)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
    barBg.BorderSizePixel = 0
    barBg.Parent = card
    local barBgc = Instance.new("UICorner")
    barBgc.CornerRadius = UDim.new(1, 0)
    barBgc.Parent = barBg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromScale(0, 1)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.Parent = barBg
    local barc = Instance.new("UICorner")
    barc.CornerRadius = UDim.new(1, 0)
    barc.Parent = bar
    local barGrad = Instance.new("UIGradient")
    barGrad.Color = ColorSequence.new(accent, accent2)
    barGrad.Parent = bar

    local pct = Instance.new("TextLabel")
    pct.Size = UDim2.fromOffset(80, 16)
    pct.Position = UDim2.new(0.5, -40, 0, 186)
    pct.BackgroundTransparency = 1
    pct.Text = "0%"
    pct.Font = Enum.Font.GothamSemibold
    pct.TextSize = 13
    pct.TextColor3 = accent2
    pct.Parent = card

    local steps = { "Loading libraries", "Building interface", "Starting collector" }
    local start = tick()
    local DUR = 2.6
    task.spawn(function()
        local segIndex = 0
        while true do
            local now = tick()
            local t = math.clamp((now - start) / DUR, 0, 1)
            segIndex = segIndex + 1
            for i, s in ipairs(segs) do
                local phase = ((segIndex * 0.035 - (i - 1) * 0.085) % 1)
                s.BackgroundTransparency = math.abs(phase * 2 - 1)
            end
            bar.Size = UDim2.fromScale(t, 1)
            pct.Text = ("%d%%"):format(math.floor(t * 100))
            subtitle.Text = steps[math.min(math.floor(t * #steps) + 1, #steps)]
            titleGrad.Rotation = -now * 40 % 360
            barGrad.Rotation = now * 200 % 360
            if t >= 1 then
                local fade = 0.4
                local fstart = tick()
                while tick() - fstart < fade do
                    local a = (tick() - fstart) / fade
                    overlay.BackgroundTransparency = 0.15 + a * 0.85
                    card.BackgroundTransparency = a
                    for i, s in ipairs({ title, subtitle, pct }) do
                        s.TextTransparency = a
                    end
                    task.wait(0.02)
                end
                sc:Destroy()
                loaderDone = true
                break
            end
            task.wait(0.03)
        end
    end)
end

local Library = nil
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil then
        break
    end
    task.wait(0.25)
end

local oldLib = rawget(_G, _G_LIB)
if oldLib and type(oldLib.Unload) == "function" then
    pcall(oldLib.Unload, oldLib)
end
rawset(_G, _G_LIB, nil)
rawset(_G, _G_GUI, nil)

while not loaderDone do
    task.wait(0.05)
end

if Library then
    local Window = Library:CreateWindow({
        Title = "Pop Bubbles Collector",
        Footer = "Pop Bubbles Collector",
        AutoShow = true,
        Center = true,
        Resizable = true,
        CornerRadius = 6,
        ToggleKeybind = Config.guiKey,
    })

    local HomeTab = Window:AddTab("Home")

    local PlayerSection = HomeTab:AddLeftGroupbox("Player")
    healthLabel = PlayerSection:AddLabel("Health: -")
    studsLabel = PlayerSection:AddLabel("Pos: -")
    wsLabel = PlayerSection:AddLabel("WalkSpeed: -")

    local ServerSection = HomeTab:AddRightGroupbox("Server")
    ServerSection:AddLabel("Place: " .. tostring(game.PlaceId))
    ServerSection:AddLabel("Job: " .. tostring(game.JobId))
    pingLabel = ServerSection:AddLabel("Ping: --")
    ServerSection:AddLabel("Players: --")
    ServerSection:AddLabel("by exlumiaa1")

    local MainTab = Window:AddTab("Main")

    local CollectSection = MainTab:AddLeftGroupbox("Auto Collect")
    CollectSection:AddToggle("AutoCollect", {
        Text = "Auto Collect",
        Default = Config.autoCollect,
        Callback = function(s)
            Config.autoCollect = s
        end,
    }):AddKeyPicker("CollectKey", {
        Text = "Toggle Auto Collect",
        Default = Config.collectKey.Name,
        Mode = "Toggle",
        SyncToggleState = true,
    })
    CollectSection:AddToggle("Teleport", {
        Text = "Teleport To Drops",
        Default = Config.useTeleport,
        Callback = function(s)
            Config.useTeleport = s
        end,
    })
    CollectSection:AddToggle("SnapCam", {
        Text = "Snap Camera With Player",
        Default = Config.snapCamera,
        Callback = function(s)
            Config.snapCamera = s
        end,
    })
    CollectSection:AddSlider("CollectWait", {
        Text = "Wait Between Drops",
        Default = Config.collectWait,
        Min = 0.05,
        Max = 1,
        Rounding = 2,
        Suffix = " sec",
        Callback = function(v)
            Config.collectWait = v
        end,
    })
    dropLabel = CollectSection:AddLabel("Drops: -")
    collectedLabel = CollectSection:AddLabel("Collected: 0")

    local TimerSection = MainTab:AddLeftGroupbox("Timer")
    TimerSection:AddToggle("Cycle", {
        Text = "Timer Cycle",
        Default = Config.cycleEnabled,
        Callback = function(s)
            Config.cycleEnabled = s
            cycleStart = tick()
        end,
    })
    TimerSection:AddSlider("CycleOn", {
        Text = "Active (sec)",
        Default = Config.cycleOn,
        Min = 1,
        Max = 60,
        Rounding = 0,
        Suffix = " s",
        Callback = function(v)
            Config.cycleOn = v
        end,
    })
    TimerSection:AddSlider("CycleOff", {
        Text = "Idle (sec)",
        Default = Config.cycleOff,
        Min = 1,
        Max = 60,
        Rounding = 0,
        Suffix = " s",
        Callback = function(v)
            Config.cycleOff = v
        end,
    })
    cycleLabel = TimerSection:AddLabel("Status: waiting")

    local WalkSection = MainTab:AddRightGroupbox("WalkSpeed")
    WalkSection:AddToggle("Walkspeed", {
        Text = "WalkSpeed",
        Default = Config.walkEnabled,
        Callback = function(s)
            Config.walkEnabled = s
            if not s then
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = originalWalkSpeed
                end
            end
        end,
    })
    WalkSection:AddSlider("WalkSpeedValue", {
        Text = "Speed",
        Default = Config.walkSpeed,
        Min = 16,
        Max = 500,
        Rounding = 1,
        Suffix = " studs/s",
        Callback = function(v)
            Config.walkSpeed = v
        end,
    })

    local AttackSection = MainTab:AddRightGroupbox("Auto Attack")
    local aimlessLabel = nil
    local tripleLabel = nil
    local aimlessToggle = nil
    local tripleToggle = nil

    local function syncAttackUI(applied)
        if aimlessLabel then
            if Config.aimlessAttack then
                aimlessLabel:SetText(applied and "Status: enabled (no aiming)" or "Status: failed - module not ready")
            elseif Config.tripleShot then
                aimlessLabel:SetText("Status: off (Triple Shot active)")
            else
                aimlessLabel:SetText("Status: camera aim required")
            end
        end
        if tripleLabel then
            if Config.tripleShot then
                tripleLabel:SetText(applied and "Status: enabled (3 throws per throw)" or "Status: failed - module not ready")
            elseif Config.aimlessAttack then
                tripleLabel:SetText("Status: off (Aimless active)")
            else
                tripleLabel:SetText("Status: disabled")
            end
        end
    end

    local function applyAttackMode()
        attackSync = function(ok, mode)
            syncAttackUI(ok and mode ~= nil)
        end
        pcall(applyAttackEngine)
    end

    aimlessToggle = AttackSection:AddToggle("Aimless", {
        Text = "Aimless Auto Attack (150 studs)",
        Default = Config.aimlessAttack,
        Callback = function(s)
            Config.aimlessAttack = s
            if s then
                Config.tripleShot = false
                if tripleToggle and tripleToggle.Value then
                    tripleToggle.Value = false
                    tripleToggle:Display()
                end
            end
            pcall(applyAttackMode)
        end,
    })
    aimlessLabel = AttackSection:AddLabel("Status: -")

    tripleToggle = AttackSection:AddToggle("TripleShot", {
        Text = "Triple Shot (3 throws)",
        Default = Config.tripleShot,
        Callback = function(s)
            Config.tripleShot = s
            if s then
                Config.aimlessAttack = false
                if aimlessToggle and aimlessToggle.Value then
                    aimlessToggle.Value = false
                    aimlessToggle:Display()
                end
            end
            pcall(applyAttackMode)
        end,
    })
    tripleLabel = AttackSection:AddLabel("Status: -")

    rawset(_G, _G_LIB, Library)
    rawset(_G, _G_GUI, Library.ScreenGui)

    pcall(applyAttackMode)
end

local function applyWalkSpeed(char)
    if Config.walkEnabled and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Config.walkSpeed
        end
    end
end

LP.CharacterAdded:Connect(function(char)
    originalWalkSpeed = 16
    task.wait(0.5)
    applyWalkSpeed(char)
end)

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then
            break
        end
        applyWalkSpeed(LP.Character)
        task.wait(0.2)
    end
end)

task.spawn(function()
    local avgMs = 0
    while true do
        if rawget(_G, _G_TOMB) then
            break
        end
        task.wait(0.5)
        if Library and healthLabel then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                healthLabel:SetText("Health: " .. ("%d/%d"):format(math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5)))
            end
            if hrp then
                local p = hrp.Position
                studsLabel:SetText(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
            end
            local hum2 = char and char:FindFirstChildOfClass("Humanoid")
            if hum2 then
                local ws = hum2.WalkSpeed
                wsLabel:SetText("WalkSpeed: " .. ("%.1f"):format(ws))
            end
            local stats = game:GetService("Stats")
            local pingItem = stats.Network.ServerStatsItem["Data Ping"]
            avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
            pingLabel:SetText("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
        end
    end
end)

local function teardown()
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_ALIVE, nil)
    removeAimlessPatch()
    removeTriplePatch()
    stopAttackEngine()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = originalWalkSpeed
        end
    end
    local lib = rawget(_G, _G_LIB)
    if lib and type(lib.Unload) == "function" then
        pcall(lib.Unload, lib)
    else
        local gui = rawget(_G, _G_GUI)
        if gui then
            pcall(function()
                gui:Destroy()
            end)
        end
    end
    rawset(_G, _G_LIB, nil)
    rawset(_G, _G_GUI, nil)
end

if STATE and STATE.onCleanup then
    STATE.onCleanup(teardown)
end
