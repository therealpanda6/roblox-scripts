loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/fast-attack-blox-fruits/refs/heads/main/aurafruit.luau"))()
_G.FastAttack = true

if _G.FastAttack then
    local _ENV = (getgenv or getrenv or getfenv)()

    local function SafeWaitForChild(parent, childName)
        local success, result = pcall(function()
            return parent:WaitForChild(childName)
        end)
        if not success or not result then
            warn("noooooo: " .. childName)
        end
        return result
    end

    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes")
    local Validator = SafeWaitForChild(Remotes, "Validator")
    local CommF = SafeWaitForChild(Remotes, "CommF_")
    local CommE = SafeWaitForChild(Remotes, "CommE")

    local Settings = {
        AutoClick = true,
        ClickDelay = 0.5
    }

    local Module = {}

    Module.FastAttack = (function()
        if _ENV.rz_FastAttack then
            return _ENV.rz_FastAttack
        end

        local FastAttack = {
            Distance = 100,
            attackMobs = true,
            attackPlayers = true,
            Equipped = nil
        }

        local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
        local RegisterHit = SafeWaitForChild(Net, "RE/RegisterHit")

        local function IsAlive(character)
            return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
        end

        local function ProcessEnemies(OthersEnemies, Folder)
            local BasePart = nil
            for _, Enemy in Folder:GetChildren() do
                local Head = Enemy:FindFirstChild("Head")
                if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < FastAttack.Distance then
                    if Enemy ~= Player.Character then
                        table.insert(OthersEnemies, {Enemy, Head})
                        BasePart = Head
                    end
                end
            end
            return BasePart
        end

        function FastAttack:Attack(BasePart, OthersEnemies)
            if not BasePart or #OthersEnemies == 0 then
                return
            end
            RegisterAttack:FireServer(Settings.ClickDelay or 0)
            RegisterHit:FireServer(BasePart, OthersEnemies)
        end

        function FastAttack:AttackNearest()
            local OthersEnemies = {}
            local Part1 = ProcessEnemies(OthersEnemies, Enemies)
            local Part2 = ProcessEnemies(OthersEnemies, Characters)

            local character = Player.Character
            if not character then
                return
            end
            local equippedWeapon = character:FindFirstChildOfClass("Tool")

            if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
                for _, enemyData in ipairs(OthersEnemies) do
                    local enemy = enemyData[1]
                    local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                    pcall(function()
                        equippedWeapon.LeftClickRemote:FireServer(direction, 1)
                    end)
                end
            elseif #OthersEnemies > 0 then
                self:Attack(Part1 or Part2, OthersEnemies)
            else
                task.wait(0.5)
            end
        end

        function FastAttack:BladeHits()
            local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
            if Equipped and Equipped.ToolTip ~= "Gun" then
                self:AttackNearest()
            else
                task.wait(0.5)
            end
        end

        task.spawn(function()
            while task.wait(Settings.ClickDelay) do
                if Settings.AutoClick then
                    FastAttack:BladeHits()
                end
            end
        end)

        _ENV.rz_FastAttack = FastAttack
        return FastAttack
    end)()
end

-- ========== PHẦN 2: FAST ATTACK LOOP TỰ ĐỘNG ==========
local remote, idremote
for _, v in next, ({game.ReplicatedStorage.Util, game.ReplicatedStorage.Common, game.ReplicatedStorage.Remotes,
                    game.ReplicatedStorage.Assets, game.ReplicatedStorage.FX}) do
    for _, n in next, v:GetChildren() do
        if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
            remote, idremote = n, n:GetAttribute("Id")
        end
    end
    v.ChildAdded:Connect(function(n)
        if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
            remote, idremote = n, n:GetAttribute("Id")
        end
    end)
end

task.spawn(function()
    while task.wait(0.5) do -- đã sửa từ 0.05 xuống 0.04
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local parts = {}

        for _, x in ipairs({workspace.Enemies, workspace.Characters}) do
            for _, v in ipairs(x and x:GetChildren() or {}) do
                local hrp = v:FindFirstChild("HumanoidRootPart")
                local hum = v:FindFirstChild("Humanoid")

                if v ~= char and hrp and hum and hum.Health > 0 and (hrp.Position - root.Position).Magnitude <= 60 then
                    for _, _v in ipairs(v:GetChildren()) do
                        if _v:IsA("BasePart") then
                            parts[#parts + 1] = {v, _v}
                        end
                    end
                end
            end
        end

        local tool = char:FindFirstChildOfClass("Tool")

        if #parts > 0 and tool and (
            tool:GetAttribute("WeaponType") == "Melee" or
            tool:GetAttribute("WeaponType") == "Sword" or
            tool:GetAttribute("WeaponType") == "Blox Fruit" or
            tool:GetAttribute("WeaponType") == "DevilFruit"
        ) then

            pcall(function()
                require(game.ReplicatedStorage.Modules.Net):RemoteEvent("RegisterHit", true)
                game.ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer()

                local head = parts[1][1]:FindFirstChild("Head")
                if not head then return end

                game.ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(
                    head,
                    parts,
                    {},
                    tostring(game.Players.LocalPlayer.UserId):sub(2,4) ..
                    tostring(coroutine.running()):sub(11,15)
                )

                cloneref(remote):FireServer(
                    string.gsub("RE/RegisterHit",".",function(c)
                        return string.char(
                            bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow()/10.50)+1)
                        )
                    end),
                    bit32.bxor(
                        idremote + 909090,
                        game.ReplicatedStorage.Modules.Net.seed:InvokeServer()*2
                    ),
                    head,
                    parts
                )
            end)
        end
    end
end)

-- ========== PHẦN 3: FAST ATTACK TRONG AUTO MELEE SECTION ==========
_G.at = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local Net = require(ReplicatedStorage.Modules.Net)
local CombatUtil = require(ReplicatedStorage.Modules.CombatUtil)

local hitRemote = Net:RemoteEvent("RegisterHit")
local attackRemote = ReplicatedStorage.Modules.Net:FindFirstChild("RE/RegisterAttack")

local function FastAttack(target)
    local char = lp.Character
    if not char then return end
    
    local hrp = target:FindFirstChild("HumanoidRootPart")
    local hum = target:FindFirstChild("Humanoid")

    if not hrp or not hum or hum.Health <= 0 then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end 

    pcall(function()
        local weaponName = CombatUtil:GetWeaponName(tool)
        local uuid = tostring(lp.UserId):sub(2,4)..tostring(math.random(10000,99999)) 
        local hitData = {{target, hrp}}

        hitRemote:FireServer(hrp, hitData, nil, nil, uuid)
        CombatUtil:ApplyDamageHighlight(target, char, weaponName, hrp, nil)
    end)
end

local function GetMobsInRange(maxDist)
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return {} end

    local root = char.HumanoidRootPart
    local mobs = {}

    for _, mob in ipairs(workspace.Enemies:GetChildren()) do
        local mHrp = mob:FindFirstChild("HumanoidRootPart")
        local mHum = mob:FindFirstChild("Humanoid")

        if mHrp and mHum and mHum.Health > 0 then
            local dist = (mHrp.Position - root.Position).Magnitude
            if dist <= (maxDist or 60) then
                table.insert(mobs, mob)
            end
        end
    end

    return mobs
end

task.spawn(function()
    while task.wait() do
        if _G.at then
            pcall(function()
                local char = lp.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local mobs = GetMobsInRange(60)

                    if #mobs > 0 then
                        if attackRemote then
                            attackRemote:FireServer()
                        end

                        for _, mob in ipairs(mobs) do
                            FastAttack(mob)
                        end
                    end
                end
            end)
        end
    end
end)
