-- Voxel Wars - Exlumiaa Hub
-- universe 10773416193 / place 78884249003161
--
-- Client-side only: ESP, aimbot, silent aim, trigger bot, no recoil.
-- Nothing here writes health, damage, scrap or XP. The game paints a red/purple
-- tag over anyone who fires its bait remotes (togglegod, setwalkspeed,
-- applydamage, espupdate, aimassisttarget, ...), so those are never touched.
--
-- Key system: Panda Auth (exlumiaa).

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local GEN = (tonumber(getgenv().__voxelWarsGen) or 0) + 1
getgenv().__voxelWarsGen = GEN

-- Drawing objects outlive the script: without this the old run's ESP boxes and
-- FOV circle stay on screen after a reload.
pcall(cleardrawcache)

local function stale()
    return tonumber(getgenv().__voxelWarsGen) ~= GEN
end

local function cleanupGui(name)
    pcall(function()
        local cg = game:GetService("CoreGui")
        for _, gui in ipairs(cg:GetChildren()) do
            if gui.Name == name then gui:Destroy() end
        end
        -- Oxidelib parents its screens under RobloxGui, not directly under CoreGui.
        local rg = cg:FindFirstChild("RobloxGui")
        for _, gui in ipairs(rg and rg:GetChildren() or {}) do
            if gui.Name == name then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        for _, gui in ipairs(pg and pg:GetChildren() or {}) do
            if gui.Name == name then gui:Destroy() end
        end
    end)
end
cleanupGui("ExlumiaaHub")
-- One tag gui is left behind per reload by the UI library.
cleanupGui("OxidelibTagGui")
cleanupGui("VoxelWarsKeyGate")

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_voxelwars.txt"
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
        local old = pg:FindFirstChild("VoxelWarsKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "VoxelWarsKeyGate"
        sc.ResetOnSpawn = false
        sc.IgnoreGuiInset = true
        sc.DisplayOrder = 998
        sc.Parent = pg

        local accent = Color3.fromRGB(255, 176, 58)
        local accent2 = Color3.fromRGB(255, 214, 150)

        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundColor3 = Color3.fromRGB(12, 10, 7)
        overlay.BackgroundTransparency = 0.1
        overlay.BorderSizePixel = 0
        overlay.Parent = sc

        local card = Instance.new("Frame")
        card.Name = "Card"
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.fromScale(0.5, 0.5)
        card.Size = UDim2.fromOffset(360, 330)
        card.BackgroundColor3 = Color3.fromRGB(22, 18, 12)
        card.BorderSizePixel = 0
        card.Parent = sc
        local cardc = Instance.new("UICorner"); cardc.CornerRadius = UDim.new(0, 16); cardc.Parent = card
        local cardStroke = Instance.new("UIStroke"); cardStroke.Color = accent; cardStroke.Transparency = 0.6; cardStroke.Thickness = 1; cardStroke.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 42)
        title.Position = UDim2.fromOffset(0, 20)
        title.BackgroundTransparency = 1
        title.Text = "Voxel Wars: Enhanced"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 22
        title.TextColor3 = Color3.fromRGB(255, 246, 235)
        title.Parent = card
        local titleGrad = Instance.new("UIGradient"); titleGrad.Rotation = -8; titleGrad.Color = ColorSequence.new(accent, accent2); titleGrad.Parent = title

        local subtitle = Instance.new("TextLabel")
        subtitle.Size = UDim2.new(1, 0, 0, 16)
        subtitle.Position = UDim2.fromOffset(0, 62)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = "Enter your key to unlock"
        subtitle.Font = Enum.Font.Gotham
        subtitle.TextSize = 12
        subtitle.TextColor3 = Color3.fromRGB(175, 160, 138)
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
        keyBox.BackgroundColor3 = Color3.fromRGB(34, 28, 20)
        keyBox.BorderSizePixel = 0
        keyBox.Font = Enum.Font.GothamBold
        keyBox.TextSize = 16
        keyBox.TextColor3 = Color3.fromRGB(255, 246, 235)
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
        getBtn.TextColor3 = Color3.fromRGB(20, 12, 2)
        local verifyBtn = makeButton("Verify", 270, Color3.fromRGB(62, 50, 34))
        verifyBtn.Name = "VerifyBtn"

        local hint = Instance.new("TextLabel")
        hint.Size = UDim2.new(1, -32, 0, 30)
        hint.Position = UDim2.fromOffset(16, 268)
        hint.BackgroundTransparency = 1
        hint.Text = "Open the link, complete the ad, then paste your key."
        hint.Font = Enum.Font.Gotham
        hint.TextSize = 11
        hint.TextColor3 = Color3.fromRGB(140, 125, 102)
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

-- ================================================================
-- STATE
-- ================================================================
local S = {
    teamCheck = true,
    -- aimbot
    aim = false, aimFov = 20, aimSmooth = 6, aimPred = true, aimSpeed = 1700,
    aimPart = "Head", aimWall = true, aimKey = nil,
    -- silent aim (ballistics launch-direction redirect)
    silent = false, silentFov = 25,
    -- trigger bot
    trigger = false, triggerFov = 5, triggerDelay = 120,
    -- weapon
    noRecoil = false,
    -- esp
    esp = false, espBox = true, espFill = false, espName = true, espDist = true,
    espHealth = true, espTracer = false, espSkel = false, espHead = false,
    espBots = true, espObj = false, espMax = 900,
    -- misc
    autoSprint = false,
}

local connections = {}
local function track(conn)
    connections[#connections + 1] = conn
    return conn
end

local function disconnectAll()
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}
end

-- ================================================================
-- TARGETS
-- ================================================================
local function collectTargets()
    local list = {}
    local myTeam = LP.Team and LP.Team.Name

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local team = p.Team and p.Team.Name
                list[#list + 1] = {
                    char = char, hum = hum, name = p.DisplayName,
                    friendly = team ~= nil and team == myTeam,
                    protected = false, isBot = false,
                }
            end
        end
    end

    local rigs = workspace:FindFirstChild("BotRigs")
    if rigs then
        for _, m in ipairs(rigs:GetChildren()) do
            local hum = m:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and m:GetAttribute("Alive") ~= false then
                local team = m:GetAttribute("Team")
                list[#list + 1] = {
                    char = m, hum = hum, name = m.Name,
                    friendly = team ~= nil and team == myTeam,
                    protected = m:GetAttribute("Protected") == true, isBot = true,
                }
            end
        end
    end

    return list
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function hasLOS(t, pos)
    if not S.aimWall then return true end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local filter = {}
    if LP.Character then filter[#filter + 1] = LP.Character end
    if t.char then filter[#filter + 1] = t.char end
    -- The first-person viewmodel hangs off the camera and sits right in front of
    -- it, so leaving it in the filter makes every target read as wall-blocked.
    if cam then filter[#filter + 1] = cam end
    rayParams.FilterDescendantsInstances = filter
    local res = workspace:Raycast(cam.CFrame.Position, pos - cam.CFrame.Position, rayParams)
    return res == nil
end

local function aimPosOf(t)
    local char = t.char
    if not char then return nil end
    local part = char:FindFirstChild(S.aimPart)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
    if not part then return nil end
    local pos = part.Position
    if S.aimPred then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local vel = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
        local cam = workspace.CurrentCamera
        if cam then
            local dist = (pos - cam.CFrame.Position).Magnitude
            pos = pos + vel * (dist / math.max(S.aimSpeed, 1))
        end
    end
    return pos, part
end

-- Closest to crosshair inside a cone of `fovDeg` degrees.
local function pickTarget(list, fovDeg)
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local origin = cam.CFrame.Position
    local look = cam.CFrame.LookVector
    local best, bestDot = nil, math.cos(math.rad(fovDeg))

    for _, t in ipairs(list) do
        if not (S.teamCheck and t.friendly) and not t.protected then
            local pos = aimPosOf(t)
            if pos then
                local delta = pos - origin
                local len = delta.Magnitude
                if len > 1 then
                    local dot = delta.Unit:Dot(look)
                    if dot > bestDot and hasLOS(t, pos) then
                        bestDot = dot
                        best = { target = t, pos = pos }
                    end
                end
            end
        end
    end

    return best
end

-- ================================================================
-- FIRING
-- ================================================================
local remotesFolder = RS:FindFirstChild("Voxel")
    and RS.Voxel:FindFirstChild("Remotes")

local fireRemotes = {}
local function refreshFireRemotes()
    fireRemotes = {}
    if not remotesFolder then return end
    for _, c in ipairs(remotesFolder:GetChildren()) do
        if c:IsA("RemoteEvent") and string.sub(c.Name, 1, 4) == "Fire" then
            fireRemotes[c] = true
        end
    end
end
refreshFireRemotes()

-- Tool.LocalScript is named after the weapon family: PistolClient -> FirePistol.
local function equippedWeapon()
    local char = LP.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    local ls = tool:FindFirstChildOfClass("LocalScript")
    if not ls then return nil end
    local base = string.gsub(ls.Name, "Client$", "")
    local remote = remotesFolder and remotesFolder:FindFirstChild("Fire" .. base)
    if not remote then return nil end
    return tool, remote
end

-- ================================================================
-- SILENT AIM (Ballistics hook)
-- The game's launch direction is solved inside Ballistics:
--   v1 = Ballistics.launch / zeroed(muzzle, aimPoint, speed, arc)
-- In this executor, hookfunction makes the ORIGINAL function unreachable, so the
-- wrappers re-solve the exact upstream maths themselves and never call it.
-- ================================================================
local ballistics = nil
do
    local vox = RS:FindFirstChild("Voxel")
    if vox then
        local mod = vox:FindFirstChild("Ballistics")
        if mod then
            local ok, m = pcall(require, mod)
            if ok and type(m) == "table" then ballistics = m end
        end
    end
end

local ballisticsHooked = false

local function flightTimeMath(a1, a2, a3)
    local v1
    local SPEED = a2 or 1700
    if not a3 then
        local SPD = a2 or 1700
        v1 = false
        if 1600 <= SPD then
            v1 = SPD < 2000
        end
    else
        v1 = true
    end
    if not v1 then
        return a1 / SPEED
    end
    local drag = if not a3 then 0.0014 else a3.drag
    return (math.exp(drag * a1) - 1) / (drag * SPEED)
end

-- Replica of Ballistics.launch (ReplicatedStorage.Voxel.Ballistics), line for line.
local function launchMath(a1, a2, a3, a4)
    local v1
    local v2 = a2 - a1
    if not a4 then
        local SPEED = a3 or 1700
        v1 = false
        if 1600 <= SPEED then
            v1 = SPEED < 2000
        end
    else
        v1 = true
    end
    if not v1 then
        return v2.Unit
    end
    v1 = flightTimeMath(v2.Magnitude, a3, a4)
    local SPEED_2 = a3 or 1700
    local drag = if not a4 then 0.0014 else a4.drag
    local v3 = drag * SPEED_2
    local gravity = if not a4 then 24.525 else a4.gravity
    return (v2 + Vector3.new(0, gravity * (v1 * v1 / 4 + (v3 * v1 - math.log(1 + v3 * v1)) / (2 * v3 * v3)), 0)).Unit
end

local function silentPick()
    if not S.silent then return nil end
    local ok, pick = pcall(pickTarget, collectTargets(), tonumber(S.silentFov) or 25)
    if not ok then return nil end
    return pick
end

local function launchWrapper(a1, a2, a3, a4)
    local pick = silentPick()
    local aim = a2
    if pick and typeof(a1) == "Vector3" and typeof(pick.pos) == "Vector3" then
        aim = pick.pos
    end
    return launchMath(a1, aim, a3, a4)
end

local function zeroedWrapper(a1, a2, a3, a4)
    local pick = silentPick()
    if pick and typeof(a1) == "Vector3" and typeof(pick.pos) == "Vector3" then
        return launchMath(a1, pick.pos, a3, a4)
    end
    return launchMath(a1, a1 + a2 * 250, a3, a4)
end

-- Always installed; with S.silent off the wrappers are faithful replicas of the
-- original functions, so the game's weapons behave exactly as before.
local function installBallisticsHook()
    if ballisticsHooked or not ballistics then return end
    if type(hookfunction) ~= "function" then return end
    local ok1 = pcall(hookfunction, ballistics.launch, launchWrapper)
    local ok2 = pcall(hookfunction, ballistics.zeroed, zeroedWrapper)
    ballisticsHooked = ok1 and ok2
end

installBallisticsHook()

local function restoreBallisticsHook()
    S.silent = false
end

-- ================================================================
-- NO RECOIL (the recoil module is the shared prototype of every gun)
-- ================================================================
local recoilModule = nil
do
    local ok, m = pcall(require, RS:FindFirstChild("Voxel") and RS.Voxel:FindFirstChild("GunRecoil") or nil)
    if ok and type(m) == "table" then recoilModule = m end
end

local recoilOrigStep, recoilOrigShot

local function applyNoRecoil(on)
    if not recoilModule then return end
    if on then
        if recoilOrigStep then return end
        recoilOrigStep = recoilModule.step
        recoilOrigShot = recoilModule.shot
        recoilModule.step = function() return 0, 0, 0 end
        recoilModule.shot = function() end
    elseif recoilOrigStep then
        recoilModule.step = recoilOrigStep
        recoilModule.shot = recoilOrigShot
        recoilOrigStep, recoilOrigShot = nil, nil
    end
end

-- ================================================================
-- ESP (Drawing)
-- ================================================================
local BONES = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}

local ENEMY = Color3.fromRGB(255, 62, 84)
local FRIENDLY = Color3.fromRGB(90, 220, 140)

local espCache = {}
local objCache = {}

local function mk(class, props)
    local ok, d = pcall(function() return Drawing.new(class) end)
    if not ok or not d then return nil end
    for k, v in pairs(props or {}) do
        pcall(function() d[k] = v end)
    end
    return d
end

local function killObj(o)
    if not o then return end
    pcall(function()
        if isrenderobj(o) then o:Remove() end
    end)
end

local function makeEspEntry()
    local e = { box = {}, out = {}, skel = {}, skelOut = {} }
    for i = 1, 4 do
        e.out[i] = mk("Line", { Thickness = 3, Color = Color3.new(0, 0, 0), Visible = false })
        e.box[i] = mk("Line", { Thickness = 1.5, Visible = false })
    end
    for i = 1, #BONES do
        e.skelOut[i] = mk("Line", { Thickness = 3, Color = Color3.new(0, 0, 0), Visible = false })
        e.skel[i] = mk("Line", { Thickness = 1.2, Visible = false })
    end
    e.fill = mk("Quad", { Filled = true, Transparency = 0.8, Visible = false })
    e.name = mk("Text", { Size = 13, Center = true, Outline = true, Visible = false })
    e.dist = mk("Text", { Size = 11, Center = true, Outline = true, Visible = false })
    e.hpBg = mk("Quad", { Filled = true, Color = Color3.new(0, 0, 0), Transparency = 0.4, Visible = false })
    e.hpFg = mk("Quad", { Filled = true, Visible = false })
    e.tracer = mk("Line", { Thickness = 1, Transparency = 0.4, Visible = false })
    e.head = mk("Circle", { Radius = 3, Filled = true, Visible = false })
    if not (e.box[1] and e.fill and e.name and e.hpFg and e.tracer and e.head) then
        for _, v in pairs(e) do
            if type(v) == "table" then
                for _, o in ipairs(v) do killObj(o) end
            else
                killObj(v)
            end
        end
        return nil
    end
    return e
end

local function destroyEntry(e)
    if not e then return end
    for _, v in pairs(e) do
        if type(v) == "table" then
            for _, o in ipairs(v) do killObj(o) end
        else
            killObj(v)
        end
    end
end

local function hideEntry(e)
    if not e then return end
    for _, v in pairs(e) do
        if type(v) == "table" then
            for _, o in ipairs(v) do pcall(function() o.Visible = false end) end
        else
            pcall(function() v.Visible = false end)
        end
    end
end

local function boundingBox(char, cam)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return nil end

    local topWorld = head.Position + Vector3.new(0, 0.75, 0)
    local botWorld = hrp.Position - Vector3.new(0, 3.1, 0)
    local a, aOn = cam:WorldToViewportPoint(topWorld)
    local b, bOn = cam:WorldToViewportPoint(botWorld)
    if not aOn and not bOn then return nil end

    local cx = (a.X + b.X) * 0.5
    local topY = a.Y
    local botY = b.Y
    local h = math.abs(botY - topY)
    if h < 2 then return nil end
    local w = h * 0.45

    return {
        tl = Vector2.new(cx - w * 0.5, topY),
        tr = Vector2.new(cx + w * 0.5, topY),
        bl = Vector2.new(cx - w * 0.5, botY),
        br = Vector2.new(cx + w * 0.5, botY),
        cx = cx, topY = topY, botY = botY, w = w, h = h,
        head = head,
    }
end

local function updateEsp(t, cam)
    local key = t.char
    local e = espCache[key]

    if not S.esp or (S.teamCheck and t.friendly) or (t.isBot and not S.espBots) then
        hideEntry(e)
        return
    end

    local bb = boundingBox(t.char, cam)
    if not bb then
        hideEntry(e)
        return
    end

    local dist = (cam.CFrame.Position - bb.head.Position).Magnitude
    if dist > S.espMax then
        hideEntry(e)
        return
    end

    if not e then
        e = makeEspEntry()
        if not e then return end
        espCache[key] = e
    end

    local col = t.friendly and FRIENDLY or ENEMY

    for i = 1, 4 do
        e.out[i].Visible = S.espBox
        e.box[i].Visible = S.espBox
    end
    if S.espBox then
        e.out[1].From, e.out[1].To = bb.tl, bb.tr
        e.out[2].From, e.out[2].To = bb.bl, bb.br
        e.out[3].From, e.out[3].To = bb.tl, bb.bl
        e.out[4].From, e.out[4].To = bb.tr, bb.br
        e.box[1].From, e.box[1].To = bb.tl, bb.tr
        e.box[2].From, e.box[2].To = bb.bl, bb.br
        e.box[3].From, e.box[3].To = bb.tl, bb.bl
        e.box[4].From, e.box[4].To = bb.tr, bb.br
        for i = 1, 4 do e.box[i].Color = col end
    end

    if S.espFill then
        e.fill.PointA, e.fill.PointB = bb.tl, bb.tr
        e.fill.PointC, e.fill.PointD = bb.br, bb.bl
        e.fill.Color = col
        e.fill.Visible = true
    else
        e.fill.Visible = false
    end

    if S.espName then
        e.name.Text = t.name .. (t.protected and " [PROT]" or "")
        e.name.Position = Vector2.new(bb.cx, bb.topY - 14)
        e.name.Color = col
        e.name.Visible = true
    else
        e.name.Visible = false
    end

    if S.espDist then
        e.dist.Text = string.format("%dm", math.floor(dist))
        e.dist.Position = Vector2.new(bb.cx, bb.botY + 3)
        e.dist.Color = col
        e.dist.Visible = true
    else
        e.dist.Visible = false
    end

    if S.espHealth then
        local hp = math.clamp(t.hum.Health / math.max(t.hum.MaxHealth, 1), 0, 1)
        local bx = bb.tr.X + 4
        e.hpBg.PointA = Vector2.new(bx, bb.topY)
        e.hpBg.PointB = Vector2.new(bx + 3, bb.topY)
        e.hpBg.PointC = Vector2.new(bx + 3, bb.botY)
        e.hpBg.PointD = Vector2.new(bx, bb.botY)
        local fgTop = bb.botY - (bb.botY - bb.topY) * hp
        e.hpFg.PointA = Vector2.new(bx, fgTop)
        e.hpFg.PointB = Vector2.new(bx + 3, fgTop)
        e.hpFg.PointC = Vector2.new(bx + 3, bb.botY)
        e.hpFg.PointD = Vector2.new(bx, bb.botY)
        e.hpFg.Color = hp > 0.5 and Color3.fromRGB(90, 220, 140)
            or (hp > 0.25 and Color3.fromRGB(240, 200, 70) or Color3.fromRGB(255, 70, 70))
        e.hpBg.Visible = true
        e.hpFg.Visible = true
    else
        e.hpBg.Visible = false
        e.hpFg.Visible = false
    end

    if S.espTracer then
        local vp = cam.ViewportSize
        e.tracer.From = Vector2.new(vp.X * 0.5, vp.Y)
        e.tracer.To = Vector2.new(bb.cx, bb.botY)
        e.tracer.Color = col
        e.tracer.Visible = true
    else
        e.tracer.Visible = false
    end

    if S.espHead then
        local hp, on = cam:WorldToViewportPoint(bb.head.Position)
        if on then
            e.head.Position = Vector2.new(hp.X, hp.Y)
            e.head.Color = col
            e.head.Visible = true
        else
            e.head.Visible = false
        end
    else
        e.head.Visible = false
    end

    for i, bone in ipairs(BONES) do
        if S.espSkel then
            local p1 = t.char:FindFirstChild(bone[1])
            local p2 = t.char:FindFirstChild(bone[2])
            if p1 and p2 then
                local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                if on1 and on2 then
                    local a = Vector2.new(s1.X, s1.Y)
                    local b = Vector2.new(s2.X, s2.Y)
                    e.skelOut[i].From, e.skelOut[i].To = a, b
                    e.skel[i].From, e.skel[i].To = a, b
                    e.skel[i].Color = col
                    e.skelOut[i].Visible = true
                    e.skel[i].Visible = true
                else
                    e.skelOut[i].Visible = false
                    e.skel[i].Visible = false
                end
            else
                e.skelOut[i].Visible = false
                e.skel[i].Visible = false
            end
        else
            e.skelOut[i].Visible = false
            e.skel[i].Visible = false
        end
    end
end

local function updateObjectives(cam)
    local zones = workspace:FindFirstChild("StrikeZones")
    if not (S.esp and S.espObj and zones) then
        for k, d in pairs(objCache) do
            killObj(d)
            objCache[k] = nil
        end
        return
    end

    local seen = {}
    for _, zone in ipairs(zones:GetChildren()) do
        local beacon = zone:FindFirstChild("Beacon")
        if beacon then
            seen[beacon] = true
            local d = objCache[beacon]
            if not d then
                d = mk("Text", { Size = 12, Center = true, Outline = true, Color = Color3.fromRGB(120, 200, 255) })
                objCache[beacon] = d
            end
            if d then
                local sp, on = cam:WorldToViewportPoint(beacon.Position + Vector3.new(0, 3, 0))
                if on then
                    d.Position = Vector2.new(sp.X, sp.Y)
                    d.Text = string.format("BEACON  %dm", math.floor((beacon.Position - cam.CFrame.Position).Magnitude))
                    d.Visible = true
                else
                    d.Visible = false
                end
            end
        end
    end

    for k, d in pairs(objCache) do
        if not seen[k] then
            killObj(d)
            objCache[k] = nil
        end
    end
end

-- ================================================================
-- FRAME LOOP
-- ================================================================
local fovCircle = nil
local aimKeyDown = false
local lastTrigger = 0
local triggerHeld = false

local function fovPixels(deg, cam)
    local half = cam.ViewportSize.Y * 0.5
    return math.tan(math.rad(deg) * 0.5) / math.tan(math.rad(cam.FieldOfView) * 0.5) * half
end

local function onFrame(dt)
    if stale() then return end
    local cam = workspace.CurrentCamera
    if not cam then return end

    local list = collectTargets()

    if S.aim and (S.aimKey == nil or aimKeyDown) then
        local pick = pickTarget(list, S.aimFov)
        if pick then
            local goal = CFrame.lookAt(cam.CFrame.Position, pick.pos)
            cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(S.aimSmooth * dt, 0, 1))
        end
    end

    if S.trigger then
        local now = os.clock()
        local tool = equippedWeapon()
        local ammo = tool and tool:GetAttribute("Ammo")
        local armed = tool ~= nil and not (type(ammo) == "number" and ammo <= 0)
            and now - lastTrigger >= S.triggerDelay / 1000
        local pick = armed and pickTarget(list, S.triggerFov) or nil
        -- Activate once and let the weapon's own fire loop do the shooting:
        -- press() resets the bolt timer, so re-activating every frame never fires.
        if pick and not triggerHeld then
            triggerHeld = true
            pcall(function() tool:Activate() end)
        elseif not pick and triggerHeld then
            triggerHeld = false
            lastTrigger = now
            pcall(function() tool:Deactivate() end)
        end
    elseif triggerHeld then
        triggerHeld = false
        pcall(function()
            local tool = equippedWeapon()
            if tool then tool:Deactivate() end
        end)
    end

    if S.esp then
        local seen = {}
        for _, t in ipairs(list) do
            seen[t.char] = true
            updateEsp(t, cam)
        end
        for char, e in pairs(espCache) do
            if not seen[char] then
                destroyEntry(e)
                espCache[char] = nil
            end
        end
    elseif next(espCache) then
        for char, e in pairs(espCache) do
            destroyEntry(e)
            espCache[char] = nil
        end
    end

    updateObjectives(cam)

    if fovCircle then
        local deg = nil
        if S.aim then
            deg = S.aimFov
        elseif S.silent then
            deg = S.silentFov
        elseif S.trigger then
            deg = S.triggerFov
        end
        if deg then
            fovCircle.Position = cam.ViewportSize * 0.5
            fovCircle.Radius = math.max(fovPixels(deg, cam), 2)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end
end

RunService:BindToRenderStep("VoxelWarsFrame", Enum.RenderPriority.Camera.Value + 2, onFrame)

-- ================================================================
-- MISC
-- ================================================================
local movement = nil
do
    local ok, m = pcall(require, RS:FindFirstChild("Voxel") and RS.Voxel:FindFirstChild("Movement") or nil)
    if ok and type(m) == "table" then movement = m end
end

local function setAutoSprint(on)
    if movement then movement.autoSprint = on and true or false end
end

-- ================================================================
-- UI
-- ================================================================
local Library = nil
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil or stale() then break end
    task.wait(0.25)
end
if not Library or stale() then return end

Library.ConfigFolder = "exlumiaa/voxel-wars"

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Voxel Wars",
    Size = UDim2.fromOffset(500, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Voxel Wars",
    LoadingFooter = "ESP / Aim",
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

-- Clearing here also removes anything the previous run left on screen.
pcall(cleardrawcache)
fovCircle = mk("Circle", { Thickness = 1, Filled = false, Transparency = 0.6, Visible = false })

local CombatTab = Window:AddTab({ Name = "Combat", Icon = "crosshair", Subtitle = "Aim" })
local Combat = CombatTab:AddSubTab("Aim")

Combat:AddSection("Aimbot")
Combat:AddToggle({
    Name = "Aimbot",
    Flag = "vw_aim",
    Default = false,
    Callback = function(v) S.aim = v and true or false end,
})
Combat:AddKeybind({
    Name = "Aim Key (hold)",
    Flag = "vw_aimkey",
    Default = nil,
    Callback = function(key) S.aimKey = key end,
})
Combat:AddSlider({
    Name = "Aimbot FOV",
    Min = 2,
    Max = 90,
    Default = 20,
    Suffix = " deg",
    Flag = "vw_aimfov",
    Callback = function(v) S.aimFov = v end,
})
Combat:AddSlider({
    Name = "Smoothness",
    Min = 1,
    Max = 25,
    Default = 6,
    Flag = "vw_aimsmooth",
    Callback = function(v) S.aimSmooth = v end,
})
Combat:AddDropdown({
    Name = "Target Bone",
    Options = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = "Head",
    Flag = "vw_aimpart",
    Callback = function(v) S.aimPart = v end,
})
Combat:AddToggle({
    Name = "Prediction",
    Flag = "vw_aimpred",
    Default = true,
    Callback = function(v) S.aimPred = v and true or false end,
})
Combat:AddSlider({
    Name = "Projectile Speed",
    Min = 800,
    Max = 2600,
    Default = 1700,
    Suffix = " studs/s",
    Flag = "vw_aimspeed",
    Callback = function(v) S.aimSpeed = v end,
})
Combat:AddToggle({
    Name = "Wall Check",
    Flag = "vw_aimwall",
    Default = true,
    Callback = function(v) S.aimWall = v and true or false end,
})

Combat:AddSection("Silent Aim")
Combat:AddToggle({
    Name = "Silent Aim",
    Flag = "vw_silent",
    Default = false,
    Callback = function(v)
        S.silent = v and true or false
    end,
})
Combat:AddSlider({
    Name = "Silent FOV",
    Min = 2,
    Max = 180,
    Default = 25,
    Suffix = " deg",
    Flag = "vw_silentfov",
    Callback = function(v) S.silentFov = tonumber(v) or 25 end,
})

Combat:AddSection("Trigger Bot")
Combat:AddToggle({
    Name = "Trigger Bot",
    Flag = "vw_trigger",
    Default = false,
    Callback = function(v) S.trigger = v and true or false end,
})
Combat:AddSlider({
    Name = "Trigger FOV",
    Min = 1,
    Max = 30,
    Default = 5,
    Suffix = " deg",
    Flag = "vw_triggerfov",
    Callback = function(v) S.triggerFov = v end,
})
Combat:AddSlider({
    Name = "Trigger Delay",
    Min = 60,
    Max = 400,
    Default = 120,
    Suffix = " ms",
    Flag = "vw_triggerdelay",
    Callback = function(v) S.triggerDelay = v end,
})

local Weapon = CombatTab:AddSubTab("Weapon")
Weapon:AddSection("Recoil")
Weapon:AddToggle({
    Name = "No Recoil",
    Flag = "vw_norecoil",
    Default = false,
    Callback = function(v)
        S.noRecoil = v and true or false
        applyNoRecoil(S.noRecoil)
    end,
})

local VisualsTab = Window:AddTab({ Name = "Visuals", Icon = "target", Subtitle = "ESP" })
local Visuals = VisualsTab:AddSubTab("ESP")

Visuals:AddSection("Players & Bots")
Visuals:AddToggle({
    Name = "ESP",
    Flag = "vw_esp",
    Default = false,
    Callback = function(v) S.esp = v and true or false end,
})
Visuals:AddToggle({
    Name = "Box",
    Flag = "vw_espbox",
    Default = true,
    Callback = function(v) S.espBox = v and true or false end,
})
Visuals:AddToggle({
    Name = "Fill",
    Flag = "vw_espfill",
    Default = false,
    Callback = function(v) S.espFill = v and true or false end,
})
Visuals:AddToggle({
    Name = "Name",
    Flag = "vw_espname",
    Default = true,
    Callback = function(v) S.espName = v and true or false end,
})
Visuals:AddToggle({
    Name = "Distance",
    Flag = "vw_espdist",
    Default = true,
    Callback = function(v) S.espDist = v and true or false end,
})
Visuals:AddToggle({
    Name = "Health Bar",
    Flag = "vw_esphealth",
    Default = true,
    Callback = function(v) S.espHealth = v and true or false end,
})
Visuals:AddToggle({
    Name = "Tracer",
    Flag = "vw_esptracer",
    Default = false,
    Callback = function(v) S.espTracer = v and true or false end,
})
Visuals:AddToggle({
    Name = "Skeleton",
    Flag = "vw_espskel",
    Default = false,
    Callback = function(v) S.espSkel = v and true or false end,
})
Visuals:AddToggle({
    Name = "Head Dot",
    Flag = "vw_esphead",
    Default = false,
    Callback = function(v) S.espHead = v and true or false end,
})
Visuals:AddToggle({
    Name = "Show Bots",
    Flag = "vw_espbots",
    Default = true,
    Callback = function(v) S.espBots = v and true or false end,
})
Visuals:AddSlider({
    Name = "Max Distance",
    Min = 100,
    Max = 2000,
    Default = 900,
    Suffix = " studs",
    Flag = "vw_espmax",
    Callback = function(v) S.espMax = v end,
})
Visuals:AddToggle({
    Name = "Team Check",
    Flag = "vw_teamcheck",
    Default = true,
    Callback = function(v) S.teamCheck = v and true or false end,
})

Visuals:AddSection("World")
Visuals:AddToggle({
    Name = "Beacons",
    Flag = "vw_espobj",
    Default = false,
    Callback = function(v) S.espObj = v and true or false end,
})

local MiscTab = Window:AddTab({ Name = "Misc", Icon = "settings", Subtitle = "Player" })
local Misc = MiscTab:AddSubTab("Player")

Misc:AddSection("Movement")
Misc:AddToggle({
    Name = "Auto Sprint",
    Flag = "vw_sprint",
    Default = false,
    Callback = function(v)
        S.autoSprint = v and true or false
        setAutoSprint(S.autoSprint)
    end,
})

local notify = function(title, content, ntype)
    pcall(function() Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 }) end)
end

local selectedConfig = ""
local configDropdown = nil
local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
    end
end

Misc:AddSection("Config")
local configInput = Misc:AddInput({
    Name = "Config Name",
    Default = "",
    Placeholder = "Enter config name...",
    Flag = "vw_config_name",
})
Misc:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        local n = tostring(name or ""):match("^%s*(.-)%s*$")
        if n == "" then notify("Config", "Enter a name first.", "warning") return end
        local ok = Library:SaveConfig(n)
        if ok then
            refreshConfigList()
            notify("Config", "Saved: " .. n, "success")
        else
            notify("Config", "Save failed.", "error")
        end
    end,
})
configDropdown = Misc:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "vw_config_selected",
    Callback = function(v) selectedConfig = v end,
})
Misc:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if selectedConfig == "" then notify("Config", "Pick a config first.", "warning") return end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            refreshConfigList()
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Load failed.", "error")
        end
    end,
})
Misc:AddButton({
    Name = "Delete Config",
    Primary = false,
    Callback = function()
        if selectedConfig == "" then notify("Config", "Pick a config first.", "warning") return end
        local ok = Library:DeleteConfig(selectedConfig)
        if ok then
            selectedConfig = ""
            refreshConfigList()
            notify("Config", "Deleted.", "success")
        else
            notify("Config", "Delete failed.", "error")
        end
    end,
})

Misc:AddSection("Session")
local status = Misc:AddLabel({ Text = "Ready." })
Misc:AddButton({
    Name = "Session Info",
    Callback = function()
        local n = #collectTargets()
        status:Set(string.format("targets: %d | silent: %s | ballistics hook: %s | aimbot: %s",
            n, tostring(S.silent), tostring(ballisticsHooked), tostring(S.aim)))
    end,
})
Misc:AddButton({
    Name = "Unload Script",
    Primary = true,
    Callback = function()
        getgenv().__voxelWarsGen = (tonumber(getgenv().__voxelWarsGen) or 0) + 1
        disconnectAll()
        pcall(function() RunService:UnbindFromRenderStep("VoxelWarsFrame") end)
        for _, e in pairs(espCache) do destroyEntry(e) end
        espCache = {}
        for _, d in pairs(objCache) do killObj(d) end
        objCache = {}
        killObj(fovCircle)
        fovCircle = nil
        restoreBallisticsHook()
        applyNoRecoil(false)
        setAutoSprint(false)
        pcall(cleardrawcache)
        pcall(function() Library:DestroyAll() end)
        cleanupGui("ExlumiaaHub")
        print("[ExlumiaaHub] Voxel Wars unloaded")
    end,
})

-- ================================================================
-- KEY HOLD + LOAD
-- ================================================================
track(UIS.InputBegan:Connect(function(input, gp)
    if gp or not S.aimKey then return end
    if input.KeyCode == S.aimKey then aimKeyDown = true end
end))
track(UIS.InputEnded:Connect(function(input)
    if not S.aimKey then return end
    if input.KeyCode == S.aimKey then aimKeyDown = false end
end))

getgenv()._voxelWars = {
    S = S,
    applyNoRecoil = applyNoRecoil,
    setAutoSprint = setAutoSprint,
    collectTargets = collectTargets,
    pickTarget = pickTarget,
    equippedWeapon = equippedWeapon,
    fireRemotes = fireRemotes,
    recoilModule = function() return recoilModule end,
    ballisticsInstall = installBallisticsHook,
    ballisticsRestore = restoreBallisticsHook,
    ballisticsHooked = function() return ballisticsHooked end,
}

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

print("[ExlumiaaHub] Voxel Wars loaded | remotes=" .. tostring(remotesFolder ~= nil)
    .. " fire=" .. tostring(next(fireRemotes) ~= nil)
    .. " recoil=" .. tostring(recoilModule ~= nil)
    .. " movement=" .. tostring(movement ~= nil))