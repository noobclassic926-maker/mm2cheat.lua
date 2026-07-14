-- [[ DELTA MM2 PREMIUM ULTIMATE V3.0 ]]
-- [[ Авторы проекта: Makanbaev Aidar & Zoya ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- [[ Глобальная таблица состояний ]]
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
    PhysicsBoost = false,
    
    WalkSpeed = 16,
    MenuColor = Color3.fromRGB(255, 0, 100),
    ButtonSize = 50,
    ButtonTransparency = 0.2
}

-- [[ Бэкапы окружения ]]
local OriginalMaterials = {}
local EspObjects = {}
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

-- Инициализация ролей
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

-- [[ Определение устройства ]]
local IsMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)

-- [[ Создание GUI ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2PremiumV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 410)
MainFrame.Position = UDim2.new(0.5, -155, 0.4, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Хэдер (Шапка)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DELTA MM2 ULTIMATE V3.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 22
CloseBtn.Parent = Header

-- Контейнер для вкладок
local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabBar.BorderSizePixel = 0
TabBar.CanvasSize = UDim2.new(1.4, 0, 0, 0)
TabBar.ScrollBarThickness = 2
TabBar.Parent = MainFrame

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabBarLayout.Parent = TabBar

local ContainerFrame = Instance.new("Frame")
ContainerFrame.Size = UDim2.new(1, 0, 1, -65)
ContainerFrame.Position = UDim2.new(0, 0, 0, 65)
ContainerFrame.BackgroundTransparency = 1
ContainerFrame.Parent = MainFrame

-- Массив хранения страниц
local Tabs = {}

local function CreateTab(name, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 80, 1, 0)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = (order == 1) and _G.DeltaConfig.MenuColor or Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 12
    TabBtn.LayoutOrder = order
    TabBtn.Parent = TabBar

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -10)
    Page.Position = UDim2.new(0, 10, 0, 5)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0, 0, 0, 450)
    Page.ScrollBarThickness = 2
    Page.Visible = (order == 1)
    Page.Parent = ContainerFrame

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
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

-- Создаем 6 вкладок
local PageFunctions = CreateTab("Функции", 1)
local PageUtils = CreateTab("Утилиты", 2)
local PageExploits = CreateTab("Эксплойт", 3)
local PageFps = CreateTab("FPS Буст", 4)
local PageSettings = CreateTab("Настройки", 5)
local PageCredits = CreateTab("Кредиты", 6)
-- [[ ЧАСТЬ 2: Компоненты UI и Логика "Функций" ]]

-- Утилиты для создания элементов управления
local function CreateToggle(parent, text, configKey, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 22)
    Button.Position = UDim2.new(1, -55, 0.5, -11)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.Text = ""
    Button.Parent = ToggleFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 11)
    ButtonCorner.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = UDim2.new(0, 3, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Indicator.Parent = Button

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 8)
    IndicatorCorner.Parent = Indicator

    local function updateVisuals(state)
        if state then
            Button:TweenBackgroundColor3(_G.DeltaConfig.MenuColor, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
            Indicator:TweenPosition(UDim2.new(1, -19, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button:TweenBackgroundColor3(Color3.fromRGB(35, 35, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
            Indicator:TweenPosition(UDim2.new(0, 3, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
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

-- Система уведомлений на экране
local function CreateNotify(title, text, color)
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(0, 220, 0, 60)
    NotifyFrame.Position = UDim2.new(1, 10, 0.8, -70)
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Parent = ScreenGui

    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 8)
    NotifyCorner.Parent = NotifyFrame

    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 4, 1, 0)
    SideBar.BackgroundColor3 = color or _G.DeltaConfig.MenuColor
    SideBar.BorderSizePixel = 0
    SideBar.Parent = NotifyFrame
    Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 4)

    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -15, 0, 20)
    NTitle.Position = UDim2.new(0, 10, 0, 5)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    NTitle.Font = Enum.Font.SourceSansBold
    NTitle.TextSize = 12
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = NotifyFrame

    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -15, 0, 30)
    NText.Position = UDim2.new(0, 10, 0, 25)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(200, 200, 200)
    NText.Font = Enum.Font.SourceSans
    NText.TextSize = 11
    NText.TextWrapped = true
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = NotifyFrame

    NotifyFrame:TweenPosition(UDim2.new(1, -230, 0.8, -70), "Out", "Quart", 0.3, true)
    task.delay(3, function()
        NotifyFrame:TweenPosition(UDim2.new(1, 10, 0.8, -70), "In", "Quart", 0.3, true, function()
            NotifyFrame:Destroy()
        end)
    end)
end

-- [[ ЛОГИКА ВКЛАДКИ: ФУНКЦИИ ]]

-- 1. MM2 ESP (Никнеймы, Коробки и Подсветка ролей)
local function UpdateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local highlight = char:FindFirstChild("Delta_Highlight")
            
            if _G.DeltaConfig.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "Delta_Highlight"
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0.2
                    highlight.Parent = char
                end
                
                -- Распознавание ролей по инвентарю
                local isMerd = p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
                local isSher = p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
                
                if isMerd then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
                elseif isSher then
                    highlight.FillColor = Color3.fromRGB(0, 100, 255)
                    highlight.OutlineColor = Color3.fromRGB(100, 200, 255)
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 100)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

CreateToggle(PageFunctions, "MM2 ESP (Все игроки)", "ESP", function(state)
    if state then
        table.insert(Connections, RunService.Heartbeat:Connect(UpdateESP))
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Delta_Highlight") then
                p.Character.Delta_Highlight:Destroy()
            end
        end
    end
end)

-- 2. ESP Пистолета (Подсветка лежащей пушки)
local function UpdateGunESP()
    local gun = Workspace:FindFirstChild("GunDrop")
    if gun and _G.DeltaConfig.GunIndicator then
        if not GunHighlight then
            GunHighlight = Instance.new("Highlight")
            GunHighlight.Name = "GunDrop_Highlight"
            GunHighlight.FillColor = Color3.fromRGB(255, 255, 0)
            GunHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            GunHighlight.FillTransparency = 0.3
            GunHighlight.Parent = gun
        end
    else
        if GunHighlight then GunHighlight:Destroy(); GunHighlight = nil end
    end
end

CreateToggle(PageFunctions, "ESP Лежащего пистолета", "GunIndicator", function(state)
    if state then
        table.insert(Connections, RunService.Heartbeat:Connect(UpdateGunESP))
    elseif GunHighlight then
        GunHighlight:Destroy()
        GunHighlight = nil
    end
end)

-- 3. Auto-Aim (Аим на Убийцу / Шерифа)
local function GetAimTarget()
    GetMM2Roles()
    local target = nil
    -- Если мы шериф/невиновный — целимся в убийцу. Если мы убийца — в шерифа или ближайшего выжившего
    local isMeMerd = LocalPlayer.Backpack:FindFirstChild("Knife") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife"))
    
    if isMeMerd then
        target = Sheriff
    else
        target = Murderer
    end
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        return target.Character.HumanoidRootPart
    end
    return nil
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if _G.DeltaConfig.AutoAim then
        local targetPart = GetAimTarget()
        if targetPart then
            local cam = Workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position, targetPart.Position)
        end
    end
end))

CreateToggle(PageFunctions, "Умный Аимбот (Auto-Aim)", "AutoAim", nil)

-- 4. Автофарм Монет (Телепорт к монетам)
local function FarmCoins()
    while _G.DeltaConfig.AutoFarm do
        task.wait(0.1)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Ищем контейнеры монет в MM2 (обычно находятся в CoinContainer на карте)
            local container = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("SandBox")
            local coinContainer = container and container:FindFirstChild("CoinContainer")
            
            if coinContainer then
                for _, coin in ipairs(coinContainer:GetChildren()) do
                    if coin:IsA("BasePart") or coin:FindFirstChild("Coin") then
                        if _G.DeltaConfig.AutoFarm then
                            char.HumanoidRootPart.CFrame = coin.CFrame
                            task.wait(0.3) -- Безопасная задержка, чтобы не кикнул античит
                        end
                    end
                end
            end
        end
    end
end

CreateToggle(PageFunctions, "Безопасный автофарм монет", "AutoFarm", function(state)
    if state then task.spawn(FarmCoins) end
end)

-- 5. Fullbright (Освещение всей карты)
CreateToggle(PageFunctions, "Полное освещение (Fullbright)", "Fullbright", function(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end)

-- 6. Cozy Mode (Уютный шейдер)
CreateToggle(PageFunctions, "Уютный шейдер (Cozy Mode)", "CozyMode", function(state)
    local cc = Lighting:FindFirstChild("Delta_Cozy")
    if state then
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "Delta_Cozy"
            cc.Parent = Lighting
        end
        cc.TintColor = Color3.fromRGB(255, 195, 135) -- Мягкий персиковый тон
        cc.Saturation = 0.15
        cc.Contrast = 0.1
        cc.Enabled = true
    else
        if cc then cc.Enabled = false end
    end
end)

-- 7. Детектор "Кто взял пистолет" (Из Части 2)
local function TrackGunHolders()
    local lastHolder = nil
    while task.wait(0.5) do
        if _G.DeltaConfig.GunIndicator then
            GetMM2Roles()
            if Sheriff and Sheriff ~= lastHolder then
                lastHolder = Sheriff
                CreateNotify("ИНФОРМАЦИЯ", Sheriff.Name .. " взял пистолет!", Color3.fromRGB(0, 150, 255))
                if _G.DeltaConfig.GunSound then
                    local s = Instance.new("Sound", Workspace)
                    s.SoundId = "rbxassetid://12221967" -- Чистый системный пинг
                    s:Play()
                    task.delay(1.5, function() s:Destroy() end)
                end
            end
        end
    end
end
task.spawn(TrackGunHolders)
-- [[ ЧАСТЬ 3: Логика "Утилит" ]]

-- [[ Переменные для отслеживания раунда ]]
local RoundStatusLabel = nil
local AlivePlayersLabel = nil

-- Функция для подсчета выживших (невинных) игроков в раунде MM2
local function GetAlivePlayersCount()
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            -- Игрок жив, если здоровье > 0 и у него нет роли наблюдателя (обычно в лобби)
            if humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Проверка на нахождение в лобби (если на карте лобби есть спавн-зона, то исключаем)
                -- В MM2 живыми в раунде считаются те, у кого в рюкзаке или руках нет "наблюдателя"
                if not player.Backpack:FindFirstChild("Spectator") and not player.Character:FindFirstChild("Spectator") then
                    count = count + 1
                end
            end
        end
    end
    return count
end

-- Функция обновления интерфейса раунда
local function UpdateRoundStats()
    if _G.DeltaConfig.RoundInfo then
        GetMM2Roles()
        local statusText = "Ожидание игры..."
        
        if Murderer then
            statusText = "РАУНД АКТИВЕН ⚔️"
        elseif not Murderer and not Sheriff then
            statusText = "В ЛОББИ ⌛"
        end
        
        if RoundStatusLabel then
            RoundStatusLabel.Text = "Статус: " .. statusText
        end
    end
    
    if _G.DeltaConfig.AliveCount then
        local aliveCount = GetAlivePlayersCount()
        if AlivePlayersLabel then
            AlivePlayersLabel.Text = "Живых игроков: " .. tostring(aliveCount)
        end
    end
end

-- [[ СОЗДАНИЕ ИНТЕРФЕЙСА В ТАБЛИЦЕ УТИЛИТ ]]

-- 1. Текстовые плашки для информеров
local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, 0, 0, 60)
InfoFrame.BackgroundTransparency = 0.95
InfoFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InfoFrame.Parent = PageUtils
Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 6)

RoundStatusLabel = Instance.new("TextLabel")
RoundStatusLabel.Size = UDim2.new(1, -10, 0, 25)
RoundStatusLabel.Position = UDim2.new(0, 10, 0, 5)
RoundStatusLabel.BackgroundTransparency = 1
RoundStatusLabel.Text = "Статус: Выключено"
RoundStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RoundStatusLabel.Font = Enum.Font.SourceSansBold
RoundStatusLabel.TextSize = 13
RoundStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
RoundStatusLabel.Parent = InfoFrame

AlivePlayersLabel = Instance.new("TextLabel")
AlivePlayersLabel.Size = UDim2.new(1, -10, 0, 25)
AlivePlayersLabel.Position = UDim2.new(0, 10, 0, 30)
AlivePlayersLabel.BackgroundTransparency = 1
AlivePlayersLabel.Text = "Живых игроков: Выключено"
AlivePlayersLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AlivePlayersLabel.Font = Enum.Font.SourceSansSemibold
AlivePlayersLabel.TextSize = 13
AlivePlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
AlivePlayersLabel.Parent = InfoFrame

-- Разделитель
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, 0, 0, 1)
Separator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Separator.BorderSizePixel = 0
Separator.Parent = PageUtils

-- 2. Переключатели Утилит
CreateToggle(PageUtils, "Информация о раунде", "RoundInfo", function(state)
    if not state and RoundStatusLabel then
        RoundStatusLabel.Text = "Статус: Выключено"
    end
end)

CreateToggle(PageUtils, "Счетчик живых игроков", "AliveCount", function(state)
    if not state and AlivePlayersLabel then
        AlivePlayersLabel.Text = "Живых игроков: Выключено"
    end
end)

-- Луп для обновления статистики каждую секунду
table.insert(Connections, RunService.Heartbeat:Connect(function()
    UpdateRoundStats()
end))

-- 3. Анти-АФК
CreateToggle(PageUtils, "Анти-АФК (Защита от кика)", "AntiAFK", function(state)
    if state then
        CreateNotify("УТИЛИТЫ", "Анти-АФК успешно запущен!", Color3.fromRGB(0, 255, 100))
    end
end)

-- Логика обхода AFK через событие IDLE
LocalPlayer.Idled:Connect(function()
    if _G.DeltaConfig.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
        CreateNotify("АНТИ-АФК", "Симуляция активности успешно проведена.", Color3.fromRGB(255, 150, 0))
    end
end)

-- 4. Звуковые Ивенты
CreateToggle(PageUtils, "Звук поднятия пистолета", "GunSound", function(state)
    if state then
        CreateNotify("НАСТРОЙКА", "Звуковое уведомление на пушку активировано.", _G.DeltaConfig.MenuColor)
    end
end)

CreateToggle(PageUtils, "Звук смерти Шерифа", "SheriffSound", function(state)
    if state then
        CreateNotify("НАСТРОЙКА", "Звуковое уведомление на смерть Шерифа активировано.", _G.DeltaConfig.MenuColor)
    end
end)

-- Мониторинг смерти Шерифа
local SheriffAlive = false
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if _G.DeltaConfig.SheriffSound then
        GetMM2Roles()
        if Sheriff then
            local char = Sheriff.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hum and hum.Health > 0 then
                SheriffAlive = true
            elseif hum and hum.Health <= 0 and SheriffAlive then
                -- Шериф только что погиб!
                SheriffAlive = false
                CreateNotify("ВНИМАНИЕ", "Шериф погиб! Пушка свободна!", Color3.fromRGB(255, 50, 50))
                
                -- Воспроизведение звука сирены тревоги
                local s = Instance.new("Sound", Workspace)
                s.SoundId = "rbxassetid://138080512" -- Драматический звук сирены/тревоги
                s.Volume = 2
                s:Play()
                task.delay(2.5, function() s:Destroy() end)
            end
        else
            SheriffAlive = false
        end
    end
end))
-- [[ ЧАСТЬ 4: Логика вкладки "Эксплуатация" ]]

-- Список игроков для выбора цели Флинга
local TargetDropdown = Instance.new("TextButton")
TargetDropdown.Size = UDim2.new(1, 0, 0, 35)
TargetDropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TargetDropdown.Text = "Выбрать цель: [Не выбрана]"
TargetDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetDropdown.Font = Enum.Font.SourceSansBold
TargetDropdown.TextSize = 13
TargetDropdown.Parent = PageExploits

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = TargetDropdown

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, 0, 0, 120)
DropdownList.Position = UDim2.new(0, 0, 1, 5)
DropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
DropdownList.Visible = false
DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownList.ScrollBarThickness = 4
DropdownList.ZIndex = 10
DropdownList.Parent = TargetDropdown

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.Parent = DropdownList

-- Функция обновления списка игроков в выпадающем меню
local function UpdateDropdown()
    for _, child in ipairs(DropdownList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local playersCount = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            playersCount = playersCount + 1
            local Item = Instance.new("TextButton")
            Item.Size = UDim2.new(1, 0, 0, 25)
            Item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Item.BorderSizePixel = 0
            Item.Text = player.DisplayName .. " (@" .. player.Name .. ")"
            Item.TextColor3 = Color3.fromRGB(255, 255, 255)
            Item.Font = Enum.Font.SourceSans
            Item.TextSize = 12
            Item.ZIndex = 11
            Item.Parent = DropdownList
            
            Item.MouseButton1Click:Connect(function()
                _G.DeltaConfig.FlingTarget = player.Name
                TargetDropdown.Text = "Цель: @" .. player.Name
                DropdownList.Visible = false
            end)
        end
    end
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, playersCount * 25)
end

TargetDropdown.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
    if DropdownList.Visible then UpdateDropdown() end
end)

-- [[ ФУНКЦИИ ЭКСПЛУАТАЦИИ ]]

-- 1. Anti-Fling (Убираем коллизию своего персонажа с другими)
CreateToggle(PageExploits, "Анти-Флинг (No Collide)", "AntiFling", function(state)
    if state then
        CreateNotify("ЭКСПЛУАТАЦИЯ", "Анти-Флинг активирован. Вы неосязаемы.", Color3.fromRGB(0, 255, 100))
    end
end)

table.insert(Connections, RunService.Stepped:Connect(function()
    if _G.DeltaConfig.AntiFling and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

-- 2. Разрушительный Fling (Раскрутка и выбивание цели)
local FlingActive = false
local function ExecuteFling()
    local targetPlayer = Players:FindFirstChild(_G.DeltaConfig.FlingTarget)
    if not targetPlayer or not targetPlayer.Character then
        CreateNotify("ОШИБКА", "Цель не найдена или мертва!", Color3.fromRGB(255, 50, 50))
        _G.DeltaConfig.Fling = false
        return
    end

    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

    if myHRP and targetHRP then
        FlingActive = true
        local originalCFrame = myHRP.CFrame
        
        -- Скрываемся из виду и копим скорость
        local bt = Instance.new("BodyThrust")
        bt.Force = Vector3.new(999999, 999999, 999999)
        bt.Location = Vector3.new(0, 1000, 0)
        bt.Parent = myHRP

        -- Быстрый налет на цель для коллизии
        local flingTime = tick()
        while tick() - flingTime < 1.5 and _G.DeltaConfig.Fling and targetHRP.Parent do
            task.wait()
            if myHRP and targetHRP then
                myHRP.Velocity = Vector3.new(10000, 10000, 10000)
                myHRP.RotVelocity = Vector3.new(10000, 10000, 10000)
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(math.random(-1,1)/10, 0, math.random(-1,1)/10)
            end
        end

        -- Возвращаемся на место
        bt:Destroy()
        myHRP.Velocity = Vector3.new(0, 0, 0)
        myHRP.RotVelocity = Vector3.new(0, 0, 0)
        myHRP.CFrame = originalCFrame
        FlingActive = false
        _G.DeltaConfig.Fling = false
        CreateNotify("ФЛИНГ", "Атака завершена!", Color3.fromRGB(255, 150, 0))
    end
end

CreateToggle(PageExploits, "Активировать Флинг цели", "Fling", function(state)
    if state then
        if _G.DeltaConfig.FlingTarget == "" then
            CreateNotify("ОШИБКА", "Сначала выберите игрока в списке!", Color3.fromRGB(255, 50, 50))
            _G.DeltaConfig.Fling = false
            return
        end
        task.spawn(ExecuteFling)
    end
end)

-- 3. Kill All (Только за Мардера)
CreateToggle(PageExploits, "Убить всех (Только за Мардера)", "KillAll", function(state)
    if state then
        local myChar = LocalPlayer.Character
        local knife = myChar and (myChar:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife"))
        
        if not knife then
            CreateNotify("ОШИБКА", "Вы не Мардер или у вас нет ножа!", Color3.fromRGB(255, 50, 50))
            _G.DeltaConfig.KillAll = false
            return
        end
        
        CreateNotify("МАСС-КИЛЛ", "Запуск зачистки сервера...", _G.DeltaConfig.MenuColor)
        
        -- Снаряжаем нож в руки, если он в рюкзаке
        if knife.Parent == LocalPlayer.Backpack then
            knife.Parent = myChar
        end
        
        task.spawn(function()
            local originalPos = myChar.HumanoidRootPart.CFrame
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = player.Character.HumanoidRootPart
                    local targetHum = player.Character:FindFirstChild("Humanoid")
                    
                    if targetHum and targetHum.Health > 0 and _G.DeltaConfig.KillAll then
                        -- ТП прямо за спину жертвы
                        myChar.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1.5)
                        task.wait(0.12)
                        
                        -- Атака ножом
                        knife:Activate()
                        task.wait(0.08)
                    end
                end
            end
            
            -- Возвращение на исходную позицию
            myChar.HumanoidRootPart.CFrame = originalPos
            _G.DeltaConfig.KillAll = false
            CreateNotify("МАСС-КИЛЛ", "Все игроки успешно зачищены!", Color3.fromRGB(0, 255, 100))
        end)
    end
end)
-- [[ ЧАСТЬ 5: FPS, Настройки, Кредиты и Запуск ]]

-- [[ 1. ВКЛАДКА: FPS БУСТ ]]
CreateToggle(PageFps, "Сжатие пикселей (3D Render)", "PixelBoost", function(state)
    if state then
        settings().Rendering.QualityLevel = 1
        Workspace.CurrentCamera.ViewSizeAbsolute:Connect(function() end) -- Триггер рендера
        CreateNotify("FPS БУСТ", "Качество рендеринга снижено до минимума.", Color3.fromRGB(0, 255, 100))
    else
        settings().Rendering.QualityLevel = OriginalLighting.QualityLevel
    end
end)

CreateToggle(PageFps, "Режим без текстур (Очистка карт)", "TextureBoost", function(state)
    if state then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                OriginalMaterials[obj] = obj.Texture
                obj.Texture = ""
            elseif obj:IsA("BasePart") then
                OriginalMaterials[obj] = obj.Material
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
        CreateNotify("FPS БУСТ", "Текстуры временно отключены.", Color3.fromRGB(0, 255, 100))
    else
        for obj, original in pairs(OriginalMaterials) do
            if obj and obj.Parent then
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Texture = original
                elseif obj:IsA("BasePart") then
                    obj.Material = original
                end
            end
        end
        table.clear(OriginalMaterials)
    end
end)


-- [[ 2. ВКЛАДКА: НАСТРОЙКИ И ИНТЕРФЕЙС ]]

-- Кнопка смены цветовой темы
local Themes = {
    {Name = "Delta Crimson", Color = Color3.fromRGB(255, 0, 100)},
    {Name = "Neon Blue", Color = Color3.fromRGB(0, 150, 255)},
    {Name = "Vampire Purple", Color = Color3.fromRGB(150, 0, 255)},
    {Name = "Toxic Green", Color = Color3.fromRGB(0, 255, 100)}
}
local CurrentThemeIdx = 1

local ThemeBtn = Instance.new("TextButton")
ThemeBtn.Size = UDim2.new(1, 0, 0, 35)
ThemeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ThemeBtn.Text = "Сменить тему: Delta Crimson"
ThemeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ThemeBtn.Font = Enum.Font.SourceSansBold
ThemeBtn.TextSize = 13
ThemeBtn.Parent = PageSettings
Instance.new("UICorner", ThemeBtn).CornerRadius = UDim.new(0, 6)

ThemeBtn.MouseButton1Click:Connect(function()
    CurrentThemeIdx = CurrentThemeIdx + 1
    if CurrentThemeIdx > #Themes then CurrentThemeIdx = 1 end
    local nextTheme = Themes[CurrentThemeIdx]
    
    _G.DeltaConfig.MenuColor = nextTheme.Color
    ThemeBtn.Text = "Сменить тему: " .. nextTheme.Name
    
    -- Обновляем заголовки и активную вкладку
    for _, t in pairs(Tabs) do
        if t.Page.Visible then
            t.Btn.TextColor3 = nextTheme.Color
        end
    end
    CreateNotify("ТЕМЫ", "Цветовая схема изменена на " .. nextTheme.Name, nextTheme.Color)
end)

-- Кнопка Выгрузки Скрипта
local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, 0, 0, 35)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
UnloadBtn.Text = "ПОЛНАЯ ВЫГРУЗКА (Убрать чит)"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 13
UnloadBtn.Parent = PageSettings
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)

UnloadBtn.MouseButton1Click:Connect(function()
    -- Отключаем все лупы и бинды
    for _, conn in ipairs(Connections) do
        if conn then conn:Disconnect() end
    end
    -- Возвращаем графику и свет
    Lighting.Ambient = OriginalLighting.Ambient
    Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.ClockTime = OriginalLighting.ClockTime
    Lighting.FogEnd = OriginalLighting.FogEnd
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    settings().Rendering.QualityLevel = OriginalLighting.QualityLevel
    
    -- Чистим ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Delta_Highlight") then
            p.Character.Delta_Highlight:Destroy()
        end
    end
    if GunHighlight then GunHighlight:Destroy() end
    
    -- Удаляем GUI
    ScreenGui:Destroy()
    print("Delta Premium Ultimate успешно выгружен!")
end)


-- [[ 3. ВКЛАДКА: КРЕДИТЫ (Разработчики) ]]
local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Size = UDim2.new(1, 0, 1, 0)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text = "DELTA MM2 PREMIUM\n\nРазработчики софта:\n⭐ Makanbaev Aidar & Zoya ⭐\n\nРелиз: v3.0 Ultimate (2026 Edition)\n\nСкрипт создан специально для комфортной игры и жесткого фана!"
CreditsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
CreditsLabel.Font = Enum.Font.SourceSansBold
CreditsLabel.TextSize = 14
CreditsLabel.TextWrapped = true
CreditsLabel.Parent = PageCredits


-- [[ 4. МОБИЛЬНАЯ КНОПКА «D» ]]
local MobileButton = Instance.new("TextButton")
MobileButton.Name = "DeltaOpenBtn"
MobileButton.Size = UDim2.new(0, _G.DeltaConfig.ButtonSize, 0, _G.DeltaConfig.ButtonSize)
MobileButton.Position = UDim2.new(0, 10, 0.5, -25)
MobileButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MobileButton.BackgroundTransparency = _G.DeltaConfig.ButtonTransparency
MobileButton.Text = "D"
MobileButton.TextColor3 = Color3.fromRGB(255, 0, 100)
MobileButton.Font = Enum.Font.SourceSansBold
MobileButton.TextSize = 22
MobileButton.Visible = IsMobile -- Кнопка видна только на смартфонах/планшетах
MobileButton.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = MobileButton

-- Сделать кнопку передвигаемой по экрану
MobileButton.Active = true
MobileButton.Draggable = true

-- Логика скрытия/открытия меню при клике на «D» или на крестик
local function ToggleGui()
    MainFrame.Visible = not MainFrame.Visible
end

MobileButton.MouseButton1Click:Connect(ToggleGui)
CloseBtn.MouseButton1Click:Connect(ToggleGui)

-- ПК Клавиша открытия (Right Shift)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        ToggleGui()
    end
end)

-- Слайдеры для настройки кнопки «D» (Размещены во вкладке Настроек)
local SizeLabel = Instance.new("TextLabel")
SizeLabel.Size = UDim2.new(1, 0, 0, 20)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "Прозрачность кнопки D: " .. tostring(_G.DeltaConfig.ButtonTransparency)
SizeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SizeLabel.Font = Enum.Font.SourceSans
SizeLabel.TextSize = 12
SizeLabel.Parent = PageSettings

local TransBtn = Instance.new("TextButton")
TransBtn.Size = UDim2.new(1, 0, 0, 25)
TransBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TransBtn.Text = "Переключить прозрачность"
TransBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TransBtn.Font = Enum.Font.SourceSansBold
TransBtn.TextSize = 12
TransBtn.Parent = PageSettings
Instance.new("UICorner", TransBtn).CornerRadius = UDim.new(0, 4)

TransBtn.MouseButton1Click:Connect(function()
    if _G.DeltaConfig.ButtonTransparency == 0.2 then
        _G.DeltaConfig.ButtonTransparency = 0.6
    else
        _G.DeltaConfig.ButtonTransparency = 0.2
    end
    MobileButton.BackgroundTransparency = _G.DeltaConfig.ButtonTransparency
    SizeLabel.Text = "Прозрачность кнопки D: " .. tostring(_G.DeltaConfig.ButtonTransparency)
end)

-- [[ ФИНАЛЬНЫЙ ЗАПУСК ]]
CreateNotify("УСПЕШНО", "Delta Premium V3.0 успешно запущен!", Color3.fromRGB(0, 255, 100))
print("====================================")
print("Delta MM2 Ultimate v3.0 loaded!")
print("Авторы: Makanbaev Aidar & Zoya")
print("Используйте ПК клавишу [Right Shift] или мобильную кнопку 'D'")
print("====================================")
