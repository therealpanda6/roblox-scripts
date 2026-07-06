-- [[ SOURCE CODE BY GEMINI AI - MODERN FLY GUI (FIXED) ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Tìm vị trí lưu GUI phù hợp (CoreGui cho Executor, PlayerGui cho Roblox Studio)
local ParentUI = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Xóa GUI cũ nếu trùng tên
if ParentUI:FindFirstChild("ModernFlyGUI") then
    ParentUI["ModernFlyGUI"]:Destroy()
end

-- Lấy hệ thống điều khiển mặc định của game (Sửa lỗi không di chuyển được trên Mobile/PC)
local PlayerModule, MasterControl
pcall(function()
    PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    MasterControl = PlayerModule:GetControls()
end)

-- ==========================================
-- 1. TẠO GIAO DIỆN (UI DESIGN)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernFlyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentUI

-- Main Frame (Khung chính)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 180)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1 -- Đậm hơn vì đã bỏ Blur màn hình
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo thả
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Aurora Border (Viền đổi màu cực quang)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Parent = UIStroke

-- Tiêu đề GUI
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "AURORA FLY SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Nút Toggle Fly (Bật/Tắt bay)
local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyButton"
FlyButton.Size = UDim2.new(0, 260, 0, 40)
FlyButton.Position = UDim2.new(0.5, -130, 0.35, 0)
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyButton.Text = "Fly: OFF"
FlyButton.TextColor3 = Color3.fromRGB(230, 75, 75)
FlyButton.TextSize = 14
FlyButton.Font = Enum.Font.GothamBold
FlyButton.AutoButtonColor = true
FlyButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = FlyButton

-- Khung nhập tốc độ (Speed Input)
local SpeedBox = Instance.new("TextBox")
SpeedBox.Name = "SpeedBox"
SpeedBox.Size = UDim2.new(0, 260, 0, 35)
SpeedBox.Position = UDim2.new(0.5, -130, 0.65, 5)
SpeedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SpeedBox.Text = "50" -- Tốc độ mặc định
SpeedBox.PlaceholderText = "Nhập tốc độ bay..."
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 14
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 8)
SpeedCorner.Parent = SpeedBox

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Thickness = 1
SpeedStroke.Color = Color3.fromRGB(50, 50, 50)
SpeedStroke.Parent = SpeedBox


-- ==========================================
-- 2. HIỆU ỨNG AURORA LOOP (GIỮ NGUYÊN)
-- ==========================================

task.spawn(function()
    local hue = 0
    while task.wait(0.02) do
        hue = (hue + 0.005) % 1
        UIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 0.8, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue + 0.25) % 1, 0.8, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.5) % 1, 0.8, 1))
        })
    end
end)


-- ==========================================
-- 3. LOGIC HỆ THỐNG BAY CẢI TIẾN
-- ==========================================

local isFlying = false
local flySpeed = 50

local BodyVelocity, BodyGyro
local Character, Humanoid, RootPart

local function updateCharacterVars(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end
if LocalPlayer.Character then updateCharacterVars(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(updateCharacterVars)

-- Cập nhật tốc độ từ ô nhập
SpeedBox.FocusLost:Connect(function()
    local num = tonumber(SpeedBox.Text)
    if num then
        flySpeed = math.clamp(num, 1, 1000)
        SpeedBox.Text = tostring(flySpeed)
    else
        SpeedBox.Text = tostring(flySpeed)
    end
end)

-- Hàm xử lý Bật/Tắt bay chuẩn
local function toggleFly()
    if not RootPart or not Humanoid then return end
    isFlying = not isFlying

    if isFlying then
        FlyButton.Text = "Fly: ON"
        FlyButton.TextColor3 = Color3.fromRGB(75, 230, 75)
        
        -- Thêm lực bay
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = RootPart

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        BodyGyro.CFrame = RootPart.CFrame
        BodyGyro.Parent = RootPart

        Humanoid.PlatformStand = true
    else
        FlyButton.Text = "Fly: OFF"
        FlyButton.TextColor3 = Color3.fromRGB(230, 75, 75)
        
        -- Dọn dẹp lực để nhân vật rơi xuống bình thường
        if BodyVelocity then BodyVelocity:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        
        if Humanoid then 
            Humanoid.PlatformStand = false
            -- Ép nhân vật đứng dậy di chuyển ngay lập tức, sửa lỗi bị đơ/kẹt hình
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) 
        end
    end
end

FlyButton.MouseButton1Click:Connect(toggleFly)

-- Vòng lặp điều khiển hướng di chuyển thông minh (RenderStepped)
RunService.RenderStepped:Connect(function()
    if isFlying and RootPart and workspace.CurrentCamera then
        local camera = workspace.CurrentCamera
        BodyGyro.CFrame = camera.CFrame
        
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- Sử dụng MasterControl để lấy hướng di chuyển (Hoạt động tốt cho cả phím WASD và Joystick điện thoại)
        if MasterControl then
            local moveVector = MasterControl:GetMoveVector()
            -- moveVector.Z: -1 là Tiến, 1 là Lùi | moveVector.X: -1 là Trái, 1 là Phải
            moveDirection = (camera.CFrame.LookVector * -moveVector.Z) + (camera.CFrame.RightVector * moveVector.X)
        else
            -- Phương án dự phòng truyền thống cho PC nếu hệ thống trên lỗi
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
        end
        
        -- Phím bổ trợ tăng/giảm độ cao trực tiếp cho PC
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end

        -- Áp dụng vận tốc bay theo hướng camera hướng tới
        if moveDirection.Magnitude > 0 then
            BodyVelocity.Velocity = moveDirection.Unit * flySpeed
        else
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Tự động tắt nếu nhân vật bị chết/reset
LocalPlayer.CharacterRemoving:Connect(function()
    if isFlying then
        toggleFly()
    end
end)
