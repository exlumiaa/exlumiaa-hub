-- Barber Empire - Exlumiaa Hub
-- universe 10773971368 / place 129516203408961
--
-- Client-side only. Auto cut (CutStation.autoPerfect + Enter), auto claim,
-- auto collect, auto buy, ClipTok, ESP, movement, teleport, HUD.
-- No key system. No server exploit; everything drives the normal remotes.

if tostring(game.GameId) ~= "10773971368" then return end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_barberempire.txt"
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
        -- >>> EXLUMIAA KEY GATE (generated from keygate/luau, do not hand-edit) >>>
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
            brand = "BARBER EMPIRE",
            guiName = "BarberEmpireKeyGate",
            savedKey = ksReadStore(),
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
                if stale() then
                    pcall(function() gui:Destroy() end)
                    return
                end
                if not gui or not gui.Parent then
                    gui = ksShowGate(function() gateDone = true end)
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
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_barberempire.txt"
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
        -- >>> EXLUMIAA KEY GATE (generated from keygate/luau, do not hand-edit) >>>
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
            brand = "BARBER EMPIRE",
            guiName = "BarberEmpireKeyGate",
            savedKey = ksReadStore(),
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
                if stale() then
                    pcall(function() gui:Destroy() end)
                    return
                end
                if not gui or not gui.Parent then
                    gui = ksShowGate(function() gateDone = true end)
                end
                task.wait(0.1)
            end
            if gui and gui.Parent then
                pcall(function() gui:Destroy() end)
            end
        end
    end
end


local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

local GEN = (tonumber(getgenv().__beGen) or 0) + 1
getgenv().__beGen = GEN
local function stale() return (tonumber(getgenv().__beGen) or 0) ~= GEN end

pcall(cleardrawcache)

local HL = RS:WaitForChild("HairLab", 30)
local Remotes = HL and HL:WaitForChild("Remotes", 30)
if not HL or not Remotes then
    warn("[ExlumiaaHub] Barber Empire: HairLab not found")
    return
end

-- ================================================================
-- CONFIG
-- ================================================================
local Config = {
    -- cut
    autoCut = false,
    cutDelay = 350,
    autoCall = false,
    -- collect
    autoTips = false,
    tipsInterval = 20,
    autoCoins = false,
    autoDrops = false,
    autoClaim = false,
    claimInterval = 60,
    -- clip tok
    autoVideo = false,
    videoFormat = "classic",
    videoGlow = false,
    videoLineup = false,
    autoSpin = false,
    spinInterval = 120,
    -- auto buy
    buyBuild = false,
    buySkills = false,
    buyChair = false,
    buyTools = false,
    buyStaff = false,
    buyEquip = true,
    buyInterval = 8,
    reserve = 0,
    -- esp
    espCustomers = false,
    espBox = true,
    espRich = true,
    espCoins = false,
    espDrops = false,
    espJars = false,
    espMaxDist = 300,
    -- movement
    speedEnabled = false,
    walkSpeed = 60,
    jumpEnabled = false,
    jumpPower = 60,
    infJump = false,
    flyEnabled = false,
    flySpeed = 80,
    noclip = false,
    antiAfk = true,
    -- misc
    hud = true,
    _cutWorker = false,
}

-- ================================================================
-- HELPERS
-- ================================================================
local function hrp()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function hum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local MONEY_SUFFIX = { K = 1e3, M = 1e6, B = 1e9, T = 1e12, Q = 1e15 }
local function parseMoney(v)
    if type(v) == "number" then return v end
    local s = tostring(v or "0"):gsub("[^%d%.,KMBTQkmbtq]", "")
    s = s:gsub(",", "")
    local num, suf = s:match("([%d%.]+)([KMBTQkmbtq]?)")
    local n = tonumber(num) or 0
    return n * (MONEY_SUFFIX[(suf or ""):upper()] or 1)
end

local function cashNow()
    local ls = LP:FindFirstChild("leaderstats")
    local c = ls and ls:FindFirstChild("Cash")
    return parseMoney(c and c.Value)
end

local function readAttr(name)
    local v = LP:GetAttribute(name)
    if type(v) == "string" then
        local ok, t = pcall(function() return HttpService:JSONDecode(v) end)
        if ok then return t end
    end
    return v
end

local function sendEnter()
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end)
end

local function firePrompt(p)
    if type(fireproximityprompt) == "function" then
        return pcall(fireproximityprompt, p)
    end
    return pcall(function()
        p:InputHoldBegin()
        task.wait(0.1)
        p:InputHoldEnd()
    end)
end

-- ================================================================
-- CUT STATION
-- ================================================================
local CutStation
local function getCutStation()
    if CutStation then return CutStation end
    local ok, m = pcall(require, HL.Client.CutStation)
    if ok and type(m) == "table" then CutStation = m end
    return CutStation
end

local function cutActive()
    local cs = getCutStation()
    if cs and type(cs.isActive) == "function" then
        local ok, v = pcall(cs.isActive)
        if ok and v then return true end
    end
    return LP:GetAttribute("Cutting") == true
end

-- ================================================================
-- CLAIMS / COLLECT
-- ================================================================
local function claimedSet(v)
    local set = {}
    if type(v) ~= "table" then return set end
    for k, val in pairs(v) do
        local n = tonumber(k)
        if n and (type(k) == "number" or val == true) then set[n] = true end
    end
    return set
end

local function claimPlaytime()
    local ok, Playtime = pcall(require, HL.Client.Playtime)
    if not ok or type(Playtime) ~= "table" then return end
    local pg = readAttr("PlayGot")
    if type(pg) ~= "table" then pg = {} end
    -- PLAYTIME is available via Goals module
    local okG, GoalsMod = pcall(require, HL.Goals)
    if not okG or type(GoalsMod) ~= "table" or type(GoalsMod.PLAYTIME) ~= "table" then return end
    local PT = GoalsMod.PLAYTIME
    for i = 1, #PT do
        if not pg[tostring(i)] then
            pcall(function() Playtime.claim(i) end)
        end
    end
end

local function claimTick()
    claimPlaytime()
    local goals = Remotes:FindFirstChild("Goals")
    if not goals then return end
    local q = readAttr("Quests")
    if type(q) == "table" then
        for _, kind in ipairs({ "daily", "weekly" }) do
            local list = q[kind]
            if type(list) == "table" then
                for i, quest in ipairs(list) do
                    if type(quest) == "table" and not quest.claimed then
                        local at = tonumber(quest.at) or 0
                        local n = tonumber(quest.n) or 0
                        if n > 0 and at >= n then
                            local ok, res = pcall(function() return goals:InvokeServer("claim", kind, i) end)
                            if ok and type(res) == "table" and res.ok then
                                print("[BarberEmpire] claimed " .. kind .. " " .. i
                                    .. (res.cash and (" +$" .. tostring(res.cash)) or ""))
                            end
                        end
                    end
                end
            end
        end
    end
    pcall(function() goals:InvokeServer("login") end)
    local pass = readAttr("PassData")
    if type(pass) == "table" then
        local xp = tonumber(pass.xp) or 0
        local tier = math.min(30, math.floor(xp / 400))
        for _, track in ipairs({ "free", "prem" }) do
            local claimed = claimedSet(pass[track])
            for t = 1, tier do
                if not claimed[t] then
                    pcall(function() goals:InvokeServer("claim", "pass", track, t) end)
                end
            end
        end
    end
    local esc = Remotes:FindFirstChild("EscMenu")
    if esc then pcall(function() esc:InvokeServer("claim") end) end
end

local function collectTips()
    local tj = Remotes:FindFirstChild("TipJar")
    if not tj then return end
    local ok, res = pcall(function() return tj:InvokeServer("collect") end)
    if ok and type(res) == "table" and res.ok and (tonumber(res.amount) or 0) > 0 then
        print("[BarberEmpire] tips +$" .. tostring(res.amount))
    end
end

-- ================================================================
-- AUTO BUY
-- ================================================================
local CHAIR_COST = { [2] = 6420, [3] = 13.8e6, [4] = 2.33e9, [5] = 895e9 }
local CHAIR_GATE = { [2] = 2, [3] = 4, [4] = 6, [5] = 8 }
local TOOL_ATTR = {
    { name = "Clippers", own = "OwnedClippers", tier = "ClipperTier" },
    { name = "Trimmer", own = "OwnedTrimmer", tier = "TrimmerTier" },
    { name = "Razor", own = "OwnedRazor", tier = "RazorTier" },
    { name = "Scissors", own = "OwnedScissors", tier = "ScissorsTier" },
    { name = "Sponge", own = "OwnedSponge", tier = "SpongeTier" },
}
local TOOL_T2 = { Clippers = 152, Trimmer = 379, Razor = 3850, Scissors = 3850, Sponge = 3000 }
local TOOL_MIN = { [2] = 0, [3] = 1e6, [4] = 1e7, [5] = 1e8 }

local function canSpend(cost)
    return cashNow() - (Config.reserve or 0) >= (cost or 0)
end

local BuildPlan
local function getBuildPlan()
    if BuildPlan then return BuildPlan end
    local ok, m = pcall(require, HL.BuildPlan)
    if ok then BuildPlan = m end
    return BuildPlan
end

local function nextPieceCost()
    local bp = getBuildPlan()
    if bp and type(bp.COSTS) == "table" then
        local lvl = tonumber(LP:GetAttribute("StoreLevel")) or 1
        local built = tonumber(LP:GetAttribute("PiecesBuilt")) or 0
        local list = bp.COSTS[lvl]
        if type(list) == "table" then return tonumber(list[built + 1]) end
    end
    return nil
end

local SkillTree
local function getSkillTree()
    if SkillTree then return SkillTree end
    local ok, m = pcall(require, HL.SkillTree)
    if ok then SkillTree = m end
    return SkillTree
end

local function ownedSkillSet()
    local set = {}
    local v = LP:GetAttribute("Skills")
    if type(v) == "string" then
        local ok, t = pcall(function() return HttpService:JSONDecode(v) end)
        if ok and type(t) == "table" then v = t end
    end
    if type(v) == "table" then
        for _, id in ipairs(v) do set[tostring(id)] = true end
    elseif type(v) == "string" then
        for id in v:gmatch("[%w_]+") do set[id] = true end
    end
    return set
end

local function buyNextSkill()
    local st = getSkillTree()
    if not st or type(st.NODES) ~= "table" then return false end
    local owned = ownedSkillSet()
    local list = {}
    for _, node in pairs(st.NODES) do
        if type(node) == "table" and node.id and node.id ~= "root" and not owned[node.id] then
            local parent = node.parent
            if parent == nil or parent == "root" or owned[parent] then
                table.insert(list, node)
            end
        end
    end
    table.sort(list, function(a, b) return (tonumber(a.cost) or 0) < (tonumber(b.cost) or 0) end)
    for _, node in ipairs(list) do
        local cost = tonumber(node.cost) or 0
        if cost > 0 and canSpend(cost) then
            local ok, res = pcall(function() return Remotes.Build:InvokeServer("skill", node.id) end)
            if ok and res then
                print("[BarberEmpire] skill " .. tostring(node.id))
                return true
            end
        end
    end
    return false
end

local lastEquip = 0
local function buyTick()
    if Config.buyBuild then
        local cost = nextPieceCost()
        if cost and canSpend(cost) then
            local ok, res = pcall(function() return Remotes.Build:InvokeServer("piece") end)
            if ok and res then
                print("[BarberEmpire] build piece +" .. tostring(cost))
                return
            end
        end
    end
    if Config.buySkills and buyNextSkill() then return end
    if Config.buyChair then
        local cl = tonumber(LP:GetAttribute("ChairLevel")) or 1
        local nextL = cl + 1
        local cost, gate = CHAIR_COST[nextL], CHAIR_GATE[nextL]
        local store = tonumber(LP:GetAttribute("StoreLevel")) or 1
        if cost and gate and store >= gate and canSpend(cost) then
            local ok, res = pcall(function() return Remotes.Hire:InvokeServer("chair", nil, "Purchase") end)
            if ok and res then
                print("[BarberEmpire] chair -> " .. tostring(nextL))
                return
            end
        end
    end
    if Config.buyTools then
        local best, bestCost
        for _, t in ipairs(TOOL_ATTR) do
            local own = tonumber(LP:GetAttribute(t.own)) or 1
            local nextTier = own + 1
            if nextTier <= 5 then
                local cost = (nextTier == 2) and TOOL_T2[t.name] or TOOL_MIN[nextTier]
                if cost and canSpend(cost) and (not bestCost or cost < bestCost) then
                    best = { tool = t.name, tier = nextTier }
                    bestCost = cost
                end
            end
        end
        if best then
            local ok, res = pcall(function() return Remotes.ToolShop:InvokeServer("buy", best.tool, best.tier) end)
            if ok and res then
                print("[BarberEmpire] tool " .. best.tool .. " t" .. best.tier)
                if Config.buyEquip then
                    pcall(function() Remotes.ToolShop:InvokeServer("equip", best.tool, best.tier) end)
                end
                return
            end
        end
        if Config.buyEquip and os.clock() - lastEquip > 5 then
            lastEquip = os.clock()
            for _, t in ipairs(TOOL_ATTR) do
                local own = tonumber(LP:GetAttribute(t.own)) or 1
                local eq = tonumber(LP:GetAttribute(t.tier)) or 1
                if own > eq then
                    pcall(function() Remotes.ToolShop:InvokeServer("equip", t.name, own) end)
                end
            end
        end
    end
    if Config.buyStaff then
        local barbers = readAttr("Barbers")
        if type(barbers) == "table" then
            for i, b in ipairs(barbers) do
                local station = tonumber(b.station) or 1
                local stationAt = tonumber(b.stationAt) or 1
                local cost = tonumber(b.stationCost)
                if station < stationAt and cost and canSpend(cost) then
                    local ok, res = pcall(function() return Remotes.Hire:InvokeServer("station", i, "Purchase") end)
                    if ok and res then
                        print("[BarberEmpire] station " .. tostring(i))
                        return
                    end
                end
            end
        end
        if canSpend(250) then
            local ok, res = pcall(function() return Remotes.Hire:InvokeServer("hire", nil, "Hire") end)
            if ok and res then
                print("[BarberEmpire] hired barber")
                return
            end
        end
        local sweepers = tonumber(LP:GetAttribute("Sweepers")) or 0
        if sweepers < 1 and canSpend(1280) then
            local ok, res = pcall(function() return Remotes.Hire:InvokeServer("sweeper", nil, "Hire") end)
            if ok and res then
                print("[BarberEmpire] hired sweeper")
                return
            end
        end
    end
end

-- ================================================================
-- CLIPTOK
-- ================================================================
local function postVideo()
    local pv = Remotes:FindFirstChild("PostVideo")
    if not pv then return false end
    local ok = pcall(function()
        pv:InvokeServer({ glow = Config.videoGlow, lineup = Config.videoLineup, format = Config.videoFormat })
    end)
    if ok then print("[BarberEmpire] posted video (" .. Config.videoFormat .. ")") end
    return ok
end

-- ================================================================
-- MOVEMENT
-- ================================================================
local flyBV, flyBG
local noclipSaved = {}

local function applySpeed()
    local h = hum()
    if h then h.WalkSpeed = Config.speedEnabled and Config.walkSpeed or 16 end
end

local function applyJump()
    local h = hum()
    if not h then return end
    if h.UseJumpPower then
        h.JumpPower = Config.jumpEnabled and Config.jumpPower or 50
    else
        h.JumpHeight = Config.jumpEnabled and (Config.jumpPower / 7) or 7.2
    end
end

local function applyNoclip(on)
    local c = LP.Character
    if not c then return end
    if on then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and not noclipSaved[p] then
                noclipSaved[p] = p.CanCollide
                p.CanCollide = false
            end
        end
    else
        for p, v in pairs(noclipSaved) do
            if p.Parent then p.CanCollide = v end
        end
        table.clear(noclipSaved)
    end
end

local function startFly()
    local h, hm = hrp(), hum()
    if not h or not hm or flyBV then return end
    hm.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = h
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1500
    flyBG.D = 60
    flyBG.CFrame = h.CFrame
    flyBG.Parent = h
end

local function stopFly()
    local hm = hum()
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    if hm then hm.PlatformStand = false end
end

local function stepFly()
    if not flyBV or not flyBG then startFly() end
    if not flyBV then return end
    local cam = Workspace.CurrentCamera
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
    flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * Config.flySpeed or Vector3.zero
    flyBG.CFrame = cam.CFrame
end

-- ================================================================
-- TELEPORT
-- ================================================================
local function tpTo(pos)
    local h = hrp()
    if not h or not pos then return false end
    h.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    return true
end

local function ownPlot()
    local town = Workspace:FindFirstChild("Town")
    local plots = town and town:FindFirstChild("Plots")
    if not plots then return nil end
    for _, p in ipairs(plots:GetChildren()) do
        if p:GetAttribute("OwnerId") == LP.UserId then return p end
    end
    return nil
end

local function partPos(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst.Position end
    local p = inst:FindFirstChildWhichIsA("BasePart", true)
    return p and p.Position
end

local function promptPos(inst)
    local pr = inst and inst:FindFirstChildWhichIsA("ProximityPrompt", true)
    return pr and partPos(pr.Parent) or partPos(inst)
end

local function specialStall(name)
    local town = Workspace:FindFirstChild("Town")
    local city = town and town:FindFirstChild("City")
    local sp = city and city:FindFirstChild("Special")
    return sp and sp:FindFirstChild(name)
end

local function findPlot(id)
    local town = Workspace:FindFirstChild("Town")
    local plots = town and town:FindFirstChild("Plots")
    return plots and plots:FindFirstChild(id)
end

local function stealFrom(plot)
    if not plot then return false end
    local jar = plot:FindFirstChild("TipJar", true)
    local pr = jar and jar:FindFirstChild("StealTips", true)
    if not pr then return false end
    local pos = partPos(pr.Parent) or partPos(jar)
    if not pos then return false end
    tpTo(pos)
    task.wait(0.35)
    firePrompt(pr)
    return true
end

-- ================================================================
-- ESP
-- ================================================================
local drawings = {}
local function newDrawing(kind, props)
    if not Drawing then return nil end
    local ok, d = pcall(function() return Drawing.new(kind) end)
    if not ok or not d then return nil end
    for k, v in pairs(props or {}) do d[k] = v end
    table.insert(drawings, d)
    return d
end

local textPool, boxPool = {}, {}
local function getText(i)
    local d = textPool[i]
    if not d then
        d = newDrawing("Text", {
            Size = 14, Center = true, Outline = true,
            Color = Color3.new(1, 1, 1), Visible = false,
        })
        textPool[i] = d
    end
    return d
end

local function getBox(i)
    local d = boxPool[i]
    if not d then
        d = newDrawing("Square", {
            Filled = false, Thickness = 1,
            Color = Color3.new(1, 1, 1), Visible = false,
        })
        boxPool[i] = d
    end
    return d
end

local function hideFrom(pool, from)
    for i = from + 1, #pool do
        if pool[i] then pool[i].Visible = false end
    end
end

local function projectBox(model, cam)
    local cf, size = model:GetBoundingBox()
    local minX, minY, maxX, maxY, any
    for _, sx in ipairs({ -0.5, 0.5 }) do
        for _, sy in ipairs({ -0.5, 0.5 }) do
            for _, sz in ipairs({ -0.5, 0.5 }) do
                local wp = (cf * CFrame.new(size.X * sx, size.Y * sy, size.Z * sz)).Position
                local sp, on = cam:WorldToViewportPoint(wp)
                if on then
                    any = true
                    minX = minX and math.min(minX, sp.X) or sp.X
                    maxX = maxX and math.max(maxX, sp.X) or sp.X
                    minY = minY and math.min(minY, sp.Y) or sp.Y
                    maxY = maxY and math.max(maxY, sp.Y) or sp.Y
                end
            end
        end
    end
    if not any then return nil end
    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

local function customerLabel(m)
    local name = m.Name
    local tag = m:FindFirstChild("Tag", true)
    if tag then
        local lbl = tag:FindFirstChildWhichIsA("TextLabel", true)
        if lbl and lbl.Text ~= "" then name = lbl.Text end
    end
    local rich = false
    if Config.espRich then
        for _, d in ipairs(m:GetDescendants()) do
            local nm = d.Name
            if nm == "RichSparkle" or nm:find("RichGold") then rich = true break end
        end
    end
    return name, rich
end

local function jarLabel(plot)
    local jar = plot:FindFirstChild("TipJar", true)
    if not jar then return nil end
    local amount
    for _, d in ipairs(jar:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text:find("%$") then amount = d.Text break end
    end
    local owner = plot:GetAttribute("OwnerName") or plot.Name
    local pos = partPos(jar)
    if not pos then return nil end
    return owner, amount or "?", pos
end

local function updateEsp()
    local cam = Workspace.CurrentCamera
    local h = hrp()
    if not cam or not h then return end
    local n = 0

    if Config.espCustomers then
        local cw = Workspace:FindFirstChild("Customers")
        if cw then
            for _, m in ipairs(cw:GetChildren()) do
                local root = m:FindFirstChild("HumanoidRootPart")
                if root and m:IsA("Model") then
                    local dist = (root.Position - h.Position).Magnitude
                    if dist <= Config.espMaxDist then
                        local name, rich = customerLabel(m)
                        local sp, on = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        if on then
                            n += 1
                            local d = getText(n)
                            if d then
                                d.Position = Vector2.new(sp.X, sp.Y)
                                d.Text = string.format("%s [%dm]%s", name, math.floor(dist), rich and " RICH" or "")
                                d.Color = rich and Color3.fromRGB(255, 210, 80) or Color3.fromRGB(255, 255, 255)
                                d.Visible = true
                            end
                            if Config.espBox then
                                local bpos, bsize = projectBox(m, cam)
                                local b = getBox(n)
                                if b then
                                    if bpos then
                                        b.Position = bpos
                                        b.Size = bsize
                                        b.Color = rich and Color3.fromRGB(255, 210, 80) or Color3.fromRGB(255, 255, 255)
                                        b.Visible = true
                                    else
                                        b.Visible = false
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    hideFrom(textPool, n)
    hideFrom(boxPool, n)

    local function simpleFolder(folderName, label, color)
        local f = Workspace:FindFirstChild(folderName)
        if not f then return end
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("BasePart") then
                local dist = (c.Position - h.Position).Magnitude
                if dist <= Config.espMaxDist then
                    local sp, on = cam:WorldToViewportPoint(c.Position)
                    if on then
                        n += 1
                        local d = getText(n)
                        if d then
                            d.Position = Vector2.new(sp.X, sp.Y)
                            d.Text = string.format("%s [%dm]", label, math.floor(dist))
                            d.Color = color
                            d.Visible = true
                        end
                    end
                end
            end
        end
    end

    if Config.espCoins then simpleFolder("MyCoins", "Coin", Color3.fromRGB(120, 220, 120)) end
    if Config.espDrops then simpleFolder("CashDrops", "Drop", Color3.fromRGB(120, 220, 255)) end

    if Config.espJars then
        local town = Workspace:FindFirstChild("Town")
        local plots = town and town:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                local owner, amount, pos = jarLabel(plot)
                if pos then
                    local dist = (pos - h.Position).Magnitude
                    if dist <= Config.espMaxDist then
                        local sp, on = cam:WorldToViewportPoint(pos + Vector3.new(0, 2, 0))
                        if on then
                            n += 1
                            local d = getText(n)
                            if d then
                                d.Position = Vector2.new(sp.X, sp.Y)
                                d.Text = string.format("%s jar %s [%dm]", owner, amount, math.floor(dist))
                                d.Color = Color3.fromRGB(255, 200, 120)
                                d.Visible = true
                            end
                        end
                    end
                end
            end
        end
    end
    hideFrom(textPool, n)
end

local hudBg, hudText, sessionStart = nil, nil, cashNow()
local function updateHud()
    if not Drawing then return end
    if not Config.hud then
        if hudBg then hudBg.Visible = false end
        if hudText then hudText.Visible = false end
        return
    end
    if not hudBg then
        hudBg = newDrawing("Square", {
            Filled = true, Color = Color3.new(0, 0, 0),
            Transparency = 0.55, Visible = false,
        })
        hudText = newDrawing("Text", {
            Size = 15, Outline = true, Center = false,
            Color = Color3.fromRGB(240, 240, 240), Visible = false,
        })
    end
    if not hudBg or not hudText then return end
    local cash = cashNow()
    local cuts = 0
    local ls = LP:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Cuts") then cuts = ls.Cuts.Value end
    local txt = string.format("Cash $%s  |  Cuts %s  |  Session +$%s",
        tostring(math.floor(cash)), tostring(cuts), tostring(math.floor(cash - sessionStart)))
    hudText.Text = txt
    hudText.Position = Vector2.new(14, 10)
    hudText.Visible = true
    hudBg.Position = Vector2.new(8, 6)
    hudBg.Size = Vector2.new(320, 24)
    hudBg.Visible = true
end

-- ================================================================
-- MAIN LOOPS
-- ================================================================
local conns = {}

local lastCutTry = 0
local function runCut()
    if Config._cutWorker then return end
    if os.clock() - lastCutTry < 2.5 then return end
    lastCutTry = os.clock()
    Config._cutWorker = true
    task.spawn(function()
        task.wait(0.45)
        if stale() then Config._cutWorker = false return end
        local cs = getCutStation()
        local ok = false
        if cs and type(cs.autoPerfect) == "function" then
            ok = pcall(cs.autoPerfect)
        end
        if ok then
            task.wait(math.max(0.1, Config.cutDelay / 1000))
            sendEnter()
            task.wait(1.0)
            if cutActive() then
                task.wait(0.5)
                sendEnter()
                task.wait(1.0)
            end
        end
        Config._cutWorker = false
    end)
end

-- cut watcher: drives auto cut and fires auto video after a cut ends
table.insert(conns, task.spawn(function()
    local wasCutting = false
    while not stale() do
        task.wait(0.25)
        local now = cutActive()
        if now and not wasCutting and Config.autoCut then
            runCut()
        elseif now and Config.autoCut then
            runCut()
        elseif not now and wasCutting and Config.autoVideo then
            task.delay(1.0, postVideo)
        end
        wasCutting = now
    end
end))

-- auto call
table.insert(conns, task.spawn(function()
    while not stale() do
        task.wait(1.0)
        if Config.autoCall and not cutActive() then
            local cw = Workspace:FindFirstChild("Customers")
            if cw then
                for _, d in ipairs(cw:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled
                        and d.ActionText:lower():find("call") then
                        firePrompt(d)
                        break
                    end
                end
            end
        end
    end
end))

-- auto tips
table.insert(conns, task.spawn(function()
    while not stale() do
        task.wait(Config.tipsInterval)
        if Config.autoTips then collectTips() end
    end
end))

-- auto claim
table.insert(conns, task.spawn(function()
    while not stale() do
        task.wait(Config.claimInterval)
        if Config.autoClaim then claimTick() end
    end
end))

-- auto buy
table.insert(conns, task.spawn(function()
    while not stale() do
        task.wait(Config.buyInterval)
        if not stale() and (Config.buyBuild or Config.buySkills or Config.buyChair
            or Config.buyTools or Config.buyStaff) then
            buyTick()
        end
    end
end))

-- auto spin
table.insert(conns, task.spawn(function()
    while not stale() do
        task.wait(Config.spinInterval)
        if Config.autoSpin then
            local vs = Remotes:FindFirstChild("VideoSpin")
            if vs then pcall(function() vs:InvokeServer() end) end
        end
    end
end))

-- coin / drop magnet (only when idle, restores position)
local magnetBusy = false
table.insert(conns, task.spawn(function()
    while not stale() do
        task.wait(1.5)
        if (Config.autoCoins or Config.autoDrops) and not magnetBusy and not cutActive() then
            local h = hrp()
            if h then
                local target
                if Config.autoCoins then
                    local f = Workspace:FindFirstChild("MyCoins")
                    if f then
                        local best, bestD
                        for _, c in ipairs(f:GetChildren()) do
                            if c:IsA("BasePart") then
                                local d = (c.Position - h.Position).Magnitude
                                if d < 300 and (not bestD or d < bestD) then best, bestD = c, d end
                            end
                        end
                        target = best
                    end
                end
                if not target and Config.autoDrops then
                    local f = Workspace:FindFirstChild("CashDrops")
                    if f then
                        for _, c in ipairs(f:GetChildren()) do
                            if c:IsA("BasePart") then
                                local d = (c.Position - h.Position).Magnitude
                                if d < 300 then target = c break end
                            end
                        end
                    end
                end
                if target then
                    magnetBusy = true
                    local saved = h.CFrame
                    pcall(function() h.CFrame = target.CFrame + Vector3.new(0, 2, 0) end)
                    task.wait(0.35)
                    pcall(function() h.CFrame = saved end)
                    magnetBusy = false
                end
            end
        end
    end
end))

-- speed / jump / noclip enforcement
table.insert(conns, RunService.Heartbeat:Connect(function()
    if stale() then return end
    if Config.speedEnabled or Config.jumpEnabled then
        local h = hum()
        if h then
            if Config.speedEnabled and math.abs(h.WalkSpeed - Config.walkSpeed) > 0.5 then
                h.WalkSpeed = Config.walkSpeed
            end
            if Config.jumpEnabled then
                if h.UseJumpPower then
                    if math.abs(h.JumpPower - Config.jumpPower) > 0.5 then h.JumpPower = Config.jumpPower end
                elseif math.abs(h.JumpHeight - Config.jumpPower / 7) > 0.5 then
                    h.JumpHeight = Config.jumpPower / 7
                end
            end
        end
    end
end))

-- render loop: ESP, HUD, fly
table.insert(conns, RunService.RenderStepped:Connect(function()
    if stale() then return end
    if Config.flyEnabled then stepFly() elseif flyBV then stopFly() end
    if Config.espCustomers or Config.espCoins or Config.espDrops or Config.espJars then
        updateEsp()
    else
        hideFrom(textPool, 0)
        hideFrom(boxPool, 0)
    end
    updateHud()
end))

table.insert(conns, UIS.JumpRequest:Connect(function()
    if stale() then return end
    if Config.infJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if stale() then return end
    table.clear(noclipSaved)
    applySpeed()
    applyJump()
    if Config.noclip then applyNoclip(true) end
    if Config.flyEnabled then startFly() end
end)

LP.Idled:Connect(function()
    if stale() or not Config.antiAfk then return end
    pcall(function()
        VIM:CaptureController()
        VIM:ClickButton2(Vector2.new())
    end)
end)

-- ================================================================
-- UI
-- ================================================================
local Library
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
if not Library or stale() then return end

Library.ConfigFolder = "exlumiaa/barber-empire"

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

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Barber Empire",
    Size = UDim2.fromOffset(540, 460),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Barber Empire",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

local function notify(title, content, ntype)
    pcall(function()
        Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 })
    end)
end

local toggleRefs = {}
local function keepToggle(t)
    if t then table.insert(toggleRefs, t) end
    return t
end

-- ---------------- FARM ----------------
local FarmTab = Window:AddTab({ Name = "Farm", Icon = "zap", Subtitle = "Auto" })

local CutSub = FarmTab:AddSubTab("Cut")
autosaveWrap(CutSub)
CutSub:AddSection("Haircut")
local autoCutToggle = keepToggle(CutSub:AddToggle({
    Name = "Auto Cut (perfect + done)", Flag = "be_autocut", Default = false,
    Callback = function(v) Config.autoCut = v end,
}))
CutSub:AddSlider({
    Name = "Done Delay", Min = 100, Max = 1500, Default = 350, Suffix = " ms",
    Flag = "be_cutdelay", Callback = function(v) Config.cutDelay = v end,
})
local autoCallToggle = keepToggle(CutSub:AddToggle({
    Name = "Auto Call Customers", Flag = "be_autocall", Default = false,
    Callback = function(v) Config.autoCall = v end,
}))


local CollectSub = FarmTab:AddSubTab("Collect")
autosaveWrap(CollectSub)
CollectSub:AddSection("Money")
local autoTipsToggle = keepToggle(CollectSub:AddToggle({
    Name = "Auto Collect Tip Jar", Flag = "be_autotips", Default = false,
    Callback = function(v) Config.autoTips = v end,
}))
CollectSub:AddSlider({
    Name = "Tips Interval", Min = 5, Max = 120, Default = 20, Suffix = " s",
    Flag = "be_tipsint", Callback = function(v) Config.tipsInterval = v end,
})
local autoCoinsToggle = keepToggle(CollectSub:AddToggle({
    Name = "Auto Coins (magnet)", Flag = "be_autocoins", Default = false,
    Callback = function(v) Config.autoCoins = v end,
}))
local autoDropsToggle = keepToggle(CollectSub:AddToggle({
    Name = "Auto Cash Drops (magnet)", Flag = "be_autodrops", Default = false,
    Callback = function(v) Config.autoDrops = v end,
}))
local autoClaimToggle = keepToggle(CollectSub:AddToggle({
    Name = "Auto Claim Rewards", Flag = "be_autoclaim", Default = false,
    Callback = function(v) Config.autoClaim = v end,
}))
CollectSub:AddSlider({
    Name = "Claim Interval", Min = 10, Max = 300, Default = 60, Suffix = " s",
    Flag = "be_claimint", Callback = function(v) Config.claimInterval = v end,
})
CollectSub:AddButton({
    Name = "Claim Now", Primary = true,
    Callback = function()
        local be = getgenv().__be
        if be then
            pcall(be.claimTick)
            notify("Claim", "Claim attempted (quests + playtime + pass + login + offline)", "info")
        end
    end,
})


local BuySub = FarmTab:AddSubTab("Auto Buy")
autosaveWrap(BuySub)
BuySub:AddSection("Upgrades")
local buyBuildToggle = keepToggle(BuySub:AddToggle({
    Name = "Auto Build Piece", Flag = "be_buybuild", Default = false,
    Callback = function(v) Config.buyBuild = v end,
}))
local buySkillsToggle = keepToggle(BuySub:AddToggle({
    Name = "Auto Skill Tree", Flag = "be_buyskills", Default = false,
    Callback = function(v) Config.buySkills = v end,
}))
local buyChairToggle = keepToggle(BuySub:AddToggle({
    Name = "Auto Chair", Flag = "be_buychair", Default = false,
    Callback = function(v) Config.buyChair = v end,
}))
local buyToolsToggle = keepToggle(BuySub:AddToggle({
    Name = "Auto Buy Tools", Flag = "be_buytools", Default = false,
    Callback = function(v) Config.buyTools = v end,
}))
local buyStaffToggle = keepToggle(BuySub:AddToggle({
    Name = "Auto Hire / Stations", Flag = "be_buystaff", Default = false,
    Callback = function(v) Config.buyStaff = v end,
}))
local buyEquipToggle = keepToggle(BuySub:AddToggle({
    Name = "Equip Best Tools", Flag = "be_buyequip", Default = true,
    Callback = function(v) Config.buyEquip = v end,
}))
BuySub:AddSlider({
    Name = "Buy Interval", Min = 2, Max = 60, Default = 8, Suffix = " s",
    Flag = "be_buyint", Callback = function(v) Config.buyInterval = v end,
})
BuySub:AddInput({
    Name = "Cash Reserve", Default = "0", Placeholder = "0",
    Flag = "be_reserve", Callback = function(v) Config.reserve = parseMoney(v) end,
})


local ClipSub = FarmTab:AddSubTab("ClipTok")
autosaveWrap(ClipSub)
ClipSub:AddSection("Video")
local autoVideoToggle = keepToggle(ClipSub:AddToggle({
    Name = "Auto Post Video", Flag = "be_autovideo", Default = false,
    Callback = function(v) Config.autoVideo = v end,
}))
ClipSub:AddDropdown({
    Name = "Format", Options = { "classic", "storytime", "commentary", "rate", "pov", "speedrun", "vip", "fail" },
    Default = "classic", Flag = "be_videoformat",
    Callback = function(v) Config.videoFormat = v end,
})
ClipSub:AddToggle({
    Name = "Glow Up", Flag = "be_videoglow", Default = false,
    Callback = function(v) Config.videoGlow = v end,
})
ClipSub:AddToggle({
    Name = "Lineup", Flag = "be_videolineup", Default = false,
    Callback = function(v) Config.videoLineup = v end,
})
local autoSpinToggle = keepToggle(ClipSub:AddToggle({
    Name = "Auto Video Spin", Flag = "be_autospin", Default = false,
    Callback = function(v) Config.autoSpin = v end,
}))
ClipSub:AddSlider({
    Name = "Spin Interval", Min = 30, Max = 600, Default = 120, Suffix = " s",
    Flag = "be_spinint", Callback = function(v) Config.spinInterval = v end,
})
ClipSub:AddButton({
    Name = "Post Video Now", Primary = true,
    Callback = function()
        if postVideo() then notify("ClipTok", "Video posted (" .. Config.videoFormat .. ")", "success")
        else notify("ClipTok", "Post failed", "error") end
    end,
})

-- ---------------- VISUALS ----------------
local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local EspSub = VisualTab:AddSubTab("ESP")
autosaveWrap(EspSub)
EspSub:AddSection("Customers")
local espCustToggle = keepToggle(EspSub:AddToggle({
    Name = "Customer ESP", Flag = "be_espcust", Default = false,
    Callback = function(v) Config.espCustomers = v end,
}))
EspSub:AddToggle({
    Name = "Box", Flag = "be_espbox", Default = true,
    Callback = function(v) Config.espBox = v end,
})
EspSub:AddToggle({
    Name = "Rich Highlight", Flag = "be_esprich", Default = true,
    Callback = function(v) Config.espRich = v end,
})
EspSub:AddSection("World")
local espCoinsToggle = keepToggle(EspSub:AddToggle({
    Name = "Coin ESP", Flag = "be_espcoins", Default = false,
    Callback = function(v) Config.espCoins = v end,
}))
local espDropsToggle = keepToggle(EspSub:AddToggle({
    Name = "Cash Drop ESP", Flag = "be_espdrops", Default = false,
    Callback = function(v) Config.espDrops = v end,
}))
local espJarsToggle = keepToggle(EspSub:AddToggle({
    Name = "Tip Jar ESP", Flag = "be_espjars", Default = false,
    Callback = function(v) Config.espJars = v end,
}))
EspSub:AddSlider({
    Name = "Max Distance", Min = 50, Max = 1000, Default = 300, Suffix = " studs",
    Flag = "be_espdist", Callback = function(v) Config.espMaxDist = v end,
})

-- ---------------- MOVEMENT ----------------
local MoveTab = Window:AddTab({ Name = "Movement", Icon = "move", Subtitle = "Player" })
local SpeedSub = MoveTab:AddSubTab("Player")
autosaveWrap(SpeedSub)
SpeedSub:AddSection("Speed")
local speedToggle = keepToggle(SpeedSub:AddToggle({
    Name = "Speed Hack", Flag = "be_speed", Default = false,
    Callback = function(v) Config.speedEnabled = v; applySpeed() end,
}))
SpeedSub:AddSlider({
    Name = "Walk Speed", Min = 16, Max = 250, Default = 60,
    Flag = "be_walkspeed", Callback = function(v) Config.walkSpeed = v; applySpeed() end,
})
local jumpToggle = keepToggle(SpeedSub:AddToggle({
    Name = "Jump Power", Flag = "be_jump", Default = false,
    Callback = function(v) Config.jumpEnabled = v; applyJump() end,
}))
SpeedSub:AddSlider({
    Name = "Jump Power Value", Min = 50, Max = 400, Default = 60,
    Flag = "be_jumppower", Callback = function(v) Config.jumpPower = v; applyJump() end,
})
local infJumpToggle = keepToggle(SpeedSub:AddToggle({
    Name = "Infinite Jump", Flag = "be_infjump", Default = false,
    Callback = function(v) Config.infJump = v end,
}))
local noclipToggle = keepToggle(SpeedSub:AddToggle({
    Name = "Noclip", Flag = "be_noclip", Default = false,
    Callback = function(v) Config.noclip = v; applyNoclip(v) end,
}))

local FlySub = MoveTab:AddSubTab("Fly")
autosaveWrap(FlySub)
FlySub:AddSection("Fly")
local flyToggle = keepToggle(FlySub:AddToggle({
    Name = "Fly (WASD / Space / Ctrl)", Flag = "be_fly", Default = false,
    Callback = function(v)
        Config.flyEnabled = v
        if v then startFly() else stopFly() end
    end,
}))
FlySub:AddSlider({
    Name = "Fly Speed", Min = 10, Max = 400, Default = 80,
    Flag = "be_flyspeed", Callback = function(v) Config.flySpeed = v end,
})

-- ---------------- TELEPORT ----------------
local TpTab = Window:AddTab({ Name = "Teleport", Icon = "map", Subtitle = "Travel" })
local TpSub = TpTab:AddSubTab("Travel")
autosaveWrap(TpSub)
TpSub:AddSection("Shop")
TpSub:AddButton({
    Name = "Chair", Primary = true,
    Callback = function()
        local plot = ownPlot()
        local pos = plot and (partPos(plot:FindFirstChild("ChairStand", true)) or partPos(plot:FindFirstChild("Spawn", true)))
        if tpTo(pos) then notify("Teleport", "Chair", "success") else notify("Teleport", "Chair not found", "warning") end
    end,
})
TpSub:AddButton({
    Name = "Own Plot",
    Callback = function()
        local plot = ownPlot()
        local pos = plot and (partPos(plot:FindFirstChild("Hub", true)) or partPos(plot:FindFirstChild("Spawn", true)))
        if tpTo(pos) then notify("Teleport", "Own plot", "success") else notify("Teleport", "Plot not found", "warning") end
    end,
})
TpSub:AddButton({
    Name = "Tool Shop",
    Callback = function()
        if tpTo(promptPos(specialStall("ToolShopStall"))) then notify("Teleport", "Tool Shop", "success")
        else notify("Teleport", "Tool Shop not found", "warning") end
    end,
})
TpSub:AddButton({
    Name = "VIP Store",
    Callback = function()
        if tpTo(promptPos(specialStall("VipStoreStall"))) then notify("Teleport", "VIP Store", "success")
        else notify("Teleport", "VIP Store not found", "warning") end
    end,
})
TpSub:AddButton({
    Name = "Hire Stall",
    Callback = function()
        if tpTo(promptPos(specialStall("HireStall"))) then notify("Teleport", "Hire Stall", "success")
        else notify("Teleport", "Hire Stall not found", "warning") end
    end,
})

TpSub:AddSection("Town")
TpSub:AddButton({
    Name = "Park Events",
    Callback = function()
        local town = Workspace:FindFirstChild("Town")
        local park = town and town:FindFirstChild("Park")
        local pos = park and (promptPos(park) or partPos(park))
        if tpTo(pos) then notify("Teleport", "Park", "success") else notify("Teleport", "Park not found", "warning") end
    end,
})
TpSub:AddButton({
    Name = "Broom",
    Callback = function()
        local broom = Workspace:FindFirstChild("Broom")
        local pos = broom and (promptPos(broom) or partPos(broom))
        if tpTo(pos) then notify("Teleport", "Broom", "success") else notify("Teleport", "Broom not found", "warning") end
    end,
})
TpSub:AddButton({
    Name = "Arcade (Plot6)",
    Callback = function()
        local plot = findPlot("Plot6")
        local arc = plot and plot:FindFirstChild("ArcadeScreen", true)
        local pos = arc and (promptPos(arc) or partPos(arc))
        if tpTo(pos) then notify("Teleport", "Arcade", "success") else notify("Teleport", "Arcade not found", "warning") end
    end,
})

TpSub:AddSection("Other Plots")
local plotDropdown = TpSub:AddDropdown({
    Name = "Plot", Options = { "Plot1", "Plot2", "Plot3", "Plot4", "Plot5", "Plot6", "Plot7", "Plot8" },
    Default = "Plot1", Flag = "be_plot", Callback = function() end,
})
TpSub:AddButton({
    Name = "Go To Plot",
    Callback = function()
        local id = plotDropdown:Get()
        local plot = findPlot(id)
        local pos = plot and (partPos(plot:FindFirstChild("Hub", true)) or partPos(plot:FindFirstChild("Spawn", true)))
        if tpTo(pos) then notify("Teleport", tostring(id), "success") else notify("Teleport", "Plot not found", "warning") end
    end,
})
TpSub:AddButton({
    Name = "Steal Tips (selected plot)",
    Callback = function()
        local id = plotDropdown:Get()
        local plot = findPlot(id)
        if not plot then notify("Teleport", "Plot not found", "warning") return end
        if plot:GetAttribute("OwnerId") == LP.UserId then
            notify("Teleport", "That is your own plot", "warning")
            return
        end
        if stealFrom(plot) then notify("Teleport", "Steal prompt fired", "success")
        else notify("Teleport", "Jar prompt not found", "warning") end
    end,
})

-- ---------------- SETTINGS ----------------
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local SafeSub = SettingsTab:AddSubTab("Session")
autosaveWrap(SafeSub)
SafeSub:AddSection("HUD")
SafeSub:AddToggle({
    Name = "Stat HUD", Flag = "be_hud", Default = true,
    Callback = function(v) Config.hud = v end,
})
SafeSub:AddToggle({
    Name = "Anti AFK", Flag = "be_antiafk", Default = true,
    Callback = function(v) Config.antiAfk = v end,
})
SafeSub:AddSection("Panic")
SafeSub:AddButton({
    Name = "Panic - Disable All", Primary = true,
    Callback = function()
        for _, k in ipairs({
            "autoCut", "autoCall", "autoTips", "autoCoins", "autoDrops", "autoClaim",
            "autoVideo", "autoSpin", "buyBuild", "buySkills", "buyChair", "buyTools",
            "buyStaff", "espCustomers", "espCoins", "espDrops", "espJars",
            "speedEnabled", "jumpEnabled", "infJump", "flyEnabled", "noclip",
        }) do
            Config[k] = false
        end
        for _, t in ipairs(toggleRefs) do
            pcall(function() t:Set(false) end)
        end
        stopFly()
        applyNoclip(false)
        applySpeed()
        applyJump()
        notify("Panic", "All features disabled", "info")
    end,
})

local ConfigSub = SettingsTab:AddSubTab("Config")
autosaveWrap(ConfigSub)
ConfigSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs", Options = {}, Default = "",
    Flag = "be_config_sel", Callback = function(v) selectedConfig = v end,
})
local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
        configDropdown:Refresh()
    end
end
local configInput = ConfigSub:AddInput({
    Name = "Config Name", Default = "", Placeholder = "Enter config name...",
    Flag = "be_config_name",
})
ConfigSub:AddDivider()
ConfigSub:AddButton({
    Name = "Save Config", Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then notify("Config", "Enter a name first!", "warning") return end
        if Library:SaveConfig(name) then
            refreshConfigList()
            notify("Config", "Saved: " .. name, "success")
        else
            notify("Config", "Save failed!", "error")
        end
    end,
})
ConfigSub:AddButton({
    Name = "Load Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning") return
        end
        if Library:LoadConfig(selectedConfig) then
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Failed to load!", "error")
        end
    end,
})
ConfigSub:AddButton({
    Name = "Delete Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning") return
        end
        Library:DeleteConfig(selectedConfig)
        local old = selectedConfig
        selectedConfig = ""
        refreshConfigList()
        notify("Config", "Deleted: " .. old, "info")
    end,
})
ConfigSub:AddDivider()
ConfigSub:AddSection("Script")
ConfigSub:AddButton({
    Name = "Unload Script", Primary = true,
    Callback = function()
        getgenv().__beGen = (tonumber(getgenv().__beGen) or 1) + 1
        for _, c in ipairs(conns) do
            pcall(function()
                if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
            end)
        end
        stopFly()
        applyNoclip(false)
        for _, d in ipairs(drawings) do pcall(function() d:Remove() end) end
        table.clear(drawings)
        pcall(function() Library:DestroyAll() end)
        for _, g in ipairs({ game:GetService("CoreGui"), LP:FindFirstChild("PlayerGui") }) do
            if g then
                local old = g:FindFirstChild("ExlumiaaHub")
                if old then pcall(function() old:Destroy() end) end
            end
        end
        print("[ExlumiaaHub] Barber Empire unloaded")
    end,
})
ConfigSub:AddSection("Info")
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })

refreshConfigList()
pcall(function() Library:LoadConfig("default") end)

-- a saved config must never start a farm / fly / noclip loop on load
for _, k in ipairs({ "autoCut", "autoCall", "autoCoins", "autoDrops", "autoVideo",
    "autoSpin", "buyBuild", "buySkills", "buyChair", "buyTools", "buyStaff",
    "flyEnabled", "noclip" }) do
    Config[k] = false
end
for _, t in ipairs(toggleRefs) do
    pcall(function() t:Set(false) end)
end

-- debug handle for live verification
getgenv().__be = {
    Config = Config,
    cashNow = cashNow,
    claimTick = claimTick,
    collectTips = collectTips,
    buyTick = buyTick,
    postVideo = postVideo,
    ownPlot = ownPlot,
    tpTo = tpTo,
    stealFrom = stealFrom,
    getCutStation = getCutStation,
    cutActive = cutActive,
}

print("[ExlumiaaHub] Barber Empire loaded | cash=" .. tostring(math.floor(cashNow()))
    .. " | plot=" .. tostring(ownPlot() and ownPlot().Name))
