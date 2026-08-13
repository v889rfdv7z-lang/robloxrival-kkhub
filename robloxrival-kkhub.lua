local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. 메인 GUI 생성
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomHubUI"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)

-- 2. 메인 프레임 (배경)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- 3. 상단 타이틀 바
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "KK Hub v2 | Development Build"
TitleText.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- 4. 닫기 버튼
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

---------------------------------------------------------
-- 5. 타겟 탐색 및 추적 함수 (문법 및 오타 수정완료)
---------------------------------------------------------

-- 가장 가까운 플레이어를 구하는 함수
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = player.Character.HumanoidRootPart
                local dist = (targetHRP.Position - myPos).Magnitude
                
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- 조준 여부 확인 함수 (예시 구현 추가)
local function isBeingAimedAt(targetPlayer, myChar)
    if not targetPlayer or not targetPlayer.Character or not myChar then return false end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    
    if targetHRP and myHRP then
        local lookDir = targetHRP.CFrame.LookVector
        local dirToMe = (myHRP.Position - targetHRP.Position).Unit
        return lookDir:Dot(dirToMe) > 0.9 -- 상대가 나를 거의 직선으로 바라볼 때 true
    end
    return false
end

-- FSM 상태 정의
local EnumState = {
    CHASE = "CHASE",
    DODGE = "DODGE"
}

local currentState = EnumState.CHASE -- 대소문자 통일 (currentState)

-- 메인 업데이트 루프 (RenderStepped)
RunService.RenderStepped:Connect(function()
    local targetPlayer = getClosestPlayer() -- 114번 줄 미완성 문법 수정 완료
    if not targetPlayer then return end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    -- 조준 감지 상태 업데이트
    if isBeingAimedAt(targetPlayer, myChar) then
        currentState = EnumState.DODGE
    else
        currentState = EnumState.CHASE
    end

    -- 상태별 동작 처리
    if currentState == EnumState.DODGE then
        -- 회피 동작 수행 (예시: 옆으로 신속 이동)
        local myHRP = myChar.HumanoidRootPart
        myHRP.AssemblyLinearVelocity = myHRP.CFrame.RightVector * 30
    elseif currentState == EnumState.CHASE then
        -- 추적 동작 수행
        local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
        if myHumanoid and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            myHumanoid:MoveTo(targetPlayer.Character.HumanoidRootPart.Position)
        end
    end
end)
