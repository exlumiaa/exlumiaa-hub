if tostring(game.GameId) ~= "10503838245" then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _pbOxTomb"
local _G_ALIVE = "_ _pbOxAlive"
local _G_ATTACK = "_ _pbAimlessAttack"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

-- Kill old Obsidian PB + old Oxidelib runs
do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub" or gui.Name == "PBCollectorLoader") then
                gui:Destroy()
            end
        end
    end)
    pcall(function()
        if LP then
            local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub" or gui.Name == "PBCollectorLoader") then
                    gui:Destroy()
                end
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
    local KEYSYSTEM_STORE_PATH = "PBCollector/panda_key_popbubbles.txt"
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
        local old = pg:FindFirstChild("PBKeyGate")
        if old then old:Destroy() end

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
        local cardc = Instance.new("UICorner"); cardc.CornerRadius = UDim.new(0, 16); cardc.Parent = card
        local cardStroke = Instance.new("UIStroke"); cardStroke.Color = accent; cardStroke.Transparency = 0.6; cardStroke.Thickness = 1; cardStroke.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 42)
        title.Position = UDim2.fromOffset(0, 20)
        title.BackgroundTransparency = 1
        title.Text = "Pop Bubbles Collector"
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
end

-- ================================================================
-- CONFIG
-- ================================================================
local Config = {
    autoCollect = true,
    useTeleport = true,
    snapCamera = true,
    collectWait = 0.12,
    walkEnabled = false,
    walkSpeed = 120,
    collectKey = Enum.KeyCode.RightControl,
    cycleEnabled = true,
    cycleOn = 5,
    cycleOff = 5,
    aimlessAttack = true,
    tripleShot = false,
}

local originalWalkSpeed = 16

-- ================================================================
-- PATCHES (Aimless / Triple Shot)
-- ================================================================
local autoAttackPatched = false
local origConeTest = nil

local function applyAimlessPatch()
    if autoAttackPatched then return true end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("AutoThrowController"))
    end)
    if not ok then return false end
    local cls = mod.AutoThrowController
    if type(cls) ~= "table" then return false end
    if origConeTest == nil then
        origConeTest = cls.buildConeTest
    end
    cls.buildConeTest = function(self, origin)
        if not workspace.CurrentCamera then return nil end
        return function()
            return true
        end
    end
    autoAttackPatched = true
    rawset(_G, _G_ATTACK, true)
    return true
end

local function removeAimlessPatch()
    if not autoAttackPatched then return end
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
    if triplePatched then return true end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("WeaponController"))
    end)
    if not ok then return false end
    local cls = mod.WeaponController
    local inst = cls and cls.getInstance and cls:getInstance()
    if type(inst) ~= "table" or type(inst.throw) ~= "function" then return false end
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
    if not triplePatched then return end
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

-- ================================================================
-- COLLECTOR
-- ================================================================
local collectedCount = 0

local dropLabel = nil
local collectedLabel = nil
local wsLabel = nil
local healthLabel = nil
local studsLabel = nil
local pingLabel = nil
local cycleLabel = nil
local aimlessLabel = nil
local tripleLabel = nil

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
                    cycleLabel:Set("Status: " .. (cycleActive and "collecting" or "waiting"))
                end
                if cycleActive then
                    local n, tp = scanCollect()
                    if dropLabel then
                        dropLabel:Set("Drops: " .. tostring(n))
                    end
                    if collectedLabel then
                        collectedLabel:Set("Collected: " .. tostring(collectedCount))
                    end
                end
            end)
            if not ok then
                rawset(_G, "_ _pbOxErr", tostring(err))
            end
        end
        task.wait(0.1)
    end
end)

-- ================================================================
-- WALKSPEED
-- ================================================================
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

-- ================================================================
-- COLLECT KEYBIND (RightControl toggles auto collect)
-- ================================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.collectKey then
        local t = Library and Library.Flags and Library.Flags["pb_autocollect"]
        if t and t.api and t.api.Set then
            Config.autoCollect = not Config.autoCollect
            pcall(t.api.Set, t.api, Config.autoCollect)
        end
    end
end)

-- ================================================================
-- UI — Oxidelib
-- ================================================================
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

local logoId = nil
pcall(function()
    if isfile and isfile("exlumiaa_logo.png") then
        logoId = getcustomasset("exlumiaa_logo.png")
    end
end)

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Pop Bubbles",
    Size = UDim2.fromOffset(700, 490),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Pop Bubbles",
    LoadingFooter = "by Exlumiaa Hub",
    Logo = logoId,
    GuiName = "ExlumiaaHub",
})

if logoId then
    pcall(function()
        if Window.Logo then Window.Logo.Image = logoId end
        if Window.Watermark then Window.Watermark.Image = logoId end
    end)
end

-- ======================== HOME TAB ========================
local HomeTab = Window:AddTab({ Name = "Home", Icon = "home", Subtitle = "Info" })
local InfoSub = HomeTab:AddSubTab("Info")

InfoSub:AddSection("Player")
healthLabel = InfoSub:AddLabel({ Text = "Health: -" })
studsLabel = InfoSub:AddLabel({ Text = "Pos: -" })
wsLabel = InfoSub:AddLabel({ Text = "WalkSpeed: -" })

InfoSub:AddSection("Server")
InfoSub:AddLabel({ Text = "Place: " .. tostring(game.PlaceId) })
InfoSub:AddLabel({ Text = "Job: " .. tostring(game.JobId) })
pingLabel = InfoSub:AddLabel({ Text = "Ping: --" })
InfoSub:AddLabel({ Text = "Players: --" })
InfoSub:AddLabel({ Text = "by exlumiaa1" })

InfoSub:AddDivider()
InfoSub:AddSection("Attack Status")
aimlessLabel = InfoSub:AddLabel({ Text = "Aimless: status unknown" })
tripleLabel = InfoSub:AddLabel({ Text = "Triple: status unknown" })

-- Info updater
local avgMs = 0
task.spawn(function()
    while true do
        task.wait(0.5)
        if rawget(_G, _G_TOMB) then break end
        pcall(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                healthLabel:Set("Health: " .. ("%d/%d"):format(math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5)))
                wsLabel:Set("WalkSpeed: " .. ("%.1f"):format(hum.WalkSpeed))
            end
            if hrp then
                local p = hrp.Position
                studsLabel:Set(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
            end
            local stats = game:GetService("Stats")
            local pingItem = stats.Network.ServerStatsItem["Data Ping"]
            avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
            pingLabel:Set("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
        end)
    end
end)

-- ======================== MAIN TAB ========================
local MainTab = Window:AddTab({ Name = "Main", Icon = "zap", Subtitle = "Collector" })
local CollectSub = MainTab:AddSubTab("Collector")
local TimerSub = MainTab:AddSubTab("Timer")
local MoveSub = MainTab:AddSubTab("Movement")
local AttackSub = MainTab:AddSubTab("Auto Attack")

CollectSub:AddSection("Auto Collect")
local autoCollectToggle = CollectSub:AddToggle({ Name = "Auto Collect (RightControl)", Default = Config.autoCollect, Flag = "pb_autocollect", Callback = function(s)
    Config.autoCollect = s
end })
CollectSub:AddToggle({ Name = "Teleport To Drops", Default = Config.useTeleport, Flag = "pb_teleport", Callback = function(s)
    Config.useTeleport = s
end })
CollectSub:AddToggle({ Name = "Snap Camera With Player", Default = Config.snapCamera, Flag = "pb_snapcam", Callback = function(s)
    Config.snapCamera = s
end })
CollectSub:AddSlider({ Name = "Wait Between Drops", Min = 1, Max = 20, Default = Config.collectWait * 100, Suffix = "x0.01s", Flag = "pb_collectwait", Callback = function(v)
    Config.collectWait = v / 100
end })
CollectSub:AddDivider()
dropLabel = CollectSub:AddLabel({ Text = "Drops: -" })
collectedLabel = CollectSub:AddLabel({ Text = "Collected: 0" })

TimerSub:AddSection("Timer")
TimerSub:AddToggle({ Name = "Timer Cycle", Default = Config.cycleEnabled, Flag = "pb_cycle", Callback = function(s)
    Config.cycleEnabled = s
    cycleStart = tick()
end })
TimerSub:AddSlider({ Name = "Active (sec)", Min = 1, Max = 60, Default = Config.cycleOn, Suffix = "s", Flag = "pb_cycle_on", Callback = function(v)
    Config.cycleOn = v
end })
TimerSub:AddSlider({ Name = "Idle (sec)", Min = 1, Max = 60, Default = Config.cycleOff, Suffix = "s", Flag = "pb_cycle_off", Callback = function(v)
    Config.cycleOff = v
end })
cycleLabel = TimerSub:AddLabel({ Text = "Status: waiting" })

MoveSub:AddSection("WalkSpeed")
MoveSub:AddToggle({ Name = "WalkSpeed", Default = Config.walkEnabled, Flag = "pb_ws_toggle", Callback = function(s)
    Config.walkEnabled = s
    if not s then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = originalWalkSpeed end
    end
end })
MoveSub:AddSlider({ Name = "Speed", Min = 16, Max = 500, Default = Config.walkSpeed, Suffix = "studs/s", Flag = "pb_ws_val", Callback = function(v)
    Config.walkSpeed = v
end })

-- ======================== AUTO ATTACK SUBTAB ========================
local function syncAttackUI(applied)
    if aimlessLabel then
        if Config.aimlessAttack then
            aimlessLabel:Set(applied and "Aimless: enabled (no aiming)" or "Aimless: failed - module not ready")
        elseif Config.tripleShot then
            aimlessLabel:Set("Aimless: off (Triple Shot active)")
        else
            aimlessLabel:Set("Aimless: camera aim required")
        end
    end
    if tripleLabel then
        if Config.tripleShot then
            tripleLabel:Set(applied and "Triple: enabled (3 throws per throw)" or "Triple: failed - module not ready")
        elseif Config.aimlessAttack then
            tripleLabel:Set("Triple: off (Aimless active)")
        else
            tripleLabel:Set("Triple: disabled")
        end
    end
end

local function applyAttackMode()
    attackSync = function(ok, mode)
        syncAttackUI(ok and mode ~= nil)
    end
    pcall(applyAttackEngine)
end

AttackSub:AddSection("Auto Attack")
local aimlessToggle = AttackSub:AddToggle({ Name = "Aimless Auto Attack (150 studs)", Default = Config.aimlessAttack, Flag = "pb_aimless", Callback = function(s)
    Config.aimlessAttack = s
    if s then
        Config.tripleShot = false
        local t = Library.Flags and Library.Flags["pb_triple"]
        if t and t.api and t.api.Set then
            pcall(t.api.Set, t.api, false)
        end
    end
    pcall(applyAttackMode)
end })
AttackSub:AddDivider()
local tripleToggle = AttackSub:AddToggle({ Name = "Triple Shot (3 throws)", Default = Config.tripleShot, Flag = "pb_triple", Callback = function(s)
    Config.tripleShot = s
    if s then
        Config.aimlessAttack = false
        local t = Library.Flags and Library.Flags["pb_aimless"]
        if t and t.api and t.api.Set then
            pcall(t.api.Set, t.api, false)
        end
    end
    pcall(applyAttackMode)
end })

-- ======================== SETTINGS TAB ========================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "pb_config_selected",
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
    Flag = "pb_config_name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
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
    Primary = false,
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
    Primary = false,
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

-- ================================================================
-- CLEANUP
-- ================================================================
local function teardown()
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_ALIVE, nil)
    removeAimlessPatch()
    removeTriplePatch()
    stopAttackEngine()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = originalWalkSpeed end
    end
    if Window and type(Window.Destroy) == "function" then
        pcall(function() Window:Destroy() end)
    end
end

if STATE and STATE.onCleanup then
    STATE.onCleanup(teardown)
end

-- Load last config on startup (after UI exists)
pcall(function() Library:LoadConfig("default") end)