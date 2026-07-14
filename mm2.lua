-- [[ Сервисы ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Состояния функций
local MM2_ESP_Enabled = false
local Fullbright_Enabled = false
local AutoAim_Enabled = false
local InfiniteJump_Enabled = false
local CustomSpeed = 16

-- Таблицы данных
local EspObjects = {}
local Connections = {}
local GunHighlight = nil

-- Переменные для ролей MM2
local Murderer = nil
local Sheriff = nil

-- [[ Определение Ролей в MM2 ]]
local function GetMM2Roles()
    Murderer = nil
    Sheriff = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            -- Проверка по наличию оружия в бэкпаке или в руках
            local hasKnife = player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")
            local hasGun = player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun")
            
            if hasKnife then
                Murderer = player
            elseif hasGun then
                Sheriff = player
            end
        end
    end
end

-- [[ 1. Создание Меню GUI ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "DELTA MM2"
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

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 320)
Container.ScrollBarThickness = 2
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Text = "D"
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 100) -- Розово-красный акцент под MM2
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 22
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui

local OpenUICorner = Instance.new("UICorner")
OpenUICorner.CornerRadius = UDim.new(1, 0)
OpenUICorner.Parent = OpenBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- Функция создания Переключателей
local function CreateToggle(name, default, callback)
    local state = default
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = state and Color3.fromRGB(80, 20, 30) or Color3.fromRGB(30, 30, 30)
    Button.Text = name .. (state and " : ON" or " : OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 14
    Button.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.BackgroundColor3 = state and Color3.fromRGB(120, 30, 45) or Color3.fromRGB(30, 30, 30)
        Button.Text = name .. (state and " : ON" or " : OFF")
        callback(state)
    end)
end

-- Функция создания Ползунков
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


-- [[ 2. Логика MM2 ESP (Роли + Пистолет) ]]

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
        highlight.OutlineTransparency = 0.2
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

            -- Цвета и Роли
            local roleText = "Innocent"
            local color = Color3.fromRGB(0, 255, 100) -- Зеленый по умолчанию

            if player == Murderer then
                roleText = "MURDERER 💀"
                color = Color3.fromRGB(255, 0, 0) -- Красный
            elseif player == Sheriff then
                roleText = "SHERIFF ︻╦╤─"
                color = Color3.fromRGB(0, 150, 255) -- Синий
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

-- Периодическое обновление ролей раз в секунду
task.spawn(function()
    while true do
        task.wait(1)
        if MM2_ESP_Enabled then
            GetMM2Roles()
        end
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
            GunHighlight.FillColor = Color3.fromRGB(255, 255, 0) -- Желтый для пистолета
            GunHighlight.FillTransparency = 0.3
            GunHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            GunHighlight.Parent = gunDrop
            
            -- Текст над пистолетом
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
        if GunHighlight then
            GunHighlight:Destroy()
            GunHighlight = nil
        end
    end
end)


-- [[ 3. Логика Авто Аима (Silent Aim) ]]

local function GetMurdererChar()
    if Murderer and Murderer.Character and Murderer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = Murderer.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            return Murderer.Character
        end
    end
    return nil
end

Connections.AutoAim = RunService.RenderStepped:Connect(function()
    if not AutoAim_Enabled then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    -- Проверяем держит ли игрок пистолет в руках
    local equippedGun = myChar:FindFirstChild("Gun")
    if equippedGun and equippedGun:IsA("Tool") then
        local targetChar = GetMurdererChar()
        if targetChar then
            local targetPart = targetChar.HumanoidRootPart
            -- Направляем камеру и персонажа в сторону убийцы для точного выстрела
            local camera = Workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
            
            -- Виртуальное нажатие (выстрел), если палец зажат на экране или автоматически
            equippedGun:Activate()
        end
    end
end)


-- [[ 4. Стандартные функции (Fullbright, Speed, Jump) ]]

local function UpdateFullbright()
    if Fullbright_Enabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    end
end
Lighting:GetPropertyChangedSignal("Ambient"):Connect(UpdateFullbright)

Connections.InfJump = UserInputService.JumpRequest:Connect(function()
    if InfiniteJump_Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
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


-- [[ 5. Регистрация кнопок ]]

CreateToggle("MM2 ESP", false, function(state)
    MM2_ESP_Enabled = state
    if state then
        GetMM2Roles()
        for _, p in ipairs(Players:GetPlayers()) do
            CreateESP(p)
        end
    end
end)

CreateToggle("Auto Aim (Murderer)", false, function(state)
    AutoAim_Enabled = state
end)

CreateToggle("Fullbright", false, function(state)
    Fullbright_Enabled = state
    if state then
        UpdateFullbright()
    else
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

CreateToggle("Infinite Jump", false, function(state)
    InfiniteJump_Enabled = state
end)

CreateSlider("WalkSpeed", 16, 100, 16, function(value)
    CustomSpeed = value
end)

-- Очистка при выходе игроков
Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        if EspObjects[player].Billboard then EspObjects[player].Billboard:Destroy() end
        if EspObjects[player].Highlight then EspObjects[player].Highlight:Destroy() end
        if EspObjects[player].Connection then EspObjects[player].Connection:Disconnect() end
        EspObjects[player] = nil
    end
end)

print("Delta MM2 Script successfully loaded!")

