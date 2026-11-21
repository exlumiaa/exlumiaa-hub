-- Summon a Pet Army - Exlumiaa Hub
-- universe 10772133952 / place 89695026030574
--
-- Client-side only. Wild/follower ESP, auto-farm (teleport + punch +
-- auto-summon), army automation (sell / equip best / buy slot), movement,
-- teleport, fullbright, config.
--
-- Farm is limited to unlocked zones: the server clamps a player past the
-- frontier back to the highest unlocked zone, so teleporting to Zone 12 only
-- works if it is unlocked.

if tostring(game.GameId) ~= "10772133952" then return end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local GEN = (tonumber(getgenv().__spaGen) or 0) + 1
getgenv().__spaGen = GEN
local function stale() return (tonumber(getgenv().__spaGen) or 0) ~= GEN end

pcall(cleardrawcache)

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_summonpetarmy.txt"
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
            brand = "SUMMON A PET ARMY",
            guiName = "SummonPetArmyKeyGate",
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
    -- visuals
    espEnabled = false,
    espTiers = { Easy = false, Hard = false, Rare = true, Boss = true, Chase = true, Divine = true },
    espMaxDist = 5000,
    espMaxCount = 40,
    espBox = true,
    espName = true,
    espInfo = true,
    espHealth = true,
    espTracer = false,
    espFollower = false,
    espAlert = true,
    fullbright = false,
    -- farm
    farmEnabled = false,
    farmZone = "Auto",
    farmTiers = { Easy = true, Hard = true, Rare = true, Boss = true, Chase = true, Divine = true },
    farmDelay = 1,
    farmOffset = 6,
    farmSummon = true,
    farmStopFull = true,
    farmRecover = 6,
    farmMaxFaints = 3,
    skipBeatenBoss = true,
    bossBlockTime = 370,
    powerMatch = true,
    powerRatio = 50,
    autoDrum = false,
    -- army
    autoSell = false,
    sellMaxRank = 1,
    sellMaxSize = 3,
    armyEquipBest = true,
    armyBuySlot = false,
    -- movement
    speedEnabled = false,
    walkSpeed = 60,
    jumpEnabled = false,
    jumpPower = 60,
    infJump = false,
    flyEnabled = false,
    flySpeed = 80,
    flyMaxHeight = 600,
    noclip = false,
    antiAfk = true,
}

-- ================================================================
-- GAME DATA
-- ================================================================
local CreatureData, Sizes, ArmyRules
pcall(function()
    CreatureData = require(RS:WaitForChild("Shared"):WaitForChild("CreatureData"))
end)
pcall(function()
    Sizes = require(RS:WaitForChild("Shared"):WaitForChild("Sizes"))
end)
pcall(function()
    ArmyRules = require(RS:WaitForChild("Shared"):WaitForChild("ArmyRules"))
end)

local Remotes = RS:WaitForChild("Remotes")
local Punch = Remotes:WaitForChild("Punch")
local Soul = Remotes:WaitForChild("Soul")
local SoulChoice = Remotes:WaitForChild("SoulChoice")
local ArmyAction = Remotes:WaitForChild("ArmyAction")
local ArmyFull = Remotes:WaitForChild("ArmyFull")

local TIER_RANK = { Easy = 1, Hard = 2, Rare = 3, Boss = 4, Chase = 5, Divine = 6, Shroud = 7 }
local TIER_COLOR = {
    Easy = Color3.fromRGB(190, 190, 190),
    Hard = Color3.fromRGB(120, 210, 130),
    Rare = Color3.fromRGB(90, 160, 255),
    Boss = Color3.fromRGB(255, 170, 60),
    Chase = Color3.fromRGB(200, 120, 255),
    Divine = Color3.fromRGB(255, 215, 0),
    Shroud = Color3.fromRGB(170, 90, 255),
}
local SIZE_NAME = { "Tiny", "Small", "Medium", "Big", "Huge" }
-- zone midpoints along Z (Config.Zones ZMin/ZMax); the map is a strip at X=0
local ZONE_MID = {
    [1] = -192, [2] = -769, [3] = -1452, [4] = -2470,
    [5] = -3728, [6] = -5277, [7] = -7041, [8] = -9134,
    [9] = -11232, [10] = -13801, [11] = -17250, [12] = -21000,
}
local ZONE_NAME = {
    [1] = "Meadow", [2] = "Canyon", [3] = "Peaks", [4] = "Hollow",
    [5] = "Ocean", [6] = "Volcano", [7] = "Jungle", [8] = "Isles",
    [9] = "Sanctum", [10] = "Godfall", [11] = "Void", [12] = "Beyond",
}
local CAMP_POS = Vector3.new(3000, 40, 150)

-- ================================================================
-- HELPERS
-- ================================================================
local function cam() return Workspace.CurrentCamera end

local function char()
    local c = LP.Character
    if c and c.Parent then return c end
    return nil
end

local function hrp()
    local c = char()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function tierOf(kind)
    local d = CreatureData and CreatureData[kind]
    if d and d.Tier then return d.Tier end
    return "Easy"
end

local function sizeName(size)
    return SIZE_NAME[math.clamp(tonumber(size) or 3, 1, #SIZE_NAME)]
end

local function creatureInfo(m)
    if not m or not m:IsA("Model") then return nil end
    local part = m.PrimaryPart
    if not part then return nil end
    local kind = m:GetAttribute("Kind")
    if not kind then return nil end
    local tier = m:GetAttribute("Tier") or tierOf(kind)
    return {
        kind = kind,
        tier = tier,
        display = m:GetAttribute("DisplayName") or m.Name,
        zone = m:GetAttribute("Zone"),
        hp = tonumber(m:GetAttribute("HP")) or 1,
        maxHp = math.max(1, tonumber(m:GetAttribute("MaxHP")) or 1),
        size = tonumber(m:GetAttribute("Size")) or 3,
        height = tonumber(m:GetAttribute("Height")) or 6,
        gid = m:GetAttribute("Gid"),
    }
end

local function unlockedZones()
    local out = { "Zone1" }
    for i = 2, 12 do
        if LP:GetAttribute("Zone" .. i .. "Unlocked") then out[#out + 1] = "Zone" .. i end
    end
    return out
end

local function farmZoneOptions()
    local out = { "Auto", "Current" }
    for _, z in ipairs(unlockedZones()) do out[#out + 1] = z end
    return out
end

local function zoneNumber(z)
    return tonumber(tostring(z or ""):match("%d+")) or 0
end

local function currentZoneId()
    local z = LP:GetAttribute("Zone")
    if type(z) == "string" and z:match("^Zone%d+$") then return z end
    return nil
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

local function hideEsp(e)
    if not e then return end
    for _, d in pairs(e) do
        if d then pcall(function() d.Visible = false end) end
    end
end

local espPool = {}

local function poolAt(i)
    local e = espPool[i]
    if e then return e end
    e = {
        box = newDraw("Square", { Thickness = 1, Filled = false }),
        hpb = newDraw("Square", { Thickness = 0, Filled = true }),
        hp = newDraw("Square", { Thickness = 0, Filled = true }),
        name = newDraw("Text", { Size = 13, Center = true, Outline = true, Font = 2 }),
        info = newDraw("Text", { Size = 12, Center = true, Outline = true, Font = 2 }),
        tracer = newDraw("Line", { Thickness = 1 }),
    }
    espPool[i] = e
    return e
end

-- projects the creature's vertical extent; cheaper than a bounding box sweep
local function project(part, height)
    local camera = cam()
    if not camera then return nil end
    local p = part.Position
    local top = camera:WorldToViewportPoint(p + Vector3.new(0, height * 0.5, 0))
    local bottom = camera:WorldToViewportPoint(p - Vector3.new(0, height * 0.5, 0))
    if top.Z <= 0 or bottom.Z <= 0 then return nil end
    local hPx = math.abs(bottom.Y - top.Y)
    if hPx < 6 or hPx > 3000 then return nil end
    local wPx = math.max(6, hPx * 0.55)
    local cx = (top.X + bottom.X) * 0.5
    return cx - wPx * 0.5, top.Y, wPx, hPx
end

-- ================================================================
-- ESP
-- ================================================================
local Library, notify
local seenGids = {}
local alertCount = 0

local function tierAllowed(tier, set)
    return set[tier] == true
end

local function collectWild()
    local w = Workspace:FindFirstChild("WildCreatures")
    if not w then return {} end
    local myPos = cam() and cam().CFrame.Position or Vector3.zero
    local list = {}
    for _, m in ipairs(w:GetChildren()) do
        local info = creatureInfo(m)
        if info and info.hp > 0 and tierAllowed(info.tier, Config.espTiers) then
            local dist = (m.PrimaryPart.Position - myPos).Magnitude
            if dist <= Config.espMaxDist then
                list[#list + 1] = { m = m, info = info, dist = dist }
            end
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

local function updateWildEsp()
    if not Config.espEnabled then
        for _, e in pairs(espPool) do hideEsp(e) end
        return
    end

    local camera = cam()
    if not camera then return end
    local vp = camera.ViewportSize
    local list = collectWild()
    local n = math.min(#list, Config.espMaxCount)
    local now = os.clock()

    for i = 1, n do
        local item = list[i]
        local info = item.info
        local e = poolAt(i)
        local x, y, w, h = project(item.m.PrimaryPart, info.height)
        if not x then
            hideEsp(e)
        else
            local col = TIER_COLOR[info.tier] or Color3.new(1, 1, 1)
            if info.tier == "Divine" then
                col = col:Lerp(Color3.new(1, 1, 1), (0.5 + 0.5 * math.sin(now * 4)) * 0.35)
            end

            if e.box then
                e.box.Visible = Config.espBox
                e.box.Color = col
                e.box.Position = Vector2.new(x, y)
                e.box.Size = Vector2.new(w, h)
            end
            if e.name then
                e.name.Visible = Config.espName
                e.name.Text = info.display .. " [" .. sizeName(info.size) .. "]"
                e.name.Color = col
                e.name.Position = Vector2.new(x + w * 0.5, y - 16)
            end
            if e.info then
                e.info.Visible = Config.espInfo
                e.info.Text = info.tier .. "  " .. math.floor(info.hp) .. "/" .. math.floor(info.maxHp)
                    .. "  " .. math.floor(item.dist) .. "m"
                e.info.Color = col
                e.info.Position = Vector2.new(x + w * 0.5, y + h + 2)
            end
            if e.hpb then
                e.hpb.Visible = Config.espHealth
                e.hpb.Color = Color3.fromRGB(20, 20, 20)
                e.hpb.Position = Vector2.new(x - 6, y)
                e.hpb.Size = Vector2.new(3, h)
            end
            if e.hp then
                local pct = math.clamp(info.hp / info.maxHp, 0, 1)
                e.hp.Visible = Config.espHealth
                e.hp.Size = Vector2.new(3, h * pct)
                e.hp.Position = Vector2.new(x - 6, y + h * (1 - pct))
                e.hp.Color = Color3.fromRGB(80, 255, 120):Lerp(Color3.fromRGB(255, 60, 60), 1 - pct)
            end
            if e.tracer then
                e.tracer.Visible = Config.espTracer
                e.tracer.From = Vector2.new(vp.X * 0.5, vp.Y)
                e.tracer.To = Vector2.new(x + w * 0.5, y + h)
                e.tracer.Color = col
            end
        end
    end

    for i = n + 1, #espPool do hideEsp(espPool[i]) end

    -- new Divine / Chase sighting
    if Config.espAlert then
        for _, item in ipairs(list) do
            local info = item.info
            if (info.tier == "Divine" or info.tier == "Chase") and info.gid and not seenGids[info.gid] then
                seenGids[info.gid] = now
                alertCount += 1
                if notify then
                    notify(
                        info.tier .. " in " .. tostring(info.zone or "?"),
                        info.display .. " (" .. sizeName(info.size) .. ") " .. math.floor(item.dist) .. "m away",
                        info.tier == "Divine" and "success" or "info"
                    )
                end
            end
        end
    end
end

local followerPool = {}

local function updateFollowerEsp()
    if not (Config.espEnabled and Config.espFollower) then
        for _, e in pairs(followerPool) do hideEsp(e) end
        return
    end
    local f = Workspace:FindFirstChild("Followers")
    if not f then return end
    local camera = cam()
    if not camera then return end
    local myPos = camera.CFrame.Position
    local i = 0
    for _, m in ipairs(f:GetChildren()) do
        if i >= 30 then break end
        local part = m:IsA("Model") and m.PrimaryPart
        if part then
            local dist = (part.Position - myPos).Magnitude
            if dist <= Config.espMaxDist then
                local sp, onScreen = camera:WorldToViewportPoint(part.Position + Vector3.new(0, 3, 0))
                if onScreen and sp.Z > 0 then
                    i += 1
                    local e = followerPool[i]
                    if not e then
                        e = {
                            text = newDraw("Text", { Size = 12, Center = true, Outline = true, Font = 2 }),
                        }
                        followerPool[i] = e
                    end
                    if e.text then
                        e.text.Visible = true
                        e.text.Text = m.Name .. "  " .. math.floor(dist) .. "m"
                        e.text.Color = Color3.fromRGB(120, 200, 255)
                        e.text.Position = Vector2.new(sp.X, sp.Y)
                    end
                end
            end
        end
    end
    for j = i + 1, #followerPool do hideEsp(followerPool[j]) end
end

-- ================================================================
-- SOUL TRACKING
-- ================================================================
local souls = {}

Soul.OnClientEvent:Connect(function(action, id, data)
    if stale() then return end
    if action == "add" and type(data) == "table" then
        souls[id] = {
            id = id,
            kind = data.kind,
            size = data.size,
            pos = data.pos,
            tier = tierOf(data.kind),
            at = os.clock(),
        }
    elseif action == "remove" then
        souls[id] = nil
    end
end)

local armyFullAt = 0
local farmToggle, farmZoneDropdown, drumToggle

-- ================================================================
-- BOSS ROUND BLOCK
-- ================================================================
-- the server refuses loot from a boss already beaten this round and announces
-- it through Notify: "You already beat <name> this round! ..."
local blockedBosses = {}

if Remotes:FindFirstChild("Notify") then
    Remotes.Notify.OnClientEvent:Connect(function(text)
        if stale() or not Config.skipBeatenBoss or type(text) ~= "string" then return end
        local name = text:match("You already beat (.+) this round")
        if not name then return end
        local w = Workspace:FindFirstChild("WildCreatures")
        if not w then return end
        for _, m in ipairs(w:GetChildren()) do
            local dn = m:GetAttribute("DisplayName") or m.Name
            if dn == name or m.Name == name then
                local kind = m:GetAttribute("Kind")
                if kind then
                    blockedBosses[kind] = os.clock() + Config.bossBlockTime
                    if notify then notify("Farm", name .. " already beaten this round - skipping", "warning") end
                end
                break
            end
        end
    end)
end

if Remotes:FindFirstChild("NightFade") then
    Remotes.NightFade.OnClientEvent:Connect(function()
        table.clear(blockedBosses)
    end)
end

local function bossBlocked(kind)
    local expire = kind and blockedBosses[kind]
    if not expire then return false end
    if os.clock() > expire then
        blockedBosses[kind] = nil
        return false
    end
    return true
end

-- ================================================================
-- ARMY AUTOMATION
-- ================================================================
local function armyState()
    local ok, res = pcall(function() return ArmyAction:InvokeServer("get") end)
    if ok and type(res) == "table" and type(res.state) == "table" then return res.state end
    return nil
end

local function sellPass(force)
    local state = armyState()
    if not state then return 0 end
    local storage = state.storage or {}
    local sold = 0
    for i = #storage, 1, -1 do
        if stale() or (not force and not Config.autoSell) then break end
        local entry = storage[i]
        local kind, size = entry, 3
        if Sizes then
            local ok, k, s = pcall(Sizes.parse, entry)
            if ok and k then kind, size = k, tonumber(s) or 3 end
        end
        local tier = tierOf(kind)
        local rank = TIER_RANK[tier] or 1
        if rank <= Config.sellMaxRank and size <= Config.sellMaxSize then
            pcall(function() ArmyAction:InvokeServer("sell", i, entry) end)
            sold += 1
            task.wait(0.15)
        end
    end
    return sold
end

local function equipBest()
    pcall(function() ArmyAction:InvokeServer("equipBest") end)
end

local function buySlot()
    local state = armyState()
    if not state then return false end
    local price = tonumber(state.nextPrice) or math.huge
    local command = tonumber(LP:GetAttribute("Command")) or 0
    if price <= command and (state.slots or 0) < (state.maxSlots or 0) then
        pcall(function() ArmyAction:InvokeServer("buySlot") end)
        return true
    end
    return false
end

ArmyFull.OnClientEvent:Connect(function()
    if stale() then return end
    armyFullAt = os.clock()
    if Config.autoSell then
        task.spawn(function() sellPass() end)
    end
    if Config.farmStopFull and Config.farmEnabled then
        Config.farmEnabled = false
        if farmToggle then pcall(function() farmToggle:Set(false) end) end
        if notify then notify("Army", "Army full - farm stopped", "warning") end
    end
end)

-- ================================================================
-- FARM
-- ================================================================
local farm = { lastMove = 0, lastBuy = 0, lastSell = 0, lastSoul = 0, downSince = nil, recoverUntil = 0, downs = {}, powerSkipped = 0 }

local powerCache = { at = 0, value = 0 }

-- the army's own power score, same formula the game's army panel uses
local function playerPower()
    if os.clock() - powerCache.at < 10 then return powerCache.value end
    powerCache.at = os.clock()
    local total = 0
    local state = ArmyRules and armyState()
    if state then
        for _, entry in ipairs(state.army or {}) do
            local ok, p = pcall(ArmyRules.power, entry)
            if ok and type(p) == "number" then total += p end
        end
    end
    powerCache.value = total
    return total
end

local function creaturePower(info)
    if not ArmyRules then return 0 end
    local ok, p = pcall(ArmyRules.power, info.kind, info.size)
    if ok and type(p) == "number" then return p end
    return 0
end

local function desiredZone()
    local sel = Config.farmZone
    if sel == "Current" then
        return currentZoneId() or "Zone1"
    end
    if sel and sel ~= "Auto" then return sel end
    local z = currentZoneId()
    if z then return z end
    local zones = unlockedZones()
    return zones[#zones]
end

-- drumming is proximity only: standing on the plot's WarDrum PlaySpot makes the
-- server set the Drumming attribute, which is what pays coins
local function drumSpot()
    local plot = LP:GetAttribute("Plot")
    local camp = Workspace:FindFirstChild("Camp")
    local plots = camp and camp:FindFirstChild("Plots")
    local p = plot and plots and plots:FindFirstChild("Plot" .. tostring(plot))
    local drum = p and p:FindFirstChild("WarDrum")
    return drum and drum:FindFirstChild("PlaySpot")
end

local function plotSpot(name)
    local plot = LP:GetAttribute("Plot")
    local camp = Workspace:FindFirstChild("Camp")
    local plots = camp and camp:FindFirstChild("Plots")
    local p = plot and plots and plots:FindFirstChild("Plot" .. tostring(plot))
    return p and p:FindFirstChild(name)
end

local function zoneAnchor(zoneId)
    local w = Workspace:FindFirstChild("WildCreatures")
    if w then
        for _, m in ipairs(w:GetChildren()) do
            if m:GetAttribute("Zone") == zoneId and m.PrimaryPart then
                return m.PrimaryPart.Position + Vector3.new(0, 4, 0)
            end
        end
    end
    local n = zoneNumber(zoneId)
    return Vector3.new(0, 80, ZONE_MID[n] or -192)
end

local function pickTarget(myPos)
    local w = Workspace:FindFirstChild("WildCreatures")
    if not w then return nil end
    local wantZone = (Config.farmZone ~= "Auto" and Config.farmZone ~= "Current") and Config.farmZone or nil
    local curZone = currentZoneId()

    local budget = math.huge
    if Config.powerMatch then
        local power = playerPower()
        if power > 0 then budget = power * (Config.powerRatio / 100) end
    end
    farm.powerSkipped = 0

    local best, bestDist
    for _, m in ipairs(w:GetChildren()) do
        local info = creatureInfo(m)
        if info and info.hp > 0 and tierAllowed(info.tier, Config.farmTiers)
            and not (Config.skipBeatenBoss and info.tier == "Boss" and bossBlocked(info.kind)) then
            local zoneOk = true
            if wantZone then
                zoneOk = info.zone == wantZone
            elseif Config.farmZone == "Current" and curZone then
                zoneOk = info.zone == curZone
            end
            local affordable = true
            if zoneOk and budget ~= math.huge then
                local cp = creaturePower(info)
                if cp > budget then
                    affordable = false
                    farm.powerSkipped += 1
                end
            end
            if zoneOk and affordable then
                local dist = (m.PrimaryPart.Position - myPos).Magnitude
                if not bestDist or dist < bestDist then best, bestDist = m, dist end
            end
        end
    end
    return best
end

local function summonPending(myPos)
    if not Config.farmSummon then return false end
    local now = os.clock()
    for id, s in pairs(souls) do
        if now - s.at > 25 then
            souls[id] = nil
        elseif s.pos and TIER_RANK[s.tier] and Config.farmTiers[s.tier] then
            souls[id] = nil
            local h = hrp()
            if h then
                h.CFrame = CFrame.new(s.pos + Vector3.new(0, 2, 0))
                task.wait(0.15)
                SoulChoice:FireServer(id, "summon")
                farm.lastSoul = now
                task.wait(0.2)
                if Config.armyEquipBest then equipBest() end
                return true
            end
        end
    end
    return false
end

local function farmStep()
    local h = hrp()
    local humanoid = hum()
    local now = os.clock()

    -- fainting respawns the character; jumping straight back to a boss before
    -- the army is back up is what turned into a death loop
    local dead = (not h) or (not humanoid) or humanoid.Health <= 0
        or humanoid:GetState() == Enum.HumanoidStateType.Dead
    if dead then
        if not farm.downSince then
            farm.downSince = now
            table.insert(farm.downs, now)
            for i = #farm.downs, 1, -1 do
                if now - farm.downs[i] > 90 then table.remove(farm.downs, i) end
            end
            if #farm.downs >= Config.farmMaxFaints then
                Config.farmEnabled = false
                if farmToggle then pcall(function() farmToggle:Set(false) end) end
                if notify then
                    notify("Farm", "Paused - fainted " .. #farm.downs .. "x in 90s", "warning")
                end
            end
        end
        task.wait(0.5)
        return
    end

    if farm.downSince then
        farm.downSince = nil
        farm.recoverUntil = now + Config.farmRecover
        return
    end
    if now < farm.recoverUntil then
        task.wait(0.3)
        return
    end

    if summonPending(h.Position) then return end

    local target = pickTarget(h.Position)
    if not target then
        local now = os.clock()
        if farm.powerSkipped > 0 and now - (farm.lastPowerNote or 0) > 30 then
            farm.lastPowerNote = now
            if notify then
                notify("Farm", farm.powerSkipped .. " creature(s) above your power budget", "info")
            end
        end
        if now - farm.lastMove > 3 then
            farm.lastMove = now
            h.CFrame = CFrame.new(zoneAnchor(desiredZone()))
        end
        task.wait(1)
        return
    end

    local part = target.PrimaryPart
    if not part then task.wait(0.3) return end

    local off = (h.Position - part.Position)
    off = Vector3.new(off.X, 0, off.Z)
    if off.Magnitude < 0.5 then off = Vector3.new(1, 0, 0) else off = off.Unit end
    h.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0) + off * Config.farmOffset)
    task.wait(0.12)

    if not Config.farmEnabled or stale() then return end
    Punch:FireServer(target)
    farm.lastMove = os.clock()

    if Config.autoSell and os.clock() - farm.lastSell > 20 then
        farm.lastSell = os.clock()
        task.spawn(function() sellPass() end)
    end
    if Config.armyBuySlot and os.clock() - farm.lastBuy > 30 then
        farm.lastBuy = os.clock()
        task.spawn(function() buySlot() end)
    end

    task.wait(Config.farmDelay)
end

task.spawn(function()
    while not stale() do
        if Config.farmEnabled then
            local ok = pcall(farmStep)
            if not ok then task.wait(0.5) end
        else
            task.wait(0.15)
        end
    end
end)

-- auto drum: park on the plot drum spot so the server keeps Drumming=true
task.spawn(function()
    while not stale() do
        if Config.autoDrum and not Config.farmEnabled then
            local spot = drumSpot()
            local h = hrp()
            if spot and h and (h.Position - spot.Position).Magnitude > 4 then
                h.CFrame = CFrame.new(spot.Position + Vector3.new(0, 3, 0))
            end
        end
        task.wait(1)
    end
end)

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

local noclipSaved = {}

local function applyNoclip(on)
    local c = char()
    if not c then return end
    if on then
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") and noclipSaved[d] == nil then
                local ok, v = pcall(function() return d.CanCollide end)
                if ok then noclipSaved[d] = v end
                pcall(function() d.CanCollide = false end)
            end
        end
    else
        for part, v in pairs(noclipSaved) do
            if part and part.Parent then pcall(function() part.CanCollide = v end) end
        end
        table.clear(noclipSaved)
    end
end

local function applySpeed()
    local humanoid = hum()
    if not humanoid then return end
    humanoid.WalkSpeed = Config.speedEnabled and Config.walkSpeed or 37
end

local function applyJump()
    local humanoid = hum()
    if not humanoid then return end
    if Config.jumpEnabled then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Config.jumpPower
    else
        humanoid.UseJumpPower = false
    end
end

UIS.JumpRequest:Connect(function()
    if stale() or not Config.infJump then return end
    local humanoid = hum()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function teleportTo(pos)
    local h = hrp()
    if not h or not pos then return false end
    h.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    return true
end

-- ================================================================
-- LIGHTING / ANTI-AFK
-- ================================================================
local lightBackup = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local function applyFullbright()
    if Config.fullbright then
        Lighting.Brightness = 3
        Lighting.ClockTime = 13
        Lighting.FogEnd = 1e6
        Lighting.Ambient = Color3.fromRGB(160, 160, 160)
        Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
    else
        Lighting.Brightness = lightBackup.Brightness
        Lighting.ClockTime = lightBackup.ClockTime
        Lighting.FogEnd = lightBackup.FogEnd
        Lighting.Ambient = lightBackup.Ambient
        Lighting.OutdoorAmbient = lightBackup.OutdoorAmbient
    end
end

LP.Idled:Connect(function()
    if stale() or not Config.antiAfk then return end
    pcall(function()
        VIM:CaptureController()
        VIM:ClickButton2(Vector2.new())
    end)
end)

-- ================================================================
-- MAIN LOOPS
-- ================================================================
local worldTick = 0

local conn
conn = RunService.RenderStepped:Connect(function(dt)
    if stale() then
        conn:Disconnect()
        return
    end

    worldTick += 1

    updateWildEsp()
    if worldTick % 4 == 0 then
        updateFollowerEsp()
    end

    if Config.flyEnabled then
        if not flyAP then startFly() end
        stepFly(dt)
    elseif flyAP then
        stopFly()
    end

    if Config.noclip then applyNoclip(true) end
end)

local housekeeping
housekeeping = RunService.Heartbeat:Connect(function()
    if stale() then
        housekeeping:Disconnect()
        return
    end

    if Config.speedEnabled or Config.jumpEnabled then
        local h = hum()
        if h then
            if Config.speedEnabled and math.abs(h.WalkSpeed - Config.walkSpeed) > 0.5 then
                h.WalkSpeed = Config.walkSpeed
            end
            if Config.jumpEnabled and h.UseJumpPower and math.abs(h.JumpPower - Config.jumpPower) > 0.5 then
                h.JumpPower = Config.jumpPower
            end
        end
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if stale() then return end
    table.clear(noclipSaved)
    applySpeed()
    applyJump()
    if Config.flyEnabled then startFly() end
end)

-- ================================================================
-- UI
-- ================================================================
Library = nil
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

Library.ConfigFolder = "exlumiaa/summon-pet-army"

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
    BrandSubtitle = "Summon a Pet Army",
    Size = UDim2.fromOffset(540, 460),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Summon a Pet Army",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

notify = function(title, content, ntype)
    pcall(function()
        Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 })
    end)
end

-- ---------------- VISUALS ----------------
local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })

local WildSub = VisualTab:AddSubTab("Creatures")
autosaveWrap(WildSub)
WildSub:AddSection("Wild Creatures")
WildSub:AddToggle({ Name = "ESP Enabled", Flag = "spa_esp", Default = false,
    Callback = function(v) Config.espEnabled = v end })
WildSub:AddToggle({ Name = "Box", Flag = "spa_box", Default = true,
    Callback = function(v) Config.espBox = v end })
WildSub:AddToggle({ Name = "Name + Size", Flag = "spa_name", Default = true,
    Callback = function(v) Config.espName = v end })
WildSub:AddToggle({ Name = "Tier + HP + Distance", Flag = "spa_info", Default = true,
    Callback = function(v) Config.espInfo = v end })
WildSub:AddToggle({ Name = "Health Bar", Flag = "spa_hp", Default = true,
    Callback = function(v) Config.espHealth = v end })
WildSub:AddToggle({ Name = "Tracer", Flag = "spa_tracer", Default = false,
    Callback = function(v) Config.espTracer = v end })
WildSub:AddToggle({ Name = "Follower ESP", Flag = "spa_follow", Default = false,
    Callback = function(v) Config.espFollower = v end })
WildSub:AddToggle({ Name = "Divine / Chase Alert", Flag = "spa_alert", Default = true,
    Callback = function(v) Config.espAlert = v end })
WildSub:AddSlider({ Name = "Max Distance", Min = 100, Max = 12000, Default = 5000, Suffix = " studs",
    Flag = "spa_dist", Callback = function(v) Config.espMaxDist = v end })

WildSub:AddSection("Tiers")
for _, tier in ipairs({ "Easy", "Hard", "Rare", "Boss", "Chase", "Divine" }) do
    local key = tier
    WildSub:AddToggle({ Name = key, Flag = "spa_t_" .. string.lower(key), Default = Config.espTiers[key],
        Callback = function(v) Config.espTiers[key] = v end })
end

local WorldSub = VisualTab:AddSubTab("World")
autosaveWrap(WorldSub)
WorldSub:AddSection("Lighting")
WorldSub:AddToggle({ Name = "Fullbright", Flag = "spa_fullbright", Default = false,
    Callback = function(v)
        Config.fullbright = v
        applyFullbright()
    end })

-- ---------------- FARM ----------------
local FarmTab = Window:AddTab({ Name = "Farm", Icon = "zap", Subtitle = "Auto" })

local FarmSub = FarmTab:AddSubTab("Auto Farm")
autosaveWrap(FarmSub)
FarmSub:AddSection("Farm")
farmToggle = FarmSub:AddToggle({ Name = "Auto Farm", Flag = "spa_farm", Default = false,
    Callback = function(v) Config.farmEnabled = v end })

farmZoneDropdown = FarmSub:AddDropdown({ Name = "Zone", Options = farmZoneOptions(), Default = "Auto",
    Flag = "spa_zone", Callback = function(v) Config.farmZone = v end })
FarmSub:AddSlider({ Name = "Punch Delay", Min = 1, Max = 3, Default = 1, Suffix = " s",
    Flag = "spa_delay", Callback = function(v) Config.farmDelay = v end })
FarmSub:AddSlider({ Name = "Stand Off Distance", Min = 2, Max = 10, Default = 6, Suffix = " studs",
    Flag = "spa_offset", Callback = function(v) Config.farmOffset = v end })
FarmSub:AddToggle({ Name = "Auto Summon Souls", Flag = "spa_summon", Default = true,
    Callback = function(v) Config.farmSummon = v end })
FarmSub:AddToggle({ Name = "Stop When Army Full", Flag = "spa_full", Default = true,
    Callback = function(v) Config.farmStopFull = v end })
FarmSub:AddSlider({ Name = "Recover After Faint", Min = 2, Max = 15, Default = 6, Suffix = " s",
    Flag = "spa_recover", Callback = function(v) Config.farmRecover = v end })
FarmSub:AddSlider({ Name = "Pause After Faints", Min = 1, Max = 6, Default = 3, Suffix = " in 90s",
    Flag = "spa_maxfaints", Callback = function(v) Config.farmMaxFaints = v end })
FarmSub:AddToggle({ Name = "Skip Beaten Bosses", Flag = "spa_skipboss", Default = true,
    Callback = function(v) Config.skipBeatenBoss = v end })
FarmSub:AddToggle({ Name = "Power Match", Flag = "spa_powermatch", Default = true,
    Callback = function(v) Config.powerMatch = v end })
FarmSub:AddSlider({ Name = "Power Budget", Min = 10, Max = 200, Default = 50, Suffix = " %",
    Flag = "spa_powerratio", Callback = function(v) Config.powerRatio = v end })

FarmSub:AddSection("Tiers")
for _, tier in ipairs({ "Easy", "Hard", "Rare", "Boss", "Chase", "Divine" }) do
    local key = tier
    FarmSub:AddToggle({ Name = key, Flag = "spa_ft_" .. string.lower(key), Default = Config.farmTiers[key],
        Callback = function(v) Config.farmTiers[key] = v end })
end

local ArmySub = FarmTab:AddSubTab("Army")
autosaveWrap(ArmySub)
ArmySub:AddSection("Automation")
ArmySub:AddToggle({ Name = "Auto Sell Storage", Flag = "spa_sell", Default = false,
    Callback = function(v) Config.autoSell = v end })
ArmySub:AddDropdown({ Name = "Sell Up To Tier",
    Options = { "Easy", "Hard", "Rare", "Boss", "Chase", "Divine" }, Default = "Easy",
    Flag = "spa_sellrank",
    Callback = function(v)
        Config.sellMaxRank = TIER_RANK[v] or 1
    end })
ArmySub:AddDropdown({ Name = "Sell Up To Size",
    Options = { "Tiny", "Small", "Medium", "Big", "Huge" }, Default = "Medium",
    Flag = "spa_sellsize",
    Callback = function(v)
        for i, n in ipairs(SIZE_NAME) do
            if n == v then Config.sellMaxSize = i end
        end
    end })
ArmySub:AddToggle({ Name = "Auto Equip Best", Flag = "spa_equip", Default = true,
    Callback = function(v) Config.armyEquipBest = v end })
ArmySub:AddToggle({ Name = "Auto Buy Slot", Flag = "spa_buyslot", Default = false,
    Callback = function(v) Config.armyBuySlot = v end })
ArmySub:AddButton({ Name = "Sell Storage Now", Primary = true,
    Callback = function()
        local n = sellPass(true)
        notify("Army", "Sold " .. tostring(n) .. " pet(s)", "success")
    end })
ArmySub:AddButton({ Name = "Equip Best Now",
    Callback = function()
        equipBest()
        notify("Army", "Equip Best sent", "info")
    end })
ArmySub:AddButton({ Name = "Refresh Army State",
    Callback = function()
        local s = armyState()
        if s then
            notify("Army", tostring(s.slots or 0) .. "/" .. tostring(s.maxSlots or 0)
                .. " slots | next " .. tostring(s.nextPrice or 0), "info")
        else
            notify("Army", "Failed to read state", "error")
        end
    end })

local CampSub = FarmTab:AddSubTab("Camp")
autosaveWrap(CampSub)
CampSub:AddSection("Drum")
drumToggle = CampSub:AddToggle({ Name = "Auto Drum", Flag = "spa_drum", Default = false,
    Callback = function(v) Config.autoDrum = v end })
CampSub:AddButton({ Name = "Go to Drum", Primary = true,
    Callback = function()
        local spot = drumSpot()
        if spot then
            teleportTo(spot.Position)
            notify("Camp", "Drum spot", "success")
        else
            notify("Camp", "Drum not found (stand in camp first)", "warning")
        end
    end })
CampSub:AddButton({ Name = "Go Home Spot",
    Callback = function()
        local spot = plotSpot("HomeSpot")
        if spot then
            teleportTo(spot.Position)
            notify("Camp", "Home spot", "success")
        else
            notify("Camp", "Home spot not found", "warning")
        end
    end })
CampSub:AddLabel({ Text = "Drumming is proximity: stand on your plot drum." })

-- ---------------- MOVEMENT ----------------
local MoveTab = Window:AddTab({ Name = "Movement", Icon = "move", Subtitle = "Player" })

local SpeedSub = MoveTab:AddSubTab("Speed")
autosaveWrap(SpeedSub)
SpeedSub:AddSection("Speed")
SpeedSub:AddToggle({ Name = "Speed Hack", Flag = "spa_speed", Default = false,
    Callback = function(v)
        Config.speedEnabled = v
        applySpeed()
    end })
SpeedSub:AddSlider({ Name = "Walk Speed", Min = 20, Max = 200, Default = 60,
    Flag = "spa_walkspeed", Callback = function(v)
        Config.walkSpeed = v
        applySpeed()
    end })
SpeedSub:AddToggle({ Name = "Jump Power", Flag = "spa_jump", Default = false,
    Callback = function(v)
        Config.jumpEnabled = v
        applyJump()
    end })
SpeedSub:AddSlider({ Name = "Jump Power Value", Min = 50, Max = 300, Default = 60,
    Flag = "spa_jumppower", Callback = function(v)
        Config.jumpPower = v
        applyJump()
    end })
SpeedSub:AddToggle({ Name = "Infinite Jump", Flag = "spa_infjump", Default = false,
    Callback = function(v) Config.infJump = v end })
SpeedSub:AddToggle({ Name = "Noclip", Flag = "spa_noclip", Default = false,
    Callback = function(v)
        Config.noclip = v
        applyNoclip(v)
    end })

local FlySub = MoveTab:AddSubTab("Fly")
autosaveWrap(FlySub)
FlySub:AddSection("Fly")
FlySub:AddToggle({ Name = "Fly (WASD / Space / Ctrl)", Flag = "spa_fly", Default = false,
    Callback = function(v)
        Config.flyEnabled = v
        if v then startFly() else stopFly() end
    end })
FlySub:AddSlider({ Name = "Speed", Min = 10, Max = 400, Default = 80,
    Flag = "spa_flyspeed", Callback = function(v) Config.flySpeed = v end })
FlySub:AddSlider({ Name = "Max Height", Min = 50, Max = 1500, Default = 600,
    Flag = "spa_flyh", Callback = function(v) Config.flyMaxHeight = v end })

-- ---------------- TELEPORT ----------------
local TpTab = Window:AddTab({ Name = "Teleport", Icon = "map", Subtitle = "Travel" })

local TpSub = TpTab:AddSubTab("Travel")
autosaveWrap(TpSub)
TpSub:AddSection("Creatures")
TpSub:AddButton({ Name = "Teleport to Nearest Target", Primary = true,
    Callback = function()
        local list = collectWild()
        if #list == 0 then notify("Teleport", "No creature matches the ESP filters", "warning") return end
        teleportTo(list[1].m.PrimaryPart.Position + Vector3.new(0, 4, 0))
        notify("Teleport", list[1].info.display, "success")
    end })
TpSub:AddButton({ Name = "Teleport to Nearest Divine / Chase",
    Callback = function()
        local list = collectWild()
        for _, item in ipairs(list) do
            if item.info.tier == "Divine" or item.info.tier == "Chase" then
                teleportTo(item.m.PrimaryPart.Position + Vector3.new(0, 4, 0))
                notify("Teleport", item.info.display, "success")
                return
            end
        end
        notify("Teleport", "None in range", "warning")
    end })

TpSub:AddSection("Zones")
local zoneDropdown = TpSub:AddDropdown({ Name = "Zone", Options = unlockedZones(), Default = "Zone1",
    Flag = "spa_tpzone", Callback = function() end })
TpSub:AddButton({ Name = "Teleport to Zone",
    Callback = function()
        local z = zoneDropdown:Get()
        if not z then return end
        teleportTo(zoneAnchor(z))
        notify("Teleport", z .. " " .. (ZONE_NAME[zoneNumber(z)] or ""), "success")
    end })
TpSub:AddButton({ Name = "Teleport to Camp",
    Callback = function()
        teleportTo(CAMP_POS)
        notify("Teleport", "Camp", "success")
    end })

-- ---------------- SETTINGS ----------------
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })

local SafeSub = SettingsTab:AddSubTab("Safety")
autosaveWrap(SafeSub)
SafeSub:AddSection("Session")
SafeSub:AddLabel({ Text = "No client anti-cheat in this game." })
SafeSub:AddLabel({ Text = "Farm stays inside unlocked zones." })
SafeSub:AddButton({ Name = "Panic - Disable All", Primary = true,
    Callback = function()
        Config.espEnabled = false
        Config.farmEnabled = false
        Config.autoDrum = false
        Config.autoSell = false
        Config.speedEnabled = false
        Config.jumpEnabled = false
        Config.infJump = false
        Config.flyEnabled = false
        Config.noclip = false
        Config.fullbright = false
        stopFly()
        applyNoclip(false)
        applySpeed()
        applyJump()
        applyFullbright()
        notify("Panic", "All features disabled", "info")
    end })

local ConfigSub = SettingsTab:AddSubTab("Config")
autosaveWrap(ConfigSub)
ConfigSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({ Name = "Saved Configs", Options = {}, Default = "",
    Flag = "spa_config_sel", Callback = function(v) selectedConfig = v end })

local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
        configDropdown:Refresh()
    end
end

local configInput = ConfigSub:AddInput({ Name = "Config Name", Default = "",
    Placeholder = "Enter config name...", Flag = "spa_config_name" })

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
        getgenv().__spaGen = (tonumber(getgenv().__spaGen) or 1) + 1
        pcall(function() conn:Disconnect() end)
        pcall(function() housekeeping:Disconnect() end)
        stopFly()
        Config.noclip = false
        applyNoclip(false)
        killAllDrawings()
        Config.fullbright = false
        applyFullbright()
        pcall(function() Library:DestroyAll() end)
        for _, g in ipairs({ game:GetService("CoreGui"), LP:FindFirstChild("PlayerGui") }) do
            if g then
                local old = g:FindFirstChild("ExlumiaaHub")
                if old then pcall(function() old:Destroy() end) end
            end
        end
        print("[ExlumiaaHub] Summon a Pet Army unloaded")
    end })

ConfigSub:AddSection("Info")
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })

refreshConfigList()
pcall(function() Library:LoadConfig("default") end)

-- a saved config must never start a teleporting farm or drum loop on load
Config.farmEnabled = false
Config.autoDrum = false
if farmToggle then pcall(function() farmToggle:Set(false) end) end
if drumToggle then pcall(function() drumToggle:Set(false) end) end

-- keep the zone dropdown in step with unlocks
task.spawn(function()
    local last = table.concat(unlockedZones(), ",")
    while not stale() do
        task.wait(10)
        local now = table.concat(unlockedZones(), ",")
        if now ~= last then
            last = now
            pcall(function()
                zoneDropdown:SetOptions(unlockedZones())
                zoneDropdown:Refresh()
                if farmZoneDropdown then
                    farmZoneDropdown:SetOptions(farmZoneOptions())
                    farmZoneDropdown:Refresh()
                end
            end)
        end
    end
end)

print("[ExlumiaaHub] Summon a Pet Army loaded | creatures="
    .. tostring(#(Workspace:FindFirstChild("WildCreatures") and Workspace.WildCreatures:GetChildren() or {})))

-- debug handle for live verification
getgenv().__spa = {
    Config = Config,
    souls = function() return souls end,
    sellPass = sellPass,
    armyState = armyState,
    pickTarget = function()
        local h = hrp()
        local t = h and pickTarget(h.Position)
        if not t then return nil end
        local i = creatureInfo(t)
        return i and (i.display .. " | " .. i.tier .. " | " .. math.floor(i.hp) .. "/" .. math.floor(i.maxHp)) or nil
    end,
    esp = function()
        local n = 0
        for _, e in pairs(espPool) do if e.box and e.box.Visible then n += 1 end end
        return { pool = #espPool, visible = n, alerts = alertCount }
    end,
    zoneAnchor = zoneAnchor,
    desiredZone = desiredZone,
    applyNoclip = applyNoclip,
    drumSpot = drumSpot,
    farmState = function()
        return { down = farm.downSince ~= nil, recoverUntil = farm.recoverUntil, downs = #farm.downs }
    end,
    blockedBosses = function()
        local out = {}
        for kind, expire in pairs(blockedBosses) do out[kind] = math.floor(expire - os.clock()) end
        return out
    end,
    playerPower = playerPower,
    creaturePower = function(kind, size)
        return creaturePower({ kind = kind, size = size or 3 })
    end,
}
