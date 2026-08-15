-- [[ KK HUB - Fixed ESP & Head Lock Aimbot ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- 1. 설정 저장 / 로드
-- ==========================================
local SettingsFile = "KK_HUB_Config.json"
local S = {
    Aimbot = false,
    SilentAim = false,
    Orbit = false,
    Wallbang = false,
    FastShot = false,
    NoRecoil = false,
    NoSpread = false,
    ESP = false,
    FullBright = false,
    InfJump = false,
    SpeedHack = false,
    SpeedVal = 100,
    AntiMelee = false,
}

local function SaveSettings()
    if writefile then pcall(function() writefile(SettingsFile, HttpService:JSONEncode(S)) end) end
end

local function LoadSettings()
    if isfile and isfile(SettingsFile) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(SettingsFile)) end)
        if success and type(decoded) == "table" then 
            for k, v in pairs(decoded) do S[k] = v end
        end
    end
end
LoadSettings()

-- ==========================================
-- 2. GUI 메뉴 (우측 상단 X 닫기 버튼)
-- ==========================================
if CoreGui:FindFirstChild("KK_HUB_Premium") then CoreGui.KK_HUB_Premium:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KK_HUB_Premium"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.Size = UDim2.new(1, 0, 0, 50)

local UICorner_2 = Instance.new("UICorner")
UICorner_2.CornerRadius = UDim.new(0, 12)
UICorner_2.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "KK HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 55, 55)
TitleLabel.TextSize = 24
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.Position = UDim2.new(1, -15, 0.5, 0)
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18

local UICorner_Close = Instance.new("UICorner")
UICorner_Close.CornerRadius = UDim.new(0, 8)
UICorner_Close.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 60)
Container.Size = UDim2.new(1, -20, 1, -70)
Container.CanvasSize = UDim2.new(0, 0, 0, 850)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

local function AddToggle(text, configKey, callback)
    local Entry = Instance.new("Frame")
    Entry.Name = text .. "_Entry"
    Entry.Parent = Container
    Entry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Entry.Size = UDim2.new(1, -10, 0, 60)

    local UICorner_E = Instance.new("UICorner")
    UICorner_E.CornerRadius = UDim.new(0, 8)
    UICorner_E.Parent = Entry

    local Label = Instance.new("TextLabel")
    Label.Parent = Entry
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 20, 0, 0)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 20
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Button = Instance.new("TextButton")
    Button.Parent = Entry
    Button.AnchorPoint = Vector2.new(1, 0.5)
    Button.Position = UDim2.new(1, -20, 0.5, 0)
    Button.Size = UDim2.new(0, 100, 0, 40)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 18

    local UICorner_B = Instance.new("UICorner")
    UICorner_B.CornerRadius = UDim.new(0, 8)
    UICorner_B.Parent = Button

    local function updateVisuals(bool)
        if bool then
            Button.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            Button.Text = "ON"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            Button.Text = "OFF"
            Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end

    updateVisuals(S[configKey])

    Button.MouseButton1Click:Connect(function()
        S[configKey] = not S[configKey]
        updateVisuals(S[configKey])
        SaveSettings()
        if callback then callback(S[configKey]) end
    end)
end

local function AddLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Parent = Container
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.Font = Enum.Font.GothamBold
    Label.Text = "--- " .. text .. " ---"
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextSize = 16
end

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 토글 메뉴 구성
AddLabel("BATTLE")
AddToggle("Aimbot (Close Head)", "Aimbot")
AddToggle("Silent Aim", "SilentAim")
AddToggle("Orbit (God Mode)", "Orbit")
AddToggle("Wallbang (벽뚫샷)", "Wallbang")
AddToggle("Fast Shot", "FastShot")
AddToggle("No Recoil", "NoRecoil")
AddToggle("No Spread", "NoSpread")

AddLabel("VISUAL")
AddToggle("ESP (Red Always Visible)", "ESP")
AddToggle("FullBright", "FullBright", function(v)
    if v then game:GetService("Lighting").Ambient = Color3.fromRGB(255,255,255)
    else game:GetService("Lighting").Ambient = Color3.fromRGB(127,127,127) end
end)

AddLabel("MOVEMENT")
AddToggle("Infinite Jump", "InfJump")
AddToggle("Speed Hack", "SpeedHack")

AddLabel("DEFENSE & MISC")
AddToggle("Anti-Knife/Katana", "AntiMelee")

-- ==========================================
-- 3. 핵심 타겟팅 & 강력한 ESP 로직
-- ==========================================

-- [가장 가까운 적의 머리(Head) 탐색]
local function getAbsoluteClosestEnemyHead()
    local closestHead = nil
    local shortestDistance = math.huge
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- 팀 구분 (팀이 없거나 서로 다른 경우만 적 판정)
            local isEnemy = not player.Team or (LocalPlayer.Team and player.Team ~= LocalPlayer.Team)
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")

            if isEnemy and hum and hum.Health > 0 and head then
                -- 월드 3D 거리 측정
                local dist = (head.Position - myRoot.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestHead = head
                end
            end
        end
    end
    return closestHead
end

-- [강력한 빨간색 ESP - 벽 투시 보장]
local function applyRedESP(player)
    if player == LocalPlayer then return end

    local function setupESP(character)
        if not character then return end
        
        -- 1) Highlight 적용
        local highlight = character:FindFirstChild("KK_ESP_HL") or Instance.new("Highlight")
        highlight.Name = "KK_ESP_HL"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- 벽 너머 표시 필수
        highlight.Parent = character

        -- 2) Fallback: Box ESP (Highlight가 렌더링되지 않는 게임 대비)
        local hrp = character:WaitForChild("HumanoidRootPart", 2)
        if hrp and not hrp:FindFirstChild("KK_ESP_Box") then
            local bgui = Instance.new("BillboardGui")
            bgui.Name = "KK_ESP_Box"
            bgui.Adornee = hrp
            bgui.AlwaysOnTop = true
            bgui.Size = UDim2.new(4, 0, 5.5, 0)
            bgui.Parent = hrp

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 0.6
            frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            frame.BorderSizePixel = 2
            frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
            frame.Parent = bgui
        end
    end

    if player.Character then setupESP(player.Character) end
    player.CharacterAdded:Connect(setupESP)
end

-- 기존 및 신규 유저 적용
for _, p in pairs(Players:GetPlayers()) do applyRedESP(p) end
Players.PlayerAdded:Connect(applyRedESP)

-- ESP 토글 제어 루프
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local isEnemy = not p.Team or (LocalPlayer.Team and p.Team ~= LocalPlayer.Team)
            local hl = p.Character:FindFirstChild("KK_ESP_HL")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local box = hrp and hrp:FindFirstChild("KK_ESP_Box")

            if S.ESP and isEnemy then
                if hl then hl.Enabled = true end
                if box then box.Enabled = true end
            else
                if hl then hl.Enabled = false end
                if box then box.Enabled = false end
            end
        end
    end
end)

-- ==========================================
-- 4. 메인 전투 및 스킬 루프
-- ==========================================
local orbitAngle = 0
RunService.RenderStepped:Connect(function(dt)
    -- 1. 오르빗 무적 모드
    if S.Orbit then
        local head = getAbsoluteClosestEnemyHead()
        local myChar = LocalPlayer.Character
        if head and myChar and myChar:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            orbitAngle = orbitAngle + (5 * dt)
            
            myChar.HumanoidRootPart.CFrame = CFrame.new(
                head.Position.X + (math.cos(orbitAngle) * 10),
                head.Position.Y - 200, -- 맵 아래 고정 (무적)
                head.Position.Z + (math.sin(orbitAngle) * 10)
            )
        end
    -- 2. 헤드 타겟팅 에임봇
    elseif S.Aimbot then
        local head = getAbsoluteClosestEnemyHead()
        if head then
            -- 무조건 가장 가까운 적의 Head로 시선 스냅 고정
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end

    -- 스피드핵
    if S.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = S.SpeedVal
    end
end)

-- 물리 판정 (벽뚫샷 / 안티 도구)
RunService.Stepped:Connect(function()
    if S.Wallbang then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
                part.CanQuery = false
            end
        end
    end

    if S.AntiMelee and LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") or name:find("katana") or name:find("sword") then
                    tool:Destroy()
                end
            end
        end
    end
end)

-- 점프 해제
UserInputService.JumpRequest:Connect(function()
    if S.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
