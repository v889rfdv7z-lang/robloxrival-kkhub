local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- UI 생성
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KKHub_Rivals"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 300)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- 타이틀 바
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(1, -35, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "KK Hub v2 | Rivals Full Release"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(230, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 컨테이너
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -45)
Container.Position = UDim2.new(0, 10, 0, 40)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 6)

-- 설정 변수
local Settings = {
    Aimbot = false,
    ESP = false,
    AutoDodge = false
}

local function CreateToggle(name, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.Text = name .. " : OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        if Settings[key] then
            btn.BackgroundColor3 = Color3.fromRGB(45, 140, 60)
            btn.Text = name .. " : ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            btn.Text = name .. " : OFF"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

-- 기능 토글 버튼 등록
CreateToggle("Aimbot (에임 조준)", "Aimbot")
CreateToggle("ESP (적 위치 표시)", "ESP")
CreateToggle("Auto Dodge (자동 회피)", "AutoDodge")

---------------------------------------------------------
-- 기능 실행 로직
---------------------------------------------------------

-- 가장 가까운 적 찾기
local function GetClosestTarget()
    local closest, minDistance = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closest = player.Character
                end
            end
        end
    end
    return closest
end

-- ESP (적 테두리 표시) 업데이트
local highlights = {}
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.ESP and player.Character:FindFirstChild("HumanoidRootPart") then
                if not highlights[player] then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = player.Character
                    highlights[player] = hl
                end
            else
                if highlights[player] then
                    highlights[player]:Destroy()
                    highlights[player] = nil
                end
            end
        end
    end
end

-- 메인 루프 (RenderStepped)
RunService.RenderStepped:Connect(function()
    UpdateESP()

    local target = GetClosestTarget()
    local myChar = LocalPlayer.Character

    -- 1. 에임봇 (Aimbot)
    if Settings.Aimbot and target and target:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
    end

    -- 2. 자동 회피 (Auto Dodge - 점프 및 순간 방향 전환)
    if Settings.AutoDodge and target and myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("Humanoid") then
        local enemyHRP = target:FindFirstChild("HumanoidRootPart")
        local myHRP = myChar.HumanoidRootPart
        
        if enemyHRP then
            local dirToMe = (myHRP.Position - enemyHRP.Position).Unit
            local enemyLook = enemyHRP.CFrame.LookVector
            
            -- 적이 나를 조준하고 있을 때
            if enemyLook:Dot(dirToMe) > 0.7 then
                if myChar.Humanoid.FloorMaterial ~= Enum.Material.Air then
                    myChar.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- 순간 점프 회피
                    myHRP.CFrame = myHRP.CFrame * CFrame.new(3, 0, 0) -- 옆으로 순간 이동
                end
            end
        end
    end
end)
