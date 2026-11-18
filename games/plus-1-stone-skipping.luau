if tostring(game.GameId) ~= "10765298801" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _ssTomb"
local _G_GEN = "_ _ssGen"

do
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_GEN, (rawget(_G, _G_GEN) or 0) + 1)
end

local _gen = rawget(_G, _G_GEN)
local function _alive()
    return rawget(_G, _G_GEN) == _gen
end

local CONNS = {}
do
    local old = rawget(_G, "_ _ssConns")
    if type(old) == "table" then
        for _, c in ipairs(old) do
            pcall(function() c:Disconnect() end)
        end
    end
    rawset(_G, "_ _ssConns", CONNS)
end

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Oxidelib" or gui.Name == "ExlumiaaHub" or gui.Name == "Obsidian") then
                gui:Destroy()
            end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Oxidelib" or gui.Name == "ExlumiaaHub" or gui.Name == "Obsidian") then
                gui:Destroy()
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
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_stoneskipping.txt"
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
            brand = "+1 Stone Skipping",
            guiName = "StoneSkipKeyGate",
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
                if not _alive() then
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

local Config = {
    autoThrow = false,
    autoPractice = false,
    autoRebirth = false,
    autoGift = false,
    autoPotion = false,
    autoHatch = false,
    hatchEgg = "Any",
}
rawset(_G, "_stoneSkipConfig", Config)

local notifyHub

-- ================================================================
-- CORE: remote, API table, state
-- ================================================================
local net = ReplicatedStorage:WaitForChild("SkippingNetwork", 10)
local ev = net and net:WaitForChild("Event", 5)

local State = {}
local lastReject = nil
local lastPracticeZone = nil

if ev and ev:IsA("RemoteEvent") then
    CONNS[#CONNS + 1] = ev.OnClientEvent:Connect(function(action, payload)
        if action == "State" and type(payload) == "table" then
            for k, v in pairs(payload) do
                State[k] = v
            end
        elseif type(payload) == "table" then
            if action == "Notice" then
                if payload.Success == false then
                    lastReject = { msg = tostring(payload.Message or ""), t = os.clock() }
                end
            elseif action == "PracticeStarted" and payload.UserId == LP.UserId then
                State.Activity = "Practice"
                lastPracticeZone = payload.ZoneId
            elseif action == "PracticeStopped" and payload.UserId == LP.UserId then
                State.Activity = "Idle"
            elseif action == "GiftRewardResult" and payload.Success then
                if notifyHub then
                    notifyHub({ Title = "+1 Stone Skipping", Content = tostring(payload.Message or "Reward claimed!"), Type = "success", Duration = 3 })
                end
            end
        end
    end)
end

local rq = net and net:FindFirstChild("Request")
local lastSyncReq = 0
local function requestSync()
    if not rq or os.clock() - lastSyncReq < 6 then return end
    lastSyncReq = os.clock()
    pcall(function() rq:FireServer("Sync", nil) end)
end

local API
local function ensureAPI()
    if API and type(API.BeginThrow) == "function" then return API end
    local ok, res = pcall(function()
        return filtergc("table", { Keys = { "BeginThrow", "ClaimGift", "UsePotion", "Rebirth" } }, true)
    end)
    if ok and type(res) == "table" then
        API = res
        return API
    end
    return nil
end

requestSync()

local GameBalance, GiftRewardsMod
local function ensureMods()
    if not GameBalance then
        pcall(function() GameBalance = require(ReplicatedStorage.Shared.Config.GameBalance) end)
    end
    if not GiftRewardsMod then
        pcall(function() GiftRewardsMod = require(ReplicatedStorage.Shared.Util.GiftRewards) end)
    end
    return GameBalance ~= nil, GiftRewardsMod ~= nil
end

local WorldMapMod
local passOwned = {}
local function passOwnedOnce(id)
    local v = passOwned[id]
    if v ~= nil then return v end
    local ok, owns = pcall(function()
        return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LP.UserId, id)
    end)
    if ok and type(owns) == "boolean" then
        passOwned[id] = owns
        return owns
    end
    return false
end

local function getPracticeZones()
    if not WorldMapMod then
        local ok, m = pcall(function() return require(ReplicatedStorage.Shared.Util.WorldMap) end)
        if not ok or type(m) ~= "table" then return nil end
        WorldMapMod = m
    end
    local ok, cfg = pcall(WorldMapMod.GetConfig, LP)
    if not ok or type(cfg) ~= "table" or type(cfg.Practice) ~= "table" then return nil end
    ensureMods()
    local pr = cfg.Practice
    local passes = GameBalance and GameBalance.TrainingPasses or {}
    local list = {}
    for name, bonus in pairs(pr.ZoneBonuses or {}) do
        if type(bonus) == "number" then
            list[#list + 1] = {
                name = name,
                req = tonumber((pr.ZoneRequiredRebirths or {})[name]) or 0,
                bonus = bonus,
                passId = tonumber(passes[name]) or nil,
            }
        end
    end
    table.sort(list, function(a, b) return a.bonus > b.bonus end)
    return { worldId = tostring(cfg.Id), list = list }
end

local function getChar()
    local c = LP.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then
        return c, hrp, hum
    end
    return nil
end

local function worldRoot()
    local sw = workspace:FindFirstChild("SkippingWorlds")
    if not sw then return nil end
    local attr = LP:GetAttribute("SkippingWorld")
    if attr then
        local w = sw:FindFirstChild(attr)
        if w then return w end
    end
    local kids = sw:GetChildren()
    return kids[1]
end

local function launchZonePart()
    local w = worldRoot()
    return w and w:FindFirstChild("LaunchZone")
end

local function trainingStand(zoneName)
    local w = worldRoot()
    local tz = w and w:FindFirstChild("TrainingZones")
    local z = tz and tz:FindFirstChild(zoneName)
    if not z then return nil end
    return z:FindFirstChild("TrainingStand")
end

local function partPos(p)
    if p:IsA("BasePart") then return p.Position end
    return p:GetPivot().Position
end

local eggOptions
local function ensureEggOptions()
    if eggOptions then return eggOptions end
    local opts = { "Any" }
    local ok, Worlds = pcall(function() return require(ReplicatedStorage.Shared.Config.Worlds) end)
    if ok and type(Worlds) == "table" and type(Worlds.Definitions) == "table" then
        local seen, list = {}, {}
        for _, def in ipairs(Worlds.Definitions) do
            for _, id in ipairs(def.EggIds or {}) do
                if type(id) == "string" and not seen[id] then
                    seen[id] = true
                    list[#list + 1] = id
                end
            end
        end
        table.sort(list)
        for _, id in ipairs(list) do
            opts[#opts + 1] = id
        end
    end
    eggOptions = opts
    return opts
end

-- ================================================================
-- LOOP: AUTO THROW
-- ================================================================
task.spawn(function()
    local lastTP = 0
    while _alive() do
        if Config.autoThrow and not Config.autoPractice then
            pcall(function()
                local api = ensureAPI()
                local char, hrp = getChar()
                local lz = launchZonePart()
                if api and char and hrp and lz then
                    local pos = partPos(lz)
                    if (hrp.Position - pos).Magnitude > 6 and os.clock() - lastTP > 1 then
                        lastTP = os.clock()
                        char:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
                    end
                    if State.Activity == "Idle" then
                        api.BeginThrow()
                    end
                end
            end)
        end
        task.wait(0.4)
    end
end)

-- ================================================================
-- LOOP: AUTO PRACTICE (probe zones best -> worst for my rebirths)
-- ================================================================
task.spawn(function()
    local zonesCache = nil
    local lastPickRebirths = nil
    local notifiedZone = nil
    local notifiedFail = nil
    while _alive() do
        if Config.autoPractice and not Config.autoThrow then
            pcall(function()
                local zones = getPracticeZones()
                if not zones or #zones.list == 0 then return end
                if not zonesCache or zonesCache.worldId ~= zones.worldId then
                    zonesCache = zones
                    lastPickRebirths = nil
                end
                local reb = tonumber(State.Rebirths) or 0
                local practicing = State.Activity == "Practice"
                if practicing and reb == lastPickRebirths then return end
                local pick = nil
                for _, z in ipairs(zonesCache.list) do
                    if reb >= z.req then
                        if not z.passId or passOwnedOnce(z.passId) then
                            pick = z
                            break
                        end
                    end
                end
                if not pick then return end
                lastPickRebirths = reb
                local stand = trainingStand(pick.name)
                local char = getChar()
                if not stand or not char then return end
                local rejectBefore = lastReject
                char:PivotTo(CFrame.new(partPos(stand) + Vector3.new(0, 3, 0)))
                local t0 = os.clock()
                local rejectMsg = nil
                while os.clock() - t0 < 3 do
                    if not _alive() or not Config.autoPractice or Config.autoThrow then return end
                    if State.Activity == "Practice" then
                        local zid = lastPracticeZone or pick.name
                        if notifiedZone ~= zid then
                            notifiedZone = zid
                            if notifyHub then
                                notifyHub({ Title = "+1 Stone Skipping", Content = "Training at " .. tostring(zid), Type = "success", Duration = 3 })
                            end
                        end
                        return
                    end
                    if lastReject ~= rejectBefore then
                        rejectMsg = lastReject.msg
                    end
                    task.wait(0.3)
                end
                local failKey = pick.name .. "@" .. reb
                if notifiedFail ~= failKey then
                    notifiedFail = failKey
                    if notifyHub then
                        notifyHub({ Title = "+1 Stone Skipping", Content = "Cannot train at " .. pick.name .. (rejectMsg and (": " .. rejectMsg) or ""), Type = "warning", Duration = 4 })
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- ================================================================
-- LOOP: AUTO REBIRTH
-- ================================================================
task.spawn(function()
    local lastAttempt = 0
    local prevRebirths = tonumber(State.Rebirths) or 0
    while _alive() do
        pcall(function()
            local reb = tonumber(State.Rebirths) or 0
            if reb ~= prevRebirths then
                if reb > prevRebirths and prevRebirths > 0 and notifyHub then
                    notifyHub({ Title = "+1 Stone Skipping", Content = "Rebirth complete (x" .. reb .. ")", Type = "success", Duration = 3 })
                end
                prevRebirths = reb
            end
            if Config.autoRebirth then
                local api = ensureAPI()
                if not api then return end
                local lvl = tonumber(State.Level)
                local nextLvl = tonumber(State.NextRebirthLevel)
                local act = State.Activity
                if lvl and nextLvl and lvl >= nextLvl and (act == "Idle" or act == "Practice") and os.clock() - lastAttempt > 3 then
                    lastAttempt = os.clock()
                    api.Rebirth(reb)
                end
            end
        end)
        task.wait(2)
    end
end)

-- ================================================================
-- LOOP: AUTO CLAIM PLAYTIME REWARD
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoGift then
            pcall(function()
                local okB, okG = ensureMods()
                local api = ensureAPI()
                if not (okB and okG and api) then return end
                if type(State.GiftClaimed) ~= "table" then requestSync() return end
                local now = workspace:GetServerTimeNow()
                local count = #GameBalance.GiftRewards.Rewards
                for i = 1, count do
                    local ok, r = pcall(GiftRewardsMod.GetReward, State, i, now, GameBalance.GiftRewards)
                    if ok and r == "Ready" then
                        api.ClaimGift(i)
                        task.wait(0.5)
                    end
                end
            end)
        end
        task.wait(4)
    end
end)

-- ================================================================
-- LOOP: AUTO USE POTIONS
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoPotion then
            pcall(function()
                local api = ensureAPI()
                if not api then return end
                if type(State.Potions) ~= "table" then requestSync() return end
                local now = workspace:GetServerTimeNow()
                local boosts = State.BoostExpiresAt or {}
                for id, count in pairs(State.Potions or {}) do
                    if type(count) == "number" and count > 0 then
                        local exp = tonumber(boosts[id]) or 0
                        if now >= exp then
                            api.UsePotion(id)
                            task.wait(1.2)
                            return
                        end
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- ================================================================
-- LOOP: AUTO HATCH EGG
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoHatch then
            pcall(function()
                local api = ensureAPI()
                if not api then return end
                if type(State.Eggs) ~= "table" then requestSync() return end
                local sel = Config.hatchEgg
                if sel and sel ~= "" and sel ~= "Any" then
                    local c = tonumber(State.Eggs[sel]) or 0
                    if c > 0 then
                        local started = api.HatchInventoryEgg(sel)
                        if started then
                            task.wait(3)
                        end
                    end
                    return
                end
                for id, count in pairs(State.Eggs or {}) do
                    if type(count) == "number" and count > 0 then
                        local started = api.HatchInventoryEgg(id)
                        if started then
                            task.wait(3)
                        end
                        return
                    end
                end
            end)
        end
        task.wait(2.5)
    end
end)

-- ================================================================
-- UI
-- ================================================================
local OxidelibUrl = "https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"
local Library = loadstring(game:HttpGet(OxidelibUrl))()

Library.ConfigFolder = "exlumia/stoneskipping"

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
    for _, m in ipairs({ "AddToggle", "AddSlider", "AddDropdown", "AddMultiDropdown", "AddInput" }) do
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

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "+1 Stone Skipping",
    Title = "Exlumiaa Hub",
    Logo = 72522294315389,
    Folder = "exlumia",
    ToggleKey = Enum.KeyCode.RightShift,
    AllowMultiple = false,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 Stone Skipping",
    LoadingFooter = "by Exlumiaa Hub",
    StatusText = "Exlumiaa Hub ready",
    GuiName = "ExlumiaaHub",
})

notifyHub = function(opts)
    local ok, err = pcall(function() Window:Notify(opts) end)
    if not ok then warn("[StoneSkip] notify failed: " .. tostring(err)) end
end

local MainTab = Window:AddTab({ Name = "Main", Icon = "bolt", Subtitle = "Auto Features" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })

local AutoSub = MainTab:AddSubTab("Automation")
autosaveWrap(AutoSub)

AutoSub:AddSection("Throw & Practice")
AutoSub:AddToggle({ Name = "Auto Throw", Description = "Throw stones automatically", Default = false, Flag = "ss_auto_throw", Callback = function(v)
    Config.autoThrow = v
    if v and Config.autoPractice then
        Config.autoPractice = false
        if notifyHub then notifyHub({ Title = "+1 Stone Skipping", Content = "Auto Practice turned off (conflicts with Auto Throw)", Type = "warning", Duration = 3 }) end
    end
end })
AutoSub:AddToggle({ Name = "Auto Practice", Description = "Train at the best zone for your rebirths", Default = false, Flag = "ss_auto_practice", Callback = function(v)
    Config.autoPractice = v
    if v and Config.autoThrow then
        Config.autoThrow = false
        if notifyHub then notifyHub({ Title = "+1 Stone Skipping", Content = "Auto Throw turned off (conflicts with Auto Practice)", Type = "warning", Duration = 3 }) end
    end
end })

AutoSub:AddSection("Progress")
AutoSub:AddToggle({ Name = "Auto Rebirth", Description = "Rebirth as soon as eligible", Default = false, Flag = "ss_auto_rebirth", Callback = function(v)
    Config.autoRebirth = v
end })

AutoSub:AddSection("Rewards")
AutoSub:AddToggle({ Name = "Auto Claim Reward", Description = "Claim ready playtime gifts", Default = false, Flag = "ss_auto_gift", Callback = function(v)
    Config.autoGift = v
end })
AutoSub:AddToggle({ Name = "Auto Use Potions", Description = "Use potions when no boost is active", Default = false, Flag = "ss_auto_potion", Callback = function(v)
    Config.autoPotion = v
end })
AutoSub:AddToggle({ Name = "Auto Hatch Egg", Description = "Hatch eggs from your inventory", Default = false, Flag = "ss_auto_hatch", Callback = function(v)
    Config.autoHatch = v
end })
AutoSub:AddDropdown({ Name = "Egg to Hatch", Description = "Egg used by Auto Hatch (Any = first available)", Options = ensureEggOptions(), Default = "Any", Flag = "ss_hatch_egg", Callback = function(v)
    Config.hatchEgg = v
end })

local SettingsSub = SettingsTab:AddSubTab("Config")
autosaveWrap(SettingsSub)
SettingsSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = SettingsSub:AddDropdown({ Name = "Saved Configs", Options = {}, Default = "", Flag = "cfg_sel", Callback = function(v) selectedConfig = v end })
local function refreshConfigList() local c = Library:ListConfigs() if configDropdown then configDropdown:SetOptions(c); configDropdown:Refresh() end end
local configInput = SettingsSub:AddInput({ Name = "Config Name", Default = "", Placeholder = "Enter config name...", Flag = "cfg_name" })
SettingsSub:AddDivider()
SettingsSub:AddButton({ Name = "Save Config", Primary = true, Callback = function()
    local name = configInput:Get() if not name or name == "" then Window:Notify({Title="Config",Content="Enter a name!",Type="warning",Duration=3}) return end
    if Library:SaveConfig(name) then refreshConfigList(); Window:Notify({Title="Config",Content="Saved: "..name,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end })
SettingsSub:AddButton({ Name = "Load Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then Window:Notify({Title="Config",Content="Select config!",Type="warning",Duration=3}) return end
    if Library:LoadConfig(selectedConfig) then refreshConfigList(); Window:Notify({Title="Config",Content="Loaded: "..selectedConfig,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end })
SettingsSub:AddButton({ Name = "Delete Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then return end
    Library:DeleteConfig(selectedConfig); local old = selectedConfig; selectedConfig = ""; refreshConfigList()
    Window:Notify({Title="Config",Content="Deleted: "..old,Type="info",Duration=3})
end })

local ServerSub = SettingsTab:AddSubTab("Server")
ServerSub:AddSection("Server")
ServerSub:AddButton({ Name = "Server Hop", Primary = true, Callback = function()
    Window:Notify({Title="Server Hop",Content="Finding new server...",Type="info",Duration=3})
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
end })

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

if notifyHub then
    notifyHub({ Title = "Exlumiaa Hub", Content = "+1 Stone Skipping loaded (v1)", Type = "success", Duration = 4 })
end
