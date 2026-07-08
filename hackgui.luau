-- [[ CYBERPUNK SCI-FI SYSTEM - VERSION 3.0 ]] --
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cấu hình trạng thái (State)
local CyberState = {
    SpeedActive = false,
    TargetSpeed = 100, -- Tốc độ mặc định khi bật
    JumpActive = false,
    TargetJump = 150,  -- Độ cao mặc định khi bật
    InfJump = false,
    ESP = false,
    Noclip = false,
    Aimbot = false,
    TargetMode = "Nearest",
    SelectedPlayer = nil,
    POVActive = false
}

-- Khởi tạo GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberSystem_V3"
ScreenGui.DisplayOrder = 999999999
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Frame Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 240, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Thanh Tiêu Đề
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "> CYBER_OVERRIDE_V3.SYS"
TitleText.TextColor3 = Color3.fromRGB(0, 240, 255)
TitleText.Font = Enum.Font.Code
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Hàm tiện ích tạo nút bấm
local function createButton(text, size, parent)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    btn.BorderColor3 = Color3.fromRGB(0, 120, 150)
    btn.Font = Enum.Font.Code
    btn.Text = "[ " .. text .. " : OFF ]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Parent = parent
    return btn
end

local function toggleVisual(btn, state)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(0, 50, 60)
        btn.BorderColor3 = Color3.fromRGB(0, 240, 255)
        btn.TextColor3 = Color3.fromRGB(0, 240, 255)
        btn.Text = string.gsub(btn.Text, "OFF", "ON")
    else
        btn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
        btn.BorderColor3 = Color3.fromRGB(0, 120, 150)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Text = string.gsub(btn.Text, "ON", "OFF")
    end
end

-- Layout Container
local LeftSide = Instance.new("Frame")
LeftSide.Size = UDim2.new(0.45, 0, 1, -50)
LeftSide.Position = UDim2.new(0, 15, 0, 50)
LeftSide.BackgroundTransparency = 1
LeftSide.Parent = MainFrame

local RightSide = Instance.new("Frame")
RightSide.Size = UDim2.new(0.5, 0, 1, -50)
RightSide.Position = UDim2.new(0.48, 0, 0, 50)
RightSide.BackgroundTransparency = 1
RightSide.Parent = MainFrame

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Parent = LeftSide
LeftLayout.Padding = UDim.new(0, 10)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- --- CỘT TRÁI (MOVEMENT & ESP) ---
-- Tạo chức năng tùy chỉnh Speed
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(1, 0, 0, 35)
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Parent = LeftSide

local SpeedBtn = createButton("HACK SPEED", UDim2.new(0.68, 0, 1, 0), SpeedFrame)
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.28, 0, 1, 0)
SpeedInput.Position = UDim2.new(0.72, 0, 0, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
SpeedInput.BorderColor3 = Color3.fromRGB(0, 240, 255)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.Code
SpeedInput.Text = tostring(CyberState.TargetSpeed)
SpeedInput.Parent = SpeedFrame

-- Tạo chức năng tùy chỉnh Jump
local JumpFrame = Instance.new("Frame")
JumpFrame.Size = UDim2.new(1, 0, 0, 35)
JumpFrame.BackgroundTransparency = 1
JumpFrame.Parent = LeftSide

local JumpBtn = createButton("NHẢY CAO", UDim2.new(0.68, 0, 1, 0), JumpFrame)
local JumpInput = Instance.new("TextBox")
JumpInput.Size = UDim2.new(0.28, 0, 1, 0)
JumpInput.Position = UDim2.new(0.72, 0, 0, 0)
JumpInput.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
JumpInput.BorderColor3 = Color3.fromRGB(0, 240, 255)
JumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpInput.Font = Enum.Font.Code
JumpInput.Text = tostring(CyberState.TargetJump)
JumpInput.Parent = JumpFrame

local InfJumpBtn = createButton("INF JUMP", UDim2.new(1, 0, 0, 35), LeftSide)
local NoclipBtn = createButton("NO CLIP", UDim2.new(1, 0, 0, 35), LeftSide)
local ESPBtn = createButton("ESP PLAYER", UDim2.new(1, 0, 0, 35), LeftSide)


-- --- CỘT PHẢI (TARGETING & COMBAT) ---
local RightLayout = Instance.new("UIListLayout")
RightLayout.Parent = RightSide
RightLayout.Padding = UDim.new(0, 10)

local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(1, 0, 0, 20)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "TARGET: NONE"
SelectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectedLabel.Font = Enum.Font.Code
SelectedLabel.TextSize = 13
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.Parent = RightSide

-- FIX DROPDOWN: Kích hoạt Scrolling động
local DropdownScroll = Instance.new("ScrollingFrame")
DropdownScroll.Size = UDim2.new(1, 0, 0, 120)
DropdownScroll.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
DropdownScroll.BorderColor3 = Color3.fromRGB(0, 240, 255)
DropdownScroll.ScrollBarThickness = 5
DropdownScroll.Parent = RightSide

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.Parent = DropdownScroll
DropdownLayout.SortOrder = Enum.SortOrder.Name
DropdownLayout.Padding = UDim.new(0, 2)

-- Tự động điều chỉnh kích thước thanh cuộn để hiện HẾT người chơi
DropdownLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, DropdownLayout.AbsoluteContentSize.Y)
end)

local CombatRow = Instance.new("Frame")
CombatRow.Size = UDim2.new(1, 0, 0, 35)
CombatRow.BackgroundTransparency = 1
CombatRow.Parent = RightSide

local AimBtn = createButton("AIMBOT", UDim2.new(0.48, 0, 1, 0), CombatRow)
local POVBtn = createButton("POV CAM", UDim2.new(0.48, 0, 1, 0), CombatRow)
POVBtn.Position = UDim2.new(0.52, 0, 0, 0)

local TPBtn = createButton("EXECUTE TELEPORT", UDim2.new(1, 0, 0, 35), RightSide)
TPBtn.Text = "[ EXECUTE TELEPORT ]"

local TargetModeBtn = Instance.new("TextButton")
TargetModeBtn.Size = UDim2.new(1, 0, 0, 30)
TargetModeBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 100)
TargetModeBtn.Text = "TARGET MODE: NEAREST"
TargetModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetModeBtn.Font = Enum.Font.Code
TargetModeBtn.Parent = RightSide


-- --- LOGIC EVENT HANDLERS ---

-- Input số cho Speed & Jump
SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val then CyberState.TargetSpeed = val else SpeedInput.Text = tostring(CyberState.TargetSpeed) end
end)

JumpInput.FocusLost:Connect(function()
    local val = tonumber(JumpInput.Text)
    if val then CyberState.TargetJump = val else JumpInput.Text = tostring(CyberState.TargetJump) end
end)

SpeedBtn.MouseButton1Click:Connect(function()
    CyberState.SpeedActive = not CyberState.SpeedActive
    toggleVisual(SpeedBtn, CyberState.SpeedActive)
end)

JumpBtn.MouseButton1Click:Connect(function()
    CyberState.JumpActive = not CyberState.JumpActive
    toggleVisual(JumpBtn, CyberState.JumpActive)
end)

InfJumpBtn.MouseButton1Click:Connect(function()
    CyberState.InfJump = not CyberState.InfJump
    toggleVisual(InfJumpBtn, CyberState.InfJump)
end)

NoclipBtn.MouseButton1Click:Connect(function()
    CyberState.Noclip = not CyberState.Noclip
    toggleVisual(NoclipBtn, CyberState.Noclip)
end)

ESPBtn.MouseButton1Click:Connect(function()
    CyberState.ESP = not CyberState.ESP
    toggleVisual(ESPBtn, CyberState.ESP)
end)

AimBtn.MouseButton1Click:Connect(function()
    CyberState.Aimbot = not CyberState.Aimbot
    toggleVisual(AimBtn, CyberState.Aimbot)
end)

POVBtn.MouseButton1Click:Connect(function()
    CyberState.POVActive = not CyberState.POVActive
    toggleVisual(POVBtn, CyberState.POVActive)
    if not CyberState.POVActive then
        Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    end
end)

TargetModeBtn.MouseButton1Click:Connect(function()
    if CyberState.TargetMode == "Nearest" then CyberState.TargetMode = "Furthest"
    elseif CyberState.TargetMode == "Furthest" then CyberState.TargetMode = "Selected"
    else CyberState.TargetMode = "Nearest" end
    TargetModeBtn.Text = "TARGET MODE: " .. CyberState.TargetMode:upper()
end)

-- Lấy mục tiêu
local function getTarget()
    if CyberState.TargetMode == "Selected" and CyberState.SelectedPlayer then
        return CyberState.SelectedPlayer
    end
    
    local target = nil
    local dist = (CyberState.TargetMode == "Nearest") and math.huge or -math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position
    if not myPos then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if CyberState.TargetMode == "Nearest" then
                if d < dist then dist = d; target = p end
            else
                if d > dist then dist = d; target = p end
            end
        end
    end
    return target
end

TPBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if t and t.Character and LocalPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
    end
end)

-- --- REFRESH DROPDOWN LIÊN TỤC (1s) ---
task.spawn(function()
    while true do
        for _, child in pairs(DropdownScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pBtn = Instance.new("TextButton")
                pBtn.Size = UDim2.new(1, -10, 0, 25)
                pBtn.BackgroundColor3 = (CyberState.SelectedPlayer == p) and Color3.fromRGB(0, 150, 180) or Color3.fromRGB(25, 30, 40)
                pBtn.Text = p.Name
                pBtn.TextColor3 = (CyberState.SelectedPlayer == p) and Color3.new(0,0,0) or Color3.new(1,1,1)
                pBtn.Font = Enum.Font.Code
                pBtn.TextSize = 12
                pBtn.Parent = DropdownScroll
                
                pBtn.MouseButton1Click:Connect(function()
                    CyberState.SelectedPlayer = p
                    CyberState.TargetMode = "Selected"
                    TargetModeBtn.Text = "TARGET MODE: SELECTED"
                    SelectedLabel.Text = "TARGET: " .. p.Name:upper()
                end)
            end
        end
        task.wait(1)
    end
end)

-- --- MAIN LOOPS ---
-- Loop 1: Movement, Noclip & ESP
task.spawn(function()
    while true do
        task.wait()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = CyberState.SpeedActive and CyberState.TargetSpeed or 16
                hum.JumpPower = CyberState.JumpActive and CyberState.TargetJump or 50
                -- Dòng dưới đây sửa lỗi các game ghi đè JumpPower
                if CyberState.JumpActive then hum.UseJumpPower = true end
            end
            if CyberState.Noclip then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local high = p.Character:FindFirstChild("CyberESP")
                if CyberState.ESP then
                    if not high then
                        high = Instance.new("Highlight")
                        high.Name = "CyberESP"
                        high.FillColor = Color3.fromRGB(0, 240, 255)
                        high.OutlineColor = Color3.fromRGB(255,255,255)
                        high.Parent = p.Character
                    end
                elseif high then high:Destroy() end
            end
        end
    end
end)

-- Loop 2: Aimbot & POV
task.spawn(function()
    while true do
        task.wait()
        local target = getTarget()
        if target and target.Character then
            if CyberState.Aimbot then
                local head = target.Character:FindFirstChild("Head")
                if head then Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position) end
            end
            if CyberState.POVActive then
                local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
                if targetHum then Camera.CameraSubject = targetHum end
            end
        end
    end
end)

-- Loop 3: Inf Jump
UserInputService.JumpRequest:Connect(function()
    if CyberState.InfJump and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
