-- [[ Сервисы Roblox ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

-- [[ Определение устройства (ПК или Мобильный) ]]
local IsMobile = false
-- Если у устройства есть тачскрин и нет аппаратной клавиатуры (или это консоль/мобильный API)
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    IsMobile = true
end

-- [[ Состояния функций ]]
local MM2_ESP_Enabled = false
local Fullbright_Enabled = false
local AutoAim_Enabled = false
local InfiniteJump_Enabled = false
local AutoFarm_Enabled = false
local CustomSpeed = 16

-- Состояния визуала
local CozyMode_Enabled = false
local Particles_Enabled = false

-- Состояния FPS бустов
local PixelBoost_Enabled = false
local TextureBoost_Enabled = false
local PhysicsBoost_Enabled = false

-- [[ Таблицы хранения для бэкапа ]]
local EspObjects = {}
local Connections = {}
local GunHighlight = nil
local OriginalMaterials = {}
local OriginalSkybox = {}
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    QualityLevel = settings().Rendering.QualityLevel
}

-- Переменные для MM2 ролей
local Murderer = nil
local Sheriff = nil

-- Сохраняем дефолтный Скайбокс при запуске
local defaultSky = Lighting:FindFirstChildOfClass("Sky")
if defaultSky then
    OriginalSkybox = {
        Bk = defaultSky.SkyboxBk,
        Dn = defaultSky.SkyboxDn,
        Ft = defaultSky.SkyboxFt,
        Lf = defaultSky.SkyboxLf,
        Rt = defaultSky.SkyboxRt,
        Up = defaultSky.SkyboxUp
    }
end

-- [[ Определение Ролей ]]
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

-- [[ 1. Создание Меню GUI ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2PremiumUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 380)
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Поддерживает и мышь на ПК, и зажатие на мобилках
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 12)
MainUICorner.Parent = MainFrame

-- Шапка
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
-- Показываем тип устройства в шапке для красоты
Title.Text = "DELTA MM2 ULTIMATE (" .. (IsMobile and "MOBILE" or "PC") .. ")"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "—"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

-- Навигация по вкладкам (3 вкладки)
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 30)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local MainTabBtn = Instance.new("TextButton")
MainTabBtn.Size = UDim2.new(0.33, 0, 1, 0)
MainTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainTabBtn.Text = "Функции"
MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTabBtn.Font = Enum.Font.SourceSansBold
MainTabBtn.TextSize = 12
MainTabBtn.Parent = TabContainer

local VisualTabBtn = Instance.new("TextButton")
VisualTabBtn.Size = UDim2.new(0.33, 0, 1, 0)
VisualTabBtn.Position = UDim2.new(0.33, 0, 0, 0)
VisualTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
VisualTabBtn.Text = "Визуал"
VisualTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
VisualTabBtn.Font = Enum.Font.SourceSansBold
VisualTabBtn.TextSize = 12
VisualTabBtn.Parent = TabContainer

local FpsTabBtn = Instance.new("TextButton")
FpsTabBtn.Size = UDim2.new(0.34, 0, 1, 0)
FpsTabBtn.Position = UDim2.new(0.66, 0, 0, 0)
FpsTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FpsTabBtn.Text = "FPS Буст"
FpsTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
FpsTabBtn.Font = Enum.Font.SourceSansBold
FpsTabBtn.TextSize = 12
FpsTabBtn.Parent = TabContainer

-- Контейнеры (Скролл-списки)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -85)
Container.Position = UDim2.new(0, 10, 0, 75)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 450)
Container.ScrollBarThickness = 2
Container.Parent = MainFrame

local VisualContainer = Instance.new("ScrollingFrame")
VisualContainer.Size = UDim2.new(1, -20, 1, -85)
VisualContainer.Position = UDim2.new(0, 10, 0, 75)
VisualContainer.BackgroundTransparency = 1
VisualContainer.CanvasSize = UDim2.new(0, 0, 0, 350)
VisualContainer.ScrollBarThickness = 2
VisualContainer.Visible = false
VisualContainer.Parent = MainFrame

local FpsContainer = Instance.new("ScrollingFrame")
FpsContainer.Size = UDim2.new(1, -20, 1, -85)
FpsContainer.Position = UDim2.new(0, 10, 0, 75)
FpsContainer.BackgroundTransparency = 1
FpsContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
FpsContainer.ScrollBarThickness = 2
FpsContainer.Visible = false
FpsContainer.Parent = MainFrame

-- Сетки макетов (Layouts)
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

local VisualUIList = Instance.new("UIListLayout")
VisualUIList.Padding = UDim.new(0, 8)
VisualUIList.Parent = VisualContainer

local FpsUIList = Instance.new("UIListLayout")
FpsUIList.Padding = UDim.new(0, 8)
FpsUIList.Parent = FpsContainer

-- Логика переключения Вкладок
MainTabBtn.MouseButton1Click:Connect(function()
    Container.Visible = true; VisualContainer.Visible = false; FpsContainer.Visible = false
    MainTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VisualTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); VisualTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    FpsTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); FpsTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

VisualTabBtn.MouseButton1Click:Connect(function()
    Container.Visible = true; VisualContainer.Visible = true; FpsContainer.Visible = false
    VisualTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); VisualTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    FpsTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); FpsTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

FpsTabBtn.MouseButton1Click:Connect(function()
    Container.Visible = false; VisualContainer.Visible = false; FpsContainer.Visible = true
    FpsTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); FpsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    VisualTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); VisualTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- Кнопка открытия «D» (Показывается в основном для мобилок)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Text = "D"
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 100)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 22
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)

-- [[ ФУНКЦИЯ ДЛЯ ПК: Скрытие/Открытие меню на кнопку RightShift ]]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and not IsMobile then
        if input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
            -- Если открыли меню, скрываем круглую кнопку "D", если закрыли — можем показать её как индикатор
            OpenBtn.Visible = not MainFrame.Visible
        end
    end
end)

-- Хелперы для создания кнопок управления
local function CreateToggle(parent, name, default, callback)
    local state = default
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = state and Color3.fromRGB(100, 20, 40) or Color3.fromRGB(30, 30, 30)
    Button.Text = name .. (state and " : ON" or " : OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 13
    Button.Parent = parent
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.BackgroundColor3 = state and Color3.fromRGB(150, 30, 60) or Color3.fromRGB(30, 30, 30)
        Button.Text = name .. (state and " : ON" or " : OFF")
        callback(state)
    end)
end

local function CreateButton(parent, name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 13
    Button.Parent = parent
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    Button.MouseButton1Click:Connect(callback)
end

local function CreateSlider(name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.Parent = SliderFrame

    local BtnMinus = Instance.new("TextButton")
    BtnMinus.Size = UDim2.new(0, 35, 0, 20)
    BtnMinus.Position = UDim2.new(0, 5, 0, 20)
    BtnMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BtnMinus.Text = "-"
    BtnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnMinus.Parent = SliderFrame
    Instance.new("UICorner", BtnMinus).CornerRadius = UDim.new(0, 4)

    local BtnPlus = Instance.new("TextButton")
    BtnPlus.Size = UDim2.new(0, 35, 0, 20)
    BtnPlus.Position = UDim2.new(1, -40, 0, 20)
    BtnPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BtnPlus.Text = "+"
    BtnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnPlus.Parent = SliderFrame
    Instance.new("UICorner", BtnPlus).CornerRadius = UDim.new(0, 4)

    local current = default
    BtnMinus.MouseButton1Click:Connect(function()
        current = math.max(min, current - 5)
        Label.Text = name .. ": " .. tostring(current)
        callback(current)
    end)
    BtnPlus.MouseButton1Click:Connect(function()
        current = math.min(max, current + 5)
        Label.Text = name .. ": " .. tostring(current)
        callback(current)
    end)
end


-- [[ 2. Логика Автофарма Монет ]]
task.spawn(function()
    while true do
        task.wait(0.2)
        if AutoFarm_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local coinData = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Coins")
            if coinData and coinData.Value >= 40 then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                    task.wait(4)
                end
            else
                local root = LocalPlayer.Character.HumanoidRootPart
                local closestCoin = nil
                local shortestDistance = math.huge

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "Coin_Sub" or obj.Name == "Coin" or (obj:IsA("BasePart") and obj.Parent.Name == "CoinContainer") then
                        local dist = (obj.Position - root.Position).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestCoin = obj
                        end
                    end
                end

                if closestCoin then
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                    root.CFrame = closestCoin.CFrame + Vector3.new(0, 1, 0)
                end
            end
        end
    end
end)


-- [[ 3. Улучшенный Auto Aim + Имитация ShiftLock и Авто-клик ]]
local function GetMurdererChar()
    if Murderer and Murderer.Character and Murderer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = Murderer.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then return Murderer.Character end
    end
    return nil
end

Connections.AutoAim = RunService.RenderStepped:Connect(function()
    if not AutoAim_Enabled then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    local equippedGun = myChar:FindFirstChild("Gun")
    if equippedGun and equippedGun:IsA("Tool") then
        local targetChar = GetMurdererChar()
        if targetChar then
            local targetPart = targetChar.HumanoidRootPart
            local camera = Workspace.CurrentCamera
            
            -- Имитация ShiftLock
            local lookAt = (targetPart.Position - camera.CFrame.Position).Unit
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + lookAt)
            
            -- Разворачиваем персонажа
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetPart.Position.X, myRoot.Position.Y, targetPart.Position.Z))
            end

            -- Автоматический клик (работает и на ПК, и на мобилках)
            equippedGun:Activate()
            VirtualUser:Button1Down(Vector2.new(0,0), camera.CFrame)
            VirtualUser:Button1Up(Vector2.new(0,0), camera.CFrame)
        end
    end
end)


-- [[ 4. Вкладка «Визуал» (Шейдеры, Скайбоксы, Партиклы) ]]

-- 1. Уютная атмосфера (Cozy Shaders)
local function ToggleCozyMode(state)
    CozyMode_Enabled = state
    if state then
        local cc = Lighting:FindFirstChild("Delta_Cozy") or Instance.new("ColorCorrectionEffect", Lighting)
        cc.Name = "Delta_Cozy"
        cc.TintColor = Color3.fromRGB(255, 200, 150)
        cc.Contrast = 0.15
        cc.Saturation = 0.1
        
        local bloom = Lighting:FindFirstChild("Delta_Bloom") or Instance.new("BloomEffect", Lighting)
        bloom.Name = "Delta_Bloom"
        bloom.Intensity = 0.6
        bloom.Size = 24
    else
        local cc = Lighting:FindFirstChild("Delta_Cozy")
        if cc then cc:Destroy() end
        local bloom = Lighting:FindFirstChild("Delta_Bloom")
        if bloom then bloom:Destroy() end
    end
end

-- 2. Смена Скайбоксов
local function ApplyCustomSkybox(id)
    local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
    sky.SkyboxBk = "rbxassetid://" .. tostring(id)
    sky.SkyboxDn = "rbxassetid://" .. tostring(id)
    sky.SkyboxFt = "rbxassetid://" .. tostring(id)
    sky.SkyboxLf = "rbxassetid://" .. tostring(id)
    sky.SkyboxRt = "rbxassetid://" .. tostring(id)
    sky.SkyboxUp = "rbxassetid://" .. tostring(id)
end

local function ResetSkybox()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky then
        if OriginalSkybox.Bk then
            sky.SkyboxBk = OriginalSkybox.Bk
            sky.SkyboxDn = OriginalSkybox.Dn
            sky.SkyboxFt = OriginalSkybox.Ft
            sky.SkyboxLf = OriginalSkybox.Lf
            sky.SkyboxRt = OriginalSkybox.Rt
            sky.SkyboxUp = OriginalSkybox.Up
        else
            sky:Destroy()
        end
    end
end

-- 3. Кастомные эффекты частиц
local function ToggleParticles(state)
    Particles_Enabled = state
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if state then
        local pe = root:FindFirstChild("Delta_Particles") or Instance.new("ParticleEmitter", root)
        pe.Name = "Delta_Particles"
        pe.Texture = "rbxassetid://241584311"
        pe.LightEmission = 1
        pe.Color = ColorSequence.new(Color3.fromRGB(255, 100, 200), Color3.fromRGB(100, 255, 255))
        pe.Size = NumberSequence.new(0.5, 0)
        pe.Speed = NumberRange.new(2, 5)
        pe.Lifetime = NumberRange.new(1, 2)
        pe.Rate = 35
    else
        local pe = root:FindFirstChild("Delta_Particles")
        if pe then pe:Destroy() end
    end
end


-- [[ 5. Надежный FPS Бустер ]]
local function TogglePixelBoost(state)
    PixelBoost_Enabled = state
    if state then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else
        settings().Rendering.QualityLevel = OriginalLighting.QualityLevel
    end
end

local function ToggleTextureBoost(state)
    TextureBoost_Enabled = state
    if state then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not OriginalMaterials[obj] then
                OriginalMaterials[obj] = {Material = obj.Material, Color = obj.Color}
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            end
        end
    else
        for obj, data in pairs(OriginalMaterials) do
            if obj and obj.Parent then
                obj.Material = data.Material
            end
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 0
            end
        end
        table.clear(OriginalMaterials)
    end
end

local function TogglePhysicsBoost(state)
    PhysicsBoost_Enabled = state
    if state then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
    else
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Brightness = OriginalLighting.Brightness
    end
end


-- [[ 6. MM2 ESP ]]
local function CreateESP(player)
    if player == LocalPlayer then return end

    local function CharacterAdded(char)
        local head = char:WaitForChild("Head", 5)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not head or not root then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MM2_ESP"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 150, 0, 45)
        billboard.Adornee = head
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 12
        label.Parent = billboard

        local highlight = Instance.new("Highlight")
        highlight.Name = "MM2_Highlight"
        highlight.Adornee = char
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = char

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not MM2_ESP_Enabled or not char:IsDescendantOf(workspace) then
                billboard.Enabled = false
                highlight.Enabled = false
                return
            end
            
            billboard.Enabled = true
            highlight.Enabled = true

            local roleText = "Innocent"
            local color = Color3.fromRGB(0, 255, 100)

            if player == Murderer then
                roleText = "MURDERER 💀"
                color = Color3.fromRGB(255, 0, 0)
            elseif player == Sheriff then
                roleText = "SHERIFF ︻╦╤─"
                color = Color3.fromRGB(0, 150, 255)
            end

            highlight.FillColor = color
            label.TextColor3 = color

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local distance = math.floor((root.Position - myRoot.Position).Magnitude)
                label.Text = string.format("%s\n%s\n[%d Studs]", player.DisplayName, roleText, distance)
            else
                label.Text = string.format("%s\n%s", player.DisplayName, roleText)
            end
        end)

        EspObjects[player] = {Billboard = billboard, Highlight = highlight, Connection = connection}
    end

    if player.Character then task.spawn(CharacterAdded, player.Character) end
    player.CharacterAdded:Connect(CharacterAdded)
end

task.spawn(function()
    while true do
        task.wait(1)
        if MM2_ESP_Enabled then GetMM2Roles() end
    end
end)

-- Поиск пистолета
Connections.GunTracker = RunService.RenderStepped:Connect(function()
    if not MM2_ESP_Enabled then
        if GunHighlight then GunHighlight:Destroy() GunHighlight = nil end
        return
    end
    local gunDrop = Workspace:FindFirstChild("GunDrop")
    if gunDrop and gunDrop:IsA("BasePart") then
        if not GunHighlight then
            GunHighlight = Instance.new("Highlight")
            GunHighlight.Adornee = gunDrop
            GunHighlight.FillColor = Color3.fromRGB(255, 255, 0)
            GunHighlight.FillTransparency = 0.3
            GunHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            GunHighlight.Parent = gunDrop
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "Gun_ESP"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 150, 0, 40)
            billboard.Adornee = gunDrop
            billboard.Parent = gunDrop

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 215, 0)
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 13
            label.Text = "★ GUN ★"
            label.Parent = billboard
        end
    else
        if GunHighlight then GunHighlight:Destroy() GunHighlight = nil end
    end
end)


-- [[ 7. Регистрация Кнопок Вкладок ]]

-- Вкладка 1: ФУНКЦИИ
CreateToggle(Container, "MM2 ESP", false, function(state)
    MM2_ESP_Enabled = state
    if state then
        GetMM2Roles()
        for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
    end
end)

CreateToggle(Container, "Auto Aim (Шифтлок + Клик)", false, function(state)
    AutoAim_Enabled = state
end)

CreateToggle(Container, "Автофарм Монет (до 40)", false, function(state)
    AutoFarm_Enabled = state
end)

CreateToggle(Container, "Fullbright", false, function(state)
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

CreateToggle(Container, "Infinite Jump", false, function(state)
    InfiniteJump_Enabled = state
end)

CreateSlider("WalkSpeed", 16, 100, 16, function(value)
    CustomSpeed = value
end)


-- Вкладка 2: ВИЗУАЛ
CreateToggle(VisualContainer, "Уютная Атмосфера (Cozy)", false, function(state)
    ToggleCozyMode(state)
end)

CreateToggle(VisualContainer, "Звездная пыль на тебе", false, function(state)
    ToggleParticles(state)
end)

CreateButton(VisualContainer, "Летнее Небо (Лето)", function()
    ApplyCustomSkybox(7905884)
end)

CreateButton(VisualContainer, "Холодное Небо", function()
    ApplyCustomSkybox(93751292568591)
end)

CreateButton(VisualContainer, "Вернуть стандартное небо", function()
    ResetSkybox()
end)


-- Вкладка 3: FPS БУСТ
CreateToggle(FpsContainer, "Буст 1: Сжатие Пикселей", false, function(state)
    TogglePixelBoost(state)
end)

CreateToggle(FpsContainer, "Буст 2: Без Текстур", false, function(state)
    ToggleTextureBoost(state)
end)

CreateToggle(FpsContainer, "Буст 3: Тени и Окружение", false, function(state)
    TogglePhysicsBoost(state)
end)


-- [[ Системные События (Полет/Прыжки) ]]
Connections.InfJump = UserInputService.JumpRequest:Connect(function()
    if InfiniteJump_Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Connections.SpeedLoop = RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= CustomSpeed then
            humanoid.WalkSpeed = CustomSpeed
        end
    end
end)

-- Очистка при отключении игрока
Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        if EspObjects[player].Billboard then EspObjects[player].Billboard:Destroy() end
        if EspObjects[player].Highlight then EspObjects[player].Highlight:Destroy() end
        if EspObjects[player].Connection then EspObjects[player].Connection:Disconnect() end
        EspObjects[player] = nil
    end
end)

print("Delta Ultimate Cross-Platform Script Successfully Loaded!")
