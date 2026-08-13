local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- 1. 메인 UI (KKCBRP 프로그램 인터페이스)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KKCBRP_Gui"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 320)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- 창 드래그 가능
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- 타이틀 바
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🧠 KKCBRP | 끝말잇기 수 읽기 엔진"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(230, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 상태 및 정보 라벨
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(1, -30, 0, 30)
StatusLabel.Position = UDim2.new(0, 15, 0, 50)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
StatusLabel.Text = "상태: 대기 중..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.SourceSans

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- 자동 입력 토글 버튼
local isAutoEnabled = true
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.Size = UDim2.new(1, -30, 0, 40)
ToggleBtn.Position = UDim2.new(0, 15, 0, 90)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 140, 60)
ToggleBtn.Text = "자동 입력 기능: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 15
ToggleBtn.Font = Enum.Font.SourceSansBold

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    isAutoEnabled = not isAutoEnabled
    if isAutoEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 140, 60)
        ToggleBtn.Text = "자동 입력 기능: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(140, 45, 45)
        ToggleBtn.Text = "자동 입력 기능: OFF"
    end
end)

-- 테스팅용 직접 입력창
local TestBox = Instance.new("TextBox")
TestBox.Parent = MainFrame
TestBox.Size = UDim2.new(1, -30, 0, 40)
TestBox.Position = UDim2.new(0, 15, 0, 145)
TestBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
TestBox.PlaceholderText = "제시어 입력 (예: 가)"
TestBox.Text = ""
TestBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TestBox.TextSize = 14
TestBox.Font = Enum.Font.SourceSans

local TestBoxCorner = Instance.new("UICorner")
TestBoxCorner.CornerRadius = UDim.new(0, 6)
TestBoxCorner.Parent = TestBox

-- 수 읽기 실행 버튼
local RunBtn = Instance.new("TextButton")
RunBtn.Parent = MainFrame
RunBtn.Size = UDim2.new(1, -30, 0, 40)
RunBtn.Position = UDim2.new(0, 15, 0, 195)
RunBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 200)
RunBtn.Text = "KKCBRP 수 읽기 및 자동 입력 실행"
RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunBtn.TextSize = 14
RunBtn.Font = Enum.Font.SourceSansBold

local RunCorner = Instance.new("UICorner")
RunCorner.CornerRadius = UDim.new(0, 6)
RunCorner.Parent = RunBtn

--------------------------------------------------------------------------------
-- 2. 백엔드 알고리즘 (두음법칙 / 실시간 API 연동 / KKCBRP 수 읽기)
--------------------------------------------------------------------------------
local function applyDooum(char)
    local dooumMap = {
        ["리"] = "이", ["륨"] = "윰", ["늄"] = "윰", ["라"] = "나", 
        ["락"] = "낙", ["란"] = "난", ["람"] = "남", ["랑"] = "낭",
        ["래"] = "내", ["랭"] = "냉", ["로"] = "노", ["론"] = "논"
    }
    return dooumMap[char] or char
end

local function fetchWordsFromEngine(startChar)
    local wordList = {}
    local url = "https://korean-word-api.vercel.app/api/words?start=" .. HttpService:UrlEncode(startChar)
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and response then
        local data = HttpService:JSONDecode(response)
        if data and data.words then
            wordList = data.words
        end
    end
    return wordList
end

local function KKCBRP_CalculateBestWord(startChar)
    StatusLabel.Text = "상태: [" .. startChar .. "] 수 읽기 계산 중..."
    
    local charsToSearch = {startChar, applyDooum(startChar)}
    local candidateWords = {}

    for _, char in ipairs(charsToSearch) do
        local words = fetchWordsFromEngine(char)
        for _, w in ipairs(words) do
            table.insert(candidateWords, w)
        end
    end

    if #candidateWords == 0 then return nil end

    local bestWord = candidateWords[1]
    local maxScore = -9999

    for _, word in ipairs(candidateWords) do
        local lastChar = string.sub(word, -3) 
        local enemyNextWords = fetchWordsFromEngine(lastChar)
        local enemyResponseCount = #enemyNextWords

        local score = 0

        -- 한방 단어
        if enemyResponseCount == 0 then
            score = 10000
        else
            -- 2수 앞 계산 (유도/루트 단어)
            local canWinNextTurn = false
            for _, eWord in ipairs(enemyNextWords) do
                local eLastChar = string.sub(eWord, -3)
                local myNextWords = fetchWordsFromEngine(eLastChar)
                
                for _, myW in ipairs(myNextWords) do
                    local myLastChar = string.sub(myW, -3)
                    if #fetchWordsFromEngine(myLastChar) == 0 then
                        canWinNextTurn = true
                        break
                    end
                end
                if canWinNextTurn then break end
            end

            if canWinNextTurn then
                score = 5000
            else
                -- 방어 단어
                score = 100 - enemyResponseCount
            end
        end

        if score > maxScore then
            maxScore = score
            bestWord = word
        end
    end

    return bestWord
end

--------------------------------------------------------------------------------
-- 3. 자동 입력 처리
--------------------------------------------------------------------------------
local function getGameTextBox()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    for _, v in ipairs(playerGui:GetDescendants()) do
        if v:IsA("TextBox") and v.Visible and v.Parent ~= MainFrame then
            return v
        end
    end
    return nil
end

local function AutoTypeAndSubmit(text)
    local textBox = getGameTextBox()
    if textBox then
        textBox:CaptureFocus()
        textBox.Text = text
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        StatusLabel.Text = "상태: 입력 완료! (" .. text .. ")"
    else
        StatusLabel.Text = "상태: 입력 완료 (" .. text .. ") - 게임 입력창 찾기 실패"
    end
end

--------------------------------------------------------------------------------
-- 4. 버튼 클릭 이벤트 연결
--------------------------------------------------------------------------------
RunBtn.MouseButton1Click:Connect(function()
    local inputChar = TestBox.Text
    if inputChar == "" then
        StatusLabel.Text = "상태: 제시어를 입력해 주세요!"
        return
    end

    task.spawn(function()
        local targetWord = KKCBRP_CalculateBestWord(inputChar)
        if targetWord then
            if isAutoEnabled then
                AutoTypeAndSubmit(targetWord)
            else
                StatusLabel.Text = "상태: 최적 단어 [" .. targetWord .. "]"
            end
        else
            StatusLabel.Text = "상태: 단어를 찾지 못했습니다."
        end
    end)
end)
