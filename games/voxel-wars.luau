-- Voxel Wars - Exlumiaa Hub
-- universe 10773416193 / place 78884249003161
--
-- Client-side only: ESP, aimbot, silent aim, trigger bot, no recoil.
-- Nothing here writes health, damage, scrap or XP. The game paints a red/purple
-- tag over anyone who fires its bait remotes (togglegod, setwalkspeed,
-- applydamage, espupdate, aimassisttarget, ...), so those are never touched.
--
-- Key system: Panda Auth (exlumiaa).

if tostring(game.GameId) ~= "10773416193" then return end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local GEN = (tonumber(getgenv().__voxelWarsGen) or 0) + 1
getgenv().__voxelWarsGen = GEN

-- Drawing objects outlive the script: without this the old run's ESP boxes and
-- FOV circle stay on screen after a reload.
pcall(cleardrawcache)

local function stale()
    return tonumber(getgenv().__voxelWarsGen) ~= GEN
end

local function cleanupGui(name)
    pcall(function()
        local cg = game:GetService("CoreGui")
        for _, gui in ipairs(cg:GetChildren()) do
            if gui.Name == name then gui:Destroy() end
        end
        -- Oxidelib parents its screens under RobloxGui, not directly under CoreGui.
        local rg = cg:FindFirstChild("RobloxGui")
        for _, gui in ipairs(rg and rg:GetChildren() or {}) do
            if gui.Name == name then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        for _, gui in ipairs(pg and pg:GetChildren() or {}) do
            if gui.Name == name then gui:Destroy() end
        end
    end)
end
cleanupGui("ExlumiaaHub")
-- One tag gui is left behind per reload by the UI library.
cleanupGui("OxidelibTagGui")
cleanupGui("VoxelWarsKeyGate")

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_voxelwars.txt"
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
            brand = "Voxel Wars",
            guiName = "VoxelWarsKeyGate",
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
-- STATE
-- ================================================================
local S = {
    teamCheck = true,
    -- aimbot
    aim = false, aimFov = 20, aimSmooth = 6, aimPred = true, aimSpeed = 1700,
    aimPart = "Head", aimWall = true, aimKey = nil,
    -- silent aim (ballistics launch-direction redirect)
    silent = false, silentFov = 25,
    -- trigger bot
    trigger = false, triggerFov = 5, triggerDelay = 120,
    -- weapon
    noRecoil = false,
    -- esp
    esp = false, espBox = true, espFill = false, espName = true, espDist = true,
    espHealth = true, espTracer = false, espSkel = false, espHead = false,
    espBots = true, espObj = false, espMax = 900,
    -- misc
    autoSprint = false,
}

local connections = {}
local function track(conn)
    connections[#connections + 1] = conn
    return conn
end

local function disconnectAll()
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}
end

-- ================================================================
-- TARGETS
-- ================================================================
local function collectTargets()
    local list = {}
    local myTeam = LP.Team and LP.Team.Name

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local team = p.Team and p.Team.Name
                list[#list + 1] = {
                    char = char, hum = hum, name = p.DisplayName,
                    friendly = team ~= nil and team == myTeam,
                    protected = false, isBot = false,
                }
            end
        end
    end

    local rigs = workspace:FindFirstChild("BotRigs")
    if rigs then
        for _, m in ipairs(rigs:GetChildren()) do
            local hum = m:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and m:GetAttribute("Alive") ~= false then
                local team = m:GetAttribute("Team")
                list[#list + 1] = {
                    char = m, hum = hum, name = m.Name,
                    friendly = team ~= nil and team == myTeam,
                    protected = m:GetAttribute("Protected") == true, isBot = true,
                }
            end
        end
    end

    return list
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function hasLOS(t, pos)
    if not S.aimWall then return true end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local filter = {}
    if LP.Character then filter[#filter + 1] = LP.Character end
    if t.char then filter[#filter + 1] = t.char end
    -- The first-person viewmodel hangs off the camera and sits right in front of
    -- it, so leaving it in the filter makes every target read as wall-blocked.
    if cam then filter[#filter + 1] = cam end
    rayParams.FilterDescendantsInstances = filter
    local res = workspace:Raycast(cam.CFrame.Position, pos - cam.CFrame.Position, rayParams)
    return res == nil
end

local function aimPosOf(t)
    local char = t.char
    if not char then return nil end
    local part = char:FindFirstChild(S.aimPart)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
    if not part then return nil end
    local pos = part.Position
    if S.aimPred then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local vel = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
        local cam = workspace.CurrentCamera
        if cam then
            local dist = (pos - cam.CFrame.Position).Magnitude
            pos = pos + vel * (dist / math.max(S.aimSpeed, 1))
        end
    end
    return pos, part
end

-- Closest to crosshair inside a cone of `fovDeg` degrees.
local function pickTarget(list, fovDeg)
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local origin = cam.CFrame.Position
    local look = cam.CFrame.LookVector
    local best, bestDot = nil, math.cos(math.rad(fovDeg))

    for _, t in ipairs(list) do
        if not (S.teamCheck and t.friendly) and not t.protected then
            local pos = aimPosOf(t)
            if pos then
                local delta = pos - origin
                local len = delta.Magnitude
                if len > 1 then
                    local dot = delta.Unit:Dot(look)
                    if dot > bestDot and hasLOS(t, pos) then
                        bestDot = dot
                        best = { target = t, pos = pos }
                    end
                end
            end
        end
    end

    return best
end

-- ================================================================
-- FIRING
-- ================================================================
local remotesFolder = RS:FindFirstChild("Voxel")
    and RS.Voxel:FindFirstChild("Remotes")

local fireRemotes = {}
local function refreshFireRemotes()
    fireRemotes = {}
    if not remotesFolder then return end
    for _, c in ipairs(remotesFolder:GetChildren()) do
        if c:IsA("RemoteEvent") and string.sub(c.Name, 1, 4) == "Fire" then
            fireRemotes[c] = true
        end
    end
end
refreshFireRemotes()

-- Tool.LocalScript is named after the weapon family: PistolClient -> FirePistol.
local function equippedWeapon()
    local char = LP.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    local ls = tool:FindFirstChildOfClass("LocalScript")
    if not ls then return nil end
    local base = string.gsub(ls.Name, "Client$", "")
    local remote = remotesFolder and remotesFolder:FindFirstChild("Fire" .. base)
    if not remote then return nil end
    return tool, remote
end

-- ================================================================
-- SILENT AIM (Ballistics hook)
-- The game's launch direction is solved inside Ballistics:
--   v1 = Ballistics.launch / zeroed(muzzle, aimPoint, speed, arc)
-- In this executor, hookfunction makes the ORIGINAL function unreachable, so the
-- wrappers re-solve the exact upstream maths themselves and never call it.
-- ================================================================
local ballistics = nil
do
    local vox = RS:FindFirstChild("Voxel")
    if vox then
        local mod = vox:FindFirstChild("Ballistics")
        if mod then
            local ok, m = pcall(require, mod)
            if ok and type(m) == "table" then ballistics = m end
        end
    end
end

local ballisticsHooked = false

local function flightTimeMath(a1, a2, a3)
    local v1
    local SPEED = a2 or 1700
    if not a3 then
        local SPD = a2 or 1700
        v1 = false
        if 1600 <= SPD then
            v1 = SPD < 2000
        end
    else
        v1 = true
    end
    if not v1 then
        return a1 / SPEED
    end
    local drag = if not a3 then 0.0014 else a3.drag
    return (math.exp(drag * a1) - 1) / (drag * SPEED)
end

-- Replica of Ballistics.launch (ReplicatedStorage.Voxel.Ballistics), line for line.
local function launchMath(a1, a2, a3, a4)
    local v1
    local v2 = a2 - a1
    if not a4 then
        local SPEED = a3 or 1700
        v1 = false
        if 1600 <= SPEED then
            v1 = SPEED < 2000
        end
    else
        v1 = true
    end
    if not v1 then
        return v2.Unit
    end
    v1 = flightTimeMath(v2.Magnitude, a3, a4)
    local SPEED_2 = a3 or 1700
    local drag = if not a4 then 0.0014 else a4.drag
    local v3 = drag * SPEED_2
    local gravity = if not a4 then 24.525 else a4.gravity
    return (v2 + Vector3.new(0, gravity * (v1 * v1 / 4 + (v3 * v1 - math.log(1 + v3 * v1)) / (2 * v3 * v3)), 0)).Unit
end

local function silentPick()
    if not S.silent then return nil end
    local ok, pick = pcall(pickTarget, collectTargets(), tonumber(S.silentFov) or 25)
    if not ok then return nil end
    return pick
end

local function launchWrapper(a1, a2, a3, a4)
    local pick = silentPick()
    local aim = a2
    if pick and typeof(a1) == "Vector3" and typeof(pick.pos) == "Vector3" then
        aim = pick.pos
    end
    return launchMath(a1, aim, a3, a4)
end

local function zeroedWrapper(a1, a2, a3, a4)
    local pick = silentPick()
    if pick and typeof(a1) == "Vector3" and typeof(pick.pos) == "Vector3" then
        return launchMath(a1, pick.pos, a3, a4)
    end
    return launchMath(a1, a1 + a2 * 250, a3, a4)
end

-- Always installed; with S.silent off the wrappers are faithful replicas of the
-- original functions, so the game's weapons behave exactly as before.
local function installBallisticsHook()
    if ballisticsHooked or not ballistics then return end
    if type(hookfunction) ~= "function" then return end
    local ok1 = pcall(hookfunction, ballistics.launch, launchWrapper)
    local ok2 = pcall(hookfunction, ballistics.zeroed, zeroedWrapper)
    ballisticsHooked = ok1 and ok2
end

installBallisticsHook()

local function restoreBallisticsHook()
    S.silent = false
end

-- ================================================================
-- NO RECOIL (the recoil module is the shared prototype of every gun)
-- ================================================================
local recoilModule = nil
do
    local ok, m = pcall(require, RS:FindFirstChild("Voxel") and RS.Voxel:FindFirstChild("GunRecoil") or nil)
    if ok and type(m) == "table" then recoilModule = m end
end

local recoilOrigStep, recoilOrigShot

local function applyNoRecoil(on)
    if not recoilModule then return end
    if on then
        if recoilOrigStep then return end
        recoilOrigStep = recoilModule.step
        recoilOrigShot = recoilModule.shot
        recoilModule.step = function() return 0, 0, 0 end
        recoilModule.shot = function() end
    elseif recoilOrigStep then
        recoilModule.step = recoilOrigStep
        recoilModule.shot = recoilOrigShot
        recoilOrigStep, recoilOrigShot = nil, nil
    end
end

-- ================================================================
-- ESP (Drawing)
-- ================================================================
local BONES = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}

local ENEMY = Color3.fromRGB(255, 62, 84)
local FRIENDLY = Color3.fromRGB(90, 220, 140)

local espCache = {}
local objCache = {}

local function mk(class, props)
    local ok, d = pcall(function() return Drawing.new(class) end)
    if not ok or not d then return nil end
    for k, v in pairs(props or {}) do
        pcall(function() d[k] = v end)
    end
    return d
end

local function killObj(o)
    if not o then return end
    pcall(function()
        if isrenderobj(o) then o:Remove() end
    end)
end

local function makeEspEntry()
    local e = { box = {}, out = {}, skel = {}, skelOut = {} }
    for i = 1, 4 do
        e.out[i] = mk("Line", { Thickness = 3, Color = Color3.new(0, 0, 0), Visible = false })
        e.box[i] = mk("Line", { Thickness = 1.5, Visible = false })
    end
    for i = 1, #BONES do
        e.skelOut[i] = mk("Line", { Thickness = 3, Color = Color3.new(0, 0, 0), Visible = false })
        e.skel[i] = mk("Line", { Thickness = 1.2, Visible = false })
    end
    e.fill = mk("Quad", { Filled = true, Transparency = 0.8, Visible = false })
    e.name = mk("Text", { Size = 13, Center = true, Outline = true, Visible = false })
    e.dist = mk("Text", { Size = 11, Center = true, Outline = true, Visible = false })
    e.hpBg = mk("Quad", { Filled = true, Color = Color3.new(0, 0, 0), Transparency = 0.4, Visible = false })
    e.hpFg = mk("Quad", { Filled = true, Visible = false })
    e.tracer = mk("Line", { Thickness = 1, Transparency = 0.4, Visible = false })
    e.head = mk("Circle", { Radius = 3, Filled = true, Visible = false })
    if not (e.box[1] and e.fill and e.name and e.hpFg and e.tracer and e.head) then
        for _, v in pairs(e) do
            if type(v) == "table" then
                for _, o in ipairs(v) do killObj(o) end
            else
                killObj(v)
            end
        end
        return nil
    end
    return e
end

local function destroyEntry(e)
    if not e then return end
    for _, v in pairs(e) do
        if type(v) == "table" then
            for _, o in ipairs(v) do killObj(o) end
        else
            killObj(v)
        end
    end
end

local function hideEntry(e)
    if not e then return end
    for _, v in pairs(e) do
        if type(v) == "table" then
            for _, o in ipairs(v) do pcall(function() o.Visible = false end) end
        else
            pcall(function() v.Visible = false end)
        end
    end
end

local function boundingBox(char, cam)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return nil end

    local topWorld = head.Position + Vector3.new(0, 0.75, 0)
    local botWorld = hrp.Position - Vector3.new(0, 3.1, 0)
    local a, aOn = cam:WorldToViewportPoint(topWorld)
    local b, bOn = cam:WorldToViewportPoint(botWorld)
    if not aOn and not bOn then return nil end

    local cx = (a.X + b.X) * 0.5
    local topY = a.Y
    local botY = b.Y
    local h = math.abs(botY - topY)
    if h < 2 then return nil end
    local w = h * 0.45

    return {
        tl = Vector2.new(cx - w * 0.5, topY),
        tr = Vector2.new(cx + w * 0.5, topY),
        bl = Vector2.new(cx - w * 0.5, botY),
        br = Vector2.new(cx + w * 0.5, botY),
        cx = cx, topY = topY, botY = botY, w = w, h = h,
        head = head,
    }
end

local function updateEsp(t, cam)
    local key = t.char
    local e = espCache[key]

    if not S.esp or (S.teamCheck and t.friendly) or (t.isBot and not S.espBots) then
        hideEntry(e)
        return
    end

    local bb = boundingBox(t.char, cam)
    if not bb then
        hideEntry(e)
        return
    end

    local dist = (cam.CFrame.Position - bb.head.Position).Magnitude
    if dist > S.espMax then
        hideEntry(e)
        return
    end

    if not e then
        e = makeEspEntry()
        if not e then return end
        espCache[key] = e
    end

    local col = t.friendly and FRIENDLY or ENEMY

    for i = 1, 4 do
        e.out[i].Visible = S.espBox
        e.box[i].Visible = S.espBox
    end
    if S.espBox then
        e.out[1].From, e.out[1].To = bb.tl, bb.tr
        e.out[2].From, e.out[2].To = bb.bl, bb.br
        e.out[3].From, e.out[3].To = bb.tl, bb.bl
        e.out[4].From, e.out[4].To = bb.tr, bb.br
        e.box[1].From, e.box[1].To = bb.tl, bb.tr
        e.box[2].From, e.box[2].To = bb.bl, bb.br
        e.box[3].From, e.box[3].To = bb.tl, bb.bl
        e.box[4].From, e.box[4].To = bb.tr, bb.br
        for i = 1, 4 do e.box[i].Color = col end
    end

    if S.espFill then
        e.fill.PointA, e.fill.PointB = bb.tl, bb.tr
        e.fill.PointC, e.fill.PointD = bb.br, bb.bl
        e.fill.Color = col
        e.fill.Visible = true
    else
        e.fill.Visible = false
    end

    if S.espName then
        e.name.Text = t.name .. (t.protected and " [PROT]" or "")
        e.name.Position = Vector2.new(bb.cx, bb.topY - 14)
        e.name.Color = col
        e.name.Visible = true
    else
        e.name.Visible = false
    end

    if S.espDist then
        e.dist.Text = string.format("%dm", math.floor(dist))
        e.dist.Position = Vector2.new(bb.cx, bb.botY + 3)
        e.dist.Color = col
        e.dist.Visible = true
    else
        e.dist.Visible = false
    end

    if S.espHealth then
        local hp = math.clamp(t.hum.Health / math.max(t.hum.MaxHealth, 1), 0, 1)
        local bx = bb.tr.X + 4
        e.hpBg.PointA = Vector2.new(bx, bb.topY)
        e.hpBg.PointB = Vector2.new(bx + 3, bb.topY)
        e.hpBg.PointC = Vector2.new(bx + 3, bb.botY)
        e.hpBg.PointD = Vector2.new(bx, bb.botY)
        local fgTop = bb.botY - (bb.botY - bb.topY) * hp
        e.hpFg.PointA = Vector2.new(bx, fgTop)
        e.hpFg.PointB = Vector2.new(bx + 3, fgTop)
        e.hpFg.PointC = Vector2.new(bx + 3, bb.botY)
        e.hpFg.PointD = Vector2.new(bx, bb.botY)
        e.hpFg.Color = hp > 0.5 and Color3.fromRGB(90, 220, 140)
            or (hp > 0.25 and Color3.fromRGB(240, 200, 70) or Color3.fromRGB(255, 70, 70))
        e.hpBg.Visible = true
        e.hpFg.Visible = true
    else
        e.hpBg.Visible = false
        e.hpFg.Visible = false
    end

    if S.espTracer then
        local vp = cam.ViewportSize
        e.tracer.From = Vector2.new(vp.X * 0.5, vp.Y)
        e.tracer.To = Vector2.new(bb.cx, bb.botY)
        e.tracer.Color = col
        e.tracer.Visible = true
    else
        e.tracer.Visible = false
    end

    if S.espHead then
        local hp, on = cam:WorldToViewportPoint(bb.head.Position)
        if on then
            e.head.Position = Vector2.new(hp.X, hp.Y)
            e.head.Color = col
            e.head.Visible = true
        else
            e.head.Visible = false
        end
    else
        e.head.Visible = false
    end

    for i, bone in ipairs(BONES) do
        if S.espSkel then
            local p1 = t.char:FindFirstChild(bone[1])
            local p2 = t.char:FindFirstChild(bone[2])
            if p1 and p2 then
                local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                if on1 and on2 then
                    local a = Vector2.new(s1.X, s1.Y)
                    local b = Vector2.new(s2.X, s2.Y)
                    e.skelOut[i].From, e.skelOut[i].To = a, b
                    e.skel[i].From, e.skel[i].To = a, b
                    e.skel[i].Color = col
                    e.skelOut[i].Visible = true
                    e.skel[i].Visible = true
                else
                    e.skelOut[i].Visible = false
                    e.skel[i].Visible = false
                end
            else
                e.skelOut[i].Visible = false
                e.skel[i].Visible = false
            end
        else
            e.skelOut[i].Visible = false
            e.skel[i].Visible = false
        end
    end
end

local function updateObjectives(cam)
    local zones = workspace:FindFirstChild("StrikeZones")
    if not (S.esp and S.espObj and zones) then
        for k, d in pairs(objCache) do
            killObj(d)
            objCache[k] = nil
        end
        return
    end

    local seen = {}
    for _, zone in ipairs(zones:GetChildren()) do
        local beacon = zone:FindFirstChild("Beacon")
        if beacon then
            seen[beacon] = true
            local d = objCache[beacon]
            if not d then
                d = mk("Text", { Size = 12, Center = true, Outline = true, Color = Color3.fromRGB(120, 200, 255) })
                objCache[beacon] = d
            end
            if d then
                local sp, on = cam:WorldToViewportPoint(beacon.Position + Vector3.new(0, 3, 0))
                if on then
                    d.Position = Vector2.new(sp.X, sp.Y)
                    d.Text = string.format("BEACON  %dm", math.floor((beacon.Position - cam.CFrame.Position).Magnitude))
                    d.Visible = true
                else
                    d.Visible = false
                end
            end
        end
    end

    for k, d in pairs(objCache) do
        if not seen[k] then
            killObj(d)
            objCache[k] = nil
        end
    end
end

-- ================================================================
-- FRAME LOOP
-- ================================================================
local fovCircle = nil
local aimKeyDown = false
local lastTrigger = 0
local triggerHeld = false

local function fovPixels(deg, cam)
    local half = cam.ViewportSize.Y * 0.5
    return math.tan(math.rad(deg) * 0.5) / math.tan(math.rad(cam.FieldOfView) * 0.5) * half
end

local function onFrame(dt)
    if stale() then return end
    local cam = workspace.CurrentCamera
    if not cam then return end

    local list = collectTargets()

    if S.aim and (S.aimKey == nil or aimKeyDown) then
        local pick = pickTarget(list, S.aimFov)
        if pick then
            local goal = CFrame.lookAt(cam.CFrame.Position, pick.pos)
            cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(S.aimSmooth * dt, 0, 1))
        end
    end

    if S.trigger then
        local now = os.clock()
        local tool = equippedWeapon()
        local ammo = tool and tool:GetAttribute("Ammo")
        local armed = tool ~= nil and not (type(ammo) == "number" and ammo <= 0)
            and now - lastTrigger >= S.triggerDelay / 1000
        local pick = armed and pickTarget(list, S.triggerFov) or nil
        -- Activate once and let the weapon's own fire loop do the shooting:
        -- press() resets the bolt timer, so re-activating every frame never fires.
        if pick and not triggerHeld then
            triggerHeld = true
            pcall(function() tool:Activate() end)
        elseif not pick and triggerHeld then
            triggerHeld = false
            lastTrigger = now
            pcall(function() tool:Deactivate() end)
        end
    elseif triggerHeld then
        triggerHeld = false
        pcall(function()
            local tool = equippedWeapon()
            if tool then tool:Deactivate() end
        end)
    end

    if S.esp then
        local seen = {}
        for _, t in ipairs(list) do
            seen[t.char] = true
            updateEsp(t, cam)
        end
        for char, e in pairs(espCache) do
            if not seen[char] then
                destroyEntry(e)
                espCache[char] = nil
            end
        end
    elseif next(espCache) then
        for char, e in pairs(espCache) do
            destroyEntry(e)
            espCache[char] = nil
        end
    end

    updateObjectives(cam)

    if fovCircle then
        local deg = nil
        if S.aim then
            deg = S.aimFov
        elseif S.silent then
            deg = S.silentFov
        elseif S.trigger then
            deg = S.triggerFov
        end
        if deg then
            fovCircle.Position = cam.ViewportSize * 0.5
            fovCircle.Radius = math.max(fovPixels(deg, cam), 2)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end
end

RunService:BindToRenderStep("VoxelWarsFrame", Enum.RenderPriority.Camera.Value + 2, onFrame)

-- ================================================================
-- MISC
-- ================================================================
local movement = nil
do
    local ok, m = pcall(require, RS:FindFirstChild("Voxel") and RS.Voxel:FindFirstChild("Movement") or nil)
    if ok and type(m) == "table" then movement = m end
end

local function setAutoSprint(on)
    if movement then movement.autoSprint = on and true or false end
end

-- ================================================================
-- UI
-- ================================================================
local function createHubUI(firstPass)
    if stale() then return end
    if firstPass then
        pcall(cleardrawcache)
    else
        cleanupGui("ExlumiaaHub")
    end
    if fovCircle then killObj(fovCircle); fovCircle = nil end

    local Library = nil
task.spawn(function()
    local ok, ret = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil or stale() then break end
    task.wait(0.25)
end
if not Library or stale() then return end

Library.ConfigFolder = "exlumiaa/voxel-wars"

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Voxel Wars",
    Size = UDim2.fromOffset(500, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Voxel Wars",
    LoadingFooter = "ESP / Aim",
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

-- Clearing here also removes anything the previous run left on screen.
pcall(cleardrawcache)
fovCircle = mk("Circle", { Thickness = 1, Filled = false, Transparency = 0.6, Visible = false })

local CombatTab = Window:AddTab({ Name = "Combat", Icon = "crosshair", Subtitle = "Aim" })
local Combat = CombatTab:AddSubTab("Aim")

Combat:AddSection("Aimbot")
Combat:AddToggle({
    Name = "Aimbot",
    Flag = "vw_aim",
    Default = false,
    Callback = function(v) S.aim = v and true or false end,
})
Combat:AddKeybind({
    Name = "Aim Key (hold)",
    Flag = "vw_aimkey",
    Default = nil,
    Callback = function(key) S.aimKey = key end,
})
Combat:AddSlider({
    Name = "Aimbot FOV",
    Min = 2,
    Max = 90,
    Default = 20,
    Suffix = " deg",
    Flag = "vw_aimfov",
    Callback = function(v) S.aimFov = v end,
})
Combat:AddSlider({
    Name = "Smoothness",
    Min = 1,
    Max = 25,
    Default = 6,
    Flag = "vw_aimsmooth",
    Callback = function(v) S.aimSmooth = v end,
})
Combat:AddDropdown({
    Name = "Target Bone",
    Options = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = "Head",
    Flag = "vw_aimpart",
    Callback = function(v) S.aimPart = v end,
})
Combat:AddToggle({
    Name = "Prediction",
    Flag = "vw_aimpred",
    Default = true,
    Callback = function(v) S.aimPred = v and true or false end,
})
Combat:AddSlider({
    Name = "Projectile Speed",
    Min = 800,
    Max = 2600,
    Default = 1700,
    Suffix = " studs/s",
    Flag = "vw_aimspeed",
    Callback = function(v) S.aimSpeed = v end,
})
Combat:AddToggle({
    Name = "Wall Check",
    Flag = "vw_aimwall",
    Default = true,
    Callback = function(v) S.aimWall = v and true or false end,
})

Combat:AddSection("Silent Aim")
Combat:AddToggle({
    Name = "Silent Aim",
    Flag = "vw_silent",
    Default = false,
    Callback = function(v)
        S.silent = v and true or false
    end,
})
Combat:AddSlider({
    Name = "Silent FOV",
    Min = 2,
    Max = 180,
    Default = 25,
    Suffix = " deg",
    Flag = "vw_silentfov",
    Callback = function(v) S.silentFov = tonumber(v) or 25 end,
})

Combat:AddSection("Trigger Bot")
Combat:AddToggle({
    Name = "Trigger Bot",
    Flag = "vw_trigger",
    Default = false,
    Callback = function(v) S.trigger = v and true or false end,
})
Combat:AddSlider({
    Name = "Trigger FOV",
    Min = 1,
    Max = 30,
    Default = 5,
    Suffix = " deg",
    Flag = "vw_triggerfov",
    Callback = function(v) S.triggerFov = v end,
})
Combat:AddSlider({
    Name = "Trigger Delay",
    Min = 60,
    Max = 400,
    Default = 120,
    Suffix = " ms",
    Flag = "vw_triggerdelay",
    Callback = function(v) S.triggerDelay = v end,
})

local Weapon = CombatTab:AddSubTab("Weapon")
Weapon:AddSection("Recoil")
Weapon:AddToggle({
    Name = "No Recoil",
    Flag = "vw_norecoil",
    Default = false,
    Callback = function(v)
        S.noRecoil = v and true or false
        applyNoRecoil(S.noRecoil)
    end,
})

local VisualsTab = Window:AddTab({ Name = "Visuals", Icon = "target", Subtitle = "ESP" })
local Visuals = VisualsTab:AddSubTab("ESP")

Visuals:AddSection("Players & Bots")
Visuals:AddToggle({
    Name = "ESP",
    Flag = "vw_esp",
    Default = false,
    Callback = function(v) S.esp = v and true or false end,
})
Visuals:AddToggle({
    Name = "Box",
    Flag = "vw_espbox",
    Default = true,
    Callback = function(v) S.espBox = v and true or false end,
})
Visuals:AddToggle({
    Name = "Fill",
    Flag = "vw_espfill",
    Default = false,
    Callback = function(v) S.espFill = v and true or false end,
})
Visuals:AddToggle({
    Name = "Name",
    Flag = "vw_espname",
    Default = true,
    Callback = function(v) S.espName = v and true or false end,
})
Visuals:AddToggle({
    Name = "Distance",
    Flag = "vw_espdist",
    Default = true,
    Callback = function(v) S.espDist = v and true or false end,
})
Visuals:AddToggle({
    Name = "Health Bar",
    Flag = "vw_esphealth",
    Default = true,
    Callback = function(v) S.espHealth = v and true or false end,
})
Visuals:AddToggle({
    Name = "Tracer",
    Flag = "vw_esptracer",
    Default = false,
    Callback = function(v) S.espTracer = v and true or false end,
})
Visuals:AddToggle({
    Name = "Skeleton",
    Flag = "vw_espskel",
    Default = false,
    Callback = function(v) S.espSkel = v and true or false end,
})
Visuals:AddToggle({
    Name = "Head Dot",
    Flag = "vw_esphead",
    Default = false,
    Callback = function(v) S.espHead = v and true or false end,
})
Visuals:AddToggle({
    Name = "Show Bots",
    Flag = "vw_espbots",
    Default = true,
    Callback = function(v) S.espBots = v and true or false end,
})
Visuals:AddSlider({
    Name = "Max Distance",
    Min = 100,
    Max = 2000,
    Default = 900,
    Suffix = " studs",
    Flag = "vw_espmax",
    Callback = function(v) S.espMax = v end,
})
Visuals:AddToggle({
    Name = "Team Check",
    Flag = "vw_teamcheck",
    Default = true,
    Callback = function(v) S.teamCheck = v and true or false end,
})

Visuals:AddSection("World")
Visuals:AddToggle({
    Name = "Beacons",
    Flag = "vw_espobj",
    Default = false,
    Callback = function(v) S.espObj = v and true or false end,
})

local MiscTab = Window:AddTab({ Name = "Misc", Icon = "settings", Subtitle = "Player" })
local Misc = MiscTab:AddSubTab("Player")

Misc:AddSection("Movement")
Misc:AddToggle({
    Name = "Auto Sprint",
    Flag = "vw_sprint",
    Default = false,
    Callback = function(v)
        S.autoSprint = v and true or false
        setAutoSprint(S.autoSprint)
    end,
})

local notify = function(title, content, ntype)
    pcall(function() Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 }) end)
end

local selectedConfig = ""
local configDropdown = nil
local function refreshConfigList()
    local configs = Library:ListConfigs()
    if configDropdown then
        configDropdown:SetOptions(configs)
    end
end

Misc:AddSection("Config")
local configInput = Misc:AddInput({
    Name = "Config Name",
    Default = "",
    Placeholder = "Enter config name...",
    Flag = "vw_config_name",
})
Misc:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        local n = tostring(name or ""):match("^%s*(.-)%s*$")
        if n == "" then notify("Config", "Enter a name first.", "warning") return end
        local ok = Library:SaveConfig(n)
        if ok then
            refreshConfigList()
            notify("Config", "Saved: " .. n, "success")
        else
            notify("Config", "Save failed.", "error")
        end
    end,
})
configDropdown = Misc:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "vw_config_selected",
    Callback = function(v) selectedConfig = v end,
})
Misc:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if selectedConfig == "" then notify("Config", "Pick a config first.", "warning") return end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            refreshConfigList()
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Load failed.", "error")
        end
    end,
})
Misc:AddButton({
    Name = "Delete Config",
    Primary = false,
    Callback = function()
        if selectedConfig == "" then notify("Config", "Pick a config first.", "warning") return end
        local ok = Library:DeleteConfig(selectedConfig)
        if ok then
            selectedConfig = ""
            refreshConfigList()
            notify("Config", "Deleted.", "success")
        else
            notify("Config", "Delete failed.", "error")
        end
    end,
})

Misc:AddSection("Session")
local status = Misc:AddLabel({ Text = "Ready." })
Misc:AddButton({
    Name = "Session Info",
    Callback = function()
        local n = #collectTargets()
        status:Set(string.format("targets: %d | silent: %s | ballistics hook: %s | aimbot: %s",
            n, tostring(S.silent), tostring(ballisticsHooked), tostring(S.aim)))
    end,
})
Misc:AddButton({
    Name = "Unload Script",
    Primary = true,
    Callback = function()
        getgenv().__voxelWarsGen = (tonumber(getgenv().__voxelWarsGen) or 0) + 1
        disconnectAll()
        pcall(function() RunService:UnbindFromRenderStep("VoxelWarsFrame") end)
        pcall(function() RunService:UnbindFromRenderStep("VoxelWarsWatchdog") end)
        for _, e in pairs(espCache) do destroyEntry(e) end
        espCache = {}
        for _, d in pairs(objCache) do killObj(d) end
        objCache = {}
        killObj(fovCircle)
        fovCircle = nil
        restoreBallisticsHook()
        applyNoRecoil(false)
        setAutoSprint(false)
        pcall(cleardrawcache)
        pcall(function() Library:DestroyAll() end)
        cleanupGui("ExlumiaaHub")
        print("[ExlumiaaHub] Voxel Wars unloaded")
    end,
})

end

createHubUI(true)

-- This game wipes the client's CoreGui/PlayerGui on round and lobby transitions,
-- which destroys the hub window. Rebuild it automatically when it's gone.
local watchdogBusy = false
RunService:UnbindFromRenderStep("VoxelWarsWatchdog")
RunService:BindToRenderStep("VoxelWarsWatchdog", Enum.RenderPriority.First.Value, function()
    if stale() or watchdogBusy then return end
    local rg = game:GetService("CoreGui").RobloxGui
    local alive = rg and rg:FindFirstChild("ExlumiaaHub") ~= nil
    if not alive then
        local pg = LP:FindFirstChild("PlayerGui")
        if pg and pg:FindFirstChild("ExlumiaaHub") then alive = true end
    end
    if alive then return end
    watchdogBusy = true
    createHubUI(false)
    watchdogBusy = false
end)

-- ================================================================
-- KEY HOLD + LOAD
-- ================================================================
track(UIS.InputBegan:Connect(function(input, gp)
    if gp or not S.aimKey then return end
    if input.KeyCode == S.aimKey then aimKeyDown = true end
end))
track(UIS.InputEnded:Connect(function(input)
    if not S.aimKey then return end
    if input.KeyCode == S.aimKey then aimKeyDown = false end
end))

getgenv()._voxelWars = {
    S = S,
    applyNoRecoil = applyNoRecoil,
    setAutoSprint = setAutoSprint,
    collectTargets = collectTargets,
    pickTarget = pickTarget,
    equippedWeapon = equippedWeapon,
    fireRemotes = fireRemotes,
    recoilModule = function() return recoilModule end,
    ballisticsInstall = installBallisticsHook,
    ballisticsRestore = restoreBallisticsHook,
    ballisticsHooked = function() return ballisticsHooked end,
}

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

print("[ExlumiaaHub] Voxel Wars loaded | remotes=" .. tostring(remotesFolder ~= nil)
    .. " fire=" .. tostring(next(fireRemotes) ~= nil)
    .. " recoil=" .. tostring(recoilModule ~= nil)
    .. " movement=" .. tostring(movement ~= nil))
