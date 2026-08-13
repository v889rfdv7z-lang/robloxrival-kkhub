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

-- 2. 메인 프레임 (배경 창)
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
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "KK Hub v2 | Beta Version"
TitleText.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- 닫기 버튼
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- 4. 탭 상단 메뉴
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabBar

local tabs = {"Main", "Visuals", "Misc", "Settings"}
local tabFrames = {}

-- 5. 추적 기능 제어 로직
local followConnection = nil

local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

-- 가장 가까운 플레이어를 검색하는 함수 (TargetPlayer 미정의 에러 해결)
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function startFollowing(distanceBehind)
    stopFollowing()
    
    followConnection = RunService.RenderStepped:Connect(function()
        local targetPlayer = get
local EnumState = {
    CHASE = "CHASE",
    DODGE = "DODGE"
}

local currentState = EnumState.CHASE

-- 메인 루프 (서버 스크립트 또는 NPC AI)
game:GetService("RunService").Heartbeat:Connect(function()
    local target = getClosestPlayer()
    if not target then return end

    -- 1. 상대가 나를 조준/사격 중인지 감지
    if isBeingAimedAt(target, myCharacter) then
        currentState = EnumState.DODGE
    else
        currentState = EnumState.CHASE
    end

    -- 2. 상태에 따른 행동 수행
    if currentState == EnumState.DODGE then
        -- 사격 감지 시 옆으로 빠른 이동 (Velocitiy 또는 MoveTo)
        dodgeToSide(myCharacter)
    elseif currentState == EnumState.CHASE then
        -- 평소에는 상대 뒤쪽 위치로 정상 이동
        moveToTargetBehind(myCharacter, target)
    end
end)
