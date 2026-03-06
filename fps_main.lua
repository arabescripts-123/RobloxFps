-- FPS Game Script
-- Sistema de ESP, Aimbot e Auto Fire

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações
local Config = {
    ESP = {
        Enabled = false,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        BoxESP = true,
        TeamCheck = false
    },
    Aimbot = {
        Enabled = false,
        FOV = 100,
        ShowFOV = true,
        TeamCheck = false,
        VisibleCheck = true,
        TargetPart = "Head"
    },
    AutoFire = {
        Enabled = false
    }
}

-- ESP Storage
local ESPObjects = {}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 50
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = Config.Aimbot.ShowFOV
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- Funções Auxiliares
local function IsAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetTeam(player)
    return player.Team
end

local function IsVisible(targetPart)
    if not targetPart then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(targetPart.Parent)
end

local function GetDistance(part)
    if not part then return math.huge end
    return (Camera.CFrame.Position - part.Position).Magnitude
end

local function WorldToScreen(position)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen
end

-- ESP Functions
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        HealthBar = Drawing.new("Line")
    }
    
    esp.Box.Thickness = 2
    esp.Box.Color = Color3.fromRGB(255, 255, 255)
    esp.Box.Filled = false
    esp.Box.Visible = false
    
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Visible = false
    
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
    esp.Distance.Visible = false
    
    esp.Health.Size = 12
    esp.Health.Center = true
    esp.Health.Outline = true
    esp.Health.Color = Color3.fromRGB(0, 255, 0)
    esp.Health.Visible = false
    
    esp.HealthBar.Thickness = 2
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Visible = false
    
    ESPObjects[player] = esp
end

local function RemoveESP(player)
    if not ESPObjects[player] then return end
    
    for _, drawing in pairs(ESPObjects[player]) do
        drawing:Remove()
    end
    
    ESPObjects[player] = nil
end

local function UpdateESP(player)
    if not Config.ESP.Enabled or player == LocalPlayer then return end
    if not IsAlive(player) then
        if ESPObjects[player] then
            for _, drawing in pairs(ESPObjects[player]) do
                drawing.Visible = false
            end
        end
        return
    end
    
    if Config.ESP.TeamCheck and GetTeam(player) == GetTeam(LocalPlayer) then
        if ESPObjects[player] then
            for _, drawing in pairs(ESPObjects[player]) do
                drawing.Visible = false
            end
        end
        return
    end
    
    if not ESPObjects[player] then
        CreateESP(player)
    end
    
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart or not humanoid then return end
    
    local esp = ESPObjects[player]
    local headPos = character:FindFirstChild("Head") and character.Head.Position or rootPart.Position
    local legPos = rootPart.Position - Vector3.new(0, 3, 0)
    
    local headScreen, headOnScreen = WorldToScreen(headPos)
    local legScreen, legOnScreen = WorldToScreen(legPos)
    
    if headOnScreen and legOnScreen then
        local height = (headScreen - legScreen).Magnitude
        local width = height / 2
        
        if Config.ESP.BoxESP then
            esp.Box.Size = Vector2.new(width, height)
            esp.Box.Position = Vector2.new(headScreen.X - width / 2, headScreen.Y)
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        if Config.ESP.ShowName then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headScreen.X, headScreen.Y - 20)
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        if Config.ESP.ShowDistance then
            local distance = math.floor(GetDistance(rootPart))
            esp.Distance.Text = distance .. "m"
            esp.Distance.Position = Vector2.new(headScreen.X, legScreen.Y + 5)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        if Config.ESP.ShowHealth then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            esp.Health.Text = math.floor(humanoid.Health) .. " HP"
            esp.Health.Position = Vector2.new(headScreen.X, headScreen.Y - 35)
            esp.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            esp.Health.Visible = true
            
            esp.HealthBar.From = Vector2.new(headScreen.X - width / 2 - 5, headScreen.Y)
            esp.HealthBar.To = Vector2.new(headScreen.X - width / 2 - 5, headScreen.Y + height * healthPercent)
            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            esp.HealthBar.Visible = true
        else
            esp.Health.Visible = false
            esp.HealthBar.Visible = false
        end
    else
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
    end
end

-- Aimbot Functions
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if Config.Aimbot.TeamCheck and GetTeam(player) == GetTeam(LocalPlayer) then
                continue
            end
            
            local character = player.Character
            local targetPart = character:FindFirstChild(Config.Aimbot.TargetPart)
            
            if targetPart then
                if Config.Aimbot.VisibleCheck and not IsVisible(targetPart) then
                    continue
                end
                
                local screenPos, onScreen = WorldToScreen(targetPart.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function AimAt(player)
    if not player or not IsAlive(player) then return end
    
    local character = player.Character
    local targetPart = character:FindFirstChild(Config.Aimbot.TargetPart)
    
    if targetPart then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    end
end

local function FireWeapon()
    local character = LocalPlayer.Character
    if not character then return end
    
    local weapon = character:FindFirstChild("Weapon")
    if weapon then
        local fireEvent = weapon:FindFirstChild("Fire", true)
        if fireEvent and fireEvent:IsA("RemoteEvent") then
            fireEvent:FireServer()
        end
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSScriptGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.BorderSizePixel = 0
Title.Text = "FPS Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local function CreateToggle(name, yPos, callback)
    local toggle = Instance.new("TextButton")
    toggle.Name = name
    toggle.Size = UDim2.new(0.9, 0, 0, 30)
    toggle.Position = UDim2.new(0.05, 0, 0, yPos)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.BorderSizePixel = 0
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 14
    toggle.Font = Enum.Font.Gotham
    toggle.Parent = MainFrame
    
    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = name .. ": " .. (enabled and "ON" or "OFF")
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
        callback(enabled)
    end)
    
    return toggle
end

local function CreateSlider(name, yPos, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.Parent = sliderFrame
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0.9, 0, 0, 20)
    slider.Position = UDim2.new(0.05, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local dragging = false
    
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition
            local sliderSize = slider.AbsoluteSize
            local relativePos = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relativePos)
            
            fill.Size = UDim2.new(relativePos, 0, 1, 0)
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

-- Toggles
CreateToggle("ESP", 40, function(enabled)
    Config.ESP.Enabled = enabled
    if not enabled then
        for player, esp in pairs(ESPObjects) do
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
    end
end)

CreateToggle("Aimbot", 80, function(enabled)
    Config.Aimbot.Enabled = enabled
end)

CreateToggle("Auto Fire", 120, function(enabled)
    Config.AutoFire.Enabled = enabled
end)

CreateToggle("Show FOV", 160, function(enabled)
    Config.Aimbot.ShowFOV = enabled
    FOVCircle.Visible = enabled
end)

CreateToggle("Team Check", 200, function(enabled)
    Config.ESP.TeamCheck = enabled
    Config.Aimbot.TeamCheck = enabled
end)

-- Sliders
CreateSlider("FOV", 250, 50, 300, 100, function(value)
    Config.Aimbot.FOV = value
    FOVCircle.Radius = value
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    if Config.Aimbot.ShowFOV then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    -- Update ESP
    for _, player in pairs(Players:GetPlayers()) do
        UpdateESP(player)
    end
    
    -- Aimbot
    if Config.Aimbot.Enabled then
        local target = GetClosestPlayer()
        if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            AimAt(target)
            
            -- Auto Fire
            if Config.AutoFire.Enabled then
                FireWeapon()
            end
        end
    end
end)

-- Player Events
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

print("FPS Script carregado com sucesso!")
