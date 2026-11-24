-- Exlumiaa Hub - Throw Food For Animals
-- Server-authoritative: every value lives in ReplicatedStorage.PlayerData, so
-- nothing here grants currency. This hub only drives the game's own remotes.
--
-- Verified live:
--   Throw_Start -> Throw_Resolve(power 0..1) -> Throw_Complete  (Complete blocks
--   for the flight time, so one throw costs ~flight + 1.6s server cooldown)
--   Training_Start / Training_Stop, Training_Bonus event -> Training_TapBonus(standId)
--   Stand_Upgrade (near the pull-up upgrade sign), Plot_UpgradeFence (near fence sign)
--   Plot_SellAnimal(id) -> {Ok, Money}, Plot_EquipBest()
--   Shop_Buy(index), Shop_Equip(index)
--
-- The game anchors the character to its launch line before a throw, so the hub
-- teleports there, waits for the server to register the new position, then fires.

if tostring(game.GameId) ~= "10766972131" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _tffaTomb"
local _G_ALIVE = "_ _tffaAlive"
local _G_CONFIG = "_ _tffaConfig"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.6)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
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

-- ================================================================
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_tffa.txt"
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
            brand = "Throw Food For Animals!",
            guiName = "TFFAKeyGate",
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
    _G._hubKeyValidated = true
end

local Library = nil
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 80 do
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library then return end

Library.ConfigFolder = "exlumiaa"

local Config = {
    autoThrow = false,
    autoTrain = false,
    autoBonus = true,
    farmMode = "Throw Only",
    trainTime = 45,
    autoPlace = false,
    autoSell = false,
    sellRarityIdx = 0,
    sellIncome = 0,
    keepMutated = true,
    autoStand = false,
    autoFence = false,
    autoFood = false,
    reserve = 0,
    antiAfk = true,
}
rawset(_G, _G_CONFIG, Config)

-- ================================================================
-- Modules
-- ================================================================
local DC
for _ = 1, 60 do
    local ok, mod = pcall(function()
        return require(LP.PlayerScripts.Client.Controllers.DataController)
    end)
    if ok and mod then DC = mod; break end
    task.wait(0.5)
end
if not DC then return end

local Remotes, GameConfig, AnimalEconomy, RarityConfig, FoodsConfig, StandsConfig, FenceConfig
local okMods = pcall(function()
    Remotes = require(ReplicatedStorage.Shared.Remotes)
    GameConfig = require(ReplicatedStorage.Config.GameConfig)
    AnimalEconomy = require(ReplicatedStorage.Config.AnimalEconomy)
    RarityConfig = require(ReplicatedStorage.Config.RarityConfig)
    FoodsConfig = require(ReplicatedStorage.Config.FoodsConfig)
    StandsConfig = require(ReplicatedStorage.Config.StandsConfig)
    FenceConfig = require(ReplicatedStorage.Config.FenceConfig)
end)
if not okMods or not Remotes then return end

task.spawn(function() pcall(function() DC:WaitForReady() end) end)

-- ================================================================
-- Helpers
-- ================================================================
local function inv(...)
    local args = table.pack(...)
    local ok, ret = pcall(function() return Remotes.Invoke(table.unpack(args, 1, args.n)) end)
    if not ok then return { Ok = false, Reason = "Error" } end
    return ret or {}
end

local function num(v)
    v = tonumber(v)
    if not v then return 0 end
    return v
end

local function money() return num(DC:Get("Money")) end
local function standLevel() return num(DC:Get("Stand")) end
local function fenceLevel() return num(DC:Get("FenceLevel")) end
local function isTraining() return LP:GetAttribute("Training") == true end

local function hp()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function plotPivot()
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(tostring(LP:GetAttribute("PlotIndex") or 1))
    if not plot then return Vector3.new(0, 2, 22.5) end
    local ok, cf = pcall(function() return plot:GetPivot() end)
    return ok and cf.Position or Vector3.new(0, 2, 22.5)
end

-- Returns true if the character was moved. The caller waits for replication.
local function teleport(pos, lookAt)
    local h = hp()
    if not h then return false end
    h.AssemblyLinearVelocity = Vector3.zero
    h.AssemblyAngularVelocity = Vector3.zero
    h.CFrame = lookAt and CFrame.lookAt(pos, lookAt) or CFrame.new(pos)
    return true
end

local function linePos()
    local launch = GameConfig.Throw.LaunchPosition
    return Vector3.new(launch.X, 5.5, launch.Z)
end

local function trainPos()
    return plotPivot() + GameConfig.Plot.TrainingSpotOffset + Vector3.new(0, 3, 0)
end

local function standPos()
    local p = plotPivot()
    local btn = p + GameConfig.Plot.UpgradeButtonOffset
    local spot = p + GameConfig.Plot.TrainingSpotOffset
    local dir = Vector3.new(btn.X - spot.X, 0, btn.Z - spot.Z)
    dir = dir.Magnitude > 0.1 and dir.Unit or Vector3.new(0, 0, -1)
    return btn + dir * 3.8 + Vector3.new(0, 3, 0), btn + Vector3.new(0, 4, 0)
end

local function fencePos()
    return plotPivot() + FenceConfig.SignOffset + Vector3.new(0, 3, 0)
end

local function shopPos()
    return plotPivot() + GameConfig.Plot.ShopCircleOffset + Vector3.new(0, 3, 0)
end

local function rarityNames()
    local out = {}
    for _, v in ipairs(RarityConfig.List or {}) do
        local name = type(v) == "table" and (v.Name or v.Rarity) or tostring(v)
        if name and name ~= "" then out[#out + 1] = name end
    end
    return out
end

local function rarityIndex(name)
    for i, v in ipairs(RarityConfig.List or {}) do
        local n = type(v) == "table" and (v.Name or v.Rarity) or tostring(v)
        if n == name then return i end
    end
    return 99
end

local function ownedFoods()
    local out = {}
    local owned = DC:Get("OwnedFoods") or {}
    for k, v in pairs(owned) do
        local idx = tonumber(k)
        if idx and v then out[idx] = true end
    end
    return out
end

local function bestFood()
    local best = 1
    for idx in pairs(ownedFoods()) do
        if idx > best then best = idx end
    end
    return best
end

local function animals()
    return DC:Get("Animals") or {}
end

local function animalInfo(entry)
    local info = AnimalEconomy.Get(entry.ModelName) or {}
    return num(info.Income), tostring(info.Rarity or "Common")
end

-- ================================================================
-- Sell
-- ================================================================
local function sellCandidates()
    local out = {}
    for id, entry in pairs(animals()) do
        if entry.Placed ~= true then
            local inc, rarity = animalInfo(entry)
            local mutated = entry.Mutation ~= nil and entry.Mutation ~= ""
            local keep = Config.keepMutated and mutated
            local match = (Config.sellRarityIdx > 0 and rarityIndex(rarity) <= Config.sellRarityIdx)
                or (Config.sellIncome > 0 and inc < Config.sellIncome)
            if match and not keep then
                out[#out + 1] = { Id = id, Income = inc }
            end
        end
    end
    table.sort(out, function(a, b) return a.Income < b.Income end)
    return out
end

local function doSell()
    local list = sellCandidates()
    for i, item in ipairs(list) do
        if i > 12 then break end
        if not inv("Plot_SellAnimal", item.Id).Ok then break end
        task.wait(0.12)
    end
    return #list
end

-- ================================================================
-- Upgrade / shop
-- ================================================================
local function doStand()
    local nextStand = StandsConfig.Get(standLevel() + 1)
    if not nextStand then return end
    if money() < num(nextStand.Price) + Config.reserve then return end
    local pos, look = standPos()
    if teleport(pos, look) then task.wait(1.1) end
    inv("Stand_Upgrade")
    task.wait(0.7)
end

local function doFence()
    local nextFence = FenceConfig.Get(fenceLevel() + 1)
    if not nextFence then return end
    if money() < num(nextFence.Price) + Config.reserve then return end
    if teleport(fencePos()) then task.wait(1.1) end
    inv("Plot_UpgradeFence")
    task.wait(0.7)
end

local function doFood()
    local best = bestFood()
    local nextFood = FoodsConfig.Get(best + 1)
    if nextFood and money() >= num(nextFood.Price) + Config.reserve then
        if teleport(shopPos()) then task.wait(1.0) end
        if inv("Shop_Buy", best + 1).Ok then
            task.wait(0.3)
            best = bestFood()
        end
    end
    if num(DC:Get("EquippedFood")) ~= best then
        inv("Shop_Equip", best)
    end
end

-- ================================================================
-- Throw
-- ================================================================
local function stopTraining()
    if isTraining() then
        inv("Training_Stop")
        task.wait(0.6)
    end
end

local lastThrowModel = "-"
local lastThrowArea = 0

local function doThrow()
    stopTraining()
    local started = false
    for attempt = 1, 5 do
        if not Config.autoThrow then return false end
        teleport(linePos())
        task.wait(attempt == 1 and 1.2 or 0.7)
        local start = inv("Throw_Start")
        if start.Ok then started = true; break end
        if start.Reason == "Busy" then
            task.wait(3)
        elseif start.Reason == "Cooldown" then
            task.wait(1.8)
        else
            task.wait(0.9)
        end
    end
    if not started then return false end

    local resolved = inv("Throw_Resolve", 1)
    if not resolved.Ok then
        inv("Throw_Cancel")
        task.wait(1.2)
        return false
    end
    lastThrowModel = tostring(resolved.ModelName or "-")
    lastThrowArea = num(resolved.AreaIndex)

    local flight = num(resolved.FlightTime) > 0 and num(resolved.FlightTime) or 2
    task.wait(flight + 0.25)
    inv("Throw_Complete")
    task.wait(GameConfig.Throw.Cooldown + 0.2)
    return true
end

-- ================================================================
-- Train
-- ================================================================
local function doTrain(duration)
    local startedAt = os.clock()
    if not isTraining() then
        teleport(trainPos())
        task.wait(1.1)
        inv("Training_Start")
        task.wait(0.6)
        if not isTraining() then
            inv("Training_Start")
            task.wait(0.6)
        end
    end
    while os.clock() - startedAt < duration do
        local mode = Config.farmMode
        if not Config.autoTrain or (mode ~= "Train Only" and mode ~= "Both") then break end
        if not isTraining() then
            teleport(trainPos())
            task.wait(0.9)
            inv("Training_Start")
        end
        task.wait(0.3)
    end
    inv("Training_Stop")
    task.wait(0.5)
end

--Bonus bubbles are server-timed; claim instantly from the event thread.
Remotes.Event("Training_Bonus").OnClientEvent:Connect(function(standId)
    if not Config.autoBonus then return end
    if not Config.autoTrain and Config.farmMode ~= "Both" then return end
    inv("Training_TapBonus", standId)
end)

-- ================================================================
-- Anti AFK
-- ================================================================
LP.Idled:Connect(function()
    if not Config.antiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ================================================================
-- UI
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Throw Food For Animals",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Throw Food For Animals",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then v:Destroy() end
    end
end)

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "crosshair", Subtitle = "Throw & Train" })
local FarmSub = FarmTab:AddSubTab("Features")

FarmSub:AddSection("Throws")
FarmSub:AddToggle({
    Name = "Auto Perfect Throw",
    Flag = "tffa_throw",
    Default = false,
    Callback = function(v) Config.autoThrow = v end,
})

FarmSub:AddSection("Training")
FarmSub:AddToggle({
    Name = "Auto Train",
    Flag = "tffa_train",
    Default = false,
    Callback = function(v) Config.autoTrain = v end,
})
FarmSub:AddToggle({
    Name = "Auto Tap Bonus (x2)",
    Flag = "tffa_bonus",
    Default = true,
    Callback = function(v) Config.autoBonus = v end,
})

FarmSub:AddSection("Farm Mode")
FarmSub:AddDropdown({
    Name = "Mode",
    Flag = "tffa_mode",
    Options = { "Throw Only", "Train Only" },
    Default = "Throw Only",
    Callback = function(v) Config.farmMode = v end,
})
FarmSub:AddSlider({
    Name = "Train Time",
    Flag = "tffa_traintime",
    Min = 10,
    Max = 300,
    Default = 45,
    Suffix = "s",
    Callback = function(v) Config.trainTime = v end,
})
local statusLabel = FarmSub:AddLabel({ Text = "Idle" })

local AnimalsTab = Window:AddTab({ Name = "Animals", Icon = "inventory", Subtitle = "Place & Sell" })
local AnimalsSub = AnimalsTab:AddSubTab("Features")

AnimalsSub:AddSection("Plot")
AnimalsSub:AddToggle({
    Name = "Auto Place Best",
    Flag = "tffa_place",
    Default = false,
    Callback = function(v) Config.autoPlace = v end,
})

AnimalsSub:AddSection("Auto Sell (unplaced)")
AnimalsSub:AddToggle({
    Name = "Auto Sell",
    Flag = "tffa_sell",
    Default = false,
    Callback = function(v) Config.autoSell = v end,
})
do
    local rarities = { "Off" }
    for _, name in ipairs(rarityNames()) do rarities[#rarities + 1] = name end
    AnimalsSub:AddDropdown({
        Name = "Sell Rarity",
        Flag = "tffa_sellrarity",
        Options = rarities,
        Default = "Off",
        Callback = function(v)
            Config.sellRarityIdx = v == "Off" and 0 or rarityIndex(v)
        end,
    })
end
do
    local labels = { "Off", "10K", "100K", "1M", "10M", "100M", "1B", "10B", "100B", "1T", "10T", "100T", "1Qa" }
    local values = { 0, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11, 1e12, 1e13, 1e14, 1e15 }
    AnimalsSub:AddDropdown({
        Name = "Sell Below Income",
        Flag = "tffa_sellincome",
        Options = labels,
        Default = "Off",
        Callback = function(v)
            for i, label in ipairs(labels) do
                if label == v then Config.sellIncome = values[i]; return end
            end
            Config.sellIncome = 0
        end,
    })
end
AnimalsSub:AddToggle({
    Name = "Keep Mutated",
    Flag = "tffa_keepmut",
    Default = true,
    Callback = function(v) Config.keepMutated = v end,
})
AnimalsSub:AddButton({
    Name = "Sell Now",
    Callback = function()
        local n = doSell()
        Library:Notify({ Title = "Auto Sell", Content = "Sold " .. tostring(n) .. " animal(s)", Duration = 4 })
    end,
})

local UpgradeTab = Window:AddTab({ Name = "Upgrades", Icon = "coin", Subtitle = "Shop" })
local UpgradeSub = UpgradeTab:AddSubTab("Features")

UpgradeSub:AddSection("Training Bar & Plot")
UpgradeSub:AddToggle({
    Name = "Auto Upgrade Training Bar",
    Flag = "tffa_stand",
    Default = false,
    Callback = function(v) Config.autoStand = v end,
})
UpgradeSub:AddToggle({
    Name = "Auto Upgrade Plot (Fence)",
    Flag = "tffa_fence",
    Default = false,
    Callback = function(v) Config.autoFence = v end,
})

UpgradeSub:AddSection("Food")
UpgradeSub:AddToggle({
    Name = "Auto Buy Food",
    Flag = "tffa_food",
    Default = false,
    Callback = function(v) Config.autoFood = v end,
})
do
    local labels = { "Off", "100K", "1M", "10M", "100M", "1B", "10B", "100B", "1T", "10T", "100T", "1Qa" }
    local values = { 0, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11, 1e12, 1e13, 1e14, 1e15 }
    UpgradeSub:AddDropdown({
        Name = "Money Reserve",
        Flag = "tffa_reserve",
        Options = labels,
        Default = "Off",
        Callback = function(v)
            for i, label in ipairs(labels) do
                if label == v then Config.reserve = values[i]; return end
            end
            Config.reserve = 0
        end,
    })
end

local MiscTab = Window:AddTab({ Name = "Misc", Icon = "settings", Subtitle = "Utility" })
local MiscSub = MiscTab:AddSubTab("Features")
MiscSub:AddSection("Utility")
MiscSub:AddToggle({
    Name = "Anti AFK",
    Flag = "tffa_afk",
    Default = true,
    Callback = function(v) Config.antiAfk = v end,
})

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Flag = "tffa_configdrop",
    Callback = function(v) selectedConfig = v end,
})

local function refreshConfigList()
    local configs = Library:ListConfigs()
    configDropdown:SetOptions(configs)
end

local configInput = ConfigSub:AddInput({
    Name = "Config Name",
    Flag = "tffa_configname",
    PlaceholderText = "Enter config name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Callback = function()
        local name = configInput.Value
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

refreshConfigList()

-- ================================================================
-- Worker
-- ================================================================
local phase = "throw"
local lastPlace, lastSellCheck, lastFood, lastStand, lastFence, lastStatus = 0, 0, 0, 0, 0, 0

task.spawn(function()
    pcall(function() DC:WaitForReady() end)
    while rawget(_G, _G_TOMB) ~= true do
        local now = os.clock()

        if Config.autoFood and now - lastFood > 6 then
            lastFood = now
            doFood()
        end
        if Config.autoStand and now - lastStand > 8 then
            lastStand = now
            doStand()
        end
        if Config.autoFence and now - lastFence > 8 then
            lastFence = now
            doFence()
        end
        if Config.autoPlace and now - lastPlace > 8 then
            lastPlace = now
            inv("Plot_EquipBest")
        end
        if Config.autoSell and now - lastSellCheck > 8 then
            lastSellCheck = now
            doSell()
        end

        local mode = Config.farmMode
        if mode == "Train Only" then
            if Config.autoTrain then
                if now - lastStatus > 0.5 then
                    lastStatus = now
                    statusLabel:Set("Training")
                end
                doTrain(1e9)
            else
                task.wait(0.4)
            end
        else
            if Config.autoThrow then
                lastStatus = now
                statusLabel:Set("Throwing Â· perfect power")
                local okThrow = doThrow()
                statusLabel:Set(okThrow and ("Caught " .. lastThrowModel .. " Â· area " .. tostring(lastThrowArea)) or "Throw failed")
            else
                if now - lastStatus > 0.5 then
                    lastStatus = now
                    statusLabel:Set("Idle")
                end
                task.wait(0.4)
            end
        end
    end
end)
