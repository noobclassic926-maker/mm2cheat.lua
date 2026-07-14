-- [[ Сервисы Roblox ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Состояния функций
local MM2_ESP_Enabled = false
local Fullbright_Enabled = false
local AutoAim_Enabled = false
local InfiniteJump_Enabled = false
local AutoFarm_Enabled = false
local CustomSpeed = 16

-- Таблицы данных
local EspObjects = {}
local Connections = {}
local GunHighlight = nil

-- Переменные для MM2
local Murderer = nil
local Sheriff = nil

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
ScreenGui.Name = "DeltaMM2Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 12)
MainUICorner.Parent = MainFrame

-- Вкладки (Главная и FPS)
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 30)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local MainTabBtn = Instance.new("TextButton")
MainTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
MainTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainTabBtn.Text = "Функции"
MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTabBtn.Font = Enum.Font.SourceSansBold
MainTabBtn.TextSize = 14
MainTabBtn.Parent = TabContainer

local FpsTabBtn = Instance.new("TextButton")
FpsTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
FpsTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
FpsTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FpsTabBtn.Text = "FPS Буст"
FpsTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
FpsTabBtn.Font = Enum.Font.SourceSansBold
FpsTabBtn.TextSize = 14
FpsTabBtn.Parent = TabContainer

-- Списки под вкладки
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -85)
Container.Position = UDim2.new(0, 10, 0, 75)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 450)
Container.ScrollBarThickness = 2
Container.Visible = true
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

local FpsContainer = Instance.new("ScrollingFrame")
FpsContainer.Size = UDim2.new(1, -20, 1, -85)
FpsContainer.Position = UDim2.new(0, 10, 0, 75)
FpsContainer.BackgroundTransparency = 1
FpsContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
FpsContainer.ScrollBarThickness = 2
FpsContainer.Visible = false
FpsContainer.Parent = MainFrame

local FpsUIList = Instance.new("UIListLayout")
FpsUIList.Padding = UDim.new(0, 8)
FpsUIList.Parent = FpsContainer

-- Переключение вкладок
MainTabBtn.MouseButton1Click:Connect(function()
    Container.Visible = true
    FpsContainer.Visible = false
    MainTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FpsTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    FpsTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

FpsTabBtn.MouseButton1Click:Connect(function()
    Container.Visible = false
    FpsContainer.Visible = true
    FpsTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    FpsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "DELTA MM2 PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
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

-- Хелперы для создания кнопок
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

-- [[ 2. Функция Автофарма монет (Левитация/Телепорт) ]]
task.spawn(function()
    while true do
        task.wait(0.2)
        if AutoFarm_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Проверка заполненности сумки (в MM2 лимит монет обычно 40)
            local coinData = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Coins")
            local playerData = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
            
            -- Если монет 40 — делаем ресет персонажа
            if coinData and coinData.Value >= 40 then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0 -- Ресет
                    task.wait(4) -- Ждем респавна
                end
            else
                -- Поиск монет на карте
                local root = LocalPlayer.Character.HumanoidRootPart
                local closestCoin = nil
                local shortestDistance = math.huge

                -- Монеты в MM2 лежат в контейнере карты в Workspace
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "Coin_Sub" or obj.Name == "Coin" or (obj:IsA("BasePart") and obj.Parent.Name == "CoinContainer") then
                        local dist = (obj.Position - root.Position).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestCoin = obj
                        end
                    end
                end

                -- Летим к ближайшей монете
                if closestCoin then
                    -- Отключаем коллизию на время полета
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                    -- Плавное перемещение к монете
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
    
    -- Проверяем, взят ли пистолет в руки
    local equippedGun = myChar:FindFirstChild("Gun")
    if equippedGun and equippedGun:IsA("Tool") then
        local targetChar = GetMurdererChar()
        if targetChar then
            local targetPart = targetChar.HumanoidRootPart
            local camera = Workspace.CurrentCamera
            
            -- 1. Эмуляция ShiftLock (камера жестко привязана к направлению персонажа и цели)
            local lookAt = (targetPart.Position - camera.CFrame.Position).Unit
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + lookAt)
            
            -- 2. Поворачиваем самого персонажа лицом к убийце
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetPart.Position.X, myRoot.Position.Y, targetPart.Position.Z))
            end

            -- 3. Автоматический клик (активация пистолета и клик через VirtualUser)
            equippedGun:Activate()
            VirtualUser:Button1Down(Vector2.new(0,0), camera.CFrame)
            VirtualUser:Button1Up(Vector2.new(0,0), camera.CFrame)
        end
    end
end)

-- [[ 4. Три метода FPS Буста ]]

-- Способ 1: Сжатие пикселей (Рендеринг в низком разрешении)
local function SetPixelFPSBoost(state)
    if state then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Workspace.CurrentCamera.FieldOfView = 70
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end

-- Способ 2: Удаление текстур и наложений (Текстуры заменяются на гладкие цвета)
local function SetNoTexturesBoost(state)
    if state then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end
end

-- Способ 3: Оптимизация физики и полное отключение теней / эффектов
local function SetPhysicsAndShadowsBoost(state)
    if state then
        Lighting.GlobalShadows = false
        for _, obj in ipairs(Lighting:GetDescendants()) do
            if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = false
            end
        end
        -- Снижаем нагрузку на физический движок для невидимых объектов
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
    else
        Lighting.GlobalShadows = true
    end
end

-- [[ 5. MM2 ESP ]]
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

-- Поиск упавшего пистолета
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

-- [[ 6. Регистрация кнопок ]]

-- Вкладка функций (Container)
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
    Fullbright_Enabled = state
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

CreateToggle(Container, "Infinite Jump", false, function(state)
    InfiniteJump_Enabled = state
end)

CreateSlider("WalkSpeed", 16, 100, 16, function(value)
    CustomSpeed = value
end)

-- Вкладка FPS (FpsContainer)
CreateToggle(FpsContainer, "Буст 1: Снижение Пикселей", false, function(state)
    SetPixelFPSBoost(state)
end)

CreateToggle(FpsContainer, "Буст 2: Удаление текстур", false, function(state)
    SetNoTexturesBoost(state)
end)

CreateToggle(FpsContainer, "Буст 3: Тени и Физика", false, function(state)
    SetPhysicsAndShadowsBoost(state)
end)

-- Бинд на бег и прыжки
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

Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        if EspObjects[player].Billboard then EspObjects[player].Billboard:Destroy() end
        if EspObjects[player].Highlight then EspObjects[player].Highlight:Destroy() end
        if EspObjects[player].Connection then EspObjects[player].Connection:Disconnect() end
        EspObjects[player] = nil
    end
end)

print("Delta Premium MM2 Loaded!")
