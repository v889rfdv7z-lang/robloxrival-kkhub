local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. 메인 GUI 생성
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KKHubGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)

-- 2. 메인 프레임
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- 3. 타이틀 바
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(1, -30, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "KK Hub v2 | Development Build"
TitleText.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- 닫기 버튼 (오타 완벽 수정)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 4. UI 컨텐츠 레이아웃
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -40)
Container.Position = UDim2.new(0, 10, 0, 35)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 5)

local dodgeEnabled = true

local function CreateToggleButton(name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(40, 40, 40)
    btn.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(40, 40, 40)
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

CreateToggleButton("Auto Dodge (자동 회피)", true, function(enabled)
    dodgeEnabled = enabled
end)

---------------------------------------------------------
-- 5. 게임 기능 로직 (원본 기능 구동부 완벽 재구성)
---------------------------------------------------------

-- [기능 1] 가장 가까운 적 탐색
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myChar = LocalPlayer.Character
    
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- [기능 2] 상대방이 나를 조준하는지 감지 (누락되었던 함수 추가)
local function isBeingAimedAt(targetPlayer, myChar)
    if not targetPlayer or not targetPlayer.Character or not myChar then return false end
    local enemyHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    
    if not enemyHRP or not myHRP then return false end

    local enemyLookVector = enemyHRP.CFrame.LookVector
    local dirToMe = (myHRP.Position - enemyHRP.Position).Unit
    local dotProduct = enemyLookVector:Dot(dirToMe)

    return dotProduct > 0.75 -- 적이 나를 바라보는 각도 감지
end

-- [기능 3] RenderStepped 메인 실행 루프 (자동 회피)
RunService.RenderStepped:Connect(function()
    if not dodgeEnabled then return end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    local myHRP = myChar.HumanoidRootPart
    local targetPlayer = getClosestPlayer()

    -- 적이 나를 조준할 때 오른쪽으로 가속 회피 (AssemblyLinearVelocity 연산 정상화)
    if targetPlayer and isBeingAimedAt(targetPlayer, myChar) then
        myHRP.AssemblyLinearVelocity = myHRP.CFrame.RightVector * 35
    end
end)
