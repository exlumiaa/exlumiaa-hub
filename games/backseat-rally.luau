-- Exlumiaa Hub - Backseat Rally
-- Two client-side helpers:
--   Autopilot     - feeds the game's own AutoDrive into CarInput.Read (driver only)
--   Driver Map    - full-route minimap drawn on the right, since the driver's
--                   cockpit has no map screen (MapScreenController is co-driver only)
--
-- Race state (StageId, Progress, checkpoint) is server-set, so this only steers
-- and draws; it never grants progress.
--
-- CarController.LocalCar / LocalRole / GetChassis() / Recover() are the game's
-- own handles (PlayerScripts.Client.Init.Car).

-- Keyed on game.GameId, which for this experience is the universe id and covers
-- every place in it.
if tostring(game.GameId) ~= "10769543742" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local STATE = rawget(_G, "STATE") or (type(getgenv) == "function" and rawget(getgenv(), "STATE") or nil)

local _G_TOMB = "_ _brTomb"
local _G_ALIVE = "_ _brAlive"
local _G_GEN = "_ _brGen"
local _G_GUI = "_ _brGui"

pcall(cleardrawcache)

do
    local oldGui = rawget(_G, _G_GUI)
    if oldGui and oldGui.Parent then
        pcall(function() oldGui:Destroy() end)
    end
end
pcall(function()
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "Oxidelib") then gui:Destroy() end
        end
    end
end)

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
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumiaa Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_backseatrally.txt"
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

    local KEY_PAGE_URL = "https://pandauth.com/getkey/" .. PUSL_SERVICE_ID

    local function ksGetKeyLink()
        if pxLoad() then
            local ok, link = pcall(function() return PUSL.getKeyUrl() end)
            if ok and type(link) == "string" and #link > 0 then
                -- the library hands back a site-relative path, prefix it before it goes out
                if link:sub(1, 1) == "/" then return "https://pandauth.com" .. link end
                return link
            end
        end
        return KEY_PAGE_URL
    end

    local function ksShowGate(onSuccess)
        -- >>> EXLUMIAA KEY GATE (generated from keygate/keygate.luau, do not hand-edit) >>>
        local Gate = (function()
        --!nocheck
        -- ============================================================
        --  Exlumiaa Hub -- Key Gate UI v3
        -- ============================================================
        --  Direction (anti-slop gate):
        --    Product   : access gate for hub users, in-game, often on weak hardware
        --    Character : exact, mechanical, quietly warm
        --    World     : night terminal -- ink panels, one cerise signal,
        --                restrained sizing
        --    Moments   : the identity row tucked under the headline; the one accented action key
        --    Texture   : flat ink panel, hairline borders, one coloured action button
        --    Signature : a progress hairline that only exists while a key is being checked
        --  No violet gradient, no gradient text, no hover fades, no eyebrow chip,
        --  no perpetual decoration loops. One bright element: the Apply key button.
        --
        --  Usage from a game script:
        --
        --    local Gate = <this module>
        --    Gate.open({
        --        title     = "Exlumiaa Hub",
        --        brand     = "VOXEL WARS",                     -- small overline
        --        accent    = Color3.fromRGB(232, 163, 61),
        --        guiName   = "VoxelWarsKeyGate",
        --        savedKey  = saved,                          -- string | nil
        --        validate  = function(key) return ok, msg end,
        --        getKeyUrl = function() return url end,      -- optional
        --        storeKey  = function(key) end,              -- optional
        --        onSuccess = function() end,                 -- required
        --    })
        -- ============================================================
        
        local TweenService = game:GetService("TweenService")
        local Players = game:GetService("Players")
        local LP = Players.LocalPlayer
        
        local KeyGate = {}
        
        -- Arimo: bold for signage and the one bright button, regular for everything else.
        local FONT_DISPLAY = Enum.Font.ArimoBold
        local FONT_DATA = Enum.Font.Arimo
        
        -- Palette "ink / cerise": one accent, used on under 5% of the surface.
        local C = {
            panel = Color3.fromRGB(18, 14, 16),
            input = Color3.fromRGB(12, 9, 11),
            hairline = Color3.fromRGB(48, 36, 41),
            edge = Color3.fromRGB(70, 52, 58),
            ink = Color3.fromRGB(240, 230, 233),
            dim = Color3.fromRGB(160, 142, 150),
            accent = Color3.fromRGB(196, 57, 107),
            accentHot = Color3.fromRGB(217, 74, 124),
            reject = Color3.fromRGB(236, 128, 120),
            accept = Color3.fromRGB(126, 208, 150),
            onAccent = Color3.fromRGB(255, 240, 246),
        }
        
        local DEFAULTS = {
            title = "Exlumiaa Hub",
            subtitle = "Enter your access key",
            brand = "",
            accent = C.accent,
            guiName = "ExlumiaKeyGate",
            footer = "One key per device",
            discord = "https://discord.gg/aKxnSwhRxx",
            premium = "https://discord.gg/aKxnSwhRxx",
            showInfo = true,
            host = "auto",
            savedKey = nil,
            validate = nil,
            getKeyUrl = nil,
            storeKey = nil,
            onSuccess = nil,
        }
        
        -- ---------------------------------------------------------------- helpers
        local function make(class, props, parent)
            local o = Instance.new(class)
            if props then
                for k, v in pairs(props) do
                    o[k] = v
                end
            end
            if parent then
                o.Parent = parent
            end
            return o
        end
        
        local function tween(o, dur, props, style)
            local t = TweenService:Create(o, TweenInfo.new(dur, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
            t:Play()
            return t
        end
        
        local function corner(o, r)
            return make("UICorner", { CornerRadius = UDim.new(0, r) }, o)
        end
        
        local function border(o, color, thickness, transparency)
            return make("UIStroke", {
                Color = color or C.hairline,
                Thickness = thickness or 1,
                Transparency = transparency or 0,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            }, o)
        end
        
        local function text(parent, size, pos, value, font, textSize, color, align)
            return make("TextLabel", {
                Size = size,
                Position = pos,
                BackgroundTransparency = 1,
                Text = value or "",
                Font = font or FONT_DATA,
                TextSize = textSize or 11,
                TextColor3 = color or C.dim,
                TextXAlignment = align or Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
            }, parent)
        end
        
        local function esc(s)
            s = tostring(s or "")
            s = string.gsub(s, "&", "&amp;")
            s = string.gsub(s, "<", "&lt;")
            s = string.gsub(s, ">", "&gt;")
            return s
        end
        
        -- ---------------------------------------------------------------- the gate
        function KeyGate.open(opts)
            opts = opts or {}
            local cfg = {}
            for k, v in pairs(DEFAULTS) do
                cfg[k] = v
            end
            for k, v in pairs(opts) do
                cfg[k] = v
            end
        
            local accent = cfg.accent
        
            local pg = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 10)
            if not pg then
                return nil
            end
            local host = pg
            if cfg.host ~= "playergui" then
                pcall(function()
                    local cg = game:GetService("CoreGui")
                    if cg then
                        host = cg
                    end
                end)
            end
        
            for _, container in ipairs({ host, pg }) do
                local stale = container and container:FindFirstChild(cfg.guiName)
                if stale then
                    pcall(function()
                        stale:Destroy()
                    end)
                end
            end
        
            local sc = make("ScreenGui", {
                Name = cfg.guiName,
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                DisplayOrder = 999,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            }, nil)
            local okParent = pcall(function()
                sc.Parent = host
            end)
            if not okParent or not sc.Parent then
                sc.Parent = pg
            end
        
            local dead = false
            local conns = {}
            local function hook(signal, fn)
                local c = signal:Connect(fn)
                conns[#conns + 1] = c
                return c
            end
            local function destroy()
                if dead then
                    return
                end
                dead = true
                for _, c in ipairs(conns) do
                    pcall(function()
                        c:Disconnect()
                    end)
                end
                pcall(function()
                    sc:Destroy()
                end)
            end
            KeyGate._destroy = destroy
        
            -- ---- backdrop: dim only, no blur, no glow
            local overlay = make("Frame", {
                Name = "Scrim",
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.fromRGB(4, 5, 7),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, sc)
        
            -- ============================================== panel
            local W, H = 720, 272
            local card = make("Frame", {
                Name = "Panel",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(W, H),
                BackgroundColor3 = C.panel,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 2,
            }, sc)
            corner(card, 10)
            local cardBorder = border(card, C.hairline, 1, 1)
        
            local scale = make("UIScale", { Scale = 1 }, card)
        
            -- ============================================== left: identity manifest
            local brand = text(card, UDim2.fromOffset(264, 12), UDim2.fromOffset(24, 24),
                string.upper(tostring(cfg.brand)), FONT_DATA, 10, C.dim)
            brand.TextTransparency = 1
            brand.Visible = (#tostring(cfg.brand) > 0)
        
            local title = text(card, UDim2.fromOffset(264, 34), UDim2.fromOffset(24, 38),
                cfg.title, FONT_DISPLAY, 26, C.ink)
            title.TextTransparency = 1
        
            local subtitle = text(card, UDim2.fromOffset(264, 16), UDim2.fromOffset(24, 76),
                cfg.subtitle, FONT_DATA, 11, C.dim)
            subtitle.TextTransparency = 1
        
            local hairTop = make("Frame", {
                Size = UDim2.fromOffset(264, 1),
                Position = UDim2.fromOffset(24, 104),
                BackgroundColor3 = C.hairline,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 3,
            }, card)
        
            local executorName = "unknown"
            if type(identifyexecutor) == "function" then
                local okExec, en = pcall(identifyexecutor)
                if okExec and type(en) == "string" and #en > 0 then
                    executorName = string.lower(en)
                end
            end
        
            local gameName = ""
            pcall(function()
                gameName = tostring(game.Name or "")
            end)
            if gameName == "" then
                gameName = "place " .. tostring(game.PlaceId)
            end
        
            local avatar = make("ImageLabel", {
                Name = "Avatar",
                Size = UDim2.fromOffset(48, 48),
                Position = UDim2.fromOffset(24, 120),
                BackgroundColor3 = C.input,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LP.UserId) .. "&w=150&h=150",
                ImageTransparency = 1,
                ZIndex = 4,
            }, card)
            corner(avatar, 4)
            local avatarRing = border(avatar, accent, 1, 1)
        
            local who = text(card, UDim2.fromOffset(186, 18), UDim2.fromOffset(84, 118),
                LP.DisplayName .. "  @" .. LP.Name, FONT_DATA, 13, C.ink)
            who.TextTruncate = Enum.TextTruncate.AtEnd
            who.TextTransparency = 1
        
            local execLine = make("TextLabel", {
                Size = UDim2.fromOffset(186, 14),
                Position = UDim2.fromOffset(84, 136),
                BackgroundTransparency = 1,
                RichText = true,
                Text = "exec " .. esc(executorName),
                Font = FONT_DATA,
                TextSize = 10,
                TextColor3 = C.dim,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextTransparency = 1,
                ZIndex = 4,
            }, card)
        
            local gameLine = make("TextLabel", {
                Size = UDim2.fromOffset(186, 14),
                Position = UDim2.fromOffset(84, 152),
                BackgroundTransparency = 1,
                RichText = true,
                Text = "game " .. esc(gameName),
                Font = FONT_DATA,
                TextSize = 10,
                TextColor3 = C.dim,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextTransparency = 1,
                ZIndex = 4,
            }, card)
        
            -- links: quiet outline buttons, no fill on hover, border colour shift only
            local function linkButton(pos, size, labelText, name)
                local b = make("TextButton", {
                    Name = name,
                    Size = size,
                    Position = pos,
                    BackgroundColor3 = C.input,
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 4,
                }, card)
                corner(b, 4)
                local s = border(b, C.edge, 1, 1)
                local l = text(b, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), labelText, FONT_DATA, 10.5, C.dim)
                l.TextXAlignment = Enum.TextXAlignment.Center
                l.TextTransparency = 1
                l.ZIndex = 5
                return b, s, l
            end
        
            local discordBtn, discordBorder, discordLabel =
                linkButton(UDim2.fromOffset(24, 186), UDim2.fromOffset(126, 28), "discord", "Discord")
            local premiumBtn, premiumBorder, premiumLabel =
                linkButton(UDim2.fromOffset(162, 186), UDim2.fromOffset(126, 28), "premium key", "Premium")
        
            local footer = text(card, UDim2.fromOffset(264, 12), UDim2.fromOffset(24, 238),
                cfg.footer, FONT_DATA, 9.5, C.dim)
            footer.TextTransparency = 1
        
            -- ============================================== right: key entry
            local vline = make("Frame", {
                Size = UDim2.fromOffset(1, 224),
                Position = UDim2.fromOffset(304, 24),
                BackgroundColor3 = C.hairline,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 3,
            }, card)
        
            local inputBox = make("Frame", {
                Name = "Slot",
                Size = UDim2.fromOffset(368, 46),
                Position = UDim2.fromOffset(328, 40),
                BackgroundColor3 = C.input,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 3,
            }, card)
            corner(inputBox, 3)
            local slotBorder = border(inputBox, C.hairline, 1, 1)
        
            local input = make("TextBox", {
                Name = "Key",
                Size = UDim2.new(1, -28, 1, 0),
                Position = UDim2.fromOffset(14, 0),
                BackgroundTransparency = 1,
                Text = cfg.savedKey or "",
                PlaceholderText = "paste the key",
                PlaceholderColor3 = Color3.fromRGB(104, 110, 122),
                ClearTextOnFocus = false,
                Font = FONT_DATA,
                TextSize = 14,
                TextColor3 = C.ink,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 4,
            }, inputBox)
        
            -- progress hairline under the slot, 0-wide until a check runs
            local progress = make("Frame", {
                Name = "Progress",
                Size = UDim2.new(0, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = accent,
                BorderSizePixel = 0,
                ZIndex = 5,
            }, inputBox)
        
            hook(input.Focused, function()
                tween(slotBorder, 0.1, { Color = accent, Transparency = 0.15 })
            end)
            hook(input.FocusLost, function()
                tween(slotBorder, 0.12, { Color = C.hairline, Transparency = 0 })
            end)
        
            -- ---- buttons: hover is a colour change, never a fade
            local getBtn = make("TextButton", {
                Name = "GetKey",
                Size = UDim2.fromOffset(132, 40),
                Position = UDim2.fromOffset(328, 100),
                BackgroundColor3 = C.input,
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                ZIndex = 4,
            }, card)
            corner(getBtn, 4)
            local getBorder = border(getBtn, C.edge, 1, 1)
            local getLabel = text(getBtn, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), "get key", FONT_DATA, 11.5, C.ink)
            getLabel.TextXAlignment = Enum.TextXAlignment.Center
            getLabel.TextTransparency = 1
            getLabel.ZIndex = 5
        
            -- the one bright element on the screen
            local applyBtn = make("TextButton", {
                Name = "Apply",
                Size = UDim2.fromOffset(224, 40),
                Position = UDim2.fromOffset(472, 100),
                BackgroundColor3 = accent,
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                ZIndex = 4,
            }, card)
            corner(applyBtn, 4)
            local applyLabel = text(applyBtn, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), "Apply key", FONT_DISPLAY, 15, C.onAccent)
            applyLabel.TextXAlignment = Enum.TextXAlignment.Center
            applyLabel.TextTransparency = 1
            applyLabel.ZIndex = 5
        
            local status = text(card, UDim2.fromOffset(368, 14), UDim2.fromOffset(328, 150), "", FONT_DATA, 10.5, C.dim)
            status.TextTransparency = 1
        
            -- steps: plain instructions, no "unlock" wording
            local stepLines = {
                "1  get key, finish the ad",
                "2  copy the key it shows",
                "3  paste it above, press apply key",
            }
            local steps = {}
            for i = 1, 3 do
                steps[i] = text(card, UDim2.fromOffset(368, 14), UDim2.fromOffset(328, 182 + (i - 1) * 18),
                    stepLines[i], FONT_DATA, 10, Color3.fromRGB(130, 136, 148))
                steps[i].TextTransparency = 1
            end
        
            local function setStatus(value, color)
                status.Text = value or ""
                status.TextColor3 = color or C.dim
                tween(status, 0.15, { TextTransparency = 0 })
            end
        
            -- ---- validation flow
            local busy = false
            local sweepTween = nil
            local function killSweep()
                if sweepTween then
                    pcall(function()
                        sweepTween:Cancel()
                    end)
                    sweepTween = nil
                end
            end
            local function beginProgress()
                killSweep()
                progress.BackgroundColor3 = accent
                progress.Size = UDim2.new(0, 0, 0, 1)
                sweepTween = tween(progress, 0.8, { Size = UDim2.new(1, 0, 0, 1) }, Enum.EasingStyle.Linear)
            end
            local function completeProgress(color)
                killSweep()
                progress.BackgroundColor3 = color or C.accept
                tween(progress, 0.1, { Size = UDim2.new(1, 0, 0, 1) })
            end
            local function clearProgress(color)
                killSweep()
                progress.BackgroundColor3 = color or accent
                tween(progress, 0.14, { Size = UDim2.new(0, 0, 0, 1) })
            end
        
            local function reject(msg)
                clearProgress(C.reject)
                setStatus("rejected: " .. tostring(msg or "key not accepted"), C.reject)
                tween(slotBorder, 0.1, { Color = C.reject })
                task.spawn(function()
                    for _, dx in ipairs({ -3, 3, -2, 2, 0 }) do
                        if dead then
                            return
                        end
                        tween(card, 0.04, { Position = UDim2.new(0.5, dx, 0.5, 0) }, Enum.EasingStyle.Linear)
                        task.wait(0.04)
                    end
                end)
                task.delay(1.2, function()
                    if not dead then
                        tween(slotBorder, 0.2, { Color = C.hairline })
                    end
                end)
            end
        
            local function accept()
                completeProgress(C.accept)
                setStatus("key accepted", C.accept)
                applyLabel.Text = "ACCEPTED"
                tween(applyBtn, 0.15, { BackgroundColor3 = C.accept })
                tween(applyLabel, 0.15, { TextColor3 = Color3.fromRGB(12, 24, 16) })
                task.delay(0.35, function()
                    if dead then
                        return
                    end
                    tween(overlay, 0.15, { BackgroundTransparency = 1 })
                    tween(card, 0.15, { BackgroundTransparency = 1 })
                    task.wait(0.16)
                    destroy()
                    if cfg.onSuccess then
                        task.spawn(cfg.onSuccess)
                    end
                end)
            end
        
            local function attempt(key, quiet)
                if dead or busy then
                    return
                end
                key = string.gsub(tostring(key or ""), "%s+", "")
                if #key == 0 then
                    setStatus("paste a key first", C.reject)
                    return
                end
                busy = true
                setStatus("checking", C.dim)
                beginProgress()
                tween(applyBtn, 0.1, { BackgroundTransparency = 0.25 })
                local okCall, ok, msg = pcall(function()
                    return cfg.validate(key)
                end)
                busy = false
                if dead then
                    return
                end
                tween(applyBtn, 0.12, { BackgroundTransparency = 0 })
                if not okCall then
                    reject("validation error")
                    return
                end
                if ok then
                    if cfg.storeKey then
                        pcall(cfg.storeKey, key)
                    end
                    accept()
                else
                    if quiet then
                        clearProgress(C.dim)
                        if msg and #msg > 0 then
                            setStatus(msg, C.dim)
                        end
                    else
                        reject(msg)
                    end
                end
            end
        
            -- ---- interactions
            local function copyLink(url, what)
                if type(url) ~= "string" or #url == 0 then
                    setStatus("no link set", C.reject)
                    return
                end
                if type(setclipboard) == "function" then
                    pcall(setclipboard, url)
                    setStatus(what .. " link copied", accent)
                else
                    setStatus(url, C.dim)
                end
            end
        
            local function linkHover(btn, st, on)
                tween(st, 0.08, { Color = on and accent or C.edge }, Enum.EasingStyle.Linear)
                tween(btn, 0.08, { BackgroundTransparency = on and 0.82 or 1 }, Enum.EasingStyle.Linear)
            end
        
            -- press feedback: the button drops 1px under the cursor and comes back
            local function pressFx(btn)
                local bx, by = btn.Position.X, btn.Position.Y
                local function up()
                    btn.Position = UDim2.new(bx.Scale, bx.Offset, by.Scale, by.Offset)
                end
                hook(btn.MouseButton1Down, function()
                    btn.Position = UDim2.new(bx.Scale, bx.Offset, by.Scale, by.Offset + 1)
                end)
                hook(btn.MouseButton1Up, up)
                hook(btn.MouseLeave, up)
            end
        
            pressFx(discordBtn)
            pressFx(premiumBtn)
            pressFx(getBtn)
            pressFx(applyBtn)
        
            hook(discordBtn.MouseEnter, function()
                linkHover(discordBtn, discordBorder, true)
            end)
            hook(discordBtn.MouseLeave, function()
                linkHover(discordBtn, discordBorder, false)
            end)
            hook(discordBtn.MouseButton1Click, function()
                copyLink(cfg.discord, "discord")
            end)
        
            hook(premiumBtn.MouseEnter, function()
                linkHover(premiumBtn, premiumBorder, true)
            end)
            hook(premiumBtn.MouseLeave, function()
                linkHover(premiumBtn, premiumBorder, false)
            end)
            hook(premiumBtn.MouseButton1Click, function()
                copyLink(cfg.premium, "premium key")
            end)
        
            hook(getBtn.MouseEnter, function()
                tween(getBorder, 0.08, { Color = accent }, Enum.EasingStyle.Linear)
                tween(getBtn, 0.08, { BackgroundTransparency = 0.82 }, Enum.EasingStyle.Linear)
            end)
            hook(getBtn.MouseLeave, function()
                tween(getBorder, 0.08, { Color = C.edge }, Enum.EasingStyle.Linear)
                tween(getBtn, 0.08, { BackgroundTransparency = 1 }, Enum.EasingStyle.Linear)
            end)
            hook(getBtn.MouseButton1Click, function()
                local url = nil
                if cfg.getKeyUrl then
                    local ok, v = pcall(cfg.getKeyUrl)
                    if ok and type(v) == "string" and #v > 0 then
                        url = v
                    end
                end
                if url then
                    copyLink(url, "key")
                else
                    setStatus("no key link yet, try again", C.reject)
                end
            end)
        
            hook(applyBtn.MouseEnter, function()
                tween(applyBtn, 0.08, { BackgroundColor3 = C.accentHot }, Enum.EasingStyle.Linear)
            end)
            hook(applyBtn.MouseLeave, function()
                tween(applyBtn, 0.08, { BackgroundColor3 = accent }, Enum.EasingStyle.Linear)
            end)
            hook(applyBtn.MouseButton1Click, function()
                attempt(input.Text, false)
            end)
            hook(input.FocusLost, function(enterPressed)
                if enterPressed then
                    attempt(input.Text, false)
                end
            end)
        
            -- ---- entrance: the panel rises 14px, then the content assembles in
            --      reading order. Staggered so the gate reads as "built", not "pasted".
            card.Position = UDim2.new(0.5, 0, 0.5, 14)
            tween(overlay, 0.2, { BackgroundTransparency = 0.32 })
            tween(card, 0.26, { BackgroundTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) })
            tween(cardBorder, 0.28, { Transparency = 0 })
        
            local stages = {
                { 0.05, brand, { TextTransparency = 0 } },
                { 0.08, title, { TextTransparency = 0 } },
                { 0.12, subtitle, { TextTransparency = 0 } },
                { 0.16, hairTop, { BackgroundTransparency = 0 } },
                { 0.18, avatar, { ImageTransparency = 0, BackgroundTransparency = 0 } },
                { 0.20, avatarRing, { Transparency = 0.55 } },
                { 0.21, who, { TextTransparency = 0 } },
                { 0.24, execLine, { TextTransparency = 0 } },
                { 0.26, gameLine, { TextTransparency = 0 } },
                { 0.30, discordBorder, { Transparency = 0.4 } },
                { 0.31, discordLabel, { TextTransparency = 0 } },
                { 0.34, premiumBorder, { Transparency = 0.4 } },
                { 0.35, premiumLabel, { TextTransparency = 0 } },
                { 0.38, footer, { TextTransparency = 0 } },
                { 0.10, vline, { BackgroundTransparency = 0 } },
                { 0.12, inputBox, { BackgroundTransparency = 0 } },
                { 0.15, slotBorder, { Transparency = 0 } },
                { 0.19, getBorder, { Transparency = 0 } },
                { 0.20, getLabel, { TextTransparency = 0 } },
                { 0.24, applyBtn, { BackgroundTransparency = 0 } },
                { 0.25, applyLabel, { TextTransparency = 0 } },
                { 0.44, steps[1], { TextTransparency = 0 } },
                { 0.48, steps[2], { TextTransparency = 0 } },
                { 0.52, steps[3], { TextTransparency = 0 } },
            }
            for _, s in ipairs(stages) do
                local delay, obj, props = s[1], s[2], s[3]
                task.delay(delay, function()
                    if not dead and obj and obj.Parent then
                        tween(obj, 0.22, props)
                    end
                end)
            end
        
            -- ---- fit to small viewports
            local function fit()
                if dead then
                    return
                end
                local cam = workspace.CurrentCamera
                local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
                local s = math.min(vp.X / (W + 80), vp.Y / (H + 70))
                scale.Scale = math.clamp(s, 0.55, 1)
            end
            fit()
            local cam = workspace.CurrentCamera
            if cam then
                hook(cam:GetPropertyChangedSignal("ViewportSize"), fit)
            end
        
            if cfg.savedKey and #cfg.savedKey > 0 then
                task.delay(0.4, function()
                    if not dead then
                        attempt(cfg.savedKey, true)
                    end
                end)
            end
        
            return {
                instance = sc,
                destroy = destroy,
                submit = function()
                    attempt(input.Text, false)
                end,
            }
        end
        
        return KeyGate
        end)()
        -- <<< EXLUMIAA KEY GATE <<<
        local handle = Gate.open({
            title = "Exlumiaa Hub",
            brand = "Backseat Rally",
            guiName = "BackseatRallyKeyGate",
            validate = ksValidate,
            getKeyUrl = ksGetKeyLink,
            storeKey = ksWriteStore,
            onSuccess = onSuccess,
        })
        if not handle then
            return nil
        end
        return {
            Parent = handle.instance and handle.instance.Parent,
            Destroy = function()
                handle.destroy()
            end,
        }
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

local function onSignal(signal, fn)
    if STATE and type(STATE.connect) == "function" then
        STATE.connect(signal, fn)
    else
        signal:Connect(fn)
    end
end

-- ================================================================
-- UI LIBRARY
-- ================================================================
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

Library.ConfigFolder = "exlumiaa/backseatrally"

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

-- ================================================================
-- GAME MODULES
-- ================================================================
local function waitFor(parent, name, timeout)
    return parent and parent:WaitForChild(name, timeout or 20) or nil
end

local playerScripts = waitFor(LP, "PlayerScripts", 30)
local client = playerScripts and waitFor(playerScripts, "Client", 30)
local init = client and waitFor(client, "Init", 30)
if not init then return end

local function requireChild(parent, name)
    local child = waitFor(parent, name, 20)
    if not child then return nil end
    local ok, mod = pcall(require, child)
    return ok and mod or nil
end

local carFolder = waitFor(init, "Car", 20)
local shared = waitFor(ReplicatedStorage, "Shared", 30)
local core = shared and waitFor(shared, "Core", 30)

local CarController = requireChild(carFolder, "CarController")
local CarInput = requireChild(carFolder, "CarInput")
local AutoDrive = requireChild(carFolder, "AutoDrive")
local Route = requireChild(core, "Route")

if not (CarController and CarInput and AutoDrive and Route) then
    return
end

-- ================================================================
-- STAGES
-- ================================================================
local stageOptions = {}
local stageIdByName = {}
local stageNameById = {}

do
    local stageModule = shared and shared:FindFirstChild("Stages")
    local okStages, stages = pcall(function()
        return stageModule and require(stageModule) or nil
    end)
    local list = {}
    if okStages and type(stages) == "table" then
        for key, cfg in pairs(stages) do
            if type(cfg) == "table" then
                list[#list + 1] = {
                    id = tostring(cfg.Id or key),
                    name = tostring(cfg.Name or cfg.Id or key),
                    order = tonumber(cfg.Order) or 999,
                }
            end
        end
    elseif stageModule then
        for _, child in ipairs(stageModule:GetChildren()) do
            list[#list + 1] = { id = child.Name, name = child.Name, order = 999 }
        end
    end
    table.sort(list, function(a, b)
        if a.order ~= b.order then return a.order < b.order end
        return a.name < b.name
    end)
    for _, entry in ipairs(list) do
        stageOptions[#stageOptions + 1] = entry.name
        stageIdByName[entry.name] = entry.id
        stageNameById[entry.id] = entry.name
    end
end

local stageTravelRemote = nil
do
    local netFolder = shared and shared:FindFirstChild("RBXUtil")
    netFolder = netFolder and netFolder:FindFirstChild("Net")
    stageTravelRemote = netFolder and netFolder:FindFirstChild("RE/StageTravel")
end

-- ================================================================
-- AUTOPILOT
-- ================================================================
local Config = {
    autopilot = false,
    showMap = false,
    mapZoom = 1,
}

-- CarController calls CarInput.Read() once per physics step, so wrapping that
-- shared table is enough to steer without touching the chassis directly.
local originalRead = CarInput.Read
CarInput.Read = function(...)
    local state = originalRead(...)
    if not Config.autopilot or type(state) ~= "table" then
        return state
    end
    if LP:GetAttribute("KnockedOut") == true then
        return state
    end
    local car = CarController.LocalCar
    local chassis = CarController.GetChassis()
    if not car or CarController.LocalRole ~= "Driver" or not chassis then
        return state
    end
    local ok, drive = pcall(AutoDrive.Read, car, chassis)
    if not ok or type(drive) ~= "table" then
        return state
    end
    state.Throttle = math.clamp(drive.Throttle or 0, 0, 1)
    state.Brake = math.clamp(drive.Brake or 0, 0, 1)
    state.Steer = math.clamp(drive.Steer or 0, -1, 1)
    state.Handbrake = drive.Handbrake == true
    state.Analog = false
    if AutoDrive.Stuck then
        AutoDrive.Stuck = false
        pcall(CarController.Recover)
    end
    return state
end

-- ================================================================
-- DRIVER MAP (Drawing)
-- ================================================================
local DRAW_OBJECTS = {}
local mapCache = {
    stage = nil,
    route = nil,
    lines = {},
    corners = {},
    startDot = nil,
    finishDot = nil,
    panel = nil,
    panelStroke = nil,
    title = nil,
    viewportX = 0,
    viewportY = 0,
    lastIndex = nil,
    zoomed = false,
}
local mapElapsed = 0

local function addDrawing(className)
    local obj = Drawing.new(className)
    DRAW_OBJECTS[#DRAW_OBJECTS + 1] = obj
    return obj
end

local function clearDrawings()
    for _, obj in ipairs(DRAW_OBJECTS) do
        pcall(function()
            obj.Visible = false
            obj:Remove()
        end)
    end
    table.clear(DRAW_OBJECTS)
    mapCache.stage = nil
    mapCache.route = nil
    table.clear(mapCache.lines)
    table.clear(mapCache.corners)
    mapCache.startDot = nil
    mapCache.finishDot = nil
    mapCache.panel = nil
    mapCache.panelStroke = nil
    mapCache.title = nil
    mapCache.lastIndex = nil
    mapCache.zoomed = false
end

local function hideDrawings()
    for _, obj in ipairs(DRAW_OBJECTS) do
        obj.Visible = false
    end
end

-- Liang-Barsky: trims a screen-space segment to the map panel so a zoomed map
-- never draws over the game. Returns nil when the segment misses the box.
local function clipSegment(x1, y1, x2, y2, left, top, right, bottom)
    local dx, dy = x2 - x1, y2 - y1
    local t0, t1 = 0, 1
    if dx == 0 then
        if x1 < left or x1 > right then return nil end
    else
        local ra, rb = (left - x1) / dx, (right - x1) / dx
        if ra > rb then ra, rb = rb, ra end
        if ra > t0 then t0 = ra end
        if rb < t1 then t1 = rb end
        if t0 > t1 then return nil end
    end
    if dy == 0 then
        if y1 < top or y1 > bottom then return nil end
    else
        local ra, rb = (top - y1) / dy, (bottom - y1) / dy
        if ra > rb then ra, rb = rb, ra end
        if ra > t0 then t0 = ra end
        if rb < t1 then t1 = rb end
        if t0 > t1 then return nil end
    end
    return x1 + t0 * dx, y1 + t0 * dy, x1 + t1 * dx, y1 + t1 * dy
end

local MAP_MAX_SIZE = 280
local MAP_MIN_SIZE = 150
local MAP_PAD = 14

local function buildMap(stageId)
    clearDrawings()
    local ok, route = pcall(Route.Get, stageId)
    local camera = workspace.CurrentCamera
    if not ok or not route or not camera then return false end
    local viewport = camera.ViewportSize
    if viewport.X < 200 or viewport.Y < 200 then return false end

    mapCache.stage = stageId
    mapCache.route = route
    mapCache.viewportX = viewport.X
    mapCache.viewportY = viewport.Y

    local size = math.clamp(math.min(MAP_MAX_SIZE, viewport.X * 0.3, viewport.Y * 0.55), MAP_MIN_SIZE, MAP_MAX_SIZE)
    local boxX = viewport.X - size - 20
    local boxY = math.max(10, (viewport.Y - size) * 0.5)
    local inner = size - MAP_PAD * 2
    local spanX = math.max(route.Max.X - route.Min.X, 1)
    local spanZ = math.max(route.Max.Z - route.Min.Z, 1)
    local scale = math.min(inner / spanX, inner / spanZ)
    local originX = boxX + MAP_PAD + (inner - spanX * scale) * 0.5
    local originY = boxY + MAP_PAD + (inner - spanZ * scale) * 0.5

    local function toMap(x, z)
        return originX + (x - route.Min.X) * scale, originY + (z - route.Min.Z) * scale
    end
    mapCache.size = size
    mapCache.boxX = boxX
    mapCache.boxY = boxY
    mapCache.scale = scale
    mapCache.originX = originX
    mapCache.originY = originY

    local panel = addDrawing("Square")
    panel.Filled = true
    panel.Color = Color3.fromRGB(10, 12, 16)
    panel.Transparency = 0.35
    panel.Size = Vector2.new(size, size)
    panel.Position = Vector2.new(boxX, boxY)

    local panelStroke = addDrawing("Square")
    panelStroke.Filled = false
    panelStroke.Color = Color3.fromRGB(120, 200, 255)
    panelStroke.Transparency = 0.55
    panelStroke.Thickness = 1
    panelStroke.Size = Vector2.new(size, size)
    panelStroke.Position = Vector2.new(boxX, boxY)

    local title = addDrawing("Text")
    title.Text = stageNameById[stageId] or stageId
    title.Size = 14
    title.Color = Color3.fromRGB(230, 235, 245)
    title.Outline = true
    title.Position = Vector2.new(boxX, boxY - 18)

    mapCache.panel = panel
    mapCache.panelStroke = panelStroke
    mapCache.title = title

    -- The line pool is fixed at build time: at 1x it keeps these fit-all
    -- coordinates, above 1x updateMap rewrites them around the car each tick.
    local step = math.max(1, math.ceil(route.Count / 300))
    local index = 1
    while index < route.Count do
        local nextIndex = math.min(route.Count, index + step)
        local a = route.P[index]
        local b = route.P[nextIndex]
        if a and b then
            local ax, ay = toMap(a.X, a.Z)
            local bx, by = toMap(b.X, b.Z)
            local line = addDrawing("Line")
            line.From = Vector2.new(ax, ay)
            line.To = Vector2.new(bx, by)
            line.Color = Color3.fromRGB(225, 230, 240)
            line.Thickness = 2
            line.Transparency = 0.15
            mapCache.lines[#mapCache.lines + 1] = {
                line = line,
                a = a,
                b = b,
                from = Vector2.new(ax, ay),
                to = Vector2.new(bx, by),
            }
        end
        index = nextIndex
    end

    local startPoint = route.P[1]
    if startPoint then
        local startDot = addDrawing("Circle")
        startDot.Filled = true
        startDot.Radius = 4
        startDot.Color = Color3.fromRGB(70, 220, 120)
        mapCache.startDot = { dot = startDot, pos = startPoint }
    end

    local finishPoint = route.P[route.Count]
    if finishPoint then
        local finishDot = addDrawing("Circle")
        finishDot.Filled = true
        finishDot.Radius = 4
        finishDot.Color = Color3.fromRGB(255, 90, 90)
        mapCache.finishDot = { dot = finishDot, pos = finishPoint }
    end

    for _, corner in ipairs(route.Corners) do
        if #mapCache.corners >= 70 then break end
        local severity = tonumber(corner.Severity) or 6
        if severity < 6 then
            local distance = corner.Apex or corner.From
            if distance then
                local point = route:PointAt(distance)
                local dot = addDrawing("Circle")
                dot.Filled = true
                dot.Radius = 2
                dot.Color = Color3.fromRGB(255, 175, 60)
                dot.Transparency = 0.2
                mapCache.corners[#mapCache.corners + 1] = { dot = dot, pos = point }
            end
        end
    end

    local carDot = addDrawing("Circle")
    carDot.Filled = true
    carDot.Radius = 5
    carDot.Color = Color3.fromRGB(0, 220, 255)
    carDot.Visible = false

    local heading = addDrawing("Line")
    heading.Thickness = 2
    heading.Color = Color3.fromRGB(0, 220, 255)

    local progress = addDrawing("Text")
    progress.Text = ""
    progress.Size = 13
    progress.Color = Color3.fromRGB(230, 235, 245)
    progress.Outline = true
    progress.Position = Vector2.new(boxX, boxY + size + 4)

    mapCache.carDot = carDot
    mapCache.heading = heading
    mapCache.progress = progress

    hideDrawings()
    return true
end

local function updateMap()
    local car = CarController.LocalCar
    local role = CarController.LocalRole
    local part = car and car.PrimaryPart
    if not part or role ~= "Driver" then
        hideDrawings()
        mapCache.lastIndex = nil
        return
    end

    local stageId = car:GetAttribute("StageId")
    local camera = workspace.CurrentCamera
    if not stageId or not camera then
        hideDrawings()
        return
    end

    local viewport = camera.ViewportSize
    if not mapCache.route
        or mapCache.stage ~= stageId
        or mapCache.viewportX ~= viewport.X
        or mapCache.viewportY ~= viewport.Y
    then
        if not buildMap(stageId) then
            hideDrawings()
            return
        end
    end

    local route = mapCache.route
    local position = part.Position
    local nearestIndex, distance = route:Nearest(position, mapCache.lastIndex, 80, 160)
    mapCache.lastIndex = nearestIndex

    local roadPoint = route:PointAt(distance)
    local boxX, boxY, size = mapCache.boxX, mapCache.boxY, mapCache.size
    local left, top = boxX + 2, boxY + 2
    local right, bottom = boxX + size - 2, boxY + size - 2
    local zoom = math.max(1, Config.mapZoom or 1)
    local projectX, projectY

    if zoom > 1.01 then
        local centerX, centerY = boxX + size * 0.5, boxY + size * 0.5
        local factor = mapCache.scale * zoom
        local centerWorldX, centerWorldZ = roadPoint.X, roadPoint.Z

        for _, entry in ipairs(mapCache.lines) do
            local ax = centerX + (entry.a.X - centerWorldX) * factor
            local ay = centerY + (entry.a.Z - centerWorldZ) * factor
            local bx = centerX + (entry.b.X - centerWorldX) * factor
            local by = centerY + (entry.b.Z - centerWorldZ) * factor
            local x1, y1, x2, y2 = clipSegment(ax, ay, bx, by, left, top, right, bottom)
            if x1 then
                entry.line.From = Vector2.new(x1, y1)
                entry.line.To = Vector2.new(x2, y2)
                entry.line.Visible = true
            else
                entry.line.Visible = false
            end
        end

        projectX = function(wx) return centerX + (wx - centerWorldX) * factor end
        projectY = function(wz) return centerY + (wz - centerWorldZ) * factor end
        mapCache.zoomed = true
    else
        if mapCache.zoomed then
            for _, entry in ipairs(mapCache.lines) do
                entry.line.From = entry.from
                entry.line.To = entry.to
                entry.line.Visible = true
            end
            mapCache.zoomed = false
        end
        projectX = function(wx) return mapCache.originX + (wx - route.Min.X) * mapCache.scale end
        projectY = function(wz) return mapCache.originY + (wz - route.Min.Z) * mapCache.scale end
    end

    local function placeDot(entry)
        if not entry then return end
        local px, py = projectX(entry.pos.X), projectY(entry.pos.Z)
        entry.dot.Position = Vector2.new(px, py)
        entry.dot.Visible = px >= left and px <= right and py >= top and py <= bottom
    end
    placeDot(mapCache.startDot)
    placeDot(mapCache.finishDot)
    for _, corner in ipairs(mapCache.corners) do
        placeDot(corner)
    end

    local markerX, markerY = projectX(roadPoint.X), projectY(roadPoint.Z)

    local look = part.CFrame.LookVector
    local dirX, dirZ = look.X, look.Z
    local magnitude = math.sqrt(dirX * dirX + dirZ * dirZ)
    if magnitude > 0.001 then
        dirX, dirZ = dirX / magnitude, dirZ / magnitude
    end

    mapCache.carDot.Position = Vector2.new(markerX, markerY)
    mapCache.heading.From = Vector2.new(markerX, markerY)
    mapCache.heading.To = Vector2.new(markerX + dirX * 12, markerY + dirZ * 12)

    local text = string.format("%s  |  %.1f / %.1f km", stageNameById[stageId] or stageId, distance / 1000, route.Length / 1000)
    if zoom > 1.01 then
        text = text .. string.format("  |  %.1fx", zoom)
    end
    mapCache.progress.Text = text

    mapCache.panel.Visible = true
    mapCache.panelStroke.Visible = true
    mapCache.title.Visible = true
    mapCache.carDot.Visible = true
    mapCache.heading.Visible = true
    mapCache.progress.Visible = true
end

onSignal(RunService.Heartbeat, function(delta)
    if not Config.showMap or isTomb() then return end
    mapElapsed = mapElapsed + delta
    if mapElapsed < 0.05 then return end
    mapElapsed = 0
    updateMap()
end)

-- ================================================================
-- MENU
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Backseat Rally",
    Size = UDim2.fromOffset(540, 440),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Backseat Rally",
    LoadingFooter = "by Exlumiaa Hub",
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

local DrivingTab = Window:AddTab({ Name = "Driving", Icon = "car", Subtitle = "Auto" })
local AutoSub = DrivingTab:AddSubTab("Autopilot")
autosaveWrap(AutoSub)

AutoSub:AddSection("Autopilot")
AutoSub:AddToggle({
    Name = "Autopilot",
    Flag = "br_autopilot",
    Default = false,
    Callback = function(v)
        Config.autopilot = v
        if v then
            notify("Autopilot", "Sit in the driver seat and start a run.", "info")
        end
    end,
})

local MapSub = DrivingTab:AddSubTab("Map")
autosaveWrap(MapSub)

MapSub:AddSection("Driver Map")
MapSub:AddToggle({
    Name = "Show Map",
    Flag = "br_map",
    Default = false,
    Callback = function(v)
        Config.showMap = v
        if not v then hideDrawings() end
    end,
})
MapSub:AddSlider({
    Name = "Zoom",
    Min = 100,
    Max = 600,
    Default = 100,
    Suffix = "%",
    Flag = "br_map_zoom",
    Callback = function(v)
        Config.mapZoom = math.clamp(tonumber(v) or 100, 100, 600) / 100
    end,
})

local stageDropdown
if stageTravelRemote and #stageOptions > 0 then
    local StagesTab = Window:AddTab({ Name = "Stages", Icon = "map", Subtitle = "Travel" })
    local StagesSub = StagesTab:AddSubTab("Select")
    autosaveWrap(StagesSub)

    StagesSub:AddSection("Stage")
    stageDropdown = StagesSub:AddDropdown({
        Name = "Stage",
        Options = stageOptions,
        Default = stageOptions[1],
        Flag = "br_stage",
        Callback = function(v) end,
    })
    StagesSub:AddDivider()
    StagesSub:AddButton({
        Name = "Travel",
        Primary = true,
        Callback = function()
            local name = stageDropdown:Get()
            local stageId = name and stageIdByName[name]
            if not stageId then
                notify("Stages", "Pick a stage first!", "warning")
                return
            end
            if CarController.LocalCar then
                notify("Stages", "Exit the car first.", "warning")
                return
            end
            local ok = pcall(function()
                stageTravelRemote:FireServer("Go", stageId)
            end)
            if ok then
                notify("Stages", "Traveling to " .. name, "success")
            else
                notify("Stages", "Travel failed.", "error")
            end
        end,
    })
end

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
autosaveWrap(ConfigSub)

ConfigSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "br_config_selected",
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
    Flag = "br_config_name",
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
            notify("Config", "Save failed.", "error")
        end
    end,
})
ConfigSub:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if selectedConfig == "" then
            notify("Config", "Pick a config first!", "warning")
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Load failed.", "error")
        end
    end,
})

ConfigSub:AddSection("About")
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })
ConfigSub:AddLabel({ Text = "Toggle Menu: RightShift" })

-- ================================================================
-- CLEANUP
-- ================================================================
local function cleanup()
    Config.autopilot = false
    Config.showMap = false
    pcall(function()
        CarInput.Read = originalRead
    end)
    clearDrawings()
    pcall(cleardrawcache)
    local gui = rawget(_G, _G_GUI)
    if gui and gui.Parent then
        pcall(function() gui:Destroy() end)
    end
    pcall(function() Library:Unload() end)
    rawset(_G, _G_ALIVE, nil)
end

if STATE and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(cleanup)
end

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

print("[ExlumiaaHub] Backseat Rally Hub loaded!")
