-- Net a Fish â€” Exlumiaa Hub
-- game.GameId 10771053183 (place 93898234979111)
-- Key system: Panda Auth (exlumiaa). No ESP.

if tostring(game.GameId) ~= "10771053183" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _nafHubTomb1"
local _G_GEN = "_ _nafHubGen"
local _G_COUNTER = "_ _nafHubCounter"

rawset(_G, _G_TOMB, true)

local MY_GEN = (tonumber(rawget(_G, _G_COUNTER)) or 0) + 1
rawset(_G, _G_COUNTER, MY_GEN)
rawset(_G, _G_GEN, MY_GEN)

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "NetAFishKeyGate") then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "NetAFishKeyGate") then gui:Destroy() end
        end
    end)
end

local function isStale()
    return tonumber(rawget(_G, _G_GEN)) ~= MY_GEN
end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_naf.txt"
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
            brand = "Net a Fish",
            guiName = "NetAFishKeyGate",
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
                if isStale() then
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

Library.ConfigFolder = "exlumiaa/netafish"

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then return end

local ThrowNet = Remotes:WaitForChild("ThrowNet", 30)
local ReelIn = Remotes:WaitForChild("ReelIn", 30)
local ResolveCatch = Remotes:WaitForChild("ResolveCatch", 30)
local CatchReady = Remotes:WaitForChild("CatchReady", 30)
local BuyItem = Remotes:WaitForChild("BuyItem", 30)
local RebirthRequest = Remotes:WaitForChild("RebirthRequest", 30)
local BestSetup = Remotes:WaitForChild("BestSetup", 30)
local CollectPadReq = Remotes:WaitForChild("CollectPadReq", 30)
local GetData = Remotes:WaitForChild("GetData", 30)
local GoHome = Remotes:WaitForChild("GoHome", 30)
local Rewards = Remotes:WaitForChild("Rewards", 30)
local Contracts = Remotes:WaitForChild("Contracts", 30)
local Challenge = Remotes:WaitForChild("Challenge", 30)
local Potions = Remotes:WaitForChild("Potions", 30)

local okFS, FishingShared = pcall(function()
    return require(ReplicatedStorage:WaitForChild("FishingShared", 30))
end)
if not okFS or type(FishingShared) ~= "table" then return end

local Map = workspace:WaitForChild("Map", 30)
local Bases = Map and Map:WaitForChild("Bases", 30)
if not Bases then return end

local State = {
    autoThrow = false,
    returnDock = true,
    autoReel = false,
    waitFull = true,
    reelAfter = 25,
    autoCatch = false,
    keepNew = true,
    keepMut = true,
    keepPerfect = true,
    keepRarity = 3,
    keepValue = 0,
    autoUpgrade = false,
    autoNet = false,
    autoRebirth = false,
    autoBest = false,
    autoCollect = false,
    autoPotion = false,
    autoContracts = false,
    autoChallenges = false,
    autoRewards = false,
    antiAfk = false,
    throwInterval = 0.7,
    reelInterval = 0.8,
    catchDelay = 0.35,
    upgradeInterval = 3,
    collectInterval = 6,
    claimInterval = 15,
    bestInterval = 30,
    rebirthInterval = 6,
    reservePct = 0,
    debug = false,
}

local Window = nil

local function notify(title, content, typ)
    if not Window then return end
    pcall(function()
        Window:Notify({Title = title, Content = content, Type = typ or "info", Duration = 4})
    end)
end

local function dbg(...)
    if State.debug then
        print("[NAF]", ...)
    end
end

local tokens = {}
local lastMsg = {}

local function setLoop(key, enabled, fn, getInterval)
    State[key] = enabled
    tokens[key] = (tokens[key] or 0) + 1
    local myToken = tokens[key]
    if not enabled then
        lastMsg[key] = nil
        return
    end
    task.spawn(function()
        task.wait(0.15)
        while State[key] and tokens[key] == myToken and not isStale() do
            local pok, ok, msg = pcall(fn)
            if not pok then
                ok, msg = false, tostring(ok)
            end
            if ok then
                lastMsg[key] = nil
            elseif msg and msg ~= lastMsg[key] then
                lastMsg[key] = msg
                notify("Net a Fish", msg, "warning")
            end
            local iv = tonumber(getInterval()) or 5
            task.wait(iv > 0 and iv or 1)
        end
    end)
end

local function getChar()
    local c = LP.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if h and r and h.Health > 0 then return c, h, r end
    return nil
end

local function myBase()
    for _, b in ipairs(Bases:GetChildren()) do
        if b:GetAttribute("OwnerUserId") == LP.UserId then return b end
    end
end

local function onDock(b)
    local _, _, r = getChar()
    if not (b and r) then return false end
    if not b:FindFirstChild("Dock") and not b:FindFirstChild("Floor") then return true end
    local ok, res = pcall(function()
        return FishingShared.OnOwnDock(b, r.Position)
    end)
    return ok and res == true
end

local function goDock(b)
    local _, _, r = getChar()
    if not r then return false end
    local part = b:FindFirstChild("Dock") or b:FindFirstChild("Floor")
    if not part then return false end
    local cf = nil
    if part:IsA("BasePart") then
        cf = part.CFrame
    elseif part:IsA("Model") then
        cf = part:GetPivot()
    end
    if not cf then return false end
    r.CFrame = cf * CFrame.new(0, 4, 0)
    return true
end

local saveCache, saveAt = nil, 0

local function getSave(force)
    if not force and saveCache and os.clock() - saveAt < 8 then return saveCache end
    local ok, data = pcall(function() return GetData:InvokeServer() end)
    if ok and type(data) == "table" then
        saveCache = data
        saveAt = os.clock()
        return data
    end
    return saveCache
end

local function leaderstat(name)
    local ls = LP:FindFirstChild("leaderstats")
    local v = ls and ls:FindFirstChild(name)
    return v and v.Value
end

-- ==================== FARM ====================

local function doThrow()
    local b = myBase()
    if not b then return false, "No base found" end
    if b:GetAttribute("NetState") ~= "Idle" then return true end
    local _, _, r = getChar()
    if not r then return false, "Character not ready" end
    if not onDock(b) then
        if not State.returnDock then return false, "Not on your dock" end
        if not goDock(b) then return false, "Could not reach your dock" end
        task.wait(0.35)
        if not onDock(b) then return false, "Not on your dock" end
    end
    ThrowNet:FireServer()
    dbg("throw")
    return true
end

local function doReel()
    local b = myBase()
    if not b then return false, "No base found" end
    local st = b:GetAttribute("NetState")
    if st ~= "Out" and st ~= "Fishing" then return true end
    local count = tonumber(b:GetAttribute("NetCount")) or 0
    local cap = tonumber(b:GetAttribute("NetCap")) or 1
    local full = count >= cap
    if State.waitFull and not full then return true end
    if not full then
        local t0 = tonumber(b:GetAttribute("NetT0"))
        if t0 and (workspace:GetServerTimeNow() - t0) < State.reelAfter then return true end
    end
    ReelIn:FireServer()
    dbg("reel", count, cap)
    return true
end

local function hideCatch()
    local pg = LP:FindFirstChild("PlayerGui")
    local gui = pg and pg:FindFirstChild("CatchUI")
    if not gui then return end
    local panel = gui:FindFirstChild("CatchPanel")
    if panel then panel.Visible = false end
    local backdrop = gui:FindFirstChild("Backdrop")
    if backdrop then backdrop.Visible = false end
end

CatchReady.OnClientEvent:Connect(function(list)
    if not State.autoCatch or type(list) ~= "table" then return end
    task.delay(State.catchDelay, function()
        if not State.autoCatch or isStale() then return end
        local decisions = {}
        for _, f in ipairs(list) do
            local d = "sell"
            if (State.keepNew and f.new) or (State.keepMut and f.mu) or (State.keepPerfect and f.perfect) then
                d = "keep"
            elseif (tonumber(f.r) or 0) >= State.keepRarity then
                d = "keep"
            elseif State.keepValue > 0 and (tonumber(f.v) or 0) >= State.keepValue then
                d = "keep"
            end
            if f.uid ~= nil then
                decisions[tostring(f.uid)] = d
            end
        end
        local ok = pcall(function() ResolveCatch:FireServer(decisions) end)
        if ok then
            task.wait(0.15)
            hideCatch()
            dbg("catch resolved", #list)
        else
            notify("Auto Catch", "ResolveCatch failed", "error")
        end
    end)
end)

local function doUpgrade()
    local save = getSave()
    if not save then return false, "Profile not ready" end
    local cash = tonumber(save.Cash) or 0
    local budget = cash - cash * (State.reservePct / 100)
    local pick, pickCost = nil, nil
    for _, u in ipairs(FishingShared.Upgrades) do
        if not u.Hidden then
            local lvl = tonumber(save.Upgrades and save.Upgrades[u.Id]) or 0
            local max = tonumber(u.Max) or 0
            if lvl < max then
                local ok = FishingShared.UpgradeLevelOk(save, u, lvl + 1)
                if ok then
                    local cost = tonumber(FishingShared.UpgradeCost(u.Id, lvl)) or math.huge
                    if cost <= budget and (not pickCost or cost < pickCost) then
                        pick, pickCost = u, cost
                    end
                end
            end
        end
    end
    if pick then
        BuyItem:FireServer("Upgrade", pick.Id)
        dbg("upgrade", pick.Id, pickCost)
    end
    return true
end

local function doNet()
    local save = getSave()
    if not save then return false, "Profile not ready" end
    local tier = tonumber(save.NetTier) or 1
    local nextId = tier + 1
    local net = FishingShared.Nets[nextId]
    if not net then return true end
    if not FishingShared.NetRebirthOk(save, nextId) then return true end
    local cash = tonumber(save.Cash) or 0
    local cost = tonumber(net.Cost) or math.huge
    if cash - cash * (State.reservePct / 100) >= cost then
        BuyItem:FireServer("Net", nextId)
        dbg("net", nextId, cost)
    end
    return true
end

local lastRebirth = 0

local function doRebirth()
    if os.clock() - lastRebirth < 6 then return true end
    local save = getSave()
    if not save then return false, "Profile not ready" end
    if (tonumber(save.Rebirths) or 0) >= (FishingShared.MaxRebirth or 50) then return true end
    if FishingShared.CanRebirth(save) then
        lastRebirth = os.clock()
        RebirthRequest:FireServer()
        dbg("rebirth")
    end
    return true
end

local function doBest()
    BestSetup:FireServer()
    dbg("best setup")
    return true
end

local function doCollect()
    local b = myBase()
    if not b then return false, "No base found" end
    local peds = b:FindFirstChild("Pedestals")
    if not peds then return true end
    local _, _, r = getChar()
    if not r then return false, "Character not ready" end
    local origin = r.CFrame
    local moved = false
    for _, ped in ipairs(peds:GetChildren()) do
        local collect = ped:FindFirstChild("Collect")
        local pad = collect and collect:FindFirstChild("Pad")
        local slot = ped:GetAttribute("Slot")
        if pad and pad:IsA("BasePart") and slot ~= nil then
            local anchor = collect:FindFirstChild("LabelAnchor")
            local info = anchor and anchor:FindFirstChild("CollectInfo")
            local amount = info and info:FindFirstChild("Amount")
            local text = amount and amount.Text
            if text and text ~= "" and text ~= "$0" then
                r.CFrame = pad.CFrame + Vector3.new(0, 3, 0)
                moved = true
                task.wait(0.12)
                pcall(function() CollectPadReq:FireServer(slot) end)
                task.wait(0.08)
            end
        end
    end
    if moved then r.CFrame = origin end
    return true
end

local function setAutoPotion(on)
    pcall(function() Potions:InvokeServer("auto", on) end)
end

local afkConn = nil

local function setAntiAfk(on)
    State.antiAfk = on
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
    if on then
        afkConn = LP.Idled:Connect(function()
            if not State.antiAfk or isStale() then return end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end
end

-- ==================== PROGRESS ====================

local function doContracts()
    local ok, st = pcall(function() return Contracts:InvokeServer("state") end)
    if not ok or type(st) ~= "table" or type(st.list) ~= "table" then
        return false, "Contracts unavailable"
    end
    for i, c in ipairs(st.list) do
        if c.k ~= "wait" and (tonumber(c.p) or 0) >= (tonumber(c.goal) or math.huge) then
            pcall(function() Contracts:InvokeServer("claim", i) end)
            task.wait(0.25)
        end
    end
    return true
end

local function doChallenges()
    local ok, st = pcall(function() return Challenge:InvokeServer("state") end)
    if not ok or type(st) ~= "table" or type(st.tiers) ~= "table" then
        return false, "Challenges unavailable"
    end
    for i, t in ipairs(st.tiers) do
        if t.done and not t.claimed then
            pcall(function() Challenge:InvokeServer("claim", i) end)
            task.wait(0.25)
        end
    end
    return true
end

local function doIndexRewards()
    local save = getSave()
    if not save then return false, "Profile not ready" end
    local done = FishingShared.IndexPagesDone(save)
    local claimed = FishingShared.IndexPagesClaimed(save)
    local claimedSet = {}
    for _, page in ipairs(claimed) do claimedSet[page] = true end
    for _, page in ipairs(done) do
        if not claimedSet[page] then
            pcall(function() Rewards:InvokeServer("claimPage", page) end)
            task.wait(0.25)
        end
    end
    return true
end

-- ==================== WORLD ====================

local function teleportToBase(name)
    local b = Bases:FindFirstChild(name)
    if not b then return false, "Base not found" end
    local _, _, r = getChar()
    if not r then return false, "Character not ready" end
    local part = b:FindFirstChild("Dock") or b:FindFirstChild("Floor")
    local cf = nil
    if part and part:IsA("BasePart") then
        cf = part.CFrame
    elseif part and part:IsA("Model") then
        cf = part:GetPivot()
    else
        local okPivot, pivot = pcall(function() return b:GetPivot() end)
        cf = okPivot and pivot or nil
    end
    if not cf then return false, "No safe spot" end
    r.CFrame = cf * CFrame.new(0, 6, 0)
    return true
end

-- ==================== UI ====================

Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Net a Fish: Enhanced",
    Size = UDim2.fromOffset(520, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Net a Fish: Enhanced",
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

local HomeTab = Window:AddTab({Name = "Home", Icon = "home", Subtitle = "Info"})
local HomeSub = HomeTab:AddSubTab("Info")

HomeSub:AddSection("Player")
local labelPlayers = HomeSub:AddLabel({Text = "Players: --"})
local labelCash = HomeSub:AddLabel({Text = "Cash: --"})
local labelIncome = HomeSub:AddLabel({Text = "$/sec: --"})
local labelRebirths = HomeSub:AddLabel({Text = "Rebirths: --"})
local labelPearls = HomeSub:AddLabel({Text = "Pearls: --"})

HomeSub:AddSection("Net")
local labelNetState = HomeSub:AddLabel({Text = "State: --"})
local labelNetCount = HomeSub:AddLabel({Text = "Net: -- / --"})
local labelNetTier = HomeSub:AddLabel({Text = "Net tier: --"})
local labelDock = HomeSub:AddLabel({Text = "On dock: --"})

HomeSub:AddSection("Game")
HomeSub:AddLabel({Text = "GameId: " .. tostring(game.GameId)})
HomeSub:AddLabel({Text = "PlaceId: " .. tostring(game.PlaceId)})
HomeSub:AddLabel({Text = "Toggle menu: RightControl"})

local FarmTab = Window:AddTab({Name = "Farm", Icon = "hammer", Subtitle = "Auto"})
local FarmSub = FarmTab:AddSubTab("Fishing")

FarmSub:AddSection("Auto Fishing")
FarmSub:AddToggle({
    Name = "Auto Throw",
    Flag = "naf_autothrow",
    Default = false,
    Callback = function(v) setLoop("autoThrow", v, doThrow, function() return State.throwInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto Reel",
    Flag = "naf_autoreel",
    Default = false,
    Callback = function(v) setLoop("autoReel", v, doReel, function() return State.reelInterval end) end,
})
FarmSub:AddToggle({
    Name = "Wait Until Net Full",
    Flag = "naf_waitfull",
    Default = true,
    Callback = function(v) State.waitFull = v end,
})
FarmSub:AddToggle({
    Name = "Return to Dock",
    Flag = "naf_returndock",
    Default = true,
    Callback = function(v) State.returnDock = v end,
})
FarmSub:AddSlider({
    Name = "Throw Interval",
    Min = 0.3,
    Max = 3,
    Default = 0.7,
    Suffix = " s",
    Flag = "naf_throw_interval",
    Callback = function(v) State.throwInterval = v end,
})
FarmSub:AddSlider({
    Name = "Reel After",
    Min = 5,
    Max = 180,
    Default = 25,
    Suffix = " s",
    Flag = "naf_reel_after",
    Callback = function(v) State.reelAfter = v end,
})

FarmSub:AddSection("Auto Catch")
FarmSub:AddToggle({
    Name = "Auto Catch",
    Flag = "naf_autocatch",
    Default = false,
    Callback = function(v)
        State.autoCatch = v
        if v then
            notify("Auto Catch", "Decisions will be sent automatically.", "info")
        end
    end,
})
FarmSub:AddToggle({
    Name = "Keep New Species",
    Flag = "naf_keep_new",
    Default = true,
    Callback = function(v) State.keepNew = v end,
})
FarmSub:AddToggle({
    Name = "Keep Mutated",
    Flag = "naf_keep_mut",
    Default = true,
    Callback = function(v) State.keepMut = v end,
})
FarmSub:AddToggle({
    Name = "Keep Perfect",
    Flag = "naf_keep_perfect",
    Default = true,
    Callback = function(v) State.keepPerfect = v end,
})
FarmSub:AddSlider({
    Name = "Keep Rarity >=",
    Min = 1,
    Max = 20,
    Default = 3,
    Flag = "naf_keep_rarity",
    Callback = function(v) State.keepRarity = v end,
})
FarmSub:AddSlider({
    Name = "Keep Value >=",
    Min = 0,
    Max = 1000000,
    Default = 0,
    Suffix = " $",
    Flag = "naf_keep_value",
    Callback = function(v) State.keepValue = v end,
})

FarmSub:AddSection("Auto Upgrade")
FarmSub:AddToggle({
    Name = "Auto Upgrade",
    Flag = "naf_autoupgrade",
    Default = false,
    Callback = function(v) setLoop("autoUpgrade", v, doUpgrade, function() return State.upgradeInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto Net",
    Flag = "naf_autonet",
    Default = false,
    Callback = function(v) setLoop("autoNet", v, doNet, function() return State.upgradeInterval end) end,
})
FarmSub:AddSlider({
    Name = "Cash Reserve",
    Min = 0,
    Max = 90,
    Default = 0,
    Suffix = " %",
    Flag = "naf_reserve",
    Callback = function(v) State.reservePct = v end,
})
FarmSub:AddSlider({
    Name = "Upgrade Interval",
    Min = 1,
    Max = 30,
    Default = 3,
    Suffix = " s",
    Flag = "naf_upgrade_interval",
    Callback = function(v) State.upgradeInterval = v end,
})

FarmSub:AddSection("Auto Progress")
FarmSub:AddToggle({
    Name = "Auto Rebirth",
    Flag = "naf_autorebirth",
    Default = false,
    Callback = function(v) setLoop("autoRebirth", v, doRebirth, function() return State.rebirthInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto Equip Best",
    Flag = "naf_autobest",
    Default = false,
    Callback = function(v) setLoop("autoBest", v, doBest, function() return State.bestInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto Collect Pads",
    Flag = "naf_autocollect",
    Default = false,
    Callback = function(v) setLoop("autoCollect", v, doCollect, function() return State.collectInterval end) end,
})
FarmSub:AddToggle({
    Name = "Auto-Buy Potions",
    Flag = "naf_autopotion",
    Default = false,
    Callback = function(v)
        State.autoPotion = v
        setAutoPotion(v)
    end,
})
FarmSub:AddToggle({
    Name = "Anti AFK",
    Flag = "naf_antiafk",
    Default = false,
    Callback = function(v) setAntiAfk(v) end,
})

local ProgressTab = Window:AddTab({Name = "Progress", Icon = "list", Subtitle = "Claims"})
local ProgressSub = ProgressTab:AddSubTab("Claims")

ProgressSub:AddSection("Quests")
ProgressSub:AddToggle({
    Name = "Auto Contracts",
    Flag = "naf_contracts",
    Default = false,
    Callback = function(v) setLoop("autoContracts", v, doContracts, function() return State.claimInterval end) end,
})
ProgressSub:AddToggle({
    Name = "Auto Today's Challenge",
    Flag = "naf_challenges",
    Default = false,
    Callback = function(v) setLoop("autoChallenges", v, doChallenges, function() return State.claimInterval end) end,
})
ProgressSub:AddToggle({
    Name = "Auto Index Rewards",
    Flag = "naf_rewards",
    Default = false,
    Callback = function(v) setLoop("autoRewards", v, doIndexRewards, function() return State.claimInterval end) end,
})
ProgressSub:AddSlider({
    Name = "Claim Interval",
    Min = 5,
    Max = 120,
    Default = 15,
    Suffix = " s",
    Flag = "naf_claim_interval",
    Callback = function(v) State.claimInterval = v end,
})

ProgressSub:AddSection("Now")
ProgressSub:AddButton({
    Name = "Claim Contracts Now",
    Callback = function()
        local ok, err = doContracts()
        notify("Contracts", ok and "Checked." or tostring(err), ok and "success" or "warning")
    end,
})
ProgressSub:AddButton({
    Name = "Claim Today's Challenge Now",
    Callback = function()
        local ok, err = doChallenges()
        notify("Today's Challenge", ok and "Checked." or tostring(err), ok and "success" or "warning")
    end,
})
ProgressSub:AddButton({
    Name = "Claim Index Rewards Now",
    Callback = function()
        local ok, err = doIndexRewards()
        notify("Index Rewards", ok and "Checked." or tostring(err), ok and "success" or "warning")
    end,
})

local WorldTab = Window:AddTab({Name = "World", Icon = "map", Subtitle = "Travel"})
local WorldSub = WorldTab:AddSubTab("Teleport")

WorldSub:AddSection("Your Base")
WorldSub:AddButton({
    Name = "Teleport to Dock",
    Primary = true,
    Callback = function()
        local b = myBase()
        if b and goDock(b) then
            notify("Teleport", "Back on your dock.", "success")
        else
            notify("Teleport", "Could not find your dock.", "error")
        end
    end,
})
WorldSub:AddButton({
    Name = "Go Home",
    Callback = function()
        pcall(function() GoHome:FireServer() end)
        notify("Teleport", "GoHome sent.", "info")
    end,
})

WorldSub:AddSection("Bases")
local baseNames = {}
for _, b in ipairs(Bases:GetChildren()) do
    table.insert(baseNames, b.Name)
end
table.sort(baseNames)
local selectedBase = baseNames[1] or ""
WorldSub:AddDropdown({
    Name = "Base",
    Options = baseNames,
    Default = selectedBase,
    Flag = "naf_base_target",
    Callback = function(v) selectedBase = v end,
})
WorldSub:AddButton({
    Name = "Teleport to Base",
    Callback = function()
        local ok, err = teleportToBase(selectedBase)
        notify("Teleport", ok and ("Moved to " .. selectedBase) or tostring(err), ok and "success" or "error")
    end,
})

WorldSub:AddSection("Server")
WorldSub:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        notify("Rejoin", "Rejoining...", "info")
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(game.JobId), LP)
        end)
    end,
})
WorldSub:AddButton({
    Name = "Server Hop",
    Callback = function()
        notify("Server Hop", "Finding a new server...", "info")
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
    end,
})

local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})
local MiscSub = SettingsTab:AddSubTab("Misc")
local ConfigSub = SettingsTab:AddSubTab("Config")

MiscSub:AddSection("Debug")
MiscSub:AddToggle({
    Name = "Debug Log",
    Flag = "naf_debug",
    Default = false,
    Callback = function(v) State.debug = v end,
})
MiscSub:AddLabel({Text = "Toggle menu: RightControl"})

ConfigSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "naf_config_selected",
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
    Flag = "naf_config_name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            notify("Config", "Enter a name first!", "warning")
            return
        end
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
            notify("Config", "Select a config first!", "warning")
            return
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
            notify("Config", "Select a config first!", "warning")
            return
        end
        Library:DeleteConfig(selectedConfig)
        selectedConfig = ""
        refreshConfigList()
        notify("Config", "Deleted.", "info")
    end,
})

-- ==================== HUD ====================

task.spawn(function()
    while not isStale() do
        task.wait(1)
        pcall(function()
            labelPlayers:Set("Players: " .. #Players:GetPlayers())
            labelCash:Set("Cash: " .. tostring(leaderstat("Cash") or 0))
            labelIncome:Set("$/sec: " .. tostring(leaderstat("$/sec") or 0))
            labelRebirths:Set("Rebirths: " .. tostring(leaderstat("Rebirths") or 0))
            labelPearls:Set("Pearls: " .. tostring(LP:GetAttribute("Pearls") or 0))
            local b = myBase()
            if b then
                local count = tonumber(b:GetAttribute("NetCount")) or 0
                local cap = tonumber(b:GetAttribute("NetCap")) or 0
                labelNetState:Set("State: " .. tostring(b:GetAttribute("NetState")))
                labelNetCount:Set(("Net: %d / %d"):format(count, cap))
                labelNetTier:Set("Net tier: " .. tostring(b:GetAttribute("NetTier")))
                labelDock:Set("On dock: " .. (onDock(b) and "yes" or "no"))
            else
                labelNetState:Set("State: no base")
            end
        end)
    end
end)

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

getgenv()._naf = {
    state = State,
    myBase = myBase,
    getSave = getSave,
    throw = doThrow,
    reel = doReel,
    upgrade = doUpgrade,
    net = doNet,
    rebirth = doRebirth,
    collect = doCollect,
    contracts = doContracts,
    challenges = doChallenges,
    indexRewards = doIndexRewards,
    teleportToBase = teleportToBase,
}

print("[ExlumiaaHub] Net a Fish loaded")
