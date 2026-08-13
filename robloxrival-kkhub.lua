local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- 1. 두음법칙 변환 함수
--------------------------------------------------------------------------------
local function applyDooum(char)
    local dooumMap = {
        ["리"] = "이", ["륨"] = "윰", ["늄"] = "윰", ["라"] = "나", 
        ["락"] = "낙", ["란"] = "난", ["람"] = "남", ["랑"] = "낭",
        ["래"] = "내", ["랭"] = "냉", ["로"] = "노", ["론"] = "논"
    }
    return dooumMap[char] or char
end

--------------------------------------------------------------------------------
-- 2. 외부 끝말잇기 검색 엔진 API 연동 (실시간 단어 수집)
--------------------------------------------------------------------------------
local function fetchWordsFromEngine(startChar)
    local wordList = {}
    -- 끝말잇기 단어 검색엔진 API endpoint (예시)
    local url = "https://korean-word-api.vercel.app/api/words?start=" .. HttpService:UrlEncode(startChar)
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and response then
        local data = HttpService:JSONDecode(response)
        if data and data.words then
            wordList = data.words -- 서버에서 검색된 단어 배열
        end
    end
    
    return wordList
end

--------------------------------------------------------------------------------
-- 3. KKCBRP 수 읽기 엔진 (한방 / 유도 / 방어 계산)
--------------------------------------------------------------------------------
local function KKCBRP_CalculateBestWord(startChar)
    -- 두음법칙 적용 글자까지 포함하여 탐색
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
        -- 마지막 글자 추출
        local lastChar = string.sub(word, -3) 
        local enemyNextWords = fetchWordsFromEngine(lastChar)
        local enemyResponseCount = #enemyNextWords

        local score = 0

        -- [1] 한방 단어 (상대가 낼 수 있는 단어가 0개인 경우)
        if enemyResponseCount == 0 then
            score = 10000
        else
            -- [2] 2수 앞 계산 (유도 및 루트 단어)
            local canWinNextTurn = false
            for _, eWord in ipairs(enemyNextWords) do
                local eLastChar = string.sub(eWord, -3)
                local myNextWords = fetchWordsFromEngine(eLastChar)
                
                -- 상대가 무슨 단어를 내든 내 다음 차례에 한방 단어가 존재하는지
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
                score = 5000 -- 승리 유도/루트 단어
            else
                -- [3] 방어 단어 (상대의 선택지를 최소화)
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
-- 4. 자동 입력 및 제출 기능
--------------------------------------------------------------------------------
local function getGameTextBox()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    for _, v in ipairs(playerGui:GetDescendants()) do
        if v:IsA("TextBox") and v.Visible then
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
        
        -- 엔터키(Return) 시뮬레이션
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        print("[KKCBRP] 자동 입력 완료: " .. text)
    end
end

--------------------------------------------------------------------------------
-- 5. 메인 실행 함수
--------------------------------------------------------------------------------
local function ProcessTurn(givenChar)
    print("[KKCBRP] 수 읽기 계산 중... (제시어: " .. givenChar .. ")")
    
    local targetWord = KKCBRP_CalculateBestWord(givenChar)
    if targetWord then
        print("[KKCBRP] 최종 선택된 단어: " .. targetWord)
        AutoTypeAndSubmit(targetWord)
    else
        warn("[KKCBRP] 단어를 찾을 수 없습니다.")
    end
end

-- 실행 테스트
task.wait(1)
ProcessTurn("가")
