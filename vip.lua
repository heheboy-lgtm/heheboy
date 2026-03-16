
-- ── ANTI-KICK ──
pcall(function()
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", function(self, ...)
        local m = getnamecallmethod()
        if m == "Kick" or m == "kick" then return end
        return oldNC(self, ...)
    end)
end)

if not game:IsLoaded() then game.Loaded:Wait() end
local P_Serv = game:GetService("Players")
local LP = P_Serv.LocalPlayer or P_Serv:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- ══════════════════════════════════════════════
--  LOADING SCREEN
-- ══════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local SafeGui
pcall(function() if type(gethui)=="function" then SafeGui=gethui() end end)
if not SafeGui then pcall(function() SafeGui=game:GetService("CoreGui") end) end
if not SafeGui then SafeGui=LP:WaitForChild("PlayerGui") end

do
    local LG = Instance.new("ScreenGui")
    LG.Name="DoraLoad"; LG.ResetOnSpawn=false; LG.Parent=SafeGui

    local LF = Instance.new("Frame", LG)
    LF.Size=UDim2.new(0,310,0,158); LF.Position=UDim2.new(0.5,-155,0.5,-79)
    LF.BackgroundColor3=Color3.fromRGB(10,8,20); LF.BorderSizePixel=0
    Instance.new("UICorner",LF).CornerRadius=UDim.new(0,14)
    local _st=Instance.new("UIStroke",LF); _st.Thickness=1.5
    _st.Color=Color3.fromRGB(140,80,255)

    -- Gradient bg
    local _gr=Instance.new("UIGradient",LF)
    _gr.Color=ColorSequence.new(Color3.fromRGB(14,10,28),Color3.fromRGB(8,6,18))
    _gr.Rotation=135

    -- Accent top stripe
    local _stripe=Instance.new("Frame",LF)
    _stripe.Size=UDim2.new(1,0,0,3); _stripe.BorderSizePixel=0
    _stripe.BackgroundColor3=Color3.fromRGB(140,80,255)
    Instance.new("UICorner",_stripe).CornerRadius=UDim.new(0,14)
    local _sg=Instance.new("UIGradient",_stripe)
    _sg.Color=ColorSequence.new(Color3.fromRGB(140,80,255),Color3.fromRGB(80,180,255))
    _sg.Rotation=0

    local function mkTxt(parent,txt,size,col,font,y)
        local l=Instance.new("TextLabel",parent)
        l.Size=UDim2.new(1,-20,0,20); l.Position=UDim2.new(0,10,0,y)
        l.BackgroundTransparency=1; l.Text=txt; l.TextSize=size
        l.TextColor3=col; l.Font=font or Enum.Font.Gotham
        l.TextXAlignment=Enum.TextXAlignment.Left; return l
    end

    mkTxt(LF,"👋  Xin chào, "..LP.Name.."!",13,Color3.fromRGB(255,196,50),Enum.Font.GothamBold,14)
    mkTxt(LF,"⚡  DORA VIP",18,Color3.fromRGB(190,130,255),Enum.Font.GothamBold,36)
    mkTxt(LF,"🛡  Đang khởi động hệ thống...",12,Color3.fromRGB(100,90,140),Enum.Font.Gotham,62)

    local PBG=Instance.new("Frame",LF)
    PBG.Size=UDim2.new(1,-24,0,8); PBG.Position=UDim2.new(0,12,0,96)
    PBG.BackgroundColor3=Color3.fromRGB(25,18,45); PBG.BorderSizePixel=0
    Instance.new("UICorner",PBG).CornerRadius=UDim.new(0,4)

    local PBar=Instance.new("Frame",PBG)
    PBar.Size=UDim2.new(0,0,1,0); PBar.BackgroundColor3=Color3.fromRGB(140,80,255)
    PBar.BorderSizePixel=0; Instance.new("UICorner",PBar).CornerRadius=UDim.new(0,4)
    local _pg=Instance.new("UIGradient",PBar)
    _pg.Color=ColorSequence.new(Color3.fromRGB(140,80,255),Color3.fromRGB(80,180,255))
    _pg.Rotation=0

    local STL=mkTxt(LF,"Đang tải...",11,Color3.fromRGB(100,90,140),Enum.Font.Gotham,114)

    -- Animate
    local steps={"⚙  Khởi tạo hệ thống...","🎯  Tải target system...","🛡  Kích hoạt bảo vệ...","✅  Sẵn sàng!"}
    for i,s in ipairs(steps) do
        local tw=TweenService:Create(PBar,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
            {Size=UDim2.new(i/#steps,0,1,0)})
        tw:Play(); tw.Completed:Wait()
        STL.Text=s
        if i==#steps then STL.TextColor3=Color3.fromRGB(130,230,80) end
        task.wait(0.08)
    end
    task.wait(0.25)
    TweenService:Create(LF,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
        {BackgroundTransparency=1,Position=UDim2.new(0.5,-155,0.4,-79)}):Play()
    task.wait(0.32); LG:Destroy()
end

-- Welcome popup
task.spawn(function()
    local PG=Instance.new("ScreenGui")
    PG.Name="DoraWelcome"; PG.ResetOnSpawn=false; PG.Parent=SafeGui
    local Pop=Instance.new("Frame",PG)
    Pop.Size=UDim2.new(0,310,0,56); Pop.Position=UDim2.new(0.5,-155,0,-60)
    Pop.BackgroundColor3=Color3.fromRGB(10,8,20); Pop.BackgroundTransparency=1
    Pop.BorderSizePixel=0
    Instance.new("UICorner",Pop).CornerRadius=UDim.new(0,12)
    local _ps=Instance.new("UIStroke",Pop); _ps.Thickness=1.5
    _ps.Color=Color3.fromRGB(140,80,255)
    local T1=Instance.new("TextLabel",Pop)
    T1.Size=UDim2.new(1,0,0.5,0); T1.BackgroundTransparency=1
    T1.Text="⚡  DORA VIP đã sẵn sàng!"; T1.TextColor3=Color3.fromRGB(190,130,255)
    T1.Font=Enum.Font.GothamBold; T1.TextSize=14; T1.TextTransparency=1
    local T2=Instance.new("TextLabel",Pop)
    T2.Size=UDim2.new(1,0,0.5,0); T2.Position=UDim2.new(0,0,0.5,0)
    T2.BackgroundTransparency=1; T2.Text="👋  Chào mừng, "..LP.Name.."!"
    T2.TextColor3=Color3.fromRGB(255,196,50); T2.Font=Enum.Font.GothamBold
    T2.TextSize=12; T2.TextTransparency=1
    TweenService:Create(Pop,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-155,0,-56),BackgroundTransparency=0}):Play()
    TweenService:Create(T1,TweenInfo.new(0.4),{TextTransparency=0}):Play()
    TweenService:Create(T2,TweenInfo.new(0.4),{TextTransparency=0}):Play()
    task.wait(2.8)
    TweenService:Create(Pop,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
        {Position=UDim2.new(0.5,-155,0,-70),BackgroundTransparency=1}):Play()
    TweenService:Create(T1,TweenInfo.new(0.3),{TextTransparency=1}):Play()
    TweenService:Create(T2,TweenInfo.new(0.3),{TextTransparency=1}):Play()
    task.wait(0.35); PG:Destroy()
end)

repeat task.wait() until LP and LP.Character and LP:FindFirstChild("PlayerGui")

-- ══════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════
local S = {
    P    = P_Serv,
    W    = game:GetService("Workspace"),
    RS   = game:GetService("RunService"),
    V    = game:GetService("VirtualInputManager"),
    L    = game:GetService("Lighting"),
    GS   = game:GetService("GuiService"),
    TS   = game:GetService("TeleportService"),
    HTTP = game:GetService("HttpService"),
    CG   = game:GetService("CoreGui"),
    UIS  = game:GetService("UserInputService"),
}

local t_wait, t_spawn   = task.wait, task.spawn
local m_random, m_floor = math.random, math.floor
local v3_new, cf_new    = Vector3.new, CFrame.new

-- ══════════════════════════════════════════════
--  GLOBAL STATE
-- ══════════════════════════════════════════════
getgenv().Setting        = getgenv().Setting or {Hitbox={Enabled=true,Size=40,Transparency=0.7}}
getgenv().LockedTarget   = nil
getgenv().Retreating     = false
getgenv().RetreatTracker = getgenv().RetreatTracker or {}
getgenv().LastTargetName = nil
getgenv().LastAttacker   = nil

local Blacklist      = {}
local PvpOffList     = {}
local TargetTimer    = {}
local LockStartTime  = 0
local LastSwitchTime = 0
local LastKillTime   = 0
local FrameCount, CurrentFPS = 0, 0
local LastRespawn    = tick()

-- ══════════════════════════════════════════════
--  FILE I/O
-- ══════════════════════════════════════════════
local function SaveFile(f,v)
    pcall(function() if writefile then writefile(f,tostring(v)) end end)
end
local function LoadFile(f,d)
    local v=d or 0
    pcall(function() if isfile and readfile and isfile(f) then v=tonumber(readfile(f)) or d or 0 end end)
    return v
end
local function LoadStr(f)
    local v=""
    pcall(function() if isfile and readfile and isfile(f) then v=readfile(f) end end)
    return v
end

local FileName      = "DoraEarned_"    ..LP.UserId..".txt"
local KillFile      = "DoraKills_"     ..LP.UserId..".txt"
local HourFile      = "DoraHour_"      ..LP.UserId..".txt"
local HourStartFile = "DoraHourStart_" ..LP.UserId..".txt"
local TimeFile      = "DoraTime_"      ..LP.UserId..".txt"
local HistFile      = "DoraBphHist_"   ..LP.UserId..".txt"
local LostFile      = "DoraLost_"      ..LP.UserId..".txt"

local TotalEarned = LoadFile(FileName,0)
local HourEarned  = LoadFile(HourFile,0)
local HourStart   = LoadFile(HourStartFile,os.time())
local PlayedTime  = LoadFile(TimeFile,0)
local Kills       = LoadFile(KillFile,0)
local TotalLost   = LoadFile(LostFile,0)

if not HourStart or HourStart<=0 then HourStart=os.time() end
if os.time()-HourStart>=3600 then HourEarned=0; HourStart=os.time() end
if PlayedTime>100000 then PlayedTime=0 end
SaveFile(HourFile,HourEarned); SaveFile(HourStartFile,HourStart)

local BphHistory={}
pcall(function()
    local raw=LoadStr(HistFile)
    if raw~="" then
        for entry in raw:gmatch("([^;]+)") do
            local tt,b,k=entry:match("([^|]+)|([^|]+)|([^|]+)")
            if tt and b and k then
                table.insert(BphHistory,{time=tt,bph=tonumber(b) or 0,kills=tonumber(k) or 0})
            end
        end
    end
end)
local function SaveBphHist()
    local s=""
    for _,h in ipairs(BphHistory) do s=s..h.time.."|"..h.bph.."|"..h.kills..";" end
    SaveFile(HistFile,s)
end

local PlayedTime2  = PlayedTime
local SessionStart = os.time()
local lastSave     = tick()

local function SaveAllState()
    local now=os.time()
    PlayedTime2=PlayedTime2+(now-SessionStart); SessionStart=now
    SaveFile(FileName,TotalEarned); SaveFile(KillFile,Kills)
    SaveFile(HourFile,HourEarned); SaveFile(HourStartFile,HourStart)
    SaveFile(TimeFile,PlayedTime2); SaveFile(LostFile,TotalLost)
    SaveBphHist()
end

-- ══════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════
local function getRealBounty()
    local ls=LP:FindFirstChild("leaderstats")
    if ls then
        local b=ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty")
        if b then
            local val=tostring(b.Value):upper():gsub(",",""):gsub("%$","")
            if val:match("M") then return (tonumber(val:gsub("M","")) or 0)*1000000
            elseif val:match("K") then return (tonumber(val:gsub("K","")) or 0)*1000 end
            return tonumber(val) or 0
        end
    end
    return 0
end

local function formatNumber(n)
    local s=n<0 and "-" or ""; n=math.abs(n)
    if n>=1000000 then return s..string.format("%.1fM",n/1000000)
    elseif n>=1000 then return s..string.format("%.1fK",n/1000)
    else return s..tostring(n) end
end

-- ══════════════════════════════════════════════
--  SAFE ZONE
-- ══════════════════════════════════════════════
local SAFEZONE_TAGS={"SafeZone","safe_zone","SafeArea","safe_area","PVPOff","PvpOff"}

local function isInSafeZone(character)
    if not character then return true end
    if character:FindFirstChildOfClass("ForceField") then return true end
    for _,tag in ipairs(SAFEZONE_TAGS) do
        if character:FindFirstChild(tag) then return true end
        local hrp=character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild(tag) then return true end
    end
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Position.Y>5000 then return true end
    return false
end

local function isTargetValid(character)
    if not character then return false end
    if not character.Parent then return false end
    local hum=character:FindFirstChild("Humanoid")
    if not hum or hum.Health<=0 then return false end
    if isInSafeZone(character) then return false end
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local myChar=LP.Character
    local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myHRP then
        local dy=hrp.Position.Y-myHRP.Position.Y
        if dy>80 or dy<-100 then return false end
    end
    return true
end

local function watchSafeZone(plr)
    if not plr or not plr.Character then return end
    local char=plr.Character
    local function onAdd(child)
        if child:IsA("ForceField") or child.Name=="SafeZone"
        or child.Name=="safe_zone" or child.Name=="SafeArea" then
            if getgenv().LockedTarget==char then
                pcall(function() restoreHitbox(char) end)
                getgenv().LockedTarget=nil
            end
            PvpOffList[plr.Name]=tick()
        end
    end
    local function onRem(child)
        if child:IsA("ForceField") or child.Name=="SafeZone"
        or child.Name=="safe_zone" or child.Name=="SafeArea" then
            PvpOffList[plr.Name]=tick()
        end
    end
    char.ChildAdded:Connect(onAdd); char.ChildRemoved:Connect(onRem)
    for _,c in ipairs(char:GetChildren()) do onAdd(c) end
end

for _,plr in pairs(S.P:GetPlayers()) do
    if plr~=LP then
        pcall(watchSafeZone,plr)
        plr.CharacterAdded:Connect(function() t_wait(0.5); pcall(watchSafeZone,plr) end)
    end
end
S.P.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() t_wait(0.5); pcall(watchSafeZone,plr) end)
end)

-- ══════════════════════════════════════════════
--  HITBOX
-- ══════════════════════════════════════════════
local ORIG_HRP=Vector3.new(2,5,1)

local function applyHitbox(character)
    if not character then return end
    if not getgenv().Setting.Hitbox.Enabled then return end
    local hrp=character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local myHRP=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local dist=(myHRP.Position-hrp.Position).Magnitude
    local base=getgenv().Setting.Hitbox.Size or 40
    local size=dist>60 and math.min(base*1.6,80) or (dist<15 and math.max(base*0.75,18) or base)
    local nS=Vector3.new(size,size,size)
    if hrp.Size~=nS then hrp.Size=nS end
    local tr=getgenv().Setting.Hitbox.Transparency or 0.7
    if hrp.Transparency~=tr then hrp.Transparency=tr end
    if hrp.CanCollide then hrp.CanCollide=false end
end

local function restoreHitbox(character)
    if not character then return end
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if hrp then pcall(function() hrp.Size=ORIG_HRP; hrp.Transparency=1; hrp.CanCollide=false end) end
end

-- ══════════════════════════════════════════════
--  PREDICT
-- ══════════════════════════════════════════════
local function getPredictedPos(character)
    local hrp=character:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local vel=hrp.AssemblyLinearVelocity; local speed=vel.Magnitude
    local pred=getgenv().Setting["Aim Prediction"] or 0.5
    if speed>30 then pred=math.min(pred*(speed/20),2.5) end
    return hrp.Position+(vel*pred)
end

-- ══════════════════════════════════════════════
--  TARGET SYSTEM
-- ══════════════════════════════════════════════
local MIN_SWITCH_DELAY=6; local MAX_LOCK_TIME=25; local ENGAGE_RANGE=120

local function clearTarget()
    if getgenv().LockedTarget then restoreHitbox(getgenv().LockedTarget) end
    getgenv().LockedTarget=nil
end

local function SyncTarget()
    local now=tick()
    local myChar=LP.Character; if not myChar then return nil end
    local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end

    if getgenv().LockedTarget and not isTargetValid(getgenv().LockedTarget) then clearTarget() end
    if getgenv().LockedTarget and isTargetValid(getgenv().LockedTarget)
    and now-LastSwitchTime<MIN_SWITCH_DELAY then return getgenv().LockedTarget end
    if getgenv().LockedTarget and now-LockStartTime>MAX_LOCK_TIME then
        local oldT=getgenv().LockedTarget; clearTarget(); Blacklist[oldT.Name]=now-40
    end
    if getgenv().LastAttacker and getgenv().LastAttacker~=getgenv().LockedTarget
    and isTargetValid(getgenv().LastAttacker) and not Blacklist[getgenv().LastAttacker.Name] then
        clearTarget(); getgenv().LockedTarget=getgenv().LastAttacker
        LockStartTime=now; LastSwitchTime=now; return getgenv().LockedTarget
    end

    local best,bestScore=nil,math.huge
    for _,plr in pairs(S.P:GetPlayers()) do
        if plr==LP then continue end
        local char=plr.Character; if not char then continue end
        if isInSafeZone(char) then
            if char:FindFirstChildOfClass("ForceField") then PvpOffList[plr.Name]=now end; continue
        end
        if PvpOffList[plr.Name] then
            if now-PvpOffList[plr.Name]<8 then continue end; PvpOffList[plr.Name]=nil
        end
        if Blacklist[plr.Name] then
            local dur=(getgenv().RetreatTracker[plr.Name] or 0)>=3 and 300 or 60
            if now-Blacklist[plr.Name]<dur then continue end; Blacklist[plr.Name]=nil
        end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        local d=(myHRP.Position-hrp.Position).Magnitude
        if d>ENGAGE_RANGE then continue end
        local hpPct=hum.Health/math.max(hum.MaxHealth,1)
        local score=d*1.0+hpPct*50
        if getgenv().LockedTarget and char==getgenv().LockedTarget then score=score-80 end
        if score<bestScore then bestScore=score; best=char end
    end

    if best and best~=getgenv().LockedTarget then
        clearTarget(); getgenv().LockedTarget=best; LockStartTime=now; LastSwitchTime=now
    elseif not best and getgenv().LockedTarget then clearTarget() end
    return getgenv().LockedTarget
end

-- ══════════════════════════════════════════════
--  EQUIP FRUIT
-- ══════════════════════════════════════════════
local function SmartEquipFruit()
    if not LP.Character then return nil end
    local tip="Blox Fruit"
    for _,v in ipairs(LP.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.ToolTip==tip or v.Name:find(tip)) then return v end
    end
    for _,v in ipairs(LP.Character:GetChildren()) do
        if v:IsA("Tool") and (v.ToolTip==tip or v.Name:find(tip)) then return v end
    end
    return nil
end

-- ══════════════════════════════════════════════
--  RESPAWN
-- ══════════════════════════════════════════════
LP.CharacterAdded:Connect(function(char)
    LastRespawn=tick(); getgenv().Retreating=false
    local hum=char:WaitForChild("Humanoid",10); if not hum then return end
    hum.HealthChanged:Connect(function(newHP)
        if newHP>=hum.MaxHealth then return end
        local myHRP=char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        local closest,minDist=nil,80
        for _,plr in pairs(S.P:GetPlayers()) do
            if plr==LP then continue end
            if not plr.Character then continue end
            local hrp=plr.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            if isInSafeZone(plr.Character) then continue end
            local d=(myHRP.Position-hrp.Position).Magnitude
            if d<minDist then minDist=d; closest=plr.Character end
        end
        if closest then
            getgenv().LastAttacker=closest
            if not getgenv().LockedTarget or not isTargetValid(getgenv().LockedTarget) then
                getgenv().LockedTarget=closest; LockStartTime=tick(); LastSwitchTime=tick()
            end
        end
    end)
end)

-- ══════════════════════════════════════════════
--  COMBAT MOVEMENT
-- ══════════════════════════════════════════════
local combatRandTick=0; local combatRX,combatRY,combatRZ=0,4,0
local combatMoveTick=0; local COMBAT_MOVE_RATE=0.08

S.RS.Heartbeat:Connect(function()
    local target=getgenv().LockedTarget; if not target then return end
    if isInSafeZone(target) then clearTarget(); return end
    if not isTargetValid(target) then clearTarget(); return end
    local myChar=LP.Character; if not myChar then return end
    local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local tHRP=target:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
    local now=tick()
    if now-combatMoveTick<COMBAT_MOVE_RATE then return end
    combatMoveTick=now
    local d=(myHRP.Position-tHRP.Position).Magnitude; if d>50 then return end
    if now-combatRandTick>0.25 then
        combatRX=math.random(-4,4); combatRY=math.random(1,4); combatRZ=math.random(-4,4)
        combatRandTick=now
    end
    local predictedPos=getPredictedPos(target) or tHRP.Position
    local destY=tHRP.Position.Y+combatRY
    destY=math.min(destY,myHRP.Position.Y+12); destY=math.max(destY,myHRP.Position.Y-2)
    local dest=Vector3.new(predictedPos.X+combatRX,destY,predictedPos.Z+combatRZ)
    myHRP.CFrame=myHRP.CFrame:Lerp(CFrame.new(dest,tHRP.Position),0.55)
    myHRP.AssemblyLinearVelocity=Vector3.new(0,0,0); myHRP.AssemblyAngularVelocity=Vector3.new(0,0,0)
end)

-- ══════════════════════════════════════════════
--  MAIN COMBAT LOOP
-- ══════════════════════════════════════════════
t_spawn(function()
    local last=tick()
    while t_wait(0.12) do
        local now=tick(); local dt=now-last; last=now
        pcall(function()
            local myChar=LP.Character; if not myChar then return end
            local myHum=myChar:FindFirstChild("Humanoid"); if not myHum then return end
            local hp=myHum.Health; local t=SyncTarget()
            if hp>=7000 and getgenv().Retreating then getgenv().Retreating=false end
            if hp>0 and hp<4000 and not getgenv().Retreating then
                getgenv().Retreating=true
                local eName=getgenv().LastTargetName
                if eName then
                    getgenv().RetreatTracker[eName]=(getgenv().RetreatTracker[eName] or 0)+1
                    if getgenv().RetreatTracker[eName]>=3 then
                        Blacklist[eName]=now
                        local bGuy=S.P:FindFirstChild(eName)
                        if bGuy and bGuy.Character then
                            local bHRP=bGuy.Character:FindFirstChild("HumanoidRootPart")
                            if bHRP then pcall(function() bHRP.CFrame=cf_new(0,50000,0) end) end
                        end
                        clearTarget(); return
                    end
                end
            end
            if not t then return end
            if not isTargetValid(t) then clearTarget(); return end
            local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
            getgenv().LastTargetName=t.Name
            TargetTimer[t.Name]=(TargetTimer[t.Name] or 0)+dt
            if TargetTimer[t.Name]>=(getgenv().Setting["Target Time"] or 10) then
                Blacklist[t.Name]=now; clearTarget(); TargetTimer[t.Name]=nil; return
            end
            if getgenv().Retreating then clearTarget(); return end
            local d=(myHRP.Position-t.HumanoidRootPart.Position).Magnitude
            if d>ENGAGE_RANGE then clearTarget(); return end
            applyHitbox(t)
            local fruit=SmartEquipFruit()
            if fruit and fruit.Parent~=myChar then myHum:EquipTool(fruit) end
        end)
    end
end)

-- ══════════════════════════════════════════════
--  ANTI-IDLE
-- ══════════════════════════════════════════════
S.RS.RenderStepped:Connect(function()
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid")
        and LP.Character.Humanoid.Health>0 then
            local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then LP.Character.Humanoid:Move(v3_new(0,0,-1),true) end
        end
    end)
end)
t_spawn(function()
    while t_wait(4) do
        pcall(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid:Move(Vector3.new(0,0,-1),true)
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- ══════════════════════════════════════════════
--  GRAPHICS
-- ══════════════════════════════════════════════
local function applyGraphics(v)
    if v:IsA("BasePart") then
        v.Material=Enum.Material.SmoothPlastic; v.Reflectance=0; v.CastShadow=false
        for _,d in ipairs(v:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then d.Transparency=1 end
        end
    elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime=NumberRange.new(0,0)
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled=false
    elseif v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect")
        or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled=false
    elseif v:IsA("Explosion") then v.BlastPressure=1; v.BlastRadius=1 end
end
t_spawn(function()
    pcall(function()
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        S.L.GlobalShadows=false; S.L.FogEnd=9e9; S.L.Brightness=2
        local Terrain=S.W:FindFirstChildOfClass("Terrain")
        if Terrain then Terrain.WaterWaveSize=0; Terrain.WaterWaveSpeed=0
            Terrain.WaterReflectance=0; Terrain.WaterTransparency=0 end
        for _,v in ipairs(S.W:GetDescendants()) do pcall(applyGraphics,v) end
        S.W.DescendantAdded:Connect(function(v) pcall(applyGraphics,v) end)
    end)
end)

-- ══════════════════════════════════════════════
--  ANTI-KICK reconnect
-- ══════════════════════════════════════════════
t_spawn(function()
    pcall(function()
        S.GS.ErrorMessageChanged:Connect(function()
            t_wait(2); S.TS:TeleportToPlaceInstance(game.PlaceId,game.JobId,LP)
        end)
    end)
end)

-- ══════════════════════════════════════════════
--  FPS COUNTER
-- ══════════════════════════════════════════════
S.RS.RenderStepped:Connect(function() FrameCount=FrameCount+1 end)
t_spawn(function() while t_wait(1) do CurrentFPS=FrameCount; FrameCount=0 end end)

-- ══════════════════════════════════════════════
--  UI  — Purple-Dark Theme
-- ══════════════════════════════════════════════
pcall(function() local o=S.CG:FindFirstChild("DORA_UI"); if o then o:Destroy() end end)

local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end

-- ─────────────────────────────────────────────
--  COLOR PALETTE  (Purple × Midnight)
-- ─────────────────────────────────────────────
local C = {
    BG      = rgb(9, 7, 20),      -- nền chính
    BG2     = rgb(13,10,28),      -- nền phụ
    PANEL   = rgb(16,12,34),      -- panel card
    TOP     = rgb(7, 5, 16),      -- top bar
    BORDER  = rgb(55,35,100),     -- viền mờ
    BORDER2 = rgb(100,60,200),    -- viền sáng
    -- Accents
    PURPLE  = rgb(155,90,255),    -- chính (purple)
    PURPLE2 = rgb(30,15,60),      -- bg purple
    GOLD    = rgb(255,200,60),    -- earned
    GOLD2   = rgb(50,38,10),
    ROSE    = rgb(255,100,140),   -- hp/lost
    ROSE2   = rgb(55,12,28),
    VIOLET  = rgb(180,140,255),   -- kills
    VIO2    = rgb(30,18,60),
    TEAL    = rgb(60,220,190),    -- target/online
    TEAL2   = rgb(8,50,44),
    LIME    = rgb(120,235,80),    -- net +
    ORANGE  = rgb(255,160,50),    -- hop/warn
    -- Neutrals
    TEXT    = rgb(230,225,255),
    SUB     = rgb(140,125,195),
    DIM     = rgb(70,55,120),
    DARK    = rgb(12,9,26),
    WHITE   = rgb(255,255,255),
}

local function cr(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8) end
local function stk(p,col,tr,thick)
    local s=Instance.new("UIStroke",p); s.Color=col or C.BORDER; s.Thickness=thick or 1
    s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
end
local function grad(p,c1,c2,rot)
    local g=Instance.new("UIGradient",p); g.Color=ColorSequence.new(c1,c2); g.Rotation=rot or 90
end
local function mkF(parent,x,y,w,h,col,tr)
    local f=Instance.new("Frame"); f.Parent=parent
    f.Position=UDim2.new(x[1],x[2],y[1],y[2]); f.Size=UDim2.new(w[1],w[2],h[1],h[2])
    f.BackgroundColor3=col or C.BG; f.BackgroundTransparency=tr or 0; f.BorderSizePixel=0; return f
end
local function mkL(parent,txt,size,color,font,xa,ya)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
    l.Text=txt or ""; l.TextSize=size or 12; l.TextColor3=color or C.TEXT
    l.Font=font or Enum.Font.Gotham
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.TextYAlignment=ya or Enum.TextYAlignment.Center
    l.Size=UDim2.new(1,0,1,0); l.Parent=parent; return l
end
local function sep(parent,y)
    local f=mkF(parent,{0,12},{0,y},{1,-24},{0,1},C.BORDER2,0.5)
    grad(f,C.BORDER2,C.BG,0)
end

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="DORA_UI"; ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ScreenGui.Parent=S.CG

local UIVisible=true

-- ─────────────────────────────────────────────
--  MAIN FRAME  580 × dynamic
-- ─────────────────────────────────────────────
local Main=Instance.new("Frame"); Main.Name="Main"
Main.Size=UDim2.new(0,580,0,560); Main.Position=UDim2.new(0.5,-290,0.5,-280)
Main.BackgroundColor3=C.BG; Main.Active=true; Main.Draggable=true; Main.ClipsDescendants=false
Main.Parent=ScreenGui; Main.BorderSizePixel=0
cr(Main,18); stk(Main,C.BORDER2,0.2,1.5)
grad(Main,rgb(12,9,26),rgb(7,5,16),160)

-- ── TOP BAR  h=40 ──
local Top=mkF(Main,{0,0},{0,0},{1,0},{0,40},C.TOP,0); cr(Top,18)
mkF(Top,{0,0},{1,-1},{1,0},{0,1},C.BORDER2,0.4)
grad(Top,rgb(12,9,24),rgb(7,5,16),90)

-- Logo pulse dot
local logoDot=mkF(Top,{0,14},{0.5,-5},{0,10},{0,10},C.PURPLE,0); cr(logoDot,5)

local TitleL=mkL(Top,"⚡ DORA VIP",14,C.WHITE,Enum.Font.GothamBold)
TitleL.Size=UDim2.new(0,120,1,0); TitleL.Position=UDim2.new(0,30,0,0)

local TopInfo=mkL(Top,"-- ms  |  Players: --",11,C.SUB)
TopInfo.Size=UDim2.new(0,190,1,0); TopInfo.Position=UDim2.new(0,156,0,0)

-- BLACK SCREEN button
local BtnBlack=Instance.new("TextButton",Top)
BtnBlack.Size=UDim2.new(0,68,0,22); BtnBlack.Position=UDim2.new(1,-132,0.5,-11)
BtnBlack.BackgroundColor3=rgb(22,14,40); BtnBlack.BorderSizePixel=0
BtnBlack.Font=Enum.Font.GothamBold; BtnBlack.TextSize=9; BtnBlack.Text="⬛ BLACK"
BtnBlack.TextColor3=C.DIM; cr(BtnBlack,7); stk(BtnBlack,C.BORDER,0.4)

-- Black screen frame
local BlackBG=Instance.new("Frame",ScreenGui)
BlackBG.Size=UDim2.new(1,0,1,0); BlackBG.BackgroundColor3=Color3.fromRGB(0,0,0)
BlackBG.ZIndex=100; BlackBG.Active=true; BlackBG.BorderSizePixel=0
local isBlack=false
pcall(function() if isfile and readfile and isfile("Suc_Blackout.txt") then isBlack=readfile("Suc_Blackout.txt")=="true" end end)
BlackBG.Visible=isBlack
BtnBlack.TextColor3=isBlack and C.ROSE or C.DIM
pcall(function() S.RS:Set3dRenderingEnabled(not isBlack) end)
BtnBlack.MouseButton1Click:Connect(function()
    isBlack=not isBlack; BlackBG.Visible=isBlack
    BtnBlack.TextColor3=isBlack and C.ROSE or C.DIM
    pcall(function() S.RS:Set3dRenderingEnabled(not isBlack) end)
    pcall(function() if writefile then writefile("Suc_Blackout.txt",tostring(isBlack)) end end)
end)

local TopFPS=mkL(Top,"FPS --",10,C.DIM,Enum.Font.Code,Enum.TextXAlignment.Right)
TopFPS.Size=UDim2.new(0,52,1,0); TopFPS.Position=UDim2.new(1,-58,0,0)

-- ── PROFILE SECTION  y=50 ──
local AvF=mkF(Main,{0,14},{0,50},{0,64},{0,64},C.PANEL,0)
cr(AvF,32); stk(AvF,C.PURPLE,0.4); AvF.ClipsDescendants=true
local AvImg=Instance.new("ImageLabel",AvF)
AvImg.Size=UDim2.new(1,0,1,0); AvImg.BackgroundTransparency=1
AvImg.ScaleType=Enum.ScaleType.Crop
AvImg.Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150"; cr(AvImg,32)
local ring=mkF(Main,{0,64},{0,96},{0,14},{0,14},C.TEAL,0); cr(ring,7); stk(ring,C.BG,0,2)

local NmL=mkL(Main,LP.Name,16,C.WHITE,Enum.Font.GothamBold)
NmL.Size=UDim2.new(0,260,0,22); NmL.Position=UDim2.new(0,88,0,53)
local RoleL=mkL(Main,"⚡ AUTO FARM  ●  ACTIVE",10,C.PURPLE)
RoleL.Size=UDim2.new(0,260,0,16); RoleL.Position=UDim2.new(0,88,0,77)

local function mkPill(y,icon,lbl,col)
    local ll=mkL(Main,icon.." "..lbl,8,C.DIM); ll.Size=UDim2.new(0,70,0,14); ll.Position=UDim2.new(0,88,0,y)
    local vl=mkL(Main,"--",12,col,Enum.Font.Code,Enum.TextXAlignment.Right)
    vl.Size=UDim2.new(0,150,0,14); vl.Position=UDim2.new(0,88,0,y); return vl
end
local function mkPill2(y,icon,lbl,col)
    local ll=mkL(Main,icon.." "..lbl,8,C.DIM); ll.Size=UDim2.new(0,70,0,14); ll.Position=UDim2.new(0,248,0,y)
    local vl=mkL(Main,"--",12,col,Enum.Font.Code,Enum.TextXAlignment.Right)
    vl.Size=UDim2.new(0,140,0,14); vl.Position=UDim2.new(0,248,0,y); return vl
end
local iBounty = mkPill(96,  "💰","Bounty", C.GOLD)
local iHP     = mkPill(110, "❤","HP",      C.ROSE)
local iLost   = mkPill2(96, "💸","Mất",    C.ROSE)
local iNet    = mkPill2(110,"📊","Net",    C.LIME)

sep(Main,126)

-- ── 4 CARDS  y=134 ──
local CW,CH=173,92; local CX1=14; local CX2=CX1+CW+8; local CX3=CX2+CW+8
local CY1=134; local CY2c=CY1+CH+8

local function mkCard(cx,cy,bg1,bg2,ac,icon,title,sub)
    local f=mkF(Main,{0,cx},{0,cy},{0,CW},{0,CH},bg1,0)
    cr(f,14); stk(f,ac,0.5); grad(f,bg1,bg2,145)
    local stripe=mkF(f,{0,0},{0,0},{1,0},{0,3},ac,0.25); cr(stripe,14)
    grad(stripe,ac,rgb(0,0,0),0)
    local ibg=mkF(f,{0,10},{0,12},{0,38},{0,38},ac,0.8); cr(ibg,19)
    mkL(ibg,icon,20,C.WHITE,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
    local tl=mkL(f,title,9,ac,Enum.Font.GothamBold)
    tl.Size=UDim2.new(1,-58,0,14); tl.Position=UDim2.new(0,54,0,10)
    local vl=mkL(f,"0",26,C.WHITE,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
    vl.Size=UDim2.new(1,-4,0,36); vl.Position=UDim2.new(0,2,0,38)
    local sl=mkL(f,sub,9,C.DIM,Enum.Font.Gotham,Enum.TextXAlignment.Center)
    sl.Size=UDim2.new(1,-4,0,14); sl.Position=UDim2.new(0,2,0,76)
    return vl,sl
end

local cEarned,cEarnedS = mkCard(CX1,CY1, rgb(18,10,8), rgb(10,6,4),   C.GOLD,   "💰","BOUNTY EARNED","session total")
local cTime,  cTimeS   = mkCard(CX2,CY1, rgb(10,8,28), rgb(6,5,18),   C.PURPLE, "⏱","TIME ELAPSED", "played time")
local cKills, cKillsS  = mkCard(CX1,CY2c,rgb(20,10,36),rgb(12,6,22),  C.VIOLET, "☠","TOTAL KILLS",  "this session")
local cTarget,cTargetS = mkCard(CX2,CY2c,rgb(8,28,24), rgb(5,18,16),  C.TEAL,   "🎯","TARGET",       "health: --")
cTarget.TextSize=12; cEarned.TextSize=22; cTime.TextSize=16

-- ── RIGHT PANEL (PLAYER INFO) ──
local rPanel=mkF(Main,{0,CX3},{0,CY1},{0,CW},{0,CH*2+8},rgb(14,10,30),0)
cr(rPanel,14); stk(rPanel,C.BORDER2,0.55); grad(rPanel,rgb(16,12,34),rgb(10,7,22),140)

-- Header với RESET button
local rHL=mkL(rPanel,"📋  PLAYER INFO",9,C.DIM,Enum.Font.GothamBold)
rHL.Size=UDim2.new(1,-52,0,16); rHL.Position=UDim2.new(0,10,0,6)

local ResetBtn=Instance.new("TextButton",rPanel)
ResetBtn.Size=UDim2.new(0,40,0,16); ResetBtn.Position=UDim2.new(1,-44,0,5)
ResetBtn.BackgroundColor3=rgb(45,12,22); ResetBtn.BorderSizePixel=0
ResetBtn.Font=Enum.Font.GothamBold; ResetBtn.TextSize=9
ResetBtn.TextColor3=C.ROSE; ResetBtn.Text="↺ RST"
cr(ResetBtn,5); stk(ResetBtn,C.ROSE,0.5)

local ResetConfirm=false
ResetBtn.MouseButton1Click:Connect(function()
    if not ResetConfirm then
        ResetConfirm=true; ResetBtn.Text="Sure?"; ResetBtn.BackgroundColor3=rgb(80,20,30)
        task.delay(2, function() ResetConfirm=false; pcall(function() ResetBtn.Text="↺ RST"; ResetBtn.BackgroundColor3=rgb(45,12,22) end) end)
    else
        ResetConfirm=false
        TotalEarned=0; HourEarned=0; Kills=0; TotalLost=0
        PlayedTime2=0; SessionStart=os.time()
        SaveFile(FileName,0); SaveFile(KillFile,0); SaveFile(HourFile,0)
        SaveFile(LostFile,0); SaveFile(TimeFile,0)
        BphHistory={}; SaveBphHist(); refreshHist()
        ResetBtn.Text="↺ RST"; ResetBtn.BackgroundColor3=rgb(45,12,22)
    end
end)

mkF(rPanel,{0,8},{0,25},{1,-16},{0,1},C.BORDER,0.6)

local function mkRRow(yy,icon,lbl,col)
    local l=mkL(rPanel,icon.." "..lbl,9,C.DIM); l.Size=UDim2.new(0,90,0,18); l.Position=UDim2.new(0,8,0,yy)
    local v=mkL(rPanel,"--",13,col,Enum.Font.Code,Enum.TextXAlignment.Right)
    v.Size=UDim2.new(1,-12,0,18); v.Position=UDim2.new(0,0,0,yy); return v
end
local rBounty = mkRRow(29,  "💰","Bounty",  C.GOLD)
local rHP     = mkRRow(50,  "❤","HP",       C.ROSE)
local rLost   = mkRRow(71,  "💸","Mất",     C.ROSE)
local rNet    = mkRRow(92,  "📊","Net",     C.LIME)
local rBPH    = mkRRow(113, "📈","BPH",     C.GOLD)
local rKills  = mkRRow(134, "☠","Kills/h",  C.VIOLET)
mkF(rPanel,{0,8},{0,155},{1,-16},{0,1},C.BORDER,0.6)
local rPing   = mkRRow(160, "📡","Ping",    C.PURPLE)

sep(Main,336)

-- ── AUTO HOP BAR  y=340 ──
local HopBar=mkF(Main,{0,14},{0,340},{1,-28},{0,36},rgb(12,8,26),0)
cr(HopBar,10); stk(HopBar,C.BORDER,0.5); grad(HopBar,rgb(14,10,30),rgb(9,6,20),90)
local HopIcon=mkL(HopBar,"⟳",13,C.PURPLE,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
HopIcon.Size=UDim2.new(0,22,1,0); HopIcon.Position=UDim2.new(0,8,0,0)
local HopTimerL=mkL(HopBar,"⏳  Auto Hop: 10:00",11,C.PURPLE,Enum.Font.GothamBold)
HopTimerL.Size=UDim2.new(0,170,1,0); HopTimerL.Position=UDim2.new(0,32,0,0)

local StatusBadge=Instance.new("TextButton",HopBar)
StatusBadge.Size=UDim2.new(0,120,0,22); StatusBadge.Position=UDim2.new(1,-124,0.5,-11)
StatusBadge.BackgroundColor3=C.DARK; StatusBadge.Font=Enum.Font.GothamBold
StatusBadge.TextSize=9; StatusBadge.TextColor3=C.DIM; StatusBadge.Text="● NO TARGET"
StatusBadge.BorderSizePixel=0; cr(StatusBadge,8); stk(StatusBadge,C.BORDER,0.4)
StatusBadge.MouseButton1Click:Connect(function() if not isHopping then doHop() end end)

local HopProgBG=mkF(Main,{0,14},{0,378},{1,-28},{0,4},C.DARK,0)
cr(HopProgBG,2); stk(HopProgBG,C.BORDER,0.8)
local HopProgFill=mkF(HopProgBG,{0,0},{0,0},{0,0},{1,0},C.PURPLE,0)
cr(HopProgFill,2); grad(HopProgFill,C.PURPLE,rgb(100,60,200),0)

-- ── BPH BAR  y=386 ──
local BphLbl=mkL(Main,"📈  BPH: 0/h",13,C.GOLD,Enum.Font.GothamBold)
BphLbl.Size=UDim2.new(0,130,0,28); BphLbl.Position=UDim2.new(0,14,0,384)
local BphRst=mkL(Main,"reset 60m 00s",10,C.SUB)
BphRst.Size=UDim2.new(0,130,0,28); BphRst.Position=UDim2.new(0,148,0,384)
local BphBG=mkF(Main,{0,14},{0,414},{1,-28},{0,5},C.DARK,0)
cr(BphBG,3); stk(BphBG,C.BORDER,0.75)
local BphFill=mkF(BphBG,{0,0},{0,0},{0,0},{1,0},C.GOLD,0)
cr(BphFill,3); grad(BphFill,C.GOLD,rgb(255,140,20),0)

sep(Main,426)

-- ── BPH HISTORY  y=430 ──
local _bhl=mkL(Main,"📈  BPH HISTORY",10,C.DIM,Enum.Font.GothamBold)
_bhl.Size=UDim2.new(1,-28,0,16); _bhl.Position=UDim2.new(0,14,0,432)
local HistEmpty=mkL(Main,"Chua co du lieu...",10,C.DIM,Enum.Font.Gotham,Enum.TextXAlignment.Center)
HistEmpty.Size=UDim2.new(1,-28,0,16); HistEmpty.Position=UDim2.new(0,14,0,452)

local histRows={}
for i=1,5 do
    local yy=452+(i-1)*26
    local row=mkF(Main,{0,14},{0,yy},{1,-28},{0,22},C.PANEL,0.05)
    cr(row,6); stk(row,C.BORDER,0.7); row.Visible=false
    local rp=Instance.new("UIPadding",row)
    rp.PaddingLeft=UDim.new(0,10); rp.PaddingRight=UDim.new(0,10)
    local tL=mkL(row,"--:--",10,C.DIM,Enum.Font.Code); tL.Size=UDim2.new(0,42,1,0)
    local vL=mkL(row,"0/h",11,C.GOLD,Enum.Font.Code)
    vL.Size=UDim2.new(0,90,1,0); vL.Position=UDim2.new(0,44,0,0)
    local kL=mkL(row,"0 kills",10,C.SUB,Enum.Font.Gotham,Enum.TextXAlignment.Right)
    kL.Size=UDim2.new(0,80,1,0); kL.Position=UDim2.new(1,-80,0,0)
    histRows[i]={f=row,t=tL,v=vL,k=kL}
end

local function refreshHist()
    local any=#BphHistory>0; HistEmpty.Visible=not any
    for i=1,5 do
        local h=BphHistory[i]
        if h then
            histRows[i].f.Visible=true; histRows[i].t.Text=h.time
            histRows[i].v.Text=formatNumber(h.bph).."/h"
            histRows[i].k.Text=tostring(h.kills).." kills"
        else histRows[i].f.Visible=false end
    end
    local histH=any and (4+math.min(#BphHistory,5)*26) or 20
    Main.Size=UDim2.new(0,580,0,452+histH+28)
end
refreshHist()

-- ── FOOTER ──
local FooterL=mkL(Main,"FPS: --  |  PING: -- ms",10,C.DIM,Enum.Font.Code)
FooterL.Size=UDim2.new(0,200,0,22); FooterL.Position=UDim2.new(0,14,1,-24)
local HintL=mkL(Main,"[RSHIFT] hide",10,C.DIM,Enum.Font.Gotham,Enum.TextXAlignment.Right)
HintL.Size=UDim2.new(0,76,0,22); HintL.Position=UDim2.new(1,-82,1,-24)
mkF(Main,{0,14},{1,-28},{1,-28},{0,1},C.BORDER,0.6)

-- ── MINI BAR ──
local Mini=Instance.new("Frame",ScreenGui)
Mini.Size=UDim2.new(0,200,0,34); Mini.Position=UDim2.new(0.5,-100,0,8)
Mini.BackgroundColor3=C.BG2; Mini.Active=true; Mini.Draggable=true; Mini.Visible=false
Mini.BorderSizePixel=0; cr(Mini,17); stk(Mini,C.BORDER2,0.3)
grad(Mini,rgb(14,10,28),rgb(8,6,18),90)
local _md=mkF(Mini,{0,11},{0.5,-5},{0,10},{0,10},C.PURPLE,0); cr(_md,5)
local MName=mkL(Mini,"⚡ DORA VIP",12,C.WHITE,Enum.Font.GothamBold)
MName.Size=UDim2.new(0,100,1,0); MName.Position=UDim2.new(0,27,0,0)
local MOpen=Instance.new("TextButton",Mini)
MOpen.Size=UDim2.new(0,58,0,22); MOpen.Position=UDim2.new(1,-62,0.5,-11)
MOpen.BackgroundColor3=C.DARK; MOpen.Font=Enum.Font.GothamBold
MOpen.TextSize=10; MOpen.TextColor3=C.SUB; MOpen.Text="▲ Open"
MOpen.BorderSizePixel=0; cr(MOpen,8); stk(MOpen,C.BORDER,0.5)
MOpen.MouseButton1Click:Connect(function() UIVisible=true; Main.Visible=true; Mini.Visible=false end)

-- RightShift toggle (không bị game chặn)
S.UIS.InputBegan:Connect(function(inp,gp)
    if inp.UserInputType==Enum.UserInputType.Keyboard
    and inp.KeyCode==Enum.KeyCode.RightShift then
        UIVisible=not UIVisible; Main.Visible=UIVisible; Mini.Visible=not UIVisible
    end
end)

-- ══════════════════════════════════════════════
--  AUTO HOP
-- ══════════════════════════════════════════════
local HOP_INTERVAL=10*60; local HOP_MIN_PLAYERS=10
local autoHopStart=tick(); local isHopping=false

local function doHop()
    if isHopping then return end; isHopping=true
    SaveAllState()
    HopTimerL.Text="⏳  Đang tìm server..."
    HopTimerL.TextColor3=C.ORANGE; HopIcon.TextColor3=C.ORANGE
    t_spawn(function()
        pcall(function()
            local placeId=game.PlaceId; local best=nil; local bestPlayers=0; local cursor=""
            for _=1,5 do
                local ok,res=pcall(function()
                    return S.HTTP:JSONDecode(game:HttpGet(
                        "https://games.roblox.com/v1/games/"..placeId..
                        "/servers/Public?sortOrder=Desc&limit=25&cursor="..cursor))
                end)
                if ok and res and res.data then
                    for _,sv in ipairs(res.data) do
                        if sv.id~=game.JobId and sv.playing>=HOP_MIN_PLAYERS
                        and sv.playing<sv.maxPlayers and sv.playing>bestPlayers then
                            bestPlayers=sv.playing; best=sv.id
                        end
                    end
                    cursor=res.nextPageCursor or ""
                    if cursor=="" or best then break end
                end
            end
            HopTimerL.Text=best and ("→ sv "..bestPlayers.." người") or "→ random sv"
            t_wait(1.5)
            if best then S.TS:TeleportToPlaceInstance(placeId,best,LP)
            else S.TS:Teleport(placeId,LP) end
        end)
        t_wait(5); autoHopStart=tick(); isHopping=false
        HopTimerL.TextColor3=C.PURPLE; HopIcon.TextColor3=C.PURPLE
    end)
end

-- ══════════════════════════════════════════════
--  BOUNTY TRACKING
-- ══════════════════════════════════════════════
local LastBounty=-1; local LastDeathBounty=-1

local function doHourReset()
    local ts=os.time(); local hh=m_floor((ts%(86400))/3600); local mm=m_floor((ts%3600)/60)
    local tstr=string.format("%02d:%02d",hh,mm)
    table.insert(BphHistory,1,{time=tstr,bph=HourEarned,kills=Kills})
    if #BphHistory>5 then table.remove(BphHistory,#BphHistory) end
    SaveBphHist(); refreshHist()
    HourEarned=0; HourStart=os.time()
    SaveFile(HourFile,0); SaveFile(HourStartFile,HourStart)
end

LP.CharacterAdded:Connect(function(char)
    if LastDeathBounty>0 then
        t_spawn(function()
            t_wait(3)
            local newBounty=getRealBounty()
            if newBounty<LastDeathBounty then
                local lost=LastDeathBounty-newBounty
                if lost>=1000 and lost<=200000 then TotalLost=TotalLost+lost; SaveFile(LostFile,TotalLost) end
            end
            LastDeathBounty=-1
        end)
    end
end)

t_spawn(function()
    while t_wait(1) do
        local current=getRealBounty(); local net=TotalEarned-TotalLost

        pcall(function()
            if LastBounty==-1 then LastBounty=current; return end
            local gain=current-LastBounty
            if gain>0 and gain>=8000 and gain<=30000 then
                if tick()-LastKillTime>8 then
                    TotalEarned=TotalEarned+gain; HourEarned=HourEarned+gain
                    SaveFile(FileName,TotalEarned); SaveFile(HourFile,HourEarned)
                    Kills=Kills+1; SaveFile(KillFile,Kills); LastKillTime=tick()
                end
            elseif gain<0 then LastDeathBounty=LastBounty end
            LastBounty=current
        end)

        -- 4 CARDS
        cEarned.Text=formatNumber(TotalEarned)
        cKills.Text=tostring(Kills)
        local total=m_floor(PlayedTime2)+(os.time()-SessionStart)
        cTime.Text=string.format("%dH %dM",m_floor(total/3600),m_floor((total%3600)/60))

        -- TARGET CARD
        local tgt=getgenv().LockedTarget
        if tgt and tgt.Parent and isTargetValid(tgt) then
            local h=tgt:FindFirstChild("Humanoid")
            local hp2=h and h.Health or 0; local mhp2=h and h.MaxHealth or 1
            local pct=m_floor(hp2/math.max(mhp2,1)*100)
            cTarget.Text=tgt.Name:sub(1,11)
            cTargetS.Text="HP "..pct.."% · "..m_floor(hp2)
            cTargetS.TextColor3=pct<30 and C.ROSE or C.TEAL
            StatusBadge.Text=getgenv().Retreating and "⚠  RETREAT" or "●  LOCKED"
            StatusBadge.TextColor3=getgenv().Retreating and C.ROSE or C.TEAL
        else
            if getgenv().LockedTarget and
               (not getgenv().LockedTarget.Parent or not isTargetValid(getgenv().LockedTarget)) then
                pcall(function() restoreHitbox(getgenv().LockedTarget) end); getgenv().LockedTarget=nil
            end
            cTarget.Text="No Target"; cTargetS.Text="health: --"; cTargetS.TextColor3=C.DIM
            StatusBadge.Text=getgenv().Retreating and "⚠  RETREAT" or "● TAP TO HOP"
            StatusBadge.TextColor3=getgenv().Retreating and C.ROSE or C.DIM
        end

        -- PROFILE PILLS
        local hp,mhp=0,0
        pcall(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                hp=LP.Character.Humanoid.Health; mhp=LP.Character.Humanoid.MaxHealth
            end
        end)
        iBounty.Text=formatNumber(current)
        iHP.Text=(mhp>0 and m_floor(hp/mhp*100) or 0).."%"
        iLost.Text=formatNumber(TotalLost)
        net=TotalEarned-TotalLost; iNet.Text=formatNumber(net)
        iNet.TextColor3=net>=0 and C.LIME or C.ROSE

        -- RIGHT PANEL
        rBounty.Text=formatNumber(current); rHP.Text=(mhp>0 and m_floor(hp/mhp*100) or 0).."%"
        rLost.Text=formatNumber(TotalLost); rNet.Text=formatNumber(net); rNet.TextColor3=net>=0 and C.LIME or C.ROSE
        local elapsed2=math.max(1,os.time()-HourStart)
        local bphRate=m_floor(HourEarned/(elapsed2/3600))
        rBPH.Text=formatNumber(bphRate).."/h"
        local sessH=math.max(0.01,(os.time()-SessionStart)/3600)
        rKills.Text=string.format("%.1f/h",Kills/sessH)
        local ping=0; pcall(function() ping=m_floor(LP:GetNetworkPing()*1000) end)
        rPing.Text=ping.."ms"

        -- BPH BAR
        if os.time()-HourStart>=3600 then doHourReset() end
        local remain=math.max(0,3600-(os.time()-HourStart))
        local rm,rs=m_floor(remain/60),m_floor(remain%60)
        BphLbl.Text="📈  BPH: "..formatNumber(HourEarned).."/h"
        BphRst.Text="reset "..rm.."m "..(rs<10 and "0" or "")..rs.."s"
        BphFill.Size=UDim2.new((3600-remain)/3600,0,1,0)

        -- HOP TIMER
        local hopElapsed=tick()-autoHopStart; local hopRemain=math.max(0,HOP_INTERVAL-hopElapsed)
        local hrm=m_floor(hopRemain/60); local hrs=m_floor(hopRemain%60)
        if not isHopping then
            HopTimerL.Text=string.format("⏳  Auto Hop: %02d:%02d",hrm,hrs)
            HopProgFill.Size=UDim2.new(math.min(hopElapsed/HOP_INTERVAL,1),0,1,0)
            local hopCol=hopRemain<60 and C.ORANGE or C.PURPLE
            HopTimerL.TextColor3=hopCol; HopIcon.TextColor3=hopCol
        end
        if hopRemain<=0 and not isHopping then doHop() end

        -- TOPBAR / FOOTER
        local srv=#S.P:GetPlayers()
        TopInfo.Text=ping.."ms  |  Players: "..srv
        TopFPS.Text="FPS "..CurrentFPS
        FooterL.Text="FPS: "..CurrentFPS.."  |  PING: "..ping.." ms"

        -- AUTO SAVE
        if tick()-lastSave>30 then
            lastSave=tick(); PlayedTime2=PlayedTime2+(os.time()-SessionStart); SessionStart=os.time()
            SaveFile(TimeFile,PlayedTime2)
        end
    end
end)
