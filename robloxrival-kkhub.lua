-- 서비스 로드
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- FOV 설정 (요청하신 1500 설정)
local FOV_RADIUS = 1500

-- 가장 가까운 적의 머리(Head) 위치 찾기 함수
local function getClosestEnemyHead()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChildOfClass("Humanoid") then
            -- 체력이 남아있는 상대만 타겟팅
            if player.Character.Humanoid.Health > 0 then
                local head = player.Character.Head
                local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    
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

-- 1. Aimbot (마우스 우클릭 시 상대 머리로 카메라 고정)
local aimbotEnabled = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- 우클릭 누를 때
        aimbotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- 우클릭 뗄 때
        aimbotEnabled = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemyHead()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- 2. Silent Aim (원거리 레이캐스트/총알 궤적을 헤드로 보정하는 기본 로직)
local metaTable = getrawmetatable(game)
local oldNamecall = metaTable.__namecall
setreadonly(metaTable, false)

metaTable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FindPartOnWithIgnoreList" or method == "Raycast" then
        local target = getClosestEnemyHead()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- 발사 시 목적지 및 궤적을 타겟의 머리로 강제 변경
            if method == "Raycast" then
                args[2] = (target.Character.Head.Position - args[1]).Unit * 1000
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)

setreadonly(metaTable, true)

-- 기본 편의 기능
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = 32
end)

print("Aimbot & Silent Aim (FOV 1500) 로드 완료!")
