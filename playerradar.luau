--[[
    ======================================
     RADAR MINIMAP (TOP-DOWN PLAYER RADAR)
    ======================================
    Đặt vào StarterPlayerScripts (LocalScript).
    Hiển thị người chơi khác quanh bạn dạng radar tròn góc phải màn hình.
    Bấm +/- để zoom, chấm đỏ nhấp nháy khi có người ở gần.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RADAR_PIXELS = 85
local CLOSE_RANGE = 20
local range = 150
local MIN_RANGE, MAX_RANGE = 50, 400

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RadarMinimap"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 850
screenGui.Parent = playerGui

local radar = Instance.new("Frame")
radar.AnchorPoint = Vector2.new(1, 1)
radar.Position = UDim2.new(1, -20, 1, -20)
radar.Size = UDim2.new(0, RADAR_PIXELS * 2 + 20, 0, RADAR_PIXELS * 2 + 20)
radar.BackgroundColor3 = Color3.fromRGB(10, 16, 12)
radar.BackgroundTransparency = 0.1
radar.Parent = screenGui
Instance.new("UICorner", radar).CornerRadius = UDim.new(1, 0)

local radarStroke = Instance.new("UIStroke")
radarStroke.Color = Color3.fromRGB(72, 219, 143)
radarStroke.Transparency = 0.4
radarStroke.Thickness = 2
radarStroke.Parent = radar

local scanArea = Instance.new("Frame")
scanArea.AnchorPoint = Vector2.new(0.5, 0.5)
scanArea.Position = UDim2.new(0.5, 0, 0.5, 0)
scanArea.Size = UDim2.new(0, RADAR_PIXELS * 2, 0, RADAR_PIXELS * 2)
scanArea.BackgroundTransparency = 1
scanArea.ClipsDescendants = true
scanArea.Parent = radar

-- Vòng tròn đồng tâm trang trí
for _, r in ipairs({0.33, 0.66, 1}) do
    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.Size = UDim2.new(r, 0, r, 0)
    ring.BackgroundTransparency = 1
    ring.Parent = scanArea
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local rs = Instance.new("UIStroke")
    rs.Color = Color3.fromRGB(72, 219, 143)
    rs.Transparency = 0.8
    rs.Thickness = 1
    rs.Parent = ring
end

-- Đường chữ thập
local hLine = Instance.new("Frame")
hLine.AnchorPoint = Vector2.new(0.5, 0.5)
hLine.Position = UDim2.new(0.5, 0, 0.5, 0)
hLine.Size = UDim2.new(1, 0, 0, 1)
hLine.BackgroundColor3 = Color3.fromRGB(72, 219, 143)
hLine.BackgroundTransparency = 0.8
hLine.Parent = scanArea

local vLine = hLine:Clone()
vLine.Size = UDim2.new(0, 1, 1, 0)
vLine.Parent = scanArea

-- Điểm đánh dấu bản thân (luôn hướng lên trên = phía trước)
local selfMarker = Instance.new("TextLabel")
selfMarker.AnchorPoint = Vector2.new(0.5, 0.5)
selfMarker.Position = UDim2.new(0.5, 0, 0.5, 0)
selfMarker.Size = UDim2.new(0, 22, 0, 22)
selfMarker.BackgroundTransparency = 1
selfMarker.Text = "▲"
selfMarker.TextColor3 = Color3.fromRGB(250, 200, 60)
selfMarker.TextScaled = true
selfMarker.ZIndex = 5
selfMarker.Parent = scanArea

-- Nhãn tầm quét
local rangeLabel = Instance.new("TextLabel")
rangeLabel.AnchorPoint = Vector2.new(0.5, 0)
rangeLabel.Position = UDim2.new(0.5, 0, 1, 6)
rangeLabel.Size = UDim2.new(1, 0, 0, 16)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "Range: " .. range .. "m"
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 12
rangeLabel.TextColor3 = Color3.fromRGB(72, 219, 143)
rangeLabel.Parent = radar

local function makeZoomBtn(text, position)
    local btn = Instance.new("TextButton")
    btn.Position = position
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(25, 35, 28)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(72, 219, 143)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = radar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

local zoomOutBtn = makeZoomBtn("-", UDim2.new(0.5, -20, 1, 24))
local zoomInBtn = makeZoomBtn("+", UDim2.new(0.5, 20, 1, 24))

zoomOutBtn.MouseButton1Click:Connect(function()
    range = math.clamp(range + 50, MIN_RANGE, MAX_RANGE)
    rangeLabel.Text = "Tầm: " .. range .. "m"
end)
zoomInBtn.MouseButton1Click:Connect(function()
    range = math.clamp(range - 50, MIN_RANGE, MAX_RANGE)
    rangeLabel.Text = "Tầm: " .. range .. "m"
end)

-- ===== Quản lý các blip người chơi =====
local blips = {}
local pulsing = {}

local function getOrCreateBlip(otherPlayer)
    if blips[otherPlayer] then return blips[otherPlayer] end
    local blip = Instance.new("Frame")
    blip.AnchorPoint = Vector2.new(0.5, 0.5)
    blip.Size = UDim2.new(0, 10, 0, 10)
    blip.BackgroundColor3 = Color3.fromRGB(90, 200, 250)
    blip.ZIndex = 4
    blip.Parent = scanArea
    Instance.new("UICorner", blip).CornerRadius = UDim.new(1, 0)
    blips[otherPlayer] = blip
    return blip
end

local function cleanupBlips()
    for plr, blip in pairs(blips) do
        if not plr.Parent or plr == player then
            blip:Destroy()
            blips[plr] = nil
            pulsing[plr] = nil
        end
    end
end

RunService.Heartbeat:Connect(function()
    cleanupBlips()

    local char = player.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local myCFrame = myHRP.CFrame

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            local otherHRP = otherChar and otherChar:FindFirstChild("HumanoidRootPart")
            if otherHRP then
                local blip = getOrCreateBlip(otherPlayer)
                blip.Visible = true

                local relative = myCFrame:ToObjectSpace(otherHRP.CFrame)
                local dx, dz = relative.X, relative.Z
                local dist = math.sqrt(dx * dx + dz * dz)

                local norm = Vector2.new(dx, dz)
                if norm.Magnitude > range then
                    norm = norm.Unit * range
                end
                local px = (norm.X / range) * RADAR_PIXELS
                local py = (norm.Y / range) * RADAR_PIXELS
                blip.Position = UDim2.new(0.5, px, 0.5, py)

                if dist <= CLOSE_RANGE then
                    if not pulsing[otherPlayer] then
                        pulsing[otherPlayer] = true
                        blip.BackgroundColor3 = Color3.fromRGB(240, 90, 90)
                        task.spawn(function()
                            while pulsing[otherPlayer] and blip.Parent do
                                TweenService:Create(blip, TweenInfo.new(0.4), {Size = UDim2.new(0, 16, 0, 16)}):Play()
                                task.wait(0.4)
                                TweenService:Create(blip, TweenInfo.new(0.4), {Size = UDim2.new(0, 10, 0, 10)}):Play()
                                task.wait(0.4)
                            end
                        end)
                    end
                else
                    pulsing[otherPlayer] = nil
                    blip.BackgroundColor3 = Color3.fromRGB(90, 200, 250)
                end
            elseif blips[otherPlayer] then
                blips[otherPlayer].Visible = false
            end
        end
    end
end)
