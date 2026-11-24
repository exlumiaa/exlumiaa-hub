if tostring(game.GameId) ~= "10764497964" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _bseHubTomb1"
local _G_GEN = "_ _bseHubGen"
local _G_COUNTER = "_ _bseHubCounter"

rawset(_G, _G_TOMB, true)

local MY_GEN = (tonumber(rawget(_G, _G_COUNTER)) or 0) + 1
rawset(_G, _G_COUNTER, MY_GEN)
rawset(_G, _G_GEN, MY_GEN)

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

local function isStale()
    return tonumber(rawget(_G, _G_GEN)) ~= MY_GEN
end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_bse.txt"
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
            brand = "Backstreet Survival",
            guiName = "BackstreetKeyGate",
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

Library.ConfigFolder = "exlumiaa/backstreet"

local Window = nil

local function notify(title, content, typ)
    if not Window then return end
    pcall(function()
        Window:Notify({Title = title, Content = content, Type = typ or "info", Duration = 4})
    end)
end

local Events = ReplicatedStorage:WaitForChild("Events")
local SellFunc = Events:WaitForChild("SellFunc")
local BankFunc = Events:WaitForChild("BankFunc")
local DataFunc = Events:WaitForChild("DataFunc")
local AFKEvent = Events:WaitForChild("AFKEvent")

local State = {
    dig = false,
    sellTrash = false,
    sellFish = false,
    sellCrop = false,
    deposit = false,
    antiAfk = false,
    instantSell = true,
    sellInterval = 6,
    depositInterval = 6,
}

local tokens = {}
local lastMsg = {}
local ticks = {}

local function setLoop(key, enabled, fn, getInterval)
    State[key] = enabled
    tokens[key] = (tokens[key] or 0) + 1
    local myToken = tokens[key]
    if not enabled then
        lastMsg[key] = nil
        return
    end
    print("[BSE] loop start: " .. key)
    task.spawn(function()
        task.wait(0.15)
        while State[key] and tokens[key] == myToken and not isStale() do
            ticks[key] = (ticks[key] or 0) + 1
            local pok, ok, msg = pcall(fn)
            if not pok then
                ok, msg = false, tostring(msg)
            end
            if ok then
                lastMsg[key] = nil
            elseif msg and msg ~= lastMsg[key] then
                lastMsg[key] = msg
                notify("Backstreet Survival", msg, "warning")
            end
            local iv = tonumber(getInterval()) or 6
            task.wait(iv > 0 and iv or 1)
        end
        print("[BSE] loop stop: " .. key)
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

local function wakeUp()
    local c, h, r = getChar()
    if not c then return end
    local slept = r.Anchored or c:GetAttribute("Sleep") == true
    if not slept then return end
    r.Anchored = false
    pcall(function()
        local animator = h:FindFirstChildOfClass("Animator")
        if not animator then return end
        for _, track in animator:GetPlayingAnimationTracks() do
            if track.Name:find("AFK", 1, true) then
                track:Stop(0.2)
            end
        end
    end)
    pcall(function() AFKEvent:FireServer(false) end)
    pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end)
end

local function walkTo(target, reach, timeout)
    reach = reach or 8
    timeout = timeout or 15
    wakeUp()
    local t0 = os.clock()
    local lastDist = math.huge
    local stall = 0
    while os.clock() - t0 < timeout do
        if isStale() then return false end
        local _, h, r = getChar()
        if not h then return false end
        local d = (r.Position - target).Magnitude
        if d <= reach then
            h:MoveTo(r.Position)
            return true
        end
        if d >= lastDist - 0.2 then
            stall = stall + 0.2
        else
            stall = 0
        end
        lastDist = d
        if stall >= 2.5 then
            stall = 0
            lastDist = math.huge
            pcall(function()
                local path = PathfindingService:CreatePath({
                    AgentRadius = 2,
                    AgentHeight = 5,
                    AgentCanJump = true,
                    AgentCanClimb = false,
                })
                path:ComputeAsync(r.Position, target)
                if path.Status ~= Enum.PathStatus.Success then return end
                local wps = path:GetWaypoints()
                for i = 2, math.min(#wps, 8) do
                    local _, hh, rr = getChar()
                    if not hh or isStale() then return end
                    if wps[i].Action == Enum.PathWaypointAction.Jump then hh.Jump = true end
                    hh:MoveTo(wps[i].Position)
                    task.wait(0.4)
                end
            end)
        else
            h:MoveTo(target)
            task.wait(0.2)
        end
    end
    local _, h, r = getChar()
    if h and r then h:MoveTo(r.Position) end
    return false
end

-- The server rejects Sell/Bank calls made from more than ~10 studs away
-- ("TooFar"), so the call has to happen next to the prompt. Instead of
-- walking there, snap the character over, make the call, snap back.
-- `originCF` is where the caller wants to end up again; pass it in so a
-- second hop closer still restores to the original spot, not the first one.
local function hopNear(target, dist, originCF)
    local _, h, r = getChar()
    if not h or not r then return false end
    wakeUp()
    local origin = originCF or r.CFrame
    local flat = Vector3.new(r.Position.X - target.X, 0, r.Position.Z - target.Z)
    if flat.Magnitude < 0.05 then flat = Vector3.new(1, 0, 0) else flat = flat.Unit end
    r.CFrame = CFrame.new(target + flat * dist + Vector3.new(0, 3, 0))
    task.wait(0.18)
    local _, _, r2 = getChar()
    if not r2 then return false end
    if (r2.Position - target).Magnitude > 12 then
        r2.CFrame = origin
        return false
    end
    return true
end

local function restoreTo(originCF)
    if not originCF then return end
    local _, _, r = getChar()
    if not r then return end
    r.CFrame = originCF
end

local function promptPos(prompt)
    local p = prompt.Parent
    if not p then return nil end
    if p:IsA("BasePart") then return p.Position end
    if p:IsA("Attachment") then return p.WorldPosition end
    if p:IsA("Model") then return p:GetPivot().Position end
    return nil
end

local function nearestPrompt(tag, wantType)
    local _, _, r = getChar()
    if not r then return nil, nil end
    local best, bestPos, bestD = nil, nil, math.huge
    for _, inst in CollectionService:GetTagged(tag) do
        if inst:IsA("ProximityPrompt") and (wantType == nil or inst:GetAttribute("Type") == wantType) then
            local pos = promptPos(inst)
            if pos then
                local d = (pos - r.Position).Magnitude
                if d < bestD then
                    best, bestPos, bestD = inst, pos, d
                end
            end
        end
    end
    return best, bestPos
end

local cfgCache = {}

local function getLootCfg(sellType)
    if cfgCache[sellType] then return cfgCache[sellType] end
    local cfg = {}
    local ok = pcall(function()
        if sellType == "Trash" then
            local t = require(ReplicatedStorage.Config.Trash)
            for k, v in t do cfg[k] = v end
        elseif sellType == "Fish" then
            local f = require(ReplicatedStorage.Config.Fish)
            for k, v in f do cfg[k] = v end
        else
            local g = require(ReplicatedStorage.Config.GardenStore)
            for _, v in g do
                if typeof(v) == "table" and typeof(v.CropTool) == "string" and v.CropTool:sub(1, 5) == "Crop_" then
                    cfg[v.CropTool:sub(6)] = v
                end
            end
        end
    end)
    cfgCache[sellType] = ok and cfg or {}
    return cfgCache[sellType]
end

local function getSavedLoot(sellType)
    local ok, res = pcall(function() return SellFunc:InvokeServer("GetSavedLoot") end)
    if ok and typeof(res) == "table" and typeof(res[sellType]) == "table" then
        return res[sellType]
    end
    return nil
end

local function buildSellPayload(sellType)
    local cfg = getLootCfg(sellType)
    local saved = getSavedLoot(sellType)
    local payload = {Type = sellType}
    local count = 0
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in bp:GetChildren() do
            if tool:IsA("Tool") and tool:GetAttribute("TYPE") == sellType then
                local prefix = sellType .. "_"
                local id = nil
                if tool.Name:sub(1, #prefix) == prefix then
                    local rest = tool.Name:sub(#prefix + 1)
                    if rest ~= "" then id = rest end
                end
                if id and cfg[id] and not (saved and saved[id] == true) then
                    local amt = math.floor(tonumber(tool:GetAttribute("amount")) or 1)
                    if amt > 0 then
                        payload[id] = (payload[id] or 0) + amt
                        count += 1
                    end
                end
            end
        end
    end
    return payload, count
end

local function doSellOnce(sellType)
    local prompt, pos = nearestPrompt("SellProx", sellType)
    if not prompt or not pos then
        return false, "No " .. sellType .. " seller found on this map"
    end
    local payload, count = buildSellPayload(sellType)
    if count == 0 then
        return false, "No " .. sellType .. " to sell"
    end
    local reach = 8
    local originCF = nil
    local hopped = false
    local _, _, r = getChar()
    if r then originCF = r.CFrame end
    if State.instantSell and r and (r.Position - pos).Magnitude > reach then
        hopped = hopNear(pos, 6, originCF)
    end
    if not hopped then
        if not walkTo(pos, reach, 15) then
            return false, "Could not reach the seller"
        end
    end
    local lastErr = nil
    local finalOk, finalMsg = false, nil
    for _ = 1, 3 do
        if isStale() then
            restoreTo(originCF)
            return false, nil
        end
        local ok, a, b = pcall(function()
            return SellFunc:InvokeServer("Sell", payload)
        end)
        if not ok then
            finalMsg = "Sell error: " .. tostring(a)
            break
        end
        if a == true then
            finalOk = true
            break
        end
        lastErr = b
        if b == "TooFar" then
            if hopped then
                hopNear(pos, 4, originCF)
            elseif not walkTo(pos, 5, 15) then
                finalMsg = "Could not reach the seller"
                break
            end
        elseif b == "NothingToSell" then
            finalMsg = "Nothing to sell"
            break
        elseif b == "Busy" then
            task.wait(0.6)
        elseif b == "NoProfile" then
            finalMsg = "Profile data is not ready yet"
            break
        end
        task.wait(0.4)
    end
    if hopped then restoreTo(originCF) end
    if finalOk then return true, nil end
    if finalMsg then return false, finalMsg end
    return false, "Sell failed (" .. tostring(lastErr) .. ")"
end

local function getCash()
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    return tonumber(cash and cash.Value) or 0
end

local function doDepositOnce()
    local prompt, pos = nearestPrompt("BankProx")
    if not prompt or not pos then
        return false, "No ATM or bank found"
    end
    if not walkTo(pos, 8, 15) then
            return false, "Could not reach the ATM"
    end
    local terminal = prompt:GetAttribute("terminal") or false
    local ok, data = pcall(function() return BankFunc:InvokeServer("GetData", 0, false) end)
    if not ok then
        return false, "Bank error: " .. tostring(data)
    end
    if typeof(data) ~= "table" then
            return false, "Bank card required (buy one at the bank first)"
    end
    local amount = math.floor(getCash())
    local serverCash = tonumber(data.Cash)
    if serverCash then
        amount = math.min(amount, math.floor(serverCash))
    end
    if amount <= 0 then
            return false, "No cash on hand"
    end
    local ok2, res = pcall(function()
        return BankFunc:InvokeServer("Deposit", amount, terminal)
    end)
    if not ok2 then
        return false, "Deposit error: " .. tostring(res)
    end
    if typeof(res) == "table" or res == true then
        return true, nil
    end
        return false, "Deposit failed (" .. tostring(res) .. ")"
end

local DIG_SCRIPTS = {
    ShovelScript = 1,
    StickScript = 2,
}

local function findDigTool()
    local c = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    local best, bestRank = nil, 99
    local function scan(container)
        if not container then return end
        for _, t in container:GetChildren() do
            if t:IsA("Tool") then
                local rank = nil
                for childName, r in DIG_SCRIPTS do
                    if t:FindFirstChild(childName) then
                        rank = r
                        break
                    end
                end
                if not rank then
                    local lower = t.Name:lower()
                    if lower:find("shovel", 1, true) then
                        rank = 3
                    elseif lower:find("stick", 1, true) then
                        rank = 4
                    end
                end
                if rank and rank < bestRank then
                    best, bestRank = t, rank
                end
            end
        end
    end
    scan(c)
    scan(bp)
    return best
end

local function doDigOnce()
    local c = getChar()
    if not c then return false, "Character is not ready" end
    wakeUp()
    local tool = findDigTool()
    if not tool then
        return false, "No digging tool available"
    end
    if tool.Parent ~= c then
        tool.Parent = c
        task.wait(0.25)
    end
    if tool.Parent ~= c then
        return false, "Failed to use the digging tool"
    end
    tool:Activate()
    local cd = tonumber(tool:GetAttribute("CD")) or 1
    task.wait(math.max(cd * 0.9, 0.2))
    return true, nil
end

local afkConn = nil

local function setAntiAfk(enabled)
    State.antiAfk = enabled
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
    if enabled then
        afkConn = LP.Idled:Connect(function()
            if not State.antiAfk or isStale() then return end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end
end

local teleportData = nil

local function getTeleportData()
    if teleportData then return teleportData end
    local ok, res = pcall(function() return require(ReplicatedStorage.Config.TeleportData) end)
    teleportData = ok and typeof(res) == "table" and res or {}
    return teleportData
end

local function teleportTo(index)
    local data = getTeleportData()[index]
    if not data or typeof(data.TargetCFrame) ~= "CFrame" then
        return false, "Invalid location"
    end
    local _, h, r = getChar()
    if not h then return false, "Character is not ready" end
    r.CFrame = data.TargetCFrame * CFrame.new(0, 3, 0)
    h:ChangeState(Enum.HumanoidStateType.Landed)
    return true, nil
end

Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Backstreet Survival: Enhanced",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Backstreet Survival: Enhanced",
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
local labelLocation = HomeSub:AddLabel({Text = "Location: --"})

HomeSub:AddSection("Game")
HomeSub:AddLabel({Text = "GameId: " .. tostring(game.GameId)})
HomeSub:AddLabel({Text = "PlaceId: " .. tostring(game.PlaceId)})

HomeSub:AddSection("Server")
HomeSub:AddLabel({Text = "JobId: " .. string.sub(tostring(game.JobId), 1, 20) .. "..."})
HomeSub:AddButton({
    Name = "Copy JobId",
    Callback = function()
        pcall(setclipboard, tostring(game.JobId))
        notify("Copied", "JobId copied!", "success")
    end,
})

local FarmTab = Window:AddTab({Name = "Farm", Icon = "hammer", Subtitle = "Auto"})
local FarmSub = FarmTab:AddSubTab("Features")

FarmSub:AddSection("Auto Dig")
FarmSub:AddToggle({
    Name = "Auto Dig",
    Flag = "bse_autodig",
    Default = false,
    Callback = function(v)
        setLoop("dig", v, doDigOnce, function() return 0.5 end)
    end,
})

FarmSub:AddSection("Auto Sell")
FarmSub:AddToggle({
    Name = "Instant Sell (Teleport)",
    Flag = "bse_instant_sell",
    Default = true,
    Callback = function(v)
        State.instantSell = v
    end,
})
FarmSub:AddToggle({
    Name = "Auto Sell Trash",
    Flag = "bse_sell_trash",
    Default = false,
    Callback = function(v)
        setLoop("sellTrash", v, function() return doSellOnce("Trash") end, function() return State.sellInterval end)
    end,
})
FarmSub:AddToggle({
    Name = "Auto Sell Fish",
    Flag = "bse_sell_fish",
    Default = false,
    Callback = function(v)
        setLoop("sellFish", v, function() return doSellOnce("Fish") end, function() return State.sellInterval end)
    end,
})
FarmSub:AddToggle({
    Name = "Auto Sell Crop",
    Flag = "bse_sell_crop",
    Default = false,
    Callback = function(v)
        setLoop("sellCrop", v, function() return doSellOnce("Crop") end, function() return State.sellInterval end)
    end,
})
FarmSub:AddSlider({
    Name = "Sell Interval",
    Min = 3,
    Max = 60,
    Default = 6,
    Suffix = " sec",
    Flag = "bse_sell_interval",
    Callback = function(v)
        State.sellInterval = v
    end,
})

local BankTab = Window:AddTab({Name = "Bank", Icon = "landmark", Subtitle = "ATM"})
local BankSub = BankTab:AddSubTab("Features")

BankSub:AddSection("Auto Deposit")
BankSub:AddToggle({
    Name = "Auto Deposit Cash",
    Flag = "bse_deposit",
    Default = false,
    Callback = function(v)
        setLoop("deposit", v, doDepositOnce, function() return State.depositInterval end)
    end,
})
BankSub:AddSlider({
    Name = "Deposit Interval",
    Min = 3,
    Max = 60,
    Default = 6,
    Suffix = " sec",
    Flag = "bse_deposit_interval",
    Callback = function(v)
        State.depositInterval = v
    end,
})
BankSub:AddSection("Notes")
BankSub:AddLabel({Text = "Bank card required. Buy one at the bank first."})
BankSub:AddLabel({Text = "Daily deposit limits are enforced by the server."})

local TeleTab = Window:AddTab({Name = "Teleport", Icon = "map", Subtitle = "Places"})
local TeleSub = TeleTab:AddSubTab("Places")

TeleSub:AddSection("Travel")
local teleportNames = {}
for _, v in getTeleportData() do
    table.insert(teleportNames, v.DisplayName)
end
local selectedTeleport = ""
TeleSub:AddDropdown({
    Name = "Location",
    Options = teleportNames,
    Default = "",
    Flag = "bse_teleport_target",
    Callback = function(v) selectedTeleport = v end,
})
TeleSub:AddButton({
    Name = "Teleport",
    Primary = true,
    Callback = function()
        local data = getTeleportData()
        for i, v in data do
            if v.DisplayName == selectedTeleport then
                local ok, err = teleportTo(i)
                if ok then
                    notify("Teleport", "Teleported to " .. v.DisplayName, "success")
                else
                    notify("Teleport", tostring(err), "error")
                end
                return
            end
        end
        notify("Teleport", "Select a location first!", "warning")
    end,
})

local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})
local MiscSub = SettingsTab:AddSubTab("Misc")
local ConfigSub = SettingsTab:AddSubTab("Config")
local HopSub = SettingsTab:AddSubTab("Server Hop")

MiscSub:AddSection("Player")
MiscSub:AddToggle({
    Name = "Anti AFK",
    Flag = "bse_antiafk",
    Default = false,
    Callback = function(v)
        setAntiAfk(v)
    end,
})
MiscSub:AddLabel({Text = "Toggle Menu: RightControl"})

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "bse_config_selected",
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
    Flag = "bse_config_name",
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
        local ok = Library:SaveConfig(name)
        if ok then
            refreshConfigList()
            notify("Config", "Saved: " .. name, "success")
        else
            notify("Config", "Save failed!", "error")
        end
    end,
})

ConfigSub:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning")
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            notify("Config", "Loaded: " .. selectedConfig, "success")
        else
            notify("Config", "Failed to load!", "error")
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            notify("Config", "Select a config first!", "warning")
            return
        end
        Library:DeleteConfig(selectedConfig)
        local old = selectedConfig
        selectedConfig = ""
        refreshConfigList()
        notify("Config", "Deleted: " .. old, "info")
    end,
})

ConfigSub:AddDivider()
ConfigSub:AddSection("Info")
ConfigSub:AddLabel({Text = "by Exlumiaa Hub"})
ConfigSub:AddLabel({Text = "Toggle Menu: RightControl"})

HopSub:AddSection("Server")
HopSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        notify("Server Hop", "Finding a new server...", "info")
        local ok, err = pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
        if not ok then
            notify("Server Hop", "Failed: " .. tostring(err), "error")
        end
    end,
})
HopSub:AddButton({
    Name = "Rejoin Server",
    Primary = false,
    Callback = function()
        notify("Rejoin", "Rejoining...", "info")
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(game.JobId), LP)
        end)
        if not ok then
            notify("Rejoin", "Failed: " .. tostring(err), "error")
        end
    end,
})

task.spawn(function()
    while not isStale() do
        task.wait(1)
        pcall(function()
            labelPlayers:Set("Players: " .. #Players:GetPlayers())
            labelCash:Set("Cash: $" .. string.format("%.2f", tonumber(getCash()) or 0))
            labelLocation:Set("Location: " .. tostring(LP:GetAttribute("Location") or "-"))
        end)
    end
end)

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

getgenv()._bse = {
    sellTrash = function() return doSellOnce("Trash") end,
    sellFish = function() return doSellOnce("Fish") end,
    sellCrop = function() return doSellOnce("Crop") end,
    deposit = doDepositOnce,
    dig = doDigOnce,
    teleport = teleportTo,
    walkTo = walkTo,
    wakeUp = wakeUp,
    nearestPrompt = nearestPrompt,
    buildSellPayload = buildSellPayload,
    state = State,
    ticks = ticks,
}

print("[ExlumiaaHub] Backstreet Survival Hub loaded!")
