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

local tabs = {"Aimbot", "Silent", "Visuals", "Misc", "Settings"}
local tabFrames = {}

-- UI요소 생성용 헬퍼 함수 (체크박스)
local function createCheckbox(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 25)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(0, 0, 0.5, -8)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.BorderColor3 = Color3.fromRGB(70, 70, 70)
    box.Text = ""
    box.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -25, 1, 0)
    label.Position = UDim2.new(0, 25, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local enabled = false
    box.MouseButton1Click:Connect(function()
        enabled = not enabled
        box.BackgroundColor3 = enabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
        box.Text = enabled and "✓" or ""
        box.TextColor3 = Color3.fromRGB(0,0,0)
    end)
end

-- 탭 페이지 생성 및 세부 옵션 채우기
for i, tabName in ipairs(tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1 / #tabs, 0, 1, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    TabButton.BorderSizePixel = 0
    TabButton.Text = tabName
    TabButton.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    TabButton.Font = Enum.Font.SourceSans
    TabButton.TextSize = 13
    TabButton.Parent = TabBar

    local PageFrame = Instance.new("ScrollingFrame")
    PageFrame.Size = UDim2.new(1, -20, 1, -85)
    PageFrame.Position = UDim2.new(0, 10, 0, 75)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = (i == 1)
    PageFrame.ScrollBarThickness = 4
    PageFrame.Parent = MainFrame
    tabFrames[tabName] = PageFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = PageFrame

    -- 각 탭별 세부 옵션 항목 생성
    if tabName == "Aimbot" then
        createCheckbox(PageFrame, "Enabled")
        createCheckbox(PageFrame, "Wall Check")
        createCheckbox(PageFrame, "Dynamic FOV")
        createCheckbox(PageFrame, "Show FOV Circle")
    elseif tabName == "Visuals" then
        createCheckbox(PageFrame, "ESP Enabled")
        createCheckbox(PageFrame, "Box ESP")
        createCheckbox(PageFrame, "Name ESP")
        createCheckbox(PageFrame, "Healthbar ESP")
        createCheckbox(PageFrame, "Skeleton ESP")
    elseif tabName == "Misc" then
        createCheckbox(PageFrame, "Inf Jump")
        createCheckbox(PageFrame, "No Recoil")
        createCheckbox(PageFrame, "Fast Reload")
    else
        createCheckbox(PageFrame, "Enable " .. tabName .. " Mode")
    end

    TabButton.MouseButton1Click:Connect(function()
        for _, btn in pairs(TabBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        for _, frame in pairs(tabFrames) do
            frame.Visible = false
        end
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        PageFrame.Visible = true
    end)
end
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local followConnection = nil -- 추적 루프를 저장할 변수

-- 추적 시작 함수
local function startFollowing(targetPlayer, distanceBehind)
	distanceBehind = distanceBehind or 4 -- 뒤쪽으로 유지할 거리 (스터드)

	-- 이미 추적 중이라면 기존 루프 해제
	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end

	-- 매 프레임(화면 갱신)마다 실행
	followConnection = RunService.RenderStepped:Connect(function()
		local myChar = LocalPlayer.Character
		local targetChar = targetPlayer.Character

		if myChar and targetChar then
			local myHrp = myChar:FindFirstChild("HumanoidRootPart")
			local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")

			-- 대상과 내 캐릭터가 모두 정상 상태일 때만 추적
			if myHrp and targetHrp and targetChar:FindFirstChild("Humanoid").Health > 0 then
				local targetCF = targetHrp.CFrame
				
				-- 상대 뒤쪽 위치 계산
				local behindPos = targetCF.Position - (targetCF.LookVector * distanceBehind)
				
				-- 내 캐릭터 위치를 상대 뒤쪽으로 이동 및 상대 바라보기
				myHrp.CFrame = CFrame.new(behindPos, targetHrp.Position)
			else
				-- 타겟이 죽거나 없어지면 추적 중단
				if followConnection then
					followConnection:Disconnect()
					followConnection = nil
				end
			end
		end
	end)
end

-- 추적 중단 함수 (라운드가 끝나거나 필요할 때 호출)
local function stopFollowing()
	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end
end

-- [사용 예시] 상대 플레이어(TargetPlayer)를 지정하여 추적 시작
-- startFollowing(TargetPlayer, 4)
