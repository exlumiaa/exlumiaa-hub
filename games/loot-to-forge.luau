if tostring(game.GameId) ~= "10684750879" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _lfHubTomb9"
local _G_ALIVE = "_ _lfHubAlive9"
local _G_GEN = "_ _lfHubGen9"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
    rawset(_G, _G_GEN, (tonumber(rawget(_G, _G_GEN)) or 0) + 1)
end
local MY_GEN = tonumber(rawget(_G, _G_GEN))

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


-- ================================================================
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_lootforge.txt"
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
            brand = "+1 Loot To Forge",
            guiName = "LootForgeKeyGate",
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

local function isTomb()
    return rawget(_G, _G_TOMB) == true or tonumber(rawget(_G, _G_GEN)) ~= MY_GEN
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

Library.ConfigFolder = "exlumiaa"

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

local function safeRequire(path)
    local obj = ReplicatedStorage
    for part in path:gmatch("[^.]+") do
        obj = obj:FindFirstChild(part)
        if not obj then return nil end
    end
    local ok, res = pcall(require, obj)
    return ok and res or nil
end

local CU = safeRequire("Utils.CommunicationUtils")
if not CU then return end

local function remE(cat, name)
    local ok, res = pcall(CU.TryGetRemoteEvent, cat, name)
    return ok and res or nil
end

local function remF(cat, name)
    local ok, res = pcall(CU.TryGetRemoteFunction, cat, name)
    return ok and res or nil
end

local function bindE(cat, name)
    local ok, res = pcall(CU.TryGetBindableEvent, cat, name)
    return ok and res or nil
end

local ForgeRF = remF("Forge", "ForgeRF")
local RebirthRE = remE("Rebirth", "TryRebirthRE")
local OfflineRE = remE("Offline", "TryClaimOfflineRewardRE")
local CodeRF = remF("Code", "TryUseCodeRF")
local ATKOnceBE = bindE("Attack", "ATKOnceBE")

local TrainCTRL = safeRequire("CTRL.TrainCTRL")
local TrainAreaHelper = safeRequire("Config.TrainArea.Helper")
local RebirthHelper = safeRequire("Config.Rebirth.Helper")
local UpgradeHelper = safeRequire("Config.Upgrade.Helper")
local UpgradeData = safeRequire("LocalData.UpgradeData")
local BackpackData = safeRequire("LocalData.BackpackData")
local DungeonData = safeRequire("LocalData.DungeonData")
local OnlineData = safeRequire("LocalData.OnlineData")
local PotionData = safeRequire("LocalData.PotionData")
local PemData = safeRequire("LocalData.PemData")
local LeftInfoGUI = safeRequire("GuiUtils.LeftInfoGUI")
local CFrameUtils = safeRequire("Utils.CFrameUtils")
local PotionConfig = safeRequire("Config.Potion.Config")
local OnlineReward = safeRequire("Config.Online.Reward")
local DamageUtils = safeRequire("SkillSystemNew.Utils.DamageUtils")

local Eco = LP:WaitForChild("Eco", 10)

local function ecoVal(name)
    if not Eco then return 0 end
    local v = Eco:FindFirstChild(name)
    if v then return v.Value or 0 end
    return 0
end

local Config = {
    autoTrain = false,
    autoOre = false,
    autoForge = false,
    forgeType = "Weapon",
    autoDungeon = false,
    autoRebirth = false,
    autoUpgrade = false,
    autoSell = false,
    sellOres = false,
    claimOnline = false,
    claimOffline = false,
    claimDaily = false,
    redeemCodes = false,
    autoPotion = false,
    atk360 = false,
    atkRadius = 25,
}

local forgeNext = 0
local dungeonNext = 0
local rebirthNext = 0
local offlineNext = 0
local dailyNext = 0
local nextCodeAttempt = 0
local claimPending = nil
local lastClaimAction = 0
local potionNext = {}
local heldPrompts = setmetatable({}, { __mode = "k" })

if DamageUtils and type(DamageUtils.AOEDamage_Self) == "function" then
    local origKey = "_ _lfAtkOrig"
    local orig = rawget(_G, origKey)
    if type(orig) ~= "function" then
        orig = DamageUtils.AOEDamage_Self
        rawset(_G, origKey, orig)
    end
    DamageUtils.AOEDamage_Self = function(c, skillName, phase, cfg, extra)
        if Config.atk360 and type(skillName) == "string" and skillName:find("ATK", 1, true) and type(cfg) == "table" then
            local r = tonumber(Config.atkRadius) or 25
            if r < 5 then r = 5 end
            cfg = {
                Size = Vector3.new(r * 2, r * 2, r * 2),
                Shape = Enum.PartType.Ball,
                Offset = Vector3.new(0, 0, 0),
                Scale = 1,
            }
        end
        return orig(c, skillName, phase, cfg, extra)
    end
end

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "+1 Loot To Forge",
    Size = UDim2.fromOffset(540, 460),
    Scale = 1.2,
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 Loot To Forge",
    LoadingFooter = "by Exlumiaa Hub",
    GuiName = "ExlumiaaHub",
    Logo = 72522294315389,
})

local function notify(title, content, ntype)
    pcall(function()
        Window:Notify({ Title = title, Content = content, Type = ntype or "info", Duration = 3 })
    end)
end

local function bestTrainArea()
    if not TrainAreaHelper then return 1 end
    local rebirth = ecoVal("rebirth")
    local best = 1
    for id = 1, 11 do
        local ok, need = pcall(TrainAreaHelper.GetNeedRebirth, id)
        if ok and need and rebirth >= need then
            local allowed = true
            if id >= 9 then
                local okP, pem = false, false
                if PemData and PemData.isHavePem then
                    okP, pem = pcall(PemData.isHavePem, "AutoTrainArea_" .. id)
                end
                allowed = okP and pem and true or false
            end
            if allowed then best = id end
        end
    end
    return best
end

local HomeTab = Window:AddTab({ Name = "Home", Icon = "home", Subtitle = "Info" })
local HomeSub = HomeTab:AddSubTab("Info")
autosaveWrap(HomeSub)

HomeSub:AddSection("Stats")
local labelCoin = HomeSub:AddLabel({ Text = "Coin: --" })
local labelLevel = HomeSub:AddLabel({ Text = "Level: --" })
local labelRebirth = HomeSub:AddLabel({ Text = "Rebirth: --" })
local labelOre = HomeSub:AddLabel({ Text = "Ore Pack: --" })

HomeSub:AddSection("Status")
local labelDungeon = HomeSub:AddLabel({ Text = "Dungeon: Idle" })
local labelTrain = HomeSub:AddLabel({ Text = "Train: Off" })

HomeSub:AddSection("Server")
HomeSub:AddButton({
    Name = "Copy JobId",
    Callback = function()
        pcall(setclipboard, tostring(game.JobId))
        notify("Copied", "JobId copied!", "success")
    end,
})

local FarmTab = Window:AddTab({ Name = "Farm", Icon = "pickaxe", Subtitle = "Train & Ore" })
local FarmSub = FarmTab:AddSubTab("Features")
autosaveWrap(FarmSub)

FarmSub:AddSection("Training")
FarmSub:AddToggle({
    Name = "Auto Train",
    Flag = "lf_auto_train",
    Default = false,
    Callback = function(v)
        Config.autoTrain = v
        if not v then
            pcall(function() LP:SetAttribute("AutoTrainAreaID", nil) end)
        end
    end,
})
FarmSub:AddLabel({ Text = "Automatically picks the best area for your rebirth" })

FarmSub:AddSection("Ore & Forge")
FarmSub:AddToggle({
    Name = "Auto Collect Ore",
    Flag = "lf_auto_ore",
    Default = false,
    Callback = function(v) Config.autoOre = v end,
})
FarmSub:AddToggle({
    Name = "Auto Forge",
    Flag = "lf_auto_forge",
    Default = false,
    Callback = function(v) Config.autoForge = v end,
})
local forgeDropdown = FarmSub:AddDropdown({
    Name = "Forge Type",
    Options = { "Weapon", "Armor" },
    Default = Config.forgeType,
    Flag = "lf_forge_type",
    Callback = function(v)
        if v == "Weapon" or v == "Armor" then Config.forgeType = v end
    end,
})
FarmSub:AddLabel({ Text = "Forge runs when you have 4+ ores" })

FarmSub:AddSection("Attack")
FarmSub:AddToggle({
    Name = "360Ã‚Â° Wide Attack",
    Flag = "lf_atk_360",
    Default = false,
    Callback = function(v) Config.atk360 = v end,
})
FarmSub:AddSlider({
    Name = "Attack Radius",
    Min = 10,
    Max = 100,
    Default = 25,
    Suffix = " studs",
    Flag = "lf_atk_radius",
    Callback = function(v) Config.atkRadius = v end,
})
FarmSub:AddLabel({ Text = "Hits in every direction around your character" })

local DungeonTab = Window:AddTab({ Name = "Dungeon", Icon = "swords", Subtitle = "Combat" })
local DungeonSub = DungeonTab:AddSubTab("Features")
autosaveWrap(DungeonSub)

DungeonSub:AddSection("Dungeon")
DungeonSub:AddToggle({
    Name = "Auto Dungeon",
    Flag = "lf_auto_dungeon",
    Default = false,
    Callback = function(v) Config.autoDungeon = v end,
})
DungeonSub:AddToggle({
    Name = "Auto Claim Daily Ticket",
    Flag = "lf_claim_daily",
    Default = false,
    Callback = function(v) Config.claimDaily = v end,
})
DungeonSub:AddLabel({ Text = "Enters the latest round automatically + auto attack" })

local ProgressTab = Window:AddTab({ Name = "Progress", Icon = "trending-up", Subtitle = "Growth" })
local ProgressSub = ProgressTab:AddSubTab("Features")
autosaveWrap(ProgressSub)

ProgressSub:AddSection("Rebirth")
ProgressSub:AddToggle({
    Name = "Auto Rebirth",
    Flag = "lf_auto_rebirth",
    Default = false,
    Callback = function(v) Config.autoRebirth = v end,
})

ProgressSub:AddSection("Upgrades")
ProgressSub:AddToggle({
    Name = "Auto Buy Upgrades",
    Flag = "lf_auto_upgrade",
    Default = false,
    Callback = function(v) Config.autoUpgrade = v end,
})
ProgressSub:AddLabel({ Text = "Buys Luck / OrePack / Train while coin is enough" })

ProgressSub:AddSection("Sell")
ProgressSub:AddToggle({
    Name = "Auto Sell Gear",
    Flag = "lf_auto_sell",
    Default = false,
    Callback = function(v) Config.autoSell = v end,
})
ProgressSub:AddToggle({
    Name = "Auto Sell Ores",
    Flag = "lf_sell_ores",
    Default = false,
    Callback = function(v) Config.sellOres = v end,
})
ProgressSub:AddLabel({ Text = "Materials (tickets) are never sold" })

local RewardsTab = Window:AddTab({ Name = "Rewards", Icon = "gift", Subtitle = "Claim" })
local RewardsSub = RewardsTab:AddSubTab("Features")
autosaveWrap(RewardsSub)

RewardsSub:AddSection("Claims")
RewardsSub:AddToggle({
    Name = "Auto Claim Online Reward",
    Flag = "lf_claim_online",
    Default = false,
    Callback = function(v) Config.claimOnline = v end,
})
RewardsSub:AddToggle({
    Name = "Auto Claim Offline Reward",
    Flag = "lf_claim_offline",
    Default = false,
    Callback = function(v) Config.claimOffline = v end,
})
RewardsSub:AddToggle({
    Name = "Auto Redeem Codes",
    Flag = "lf_redeem_codes",
    Default = false,
    Callback = function(v) Config.redeemCodes = v end,
})

RewardsSub:AddSection("Potion")
RewardsSub:AddToggle({
    Name = "Auto Use Potion",
    Flag = "lf_auto_potion",
    Default = false,
    Callback = function(v) Config.autoPotion = v end,
})

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")
autosaveWrap(ConfigSub)

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "lf_config_selected",
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
    Flag = "lf_config_name",
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
ConfigSub:AddLabel({ Text = "by Exlumiaa Hub" })
ConfigSub:AddLabel({ Text = "Toggle Menu: RightShift" })

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

local function trainSync()
    if not Config.autoTrain then return end
    local want = bestTrainArea()
    local cur = LP:GetAttribute("AutoTrainAreaID")
    local running = false
    if TrainCTRL then
        local okR, r = pcall(TrainCTRL.GetIsAutoing)
        running = okR and r or false
    end
    if cur == want and running then return end
    local okArea = false
    pcall(function()
        local f1 = workspace:FindFirstChild("CanAttackFolder")
        local f2 = f1 and f1:FindFirstChild("TrainArea")
        okArea = f2 ~= nil and f2:FindFirstChild("Train_" .. want) ~= nil
    end)
    if not okArea then return end
    if cur ~= nil then
        pcall(function() LP:SetAttribute("AutoTrainAreaID", nil) end)
        task.wait(0.1)
    end
    pcall(function() LP:SetAttribute("AutoTrainAreaID", want) end)
end

local function oreTick()
    if not Config.autoOre or not LeftInfoGUI then return end
    local okP, pack = pcall(LeftInfoGUI.GetOrePack)
    local okM, cap = pcall(UpgradeData.GetMaxNum, "OrePack")
    if okP and okM and pack and cap and cap > 0 and pack >= cap then return end
    local oc = workspace:FindFirstChild("OreCache")
    if not oc then return end
    local now = tick()
    for _, d in ipairs(oc:GetDescendants()) do
        if d:IsA("ProximityPrompt") and now >= (heldPrompts[d] or 0) then
            heldPrompts[d] = now + 1.5
            pcall(function()
                d.MaxDistance = 9999
                d:InputHoldBegin()
            end)
            task.delay(0.6, function()
                pcall(function() d:InputHoldEnd() end)
            end)
        end
    end
end

local function forgeTick()
    if not Config.autoForge or not ForgeRF then return end
    local now = tick()
    if now < forgeNext then return end
    local okD, data = pcall(BackpackData.GetData)
    if not okD or not data or not data.have then return end
    local stacks = {}
    for uuid, item in pairs(data.have) do
        if item.Type == "Ore" then
            stacks[#stacks + 1] = { uuid = uuid, n = tonumber(item.Number) or 1 }
        end
    end
    if #stacks == 0 then
        forgeNext = now + 3
        return
    end
    table.sort(stacks, function(a, b) return a.n > b.n end)
    local list, total = {}, 0
    for i = 1, math.min(#stacks, 4) do
        list[stacks[i].uuid] = stacks[i].n
        total = total + stacks[i].n
    end
    if total < 4 then
        forgeNext = now + 3
        return
    end
    local ok, res = pcall(function()
        return ForgeRF:InvokeServer({ ConfigType = Config.forgeType, UUIDList = list })
    end)
    if ok and res then
        forgeNext = now + 3
        notify("Forge", "Forged " .. Config.forgeType .. "!", "success")
    else
        forgeNext = now + 2
    end
end

local function dungeonEnter()
    if not Config.autoDungeon or not DungeonData then return end
    if LP:GetAttribute("Dungeoning") then return end
    local now = tick()
    if now < dungeonNext then return end
    dungeonNext = now + 6
    local round = 1
    pcall(function() round = DungeonData.GetMaxRound() + 1 end)
    local ok, res = pcall(DungeonData.TryIntoDungeon, round)
    if ok and res then
        notify("Dungeon", "Entered round " .. tostring(round), "success")
    end
end

local function dungeonCombat()
    if not Config.autoDungeon then return end
    if not LP:GetAttribute("Dungeoning") then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end
    local best, bestPivot = nil, nil
    pcall(function()
        local ef = workspace:FindFirstChild("EnemyFolder")
        if not ef then return end
        for _, e in ipairs(ef:GetChildren()) do
            if not e:GetAttribute("Dead") then
                local pp = e.PrimaryPart
                if pp then
                    local d = (pp.Position - hrp.Position).Magnitude
                    if not best or d < best then
                        best = d
                        if e:IsA("Model") then
                            bestPivot = e:GetPivot()
                        else
                            bestPivot = CFrame.new(pp.Position)
                        end
                    end
                end
            end
        end
    end)
    if not bestPivot then return end
    if CFrameUtils then
        pcall(function()
            char:PivotTo(CFrameUtils.FaceToCF(char:GetPivot(), bestPivot))
        end)
    end
    if best and best > 10 then
        pcall(function() hum:MoveTo(bestPivot.Position) end)
    end
    if ATKOnceBE then
        pcall(function() ATKOnceBE:Fire() end)
    end
end

local function rebirthTick()
    if not Config.autoRebirth or not RebirthHelper or not RebirthRE then return end
    local now = tick()
    if now < rebirthNext then return end
    local rebirth = ecoVal("rebirth")
    local level = ecoVal("level")
    local okM, isMax = pcall(RebirthHelper.CheckIsMax, rebirth)
    if okM and isMax then return end
    local okN, need = pcall(RebirthHelper.GetNeedLevel, rebirth + 1)
    if okN and need and need > 0 and level >= need then
        pcall(function() RebirthRE:FireServer() end)
        rebirthNext = now + 3
        notify("Rebirth", "Rebirth triggered!", "success")
    end
end

local upgradeIds = { "Luck", "OrePack", "Train" }

local function upgradeTick()
    if not Config.autoUpgrade or not UpgradeData or not UpgradeHelper then return end
    local coin = ecoVal("coin")
    for _, id in ipairs(upgradeIds) do
        local okL, level = pcall(UpgradeData.GetLevel, id)
        if okL and level then
            local okM, isMax = pcall(UpgradeHelper.CheckIsMax, id, level)
            if not (okM and isMax) then
                local okP, price = pcall(UpgradeHelper.GetPrice, id, level + 1)
                if okP and price and price > 0 and coin >= price then
                    pcall(UpgradeData.UpgradeOnce, id)
                    return
                end
            end
        end
    end
end

local function sellTick()
    if not Config.autoSell and not Config.sellOres then return end
    if not BackpackData then return end
    local okD, data = pcall(BackpackData.GetData)
    if not okD or not data or not data.have then return end
    for uuid, item in pairs(data.have) do
        local typ = item.Type
        local sell
        if typ == "Ore" then
            sell = Config.sellOres
        else
            sell = Config.autoSell and typ ~= "Material"
        end
        if sell then
            local okE, equipped = pcall(BackpackData.IsEquipedUUID, uuid)
            if not (okE and equipped) then
                pcall(BackpackData.TrySellItem, uuid, 9999)
                return
            end
        end
    end
end

local CODES = { "30000CCU", "20000CCU", "50000CCU" }
local codeQueue = {}

local function claimsTick()
    local now = tick()
    if claimPending then
        if claimPending.kind == "online" then
            local okD, data = pcall(OnlineData.GetData)
            local acked = okD and type(data) == "table" and data.Reward
                and (data.Reward[claimPending.key] or data.Reward[tostring(claimPending.key)])
            if acked then
                claimPending = nil
            elseif now >= claimPending.deadline then
                claimPending = nil
            else
                return
            end
        elseif claimPending.kind == "daily" then
            local ok, claimed = pcall(DungeonData.CheckTodayClaimed)
            if ok and claimed then
                claimPending = nil
            elseif now >= claimPending.deadline or not ok then
                claimPending = nil
            else
                return
            end
        else
            claimPending = nil
        end
    end
    if now - lastClaimAction < 0.4 then return end
    if Config.claimOnline and OnlineData and OnlineReward then
        local okD, data = pcall(OnlineData.GetData)
        local okT, times = pcall(OnlineData.GetOnlineTimes)
        if okD and okT and type(data) == "table" then
            local bestKey, bestN = nil, math.huge
            for key, cfg in pairs(OnlineReward) do
                local claimed = data.Reward and (data.Reward[key] or data.Reward[tostring(key)])
                if not claimed and times >= (tonumber(cfg.Time) or 0) then
                    local n = tonumber(key)
                    if n and n < bestN then
                        bestKey, bestN = key, n
                    end
                end
            end
            if bestKey then
                pcall(OnlineData.TryClaim, bestKey)
                claimPending = { kind = "online", key = bestKey, deadline = now + 4 }
                lastClaimAction = now
                return
            end
        end
    end
    if Config.claimOffline and OfflineRE and now >= offlineNext then
        offlineNext = now + 60
        lastClaimAction = now
        pcall(function() OfflineRE:FireServer() end)
        return
    end
    if Config.claimDaily and DungeonData and now >= dailyNext then
        dailyNext = now + 30
        lastClaimAction = now
        local ok, claimed = pcall(DungeonData.CheckTodayClaimed)
        if ok and not claimed then
            pcall(DungeonData.TryClaimDailyDunTic)
            claimPending = { kind = "daily", deadline = now + 4 }
        end
        return
    end
    if Config.redeemCodes and CodeRF and now >= nextCodeAttempt then
        if #codeQueue == 0 then
            for i = #CODES, 1, -1 do
                table.insert(codeQueue, CODES[i])
            end
        end
        local code = table.remove(codeQueue)
        pcall(CodeRF.InvokeServer, CodeRF, code)
        if #codeQueue == 0 then
            nextCodeAttempt = now + 120
        else
            nextCodeAttempt = now + 0.6
        end
        lastClaimAction = now
        return
    end
    if Config.autoPotion and PotionConfig and PotionData then
        for name in pairs(PotionConfig) do
            if now >= (potionNext[name] or 0) then
                potionNext[name] = now + 280
                lastClaimAction = now
                pcall(PotionData.UsePotion, name, 1)
                return
            end
        end
    end
end

task.spawn(function()
    while not isTomb() do
        pcall(trainSync)
        pcall(forgeTick)
        pcall(dungeonEnter)
        pcall(rebirthTick)
        pcall(upgradeTick)
        pcall(sellTick)
        pcall(claimsTick)
        pcall(function()
            labelCoin:Set("Coin: " .. tostring(math.floor(ecoVal("coin"))))
            labelLevel:Set("Level: " .. tostring(ecoVal("level")))
            labelRebirth:Set("Rebirth: " .. tostring(ecoVal("rebirth")))
            local pack = LeftInfoGUI and LeftInfoGUI.GetOrePack() or 0
            local cap = UpgradeData and UpgradeData.GetMaxNum("OrePack") or 0
            labelOre:Set("Ore Pack: " .. tostring(pack) .. "/" .. tostring(cap))
            local dung = LP:GetAttribute("Dungeoning")
            labelDungeon:Set("Dungeon: " .. (dung and "In Combat" or "Idle"))
            local area = LP:GetAttribute("AutoTrainAreaID")
            labelTrain:Set("Train: " .. (area and ("Area " .. tostring(area)) or "Off"))
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while not isTomb() do
        pcall(oreTick)
        pcall(dungeonCombat)
        task.wait(0.25)
    end
end)

print("[ExlumiaaHub] Loot To Forge Hub loaded!")
