local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- =========================================
-- 1. XÓA HIỆU ỨNG & TỐI ƯU HÓA (FPS BOOST)
-- =========================================
settings().Rendering.QualityLevel = 1
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 1

for _, v in pairs(game:GetDescendants()) do
    if v:IsA("Part") or v:IsA("Union") or v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
        v.Enabled = false
    end
end

-- =========================================
-- 2. ANTI-AFK (CHỐNG KICK TREO MÁY)
-- =========================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- =========================================
-- 3. AUTO-REJOIN (TỰ ĐỘNG VÀO LẠI KHI DISCONNECT)
-- =========================================
GuiService.ErrorMessageChanged:Connect(function()
    task.wait(2)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- =========================================
-- 4. GIAO DIỆN ĐỒNG HỒ FPS RGB GAMING
-- =========================================
local guiParent
local success = pcall(function() guiParent = game:GetService("CoreGui") end)
if not success or not guiParent then
    guiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RGB_FPS_Monitor"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 140, 0, 45)
mainFrame.Position = UDim2.new(0.5, -70, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local uiStrokeFrame = Instance.new("UIStroke")
uiStrokeFrame.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStrokeFrame.Thickness = 2.5
uiStrokeFrame.Parent = mainFrame

local fpsText = Instance.new("TextLabel")
fpsText.Size = UDim2.new(1, 0, 1, 0)
fpsText.BackgroundTransparency = 1
fpsText.Text = "FPS: ..."
fpsText.Font = Enum.Font.GothamBlack
fpsText.TextSize = 22
fpsText.Parent = mainFrame

local uiStrokeText = Instance.new("UIStroke")
uiStrokeText.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
uiStrokeText.Thickness = 1.2
uiStrokeText.Transparency = 0.2
uiStrokeText.Parent = fpsText

-- Logic Kéo Thả (Draggable)
local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- =========================================
-- 5. CẬP NHẬT FPS (MỖI 1 GIÂY) & HIỆU ỨNG RGB
-- =========================================
local lastUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    
    -- Thay đổi điều kiện: Tính toán và cập nhật số FPS đúng mỗi 1.0 giây
    if currentTime - lastUpdate >= 1.0 then
        local fps = math.floor(frameCount / (currentTime - lastUpdate))
        fpsText.Text = "FPS: " .. tostring(fps)
        
        -- Reset bộ đếm cho giây tiếp theo
        frameCount = 0
        lastUpdate = currentTime
    end
    
    -- Hiệu ứng đổi màu Chroma RGB (vẫn mượt mà theo từng khung hình)
    local rainbowHue = (currentTime % 4) / 4 
    local rgbColor = Color3.fromHSV(rainbowHue, 1, 1)
    
    fpsText.TextColor3 = rgbColor
    uiStrokeText.Color = rgbColor
    uiStrokeFrame.Color = rgbColor
end)
