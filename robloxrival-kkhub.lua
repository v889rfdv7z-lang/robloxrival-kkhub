-- 서비스 로드
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- 설정값
local FOV_RADIUS = 1500
local aimbotEnabled = false
local espEnabled = true

-- 1. 모바일 전용 화면 GUI (AIM 버튼) 생성
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KKHubMobileGui"
ScreenGui.ResetOnSpawn = false

-- 실행 환경에 따라 안전하게 GUI 부착
local success, err = pcall(function()
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)
if not success then
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- AIM 버튼
local AimButton = Instance.new("TextButton")
AimButton.Name = "AimButton"
AimButton.Parent = ScreenGui
AimButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
AimButton.Position = UDim2.new(0.75, 0, 0.45, 0) -- 우측 하단 화면
AimButton.Size = UDim2.new(0, 75, 0, 75)
AimButton.Text = "AIM"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.TextSize = 22
AimButton.Font = Enum.Font.SourceSansBold

-- 버튼 모서리 둥글게 처리
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = AimButton

-- 모바일 터치 이벤트 (누르고 있는 동안 조준)
AimButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimbotEnabled = true
        AimButton.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
    end
end)

AimButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimbotEnabled = false
        AimButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

-- 2. 가장 가까운 적 머리(Head) 탐색 함수
local function getClosestEnemyHead()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChildOfClass("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local head = player.Character.Head
                local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- 화면 중심 기준 거리 계산
                    local viewportSize = Camera.ViewportSize
                    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- 3. 에임봇 (AIM 버튼을 누르는 동안 적 머리로 카메라 추적)
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemyHead()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- 4. Silent Aim (메타테이블 기반 총알 궤적 보정)
local metaTable = nil
pcall(function()
    metaTable = getrawmetatable(game)
end)

if metaTable then
    local oldNamecall = metaTable.__namecall
    setreadonly(metaTable, false)

    metaTable.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "FindPartOnWithIgnoreList" or method == "Raycast" then
            local target = getClosestEnemyHead()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                if method == "Raycast" then
                    args[2] = (target.Character.Head.Position - args[1]).Unit * 1000
                end
            end
        end

        return oldNamecall(self, unpack(args))
    end)

    setreadonly(metaTable, true)
end

-- 5. ESP (적 위치 빨간색 하이라이트)
local function applyESP(player)
    if player == LocalPlayer then return end

    local function setupHighlight(char)
        if not espEnabled then return end
        local highlight = char:FindFirstChild("ESPHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Adornee = char
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = char
        end
    end

    if player.Character then setupHighlight(player.Character) end
    player.CharacterAdded:Connect(setupHighlight)
end

for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- 6. 모바일 속도 보정 (WalkSpeed 32)
local function setSpeed(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = 32
    end
end

if LocalPlayer.Character then setSpeed(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setSpeed)

print("모바일 전용 KK Hub 스크립트 로드 완료!")
