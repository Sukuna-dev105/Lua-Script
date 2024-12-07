--Sukuna制作,QQ交流群：258819341
tweenService = game:GetService("TweenService")
local tweenSpeed = 150

local function calculateTweenDuration(startPos, endPos, speed)
    local distance = (endPos - startPos).magnitude
    return distance / speed
end

local function createTweenInfo(startPos, endPos)
    local duration = calculateTweenDuration(startPos, endPos, tweenSpeed)
    return TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
end

local isTweenMode = false
local currentTween = nil

local teleportButtons = {}
local visibilityToggleButton, modeToggleButton, textBox, speedTextBox

local function createButton(parent, position, text, clickFunction, textColor, backgroundColor)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.9
    frame.BorderColor3 = Color3.fromRGB(0, 0, 255)
    frame.BorderSizePixel = 2
    frame.Size = UDim2.new(0.5, -1, 0.1, -10)
    frame.Position = position
    frame.Active = true
    frame.Draggable = true

    local textButton = Instance.new("TextButton")
    textButton.Parent = frame
    textButton.BackgroundColor3 = backgroundColor or Color3.fromRGB(255, 255, 255)
    textButton.BackgroundTransparency = 0.5
    textButton.Position = UDim2.new(0.05, 0, 0.05, 0)
    textButton.TextColor3 = textColor or Color3.fromRGB(255, 0, 0)
    textButton.Size = UDim2.new(0.9, 0, 0.9, 0)
    textButton.Font = Enum.Font.PatrickHand
    textButton.FontSize = Enum.FontSize.Size14
    textButton.Text = text
    textButton.TextScaled = true
    textButton.TextSize = 14
    textButton.TextWrapped = true

    textButton.MouseButton1Click:Connect(clickFunction)

    table.insert(teleportButtons, frame)
end

local function printAllPlayerNames()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        print(player.Name)
    end
end

printAllPlayerNames()

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.CoreGui

local buttonContainer = Instance.new("Frame")
buttonContainer.Parent = screenGui
buttonContainer.BackgroundTransparency = 1
buttonContainer.Size = UDim2.new(0.2, 0, 0.8, 0)
buttonContainer.Position = UDim2.new(0.9, 0, 0.2, 0)
buttonContainer.Visible = true

visibilityToggleButton = Instance.new("TextButton")
visibilityToggleButton.Parent = screenGui
visibilityToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
visibilityToggleButton.BackgroundTransparency = 0.5
visibilityToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 255)
visibilityToggleButton.BorderSizePixel = 2
visibilityToggleButton.Position = UDim2.new(0.9, 0, 0.05, 0)
visibilityToggleButton.Size = UDim2.new(0.1, 0, 0.1, 0)
visibilityToggleButton.Text = "隐藏"
visibilityToggleButton.TextColor3 = Color3.fromRGB(0, 191, 255)
visibilityToggleButton.Font = Enum.Font.PatrickHand
visibilityToggleButton.FontSize = Enum.FontSize.Size14
visibilityToggleButton.TextScaled = true

local uiCornerVisibility = Instance.new("UICorner")
uiCornerVisibility.CornerRadius = UDim.new(0.5, 0)
uiCornerVisibility.Parent = visibilityToggleButton

local isVisible = true
visibilityToggleButton.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    buttonContainer.Visible = isVisible
    modeToggleButton.Visible = isVisible
    textBox.Visible = isVisible
    speedTextBox.Visible = isVisible
    visibilityToggleButton.Text = isVisible and "隐藏" or "显示"
end)

modeToggleButton = Instance.new("TextButton")
modeToggleButton.Parent = screenGui
modeToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
modeToggleButton.BackgroundTransparency = 0.5
modeToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 255)
modeToggleButton.BorderSizePixel = 2
modeToggleButton.Position = UDim2.new(0.9, 0, 0.15, 0)
modeToggleButton.Size = UDim2.new(0.1, 0, 0.1, 0)
modeToggleButton.Text = "瞬移"
modeToggleButton.TextColor3 = Color3.fromRGB(220, 20, 60)
modeToggleButton.Font = Enum.Font.PatrickHand
modeToggleButton.FontSize = Enum.FontSize.Size14
modeToggleButton.TextScaled = true

local uiCornerMode = Instance.new("UICorner")
uiCornerMode.CornerRadius = UDim.new(0.5, 0)
uiCornerMode.Parent = modeToggleButton

modeToggleButton.MouseButton1Click:Connect(function()
    isTweenMode = not isTweenMode
    modeToggleButton.Text = isTweenMode and "飞行" or "瞬移"
    modeToggleButton.TextColor3 = isTweenMode and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 20, 60)
    
    if not isTweenMode and currentTween then
        currentTween:Cancel()
    end
end)

textBox = Instance.new("TextBox")
textBox.Parent = screenGui
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
textBox.BackgroundTransparency = 0.5
textBox.BorderColor3 = Color3.fromRGB(0, 0, 255)
textBox.BorderSizePixel = 2
textBox.Position = UDim2.new(0.9, 0, 0.25, 0)
textBox.Size = UDim2.new(0.1, 0, 0.1, 0)
textBox.Text = "瞬移玩家用户名"
textBox.TextColor3 = Color3.fromRGB(255, 255, 0)
textBox.Font = Enum.Font.PatrickHand
textBox.TextScaled = true
textBox.ClearTextOnFocus = false

local uiCornerTextBox = Instance.new("UICorner")
uiCornerTextBox.CornerRadius = UDim.new(0.5, 0)
uiCornerTextBox.Parent = textBox

textBox.FocusLost:Connect(function(enterPressed)
    while enterPressed do
	    wait()
        local username = textBox.Text
        local player = game:GetService("Players"):FindFirstChild(username)
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = player.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
            local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            if isTweenMode then
                if currentTween then
                    currentTween:Cancel()
                end

                local goal = {CFrame = CFrame.new(targetPosition)}
                local tweenInfo = createTweenInfo(playerPos, targetPosition)
                currentTween = tweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, goal)
                currentTween:Play()
            else
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            end
        else
            warn("Player not found: " .. username)
        end
    end
end)

speedTextBox = Instance.new("TextBox")
speedTextBox.Parent = screenGui
speedTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
speedTextBox.BackgroundTransparency = 0.5
speedTextBox.BorderColor3 = Color3.fromRGB(0, 0, 255)
speedTextBox.BorderSizePixel = 2
speedTextBox.Position = UDim2.new(0.95, 0, 0.75, 0)
speedTextBox.Size = UDim2.new(0.05, 0, 0.1, 0)
speedTextBox.Text = tostring(tweenSpeed)
speedTextBox.TextColor3 = Color3.fromRGB(170, 0, 255)
speedTextBox.Font = Enum.Font.PatrickHand
speedTextBox.TextScaled = true
speedTextBox.ClearTextOnFocus = false

local uiCornerSpeedTextBox = Instance.new("UICorner")
uiCornerSpeedTextBox.CornerRadius = UDim.new(0.5, 0)
uiCornerSpeedTextBox.Parent = speedTextBox

speedTextBox.FocusLost:Connect(function(enterPressed)
    while enterPressed do
	    wait()
        local newSpeed = tonumber(speedTextBox.Text)
        if newSpeed and newSpeed > 0 then
            tweenSpeed = newSpeed
        else
            warn("Invalid tween speed: " .. tostring(speedTextBox.Text))
        end
    end
end)

updateLabels()

local tweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
--Sukuna制作,QQ交流群：258819341