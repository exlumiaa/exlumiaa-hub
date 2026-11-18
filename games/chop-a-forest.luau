-- Exlumiaa Hub - Chop A Forest
-- Server-authoritative game: every value lives in attributes/leaderstats, so
-- nothing here grants currency. This hub only drives the game's own remotes.
--
-- Verified against the live run place:
--   Chop:FireServer(tree, hitPos, side, swingCount)  -> drops tree HP
--   PickUpLog:FireServer(log)                        -> CarriedLogs +1 (server reach 15)
--   DepositLogs:FireServer(false)                    -> sells carried logs at a DepositPad
-- Fists server reach is 11 studs, so the loop always walks within reach first.

-- Keyed on game.GameId, which for this experience is the universe id and covers
-- every place in it (both 77239332768345 and the twin 103363457515322).
if tostring(game.GameId) ~= "10767386157" then return end


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local STATE = rawget(_G, "STATE") or (type(getgenv) == "function" and rawget(getgenv(), "STATE") or nil)

local _G_TOMB = "_ _cafTomb"
local _G_ALIVE = "_ _cafAlive"
local _G_GEN = "_ _cafGen"
local _G_GUI = "_ _cafGui"

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
            if gui:IsA("ScreenGui") and gui.Name == "ExlumiaaHub" then gui:Destroy() end
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
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_chopaforest.txt"
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
            brand = "Chop A Forest",
            guiName = "ChopAForestKeyGate",
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

Library.ConfigFolder = "exlumiaa/chopaforest"

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
-- CONFIG
-- ================================================================
local Config = {
    targetMode = "Nearest",

    autoChop = false,
    chopReach = 10,
    chopRate = 0.35,
    farmRadius = 150,

    autoPickup = false,
    pickupRange = 14,

    autoSell = false,
    sellReach = 20,

    espEnabled = false,
    espBest = true,
    espLabels = false,
    espRadius = 140,
    espMax = 25,

    autoGems = false,
    autoBird = false,
    birdReach = 20,

    truckLoad = false,
    truckUnload = false,
    truckReach = 14,
}

-- Sell price per species (ReplicatedStorage.Shared.Configs.Chopping -> Selling.Price)
local PRICE = {
    Birch = 1, Pine = 1.25, Oak = 1.5, Ancient = 2.5, Aspen = 1.05,
    Spruce = 0.665, Cypress = 2.05, UmbrellaPine = 0.6, Maple = 0.97,
    Poplar = 1.5, Fir = 0.395, Cherry = 1.25, CopperBeech = 0.695,
}

-- ================================================================
-- GAME ACCESS
-- ================================================================
local function remote(name)
    local shared = ReplicatedStorage:FindFirstChild("Shared")
    local services = shared and shared:FindFirstChild("Services")
    local group = services and services:FindFirstChild("ChopRemotes")
    return group and group:FindFirstChild(name) or nil
end

local function myHrp()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function myHum()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function carried()
    return tonumber(LP:GetAttribute("CarriedLogs")) or 0
end

-- Bag capacity is upgrade-driven, so it is read from the game's own helper.
-- The game fills the bag in LogCarry.PickUp and treats it as full when
-- carried >= UpgradeMath.CarryMax(player); matching that exact test is what
-- keeps this loop and the server agreeing on when to stop chopping.
local UpgradeMath = nil
do
    local ok, mod = pcall(function()
        local shared = ReplicatedStorage:FindFirstChild("Shared")
        local utils = shared and shared:FindFirstChild("Utilities")
        local m = utils and utils:FindFirstChild("UpgradeMath")
        return m and require(m) or nil
    end)
    if ok and type(mod) == "table" and type(mod.CarryMax) == "function" then
        UpgradeMath = mod
    end
end

local function carryMax()
    if not UpgradeMath then return nil end
    local ok, max = pcall(UpgradeMath.CarryMax, LP)
    if ok and type(max) == "number" and max > 0 then return max end
    return nil
end

local function bagFull()
    local max = carryMax()
    if max then return carried() >= max end
    return carried() > 0
end

-- Locked areas: only the first workspace.AreasUnlocked forest areas are open, and
-- the rest sit behind fences, so nothing outside them may be walked to. Trees carry
-- AreaIndex; sell huts carry their area key, which AreaOrder turns into the same index.
local AreaOrder = nil
do
    local ok, cfg = pcall(function()
        local shared = ReplicatedStorage:FindFirstChild("Shared")
        local configs = shared and shared:FindFirstChild("Configs")
        local chopping = configs and configs:FindFirstChild("Chopping")
        return chopping and require(chopping) or nil
    end)
    local forest = ok and cfg and cfg.Forest
    local areas = forest and forest.Areas
    if type(areas) == "table" and type(areas.Order) == "table" then
        AreaOrder = areas.Order
    end
end

local function unlockedAreas()
    return tonumber(workspace:GetAttribute("AreasUnlocked")) or math.huge
end

local function inUnlockedArea(instance)
    local idx = tonumber(instance:GetAttribute("AreaIndex"))
    if idx == nil and AreaOrder then
        local key = instance:GetAttribute("Area") or instance:GetAttribute("Biome")
        if key ~= nil then idx = table.find(AreaOrder, key) end
    end
    return idx == nil or idx <= unlockedAreas()
end

local treeCache, treeCacheAt = {}, 0
local function trees()
    if os.clock() - treeCacheAt > 2 then
        treeCache = {}
        local map = workspace:FindFirstChild("Map")
        local folder = map and map:FindFirstChild("Trees")
        if folder then
            for _, t in ipairs(folder:GetChildren()) do
                treeCache[#treeCache + 1] = t
            end
        end
        treeCacheAt = os.clock()
    end
    return treeCache
end

-- Every sell station ships a DepositPad part (Map.SellSpot + ForestHuts outposts).
local padCache, padCacheAt = {}, 0
local function pads()
    if os.clock() - padCacheAt > 5 then
        padCache = {}
        local map = workspace:FindFirstChild("Map")
        local main = map and map:FindFirstChild("SellSpot")
        local p = main and main:FindFirstChild("DepositPad")
        if p then padCache[#padCache + 1] = p end
        local huts = workspace:FindFirstChild("ForestHuts")
        if huts then
            for _, hut in ipairs(huts:GetChildren()) do
                if inUnlockedArea(hut) then
                    local outpost = hut:FindFirstChild("SellOutpost")
                    local d = outpost and outpost:FindFirstChild("DepositPad")
                    if d then padCache[#padCache + 1] = d end
                end
            end
        end
        padCacheAt = os.clock()
    end
    return padCache
end

local function nearestPad(origin, skip)
    local best, bd
    for _, p in ipairs(pads()) do
        if not (skip and skip(p)) then
            local d = (p.Position - origin).Magnitude
            if not bd or d < bd then bd, best = d, p end
        end
    end
    return best, bd
end

local function treePos(t)
    local trunk = t:FindFirstChild("TrunkBase") or t:FindFirstChild("Root")
    if trunk then return trunk.Position end
    return t:GetPivot().Position
end

local function isChoppable(t)
    if not t or not t.Parent then return false end
    local hp = tonumber(t:GetAttribute("HP")) or 0
    return hp > 0 and not t:GetAttribute("Doomed")
end

local function treeInfo(t)
    local hp = tonumber(t:GetAttribute("HP")) or 0
    local maxhp = tonumber(t:GetAttribute("MaxHP")) or hp
    local species = t:GetAttribute("Species") or t:GetAttribute("TreeType") or t.Name
    return hp, maxhp, species, PRICE[species] or 1
end

local function collectTrees(origin, radius, choppableOnly)
    local out = {}
    for _, t in ipairs(trees()) do
        if inUnlockedArea(t) and ((not choppableOnly) or isChoppable(t)) then
            local pos = treePos(t)
            local d = (pos - origin).Magnitude
            if d <= radius then
                local hp, maxhp, species, price = treeInfo(t)
                local top = pos + Vector3.new(0, tonumber(t:GetAttribute("Height")) or 8, 0)
                out[#out + 1] = { tree = t, pos = pos, top = top, dist = d, hp = hp, maxhp = maxhp, species = species, price = price }
            end
        end
    end
    return out
end

-- ================================================================
-- ACTIONS
-- ================================================================
local swingCount = 0

local function chopOnce(tree)
    local chop = remote("Chop")
    if not chop then return end
    local pos = treePos(tree)
    local hrp = myHrp()
    if hrp then
        local d = hrp.Position - pos
        if d.Magnitude > 0.01 then pos = pos + d.Unit * 1.5 end
    end
    swingCount = swingCount + 1
    pcall(function() chop:FireServer(tree, pos, 1, swingCount) end)
end

local function doPickup(origin)
    local pick = remote("PickUpLog")
    local container = workspace:FindFirstChild("Logs")
    if not pick or not container then return end
    for _, log in ipairs(container:GetChildren()) do
        local pos = log.PrimaryPart and log.PrimaryPart.Position
        if not pos then
            local ok, cf = pcall(function() return log:GetPivot() end)
            pos = ok and cf.Position or nil
        end
        if pos and (pos - origin).Magnitude <= Config.pickupRange then
            pcall(function() pick:FireServer(log) end)
        end
    end
end

-- ================================================================
-- TREE ESP
-- ================================================================
local chamsPool, labelPool = {}, {}
local espList, espBest = {}, nil

local function valueColor(price)
    if price >= 2.5 then return Color3.fromRGB(255, 60, 60) end
    if price >= 2 then return Color3.fromRGB(255, 140, 0) end
    if price >= 1.5 then return Color3.fromRGB(255, 235, 60) end
    if price >= 1 then return Color3.fromRGB(235, 235, 235) end
    return Color3.fromRGB(150, 160, 175)
end

-- Chams: Highlight instances track their Adornee themselves, so this only needs
-- to run at ~3Hz. Roblox renders a limited number of Highlights at once, which is
-- why Max Trees caps the list.
local function chamsUpdate()
    if not Config.espEnabled then
        for _, h in ipairs(chamsPool) do pcall(function() h.Adornee = nil end) end
        espList, espBest = {}, nil
        return
    end
    local hrp = myHrp()
    if not hrp then return end

    local list = collectTrees(hrp.Position, Config.espRadius, true)
    table.sort(list, function(a, b) return a.dist < b.dist end)

    local best = nil
    if Config.espBest then
        for _, e in ipairs(list) do
            if not best or e.price > best.price then best = e end
        end
    end
    espList, espBest = list, best

    local n = math.min(#list, Config.espMax)
    for i = 1, n do
        local e = list[i]
        local h = chamsPool[i]
        if not h then
            h = Instance.new("Highlight")
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillTransparency = 0.55
            h.OutlineTransparency = 0.15
            chamsPool[i] = h
        end
        local col = (Config.espBest and best == e) and Color3.fromRGB(255, 40, 200) or valueColor(e.price)
        h.FillColor = col
        h.OutlineColor = col
        h.Adornee = e.tree
        h.Parent = Camera
    end
    for i = n + 1, #chamsPool do
        pcall(function() chamsPool[i].Adornee = nil end)
    end
end

-- Labels are the only part that needs a per-frame update.
local function labelUpdate()
    local n = 0
    if Config.espEnabled and Config.espLabels then
        for i = 1, #espList do
            if n >= Config.espMax then break end
            local e = espList[i]
            local sp, on = Camera:WorldToViewportPoint(e.top)
            if on then
                n = n + 1
                local t = labelPool[n]
                if not t then
                    t = Drawing.new("Text")
                    t.Size = 13
                    t.Center = true
                    t.Outline = true
                    t.Font = 2
                    labelPool[n] = t
                end
                local col = (Config.espBest and espBest == e) and Color3.fromRGB(255, 40, 200) or valueColor(e.price)
                t.Text = string.format("%s  %.1f/%.1f  %dm", e.species, e.hp, e.maxhp, math.floor(e.dist))
                t.Position = Vector2.new(sp.X, sp.Y)
                t.Color = col
                t.Visible = true
            end
        end
    end
    for i = n + 1, #labelPool do
        labelPool[i].Visible = false
    end
end

-- ================================================================
-- FARM LOOP
-- ================================================================
local target = nil
local lastChop, lastSell = 0, 0
local stuckAt, stuckBest = 0, math.huge
local blacklist = {}

local function blocked(inst)
    local exp = blacklist[inst]
    if not exp then return false end
    if exp > os.clock() then return true end
    blacklist[inst] = nil
    return false
end

-- Walks toward goal, but gives up when no progress is made, so an unreachable
-- tree or sell pad is dropped instead of pushing the character into it forever.
local function walk(hum, goal, origin)
    local dist = (goal - origin).Magnitude
    if dist < stuckBest - 1 then stuckBest, stuckAt = dist, os.clock() end
    if os.clock() - stuckAt > 4 then return false end
    hum:MoveTo(goal)
    return true
end

local function pickTree(origin)
    local best, bd
    for _, t in ipairs(collectTrees(origin, Config.farmRadius, true)) do
        if not blocked(t.tree) then
            if Config.targetMode == "Best Value" then
                if not best or t.price > best.price then best, bd = t.tree, t.dist end
            elseif not bd or t.dist < bd then
                best, bd = t.tree, t.dist
            end
        end
    end
    return best, bd
end

-- ================================================================
-- GEMS, BIRDS, TRUCK
-- ================================================================
-- Each of these is a single remote fired once the character is close enough.

-- Gems only exist briefly and only for the player who dropped them.
local function doGems(origin)
    local r = remote("CollectGem")
    local folder = workspace:FindFirstChild("GemDrops")
    if not r or not folder then return end
    for _, gem in ipairs(folder:GetChildren()) do
        local owner = gem:GetAttribute("Owner")
        if owner == nil or tostring(owner) == tostring(LP.UserId) then
            local pos = gem:IsA("BasePart") and gem.Position or nil
            if not pos then
                local ok, cf = pcall(function() return gem:GetPivot() end)
                pos = ok and cf.Position or nil
            end
            if pos and (pos - origin).Magnitude <= Config.pickupRange then
                pcall(function() r:FireServer(gem, "Click") end)
            end
        end
    end
end

local function doBirds(origin)
    local r = remote("PopBird")
    local folder = workspace:FindFirstChild("AmbientBirds")
    if not r or not folder then return end
    for _, bird in ipairs(folder:GetChildren()) do
        local rp = bird:FindFirstChild("RootPart") or bird.PrimaryPart
        if rp and (rp.Position - origin).Magnitude <= Config.birdReach then
            pcall(function() r:FireServer(rp.Position, true) end)
        end
    end
end

local function ownTruck()
    local folder = workspace:FindFirstChild("Vehicles")
    if not folder then return nil end
    for _, v in ipairs(folder:GetChildren()) do
        if tostring(v:GetAttribute("Owner")) == tostring(LP.UserId) then return v end
    end
    return nil
end

local function truckCargo(truck)
    return tonumber(truck and truck:GetAttribute("CargoCount")) or 0
end

local function truckSpace(truck)
    local cap = tonumber(truck and truck:GetAttribute("Capacity"))
    if not cap then return 0 end
    return math.max(0, cap - truckCargo(truck))
end

-- LoadTruck and UnloadTruck take no arguments; the server does the distance check
-- itself (Chopping.Vehicles.Cargo.ServerLoadReach = 18), so the walk stops short.
local lastTruck = 0
local function truckTrip(hrp, hum, name)
    local truck = ownTruck()
    local bed = truck and truck:FindFirstChild("LogBed")
    local zone = bed and bed:FindFirstChild("BedZone")
    if not zone then return end
    if (zone.Position - hrp.Position).Magnitude > Config.truckReach then
        walk(hum, zone.Position, hrp.Position)
        return
    end
    local now = os.clock()
    if now - lastTruck >= 0.5 then
        lastTruck = now
        local r = remote(name)
        if r then pcall(function() r:FireServer() end) end
    end
end

-- The Garage tab queues a trip here and the loop walks to it, so a single
-- thread owns the character's movement. runGarage is defined below the UI,
-- where the notify helper exists.
local garageJob, runGarage = nil, nil

local lastExtras = 0

local farmTicks, farmErr, farmStep = 0, nil, ""
rawset(_G, "_ _cafDiag", function() return farmTicks, farmErr, farmStep end)

task.spawn(function()
    while not isTomb() do
        task.wait(0.1)
        if not isTomb() then
            farmTicks = farmTicks + 1
            local ok, err = xpcall(function()
                farmStep = "start"
                local hrp = myHrp()
                local hum = myHum()
                if not hrp or not hum or hum.Health <= 0 then return end
                local now = os.clock()

                -- A queued Garage trip takes priority: it is a one-off the user asked
                -- for, and it needs the character's movement to itself.
                if garageJob and runGarage then
                    farmStep = "garage"
                    if runGarage(hrp, hum) then garageJob = nil end
                    return
                end

                if not (Config.autoChop or Config.autoPickup or Config.autoSell
                    or Config.autoGems or Config.autoBird or Config.truckLoad or Config.truckUnload) then
                    return
                end

                farmStep = "pickup"
                if Config.autoPickup then doPickup(hrp.Position) end

                -- Gems and birds show up around the trees being chopped, so they are
                -- swept on the same tick as the log pickup.
                if Config.autoGems or Config.autoBird then
                    if now - lastExtras >= 0.3 then
                        lastExtras = now
                        if Config.autoGems then doGems(hrp.Position) end
                        if Config.autoBird then doBirds(hrp.Position) end
                    end
                end

                -- Truck work sits in front of the pad trip: loading the truck is the
                -- alternative to carrying a full bag to a DepositPad. Unloading only
                -- starts with empty hands, so it never fights the sell trip.
                farmStep = "truck"
                if Config.truckLoad and bagFull() then
                    if truckSpace(ownTruck()) > 0 then
                        truckTrip(hrp, hum, "LoadTruck")
                        return
                    end
                elseif Config.truckUnload and carried() == 0 and truckCargo(ownTruck()) > 0 then
                    truckTrip(hrp, hum, "UnloadTruck")
                    return
                end

                -- Sell phase: only once the bag is full, so a run is never cut
                -- short with a few logs in hand.
                farmStep = "sell"
                if Config.autoSell and bagFull() then
                    local pad, dist = nearestPad(hrp.Position, blocked)
                    if pad then
                        if dist <= Config.sellReach then
                            if Camera then
                                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, pad.Position)
                            end
                            if now - lastSell >= 0.6 then
                                lastSell = now
                                local dep = remote("DepositLogs")
                                if dep then pcall(function() dep:FireServer(false) end) end
                            end
                        elseif not walk(hum, pad.Position, hrp.Position) then
                            blacklist[pad] = now + 30
                            stuckBest, stuckAt = math.huge, now
                        end
                    end
                    return
                end

                -- Farm phase. Only Auto Chop acquires a target, so with it off the
                -- character never walks anywhere.
                if not Config.autoChop then target = nil return end
                farmStep = "chop"
                if not isChoppable(target) then target = nil end
                if not target then
                    farmStep = "pickTree"
                    local tree, dist = pickTree(hrp.Position)
                    target = tree
                    stuckBest, stuckAt = dist or math.huge, now
                end
                if not target then return end

                farmStep = "walkOrChop"
                local pos = treePos(target)
                local dist = (pos - hrp.Position).Magnitude
                if dist <= Config.chopReach then
                    stuckBest, stuckAt = math.huge, now
                    if now - lastChop >= Config.chopRate then
                        lastChop = now
                        farmStep = "chopFire"
                        chopOnce(target)
                    end
                elseif not walk(hum, pos, hrp.Position) then
                    blacklist[target] = now + 20
                    target = nil
                    stuckBest, stuckAt = math.huge, now
                end
            end, debug.traceback)
            if not ok and not farmErr then
                farmErr = tostring(err)
                warn("[ExlumiaaHub] farm loop error at " .. farmStep .. ": " .. farmErr)
            end
        end
    end
end)

task.spawn(function()
    while not isTomb() do
        task.wait(0.3)
        if isTomb() then break end
        pcall(function()
            Camera = workspace.CurrentCamera
            chamsUpdate()
        end)
    end
end)

onSignal(game:GetService("RunService").RenderStepped, function()
    if isTomb() then return end
    pcall(function()
        Camera = workspace.CurrentCamera
        labelUpdate()
    end)
end)

-- ================================================================
-- CLEANUP
-- ================================================================
local function cleanup()
    rawset(_G, _G_TOMB, true)
    task.wait(0.1)
    for _, h in ipairs(chamsPool) do pcall(function() h:Destroy() end) end
    for _, t in ipairs(labelPool) do pcall(function() t:Remove() end) end
    chamsPool, labelPool, espList = {}, {}, {}
    pcall(cleardrawcache)
    local gui = rawget(_G, _G_GUI)
    if gui and gui.Parent then
        pcall(function() gui:Destroy() end)
    end
    rawset(_G, _G_ALIVE, nil)
end

if STATE and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(cleanup)
end

-- ================================================================
-- MENU
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Chop A Forest",
    Size = UDim2.fromOffset(540, 460),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Chop A Forest",
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

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "tree", Subtitle = "Auto" })
local FarmSub = FarmTab:AddSubTab("Auto Farm")
autosaveWrap(FarmSub)

FarmSub:AddSection("Chopping")
FarmSub:AddToggle({
    Name = "Auto Chop",
    Flag = "caf_chop",
    Default = false,
    Callback = function(v) Config.autoChop = v end,
})
FarmSub:AddSlider({
    Name = "Chop Reach",
    Min = 5, Max = 20, Default = 10,
    Suffix = " studs",
    Flag = "caf_chop_reach",
    Callback = function(v) Config.chopReach = v end,
})
FarmSub:AddSlider({
    Name = "Chop Rate",
    Min = 0.1, Max = 2, Default = 0.35,
    Suffix = " s",
    Flag = "caf_chop_rate",
    Callback = function(v) Config.chopRate = v end,
})
FarmSub:AddDropdown({
    Name = "Target",
    Options = { "Nearest", "Best Value" },
    Default = "Nearest",
    Flag = "caf_target",
    Callback = function(v) if type(v) == "string" then Config.targetMode = v end end,
})
FarmSub:AddSlider({
    Name = "Farm Radius",
    Min = 20, Max = 500, Default = 150,
    Suffix = " studs",
    Flag = "caf_farm_radius",
    Callback = function(v) Config.farmRadius = v end,
})

FarmSub:AddSection("Logs & Sell")
FarmSub:AddToggle({
    Name = "Auto Pickup",
    Flag = "caf_pickup",
    Default = false,
    Callback = function(v) Config.autoPickup = v end,
})
FarmSub:AddSlider({
    Name = "Pickup Range",
    Min = 5, Max = 15, Default = 14,
    Suffix = " studs",
    Flag = "caf_pickup_range",
    Callback = function(v) Config.pickupRange = v end,
})
FarmSub:AddToggle({
    Name = "Auto Sell",
    Flag = "caf_sell",
    Default = false,
    Callback = function(v) Config.autoSell = v end,
})
FarmSub:AddSlider({
    Name = "Sell Reach",
    Min = 8, Max = 24, Default = 20,
    Suffix = " studs",
    Flag = "caf_sell_reach",
    Callback = function(v) Config.sellReach = v end,
})
FarmSub:AddSection("Gems & Birds")
FarmSub:AddToggle({
    Name = "Auto Collect Gems",
    Flag = "caf_gems",
    Default = false,
    Callback = function(v) Config.autoGems = v end,
})
FarmSub:AddToggle({
    Name = "Auto Pop Birds",
    Flag = "caf_birds",
    Default = false,
    Callback = function(v) Config.autoBird = v end,
})
FarmSub:AddSlider({
    Name = "Bird Reach",
    Min = 8, Max = 40, Default = 20,
    Suffix = " studs",
    Flag = "caf_bird_reach",
    Callback = function(v) Config.birdReach = v end,
})

local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local VisualSub = VisualTab:AddSubTab("Trees")
autosaveWrap(VisualSub)

VisualSub:AddSection("Tree ESP")
VisualSub:AddToggle({
    Name = "Tree Chams",
    Flag = "caf_esp",
    Default = false,
    Callback = function(v) Config.espEnabled = v end,
})
VisualSub:AddToggle({
    Name = "Best Tree (pink)",
    Flag = "caf_esp_best",
    Default = true,
    Callback = function(v) Config.espBest = v end,
})
VisualSub:AddToggle({
    Name = "Text Labels",
    Flag = "caf_esp_labels",
    Default = false,
    Callback = function(v) Config.espLabels = v end,
})
VisualSub:AddSlider({
    Name = "ESP Radius",
    Min = 40, Max = 500, Default = 140,
    Suffix = " studs",
    Flag = "caf_esp_radius",
    Callback = function(v) Config.espRadius = v end,
})
VisualSub:AddSlider({
    Name = "Max Trees",
    Min = 5, Max = 30, Default = 25,
    Flag = "caf_esp_max",
    Callback = function(v) Config.espMax = v end,
})
VisualSub:AddLabel({ Text = "Colour = sell value (grey/white/yellow/orange/red)" })

local UpgradeTab = Window:AddTab({ Name = "Upgrades", Icon = "coin", Subtitle = "Shop" })
local UpgradeSub = UpgradeTab:AddSubTab("Upgrades")

-- Upgrade list, levels and prices all come from the game's own config
-- (Chopping.Upgrades.Sections[].Items[]) and the Up_<Id> player attributes.
local function upgradeSections()
    local ok, cfg = pcall(function()
        local shared = ReplicatedStorage:FindFirstChild("Shared")
        local configs = shared and shared:FindFirstChild("Configs")
        local chopping = configs and configs:FindFirstChild("Chopping")
        return chopping and require(chopping) or nil
    end)
    local up = ok and cfg and cfg.Upgrades
    return up and up.Sections or nil
end

local function upgradeLevel(id)
    return math.max(0, tonumber(LP:GetAttribute("Up_" .. id)) or 0)
end

local function upgradeText(item)
    local max = #item.Prices
    local lvl = math.min(upgradeLevel(item.Id), max)
    local cost = lvl >= max and "MAX" or ("$" .. tostring(item.Prices[lvl + 1]))
    return string.format("  %s   %d/%d   %s", item.Name, lvl, max, cost)
end

local upgradeRows = {}
local upgradeCash, upgradeCashShown = nil, ""

local function refreshUpgrades()
    for _, row in ipairs(upgradeRows) do
        local text = upgradeText(row.item)
        if row.btn.Text ~= text then row.btn.Text = text end
    end
    if upgradeCash then
        local stats = LP:FindFirstChild("leaderstats")
        local cash = stats and stats:FindFirstChild("Cash")
        local text = "Cash: $" .. math.floor(cash and cash.Value or 0)
        if upgradeCashShown ~= text then
            upgradeCashShown = text
            upgradeCash.Text = text
        end
    end
end

local function buyUpgrade(item)
    if upgradeLevel(item.Id) >= #item.Prices then
        notify("Upgrades", item.Name .. " is already maxed", "info")
        return
    end
    local r = remote("BuyUpgrade")
    if not r then
        notify("Upgrades", "BuyUpgrade remote not found", "error")
        return
    end
    r:FireServer(item.Id)
    -- The server applies the level a moment later; refresh on pcall in case this
    -- thread cannot touch the hub GUI (it lives in a Plugin-capability container).
    task.delay(0.6, function() pcall(refreshUpgrades) end)
end

UpgradeSub:AddSection("Shop")
upgradeCash = UpgradeSub:AddLabel({ Text = "Cash: $?" }).Instance
UpgradeSub:AddButton({ Name = "Refresh", Callback = refreshUpgrades })

local upgradeList = upgradeSections()
local upgradeLocked = {}
if upgradeList then
    for _, section in ipairs(upgradeList) do
        local req = section.Requires
        local owned = (req == nil) or LP:GetAttribute("Owns" .. req) == true
        if not section.ComingSoon then
            if not owned then
                upgradeLocked[#upgradeLocked + 1] = section.DisplayName
            else
                UpgradeSub:AddSection(section.DisplayName)
                for _, item in ipairs(section.Items) do
                    local btn = UpgradeSub:AddButton({
                        Name = upgradeText(item),
                        Callback = function() buyUpgrade(item) end,
                    })
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    upgradeRows[#upgradeRows + 1] = { item = item, btn = btn }
                end
            end
        end
    end
else
    UpgradeSub:AddLabel({ Text = "Could not read the upgrade list from the game." })
end
if #upgradeLocked > 0 then
    UpgradeSub:AddDivider()
    UpgradeSub:AddLabel({ Text = "Locked - own the tool first: " .. table.concat(upgradeLocked, ", ") })
end
refreshUpgrades()

-- ================================================================
-- TRUCK & GARAGE
-- ================================================================
-- Buying and spawning both go through RemoteFunctions that refuse anything not
-- done at the garage (Why = "Far"), so every action here queues a trip and the
-- farm loop walks the character to Map.Garage.ShopZone first.
local function garageZone()
    local map = workspace:FindFirstChild("Map")
    local garage = map and map:FindFirstChild("Garage")
    return garage and garage:FindFirstChild("ShopZone")
end

local function vehiclesConfig()
    local ok, cfg = pcall(function()
        local shared = ReplicatedStorage:FindFirstChild("Shared")
        local configs = shared and shared:FindFirstChild("Configs")
        local chopping = configs and configs:FindFirstChild("Chopping")
        return chopping and require(chopping) or nil
    end)
    return ok and cfg and cfg.Vehicles and cfg.Vehicles.List or nil
end

-- The vehicle config only carries an Id ("Truck01_RustyRunabout"), so the display
-- name is built from it.
local function prettyName(id)
    local s = tostring(id):gsub("^Truck%d+_", "")
    return (s:gsub("(%l)(%u)", "%1 %2"))
end

local function ownedVehicles()
    local out = {}
    local s = LP:GetAttribute("VehiclesOwned")
    if type(s) == "string" then
        for id in string.gmatch(s, "[^,%s]+") do out[#out + 1] = id end
    end
    return out
end

local function isRobux(v)
    return tonumber(v.ProductId) ~= nil
end

local function isGem(v)
    return tostring(v.Currency or ""):lower():find("gem") ~= nil
end

-- Coins only, and never the Robux ones: this only ever spends money the player
-- can see in leaderstats.
local function bestAffordableVehicle()
    local owned = {}
    for _, id in ipairs(ownedVehicles()) do owned[id] = true end
    local stats = LP:FindFirstChild("leaderstats")
    local cash = (stats and stats:FindFirstChild("Cash") and stats.Cash.Value) or 0
    local best, bestPrice
    for _, v in ipairs(vehiclesConfig() or {}) do
        local id = tostring(v.Id)
        local price = tonumber(v.Price) or math.huge
        if not owned[id] and not isRobux(v) and not isGem(v) and not v.Run
            and price <= cash and (not bestPrice or price > bestPrice) then
            best, bestPrice = id, price
        end
    end
    return best
end

-- Called from the farm loop, which owns the character's movement. Returns true
-- once the job is finished (or given up on), false while still walking.
runGarage = function(hrp, hum)
    local job = garageJob
    local zone = garageZone()
    if not zone then
        notify("Garage", "Garage not found", "error")
        return true
    end
    if (zone.Position - hrp.Position).Magnitude > Config.sellReach then
        return not walk(hum, zone.Position, hrp.Position)
    end
    local id = job.id
    if job.kind == "buy" and not id then
        id = bestAffordableVehicle()
        if not id then
            notify("Garage", "Nothing affordable - no truck bought", "info")
            return true
        end
    end
    local remoteName = job.kind == "buy" and "BuyVehicle" or "SpawnVehicle"
    local r = remote(remoteName)
    if not r then
        notify("Garage", remoteName .. " remote not found", "error")
        return true
    end
    local ok, res = pcall(function() return r:InvokeServer(id) end)
    if not ok then
        notify("Garage", tostring(res), "error")
        return true
    end
    local good = type(res) == "table" and res.Ok == true
    local why = type(res) == "table" and tostring(res.Why) or tostring(res)
    if good then
        notify("Garage", prettyName(id) .. " " .. (job.kind == "buy" and "bought" or "spawned"), "success")
    else
        notify("Garage", prettyName(id) .. " failed: " .. why, "warning")
    end
    return true
end

local TruckTab = Window:AddTab({ Name = "Truck", Icon = "truck", Subtitle = "Logs & Garage" })
local TruckSub = TruckTab:AddSubTab("Truck")
autosaveWrap(TruckSub)

TruckSub:AddSection("Truck Quest")
TruckSub:AddToggle({
    Name = "Auto Load Truck",
    Flag = "caf_truck_load",
    Default = false,
    Callback = function(v) Config.truckLoad = v end,
})
TruckSub:AddToggle({
    Name = "Auto Unload & Sell",
    Flag = "caf_truck_unload",
    Default = false,
    Callback = function(v) Config.truckUnload = v end,
})
TruckSub:AddSlider({
    Name = "Truck Reach",
    Min = 8, Max = 17, Default = 14,
    Suffix = " studs",
    Flag = "caf_truck_reach",
    Callback = function(v) Config.truckReach = v end,
})
TruckSub:AddButton({
    Name = "Spawn My Truck",
    Callback = function()
        local owned = ownedVehicles()
        if #owned == 0 then
            notify("Garage", "No truck owned yet", "warning")
            return
        end
        garageJob = { kind = "spawn", id = owned[1] }
    end,
})

TruckSub:AddSection("Garage")
TruckSub:AddButton({
    Name = "Buy Best Affordable (Coins)",
    Primary = true,
    Callback = function() garageJob = { kind = "buy", id = nil } end,
})
local vehicleList = vehiclesConfig()
if vehicleList then
    for _, v in ipairs(vehicleList) do
        if not isRobux(v) then
            local id = tostring(v.Id)
            TruckSub:AddButton({
                Name = string.format("  %s   %s %d", prettyName(v.Id), tostring(v.Currency or "?"), tonumber(v.Price) or 0),
                Callback = function() garageJob = { kind = "buy", id = id } end,
            })
        end
    end
else
    TruckSub:AddLabel({ Text = "Could not read the vehicle list from the game." })
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
    Flag = "caf_config_selected",
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
    Flag = "caf_config_name",
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

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

print("[ExlumiaaHub] Chop A Forest Hub loaded!")
