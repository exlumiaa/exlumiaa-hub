if tostring(game.GameId) ~= "10741654282" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local STATE = rawget(_G, "STATE") or (type(getgenv) == "function" and rawget(getgenv(), "STATE") or nil)

local _G_TOMB = "_ _bkzTomb"
local _G_ALIVE = "_ _bkzAlive"
local _G_GEN = "_ _bkzGen"
local _G_GUI = "_ _bkzGui"

do
    local oldGui = rawget(_G, _G_GUI)
    if oldGui and oldGui.Parent then
        pcall(function() oldGui:Destroy() end)
    end
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

local function isTomb()
    return rawget(_G, _G_TOMB) == true or tonumber(rawget(_G, _G_GEN)) ~= MY_GEN
end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_bkz.txt"
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
        local old = pg:FindFirstChild("BuildKillZombiesKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "BuildKillZombiesKeyGate"
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
        title.Text = "Build and Kill Zombies"
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

-- ================================================================
-- CONFIG
-- ================================================================
local Config = {
    speedBoost = false,
    speedValue = 4,
    autoDrive = false,
    autoDriveSpeed = 100,
    teleportToCar = false,
    damageBoost = false,
    damageValue = 5,
    healthBoost = false,
    healthValue = 500,
    autoCrush = false,
    fuelCollect = false,
    espEnabled = false,
    espBox = true,
    espName = true,
    espDistance = true,
    espMaxDist = 400,
    autoSkill = false,
    autoQuest = false,
    autoRoll = false,
    autoRollStation = "Blocks",
    autoRollSkip = true,
    autoBuyRoll = false,
    maxBuyPrice = 5000,
    rollCategories = "",
    autoCodes = false,
    autoChest = false,
    autoBoss = false,
}

-- ================================================================
-- HELPERS
-- ================================================================
local function myCar()
    local cars = workspace:FindFirstChild("Cars")
    if not cars then return nil end
    for _, c in ipairs(cars:GetChildren()) do
        if c:GetAttribute("OwnerUserId") == LP.UserId then return c end
    end
    return nil
end

local function carChassis(car)
    if not car then return nil end
    return car:FindFirstChild("Chassis") or car.PrimaryPart
end

local Packets = nil
do
    local ok, res = pcall(function()
        return require(ReplicatedStorage.Packages.Packets)
    end)
    Packets = ok and res or nil
end

local function runAxisOf(car)
    if not car then return Vector3.new(1, 0, 0) end
    local ax = car:GetAttribute("RunAxis")
    -- typeof, not type(): Luau's type() reports native vectors as "vector", so
    -- comparing against "Vector3" here was always false and the attribute was
    -- never used.
    if typeof(ax) == "Vector3" and ax.Magnitude > 0 then
        return ax.Unit
    end
    return Vector3.new(1, 0, 0)
end

-- Aiming at a zombie picks up its height as well as its bearing, and a
-- vertical velocity drives the car into the floor and stops it dead. Driving
-- is always done flat on the ground, so drop Y from every direction used.
local function flatXZ(v)
    return Vector3.new(v.X, 0, v.Z)
end

-- The car is not ours to push around. ReplicatedStorage.Controllers.CarController
-- owns it: on PreSimulation it raycasts all four wheels and applies suspension,
-- drive and grip forces, and it takes throttle/steer from GetThrottleSteer(),
-- which is nothing but UserInputService:IsKeyDown(W / S / A / D).
--
-- Writing Chassis.AssemblyLinearVelocity by hand fought that controller every
-- frame. The car was flung clear of the ground, and
-- ReplicatedStorage.Shared.Data.RunValidationConfig is what noticed:
-- GroundClearance = 9, AirGrace = 2.5, StrikesToEndRun = 3 inside a 30s
-- window. Three strikes and the run is killed with
-- "Your vehicle was returned after repeated invalid movement."
--
-- So drive it the way a player does: hold the throttle, steer with A/D, and
-- leave the physics to the controller.
--
-- Holding real keys with keypress() fixed that, but only on a focused PC
-- window: a phone has no keyboard to press, and GetThrottleSteer reads
-- IsKeyDown unconditionally on every platform. So answer the read instead
-- of the keyboard. STATE.namecallHook answers IsKeyDown for the three keys
-- the drive loop is "holding", which is exactly the value GetThrottleSteer
-- would see if a thumb were on a real key. Nothing is pressed, so nothing
-- needs focus, and a mobile player gets the same drive as a desktop one.
local KEY_W, KEY_A, KEY_D = Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.D

local driveKeys = {
    [KEY_W] = false,
    [KEY_A] = false,
    [KEY_D] = false,
}

-- True when the game is answered by the hook rather than by native input.
-- Without STATE (a bare execute instead of a live-reload) the hook cannot
-- be installed, so setDriveKey falls back to keypress() and the status line
-- keeps the old focus requirement instead of pretending.
local driveHooked = false

if STATE and type(STATE.namecallHook) == "function" then
    pcall(function()
        STATE.namecallHook("IsKeyDown", function(self, method, ...)
            local kc = ...
            if kc and driveKeys[kc] then return true end
            -- no substitution: let the real answer through, so a player who
            -- is genuinely holding a key still gets it
        end)
        driveHooked = true
    end)
end

-- keypress takes a virtual-key number, not an Enum.KeyCode: passing
-- Enum.KeyCode.W raises "number expected, got EnumItem". Enum values are
-- lowercase ascii (W = 119) while the VK codes are uppercase (W = 87).
local VK = {
    [KEY_W] = 87,
    [KEY_A] = 65,
    [KEY_D] = 68,
}

local function setDriveKey(kc, want)
    if driveKeys[kc] == want then return end
    driveKeys[kc] = want
    if driveHooked then return end
    pcall(function()
        local vk = VK[kc]
        if not vk then return end
        if want then keypress(vk) else keyrelease(vk) end
    end)
end

local function releaseDriveKeys()
    for kc, held in pairs(driveKeys) do
        if held then
            driveKeys[kc] = false
            if not driveHooked then
                pcall(function()
                    local vk = VK[kc]
                    if vk then keyrelease(vk) end
                end)
            end
        end
    end
end

-- Returns false with a reason when driving is impossible right now, so the
-- status label can say why instead of claiming "driving" while nothing moves.
local function applyDriveInput(car, chassis, dir, speed)
    if not driveHooked and not isrbxactive() then
        releaseDriveKeys()
        return false, "Roblox window is not focused"
    end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = car:FindFirstChild("DriverSeat")
    if not hum or not seat or hum.SeatPart ~= seat then
        releaseDriveKeys()
        return false, "not sitting in the driver seat"
    end

    local vel = chassis.AssemblyLinearVelocity
    local cur = Vector3.new(vel.X, 0, vel.Z).Magnitude
    -- Pulse the throttle instead of pinning it: holding W all the time would
    -- ignore the Drive Speed slider and just run the car at TopSpeed.
    setDriveKey(KEY_W, cur < speed - 4)

    local want = flatXZ(dir)
    if want.Magnitude < 0.02 then
        setDriveKey(KEY_A, false)
        setDriveKey(KEY_D, false)
        return true
    end
    local look = flatXZ(chassis.CFrame.LookVector)
    if look.Magnitude < 0.02 then
        setDriveKey(KEY_A, false)
        setDriveKey(KEY_D, false)
        return true
    end
    local l, w = look.Unit, want.Unit
    -- negative cross means the target lies to the left of the nose
    local cross = l.X * w.Z - l.Z * w.X
    local dot = l:Dot(w)
    local steer = 0
    if dot < -0.5 then
        steer = if cross < 0 then -1 else 1
    elseif cross < -0.16 then
        steer = -1
    elseif cross > 0.16 then
        steer = 1
    end
    setDriveKey(KEY_A, steer == -1)
    setDriveKey(KEY_D, steer == 1)
    return true
end

local function spawnCar()
    if not Packets then return false, "Packets unavailable" end
    pcall(function() Packets.SpawnCar:Fire() end)
    local t = tick()
    while tick() - t < 5 do
        if myCar() then return true end
        task.wait(0.2)
    end
    return false, "Car did not spawn"
end

local function despawnCar()
    if not Packets then return false, "Packets unavailable" end
    pcall(function() Packets.DespawnCar:Fire() end)
    return true
end

-- ================================================================
-- CAR STATS
-- ================================================================
local baseAttrs = nil

-- TopSpeed, Accel and Turn get recomputed by the server from the placed parts,
-- so writing them does nothing lasting. The knobs that DO stick, measured on a
-- live car, are EnginePower and TurboMult: setting each to 500 held for the
-- full wait. DragFactor, which an earlier note claimed was the multiplier, is
-- not an attribute of this car at all - setting it is stripped straight back to
-- nil, which is why the old Speed Boost did nothing.
local function applyCarStats()
    local car = myCar()
    if not car then
        baseAttrs = nil
        return
    end
    if not baseAttrs then
        baseAttrs = {
            EnginePower = tonumber(car:GetAttribute("EnginePower")) or 13,
            TurboMult = tonumber(car:GetAttribute("TurboMult")) or 1,
        }
    end

    if Config.speedBoost then
        local mult = math.clamp(tonumber(Config.speedValue) or 1, 1, 6)
        car:SetAttribute("TurboMult", mult)
        car:SetAttribute("EnginePower", baseAttrs.EnginePower * mult)
    else
        car:SetAttribute("TurboMult", baseAttrs.TurboMult)
        car:SetAttribute("EnginePower", baseAttrs.EnginePower)
    end

    if Config.damageBoost then
        car:SetAttribute("TotalDamageExtra", Config.damageValue)
    end

    if Config.healthBoost then
        car:SetAttribute("TotalHealthExtra", Config.healthValue)
    end
end

-- ================================================================
-- AUTO ROLL
-- Rolling is not a packet we send: the server picks the result and only fires
-- RollSpin after a roll station is physically used. So we walk the character
-- to the station on our own plot and press its "Roll!" ProximityPrompt, then
-- wait out RollConfig.SpinDuration (2.5s / RollSpeed) before the next one.
-- ================================================================
local rollRunning = false
local rollStop = false
local rollStationApi = nil
local rollCategoryApi = nil
local freeStuffRunning = false
local lastInventoryGain = nil
local lastBuyResult = nil
-- shared state, declared up here because buyRolledItem() further down runs
-- before the codes section that also touches these
local inventoryCount = 0
local inventoryKinds = 0
local codeMessages = {}
local redeemedCodes = {}
-- startAutoRoll() is defined before the money helpers, so it needs these bound
-- as forward declarations first - as plain locals it would resolve to a global
-- that does not exist yet and blow up at call time.
local buyRolledItem

-- "⭐ Distance" / "Distance" on the leaderstats, as a plain number
local function cashDistance()
    local ls = LP:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local d = ls:FindFirstChild("⭐ Distance") or ls:FindFirstChild("Distance")
    return d and (tonumber(d.Value) or 0) or 0
end

local function myPlot()
    local plots = workspace:FindFirstChild("Game")
        and workspace.Game:FindFirstChild("Lobby")
        and workspace.Game.Lobby:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == LP.UserId then return plot end
    end
    return nil
end

local function rollStations()
    local plot = myPlot()
    if not plot then return nil, "your plot is not loaded yet" end
    local rolls = plot:FindFirstChild("Rolls")
    if not rolls then return nil, "this plot has no roll stations" end

    -- Oxidelib's dropdown has no Callback, so read the live value from its api.
    local want = "Blocks"
    if rollStationApi and type(rollStationApi.Get) == "function" then
        local v = rollStationApi:Get()
        if type(v) == "string" then want = v end
    end

    local out = {}
    local function add(name)
        local part = rolls[name] and rolls[name]:FindFirstChild("Roll")
        local prompt = part and part:FindFirstChildOfClass("ProximityPrompt")
        if prompt then out[#out+1] = prompt end
    end
    if want == "Both" or want == "Blocks" then add("RollBlocks") end
    if want == "Both" or want == "Weapons" then add("RollWeapons") end
    return out, nil
end

local function startAutoRoll()
    if rollRunning then return end
    rollRunning = true
    rollStop = false

    task.spawn(function()
        local interval = 3
        pcall(function()
            local RC = require(ReplicatedStorage.Shared.Data.RollConfig)
            interval = (RC.SpinDuration or 2.5) + 0.5
        end)

        -- rollStop is a plain local, not Config and not STATE: STATE only exists
        -- when the script is launched through the MCP live-reload, so relying on
        -- it left the loop running after the toggle was switched off whenever the
        -- script was executed by hand. isTomb() is the reload guard, because it
        -- reads a counter in _G and works no matter how the script was started.
        local savedCFrame = nil
        while not rollStop and not isTomb() do
            local prompts = rollStations()

            if prompts and #prompts > 0 then
                for _, prompt in ipairs(prompts) do
                    if rollStop or isTomb() then break end
                    if prompt and prompt.Parent then
                        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if not savedCFrame then savedCFrame = hrp.CFrame end
                            -- Move once, let it settle, press once. Both parts
                            -- matter: re-writing the CFrame on consecutive frames
                            -- is what made the server ignore the prompt, and
                            -- firing several times in a row floods it - a single
                            -- press is what actually returns a 14 item roll.
                            hrp.CFrame = prompt.Parent.CFrame * CFrame.new(0, 1.5, 2.5)
                            task.wait(0.8)
                            if not rollStop and not isTomb() and hrp.Parent then
                                pcall(fireproximityprompt, prompt)
                            end

                            -- A roll only changes the item on show, so buy it
                            -- straight away or the roll gave us nothing.
                            if Config.autoBuyRoll and not rollStop then
                                local plot = myPlot()
                                local rolls = plot and plot:FindFirstChild("Rolls")
                                if rolls then
                                local bought, why
                                for _, name in ipairs({ "RollBlocks", "RollWeapons" }) do
                                    local st = rolls:FindFirstChild(name)
                                    local okBuy, r1, r2 = pcall(function()
                                        return buyRolledItem(st, hrp)
                                    end)
                                    if not okBuy then
                                        bought = bought or false
                                        why = why or (name .. " error: " .. tostring(r1))
                                    elseif r1 then
                                        bought = true
                                        why = name .. " bought"
                                        break
                                    elseif r2 and r2 ~= "nothing to buy yet"
                                        and r2 ~= "no buy prompt" then
                                        why = why or (name .. ": " .. tostring(r2))
                                    end
                                end
                                lastBuyResult = why or "nothing to buy yet"
                                end
                            end
                        end
                    end
                    task.wait(interval)
                end
            else
                task.wait(0.5)
            end
        end

        -- hand the character back where it was when auto roll was switched off
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and savedCFrame then
            pcall(function() hrp.CFrame = savedCFrame end)
        end
        rollRunning = false
    end)
end

-- ================================================================
-- PACKETS
-- ================================================================
local function getPackets()
    local ok, p = pcall(function() return require(ReplicatedStorage.Packages.Packets) end)
    return ok and p or nil
end

-- ================================================================
-- ZOMBIES
-- ================================================================
local function zombieFolder()
    return workspace:FindFirstChild("ClientZombies")
end

local function eachZombie(fn)
    local f = zombieFolder()
    if not f then return end
    for _, z in ipairs(f:GetChildren()) do
        if z:IsA("Model") then
            local root = z:FindFirstChild("HumanoidRootPart")
            if root then fn(z, root) end
        end
    end
end

local function nearestZombie(fromPos, maxDist)
    local best, bestDist = nil, maxDist or math.huge
    eachZombie(function(z, root)
        local d = (root.Position - fromPos).Magnitude
        if d < bestDist then
            best, bestDist = z, d
        end
    end)
    return best, bestDist
end

-- ================================================================
-- FUEL (boss fight only)
-- ================================================================
local fuelTargets = {}

local function onFuelSpawned(id, pos)
    fuelTargets[id] = pos
end

local function onFuelRemoved(id)
    fuelTargets[id] = nil
end

local function nearestFuel(fromPos, maxDist)
    local bestId, bestPos, bestDist = nil, nil, maxDist or math.huge
    for id, pos in pairs(fuelTargets) do
        local d = (pos - fromPos).Magnitude
        if d < bestDist then
            bestId, bestPos, bestDist = id, pos, d
        end
    end
    return bestId, bestPos, bestDist
end

-- ================================================================
-- AUTO DRIVE
-- ================================================================
local autoDriveConn = nil
local driveActive = false
-- declared above stopAutoDrive on purpose: a local named later in the chunk
-- would not be in scope inside the function body and would silently become a
-- global, leaving the status label reading the wrong variable.
local driveStatus = "off"
local spawnWait = 0

local function stopAutoDrive()
    if autoDriveConn then
        pcall(function() autoDriveConn:Disconnect() end)
        autoDriveConn = nil
    end
    -- syncAutoDrive only starts the loop when driveActive is false, so leaving
    -- this flag set meant Auto Drive could run once and then never restart
    -- after being switched off and on again.
    driveActive = false
    driveStatus = "off"
    -- let go of the throttle, or the character keeps walking after Auto Drive
    -- is switched off
    releaseDriveKeys()
end

local function driveWanted()
    return Config.autoDrive or Config.autoCrush or Config.fuelCollect
end

local function startAutoDrive()
    stopAutoDrive()
    driveActive = true

    -- Put the car out ourselves instead of waiting for the game to do it, which
    -- left Auto Drive doing nothing for several seconds after being switched on.
    driveStatus = "starting"
    if not myCar() then
        task.spawn(function()
            for attempt = 1, 6 do
                if not driveWanted() then driveStatus = "stopped" return end
                if myCar() then driveStatus = "car ready" return end
                if not Packets then
                    driveStatus = "packets missing"
                    return
                end
                driveStatus = ("spawn attempt %d"):format(attempt)
                pcall(function() Packets.SpawnCar:Fire() end)
                task.wait(1)
            end
            driveStatus = myCar() and "car ready" or "spawn failed"
        end)
    else
        driveStatus = "car already out"
    end

    autoDriveConn = RunService.Heartbeat:Connect(function()
        if isTomb() then
            stopAutoDrive()
            return
        end
        if not driveWanted() then
            stopAutoDrive()
            return
        end
        local car = myCar()

        -- The car disappears at the end of a run, so the spawn loop above exits
        -- as soon as one exists and then never notices. Keep checking instead:
        -- when auto drive is wanted and there is no car, put it back out.
        if not car then
            -- never leave W held with no car: the character would walk on foot
            releaseDriveKeys()
            spawnWait = (spawnWait or 0) - 1
            if spawnWait <= 0 then
                spawnWait = 90
                driveStatus = "car gone, putting it back out"
                if Packets then pcall(function() Packets.SpawnCar:Fire() end) end
            end
            return
        end
        spawnWait = 0

        local chassis = carChassis(car)
        if not chassis then
            releaseDriveKeys()
            return
        end
        local pos = chassis.Position
        local speed = Config.autoDriveSpeed

        -- fuel pickups only exist during a boss fight, so they win over everything
        local dir = nil
        if Config.fuelCollect then
            local _, fuelPos = nearestFuel(pos, 800)
            if fuelPos then dir = fuelPos - pos end
        end

        if dir == nil and Config.autoCrush then
            -- nearestZombie returns the model and the distance, so take the part
            local zModel, zDist = nearestZombie(pos, 200)
            if zModel and zDist then
                local zRoot = zModel:FindFirstChild("HumanoidRootPart")
                local aim = zRoot and zRoot.Position or nil
                if aim then
                    -- actually steer at the zombie: blend the run axis with the
                    -- direction to it, otherwise this branch was identical to the
                    -- default and "Auto Crush" did nothing at all.
                    local flatAxis = flatXZ(runAxisOf(car))
                    local toZombie = flatXZ(aim - pos)
                    dir = flatAxis * 0.35
                    if toZombie.Magnitude > 0.01 then
                        dir = dir + toZombie.Unit * 0.65
                    end
                    if dir.Magnitude <= 0.01 then dir = flatAxis end
                end
            end
        end

        if dir == nil then dir = runAxisOf(car) end

        local ok, why = applyDriveInput(car, chassis, dir, speed)
        driveStatus = ok and "driving" or (why or "driving")
    end)
end

local function syncAutoDrive()
    if driveWanted() then
        if not driveActive then startAutoDrive() end
    else
        if driveActive then stopAutoDrive() end
    end
end

-- ================================================================
-- ESP
-- ================================================================
local espObjects = {}

local function clearESP()
    for _, v in pairs(espObjects) do
        -- espObjects values are tables of two instances, not instances, so
        -- setting .Parent on one did nothing: turning the ESP off left every
        -- highlight and billboard on screen forever
        pcall(function() if v.bb then v.bb:Destroy() end end)
        pcall(function() if v.hl then v.hl:Destroy() end end)
    end
    espObjects = {}
end

local function updateESP()
    if not Config.espEnabled then
        if next(espObjects) then clearESP() end
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local live = {}

    eachZombie(function(z, root)
        local screen, onScreen = cam:WorldToViewportPoint(root.Position)
        if onScreen and screen.Z > 0 then
            local dist = (root.Position - cam.CFrame.Position).Magnitude
            if dist <= Config.espMaxDist then
                live[z] = true
                local entry = espObjects[z]
                if not entry then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ExlumiaaESP"
                    bb.Adornee = root
                    bb.Size = UDim2.fromOffset(200, 40)
                    bb.StudsOffset = Vector3.new(0, 3.2, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = Config.espMaxDist + 100
                    bb.Parent = z
                    local name = Instance.new("TextLabel")
                    name.Name = "Name"
                    name.Size = UDim2.fromScale(1, 0.5)
                    name.BackgroundTransparency = 1
                    name.Font = Enum.Font.GothamBold
                    name.TextSize = 13
                    name.TextColor3 = Color3.fromRGB(255, 90, 90)
                    name.TextStrokeTransparency = 0.4
                    name.Text = ""
                    name.Parent = bb
                    local distL = Instance.new("TextLabel")
                    distL.Name = "Dist"
                    distL.Size = UDim2.fromScale(1, 0.5)
                    distL.Position = UDim2.fromScale(0, 0.5)
                    distL.BackgroundTransparency = 1
                    distL.Font = Enum.Font.Gotham
                    distL.TextSize = 12
                    distL.TextColor3 = Color3.fromRGB(255, 220, 120)
                    distL.TextStrokeTransparency = 0.4
                    distL.Text = ""
                    distL.Parent = bb
                    local hl = Instance.new("Highlight")
                    hl.Name = "ExlumiaaHL"
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(255, 70, 70)
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = z
                    entry = { bb = bb, name = name, dist = distL, hl = hl }
                    espObjects[z] = entry
                end
                entry.name.Text = Config.espName and z.Name or ""
                entry.dist.Text = Config.espDistance and ("%.0f studs"):format(dist) or ""
                entry.hl.Enabled = Config.espBox
            end
        end
    end)

    for k in pairs(espObjects) do
        if not live[k] then
            pcall(function() espObjects[k].bb:Destroy() end)
            pcall(function() espObjects[k].hl:Destroy() end)
            espObjects[k] = nil
        end
    end
end

-- ================================================================
-- AUTOMATION
-- ================================================================
local lastSkillSync = 0
local lastQuestSync = 0
local lastBoss = 0
local questState = nil
local skillState = nil
local currentConfig = "default"

local function skillById()
    local ok, cfg = pcall(function() return require(ReplicatedStorage.Shared.Data.SkillConfig) end)
    if not ok or not cfg then return nil end
    return cfg.ById
end

local function ownedSet()
    local set = {}
    if type(skillState) == "string" then
        local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(skillState) end)
        if ok and type(decoded) == "table" then
            for _, v in ipairs(decoded) do set[tostring(v)] = true end
        end
    end
    return set
end

-- the game stores leaderstats as StringValues like "22.5K" / "1.2M", so a plain
-- tonumber() always fails and every affordability check sees zero
local function parseAmount(value)
    if type(value) == "number" then return value end
    if type(value) ~= "string" then return 0 end
    local n = tonumber(value)
    if n then return n end
    -- prices in this game are shown as "$4k" / "R$ 250", so drop the currency
    -- prefix before matching the number
    local cleaned = value:gsub("[^%d%.KkMmBbTt]", "")
    local num, suffix = string.match(cleaned, "^%s*([%d%.]+)%s*([KkMmBbTt]?)")
    if not num then return 0 end
    n = tonumber(num) or 0
    local mult = ({ K = 1e3, M = 1e6, B = 1e9, T = 1e12 })[suffix:upper()]
    return n * (mult or 1)
end

local function compactNumber(n)
    n = tonumber(n) or 0
    if n >= 1e9 then return ("%.1fB"):format(n / 1e9) end
    if n >= 1e6 then return ("%.1fM"):format(n / 1e6) end
    if n >= 1e3 then return ("%.1fK"):format(n / 1e3) end
    return tostring(math.floor(n))
end

local function cashValue()
    local ls = LP:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local cv = ls:FindFirstChild("💵 Cash") or ls:FindFirstChild("Cash")
    return parseAmount(cv and cv.Value)
end

-- Rolling only DISPLAYS an item at the station - it does not hand it over.
-- The station's ItemPlace carries a separate "Buy" prompt (hold 0.9s) and that
-- is the step that actually puts the part in your inventory. Measured: 5 rolls
-- gave 0 items, but buying straight after a roll gave the item every time.
local function stationBuyPrompt(station)
    local place = station and station:FindFirstChild("ItemPlace")
    return place and place:FindFirstChildWhichIsA("ProximityPrompt", true) or nil
end

-- The prompt hangs off an Attachment (ItemPlace.Attachment.BuyPrompt), and an
-- Attachment has no CFrame, so walk up to the BasePart before moving anyone.
local function partUnder(node)
    local cur = node
    while cur and not cur:IsA("BasePart") do cur = cur.Parent end
    return cur
end

local function stationPrice(station)
    local info = station and station:FindFirstChild("Info")
    local label = info and info:FindFirstChild("Price")
    local text = label and label:FindFirstChild("Text")
    if not text then return nil end
    local raw = ""
    pcall(function() raw = text.Text or "" end)
    return parseAmount(raw)
end

buyRolledItem = function(station, hrp)
    local buy = stationBuyPrompt(station)
    if not buy or not buy.Parent then return false, "no buy prompt" end
    if not buy.Enabled then return false, "nothing to buy yet" end
    if not hrp then return false, "no character" end

    local price = stationPrice(station)
    local have = cashValue()
    if price and price > have then
        return false, ("need %s, have %s"):format(
            compactNumber(price), compactNumber(have))
    end
    if Config.maxBuyPrice > 0 and price and price > Config.maxBuyPrice then
        return false, "costs " .. compactNumber(price) .. ", over your limit"
    end

    local anchor = partUnder(buy)
    if not anchor then return false, "no part under the prompt" end

    local saved = hrp.CFrame
    pcall(function()
        hrp.CFrame = anchor.CFrame * CFrame.new(0, 1.5, 2.5)
    end)
    task.wait(0.8)
    local before = inventoryCount
    pcall(fireproximityprompt, buy)
    task.wait(1.2)
    pcall(function() hrp.CFrame = saved end)
    return inventoryCount > before, nil
end

local function trySkills()    local P = getPackets()
    if not P then return end
    if tick() - lastSkillSync > 20 then
        lastSkillSync = tick()
        pcall(function() P.RequestSkills:Fire() end)
        task.wait(0.5)
    end
    local byId = skillById()
    if type(byId) ~= "table" then return end
    local owned = ownedSet()
    local cash = cashValue()

    -- cheapest first so the parent chain unlocks in order
    local queue = {}
    for _, s in pairs(byId) do
        if type(s) == "table" and type(s.Id) == "string" then
            local id = s.Id
            local cost = tonumber(s.Cost) or 0
            local parent = type(s.Parent) == "string" and s.Parent or ""
            -- skip the skill-tree layout nodes, they are not purchasable
            local isNode = not (string.match(id, "_root$") or string.match(id, "_portal$")
                or s.Title == "Back" or s.Title == "Start")
            if isNode and not owned[id] and cost <= cash and (parent == "" or owned[parent]) then
                queue[#queue + 1] = { id = id, cost = cost }
            end
        end
    end
    table.sort(queue, function(a, b) return a.cost < b.cost end)

    for _, item in ipairs(queue) do
        if tick() - lastSkillSync > 8 then break end
        owned[item.id] = true
        pcall(function() P.BuySkill:Fire(item.id) end)
        task.wait(0.4)
    end
end

local function questConfig()
    local ok, cfg = pcall(function() return require(ReplicatedStorage.Shared.Data.QuestConfig) end)
    if not ok or not cfg then return nil end
    return cfg.Quests
end

local function tryQuests()
    local P = getPackets()
    if not P then return end
    if tick() - lastQuestSync > 10 then
        lastQuestSync = tick()
        pcall(function() P.RequestQuests:Fire() end)
        task.wait(0.5)
    end
    if type(questState) ~= "string" then return end
    local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(questState) end)
    if not ok or type(data) ~= "table" then return end
    local quests = questConfig()
    if type(quests) ~= "table" then return end

    local claimed = {}
    for _, v in pairs(data.Claimed or {}) do claimed[tostring(v)] = true end
    local progress = data.Progress or {}

    -- Progress is keyed by the quest Id, not by Stat. The game's own
    -- EventTotem reads Progress[q.Id] (ReplicatedStorage.Controllers.
    -- ClientSetupService.Misc.EventTotem), and the two differ for the zombie
    -- quest: its Id is "zombies" while its Stat is "ZombieKills". Keying off
    -- Stat made that quest read 0 forever and never claim.
    for _, q in ipairs(quests) do
        if type(q) == "table" and type(q.Id) == "string" and not claimed[q.Id] then
            local have = tonumber(progress[string.lower(q.Id)])
                or tonumber(progress[q.Id])
                or tonumber(progress[string.lower(tostring(q.Stat or ""))])
                or 0
            local goal = tonumber(q.Goal)
            if goal and have >= goal then
                pcall(function() P.ClaimQuest:Fire(q.Id) end)
                claimed[q.Id] = true
                task.wait(0.4)
            end
        end
    end
end

-- ================================================================
-- FREE STUFF: codes, chest, roll skip, roll categories
-- ================================================================

-- The game ships its own list of live codes in Shared.Data.CodesConfig, so
-- there is nothing to hardcode: read them, keep the ones still Active, and
-- hand them to the server one at a time.
local function activeCodes()
    local ok, CC = pcall(function()
        return require(ReplicatedStorage.Shared.Data.CodesConfig)
    end)
    if not ok or type(CC) ~= "table" then return {}, "could not read the code list" end
    local list = {}
    for name, def in pairs(CC) do
        if type(def) == "table" and def.Active == true then
            local need = tonumber(def.MinDistance)
            if not need or (cashDistance() >= need) then
                list[#list+1] = { code = tostring(name), need = need }
            end
        end
    end
    table.sort(list, function(a, b) return a.code < b.code end)
    return list, nil
end


-- The server never answers on the RedeemCode response channel, so success is
-- judged from what actually changes: cash, and the InventoryChanged packet
-- the server fires for every item you are handed.

local function redeemCodes(manual)
    local P = getPackets()
    if not P then return 0, "packets are not loaded" end
    local list, err = activeCodes()
    if not list or #list == 0 then
        if manual then notify("Codes", err or "No live codes right now", "info") end
        return 0, err or "no live codes right now"
    end

    local before = inventoryCount
    local sent = 0
    for _, entry in ipairs(list) do
        if isTomb() then break end
        if not redeemedCodes[entry.code] then
            redeemedCodes[entry.code] = true
            pcall(function()
                P.RedeemCode:Response(function() end)
            end)
            pcall(function() P.RedeemCode:Fire(entry.code) end)
            sent = sent + 1
            task.wait(manual and 1.2 or 0.6)
        end
    end

    if manual then
        local extra = ""
        local recent = {}
        for i = #codeMessages, math.max(1, #codeMessages - 2), -1 do
            recent[#recent + 1] = codeMessages[i]
        end
        if #recent > 0 then extra = "  " .. table.concat(recent, " / ") end
        if inventoryCount > before then
            notify("Codes", ("Sent %d codes, got %d items%s"):format(sent, inventoryCount - before, extra), "success")
        else
            notify("Codes", ("Sent %d codes, none left to claim"):format(sent), "warning")
        end
    end
    return sent, inventoryCount - before
end

local function claimChest(manual)
    local P = getPackets()
    if not P then return false end
    local ok, err = pcall(function() P.ClaimChestReward:Fire() end)
    if manual then
        notify("Chest", ok and "Claimed" or ("Failed: " .. tostring(err)), ok and "success" or "error")
    end
    return ok
end

local function applyRollCategories()
    local P = getPackets()
    if not P then return end
    local list = rollCategoryApi and type(rollCategoryApi.Get) == "function"
        and rollCategoryApi:Get() or nil
    if type(list) ~= "table" then
        if type(list) == "string" then
            local out = {}
            for name in string.gmatch(list, "[^,]+") do out[#out+1] = name end
            list = out
        else
            list = { "Block", "Engine", "Fuel", "Wheel" }
        end
    end
    if #list == 0 then return end
    table.sort(list)
    pcall(function() P.SetRollCategories:Fire(table.concat(list, ",")) end)
end

local function startFreeStuff()
    if freeStuffRunning then return end
    freeStuffRunning = true
    task.spawn(function()
        local chestTried = false
        while (Config.autoCodes or Config.autoChest) and not isTomb() do
            if Config.autoCodes then pcall(redeemCodes, false) end
            if Config.autoChest and not chestTried then
                chestTried = claimChest(false)
            end
            task.wait(60)
        end
        freeStuffRunning = false
    end)
end

-- ================================================================
-- LIVE EVENT
-- The Build tab (slot save/load/buy, My Parts) was removed, so the slot
-- bookkeeping went with it. The live event state stays: the Home tab still
-- shows it.
-- ================================================================
local liveEvent = { name = "No event running", state = "idle" }

local function wireLiveEvent()
    local P = getPackets()
    if not P then return end
    pcall(function() P.LiveEventRequestActive:Fire() end)
    local function showEvent(t)
        if type(t) ~= "table" then
            liveEvent.name = tostring(t or "No event running")
            liveEvent.state = "active"
            return
        end
        local name = t.Name or t.Definition or t.Id or t.Event
        liveEvent.name = name and tostring(name) or "Event running"
        liveEvent.state = tostring(t.State or t.Phase or "active")
    end
    pcall(function()
        P.LiveEventActive.OnClientEvent:Connect(function(t)
            if type(t) == "table" and next(t) == nil then
                liveEvent.name = "No event running"
                liveEvent.state = "idle"
            else
                showEvent(t)
            end
        end)
    end)
    pcall(function()
        P.LiveEventStateChanged.OnClientEvent:Connect(function(a, b, c)
            if type(a) == "table" then showEvent(a) end
            if b ~= nil then liveEvent.state = tostring(b) end
            if c ~= nil and type(c) == "string" and c ~= "" then liveEvent.name = c end
        end)
    end)
    pcall(function()
        P.LiveEventStarted.OnClientEvent:Connect(function(a, b)
            if type(a) == "string" and a ~= "" then liveEvent.name = a end
            liveEvent.state = tostring(b or "started")
        end)
    end)
    for _, name in ipairs({ "LiveEventEnded", "LiveEventPaused" }) do
        pcall(function()
            P[name].OnClientEvent:Connect(function()
                liveEvent.name = "No event running"
                liveEvent.state = name == "LiveEventPaused" and "paused" or "idle"
            end)
        end)
    end
end

-- ================================================================
-- PARTS (reference only, no code)
-- The Build tab and Auto Build were both removed. Auto Build poured every
-- owned part into the first free grid cell of the plot and, once the
-- inventory ran dry, kept re-sending a part the server had already rejected,
-- which spammed "you do not own that part" hundreds of times.
--
-- For reference if parts are ever needed again: placement is grid based,
-- PlacePart(partId, x, y, z, rot, paint), and the server answers
-- PlaceRejected with a reason string. Observed payloads:
--   "NotOwned"     - a real part id we have none of left
--   "UnknownPart"  - an id the save does not know at all
-- and a placed part shows up as a Model named "x,y,z" under plot.Parts.
-- Inventory is absolute per-id counts pushed on InventoryChanged, and
-- RequestInventory asks for a fresh snapshot.
-- ================================================================

local function tryBoss()
    if not Config.autoBoss then return end
    local P = getPackets()
    if not P then return end
    if tick() - lastBoss < 20 then return end
    lastBoss = tick()
    pcall(function() P.BossSync:Fire() end)
end

-- ================================================================
-- SIGNAL WIRING
-- ================================================================
task.spawn(function()
    local P = getPackets()
    if not P then return end
    local function link(packet, fn)
        pcall(function()
            if packet and packet.OnClientEvent then
                packet.OnClientEvent:Connect(fn)
            end
        end)
    end
    link(P.FuelSpawned, onFuelSpawned)
    link(P.FuelRemoved, onFuelRemoved)
    link(P.FuelCollected, onFuelRemoved)
    link(P.QuestsChanged, function(s) questState = s end)
    link(P.SkillsChanged, function(s) skillState = s end)
    link(P.RollConfirmation, function(a, b, c, token)
        -- the 4th argument is the skip token; sending it straight back with
        -- true takes the result without waiting out the 2.5s spin
        if Config.autoRollSkip and type(token) == "string" and token ~= "" then
            pcall(function() P.ConfirmRollSkip:Fire(token, true) end)
        end
    end)
    link(P.InventoryChanged, function(itemId, amount)
        local n = tonumber(amount) or 0
        if type(itemId) == "string" and n > 0 then
            inventoryCount = inventoryCount + n
            inventoryKinds = inventoryKinds + 1
            lastInventoryGain = string.format("%s x%d", itemId, n)
        end
    end)
    for _, name in ipairs({ "ChatNotify", "AlertPlayer" }) do
        pcall(function()
            link(P[name], function(a, b)
                local text = b or a
                if type(text) == "string" and #text < 200 then
                    text = text:gsub("<[^>]->", "")
                    codeMessages[#codeMessages + 1] = text
                    if #codeMessages > 12 then table.remove(codeMessages, 1) end
                end
            end)
        end)
    end
    pcall(function() P.RequestInventory:Fire() end)
    link(P.ZombieDied, function() end)
    link(P.BossSpawned, function()
        if Config.autoBoss then
            task.delay(2, function()
                local pk = getPackets()
                if pk then pcall(function() pk.JoinBattle:Fire() end) end
            end)
        end
    end)
end)

task.spawn(function()
    while true do
        if isTomb() then break end
        task.wait(0.1)
        pcall(updateESP)
    end
end)

task.spawn(function()
    while true do
        if isTomb() then break end
        if Config.autoSkill then pcall(trySkills) end
        if Config.autoQuest then pcall(tryQuests) end
        if Config.autoBoss then pcall(tryBoss) end
        pcall(syncAutoDrive)
        task.wait(1)
    end
end)

-- ================================================================
-- MAIN LOOP
-- ================================================================
task.spawn(function()
    while true do
        if isTomb() then break end
        pcall(applyCarStats)
        task.wait(0.1)
    end
end)

-- ================================================================
-- TELEPORT
-- ================================================================
local function teleportToCar()
    local car = myCar()
    local chassis = carChassis(car)
    if not chassis then return false, "No car deployed" end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then return true end
    local seat = nil
    if car then
        for _, d in ipairs(car:GetDescendants()) do
            if d:IsA("Seat") then
                seat = d
                break
            end
        end
    end
    if not seat then return false, "No seat found" end
    local cf = seat.CFrame * CFrame.new(0, 3, 0)
    local ok, err = pcall(function()
        hum.Sit = true
        hum:MoveTo(cf.Position)
        -- SeatPart is read only, so assigning it always threw and made this
        -- button report a failure; Seat:Sit is the call that actually welds.
        seat:Sit(hum)
    end)
    if not ok then return false, tostring(err) end
    return true
end

local function teleportToOrigin()
    local car = myCar()
    local chassis = carChassis(car)
    if not chassis then return false, "No car deployed" end
    local origin = car:GetAttribute("RunOrigin")
    if typeof(origin) ~= "Vector3" then return false, "No RunOrigin" end
    local target = origin + Vector3.new(0, 3, 0)
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        pcall(function() hum.Sit = false end)
    end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false, "No character" end
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(target)
    end)
    -- The server corrects a client-written character CFrame within a few
    -- frames when the jump is long, so the write below can look like it
    -- worked and then vanish. Check we actually stayed before saying success.
    task.wait(0.4)
    local again = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if again and (again.Position - target).Magnitude > 25 then
        return false, "Too far to jump - get closer to your plot first"
    end
    return true
end


-- ================================================================
-- UI -- comment) Oxidelib
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

Library.ConfigFolder = "exlumiaa/bkillzombies"

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

Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Build and Kill Zombies",
    Size = UDim2.fromOffset(700, 490),
    Scale = 1.1,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Build and Kill Zombies",
    LoadingFooter = "by Exlumiaa Hub",
    StatusText = "Exlumiaa Hub is ready",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

pcall(function()
    local gui = Window:FindFirstChildOfClass("ScreenGui") or Library.ScreenGui
    if gui then rawset(_G, _G_GUI, gui) end
end)

local function notify(title, content, ntype)
    pcall(function()
        Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 })
    end)
end


-- ================================================================
-- SERVER HOP
-- ================================================================
local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    local ok, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if ok and result then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(result) end)
        if decodeOk and data and data.data then
            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        end
    end
    if #servers > 0 then
        local target = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, target, LP)
    else
        TeleportService:Teleport(placeId)
    end
end

-- ================================================================

-- ================================================================
-- UI TABS
-- ================================================================
local HomeTab = Window:AddTab({ Name = "Home", Icon = "home", Subtitle = "Info" })
local InfoSub = HomeTab:AddSubTab("Info")
autosaveWrap(InfoSub)

InfoSub:AddSection("Player")
local labelHealth = InfoSub:AddLabel({ Text = "Health: -" })
local labelPos = InfoSub:AddLabel({ Text = "Pos: -" })
local labelCash = InfoSub:AddLabel({ Text = "Cash: -" })
local labelDistance = InfoSub:AddLabel({ Text = "Distance: -" })
local labelParts = InfoSub:AddLabel({ Text = "Parts Picked Up: 0" })
local labelLastGain = InfoSub:AddLabel({ Text = "Last Part: -" })
local labelBuy = InfoSub:AddLabel({ Text = "Last Buy: -" })
local labelEventHome = InfoSub:AddLabel({ Text = "Event: -" })

InfoSub:AddSection("Car")
local labelCar = InfoSub:AddLabel({ Text = "Car: not deployed" })
local labelTopSpeed = InfoSub:AddLabel({ Text = "TopSpeed: -" })
local labelCarHealth = InfoSub:AddLabel({ Text = "Car Health: -" })
local labelFuel = InfoSub:AddLabel({ Text = "Fuel: -" })
local labelVel = InfoSub:AddLabel({ Text = "Velocity: -" })

InfoSub:AddSection("Server")
InfoSub:AddLabel({ Text = "Place: " .. tostring(game.PlaceId) })
InfoSub:AddLabel({ Text = "Job: " .. tostring(game.JobId) })
local labelPing = InfoSub:AddLabel({ Text = "Ping: --" })
local labelPlayers = InfoSub:AddLabel({ Text = "Players: --" })
InfoSub:AddLabel({ Text = "by Exlumiaa Hub" })

task.spawn(function()
    local avgMs = 0
    while true do
        -- refresh faster while the ESP is on so the labels do not lag behind
        task.wait(Config.espEnabled and 0.1 or 0.5)
        if isTomb() then break end
        -- the ESP runs outside the label pcall: one bad label Set used to abort
        -- the block before the ESP was ever reached, which left it dead
        pcall(updateESP)
        pcall(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                labelHealth:Set("Health: " .. ("%d/%d"):format(math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5)))
            end
            if root then
                local p = root.Position
                labelPos:Set(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
            end
            local ls = LP:FindFirstChild("leaderstats")
            if ls then
                local cash = ls:FindFirstChild("💵 Cash") or ls:FindFirstChild("Cash")
                if cash then labelCash:Set("Cash: " .. tostring(cash.Value)) end
                local dist = ls:FindFirstChild("⭐ Distance") or ls:FindFirstChild("Distance")
                if dist then labelDistance:Set("Distance: " .. tostring(dist.Value)) end
            end
            labelParts:Set("Parts Picked Up: " .. tostring(inventoryCount))
            labelLastGain:Set("Last Part: " .. tostring(lastInventoryGain or "-"))
            labelBuy:Set("Last Buy: " .. tostring(lastBuyResult or "-"))
            labelEventHome:Set("Event: " .. tostring(liveEvent.name))
            local car = myCar()
            if car then
                labelCar:Set("Car: deployed")
                labelTopSpeed:Set("TopSpeed: " .. tostring(car:GetAttribute("TopSpeed")))
                labelCarHealth:Set("Car Health: " .. tostring(car:GetAttribute("CarHealth")))
                labelFuel:Set("Fuel: " .. tostring(car:GetAttribute("Fuel")))
                local ch = carChassis(car)
                labelVel:Set("Velocity: " .. (ch and ("%.0f"):format(ch.AssemblyLinearVelocity.Magnitude) or "-"))
            else
                labelCar:Set("Car: not deployed")
                labelTopSpeed:Set("TopSpeed: -")
                labelCarHealth:Set("Car Health: -")
                labelFuel:Set("Fuel: -")
                labelVel:Set("Velocity: -")
            end
            local stats = game:GetService("Stats")
            local pingItem = stats.Network.ServerStatsItem["Data Ping"]
            avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
            labelPing:Set("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
            labelPlayers:Set("Players: " .. #Players:GetPlayers())
        end)
    end
end)

-- ================================================================
-- DRIVE TAB
-- ================================================================
local DriveTab = Window:AddTab({ Name = "Drive", Icon = "car", Subtitle = "Go faster" })
local SpeedSub = DriveTab:AddSubTab("Speed")
local DriveAutoSub = DriveTab:AddSubTab("Auto Drive")
-- Spawning, stowing and teleporting the car is still driving, so the buttons
-- live here instead of taking a whole tab of their own.
local DriveCarSub = DriveTab:AddSubTab("Car")

SpeedSub:AddSection("Car Speed")
SpeedSub:AddToggle({
    Name = "Speed Boost",
    Default = Config.speedBoost,
    Flag = "bkz_speed",
    Callback = function(s)
        Config.speedBoost = s
        if not s then baseAttrs = nil end
        pcall(applyCarStats)
    end,
})
SpeedSub:AddSlider({
    Name = "How Much Faster",
    Min = 1,
    Max = 6,
    Default = Config.speedValue,
    Suffix = "x",
    Flag = "bkz_speedval",
    Callback = function(v)
        Config.speedValue = v
        pcall(applyCarStats)
    end,
})
SpeedSub:AddLabel({ Text = "1x normal, 3x = 3x speed" })
SpeedSub:AddLabel({ Text = "Max 6x, above = crash" })

DriveAutoSub:AddSection("Let The Car Drive Itself")
DriveAutoSub:AddToggle({
    Name = "Auto Drive",
    Default = Config.autoDrive,
    Flag = "bkz_autodrive",
    Callback = function(s)
        Config.autoDrive = s
        pcall(syncAutoDrive)
    end,
})
DriveAutoSub:AddSlider({
    Name = "Drive Speed",
    Min = 24,
    Max = 130,
    Default = Config.autoDriveSpeed,
    Suffix = "",
    Flag = "bkz_drivespeed",
    Callback = function(v)
        Config.autoDriveSpeed = v
    end,
})
DriveAutoSub:AddLabel({ Text = "Max 130, above = crash" })
local labelDriveStatus = DriveAutoSub:AddLabel({ Text = "Status: off" })
task.spawn(function()
    while not isTomb() do
        pcall(function() labelDriveStatus:Set("Status: " .. tostring(driveStatus)) end)
        task.wait(0.5)
    end
end)

DriveAutoSub:AddDivider()

DriveAutoSub:AddSection("While Driving")
DriveAutoSub:AddToggle({
    Name = "Auto Crush Zombies",
    Default = Config.autoCrush,
    Flag = "bkz_crush",
    Callback = function(s)
        Config.autoCrush = s
        pcall(syncAutoDrive)
    end,
})
DriveAutoSub:AddLabel({ Text = "Steers into zombies" })
DriveAutoSub:AddToggle({
    Name = "Catch Fuel Cans",
    Default = Config.fuelCollect,
    Flag = "bkz_fuel",
    Callback = function(s)
        Config.fuelCollect = s
        pcall(syncAutoDrive)
    end,
})
DriveAutoSub:AddLabel({ Text = "Boss fights only" })

-- ================================================================
-- COMBAT TAB
-- ================================================================
-- Zombies live here too, not in their own tab: you need the ESP on screen
-- for Auto Crush to aim at anything, so splitting them apart only meant
-- toggling back and forth.
local CombatTab = Window:AddTab({ Name = "Combat", Icon = "swords", Subtitle = "Fight back" })
local FightSub = CombatTab:AddSubTab("Power")

FightSub:AddSection("Kill Zombies Faster")
FightSub:AddToggle({
    Name = "Damage Boost",
    Default = Config.damageBoost,
    Flag = "bkz_damage",
    Callback = function(s) Config.damageBoost = s end,
})
FightSub:AddSlider({
    Name = "How Much More Damage",
    Min = 0,
    Max = 50,
    Default = Config.damageValue,
    Suffix = "x",
    Flag = "bkz_damageval",
    Callback = function(v) Config.damageValue = v end,
})
FightSub:AddLabel({ Text = "1x normal, 5x = 5x damage" })

FightSub:AddDivider()

FightSub:AddSection("Take Less Damage")
FightSub:AddToggle({
    Name = "Health Boost",
    Default = Config.healthBoost,
    Flag = "bkz_health",
    Callback = function(s) Config.healthBoost = s end,
})
FightSub:AddSlider({
    Name = "Extra Health",
    Min = 0,
    Max = 5000,
    Default = Config.healthValue,
    Suffix = "",
    Flag = "bkz_healthval",
    Callback = function(v) Config.healthValue = v end,
})
FightSub:AddLabel({ Text = "Adds to your max health" })

-- ================================================================
-- ZOMBIES (subtab of Combat)
-- ================================================================
local ESPSub = CombatTab:AddSubTab("Zombies")

ESPSub:AddSection("Zombie ESP")
ESPSub:AddToggle({
    Name = "Show Zombies",
    Default = Config.espEnabled,
    Flag = "bkz_esp",
    Callback = function(s)
        Config.espEnabled = s
        if not s then pcall(clearESP) end
    end,
})
ESPSub:AddLabel({ Text = "Marks every visible zombie" })

ESPSub:AddDivider()

ESPSub:AddSection("What To Show")
ESPSub:AddToggle({
    Name = "Box Around Zombie",
    Default = Config.espBox,
    Flag = "bkz_espbox",
    Callback = function(s) Config.espBox = s end,
})
ESPSub:AddToggle({
    Name = "Zombie Name",
    Default = Config.espName,
    Flag = "bkz_espname",
    Callback = function(s) Config.espName = s end,
})
ESPSub:AddToggle({
    Name = "Distance",
    Default = Config.espDistance,
    Flag = "bkz_espdist",
    Callback = function(s) Config.espDistance = s end,
})
ESPSub:AddSlider({
    Name = "Show Up To",
    Min = 50,
    Max = 1500,
    Default = Config.espMaxDist,
    Suffix = "",
    Flag = "bkz_espmax",
    Callback = function(v) Config.espMaxDist = v end,
})
ESPSub:AddLabel({ Text = "Hides zombies past this" })

-- ================================================================
-- EARN TAB
-- ================================================================
local EarnTab = Window:AddTab({ Name = "Earn", Icon = "star", Subtitle = "Get rewards" })
local EarnSub = EarnTab:AddSubTab("Rewards")

EarnSub:AddSection("Buy Things For Me")
EarnSub:AddToggle({
    Name = "Auto Buy Skills",
    Default = Config.autoSkill,
    Flag = "bkz_autoskill",
    Callback = function(s) Config.autoSkill = s end,
})
EarnSub:AddLabel({ Text = "Buys skills when affordable" })
EarnSub:AddToggle({
    Name = "Auto Claim Quests",
    Default = Config.autoQuest,
    Flag = "bkz_autoquest",
    Callback = function(s) Config.autoQuest = s end,
})
EarnSub:AddLabel({ Text = "Claims finished quests" })

EarnSub:AddDivider()

EarnSub:AddSection("Roll For Items")
EarnSub:AddToggle({
    Name = "Auto Roll",
    Default = Config.autoRoll,
    Flag = "bkz_autoroll",
    Callback = function(s)
        Config.autoRoll = s
        if s then
            startAutoRoll()
        else
            rollStop = true
        end
    end,
})
EarnSub:AddLabel({ Text = "Auto rolls, walks to lever if far" })
rollStationApi = EarnSub:AddDropdown({
    Name = "Which One",
    Options = { "Blocks", "Both", "Weapons" },
    Default = "Blocks",
    Flag = "bkz_rollstation",
})
EarnSub:AddLabel({ Text = "Blocks: car parts, reliable" })
EarnSub:AddLabel({ Text = "Weapons: never worked, avoid" })

EarnSub:AddDivider()

EarnSub:AddSection("Free Stuff")
EarnSub:AddToggle({
    Name = "Auto Redeem Codes",
    Default = Config.autoCodes,
    Flag = "bkz_autocodes",
    Callback = function(s)
        Config.autoCodes = s
        if s then startFreeStuff() end
    end,
})
EarnSub:AddLabel({ Text = "Tries all live codes" })
EarnSub:AddButton({
    Name = "Redeem All Codes Now",
    Primary = true,
    Callback = function() task.spawn(redeemCodes, true) end,
})
EarnSub:AddToggle({
    Name = "Auto Claim Free Chest",
    Default = Config.autoChest,
    Flag = "bkz_chest",
    Callback = function(s)
        Config.autoChest = s
        if s then startFreeStuff() end
    end,
})
EarnSub:AddLabel({ Text = "Grabs plot chest reward" })

EarnSub:AddDivider()

EarnSub:AddSection("Roll Options")
EarnSub:AddToggle({
    Name = "Buy What You Roll",
    Default = Config.autoBuyRoll,
    Flag = "bkz_autobuyroll",
    Callback = function(s) Config.autoBuyRoll = s end,
})
EarnSub:AddLabel({ Text = "Buys the rolled item" })
EarnSub:AddSlider({
    Name = "Max Price Per Part",
    Min = 0,
    Max = 50000,
    Step = 500,
    Suffix = "",
    Default = Config.maxBuyPrice,
    Flag = "bkz_maxbuy",
    Callback = function(v) Config.maxBuyPrice = v end,
})
EarnSub:AddLabel({ Text = "0 = no limit, costs cash" })
EarnSub:AddToggle({
    Name = "Skip The Spin Animation",
    Default = Config.autoRollSkip,
    Flag = "bkz_rollskip",
    Callback = function(s) Config.autoRollSkip = s end,
})
EarnSub:AddLabel({ Text = "Skips the spin wait" })
rollCategoryApi = EarnSub:AddMultiDropdown({
    Name = "What To Roll",
    Options = { "Block", "Engine", "Fuel", "Wheel" },
    Default = { "Block", "Engine", "Fuel", "Wheel" },
    Flag = "bkz_rollcats",
})
EarnSub:AddButton({
    Name = "Apply Categories",
    Callback = function()
        task.spawn(function()
            applyRollCategories()
            notify("Roll", "Categories sent to the game", "success")
        end)
    end,
})
EarnSub:AddLabel({ Text = "Fewer = faster rolls" })

EarnSub:AddDivider()

EarnSub:AddSection("Boss Fights")
EarnSub:AddToggle({
    Name = "Auto Join Boss",
    Default = Config.autoBoss,
    Flag = "bkz_autoboss",
    Callback = function(s) Config.autoBoss = s end,
})
EarnSub:AddLabel({ Text = "Joins boss instantly" })

-- ================================================================
-- CAR BUTTONS (subtab of Drive)
-- ================================================================
DriveCarSub:AddSection("Start And Stop")
DriveCarSub:AddButton({
    Name = "Put Out My Car",
    Primary = true,
    Callback = function()
        task.spawn(function()
            local ok, err = spawnCar()
            if ok then
                notify("Car", "Car is out", "success")
            else
                notify("Car", tostring(err), "error")
            end
        end)
    end,
})
DriveCarSub:AddButton({
    Name = "Put Car Away",
    Callback = function()
        task.spawn(function()
            local ok, err = despawnCar()
            if ok then
                notify("Car", "Car is away", "success")
            else
                notify("Car", tostring(err), "error")
            end
        end)
    end,
})
DriveCarSub:AddLabel({ Text = "Auto Drive spawns the car" })

DriveCarSub:AddDivider()

DriveCarSub:AddSection("Move Me")
DriveCarSub:AddButton({
    Name = "Jump Into My Car",
    Callback = function()
        local ok, err = teleportToCar()
        if ok then
            notify("Car", "You are in the car", "success")
        else
            notify("Car", tostring(err), "error")
        end
    end,
})
DriveCarSub:AddButton({
    Name = "Back To Start Line",
    Callback = function()
        local ok, err = teleportToOrigin()
        if ok then
            notify("Car", "Back at the start", "success")
        else
            notify("Car", tostring(err), "error")
        end
    end,
})

-- ================================================================
-- SETTINGS TAB
-- ================================================================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")

ConfigSub:AddSection("Config")
ConfigSub:AddInput({
    Name = "Config Name",
    Placeholder = "default",
    Default = "default",
    Flag = "bkz_configname",
    Callback = function(v) currentConfig = (v ~= "" and v or "default") end,
})
ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        pcall(function() Library:SaveConfig(currentConfig) end)
        notify("Config", "Saved: " .. currentConfig, "success")
    end,
})
ConfigSub:AddButton({
    Name = "Load Config",
    Callback = function()
        local ok = pcall(function() Library:LoadConfig(currentConfig) end)
        notify("Config", ok and ("Loaded: " .. currentConfig) or "Load failed", ok and "success" or "error")
    end,
})
ConfigSub:AddButton({
    Name = "Delete Config",
    Callback = function()
        local ok = pcall(function() Library:DeleteConfig(currentConfig) end)
        notify("Config", ok and ("Deleted: " .. currentConfig) or "Delete failed", ok and "success" or "error")
    end,
})

ConfigSub:AddDivider()

ConfigSub:AddSection("Server")
ConfigSub:AddButton({
    Name = "Server Hop",
    Callback = function()
        notify("Server Hop", "Finding a new server...", "info")
        task.spawn(function()
            local ok, err = pcall(serverHop)
            if not ok then
                notify("Server Hop", "Failed: " .. tostring(err), "error")
            end
        end)
    end,
})
ConfigSub:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end,
})

ConfigSub:AddDivider()

ConfigSub:AddSection("About")
ConfigSub:AddLabel({ Text = "Exlumiaa Hub" })
ConfigSub:AddLabel({ Text = "Toggle: Right Shift" })


-- ================================================================
-- EVENTS / CLEANUP
-- ================================================================
local function teardown()
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_ALIVE, nil)
    pcall(stopAutoDrive)
    pcall(clearESP)
    pcall(function()
        local car = myCar()
        if car and baseAttrs then
            if baseAttrs.TopSpeed then car:SetAttribute("TopSpeed", baseAttrs.TopSpeed) end
            if baseAttrs.Accel then car:SetAttribute("Accel", baseAttrs.Accel) end
        end
        if car then
            car:SetAttribute("TotalDamageExtra", 0)
            car:SetAttribute("TotalHealthExtra", 0)
        end
    end)
    pcall(function()
        if Window and type(Window.Destroy) == "function" then
            Window:Destroy()
        end
    end)
end

if STATE and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(teardown)
end

if Config.autoDrive or Config.autoCrush or Config.fuelCollect then
    task.spawn(startAutoDrive)
end

pcall(wireLiveEvent)

pcall(function() Library:LoadConfig("default") end)
task.wait(0.2)
pcall(syncAutoDrive)

print("[ExlumiaaHub] Build and Kill Zombies hub loaded!")

