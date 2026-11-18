-- Exlumiaa Hub - +1 Spider Arm
-- Universe 10771997908 (place 117734411290994)
-- Mechanics verified live:
--   Training: stand on a rig -> server grants XP every ~0.5s (TrainNet "trained")
--             bubbles arrive as TrainNet "bubble", pop with TrainNet("pop", id);
--             each pop stacks an XP boost (up to x10) for 15s
--   Rebirth:  RebirthNet("rebirth") at level 10 + 10*Rebirths, +50% training each
--   Daily:    RewardNet("daily"); DailyTime holds the last claim time
--   Spin:     SpiderNet("spin") free when now >= SpiderSpinAt
--   Boxes:    SpiderNet("open", "Spider", count) costs 1 key + 1 box each
--   Revive:   StoreNet("revive") with ReviveTokens
-- Robux rigs (Inferno+) are deliberately not used.

if tostring(game.GameId) ~= "10771997908" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _psaTomb"
local _G_ALIVE = "_ _psaAlive"
local _G_CONFIG = "_ _psaConfig"

if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_plus_1_spider_arm.txt"
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
            brand = "+1 Spider Arm",
            guiName = "Plus1SpiderArmKeyGate",
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
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "ExlumiaaHUD") then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        for _, gui in ipairs(pg and pg:GetChildren() or {}) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "ExlumiaaHUD") then gui:Destroy() end
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
for _ = 1, 80 do
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library then return end
Library.ConfigFolder = "exlumiaa"

local Config = {
    autoTrain = false,
    autoPop = true,
    targetLevel = 0,
    autoRebirth = false,
    autoDaily = false,
    autoSpin = false,
    autoBoxes = false,
    autoRevive = false,
    autoRevive = false,
    antiAfk = true,
    hud = true,
    fullbright = false,
    unlimitedGrip = false,
}
rawset(_G, _G_CONFIG, Config)

local Armature = ReplicatedStorage:WaitForChild("Armature", 20)
if not Armature then return end
local TrainNet = Armature:WaitForChild("TrainNet", 10)
local RewardNet = Armature:WaitForChild("RewardNet", 10)
local RebirthNet = Armature:WaitForChild("RebirthNet", 10)
local StoreNet = Armature:WaitForChild("StoreNet", 10)
local SpiderNet = Armature:WaitForChild("SpiderNet", 10)
if not (TrainNet and RewardNet and RebirthNet and StoreNet and SpiderNet) then return end

-- Grip is client-side in the Driver module: updateGrip drains it and calls
-- slip() at zero. Keeping it topped up means no slip, i.e. unlimited grip.
local DriverModule = nil
pcall(function() DriverModule = require(Armature:WaitForChild("Driver", 10)) end)

local gripPatched, gripOriginal = false, nil
local function setUnlimitedGrip(on)
    if not DriverModule or type(DriverModule.updateGrip) ~= "function" then return end
    if on and not gripPatched then
        gripOriginal = DriverModule.updateGrip
        DriverModule.updateGrip = function(self, dt)
            if self.deployed and not self.outClock and self.root and not self:inLobby(self.root.Position) then
                self.grip = self:gripCap()
                self.spent = false
                if self.solver then self.solver.noGrip = false end
            end
            return gripOriginal(self, dt)
        end
        gripPatched = true
    elseif not on and gripPatched then
        DriverModule.updateGrip = gripOriginal
        gripPatched = false
    end
end

-- ================================================================
-- Helpers
-- ================================================================
local function char() return LP.Character end
local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
local function root()
    local c = char()
    return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) or nil
end
local function alive()
    local h = hum()
    return h ~= nil and h.Health > 0 and root() ~= nil
end
local function num(v)
    v = tonumber(v)
    return type(v) == "number" and v or 0
end
local function now() return workspace:GetServerTimeNow() end

local function fire(remote, ...)
    if remote and remote:IsA("RemoteEvent") then
        local args = table.pack(...)
        pcall(function() remote:FireServer(table.unpack(args, 1, args.n)) end)
    end
end

local function tp(pos)
    local r = root()
    if not r then return false end
    pcall(function() r.CFrame = CFrame.new(pos) end)
    return true
end

local function level() return num(LP:GetAttribute("Level")) end
local function rebirths() return num(LP:GetAttribute("Rebirths")) end
local function rebirthNeed() return 10 + 10 * rebirths() end

-- ================================================================
-- Training stations (non-Robux only)
-- ================================================================
local STATIONS = {
    { Name = "Scrap", Rig = "ScrapRig", Rebirths = 0 },
    { Name = "Steel", Rig = "SteelRig", Rebirths = 2 },
    { Name = "Turbo", Rig = "TurboRig", Rebirths = 4 },
    { Name = "Plasma", Rig = "PlasmaRig", Rebirths = 6 },
}

local function stationPad(rigName)
    local map = workspace:FindFirstChild("Map")
    local lobby = map and map:FindFirstChild("Lobby")
    local features = lobby and lobby:FindFirstChild("Features")
    local training = features and features:FindFirstChild("Training")
    local stations = training and training:FindFirstChild("Stations")
    local rig = stations and stations:FindFirstChild(rigName)
    return rig and rig:FindFirstChild("Pad")
end

local function bestStation()
    local rebs = rebirths()
    local best = STATIONS[1]
    for _, s in ipairs(STATIONS) do
        if rebs >= s.Rebirths then best = s end
    end
    return best
end

local function warpToRig()
    local s = bestStation()
    local pad = stationPad(s.Rig)
    if not pad then return false end
    return tp(pad.Position + Vector3.new(0, 3, 0))
end

-- ================================================================
-- Core automation
-- ================================================================
local busy = false
local lastWarp = 0
local lastRebirth = 0
local lastDaily = 0
local lastSpin = 0
local lastBox = 0
local lastRevive = 0

local function trainTick()
    if busy or not alive() then return end
    local lvl = level()
    if Config.autoRebirth and lvl >= rebirthNeed() and os.clock() - lastRebirth > 8 then
        lastRebirth = os.clock()
        busy = true
        fire(RebirthNet, "rebirth")
        task.wait(2.5)
        lastWarp = 0
        busy = false
        return
    end
    if not Config.autoTrain then return end
    if Config.targetLevel > 0 and lvl >= Config.targetLevel then return end
    local s = bestStation()
    local training = tostring(LP:GetAttribute("Training") or "")
    if training == "" or training ~= s.Name then
        if os.clock() - lastWarp > 2.5 then
            lastWarp = os.clock()
            warpToRig()
        end
    end
end

local function rewardTick()
    if not alive() then return end
    local t = now()
    if Config.autoDaily and os.clock() - lastDaily > 10 then
        local dailyAt = num(LP:GetAttribute("DailyTime"))
        if dailyAt == 0 or t >= dailyAt + 86400 then
            lastDaily = os.clock()
            fire(RewardNet, "daily")
        end
    end
    if Config.autoSpin and os.clock() - lastSpin > 5 then
        local spinAt = num(LP:GetAttribute("SpiderSpinAt"))
        if num(LP:GetAttribute("SpiderSpins")) > 0 or t >= spinAt then
            lastSpin = os.clock()
            fire(SpiderNet, "spin")
        end
    end
    if Config.autoBoxes and os.clock() - lastBox > 4 then
        local boxes = LP:GetAttribute("SpiderBoxes")
        local count = 0
        if type(boxes) == "table" then count = num(boxes.Spider) elseif type(boxes) == "string" then
            local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(boxes) end)
            if ok and type(decoded) == "table" then count = num(decoded.Spider) end
        end
        if count > 0 and num(LP:GetAttribute("SpiderKeys")) > 0 then
            lastBox = os.clock()
            fire(SpiderNet, "open", "Spider", 1)
        end
    end
    if Config.autoRevive and os.clock() - lastRevive > 5 then
        local h = hum()
        if num(LP:GetAttribute("ReviveTokens")) > 0 and h and h.Health <= 0 then
            lastRevive = os.clock()
            fire(StoreNet, "revive")
        end
    end
end

local function nearestCheckpoint()
    return nil
end

local function checkpointTick() end

-- Auto-pop bubbles: the server sends the id, we answer like the game's UI does.
local function onTrainEvent(kind, id)
    if kind == "bubble" and Config.autoPop then
        local bubbleId = id
        task.delay(0.35, function()
            if Config.autoPop and rawget(_G, _G_TOMB) ~= true then
                fire(TrainNet, "pop", bubbleId)
            end
        end)
    end
end
TrainNet.OnClientEvent:Connect(onTrainEvent)

-- ================================================================
-- Space hold for climbing
-- ================================================================
local climbHeld = false
local function setClimb(on)
    if on == climbHeld then return end
    climbHeld = on
    pcall(function()
        if on then keypress(0x20) else keyrelease(0x20) end
    end)
end

-- ================================================================
-- Fullbright
-- ================================================================
local fbSaved = nil
local function setFullbright(on)
    if on and not fbSaved then
        fbSaved = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ExposureCompensation = Lighting.ExposureCompensation,
        }
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(150, 150, 150)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        Lighting.ExposureCompensation = 0.2
    elseif not on and fbSaved then
        for k, v in pairs(fbSaved) do Lighting[k] = v end
        fbSaved = nil
    end
end

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
-- HUD
-- ================================================================
local hud = nil
do
    local ok = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "ExlumiaaHUD"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        local parent = game:GetService("CoreGui")
        gui.Parent = parent
        local label = Instance.new("TextLabel")
        label.Name = "Stats"
        label.Size = UDim2.fromOffset(250, 74)
        label.Position = UDim2.fromOffset(14, 14)
        label.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        label.BackgroundTransparency = 0.25
        label.TextColor3 = Color3.fromRGB(235, 235, 240)
        label.Font = Enum.Font.Code
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Text = ""
        label.Parent = gui
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingTop = UDim.new(0, 6)
        pad.Parent = label
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        hud = { gui = gui, label = label }
    end)
    if not ok then hud = nil end
end

local function updateHud()
    if not hud then return end
    hud.gui.Enabled = Config.hud
    if not Config.hud then return end
    local boxes = LP:GetAttribute("SpiderBoxes")
    local boxCount = 0
    if type(boxes) == "table" then boxCount = num(boxes.Spider) elseif type(boxes) == "string" then
        local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(boxes) end)
        if ok and type(decoded) == "table" then boxCount = num(decoded.Spider) end
    end
    local training = tostring(LP:GetAttribute("Training") or "")
    hud.label.Text = string.format(
        "LEVEL %d   XP %d\nWINS %d   REBIRTHS %d (need Lv %d)\nRIG %s   %s\nKEYS %d   BOXES %d   SPINS %d",
        level(), math.floor(num(LP:GetAttribute("XP"))),
        math.floor(num(LP:GetAttribute("Wins"))), rebirths(), rebirthNeed(),
        bestStation().Name, training ~= "" and ("TRAINING " .. training) or "idle",
        math.floor(num(LP:GetAttribute("SpiderKeys"))), boxCount,
        math.floor(num(LP:GetAttribute("SpiderSpins")))
    )
end

-- ================================================================
-- Main loop
-- ================================================================
task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        local ok, err = pcall(function()
            trainTick()
            rewardTick()
            checkpointTick()
            updateHud()
            if Config.fullbright ~= (fbSaved ~= nil) then setFullbright(Config.fullbright) end
            if Config.unlimitedGrip ~= gripPatched then setUnlimitedGrip(Config.unlimitedGrip) end
        end)
        if not ok then warn("[Spider] loop: " .. tostring(err)) end
        task.wait(0.5)
    end
    setClimb(false)
    setUnlimitedGrip(false)
    setFullbright(false)
    if hud then hud.gui:Destroy() end
end)

-- ================================================================
-- UI
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "+1 Spider Arm",
    Size = UDim2.fromOffset(520, 420),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 Spider Arm",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then v:Destroy() end
    end
end)

local TrainTab = Window:AddTab({ Name = "Main", Icon = "bolt", Subtitle = "Features" })
local TrainSub = TrainTab:AddSubTab("Features")

TrainSub:AddSection("Training")
TrainSub:AddToggle({
    Name = "Auto Train",
    Flag = "psa_train",
    Default = false,
    Callback = function(v) Config.autoTrain = v end,
})
TrainSub:AddToggle({
    Name = "Auto Pop Bubbles",
    Flag = "psa_pop",
    Default = true,
    Callback = function(v) Config.autoPop = v end,
})
TrainSub:AddToggle({
    Name = "Auto Rebirth",
    Flag = "psa_rebirth",
    Default = false,
    Callback = function(v) Config.autoRebirth = v end,
})
TrainSub:AddToggle({
    Name = "Unlimited Grip",
    Flag = "psa_grip",
    Default = false,
    Callback = function(v) Config.unlimitedGrip = v end,
})

local RewardTab = Window:AddTab({ Name = "Rewards", Icon = "gift", Subtitle = "Daily & Boxes" })
local RewardSub = RewardTab:AddSubTab("Features")

RewardSub:AddSection("Rewards")
RewardSub:AddToggle({
    Name = "Auto Daily",
    Flag = "psa_daily",
    Default = false,
    Callback = function(v) Config.autoDaily = v end,
})
RewardSub:AddToggle({
    Name = "Auto Spin",
    Flag = "psa_spin",
    Default = false,
    Callback = function(v) Config.autoSpin = v end,
})
RewardSub:AddToggle({
    Name = "Auto Open Boxes",
    Flag = "psa_boxes",
    Default = false,
    Callback = function(v) Config.autoBoxes = v end,
})
RewardSub:AddToggle({
    Name = "Auto Revive",
    Flag = "psa_revive",
    Default = false,
    Callback = function(v) Config.autoRevive = v end,
})

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Utility" })
local SettingsSub = SettingsTab:AddSubTab("Features")

SettingsSub:AddSection("Utility")
SettingsSub:AddToggle({
    Name = "Anti AFK",
    Flag = "psa_afk",
    Default = true,
    Callback = function(v) Config.antiAfk = v end,
})
SettingsSub:AddToggle({
    Name = "Stats HUD",
    Flag = "psa_hud",
    Default = true,
    Callback = function(v) Config.hud = v end,
})
SettingsSub:AddToggle({
    Name = "Fullbright / No Fog",
    Flag = "psa_fullbright",
    Default = false,
    Callback = function(v) Config.fullbright = v end,
})
SettingsSub:AddSection("Config")
local configDropdown = SettingsSub:AddDropdown({
    Name = "Saved Configs",
    Flag = "psa_config_selected",
    Options = {},
    Default = "",
    Callback = function(v) selectedConfig = v end,
})
local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
        configDropdown:Refresh()
    end
end
local configInput = SettingsSub:AddInput({
    Name = "Config Name",
    Flag = "psa_config_name",
    Default = "",
    Placeholder = "Enter config name...",
})
SettingsSub:AddDivider()
SettingsSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            pcall(function() Window:Notify({ Title = "Config", Content = "Enter a name first!", Duration = 3 }) end)
            return
        end
        if Library:SaveConfig(name) then
            refreshConfigList()
            pcall(function() Window:Notify({ Title = "Config", Content = "Saved: " .. name, Duration = 3 }) end)
        else
            pcall(function() Window:Notify({ Title = "Config", Content = "Save failed.", Duration = 3 }) end)
        end
    end,
})
SettingsSub:AddButton({
    Name = "Load Config",
    Callback = function()
        local selected = configDropdown:Get()
        if not selected or selected == "" then
            pcall(function() Window:Notify({ Title = "Config", Content = "Select a config first!", Duration = 3 }) end)
            return
        end
        if Library:LoadConfig(selected) then
            refreshConfigList()
            pcall(function() Window:Notify({ Title = "Config", Content = "Loaded: " .. selected, Duration = 3 }) end)
        else
            pcall(function() Window:Notify({ Title = "Config", Content = "Load failed.", Duration = 3 }) end)
        end
    end,
})

pcall(function() Library:LoadConfig("default") end)

pcall(function()
    Window:Notify({
        Title = "Exlumiaa Hub loaded",
        Content = "Press RightShift to toggle. Turn on Auto Train in the Train tab.",
    })
end)
