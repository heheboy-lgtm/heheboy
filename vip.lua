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
repeat task.wait() until LP and LP.Character and LP:FindFirstChild("PlayerGui")

local TweenService = game:GetService("TweenService")
local SafeGui
pcall(function() if type(gethui)=="function" then SafeGui=gethui() end end)
if not SafeGui then pcall(function() SafeGui=game:GetService("CoreGui") end) end
if not SafeGui then SafeGui=LP:WaitForChild("PlayerGui") end

-- ══════════════════════════════════════════════
--  LOADING SCREEN
-- ══════════════════════════════════════════════
local DoraLoadDone = false
task.spawn(function()
    local LG=Instance.new("ScreenGui"); LG.Name="DoraLoad"; LG.ResetOnSpawn=false; LG.Parent=SafeGui
    local Dim=Instance.new("Frame",LG); Dim.Size=UDim2.new(1,0,1,0)
    Dim.BackgroundColor3=Color3.fromRGB(0,0,0); Dim.BackgroundTransparency=0.5; Dim.BorderSizePixel=0
    local LF=Instance.new("Frame",LG)
    LF.Size=UDim2.new(0,300,0,148); LF.Position=UDim2.new(0.5,-150,0.6,-74)
    LF.BackgroundColor3=Color3.fromRGB(22,24,34); LF.BorderSizePixel=0; LF.BackgroundTransparency=1
    Instance.new("UICorner",LF).CornerRadius=UDim.new(0,14)
    local _st=Instance.new("UIStroke",LF); _st.Thickness=1.2; _st.Color=Color3.fromRGB(75,82,115); _st.Transparency=0.2
    local function mT(p,t,s,c,y)
        local l=Instance.new("TextLabel",p); l.Size=UDim2.new(1,-18,0,18); l.Position=UDim2.new(0,10,0,y)
        l.BackgroundTransparency=1; l.Text=t; l.TextSize=s; l.TextColor3=c
        l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left; return l
    end
    mT(LF,"DORA VIP",17,Color3.fromRGB(50,210,190),14)
    mT(LF,"Xin Chào, "..LP.Name.."!",11,Color3.fromRGB(255,200,55),36)
    local STL=mT(LF,"Đang tải...",10,Color3.fromRGB(80,88,120),60)
    local PBG=Instance.new("Frame",LF); PBG.Size=UDim2.new(1,-22,0,4); PBG.Position=UDim2.new(0,11,0,84)
    PBG.BackgroundColor3=Color3.fromRGB(30,32,44); PBG.BorderSizePixel=0
    Instance.new("UICorner",PBG).CornerRadius=UDim.new(0,2)
    local PBar=Instance.new("Frame",PBG); PBar.Size=UDim2.new(0,0,1,0)
    PBar.BackgroundColor3=Color3.fromRGB(50,210,190); PBar.BorderSizePixel=0
    Instance.new("UICorner",PBar).CornerRadius=UDim.new(0,2)
    TweenService:Create(LF,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-150,0.5,-74),BackgroundTransparency=0}):Play()
    task.wait(0.35)
    local steps={"Khởi tạo...","Target system...","Bảo vệ...","Sẵn sàng!"}
    for i,s in ipairs(steps) do
        TweenService:Create(PBar,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
            {Size=UDim2.new(i/#steps,0,1,0)}):Play()
        STL.Text=s; task.wait(0.2)
    end
    task.wait(0.3)
    TweenService:Create(LF,TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
        {BackgroundTransparency=1,Position=UDim2.new(0.5,-150,0.42,-74)}):Play()
    TweenService:Create(Dim,TweenInfo.new(0.28),{BackgroundTransparency=1}):Play()
    task.wait(0.32); LG:Destroy(); DoraLoadDone=true
end)

repeat task.wait(0.05) until DoraLoadDone

-- ══════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════
local S={
    P=P_Serv, W=game:GetService("Workspace"), RS=game:GetService("RunService"),
    V=game:GetService("VirtualInputManager"), L=game:GetService("Lighting"),
    GS=game:GetService("GuiService"), TS=game:GetService("TeleportService"),
    HTTP=game:GetService("HttpService"), CG=game:GetService("CoreGui"),
    UIS=game:GetService("UserInputService"),
}
local t_wait,t_spawn = task.wait,task.spawn
local m_random,m_floor = math.random,math.floor
local v3_new,cf_new = Vector3.new,CFrame.new

-- ══════════════════════════════════════════════
--  GLOBAL STATE
-- ══════════════════════════════════════════════
getgenv().LockedTarget   = nil
getgenv().Retreating     = false
getgenv().RetreatTracker = getgenv().RetreatTracker or {}
getgenv().LastTargetName = nil
local Blacklist = {}
local PatrolPoints = {
    { name="Candy Island Center",   pos=Vector3.new(-2490, 18, -4100) },
    { name="Candy Island East",     pos=Vector3.new(-2150, 18, -4050) },
    { name="Candy Island West",     pos=Vector3.new(-2780, 18, -4200) },
    { name="Floating Turtle",       pos=Vector3.new(-2200, 22, -5200) },
    { name="Hydra Island",          pos=Vector3.new(-3800, 22, -4800) },
    { name="Mansion Island",        pos=Vector3.new(-1400, 22, -3900) },
}
local PatrolIndex   = 1
local LastPatrol    = 0
local PATROL_WAIT   = 25  -- giây không có target thì teleport đảo kế tiếp

local NoTargetTime  = 0   -- đếm giây không có target
local NO_TARGET_HOP = 120 -- sau 120s không target → hop sv mới (thay vì đợi 10 phút)
local FrameCount,CurrentFPS = 0,0

-- ══════════════════════════════════════════════
--  FILE I/O
-- ══════════════════════════════════════════════
local function SaveFile(f,v) pcall(function() if writefile then writefile(f,tostring(v)) end end) end
local function LoadFile(f,d)
    local v=d or 0
    pcall(function() if isfile and readfile and isfile(f) then v=tonumber(readfile(f)) or d or 0 end end)
    return v
end
local function LoadStr(f)
    local v="" pcall(function() if isfile and readfile and isfile(f) then v=readfile(f) end end); return v
end
local FileName="DoraEarned_"..LP.UserId..".txt"; local KillFile="DoraKills_"..LP.UserId..".txt"
local HourFile="DoraHour_"..LP.UserId..".txt"; local HourStartFile="DoraHourStart_"..LP.UserId..".txt"
local TimeFile="DoraTime_"..LP.UserId..".txt"; local HistFile="DoraBphHist_"..LP.UserId..".txt"
local LostFile="DoraLost_"..LP.UserId..".txt"
local TotalEarned=LoadFile(FileName,0); local HourEarned=LoadFile(HourFile,0)
local HourStart=LoadFile(HourStartFile,os.time()); local PlayedTime=LoadFile(TimeFile,0)
local Kills=LoadFile(KillFile,0); local TotalLost=LoadFile(LostFile,0)
if not HourStart or HourStart<=0 then HourStart=os.time() end
if os.time()-HourStart>=3600 then HourEarned=0; HourStart=os.time() end
if PlayedTime>100000 then PlayedTime=0 end
SaveFile(HourFile,HourEarned); SaveFile(HourStartFile,HourStart)
local BphHistory={}
pcall(function()
    local raw=LoadStr(HistFile); if raw=="" then return end
    for entry in raw:gmatch("([^;]+)") do
        local tt,b,k=entry:match("([^|]+)|([^|]+)|([^|]+)")
        if tt and b and k then table.insert(BphHistory,{time=tt,bph=tonumber(b) or 0,kills=tonumber(k) or 0}) end
    end
end)
local function SaveBphHist()
    local s="" for _,h in ipairs(BphHistory) do s=s..h.time.."|"..h.bph.."|"..h.kills..";" end
    SaveFile(HistFile,s)
end
local PlayedTime2=PlayedTime; local SessionStart=os.time(); local lastSave=tick()
local LastKillTime=0
local function SaveAllState()
    local now=os.time(); PlayedTime2=PlayedTime2+(now-SessionStart); SessionStart=now
    SaveFile(FileName,TotalEarned); SaveFile(KillFile,Kills); SaveFile(HourFile,HourEarned)
    SaveFile(HourStartFile,HourStart); SaveFile(TimeFile,PlayedTime2); SaveFile(LostFile,TotalLost); SaveBphHist()
end

-- ══════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════
local function getRealBounty()
    local ls=LP:FindFirstChild("leaderstats"); if not ls then return 0 end
    local b=ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor"); if not b then return 0 end
    local val=tostring(b.Value):upper():gsub(",",""):gsub("%$","")
    if val:match("M") then return (tonumber(val:gsub("M","")) or 0)*1000000
    elseif val:match("K") then return (tonumber(val:gsub("K","")) or 0)*1000 end
    return tonumber(val) or 0
end
local function formatNumber(n)
    local s=n<0 and "-" or ""; n=math.abs(n)
    if n>=1000000 then return s..string.format("%.2fM",n/1000000)
    elseif n>=1000 then return s..string.format("%.1fK",n/1000) end
    return s..tostring(n)
end

-- ══════════════════════════════════════════════
--  HITBOX
-- ══════════════════════════════════════════════
local ORIG_HRP=Vector3.new(2,5,1)
local function applyHitbox(character)
    if not character then return end
    local st=getgenv().Setting; if not st or not st.Hitbox or not st.Hitbox.Enabled then return end
    local hrp=character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local sz=st.Hitbox.Size or 60
    if hrp.Size.X~=sz then
        hrp.Size=v3_new(sz,sz,sz)
        hrp.Transparency=st.Hitbox.Transparency or 0.7
        hrp.CanCollide=false
    end
end
local function restoreHitbox(character)
    if not character then return end
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if hrp then pcall(function() hrp.Size=ORIG_HRP; hrp.Transparency=1; hrp.CanCollide=false end) end
end

-- ══════════════════════════════════════════════
--  TARGET SYSTEM — CHI BANANA
-- ══════════════════════════════════════════════
local bLabel=nil; local lastUISearch=0
local TargetTimerRaw={}

local function getBananaChar()
    if bLabel and bLabel.Parent then
        local txt=bLabel.Text
        if txt then
            local n=txt:match("Target %([%s]*([%w_]+)")
            if n then
                local p=S.P:FindFirstChild(n)
                return p and p.Character or nil
            end
        end
        bLabel=nil
    end
    local now=tick()
    if now-lastUISearch<0.3 then return nil end
    lastUISearch=now
    for _,v in ipairs(S.CG:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text and v.Text:find("Target %(") then
            bLabel=v; break
        end
    end
    if not bLabel then
        for _,v in ipairs(LP.PlayerGui:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text and v.Text:find("Target %(") then
                bLabel=v; break
            end
        end
    end
    return nil
end

local function isCharAlive(char)
    if not char or not char.Parent then return false end
    local hum=char:FindFirstChild("Humanoid"); if not hum or hum.Health<=0 then return false end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
    if hrp.Position.Y > 3000 then return false end
    local myChar=LP.Character
    local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myHRP then
        local dy=math.abs(hrp.Position.Y - myHRP.Position.Y)
        if dy > 150 then return false end
    end
    return true
end

local function SyncTarget(dt)
    local now = tick()
    local bananaChar = getBananaChar()

    if not bananaChar or not isCharAlive(bananaChar) then
        if getgenv().LockedTarget then
            restoreHitbox(getgenv().LockedTarget)
            getgenv().LockedTarget = nil
        end
        return nil
    end

    -- 🚫 blacklist
    if Blacklist[bananaChar.Name] and now - Blacklist[bananaChar.Name] < 600 then
        if getgenv().LockedTarget then
            restoreHitbox(getgenv().LockedTarget)
            getgenv().LockedTarget = nil
        end
        return nil
    end

    -- 🎯 set target
    if bananaChar ~= getgenv().LockedTarget then
        if getgenv().LockedTarget then
            restoreHitbox(getgenv().LockedTarget)
        end
        getgenv().LockedTarget = bananaChar
        TargetTimerRaw[bananaChar.Name] = 0
    end

    local tName = bananaChar.Name
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tHRP = bananaChar:FindFirstChild("HumanoidRootPart")

    -- 🚫 anti bay trời
    if tHRP and tHRP.Position.Y > 3000 then
        Blacklist[tName] = tick()
        restoreHitbox(bananaChar)
        getgenv().LockedTarget = nil
        TargetTimerRaw[tName] = nil
        return nil
    end

    -- 📏 check khoảng cách
    local isClose = false
    if myHRP and tHRP then
        local dist = (myHRP.Position - tHRP.Position).Magnitude
        if dist < 60 then
            isClose = true
        end
    end

    -- 🧠 logic timer
    if isClose then
        TargetTimerRaw[tName] = math.max(0, (TargetTimerRaw[tName] or 0) - dt * 2)
    else
        TargetTimerRaw[tName] = (TargetTimerRaw[tName] or 0) + dt
    end

    -- ⏱ timeout
 if (TargetTimerRaw[tName] or 0) >= 20 then
        Blacklist[tName] = tick()
        restoreHitbox(bananaChar)
        getgenv().LockedTarget = nil
        TargetTimerRaw[tName] = nil
        return nil
    end

    getgenv().LastTargetName = tName
    return bananaChar
end

-- ══════════════════════════════════════════════
--  AUTO CLICK
-- ══════════════════════════════════════════════
local AutoClickEnabled=true
local AutoClickRate=0.05
local lastAutoClick=0
local function doScreenClick()
    pcall(function()
        local mp=S.UIS:GetMouseLocation()
        local mx=math.floor(mp.X); local my=math.floor(mp.Y)
        S.V:SendMouseButtonEvent(mx,my,0,true,game,1)
        task.delay(0.03,function()
            pcall(function()
                local mp2=S.UIS:GetMouseLocation()
                S.V:SendMouseButtonEvent(math.floor(mp2.X),math.floor(mp2.Y),0,false,game,1)
            end)
        end)
    end)
end
t_spawn(function()
    while t_wait(0.01) do
        pcall(function()
            if not AutoClickEnabled then return end
            if not getgenv().LockedTarget or not isCharAlive(getgenv().LockedTarget) then return end
            if getgenv().Retreating then return end
            local now=tick()
            if now-lastAutoClick<AutoClickRate then return end
            lastAutoClick=now; doScreenClick()
        end)
    end
end)

local function setFruitMode(enable)
    pcall(function()
        local W=getgenv().Setting and getgenv().Setting["Weapons"]; if not W then return end
        if W["Blox Fruit"] then W["Blox Fruit"]["Enable"]=enable end
        local MC=getgenv().Setting["Method Click"]; if MC then MC["Click Fruit"]=enable end
    end)
end

-- ══════════════════════════════════════════════
--  KEN DODGE
-- ══════════════════════════════════════════════
local KenEnabled=true
local lastKenDodge=0
local KenCooldown=0.3
local lastMyHP=-1
local HP_DROP_THRESHOLD=150

local function pressKey(kc,ht)
    pcall(function()
        S.V:SendKeyEvent(true,kc,false,game)
        task.delay(ht or 0.12,function() pcall(function() S.V:SendKeyEvent(false,kc,false,game) end) end)
    end)
end

local function doDodge()
    if not KenEnabled then return end
    local now=tick(); if now-lastKenDodge<KenCooldown then return end
    lastKenDodge=now
    local myChar=LP.Character; if not myChar then return end
    local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local dodgeDir
    local tgt=getgenv().LockedTarget
    if tgt then
        local tHRP=tgt:FindFirstChild("HumanoidRootPart")
        if tHRP then
            local away=myHRP.Position-tHRP.Position
            local perp=Vector3.new(-away.Z,0,away.X).Unit
            dodgeDir=math.random()<0.5 and perp or -perp
        end
    end
    if not dodgeDir then
        local a=math.random(0,360)
        dodgeDir=Vector3.new(math.cos(math.rad(a)),0,math.sin(math.rad(a)))
    end
    local dest=myHRP.Position+dodgeDir*math.random(10,18)+Vector3.new(0,math.random(4,9),0)
    pcall(function()
        myHRP.CFrame=CFrame.new(dest,dest+myHRP.CFrame.LookVector)
        myHRP.AssemblyLinearVelocity=Vector3.new(0,0,0)
    end)
    pressKey(Enum.KeyCode.Space,0.08)
end

local function setupKenHook()
    local myChar=LP.Character; if not myChar then return end
    local hum=myChar:FindFirstChild("Humanoid"); if not hum then return end
    lastMyHP=hum.Health
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not KenEnabled then return end
        local newHP=hum.Health
        local drop=lastMyHP-newHP
        if drop>=HP_DROP_THRESHOLD and newHP>0 then doDodge() end
        lastMyHP=newHP
    end)
end
LP.CharacterAdded:Connect(function() task.wait(0.5); setupKenHook(); getgenv().Retreating=false end)
if LP.Character then setupKenHook() end

-- ══════════════════════════════════════════════
--  SMART RUN
-- ══════════════════════════════════════════════
local RunState={Active=false,LastRun=0,RunCooldown=8}
local function getHuntersNearby()
    local myChar=LP.Character; if not myChar then return {} end
    local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return {} end
    local hunters={}
    for _,plr in pairs(S.P:GetPlayers()) do
        if plr==LP then continue end
        local char=plr.Character; if not char then continue end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local hum=char:FindFirstChild("Humanoid"); if not hum or hum.Health<=0 then continue end
        local dist=(myHRP.Position-hrp.Position).Magnitude; if dist>200 then continue end
        local vel=hrp.AssemblyLinearVelocity
        local dot=(myHRP.Position-hrp.Position).Unit:Dot(vel.Unit)
        if vel.Magnitude>15 and dot>0.5 and dist<120 then table.insert(hunters,{char=char,dist=dist}) end
    end
    return hunters
end
local function doSmartRun()
    if not LP.Character then return end
    local myHRP=LP.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local now=tick(); if now-RunState.LastRun<RunState.RunCooldown then return end
    RunState.LastRun=now; RunState.Active=true
    pcall(function() local hum=LP.Character:FindFirstChild("Humanoid"); if hum then hum:UnequipTools() end end)
    local hunters=getHuntersNearby(); local escapeDir=Vector3.new(0,0,0)
    if #hunters>0 then
        for _,h in ipairs(hunters) do
            local hrp=h.char:FindFirstChild("HumanoidRootPart")
            if hrp then escapeDir=escapeDir+(myHRP.Position-hrp.Position).Unit end
        end
        if escapeDir.Magnitude>0 then escapeDir=escapeDir.Unit else escapeDir=Vector3.new(1,0,0) end
    else
        local a=math.random(0,360); escapeDir=Vector3.new(math.cos(math.rad(a)),0,math.sin(math.rad(a)))
    end
    local pos=myHRP.Position
    for i=1,4 do
        task.delay(i*0.15,function() pcall(function()
            if not LP.Character then return end
            local hrp=LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local dest=pos+escapeDir*(i*55)+Vector3.new(0,i*3,0)
            hrp.CFrame=CFrame.new(dest,dest+escapeDir); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
        end) end)
    end
    task.delay(0.8,function() pcall(function()
        if not LP.Character then return end
        local hrp=LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        hrp.CFrame=CFrame.new(hrp.Position+Vector3.new(0,60,0)+escapeDir*80)
    end) end)
    task.delay(2,function() RunState.Active=false end)
end

-- ══════════════════════════════════════════════
--  MAIN LOOP
-- ══════════════════════════════════════════════
t_spawn(function()
    setFruitMode(true)
    local last=tick()
    while t_wait(0.1) do
        local now=tick(); local dt=now-last; last=now
        pcall(function()
            local myChar=LP.Character; if not myChar then return end
            local myHum=myChar:FindFirstChild("Humanoid"); if not myHum then return end
            local hp=myHum.Health
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
                            if bHRP then pcall(function() Blacklist[eName] = tick() end) end
                        end
                        if getgenv().LockedTarget then restoreHitbox(getgenv().LockedTarget); getgenv().LockedTarget=nil end
                        return
                    end
                end
            end
            local t=SyncTarget(dt)
            if not t or getgenv().Retreating or RunState.Active then return end
            applyHitbox(t)
            pcall(function()
                if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health>0 then
                    local tip="Blox Fruit"; local eT=nil
                    for _,v in ipairs(LP.Backpack:GetChildren()) do
                        if v:IsA("Tool") and (v.ToolTip==tip or v.Name:match(tip)) then eT=v; break end
                    end
                    if not eT then
                        for _,v in ipairs(LP.Character:GetChildren()) do
                            if v:IsA("Tool") and (v.ToolTip==tip or v.Name:match(tip)) then eT=v; break end
                        end
                    end
                    if eT and eT.Parent~=LP.Character then LP.Character.Humanoid:EquipTool(eT) end
                end
            end)
        end)
    end
end)

-- Danger monitor
local RunLabel
t_spawn(function()
    while t_wait(0.25) do
        pcall(function()
            local myChar=LP.Character; if not myChar then return end
            local myHum=myChar:FindFirstChild("Humanoid"); if not myHum then return end
            local hp=myHum.Health; local hpPct=hp/math.max(myHum.MaxHealth,1)
            local hunters=getHuntersNearby()
            if hpPct<0.15 and #hunters>0 and not RunState.Active then
                getgenv().Retreating=true
                if getgenv().LockedTarget then restoreHitbox(getgenv().LockedTarget); getgenv().LockedTarget=nil end
                doSmartRun()
            elseif hpPct<0.28 and #hunters>0 and not RunState.Active and not getgenv().Retreating then
                getgenv().Retreating=true
                if getgenv().LockedTarget then restoreHitbox(getgenv().LockedTarget); getgenv().LockedTarget=nil end
                task.delay(0.5,function()
                    if LP.Character then
                        local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame=CFrame.new(hrp.Position+Vector3.new(math.random(-1,1)*60,20,math.random(-1,1)*60)) end
                    end
                end)
            end
            if RunLabel then
                if RunState.Active then RunLabel.Text="[RUN]"; RunLabel.TextColor3=Color3.fromRGB(255,200,50)
                elseif #hunters>0 and hpPct<0.4 then RunLabel.Text="[!] "..#hunters.." enemy"; RunLabel.TextColor3=Color3.fromRGB(255,100,100)
                elseif #hunters>0 then RunLabel.Text="[~] "..#hunters.." nearby"; RunLabel.TextColor3=Color3.fromRGB(255,160,50)
                else RunLabel.Text="[OK] Safe"; RunLabel.TextColor3=Color3.fromRGB(100,220,100) end
            end
        end)
    end
end)

-- Heartbeat
local lastRandTick=0; local rX,rY,rZ=0,5,5
S.RS.Heartbeat:Connect(function()
    pcall(function()
        local t=getgenv().LockedTarget; if not t then return end
        if not isCharAlive(t) then restoreHitbox(t); getgenv().LockedTarget=nil; return end
        if getgenv().Retreating or RunState.Active then return end
        local myChar=LP.Character; if not myChar then return end
        local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        local tHRP=t:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
if tHRP.Position.Y > 3000 then
    Blacklist[t.Name] = tick()
    restoreHitbox(t)
    getgenv().LockedTarget = nil
    return
end

if myHRP and tHRP then
    local dy = math.abs(myHRP.Position.Y - tHRP.Position.Y)
    if dy > 150 then
        Blacklist[t.Name] = tick()
        restoreHitbox(t)
        getgenv().LockedTarget = nil
        return
    end
end
local d = (myHRP.Position - tHRP.Position).Magnitude

-- 🚀 kéo lại gần nếu quá xa
if d > 80 then
    myHRP.CFrame = tHRP.CFrame * cf_new(0, 10, 0)
    return
end

-- 🚫 quá sát thì lùi ra
if d < 8 then
    myHRP.CFrame = tHRP.CFrame * cf_new(0, 6, -8)
    return
end
        local now=tick()
        if now-lastRandTick>0.1 then
            rX = m_random(-7,7); rY = m_random(3,8); rZ = m_random(-7,7); lastRandTick=now
        end
        myHRP.CFrame=tHRP.CFrame*cf_new(rX,rY,rZ)
        myHRP.AssemblyLinearVelocity=v3_new(0,0,0); myHRP.AssemblyAngularVelocity=v3_new(0,0,0)
    end)
end)

-- Anti-AFK
S.RS.RenderStepped:Connect(function()
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health>0 then
            local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then LP.Character.Humanoid:Move(v3_new(0,0,-1),true) end
        end
    end)
end)
t_spawn(function()
    while t_wait(4) do pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid:Move(Vector3.new(0,0,-1),true)
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end) end
end)

-- Graphics
local function applyGraphics(v)
    if v:IsA("BasePart") then
        v.Material=Enum.Material.SmoothPlastic; v.Reflectance=0; v.CastShadow=false
        for _,d in ipairs(v:GetDescendants()) do if d:IsA("Decal") or d:IsA("Texture") then d.Transparency=1 end end
    elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime=NumberRange.new(0,0)
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled=false
    elseif v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect")
        or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled=false
    elseif v:IsA("Explosion") then v.BlastPressure=1; v.BlastRadius=1 end
end
t_spawn(function() pcall(function()
    settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
    S.L.GlobalShadows=false; S.L.FogEnd=9e9; S.L.Brightness=2
    local Terrain=S.W:FindFirstChildOfClass("Terrain")
    if Terrain then Terrain.WaterWaveSize=0; Terrain.WaterWaveSpeed=0; Terrain.WaterReflectance=0; Terrain.WaterTransparency=0 end
    for _,v in ipairs(S.W:GetDescendants()) do pcall(applyGraphics,v) end
    S.W.DescendantAdded:Connect(function(v) pcall(applyGraphics,v) end)
end) end)
t_spawn(function() pcall(function()
    S.GS.ErrorMessageChanged:Connect(function()
        t_wait(2); S.TS:TeleportToPlaceInstance(game.PlaceId,game.JobId,LP)
    end)
end) end)
S.RS.RenderStepped:Connect(function() FrameCount=FrameCount+1 end)
t_spawn(function() while t_wait(1) do CurrentFPS=FrameCount; FrameCount=0 end end)

-- ══════════════════════════════════════════════════════════════
--  UI  v14b  — Layout fix, 640x420, no overlap
-- ══════════════════════════════════════════════════════════════
local doHop; local isHopping=false; local autoHopStart=tick()
pcall(function() local o=S.CG:FindFirstChild("DORA_UI"); if o then o:Destroy() end end)

local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
local C={
    BG=rgb(18,20,28),BG2=rgb(24,26,36),CARD=rgb(28,30,42),LBG=rgb(14,16,24),
    BORDER=rgb(45,50,75),B2=rgb(60,68,105),
    CYAN=rgb(45,210,188),CYAND=rgb(6,42,38),
    GOLD=rgb(255,198,48),GOLDD=rgb(46,34,5),
    ROSE=rgb(248,88,112),ROSED=rgb(48,8,20),
    BLUE=rgb(72,152,255),BLUED=rgb(8,26,58),
    VIO=rgb(178,112,252),VIOD=rgb(34,14,68),
    LIME=rgb(118,238,78),SUB=rgb(138,146,178),DIM=rgb(120,128,165),
    TEXT=rgb(222,230,246),WHITE=rgb(255,255,255),DARK=rgb(16,18,26),ORANGE=rgb(255,162,52),
}

local function cr(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r or 8) end
local function stk(p,col,tr,th)
    local s=Instance.new("UIStroke",p); s.Color=col or C.BORDER; s.Thickness=th or 1
    s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
end
local function grad(p,c1,c2,rot)
    local g=Instance.new("UIGradient",p); g.Color=ColorSequence.new(c1,c2); g.Rotation=rot or 90
end
local function mkF(par,x,y,w,h,col,tr)
    local f=Instance.new("Frame"); f.Parent=par
    f.Position=UDim2.new(x[1],x[2],y[1],y[2]); f.Size=UDim2.new(w[1],w[2],h[1],h[2])
    f.BackgroundColor3=col or C.BG; f.BackgroundTransparency=tr or 0; f.BorderSizePixel=0; return f
end
local function mkL(par,txt,sz,col,font,xa)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=txt or ""
    l.TextSize=sz or 12; l.TextColor3=col or C.TEXT; l.Font=font or Enum.Font.Gotham
    l.TextXAlignment=xa or Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Center
    l.Size=UDim2.new(1,0,1,0); l.Parent=par; return l
end
local function mkBtn(par,x,y,w,h,bg,col,txt,sz)
    local b=Instance.new("TextButton"); b.Parent=par
    b.Position=UDim2.new(x[1],x[2],y[1],y[2]); b.Size=UDim2.new(w[1],w[2],h[1],h[2])
    b.BackgroundColor3=bg; b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold
    b.TextColor3=col; b.Text=txt; b.TextSize=sz or 10; cr(b,7); return b
end

-- ════════════════════════════════════════════
-- SCREEN GUI  +  MAIN  640 x 420
-- Layout tính toán pixel cố định:
--   TitleBar  : y=0  h=30
--   LP_panel  : x=6  w=205  y=36  h=378  (đến y=414)
--   Right area: x=217  w=417
--     4 cards  : y=36  h=148  (2x2, mỗi card 205x70)
--     BPH bar  : y=190  h=64
--     History  : y=260  h=94
--     Buttons  : y=360  h=30  (4 nút ngang)
-- ════════════════════════════════════════════
local ScreenGui=Instance.new("ScreenGui"); ScreenGui.Name="DORA_UI"; ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ScreenGui.Parent=S.CG
local UIVisible=true

-- Kích thước cố định
local MW,MH = 640,420
local TH = 30   -- title bar height
local PAD = 6   -- padding chung
local LW = 205  -- left panel width
local RX = LW+PAD*2  -- right content x offset = 217
local RW = MW-RX-PAD  -- right content width = 640-217-6 = 417

local Main=Instance.new("Frame"); Main.Name="Main"
Main.Size=UDim2.new(0,MW,0,MH)
Main.Position=UDim2.new(0.5,-MW/2,0.5,-MH/2)
Main.BackgroundColor3=C.BG; Main.Active=true; Main.Draggable=true
Main.Parent=ScreenGui; Main.BorderSizePixel=0
cr(Main,12); stk(Main,C.B2,0.25,1.5)
grad(Main,rgb(20,22,32),rgb(14,16,24),160)

-- ── TITLE BAR ──────────────────────────
local TitleBar=mkF(Main,{0,0},{0,0},{1,0},{0,TH},C.LBG,0)
-- Tên
local TitleL=mkL(TitleBar,"DORA VIP",12,C.CYAN,Enum.Font.GothamBold)
TitleL.Size=UDim2.new(0,90,1,0); TitleL.Position=UDim2.new(0,10,0,0)
-- FPS
local FpsL=mkL(TitleBar,"FPS --",9,C.DIM,Enum.Font.Code,Enum.TextXAlignment.Right)
FpsL.Size=UDim2.new(0,46,1,0); FpsL.Position=UDim2.new(1,-52,0,0)
-- Ping
local PingL=mkL(TitleBar,"--ms",9,C.DIM,Enum.Font.Code,Enum.TextXAlignment.Right)
PingL.Size=UDim2.new(0,42,1,0); PingL.Position=UDim2.new(1,-100,0,0)
-- Target timeout
local T_ToutL=mkL(TitleBar,"T/O: --",9,C.GOLD,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
T_ToutL.Size=UDim2.new(0,110,1,0); T_ToutL.Position=UDim2.new(1,-215,0,0)
-- divider dưới title
mkF(Main,{0,0},{0,TH},{1,0},{0,1},C.B2,0.6)

-- ── PANEL TRÁI ─────────────────────────
-- y=36, h=MH-36-6=378  (đến y=414)
local LP_panel=mkF(Main,{0,PAD},{0,TH+PAD},{0,LW},{0,MH-TH-PAD*2},C.LBG,0)
cr(LP_panel,10); stk(LP_panel,C.BORDER,0.4)
grad(LP_panel,rgb(18,20,30),rgb(12,14,22),165)

-- Avatar (76x76, centered trong 205px → x offset = (205-76)/2 = 64)
local AvCircle=mkF(LP_panel,{0.5,-38},{0,10},{0,76},{0,76},rgb(26,28,40),0)
cr(AvCircle,38); stk(AvCircle,C.CYAN,0.3)
local AvImg=Instance.new("ImageLabel",AvCircle); AvImg.Size=UDim2.new(1,0,1,0); AvImg.BackgroundTransparency=1
AvImg.ScaleType=Enum.ScaleType.Crop
AvImg.Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150"; cr(AvImg,38)
local onDot=mkF(LP_panel,{0.5,24},{0,72},{0,12},{0,12},C.LIME,0); cr(onDot,6); stk(onDot,C.LBG,0,2)

-- Tên script + tên player
local ScL=mkL(LP_panel,"DORA VIP",13,C.WHITE,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
ScL.Size=UDim2.new(1,-4,0,18); ScL.Position=UDim2.new(0,2,0,90)
local NmL=mkL(LP_panel,LP.Name,10,C.CYAN,Enum.Font.Gotham,Enum.TextXAlignment.Center)
NmL.Size=UDim2.new(1,-4,0,14); NmL.Position=UDim2.new(0,2,0,108)

-- divider
mkF(LP_panel,{0,10},{0,126},{1,-20},{0,1},C.B2,0.5)

-- Info rows (y bắt đầu từ 132, mỗi row cao 22, gap 2)
local function mkRow(y,lbl,vc)
    local bg=mkF(LP_panel,{0,6},{0,y},{1,-12},{0,20},rgb(20,22,32),0); cr(bg,5)
    local lL=mkL(bg,lbl,8,C.DIM,Enum.Font.Gotham); lL.Size=UDim2.new(0,46,1,0); lL.Position=UDim2.new(0,5,0,0)
    local vL=mkL(bg,"--",10,vc,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
    vL.Size=UDim2.new(1,-8,1,0); return vL
end
local iBoL  = mkRow(132,"Bounty", C.CYAN)
local iHpL  = mkRow(155,"HP",     C.LIME)
local iNetL = mkRow(178,"Net",    C.GOLD)
local iLostL= mkRow(201,"Mat",    C.ROSE)

-- divider
mkF(LP_panel,{0,10},{0,225},{1,-20},{0,1},C.B2,0.5)

-- AUTO FARM status
local StatL=mkL(LP_panel,"AUTO FARM  ACTIVE",8,C.CYAN,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
StatL.Size=UDim2.new(1,-4,0,14); StatL.Position=UDim2.new(0,2,0,230)

-- ── BPH BAR (y=248, h=56) ──────────────
local BphBG=mkF(LP_panel,{0,6},{0,248},{1,-12},{0,56},rgb(12,14,22),0)
cr(BphBG,8); stk(BphBG,C.GOLD,0.35)
local BphTitle=mkL(BphBG,"BPH / GIO",7,C.DIM,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
BphTitle.Size=UDim2.new(1,0,0,14); BphTitle.Position=UDim2.new(0,0,0,2)
local BphVal=mkL(BphBG,"--",22,C.GOLD,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
BphVal.Size=UDim2.new(1,0,0,28); BphVal.Position=UDim2.new(0,0,0,14)
local BphTimer=mkL(BphBG,"reset --m --s",7,C.DIM,Enum.Font.Code,Enum.TextXAlignment.Center)
BphTimer.Size=UDim2.new(1,0,0,12); BphTimer.Position=UDim2.new(0,0,0,43)

-- ── HISTORY (y=308, h=66) ──────────────
-- History panel - nằm dưới BPH bar, font to, spacing tốt
local HistTitle=mkL(LP_panel,"LỊCH SỬ BPH (5 GIỜ GẦN NHẤT)",7,C.DIM,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
HistTitle.Size=UDim2.new(1,-4,0,12); HistTitle.Position=UDim2.new(0,2,0,307)
local HistBG=mkF(LP_panel,{0,6},{0,320},{1,-12},{0,52},rgb(12,14,22),0)
cr(HistBG,6); stk(HistBG,C.BORDER,0.55)
local HistScroll=Instance.new("ScrollingFrame",HistBG)
HistScroll.Size=UDim2.new(1,-2,1,-2); HistScroll.Position=UDim2.new(0,1,0,1)
HistScroll.BackgroundTransparency=1
HistScroll.BorderSizePixel=0; HistScroll.ScrollBarThickness=2
HistScroll.ScrollBarImageColor3=C.VIO; HistScroll.CanvasSize=UDim2.new(1,0,0,24)
HistScroll.ScrollingDirection=Enum.ScrollingDirection.Y; cr(HistScroll,5)
local HistEmpty=Instance.new("TextLabel",HistScroll); HistEmpty.Size=UDim2.new(1,0,0,22)
HistEmpty.BackgroundTransparency=1; HistEmpty.Text="Chưa có dữ liệu"; HistEmpty.TextSize=9
HistEmpty.TextColor3=C.DIM; HistEmpty.Font=Enum.Font.Gotham; HistEmpty.TextXAlignment=Enum.TextXAlignment.Center
local histRows={}
for i=1,5 do
    -- Mỗi row cao 20px, gap 2px → canvasSize = 5*22 = 110
    local row=mkF(HistScroll,{0,0},{0,(i-1)*22},{1,0},{0,20},rgb(18,20,30),0)
    cr(row,4); row.Visible=false; stk(row,C.BORDER,0.7)
    local rp=Instance.new("UIPadding",row)
    rp.PaddingLeft=UDim.new(0,5); rp.PaddingRight=UDim.new(0,5)
    -- Giờ (to hơn)
    local tL=mkL(row,"--:--",9,C.SUB,Enum.Font.GothamBold); tL.Size=UDim2.new(0,32,1,0)
    -- BPH (to nhất, màu vàng nổi bật)
    local vL=mkL(row,"--/h",10,C.GOLD,Enum.Font.GothamBold); vL.Size=UDim2.new(0,72,1,0); vL.Position=UDim2.new(0,34,0,0)
    -- Kills (căn phải)
    local kL=mkL(row,"0k",9,C.VIO,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
    kL.Size=UDim2.new(0,46,1,0); kL.Position=UDim2.new(1,-46,0,0)
    histRows[i]={f=row,t=tL,v=vL,k=kL}
end
local function refreshHist()
    pcall(function()
        local clean={}
        for _,h in ipairs(BphHistory) do
            if type(h)=="table" and h.time and h.bph~=nil and h.kills~=nil then table.insert(clean,h) end
        end
        BphHistory=clean; local any=#BphHistory>0; HistEmpty.Visible=not any
        local count=math.min(#BphHistory,5)
        for i=1,5 do
            local h=BphHistory[i]
            if h then
                histRows[i].f.Visible=true; histRows[i].f.Position=UDim2.new(0,0,0,(i-1)*22)
                histRows[i].t.Text=tostring(h.time or "--")
                histRows[i].v.Text=formatNumber(math.max(0,tonumber(h.bph) or 0)).."/h"
                local k=tonumber(h.kills) or 0
                histRows[i].k.Text=tostring(k).."k"
            else histRows[i].f.Visible=false end
        end
        HistScroll.CanvasSize=UDim2.new(1,0,0,math.max(22,count*22))
    end)
end

-- Buttons dưới cùng panel trái: HOP + RESET (y=370, h=24)
local BtnHop=mkBtn(LP_panel,{0,6},{1,-28},{0,91},{0,24},C.VIOD,C.VIO,"HOP SV",9)
stk(BtnHop,C.VIO,0.5)
BtnHop.MouseButton1Click:Connect(function() if not isHopping then doHop() end end)
local ResetBtn=mkBtn(LP_panel,{1,-97},{1,-28},{0,91},{0,24},C.ROSED,C.ROSE,"RESET",9)
stk(ResetBtn,C.ROSE,0.5)
local ResetConfirm=false
ResetBtn.MouseButton1Click:Connect(function()
    if not ResetConfirm then
        ResetConfirm=true; ResetBtn.Text="Sure?"
        task.delay(2,function() ResetConfirm=false; pcall(function() ResetBtn.Text="RESET" end) end)
    else
        ResetConfirm=false
        TotalEarned=0;HourEarned=0;Kills=0;TotalLost=0;PlayedTime2=0;SessionStart=os.time()
        SaveFile(FileName,0);SaveFile(KillFile,0);SaveFile(HourFile,0);SaveFile(LostFile,0);SaveFile(TimeFile,0)
        BphHistory={};SaveBphHist();refreshHist();ResetBtn.Text="RESET"
    end
end)

-- ── 4 CARDS (phần phải) ────────────────
local CW = math.floor((RW-PAD)/2)
local CARD_H = 76
local CARD_Y1 = TH+PAD
local CARD_Y2 = CARD_Y1+CARD_H+PAD

-- Icon dùng text symbol — chắc chắn hiện đúng, không bị lỗi asset
-- Style: ký tự Unicode đơn giản trong vòng tròn màu
local ICONS = {
    bounty = "$",   -- bounty/money
    time   = "T",   -- time
    kill   = "X",   -- kill
    target = "O",   -- target
}

local function mkCard(col,lbl,iconTxt,yOff,xOff)
    local f=mkF(Main,{0,RX+xOff},{0,yOff},{0,CW},{0,CARD_H},C.CARD,0)
    cr(f,10); stk(f,col,0.35,1.2)
    grad(f,rgb(26,28,42),rgb(16,18,30),145)
    -- accent line top
    mkF(f,{0,0},{0,0},{1,0},{0,2},col,0.2); cr(f:FindFirstChildOfClass("Frame"),10)

    -- Icon circle (28x28, góc trái, căn giữa dọc)
    local iconBG=mkF(f,{0,10},{0.5,-14},{0,28},{0,28},col,0.75); cr(iconBG,14)
    local iconL=Instance.new("TextLabel",iconBG)
    iconL.Size=UDim2.new(1,0,1,0); iconL.BackgroundTransparency=1
    iconL.Text=iconTxt; iconL.TextSize=13; iconL.Font=Enum.Font.GothamBold
    iconL.TextColor3=C.WHITE; iconL.TextXAlignment=Enum.TextXAlignment.Center
    iconL.TextYAlignment=Enum.TextYAlignment.Center

    -- Title — màu col đủ sáng (không dùng DIM)
    local tl=mkL(f,lbl,9,col,Enum.Font.GothamBold)
    tl.Size=UDim2.new(1,-48,0,14); tl.Position=UDim2.new(0,44,0,8)

    -- Value to — màu col
    local vl=mkL(f,"0",24,col,Enum.Font.GothamBold)
    vl.Size=UDim2.new(1,-48,0,34); vl.Position=UDim2.new(0,44,0,24)

    -- Sub — màu SUB sáng (rgb 155,162,190), không tối
    local sl=mkL(f,"",8,C.SUB,Enum.Font.Gotham)
    sl.Size=UDim2.new(1,-10,0,13); sl.Position=UDim2.new(0,8,1,-15)
    return vl,sl
end

local cEarned,cEarnedS = mkCard(C.CYAN, "Bounty Earned", ICONS.bounty, CARD_Y1, 0)
local cTime,  cTimeS   = mkCard(C.GOLD, "Time Elapsed",  ICONS.time,   CARD_Y1, CW+PAD)
local cKills, cKillsS  = mkCard(C.VIO,  "Total Kill",    ICONS.kill,   CARD_Y2, 0)
local cTarget,cTargetS = mkCard(C.BLUE, "Target Info",   ICONS.target, CARD_Y2, CW+PAD)
cEarned.TextSize=22; cTime.TextSize=15; cKills.TextSize=26; cTarget.TextSize=11
cTarget.TextColor3=C.TEXT; cTarget.Text="No target"; cTargetS.Text="Cho Banana..."

-- ── BPH BAR PHẢI (bên phải, to, y=200, h=60) ──
-- Hiện BPH ở bên phải to, song song với bên trái nhỏ
local BPH_Y = CARD_Y2+CARD_H+PAD  -- = 118+76+6 = 200
local BphBigBG=mkF(Main,{0,RX},{0,BPH_Y},{0,RW},{0,60},rgb(10,12,20),0)
cr(BphBigBG,8); stk(BphBigBG,C.GOLD,0.3,1.5)
-- label
local BphBigL=mkL(BphBigBG,"BOUNTY / HOUR",8,C.SUB,Enum.Font.GothamBold,Enum.TextXAlignment.Left)
BphBigL.Size=UDim2.new(0,140,0,14); BphBigL.Position=UDim2.new(0,10,0,4)
-- value
local BphBigVal=mkL(BphBigBG,"--",28,C.GOLD,Enum.Font.GothamBold,Enum.TextXAlignment.Left)
BphBigVal.Size=UDim2.new(0.6,0,0,36); BphBigVal.Position=UDim2.new(0,10,0,18)
-- timer bên phải trong cùng bar
local BphBigTimer=mkL(BphBigBG,"reset --",9,C.SUB,Enum.Font.Code,Enum.TextXAlignment.Right)
BphBigTimer.Size=UDim2.new(0,140,0,14); BphBigTimer.Position=UDim2.new(1,-145,0,4)
-- earned this hour
local BphBigEarned=mkL(BphBigBG,"this hour: --",8,C.SUB,Enum.Font.Gotham,Enum.TextXAlignment.Right)
BphBigEarned.Size=UDim2.new(0,160,0,14); BphBigEarned.Position=UDim2.new(1,-165,1,-16)

-- ── HISTORY PHẢI (y=266, h=84) ──
local HIST_Y = BPH_Y+60+PAD  -- = 266
local HistRBG=mkF(Main,{0,RX},{0,HIST_Y},{0,RW},{0,84},rgb(10,12,20),0)
cr(HistRBG,8); stk(HistRBG,C.BORDER,0.5)
local HrTitle=mkL(HistRBG,"LỊCH SỬ BPH / GIỜ",8,C.SUB,Enum.Font.GothamBold)
HrTitle.Size=UDim2.new(1,-10,0,14); HrTitle.Position=UDim2.new(0,8,0,2)
-- 3 columns header
local HistRScroll=Instance.new("ScrollingFrame",HistRBG)
HistRScroll.Size=UDim2.new(1,-4,0,66); HistRScroll.Position=UDim2.new(0,2,0,18)
HistRScroll.BackgroundTransparency=1; HistRScroll.BorderSizePixel=0; HistRScroll.ScrollBarThickness=2
HistRScroll.ScrollBarImageColor3=C.VIO; HistRScroll.CanvasSize=UDim2.new(1,0,0,20)
HistRScroll.ScrollingDirection=Enum.ScrollingDirection.Y; cr(HistRScroll,5)
local HistREmpty=Instance.new("TextLabel",HistRScroll); HistREmpty.Size=UDim2.new(1,0,0,20)
HistREmpty.BackgroundTransparency=1; HistREmpty.Text="Chua co du lieu"; HistREmpty.TextSize=9
HistREmpty.TextColor3=C.DIM; HistREmpty.Font=Enum.Font.Gotham; HistREmpty.TextXAlignment=Enum.TextXAlignment.Center
local histRRows={}
for i=1,5 do
    local row=mkF(HistRScroll,{0,0},{0,(i-1)*20},{1,0},{0,19},rgb(18,20,30),0)
    cr(row,4); row.Visible=false
    local rp2=Instance.new("UIPadding",row); rp2.PaddingLeft=UDim.new(0,6); rp2.PaddingRight=UDim.new(0,6)
    -- time
    local tL2=mkL(row,"--:--",8,C.SUB,Enum.Font.Code); tL2.Size=UDim2.new(0,36,1,0)
    -- bph
    local vL2=mkL(row,"--/h",10,C.GOLD,Enum.Font.GothamBold); vL2.Size=UDim2.new(0,90,1,0); vL2.Position=UDim2.new(0,38,0,0)
    -- kills
    local kL2=mkL(row,"0 kills",8,C.VIO,Enum.Font.Gotham,Enum.TextXAlignment.Right)
    kL2.Size=UDim2.new(0,70,1,0); kL2.Position=UDim2.new(1,-70,0,0)
    histRRows[i]={f=row,t=tL2,v=vL2,k=kL2}
end
local function refreshHistR()
    pcall(function()
        local clean={}
        for _,h in ipairs(BphHistory) do
            if type(h)=="table" and h.time and h.bph~=nil and h.kills~=nil then table.insert(clean,h) end
        end
        BphHistory=clean; local any=#BphHistory>0; HistREmpty.Visible=not any
        local count=math.min(#BphHistory,5)
        for i=1,5 do
            local h=BphHistory[i]
            if h then
                histRRows[i].f.Visible=true; histRRows[i].f.Position=UDim2.new(0,0,0,(i-1)*20)
                histRRows[i].t.Text=tostring(h.time or "--")
                histRRows[i].v.Text=formatNumber(math.max(0,tonumber(h.bph) or 0)).."/h"
                histRRows[i].k.Text=tostring(math.max(0,tonumber(h.kills) or 0)).." kills"
            else histRRows[i].f.Visible=false end
        end
        HistRScroll.CanvasSize=UDim2.new(1,0,0,math.max(20,count*20))
    end)
end

-- ── 4 NOTS DUOI CUNG (y=356, h=28) ──
local BTN_Y = HIST_Y+84+PAD  -- = 356
local BW4 = math.floor((RW-PAD*3)/4)  -- width mỗi nút

local function mkBtnR4(xi,lbl,bg,col)
    local b=mkBtn(Main,{0,RX+xi},{0,BTN_Y},{0,BW4},{0,28},bg,col,lbl,9)
    stk(b,col,0.5); return b
end

local BtnAC   = mkBtnR4(0,                   "CLICK ON",  C.CYAND, C.CYAN)
local BtnKen  = mkBtnR4(BW4+PAD,             "KEN 200",   C.BLUED, C.BLUE)
local BtnBlack= mkBtnR4((BW4+PAD)*2,         "MAP OFF",   C.DARK,  C.DIM)
local BtnHide = mkBtnR4((BW4+PAD)*3,         "HIDE [K]",  C.DARK,  C.DIM)

-- Click ON/OFF
BtnAC.MouseButton1Click:Connect(function()
    AutoClickEnabled=not AutoClickEnabled
    if AutoClickEnabled then BtnAC.Text="CLICK ON"; BtnAC.TextColor3=C.CYAN; BtnAC.BackgroundColor3=C.CYAND
    else BtnAC.Text="CLICK OFF"; BtnAC.TextColor3=C.DIM; BtnAC.BackgroundColor3=C.DARK end
end)

-- Ken toggle + ngưỡng (chuột phải)
local function updateKenBtn()
    if KenEnabled then BtnKen.Text="KEN "..HP_DROP_THRESHOLD; BtnKen.TextColor3=C.BLUE; BtnKen.BackgroundColor3=C.BLUED
    else BtnKen.Text="KEN OFF"; BtnKen.TextColor3=C.DIM; BtnKen.BackgroundColor3=C.DARK end
end
BtnKen.MouseButton1Click:Connect(function() KenEnabled=not KenEnabled; updateKenBtn() end)
BtnKen.MouseButton2Click:Connect(function()
    if HP_DROP_THRESHOLD>=500 then HP_DROP_THRESHOLD=300
    elseif HP_DROP_THRESHOLD>=300 then HP_DROP_THRESHOLD=200
    elseif HP_DROP_THRESHOLD>=200 then HP_DROP_THRESHOLD=100
    else HP_DROP_THRESHOLD=500 end
    updateKenBtn()
end)

-- Map blackout
local isBlack=false
pcall(function() if isfile and readfile and isfile("Suc_Blackout.txt") then isBlack=readfile("Suc_Blackout.txt")=="true" end end)
BtnBlack.TextColor3=isBlack and C.ROSE or C.DIM
BtnBlack.Text=isBlack and "MAP ON" or "MAP OFF"
pcall(function() S.RS:Set3dRenderingEnabled(not isBlack) end)
BtnBlack.MouseButton1Click:Connect(function()
    isBlack=not isBlack
    BtnBlack.TextColor3=isBlack and C.ROSE or C.DIM
    BtnBlack.Text=isBlack and "MAP ON" or "MAP OFF"
    pcall(function() S.RS:Set3dRenderingEnabled(not isBlack) end)
    pcall(function() if writefile then writefile("Suc_Blackout.txt",tostring(isBlack)) end end)
end)

-- Hide
BtnHide.MouseButton1Click:Connect(function()
    UIVisible=false; Main.Visible=false
    local Mini2=ScreenGui:FindFirstChild("MiniBar")
    if Mini2 then Mini2.Visible=true end
end)

-- RunLabel dùng sub label của card target
RunLabel=cTargetS

-- ── MINI BAR ──────────────────────────
local Mini=Instance.new("Frame",ScreenGui); Mini.Name="MiniBar"
Mini.Size=UDim2.new(0,200,0,26); Mini.Position=UDim2.new(0.5,-100,0,5)
Mini.BackgroundColor3=C.BG2; Mini.Active=true; Mini.Draggable=true; Mini.Visible=false
Mini.BorderSizePixel=0; cr(Mini,13); stk(Mini,C.B2,0.3)
grad(Mini,rgb(22,24,34),rgb(14,16,22),90)
do
    local dot=mkF(Mini,{0,7},{0.5,-3},{0,6},{0,6},C.CYAN,0); cr(dot,3)
    local ml=Instance.new("TextLabel",Mini); ml.Size=UDim2.new(0,88,1,0); ml.Position=UDim2.new(0,17,0,0)
    ml.BackgroundTransparency=1; ml.Text="DORA VIP"; ml.TextSize=10
    ml.TextColor3=C.WHITE; ml.Font=Enum.Font.GothamBold; ml.TextXAlignment=Enum.TextXAlignment.Left
end
local MOpen=mkBtn(Mini,{1,-58},{0.5,-9},{0,54},{0,18},C.DARK,C.SUB,"OPEN",9)
stk(MOpen,C.BORDER,0.5)
MOpen.MouseButton1Click:Connect(function() UIVisible=true; Main.Visible=true; Mini.Visible=false end)

-- Toggle K
S.UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==Enum.KeyCode.K then
        UIVisible=not UIVisible; Main.Visible=UIVisible; Mini.Visible=not UIVisible
    end
end)

refreshHist(); refreshHistR()



-- ══════════════════════════════════════════════
--  AUTO HOP
-- ══════════════════════════════════════════════
local HOP_INTERVAL=30*60  -- backup hop 30 phút (vì auto-hop khi hết target rồi)

doHop=function()
    if isHopping then return end
    isHopping=true; SaveAllState()
    pcall(function() BtnHop.Text="Tim sv..."; BtnHop.TextColor3=C.GOLD end)
    t_spawn(function()
        local placeId=game.PlaceId; local servers={}; local cursor=""
        for page=1,6 do
            local url="https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100"
            if cursor~="" then url=url.."&cursor="..cursor end
            local ok,raw=pcall(function() return game:HttpGet(url,true) end)
            if not ok or not raw or #raw<5 then break end
            local ok2,data=pcall(function() return S.HTTP:JSONDecode(raw) end)
            if not ok2 or type(data)~="table" or not data.data then break end
            for _,sv in ipairs(data.data) do
                if type(sv)~="table" then continue end
                local sid=sv.id or sv.gameId
                if not sid or sid=="" or sid==game.JobId then continue end
                local playing=tonumber(sv.playing) or 0; local maxP=tonumber(sv.maxPlayers) or 1
                if playing>=2 and playing<maxP then table.insert(servers,{id=sid,playing=playing,maxPlayers=maxP}) end
            end
            pcall(function() BtnHop.Text=tostring(#servers).."sv" end)
            local nc=data.nextPageCursor
            if type(nc)~="string" or nc=="" then break end
            if #servers>=30 then break end
            cursor=nc; task.wait(0.15)
        end
        local best=nil
        if #servers>0 then
            table.sort(servers,function(a,b)
                local fa=a.playing/math.max(a.maxPlayers,1); local fb=b.playing/math.max(b.maxPlayers,1)
                return a.playing*(fa<0.9 and 1 or 0)>b.playing*(fb<0.9 and 1 or 0)
            end)
            best=servers[1]
        end
        task.wait(0.5)
        if best then
            pcall(function() BtnHop.Text=best.playing.."/"..best.maxPlayers end)
            task.wait(0.4)
            local done=false
            for attempt=1,3 do
                local ok=pcall(function() S.TS:TeleportToPlaceInstance(placeId,best.id,LP) end)
                if ok then done=true; break end
                pcall(function() BtnHop.Text="Retry "..attempt end)
                task.wait(2.5)
            end
            if not done then pcall(function() BtnHop.Text="Fail"; BtnHop.TextColor3=C.ROSE end) end
        else
            pcall(function() BtnHop.Text="No sv"; BtnHop.TextColor3=C.ROSE end)
        end
        task.delay(8, function()
            autoHopStart = tick()
            isHopping = false
            NoTargetTime = 0
            pcall(function() BtnHop.TextColor3 = C.VIO end)
        end)
    end)  -- đóng t_spawn
end       -- ← THÊM DÒNG NÀY để đóng doHop

-- ══════════════════════════════════════════════
--  BOUNTY TRACKING + UPDATE LOOP
--  FIX BPH: dùng bất kỳ gain dương (không lọc >=8000)
--  và dùng direct leaderstats thay vì delta nhỏ
-- ══════════════════════════════════════════════
local LastBounty=-1; local LastDeathBounty=-1
-- KillsThisHour được khai báo trong update loop (local scoped)
-- Nhưng doHourReset cần truy cập nó → dùng upvalue qua closure
local _KillsThisHour = 0  -- sẽ được update từ loop

local function doHourReset()
local ts=os.time()+7*3600  -- +7 giờ VN
    -- Lưu bounty kiếm được + số kill trong giờ vừa xong
    table.insert(BphHistory,1,{
        time=string.format("%02d:%02d",m_floor((ts%86400)/3600),m_floor((ts%3600)/60)),
        bph=HourEarned,
        kills=_KillsThisHour  -- số kill trong GIỜU ĐÓ, không phải tổng
    })
    if #BphHistory>5 then table.remove(BphHistory,#BphHistory) end
   SaveBphHist(); refreshHist(); refreshHistR()

    HourEarned=0; HourStart=os.time()
    _KillsThisHour=0  -- reset kills giờ mới
    SaveFile(HourFile,0); SaveFile(HourStartFile,HourStart)
end

LP.CharacterAdded:Connect(function()
    if LastDeathBounty>0 then
        t_spawn(function()
            t_wait(3); local nb=getRealBounty()
            if nb<LastDeathBounty then
                local lost=LastDeathBounty-nb
                if lost>=500 and lost<=500000 then TotalLost=TotalLost+lost; SaveFile(LostFile,TotalLost) end
            end; LastDeathBounty=-1
        end)
    end
end)

t_spawn(function()
    -- Theo dõi kills trong giờ hiện tại riêng
    local KillsThisHour = 0
    while t_wait(1) do
        local current=getRealBounty()
        pcall(function()
            if LastBounty==-1 then LastBounty=current; return end
            local gain=current-LastBounty

            -- Cộng BPH khi bounty tăng bất kỳ lượng hợp lý
            -- Không dùng cooldown — mỗi lần leaderstats tăng = 1 kill
            if gain>0 and gain>=500 and gain<=1500000 then
                TotalEarned=TotalEarned+gain
                HourEarned=HourEarned+gain   -- BPH/h = tổng HourEarned trong giờ này
                KillsThisHour=KillsThisHour+1
                _KillsThisHour=KillsThisHour  -- sync upvalue cho doHourReset
                Kills=Kills+1
                SaveFile(FileName,TotalEarned); SaveFile(HourFile,HourEarned)
                SaveFile(KillFile,Kills)
            elseif gain<-100 then
                LastDeathBounty=LastBounty
            end
            LastBounty=current
        end)

        -- Update cards
        cEarned.Text=formatNumber(TotalEarned)
        cKills.Text=tostring(Kills)
        local total=m_floor(PlayedTime2)+(os.time()-SessionStart)
        cTime.Text=string.format("%dh %dm",m_floor(total/3600),m_floor((total%3600)/60))
        cTimeS.Text=string.format("played %d min",m_floor(total/60))

       -- Target card + patrol logic
        local tgt=getgenv().LockedTarget
        if tgt and isCharAlive(tgt) then
            NoTargetTime = 0  -- có target → reset timer
            local h=tgt:FindFirstChild("Humanoid")
            local hp2=h and h.Health or 0; local mhp2=h and h.MaxHealth or 1
            local pct=m_floor(hp2/math.max(mhp2,1)*100)
            cTarget.Text=tgt.Name:sub(1,12)
            cTargetS.Text="HP "..pct.."%  |  T/O "..m_floor(math.max(0,25-(TargetTimerRaw[tgt.Name] or 0))).."s"
            cTargetS.TextColor3=pct<30 and C.ROSE or C.CYAN
            cTarget.TextColor3=C.BLUE
            local tLeft=math.max(0,25-(TargetTimerRaw[tgt.Name] or 0))
            T_ToutL.Text=tgt.Name:sub(1,10).."  "..m_floor(tLeft).."s"
            T_ToutL.TextColor3=tLeft<8 and C.ROSE or C.GOLD
        else
            if getgenv().LockedTarget then restoreHitbox(getgenv().LockedTarget); getgenv().LockedTarget=nil end
            cTarget.Text="No target"; cTarget.TextColor3=C.DIM

            -- ── Đếm thời gian không có target ──
            NoTargetTime = NoTargetTime + 1

            -- ── Patrol: teleport đảo tiếp theo sau PATROL_WAIT giây ──
            local nowTick = tick()
            if NoTargetTime >= PATROL_WAIT and nowTick - LastPatrol >= PATROL_WAIT then
                LastPatrol = nowTick
                local pt = PatrolPoints[PatrolIndex]
                PatrolIndex = (PatrolIndex % #PatrolPoints) + 1
                pcall(function()
                    local myChar = LP.Character
                    if myChar then
                        local hrp = myChar:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(pt.pos)
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        end
                    end
                end)
                cTargetS.Text = "→ " .. pt.name
                cTargetS.TextColor3 = C.GOLD
            else
                local hopIn = math.max(0, NO_TARGET_HOP - NoTargetTime)
                cTargetS.Text = "Rảnh "..NoTargetTime.."s | hop "..hopIn.."s"
                cTargetS.TextColor3 = C.DIM
            end
            T_ToutL.Text="T/O: --"; T_ToutL.TextColor3=C.DIM

            -- ── Auto-hop sau NO_TARGET_HOP giây không target ──
            if NoTargetTime >= NO_TARGET_HOP and not isHopping then
                NoTargetTime = 0
                
                doHop()
            end
        end
        -- Player info rows
        local hp,mhp=0,100
        pcall(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                hp=LP.Character.Humanoid.Health; mhp=LP.Character.Humanoid.MaxHealth
            end
        end)
        local hpPct=mhp>0 and m_floor(hp/mhp*100) or 0
        local net=TotalEarned-TotalLost
        iBoL.Text=formatNumber(current)
        iHpL.Text=hpPct.."%"; iHpL.TextColor3=hpPct<30 and C.ROSE or (hpPct<60 and C.GOLD or C.LIME)
        iNetL.Text=formatNumber(net); iNetL.TextColor3=net>=0 and C.GOLD or C.ROSE
        iLostL.Text=formatNumber(TotalLost)

        -- FPS / Ping
        local ping=0; pcall(function() ping=m_floor(LP:GetNetworkPing()*1000) end)
        FpsL.Text="FPS "..CurrentFPS
        PingL.Text=ping.."ms"
        PingL.TextColor3=ping<80 and C.LIME or (ping<150 and C.GOLD or C.ROSE)

        -- BPH display (nổi bật)
        if os.time()-HourStart>=3600 then
            doHourReset()
           KillsThisHour=0
refreshHist(); refreshHistR()
        end
        local elapsed2=math.max(1,os.time()-HourStart)
        local remain=math.max(0,3600-elapsed2)
        local rm=m_floor(remain/60); local rs=m_floor(remain%60)
        -- BPH thực tế = HourEarned chia thời gian đã trôi (extrapolate ra 1h)
        local bphRate=elapsed2>0 and m_floor(HourEarned/(elapsed2/3600)) or 0
        BphVal.Text=formatNumber(bphRate)
        BphVal.TextColor3=bphRate>50000 and C.LIME or (bphRate>10000 and C.GOLD or C.CYAN)
        BphTimer.Text=string.format("reset in %dm %02ds", rm, rs)
        -- BPH bar bên phải (to)
        BphBigVal.Text=formatNumber(bphRate)
        BphBigVal.TextColor3=bphRate>50000 and C.LIME or (bphRate>10000 and C.GOLD or C.CYAN)
        BphBigTimer.Text=string.format("reset  %dm %02ds", rm, rs)
        BphBigEarned.Text="GIỜ NÀY: "..formatNumber(HourEarned).."  ("..KillsThisHour.." kill)"
        -- Sub label card Earned
        cEarnedS.Text=formatNumber(bphRate).."/h"

        -- Hop timer
        local hopElapsed=tick()-autoHopStart; local hopRemain=math.max(0,HOP_INTERVAL-hopElapsed)
        if not isHopping then
            BtnHop.Text=string.format("%02d:%02d",m_floor(hopRemain/60),m_floor(hopRemain%60))
            BtnHop.TextColor3=hopRemain<60 and C.GOLD or C.VIO
        end
        if hopRemain<=0 and not isHopping then doHop() end

        -- Auto save
        if tick()-lastSave>30 then
            lastSave=tick(); PlayedTime2=PlayedTime2+(os.time()-SessionStart); SessionStart=os.time()
            SaveFile(TimeFile,PlayedTime2)
        end
    end
end)
