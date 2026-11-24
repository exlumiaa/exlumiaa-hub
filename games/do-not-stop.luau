-- Do Not Stop â€” Exlumiaa Hub
-- Game: 10772946647 (lobby 116779912472448, routes 107530102033104 / Map02-07 / Endless)
-- Key system: Panda Auth (exlumiaa).

local PLACES = {
    [116779912472448] = "Lobby",
    [107530102033104] = "Do Not Stop",
    [73944063866340] = "Map 02",
    [81271298082422] = "Map 03",
    [76065553551463] = "Map 04",
    [111081709255588] = "Map 05",
    [137070863487426] = "Map 06",
    [129862496496546] = "Map 07",
    [98531913151071] = "Endless",
}
if not PLACES[game.PlaceId] and tostring(game.GameId) ~= "10772946647" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local LOBBY = 116779912472448

local GEN = (tonumber(getgenv().__route1610Gen) or 0) + 1
getgenv().__route1610Gen = GEN

local function stale()
    return tonumber(getgenv().__route1610Gen) ~= GEN
end

local function cleanupGui(name)
    pcall(function()
        local cg = game:GetService("CoreGui")
        for _, gui in ipairs(cg:GetChildren()) do
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
cleanupGui("Route1610HUD")
cleanupGui("DNSKeyGate")

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_dns.txt"
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
            brand = "Do Not Stop",
            guiName = "DNSKeyGate",
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
                task.wait(0.1)
            end
            if gui and gui.Parent then
                pcall(function() gui:Destroy() end)
            end
        end
    end
end

local Shared = ReplicatedStorage:FindFirstChild("Shared")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

local function getRun()
    local runs = workspace:FindFirstChild("Runs")
    return runs and runs:FindFirstChild(tostring(LP.UserId))
end

local function getChassis()
    local cars = workspace:FindFirstChild("Cars")
    local car = cars and cars:FindFirstChild("Car_" .. tostring(LP.UserId))
    return car and car:FindFirstChild("Chassis")
end

local S = {
    autoRun = false,
    drive = false,
    autoRetry = true,
    speedCap = 126,
    esp = false,
    hud = true,
    lastStart = 0,
    runs = 0,
    finishes = 0,
    caught = 0,
    creditsStart = nil,
    creditsGain = 0,
    startedAt = os.clock(),
}

local function fireStart(retry)
    local rem = Remotes and Remotes:FindFirstChild("StartRun")
    if not rem then return false end
    local ok = pcall(function() rem:FireServer(retry == true) end)
    if ok then S.lastStart = os.clock() end
    return ok
end

local ctrl = { lastAng = 0, speed = 0, vmax = 0, lat = 0, s = 0, look = 0, lastMove = 0, recoverUntil = 0 }

-- ================================================================
-- ROAD PATH
-- ================================================================
local RoadPath, path, finishS
do
    local ok, err = pcall(function()
        local cfg = Shared and Shared:FindFirstChild("Config")
        local rules = Shared and Shared:FindFirstChild("Rules")
        local World = cfg and cfg:FindFirstChild("World")
        local Road = rules and rules:FindFirstChild("RoadPath")
        local RunCfg = cfg and cfg:FindFirstChild("Run")
        if not (World and Road) then return end
        RoadPath = require(Road)
        local worldOk, world = pcall(require, World)
        if not worldOk or type(world) ~= "table" then return end
        path = RoadPath.build(world)
        if RunCfg then
            local runOk, runData = pcall(require, RunCfg)
            if runOk and type(runData) == "table" then
                finishS = tonumber(runData.FinishS)
            end
        end
    end)
    if not ok then path = nil end
end
finishS = finishS or 8360

local function pointAt(s, lateral)
    if not path then return nil end
    return RoadPath.pointAt(path, s, lateral or 0)
end

-- ================================================================
-- AUTO DRIVE
-- ================================================================
local Input = nil
do
    local client = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("Client")
    local mod = client and client:FindFirstChild("Input")
    if mod then
        local ok, res = pcall(require, mod)
        if ok and type(res) == "table" and type(res.setOverride) == "function" then
            Input = res
        end
    end
end

local CURVE_STEPS = { 40, 80, 140, 200 }

local function driveTick()
    local run = getRun()
    if not run or run:GetAttribute("State") ~= "Driving" then return 0, 0, 0, false end
    local ch = getChassis()
    if not ch or not path then return 0, 1, 0, false end

    local now = os.clock()
    local s = run:GetAttribute("CarS") or 0
    local pos = ch.Position
    local _, lat = RoadPath.project(path, pos.X, pos.Z)
    lat = tonumber(lat) or 0
    local speed = ch.AssemblyLinearVelocity.Magnitude

    if ctrl.recoverUntil > now then
        ctrl.speed = speed
        return 0, 1, -math.sign(lat), false
    end
    if speed < 3 then
        if now - (ctrl.lastMove or now) > 2.5 then
            ctrl.recoverUntil = now + 1.4
            ctrl.lastMove = now
            ctrl.lastAng = 0
        end
    else
        ctrl.lastMove = now
    end

    local _, _, _, f0x, f0z = pointAt(s)
    if not f0x then return 0, 1, 0, false end
    local k = 0
    for _, d in ipairs(CURVE_STEPS) do
        local _, _, _, f1x, f1z = pointAt(s + d)
        local bend = math.acos(math.clamp(f0x * f1x + f0z * f1z, -1, 1))
        if bend / d > k then k = bend / d end
    end

    local vmax = math.clamp(math.sqrt(50 / math.max(k, 0.0004)), 40, S.speedCap)
    if math.abs(lat) > 9 then vmax = math.min(vmax, 80) end

    local look = math.clamp(18 + speed * 0.5, 26, 78)
    local tx, ty, tz = pointAt(s + look)
    local rel = ch.CFrame:PointToObjectSpace(Vector3.new(tx, ty, tz))
    local ang = math.atan2(rel.X, -rel.Z)
    local dAng = ang - ctrl.lastAng
    ctrl.lastAng = ang

    local steer = math.clamp(ang * 2.1 + dAng * 3.5, -1, 1)
    local throttle = speed < vmax and 1 or 0
    local brake = speed > vmax + 12 and 1 or 0

    ctrl.speed, ctrl.vmax, ctrl.lat, ctrl.s, ctrl.look = speed, vmax, lat, s, look
    return throttle, brake, steer, false
end

local function installOverride()
    if not Input then return false end
    Input.setOverride(function()
        if stale() or not S.drive then return 0, 0, 0, false end
        return driveTick()
    end)
    return true
end

local function clearOverride()
    if Input then pcall(function() Input.setOverride(nil) end) end
end

local function setDrive(on)
    S.drive = on and true or false
    ctrl.lastAng = 0
    if S.drive then
        if not installOverride() then
            S.drive = false
            return false, "Input module not found"
        end
    else
        clearOverride()
    end
    return true
end

-- ================================================================
-- RUN LOOP
-- ================================================================
local function setAutoRun(on)
    S.autoRun = on and true or false
    if S.autoRun and not S.drive then setDrive(true) end
    if not S.autoRun then setDrive(false) end
end

local lastState = nil
local LobbyModule
local lastPadWalk = 0

local function lobbyQueue()
    if game.PlaceId ~= LOBBY then return false end
    if not LobbyModule then
        pcall(function() LobbyModule = require(LP.PlayerScripts.Client.Lobby) end)
    end
    if not LobbyModule then return false end

    local lobby = LobbyModule.state and LobbyModule.state.lobby
    if not lobby then
        local pads = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Pads")
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if pads and hrp and hum and os.clock() - lastPadWalk > 2 then
            lastPadWalk = os.clock()
            local best, bestD = nil, math.huge
            for _, model in ipairs(pads:GetChildren()) do
                local part = model:FindFirstChildWhichIsA("BasePart")
                if part then
                    local d = (part.Position - hrp.Position).Magnitude
                    if d < bestD then best, bestD = part, d end
                end
            end
            if best and bestD > 6 then
                hum:MoveTo(best.Position + Vector3.new(0, 3, 0))
            end
        end
        return false
    end

    local rem = Remotes and Remotes:FindFirstChild("LobbyRequest")
    if not rem then return false end
    pcall(function() rem:FireServer("Start") end)
    S.lastStart = os.clock()
    return true
end

local function tickRunLoop()
    local run = getRun()
    if not run then
        if S.autoRun and os.clock() - S.lastStart > 8 then lobbyQueue() end
        return
    end
    local state = run:GetAttribute("State")
    local now = os.clock()

    if state ~= lastState then
        if state == "Finished" then
            S.finishes += 1
            S.runs += 1
        elseif state == "Caught" then
            S.caught += 1
            S.runs += 1
        end
        lastState = state
    end

    if not S.autoRun then return end
    if now - S.lastStart < 3 then return end

    if state == "Idle" or state == "Finished" then
        fireStart(false)
    elseif state == "Caught" then
        local retries = tonumber(run:GetAttribute("Retries")) or 0
        if S.autoRetry and retries < 2 then
            fireStart(true)
        else
            fireStart(false)
        end
    end
end

-- ================================================================
-- ESP
-- ================================================================
local MONSTERS = { Watcher = true, Scarecrow = true, Runner = true, Intruder = true }
local espGuiName = "R1610ESP"

local function clearEsp()
    local root = workspace:FindFirstChild("ClientMonsters")
    if not root then return end
    for _, d in ipairs(root:GetDescendants()) do
        if d.Name == espGuiName then d:Destroy() end
    end
end

local function refreshEsp()
    local root = workspace:FindFirstChild("ClientMonsters")
    if not root then return end
    local cam = workspace.CurrentCamera
    local origin = cam and cam.CFrame.Position or Vector3.zero
    for _, model in ipairs(root:GetChildren()) do
        if MONSTERS[model.Name] then
            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if part then
                local gui = part:FindFirstChild(espGuiName)
                if S.esp then
                    if not gui then
                        gui = Instance.new("BillboardGui")
                        gui.Name = espGuiName
                        gui.AlwaysOnTop = true
                        gui.Size = UDim2.fromOffset(150, 32)
                        gui.StudsOffset = Vector3.new(0, 3.5, 0)
                        gui.MaxDistance = 600
                        local label = Instance.new("TextLabel")
                        label.Name = "Tag"
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.Font = Enum.Font.Code
                        label.TextSize = 15
                        label.TextColor3 = Color3.fromRGB(255, 186, 66)
                        label.TextStrokeTransparency = 0.25
                        label.Text = model.Name
                        label.Parent = gui
                        gui.Parent = part
                    end
                    local dist = (part.Position - origin).Magnitude
                    gui.Tag.Text = string.format("%s  %dm", model.Name, math.floor(dist))
                elseif gui then
                    gui:Destroy()
                end
            end
        end
    end
end

-- ================================================================
-- HUD
-- ================================================================
local hud, hudLabels
local function buildHud()
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "Route1610HUD"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 4
    gui.Parent = pg

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0, 1)
    panel.Position = UDim2.new(0, 16, 1, -16)
    panel.Size = UDim2.fromOffset(196, 104)
    panel.BackgroundColor3 = Color3.fromRGB(16, 13, 10)
    panel.BackgroundTransparency = 0.22
    panel.BorderSizePixel = 0
    panel.Parent = gui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = panel
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 176, 58)
    stroke.Transparency = 0.55
    stroke.Thickness = 1
    stroke.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 16)
    title.Position = UDim2.fromOffset(8, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(255, 176, 58)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "DO NOT STOP"
    title.Parent = panel

    local rows = { "SPEED", "DIST", "GAP", "STATE", "CREDITS" }
    hudLabels = {}
    for i, name in ipairs(rows) do
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = UDim2.new(1, -16, 0, 15)
        label.Position = UDim2.fromOffset(8, 24 + (i - 1) * 15)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Code
        label.TextSize = 12
        label.TextColor3 = Color3.fromRGB(238, 232, 222)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = name .. "  --"
        label.Parent = panel
        hudLabels[name] = label
    end

    hud = gui
    return gui
end

local function updateHud()
    if not hudLabels then return end
    if not S.hud then
        if hud then hud.Enabled = false end
        return
    end
    if hud then hud.Enabled = true end
    local run = getRun()
    local state = run and run:GetAttribute("State") or "Lobby"
    local s = run and tonumber(run:GetAttribute("CarS")) or 0
    local runnerS = run and tonumber(run:GetAttribute("RunnerS"))
    local active = run and run:GetAttribute("RunnerActive") == true
    local gap = (active and runnerS) and (runnerS - s) or nil
    local credits = tonumber(LP:GetAttribute("Credits")) or 0

    hudLabels.SPEED.Text = string.format("SPEED   %d", math.floor(ctrl.speed))
    hudLabels.DIST.Text = string.format("DIST    %d / %d", math.floor(s), math.floor(finishS))
    if gap then
        hudLabels.GAP.Text = string.format("GAP     %+d", math.floor(gap))
        hudLabels.GAP.TextColor3 = gap < 30 and Color3.fromRGB(255, 96, 82) or Color3.fromRGB(238, 232, 222)
    else
        hudLabels.GAP.Text = "GAP     --"
        hudLabels.GAP.TextColor3 = Color3.fromRGB(150, 142, 130)
    end
    hudLabels.STATE.Text = "STATE   " .. tostring(state)
    hudLabels.CREDITS.Text = string.format("CREDITS %d", credits)
end

-- ================================================================
-- GARAGE (lobby only)
-- ================================================================
local KNOWN_CODES = { "RELEASE", "DONOTSTOP", "ROUTE1610", "LASTSTOP" }

local CAR_LEVELS = {}
pcall(function()
    local cfg = Shared and Shared:FindFirstChild("Config")
    local prog = cfg and cfg:FindFirstChild("Progression")
    if prog then
        local data = require(prog)
        if type(data) == "table" and type(data.Cars) == "table" then
            CAR_LEVELS = data.Cars
        end
    end
end)

local function garageAsk(action, arg)
    local g = Remotes and Remotes:FindFirstChild("Garage")
    if not g then return nil, "no Garage remote" end
    local done, res = false, nil
    task.spawn(function()
        local ok, value = pcall(function() return g:InvokeServer(action, arg) end)
        res = ok and value or ("ERR " .. tostring(value))
        done = true
    end)
    local t0 = os.clock()
    while not done and os.clock() - t0 < 8 do
        if stale() then return nil, "unloaded" end
        task.wait(0.1)
    end
    if not done then return nil, "no answer" end
    return res
end

local function redeem(code)
    if game.PlaceId ~= LOBBY then return false, "Codes only work in the lobby" end
    code = string.upper(string.gsub(tostring(code or ""), "%s+", ""))
    if code == "" then return false, "Empty code" end
    local res, err = garageAsk("redeem", code)
    if not res then return false, err end
    if type(res) == "table" then
        return res.ok == true, tostring(res.why or res.msg or res.ok)
    end
    return false, tostring(res)
end

local function equipBestCar()
    local res, err = garageAsk("state")
    if type(res) ~= "table" then return false, tostring(err or res) end
    local level = tonumber(res.level) or 0
    local best, bestLevel = nil, -1
    for id, lv in pairs(CAR_LEVELS) do
        lv = tonumber(lv)
        if lv and lv <= level and lv > bestLevel then
            best, bestLevel = id, lv
        end
    end
    if not best then return false, "no car unlocked" end
    if type(res.equip) == "table" and res.equip.car == best then
        return true, best .. " already equipped"
    end
    local out = garageAsk("equip", { kind = "car", id = best })
    if type(out) == "table" then
        return out.ok == true, tostring(out.why or out.ok)
    end
    return false, tostring(out)
end

local function openCrates()
    local res, err = garageAsk("state")
    if type(res) ~= "table" then return false, tostring(err or res) end
    local list = res.crates
    if type(list) ~= "table" or #list == 0 then return false, "no crates to open" end
    local opened = 0
    for _, crate in ipairs(list) do
        local id = type(crate) == "table" and (crate.Id or crate.id) or crate
        if id then
            garageAsk("open", id)
            opened += 1
            task.wait(1.5)
        end
    end
    return true, "opened " .. opened
end

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
    if Library ~= nil or stale() then break end
    task.wait(0.25)
end
if not Library or stale() then return end

Library.ConfigFolder = "exlumiaa/do-not-stop"

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Do Not Stop",
    Size = UDim2.fromOffset(500, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Do Not Stop",
    LoadingFooter = "Auto Drive",
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

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "car", Subtitle = "Auto Run" })
local Farm = FarmTab:AddSubTab("Run")

local status

Farm:AddSection("Run")
Farm:AddToggle({
    Name = "Auto Run",
    Flag = "r1610_autorun",
    Default = false,
    Callback = function(v) setAutoRun(v) end,
})
Farm:AddToggle({
    Name = "Auto Drive",
    Flag = "r1610_drive",
    Default = false,
    Callback = function(v)
        local ok, err = setDrive(v)
        if not ok then status:Set("Auto Drive failed: " .. tostring(err)) end
    end,
})
Farm:AddToggle({
    Name = "Auto Retry (free only)",
    Flag = "r1610_retry",
    Default = true,
    Callback = function(v) S.autoRetry = v and true or false end,
})
Farm:AddSlider({
    Name = "Speed Cap",
    Min = 60,
    Max = 135,
    Default = 126,
    Suffix = " studs/s",
    Flag = "r1610_speed",
    Callback = function(v) S.speedCap = v end,
})

Farm:AddSection("Manual")
Farm:AddButton({
    Name = "Start Run",
    Primary = true,
    Callback = function()
        local ok = fireStart(false)
        status:Set(ok and "Run start sent." or "No StartRun remote.")
    end,
})
Farm:AddButton({
    Name = "Leave Run",
    Callback = function()
        local rem = Remotes and Remotes:FindFirstChild("LeaveRun")
        if rem then pcall(function() rem:FireServer() end) end
    end,
})

Farm:AddSection("Status")
status = Farm:AddLabel({ Text = "Idle." })

local GarageTab = Window:AddTab({ Name = "Garage", Icon = "wrench", Subtitle = "Codes" })
local Garage = GarageTab:AddSubTab("Codes")

Garage:AddSection("Codes")
local codeInput = Garage:AddInput({
    Name = "Code",
    Default = "",
    Placeholder = "Type a code",
    Flag = "r1610_code",
})
local garageStatus = Garage:AddLabel({ Text = game.PlaceId == LOBBY and "Ready." or "Garage answers in the lobby only." })

Garage:AddButton({
    Name = "Redeem Code",
    Primary = true,
    Callback = function()
        local ok, text = pcall(function() return codeInput:Get() end)
        local code = ok and text or ""
        if code == "" then
            garageStatus:Set("Type a code first.")
            return
        end
        garageStatus:Set("Redeeming " .. code .. "...")
        local done, msg = redeem(code)
        garageStatus:Set((done and "OK: " or "Failed: ") .. tostring(msg))
    end,
})

Garage:AddButton({
    Name = "Redeem All Known",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Codes only work in the lobby.")
            return
        end
        task.spawn(function()
            for _, code in ipairs(KNOWN_CODES) do
                if stale() then return end
                garageStatus:Set("Redeeming " .. code .. "...")
                local done, msg = redeem(code)
                garageStatus:Set(code .. ": " .. (done and "OK" or tostring(msg)))
                task.wait(2.5)
            end
        end)
    end,
})

Garage:AddSection("Garage")
Garage:AddButton({
    Name = "Load Profile",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Garage answers in the lobby only.")
            return
        end
        garageStatus:Set("Asking the garage...")
        local res, err = garageAsk("state")
        if not res then
            garageStatus:Set("Failed: " .. tostring(err))
            return
        end
        if type(res) == "table" then
            garageStatus:Set(string.format("Level %s | %s credits", tostring(res.level), tostring(res.credits)))
        else
            garageStatus:Set("Answer: " .. tostring(res))
        end
    end,
})

Garage:AddSection("Freebies")
Garage:AddButton({
    Name = "Claim Group Reward",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Lobby only.")
            return
        end
        garageStatus:Set("Claiming group reward...")
        local res, err = garageAsk("group")
        if type(res) == "table" then
            garageStatus:Set((res.ok and "OK" or "Failed: " .. tostring(res.why)))
        else
            garageStatus:Set(tostring(err or res))
        end
    end,
})
Garage:AddButton({
    Name = "Open All Crates",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Lobby only.")
            return
        end
        garageStatus:Set("Opening crates...")
        local ok, msg = openCrates()
        garageStatus:Set((ok and "OK: " or "Failed: ") .. tostring(msg))
    end,
})
Garage:AddButton({
    Name = "Equip Best Car",
    Callback = function()
        if game.PlaceId ~= LOBBY then
            garageStatus:Set("Lobby only.")
            return
        end
        local ok, msg = equipBestCar()
        garageStatus:Set((ok and "OK: " or "Failed: ") .. tostring(msg))
    end,
})

local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local Visual = VisualTab:AddSubTab("World")

Visual:AddSection("World")
Visual:AddToggle({
    Name = "Monster ESP",
    Flag = "r1610_esp",
    Default = false,
    Callback = function(v)
        S.esp = v and true or false
        if not S.esp then clearEsp() end
    end,
})
Visual:AddToggle({
    Name = "HUD",
    Flag = "r1610_hud",
    Default = true,
    Callback = function(v)
        S.hud = v and true or false
        if hud then hud.Enabled = S.hud end
    end,
})

Visual:AddSection("Info")
Visual:AddLabel({ Text = "Monster ESP tags Watcher / Scarecrow / Runner / Intruder." })
Visual:AddLabel({ Text = "HUD shows speed, road distance, runner gap, credits." })

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Misc" })
local Settings = SettingsTab:AddSubTab("Session")

Settings:AddSection("Session")
local sessionLabel = Settings:AddLabel({ Text = "0 runs | 0 finishes | 0 caught" })

Settings:AddButton({
    Name = "Refresh Stats",
    Callback = function()
        sessionLabel:Set(string.format("%d runs | %d finishes | %d caught", S.runs, S.finishes, S.caught))
    end,
})

Settings:AddButton({
    Name = "Unload Script",
    Callback = function()
        getgenv().__route1610Gen = (tonumber(getgenv().__route1610Gen) or 0) + 1
        clearOverride()
        clearEsp()
        cleanupGui("ExlumiaaHub")
        cleanupGui("Route1610HUD")
    end,
})

-- ================================================================
-- LOOP
-- ================================================================
buildHud()

local acc = 0
local espAcc = 0
RunService.Heartbeat:Connect(function(dt)
    if stale() then return end
    acc += dt
    espAcc += dt
    if acc >= 0.4 then
        acc = 0
        tickRunLoop()
        updateHud()
        local credits = tonumber(LP:GetAttribute("Credits"))
        if credits then
            if S.creditsStart == nil then S.creditsStart = credits end
            S.creditsGain = credits - S.creditsStart
        end
    end
    if espAcc >= 0.3 then
        espAcc = 0
        if S.esp then refreshEsp() end
    end
end)

LP.OnTeleport:Connect(function()
    clearOverride()
    clearEsp()
end)

getgenv()._route1610 = {
    getState = function()
        return {
            autoRun = S.autoRun,
            drive = S.drive,
            autoRetry = S.autoRetry,
            speedCap = S.speedCap,
            esp = S.esp,
            hud = S.hud,
            runs = S.runs,
            finishes = S.finishes,
            caught = S.caught,
            credits = tonumber(LP:GetAttribute("Credits")),
            hasPath = path ~= nil,
            hasInput = Input ~= nil,
            ctrl = { speed = ctrl.speed, vmax = ctrl.vmax, lat = ctrl.lat, s = ctrl.s },
        }
    end,
    setAutoRun = setAutoRun,
    setDrive = setDrive,
    setSpeed = function(v) S.speedCap = tonumber(v) or S.speedCap end,
    setEsp = function(v)
        S.esp = v and true or false
        if not S.esp then clearEsp() end
    end,
    startRun = fireStart,
    redeem = redeem,
    garage = garageAsk,
    equipBestCar = equipBestCar,
    openCrates = openCrates,
    clearOverride = clearOverride,
}

print("[ExlumiaaHub] Do Not Stop loaded | path=" .. tostring(path ~= nil) .. " input=" .. tostring(Input ~= nil))
