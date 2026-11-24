-- Exlumiaa Hub - Bug Evolution
-- Server-authoritative: stats live in Player attributes. This hub only moves the
-- character, drives the game's own remotes, and draws ESP.
--
-- Verified from the client scripts:
--   Attack:FireServer(targetModel)    target = Creature / Breakable model
--   Evolve:InvokeServer()             gated by Level >= NextStageLevel
--   PickTrait:FireServer(1..3)        offer arrives on TraitOffer.OnClientEvent
--   SetSprint:FireServer(bool)
--   SetFlying:FireServer(bool)        only for species with CanFly
--   RequestSpawn:FireServer("Respawn" / "Revive")
--   Rewards:InvokeServer("ClaimPlaytime")
--   Orbs are untagged Parts in workspace.Orbs, picked up on touch.

if tostring(game.GameId) ~= "10769957062" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _bugEvoTomb"
local _G_ALIVE = "_ _bugEvoAlive"
local _G_CONFIG = "_ _bugEvoConfig"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.6)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_bug_evolution.txt"
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
            brand = "Bug Evolution",
            guiName = "BugEvolutionKeyGate",
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
for _ = 1, 80 do
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library then return end

Library.ConfigFolder = "exlumiaa"

local Config = {
    autoFarm = false,
    farmMode = "Bugs & Breakables",
    autoCorpse = false,
    autoOrbs = false,
    orbPriority = "Nearest",
    farmRadius = 300,
    orbRadius = 300,
    autoEvolve = false,
    autoTrait = false,
    traitPref = "XP Gain",
    autoRespawn = false,
    autoRewards = false,
    antiAfk = true,
    autoSprint = false,
    infiniteSprint = false,
    fly = false,
    flySpeed = 45,
    espBugs = false,
    espBreak = false,
    espOrbs = false,
    espPlayers = false,
    espTracers = false,
    espRange = 250,
    fullbright = false,
}
rawset(_G, _G_CONFIG, Config)

-- ================================================================
-- Modules / remotes
-- ================================================================
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then return end

local Shared = ReplicatedStorage:FindFirstChild("Shared")
local TraitDefs = nil
if Shared then
    pcall(function() TraitDefs = require(Shared.TraitDefs) end)
end

local function fire(name, ...)
    local r = Remotes:FindFirstChild(name)
    if r and r:IsA("RemoteEvent") then
        local args = table.pack(...)
        pcall(function() r:FireServer(table.unpack(args, 1, args.n)) end)
    end
end

local function invoke(name, ...)
    local r = Remotes:FindFirstChild(name)
    if r and r:IsA("RemoteFunction") then
        local args = table.pack(...)
        local ok, a, b = pcall(function() return r:InvokeServer(table.unpack(args, 1, args.n)) end)
        if ok then return a, b end
    end
    return nil, nil
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
    return LP:GetAttribute("Alive") == true and h ~= nil and h.Health > 0 and root() ~= nil
end
local function num(v)
    v = tonumber(v)
    return v or 0
end
local function partOf(model)
    return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
end
local function radiusOf(model)
    return num(model:GetAttribute("Radius")) * math.max(1, num(model:GetAttribute("Scale")) or 1)
end

local function teleport(pos, lookAt)
    local h = root()
    if not h then return false end
    h.AssemblyLinearVelocity = Vector3.zero
    h.AssemblyAngularVelocity = Vector3.zero
    h.CFrame = lookAt and CFrame.lookAt(pos, lookAt) or CFrame.new(pos)
    return true
end

local function approach(model)
    local p = partOf(model)
    local h = root()
    if not p or not h then return false end
    local target = p.Position
    local flat = Vector3.new(target.X - h.Position.X, 0, target.Z - h.Position.Z)
    local dir = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
    local dist = radiusOf(model) + 2.6
    return teleport(target - dir * dist + Vector3.new(0, 2.2, 0), target)
end

local function nearest(list, valid, maxDist)
    local h = root()
    if not h then return nil end
    local best, bestD = nil, maxDist
    for _, inst in ipairs(list) do
        if inst.Parent and valid(inst) then
            local p = partOf(inst)
            if p then
                local d = (p.Position - h.Position).Magnitude
                if d < bestD then
                    bestD = d
                    best = inst
                end
            end
        end
    end
    return best, bestD
end

local function nearestOrb(maxDist)
    local folder = workspace:FindFirstChild("Orbs")
    local h = root()
    if not folder or not h then return nil end
    local best, bestD = nil, maxDist
    for _, orb in ipairs(folder:GetChildren()) do
        if orb:IsA("BasePart") then
            local d = (orb.Position - h.Position).Magnitude
            if d < bestD then
                bestD = d
                best = orb
            end
        end
    end
    return best, bestD
end

local function bestOrbByXP(maxDist)
    local folder = workspace:FindFirstChild("Orbs")
    local h = root()
    if not folder or not h then return nil end
    local best, bestScore = nil, -1
    for _, orb in ipairs(folder:GetChildren()) do
        if orb:IsA("BasePart") then
            local d = (orb.Position - h.Position).Magnitude
            if d <= maxDist then
                local score = num(orb:GetAttribute("XP")) * 1000 - d
                if score > bestScore then
                    bestScore = score
                    best = orb
                end
            end
        end
    end
    return best
end

local function isBug(inst)
    if inst:GetAttribute("IsPlayer") or inst:GetAttribute("Corpse") then return false end
    local h = inst:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0
end
local function isCorpse(inst)
    return inst:GetAttribute("Corpse") == true and partOf(inst) ~= nil
end
local function isBreakable(inst)
    return partOf(inst) ~= nil and num(inst:GetAttribute("HP")) > 0
end

local function setFreeSprint(on)
    local c = char()
    if not c then return end
    if on then
        if c:GetAttribute("BugEvoFreeSprint") ~= true then
            c:SetAttribute("BugEvoOldFreeSprint", c:GetAttribute("FreeSprint") == true)
            c:SetAttribute("BugEvoFreeSprint", true)
        end
        c:SetAttribute("FreeSprint", true)
    elseif c:GetAttribute("BugEvoFreeSprint") == true then
        c:SetAttribute("FreeSprint", c:GetAttribute("BugEvoOldFreeSprint") == true)
        c:SetAttribute("BugEvoFreeSprint", false)
    end
end

setFreeSprint(false)

-- ================================================================
-- Auto farm
-- ================================================================
local lastCorpseAttack = 0
local lastSprint = false
local farmFlip = false

local function doCorpse()
    local corpse = nearest(CollectionService:GetTagged("Creature"), isCorpse, Config.farmRadius)
    if not corpse then return false end
    if os.clock() - lastCorpseAttack < 0.4 then return true end
    approach(corpse)
    task.wait(0.12)
    lastCorpseAttack = os.clock()
    fire("Attack", corpse)
    return true
end

local function doOrbs()
    local orb
    if Config.orbPriority == "Largest XP" then
        orb = bestOrbByXP(Config.orbRadius)
    else
        orb = nearestOrb(Config.orbRadius)
    end
    if not orb then return false end
    teleport(orb.Position)
    return true
end

local function doTarget()
    local h = root()
    if not h then return false end
    local mode = Config.farmMode
    local bug, brk
    if mode ~= "Orbs Only" then
        if mode ~= "Breakables" then
            bug = nearest(CollectionService:GetTagged("Creature"), isBug, Config.farmRadius)
        end
        if mode ~= "Bugs" then
            brk = nearest(CollectionService:GetTagged("Breakable"), isBreakable, Config.farmRadius)
        end
    end

    local target, bestD
    if bug then target, bestD = bug, (partOf(bug).Position - h.Position).Magnitude end
    if brk then
        local d = (partOf(brk).Position - h.Position).Magnitude
        if not target or d < bestD then target = brk end
    end
    if not target then return false end

    approach(target)
    return true
end

local function setAutoAttack(on)
    pcall(function()
        local Controls = require(LP.PlayerScripts.Client.Controls)
        if Controls and Controls.SetAutoAttack then Controls.SetAutoAttack(on == true) end
    end)
end

-- ================================================================
-- Auto evolve / respawn / rewards
-- ================================================================
local lastEvolve, lastRespawn, lastReward = 0, 0, 0
local evolveFailUntil = 0

local function doEvolve()
    local now = os.clock()
    if now < evolveFailUntil or now - lastEvolve < 2 then return end
    if LP:GetAttribute("Transforming") then return end
    local level = num(LP:GetAttribute("Level"))
    local need = num(LP:GetAttribute("NextStageLevel"))
    local stage = num(LP:GetAttribute("Stage"))
    local maxStage = num(LP:GetAttribute("StageCount"))
    if need <= 0 or level < need or (maxStage > 0 and stage >= maxStage) then return end

    lastEvolve = now
    local ok, msg = invoke("Evolve")
    if ok ~= true then
        evolveFailUntil = now + 10
        if type(msg) == "string" and msg ~= "" then print("[BugEvo] Evolve:", msg) end
    end
end

local function doRespawn()
    if LP:GetAttribute("Alive") ~= false then return end
    if os.clock() - lastRespawn < 2 then return end
    lastRespawn = os.clock()
    fire("RequestSpawn", "Respawn")
end

local function doRewards()
    if os.clock() - lastReward < 25 then return end
    lastReward = os.clock()
    invoke("Rewards", "ClaimPlaytime")
end

-- ================================================================
-- Trait picker
-- ================================================================
local function traitScore(id)
    if not TraitDefs then return 0 end
    local ok, t = pcall(function() return TraitDefs.Get(id) end)
    if not ok or type(t) ~= "table" then return 0 end
    local b = t.Bonus or {}
    local pref = Config.traitPref
    local s = 0
    if pref == "XP Gain" then
        s = num(b.XPGain) * 200
    elseif pref == "Offensive" then
        s = num(b.Damage) * 160 + num(b.AttackSpeed) * 120 + num(b.Reach) * 80 + num(b.Crit) * 60
    elseif pref == "Defensive" then
        s = num(b.Health) * 160 + num(b.DamageReduction) * 200 + num(b.Lifesteal) * 120 + num(b.Healing) * 100
    else
        s = num(b.Speed) * 160 + num(b.Stamina) * 100 + num(b.SprintCost) * -60
    end
    for _, v in pairs(b) do
        if num(v) < 0 then s = s + num(v) * 60 end
    end
    return s
end

local connections = {}

pcall(function()
    connections[#connections + 1] = Remotes.TraitOffer.OnClientEvent:Connect(function(offer)
        if not Config.autoTrait or type(offer) ~= "table" then return end
        task.delay(0.35, function()
            if not Config.autoTrait then return end
            local best, bestScore = 1, -math.huge
            for i, id in ipairs(offer) do
                local s = traitScore(id)
                if s > bestScore then
                    bestScore = s
                    best = i
                end
            end
            fire("PickTrait", best)
        end)
    end)
end)

-- ================================================================
-- Anti AFK
-- ================================================================
connections[#connections + 1] = LP.Idled:Connect(function()
    if not Config.antiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ================================================================
-- Fly
-- ================================================================
local flyVel, flyAttach, flyAlign = nil, nil, nil

local function stopFly()
    if flyVel then flyVel:Destroy() end
    if flyAlign then flyAlign:Destroy() end
    if flyAttach then flyAttach:Destroy() end
    flyVel, flyAlign, flyAttach = nil, nil, nil
    local c, h = char(), hum()
    if h then
        h.PlatformStand = false
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Freefall) end)
    end
    if c then c:SetAttribute("Flying", false) end
    fire("SetFlying", false)
end

local function startFly()
    local c, h, r = char(), hum(), root()
    if not c or not h or not r then return false end
    stopFly()
    flyAttach = Instance.new("Attachment")
    flyAttach.Name = "BugEvoFly"
    flyAttach.Parent = r
    flyVel = Instance.new("LinearVelocity")
    flyVel.Attachment0 = flyAttach
    flyVel.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVel.MaxForce = math.huge
    flyVel.VectorVelocity = Vector3.zero
    flyVel.Parent = r
    flyAlign = Instance.new("AlignOrientation")
    flyAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyAlign.Attachment0 = flyAttach
    flyAlign.MaxTorque = math.huge
    flyAlign.Responsiveness = 18
    flyAlign.CFrame = CFrame.lookAt(Vector3.zero, workspace.CurrentCamera.CFrame.LookVector)
    flyAlign.Parent = r
    h.PlatformStand = true
    c:SetAttribute("Flying", true)
    fire("SetFlying", true)
    return true
end

-- ================================================================
-- Fullbright
-- ================================================================
local oldLight = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local oldAtmosphereDensity = atmosphere and atmosphere.Density or 0

local function setFullbright(on)
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.Ambient = Color3.fromRGB(140, 140, 140)
        Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
        if atmosphere then atmosphere.Density = 0 end
    else
        Lighting.Brightness = oldLight.Brightness
        Lighting.ClockTime = oldLight.ClockTime
        Lighting.FogEnd = oldLight.FogEnd
        Lighting.Ambient = oldLight.Ambient
        Lighting.OutdoorAmbient = oldLight.OutdoorAmbient
        if atmosphere then atmosphere.Density = oldAtmosphereDensity end
    end
end

-- ================================================================
-- ESP (Drawing only: safe from the hub GUI capability wall)
-- ================================================================
local esp = {}
local fullbrightOn = false

local function getESP(inst)
    local e = esp[inst]
    if e then return e end
    local t, l
    local ok = pcall(function()
        t = Drawing.new("Text")
        t.Size = 13
        t.Center = true
        t.Outline = true
        t.OutlineColor = Color3.new(0, 0, 0)
        if Drawing.Fonts then t.Font = Drawing.Fonts.Plex end
        t.Visible = false
        l = Drawing.new("Line")
        l.Thickness = 1
        l.Transparency = 0.6
        l.Visible = false
    end)
    if not ok or not t or not l then
        if t then t:Remove() end
        if l then l:Remove() end
        return nil
    end
    e = { text = t, line = l }
    esp[inst] = e
    return e
end

local function destroyESP(inst)
    local e = esp[inst]
    if e then
        pcall(function() e.text:Remove() end)
        pcall(function() e.line:Remove() end)
        esp[inst] = nil
    end
end

local function clearESP()
    local list = {}
    for inst in pairs(esp) do list[#list + 1] = inst end
    for _, inst in ipairs(list) do destroyESP(inst) end
end

local function updateESP()
    local cam = workspace.CurrentCamera
    local r = root()
    if not cam or not r then
        clearESP()
        return
    end
    local vp = cam.ViewportSize
    local bottom = Vector2.new(vp.X / 2, vp.Y)
    local seen = {}
    local any = Config.espBugs or Config.espBreak or Config.espOrbs or Config.espPlayers

    local function show(inst, pos, label, color, height, tracer)
        if not inst.Parent then return end
        local sp, onScreen = cam:WorldToViewportPoint(pos + Vector3.new(0, height or 2, 0))
        local e = getESP(inst)
        if not e then return end
        if not onScreen or sp.Z <= 0 then
            e.text.Visible = false
            e.line.Visible = false
            return
        end
        seen[inst] = true
        e.text.Text = label
        e.text.Position = Vector2.new(sp.X, sp.Y)
        e.text.Color = color
        e.text.Visible = true
        e.line.From = bottom
        e.line.To = Vector2.new(sp.X, sp.Y)
        e.line.Color = color
        e.line.Visible = Config.espTracers and tracer ~= false
    end

    if any then
        if Config.espBugs then
            for _, inst in ipairs(CollectionService:GetTagged("Creature")) do
                if inst.Parent and not inst:GetAttribute("IsPlayer") then
                    local p = partOf(inst)
                    local h = inst:FindFirstChildOfClass("Humanoid")
                    if p and h then
                        local d = (p.Position - r.Position).Magnitude
                        if d <= Config.espRange then
                            local maxH = h.MaxHealth > 0 and h.MaxHealth or 1
                            local hp = math.clamp(math.floor(h.Health / maxH * 100), 0, 100)
                            local corpse = inst:GetAttribute("Corpse") == true
                            local label = (corpse and "[Corpse] " or "") .. tostring(inst:GetAttribute("BugId") or inst.Name)
                                .. "  " .. (corpse and "" or (hp .. "%  ")) .. math.floor(d) .. "m"
                            show(inst, p.Position, label, corpse and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 170, 60), radiusOf(inst) * 1.6 + 1.5)
                        end
                    end
                end
            end
        end
        if Config.espBreak then
            for _, inst in ipairs(CollectionService:GetTagged("Breakable")) do
                local p = partOf(inst)
                if inst.Parent and p then
                    local d = (p.Position - r.Position).Magnitude
                    if d <= Config.espRange then
                        local hp = num(inst:GetAttribute("HP"))
                        local maxH = math.max(1, num(inst:GetAttribute("MaxHP")))
                        local label = tostring(inst:GetAttribute("BreakId") or inst.Name)
                            .. "  " .. math.floor(hp / maxH * 100) .. "%  "
                            .. math.floor(d) .. "m  +" .. math.floor(num(inst:GetAttribute("XP"))) .. "xp"
                        show(inst, p.Position, label, Color3.fromRGB(90, 240, 255), radiusOf(inst) * 1.6 + 2)
                    end
                end
            end
        end
        if Config.espOrbs then
            local folder = workspace:FindFirstChild("Orbs")
            if folder then
                local near = {}
                local orbRange = math.min(Config.espRange, 80)
                for _, orb in ipairs(folder:GetChildren()) do
                    if orb:IsA("BasePart") then
                        local d = (orb.Position - r.Position).Magnitude
                        if d <= orbRange then near[#near + 1] = { orb = orb, d = d } end
                    end
                end
                table.sort(near, function(a, b) return a.d < b.d end)
                for i = 1, math.min(#near, 15) do
                    local entry = near[i]
                    local xp = num(entry.orb:GetAttribute("XP"))
                    local col = xp >= 18 and Color3.fromRGB(255, 110, 220)
                        or (xp >= 6 and Color3.fromRGB(255, 220, 90) or Color3.fromRGB(140, 255, 180))
                    show(entry.orb, entry.orb.Position, "Orb +" .. math.floor(xp) .. "  " .. math.floor(entry.d) .. "m", col, 2, false)
                end
            end
        end
        if Config.espPlayers then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP then
                    local c = pl.Character
                    local p = c and c:FindFirstChild("HumanoidRootPart")
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if p and h and h.Health > 0 then
                        local d = (p.Position - r.Position).Magnitude
                        if d <= Config.espRange then
                            local lvl = num(pl:GetAttribute("Level"))
                            local stage = tostring(pl:GetAttribute("StageName") or pl:GetAttribute("StageId") or "")
                            local label = pl.Name .. "  Lv" .. lvl .. (stage ~= "" and (" " .. stage) or "")
                                .. "  " .. math.floor(h.Health / math.max(1, h.MaxHealth) * 100) .. "%  " .. math.floor(d) .. "m"
                            show(p, p.Position, label, Color3.fromRGB(255, 120, 120), 4)
                        end
                    end
                end
            end
        end
    end

    local remove = nil
    for inst, e in pairs(esp) do
        if not seen[inst] then
            e.text.Visible = false
            e.line.Visible = false
            if not inst.Parent then
                remove = remove or {}
                remove[#remove + 1] = inst
            end
        end
    end
    if remove then
        for _, inst in ipairs(remove) do destroyESP(inst) end
    end
end

task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        if fullbrightOn ~= Config.fullbright then
            fullbrightOn = Config.fullbright
            setFullbright(fullbrightOn)
        end
        updateESP()
        task.wait(0.12)
    end
    clearESP()
    setFullbright(false)
end)

-- ================================================================
-- Heartbeat: sprint / fly
-- ================================================================
connections[#connections + 1] = RunService.Heartbeat:Connect(function()
    if rawget(_G, _G_TOMB) == true then return end
    local c, h = char(), hum()
    if not c or not h then return end

    if Config.infiniteSprint and alive() then
        setFreeSprint(true)
        LP:SetAttribute("Stamina", num(LP:GetAttribute("MaxStamina")) > 0 and num(LP:GetAttribute("MaxStamina")) or 100)
        LP:SetAttribute("Exhausted", false)
    else
        setFreeSprint(false)
        if Config.autoSprint then
            local want = h.MoveDirection.Magnitude > 0.05
            if want ~= lastSprint then
                lastSprint = want
                fire("SetSprint", want)
            end
        end
    end

    if Config.fly then
        if not alive() then
            if flyVel then stopFly() end
        elseif not flyVel then
            startFly()
        else
            local cam = workspace.CurrentCamera
            local fwd = (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
                - (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
            local side = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0)
                - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
            local flat = cam.CFrame.LookVector * Vector3.new(1, 0, 1)
            flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
            local dir = (flat * fwd + cam.CFrame.RightVector * side)
            if dir.Magnitude > 1 then dir = dir.Unit end
            local vel = dir * Config.flySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, Config.flySpeed * 0.8, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, Config.flySpeed * 0.8, 0) end
            flyVel.VectorVelocity = vel
            flyAlign.CFrame = CFrame.lookAt(Vector3.zero, cam.CFrame.LookVector)
        end
    elseif flyVel then
        stopFly()
    end
end)

-- ================================================================
-- UI
-- ================================================================
local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Bug Evolution",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Bug Evolution",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
})

pcall(function()
    for _, v in ipairs(Window.Container:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Oxidelib is ready" then v:Destroy() end
    end
end)

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "crosshair", Subtitle = "Farm & Evolve" })
local FarmSub = FarmTab:AddSubTab("Features")

FarmSub:AddSection("Farm")
FarmSub:AddToggle({
    Name = "Auto Farm",
    Flag = "be_farm",
    Default = false,
    Callback = function(v)
        Config.autoFarm = v
        if v then setAutoAttack(true) end
    end,
})
FarmSub:AddDropdown({
    Name = "Farm Mode",
    Flag = "be_farmmode",
    Options = { "Bugs & Breakables", "Bugs", "Breakables", "Orbs Only", "Balanced" },
    Default = "Bugs & Breakables",
    Callback = function(v) Config.farmMode = v end,
})
FarmSub:AddSlider({
    Name = "Farm Radius",
    Flag = "be_farmradius",
    Min = 50,
    Max = 1000,
    Default = 300,
    Suffix = "m",
    Callback = function(v) Config.farmRadius = v end,
})
FarmSub:AddToggle({
    Name = "Auto Eat Corpses",
    Flag = "be_corpse",
    Default = false,
    Callback = function(v) Config.autoCorpse = v end,
})

FarmSub:AddSection("Orbs")
FarmSub:AddToggle({
    Name = "Auto Collect Orbs",
    Flag = "be_orbs",
    Default = false,
    Callback = function(v) Config.autoOrbs = v end,
})
FarmSub:AddDropdown({
    Name = "Orb Priority",
    Flag = "be_orbprio",
    Options = { "Nearest", "Largest XP" },
    Default = "Nearest",
    Callback = function(v) Config.orbPriority = v end,
})
FarmSub:AddSlider({
    Name = "Orb Radius",
    Flag = "be_orbradius",
    Min = 50,
    Max = 1000,
    Default = 300,
    Suffix = "m",
    Callback = function(v) Config.orbRadius = v end,
})

FarmSub:AddSection("Evolve & Traits")
FarmSub:AddToggle({
    Name = "Auto Evolve",
    Flag = "be_evolve",
    Default = false,
    Callback = function(v) Config.autoEvolve = v end,
})
FarmSub:AddToggle({
    Name = "Auto Pick Trait",
    Flag = "be_trait",
    Default = false,
    Callback = function(v) Config.autoTrait = v end,
})
FarmSub:AddDropdown({
    Name = "Trait Preference",
    Flag = "be_traitpref",
    Options = { "XP Gain", "Offensive", "Defensive", "Movement" },
    Default = "XP Gain",
    Callback = function(v) Config.traitPref = v end,
})

FarmSub:AddSection("Utility")
FarmSub:AddToggle({
    Name = "Auto Respawn",
    Flag = "be_respawn",
    Default = false,
    Callback = function(v) Config.autoRespawn = v end,
})
FarmSub:AddToggle({
    Name = "Auto Claim Playtime",
    Flag = "be_rewards",
    Default = false,
    Callback = function(v) Config.autoRewards = v end,
})
FarmSub:AddToggle({
    Name = "Anti AFK",
    Flag = "be_afk",
    Default = true,
    Callback = function(v) Config.antiAfk = v end,
})

local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local VisualSub = VisualTab:AddSubTab("Features")

VisualSub:AddSection("ESP")
VisualSub:AddToggle({
    Name = "ESP Bugs",
    Flag = "be_espbugs",
    Default = false,
    Callback = function(v) Config.espBugs = v end,
})
VisualSub:AddToggle({
    Name = "ESP Breakables",
    Flag = "be_espbreak",
    Default = false,
    Callback = function(v) Config.espBreak = v end,
})
VisualSub:AddToggle({
    Name = "ESP Orbs",
    Flag = "be_esporbs",
    Default = false,
    Callback = function(v) Config.espOrbs = v end,
})
VisualSub:AddToggle({
    Name = "ESP Players",
    Flag = "be_espplayers",
    Default = false,
    Callback = function(v) Config.espPlayers = v end,
})
VisualSub:AddToggle({
    Name = "Tracers",
    Flag = "be_tracers",
    Default = false,
    Callback = function(v) Config.espTracers = v end,
})
VisualSub:AddSlider({
    Name = "ESP Range",
    Flag = "be_esprange",
    Min = 50,
    Max = 1000,
    Default = 250,
    Suffix = "m",
    Callback = function(v) Config.espRange = v end,
})

VisualSub:AddSection("World")
VisualSub:AddToggle({
    Name = "Fullbright / No Fog",
    Flag = "be_fullbright",
    Default = false,
    Callback = function(v) Config.fullbright = v end,
})

local PlayerTab = Window:AddTab({ Name = "Player", Icon = "running", Subtitle = "Movement" })
local PlayerSub = PlayerTab:AddSubTab("Features")

PlayerSub:AddSection("Sprint")
PlayerSub:AddToggle({
    Name = "Auto Sprint",
    Flag = "be_sprint",
    Default = false,
    Callback = function(v)
        Config.autoSprint = v
        if not v and not Config.infiniteSprint then fire("SetSprint", false) end
    end,
})
PlayerSub:AddToggle({
    Name = "Infinite Sprint",
    Flag = "be_inf",
    Default = false,
    Callback = function(v)
        Config.infiniteSprint = v
        if not v then
            setFreeSprint(false)
            fire("SetSprint", false)
        end
    end,
})

PlayerSub:AddSection("Fly")
PlayerSub:AddToggle({
    Name = "Fly (local)",
    Flag = "be_fly",
    Default = false,
    Callback = function(v)
        Config.fly = v
        if v then
            if not startFly() then Config.fly = false end
        else
            stopFly()
        end
    end,
})
PlayerSub:AddSlider({
    Name = "Fly Speed",
    Flag = "be_flyspeed",
    Min = 20,
    Max = 200,
    Default = 45,
    Callback = function(v) Config.flySpeed = v end,
})

PlayerSub:AddSection("Info")
PlayerSub:AddButton({
    Name = "Show Stats",
    Callback = function()
        Window:Notify({
            Title = "Stats",
            Content = string.format(
                "Level %s  Â·â•–  XP %s/%s  Â·â•–  Stage %s  Â·â•–  Coins %s  Â·â•–  Zone %s",
                tostring(LP:GetAttribute("Level")),
                tostring(LP:GetAttribute("XP")),
                tostring(LP:GetAttribute("XPNeed")),
                tostring(LP:GetAttribute("StageName")),
                tostring(LP:GetAttribute("Coins")),
                tostring(LP:GetAttribute("Zone") or "-")
            ),
            Type = "info",
            Duration = 6,
        })
    end,
})

-- ================================================================
-- Settings
-- ================================================================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
ConfigSub:AddSection("Config")

local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Flag = "be_configdrop",
    Callback = function(v) selectedConfig = v end,
})
local configInput = ConfigSub:AddInput({
    Name = "Config Name",
    Flag = "be_configname",
    PlaceholderText = "Enter config name",
})

local function refreshConfigList()
    configDropdown:SetOptions(Library:ListConfigs())
end

ConfigSub:AddDivider()
ConfigSub:AddButton({
    Name = "Save Config",
    Callback = function()
        local name = configInput.Value
        if not name or name == "" then
            Window:Notify({ Title = "Config", Content = "Enter a name first!", Type = "warning", Duration = 3 })
            return
        end
        if Library:SaveConfig(name) then
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
        if selectedConfig == "" then
            Window:Notify({ Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3 })
            return
        end
        if Library:LoadConfig(selectedConfig) then
            Window:Notify({ Title = "Config", Content = "Loaded: " .. selectedConfig, Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Config", Content = "Failed to load!", Type = "error", Duration = 3 })
        end
    end,
})
ConfigSub:AddButton({
    Name = "Delete Config",
    Callback = function()
        if selectedConfig == "" then
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
task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do
        if alive() and not LP:GetAttribute("Transforming") then
            if Config.autoEvolve then doEvolve() end
            if Config.autoRewards then doRewards() end

            local did = false
            if Config.autoFarm then
                farmFlip = not farmFlip
                if Config.farmMode == "Orbs Only" then
                    did = doOrbs()
                elseif Config.farmMode == "Balanced" then
                    did = farmFlip and doTarget() or doOrbs()
                else
                    did = doTarget()
                end
            end
            if not did and Config.autoCorpse then did = doCorpse() end
            if not did and Config.autoOrbs then did = doOrbs() end
        end

        if Config.autoRespawn then doRespawn() end

        task.wait((Config.autoFarm or Config.autoOrbs or Config.autoCorpse) and 0.2 or 0.4)
    end
end)

task.spawn(function()
    while rawget(_G, _G_TOMB) ~= true do task.wait(0.1) end
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    setFreeSprint(false)
end)
