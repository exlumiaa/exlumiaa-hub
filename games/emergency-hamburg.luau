-- Emergency Hamburg - Exlumiaa Hub
-- universe 2992873140 / place 7711635737
--
-- Client-side only. ESP, aimbot, silent aim, triggerbot, fly, noclip,
-- speed, teleport, config.
--
-- This game ships a client-side anti-cheat that REPORTS property changes to
-- the server (WalkSpeed > 20, JumpHeight > 4, body movers, banned GUI names,
-- CoreGui reachable). Its report events are plain Lua tables, so the shield
-- below replaces their `fire` with a no-op. Nothing is sent, nothing to evade.

if tostring(game.GameId) ~= "2992873140" then return end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local GEN = (tonumber(getgenv().__ehGen) or 0) + 1
getgenv().__ehGen = GEN
local function stale() return (tonumber(getgenv().__ehGen) or 0) ~= GEN end

-- reloads leave Drawing objects behind; wipe them before creating ours
pcall(cleardrawcache)

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_emergencyhamburg.txt"
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
            brand = "EMERGENCY HAMBURG",
            guiName = "EmergencyHamburgKeyGate",
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
-- CONFIG
-- ================================================================
local Config = {
    espEnabled = false,
    espChams = true,
    espBox = true,
    espName = true,
    espDistance = true,
    espHealth = true,
    espTracer = false,
    espTeamCheck = false,
    espMaxDist = 600,
    vehEsp = false,
    vehMaxDist = 400,
    locRobberies = false,
    locDeliveries = false,
    locEmergencies = false,
    locCameras = false,

    aimEnabled = false,
    aimFov = 120,
    aimSmooth = 5,
    aimWallCheck = true,
    aimPred = true,
    aimPredPct = 100,
    aimPart = "Head",
    aimMaxDist = 400,
    fovCircle = true,

    silentEnabled = false,
    silentFov = 180,

    triggerEnabled = false,
    triggerDelay = 60,

    flyEnabled = false,
    flySpeed = 60,
    flyMaxHeight = 340,

    speedEnabled = false,
    walkSpeed = 32,

    noclip = false,
    infStamina = false,
}

-- ================================================================
-- HELPERS
-- ================================================================
local function char()
    return LP.Character
end

local function hrp()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function hum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function alive()
    local h = hum()
    return h ~= nil and h.Health > 0
end

local function cam()
    return Workspace.CurrentCamera
end

local function teamColor(pl)
    local ok, t = pcall(function() return pl.Team.TeamColor.Color end)
    if ok and t then return t end
    return Color3.fromRGB(255, 255, 255)
end

-- ================================================================
-- NETWORKING + ANTI-CHEAT SHIELD
-- ================================================================
local net = require(RS.Code.modules.networking)
local ClientEvents = net.ClientEvents

local AC_EVENTS = {
    "9790f8cd-5034-4e9e-8b37-4160b213751e", -- generic property report
    "dbaecdb7-a66b-4d48-908f-066e137571aa", -- CoreGui probe
    "de774215-b957-4c2b-8400-ca2d84116c64", -- banned service
    "d160d719-5b6e-4fee-8a55-f9b6e55710a5", -- banned GUI name
    "5dcc5357-77b1-4209-ad25-96fd42f8f601", -- ban log line
}
local acBackup = {}
for _, id in ipairs(AC_EVENTS) do
    local ev = ClientEvents[id]
    if ev and type(ev.fire) == "function" then
        -- keep the real sender across reloads so wrappers never stack
        local orig = rawget(ev, "__eh_orig") or ev.fire
        rawset(ev, "__eh_orig", orig)
        acBackup[id] = orig
        ev.fire = function() end
    end
end

local function restoreShield()
    for id, fn in pairs(acBackup) do
        local ev = ClientEvents[id]
        if ev then ev.fire = fn end
    end
end

-- ================================================================
-- PRODUCER (game state)
-- ================================================================
local producer
do
    local ok, mod = pcall(require, LP.PlayerScripts.Code.producer)
    if ok and type(mod) == "table" then producer = mod.producer end
end

local function state()
    if not producer then return nil end
    local ok, s = pcall(function() return producer:getState() end)
    return ok and s or nil
end

-- ================================================================
-- TARGETING
-- ================================================================
local function aimPartOf(c)
    if not c then return nil end
    return c:FindFirstChild(Config.aimPart)
        or c:FindFirstChild("Head")
        or c:FindFirstChild("HumanoidRootPart")
end

local function isEnemy(pl)
    if pl == LP then return false end
    if Config.espTeamCheck and LP.Team and pl.Team == LP.Team then return false end
    local c = pl.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    return true
end

local function visibleFromCamera(part)
    if not Config.aimWallCheck then return true end
    local camera = cam()
    if not camera then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    local origin = camera.CFrame.Position
    local hit = Workspace:Raycast(origin, part.Position - origin, params)
    if not hit then return true end
    return hit.Instance:IsDescendantOf(part.Parent)
end

local function bulletVelocity()
    local c = LP.Character
    local tool = c and c:FindFirstChildOfClass("Tool")
    local v = tool and tool:GetAttribute("BulletVelocity")
    return (type(v) == "number" and v > 0) and v or 600
end

local function predictedPos(pl, part)
    local pos = part.Position
    if not Config.aimPred then return pos end
    local root = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    if not root then return pos end
    local camera = cam()
    if not camera then return pos end
    local dist = (pos - camera.CFrame.Position).Magnitude
    local t = dist / bulletVelocity()
    return pos + root.AssemblyLinearVelocity * t * (Config.aimPredPct / 100)
end

local function bestTarget(fovDegrees)
    local camera = cam()
    if not camera then return nil end
    local origin = camera.CFrame.Position
    local look = camera.CFrame.LookVector
    local best, bestScore = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if isEnemy(pl) then
            local part = aimPartOf(pl.Character)
            if part then
                local pos = predictedPos(pl, part)
                local dist = (pos - origin).Magnitude
                if dist <= Config.aimMaxDist then
                    local dir = (pos - origin).Unit
                    local ang = math.deg(math.acos(math.clamp(look:Dot(dir), -1, 1)))
                    if ang <= fovDegrees then
                        local score = ang + dist * 0.02
                        if score < bestScore and visibleFromCamera(part) then
                            best, bestScore = pl, score
                        end
                    end
                end
            end
        end
    end
    return best
end

local function shotOrigin()
    local c = LP.Character
    if c then
        local tool = c:FindFirstChildOfClass("Tool")
        if tool then
            local m = tool:FindFirstChild("Muzzle", true)
            if m and m:IsA("Attachment") then return m.WorldPosition end
            local h = tool:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then return h.Position end
        end
    end
    local camera = cam()
    return camera and camera.CFrame.Position or nil
end

-- ================================================================
-- SILENT AIM
-- ================================================================
local SHOT_ID = "1013ed52-5286-4d1d-b0b9-9f5ae11ad8fb"
local shotEvent = ClientEvents[SHOT_ID]
local shotOriginal = shotEvent and (rawget(shotEvent, "__eh_orig") or shotEvent.fire)

if shotEvent and shotOriginal then
    rawset(shotEvent, "__eh_orig", shotOriginal)
    shotEvent.fire = function(self, id, dir, fp, tick)
        if Config.silentEnabled and not stale() then
            local target = bestTarget(Config.silentFov)
            if target then
                local part = aimPartOf(target.Character)
                local origin = shotOrigin()
                if part and origin then
                    local aim = predictedPos(target, part)
                    local v = aim - origin
                    if v.Magnitude > 0.1 then dir = v.Unit end
                end
            end
        end
        return shotOriginal(self, id, dir, fp, tick)
    end
end

-- ================================================================
-- DRAWING POOL
-- ================================================================
local drawObjects = {}

local function newDraw(cls, props)
    local ok, d = pcall(function() return Drawing.new(cls) end)
    if not ok or not d then return nil end
    for k, v in pairs(props) do pcall(function() d[k] = v end) end
    d.Visible = false
    drawObjects[#drawObjects + 1] = d
    return d
end

local function killAllDrawings()
    for _, d in ipairs(drawObjects) do pcall(function() d:Remove() end) end
    table.clear(drawObjects)
end

local function projectBox(cf, size)
    local camera = cam()
    if not camera then return nil end
    local vp = camera.ViewportSize
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local behind = 0
    for _, sx in ipairs({ -0.5, 0.5 }) do
        for _, sy in ipairs({ -0.5, 0.5 }) do
            for _, sz in ipairs({ -0.5, 0.5 }) do
                local wp = cf:PointToWorldSpace(Vector3.new(size.X * sx, size.Y * sy, size.Z * sz))
                local sp = camera:WorldToViewportPoint(wp)
                if sp.Z <= 0 then behind += 1 end
                minX = math.min(minX, sp.X); maxX = math.max(maxX, sp.X)
                minY = math.min(minY, sp.Y); maxY = math.max(maxY, sp.Y)
            end
        end
    end
    if behind == 8 then return nil end
    -- fully outside the viewport
    if maxX < 0 or minX > vp.X or maxY < 0 or minY > vp.Y then return nil end
    return minX, minY, maxX - minX, maxY - minY
end

-- ================================================================
-- ESP — PLAYERS
-- ================================================================
local playerEsp = {}

local function ensurePlayerEsp(pl)
    local e = playerEsp[pl]
    if e then return e end
    e = {
        box = newDraw("Square", { Thickness = 1, Filled = false }),
        name = newDraw("Text", { Size = 13, Center = true, Outline = true, Font = 2 }),
        dist = newDraw("Text", { Size = 12, Center = true, Outline = true, Font = 2 }),
        tracer = newDraw("Line", { Thickness = 1 }),
        health = newDraw("Square", { Thickness = 0, Filled = true }),
    }
    playerEsp[pl] = e
    return e
end

local function hidePlayerEsp(e)
    if not e then return end
    for _, d in pairs(e) do
        if d then pcall(function() d.Visible = false end) end
    end
end

local function updatePlayerEsp()
    local camera = cam()
    if not camera then return end
    local myPos = camera.CFrame.Position
    local vp = camera.ViewportSize

    if not Config.espEnabled then
        for _, e in pairs(playerEsp) do hidePlayerEsp(e) end
        return
    end

    for _, pl in ipairs(Players:GetPlayers()) do
        local e = ensurePlayerEsp(pl)
        if not isEnemy(pl) then
            hidePlayerEsp(e)
        else
            local c = pl.Character
            local part = aimPartOf(c)
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local ok = false
            if c and part and h and h.Health > 0 then
                local dist = (part.Position - myPos).Magnitude
                if dist <= Config.espMaxDist then
                    local cf, size = c:GetBoundingBox()
                    local x, y, w, hh = projectBox(cf, size)
                    if x then
                        ok = true
                        local col = teamColor(pl)
                        if e.box then
                            e.box.Visible = Config.espBox
                            e.box.Color = col
                            e.box.Position = Vector2.new(x, y)
                            e.box.Size = Vector2.new(w, hh)
                        end
                        if e.name then
                            e.name.Visible = Config.espName
                            e.name.Text = pl.Name
                            e.name.Color = col
                            e.name.Position = Vector2.new(x + w / 2, y - 16)
                        end
                        if e.dist then
                            e.dist.Visible = Config.espDistance
                            e.dist.Text = string.format("%dm", math.floor(dist))
                            e.dist.Color = col
                            e.dist.Position = Vector2.new(x + w / 2, y + hh + 2)
                        end
                        if e.tracer then
                            e.tracer.Visible = Config.espTracer
                            e.tracer.From = Vector2.new(vp.X / 2, vp.Y)
                            e.tracer.To = Vector2.new(x + w / 2, y + hh)
                            e.tracer.Color = col
                        end
                        if e.health then
                            e.health.Visible = Config.espHealth
                            local pct = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
                            local barH = hh * pct
                            e.health.Size = Vector2.new(2, barH)
                            e.health.Position = Vector2.new(x - 5, y + (hh - barH))
                            e.health.Color = Color3.fromRGB(80, 255, 120):Lerp(Color3.fromRGB(255, 60, 60), 1 - pct)
                        end
                    end
                end
            end
            if not ok then hidePlayerEsp(e) end
        end
    end
end

-- ================================================================
-- ESP — VEHICLES + LOCATIONS
-- ================================================================
local worldEsp = {}

local function ensureWorldEsp(key)
    local e = worldEsp[key]
    if e then return e end
    e = {
        text = newDraw("Text", { Size = 12, Center = true, Outline = true, Font = 2 }),
    }
    worldEsp[key] = e
    return e
end

local function drawWorldLabel(key, pos, text, color)
    local camera = cam()
    if not camera then return end
    local sp, onScreen = camera:WorldToViewportPoint(pos)
    local e = ensureWorldEsp(key)
    if not e or not e.text then return end
    if onScreen and sp.Z > 0 then
        e.text.Visible = true
        e.text.Text = text
        e.text.Color = color
        e.text.Position = Vector2.new(sp.X, sp.Y)
    else
        e.text.Visible = false
    end
end

local function clearWorldEsp()
    for _, e in pairs(worldEsp) do
        if e.text then pcall(function() e.text.Visible = false end) end
    end
end

local function updateWorldEsp()
    if not Config.vehEsp and not Config.locRobberies and not Config.locDeliveries
        and not Config.locEmergencies and not Config.locCameras then
        clearWorldEsp()
        return
    end
    local camera = cam()
    if not camera then return end
    local myPos = camera.CFrame.Position

    if Config.vehEsp then
        local folder = Workspace:FindFirstChild("Vehicles")
        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                local ok, cf, size = pcall(function()
                    local c, s = v:GetBoundingBox()
                    return c, s
                end)
                if ok and cf then
                    local dist = (cf.Position - myPos).Magnitude
                    if dist <= Config.vehMaxDist then
                        local name = v:GetAttribute("Config") or v.Name
                        local locked = v:GetAttribute("Locked")
                        local tag = (locked == true) and " [LOCKED]" or ""
                        drawWorldLabel("v_" .. v.Name, cf.Position + Vector3.new(0, size.Y / 2, 0),
                            string.format("%s%s  %dm", tostring(name), tag, math.floor(dist)),
                            Color3.fromRGB(255, 200, 80))
                    else
                        local e = worldEsp["v_" .. v.Name]
                        if e and e.text then e.text.Visible = false end
                    end
                end
            end
        end
    end

    local function folderLabels(folderName, enabled, color, prefix)
        local folder = Workspace:FindFirstChild(folderName)
        if not folder then return end
        for _, obj in ipairs(folder:GetChildren()) do
            local key = prefix .. obj.Name
            if enabled then
                local ok, pos = pcall(function()
                    if obj:IsA("BasePart") then return obj.Position end
                    local p = obj:FindFirstChildWhichIsA("BasePart", true)
                    if p then return p.Position end
                    return obj:GetPivot().Position
                end)
                if ok and pos then
                    local dist = (pos - myPos).Magnitude
                    if dist <= Config.espMaxDist then
                        drawWorldLabel(key, pos + Vector3.new(0, 3, 0),
                            string.format("%s  %dm", obj.Name, math.floor(dist)), color)
                    else
                        local e = worldEsp[key]
                        if e and e.text then e.text.Visible = false end
                    end
                end
            else
                local e = worldEsp[key]
                if e and e.text then e.text.Visible = false end
            end
        end
    end

    folderLabels("Robberies", Config.locRobberies, Color3.fromRGB(255, 90, 90), "r_")
    folderLabels("DeliveryDestinations", Config.locDeliveries, Color3.fromRGB(90, 220, 255), "d_")
    folderLabels("Emergencies", Config.locEmergencies, Color3.fromRGB(255, 140, 0), "e_")
    folderLabels("SecurityCameras", Config.locCameras, Color3.fromRGB(180, 180, 255), "c_")
end

-- ================================================================
-- GAME ESP (chams) + beam cleanup
-- ================================================================
local function setChams(on)
    if not producer then return end
    pcall(function() producer.setEspEnabled(on and true or false) end)
end

local function killBeams()
    for _, pl in ipairs(Players:GetPlayers()) do
        local c = pl.Character
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                if d.Name == "EspBeam" then pcall(function() d:Destroy() end) end
            end
        end
    end
end

-- ================================================================
-- MOVEMENT
-- ================================================================
local flyAtt, flyAP, flyAO

local function stopFly()
    if flyAP then pcall(function() flyAP:Destroy() end); flyAP = nil end
    if flyAO then pcall(function() flyAO:Destroy() end); flyAO = nil end
    if flyAtt then pcall(function() flyAtt:Destroy() end); flyAtt = nil end
end

local function startFly()
    stopFly()
    local h = hrp()
    if not h then return end
    flyAtt = Instance.new("Attachment")
    flyAtt.Parent = h
    flyAP = Instance.new("AlignPosition")
    flyAP.Attachment0 = flyAtt
    flyAP.Mode = Enum.PositionAlignmentMode.OneAttachment
    flyAP.MaxForce = 1e6
    flyAP.Responsiveness = 5
    flyAP.Position = h.Position
    flyAP.Parent = h
    flyAO = Instance.new("AlignOrientation")
    flyAO.Attachment0 = flyAtt
    flyAO.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyAO.MaxTorque = 1e6
    flyAO.Responsiveness = 5
    flyAO.Parent = h
end

local function stepFly(dt)
    if not flyAP or not flyAO then return end
    local camera = cam()
    if not camera then return end
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
    local pos = flyAP.Position
    if dir.Magnitude > 0 then
        pos += dir.Unit * Config.flySpeed * dt
    end
    pos = Vector3.new(pos.X, math.min(pos.Y, Config.flyMaxHeight), pos.Z)
    flyAP.Position = pos
    local look = camera.CFrame.LookVector
    flyAO.CFrame = CFrame.lookAt(Vector3.zero, Vector3.new(look.X, 0, look.Z))
end

local function stepNoclip()
    local c = LP.Character
    if not c then return end
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function() d.CanCollide = not Config.noclip end)
        end
    end
end

local function applySpeed()
    local h = hum()
    if not h then return end
    if Config.speedEnabled then
        h.WalkSpeed = Config.walkSpeed
    else
        h.WalkSpeed = 20
    end
end

-- Stamina lives entirely on the client: CharacterStaminaController keeps a local
-- 0..1 value and every write goes through setStamina, so pinning that is enough.
local staminaClass
pcall(function()
    local mod = require(LP.PlayerScripts.Code.controllers.character.characterStaminaController)
    staminaClass = mod and mod.CharacterStaminaController
end)
local staminaSetOriginal = staminaClass and staminaClass.setStamina

local function applyStamina()
    if not staminaClass or not staminaSetOriginal then return end
    if Config.infStamina then
        staminaClass.setStamina = function(self) self.stamina = 1 end
    else
        staminaClass.setStamina = staminaSetOriginal
    end
end

-- ================================================================
-- TELEPORT
-- ================================================================
local function teleportTo(pos)
    local h = hrp()
    if not h or not pos then return false end
    h.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    return true
end

local function teleportToCursor()
    local camera = cam()
    if not camera then return false end
    local mouse = UIS:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    local hit = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if not hit then return false end
    return teleportTo(hit.Position)
end

local function teleportToPlayer(name)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and string.find(string.lower(pl.Name), string.lower(name or ""), 1, true) then
            local h = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
            if h then return teleportTo(h.Position) end
        end
    end
    return false
end

-- ================================================================
-- TRIGGERBOT
-- ================================================================
local VIM = game:GetService("VirtualInputManager")
local lastTrigger = 0

local function clickMouse()
    local camera = cam()
    if not camera then return end
    local vp = camera.ViewportSize
    pcall(function()
        VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 0)
        VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 0)
    end)
end

local function crosshairTarget()
    local camera = cam()
    if not camera then return nil end
    local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    local hit = Workspace:Raycast(ray.Origin, ray.Direction * 600, params)
    if not hit then return nil end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character and hit.Instance:IsDescendantOf(pl.Character) then
            local h = pl.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then return pl end
        end
    end
    return nil
end

local function stepTrigger()
    if not Config.triggerEnabled then return end
    if os.clock() - lastTrigger < Config.triggerDelay / 1000 then return end
    if not alive() then return end
    local c = LP.Character
    local tool = c and c:FindFirstChildOfClass("Tool")
    if not tool then return end
    if crosshairTarget() then
        lastTrigger = os.clock()
        clickMouse()
    end
end

-- ================================================================
-- FOV CIRCLE
-- ================================================================
local fovCircle = newDraw("Circle", { Thickness = 1, Filled = false, NumSides = 64 })

local function updateFov()
    if not fovCircle then return end
    local camera = cam()
    if not camera then return end
    local show = (Config.aimEnabled or Config.silentEnabled) and Config.fovCircle
    fovCircle.Visible = show
    if show then
        fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        fovCircle.Radius = Config.aimFov
        fovCircle.Color = Config.aimEnabled and Color3.fromRGB(120, 220, 255) or Color3.fromRGB(255, 200, 80)
    end
end

-- ================================================================
-- DETECTION MONITOR
-- ================================================================
local detectionCount = 0
local lastDetectionCheck = 0

local function checkDetections()
    if os.clock() - lastDetectionCheck < 2 then return end
    lastDetectionCheck = os.clock()
    local s = state()
    local d = s and s.playerData and s.playerData.detections
    if not d then return end
    local n = 0
    for _ in pairs(d) do n += 1 end
    detectionCount = n
end

-- ================================================================
-- MAIN LOOP
-- ================================================================
local worldTick = 0

local conn
conn = RunService.RenderStepped:Connect(function(dt)
    if stale() then
        conn:Disconnect()
        return
    end

    updatePlayerEsp()
    updateFov()
    stepTrigger()
    checkDetections()

    worldTick += 1
    if worldTick % 6 == 0 then
        updateWorldEsp()
        if Config.espChams then killBeams() end
    end

    if Config.aimEnabled then
        local target = bestTarget(Config.aimFov)
        if target then
            local part = aimPartOf(target.Character)
            local camera = cam()
            if part and camera then
                local goal = CFrame.lookAt(camera.CFrame.Position, predictedPos(target, part))
                camera.CFrame = camera.CFrame:Lerp(goal, 1 / math.max(Config.aimSmooth, 1))
            end
        end
    end

    if Config.flyEnabled then
        if not flyAP then startFly() end
        stepFly(dt)
    elseif flyAP then
        stopFly()
    end

    if Config.noclip then stepNoclip() end
end)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if stale() then return end
    applySpeed()
    if Config.flyEnabled then startFly() end
end)

Players.PlayerRemoving:Connect(function(pl)
    local e = playerEsp[pl]
    if e then
        hidePlayerEsp(e)
        playerEsp[pl] = nil
    end
end)

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
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library or stale() then return end

Library.ConfigFolder = "exlumiaa/emergency-hamburg"

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
    BrandSubtitle = "Emergency Hamburg",
    Size = UDim2.fromOffset(540, 460),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Emergency Hamburg",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

local function notify(title, content, ntype)
    pcall(function()
        Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 })
    end)
end

-- ---------------- VISUALS ----------------
local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })

local PlayersSub = VisualTab:AddSubTab("Players")
autosaveWrap(PlayersSub)
PlayersSub:AddSection("ESP")
PlayersSub:AddToggle({ Name = "ESP Enabled", Flag = "eh_esp", Default = false,
    Callback = function(v) Config.espEnabled = v end })
PlayersSub:AddToggle({ Name = "Game Chams + Nameplate", Flag = "eh_chams", Default = true,
    Callback = function(v)
        Config.espChams = v
        setChams(v and Config.espEnabled)
    end })
PlayersSub:AddToggle({ Name = "Box", Flag = "eh_box", Default = true,
    Callback = function(v) Config.espBox = v end })
PlayersSub:AddToggle({ Name = "Name", Flag = "eh_name", Default = true,
    Callback = function(v) Config.espName = v end })
PlayersSub:AddToggle({ Name = "Distance", Flag = "eh_dist", Default = true,
    Callback = function(v) Config.espDistance = v end })
PlayersSub:AddToggle({ Name = "Health Bar", Flag = "eh_health", Default = true,
    Callback = function(v) Config.espHealth = v end })
PlayersSub:AddToggle({ Name = "Tracer", Flag = "eh_tracer", Default = false,
    Callback = function(v) Config.espTracer = v end })
PlayersSub:AddToggle({ Name = "Team Check", Flag = "eh_team", Default = false,
    Callback = function(v) Config.espTeamCheck = v end })
PlayersSub:AddSlider({ Name = "Max Distance", Min = 50, Max = 2000, Default = 600, Suffix = " studs",
    Flag = "eh_maxdist", Callback = function(v) Config.espMaxDist = v end })

local VehSub = VisualTab:AddSubTab("Vehicles")
autosaveWrap(VehSub)
VehSub:AddSection("Vehicles")
VehSub:AddToggle({ Name = "Vehicle ESP", Flag = "eh_veh", Default = false,
    Callback = function(v) Config.vehEsp = v end })
VehSub:AddSlider({ Name = "Max Distance", Min = 50, Max = 1500, Default = 400, Suffix = " studs",
    Flag = "eh_vehdist", Callback = function(v) Config.vehMaxDist = v end })

local LocSub = VisualTab:AddSubTab("Locations")
autosaveWrap(LocSub)
LocSub:AddSection("World")
LocSub:AddToggle({ Name = "Robberies", Flag = "eh_loc_rob", Default = false,
    Callback = function(v) Config.locRobberies = v end })
LocSub:AddToggle({ Name = "Delivery Points", Flag = "eh_loc_del", Default = false,
    Callback = function(v) Config.locDeliveries = v end })
LocSub:AddToggle({ Name = "Emergencies", Flag = "eh_loc_emg", Default = false,
    Callback = function(v) Config.locEmergencies = v end })
LocSub:AddToggle({ Name = "Security Cameras", Flag = "eh_loc_cam", Default = false,
    Callback = function(v) Config.locCameras = v end })

-- ---------------- COMBAT ----------------
local CombatTab = Window:AddTab({ Name = "Combat", Icon = "crosshair", Subtitle = "Aim" })

local AimSub = CombatTab:AddSubTab("Aimbot")
autosaveWrap(AimSub)
AimSub:AddSection("Aimbot")
AimSub:AddToggle({ Name = "Aimbot", Flag = "eh_aim", Default = false,
    Callback = function(v) Config.aimEnabled = v end })
AimSub:AddToggle({ Name = "Wall Check", Flag = "eh_aim_wall", Default = true,
    Callback = function(v) Config.aimWallCheck = v end })
AimSub:AddToggle({ Name = "Show FOV Circle", Flag = "eh_fov_circle", Default = true,
    Callback = function(v) Config.fovCircle = v end })
AimSub:AddSlider({ Name = "FOV", Min = 20, Max = 600, Default = 120, Suffix = " px",
    Flag = "eh_aim_fov", Callback = function(v) Config.aimFov = v end })
AimSub:AddSlider({ Name = "Smoothing", Min = 1, Max = 20, Default = 5,
    Flag = "eh_aim_smooth", Callback = function(v) Config.aimSmooth = v end })
AimSub:AddSlider({ Name = "Max Distance", Min = 50, Max = 1000, Default = 400, Suffix = " studs",
    Flag = "eh_aim_dist", Callback = function(v) Config.aimMaxDist = v end })
AimSub:AddDropdown({ Name = "Target Part", Options = { "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso" },
    Default = "Head", Flag = "eh_aim_part",
    Callback = function(v) if type(v) == "string" then Config.aimPart = v end end })
AimSub:AddToggle({ Name = "Prediction", Flag = "eh_aim_pred", Default = true,
    Callback = function(v) Config.aimPred = v end })
AimSub:AddSlider({ Name = "Prediction Amount", Min = 0, Max = 200, Default = 100, Suffix = "%",
    Flag = "eh_aim_predpct", Callback = function(v) Config.aimPredPct = v end })

local SilentSub = CombatTab:AddSubTab("Silent Aim")
autosaveWrap(SilentSub)
SilentSub:AddSection("Silent Aim")
SilentSub:AddToggle({ Name = "Silent Aim", Flag = "eh_silent", Default = false,
    Callback = function(v) Config.silentEnabled = v end })
SilentSub:AddSlider({ Name = "Silent FOV", Min = 10, Max = 180, Default = 180, Suffix = " deg",
    Flag = "eh_silent_fov", Callback = function(v) Config.silentFov = v end })

local TrigSub = CombatTab:AddSubTab("Triggerbot")
autosaveWrap(TrigSub)
TrigSub:AddSection("Triggerbot")
TrigSub:AddToggle({ Name = "Triggerbot", Flag = "eh_trigger", Default = false,
    Callback = function(v) Config.triggerEnabled = v end })
TrigSub:AddSlider({ Name = "Delay", Min = 0, Max = 500, Default = 60, Suffix = " ms",
    Flag = "eh_trigger_delay", Callback = function(v) Config.triggerDelay = v end })

-- ---------------- MOVEMENT ----------------
local MoveTab = Window:AddTab({ Name = "Movement", Icon = "move", Subtitle = "Player" })

local FlySub = MoveTab:AddSubTab("Fly")
autosaveWrap(FlySub)
FlySub:AddSection("Fly")
FlySub:AddToggle({ Name = "Fly (WASD / Space / Ctrl)", Flag = "eh_fly", Default = false,
    Callback = function(v)
        Config.flyEnabled = v
        if v then startFly() else stopFly() end
    end })
FlySub:AddSlider({ Name = "Speed", Min = 10, Max = 300, Default = 60,
    Flag = "eh_fly_speed", Callback = function(v) Config.flySpeed = v end })
FlySub:AddSlider({ Name = "Max Height", Min = 50, Max = 1000, Default = 340,
    Flag = "eh_fly_h", Callback = function(v) Config.flyMaxHeight = v end })

local WalkSub = MoveTab:AddSubTab("Speed")
autosaveWrap(WalkSub)
WalkSub:AddSection("Speed")
WalkSub:AddToggle({ Name = "Speed Hack", Flag = "eh_speed", Default = false,
    Callback = function(v)
        Config.speedEnabled = v
        applySpeed()
    end })
WalkSub:AddSlider({ Name = "Walk Speed", Min = 20, Max = 150, Default = 32,
    Flag = "eh_walkspeed", Callback = function(v)
        Config.walkSpeed = v
        applySpeed()
    end })
WalkSub:AddToggle({ Name = "Noclip", Flag = "eh_noclip", Default = false,
    Callback = function(v) Config.noclip = v end })
WalkSub:AddToggle({ Name = "Infinite Stamina", Flag = "eh_stamina", Default = false,
    Callback = function(v)
        Config.infStamina = v
        applyStamina()
    end })

local TpSub = MoveTab:AddSubTab("Teleport")
autosaveWrap(TpSub)
TpSub:AddSection("Teleport")
TpSub:AddButton({ Name = "Teleport to Cursor", Primary = true,
    Callback = function()
        if teleportToCursor() then notify("Teleport", "Done", "success")
        else notify("Teleport", "No ground under cursor", "warning") end
    end })
local tpInput = TpSub:AddInput({ Name = "Player Name", Default = "", Placeholder = "username",
    Flag = "eh_tp_name" })
TpSub:AddButton({ Name = "Teleport to Player",
    Callback = function()
        local name = tpInput:Get()
        if name and name ~= "" and teleportToPlayer(name) then
            notify("Teleport", "Done", "success")
        else
            notify("Teleport", "Player not found", "warning")
        end
    end })

-- ---------------- SETTINGS ----------------
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })

local SafeSub = SettingsTab:AddSubTab("Safety")
autosaveWrap(SafeSub)
SafeSub:AddSection("Anti-Cheat")
local detectLabel = SafeSub:AddLabel({ Text = "Detections: 0" })
SafeSub:AddButton({ Name = "Refresh Status",
    Callback = function()
        lastDetectionCheck = 0
        checkDetections()
        pcall(function() detectLabel:Set("Detections: " .. tostring(detectionCount)) end)
    end })
SafeSub:AddButton({ Name = "Panic — Disable All", Primary = true,
    Callback = function()
        Config.aimEnabled = false
        Config.silentEnabled = false
        Config.triggerEnabled = false
        Config.flyEnabled = false
        Config.speedEnabled = false
        Config.noclip = false
        Config.espEnabled = false
        Config.vehEsp = false
        stopFly()
        applySpeed()
        notify("Panic", "All features disabled", "info")
    end })

local ConfigSub = SettingsTab:AddSubTab("Config")
autosaveWrap(ConfigSub)
ConfigSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({ Name = "Saved Configs", Options = {}, Default = "",
    Flag = "eh_config_sel", Callback = function(v) selectedConfig = v end })

local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
        configDropdown:Refresh()
    end
end

local configInput = ConfigSub:AddInput({ Name = "Config Name", Default = "",
    Placeholder = "Enter config name...", Flag = "eh_config_name" })

ConfigSub:AddDivider()
ConfigSub:AddButton({ Name = "Save Config", Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then notify("Config", "Enter a name first!", "warning") return end
        if Library:SaveConfig(name) then
            refreshConfigList()
            notify("Config", "Saved: " .. name, "success")
        else
            notify("Config", "Save failed!", "error")
        end
    end })
ConfigSub:AddButton({ Name = "Load Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning") return
        end
        if Library:LoadConfig(selectedConfig) then
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Failed to load!", "error")
        end
    end })
ConfigSub:AddButton({ Name = "Delete Config",
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning") return
        end
        Library:DeleteConfig(selectedConfig)
        local old = selectedConfig
        selectedConfig = ""
        refreshConfigList()
        notify("Config", "Deleted: " .. old, "info")
    end })

ConfigSub:AddDivider()
ConfigSub:AddSection("Script")
ConfigSub:AddButton({ Name = "Unload Script", Primary = true,
    Callback = function()
        getgenv().__ehGen = (tonumber(getgenv().__ehGen) or 1) + 1
        pcall(function() conn:Disconnect() end)
        pcall(function() chamsConn:Disconnect() end)
        stopFly()
        setChams(false)
        killAllDrawings()
        restoreShield()
        if shotEvent and shotOriginal then shotEvent.fire = shotOriginal end
        local h = hum()
        if h then pcall(function() h.WalkSpeed = 20 end) end
        Config.infStamina = false
        applyStamina()
        pcall(function() Library:DestroyAll() end)
        for _, g in ipairs({ game:GetService("CoreGui"), LP:FindFirstChild("PlayerGui") }) do
            if g then
                local old = g:FindFirstChild("ExlumiaaHub")
                if old then pcall(function() old:Destroy() end) end
            end
        end
        print("[ExlumiaaHub] Emergency Hamburg unloaded")
    end })

ConfigSub:AddSection("Info")
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })

refreshConfigList()
pcall(function() Library:LoadConfig("default") end)

-- chams follow the ESP toggle, only touching the game when the state changes
local chamsOn = false
local chamsConn = RunService.Heartbeat:Connect(function()
    if stale() then return end
    local want = Config.espEnabled and Config.espChams
    if want == chamsOn then return end
    chamsOn = want
    setChams(want)
end)

print("[ExlumiaaHub] Emergency Hamburg loaded | shield=" .. tostring(next(acBackup) ~= nil)
    .. " shot=" .. tostring(shotOriginal ~= nil)
    .. " producer=" .. tostring(producer ~= nil))

-- debug handle for live verification
getgenv().__eh = {
    Config = Config,
    state = state,
    detectionCount = function() return detectionCount end,
    bestTarget = function(fov)
        local t = bestTarget(fov)
        return t and t.Name or nil
    end,
    shotOrigin = shotOrigin,
    applyStamina = applyStamina,
    staminaClass = function() return staminaClass end,
    esp = function()
        local tracked, visible, sample = 0, 0, nil
        for pl, e in pairs(playerEsp) do
            tracked += 1
            local v = e.box and e.box.Visible or false
            if v then visible += 1 end
            if not sample then
                sample = pl.Name
                    .. " box=" .. tostring(e.box and e.box.Visible)
                    .. " name=" .. tostring(e.name and e.name.Visible)
                    .. " text=" .. tostring(e.name and e.name.Text)
                    .. " pos=" .. tostring(e.box and e.box.Position)
            end
        end
        return { tracked = tracked, visible = visible, sample = sample }
    end,
}