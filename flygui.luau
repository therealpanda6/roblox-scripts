-- [[ SOURCE CODE BY GEMINI AI - HACKER STYLE FLY_GUI ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Tìm vị trí lưu GUI phù hợp (CoreGui cho Executor, PlayerGui cho Roblox Studio)
local ParentUI = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Xóa GUI cũ nếu trùng tên "fly gui"
if ParentUI:FindFirstChild("fly gui") then
    ParentUI["fly gui"]:Destroy()
end

-- Lấy hệ thống điều khiển mặc định của game để di chuyển mượt mà
local PlayerModule, MasterControl
pcall(function()
    PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    MasterControl = PlayerModule:GetControls()
end)

-- Mã màu phong cách Hacker Console
local COLOR_BG = Color3.fromRGB(10, 10, 10)         -- Đen đặc Terminal
local COLOR_NEON = Color3.fromRGB(0, 255, 65)       -- Xanh lá sáng Neon
local COLOR_DARK_GREEN = Color3.fromRGB(0, 60, 15)  -- Xanh lá tối cho viền phụ
local COLOR_TEXT_DIM = Color3.fromRGB(0, 180, 45)   -- Xanh lá vừa cho text phụ

-- ==========================================
-- 1. TẠO GIAO DIỆN (UI DESIGN)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "fly gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999999 -- Luôn hiển thị trên cùng lớp nền
ScreenGui.Parent = ParentUI

-- Main Frame (Khung vuông góc cạnh)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 200)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 4) -- Bo góc cực nhẹ cho tinh tế
UICorner.Parent = MainFrame

-- Viền Neon cứng cáp
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = COLOR_NEON
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

-- Tiêu đề GUI (Giữ con trỏ nhấp nháy tạo điểm nhấn hacker)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "FLY CONTROL SYSTEM_"
Title.TextColor3 = COLOR_NEON
Title.TextSize = 15
Title.Font = Enum.Font.Code -- Phông chữ Code cố định độ rộng
Title.Parent = MainFrame

-- Nút Bật/Tắt trạng thái bay (English Text)
local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyButton"
FlyButton.Size = UDim2.new(0, 280, 0, 40)
FlyButton.Position = UDim2.new(0.5, -140, 0, 45)
FlyButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FlyButton.Text = "Fly: OFF" -- Text tiếng Anh bình thường
FlyButton.TextColor3 = COLOR_TEXT_DIM
FlyButton.TextSize = 14
FlyButton.Font = Enum.Font.Code

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 1
ButtonStroke.Color = COLOR_DARK_GREEN
ButtonStroke.Parent = FlyButton

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 3)
ButtonCorner.Parent = FlyButton
FlyButton.Parent = MainFrame

-- Chú thích tốc độ (English Text)
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0, 280, 0, 20)
SpeedLabel.Position = UDim2.new(0.5, -140, 0, 100)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Flight Speed (Press Enter to apply):" -- Text tiếng Anh bình thường
SpeedLabel.TextColor3 = COLOR_TEXT_DIM
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.Code
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

-- Hộp nhập tốc độ
local SpeedBox = Instance.new("TextBox")
SpeedBox.Name = "SpeedBox"
SpeedBox.Size = UDim2.new(0, 280, 0, 35)
SpeedBox.Position = UDim2.new(0.5, -140, 0, 125)
SpeedBox.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
SpeedBox.Text = "50"
SpeedBox.PlaceholderText = "Enter speed here..." -- Text tiếng Anh bình thường
SpeedBox.PlaceholderColor3 = COLOR_DARK_GREEN
SpeedBox.TextColor3 = COLOR_NEON
SpeedBox.TextSize = 14
SpeedBox.Font = Enum.Font.Code

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Thickness = 1
SpeedStroke.Color = COLOR_DARK_GREEN
SpeedStroke.Parent = SpeedBox

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 3)
SpeedCorner.Parent = SpeedBox
SpeedBox.Parent = MainFrame


-- ==========================================
-- 2. HIỆU ỨNG NHẤP NHÁY CON TRỎ (HACKER BLINK)
-- ==========================================

task.spawn(function()
    while task.wait(0.5) do
        Title.Text = "FLY CONTROL SYSTEM_"
        task.wait(0.5)
        Title.Text = "FLY CONTROL SYSTEM "
    end
end)


-- ==========================================
-- 3. LOGIC HỆ THỐNG BAY GỐC (HỖ TRỢ DI CHUYỂN)
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

-- Đọc dữ liệu từ ô nhập tốc độ
SpeedBox.FocusLost:Connect(function()
    local num = tonumber(SpeedBox.Text)
    if num then
        flySpeed = math.clamp(num, 1, 1000)
        SpeedBox.Text = tostring(flySpeed)
    else
        SpeedBox.Text = tostring(flySpeed)
    end
end)

-- Cơ chế Bật/Tắt trạng thái Bay
local function toggleFly()
    if not RootPart or not Humanoid then return end
    isFlying = not isFlying

    if isFlying then
        FlyButton.Text = "Fly: ON"
        FlyButton.TextColor3 = COLOR_NEON
        ButtonStroke.Color = COLOR_NEON
        
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
        FlyButton.TextColor3 = COLOR_TEXT_DIM
        ButtonStroke.Color = COLOR_DARK_GREEN
        
        if BodyVelocity then BodyVelocity:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        
        if Humanoid then 
            Humanoid.PlatformStand = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

FlyButton.MouseButton1Click:Connect(toggleFly)

-- Vòng lặp RenderStepped quản lý di chuyển (PC WASD / Mobile Joystick)
RunService.RenderStepped:Connect(function()
    if isFlying and RootPart and workspace.CurrentCamera then
        local camera = workspace.CurrentCamera
        BodyGyro.CFrame = camera.CFrame
        
        local moveDirection = Vector3.new(0, 0, 0)
        
        if MasterControl then
            local moveVector = MasterControl:GetMoveVector()
            moveDirection = (camera.CFrame.LookVector * -moveVector.Z) + (camera.CFrame.RightVector * moveVector.X)
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
        end
        
        -- Phím bổ trợ độ cao cho PC
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

        if moveDirection.Magnitude > 0 then
            BodyVelocity.Velocity = moveDirection.Unit * flySpeed
        else
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if isFlying then
        toggleFly()
    end
end)
