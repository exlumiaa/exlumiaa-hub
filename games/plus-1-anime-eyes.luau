if tostring(game.GameId) ~= "10770933473" then return end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _animeEyesTomb"
local _G_ALIVE = "_ _animeEyesAlive"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

-- ================================================================
-- KEY SYSTEM (Panda Universal Script Library)
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_animeeyes.txt"
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
            brand = "+1 Anime Eyes",
            guiName = "AnimeEyesKeyGate",
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

Library.ConfigFolder = "exlumiaa"

local Config = {
    autoTrain = false,
    autoClicker = false,
    autoAttack = false,
    autoRebirth = false,
    autoEyes = false,
    autoWin = false,
    autoClaims = false,
    autoQuests = false,
    autoRewards = false,
    autoBubble = false,
    autoBoss = false,
    autoExit = false,
    autoEggs = false,
    autoPets = false,
    autoFuse = false,
    autoAura = false,
}
rawset(_G, "_animeEyesConfig", Config)

local Shared = ReplicatedStorage:WaitForChild("Shared", 30)
local ConfigFolder = Shared and Shared:WaitForChild("Config", 30)

local function req(name)
    local m = ConfigFolder and ConfigFolder:FindFirstChild(name)
    if not m then return nil end
    local ok, ret = pcall(require, m)
    return ok and ret or nil
end

local EyesCfg = req("Eyes")
local WorldCfg = req("World")
local AbilitiesCfg = req("Abilities")
local CodesCfg = req("Codes")
local RewardsCfg = req("Rewards")
local PetsCfg = req("Pets")
local AurasCfg = req("Auras")
local FuseCfg = req("Fuse")

local FuseLogic = nil
pcall(function()
    FuseLogic = require(Shared.Logic.Fuse)
end)

local MenusMod = nil
pcall(function()
    MenusMod = require(LP.PlayerScripts.Client.Menus)
end)

local trainCfgCache = {}
local function trainingFor(world)
    local key = world == 1 and "Training" or ("Training" .. tostring(world))
    if trainCfgCache[key] == nil then trainCfgCache[key] = req(key) or false end
    return trainCfgCache[key] or nil
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
local function netEvent(name)
    return Remotes and Remotes:FindFirstChild(name)
end
local function netFunc(name)
    return Remotes and Remotes:FindFirstChild(name)
end

local function attr(key, default)
    local v = LP:GetAttribute(key)
    if v == nil then return default end
    return v
end

local function jsonTable(key)
    local raw = LP:GetAttribute(key)
    if type(raw) == "table" then return raw end
    if type(raw) ~= "string" or raw == "" then return {} end
    local ok, v = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok and type(v) == "table" then return v end
    return {}
end

local function getChar()
    local c = LP.Character
    if not c then return nil, nil, nil end
    return c, c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
end

local function pivotTo(pos)
    local _, hrp, hum = getChar()
    if hrp and hum and hum.Health > 0 then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function spotPosition(world, index)
    local mapName = world == 1 and "Map" or ("Map" .. tostring(world))
    local map = Workspace:FindFirstChild(mapName)
    local hub = map and map:FindFirstChild("Hub")
    local model = hub and hub:FindFirstChild("Training" .. tostring(index))
    if model then return model:GetPivot().Position end
    if WorldCfg and WorldCfg.TRAINING and WorldCfg.TRAINING[index] then
        local origin = Vector3.zero
        if WorldCfg.origin then origin = WorldCfg.origin(world) end
        return origin + WorldCfg.TRAINING[index]
    end
    return nil
end

local function eggSpotPosition(world, index)
    local mapName = world == 1 and "Map" or ("Map" .. tostring(world))
    local map = Workspace:FindFirstChild(mapName)
    local hub = map and map:FindFirstChild("Hub")
    local model = hub and (hub:FindFirstChild("Egg" .. tostring(index)) or hub:FindFirstChild("EggPlatform"))
    return model and model:GetPivot().Position or nil
end

local function bestTrainingSpot()
    local world = attr("World", 1)
    local list = trainingFor(world)
    if not list then return nil end
    local rebirths = attr("Rebirths", 0)
    local idx, mult = nil, 0
    for i, s in ipairs(list) do
        if not s.pass and (s.rebirths or 0) <= rebirths and (s.mult or 0) > mult then
            idx, mult = i, s.mult
        end
    end
    return idx, mult, world
end

local EnemiesMod = nil
local function getEnemies()
    if EnemiesMod then return EnemiesMod end
    local ok, m = pcall(function()
        return require(LP.PlayerScripts.Client.Enemies)
    end)
    if ok then EnemiesMod = m end
    return EnemiesMod
end

-- Auto Train: stand on the best unlocked training pad and fire Train at 10/s.
task.spawn(function()
    local lastPivot = 0
    while true do
        task.wait(0.1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoTrain then
            local _, hrp, hum = getChar()
            if hrp and hum and hum.Health > 0 and not attr("InStages", false) and not attr("InWave", false) then
                local idx = bestTrainingSpot()
                if idx then
                    local now = os.clock()
                    if attr("TrainSpot", 0) ~= idx or now - lastPivot > 8 then
                        local pos = spotPosition(attr("World", 1), idx)
                        if pos then
                            pivotTo(pos)
                            lastPivot = now
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Clicker: unlimited Train clicks at the server's 10/s rate (the game's auto is timed).
task.spawn(function()
    while true do
        task.wait(0.1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoClicker or (Config.autoTrain and not attr("InStages", false) and not attr("InWave", false)) then
            local _, hrp, hum = getChar()
            if hrp and hum and hum.Health > 0 then
                local T = netEvent("Train")
                if T then pcall(function() T:FireServer() end) end
            end
        end
    end
end)

-- Auto Attack: nearest enemy in 360 degrees, eye attack + E/R skills.
task.spawn(function()
    local nextAtk = 0
    local nextSkill = {}
    while true do
        task.wait(0.05)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoAttack then
            local _, hrp, hum = getChar()
            if hrp and hum and hum.Health > 0 then
                local Enemies = getEnemies()
                if Enemies and Enemies.list then
                    local target, best = nil, math.huge
                    for _, e in ipairs(Enemies.list()) do
                        local d = (e.pos - hrp.Position).Magnitude
                        if d < best then target, best = e, d end
                    end
                    if target and best <= 75 then
                        local now = os.clock()
                        if now >= nextAtk then
                            nextAtk = now + 0.3
                            local cast = netEvent("Cast")
                            if cast then pcall(function() cast:FireServer("attack", target.pos, target.id) end) end
                            if not Config.autoClicker then
                                local T = netEvent("Train")
                                if T then pcall(function() T:FireServer() end) end
                            end
                        end
                        local eye = EyesCfg and EyesCfg.byId and EyesCfg.byId[attr("Eye", "sharingan")]
                        if eye and AbilitiesCfg and AbilitiesCfg.byId then
                            for _, skillId in ipairs({eye.skillE, eye.skillR}) do
                                local ab = AbilitiesCfg.byId[skillId]
                                if ab and now >= (nextSkill[skillId] or 0) then
                                    nextSkill[skillId] = now + (ab.cooldown or 5)
                                    local cast = netEvent("Cast")
                                    if cast then pcall(function() cast:FireServer(skillId, target.pos, target.id) end) end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Rebirth: invoke when the level requirement is met.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(0.5)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoRebirth then
            local now = os.clock()
            if now >= nextTry and attr("Level", 0) >= attr("RebirthLevel", 10) then
                nextTry = now + 3
                task.spawn(function()
                    local rf = netFunc("Rebirth")
                    if rf then pcall(function() rf:InvokeServer() end) end
                end)
            end
        end
    end
end)

-- Auto Eye: unlock every affordable eye and equip the best multiplier owned.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoEyes and EyesCfg and EyesCfg.list and os.clock() >= nextTry then
            nextTry = os.clock() + 2
            local owned = {}
            local ok, decoded = pcall(function()
                return HttpService:JSONDecode(attr("Eyes", "{}"))
            end)
            if ok and type(decoded) == "table" then
                for id in pairs(decoded) do owned[id] = true end
            end
            local world = attr("World", 1)
            local wins = attr("TotalWins", 0)
            for _, e in ipairs(EyesCfg.list) do
                if not owned[e.id] and not e.pass and not e.boss and (e.world or 1) <= world and (e.wins or 0) <= wins then
                    local un = netEvent("UnlockEye")
                    if un then
                        pcall(function() un:FireServer(e.id) end)
                        owned[e.id] = true
                        task.wait(0.25)
                    end
                end
            end
            local bestId, bestMult = nil, attr("EyeMult", 1)
            if EyesCfg.byId then
                for id in pairs(owned) do
                    local e = EyesCfg.byId[id]
                    if e and not e.pass and (e.world or 1) <= world and (e.mult or 0) > bestMult then
                        bestId, bestMult = id, e.mult
                    end
                end
            end
            if bestId then
                local eq = netEvent("Equip")
                if eq then pcall(function() eq:FireServer(bestId) end) end
            end
        end
    end
end)

-- Auto Claim: daily and group rewards.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoClaims and os.clock() >= nextTry then
            nextTry = os.clock() + 60
            task.spawn(function()
                local daily = netFunc("ClaimDaily")
                if daily then pcall(function() daily:InvokeServer() end) end
                local group = netFunc("ClaimGroup")
                if group then pcall(function() group:InvokeServer() end) end
            end)
        end
    end
end)

-- Auto Quest: claim daily/weekly quest slots.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoQuests and os.clock() >= nextTry then
            nextTry = os.clock() + 30
            task.spawn(function()
                local quest = netFunc("ClaimQuest")
                if quest then
                    for _, kind in ipairs({"daily", "weekly"}) do
                        for slot = 1, 5 do
                            pcall(function() quest:InvokeServer(kind, slot) end)
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Reward: time-based gifts from the Rewards menu (5/15/60 min).
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoRewards and RewardsCfg and os.clock() >= nextTry then
            nextTry = os.clock() + 5
            local rf = netFunc("ClaimReward")
            if rf then
                local claimed = {}
                for i, token in ipairs(string.split(attr("RewardsClaimed", ""), ",")) do
                    claimed[i] = tonumber(token) or 0
                end
                local now = Workspace:GetServerTimeNow()
                local elapsed = now - attr("JoinedAt", now)
                for i, r in ipairs(RewardsCfg) do
                    local c = claimed[i] or 0
                    local total = math.min(r.max or 0, math.floor(elapsed / ((r.minutes or 1) * 60)))
                    for _ = 1, total - c do
                        local ok, granted = pcall(function() return rf:InvokeServer(i) end)
                        if not ok or granted ~= true then break end
                        task.wait(0.25)
                    end
                end
            end
        end
    end
end)

-- Auto Bubble: free multiplier bubbles spawn while training; claim them on arrival.
task.spawn(function()
    local pop = netEvent("Pops")
    if not pop then return end
    local conn
    conn = pop.OnClientEvent:Connect(function(kind, data)
        if rawget(_G, _G_TOMB) then
            if conn then conn:Disconnect() end
            return
        end
        if not Config.autoBubble or kind ~= "bubble" or type(data) ~= "table" then return end
        if data.kind ~= "free" or type(data.id) ~= "number" then return end
        task.delay(0.2, function()
            if rawget(_G, _G_TOMB) or not Config.autoBubble then return end
            pcall(function() pop:FireServer("claim", data.id) end)
        end)
    end)
end)

-- Auto Win: keep the game's stage auto-win enabled.
task.spawn(function()
    while true do
        task.wait(3)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoWin and attr("AutoWinOn", false) ~= true then
            local ev = netEvent("AutoWin")
            if ev then pcall(function() ev:FireServer("on", true) end) end
        end
    end
end)

-- Auto Boss: join the world boss while it is waiting or fighting.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(2)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoBoss and os.clock() >= nextTry then
            local phase = Workspace:GetAttribute("BossPhase")
            if phase == "coming" or phase == "wait" or phase == "fight" then
                nextTry = os.clock() + 15
                local inArena = false
                local arena = Workspace:FindFirstChild("BossArena")
                local _, hrp = getChar()
                if arena and hrp then
                    local ok, pos = pcall(function() return arena:GetPivot().Position end)
                    if ok and (hrp.Position - pos).Magnitude < 500 then inArena = true end
                end
                if not inArena then
                    local ev = netEvent("Boss")
                    if ev then pcall(function() ev:FireServer("join") end) end
                end
            end
        end
    end
end)

-- Auto Exit Bonus: claim the playtime bonus whenever it is available.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(2)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoExit and attr("ExitBonus", true) == false and os.clock() >= nextTry then
            nextTry = os.clock() + 10
            local rf = netFunc("ExitBonus")
            if rf then pcall(function() rf:InvokeServer() end) end
        end
    end
end)

-- Auto Aura: equip the highest multiplier aura unlocked by total wins.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoAura and AurasCfg and AurasCfg.list and os.clock() >= nextTry then
            nextTry = os.clock() + 4
            local wins = attr("TotalWins", 0)
            local owned = jsonTable("OwnedAuras")
            local current = attr("Aura", "")
            local bestId, bestMult = nil, 0
            for _, a in ipairs(AurasCfg.list) do
                local unlocked = owned[a.id] == true or (not a.exclusive and (a.trophies or 0) <= wins)
                if unlocked and (a.mult or 0) > bestMult then
                    bestId, bestMult = a.id, a.mult
                end
            end
            if bestId and bestId ~= current then
                local rf = netFunc("EquipAura")
                if rf then pcall(function() rf:InvokeServer(bestId) end) end
            end
        end
    end
end)

-- Auto Eggs: hatch the best egg affordable in the current world.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(0.5)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoEggs and PetsCfg and PetsCfg.eggs and os.clock() >= nextTry then
            local owned = jsonTable("Pets")
            local ownedCount = 0
            for _ in pairs(owned) do ownedCount += 1 end
            local space = attr("PetSpace", PetsCfg.SPACE or 30)
            if ownedCount < space then
                local world = attr("World", 1)
                local chakra = attr("Chakra", 0)
                local eggs = PetsCfg.eggsFor and PetsCfg.eggsFor(world) or PetsCfg.eggs
                local best, bestIndex, bestCost = nil, nil, -1
                for i, egg in ipairs(eggs) do
                    if not egg.product and (egg.cost or 0) > 0 and egg.cost <= chakra and egg.cost > bestCost then
                        best, bestIndex, bestCost = egg, i, egg.cost
                    end
                end
                if best then
                    nextTry = os.clock() + 1.2
                    local pos = eggSpotPosition(world, bestIndex)
                    if pos then
                        pivotTo(pos)
                        task.wait(0.8)
                    end
                    -- The egg pad only offers Hatch 1 or Hatch 3, never 2.
                    local n = if space - ownedCount >= 3 then 3 else 1
                    local rf = netFunc("PetAction")
                    if rf then pcall(function() rf:InvokeServer("hatch", {egg = best.id, count = n}) end) end
                    task.wait(1.0)
                    if MenusMod then
                        if type(MenusMod.leaveEgg) == "function" then pcall(MenusMod.leaveEgg) end
                        if type(MenusMod.current) == "function" and MenusMod.current() == "Egg" and type(MenusMod.close) == "function" then pcall(MenusMod.close) end
                    end
                end
            end
        end
    end
end)

-- Auto Pets: keep the highest multiplier pets equipped.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoPets and PetsCfg and PetsCfg.byId and os.clock() >= nextTry then
            nextTry = os.clock() + 3
            local pets = jsonTable("Pets")
            local tiers = jsonTable("PetTiers")
            local equipped = jsonTable("Equipped")
            local world = attr("World", 1)
            local maxSlots = attr("EquipMax", 3)
            local ranked = {}
            for uid in pairs(pets) do
                local mult = 0
                if FuseLogic then
                    mult = FuseLogic.multOf(pets, tiers, uid, world) or 0
                else
                    local p = PetsCfg.byId[pets[uid]]
                    mult = p and p.mult or 0
                end
                ranked[#ranked + 1] = {uid = uid, mult = mult}
            end
            table.sort(ranked, function(a, b) return a.mult > b.mult end)
            local desired = {}
            for i = 1, math.min(maxSlots, #ranked) do desired[ranked[i].uid] = true end
            local current = {}
            for _, uid in ipairs(equipped) do current[uid] = true end
            local rf = netFunc("PetAction")
            if rf then
                for _, uid in ipairs(equipped) do
                    if not desired[uid] then
                        pcall(function() rf:InvokeServer("unequip", uid) end)
                        task.wait(0.15)
                    end
                end
                for i = 1, math.min(maxSlots, #ranked) do
                    local uid = ranked[i].uid
                    if not current[uid] then
                        pcall(function() rf:InvokeServer("equip", uid) end)
                        task.wait(0.15)
                    end
                end
            end
        end
    end
end)

-- Auto Fuse: fuse the best group of four matching pets.
task.spawn(function()
    local nextTry = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        if Config.autoFuse and FuseLogic and FuseCfg and os.clock() >= nextTry then
            nextTry = os.clock() + 4
            local groups = FuseLogic.groups(jsonTable("Pets"), jsonTable("PetTiers"), jsonTable("Equipped"), attr("World", 1))
            local group = groups and groups[1]
            if group and group.uids and #group.uids == (FuseCfg.COUNT or 4) then
                local uids = {}
                for _, uid in ipairs(group.uids) do uids[#uids + 1] = tostring(uid) end
                local rf = netFunc("Fuse")
                if rf then
                    local ok, ret = pcall(function() return rf:InvokeServer("fuse", uids) end)
                    if ok and ret then nextTry = os.clock() + 6 end
                end
            end
        end
    end
end)

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "+1 Anime Eyes",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 Anime Eyes",
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

local FarmTab = Window:AddTab({Name = "Farm", Icon = "crosshair", Subtitle = "Auto"})
local FarmSub = FarmTab:AddSubTab("Features")

FarmSub:AddSection("Training")
FarmSub:AddToggle({
    Name = "Auto Train",
    Flag = "ae_autotrain",
    Default = false,
    Callback = function(v)
        Config.autoTrain = v
    end,
})
FarmSub:AddToggle({
    Name = "Auto Clicker",
    Flag = "ae_autoclicker",
    Default = false,
    Callback = function(v)
        Config.autoClicker = v
    end,
})
FarmSub:AddToggle({
    Name = "Auto Claim Bubbles",
    Flag = "ae_autobubble",
    Default = false,
    Callback = function(v)
        Config.autoBubble = v
    end,
})
do
    local idx, mult = bestTrainingSpot()
    FarmSub:AddLabel({
        Text = if idx then "Best spot now: #" .. tostring(idx) .. " (x" .. tostring(mult) .. ")" else "Best spot: none",
    })
end

FarmSub:AddSection("Combat")
FarmSub:AddToggle({
    Name = "Auto Attack (360)",
    Flag = "ae_autoattack",
    Default = false,
    Callback = function(v)
        Config.autoAttack = v
    end,
})
FarmSub:AddToggle({
    Name = "Auto Boss",
    Flag = "ae_autoboss",
    Default = false,
    Callback = function(v)
        Config.autoBoss = v
    end,
})

FarmSub:AddSection("Progression")
FarmSub:AddToggle({
    Name = "Auto Rebirth",
    Flag = "ae_autorebirth",
    Default = false,
    Callback = function(v)
        Config.autoRebirth = v
    end,
})
FarmSub:AddToggle({
    Name = "Auto Unlock + Equip Eyes",
    Flag = "ae_autoeyes",
    Default = false,
    Callback = function(v)
        Config.autoEyes = v
    end,
})
FarmSub:AddToggle({
    Name = "Auto Win Stages",
    Flag = "ae_autowin",
    Default = false,
    Callback = function(v)
        Config.autoWin = v
        local ev = netEvent("AutoWin")
        if ev then pcall(function() ev:FireServer("on", v) end) end
    end,
})

local LoadoutTab = Window:AddTab({Name = "Loadout", Icon = "inventory", Subtitle = "Aura & Pets"})
local LoadoutSub = LoadoutTab:AddSubTab("Features")

LoadoutSub:AddSection("Aura")
LoadoutSub:AddToggle({
    Name = "Auto Equip Best Aura",
    Flag = "ae_autoaura",
    Default = false,
    Callback = function(v)
        Config.autoAura = v
    end,
})

LoadoutSub:AddSection("Pets")
LoadoutSub:AddToggle({
    Name = "Auto Hatch Eggs",
    Flag = "ae_autoeggs",
    Default = false,
    Callback = function(v)
        Config.autoEggs = v
    end,
})
LoadoutSub:AddToggle({
    Name = "Auto Equip Best Pets",
    Flag = "ae_autopets",
    Default = false,
    Callback = function(v)
        Config.autoPets = v
    end,
})
LoadoutSub:AddToggle({
    Name = "Auto Fuse Pets",
    Flag = "ae_autofuse",
    Default = false,
    Callback = function(v)
        Config.autoFuse = v
    end,
})

local ClaimsTab = Window:AddTab({Name = "Claims", Icon = "gift", Subtitle = "Rewards"})
local ClaimsSub = ClaimsTab:AddSubTab("Features")

ClaimsSub:AddSection("Quests & Rewards")
ClaimsSub:AddToggle({
    Name = "Auto Claim Quests",
    Flag = "ae_autoquests",
    Default = false,
    Callback = function(v)
        Config.autoQuests = v
    end,
})
ClaimsSub:AddToggle({
    Name = "Auto Claim Rewards",
    Flag = "ae_autorewards",
    Default = false,
    Callback = function(v)
        Config.autoRewards = v
    end,
})
ClaimsSub:AddToggle({
    Name = "Auto Claim Daily/Group",
    Flag = "ae_autoclaim",
    Default = false,
    Callback = function(v)
        Config.autoClaims = v
    end,
})
ClaimsSub:AddToggle({
    Name = "Auto Exit Bonus",
    Flag = "ae_autoexit",
    Default = false,
    Callback = function(v)
        Config.autoExit = v
    end,
})

ClaimsSub:AddSection("Codes")
ClaimsSub:AddButton({
    Name = "Redeem All Codes",
    Primary = true,
    Callback = function()
        if not CodesCfg or not CodesCfg.list then
            Window:Notify({Title = "Codes", Content = "Code list not found!", Type = "error", Duration = 3})
            return
        end
        local rf = netFunc("RedeemCode")
        if not rf then
            Window:Notify({Title = "Codes", Content = "RedeemCode remote missing!", Type = "error", Duration = 3})
            return
        end
        local sent = 0
        for _, c in ipairs(CodesCfg.list) do
            if c.live ~= false and c.code then
                pcall(function() rf:InvokeServer(c.code) end)
                sent += 1
                task.wait(0.7)
            end
        end
        Window:Notify({Title = "Codes", Content = "Tried " .. tostring(sent) .. " codes.", Type = "success", Duration = 4})
    end,
})

local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})
local ConfigSub = SettingsTab:AddSubTab("Config")
local HopSub = SettingsTab:AddSubTab("Server Hop")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "ae_config_selected",
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
    Flag = "ae_config_name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            Window:Notify({Title = "Config", Content = "Enter a name first!", Type = "warning", Duration = 3})
            return
        end
        local ok = Library:SaveConfig(name)
        if ok then
            refreshConfigList()
            Window:Notify({Title = "Config", Content = "Saved: " .. name, Type = "success", Duration = 3})
        else
            Window:Notify({Title = "Config", Content = "Save failed!", Type = "error", Duration = 3})
        end
    end,
})

ConfigSub:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3})
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            Window:Notify({Title = "Config", Content = "Loaded: " .. selectedConfig, Type = "success", Duration = 3})
        else
            Window:Notify({Title = "Config", Content = "Failed to load!", Type = "error", Duration = 3})
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3})
            return
        end
        Library:DeleteConfig(selectedConfig)
        local old = selectedConfig
        selectedConfig = ""
        refreshConfigList()
        Window:Notify({Title = "Config", Content = "Deleted: " .. old, Type = "info", Duration = 3})
    end,
})

ConfigSub:AddDivider()
ConfigSub:AddSection("Info")
ConfigSub:AddLabel({Text = "by Exlumiaa Hub v1"})
ConfigSub:AddLabel({Text = "Toggle Menu: RightShift"})
ConfigSub:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        pcall(setclipboard, "discord.gg/exlumiaa")
        Window:Notify({Title = "Discord", Content = "Invite copied!", Type = "success", Duration = 3})
    end,
})

HopSub:AddSection("Server Hop")
HopSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        Window:Notify({Title = "Server Hop", Content = "Finding a new server...", Type = "info", Duration = 3})
        local ok, err = pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        end)
        if not ok then
            Window:Notify({Title = "Server Hop", Content = "Failed: " .. tostring(err), Type = "error", Duration = 5})
        end
    end,
})

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

print("[ExlumiaaHub] +1 Anime Eyes Hub v1 loaded!")
