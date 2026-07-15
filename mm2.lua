-- [[ DELTA MM2 PREMIUM ULTIMATE V3.1 (V2 REBORN) ]]
-- [[ Разработчики: Makanbaev Aidar & Zoya ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- [[ Глобальные состояния и бэкапы ]]
_G.DeltaConfig = {
    ESP = false,
    AutoAim = false,
    AutoFarm = false,
    Fullbright = false,
    CozyMode = false,
    GunIndicator = false,
    AntiAFK = false,
    RoundInfo = false,
    AliveCount = false,
    SheriffSound = false,
    GunSound = false,
    KillAll = false,
    AntiFling = false,
    Fling = false,
    FlingTarget = "",
    PixelBoost = false,
    TextureBoost = false,
    ButtonSize = 50,
    ButtonTransparency = 0.2,
    MenuColor = Color3.fromRGB(255, 30, 30) -- Фирменный красный V2 по умолчанию
}

local OriginalMaterials = {}
local Connections = {}
local GunHighlight = nil
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    QualityLevel = settings().Rendering.QualityLevel
}

local Murderer = nil
local Sheriff = nil

local function GetMM2Roles()
    Murderer = nil
    Sheriff = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local hasKnife = player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")
            local hasGun = player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun")
            if hasKnife then Murderer = player
            elseif hasGun then Sheriff = player end
        end
    end
end

-- [[ Инициализация GUI ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2V3Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 350)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Шапка в стиле V2
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 10)
HeaderCover.Position = UDim2.new(0, 0, 1, -10)
HeaderCover.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DELTA MM2 ULTIMATE V3.1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = _G.DeltaConfig.MenuColor
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 24
CloseBtn.Parent = Header

-- Панель Вкладок слева (классика V2)
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 80, 1, -35)
LeftPanel.Position = UDim2.new(0, 0, 0, 35)
LeftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 8)
LeftCorner.Parent = LeftPanel

local ContainerFrame = Instance.new("Frame")
ContainerFrame.Size = UDim2.new(1, -85, 1, -45)
ContainerFrame.Position = UDim2.new(0, 85, 0, 40)
ContainerFrame.BackgroundTransparency = 1
ContainerFrame.Parent = MainFrame

local Tabs = {}

local function CreateTab(name, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.Position = UDim2.new(0, 0, 0, (order-1) * 32)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = (order == 1) and _G.DeltaConfig.MenuColor or Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 12
    TabBtn.Parent = LeftPanel

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0, 0, 0, 420)
    Page.ScrollBarThickness = 2
    Page.Visible = (order == 1)
    Page.Parent = ContainerFrame

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.Parent = Page

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            t.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        Page.Visible = true
        TabBtn.TextColor3 = _G.DeltaConfig.MenuColor
    end)

    Tabs[name] = {Page = Page, Btn = TabBtn}
    return Page
end

-- Вкладки
local PageFunctions = CreateTab("Функции", 1)
local PageUtils = CreateTab("Утилиты", 2)
local PageExploits = CreateTab("Эксплойт", 3)
local PageFps = CreateTab("FPS Буст", 4)
local PageThemes = CreateTab("Кастомизация", 5)
local PageSettings = CreateTab("Настройки", 6)
local PageCredits = CreateTab("Кредиты", 7)
-- Быстрые уведомления
local function CreateNotify(title, text, color)
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(0, 200, 0, 50)
    NotifyFrame.Position = UDim2.new(1, 10, 0.85, -60)
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Parent = ScreenGui

    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 6)
    NotifyCorner.Parent = NotifyFrame

    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 4, 1, 0)
    SideBar.BackgroundColor3 = color or _G.DeltaConfig.MenuColor
    SideBar.BorderSizePixel = 0
    SideBar.Parent = NotifyFrame

    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -15, 0, 18)
    NTitle.Position = UDim2.new(0, 10, 0, 4)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NTitle.Font = Enum.Font.SourceSansBold
    NTitle.TextSize = 12
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = NotifyFrame

    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -15, 0, 24)
    NText.Position = UDim2.new(0, 10, 0, 20)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(200, 200, 200)
    NText.Font = Enum.Font.SourceSans
    NText.TextSize = 11
    NText.TextWrapped = true
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = NotifyFrame

    NotifyFrame:TweenPosition(UDim2.new(1, -210, 0.85, -60), "Out", "Quart", 0.3, true)
    task.delay(3, function()
        if NotifyFrame and NotifyFrame.Parent then
            NotifyFrame:TweenPosition(UDim2.new(1, 10, 0.85, -60), "In", "Quart", 0.3, true, function()
                NotifyFrame:Destroy()
            end)
        end
    end)
end

-- Динамическое обновление тем меню
local function UpdateMenuTheme(newColor)
    _G.DeltaConfig.MenuColor = newColor
    CloseBtn.TextColor3 = newColor
    for name, tab in pairs(Tabs) do
        if tab.Page.Visible then
            tab.Btn.TextColor3 = newColor
        end
    end
    -- Находим все включенные кнопки в контейнере и перекрашиваем их
    for _, child in ipairs(ContainerFrame:GetDescendants()) do
        if child:IsA("TextButton") and child.Name == "ToggleBtn" and child.BackgroundColor3 ~= Color3.fromRGB(35, 35, 35) then
            child.BackgroundColor3 = newColor
        end
    end
    local mobBtn = ScreenGui:FindFirstChild("DeltaOpenBtn")
    if mobBtn then mobBtn.TextColor3 = newColor end
end

-- Конструктор переключателей (Toggle)
local function CreateToggle(parent, text, configKey, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Name = "ToggleBtn"
    Button.Size = UDim2.new(0, 40, 0, 18)
    Button.Position = UDim2.new(1, -45, 0.5, -9)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.Text = ""
    Button.Parent = ToggleFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 9)
    ButtonCorner.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = UDim2.new(0, 2, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Indicator.Parent = Button

    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 7)

    local function updateVisuals(state)
        if state then
            Button.BackgroundColor3 = _G.DeltaConfig.MenuColor
            Indicator.Position = UDim2.new(1, -16, 0.5, -7)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Indicator.Position = UDim2.new(0, 2, 0.5, -7)
            Indicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        end
    end

    Button.MouseButton1Click:Connect(function()
        _G.DeltaConfig[configKey] = not _G.DeltaConfig[configKey]
        updateVisuals(_G.DeltaConfig[configKey])
        if callback then callback(_G.DeltaConfig[configKey]) end
    end)
    
    updateVisuals(_G.DeltaConfig[configKey])
end
-- Улучшенный ESP с Дистанцией и Никами
local function UpdateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local highlight = p.Character:FindFirstChild("Delta_Highlight")
            local billG = p.Character.Head:FindFirstChild("Delta_ESP_Label")

            if _G.DeltaConfig.ESP then
                -- 1. Цветовая Подсветка (Highlight)
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "Delta_Highlight"
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0.2
                    highlight.Parent = p.Character
                end

                local isMerd = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                local isSher = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                local roleColor = Color3.fromRGB(0, 255, 100) -- Невиновный

                if isMerd then
                    roleColor = Color3.fromRGB(255, 0, 0) -- Убийца
                elseif isSher then
                    roleColor = Color3.fromRGB(0, 150, 255) -- Шериф
                end
                highlight.FillColor = roleColor

                -- 2. Текстовая Индикация (BillboardGui)
                if not billG then
                    billG = Instance.new("BillboardGui")
                    billG.Name = "Delta_ESP_Label"
                    billG.AlwaysOnTop = true
                    billG.Size = UDim2.new(0, 100, 0, 30)
                    billG.ExtentsOffset = Vector3.new(0, 2.5, 0)
                    billG.Parent = p.Character.Head

                    local lbl = Instance.new("TextLabel", billG)
                    lbl.Name = "Label"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.SourceSansBold
                    lbl.TextSize = 10
                    lbl.TextStrokeTransparency = 0
                end

                local distance = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude) or 0)
                local roleName = isMerd and "[MURDER]" or (isSher and "[SHERIFF]" or "[HERO]")
                billG.Label.TextColor3 = roleColor
                billG.Label.Text = p.Name .. "\n" .. roleName .. " | " .. tostring(distance) .. "s"
            else
                if highlight then highlight:Destroy() end
                if billG then billG:Destroy() end
            end
        end
    end
end

CreateToggle(PageFunctions, "MM2 ESP (Ники + Роли + Студы)", "ESP", function(s)
    if s then table.insert(Connections, RunService.Heartbeat:Connect(UpdateESP)) end
end)

-- РАБОЧИЙ ESP Пистолета на полу
local function UpdateGunESP()
    local gun = Workspace:FindFirstChild("GunDrop")
    if gun and _G.DeltaConfig.GunIndicator then
        local gunModel = gun:FindFirstChildOfClass("Model") or gun
        if not GunHighlight then
            GunHighlight = Instance.new("Highlight")
            GunHighlight.Name = "GunDrop_Highlight"
            GunHighlight.FillColor = Color3.fromRGB(255, 255, 0)
            GunHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            GunHighlight.FillTransparency = 0.3
            GunHighlight.Parent = gunModel
        end
    else
        if GunHighlight then GunHighlight:Destroy(); GunHighlight = nil end
    end
end

CreateToggle(PageFunctions, "ESP Пистолета на полу", "GunIndicator", function(s)
    if s then table.insert(Connections, RunService.Heartbeat:Connect(UpdateGunESP)) end
end)

-- Auto-Aim
local function GetAimTarget()
    GetMM2Roles()
    local isMeMerd = LocalPlayer.Backpack:FindFirstChild("Knife") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife"))
    local target = isMeMerd and Sheriff or Murderer
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        return target.Character.HumanoidRootPart
    end
    return nil
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if _G.DeltaConfig.AutoAim then
        local target = GetAimTarget()
        if target then
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
end))
CreateToggle(PageFunctions, "Авто-Аимбот (Auto-Aim)", "AutoAim", nil)

-- Автофарм Монет
local function FarmCoins()
    while _G.DeltaConfig.AutoFarm do
        task.wait(0.3)
        local container = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("SandBox")
        local coins = container and container:FindFirstChild("CoinContainer")
        if coins and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, coin in ipairs(coins:GetChildren()) do
                if _G.DeltaConfig.AutoFarm and coin:IsA("BasePart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
                    task.wait(0.3)
                end
            end
        end
    end
end
CreateToggle(PageFunctions, "Автофарм монет", "AutoFarm", function(s) if s then task.spawn(FarmCoins) end end)

-- Освещение (Fullbright)
CreateToggle(PageFunctions, "Освещение (Fullbright)", "Fullbright", function(s)
    if s then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end)

-- Cozy Mode
CreateToggle(PageFunctions, "Cozy Mode (Шейдер)", "CozyMode", function(s)
    local cc = Lighting:FindFirstChild("Delta_Cozy") or Instance.new("ColorCorrectionEffect", Lighting)
    cc.Name = "Delta_Cozy"
    cc.TintColor = Color3.fromRGB(255, 195, 135)
    cc.Enabled = s
end)
local InfoFrame = Instance.new("Frame", PageUtils)
InfoFrame.Size = UDim2.new(1, 0, 0, 50)
InfoFrame.BackgroundTransparency = 0.95
InfoFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

local RoundLabel = Instance.new("TextLabel", InfoFrame)
RoundLabel.Size = UDim2.new(1, -10, 0, 20)
RoundLabel.Position = UDim2.new(0, 10, 0, 5)
RoundLabel.BackgroundTransparency = 1
RoundLabel.Text = "Статус раунда: Не активен"
RoundLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RoundLabel.Font = Enum.Font.SourceSansBold
RoundLabel.TextSize = 13
RoundLabel.TextXAlignment = Enum.TextXAlignment.Left

local AliveLabel = Instance.new("TextLabel", InfoFrame)
AliveLabel.Size = UDim2.new(1, -10, 0, 20)
AliveLabel.Position = UDim2.new(0, 10, 0, 25)
AliveLabel.BackgroundTransparency = 1
AliveLabel.Text = "Живых игроков: Выключено"
AliveLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AliveLabel.Font = Enum.Font.SourceSans
AliveLabel.TextSize = 12
AliveLabel.TextXAlignment = Enum.TextXAlignment.Left

local function GetAliveCount()
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if not p.Backpack:FindFirstChild("Spectator") and not p.Character:FindFirstChild("Spectator") then
                count = count + 1
            end
        end
    end
    return count
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if _G.DeltaConfig.RoundInfo then
        GetMM2Roles()
        RoundLabel.Text = "Статус раунда: " .. (Murderer and "ИГРА АКТИВНА ⚔️" or "В ЛОББИ ⌛")
    end
    if _G.DeltaConfig.AliveCount then
        AliveLabel.Text = "Живых игроков: " .. tostring(GetAliveCount())
    end
end))

CreateToggle(PageUtils, "Информация о раунде", "RoundInfo", nil)
CreateToggle(PageUtils, "Счетчик живых игроков", "AliveCount", nil)

-- Анти-АФК
CreateToggle(PageUtils, "Анти-АФК (Защита)", "AntiAFK", nil)
LocalPlayer.Idled:Connect(function()
    if _G.DeltaConfig.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end
end)

-- Звуковые Системы
CreateToggle(PageUtils, "Звук поднятия пистолета", "GunSound", nil)
CreateToggle(PageUtils, "Звук смерти Шерифа", "SheriffSound", nil)

local SheriffAlive = false
local GunOnFloor = false

table.insert(Connections, RunService.Heartbeat:Connect(function()
    GetMM2Roles()
    -- Звук пистолета
    local gun = Workspace:FindFirstChild("GunDrop")
    if gun and not GunOnFloor then
        GunOnFloor = true
        if _G.DeltaConfig.GunSound then
            local s = Instance.new("Sound", Workspace)
            s.SoundId = "rbxassetid://12221967" -- Пинг
            s:Play()
            task.delay(1.5, function() s:Destroy() end)
        end
    elseif not gun then
        GunOnFloor = false
    end

    -- Звук сирены Шерифа
    if Sheriff then
        local hum = Sheriff.Character and Sheriff.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            SheriffAlive = true
        elseif hum and hum.Health <= 0 and SheriffAlive then
            SheriffAlive = false
            CreateNotify("ВНИМАНИЕ", "Шериф мертв! Пистолет на полу!", Color3.fromRGB(255, 30, 30))
            if _G.DeltaConfig.SheriffSound then
                local s = Instance.new("Sound", Workspace)
                s.SoundId = "rbxassetid://138080512" -- Сирена
                s.Volume = 2
                s:Play()
                task.delay(2.5, function() s:Destroy() end)
            end
        end
    else
        SheriffAlive = false
    end
end))

-- [[ ЭКСПЛОЙТЫ ]]
local TargetBox = Instance.new("TextBox", PageExploits)
TargetBox.Size = UDim2.new(1, 0, 0, 30)
TargetBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TargetBox.PlaceholderText = "Никнейм цели для Флинга..."
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.Font = Enum.Font.SourceSansBold
TargetBox.TextSize = 13
Instance.new("UICorner", TargetBox).CornerRadius = UDim.new(0, 6)

TargetBox.FocusLost:Connect(function()
    _G.DeltaConfig.FlingTarget = TargetBox.Text
end)

-- Анти-Флинг
CreateToggle(PageExploits, "Анти-Флинг (No Collide)", "AntiFling", nil)
table.insert(Connections, RunService.Stepped:Connect(function()
    if _G.DeltaConfig.AntiFling and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

-- Улучшенный Флинг с Автопреследованием цели до смерти
local function RunFling()
    local targetName = _G.DeltaConfig.FlingTarget:lower()
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #targetName) == targetName then
            target = p
            break
        end
    end

    if target and target.Character and LocalPlayer.Character then
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
        
        if myHRP and targetHRP and targetHum then
            local origCFrame = myHRP.CFrame
            
            -- Создаем мощный крутящий импульс
            local bodyVel = Instance.new("BodyVelocity", myHRP)
            bodyVel.MaxForce = Vector3.new(1, 1, 1) * 999999
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            
            local bodyAng = Instance.new("BodyAngularVelocity", myHRP)
            bodyAng.MaxTorque = Vector3.new(1, 1, 1) * 999999
            bodyAng.AngularVelocity = Vector3.new(0, 9999, 0) -- Вращение на бешеной скорости
            
            CreateNotify("ЭКСПЛУАТАЦИЯ", "Преследую цель: " .. target.Name, Color3.fromRGB(255, 150, 0))
            
            while _G.DeltaConfig.Fling and targetHum.Health > 0 and target.Character.Parent do
                task.wait()
                if myHRP and targetHRP then
                    -- Намертво прилипаем к цели и бьем физикой
                    myHRP.Velocity = Vector3.new(9999, 9999, 9999)
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(math.random(-1, 1)/10, 0, math.random(-1, 1)/10)
                end
            end
            
            bodyVel:Destroy()
            bodyAng:Destroy()
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.RotVelocity = Vector3.new(0, 0, 0)
            myHRP.CFrame = origCFrame
            _G.DeltaConfig.Fling = false
            CreateNotify("ЭКСПЛУАТАЦИЯ", "Цель мертва или флинг выключен!", Color3.fromRGB(0, 255, 100))
        end
    else
        CreateNotify("ОШИБКА", "Цель не найдена!", Color3.fromRGB(255, 30, 30))
        _G.DeltaConfig.Fling = false
    end
end

CreateToggle(PageExploits, "Флинг цели (Авто-Преследование)", "Fling", function(s)
    if s then task.spawn(RunFling) end
end)

-- Kill All за Мардера
CreateToggle(PageExploits, "Убить всех (Только за Мардера)", "KillAll", function(s)
    if s then
        local char = LocalPlayer.Character
        local knife = char and (char:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife"))
        if not knife then
            CreateNotify("ОШИБКА", "У вас нет ножа!", Color3.fromRGB(255, 30, 30))
            _G.DeltaConfig.KillAll = false
            return
        end
        if knife.Parent == LocalPlayer.Backpack then knife.Parent = char end
        
        task.spawn(function()
            local origCFrame = char.HumanoidRootPart.CFrame
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if p.Character.Humanoid.Health > 0 and _G.DeltaConfig.KillAll then
                        char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                        task.wait(0.12)
                        knife:Activate()
                        task.wait(0.08)
                    end
                end
            end
            char.HumanoidRootPart.CFrame = origCFrame
            _G.DeltaConfig.KillAll = false
        end)
    end
end)
-- Режим без текстур (FPS)
CreateToggle(PageFps, "Режим без текстур", "TextureBoost", function(s)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if s then OriginalMaterials[obj] = obj.Texture; obj.Texture = ""
            else obj.Texture = OriginalMaterials[obj] or "" end
        elseif obj:IsA("BasePart") then
            if s then OriginalMaterials[obj] = obj.Material; obj.Material = Enum.Material.SmoothPlastic
            else obj.Material = OriginalMaterials[obj] or Enum.Material.Plastic end
        end
    end
end)

-- [[ КАСТОМИЗАЦИЯ И ТЕМЫ ]]
local Colors = {
    {"Красный (V2)", Color3.fromRGB(255, 30, 30)},
    {"Фиолетовый", Color3.fromRGB(130, 30, 255)},
    {"Бирюзовый", Color3.fromRGB(0, 230, 230)},
    {"Зеленый", Color3.fromRGB(30, 255, 30)},
    {"Сакура", Color3.fromRGB(255, 105, 180)}
}

for _, t in ipairs(Colors) do
    local colorBtn = Instance.new("TextButton", PageThemes)
    colorBtn.Size = UDim2.new(1, 0, 0, 26)
    colorBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    colorBtn.Text = "Тема: " .. t[1]
    colorBtn.TextColor3 = t[2]
    colorBtn.Font = Enum.Font.SourceSansBold
    colorBtn.TextSize = 13
    Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 6)
    
    colorBtn.MouseButton1Click:Connect(function()
        UpdateMenuTheme(t[2])
        CreateNotify("ТЕМА ИЗМЕНЕНА", "Цветовая гамма обновлена!", t[2])
    end)
end

-- Изменение кнопки "D" (Размер)
local SizeLabel = Instance.new("TextLabel", PageThemes)
SizeLabel.Size = UDim2.new(1, 0, 0, 20)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "Управление кнопкой открытия:"
SizeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SizeLabel.Font = Enum.Font.SourceSans
SizeLabel.TextSize = 12

local ChangeSizeBtn = Instance.new("TextButton", PageThemes)
ChangeSizeBtn.Size = UDim2.new(1, 0, 0, 26)
ChangeSizeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ChangeSizeBtn.Text = "Размер кнопки [50]"
ChangeSizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChangeSizeBtn.Font = Enum.Font.SourceSansBold
ChangeSizeBtn.TextSize = 12
Instance.new("UICorner", ChangeSizeBtn).CornerRadius = UDim.new(0, 6)

ChangeSizeBtn.MouseButton1Click:Connect(function()
    local mobBtn = ScreenGui:FindFirstChild("DeltaOpenBtn")
    if mobBtn then
        if _G.DeltaConfig.ButtonSize == 50 then
            _G.DeltaConfig.ButtonSize = 70
        elseif _G.DeltaConfig.ButtonSize == 70 then
            _G.DeltaConfig.ButtonSize = 35
        else
            _G.DeltaConfig.ButtonSize = 50
        end
        ChangeSizeBtn.Text = "Размер кнопки [" .. tostring(_G.DeltaConfig.ButtonSize) .. "]"
        mobBtn.Size = UDim2.new(0, _G.DeltaConfig.ButtonSize, 0, _G.DeltaConfig.ButtonSize)
    end
end)

-- Изменение прозрачности "D"
local ChangeTransBtn = Instance.new("TextButton", PageThemes)
ChangeTransBtn.Size = UDim2.new(1, 0, 0, 26)
ChangeTransBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ChangeTransBtn.Text = "Прозрачность кнопки [0.2]"
ChangeTransBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChangeTransBtn.Font = Enum.Font.SourceSansBold
ChangeTransBtn.TextSize = 12
Instance.new("UICorner", ChangeTransBtn).CornerRadius = UDim.new(0, 6)

ChangeTransBtn.MouseButton1Click:Connect(function()
    local mobBtn = ScreenGui:FindFirstChild("DeltaOpenBtn")
    if mobBtn then
        if _G.DeltaConfig.ButtonTransparency == 0.2 then
            _G.DeltaConfig.ButtonTransparency = 0.6
        elseif _G.DeltaConfig.ButtonTransparency == 0.6 then
            _G.DeltaConfig.ButtonTransparency = 0.0
        else
            _G.DeltaConfig.ButtonTransparency = 0.2
        end
        ChangeTransBtn.Text = "Прозрачность кнопки [" .. tostring(_G.DeltaConfig.ButtonTransparency) .. "]"
        mobBtn.BackgroundTransparency = _G.DeltaConfig.ButtonTransparency
    end
end)

-- Настройки и Выгрузка
local UnloadBtn = Instance.new("TextButton", PageSettings)
UnloadBtn.Size = UDim2.new(1, 0, 0, 30)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
UnloadBtn.Text = "ПОЛНАЯ ВЫГРУЗКА СКРИПТА"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 13
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)

UnloadBtn.MouseButton1Click:Connect(function()
    for _, conn in ipairs(Connections) do if conn then conn:Disconnect() end end
    Lighting.Ambient = OriginalLighting.Ambient
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("Delta_Highlight") then p.Character.Delta_Highlight:Destroy() end
            if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("Delta_ESP_Label") then p.Character.Head.Delta_ESP_Label:Destroy() end
        end
    end
    if GunHighlight then GunHighlight:Destroy() end
    ScreenGui:Destroy()
end)

-- Кредиты
local CreditsLabel = Instance.new("TextLabel", PageCredits)
CreditsLabel.Size = UDim2.new(1, 0, 1, 0)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text = "Разработчики софта:\n⭐ Makanbaev Aidar & Zoya ⭐\n\nDelta Premium v3.1 (Extended Edition)\n\nУдачной игры и жесткого фана! 🔥"
CreditsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
CreditsLabel.Font = Enum.Font.SourceSansBold
CreditsLabel.TextSize = 13
CreditsLabel.TextWrapped = true

-- Кнопка "D" для Мобильных устройств
local MobileButton = Instance.new("TextButton", ScreenGui)
MobileButton.Name = "DeltaOpenBtn"
MobileButton.Size = UDim2.new(0, _G.DeltaConfig.ButtonSize, 0, _G.DeltaConfig.ButtonSize)
MobileButton.Position = UDim2.new(0, 15, 0.5, -25)
MobileButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MobileButton.BackgroundTransparency = _G.DeltaConfig.ButtonTransparency
MobileButton.Text = "D"
MobileButton.TextColor3 = _G.DeltaConfig.MenuColor
MobileButton.Font = Enum.Font.SourceSansBold
MobileButton.TextSize = 22
MobileButton.Active = true
MobileButton.Draggable = true
Instance.new("UICorner", MobileButton).CornerRadius = UDim.new(0, 8)

-- Открытие / Закрытие
local function ToggleGui()
    MainFrame.Visible = not MainFrame.Visible
end

MobileButton.MouseButton1Click:Connect(ToggleGui)
CloseBtn.MouseButton1Click:Connect(ToggleGui)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then ToggleGui() end
end)

CreateNotify("Delta Premium V3.1", "Скрипт полностью обновлен!", Color3.fromRGB(0, 255, 100))
