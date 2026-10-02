if tostring(game.GameId) ~= "10764497964" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _bseHubTomb1"
local _G_GEN = "_ _bseHubGen"
local _G_COUNTER = "_ _bseHubCounter"

rawset(_G, _G_TOMB, true)

local MY_GEN = (tonumber(rawget(_G, _G_COUNTER)) or 0) + 1
rawset(_G, _G_COUNTER, MY_GEN)
rawset(_G, _G_GEN, MY_GEN)

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

local function isStale()
    return tonumber(rawget(_G, _G_GEN)) ~= MY_GEN
end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_bse.txt"
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
        local old = pg:FindFirstChild("BackstreetKeyGate")
        if old then old:Destroy() end

        local sc = Instance.new("ScreenGui")
        sc.Name = "BackstreetKeyGate"
        sc.ResetOnSpawn = false
        sc.IgnoreGuiInset = true
        sc.DisplayOrder = 998
        sc.Parent = pg

        local accent = Color3.fromRGB(167, 200, 244)
        local accent2 = Color3.fromRGB(190, 215, 250)

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
        title.Text = "Backstreet Survival: Enhanced"
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
        getBtn.TextColor3 = Color3.fromRGB(10, 16, 26)
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
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library then return end

Library.ConfigFolder = "exlumiaa/backstreet"

local Window = nil

local function notify(title, content, typ)
    if not Window then return end
    pcall(function()
        Window:Notify({Title = title, Content = content, Type = typ or "info", Duration = 4})
    end)
end

local Events = ReplicatedStorage:WaitForChild("Events")
local SellFunc = Events:WaitForChild("SellFunc")
local BankFunc = Events:WaitForChild("BankFunc")
local DataFunc = Events:WaitForChild("DataFunc")
local AFKEvent = Events:WaitForChild("AFKEvent")

local State = {
    dig = false,
    sellTrash = false,
    sellFish = false,
    sellCrop = false,
    deposit = false,
    antiAfk = false,
    instantSell = true,
    sellInterval = 6,
    depositInterval = 6,
}

local tokens = {}
local lastMsg = {}
local ticks = {}

local function setLoop(key, enabled, fn, getInterval)
    State[key] = enabled
    tokens[key] = (tokens[key] or 0) + 1
    local myToken = tokens[key]
    if not enabled then
        lastMsg[key] = nil
        return
    end
    print("[BSE] loop start: " .. key)
    task.spawn(function()
        task.wait(0.15)
        while State[key] and tokens[key] == myToken and not isStale() do
            ticks[key] = (ticks[key] or 0) + 1
            local pok, ok, msg = pcall(fn)
            if not pok then
                ok, msg = false, tostring(msg)
            end
            if ok then
                lastMsg[key] = nil
            elseif msg and msg ~= lastMsg[key] then
                lastMsg[key] = msg
                notify("Backstreet Survival", msg, "warning")
            end
            local iv = tonumber(getInterval()) or 6
            task.wait(iv > 0 and iv or 1)
        end
        print("[BSE] loop stop: " .. key)
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

local function wakeUp()
    local c, h, r = getChar()
    if not c then return end
    local slept = r.Anchored or c:GetAttribute("Sleep") == true
    if not slept then return end
    r.Anchored = false
    pcall(function()
        local animator = h:FindFirstChildOfClass("Animator")
        if not animator then return end
        for _, track in animator:GetPlayingAnimationTracks() do
            if track.Name:find("AFK", 1, true) then
                track:Stop(0.2)
            end
        end
    end)
    pcall(function() AFKEvent:FireServer(false) end)
    pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end)
end

local function walkTo(target, reach, timeout)
    reach = reach or 8
    timeout = timeout or 15
    wakeUp()
    local t0 = os.clock()
    local lastDist = math.huge
    local stall = 0
    while os.clock() - t0 < timeout do
        if isStale() then return false end
        local _, h, r = getChar()
        if not h then return false end
        local d = (r.Position - target).Magnitude
        if d <= reach then
            h:MoveTo(r.Position)
            return true
        end
        if d >= lastDist - 0.2 then
            stall = stall + 0.2
        else
            stall = 0
        end
        lastDist = d
        if stall >= 2.5 then
            stall = 0
            lastDist = math.huge
            pcall(function()
                local path = PathfindingService:CreatePath({
                    AgentRadius = 2,
                    AgentHeight = 5,
                    AgentCanJump = true,
                    AgentCanClimb = false,
                })
                path:ComputeAsync(r.Position, target)
                if path.Status ~= Enum.PathStatus.Success then return end
                local wps = path:GetWaypoints()
                for i = 2, math.min(#wps, 8) do
                    local _, hh, rr = getChar()
                    if not hh or isStale() then return end
                    if wps[i].Action == Enum.PathWaypointAction.Jump then hh.Jump = true end
                    hh:MoveTo(wps[i].Position)
                    task.wait(0.4)
                end
            end)
        else
            h:MoveTo(target)
            task.wait(0.2)
        end
    end
    local _, h, r = getChar()
    if h and r then h:MoveTo(r.Position) end
    return false
end

-- The server rejects Sell/Bank calls made from more than ~10 studs away
-- ("TooFar"), so the call has to happen next to the prompt. Instead of
-- walking there, snap the character over, make the call, snap back.
-- `originCF` is where the caller wants to end up again; pass it in so a
-- second hop closer still restores to the original spot, not the first one.
local function hopNear(target, dist, originCF)
    local _, h, r = getChar()
    if not h or not r then return false end
    wakeUp()
    local origin = originCF or r.CFrame
    local flat = Vector3.new(r.Position.X - target.X, 0, r.Position.Z - target.Z)
    if flat.Magnitude < 0.05 then flat = Vector3.new(1, 0, 0) else flat = flat.Unit end
    r.CFrame = CFrame.new(target + flat * dist + Vector3.new(0, 3, 0))
    task.wait(0.18)
    local _, _, r2 = getChar()
    if not r2 then return false end
    if (r2.Position - target).Magnitude > 12 then
        r2.CFrame = origin
        return false
    end
    return true
end

local function restoreTo(originCF)
    if not originCF then return end
    local _, _, r = getChar()
    if not r then return end
    r.CFrame = originCF
end

local function promptPos(prompt)
    local p = prompt.Parent
    if not p then return nil end
    if p:IsA("BasePart") then return p.Position end
    if p:IsA("Attachment") then return p.WorldPosition end
    if p:IsA("Model") then return p:GetPivot().Position end
    return nil
end

local function nearestPrompt(tag, wantType)
    local _, _, r = getChar()
    if not r then return nil, nil end
    local best, bestPos, bestD = nil, nil, math.huge
    for _, inst in CollectionService:GetTagged(tag) do
        if inst:IsA("ProximityPrompt") and (wantType == nil or inst:GetAttribute("Type") == wantType) then
            local pos = promptPos(inst)
            if pos then
                local d = (pos - r.Position).Magnitude
                if d < bestD then
                    best, bestPos, bestD = inst, pos, d
                end
            end
        end
    end
    return best, bestPos
end

local cfgCache = {}

local function getLootCfg(sellType)
    if cfgCache[sellType] then return cfgCache[sellType] end
    local cfg = {}
    local ok = pcall(function()
        if sellType == "Trash" then
            local t = require(ReplicatedStorage.Config.Trash)
            for k, v in t do cfg[k] = v end
        elseif sellType == "Fish" then
            local f = require(ReplicatedStorage.Config.Fish)
            for k, v in f do cfg[k] = v end
        else
            local g = require(ReplicatedStorage.Config.GardenStore)
            for _, v in g do
                if typeof(v) == "table" and typeof(v.CropTool) == "string" and v.CropTool:sub(1, 5) == "Crop_" then
                    cfg[v.CropTool:sub(6)] = v
                end
            end
        end
    end)
    cfgCache[sellType] = ok and cfg or {}
    return cfgCache[sellType]
end

local function getSavedLoot(sellType)
    local ok, res = pcall(function() return SellFunc:InvokeServer("GetSavedLoot") end)
    if ok and typeof(res) == "table" and typeof(res[sellType]) == "table" then
        return res[sellType]
    end
    return nil
end

local function buildSellPayload(sellType)
    local cfg = getLootCfg(sellType)
    local saved = getSavedLoot(sellType)
    local payload = {Type = sellType}
    local count = 0
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in bp:GetChildren() do
            if tool:IsA("Tool") and tool:GetAttribute("TYPE") == sellType then
                local prefix = sellType .. "_"
                local id = nil
                if tool.Name:sub(1, #prefix) == prefix then
                    local rest = tool.Name:sub(#prefix + 1)
                    if rest ~= "" then id = rest end
                end
                if id and cfg[id] and not (saved and saved[id] == true) then
                    local amt = math.floor(tonumber(tool:GetAttribute("amount")) or 1)
                    if amt > 0 then
                        payload[id] = (payload[id] or 0) + amt
                        count += 1
                    end
                end
            end
        end
    end
    return payload, count
end

local function doSellOnce(sellType)
    local prompt, pos = nearestPrompt("SellProx", sellType)
    if not prompt or not pos then
        return false, "No " .. sellType .. " seller found on this map"
    end
    local payload, count = buildSellPayload(sellType)
    if count == 0 then
        return false, "No " .. sellType .. " to sell"
    end
    local reach = 8
    local originCF = nil
    local hopped = false
    local _, _, r = getChar()
    if r then originCF = r.CFrame end
    if State.instantSell and r and (r.Position - pos).Magnitude > reach then
        hopped = hopNear(pos, 6, originCF)
    end
    if not hopped then
        if not walkTo(pos, reach, 15) then
            return false, "Could not reach the seller"
        end
    end
    local lastErr = nil
    local finalOk, finalMsg = false, nil
    for _ = 1, 3 do
        if isStale() then
            restoreTo(originCF)
            return false, nil
        end
        local ok, a, b = pcall(function()
            return SellFunc:InvokeServer("Sell", payload)
        end)
        if not ok then
            finalMsg = "Sell error: " .. tostring(a)
            break
        end
        if a == true then
            finalOk = true
            break
        end
        lastErr = b
        if b == "TooFar" then
            if hopped then
                hopNear(pos, 4, originCF)
            elseif not walkTo(pos, 5, 15) then
                finalMsg = "Could not reach the seller"
                break
            end
        elseif b == "NothingToSell" then
            finalMsg = "Nothing to sell"
            break
        elseif b == "Busy" then
            task.wait(0.6)
        elseif b == "NoProfile" then
            finalMsg = "Profile data is not ready yet"
            break
        end
        task.wait(0.4)
    end
    if hopped then restoreTo(originCF) end
    if finalOk then return true, nil end
    if finalMsg then return false, finalMsg end
    return false, "Sell failed (" .. tostring(lastErr) .. ")"
end

local function getCash()
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    return tonumber(cash and cash.Value) or 0
end

local function doDepositOnce()
    local prompt, pos = nearestPrompt("BankProx")
    if not prompt or not pos then
        return false, "No ATM or bank found"
    end
    if not walkTo(pos, 8, 15) then
            return false, "Could not reach the ATM"
    end
    local terminal = prompt:GetAttribute("terminal") or false
    local ok, data = pcall(function() return BankFunc:InvokeServer("GetData", 0, false) end)
    if not ok then
        return false, "Bank error: " .. tostring(data)
    end
    if typeof(data) ~= "table" then
            return false, "Bank card required (buy one at the bank first)"
    end
    local amount = math.floor(getCash())
    local serverCash = tonumber(data.Cash)
    if serverCash then
        amount = math.min(amount, math.floor(serverCash))
    end
    if amount <= 0 then
            return false, "No cash on hand"
    end
    local ok2, res = pcall(function()
        return BankFunc:InvokeServer("Deposit", amount, terminal)
    end)
    if not ok2 then
        return false, "Deposit error: " .. tostring(res)
    end
    if typeof(res) == "table" or res == true then
        return true, nil
    end
        return false, "Deposit failed (" .. tostring(res) .. ")"
end

local DIG_SCRIPTS = {
    ShovelScript = 1,
    StickScript = 2,
}

local function findDigTool()
    local c = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    local best, bestRank = nil, 99
    local function scan(container)
        if not container then return end
        for _, t in container:GetChildren() do
            if t:IsA("Tool") then
                local rank = nil
                for childName, r in DIG_SCRIPTS do
                    if t:FindFirstChild(childName) then
                        rank = r
                        break
                    end
                end
                if not rank then
                    local lower = t.Name:lower()
                    if lower:find("shovel", 1, true) then
                        rank = 3
                    elseif lower:find("stick", 1, true) then
                        rank = 4
                    end
                end
                if rank and rank < bestRank then
                    best, bestRank = t, rank
                end
            end
        end
    end
    scan(c)
    scan(bp)
    return best
end

local function doDigOnce()
    local c = getChar()
    if not c then return false, "Character is not ready" end
    wakeUp()
    local tool = findDigTool()
    if not tool then
        return false, "No digging tool available"
    end
    if tool.Parent ~= c then
        tool.Parent = c
        task.wait(0.25)
    end
    if tool.Parent ~= c then
        return false, "Failed to use the digging tool"
    end
    tool:Activate()
    local cd = tonumber(tool:GetAttribute("CD")) or 1
    task.wait(math.max(cd * 0.9, 0.2))
    return true, nil
end

local afkConn = nil

local function setAntiAfk(enabled)
    State.antiAfk = enabled
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
    if enabled then
        afkConn = LP.Idled:Connect(function()
            if not State.antiAfk or isStale() then return end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end
end

local teleportData = nil

local function getTeleportData()
    if teleportData then return teleportData end
    local ok, res = pcall(function() return require(ReplicatedStorage.Config.TeleportData) end)
    teleportData = ok and typeof(res) == "table" and res or {}
    return teleportData
end

local function teleportTo(index)
    local data = getTeleportData()[index]
    if not data or typeof(data.TargetCFrame) ~= "CFrame" then
        return false, "Invalid location"
    end
    local _, h, r = getChar()
    if not h then return false, "Character is not ready" end
    r.CFrame = data.TargetCFrame * CFrame.new(0, 3, 0)
    h:ChangeState(Enum.HumanoidStateType.Landed)
    return true, nil
end

Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Backstreet Survival: Enhanced",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Backstreet Survival: Enhanced",
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
local labelLocation = HomeSub:AddLabel({Text = "Location: --"})

HomeSub:AddSection("Game")
HomeSub:AddLabel({Text = "GameId: " .. tostring(game.GameId)})
HomeSub:AddLabel({Text = "PlaceId: " .. tostring(game.PlaceId)})

HomeSub:AddSection("Server")
HomeSub:AddLabel({Text = "JobId: " .. string.sub(tostring(game.JobId), 1, 20) .. "..."})
HomeSub:AddButton({
    Name = "Copy JobId",
    Callback = function()
        pcall(setclipboard, tostring(game.JobId))
        notify("Copied", "JobId copied!", "success")
    end,
})

local FarmTab = Window:AddTab({Name = "Farm", Icon = "hammer", Subtitle = "Auto"})
local FarmSub = FarmTab:AddSubTab("Features")

FarmSub:AddSection("Auto Dig")
FarmSub:AddToggle({
    Name = "Auto Dig",
    Flag = "bse_autodig",
    Default = false,
    Callback = function(v)
        setLoop("dig", v, doDigOnce, function() return 0.5 end)
    end,
})

FarmSub:AddSection("Auto Sell")
FarmSub:AddToggle({
    Name = "Instant Sell (Teleport)",
    Flag = "bse_instant_sell",
    Default = true,
    Callback = function(v)
        State.instantSell = v
    end,
})
FarmSub:AddToggle({
    Name = "Auto Sell Trash",
    Flag = "bse_sell_trash",
    Default = false,
    Callback = function(v)
        setLoop("sellTrash", v, function() return doSellOnce("Trash") end, function() return State.sellInterval end)
    end,
})
FarmSub:AddToggle({
    Name = "Auto Sell Fish",
    Flag = "bse_sell_fish",
    Default = false,
    Callback = function(v)
        setLoop("sellFish", v, function() return doSellOnce("Fish") end, function() return State.sellInterval end)
    end,
})
FarmSub:AddToggle({
    Name = "Auto Sell Crop",
    Flag = "bse_sell_crop",
    Default = false,
    Callback = function(v)
        setLoop("sellCrop", v, function() return doSellOnce("Crop") end, function() return State.sellInterval end)
    end,
})
FarmSub:AddSlider({
    Name = "Sell Interval",
    Min = 3,
    Max = 60,
    Default = 6,
    Suffix = " sec",
    Flag = "bse_sell_interval",
    Callback = function(v)
        State.sellInterval = v
    end,
})

local BankTab = Window:AddTab({Name = "Bank", Icon = "landmark", Subtitle = "ATM"})
local BankSub = BankTab:AddSubTab("Features")

BankSub:AddSection("Auto Deposit")
BankSub:AddToggle({
    Name = "Auto Deposit Cash",
    Flag = "bse_deposit",
    Default = false,
    Callback = function(v)
        setLoop("deposit", v, doDepositOnce, function() return State.depositInterval end)
    end,
})
BankSub:AddSlider({
    Name = "Deposit Interval",
    Min = 3,
    Max = 60,
    Default = 6,
    Suffix = " sec",
    Flag = "bse_deposit_interval",
    Callback = function(v)
        State.depositInterval = v
    end,
})
BankSub:AddSection("Notes")
BankSub:AddLabel({Text = "Bank card required. Buy one at the bank first."})
BankSub:AddLabel({Text = "Daily deposit limits are enforced by the server."})

local TeleTab = Window:AddTab({Name = "Teleport", Icon = "map", Subtitle = "Places"})
local TeleSub = TeleTab:AddSubTab("Places")

TeleSub:AddSection("Travel")
local teleportNames = {}
for _, v in getTeleportData() do
    table.insert(teleportNames, v.DisplayName)
end
local selectedTeleport = ""
TeleSub:AddDropdown({
    Name = "Location",
    Options = teleportNames,
    Default = "",
    Flag = "bse_teleport_target",
    Callback = function(v) selectedTeleport = v end,
})
TeleSub:AddButton({
    Name = "Teleport",
    Primary = true,
    Callback = function()
        local data = getTeleportData()
        for i, v in data do
            if v.DisplayName == selectedTeleport then
                local ok, err = teleportTo(i)
                if ok then
                    notify("Teleport", "Teleported to " .. v.DisplayName, "success")
                else
                    notify("Teleport", tostring(err), "error")
                end
                return
            end
        end
        notify("Teleport", "Select a location first!", "warning")
    end,
})

local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})
local MiscSub = SettingsTab:AddSubTab("Misc")
local ConfigSub = SettingsTab:AddSubTab("Config")
local HopSub = SettingsTab:AddSubTab("Server Hop")

MiscSub:AddSection("Player")
MiscSub:AddToggle({
    Name = "Anti AFK",
    Flag = "bse_antiafk",
    Default = false,
    Callback = function(v)
        setAntiAfk(v)
    end,
})
MiscSub:AddLabel({Text = "Toggle Menu: RightControl"})

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "bse_config_selected",
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
    Flag = "bse_config_name",
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
    Primary = false,
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
    Primary = false,
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
ConfigSub:AddLabel({Text = "by Exlumiaa Hub"})
ConfigSub:AddLabel({Text = "Toggle Menu: RightControl"})

HopSub:AddSection("Server")
HopSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        notify("Server Hop", "Finding a new server...", "info")
        local ok, err = pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
        if not ok then
            notify("Server Hop", "Failed: " .. tostring(err), "error")
        end
    end,
})
HopSub:AddButton({
    Name = "Rejoin Server",
    Primary = false,
    Callback = function()
        notify("Rejoin", "Rejoining...", "info")
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(game.JobId), LP)
        end)
        if not ok then
            notify("Rejoin", "Failed: " .. tostring(err), "error")
        end
    end,
})

task.spawn(function()
    while not isStale() do
        task.wait(1)
        pcall(function()
            labelPlayers:Set("Players: " .. #Players:GetPlayers())
            labelCash:Set("Cash: $" .. string.format("%.2f", tonumber(getCash()) or 0))
            labelLocation:Set("Location: " .. tostring(LP:GetAttribute("Location") or "-"))
        end)
    end
end)

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

getgenv()._bse = {
    sellTrash = function() return doSellOnce("Trash") end,
    sellFish = function() return doSellOnce("Fish") end,
    sellCrop = function() return doSellOnce("Crop") end,
    deposit = doDepositOnce,
    dig = doDigOnce,
    teleport = teleportTo,
    walkTo = walkTo,
    wakeUp = wakeUp,
    nearestPrompt = nearestPrompt,
    buildSellPayload = buildSellPayload,
    state = State,
    ticks = ticks,
}

print("[ExlumiaaHub] Backstreet Survival Hub loaded!")
