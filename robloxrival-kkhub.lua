local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local UNLOADED = false

if not LocalPlayer then
    warn("[RIVALS] NO LOCALPLAYER")
    return
end

local HasDrawing = pcall(function()
    local test = Drawing.new("Circle")
    test:Remove()
    return true
end)

-- ============================================================================
-- THEME
-- ============================================================================
local THEME = {
    BG_Dark = Color3.fromRGB(18, 18, 22),
    BG_Darker = Color3.fromRGB(12, 12, 16),
    BG_Card = Color3.fromRGB(28, 28, 35),
    BG_CardHover = Color3.fromRGB(35, 35, 44),
    
    Text_Primary = Color3.fromRGB(255, 255, 255),
    Text_Secondary = Color3.fromRGB(190, 190, 200),
    Text_Muted = Color3.fromRGB(130, 130, 145),
    
    Accent_Main = Color3.fromRGB(90, 135, 255),
    Accent_Light = Color3.fromRGB(115, 165, 255),
    Danger = Color3.fromRGB(245, 75, 85),
    Success = Color3.fromRGB(85, 225, 125),
}

-- ============================================================================
-- CONFIG
-- ============================================================================
local CONFIG = {
    Combat = {
        Name = "Combat",
        Items = {
            { ID = "Aimbot", Name = "Aimbot", Type = "Toggle", Desc = "Auto-aim at players", SliderID = "AimbotSmooth" },
            { ID = "AimbotSmooth", Name = "Smoothness", Type = "Slider", Min = 1, Max = 20, Default = 8 },
            { ID = "AimbotFOV", Name = "FOV Circle", Type = "Toggle", Desc = "Show FOV circle" },
            { ID = "AimbotFOVRadius", Name = "FOV Radius", Type = "Slider", Min = 50, Max = 300, Default = 120 },
            { ID = "SilentAim", Name = "Silent Aim", Type = "Toggle", Desc = "Hit registration" },
            { ID = "Triggerbot", Name = "Triggerbot", Type = "Toggle", Desc = "Auto-click when cursor over player" },
            { ID = "TriggerbotDelay", Name = "Trigger Delay", Type = "Slider", Min = 10, Max = 200, Default = 50 },
        }
    },
    Movement = {
        Name = "Movement",
        Items = {
            { ID = "WalkSpeed", Name = "WalkSpeed", Type = "Toggle", Desc = "Custom walk speed", SliderID = "WalkSpeedVal" },
            { ID = "WalkSpeedVal", Name = "Speed", Type = "Slider", Min = 16, Max = 200, Default = 24 },
            { ID = "JumpPower", Name = "JumpPower", Type = "Toggle", Desc = "Custom jump power", SliderID = "JumpPowerVal" },
            { ID = "JumpPowerVal", Name = "Jump", Type = "Slider", Min = 50, Max = 300, Default = 60 },
            { ID = "InfiniteJump", Name = "InfiniteJump", Type = "Toggle", Desc = "Jump in mid-air" },
            { ID = "Fly", Name = "Fly", Type = "Toggle", Desc = "Flying (WASD+Space)" },
            { ID = "Noclip", Name = "Noclip", Type = "Toggle", Desc = "Walk through walls" },
            { ID = "ClickTP", Name = "ClickTP", Type = "Toggle", Desc = "Ctrl+Click teleport" },
        }
    },
    Visuals = {
        Name = "Visuals",
        Items = {
            { ID = "FOV", Name = "FOV", Type = "Toggle", Desc = "Custom field of view", SliderID = "FOVVal" },
            { ID = "FOVVal", Name = "FOV Value", Type = "Slider", Min = 30, Max = 120, Default = 90 },
            { ID = "Fullbright", Name = "Fullbright", Type = "Toggle", Desc = "Remove shadows" },
            { ID = "ThirdPerson", Name = "Third Person", Type = "Toggle", Desc = "Force third person" },
            { ID = "CameraZoom", Name = "Camera Zoom", Type = "Toggle", Desc = "Extended zoom", SliderID = "ZoomVal" },
            { ID = "ZoomVal", Name = "Zoom Distance", Type = "Slider", Min = 10, Max = 100, Default = 20 },
        }
    },
    ESP = { 
        Name = "ESP", 
        Items = {
            { ID = "ESP_Box", Name = "Box ESP", Type = "Toggle", Desc = "Boxes around players" },
            { ID = "ESP_Tracer", Name = "Tracers", Type = "Toggle", Desc = "Lines to players" },
            { ID = "ESP_Name", Name = "Name Tags", Type = "Toggle", Desc = "Show player names" },
            { ID = "ESP_Distance", Name = "Distance", Type = "Toggle", Desc = "Show distance" },
            { ID = "ESP_Health", Name = "Health Bar", Type = "Toggle", Desc = "Show player health" },
        } 
    },
    Utility = {
        Name = "Utility",
        Items = {
            { ID = "AntiAFK", Name = "AntiAFK", Type = "Toggle", Desc = "Prevent idle kick" },
        }
    },
}

local TAB_ORDER = { "Combat", "Movement", "Visuals", "ESP", "Utility" }

-- ============================================================================
-- UTILITIES
-- ============================================================================
local function Clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

local function GetCharacter()
    local char = LocalPlayer.Character
    return char and char.Parent and char or nil
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function AddPadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top)
    padding.PaddingBottom = UDim.new(0, bottom)
    padding.PaddingLeft = UDim.new(0, left)
    padding.PaddingRight = UDim.new(0, right)
    padding.Parent = parent
    return padding
end

local function GetNearestPlayer(maxDistance)
    local nearest = nil
    local nearestDist = maxDistance or math.huge
    local root = GetRootPart()
    
    if not root then return nil, math.huge end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local enemyHum = player.Character:FindFirstChildOfClass("Humanoid")
            if enemyRoot and enemyHum and enemyHum.Health > 0 then
                local dist = (root.Position - enemyRoot.Position).Magnitude
                if dist < nearestDist then
                    nearest = player
                    nearestDist = dist
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function IsPlayerInFOV(player, fovRadius)
    if not player or not player.Character then return false end
    
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local cam = workspace.CurrentCamera
    if not cam then return false end
    
    local screenPos, onScreen = cam:WorldToViewportPoint(root.Position)
    if not onScreen then return false end
    
    local centerX = cam.ViewportSize.X / 2
    local centerY = cam.ViewportSize.Y / 2
    
    local screenX = screenPos.X
    local screenY = screenPos.Y
    local dist = math.sqrt((screenX - centerX)^2 + (screenY - centerY)^2)
    
    return dist <= fovRadius, dist
end

local function GetPlayerAtCursor()
    local target = Mouse.Target
    if not target then return nil end
    
    local char = target.Parent
    while char and not char:FindFirstChildOfClass("Humanoid") do
        char = char.Parent
    end
    
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character == char and player ~= LocalPlayer then
                    return player
                end
            end
        end
    end
    
    return nil
end

-- ============================================================================
-- CONNECTION MANAGER
-- ============================================================================
local ConnectionManager = {
    _connections = {}
}

function ConnectionManager:Track(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        table.insert(self._connections, conn)
        return conn
    end
end

function ConnectionManager:DisconnectAll()
    for i = #self._connections, 1, -1 do
        local conn = self._connections[i]
        if conn then
            pcall(function() conn:Disconnect() end)
        end
        self._connections[i] = nil
    end
end

-- ============================================================================
-- MODULE SYSTEM
-- ============================================================================
local Modules = {}
local ModuleRegistry = {}

local GUI

local function CreateModule(id, config)
    local mod = {
        ID = id,
        Name = config.Name or id,
        Type = config.Type,
        Enabled = false,
        Value = config.Default or 0,
        Min = config.Min or 0,
        Max = config.Max or 100,
        Default = config.Default or 0,
        Desc = config.Desc or "",
        SliderID = config.SliderID,
        _connections = {},
        _originalValues = {}
    }
    
    function mod:Enable()
        if UNLOADED or self.Enabled then return end
        self.Enabled = true
        
        if self.OnEnable then
            task.spawn(function()
                if UNLOADED then return end
                pcall(function() self.OnEnable() end)
            end)
        end
        
        if GUI and GUI._toggleRefs and GUI._toggleRefs[self.ID] then
            GUI._toggleRefs[self.ID](self.Enabled)
        end
    end
    
    function mod:Disable()
        if not self.Enabled then return end
        self.Enabled = false
        
        for i = #self._connections, 1, -1 do
            local conn = self._connections[i]
            if conn then
                pcall(function() conn:Disconnect() end)
            end
            self._connections[i] = nil
        end
        
        if self.OnDisable then
            pcall(function() self.OnDisable() end)
        end
        
        if GUI and GUI._toggleRefs and GUI._toggleRefs[self.ID] then
            GUI._toggleRefs[self.ID](self.Enabled)
        end
    end
    
    function mod:SetValue(v)
        if UNLOADED then return end
        self.Value = Clamp(v, self.Min, self.Max)
        if self.Enabled and self.OnValue then
            pcall(function() self.OnValue(self.Value) end)
        end
        if GUI and GUI._sliderRefs and GUI._sliderRefs[self.ID] then
            GUI._sliderRefs[self.ID](self.Value)
        end
    end
    
    function mod:GetValue()
        return self.Value
    end
    
    function mod:Track(conn)
        if conn then
            table.insert(self._connections, conn)
            return conn
        end
    end
    
    ModuleRegistry[id] = mod
    return mod
end

-- ============================================================================
-- FOV Circle
-- ============================================================================
local FOVCircle = nil
if HasDrawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Filled = false
    FOVCircle.Thickness = 2
    FOVCircle.Color = Color3.fromRGB(255, 100, 100)
    FOVCircle.NumSides = 100
    FOVCircle.Transparency = 0.3
end

local function RemoveFOVCircle()
    if FOVCircle then
        pcall(function() FOVCircle:Remove() end)
        FOVCircle = nil
    end
end

-- ============================================================================
-- COMBAT MODULES
-- ============================================================================

Modules.Aimbot = CreateModule("Aimbot", {
    Name = "Aimbot",
    Type = "Toggle",
    Desc = "Auto-aim at players",
    SliderID = "AimbotSmooth"
})

Modules.Aimbot.OnEnable = function()
    Modules.Aimbot:Track(RunService.RenderStepped:Connect(function()
        if not Modules.Aimbot.Enabled or UNLOADED then return end
        
        local fovRadius = ModuleRegistry["AimbotFOVRadius"] and ModuleRegistry["AimbotFOVRadius"]:GetValue() or 120
        local target, dist = GetNearestPlayer(500)
        
        if target and IsPlayerInFOV(target, fovRadius) then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local cam = workspace.CurrentCamera
                if cam then
                    local smoothness = ModuleRegistry["AimbotSmooth"] and ModuleRegistry["AimbotSmooth"]:GetValue() or 8
                    local targetPos = root.Position + Vector3.new(0, 2, 0)
                    local lookAt = CFrame.new(cam.CFrame.Position, targetPos)
                    cam.CFrame = cam.CFrame:Lerp(lookAt, smoothness / 20)
                end
            end
        end
    end))
end

Modules.AimbotSmooth = CreateModule("AimbotSmooth", {
    Name = "Smoothness",
    Type = "Slider",
    Min = 1,
    Max = 20,
    Default = 8
})

Modules.AimbotFOV = CreateModule("AimbotFOV", {
    Name = "FOV Circle",
    Type = "Toggle",
    Desc = "Show FOV circle"
})

Modules.AimbotFOV.OnEnable = function()
    if FOVCircle and not UNLOADED then
        FOVCircle.Visible = true
        Modules.AimbotFOV:Track(RunService.RenderStepped:Connect(function()
            if FOVCircle and Modules.AimbotFOV.Enabled then
                local cam = workspace.CurrentCamera
                FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            end
        end))
        local radiusMod = ModuleRegistry["AimbotFOVRadius"]
        if radiusMod then
            FOVCircle.Radius = radiusMod:GetValue()
        end
    end
end

Modules.AimbotFOV.OnDisable = function()
    if FOVCircle then
        FOVCircle.Visible = false
    end
end

Modules.AimbotFOVRadius = CreateModule("AimbotFOVRadius", {
    Name = "FOV Radius",
    Type = "Slider",
    Min = 50,
    Max = 300,
    Default = 120
})

Modules.AimbotFOVRadius.OnValue = function(v)
    if FOVCircle and Modules.AimbotFOV.Enabled and not UNLOADED then
        FOVCircle.Radius = v
    end
end

Modules.SilentAim = CreateModule("SilentAim", {
    Name = "Silent Aim",
    Type = "Toggle",
    Desc = "Hit registration"
})

Modules.SilentAim.OnEnable = function()
    Modules.SilentAim:Track(RunService.RenderStepped:Connect(function()
        if not Modules.SilentAim.Enabled or UNLOADED then return end
        
        local fovRadius = ModuleRegistry["AimbotFOVRadius"] and ModuleRegistry["AimbotFOVRadius"]:GetValue() or 120
        local target, dist = GetNearestPlayer(500)
        
        if target and IsPlayerInFOV(target, fovRadius) then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, root.Position + Vector3.new(0, 2, 0))
                end
            end
        end
    end))
end

Modules.Triggerbot = CreateModule("Triggerbot", {
    Name = "Triggerbot",
    Type = "Toggle",
    Desc = "Auto-click when cursor over player",
    SliderID = "TriggerbotDelay"
})

Modules.Triggerbot.OnEnable = function()
    local lastClick = 0
    
    Modules.Triggerbot:Track(RunService.RenderStepped:Connect(function()
        if not Modules.Triggerbot.Enabled or UNLOADED then return end
        
        local player = GetPlayerAtCursor()
        if player then
            local now = tick()
            local delay = ModuleRegistry["TriggerbotDelay"] and ModuleRegistry["TriggerbotDelay"]:GetValue() or 50
            local minDelay = delay / 1000
            
            if now - lastClick >= minDelay then
                lastClick = now
                
                if VirtualInputManager then
                    local vp = Camera.ViewportSize
                    VirtualInputManager:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 0)
                    task.wait(0.001)
                    if UNLOADED then return end
                    VirtualInputManager:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 0)
                else
                    if mouse1press and mouse1release then
                        mouse1press()
                        task.wait(0.001)
                        if UNLOADED then return end
                        mouse1release()
                    end
                end
            end
        end
    end))
end

Modules.TriggerbotDelay = CreateModule("TriggerbotDelay", {
    Name = "Trigger Delay",
    Type = "Slider",
    Min = 10,
    Max = 200,
    Default = 50
})

-- ============================================================================
-- MOVEMENT MODULES
-- ============================================================================

Modules.WalkSpeed = CreateModule("WalkSpeed", {
    Name = "WalkSpeed",
    Type = "Toggle",
    Desc = "Custom walk speed",
    SliderID = "WalkSpeedVal"
})

local function RestoreWalkSpeed()
    local hum = GetHumanoid()
    if hum and Modules.WalkSpeed._originalValues.WalkSpeed then
        hum.WalkSpeed = Modules.WalkSpeed._originalValues.WalkSpeed
    end
end

Modules.WalkSpeed.OnEnable = function()
    local function UpdateWalkSpeed()
        if not Modules.WalkSpeed.Enabled or UNLOADED then return end
        local hum = GetHumanoid()
        if hum then
            if not Modules.WalkSpeed._originalValues.WalkSpeed or Modules.WalkSpeed._originalValues.Hum ~= hum then
                Modules.WalkSpeed._originalValues.WalkSpeed = hum.WalkSpeed
                Modules.WalkSpeed._originalValues.Hum = hum
            end
            local valMod = ModuleRegistry["WalkSpeedVal"]
            if valMod then
                hum.WalkSpeed = Clamp(valMod:GetValue(), 16, 200)
            end
        end
    end

    UpdateWalkSpeed()
    Modules.WalkSpeed:Track(RunService.Heartbeat:Connect(UpdateWalkSpeed))
end

Modules.WalkSpeed.OnDisable = function()
    RestoreWalkSpeed()
end

Modules.WalkSpeedVal = CreateModule("WalkSpeedVal", {
    Name = "Speed",
    Type = "Slider",
    Min = 16,
    Max = 200,
    Default = 24
})

Modules.WalkSpeedVal.OnValue = function(v)
    if Modules.WalkSpeed.Enabled and not UNLOADED then
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = Clamp(v, 16, 200)
        end
    end
end

Modules.JumpPower = CreateModule("JumpPower", {
    Name = "JumpPower",
    Type = "Toggle",
    Desc = "Custom jump power",
    SliderID = "JumpPowerVal"
})

local function RestoreJumpPower()
    local hum = GetHumanoid()
    if hum then
        if Modules.JumpPower._originalValues.JumpPower then
            hum.JumpPower = Modules.JumpPower._originalValues.JumpPower
        end
        if Modules.JumpPower._originalValues.UseJumpPower ~= nil then
            hum.UseJumpPower = Modules.JumpPower._originalValues.UseJumpPower
        end
    end
end

Modules.JumpPower.OnEnable = function()
    local function UpdateJumpPower()
        if not Modules.JumpPower.Enabled or UNLOADED then return end
        local hum = GetHumanoid()
        if hum then
            if not Modules.JumpPower._originalValues.JumpPower or Modules.JumpPower._originalValues.Hum ~= hum then
                Modules.JumpPower._originalValues.JumpPower = hum.JumpPower
                Modules.JumpPower._originalValues.UseJumpPower = hum.UseJumpPower
                Modules.JumpPower._originalValues.Hum = hum
            end
            local valMod = ModuleRegistry["JumpPowerVal"]
            if valMod then
                hum.UseJumpPower = true
                hum.JumpPower = Clamp(valMod:GetValue(), 50, 300)
            end
        end
    end

    UpdateJumpPower()
    Modules.JumpPower:Track(RunService.Heartbeat:Connect(UpdateJumpPower))
end

Modules.JumpPower.OnDisable = function()
    RestoreJumpPower()
end

Modules.JumpPowerVal = CreateModule("JumpPowerVal", {
    Name = "Jump",
    Type = "Slider",
    Min = 50,
    Max = 300,
    Default = 60
})

Modules.JumpPowerVal.OnValue = function(v)
    if Modules.JumpPower.Enabled and not UNLOADED then
        local hum = GetHumanoid()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = Clamp(v, 50, 300)
        end
    end
end

Modules.InfiniteJump = CreateModule("InfiniteJump", {
    Name = "InfiniteJump",
    Type = "Toggle",
    Desc = "Jump in mid-air"
})

Modules.InfiniteJump.OnEnable = function()
    Modules.InfiniteJump:Track(UserInputService.JumpRequest:Connect(function()
        if not Modules.InfiniteJump.Enabled or UNLOADED then return end
        local hum = GetHumanoid()
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

Modules.Fly = CreateModule("Fly", {
    Name = "Fly",
    Type = "Toggle",
    Desc = "Flying (WASD+Space)"
})

Modules.Fly.OnEnable = function()
    local flying = false
    local speed = 20
    
    Modules.Fly:Track(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not Modules.Fly.Enabled or UNLOADED then return end
        if input.KeyCode == Enum.KeyCode.Space then
            flying = not flying
        end
    end))
    
    Modules.Fly:Track(RunService.Stepped:Connect(function()
        if not Modules.Fly.Enabled or not flying or UNLOADED then return end
        
        local root = GetRootPart()
        if not root then return end
        
        local velocity = root:FindFirstChild("FlyVelocity")
        if not velocity then
            velocity = Instance.new("BodyVelocity")
            velocity.Name = "FlyVelocity"
            velocity.MaxForce = Vector3.new(10000, 10000, 10000)
            velocity.Parent = root
        end
        
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + root.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - root.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - root.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + root.CFrame.RightVector end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity.Velocity = Vector3.new(0, speed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity.Velocity = Vector3.new(0, -speed, 0)
        else
            if moveDir.Magnitude > 0 then
                velocity.Velocity = moveDir.Unit * speed
            else
                velocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end))
end

Modules.Fly.OnDisable = function()
    local root = GetRootPart()
    if root then
        local fly = root:FindFirstChild("FlyVelocity")
        if fly then fly:Destroy() end
    end
end

Modules.Noclip = CreateModule("Noclip", {
    Name = "Noclip",
    Type = "Toggle",
    Desc = "Walk through walls"
})

Modules.Noclip.OnEnable = function()
    Modules.Noclip:Track(RunService.Stepped:Connect(function()
        if not Modules.Noclip.Enabled or UNLOADED then return end
        local char = GetCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end))
end

Modules.Noclip.OnDisable = function()
    local char = GetCharacter()
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

Modules.ClickTP = CreateModule("ClickTP", {
    Name = "ClickTP",
    Type = "Toggle",
    Desc = "Ctrl+Click teleport"
})

Modules.ClickTP.OnEnable = function()
    Modules.ClickTP:Track(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not Modules.ClickTP.Enabled or UNLOADED then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 
            and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            
            local char = GetCharacter()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and Mouse and Mouse.Hit then
                hrp.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
            end
        end
    end))
end

-- ============================================================================
-- VISUALS MODULES
-- ============================================================================

Modules.FOV = CreateModule("FOV", {
    Name = "FOV",
    Type = "Toggle",
    Desc = "Custom field of view",
    SliderID = "FOVVal"
})

Modules.FOV.OnEnable = function()
    local cam = workspace.CurrentCamera
    if cam then
        if not Modules.FOV._originalValues.FOV then
            Modules.FOV._originalValues.FOV = cam.FieldOfView
        end
        local valMod = ModuleRegistry["FOVVal"]
        if valMod then
            cam.FieldOfView = Clamp(valMod:GetValue(), 30, 120)
        end
    end
    
    Modules.FOV:Track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if not Modules.FOV.Enabled or UNLOADED then return end
        local newCam = workspace.CurrentCamera
        if newCam then
            local valMod = ModuleRegistry["FOVVal"]
            if valMod then
                newCam.FieldOfView = Clamp(valMod:GetValue(), 30, 120)
            end
        end
    end))
end

Modules.FOV.OnDisable = function()
    local cam = workspace.CurrentCamera
    if cam and Modules.FOV._originalValues.FOV then
        cam.FieldOfView = Modules.FOV._originalValues.FOV
    end
end

Modules.FOVVal = CreateModule("FOVVal", {
    Name = "FOV Value",
    Type = "Slider",
    Min = 30,
    Max = 120,
    Default = 90
})

Modules.FOVVal.OnValue = function(v)
    if Modules.FOV.Enabled and not UNLOADED then
        local cam = workspace.CurrentCamera
        if cam then
            cam.FieldOfView = Clamp(v, 30, 120)
        end
    end
end

Modules.Fullbright = CreateModule("Fullbright", {
    Name = "Fullbright",
    Type = "Toggle",
    Desc = "Remove shadows"
})

Modules.Fullbright.OnEnable = function()
    if not Modules.Fullbright._originalValues.Brightness then
        Modules.Fullbright._originalValues.Brightness = Lighting.Brightness
        Modules.Fullbright._originalValues.ClockTime = Lighting.ClockTime
        Modules.Fullbright._originalValues.FogEnd = Lighting.FogEnd
        Modules.Fullbright._originalValues.GlobalShadows = Lighting.GlobalShadows
    end
    
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
end

Modules.Fullbright.OnDisable = function()
    if Modules.Fullbright._originalValues.Brightness then
        Lighting.Brightness = Modules.Fullbright._originalValues.Brightness
    end
    if Modules.Fullbright._originalValues.ClockTime then
        Lighting.ClockTime = Modules.Fullbright._originalValues.ClockTime
    end
    if Modules.Fullbright._originalValues.FogEnd then
        Lighting.FogEnd = Modules.Fullbright._originalValues.FogEnd
    end
    if Modules.Fullbright._originalValues.GlobalShadows ~= nil then
        Lighting.GlobalShadows = Modules.Fullbright._originalValues.GlobalShadows
    end
end

Modules.ThirdPerson = CreateModule("ThirdPerson", {
    Name = "Third Person",
    Type = "Toggle",
    Desc = "Force third person"
})

Modules.ThirdPerson.OnEnable = function()
    Modules.ThirdPerson:Track(RunService.RenderStepped:Connect(function()
        if UNLOADED or not Modules.ThirdPerson.Enabled then return end
        local cam = workspace.CurrentCamera
        local hum = GetHumanoid()
        if cam and hum then
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = hum
        end
    end))
end

Modules.CameraZoom = CreateModule("CameraZoom", {
    Name = "Camera Zoom",
    Type = "Toggle",
    Desc = "Extended zoom",
    SliderID = "ZoomVal"
})

Modules.CameraZoom.OnEnable = function()
    if not Modules.CameraZoom._originalValues.MaxDistance then
        Modules.CameraZoom._originalValues.MaxDistance = LocalPlayer.CameraMaxZoomDistance
    end
    local valMod = ModuleRegistry["ZoomVal"]
    if valMod then
        LocalPlayer.CameraMaxZoomDistance = Clamp(valMod:GetValue(), 10, 100)
    end
end

Modules.CameraZoom.OnDisable = function()
    if Modules.CameraZoom._originalValues.MaxDistance then
        LocalPlayer.CameraMaxZoomDistance = Modules.CameraZoom._originalValues.MaxDistance
    end
end

Modules.ZoomVal = CreateModule("ZoomVal", {
    Name = "Zoom Distance",
    Type = "Slider",
    Min = 10,
    Max = 100,
    Default = 20
})

Modules.ZoomVal.OnValue = function(v)
    if Modules.CameraZoom.Enabled and not UNLOADED then
        LocalPlayer.CameraMaxZoomDistance = Clamp(v, 10, 100)
    end
end

-- ============================================================================
-- ESP MODULES (Drawing-based, 2D Screen-Space)
-- ============================================================================

local ESPObjects = {}
local ESPCharConns = {} 

local ESP_COLOR_BOX     = Color3.fromRGB(255, 60, 60)
local ESP_COLOR_TRACER  = Color3.fromRGB(255, 60, 60)
local ESP_COLOR_NAME    = Color3.fromRGB(255, 255, 255)
local ESP_COLOR_DIST    = Color3.fromRGB(200, 200, 255)
local ESP_COLOR_HP_BG   = Color3.fromRGB(40, 40, 40)
local ESP_COLOR_HP_FULL = Color3.fromRGB(0, 255, 100)
local ESP_COLOR_HP_LOW  = Color3.fromRGB(255, 60, 60)

local function LerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local function RemoveESPForPlayer(uid)
    local objs = ESPObjects[uid]
    if not objs then return end

    for _, line in ipairs(objs.boxLines or {}) do pcall(function() line:Remove() end) end
    if objs.tracer    then pcall(function() objs.tracer:Remove() end)    end
    if objs.nameLabel then pcall(function() objs.nameLabel:Remove() end) end
    if objs.distLabel then pcall(function() objs.distLabel:Remove() end) end
    if objs.hpBg      then pcall(function() objs.hpBg:Remove() end)      end
    if objs.hpFill    then pcall(function() objs.hpFill:Remove() end)    end

    ESPObjects[uid] = nil
end

local function WipeAllESPObjects()
    for uid, _ in pairs(ESPObjects) do
        RemoveESPForPlayer(uid)
    end
    ESPObjects = {}
end

local function CreateESPForPlayer(player)
    if UNLOADED or player == LocalPlayer or not HasDrawing then return end
    
    local uid = player.UserId
    if ESPObjects[uid] then RemoveESPForPlayer(uid) end 

    local objs = {}

    objs.boxLines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = ESP_COLOR_BOX
        line.Visible = false
        line.ZIndex = 5
        objs.boxLines[i] = line
    end

    objs.tracer = Drawing.new("Line")
    objs.tracer.Thickness = 1.5
    objs.tracer.Color = ESP_COLOR_TRACER
    objs.tracer.Visible = false
    objs.tracer.ZIndex = 4

    objs.nameLabel = Drawing.new("Text")
    objs.nameLabel.Text = player.Name
    objs.nameLabel.Color = ESP_COLOR_NAME
    objs.nameLabel.Size = 14
    objs.nameLabel.Font = 2
    objs.nameLabel.Outline = true
    objs.nameLabel.Center = true
    objs.nameLabel.Visible = false
    objs.nameLabel.ZIndex = 6

    objs.distLabel = Drawing.new("Text")
    objs.distLabel.Text = ""
    objs.distLabel.Color = ESP_COLOR_DIST
    objs.distLabel.Size = 12
    objs.distLabel.Font = 2
    objs.distLabel.Outline = true
    objs.distLabel.Center = true
    objs.distLabel.Visible = false
    objs.distLabel.ZIndex = 6

    objs.hpBg = Drawing.new("Square")
    objs.hpBg.Filled = true
    objs.hpBg.Color = ESP_COLOR_HP_BG
    objs.hpBg.Thickness = 1
    objs.hpBg.Visible = false
    objs.hpBg.ZIndex = 5

    objs.hpFill = Drawing.new("Square")
    objs.hpFill.Filled = true
    objs.hpFill.Color = ESP_COLOR_HP_FULL
    objs.hpFill.Thickness = 1
    objs.hpFill.Visible = false
    objs.hpFill.ZIndex = 6

    ESPObjects[uid] = objs
end

local function SetESPVisible(objs, box, tracer, name, dist, health)
    if not objs then return end
    for _, line in ipairs(objs.boxLines or {}) do line.Visible = box end
    if objs.tracer    then objs.tracer.Visible    = tracer end
    if objs.nameLabel then objs.nameLabel.Visible = name   end
    if objs.distLabel then objs.distLabel.Visible = dist   end
    if objs.hpBg      then objs.hpBg.Visible      = health end
    if objs.hpFill    then objs.hpFill.Visible    = health end
end

local function DrawBox(objs, x, y, w, h)
    local lines = objs.boxLines
    lines[1].From = Vector2.new(x,     y)
    lines[1].To   = Vector2.new(x + w, y)
    
    lines[2].From = Vector2.new(x,     y + h)
    lines[2].To   = Vector2.new(x + w, y + h)
    
    lines[3].From = Vector2.new(x, y)
    lines[3].To   = Vector2.new(x, y + h)
    
    lines[4].From = Vector2.new(x + w, y)
    lines[4].To   = Vector2.new(x + w, y + h)
end

local ESPRenderConn = nil
local function StartESPRender()
    if ESPRenderConn or UNLOADED then return end

    ESPRenderConn = RunService.RenderStepped:Connect(function()
        if UNLOADED then return end
        
        local boxOn    = Modules.ESP_Box      and Modules.ESP_Box.Enabled
        local tracerOn = Modules.ESP_Tracer   and Modules.ESP_Tracer.Enabled
        local nameOn   = Modules.ESP_Name     and Modules.ESP_Name.Enabled
        local distOn   = Modules.ESP_Distance and Modules.ESP_Distance.Enabled
        local hpOn     = Modules.ESP_Health   and Modules.ESP_Health.Enabled

        local anyOn = boxOn or tracerOn or nameOn or distOn or hpOn
        if not anyOn then
            for uid, objs in pairs(ESPObjects) do
                SetESPVisible(objs, false, false, false, false, false)
            end
            return
        end

        local myChar = GetCharacter()
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local vp     = Camera.ViewportSize
        local screenCenter = Vector2.new(vp.X / 2, vp.Y)

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end

            local uid  = player.UserId
            local objs = ESPObjects[uid]
            if not objs then continue end

            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")

            if not root or not char then
                SetESPVisible(objs, false, false, false, false, false)
                continue
            end

            local headPos  = root.Position + Vector3.new(0, 2.5, 0)
            local feetPos  = root.Position - Vector3.new(0, 2.5, 0)

            local headSP, headVis = Camera:WorldToViewportPoint(headPos)
            local feetSP, feetVis = Camera:WorldToViewportPoint(feetPos)

            if not headVis then
                SetESPVisible(objs, false, false, false, false, false)
                continue
            end

            local screenH = math.abs(headSP.Y - feetSP.Y)
            local screenW = screenH * 0.6
            local cx      = headSP.X
            local top     = headSP.Y
            local boxX    = cx - screenW / 2
            local boxY    = top

            local dist = 0
            if myRoot then
                dist = math.floor((myRoot.Position - root.Position).Magnitude)
            end

            if boxOn then
                DrawBox(objs, boxX, boxY, screenW, screenH)
                for _, line in ipairs(objs.boxLines) do line.Visible = true end
            else
                for _, line in ipairs(objs.boxLines) do line.Visible = false end
            end

            if tracerOn then
                objs.tracer.From    = screenCenter
                objs.tracer.To      = Vector2.new(feetSP.X, feetSP.Y)
                objs.tracer.Visible = true
            else
                objs.tracer.Visible = false
            end

            if nameOn then
                objs.nameLabel.Position = Vector2.new(cx, boxY - 16)
                objs.nameLabel.Text     = player.Name
                objs.nameLabel.Visible  = true
            else
                objs.nameLabel.Visible = false
            end

            if distOn then
                objs.distLabel.Position = Vector2.new(cx, boxY + screenH + 2)
                objs.distLabel.Text     = dist .. " studs"
                objs.distLabel.Visible  = true
            else
                objs.distLabel.Visible = false
            end

            if hpOn and hum then
                local hp     = hum.Health
                local maxHp  = math.max(hum.MaxHealth, 1)
                local ratio  = Clamp(hp / maxHp, 0, 1)
                local barW   = 4
                local barX   = boxX - barW - 2
                local fillH  = math.floor(screenH * ratio)

                objs.hpBg.Position = Vector2.new(barX, boxY)
                objs.hpBg.Size     = Vector2.new(barW, screenH)
                objs.hpBg.Visible  = true

                objs.hpFill.Position = Vector2.new(barX, boxY + (screenH - fillH))
                objs.hpFill.Size     = Vector2.new(barW, fillH)
                objs.hpFill.Color    = LerpColor(ESP_COLOR_HP_LOW, ESP_COLOR_HP_FULL, ratio)
                objs.hpFill.Visible  = true
            else
                objs.hpBg.Visible   = false
                objs.hpFill.Visible = false
            end
        end
    end)
end

local function StopESPRender()
    if ESPRenderConn then
        ESPRenderConn:Disconnect()
        ESPRenderConn = nil
    end
end

local function InitAllESP()
    if UNLOADED then return end
    for _, p in ipairs(Players:GetPlayers()) do
        CreateESPForPlayer(p)
    end
end

local ESPPlayersConn_Added   = nil
local ESPPlayersConn_Removing = nil

local function DisconnectESPPlayerEvents()
    if ESPPlayersConn_Added then
        ESPPlayersConn_Added:Disconnect()
        ESPPlayersConn_Added = nil
    end
    if ESPPlayersConn_Removing then
        ESPPlayersConn_Removing:Disconnect()
        ESPPlayersConn_Removing = nil
    end
    for uid, conn in pairs(ESPCharConns) do
        if conn then pcall(function() conn:Disconnect() end) end
        ESPCharConns[uid] = nil
    end
    ESPCharConns = {}
end

local function ConnectESPPlayerEvents()
    if ESPPlayersConn_Added or UNLOADED then return end

    ESPPlayersConn_Added = Players.PlayerAdded:Connect(function(player)
        task.wait(0.5)
        if UNLOADED then return end
        CreateESPForPlayer(player)
        
        ESPCharConns[player.UserId] = player.CharacterAdded:Connect(function()
            task.wait(0.2)
            if UNLOADED then return end
            CreateESPForPlayer(player)
        end)
    end)

    ESPPlayersConn_Removing = Players.PlayerRemoving:Connect(function(player)
        local uid = player.UserId
        RemoveESPForPlayer(uid)
        if ESPCharConns[uid] then
            ESPCharConns[uid]:Disconnect()
            ESPCharConns[uid] = nil
        end
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPCharConns[player.UserId] then
                ESPCharConns[player.UserId] = player.CharacterAdded:Connect(function()
                    task.wait(0.2)
                    if UNLOADED then return end
                    CreateESPForPlayer(player)
                end)
            end
        end
    end
end

local function AreAnyESPTogglesActive()
    return (Modules.ESP_Box and Modules.ESP_Box.Enabled)
        or (Modules.ESP_Tracer   and Modules.ESP_Tracer.Enabled)
        or (Modules.ESP_Name     and Modules.ESP_Name.Enabled)
        or (Modules.ESP_Distance and Modules.ESP_Distance.Enabled)
        or (Modules.ESP_Health   and Modules.ESP_Health.Enabled)
end

local function OnAnyESPEnable()
    if UNLOADED then return end
    InitAllESP()
    ConnectESPPlayerEvents()
    StartESPRender()
end

local function OnAnyESPDisable()
    if UNLOADED then return end
    if not AreAnyESPTogglesActive() then
        StopESPRender()
        WipeAllESPObjects()
        DisconnectESPPlayerEvents()
    end
end

-- ============================================================================
-- ESP Sub-modules
-- ============================================================================

Modules.ESP_Box = CreateModule("ESP_Box", {
    Name = "Box ESP",
    Type = "Toggle",
    Desc = "Boxes around players"
})
Modules.ESP_Box.OnEnable  = OnAnyESPEnable
Modules.ESP_Box.OnDisable = OnAnyESPDisable

Modules.ESP_Tracer = CreateModule("ESP_Tracer", {
    Name = "Tracers",
    Type = "Toggle",
    Desc = "Lines to players"
})
Modules.ESP_Tracer.OnEnable  = OnAnyESPEnable
Modules.ESP_Tracer.OnDisable = OnAnyESPDisable

Modules.ESP_Name = CreateModule("ESP_Name", {
    Name = "Name Tags",
    Type = "Toggle",
    Desc = "Show player names"
})
Modules.ESP_Name.OnEnable  = OnAnyESPEnable
Modules.ESP_Name.OnDisable = OnAnyESPDisable

Modules.ESP_Distance = CreateModule("ESP_Distance", {
    Name = "Distance",
    Type = "Toggle",
    Desc = "Show distance"
})
Modules.ESP_Distance.OnEnable  = OnAnyESPEnable
Modules.ESP_Distance.OnDisable = OnAnyESPDisable

Modules.ESP_Health = CreateModule("ESP_Health", {
    Name = "Health Bar",
    Type = "Toggle",
    Desc = "Show player health"
})
Modules.ESP_Health.OnEnable  = OnAnyESPEnable
Modules.ESP_Health.OnDisable = OnAnyESPDisable

-- ============================================================================
-- UTILITY MODULES
-- ============================================================================

Modules.AntiAFK = CreateModule("AntiAFK", {
    Name = "AntiAFK",
    Type = "Toggle",
    Desc = "Prevent idle kick"
})

Modules.AntiAFK.OnEnable = function()
    Modules.AntiAFK:Track(LocalPlayer.Idled:Connect(function()
        if not Modules.AntiAFK.Enabled or UNLOADED then return end
        local vu = game:GetService("VirtualUser")
        if vu then
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0, 0))
        end
    end))
end

-- ============================================================================
-- GUI SYSTEM
-- ============================================================================
GUI = {
    Visible = true,
    MainFrame = nil,
    ScreenGui = nil,
    CurrentTab = "Combat",
    ToggleConn = nil,
    _toggleRefs = {},
    _sliderRefs = {},
}

function GUI:Build()
    if self.MainFrame or UNLOADED then return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "RIVALS_GUI_v4.5"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 640, 0, 440)
    main.Position = UDim2.new(0.5, -320, 0.5, -220)
    main.BackgroundColor3 = THEME.BG_Dark
    main.BorderSizePixel = 0
    AddCorner(main, 10)
    main.Parent = sg

    self.MainFrame = main
    self.ScreenGui = sg

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = THEME.BG_Darker
    header.BorderSizePixel = 0
    AddCorner(header, 10)
    header.Parent = main

    local dragging = false
    local dragStart, startPos

    ConnectionManager:Track(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end))

    ConnectionManager:Track(header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    ConnectionManager:Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = 'RIVALS <font color="#5A87FF">v4.5</font>'
    title.RichText = true
    title.TextColor3 = THEME.Text_Primary
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -36, 0.5, -14)
    close.BackgroundColor3 = THEME.Danger
    close.BorderSizePixel = 0
    AddCorner(close, 7)
    close.Text = "✕"
    close.TextColor3 = THEME.Text_Primary
    close.Font = Enum.Font.GothamBold
    close.TextSize = 13
    close.Parent = header

    ConnectionManager:Track(close.MouseButton1Click:Connect(function() self:Unload() end))

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -44)
    sidebar.Position = UDim2.new(0, 0, 0, 44)
    sidebar.BackgroundColor3 = THEME.BG_Darker
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sidebarList = Instance.new("UIListLayout")
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Padding = UDim.new(0, 5)
    sidebarList.Parent = sidebar
    AddPadding(sidebar, 10, 10, 10, 10)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -150, 1, -44)
    content.Position = UDim2.new(0, 150, 0, 44)
    content.BackgroundTransparency = 1
    content.Parent = main

    local tabButtons = {}
    local tabs = {}

    for idx, tabName in ipairs(TAB_ORDER) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = idx == 1 and THEME.Accent_Main or THEME.BG_Dark
        btn.BorderSizePixel = 0
        btn.Text = CONFIG[tabName].Name
        btn.TextColor3 = idx == 1 and THEME.Text_Primary or THEME.Text_Secondary
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.LayoutOrder = idx
        AddCorner(btn, 7)
        btn.Parent = sidebar

        table.insert(tabButtons, { btn = btn, name = tabName })

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = THEME.Accent_Main
        scroll.Visible = idx == 1
        scroll.Parent = content

        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 10)
        list.Parent = scroll
        AddPadding(scroll, 14, 14, 14, 14)

        ConnectionManager:Track(list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 28)
        end))

        table.insert(tabs, { frame = scroll, name = tabName })

        ConnectionManager:Track(btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabButtons) do
                t.btn.BackgroundColor3 = THEME.BG_Dark
                t.btn.TextColor3 = THEME.Text_Secondary
            end
            btn.BackgroundColor3 = THEME.Accent_Main
            btn.TextColor3 = THEME.Text_Primary

            for _, t in ipairs(tabs) do
                t.frame.Visible = (t.name == tabName)
            end
            self.CurrentTab = tabName
        end))
    end

    for tabName, tabData in pairs(CONFIG) do
        local tabScroll = nil
        for _, t in ipairs(tabs) do
            if t.name == tabName then tabScroll = t.frame break end
        end

        if tabScroll then
            for _, item in ipairs(tabData.Items) do
                local mod = ModuleRegistry[item.ID]
                if mod then
                    if item.Type == "Toggle" then
                        self:CreateToggleSwitch(tabScroll, mod)
                    elseif item.Type == "Slider" then
                        self:CreateSliderControl(tabScroll, mod)
                    end
                end
            end
        end
    end
end

function GUI:CreateToggleSwitch(parent, module)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 58)
    row.BackgroundColor3 = THEME.BG_Card
    row.BorderSizePixel = 0
    AddCorner(row, 8)
    row.Parent = parent

    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0, 40, 0, 40)
    iconBg.Position = UDim2.new(0, 12, 0.5, -20)
    iconBg.BackgroundColor3 = module.Enabled and THEME.Accent_Main or THEME.BG_Darker
    iconBg.BorderSizePixel = 0
    AddCorner(iconBg, 8)
    iconBg.Parent = row

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "✓"
    icon.TextColor3 = module.Enabled and THEME.Text_Primary or THEME.Text_Muted
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 17
    icon.Parent = iconBg

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -130, 0, 19)
    nameLabel.Position = UDim2.new(0, 62, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = module.Name
    nameLabel.TextColor3 = THEME.Text_Primary
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = row

    if module.Desc and module.Desc ~= "" then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -130, 0, 15)
        descLabel.Position = UDim2.new(0, 62, 0, 31)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = module.Desc
        descLabel.TextColor3 = THEME.Text_Muted
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 11
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = row
    end

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 26)
    toggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBtn.BackgroundColor3 = module.Enabled and THEME.Accent_Main or THEME.BG_Darker
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    AddCorner(toggleBtn, 13)
    toggleBtn.Parent = row

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 19, 0, 19)
    toggleCircle.Position = UDim2.new(0, module.Enabled and 28 or 4, 0.5, -9.5)
    toggleCircle.BackgroundColor3 = THEME.Text_Primary
    toggleCircle.BorderSizePixel = 0
    AddCorner(toggleCircle, 9.5)
    toggleCircle.Parent = toggleBtn

    local updateFn = function(enabled)
        toggleCircle:TweenPosition(
            enabled and UDim2.new(0, 28, 0.5, -9.5) or UDim2.new(0, 4, 0.5, -9.5),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true
        )
        toggleBtn.BackgroundColor3 = enabled and THEME.Accent_Main or THEME.BG_Darker
        iconBg.BackgroundColor3 = enabled and THEME.Accent_Main or THEME.BG_Darker
        icon.TextColor3 = enabled and THEME.Text_Primary or THEME.Text_Muted
    end

    self._toggleRefs[module.ID] = updateFn

    ConnectionManager:Track(toggleBtn.Activated:Connect(function()
        if UNLOADED then return end
        if module.Enabled then
            module:Disable()
        else
            module:Enable()
        end
    end))

    return row
end

function GUI:CreateSliderControl(parent, module)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 74)
    row.BackgroundColor3 = THEME.BG_Card
    row.BorderSizePixel = 0
    AddCorner(row, 8)
    row.Parent = parent

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 0, 19)
    nameLabel.Position = UDim2.new(0, 14, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = module.Name
    nameLabel.TextColor3 = THEME.Text_Primary
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = row

    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0.3, 0, 0, 19)
    valueDisplay.Position = UDim2.new(0.7, -14, 0, 10)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(module.Value ~= 0 and module.Value or module.Default)
    valueDisplay.TextColor3 = THEME.Accent_Light
    valueDisplay.Font = Enum.Font.GothamBold
    valueDisplay.TextSize = 14
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.Parent = row

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -28, 0, 17)
    sliderBtn.Position = UDim2.new(0, 14, 0, 47)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = row

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 9)
    sliderBg.Position = UDim2.new(0, 0, 0.5, -4.5)
    sliderBg.BackgroundColor3 = THEME.BG_Darker
    sliderBg.BorderSizePixel = 0
    AddCorner(sliderBg, 4.5)
    sliderBg.Parent = sliderBtn

    local currentVal = module.Value ~= 0 and module.Value or module.Default
    local pct = (currentVal - module.Min) / (module.Max - module.Min)
    pct = Clamp(pct, 0, 1)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderFill.BackgroundColor3 = THEME.Accent_Main
    sliderFill.BorderSizePixel = 0
    AddCorner(sliderFill, 4.5)
    sliderFill.Parent = sliderBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 15, 0, 15)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.BackgroundColor3 = THEME.Text_Primary
    knob.BorderSizePixel = 0
    AddCorner(knob, 7.5)
    knob.Parent = sliderFill

    local dragging = false

    local function UpdateSlider(inputPos)
        if UNLOADED then return end
        local sx = sliderBg.AbsolutePosition.X
        local sw = sliderBg.AbsoluteSize.X
        local p = Clamp((inputPos.X - sx) / sw, 0, 1)
        sliderFill.Size = UDim2.new(p, 0, 1, 0)
        local val = math.floor(module.Min + p * (module.Max - module.Min) + 0.5)
        val = Clamp(val, module.Min, module.Max)
        valueDisplay.Text = tostring(val)
        module:SetValue(val)
    end

    ConnectionManager:Track(sliderBtn.InputBegan:Connect(function(input)
        if UNLOADED then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input.Position)
        end
    end))

    ConnectionManager:Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    ConnectionManager:Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and not UNLOADED and (input.UserInputType == Enum.UserInputType.MouseMovement 
            or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position)
        end
    end))

    local updateFn = function(val)
        if UNLOADED then return end
        local p = (val - module.Min) / (module.Max - module.Min)
        p = Clamp(p, 0, 1)
        sliderFill.Size = UDim2.new(p, 0, 1, 0)
        valueDisplay.Text = tostring(val)
    end

    self._sliderRefs[module.ID] = updateFn

    return row
end

function GUI:Toggle()
    if UNLOADED then return end
    self.Visible = not self.Visible
    if self.MainFrame then
        self.MainFrame.Visible = self.Visible
    end
end

function GUI:Unload()
    if UNLOADED then return end
    UNLOADED = true
    
    for _, mod in pairs(ModuleRegistry) do
        if mod.Enabled then 
            pcall(function() mod:Disable() end)
        end
    end
    
    StopESPRender()
    DisconnectESPPlayerEvents()
    WipeAllESPObjects()
    RemoveFOVCircle()
    
    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
        self.ScreenGui = nil
    end
    self.MainFrame = nil
    
    ConnectionManager:DisconnectAll()
    
    self._toggleRefs = {}
    self._sliderRefs = {}
    
    print("[RIVALS] Unloaded successfully")
end

-- ============================================================================
-- INPUT
-- ============================================================================
GUI.ToggleConn = ConnectionManager:Track(
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or UNLOADED then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            GUI:Toggle()
        end
    end)
)

-- ============================================================================
-- INIT
-- ============================================================================
GUI:Build()
print("[RIVALS] v4.5 ESP Fixed & Debugged Loaded!")
print("[RIVALS] Press RightShift to toggle GUI")
print("[RIVALS] Modules:", #ModuleRegistry)
