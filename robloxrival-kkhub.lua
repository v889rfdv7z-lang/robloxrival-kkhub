-- =======================================================================
-- 🛠️ EKO HUB - 스크립트 도둑질 (최종 보스 본체 추출 엔진)
-- =======================================================================

-- 1. 로더가 몰래 숨겨뒀던 '진짜 본체' 암호화 링크
local targetUrl = "https://api.luarmor.net/files/v4/loaders/b477c6c716098ac8ffb336fe5b96b796.lua"

-- 2. 저장될 전리품 파일 이름
local saveFileName = "킥훅.txt"

local function StealScript()
    -- 익스큐터 권한 체크
    if not writefile then
        warn("❌ [이코 허브] 현재 익스큐터는 파일 저장(writefile)을 지원하지 않습니다.")
        return
    end

    print("📡 [이코 허브] 최종 보스 벙커 접속 중... 난독화된 본체를 뜯어옵니다!")

    -- 에러 튕김 방지 (pcall)
    local success, result = pcall(function()
        -- 실행(loadstring)시키지 않고, 순수하게 텍스트만 다운로드
        local sourceCode = game:HttpGet(targetUrl)

        -- 용량이 클 수 있으므로 바로 파일로 강제 저장
        writefile(saveFileName, sourceCode)
        return true
    end)

    if success then
        print("✅ [이코 허브] 작전 성공! 익스큐터의 'workspace' 폴더에 [" .. saveFileName .. "] 파일이 생성되었습니다.")
        print("⚠️ 경고: 파일을 열었을 때 눈알이 빠질 것 같은 외계어가 보인다면 정상입니다.")
    else
        warn("❌ [이코 허브] 본체 다운로드 실패! 서버에서 접근을 차단했을 수 있습니다.")
    end
end

-- 엔진 가동!
StealScript() 이걸로 api 권한 없는거도 뚫기가능
