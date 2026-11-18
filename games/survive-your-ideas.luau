-- Survive Your Ideas â€” Auto Write / OP Word List
-- Game: 10769671316 (places 77900175935766 / 109001332046330)
-- Key system: Panda Auth (exlumiaa).

if tostring(game.GameId) ~= "10769671316" and tostring(game.PlaceId) ~= "77900175935766" and tostring(game.PlaceId) ~= "109001332046330" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

local GEN = (tonumber(getgenv().__ugcAutoWriteGen) or 0) + 1
getgenv().__ugcAutoWriteGen = GEN

local function stale()
    return tonumber(getgenv().__ugcAutoWriteGen) ~= GEN
end

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "UGCKeyGate") then gui:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        for _, gui in ipairs(pg and pg:GetChildren() or {}) do
            if gui:IsA("ScreenGui") and (gui.Name == "ExlumiaaHub" or gui.Name == "UGCKeyGate") then gui:Destroy() end
        end
    end)
end

-- ================================================================
-- KEY SYSTEM (Panda Auth) - same pattern as the other Exlumia Hub games
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_ugc.txt"
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
            brand = "Survive Your Ideas",
            guiName = "UGCKeyGate",
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

local WORDS = {
    "dragon", "blackhole", "supernova", "meteor", "asteroid", "comet", "nuke",
    "atomic", "hydrogen", "tsunami", "tornado", "hurricane", "earthquake",
    "volcano", "eruption", "lava", "magma", "blizzard", "thunderstorm",
    "lightning", "sandstorm", "acidrain", "flood", "wildfire", "apocalypse",
    "cataclysm", "armageddon", "doomsday", "extinction", "god", "titan",
    "leviathan", "kraken", "hydra", "phoenix", "grimreaper", "death", "void",
    "galaxy", "universe", "portal", "blackout", "eclipse", "singularity",
    "quantum", "antimatter", "plasma", "laser", "railgun", "mech", "robot",
    "cyborg", "alien", "ufo", "invasion", "army", "swarm", "clone", "giant",
    "colossus", "behemoth", "fortress", "shield", "forcefield", "medkit",
    "jetpack", "grappler", "timefreeze", "timestop", "freeze", "iceage",
    "inferno", "hellfire", "firestorm", "storm", "cyclone", "twister",
    "quake", "sinkhole", "avalanche", "landslide", "monsoon", "typhoon",
    "waterspout", "whirlpool", "maelstrom", "abyss", "nightmare", "shadow",
    "demon", "angel", "spirit", "zombie", "vampire", "werewolf", "dinosaur",
    "trex", "raptor", "megalodon", "sharknado", "piranha",
}

local function clean(word)
    local s = tostring(word or "")
    s = s:gsub("%s+", "")
    s = s:sub(1, 20)
    return s
end

local LobbyRemotes = ReplicatedStorage:FindFirstChild("LobbyRemotes")
local SuggestWord = LobbyRemotes and LobbyRemotes:FindFirstChild("SuggestWord")
local WriterRemotes = ReplicatedStorage:FindFirstChild("WriterRemotes")
local SubmitWord = WriterRemotes and WriterRemotes:FindFirstChild("SubmitWord")

local function remote(path)
    local node = ReplicatedStorage
    for _, part in ipairs(path) do
        node = node and node:FindFirstChild(part)
        if not node then return nil end
    end
    return node
end

local ItemsReq = remote({"Items", "Remotes", "Request"})
local MasteryReq = remote({"Mastery", "Remotes", "Request"})
local MetaReq = remote({"MetaWords", "Remotes", "Request"})
local CodesRedeem = remote({"Codes", "Redeem"})
local GroupReward = remote({"LobbyRemotes", "GroupReward"})
local SetSprint = remote({"SprintRemotes", "SetSprint"})

local function sendChat(word)
    local channels = TextChatService:FindFirstChild("TextChannels")
    local general = channels and channels:FindFirstChild("RBXGeneral")
    if not general then return false, "No chat channel" end
    local ok, err = pcall(function() return general:SendAsync(word) end)
    return ok, ok and "sent" or tostring(err)
end

local function sendSuggest(word)
    if SuggestWord then
        local ok, res = pcall(function() return SuggestWord:InvokeServer(word) end)
        return ok and res == "ok", tostring(res)
    end
    if SubmitWord then
        local ok, err = pcall(function() SubmitWord:FireServer(word) end)
        return ok, ok and "sent" or tostring(err)
    end
    return false, "No suggest remote"
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

Library.ConfigFolder = "exlumiaa/ugc"

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Survive Your Ideas: Auto Write",
    Size = UDim2.fromOffset(500, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Survive Your Ideas",
    LoadingFooter = "Auto Write",
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

local Tab = Window:AddTab({Name = "Words", Icon = "pencil", Subtitle = "Auto Write"})
local Sub = Tab:AddSubTab("Send")

Sub:AddSection("OP Word")
local selected = WORDS[1]

local customInput = Sub:AddInput({
    Name = "Custom Word",
    Default = "",
    Placeholder = "Type a word (overrides dropdown)",
    Flag = "ugc_custom_word",
})

local status = Sub:AddLabel({Text = "Ready."})

local method = "Chat"
Sub:AddDropdown({
    Name = "Method",
    Options = {"Chat", "Suggest", "Chat + Suggest"},
    Default = "Chat",
    Flag = "ugc_method",
    Callback = function(v) method = v end,
})

local function getInput()
    local ok, text = pcall(function() return customInput:Get() end)
    if ok and text and text ~= "" then return clean(text) end
    return nil
end

local function doSend(word, silent)
    word = clean(word)
    if word == "" then return false, "Empty word" end
    local results = {}
    if method == "Chat" or method == "Chat + Suggest" then
        local ok, msg = sendChat(word)
        table.insert(results, "chat:" .. tostring(msg))
        if not silent then
            status:Set("Sent to chat: " .. word .. " (" .. tostring(msg) .. ")")
        end
        if not ok and method == "Chat" then return false, table.concat(results, " | ") end
    end
    if method == "Suggest" or method == "Chat + Suggest" then
        local ok, msg = sendSuggest(word)
        table.insert(results, "suggest:" .. tostring(msg))
        if not silent then
            status:Set("Suggested: " .. word .. " (" .. tostring(msg) .. ")")
        end
        if not ok and method == "Suggest" then return false, table.concat(results, " | ") end
    end
    return true, table.concat(results, " | ")
end

local nextWord

Sub:AddButton({
    Name = "Send Word",
    Primary = true,
    Callback = function()
        local word = getInput() or nextWord()
        local ok, msg = doSend(word)
        if not ok then status:Set("Failed: " .. tostring(msg)) end
    end,
})

Sub:AddButton({
    Name = "Suggest Word",
    Callback = function()
        local word = getInput() or nextWord()
        local ok, msg = sendSuggest(word)
        status:Set((ok and "Suggested: " or "Suggest failed: ") .. word .. " (" .. tostring(msg) .. ")")
    end,
})

Sub:AddSection("Auto Write")
local autoOn = false
local autoToken = 0
local interval = 2
local cycle = true
local randomMode = false
local index = 1

nextWord = function()
    if randomMode then
        return WORDS[math.random(1, #WORDS)]
    end
    if not cycle then
        return getInput() or selected
    end
    local word = WORDS[index]
    index = index % #WORDS + 1
    return word
end

local function setAuto(on)
    autoOn = on
    autoToken = autoToken + 1
    local my = autoToken
    if not on then
        status:Set("Auto write stopped.")
        return
    end
    status:Set("Auto write started.")
    task.spawn(function()
        task.wait(0.5)
        while autoOn and autoToken == my and not stale() do
            local word = nextWord()
            local ok, msg = doSend(word, true)
            status:Set((ok and "Auto: " or "Auto failed: ") .. tostring(word) .. " (" .. tostring(msg) .. ")")
            task.wait(interval)
        end
    end)
end

Sub:AddToggle({
    Name = "Auto Write",
    Flag = "ugc_auto",
    Default = false,
    Callback = function(v) setAuto(v) end,
})

Sub:AddSlider({
    Name = "Interval",
    Min = 1,
    Max = 10,
    Default = 2,
    Suffix = " s",
    Flag = "ugc_interval",
    Callback = function(v) interval = v end,
})

Sub:AddToggle({
    Name = "Cycle Words",
    Flag = "ugc_cycle",
    Default = true,
    Callback = function(v) cycle = v end,
})

Sub:AddToggle({
    Name = "Random Word",
    Flag = "ugc_random",
    Default = false,
    Callback = function(v) randomMode = v end,
})

local SurvivalTab = Window:AddTab({Name = "Survival", Icon = "shield", Subtitle = "God Mode"})
local SurvivalSub = SurvivalTab:AddSubTab("Health")

local godOn = false
local godToken = 0

local function setGod(on)
    godOn = on
    godToken = godToken + 1
    local my = godToken
    if not on then return end
    task.spawn(function()
        while godOn and godToken == my and not stale() do
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = 1e9
                hum.Health = 1e9
            end
            task.wait(0.2)
        end
    end)
end

SurvivalSub:AddSection("Health")
SurvivalSub:AddToggle({
    Name = "God Mode",
    Flag = "ugc_god",
    Default = false,
    Callback = function(v) setGod(v) end,
})
local FarmTab = Window:AddTab({Name = "Farm", Icon = "hammer", Subtitle = "Auto"})
local FarmSub = FarmTab:AddSubTab("Items")

local function cash()
    local ls = LP:FindFirstChild("leaderstats")
    local c = ls and ls:FindFirstChild("Cash")
    return c and tonumber(c.Value) or 0
end

local function afterReserve(pct)
    local c = cash()
    return c - c * (pct / 100)
end

local spinOn = false
local spinToken = 0
local spinInterval = 3
local spinReserve = 0

local function setSpin(on)
    spinOn = on
    spinToken = spinToken + 1
    local my = spinToken
    if not on then return end
    task.spawn(function()
        while spinOn and spinToken == my and not stale() do
            if ItemsReq and afterReserve(spinReserve) >= 10000 then
                pcall(function() ItemsReq:InvokeServer("spin") end)
            end
            task.wait(spinInterval)
        end
    end)
end

FarmSub:AddSection("Item Spin")
FarmSub:AddToggle({
    Name = "Auto Spin",
    Flag = "ugc_spin",
    Default = false,
    Callback = function(v) setSpin(v) end,
})
FarmSub:AddSlider({
    Name = "Spin Interval",
    Min = 1,
    Max = 15,
    Default = 3,
    Suffix = " s",
    Flag = "ugc_spin_interval",
    Callback = function(v) spinInterval = v end,
})
FarmSub:AddSlider({
    Name = "Cash Reserve",
    Min = 0,
    Max = 90,
    Default = 0,
    Suffix = " %",
    Flag = "ugc_spin_reserve",
    Callback = function(v) spinReserve = v end,
})

local MASTERY_IDS = {"tornado", "tsunami", "nuke", "black_hole", "monster", "dinosaur", "gojo", "hero", "earthquake", "kill"}

local function claimMastery()
    if not MasteryReq then return false, "No mastery remote" end
    for _, id in ipairs(MASTERY_IDS) do
        pcall(function() MasteryReq:InvokeServer("claim", id) end)
        task.wait(0.2)
    end
    return true
end

local masteryOn = false
local masteryToken = 0

local function setMastery(on)
    masteryOn = on
    masteryToken = masteryToken + 1
    local my = masteryToken
    if not on then return end
    task.spawn(function()
        while masteryOn and masteryToken == my and not stale() do
            if (tonumber(LP:GetAttribute("MasteryReady")) or 0) > 0 then
                claimMastery()
            end
            task.wait(20)
        end
    end)
end

FarmSub:AddSection("Mastery")
FarmSub:AddToggle({
    Name = "Auto Claim Mastery",
    Flag = "ugc_mastery",
    Default = false,
    Callback = function(v) setMastery(v) end,
})
FarmSub:AddButton({
    Name = "Claim Mastery Now",
    Callback = function()
        local ok, err = claimMastery()
        status:Set(ok and "Mastery claims sent." or ("Mastery: " .. tostring(err)))
    end,
})

local META_WORDS = {
    {id = "double", cost = 250000},
    {id = "secret", cost = 250000},
    {id = "lag", cost = 400000},
    {id = "undo", cost = 400000},
    {id = "ghost", cost = 500000},
    {id = "jackpot", cost = 750000},
}
local metaOn = false
local metaToken = 0
local metaReserve = 0

local function buyMeta()
    if not MetaReq then return false, "No meta remote" end
    for _, w in ipairs(META_WORDS) do
        if afterReserve(metaReserve) >= w.cost then
            pcall(function() MetaReq:InvokeServer("buy", w.id) end)
            task.wait(0.3)
        end
    end
    return true
end

local function setMeta(on)
    metaOn = on
    metaToken = metaToken + 1
    local my = metaToken
    if not on then return end
    task.spawn(function()
        while metaOn and metaToken == my and not stale() do
            buyMeta()
            task.wait(10)
        end
    end)
end

FarmSub:AddSection("Meta Words (Cash)")
FarmSub:AddToggle({
    Name = "Auto Buy Cash Words",
    Flag = "ugc_meta",
    Default = false,
    Callback = function(v) setMeta(v) end,
})
FarmSub:AddSlider({
    Name = "Meta Cash Reserve",
    Min = 0,
    Max = 90,
    Default = 0,
    Suffix = " %",
    Flag = "ugc_meta_reserve",
    Callback = function(v) metaReserve = v end,
})
FarmSub:AddButton({
    Name = "Buy Cash Words Now",
    Callback = function()
        local ok, err = buyMeta()
        status:Set(ok and "Meta word buys sent." or ("Meta: " .. tostring(err)))
    end,
})

FarmSub:AddSection("Codes")
local codesInput = FarmSub:AddInput({
    Name = "Codes (comma separated)",
    Default = "",
    Placeholder = "code1, code2",
    Flag = "ugc_codes",
})
FarmSub:AddButton({
    Name = "Redeem Codes",
    Callback = function()
        if not CodesRedeem then status:Set("No Codes.Redeem remote.") return end
        local text = codesInput:Get() or ""
        local n = 0
        for code in string.gmatch(text, "[^,%s]+") do
            pcall(function() CodesRedeem:InvokeServer(code) end)
            n = n + 1
            task.wait(0.4)
        end
        status:Set("Redeemed " .. n .. " code(s).")
    end,
})

local UtilTab = Window:AddTab({Name = "Utility", Icon = "settings", Subtitle = "QoL"})
local UtilSub = UtilTab:AddSubTab("Character")

local sprintOn = false
local function setSprint(on)
    sprintOn = on
    if SetSprint then pcall(function() SetSprint:FireServer(on) end) end
end

UtilSub:AddSection("Movement")
UtilSub:AddToggle({
    Name = "Auto Sprint",
    Flag = "ugc_sprint",
    Default = false,
    Callback = function(v) setSprint(v) end,
})

local stamOn = false
local stamToken = 0
local function setStamina(on)
    stamOn = on
    stamToken = stamToken + 1
    local my = stamToken
    if not on then return end
    task.spawn(function()
        while stamOn and stamToken == my and not stale() do
            pcall(function() LP:SetAttribute("Stamina", 100) end)
            RunService.RenderStepped:Wait()
        end
    end)
end
UtilSub:AddToggle({
    Name = "Infinite Stamina",
    Flag = "ugc_stamina",
    Default = false,
    Callback = function(v) setStamina(v) end,
})

local afkOn = false
local afkConn = nil
local function setAfk(on)
    afkOn = on
    if afkConn then afkConn:Disconnect(); afkConn = nil end
    if on then
        afkConn = LP.Idled:Connect(function()
            if not afkOn or stale() then return end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end
end

UtilSub:AddSection("Session")
UtilSub:AddToggle({
    Name = "Anti-AFK",
    Flag = "ugc_afk",
    Default = false,
    Callback = function(v) setAfk(v) end,
})
UtilSub:AddButton({
    Name = "Claim Group Reward",
    Callback = function()
        if not GroupReward then status:Set("No GroupReward remote.") return end
        local ok, res = pcall(function() return GroupReward:InvokeServer("claim") end)
        status:Set(ok and ("Group reward: " .. tostring(res)) or ("Group reward failed: " .. tostring(res)))
    end,
})
UtilSub:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(game.JobId), LP) end)
    end,
})
UtilSub:AddButton({
    Name = "Server Hop",
    Callback = function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end,
})

pcall(function() Library:LoadConfig("default") end)

local function getState()
    return {
        auto = autoOn,
        interval = interval,
        method = method,
        random = randomMode,
        god = godOn,
        spin = spinOn,
        mastery = masteryOn,
        meta = metaOn,
        sprint = sprintOn,
        stamina = stamOn,
        afk = afkOn,
    }
end

getgenv()._ugcAutoWrite = {
    words = WORDS,
    sendChat = sendChat,
    sendSuggest = sendSuggest,
    doSend = doSend,
    state = { auto = autoOn, interval = interval, method = method, random = randomMode, god = godOn, spin = spinOn, mastery = masteryOn, meta = metaOn, sprint = sprintOn, stamina = stamOn, afk = afkOn },
    getState = getState,
    setGod = setGod,
    setRandom = function(v) randomMode = v end,
    nextWord = nextWord,
    setSpin = setSpin,
    setMastery = setMastery,
    claimMastery = claimMastery,
    setMeta = setMeta,
    buyMeta = buyMeta,
    setSprint = setSprint,
    setStamina = setStamina,
    setAfk = setAfk,
}

print("[ExlumiaaHub] Survive Your Ideas Auto Write loaded")
