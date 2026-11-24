if tostring(game.GameId) ~= "10503838245" then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

local _G_TOMB = "_ _pbOxTomb"
local _G_ALIVE = "_ _pbOxAlive"
local _G_ATTACK = "_ _pbAimlessAttack"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
end

-- Kill old Obsidian PB + old Oxidelib runs
do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub" or gui.Name == "PBCollectorLoader") then
                gui:Destroy()
            end
        end
    end)
    pcall(function()
        if LP then
            local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and (gui.Name == "Obsidian" or gui.Name == "ExlumiaaHub" or gui.Name == "PBCollectorLoader") then
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
    local KEYSYSTEM_STORE_PATH = "PBCollector/panda_key_popbubbles.txt"
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
            brand = "POP BUBBLES",
            guiName = "PBKeyGate",
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
    autoCollect = true,
    useTeleport = true,
    snapCamera = true,
    collectWait = 0.12,
    walkEnabled = false,
    walkSpeed = 120,
    collectKey = Enum.KeyCode.RightControl,
    cycleEnabled = true,
    cycleOn = 5,
    cycleOff = 5,
    aimlessAttack = true,
    tripleShot = false,
}

local originalWalkSpeed = 16

-- ================================================================
-- PATCHES (Aimless / Triple Shot)
-- ================================================================
local autoAttackPatched = false
local origConeTest = nil

local function applyAimlessPatch()
    if autoAttackPatched then return true end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("AutoThrowController"))
    end)
    if not ok then return false end
    local cls = mod.AutoThrowController
    if type(cls) ~= "table" then return false end
    if origConeTest == nil then
        origConeTest = cls.buildConeTest
    end
    cls.buildConeTest = function(self, origin)
        if not workspace.CurrentCamera then return nil end
        return function()
            return true
        end
    end
    autoAttackPatched = true
    rawset(_G, _G_ATTACK, true)
    return true
end

local function removeAimlessPatch()
    if not autoAttackPatched then return end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("AutoThrowController"))
    end)
    if ok and mod.AutoThrowController and origConeTest then
        mod.AutoThrowController.buildConeTest = origConeTest
    end
    origConeTest = nil
    autoAttackPatched = false
    rawset(_G, _G_ATTACK, nil)
end

local cycleStart = tick()

local triplePatched = false
local origThrowFn = nil
local tripleSpreadDeg = 3

local function applyTriplePatch()
    if triplePatched then return true end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("WeaponController"))
    end)
    if not ok then return false end
    local cls = mod.WeaponController
    local inst = cls and cls.getInstance and cls:getInstance()
    if type(inst) ~= "table" or type(inst.throw) ~= "function" then return false end
    if origThrowFn == nil then
        origThrowFn = inst.throw
    end
    local spreadRad = math.rad(tripleSpreadDeg)
    local uid = LP.UserId
    inst.throw = function(self, manual, ...)
        local okCall, result = pcall(origThrowFn, self, manual, ...)
        if not Config.tripleShot then
            return okCall and result or nil
        end
        local root = self.cachedRoot
        if root then
            local okT, tp = pcall(function()
                return self:getTargetPosition(root, false, manual)
            end)
            if okT and typeof(tp) == "Vector3" then
                local off = tp - root.Position
                local dir = off.Magnitude > 0.001 and off.Unit or nil
                if dir then
                    local pivot = CFrame.new(root.Position, root.Position + dir)
                    for _, side in ipairs({ 1, -1 }) do
                        local newUnit = (pivot * CFrame.Angles(0, side * spreadRad, 0)).LookVector
                        local id = ("%*_%*"):format(uid, tick() + 0.001 * side)
                        pcall(function()
                            self.remote:FireServer(newUnit, id, false)
                        end)
                    end
                end
            end
        end
        return okCall and result or nil
    end
    triplePatched = true
    return true
end

local function removeTriplePatch()
    if not triplePatched then return end
    local ok, mod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("WeaponController"))
    end)
    local cls = ok and mod.WeaponController or nil
    local inst = cls and cls.getInstance and cls:getInstance() or nil
    if inst and origThrowFn then
        inst.throw = origThrowFn
    end
    origThrowFn = nil
    triplePatched = false
end

local autoThrowForced = false
local attackMode = nil
local attackSync = nil

local function getWeaponMods()
    local okAT, atMod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("AutoThrowController"))
    end)
    local okWC, wcMod = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("Weapon"):WaitForChild("WeaponController"))
    end)
    if not okAT or not okWC then
        return nil, nil
    end
    return atMod, wcMod
end

local function startAttackEngine()
    local atMod, wcMod = getWeaponMods()
    if not atMod or not wcMod then
        return false
    end
    local at = atMod.AutoThrowController:getInstance()
    local wc = wcMod.WeaponController:getInstance()
    if type(at) ~= "table" or type(wc) ~= "table" then
        return false
    end
    at:setEnabledState(true)
    if not at.targetingConnection then
        at:startTargetingLoop()
    end
    wc:setAutoThrow(true, function()
        return at:getAutoThrowTarget()
    end)
    autoThrowForced = true
    return true
end

local function stopAttackEngine()
    if not autoThrowForced then
        return
    end
    local atMod, wcMod = getWeaponMods()
    if atMod and atMod.AutoThrowController then
        local at = atMod.AutoThrowController:getInstance()
        if type(at) == "table" then
            at:setEnabledState(false)
            at:stopTargetingLoop()
        end
    end
    if wcMod and wcMod.WeaponController then
        local wc = wcMod.WeaponController:getInstance()
        if type(wc) == "table" then
            wc:setAutoThrow(false)
        end
    end
    autoThrowForced = false
end

local function applyAttackEngine()
    local ok = true
    if Config.aimlessAttack then
        Config.tripleShot = false
        removeTriplePatch()
        ok = pcall(applyAimlessPatch)
        ok = startAttackEngine() and ok
        attackMode = "aimless"
    elseif Config.tripleShot then
        ok = pcall(applyAimlessPatch)
        ok = pcall(applyTriplePatch) and ok
        ok = startAttackEngine() and ok
        attackMode = "triple"
    else
        removeAimlessPatch()
        removeTriplePatch()
        stopAttackEngine()
        attackMode = nil
    end
    if attackSync then
        pcall(attackSync, ok, attackMode)
    end
    return ok
end

task.spawn(function()
    if Config.tripleShot and Config.aimlessAttack then
        Config.tripleShot = false
    end
    task.wait(1.5)
    if rawget(_G, _G_TOMB) then
        return
    end
    pcall(applyAttackEngine)
end)

-- ================================================================
-- COLLECTOR
-- ================================================================
local collectedCount = 0

local dropLabel = nil
local collectedLabel = nil
local wsLabel = nil
local healthLabel = nil
local studsLabel = nil
local pingLabel = nil
local cycleLabel = nil
local aimlessLabel = nil
local tripleLabel = nil

local function getHrp()
    local char = LP.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getDropPositions()
    local uid = LP.UserId
    local suffix = "Drops_" .. uid
    local found = {}
    for _, folder in ipairs(workspace:GetChildren()) do
        if folder:IsA("Folder") and string.sub(folder.Name, -string.len(suffix)) == suffix and string.sub(folder.Name, 1, 5) == "Local" then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    local ok, piv = pcall(function()
                        return model:GetPivot().Position
                    end)
                    if ok and piv then
                        found[#found + 1] = { id = model.Name, pos = piv, model = model }
                    end
                end
            end
        end
    end
    return found
end

local lastSeen = {}

local function scanCollect()
    local list = getDropPositions()
    local tpCount = 0
    local seen = {}
    for _, d in ipairs(list) do
        seen[d.id] = true
    end
    for id in pairs(lastSeen) do
        if not seen[id] then
            collectedCount += 1
        end
    end
    lastSeen = {}
    for _, d in ipairs(list) do
        lastSeen[d.id] = true
    end

    local hrp = getHrp()
    local cam = workspace.CurrentCamera
    if not hrp or not cam then
        return #list, 0
    end

    if Config.useTeleport then
        for _, d in ipairs(list) do
            if rawget(_G, _G_TOMB) then
                break
            end
            local hrpNow = getHrp()
            if not hrpNow then
                break
            end
            local cur = hrpNow.Position
            if (cur - d.pos).Magnitude > 12 then
                tpCount += 1
                hrpNow.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrpNow.CFrame = CFrame.new(d.pos.X, d.pos.Y + 3, d.pos.Z)
                if Config.snapCamera and cam then
                    cam.CFrame = CFrame.lookAt(d.pos + Vector3.new(0, 6, 0), d.pos)
                end
                task.wait(Config.collectWait)
            end
        end
    end

    return #list, tpCount
end

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then
            break
        end
        if Config.autoCollect then
            local ok, err = pcall(function()
                local cycleActive = true
                if Config.cycleEnabled then
                    local period = Config.cycleOn + Config.cycleOff
                    local elapsed = (tick() - cycleStart) % period
                    cycleActive = elapsed < Config.cycleOn
                end
                if cycleLabel then
                    cycleLabel:Set("Status: " .. (cycleActive and "collecting" or "waiting"))
                end
                if cycleActive then
                    local n, tp = scanCollect()
                    if dropLabel then
                        dropLabel:Set("Drops: " .. tostring(n))
                    end
                    if collectedLabel then
                        collectedLabel:Set("Collected: " .. tostring(collectedCount))
                    end
                end
            end)
            if not ok then
                rawset(_G, "_ _pbOxErr", tostring(err))
            end
        end
        task.wait(0.1)
    end
end)

-- ================================================================
-- WALKSPEED
-- ================================================================
local function applyWalkSpeed(char)
    if Config.walkEnabled and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Config.walkSpeed
        end
    end
end

LP.CharacterAdded:Connect(function(char)
    originalWalkSpeed = 16
    task.wait(0.5)
    applyWalkSpeed(char)
end)

task.spawn(function()
    while true do
        if rawget(_G, _G_TOMB) then
            break
        end
        applyWalkSpeed(LP.Character)
        task.wait(0.2)
    end
end)

-- ================================================================
-- COLLECT KEYBIND (RightControl toggles auto collect)
-- ================================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.collectKey then
        local t = Library and Library.Flags and Library.Flags["pb_autocollect"]
        if t and t.api and t.api.Set then
            Config.autoCollect = not Config.autoCollect
            pcall(t.api.Set, t.api, Config.autoCollect)
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
    BrandSubtitle = "Pop Bubbles",
    Size = UDim2.fromOffset(700, 490),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Pop Bubbles",
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
healthLabel = InfoSub:AddLabel({ Text = "Health: -" })
studsLabel = InfoSub:AddLabel({ Text = "Pos: -" })
wsLabel = InfoSub:AddLabel({ Text = "WalkSpeed: -" })

InfoSub:AddSection("Server")
InfoSub:AddLabel({ Text = "Place: " .. tostring(game.PlaceId) })
InfoSub:AddLabel({ Text = "Job: " .. tostring(game.JobId) })
pingLabel = InfoSub:AddLabel({ Text = "Ping: --" })
InfoSub:AddLabel({ Text = "Players: --" })
InfoSub:AddLabel({ Text = "by exlumiaa1" })

InfoSub:AddDivider()
InfoSub:AddSection("Attack Status")
aimlessLabel = InfoSub:AddLabel({ Text = "Aimless: status unknown" })
tripleLabel = InfoSub:AddLabel({ Text = "Triple: status unknown" })

-- Info updater
local avgMs = 0
task.spawn(function()
    while true do
        task.wait(0.5)
        if rawget(_G, _G_TOMB) then break end
        pcall(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                healthLabel:Set("Health: " .. ("%d/%d"):format(math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5)))
                wsLabel:Set("WalkSpeed: " .. ("%.1f"):format(hum.WalkSpeed))
            end
            if hrp then
                local p = hrp.Position
                studsLabel:Set(("Pos: %.0f, %.0f, %.0f"):format(p.X, p.Y, p.Z))
            end
            local stats = game:GetService("Stats")
            local pingItem = stats.Network.ServerStatsItem["Data Ping"]
            avgMs = avgMs * 0.8 + pingItem:GetValue() * 0.2
            pingLabel:Set("Ping: " .. ("%dms"):format(math.floor(avgMs + 0.5)))
        end)
    end
end)

-- ======================== MAIN TAB ========================
local MainTab = Window:AddTab({ Name = "Main", Icon = "zap", Subtitle = "Collector" })
local CollectSub = MainTab:AddSubTab("Collector")
local TimerSub = MainTab:AddSubTab("Timer")
local MoveSub = MainTab:AddSubTab("Movement")
local AttackSub = MainTab:AddSubTab("Auto Attack")

CollectSub:AddSection("Auto Collect")
local autoCollectToggle = CollectSub:AddToggle({ Name = "Auto Collect (RightControl)", Default = Config.autoCollect, Flag = "pb_autocollect", Callback = function(s)
    Config.autoCollect = s
end })
CollectSub:AddToggle({ Name = "Teleport To Drops", Default = Config.useTeleport, Flag = "pb_teleport", Callback = function(s)
    Config.useTeleport = s
end })
CollectSub:AddToggle({ Name = "Snap Camera With Player", Default = Config.snapCamera, Flag = "pb_snapcam", Callback = function(s)
    Config.snapCamera = s
end })
CollectSub:AddSlider({ Name = "Wait Between Drops", Min = 1, Max = 20, Default = Config.collectWait * 100, Suffix = "x0.01s", Flag = "pb_collectwait", Callback = function(v)
    Config.collectWait = v / 100
end })
CollectSub:AddDivider()
dropLabel = CollectSub:AddLabel({ Text = "Drops: -" })
collectedLabel = CollectSub:AddLabel({ Text = "Collected: 0" })

TimerSub:AddSection("Timer")
TimerSub:AddToggle({ Name = "Timer Cycle", Default = Config.cycleEnabled, Flag = "pb_cycle", Callback = function(s)
    Config.cycleEnabled = s
    cycleStart = tick()
end })
TimerSub:AddSlider({ Name = "Active (sec)", Min = 1, Max = 60, Default = Config.cycleOn, Suffix = "s", Flag = "pb_cycle_on", Callback = function(v)
    Config.cycleOn = v
end })
TimerSub:AddSlider({ Name = "Idle (sec)", Min = 1, Max = 60, Default = Config.cycleOff, Suffix = "s", Flag = "pb_cycle_off", Callback = function(v)
    Config.cycleOff = v
end })
cycleLabel = TimerSub:AddLabel({ Text = "Status: waiting" })

MoveSub:AddSection("WalkSpeed")
MoveSub:AddToggle({ Name = "WalkSpeed", Default = Config.walkEnabled, Flag = "pb_ws_toggle", Callback = function(s)
    Config.walkEnabled = s
    if not s then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = originalWalkSpeed end
    end
end })
MoveSub:AddSlider({ Name = "Speed", Min = 16, Max = 500, Default = Config.walkSpeed, Suffix = "studs/s", Flag = "pb_ws_val", Callback = function(v)
    Config.walkSpeed = v
end })

-- ======================== AUTO ATTACK SUBTAB ========================
local function syncAttackUI(applied)
    if aimlessLabel then
        if Config.aimlessAttack then
            aimlessLabel:Set(applied and "Aimless: enabled (no aiming)" or "Aimless: failed - module not ready")
        elseif Config.tripleShot then
            aimlessLabel:Set("Aimless: off (Triple Shot active)")
        else
            aimlessLabel:Set("Aimless: camera aim required")
        end
    end
    if tripleLabel then
        if Config.tripleShot then
            tripleLabel:Set(applied and "Triple: enabled (3 throws per throw)" or "Triple: failed - module not ready")
        elseif Config.aimlessAttack then
            tripleLabel:Set("Triple: off (Aimless active)")
        else
            tripleLabel:Set("Triple: disabled")
        end
    end
end

local function applyAttackMode()
    attackSync = function(ok, mode)
        syncAttackUI(ok and mode ~= nil)
    end
    pcall(applyAttackEngine)
end

AttackSub:AddSection("Auto Attack")
local aimlessToggle = AttackSub:AddToggle({ Name = "Aimless Auto Attack (150 studs)", Default = Config.aimlessAttack, Flag = "pb_aimless", Callback = function(s)
    Config.aimlessAttack = s
    if s then
        Config.tripleShot = false
        local t = Library.Flags and Library.Flags["pb_triple"]
        if t and t.api and t.api.Set then
            pcall(t.api.Set, t.api, false)
        end
    end
    pcall(applyAttackMode)
end })
AttackSub:AddDivider()
local tripleToggle = AttackSub:AddToggle({ Name = "Triple Shot (3 throws)", Default = Config.tripleShot, Flag = "pb_triple", Callback = function(s)
    Config.tripleShot = s
    if s then
        Config.aimlessAttack = false
        local t = Library.Flags and Library.Flags["pb_aimless"]
        if t and t.api and t.api.Set then
            pcall(t.api.Set, t.api, false)
        end
    end
    pcall(applyAttackMode)
end })

-- ======================== SETTINGS TAB ========================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })
local ConfigSub = SettingsTab:AddSubTab("Config")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "pb_config_selected",
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
    Flag = "pb_config_name",
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

-- ================================================================
-- CLEANUP
-- ================================================================
local function teardown()
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_ALIVE, nil)
    removeAimlessPatch()
    removeTriplePatch()
    stopAttackEngine()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = originalWalkSpeed end
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
