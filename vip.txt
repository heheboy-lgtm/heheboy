if not game:IsLoaded() then game.Loaded:Wait() end
local P_Serv = game:GetService("Players")
local LP = P_Serv.LocalPlayer or P_Serv:GetPropertyChangedSignal("LocalPlayer"):Wait()

local S = {
    P = P_Serv, W = game:GetService("Workspace"),
    RS = game:GetService("RunService"), V = game:GetService("VirtualInputManager"),
    L = game:GetService("Lighting"), ST = game:GetService("Stats"),
    GS = game:GetService("GuiService"), TS = game:GetService("TeleportService"),
    HTTP = game:GetService("HttpService"), CG = game:GetService("CoreGui")
}

local t_wait, t_spawn = task.wait, task.spawn
local m_random, m_floor = math.random, math.floor
local v3_new, cf_new = Vector3.new, CFrame.new

getgenv().Setting = getgenv().Setting or {
    Hitbox = { Enabled = true, Size = 35, Transparency = 0.7 },
    DeleteMap = true
}

getgenv().LockedTarget = nil
getgenv().Retreating = false
getgenv().RetreatTracker = getgenv().RetreatTracker or {}
getgenv().LastTargetName = nil
getgenv().LastAttacker = nil
local Blacklist = {}
local PvpOffList = {}
local bLabel = nil
local lastUISearch = 0

local function getRealBounty()
    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        local b = ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty")
        if b then 
            local val = tostring(b.Value):upper()
            val = val:gsub(",", ""):gsub("%$", "")
            
            if val:match("M") then
                return (tonumber(val:gsub("M", "")) or 0) * 1000000
            elseif val:match("K") then
                return (tonumber(val:gsub("K", "")) or 0) * 1000
            end
            
            return tonumber(val) or 0
        end
    end
    return 0
end

local FileName = "DoraEarned_" .. LP.UserId .. ".txt"
local KillFile = "DoraKills_" .. LP.UserId .. ".txt"
local HourFile = "DoraHour_" .. LP.UserId .. ".txt"
local HourStartFile = "DoraHourStart_" .. LP.UserId .. ".txt"
local TimeFile = "DoraTime_" .. LP.UserId .. ".txt"
local function SaveHour(val)
    pcall(function()
        if writefile then
            writefile(HourFile, tostring(val))
        end
    end)
end

local function LoadHour()
    local val = 0
    pcall(function()
        if isfile and readfile and isfile(HourFile) then
            val = tonumber(readfile(HourFile)) or 0
        end
    end)
    return val
end
local function SaveEarned(val)
    pcall(function()
        if writefile then
            writefile(FileName, tostring(val))
        end
    end)
end
local function SaveHourStart(val)
    pcall(function()
        if writefile then
            writefile(HourStartFile, tostring(val))
        end
    end)
end

local function LoadHourStart()
    local val = tick()
    pcall(function()
        if isfile and readfile and isfile(HourStartFile) then
            val = tonumber(readfile(HourStartFile)) or tick()
        end
    end)
    return val
end

local function SaveTime(val)
    pcall(function()
        if writefile then
            writefile(TimeFile, tostring(val))
        end
    end)
end

local function LoadTime()
    local val = 0
    pcall(function()
        if isfile and readfile and isfile(TimeFile) then
            val = tonumber(readfile(TimeFile)) or 0

            -- nếu số quá lớn thì reset
            if val > 100000 then
                val = 0
                if writefile then
                    writefile(TimeFile,"0")
                end
            end
        end
    end)
    return val
end
local function SaveKills(val)
    pcall(function()
        if writefile then
            writefile(KillFile, tostring(val))
        end
    end)
end
local function LoadKills()
    local val = 0
    pcall(function()
        if isfile and readfile and isfile(KillFile) then
            val = tonumber(readfile(KillFile)) or 0
        end
    end)
    return val
end
local function LoadEarned()
    local val = 0
    pcall(function()
        if isfile and readfile and isfile(FileName) then val = tonumber(readfile(FileName)) or 0 end
    end)
    return val
end

local TotalEarned = LoadEarned() 
local HourEarned = LoadHour()
local HourStart = LoadHourStart()

if not HourStart or HourStart <= 0 then
    HourStart = tick()
    SaveHourStart(HourStart)
end

-- reset mỗi 1 giờ
if tick() - HourStart >= 3600 then
    HourEarned = 0
    HourStart = tick()
    SaveHour(0)
    SaveHourStart(HourStart)
end
local LastBounty = -1
local LastKillTime = 0
local FrameCount, CurrentFPS = 0, 0
local PlayedTime = LoadTime()
local SessionStart = tick()
local StartTime = tick()
local lastSave = tick()
local LastRespawn = tick()
local PvpDelay = 5
LP.CharacterAdded:Connect(function(char)

    LastRespawn = tick()

    local hum = char:WaitForChild("Humanoid")

    hum.HealthChanged:Connect(function(newHP)

        if newHP < hum.MaxHealth then

            local closest = nil
            local dist = math.huge

            for _,plr in pairs(game:GetService("Players"):GetPlayers()) do
                if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

                    local d = (LP.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude

                    if d < dist and d < 80 then
                        dist = d
                        closest = plr.Character
                    end

                end
            end

           if closest 
and not closest:FindFirstChild("SafeZone")
and not closest:FindFirstChild("ForceField") then

    getgenv().LastAttacker = closest
    getgenv().LockedTarget = closest

end

        end

    end)

end)
if LP.Character and LP.Character:FindFirstChild("Humanoid") then
    if LP.Character.Humanoid.Health <= 0 then
        LastRespawn = tick()
    end
end
local PvpDelay = 5
local Kills = LoadKills()

--// DORA UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DORA_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,240,0,165)
Main.Position = UDim2.new(1,-270,0.35,0)
Main.BackgroundColor3 = Color3.fromRGB(12,12,16)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner",Main)
Corner.CornerRadius = UDim.new(0,8)

local Stroke = Instance.new("UIStroke",Main)
Stroke.Color = Color3.fromRGB(0,255,180)
Stroke.Thickness = 2

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,0,0,25)
Title.Font = Enum.Font.GothamBold
Title.Text = "DORA VIP"
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(0,170,255)

-- Total
local Total = Instance.new("TextLabel")
Total.Parent = Main
Total.BackgroundTransparency = 1
Total.Position = UDim2.new(0,10,0,35)
Total.Size = UDim2.new(1,-20,0,20)
Total.Font = Enum.Font.GothamBold
Total.Text = "TOTAL: --"
Total.TextSize = 14
Total.TextColor3 = Color3.fromRGB(255,255,255)
Total.TextXAlignment = Enum.TextXAlignment.Left

-- Earned
local Earn = Instance.new("TextLabel")
Earn.Parent = Main
Earn.BackgroundTransparency = 1
Earn.Position = UDim2.new(0,10,0,55)
Earn.Size = UDim2.new(1,-20,0,20)
Earn.Font = Enum.Font.GothamBold
Earn.Text = "EARNED: 0"
Earn.TextSize = 14
Earn.TextColor3 = Color3.fromRGB(0,255,120)
Earn.TextXAlignment = Enum.TextXAlignment.Left

-- Bounty per hour
local BPH = Instance.new("TextLabel")
BPH.Parent = Main
BPH.BackgroundTransparency = 1
BPH.Position = UDim2.new(0,10,0,75)
BPH.Size = UDim2.new(1,-20,0,20)
BPH.Font = Enum.Font.GothamBold
BPH.Text = "BPH: 0/h"
BPH.TextSize = 14
BPH.TextColor3 = Color3.fromRGB(255,200,50)
BPH.TextXAlignment = Enum.TextXAlignment.Left

-- FPS Ping
local Stats = Instance.new("TextLabel")
Stats.Parent = Main
Stats.BackgroundTransparency = 1
Stats.Position = UDim2.new(0,10,0,95)
Stats.Size = UDim2.new(1,-20,0,20)
Stats.Font = Enum.Font.Gotham
Stats.Text = "FPS: -- | PING: --"
Stats.TextSize = 13
Stats.TextColor3 = Color3.fromRGB(200,200,200)
Stats.TextXAlignment = Enum.TextXAlignment.Left
-- KILLS
local KillLabel = Instance.new("TextLabel")
KillLabel.Parent = Main
KillLabel.BackgroundTransparency = 1
KillLabel.Position = UDim2.new(0,10,0,115)
KillLabel.Size = UDim2.new(1,-20,0,20)
KillLabel.Font = Enum.Font.GothamBold
KillLabel.Text = "KILLS: 0"
KillLabel.TextSize = 14
KillLabel.TextColor3 = Color3.fromRGB(255,80,80)
KillLabel.TextXAlignment = Enum.TextXAlignment.Left

-- TIME
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Parent = Main
TimeLabel.BackgroundTransparency = 1
TimeLabel.Position = UDim2.new(0,10,0,135)
TimeLabel.Size = UDim2.new(1,-20,0,20)
TimeLabel.Font = Enum.Font.GothamBold
TimeLabel.Text = "TIME: 0m"
TimeLabel.TextSize = 14
TimeLabel.TextColor3 = Color3.fromRGB(150,200,255)
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
local function formatNumber(n)
    local s = n < 0 and "-" or ""; n = math.abs(n)
    if n >= 1000000 then return s..string.format("%.2fM", n/1000000)
    elseif n >= 1000 then return s..string.format("%.1fK", n/1000)
    else return s..tostring(n) end
end

S.RS.RenderStepped:Connect(function() FrameCount = FrameCount + 1 end)
t_spawn(function() while t_wait(1) do  CurrentFPS = FrameCount; FrameCount = 0 end end)

t_spawn(function()
    while t_wait(1) do
        local current = getRealBounty()

        pcall(function()

            if LastBounty == -1 then
                LastBounty = current
                return
            end

local gain = current - LastBounty

-- chỉ tính khi bounty tăng
if gain > 0 then

    -- giới hạn bounty hợp lệ
    if gain >= 8000 and gain <= 30000 then

        -- tránh cộng 2 lần
        if tick() - LastKillTime > 5 then

            TotalEarned = TotalEarned + gain
            HourEarned = HourEarned + gain

            SaveEarned(TotalEarned)
            SaveHour(HourEarned)

            Kills = Kills + 1
            SaveKills(Kills)

            LastKillTime = tick()

        end

    end

end

LastBounty = current

        end)

        Total.Text = "TOTAL: " .. formatNumber(current)
        Earn.Text = "EARNED: +" .. formatNumber(TotalEarned)

        local elapsed = tick() - HourStart
        if elapsed >= 3600 then
            HourEarned = 0
            HourStart = tick()
            SaveHour(0)
            SaveHourStart(HourStart)
        end

        local remain = 3600 - (tick() - HourStart)
        if remain < 0 then remain = 0 end

        local m = math.floor(remain / 60)
        local s = math.floor(remain % 60)

        BPH.Text = "BPH: " .. formatNumber(HourEarned) .. "/h | reset "..m.."m "..s.."s"

        local ping = 0
        pcall(function()
            ping = m_floor(LP:GetNetworkPing() * 1000)
        end)

        Stats.Text = string.format("FPS: %d | PING: %d ms", CurrentFPS, ping)

        local total = math.floor(PlayedTime + (tick() - SessionStart))
        local hours = math.floor(total / 3600)
        local minutes = math.floor((total % 3600) / 60)

        TimeLabel.Text = string.format("TIME: %dh %dm", hours, minutes)

        if tick() - lastSave > 10 then
            lastSave = tick()
            PlayedTime = total
SaveTime(PlayedTime)
        end

        KillLabel.Text = "KILLS: " .. Kills

    end
end)


pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then return end
        return oldNamecall(self, ...)
    end)
end)

t_spawn(function()
    pcall(function()
        S.GS.ErrorMessageChanged:Connect(function()
            t_wait(2); S.TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end)
    end)
end)

local function applyAllSmoothGraphics(v)
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
        v.CastShadow = false
        for _, descendant in ipairs(v:GetDescendants()) do
            if descendant:IsA("Decal") or descendant:IsA("Texture") then
                descendant.Transparency = 1 
            end
        end
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1 
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0,0)
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false 
    elseif v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
        v.Enabled = false 
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    end
end

t_spawn(function()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 
        S.L.GlobalShadows = false
        S.L.FogEnd = 9e9
        S.L.Brightness = 2 

        local Terrain = S.W:FindFirstChildOfClass("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end

        for _, v in ipairs(S.W:GetDescendants()) do
            pcall(applyAllSmoothGraphics, v)
        end

        S.W.DescendantAdded:Connect(function(v)
            pcall(applyAllSmoothGraphics, v)
        end)
    end)
end)

t_spawn(function()
    S.RS.RenderStepped:Connect(function()
        pcall(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health > 0 then
                local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    LP.Character.Humanoid:Move(v3_new(0, 0, -1), true)
                end
            end
        end)
    end)
end)

local function SyncBananaTarget()

-- FIX target chết
if getgenv().LockedTarget 
and getgenv().LockedTarget:FindFirstChild("Humanoid") 
and getgenv().LockedTarget.Humanoid.Health <= 0 then
    getgenv().LockedTarget = nil
    getgenv().LastAttacker = nil
end

if getgenv().LockedTarget 
and getgenv().LockedTarget:FindFirstChild("Humanoid") then
    if getgenv().LockedTarget.Humanoid.Health > 0 then
        return getgenv().LockedTarget
    end
end
    -- ưu tiên người đánh mình
    if getgenv().LastAttacker
    and getgenv().LastAttacker:FindFirstChild("Humanoid")
    and getgenv().LastAttacker.Humanoid.Health > 0 then

        if not getgenv().LastAttacker:FindFirstChild("SafeZone") then
            return getgenv().LastAttacker
        end
    end

    local best = nil
    local bestScore = math.huge

    for _,plr in pairs(S.P:GetPlayers()) do
-- nếu trước đó PvP OFF mà giờ bật PvP lại
if PvpOffList[plr.Name] and plr.Character and not plr.Character:FindFirstChild("ForceField") then
    PvpOffList[plr.Name] = nil
    return plr.Character
end
        if plr ~= LP 
        and plr.Character
        and plr.Character:FindFirstChild("HumanoidRootPart")
        and plr.Character:FindFirstChild("Humanoid")
        and plr.Character.Humanoid.Health > 0 then

            -- ❌ bỏ qua SafeZone
if plr.Character:FindFirstChild("SafeZone")
or plr.Character.HumanoidRootPart:FindFirstChild("SafeZone") then
continue
end

-- nếu PvP OFF thì lưu lại
if plr.Character:FindFirstChild("ForceField") then
    PvpOffList[plr.Name] = tick() -- lưu thời gian PvP OFF
    continue
end
-- nếu vừa tắt PvP thì chờ 10s xem có bật lại không
if PvpOffList[plr.Name] then
    if tick() - PvpOffList[plr.Name] < 10 then
        -- chờ PvP ON
        continue
    else
        -- quá 10s mới bỏ qua
        PvpOffList[plr.Name] = nil
    end
end
            local d = (LP.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            local hp = plr.Character.Humanoid.Health

            if d < 230 then

                local score = d + (hp * 0.05)

                if score < bestScore then
                    bestScore = score
                    best = plr.Character
                end

            end

        end
    end

    return best
end
local function ApplyHitbox(target)

    if not target then return end
    if not target:FindFirstChild("HumanoidRootPart") then return end

    local hrp = target.HumanoidRootPart

    local dist = (LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
local myY = LP.Character.HumanoidRootPart.Position.Y
local enemyY = hrp.Position.Y

-- bỏ target nếu bay quá cao
if enemyY - myY > 60 then
    getgenv().LockedTarget = nil
    return
end
    local size = 35

    if dist > 40 then
        size = 55
    elseif dist < 15 then
        size = 25
    end

    hrp.Size = Vector3.new(size,size,size)
    hrp.Transparency = 0.7
    hrp.CanCollide = false

end
local function SmartEquipFruit()
    if not LP.Character then return nil end
    local tip = "Blox Fruit"
    for _, v in ipairs(LP.Backpack:GetChildren()) do 
        if v:IsA("Tool") and (v.ToolTip == tip or v.Name:match(tip)) then return v end 
    end
    for _, v in ipairs(LP.Character:GetChildren()) do 
        if v:IsA("Tool") and (v.ToolTip == tip or v.Name:match(tip)) then return v end 
    end
    return nil
end
t_spawn(function()
    local tmr, last = {}, tick()
    while t_wait(0.1) do
        local now, dt = tick(), tick() - last; last = now
        pcall(function()
            local hp = LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health or 0
          local t = SyncBananaTarget()

if getgenv().LockedTarget 
and getgenv().LockedTarget:FindFirstChild("Humanoid") 
and getgenv().LockedTarget.Humanoid.Health <= 0 then
    getgenv().LockedTarget = nil
end
            if t then getgenv().LastTargetName = t.Name end
            if hp >= 7000 and getgenv().Retreating then getgenv().Retreating = false end

            if hp > 0 and hp < 4000 and not getgenv().Retreating then
                getgenv().Retreating = true
                local eName = getgenv().LastTargetName
                if eName then
                    getgenv().RetreatTracker[eName] = (getgenv().RetreatTracker[eName] or 0) + 1
                    if getgenv().RetreatTracker[eName] >= 3 then
                        Blacklist[eName] = tick()
                        local bGuy = S.P:FindFirstChild(eName)
                        if bGuy and bGuy.Character and bGuy.Character:FindFirstChild("HumanoidRootPart") then
                            pcall(function() bGuy.Character.HumanoidRootPart.CFrame = cf_new(0, 50000, 0) end)
                        end
                        getgenv().LockedTarget = nil
                        return
                    end
                end
            end

            if t and t:FindFirstChild("HumanoidRootPart") and t:FindFirstChild("Humanoid") and t.Humanoid.Health > 0 and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                if Blacklist[t.Name] and tick() - Blacklist[t.Name] < 300 then
                    getgenv().LockedTarget = nil; return
                end

                local d = (LP.Character.HumanoidRootPart.Position - t.HumanoidRootPart.Position).Magnitude
                getgenv().LockedTarget = (d <= 120 and not getgenv().Retreating) and t or nil

                if getgenv().LockedTarget == t then

    ApplyHitbox(t)

    tmr[t.Name] = (tmr[t.Name] or 0) + dt

    if tmr[t.Name] >= 3 then
        Blacklist[t.Name] = tick()
        pcall(function()
            t.HumanoidRootPart.CFrame = cf_new(0,50000,0)
        end)
        getgenv().LockedTarget = nil
        tmr[t.Name] = nil
    end

elseif not getgenv().Retreating then
    tmr[t.Name] = 0
end
            else
                getgenv().LockedTarget = nil
            end
        end)
pcall(function()
    if getgenv().LockedTarget and LP.Character and LP.Character:FindFirstChild("Humanoid") then

        local fruit = SmartEquipFruit()
        if fruit and fruit.Parent ~= LP.Character then
            LP.Character.Humanoid:EquipTool(fruit)
        end
    end
end)
    end
end)

local lastRandTick = 0
local rX,rY,rZ = 0,5,5

S.RS.Heartbeat:Connect(function()

    local target = getgenv().LockedTarget

    if not target then return end
    if not target:FindFirstChild("HumanoidRootPart") then return end
    if not LP.Character then return end

    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local enemy = target.HumanoidRootPart

    local dist = (hrp.Position - enemy.Position).Magnitude
if enemy.Position.Y - hrp.Position.Y > 60 then
    getgenv().LockedTarget = nil
    return
end
if dist < 60 then

    local now = tick()

    if now - lastRandTick > 0.15 then
        rX = math.random(-10,10)
        rY = math.random(3,8)
        rZ = math.random(-10,10)
        lastRandTick = now
    end

    local pos = enemy.Position + Vector3.new(rX,rY,rZ)

    -- chặn bay quá cao (portal v)
    if pos.Y - hrp.Position.Y > 25 then
        pos = Vector3.new(pos.X, hrp.Position.Y + 5, pos.Z)
    end

    hrp.CFrame = CFrame.new(pos)

    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)

end

end)

task.spawn(function()

    while task.wait(3) do

        pcall(function()

            if LP.Character and LP.Character:FindFirstChild("Humanoid") then

                LP.Character.Humanoid:Move(Vector3.new(0,0,-1),true)

                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

            end

        end)

    end

end)
