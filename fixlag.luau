-- ==========================================
--  TỐI ƯU HÓA TOÀN DIỆN & HUD RGB GAMING 
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. TÍNH NĂNG ANTI-AFK
-- ==========================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ==========================================
-- 2. TỰ ĐỘNG KẾT NỐI LẠI (AUTO REJOIN)
-- ==========================================
pcall(function()
    local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
    promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end)

-- ==========================================
-- 3. TỐI ƯU HÓA FPS & XÓA HIỆU ỨNG (FIX LAG)
-- ==========================================
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 2

Workspace.Terrain.WaterWaveSize = 0
Workspace.Terrain.WaterWaveSpeed = 0
Workspace.Terrain.WaterReflectance = 0
Workspace.Terrain.WaterTransparency = 0

local function optimizeDescendant(descendant)
    if descendant:IsA("BasePart") then
        descendant.Material = Enum.Material.SmoothPlastic
        descendant.Reflectance = 0
    elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
        descendant.Transparency = 1
    elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
        descendant.Enabled = false
    elseif descendant:IsA("PostEffect") or descendant:IsA("Atmosphere") or descendant:IsA("Clouds") then
        descendant.Enabled = false
    end
end

for _, v in pairs(game:GetDescendants()) do
    pcall(optimizeDescendant, v)
end
game.DescendantAdded:Connect(function(descendant)
    pcall(optimizeDescendant, descendant)
end)

-- ==========================================
-- 4. TẠO GIAO DIỆN HUD PIXEL-PERFECT (SỬA LỖI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RGB_Gaming_HUD"
ScreenGui.DisplayOrder = 999999999 
ScreenGui.ResetOnSpawn = false

local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Frame chính (Nền đen tuyệt đối)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 80)
MainFrame.Position = UDim2.new(0, 10, 0, 60) -- Nằm góc trái dưới chat/logo hợp lý
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Viền cầu vồng sắc nét (Sharp Border)
local BorderStroke = Instance.new("UIStroke")
BorderStroke.Thickness = 2
BorderStroke.Parent = MainFrame

-- Khung hiệu ứng Glow phát sáng (Đặt trùng khít tọa độ gốc 0,0)
local GlowFrame = Instance.new("Frame")
GlowFrame.Size = UDim2.new(1, 0, 1, 0)
GlowFrame.Position = UDim2.new(0, 0, 0, 0)
GlowFrame.BackgroundTransparency = 1
GlowFrame.BorderSizePixel = 0
GlowFrame.Parent = MainFrame

local GlowStroke = Instance.new("UIStroke")
GlowStroke.Thickness = 6
GlowStroke.Transparency = 0.6 -- Tạo độ nhòe ánh sáng phát quang ngoài viền
GlowStroke.Parent = GlowFrame

-- Dòng 1: FPS & PING (Cố định vị trí bằng pixel, căn giữa hoàn hảo)
local Line1 = Instance.new("TextLabel")
Line1.Size = UDim2.new(1, 0, 0, 30)
Line1.Position = UDim2.new(0, 0, 0, 12) -- Cách lề trên 12px
Line1.BackgroundTransparency = 1
Line1.Font = Enum.Font.Arcade
Line1.TextSize = 16 -- Sử dụng kích thước cố định để chữ không bị tràn/bóp méo
Line1.TextXAlignment = Enum.TextXAlignment.Center
Line1.TextYAlignment = Enum.TextYAlignment.Center
Line1.TextStrokeTransparency = 0.4
Line1.TextStrokeColor3 = Color3.new(0, 0, 0)
Line1.Parent = MainFrame

-- Dòng 2: TIME & RUN TIME
local Line2 = Instance.new("TextLabel")
Line2.Size = UDim2.new(1, 0, 0, 30)
Line2.Position = UDim2.new(0, 0, 0, 42) -- Cách lề trên 42px (khoảng cách an toàn)
Line2.BackgroundTransparency = 1
Line2.Font = Enum.Font.Arcade
Line2.TextSize = 16
Line2.TextXAlignment = Enum.TextXAlignment.Center
Line2.TextYAlignment = Enum.TextYAlignment.Center
Line2.TextStrokeTransparency = 0.4
Line2.TextStrokeColor3 = Color3.new(0, 0, 0)
Line2.Parent = MainFrame

-- ==========================================
-- 5. TÍNH NĂNG KÉO THẢ (DRAGGABLE KHÔNG LỆCH)
-- ==========================================
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.Heartbeat:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- 6. CẬP NHẬT THÔNG SỐ & HIỆU ỨNG RGB
-- ==========================================
local startTime = tick()
local frames = 0
local currentFPS = 0

task.spawn(function()
    while task.wait(1) do
        currentFPS = frames
        frames = 0
    end
end)

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    
    local hue = tick() % 4 / 4 -- Chu kỳ chạy màu 4 giây mượt mà
    local rgbColor = Color3.fromHSV(hue, 1, 1)
    
    BorderStroke.Color = rgbColor
    GlowStroke.Color = rgbColor
    Line1.TextColor3 = rgbColor
    Line2.TextColor3 = rgbColor

    local ping = 0
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)

    local realTime = os.date("%H:%M:%S")
    local elapsed = math.floor(tick() - startTime)
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    local runTime = string.format("%02d:%02d", mins, secs)

    Line1.Text = "FPS: " .. currentFPS .. "  |  PING: " .. ping .. "ms"
    Line2.Text = "TIME: " .. realTime .. "  |  RUN: " .. runTime
end)

-- ==========================================
-- 7. TỐI ƯU HÓA NETWORK & ỔN ĐỊNH PING 
-- ==========================================
task.spawn(function()
    pcall(function()
        settings().Network.IncomingReplicationLag = 0
    end)
    pcall(function()
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
        settings().Physics.AllowSleep = true
    end)
    pcall(function()
        local RenderSettings = settings():GetService("RenderSettings")
        RenderSettings.EagerBulkExecution = false
    end)
end)
