if tostring(game.GameId) ~= "10765288803" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local LP = Players.LocalPlayer

local _G_TOMB = "_ _bstTomb"
local _G_GEN = "_ _bstGen"

do
    rawset(_G, _G_TOMB, true)
    rawset(_G, _G_GEN, (rawget(_G, _G_GEN) or 0) + 1)
end

local _gen = rawget(_G, _G_GEN)
local function _alive()
    return rawget(_G, _G_GEN) == _gen
end

do
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.W, false, game)
    end)
    pcall(function()
        game:GetService("RunService"):UnbindFromRenderStep("BSE_AUTOAIM")
    end)
end

do
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Oxidelib" or gui.Name == "ExlumiaaHub" or gui.Name == "Obsidian") then
                gui:Destroy()
            end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Oxidelib" or gui.Name == "ExlumiaaHub" or gui.Name == "Obsidian") then
                gui:Destroy()
            end
        end
    end)
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst.Name == "_BSESP" then pcall(function() inst:Destroy() end) end
    end
end

-- ================================================================
-- KEY SYSTEM
-- ================================================================
if not _G._hubKeyValidated then
    local PUSL_SERVICE_ID = "exlumiaa"
    local PUSL_LIB_URL = "https://secure.pandauth.com/pv4/lib"
    local KEYSYSTEM_STORE_PATH = "ExlumiaHub/panda_key_breakandsteal.txt"
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
            brand = "Break and Steal an Egg",
            guiName = "BreakStealKeyGate",
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
                if not _alive() then
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

local Config = {
    autoBreak = false,
    breakZones = {},
    autoSell = false,
    autoClaim = false,
    autoUpgradePlot = false,
    autoPlace = false,
    autoHatch = false,
    autoTreadmill = false,
    autoShop = false,
    batAura = false,
    espEggs = false,
    espAnimals = false,
    speedOn = false,
    speedVal = 60,
    antiAFK = false,
    tpKeyQ = true,
    dmgMult = 1,
    autoSteal = false,
    stealRarities = {},
    stealMinWeight = 0,
    stealMaxDist = 700,
}
rawset(_G, "_breakStealConfig", Config)

local function zoneSetFromList(sel)
    local set = {}
    if type(sel) == "table" then
        for _, name in ipairs(sel) do
            local n = tonumber((tostring(name):match("^Zone (%d+)")))
            if n then set[n] = true end
        end
    end
    return set
end

local ZONE_LABELS = { "Zone 1 (Common)", "Zone 2 (Uncommon)", "Zone 3 (Rare)", "Zone 4 (Epic)", "Zone 5 (Legendary)", "Zone 6 (Mythic)", "Zone 7 (Divine)", "Zone 8 (Cosmic)", "Zone 9 (Secret)" }

local STEAL_RARITY_OPTIONS
pcall(function() STEAL_RARITY_OPTIONS = require(ReplicatedStorage.Shared.IndexConfig).RarityOrder end)
if type(STEAL_RARITY_OPTIONS) ~= "table" or #STEAL_RARITY_OPTIONS == 0 then
    STEAL_RARITY_OPTIONS = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Cosmic", "Secret", "Celestial", "Inferno", "Void", "Omega" }
end

local notifyHub

local function getRemote(name)
    local r = ReplicatedStorage:FindFirstChild(name)
    if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction") or r:IsA("UnreliableRemoteEvent")) then
        return r
    end
    return nil
end

local function fireRS(name, ...)
    local r = getRemote(name)
    if r and r:IsA("RemoteEvent") then
        r:FireServer(...)
        return true
    end
    return false
end

local function getOwnPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, p in ipairs(plots:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == LP.UserId then
            return p
        end
    end
    return nil
end

local function getChar()
    local c = LP.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then
        return c, hrp, hum
    end
    return nil
end

local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local wHeld = false
local function pressW()
    if not wHeld then
        wHeld = true
        pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game) end)
    end
end
local function releaseW()
    if wHeld then
        wHeld = false
        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game) end)
    end
end

local aiming = false
local aimTarget = nil
local function setAim(pos)
    aimTarget = pos
    if not aiming then
        aiming = true
        pcall(function()
            RunService:BindToRenderStep("BSE_AUTOAIM", Enum.RenderPriority.Camera.Value + 1, function()
                local t = aimTarget
                local cam = workspace.CurrentCamera
                if t and cam then
                    local cp = cam.CFrame.Position
                    cam.CFrame = CFrame.lookAt(cp, Vector3.new(t.X, cp.Y, t.Z))
                end
            end)
        end)
    end
end
local function clearAim()
    aimTarget = nil
    if aiming then
        aiming = false
        pcall(function() RunService:UnbindFromRenderStep("BSE_AUTOAIM") end)
    end
end
local function stopTravel()
    releaseW()
    clearAim()
end
local function kbBlocked()
    local ok, tb = pcall(function() return game:GetService("UserInputService"):GetFocusedTextBox() end)
    return ok and tb ~= nil
end

local tpToken = 0
local tpBusy = false
local function stagedTeleport(dest, hop, interval)
    if not dest then return end
    tpToken = tpToken + 1
    local myToken = tpToken
    tpBusy = true
    task.spawn(function()
        local HOP = hop or 300
        local INT = interval or 1.2
        local steps = 0
        while _alive() and myToken == tpToken do
            steps = steps + 1
            if steps > 12 then
                if myToken == tpToken then tpBusy = false end
                if notifyHub then
                    notifyHub({ Title = "Teleport", Content = "Kept getting pulled back - teleport failed", Type = "warning", Duration = 3 })
                end
                return
            end
            local char, hrp = getChar()
            if not char then
                if myToken == tpToken then tpBusy = false end
                return
            end
            local pos = hrp.Position
            local delta = dest - pos
            local dist = delta.Magnitude
            if dist < 12 then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                if myToken == tpToken then tpBusy = false end
                return
            end
            local step
            if dist <= HOP then
                step = dest
            else
                step = pos + delta.Unit * HOP
            end
            local rot = hrp.CFrame - pos
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(step) * rot
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            task.wait(INT)
        end
        if myToken == tpToken then tpBusy = false end
    end)
end

local function isLiveEgg(p)
    return p.Parent ~= nil and p:IsA("BasePart")
        and not p:GetAttribute("Broken")
        and not p:GetAttribute("Hatching")
        and not p:GetAttribute("Despawning")
end

local function nearestLiveEgg(pos, maxDist, unfiltered)
    local allow
    if not unfiltered then
        allow = type(Config.breakZones) == "table" and Config.breakZones or {}
    end
    local best, bestD = nil, maxDist or math.huge
    for _, p in ipairs(CollectionService:GetTagged("BreakableEgg")) do
        if isLiveEgg(p) then
            local zi = tonumber(p:GetAttribute("ZoneIndex"))
            if (not allow) or (zi and allow[zi]) then
                local d = (p.Position - pos).Magnitude
                if d < bestD then
                    best, bestD = p, d
                end
            end
        end
    end
    return best, bestD
end

local function heldAnimalTool(char)
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and CollectionService:HasTag(t, "AnimalTool") then
            return t
        end
    end
    return nil
end

local function plotCapacity(plot)
    local placed = plot:GetAttribute("AnimalsPlaced") or 0
    local maxA = plot:GetAttribute("MaxAnimals")
    if not maxA then
        local ok, cfg = pcall(function() return require(ReplicatedStorage.Shared.PlotUpgradeConfig) end)
        if ok and cfg and cfg.Capacity then
            pcall(function()
                maxA = cfg.Capacity(plot:GetAttribute("PlotLevel") or 1)
            end)
        end
    end
    return placed, maxA or 999
end

local placeCounter = math.random(1, 5000)

-- ================================================================
-- LOOP: AUTO BREAK
-- ================================================================
task.spawn(function()
    local lastHit = 0
    local lastEquip = 0
    local walkPos, walkAt = nil, 0
    while _alive() do
        if Config.autoBreak and not Config.autoSteal and not Config.autoTreadmill and not tpBusy then
            pcall(function()
                local char, hrp, hum = getChar()
                if char and not heldAnimalTool(char) then
                    local egg, d = nearestLiveEgg(hrp.Position, 100000)
                    if egg then
                        if d > 6.5 then
                            if kbBlocked() then
                                stopTravel()
                            else
                                setAim(egg.Position)
                                pressW()
                                if not walkPos or (hrp.Position - walkPos).Magnitude > 4 then
                                    walkPos, walkAt = hrp.Position, os.clock()
                                elseif os.clock() - walkAt > 1.5 then
                                    walkAt = os.clock()
                                    hum.Jump = true
                                end
                            end
                        else
                            stopTravel()
                            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(egg.Position.X, hrp.Position.Y, egg.Position.Z))
                            local bp = LP:FindFirstChild("Backpack")
                            local held = char:FindFirstChild("Pickaxe")
                            if not held and bp and bp:FindFirstChild("Pickaxe") and os.clock() - lastEquip > 0.6 then
                                lastEquip = os.clock()
                                hum:EquipTool(bp:FindFirstChild("Pickaxe"))
                                held = char:FindFirstChild("Pickaxe")
                            end
                            local mult = math.clamp(math.floor(tonumber(Config.dmgMult) or 1), 1, 5)
                            local hitGap = 0.4 + (mult - 1) * 0.15
                            if held and os.clock() - lastHit >= hitGap then
                                lastHit = os.clock()
                                local fired = false
                                for _ = 1, mult do
                                    if fireRS("EggHitRequest", egg) then fired = true end
                                end
                                if fired then
                                    pcall(function()
                                        local sfx = held:FindFirstChild("Handle")
                                        sfx = sfx and sfx:FindFirstChild("PickaxeSwoosh")
                                    end)
                                end
                            end
                        end
                    else
                        stopTravel()
                        task.wait(1)
                    end
                else
                    stopTravel()
                end
            end)
        else
            stopTravel()
        end
        task.wait(0.15)
    end
    stopTravel()
end)

-- ================================================================
-- HELPERS + LOOP: AUTO STEAL
-- ================================================================
local stealTpBlockedUntil = 0
local stealLastPos, stealLastMoveAt = nil, 0
local stealTpReverts = 0

local function stealTravelTo(hrp, hum, dest)
    local pos = hrp.Position
    local dist = (dest - pos).Magnitude
    if dist < 10 then return dist end
    if os.clock() >= stealTpBlockedUntil and dist > 40 and not tpBusy then
        local before = pos
        local stepPos = if dist <= 320 then dest else pos + (dest - pos).Unit * 320
        local rot = hrp.CFrame - pos
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(stepPos) * rot
        task.wait(0.5)
        local moved = (hrp.Position - before).Magnitude
        if moved < 60 then
            stealTpReverts = stealTpReverts + 1
            if stealTpReverts >= 2 then
                stealTpReverts = 0
                stealTpBlockedUntil = os.clock() + 4
            end
        else
            stealTpReverts = 0
        end
        task.wait(0.7)
    else
        hum:MoveTo(dest)
        task.wait(0.35)
        if not stealLastPos or (hrp.Position - stealLastPos).Magnitude > 4 then
            stealLastPos, stealLastMoveAt = hrp.Position, os.clock()
        elseif os.clock() - stealLastMoveAt > 1.5 then
            stealLastMoveAt = os.clock()
            hum.Jump = true
        end
    end
    return (dest - hrp.Position).Magnitude
end

local function stealTargetModel(promptPart)
    local node = promptPart
    for _ = 1, 4 do
        if not node then break end
        if node:GetAttribute("AnimalName") then return node end
        node = node.Parent
    end
    local best, bestD = nil, 20
    for _, m in ipairs(CollectionService:GetTagged("AnimalPickup")) do
        local ok, pivot = pcall(function() return m:GetPivot().Position end)
        if ok then
            local d = (pivot - promptPart.Position).Magnitude
            if d < bestD then best, bestD = m, d end
        end
    end
    return best
end

local function stealAllowed(model)
    local hasRar = next(Config.stealRarities) ~= nil
    local minW = tonumber(Config.stealMinWeight) or 0
    if not model then
        return (not hasRar) and minW <= 0
    end
    if hasRar and not Config.stealRarities[model:GetAttribute("Rarity")] then return false end
    if minW > 0 then
        local w = model:GetAttribute("WeightKg")
        if not (typeof(w) == "number" and w >= minW) then return false end
    end
    return true
end

local function nearestStealTarget(pos, blacklist)
    local prompt, part, model, dBest = nil, nil, nil, 100000
    for _, pr in ipairs(CollectionService:GetTagged("SmartPrompt")) do
        if pr:IsA("ProximityPrompt") and pr.Name == "StealPrompt" and pr.Enabled then
            local prPart = pr.Parent
            if prPart and prPart:IsA("BasePart") then
                local m = stealTargetModel(prPart)
                local untilTime = blacklist[pr] or blacklist[prPart] or (m and blacklist[m])
                if (not untilTime or untilTime < os.clock()) and stealAllowed(m) then
                    local d = (prPart.Position - pos).Magnitude
                    if d < dBest then
                        prompt, part, model, dBest = pr, prPart, m, d
                    end
                end
            end
        end
    end
    return prompt, part, model, dBest
end

task.spawn(function()
    local blacklist = {}
    local stealState = "idle"
    local stealAt = 0
    local holdEndAt = 0
    local carryAt = 0
    local nudgeUntil = 0
    local nudgePoint = nil

    while _alive() do
        if Config.autoSteal then
            pcall(function()
                local char, hrp, hum = getChar()
                if not char then return end
                local carrying = LP:GetAttribute("Carrying") ~= nil
                if carrying then
                    stealState = "idle"
                    if carryAt == 0 then carryAt = os.clock() end
                    local plot = getOwnPlot()
                    local hb = plot and plot:FindFirstChild("Hitbox")
                    if hb and hb:IsA("BasePart") then
                        local dest = hb.Position + Vector3.new(0, 4, 0)
                        local dist = (dest - hrp.Position).Magnitude
                        if os.clock() < nudgeUntil and nudgePoint then
                            hum:MoveTo(nudgePoint)
                            task.wait(0.3)
                        elseif dist > 12 then
                            stealTravelTo(hrp, hum, dest)
                        else
                            hum:MoveTo(hb.Position)
                            task.wait(0.3)
                            if os.clock() - carryAt > 14 then
                                nudgePoint = hb.Position + (hrp.Position - hb.Position).Unit * 55
                                nudgeUntil = os.clock() + 2.5
                                carryAt = os.clock() - 8
                            end
                        end
                    end
                else
                    carryAt = 0
                    nudgeUntil = 0
                    nudgePoint = nil
                    local prompt, part, model, d = nearestStealTarget(hrp.Position, blacklist)
                    if prompt and d and d > (tonumber(Config.stealMaxDist) or 700) then
                        prompt = nil
                    end
                    if not prompt then
                        task.wait(1)
                    else
                        local dest = part.Position + Vector3.new(0, 3, 0)
                        local dist = (dest - hrp.Position).Magnitude
                        if dist > 8 then
                            stealState = "idle"
                            stealTravelTo(hrp, hum, dest)
                        elseif stealState == "idle" and os.clock() - stealAt > 1.5 then
                            stealState = "hold"
                            stealAt = os.clock()
                            holdEndAt = stealAt + 0.55
                            pcall(function() prompt:InputHoldBegin() end)
                        elseif stealState == "hold" and os.clock() >= holdEndAt then
                            stealState = "wait"
                            pcall(function() prompt:InputHoldEnd() end)
                            stealAt = os.clock()
                        elseif stealState == "wait" and os.clock() - stealAt > 1.2 then
                            stealState = "idle"
                            if not LP:GetAttribute("Carrying") then
                                blacklist[prompt] = os.clock() + 8
                                if model then blacklist[model] = os.clock() + 8 end
                            end
                        else
                            task.wait(0.2)
                        end
                    end
                end
            end)
        else
            stealState = "idle"
            carryAt = 0
        end
        task.wait(0.25)
    end
end)

-- ================================================================
-- LOOP: AUTO SELL (animals in backpack when plot is full)
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoSell then
            pcall(function()
                local rf = getRemote("BackpackSellRemote")
                if rf and rf:IsA("RemoteFunction") then
                    local plot = getOwnPlot()
                    if plot then
                        local placed, maxA = plotCapacity(plot)
                        if placed >= maxA then
                            local list = {}
                            for _, t in ipairs(LP.Backpack:GetChildren()) do
                                if t:IsA("Tool") and CollectionService:HasTag(t, "AnimalTool") then
                                    table.insert(list, t)
                                end
                            end
                            if #list > 0 then
                                rf:InvokeServer(list)
                                if notifyHub then
                                    notifyHub({ Title = "Auto Sell", Content = "Sold " .. #list .. " animals (plot full)", Type = "info", Duration = 3 })
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- ================================================================
-- LOOP: AUTO CLAIM INDEX REWARD
-- ================================================================
task.spawn(function()
    local lastClaim = 0
    local function scanReady(t, names, depth)
        if type(t) ~= "table" or depth > 3 then return end
        for k, v in pairs(t) do
            if v == "Ready" and type(k) == "string" then
                table.insert(names, k)
            elseif type(v) == "table" then
                scanReady(v, names, depth + 1)
            end
        end
    end
    pcall(function()
        local r = getRemote("IndexRemote")
        if r and r:IsA("RemoteEvent") then
            r.OnClientEvent:Connect(function(t1, t2)
                if t1 ~= "State" or not Config.autoClaim then return end
                local names = {}
                scanReady(t2, names, 1)
                if #names > 0 and os.clock() - lastClaim >= 5 then
                    lastClaim = os.clock()
                    pcall(function()
                        for _, name in ipairs(names) do
                            r:FireServer("Claim", name)
                        end
                    end)
                end
            end)
        end
    end)
    while _alive() do
        if Config.autoClaim then
            pcall(function()
                local r = getRemote("IndexRemote")
                if r and r:IsA("RemoteEvent") then
                    r:FireServer("Get", nil)
                end
            end)
        end
        task.wait(10)
    end
end)

-- ================================================================
-- LOOP: AUTO UPGRADE PLOT
-- ================================================================
task.spawn(function()
    while _alive() do
        if Config.autoUpgradePlot then
            pcall(function()
                fireRS("UpgradePlotRequest")
            end)
        end
        task.wait(5)
    end
end)

-- ================================================================
-- LOOP: AUTO SHOP (PICKAXE + TRAIL)
-- ================================================================
task.spawn(function()
    local PickaxeConfig, TrailsConfig
    local function ensureConfigs()
        if not PickaxeConfig then
            local ok, m = pcall(function() return require(ReplicatedStorage.Shared.PickaxeConfig) end)
            if ok and type(m) == "table" then PickaxeConfig = m end
        end
        if not TrailsConfig then
            local ok, m = pcall(function() return require(ReplicatedStorage.Shared.TrailsConfig) end)
            if ok and type(m) == "table" then TrailsConfig = m end
        end
        return PickaxeConfig ~= nil and TrailsConfig ~= nil
    end
    local function parseIds(s)
        local set = {}
        if type(s) == "string" then
            for token in string.gmatch(s, "[^,]+") do
                local n = tonumber(token)
                if n then set[n] = true end
            end
        end
        return set
    end
    local lastFire = 0
    while _alive() do
        if Config.autoShop and ensureConfigs() then
            pcall(function()
                local cash = LP:GetAttribute("Cash")
                if typeof(cash) ~= "number" then return end
                if os.clock() - lastFire < 1.5 then return end
                -- pickaxe: owned set
                local owned = { [PickaxeConfig.DefaultTier] = true }
                local tier = LP:GetAttribute("PickaxeTier")
                if typeof(tier) == "number" then owned[tier] = true end
                for id in pairs(parseIds(LP:GetAttribute("OwnedPickaxes"))) do owned[id] = true end
                local maxPick = PickaxeConfig.DefaultTier
                for id in pairs(owned) do
                    if id > maxPick then maxPick = id end
                end
                -- find highest affordable tier (same logic as the game shop)
                local buyTier
                for i, entry in ipairs(PickaxeConfig.Tiers) do
                    if i > maxPick and not owned[i] and (entry.Price or 0) <= cash then
                        if buyTier == nil or i > buyTier then buyTier = i end
                    end
                end
                if buyTier then
                    lastFire = os.clock()
                    fireRS("PickaxeShopRequest", "Buy", buyTier)
                    return
                end
                if typeof(tier) ~= "number" or tier ~= maxPick then
                    lastFire = os.clock()
                    fireRS("PickaxeShopRequest", "Equip", maxPick)
                    return
                end
                -- trail
                local tOwned = parseIds(LP:GetAttribute("OwnedTrails"))
                local maxTrail = 0
                for id in pairs(tOwned) do
                    if id > maxTrail then maxTrail = id end
                end
                local buyTrail
                for _, entry in ipairs(TrailsConfig.Trails) do
                    if entry.Id > maxTrail and not tOwned[entry.Id] and (entry.Price or 0) <= cash then
                        if buyTrail == nil or entry.Id > buyTrail then buyTrail = entry.Id end
                    end
                end
                if buyTrail then
                    lastFire = os.clock()
                    fireRS("TrailShopRequest", "Buy", buyTrail)
                    return
                end
                local equipped = LP:GetAttribute(TrailsConfig.EquippedAttribute)
                if maxTrail > 0 and (typeof(equipped) ~= "number" or equipped ~= maxTrail) then
                    lastFire = os.clock()
                    fireRS("TrailShopRequest", "Equip", maxTrail)
                end
            end)
        end
        task.wait(5)
    end
end)

-- ================================================================
-- LOOP: AUTO PLACE (place animals on own plot)
-- ================================================================
task.spawn(function()
    local lastAttempt = 0
    while _alive() do
        if Config.autoPlace then
            pcall(function()
                local char, hrp, hum = getChar()
                if char then
                    local tool = heldAnimalTool(char)
                    if tool then
                        local plot = getOwnPlot()
                        local hb = plot and plot:FindFirstChild("Hitbox")
                        if plot and hb and hb:IsA("BasePart") and not plot:GetAttribute("RestoringPets") then
                            local placed, maxA = plotCapacity(plot)
                            if placed < maxA and os.clock() - lastAttempt >= 1.2 then
                                local maxDist = 40
                                pcall(function()
                                    maxDist = require(ReplicatedStorage.Shared.AnimalPlacementConfig).MaxPlaceDistance or maxDist
                                end)
                                local half = hb.Size * 0.5
                                local off = Vector3.new(
                                    (math.random() * 2 - 1) * half.X * 0.7,
                                    hb.Size.Y * 0.25,
                                    (math.random() * 2 - 1) * half.Z * 0.7
                                )
                                local target = hb.CFrame * off
                                local dist = (Vector3.new(target.X, 0, target.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
                                if dist <= maxDist then
                                    lastAttempt = os.clock()
                                    placeCounter = placeCounter + 1
                                    fireRS("PlaceAnimalRemote", tool, target, placeCounter)
                                else
                                    hum:MoveTo(hb.Position)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.25)
    end
end)

-- ================================================================
-- LOOP: AUTO HATCH & SKIP (eggs in inventory)
-- ================================================================
task.spawn(function()
    local lastHatch = 0
    while _alive() do
        if Config.autoHatch then
            pcall(function()
                if os.clock() - lastHatch >= 3 then
                    lastHatch = os.clock()
                    fireRS("MergeMachineRemote", "SkipAll")
                end
                local bp = LP:FindFirstChild("Backpack")
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") and CollectionService:HasTag(t, "MergeEggTool") then
                            local eggId = t:GetAttribute("EggId")
                            if eggId then
                                fireRS("MergeMachineRemote", "HatchEgg", eggId)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- ================================================================
-- LOOP: AUTO TREADMILL
-- ================================================================
local function getTreadmillPos(plot)
    if not plot then return nil end
    local beltModels = {}
    for _, d in ipairs(plot:GetDescendants()) do
        local lower = string.lower(d.Name)
        if d:IsA("Model") and string.find(lower, "treadmill") and not string.find(lower, "board") then
            table.insert(beltModels, d)
        end
    end
    for _, m in ipairs(beltModels) do
        local hitbox = m:FindFirstChild("Hitbox")
        if hitbox and hitbox:IsA("BasePart") then
            return hitbox.Position - Vector3.new(0, 1.1, 0)
        end
    end
    if beltModels[1] then
        return beltModels[1]:GetPivot().Position + Vector3.new(0, 1, 0)
    end
    return nil
end

task.spawn(function()
    local wasOn = false
    while _alive() do
        if Config.autoTreadmill then
            wasOn = true
            pcall(function()
                local char, hrp = getChar()
                if char and not heldAnimalTool(char) then
                    local pos = getTreadmillPos(getOwnPlot())
                    if pos and (hrp.Position - pos).Magnitude > 10 and not tpBusy then
                        stagedTeleport(pos + Vector3.new(0, 2, 0))
                    end
                end
            end)
        elseif wasOn then
            wasOn = false
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("TreadmillSessionRemote")
                if r and r:IsA("RemoteEvent") then
                    r:FireServer()
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ================================================================
-- LOOP: BAT KILL AURA (auto swing at nearest player)
-- ================================================================
task.spawn(function()
    local BatTargeting
    local lastSwing = 0
    local wasOn = false
    while _alive() do
        if Config.batAura then
            wasOn = true
            pcall(function()
                if not BatTargeting then
                    local ok, m = pcall(function() return require(ReplicatedStorage.Shared.BatTargeting) end)
                    if ok and type(m) == "table" then BatTargeting = m end
                end
                if not BatTargeting then return end
                local char, hrp, hum = getChar()
                if not char then return end
                local bat = char:FindFirstChild("Bat")
                if not bat then
                    local bp = LP:FindFirstChild("Backpack")
                    bat = bp and bp:FindFirstChild("Bat")
                    if bat and hum then
                        hum:EquipTool(bat)
                        return
                    end
                    return
                end
                local rem = ReplicatedStorage:FindFirstChild("BatHitRequest")
                if not rem or not rem:IsA("RemoteEvent") then return end
                local now = tick()
                if now - lastSwing < 0.75 then return end
                local target = BatTargeting.SelectClosestTarget(LP, hrp.Position, 20)
                if target then
                    local tc = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                    if tc then
                        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(tc.Position.X, hrp.Position.Y, tc.Position.Z))
                    end
                    lastSwing = now
                    rem:FireServer(target)
                end
            end)
        elseif wasOn then
            wasOn = false
        end
        task.wait(0.25)
    end
end)

-- ================================================================
-- LOOP: ESP
-- ================================================================
local function makeESP(adornee, color)
    local h = Instance.new("Highlight")
    h.Name = "_BSESP"
    h.FillColor = color
    h.FillTransparency = 0.82
    h.OutlineColor = color
    h.OutlineTransparency = 0.1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = adornee
    h.Parent = adornee
    return h
end

local function fmtMoney(n)
    n = math.floor((n or 0) + 0.5)
    local abs = math.abs(n)
    local suffix, div = "", 1
    if abs >= 1e12 then suffix, div = "T", 1e12
    elseif abs >= 1e9 then suffix, div = "B", 1e9
    elseif abs >= 1e6 then suffix, div = "M", 1e6
    elseif abs >= 1e3 then suffix, div = "K", 1e3
    else return tostring(n) end
    local v = n / div
    local s = if v >= 100 then string.format("%.0f", v) else string.format("%.1f", v)
    return (s:gsub("%.0$", "")) .. suffix
end

local function ensureValueTag(inst)
    local bb = inst:FindFirstChild("_BSESPV")
    if bb then return bb end
    bb = Instance.new("BillboardGui")
    bb.Name = "_BSESPV"
    bb.Size = UDim2.new(0, 150, 0, 34)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 500
    bb.Parent = inst
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Main"
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(255, 220, 90)
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextStrokeTransparency = 0.35
    lbl.Text = ""
    lbl.Parent = bb
    return bb
end

task.spawn(function()
    local EGG_COLOR = Color3.fromRGB(80, 255, 120)
    local ANIMAL_COLOR = Color3.fromRGB(255, 200, 60)
    local BSC
    while _alive() do
        pcall(function()
            if not BSC then
                local ok, m = pcall(function() return require(ReplicatedStorage.Shared.BackpackSellConfig) end)
                if ok and type(m) == "table" and type(m.EggValue) == "function" then BSC = m end
            end
            local want = {}
            if Config.espEggs then
                for _, p in ipairs(CollectionService:GetTagged("BreakableEgg")) do
                    if isLiveEgg(p) then want[p] = true end
                end
            end
            if Config.espAnimals then
                local ap = workspace:FindFirstChild("AnimalPickups")
                if ap then
                    for _, m in ipairs(ap:GetChildren()) do
                        want[m] = true
                    end
                end
            end
            for inst in pairs(want) do
                if inst.Parent and not inst:FindFirstChild("_BSESP") then
                    local isEgg = inst:IsA("BasePart")
                    makeESP(inst, if isEgg then EGG_COLOR else ANIMAL_COLOR)
                end
                if inst:IsA("BasePart") and want[inst] and inst:FindFirstChild("_BSESP") then
                    local et = inst:GetAttribute("EggType")
                    if et and BSC then
                        local bb = ensureValueTag(inst)
                        bb.StudsOffset = Vector3.new(0, inst.Size.Y / 2 + 1.5, 0)
                        local lbl = bb:FindFirstChild("Main")
                        if lbl then
                            local val
                            pcall(function()
                                val = BSC.EggValue(et, inst:GetAttribute("WeightKg"))
                            end)
                            local txt = if typeof(val) == "number" then "$" .. fmtMoney(val) .. "  " .. et else tostring(et)
                            if lbl.Text ~= txt then lbl.Text = txt end
                        end
                    end
                end
            end
            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst.Name == "_BSESP" and inst:IsA("Highlight") then
                    local ad = inst.Adornee
                    if not ad or not want[ad] or ad.Parent == nil then
                        inst:Destroy()
                    end
                elseif inst.Name == "_BSESPV" and inst:IsA("BillboardGui") then
                    local par = inst.Parent
                    if not par or not want[par] then
                        inst:Destroy()
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- ================================================================
-- LOOP: WALKSPEED + ANTI-AFK
-- ================================================================
task.spawn(function()
    local wasOn = false
    local function gameMappedSpeed()
        local ok, v = pcall(function()
            return require(ReplicatedStorage.Shared.SpeedConfig).SpeedPowerToWalkSpeed(LP:GetAttribute("SpeedPower") or 10)
        end)
        if ok and type(v) == "number" then return v end
        return nil
    end
    local creatures = {}
    local nextScan = 0
    local function refreshCreatures()
        creatures = {}
        local zb = workspace:FindFirstChild("Build") and workspace.Build:FindFirstChild("ZoneBuilds")
        if not zb then return end
        for _, d in ipairs(zb:GetDescendants()) do
            if d:IsA("Model") then
                local hum = d:FindFirstChildOfClass("Humanoid")
                local hrp = d:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
                    table.insert(creatures, hrp)
                end
            end
        end
    end
    local function nearCreature(pos)
        local best = math.huge
        for i = #creatures, 1, -1 do
            local cr = creatures[i]
            if not cr.Parent then
                table.remove(creatures, i)
            else
                local d = (Vector3.new(cr.Position.X, 0, cr.Position.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
                if d < best then best = d end
            end
        end
        return best
    end
    while _alive() do
        pcall(function()
            local char, hrp, hum = getChar()
            if char and hum then
                if Config.speedOn then
                    local target = math.clamp(Config.speedVal, 16, 200)
                    local now = os.clock()
                    if now >= nextScan then
                        nextScan = now + 5
                        refreshCreatures()
                    end
                    if #creatures > 0 and nearCreature(hrp.Position) < 110 then
                        target = math.min(target, 100)
                    end
                    if math.abs(hum.WalkSpeed - target) > 0.5 then
                        hum.WalkSpeed = target
                    end
                    wasOn = true
                elseif wasOn then
                    wasOn = false
                    local mapped = gameMappedSpeed()
                    if mapped then
                        hum.WalkSpeed = math.clamp(mapped, 16, 200)
                    end
                end
            end
        end)
        task.wait(0.15)
    end
end)

task.spawn(function()
    while _alive() do
        if Config.antiAFK then
            pcall(function()
                local char, hrp, hum = getChar()
                if char then
                    hum.Jump = true
                end
            end)
        end
        task.wait(12)
    end
end)

-- ================================================================
-- UI
-- ================================================================
local OxidelibUrl = "https://raw.githubusercontent.com/exlumiaa/exlumiaa-hub/main/Oxidelib.lua"
local Library = loadstring(game:HttpGet(OxidelibUrl))()

Library.ConfigFolder = "exlumiaa/breakandsteal"

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
    for _, m in ipairs({ "AddToggle", "AddSlider", "AddDropdown", "AddMultiDropdown", "AddInput" }) do
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

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "Break and Steal an Egg",
    Title = "Exlumiaa Hub",
    Logo = 72522294315389,
    Folder = "exlumia",
    ToggleKey = Enum.KeyCode.RightShift,
    AllowMultiple = false,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "Break and Steal an Egg",
    LoadingFooter = "by Exlumiaa Hub",
    StatusText = "Exlumiaa Hub ready",
    GuiName = "ExlumiaaHub",
})

notifyHub = function(opts)
    local ok, err = pcall(function() Window:Notify(opts) end)
    if not ok then warn("[BreakSteal] notify failed: " .. tostring(err)) end
end

local MainTab = Window:AddTab({ Name = "Main", Icon = "agriculture", Subtitle = "Auto Features" })
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "person", Subtitle = "Local Player" })
local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Subtitle = "ESP" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Subtitle = "Config" })

local FarmSub = MainTab:AddSubTab("Farm")
local BaseSub = MainTab:AddSubTab("Base")
local RewardSub = MainTab:AddSubTab("Rewards")
local BatSub = MainTab:AddSubTab("Bat")
local PlayerSub = PlayerTab:AddSubTab("Movement")
local TpSub = PlayerTab:AddSubTab("Teleport")
local ESPSub = VisualTab:AddSubTab("ESP")
for _, sub in ipairs({ FarmSub, BaseSub, RewardSub, BatSub, PlayerSub, TpSub, ESPSub }) do
    autosaveWrap(sub)
end

FarmSub:AddSection("Egg Loop")
FarmSub:AddToggle({ Name = "Auto Break", Default = false, Flag = "bs_auto_break", Callback = function(v)
    Config.autoBreak = v
    if v and Config.autoTreadmill then
        Config.autoTreadmill = false
        if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Treadmill turned off (conflicts with Auto Break)", Type = "warning", Duration = 3 }) end
    end
    if v and Config.batAura then
        Config.batAura = false
        if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Swing turned off (conflicts with Auto Break)", Type = "warning", Duration = 3 }) end
    end
end })
FarmSub:AddMultiDropdown({
    Name = "Break Zones",
    Options = ZONE_LABELS,
    Default = {},
    MaxVisible = 5,
    Flag = "bs_break_zones",
    Callback = function(sel)
        Config.breakZones = zoneSetFromList(sel)
    end,
})
FarmSub:AddToggle({ Name = "Auto Hatch & Skip", Default = false, Flag = "bs_auto_hatch", Callback = function(v)
    Config.autoHatch = v
end })
FarmSub:AddSlider({ Name = "Hit Multiplier", Min = 1, Max = 5, Default = 1, Rounding = 0, Flag = "bs_dmg_mult", Callback = function(v)
    Config.dmgMult = v
end })

FarmSub:AddSection("Steal")
FarmSub:AddToggle({ Name = "Auto Steal", Default = false, Flag = "bs_auto_steal", Callback = function(v)
    Config.autoSteal = v
    if v and Config.autoBreak then
        Config.autoBreak = false
        if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Break turned off (Auto Steal needs to move you)", Type = "warning", Duration = 3 }) end
    end
end })
FarmSub:AddMultiDropdown({
    Name = "Steal Rarities",
    Options = STEAL_RARITY_OPTIONS,
    Default = {},
    MaxVisible = 6,
    Flag = "bs_steal_rarities",
    Callback = function(sel)
        local set = {}
        if type(sel) == "table" then
            for _, r in ipairs(sel) do set[r] = true end
        end
        Config.stealRarities = set
    end,
})
FarmSub:AddInput({ Name = "Steal Min Weight", Default = "0", Placeholder = "0", Flag = "bs_steal_minwt", Callback = function(v)
    Config.stealMinWeight = tonumber(v) or 0
end })
FarmSub:AddSlider({ Name = "Steal Max Distance", Min = 200, Max = 3000, Default = 700, Rounding = 0, Flag = "bs_steal_maxdist", Callback = function(v)
    Config.stealMaxDist = v
end })

BaseSub:AddSection("Base")
BaseSub:AddToggle({ Name = "Auto Place", Default = false, Flag = "bs_auto_place", Callback = function(v)
    Config.autoPlace = v
end })
BaseSub:AddToggle({ Name = "Auto Treadmill", Default = false, Flag = "bs_auto_treadmill", Callback = function(v)
    Config.autoTreadmill = v
    if v and Config.autoBreak then
        Config.autoBreak = false
        if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Break turned off (conflicts with Auto Treadmill)", Type = "warning", Duration = 3 }) end
    end
end })
BaseSub:AddToggle({ Name = "Auto Sell", Default = false, Flag = "bs_auto_sell", Callback = function(v)
    Config.autoSell = v
end })
BaseSub:AddToggle({ Name = "Auto Upgrade Plot", Default = false, Flag = "bs_auto_upgrade", Callback = function(v)
    Config.autoUpgradePlot = v
end })
BaseSub:AddSection("Shop")
BaseSub:AddToggle({ Name = "Auto Shop", Default = false, Flag = "bs_auto_shop", Callback = function(v)
    Config.autoShop = v
end })

RewardSub:AddSection("Claim")
RewardSub:AddToggle({ Name = "Auto Claim Reward", Default = false, Flag = "bs_auto_claim", Callback = function(v)
    Config.autoClaim = v
    if v then
        task.spawn(function()
            pcall(function()
                local r = getRemote("IndexRemote")
                if r and r:IsA("RemoteEvent") then r:FireServer("Get", nil) end
            end)
        end)
    end
end })

BatSub:AddSection("Kill Aura")
BatSub:AddToggle({ Name = "Auto Swing", Default = false, Flag = "bs_auto_swing", Callback = function(v)
    Config.batAura = v
    if v then
        if Config.autoBreak then
            Config.autoBreak = false
            if notifyHub then notifyHub({ Title = "Break and Steal", Content = "Auto Break turned off (conflicts with Auto Swing)", Type = "warning", Duration = 3 }) end
        end
    end
end })

PlayerSub:AddSection("Speed")
PlayerSub:AddToggle({ Name = "WalkSpeed", Default = false, Flag = "bs_walkspeed", Callback = function(v)
    Config.speedOn = v
end })
PlayerSub:AddSlider({ Name = "Speed Value", Min = 16, Max = 200, Default = 60, Rounding = 0, Flag = "bs_speed_val", Callback = function(v)
    Config.speedVal = v
end })
PlayerSub:AddSection("Anti AFK")
PlayerSub:AddToggle({ Name = "Anti-AFK", Default = false, Flag = "bs_antiafk", Callback = function(v)
    Config.antiAFK = v
end })

TpSub:AddSection("Teleport")
local function tpToBase()
    pcall(function()
        local char = getChar()
        local plot = getOwnPlot()
        if char and plot then
            local dest = nil
            local sp = plot:FindFirstChild("SpawnPoint")
            if sp and sp:IsA("BasePart") then
                dest = sp.Position + Vector3.new(0, 3, 0)
            else
                local hb = plot:FindFirstChild("Hitbox")
                if hb then
                    dest = hb.Position + Vector3.new(0, 5, 0)
                end
            end
            if dest then
                stagedTeleport(dest, 350, 1.2)
            end
        end
    end)
end
TpSub:AddButton({ Name = "Teleport to Base", Primary = false, Callback = function()
    tpToBase()
end })
TpSub:AddToggle({ Name = "Q Key to Base", Default = true, Flag = "bs_tp_q", Callback = function(v)
    Config.tpKeyQ = v
end })
TpSub:AddButton({ Name = "Teleport to Nearest Egg", Primary = false, Callback = function()
    pcall(function()
        local char, hrp = getChar()
        if char then
            local egg = nearestLiveEgg(hrp.Position, 100000, true)
            if egg then
                stagedTeleport(egg.Position + Vector3.new(0, 3, 0))
            elseif notifyHub then
                notifyHub({ Title = "Teleport", Content = "No live eggs found", Type = "warning", Duration = 3 })
            end
        end
    end)
end })
TpSub:AddButton({ Name = "Teleport to Egg Machine", Primary = false, Callback = function()
    pcall(function()
        local char = getChar()
        local em = workspace:FindFirstChild("EggMachine")
        if char and em then
            stagedTeleport(em:GetPivot().Position + Vector3.new(0, 4, 0))
        end
    end)
end })
TpSub:AddSection("Zone")
local selectedZone = ""
TpSub:AddDropdown({
    Name = "Zone",
    Options = ZONE_LABELS,
    Default = "",
    Flag = "bs_tp_zone",
    Callback = function(v) selectedZone = v end,
})
TpSub:AddButton({
    Name = "Teleport to Zone",
    Primary = true,
    Callback = function()
        if not selectedZone or selectedZone == "" then
            if notifyHub then notifyHub({ Title = "Teleport", Content = "Select a zone first!", Type = "warning", Duration = 3 }) end
            return
        end
        local n = selectedZone:match("^Zone (%d+)")
        pcall(function()
            local char, hrp = getChar()
            local build = workspace:FindFirstChild("Build")
            local zoneBuilds = build and build:FindFirstChild("ZoneBuilds")
            local zone = zoneBuilds and zoneBuilds:FindFirstChild("Zone" .. tostring(n))
            if char and zone and hrp then
                local zp = zone:GetPivot().Position
                local from = hrp.Position
                local full = (zp - from).Magnitude
                local target = zp + Vector3.new(0, 5, 0)
                if full > 100 then
                    target = from + (zp - from).Unit * (full - 60) + Vector3.new(0, 5, 0)
                end
                stagedTeleport(target, 300, 1.2)
                if notifyHub then notifyHub({ Title = "Teleport", Content = "Teleporting to " .. selectedZone, Type = "success", Duration = 3 }) end
            elseif notifyHub then
                notifyHub({ Title = "Teleport", Content = "Zone not found", Type = "error", Duration = 3 })
            end
        end)
    end,
})

do
    local UIS = game:GetService("UserInputService")
    local lastQ = 0
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Q and Config.tpKeyQ then
            if os.clock() - lastQ > 0.3 and not UIS:GetFocusedTextBox() then
                lastQ = os.clock()
                tpToBase()
            end
        end
    end)
end

ESPSub:AddSection("ESP")
ESPSub:AddToggle({ Name = "ESP Eggs", Default = false, Flag = "bs_esp_eggs", Callback = function(v)
    Config.espEggs = v
    if not v then
        for _, inst in ipairs(workspace:GetDescendants()) do
            if (inst.Name == "_BSESP" and inst:IsA("Highlight")) or (inst.Name == "_BSESPV" and inst:IsA("BillboardGui")) then
                inst:Destroy()
            end
        end
    end
end })
ESPSub:AddToggle({ Name = "ESP Animals", Default = false, Flag = "bs_esp_animals", Callback = function(v)
    Config.espAnimals = v
    if not v then
        local ap = workspace:FindFirstChild("AnimalPickups")
        if ap then
            for _, m in ipairs(ap:GetChildren()) do
                local h = m:FindFirstChild("_BSESP")
                if h then h:Destroy() end
            end
        end
    end
end })

local SettingsSub = SettingsTab:AddSubTab("Config")
autosaveWrap(SettingsSub)
SettingsSub:AddSection("Config")
local selectedConfig = ""
local configDropdown = SettingsSub:AddDropdown({ Name = "Saved Configs", Options = {}, Default = "", Flag = "cfg_sel", Callback = function(v) selectedConfig = v end })
local function refreshConfigList() local c = Library:ListConfigs() if configDropdown then configDropdown:SetOptions(c); configDropdown:Refresh() end end
local configInput = SettingsSub:AddInput({ Name = "Config Name", Default = "", Placeholder = "Enter config name...", Flag = "cfg_name" })
SettingsSub:AddDivider()
SettingsSub:AddButton({ Name = "Save Config", Primary = true, Callback = function()
    local name = configInput:Get() if not name or name == "" then Window:Notify({Title="Config",Content="Enter a name!",Type="warning",Duration=3}) return end
    if Library:SaveConfig(name) then refreshConfigList(); Window:Notify({Title="Config",Content="Saved: "..name,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end })
SettingsSub:AddButton({ Name = "Load Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then Window:Notify({Title="Config",Content="Select config!",Type="warning",Duration=3}) return end
    if Library:LoadConfig(selectedConfig) then refreshConfigList(); Window:Notify({Title="Config",Content="Loaded: "..selectedConfig,Type="success",Duration=3}) else Window:Notify({Title="Config",Content="Failed!",Type="error",Duration=3}) end
end })
SettingsSub:AddButton({ Name = "Delete Config", Primary = false, Callback = function()
    if not selectedConfig or selectedConfig == "" then return end
    Library:DeleteConfig(selectedConfig); local old = selectedConfig; selectedConfig = ""; refreshConfigList()
    Window:Notify({Title="Config",Content="Deleted: "..old,Type="info",Duration=3})
end })

local ServerSub = SettingsTab:AddSubTab("Server")
ServerSub:AddSection("Server")
ServerSub:AddButton({ Name = "Server Hop", Primary = true, Callback = function()
    Window:Notify({Title="Server Hop",Content="Finding new server...",Type="info",Duration=3})
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
end })

pcall(function() Library:LoadConfig("default") end)
pcall(function()
    Config.breakZones = zoneSetFromList(Library:GetFlag("bs_break_zones"))
end)
pcall(function()
    local sel = Library:GetFlag("bs_steal_rarities")
    local set = {}
    if type(sel) == "table" then
        for _, r in ipairs(sel) do set[r] = true end
    end
    Config.stealRarities = set
    Config.stealMinWeight = tonumber(Library:GetFlag("bs_steal_minwt")) or 0
    Config.stealMaxDist = tonumber(Library:GetFlag("bs_steal_maxdist")) or 700
    Config.dmgMult = tonumber(Library:GetFlag("bs_dmg_mult")) or 1
end)
pcall(refreshConfigList)

if notifyHub then
    notifyHub({ Title = "Exlumiaa Hub", Content = "Break and Steal an Egg loaded (v1)", Type = "success", Duration = 4 })
end
