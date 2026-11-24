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
            brand = "Build and Kill Zombies",
            guiName = "BuildKillZombiesKeyGate",
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

-- "â­ Distance" / "Distance" on the leaderstats, as a plain number
local function cashDistance()
    local ls = LP:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local d = ls:FindFirstChild("â­ Distance") or ls:FindFirstChild("Distance")
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
    local cv = ls:FindFirstChild("ðŸ’µ Cash") or ls:FindFirstChild("Cash")
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
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"))()
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
                local cash = ls:FindFirstChild("ðŸ’µ Cash") or ls:FindFirstChild("Cash")
                if cash then labelCash:Set("Cash: " .. tostring(cash.Value)) end
                local dist = ls:FindFirstChild("â­ Distance") or ls:FindFirstChild("Distance")
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
