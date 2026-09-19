if tostring(game.GameId) ~= "10717002748" then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local _G_TOMB = "_ _dmgHubTomb19"
local _G_ALIVE = "_ _dmgHubAlive19"

do
    local alive = rawget(_G, _G_ALIVE)
    if alive == true then
        rawset(_G, _G_TOMB, true)
        task.wait(0.5)
    end
    rawset(_G, _G_TOMB, false)
    rawset(_G, _G_ALIVE, true)
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
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
    end)
    Library = ok and ret or nil
end)
for _ = 1, 60 do
    if Library ~= nil then break end
    task.wait(0.25)
end
if not Library then return end

Library.ConfigFolder = "exlumiaa"

local Config = {
    autoShoot = false,
    walkSpeed = 16,
    walkEnabled = false,
}

local originalWalkSpeed = 16

local function getNearestEnemy(origin)
    local best, bestDist = nil, math.huge
    for _, tag in ipairs(CollectionService:GetTagged("EnemyToy")) do
        local model = tag
        if not model:IsA("Model") then
            model = tag:FindFirstAncestorOfClass("Model")
        end
        if model and model:IsA("Model") then
            local hrp = model:FindFirstChild("HumanoidRootPart")
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (origin - hrp.Position).Magnitude
                if d < bestDist then
                    best = { model = model, hrp = hrp, hum = hum }
                    bestDist = d
                end
            end
        end
    end
    return best, bestDist
end

local origIsAutoShootEnabled = nil
local origUsesAutoShoot = nil
local origHasEnemy = nil
local origShoot = nil
local savedAFK = nil
local hookActive = false

local function hookAll()
    if hookActive then return end
    hookActive = true

    local okCA, CombatAssist = pcall(function()
        return require(LP.PlayerScripts.Core.CombatAssist)
    end)
    if okCA and CombatAssist then
        origIsAutoShootEnabled = CombatAssist.isAutoShootEnabled
        origUsesAutoShoot = CombatAssist.usesAutoShoot
        CombatAssist.isAutoShootEnabled = function() return true end
        CombatAssist.usesAutoShoot = function() return true end
    end

    local okBC, BC = pcall(function()
        return require(LP.PlayerScripts.Features.Blaster.BlasterClient)
    end)
    if not okBC or type(BC) ~= "table" then return end

    local idx = BC.__index
    if not idx or typeof(idx) ~= "table" then return end

    origHasEnemy = idx.hasEnemyUnderCrosshair
    origShoot = idx.shoot

    idx.hasEnemyUnderCrosshair = function(self)
        local char = LP.Character
        if not char then return false end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return false end
        local enemy = getNearestEnemy(myHRP.Position)
        return enemy ~= nil
    end

    idx.shoot = function(self, ...)
        local char = LP.Character
        if char then
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local enemy, dist = getNearestEnemy(myHRP.Position)
                if enemy and dist <= 500 then
                    savedAFK = LP:GetAttribute("AFKTraining")
                    LP:SetAttribute("AFKTraining", true)
                    self.afkTarget = enemy.hrp.Position + Vector3.new(0, 1.5, 0)
                    local ok, result = pcall(origShoot, self, ...)
                    self.afkTarget = nil
                    LP:SetAttribute("AFKTraining", savedAFK)
                    savedAFK = nil
                    if not ok then warn("[ExlumiaaHub] shoot err: " .. tostring(result)) end
                    return result
                end
            end
        end
        return origShoot(self, ...)
    end
end

local function unhookAll()
    pcall(function()
        local _, CA = pcall(require, LP.PlayerScripts.Core.CombatAssist)
        if CA then
            if origIsAutoShootEnabled then CA.isAutoShootEnabled = origIsAutoShootEnabled end
            if origUsesAutoShoot then CA.usesAutoShoot = origUsesAutoShoot end
        end
    end)

    pcall(function()
        local _, BC = pcall(require, LP.PlayerScripts.Features.Blaster.BlasterClient)
        if BC and type(BC) == "table" and BC.__index then
            local idx = BC.__index
            if origHasEnemy then idx.hasEnemyUnderCrosshair = origHasEnemy end
            if origShoot then idx.shoot = origShoot end
        end
    end)

    if savedAFK ~= nil then
        LP:SetAttribute("AFKTraining", savedAFK)
        savedAFK = nil
    end
    origIsAutoShootEnabled = nil
    origUsesAutoShoot = nil
    origHasEnemy = nil
    origShoot = nil
    hookActive = false
end

local mainConn
mainConn = RunService.RenderStepped:Connect(function()
    if rawget(_G, _G_TOMB) then
        if mainConn then mainConn:Disconnect() end
        unhookAll()
        return
    end
    Camera = workspace.CurrentCamera
end)

local walkConn
local function applyWalkSpeed()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.walkEnabled then
                hum.WalkSpeed = Config.walkSpeed
            else
                hum.WalkSpeed = originalWalkSpeed
            end
        end
    end
end

local Window = Library:CreateWindow({
    Name = "Exlumiaa Hub",
    BrandSubtitle = "+1 DMG FPS",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    LoadingAnimation = true,
    LoadingText = "Exlumiaa Hub",
    LoadingSubtitle = "+1 DMG FPS",
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
local labelPlayers = HomeSub:AddLabel({Text = "Players: " .. #Players:GetPlayers()})
local labelFPS = HomeSub:AddLabel({Text = "FPS: --"})

HomeSub:AddSection("Game")
HomeSub:AddLabel({Text = "GameId: " .. tostring(game.GameId)})
HomeSub:AddLabel({Text = "PlaceId: " .. tostring(game.PlaceId)})

HomeSub:AddSection("Server")
HomeSub:AddLabel({Text = "JobId: " .. string.sub(tostring(game.JobId), 1, 20) .. "..."})
HomeSub:AddButton({
    Name = "Copy JobId",
    Callback = function()
        pcall(setclipboard, tostring(game.JobId))
        Window:Notify({Title = "Copied", Content = "JobId copied!", Type = "success", Duration = 3})
    end,
})

task.spawn(function()
    while true do
        task.wait(1)
        if rawget(_G, _G_TOMB) then break end
        pcall(function()
            labelPlayers:Set("Players: " .. #Players:GetPlayers())
        end)
    end
end)

task.spawn(function()
    local lastTick = tick()
    local frames = 0
    while true do
        if rawget(_G, _G_TOMB) then break end
        frames += 1
        if tick() - lastTick >= 1 then
            pcall(function() labelFPS:Set("FPS: " .. frames) end)
            frames = 0
            lastTick = tick()
        end
        task.wait()
    end
end)

local CombatTab = Window:AddTab({Name = "Combat", Icon = "crosshairs", Subtitle = "Auto"})
local CombatSub = CombatTab:AddSubTab("Features")

CombatSub:AddSection("Auto Farm")
CombatSub:AddToggle({
    Name = "Auto Shoot + Auto Hit",
    Flag = "dmg_autoshoot",
    Default = false,
    Callback = function(v)
        Config.autoShoot = v
        if v then hookAll() else unhookAll() end
    end,
})

local PlayerTab = Window:AddTab({Name = "Player", Icon = "user", Subtitle = "Local"})
local PlayerSub = PlayerTab:AddSubTab("Movement")

PlayerSub:AddSection("WalkSpeed")
PlayerSub:AddToggle({
    Name = "Enable WalkSpeed",
    Flag = "dmg_ws_enable",
    Default = false,
    Callback = function(v)
        Config.walkEnabled = v
        applyWalkSpeed()
    end,
})
PlayerSub:AddSlider({
    Name = "WalkSpeed Value",
    Min = 16,
    Max = 500,
    Default = 16,
    Suffix = " studs/s",
    Flag = "dmg_ws_val",
    Callback = function(v)
        Config.walkSpeed = v
        if Config.walkEnabled then applyWalkSpeed() end
    end,
})

local SettingsTab = Window:AddTab({Name = "Settings", Icon = "settings", Subtitle = "Config"})
local ConfigSub = SettingsTab:AddSubTab("Config")
local HopSub = SettingsTab:AddSubTab("Server Hop")

ConfigSub:AddSection("Config")
local selectedConfig = ""

local configDropdown = ConfigSub:AddDropdown({
    Name = "Saved Configs",
    Options = {},
    Default = "",
    Flag = "dmg_config_selected",
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
    Flag = "dmg_config_name",
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local name = configInput:Get()
        if not name or name == "" then
            Window:Notify({Title = "Config", Content = "Enter a name first!", Type = "warning", Duration = 3})
            return
        end
        local ok = Library:SaveConfig(name)
        if ok then
            refreshConfigList()
            Window:Notify({Title = "Config", Content = "Saved: " .. name, Type = "success", Duration = 3})
        else
            Window:Notify({Title = "Config", Content = "Save failed!", Type = "error", Duration = 3})
        end
    end,
})

ConfigSub:AddButton({
    Name = "Load Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3})
            return
        end
        local ok = Library:LoadConfig(selectedConfig)
        if ok then
            Window:Notify({Title = "Config", Content = "Loaded: " .. selectedConfig, Type = "success", Duration = 3})
        else
            Window:Notify({Title = "Config", Content = "Failed to load!", Type = "error", Duration = 3})
        end
    end,
})

ConfigSub:AddButton({
    Name = "Delete Config",
    Primary = false,
    Callback = function()
        if not selectedConfig or selectedConfig == "" then
            Window:Notify({Title = "Config", Content = "Select a config first!", Type = "warning", Duration = 3})
            return
        end
        Library:DeleteConfig(selectedConfig)
        local old = selectedConfig
        selectedConfig = ""
        refreshConfigList()
        Window:Notify({Title = "Config", Content = "Deleted: " .. old, Type = "info", Duration = 3})
    end,
})

ConfigSub:AddDivider()
ConfigSub:AddSection("Info")
ConfigSub:AddLabel({Text = "by Exlumiaa Hub v20"})
ConfigSub:AddLabel({Text = "Toggle Menu: RightShift"})
ConfigSub:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        pcall(setclipboard, "discord.gg/exlumiaa")
        Window:Notify({Title = "Discord", Content = "Invite copied!", Type = "success", Duration = 3})
    end,
})

HopSub:AddSection("Server Hop")
HopSub:AddButton({
    Name = "Server Hop",
    Primary = true,
    Callback = function()
        Window:Notify({Title = "Server Hop", Content = "Finding a new server...", Type = "info", Duration = 3})
        local ok, err = pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        end)
        if not ok then
            Window:Notify({Title = "Server Hop", Content = "Failed: " .. tostring(err), Type = "error", Duration = 5})
        end
    end,
})

pcall(function() Library:LoadConfig("default") end)
pcall(refreshConfigList)

print("[ExlumiaaHub] +1 DMG FPS Hub v20 loaded!")
