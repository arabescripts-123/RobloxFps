-- FPS Game Script
print("[FPS] Iniciando...")

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

pcall(function()
    if game.CoreGui:FindFirstChild("FPSGui") then
        game.CoreGui:FindFirstChild("FPSGui"):Destroy()
    end
end)

task.wait(1)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSGui"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 390)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(0, 0, 0)
UIStroke.Thickness = 3

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Arabe Scripts"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Active = true

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Parent = MainFrame
rejoinBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
rejoinBtn.Position = UDim2.new(1, -35, 0, 5)
rejoinBtn.Size = UDim2.new(0, 30, 0, 30)
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.Text = "R"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.TextSize = 14

local rejoinCorner = Instance.new("UICorner")
rejoinCorner.CornerRadius = UDim.new(0, 6)
rejoinCorner.Parent = rejoinBtn

local dragging, dragInput, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function createButton(text, position)
    local Button = Instance.new("TextButton")
    local BtnCorner = Instance.new("UICorner")
    local Indicator = Instance.new("Frame")
    local IndicatorCorner = Instance.new("UICorner")
    
    Button.Parent = MainFrame
    Button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Button.Position = position
    Button.Size = UDim2.new(0, 130, 0, 35)
    Button.Font = Enum.Font.Gotham
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Indicator.Parent = Button
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Indicator.Position = UDim2.new(1, -25, 0.5, -8)
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.BorderSizePixel = 0
    
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    return Button, Indicator
end

local function createKeyBox(text, position)
    local Box = Instance.new("TextBox")
    Box.Parent = MainFrame
    Box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Box.Position = position
    Box.Size = UDim2.new(0, 35, 0, 35)
    Box.Font = Enum.Font.Gotham
    Box.Text = text
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.TextSize = 10
    Box.ClearTextOnFocus = false
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Box
    return Box
end

local espKey = Enum.KeyCode.J
local aimbotKey = Enum.KeyCode.X
local autoFireKey = Enum.KeyCode.C
local maxKey = Enum.KeyCode.V
local fovKey = Enum.KeyCode.N
local toggleKey = Enum.KeyCode.Z

local aimbotEnabled = false
local aimbotFOV = 100
local rightMouseDown = false
local autoFireEnabled = false
local maxEnabled = false
local showFOV = false

local espEnabled = false
local espBoxes = {}
local espConnections = {}

local function isEnemy(otherPlayer)
    if not otherPlayer or otherPlayer == player then return false end
    if not player.Team or not otherPlayer.Team then return true end
    if player.Team.Name == "FFA" or otherPlayer.Team.Name == "FFA" then return true end
    return otherPlayer.Team ~= player.Team
end

local function addESP(plr)
    if plr == player or not espEnabled then return end
    
    local function createHighlight(char)
        task.wait(0.1)
        if not espEnabled then return end
        
        pcall(function()
            if not isEnemy(plr) then return end
            
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not head or not humanoid then return end
            
            local color = Color3.fromRGB(255, 0, 0)
            
            local highlight = Instance.new("Highlight")
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0.2
            highlight.Adornee = char
            highlight.Parent = char
            
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = color
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.Parent = billboard
            
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local healthBillboard = Instance.new("BillboardGui")
            healthBillboard.Adornee = rootPart or head
            healthBillboard.Size = UDim2.new(0, 100, 0, 30)
            healthBillboard.StudsOffset = Vector3.new(0, -4, 0)
            healthBillboard.AlwaysOnTop = true
            healthBillboard.Parent = rootPart or head
            
            local healthLabel = Instance.new("TextLabel")
            healthLabel.Size = UDim2.new(1, 0, 1, 0)
            healthLabel.BackgroundTransparency = 1
            healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            healthLabel.TextStrokeTransparency = 0.5
            healthLabel.Font = Enum.Font.GothamBold
            healthLabel.TextSize = 12
            healthLabel.Parent = healthBillboard
            
            local function updateHealth()
                if humanoid and humanoid.Health > 0 then
                    healthLabel.Text = math.floor(humanoid.Health) .. " HP"
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    healthLabel.TextColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                end
            end
            
            updateHealth()
            humanoid.HealthChanged:Connect(updateHealth)
            
            if not espBoxes[plr] then espBoxes[plr] = {} end
            table.insert(espBoxes[plr], highlight)
            table.insert(espBoxes[plr], billboard)
            table.insert(espBoxes[plr], healthBillboard)
        end)
    end
    
    if plr.Character then createHighlight(plr.Character) end
    espConnections[plr] = plr.CharacterAdded:Connect(function(char)
        if espEnabled then createHighlight(char) end
    end)
end

local function removeESP(plr)
    if espBoxes[plr] then
        for _, v in pairs(espBoxes[plr]) do
            pcall(function() v:Destroy() end)
        end
        espBoxes[plr] = nil
    end
    if espConnections[plr] then
        espConnections[plr]:Disconnect()
        espConnections[plr] = nil
    end
end

local function refreshESP()
    for plr, _ in pairs(espBoxes) do
        if not isEnemy(plr) then
            removeESP(plr)
        end
    end
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and isEnemy(plr) then
            if not espBoxes[plr] and plr.Character then
                removeESP(plr)
                addESP(plr)
            end
        end
    end
end

local function enableESP()
    for _, plr in pairs(game.Players:GetPlayers()) do addESP(plr) end
    espConnections.playerAdded = game.Players.PlayerAdded:Connect(function(plr)
        if espEnabled then addESP(plr) end
    end)
    espConnections.playerRemoving = game.Players.PlayerRemoving:Connect(function(plr)
        removeESP(plr)
    end)
    espConnections.refresh = RunService.Heartbeat:Connect(function()
        if espEnabled and tick() % 2 < 0.016 then
            refreshESP()
        end
    end)
end

local function disableESP()
    for plr, _ in pairs(espBoxes) do removeESP(plr) end
    if espConnections.playerAdded then
        espConnections.playerAdded:Disconnect()
        espConnections.playerAdded = nil
    end
    if espConnections.playerRemoving then
        espConnections.playerRemoving:Disconnect()
        espConnections.playerRemoving = nil
    end
    if espConnections.refresh then
        espConnections.refresh:Disconnect()
        espConnections.refresh = nil
    end
end

local espBtn, espIndicator = createButton("ESP", UDim2.new(0, 10, 0, 50))
local espKeyBox = createKeyBox("J", UDim2.new(0, 145, 0, 50))

local aimbotBtn, aimbotIndicator = createButton("Aimbot", UDim2.new(0, 10, 0, 95))
local aimbotKeyBox = createKeyBox("X", UDim2.new(0, 145, 0, 95))

local autoFireBtn, autoFireIndicator = createButton("Auto Fire", UDim2.new(0, 10, 0, 140))
local autoFireKeyBox = createKeyBox("C", UDim2.new(0, 145, 0, 140))

local maxBtn, maxIndicator = createButton("Max", UDim2.new(0, 10, 0, 185))
local maxKeyBox = createKeyBox("V", UDim2.new(0, 145, 0, 185))

local fovBtn, fovIndicator = createButton("Show FOV", UDim2.new(0, 10, 0, 230))
local fovKeyBox = createKeyBox("N", UDim2.new(0, 145, 0, 230))

local fovLabel = Instance.new("TextLabel")
fovLabel.Parent = MainFrame
fovLabel.BackgroundTransparency = 1
fovLabel.Position = UDim2.new(0, 10, 0, 275)
fovLabel.Size = UDim2.new(1, -20, 0, 20)
fovLabel.Font = Enum.Font.Gotham
fovLabel.Text = "FOV: 100"
fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovLabel.TextSize = 12
fovLabel.TextXAlignment = Enum.TextXAlignment.Left

local fovSliderBg = Instance.new("Frame")
fovSliderBg.Parent = MainFrame
fovSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
fovSliderBg.Position = UDim2.new(0, 10, 0, 300)
fovSliderBg.Size = UDim2.new(0, 200, 0, 20)
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 6)
sliderCorner.Parent = fovSliderBg

local fovSliderFill = Instance.new("Frame")
fovSliderFill.Parent = fovSliderBg
fovSliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
fovSliderFill.Size = UDim2.new(0.11, 0, 1, 0)
fovSliderFill.BorderSizePixel = 0
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 6)
fillCorner.Parent = fovSliderFill

local fovSliderBtn = Instance.new("TextButton")
fovSliderBtn.Parent = fovSliderBg
fovSliderBtn.BackgroundTransparency = 1
fovSliderBtn.Size = UDim2.new(1, 0, 1, 0)
fovSliderBtn.Text = ""

local sliderDragging = false
fovSliderBtn.MouseButton1Down:Connect(function()
    sliderDragging = true
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if sliderDragging and not maxEnabled then
        local mousePos = UIS:GetMouseLocation()
        local sliderPos = fovSliderBg.AbsolutePosition
        local sliderSize = fovSliderBg.AbsoluteSize
        local relativePos = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
        aimbotFOV = math.floor(50 + (450 * relativePos))
        fovSliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        fovLabel.Text = "FOV: " .. aimbotFOV
    end
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        enableESP()
        espIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        disableESP()
        espIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

local function getClosestEnemyInFOV()
    local mouse = player:GetMouse()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local closest = nil
    local shortestDistance = aimbotFOV
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            
            if humanoid and head and humanoid.Health > 0 then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {player.Character}
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        local result = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, (head.Position - workspace.CurrentCamera.CFrame.Position).Unit * 1000, raycastParams)
                        if result and result.Instance:IsDescendantOf(plr.Character) then
                            shortestDistance = distance
                            closest = head
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function getClosestEnemyHead()
    local cam = workspace.CurrentCamera
    local closest = nil
    local shortestDistance = math.huge
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            
            if humanoid and head and humanoid.Health > 0 then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {player.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local result = workspace:Raycast(cam.CFrame.Position, (head.Position - cam.CFrame.Position).Unit * 1000, raycastParams)
                    if result and result.Instance:IsDescendantOf(plr.Character) then
                        local distance = (cam.CFrame.Position - head.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closest = head
                        end
                    end
                end
            end
        end
    end
    return closest
end

local headExpansion = 3

player.CharacterAdded:Connect(function()
    task.wait(1)
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                head.Size = head.Size + Vector3.new(headExpansion, headExpansion, headExpansion)
                head.Transparency = 1
                head.CanCollide = false
            end
        end
    end
end)

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if plr ~= player then
            local head = char:FindFirstChild("Head")
            if head then
                head.Size = head.Size + Vector3.new(headExpansion, headExpansion, headExpansion)
                head.Transparency = 1
                head.CanCollide = false
            end
        end
    end)
end)

for _, plr in pairs(game.Players:GetPlayers()) do
    if plr ~= player and plr.Character then
        local head = plr.Character:FindFirstChild("Head")
        if head then
            head.Size = head.Size + Vector3.new(headExpansion, headExpansion, headExpansion)
            head.Transparency = 1
            head.CanCollide = false
        end
    end
end

local function isEnemyInCrosshair()
    local cam = workspace.CurrentCamera
    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local ray = cam:ViewportPointToRay(screenCenter.X, screenCenter.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    
    if result and result.Instance then
        local hitChar = result.Instance.Parent
        local hitPlayer = game.Players:GetPlayerFromCharacter(hitChar)
        
        if hitPlayer and isEnemy(hitPlayer) then
            local humanoid = hitChar:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                return true, hitPlayer
            end
        end
    end
    return false, nil
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 50
FOVCircle.Radius = aimbotFOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false
FOVCircle.Filled = false
FOVCircle.Transparency = 1

RunService.RenderStepped:Connect(function()
    if showFOV then
        local mousePos = UIS:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = aimbotFOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    if maxEnabled then
        local target = getClosestEnemyHead()
        if target then
            local cam = workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
        end
    elseif aimbotEnabled and rightMouseDown then
        local target = getClosestEnemyInFOV()
        if target then
            local cam = workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if maxEnabled or autoFireEnabled then
        local hasEnemy = isEnemyInCrosshair()
        if hasEnemy then
            pcall(function()
                mouse1press()
                task.wait(0.001)
                mouse1release()
            end)
        end
    end
end)

aimbotBtn.MouseButton1Click:Connect(function()
    if maxEnabled then return end
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        aimbotIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        aimbotIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

autoFireBtn.MouseButton1Click:Connect(function()
    if maxEnabled then return end
    autoFireEnabled = not autoFireEnabled
    if autoFireEnabled then
        autoFireIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        autoFireIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

maxBtn.MouseButton1Click:Connect(function()
    maxEnabled = not maxEnabled
    if maxEnabled then
        aimbotEnabled = false
        autoFireEnabled = false
        showFOV = false
        aimbotIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        autoFireIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        fovIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        maxIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        maxIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

fovBtn.MouseButton1Click:Connect(function()
    if maxEnabled then return end
    showFOV = not showFOV
    if showFOV then
        fovIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        fovIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)



rejoinBtn.MouseButton1Click:Connect(function()
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
    ts:Teleport(game.PlaceId, p)
end)

espKeyBox.FocusLost:Connect(function()
    local text = espKeyBox.Text:upper()
    local success, key = pcall(function() return Enum.KeyCode[text] end)
    if success and key then
        espKey = key
        espKeyBox.Text = text
    else
        espKeyBox.Text = "J"
        espKey = Enum.KeyCode.J
    end
end)

aimbotKeyBox.FocusLost:Connect(function()
    local text = aimbotKeyBox.Text:upper()
    local success, key = pcall(function() return Enum.KeyCode[text] end)
    if success and key then
        aimbotKey = key
        aimbotKeyBox.Text = text
    else
        aimbotKeyBox.Text = "X"
        aimbotKey = Enum.KeyCode.X
    end
end)

autoFireKeyBox.FocusLost:Connect(function()
    local text = autoFireKeyBox.Text:upper()
    local success, key = pcall(function() return Enum.KeyCode[text] end)
    if success and key then
        autoFireKey = key
        autoFireKeyBox.Text = text
    else
        autoFireKeyBox.Text = "C"
        autoFireKey = Enum.KeyCode.C
    end
end)

maxKeyBox.FocusLost:Connect(function()
    local text = maxKeyBox.Text:upper()
    local success, key = pcall(function() return Enum.KeyCode[text] end)
    if success and key then
        maxKey = key
        maxKeyBox.Text = text
    else
        maxKeyBox.Text = "V"
        maxKey = Enum.KeyCode.V
    end
end)

fovKeyBox.FocusLost:Connect(function()
    local text = fovKeyBox.Text:upper()
    local success, key = pcall(function() return Enum.KeyCode[text] end)
    if success and key then
        fovKey = key
        fovKeyBox.Text = text
    else
        fovKeyBox.Text = "N"
        fovKey = Enum.KeyCode.N
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = true
        return
    end
    
    if gameProcessed then return end
    
    if input.KeyCode == toggleKey then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == espKey then
        espEnabled = not espEnabled
        if espEnabled then
            enableESP()
            espIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        else
            disableESP()
            espIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    elseif input.KeyCode == aimbotKey then
        if maxEnabled then return end
        aimbotEnabled = not aimbotEnabled
        if aimbotEnabled then
            aimbotIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        else
            aimbotIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    elseif input.KeyCode == autoFireKey then
        if maxEnabled then return end
        autoFireEnabled = not autoFireEnabled
        if autoFireEnabled then
            autoFireIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        else
            autoFireIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    elseif input.KeyCode == maxKey then
        maxEnabled = not maxEnabled
        if maxEnabled then
            aimbotEnabled = false
            autoFireEnabled = false
            showFOV = false
            aimbotIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            autoFireIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            fovIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            maxIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        else
            maxIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    elseif input.KeyCode == fovKey then
        if maxEnabled then return end
        showFOV = not showFOV
        if showFOV then
            fovIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        else
            fovIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = false
    end
end)

ScreenGui.Parent = game.CoreGui

print("[FPS] Carregado! Z=Menu J=ESP X=Aimbot C=AutoFire V=Max N=FOV | Scroll=FOV Size | Aimbot: Segure BOTAO DIREITO")
