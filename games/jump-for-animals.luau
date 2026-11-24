if tostring(game.GameId) ~= "10690360998" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _jfaTombOx"
local _G_ALIVE = "_ _jfaAliveOx"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

-- Kill old Obsidian JFA + old Oxidelib runs
do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub" or gui.Name == "JFALoading") then
                gui:Destroy()
            end
        end
    end)
    pcall(function()
        if LP then
            local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub" or gui.Name == "JFALoading") then
                    gui:Destroy()
                end
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
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_jfa.txt"
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
            brand = "Jump for Animals!",
            guiName = "JFAKeyGate",
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
end

-- ================================================================
-- CONFIG
-- ================================================================
local Config = {
    autoTrain = false,
    autoCollect = false,
    collectDelay = 0.3,
    collectArea = "All",
    autoPlace = true,
    autoTpOpEgg = false,
    guardDropBlock = false,
    walkEnabled = false,
    walkSpeed = 50,
    jumpEnabled = false,
    jumpPower = 100,
    tpToHome = false,
    homeKey = Enum.KeyCode.Q,
}

local AREAS = { "All", "Celestial Heights", "Coral Reef", "Crystal Mines", "Desert", "Jungle", "Meadow", "Mystic Isles", "Prehistoric", "Savannah", "Winter" }

local AREA_POSITIONS = {
    ["Coral Reef"] = Vector3.new(0.6, 15, -196),
    ["Meadow"] = Vector3.new(0, -3, -133),
    ["Mystic Isles"] = Vector3.new(-2, 1702, -966),
    ["Prehistoric"] = Vector3.new(0.6, 2561, -1103),
    ["Celestial Heights"] = Vector3.new(-0.6, 3234, -1175),
    ["Savannah"] = Vector3.new(0, 4952, -1315),
    ["Winter"] = Vector3.new(0.6, 72, -336),
    ["Desert"] = Vector3.new(-0.6, 255, -478),
    ["Crystal Mines"] = Vector3.new(-0.6, 541, -617),
    ["Jungle"] = Vector3.new(-0.6, 906, -757),
}

local TELEPORT_AREAS = { "Coral Reef", "Meadow", "Mystic Isles", "Prehistoric", "Celestial Heights", "Savannah", "Winter", "Desert", "Crystal Mines", "Jungle" }

local originalWalkSpeed = 16
local originalJumpPower = 50
local homePosition = nil

-- ================================================================
-- HELPERS
-- ================================================================
local function getRemotes()
    return ReplicatedStorage:WaitForChild("Remotes", 10)
end

local function teleportTo(pos)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
end

-- ================================================================
-- GUARD DROP BLOCK
-- ================================================================
local guardDropHooked = false
local oldNamecall = nil

local function hookGuardDrop()
    if guardDropHooked then return end
    if not hookmetamethod or not getnamecallmethod then
        warn("[JFA] hookmetamethod not available")
        return
    end
    local Remotes = getRemotes()
    if not Remotes then return end
    local dropRemote = Remotes:FindFirstChild("DropEggRequest")
    if not dropRemote then return end
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Config.guardDropBlock and method == "FireServer" and self == dropRemote then
            return nil
        end
        return oldNamecall(self, ...)
    end))
    guardDropHooked = true
end

-- ================================================================
-- AUTO TRAIN
-- ================================================================
local function getSquatDetector()
    local plot = LP:FindFirstChild("Plot")
    if not plot then return nil end
    local plotVal = plot.Value
    if not plotVal then return nil end
    local squatZone = plotVal:FindFirstChild("SquatZone")
    if not squatZone then return nil end
    local floor = squatZone:FindFirstChild("Floor")
    if not floor then return nil end
    return floor:FindFirstChild("Detector")
end

local function autoTrainTick()
    if not Config.autoTrain then return end
    if LP:GetAttribute("IsSquatting") == true then return end

    local Remotes = getRemotes()
    if not Remotes then return end
    local squatReq = Remotes:FindFirstChild("SquatTrainingRequest")
    if not squatReq then return end

    local detector = getSquatDetector()
    if not detector then return end

    local tutorialStep = LP:GetAttribute("TutorialStep")
    if LP:GetAttribute("TutorialCompleted") ~= true
        and tutorialStep ~= "ReachTrain"
        and tutorialStep ~= "Train" then
        return
    end

    teleportTo(detector.Position)
    task.wait(0.1)
    squatReq:FireServer(detector)
end

local function stopTraining()
    if LP:GetAttribute("IsSquatting") == true then
        local Remotes = getRemotes()
        if Remotes then
            local stopReq = Remotes:FindFirstChild("StopSquattingRequest")
            if stopReq then
                pcall(function() stopReq:FireServer() end)
            end
        end
    end
end

local function autoSquatBonusTick()
    if not Config.autoTrain then return end
    if LP:GetAttribute("IsSquatting") ~= true then return end
    if LP:GetAttribute("SquatBonusAvailable") ~= true then return end

    local Remotes = getRemotes()
    if not Remotes then return end
    local bonusReq = Remotes:FindFirstChild("SquatBonusRequest")
    if not bonusReq then return end

    local version = tonumber(LP:GetAttribute("SquatBonusVersion")) or 0
    pcall(function() bonusReq:FireServer(version) end)
end

-- ================================================================
-- AUTO COLLECT EGGS
-- ================================================================
local function getPlotPosition()
    local plot = LP:FindFirstChild("Plot")
    if not plot then return nil end
    local plotVal = plot.Value
    if not plotVal then return nil end
    local settings = ReplicatedStorage:FindFirstChild("Settings")
    if settings then
        local eggs = settings:FindFirstChild("Eggs")
        if eggs then
            local ok, eggsMod = pcall(require, eggs)
            if ok and eggsMod.Placement then
                local region = plotVal:FindFirstChild(eggsMod.Placement.RegionName)
                if region and region:IsA("BasePart") then
                    return region.Position + Vector3.new(0, 3, 0)
                end
            end
        end
    end
    return plotVal.Position + Vector3.new(0, 3, 0)
end

local function getCarriedEggTool()
    local char = LP.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("IsEggTool") then
                return child
            end
        end
    end
    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("IsEggTool") then
                return child
            end
        end
    end
    return nil
end

local function autoCollectTick()
    if not Config.autoCollect then return end

    local carried = LP:GetAttribute("CarriedEggCount") or 0
    if carried > 0 then
        if Config.autoPlace then
            local plotPos = getPlotPosition()
            if plotPos then
                teleportTo(plotPos)
                task.wait(0.15)
                local tool = getCarriedEggTool()
                if tool then
                    local eggId = tool:GetAttribute("EggId")
                    if eggId then
                        local Remotes = getRemotes()
                        if Remotes then
                            local placeReq = Remotes:FindFirstChild("PlaceEggRequest")
                            if placeReq then
                                for i = 1, 3 do
                                    local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                                    pcall(function() placeReq:FireServer(eggId, plotPos + offset) end)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
        end
        return
    end

    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest = nil
    local nearDist = math.huge
    local nearPos = nil

    for _, att in ipairs(CollectionService:GetTagged("DynamicEggPrompt")) do
        if att:IsA("Attachment") then
            if Config.collectArea ~= "All" then
                local path = att:GetFullName()
                if not path:find("Stages%." .. Config.collectArea:gsub("%-", "%%-")) then
                    continue
                end
            end
            for _, prompt in ipairs(att:GetChildren()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Name == "CollectPrompt" then
                    local ov = att:FindFirstChild("EggRoot")
                    local target = ov and ov.Value
                    if not target then target = att:FindFirstAncestorOfClass("Model") end
                    if target then
                        local pos = target:IsA("BasePart") and target.Position or (target:IsA("Model") and target:GetPivot().Position or nil)
                        if pos then
                            local dist = (hrp.Position - pos).Magnitude
                            if dist < nearDist then
                                nearDist = dist
                                nearest = prompt
                                nearPos = pos
                            end
                        end
                    end
                end
            end
        end
    end

    if not nearest or not nearPos then return end

    teleportTo(nearPos)
    task.wait(0.2)
    nearest:InputHoldBegin()
    task.wait(nearest.HoldDuration + 0.5)
    nearest:InputHoldEnd()
    task.wait(Config.collectDelay)
end

-- ================================================================
-- SERVER HOP
-- ================================================================
local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    local ok, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if ok and result then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(result) end)
        if decodeOk and data and data.data then
            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        end
    end
    if #servers > 0 then
        local target = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, target, LP)
    else
        TeleportService:Teleport(placeId)
    end
end

-- ================================================================
-- WALKSPEED / JUMPOWER
-- ================================================================
local function applyStats(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Config.walkEnabled then
        hum.WalkSpeed = Config.walkSpeed
    end
    if Config.jumpEnabled then
        hum.JumpPower = Config.jumpPower
    end
end

-- ================================================================
-- OP EGG TRACKER
-- ================================================================
local opEggTpSent = false

local function getOpEggCountdown()
    local Map = workspace:FindFirstChild("Map")
    if not Map then return nil, false, false end
    local enabled = Map:GetAttribute("SecretSpawnEnabled")
    if enabled == false then return nil, false, false end
    local queued = Map:GetAttribute("SecretSpawnQueued")
    local endsAt = Map:GetAttribute("SecretSpawnEndsAt")
    local now = workspace:GetServerTimeNow()
    local remaining = endsAt and math.max(math.ceil(endsAt - now), 0) or 0
    return remaining, queued == true, true
end

local function opEggTick()
    if not Config.autoTpOpEgg then return end
    local remaining, queued, enabled = getOpEggCountdown()
    if not enabled then return end

    if remaining == 0 and not queued then
        if not opEggTpSent then
            local pos = AREA_POSITIONS["Prehistoric"]
            if pos then
                teleportTo(pos)
                opEggTpSent = true
            end
        end
    else
        opEggTpSent = false
    end
end

-- ================================================================
-- MAIN LOOP
-- ================================================================
task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        pcall(autoTrainTick)
        pcall(autoSquatBonusTick)
        pcall(autoCollectTick)
        pcall(opEggTick)
        task.wait(0.1)
    end
end)

LP.CharacterAdded:Connect(function(char)
    originalWalkSpeed = 16
    originalJumpPower = 50
    task.wait(0.5)
    applyStats(char)
end)

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then break end
        applyStats(LP.Character)
        task.wait(0.2)
    end
end)

-- ================================================================
-- TP TO HOME KEYBIND (Q)
-- ================================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.homeKey and Config.tpToHome then
        if homePosition then
            teleportTo(homePosition)
        end
    end
end)

-- ================================================================
-- UI â€” Oxidelib
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
if not Library then return end

Library.ConfigFolder = "exlumiaa"

local logoId = nil
pcall(function()
    if isfile and isfile("exlumiaa_logo.png") then
        logoId = getcustomasset("exlumiaa_logo.png")
    end
end)

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Jump for Animals!",
    Size = UDim2.fromOffset(700, 490),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Jump for Animals!",
    LoadingFooter = "by Exlumiaa Hub",
    Logo = logoId,
    GuiName = "ExlumiaaHub",
})

if logoId then
    pcall(function()
        if Window.Logo then Window.Logo.Image = logoId end
        if Window.Watermark then Window.Watermark.Image = logoId end
    end)
end

-- ======================== HOME TAB ========================
local HomeTab = Window:AddTab({ Name = "Home", Icon = "home", Subtitle = "Info" })
local InfoSub = HomeTab:AddSubTab("Info")

InfoSub:AddSection("Player")
local labelHealth = InfoSub:AddLabel({ Text = "Health: -" })
local labelPos = InfoSub:AddLabel({ Text = "Pos: -" })
local labelWS = InfoSub:AddLabel({ Text = "WalkSpeed: -" })
local labelJP = InfoSub:AddLabel({ Text = "JumpPower: -" })

InfoSub:AddSection("Server")
InfoSub:AddLabel({ Text = "Place: " .. tostring(game.PlaceId) })
InfoSub:AddLabel({ Text = "Job: " .. tostring(game.JobId) })
local labelPing = InfoSub:AddLabel({ Text = "Ping: --" })
local labelPlayers = InfoSub:AddLabel({ Text = "Players: --" })
InfoSub:AddLabel({ Text = "by exlumiaa1" })

InfoSub:AddDivider()
local opEggLabel = InfoSub:AddLabel({ Text = "Divine Egg: loading..." })

-- Ping/pos/health updater
task.spawn(function()
    local avgMs = 0
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        pcall(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                labelHealth:Set("Health: " .. ("%d/%d"):format(math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5)))
            end
            if hrp then
                local p = hrp.Position
                labelPos:Set(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
            end
            if hum then
                labelWS:Set("WalkSpeed: " .. ("%.1f"):format(hum.WalkSpeed))
                labelJP:Set("JumpPower: " .. ("%.1f"):format(hum.JumpPower))
            end
            local stats = game:GetService("Stats")
            local pingItem = stats.Network.ServerStatsItem["Data Ping"]
            avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
            labelPing:Set("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
            labelPlayers:Set("Players: " .. #Players:GetPlayers())

            local remaining, queued, enabled = getOpEggCountdown()
            if not enabled then
                opEggLabel:Set("Divine Egg: disabled")
            elseif queued then
                opEggLabel:Set("Divine Egg: NEXT RESTOCK!")
            elseif remaining and remaining > 0 then
                local m = math.floor(remaining / 60)
                local s = remaining % 60
                opEggLabel:Set(("Divine Egg: %dm %ds"):format(m, s))
            else
                opEggLabel:Set("Divine Egg: SPAWNED!")
            end
        end)
    end
end)

-- ======================== MAIN TAB ========================
local MainTab = Window:AddTab({ Name = "Main", Icon = "zap", Subtitle = "Farming" })
local FarmSub = MainTab:AddSubTab("Farm")
local MoveSub = MainTab:AddSubTab("Movement")
local TpSub = MainTab:AddSubTab("Teleport")
local GuardSub = MainTab:AddSubTab("Guard")

FarmSub:AddSection("Auto Train")
FarmSub:AddToggle({ Name = "Auto Squat Train", Default = Config.autoTrain, Flag = "jfa_train", Callback = function(s)
    Config.autoTrain = s
    if not s then pcall(stopTraining) end
end })
FarmSub:AddLabel({ Text = "Includes auto 2X bonus" })

FarmSub:AddDivider()

FarmSub:AddSection("Auto Collect Eggs")
FarmSub:AddToggle({ Name = "Auto Collect", Default = Config.autoCollect, Flag = "jfa_collect", Callback = function(s)
    Config.autoCollect = s
end })
FarmSub:AddDropdown({ Name = "Area", Options = AREAS, Default = Config.collectArea, Flag = "jfa_area", Callback = function(v)
    Config.collectArea = v
end })
FarmSub:AddSlider({ Name = "Collect Delay", Min = 1, Max = 20, Default = Config.collectDelay * 10, Suffix = "x0.1s", Flag = "jfa_collect_delay", Callback = function(v)
    Config.collectDelay = v / 10
end })
FarmSub:AddToggle({ Name = "Auto Place on Plot", Default = Config.autoPlace, Flag = "jfa_autoplace", Callback = function(s)
    Config.autoPlace = s
end })

MoveSub:AddSection("WalkSpeed")
MoveSub:AddToggle({ Name = "WalkSpeed", Default = Config.walkEnabled, Flag = "jfa_ws_toggle", Callback = function(s)
    Config.walkEnabled = s
    if not s then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = originalWalkSpeed end
    end
end })
MoveSub:AddSlider({ Name = "Speed", Min = 16, Max = 300, Default = Config.walkSpeed, Suffix = " studs/s", Flag = "jfa_ws_val", Callback = function(v)
    Config.walkSpeed = v
end })

MoveSub:AddDivider()

MoveSub:AddSection("JumpPower")
MoveSub:AddToggle({ Name = "Jump Power", Default = Config.jumpEnabled, Flag = "jfa_jp_toggle", Callback = function(s)
    Config.jumpEnabled = s
    if not s then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = originalJumpPower end
    end
end })
MoveSub:AddSlider({ Name = "Power", Min = 50, Max = 500, Default = Config.jumpPower, Suffix = " studs", Flag = "jfa_jp_val", Callback = function(v)
    Config.jumpPower = v
end })

GuardSub:AddSection("Guard")
GuardSub:AddToggle({ Name = "Guard Drop Block", Default = Config.guardDropBlock, Flag = "jfa_guard", Callback = function(s)
    Config.guardDropBlock = s
    if s then hookGuardDrop() end
end })

-- ======================== TELEPORT SUBTAB ========================
TpSub:AddSection("TP To Home")
TpSub:AddToggle({ Name = "TP To Home (Toggle Q)", Default = Config.tpToHome, Flag = "jfa_tphome", Callback = function(s)
    Config.tpToHome = s
    if s then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            homePosition = hrp.Position
        end
    end
end })
local homeLabel = TpSub:AddLabel({ Text = "Home: not set" })

TpSub:AddDivider()

TpSub:AddSection("Server Hop")
TpSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        Window:Notify({ Title = "Server Hop", Content = "Finding a new server...", Type = "info", Duration = 3 })
        task.spawn(function()
            local ok, err = pcall(serverHop)
            if not ok then
                Window:Notify({ Title = "Server Hop", Content = "Failed: " .. tostring(err), Type = "error", Duration = 5 })
            end
        end)
    end,
})

TpSub:AddDivider()

TpSub:AddSection("Teleport to Area")
local tpArea = "Meadow"
TpSub:AddDropdown({ Name = "Area", Options = TELEPORT_AREAS, Default = tpArea, Flag = "jfa_tparea", Callback = function(v)
    tpArea = v
end })
TpSub:AddButton({
    Name = "Teleport",
    Primary = false,
    Callback = function()
        local pos = AREA_POSITIONS[tpArea]
        if pos then teleportTo(pos) end
    end,
})

TpSub:AddDivider()
TpSub:AddSection("OP Egg Tracker")
TpSub:AddToggle({ Name = "Auto TP When Spawned", Default = Config.autoTpOpEgg, Flag = "jfa_opegg", Callback = function(s)
    Config.autoTpOpEgg = s
    opEggTpSent = false
end })

-- Home label updater
task.spawn(function()
    while true do
        task.wait(0.5)
        if rawget(_G, _G_TOMB) then break end
        if homeLabel then
            if homePosition then
                homeLabel:Set(("Home: %.0f, %.0f, %.0f"):format(homePosition.X, homePosition.Y, homePosition.Z))
            else
                homeLabel:Set("Home: not set")
            end
        end
    end
end)

-- ======================== SETTINGS TAB ========================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
local HopSub = SettingsTab:AddSubTab("Server Hop")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "jfa_config_selected",
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
    Flag = "jfa_config_name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            Window:Notify({ Title = "Config", Content = "Enter a name first!", Type = "warning", Duration = 3 })
            return
        end
        local ok = Library:SaveConfig(name)
        if ok then
            refreshConfigList()
            Window:Notify({ Title = "Config", Content = "Saved: " .. name, Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Config", Content = "Save failed!", Type = "error", Duration = 3 })
        end
    end,
})

ConfigSub:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({ Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3 })
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            Window:Notify({ Title = "Config", Content = "Loaded: " .. selectedConfig, Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Config", Content = "Failed to load!", Type = "error", Duration = 3 })
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({ Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3 })
            return
        end
        Library:DeleteConfig(selectedConfig)
        selectedConfig = ""
        refreshConfigList()
        Window:Notify({ Title = "Config", Content = "Deleted config.", Type = "info", Duration = 3 })
    end,
})

HopSub:AddSection("Server Hop")
HopSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        Window:Notify({ Title = "Server Hop", Content = "Finding a new server...", Type = "info", Duration = 3 })
        task.spawn(function()
            local ok, err = pcall(serverHop)
            if not ok then
                Window:Notify({ Title = "Server Hop", Content = "Failed: " .. tostring(err), Type = "error", Duration = 5 })
            end
        end)
    end,
})

-- ================================================================
-- CLEANUP
-- ================================================================
local function teardown()
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_ALIVE, nil)
    pcall(stopTraining)
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = originalWalkSpeed
            hum.JumpPower = originalJumpPower
        end
    end
    if Window and type(Window.Destroy) == "function" then
        pcall(function() Window:Destroy() end)
    end
end

if STATE and STATE.onCleanup then
    STATE.onCleanup(teardown)
end

-- Load last config on startup (after UI exists)
pcall(function() Library:LoadConfig("default") end)
