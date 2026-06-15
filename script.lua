--[[
  COBALT  •  sell lemons autofarm  •  v4.0
  by poetry
--]]

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenSvc   = game:GetService("TweenService")
local LP         = Players.LocalPlayer

-- ══════════════════════════════════════════
--  THEME  (edit these to customise)
-- ══════════════════════════════════════════
local Theme = {
    Bg          = Color3.fromRGB(8,   8,   8),
    Panel       = Color3.fromRGB(12,  12,  12),
    Card        = Color3.fromRGB(18,  18,  18),
    CardHover   = Color3.fromRGB(24,  24,  24),
    Border      = Color3.fromRGB(38,  38,  38),
    BorderBright= Color3.fromRGB(60,  60,  60),
    Accent      = Color3.fromRGB(80,  140, 255),
    AccentDim   = Color3.fromRGB(30,  55,  130),
    AccentGlow  = Color3.fromRGB(130, 180, 255),
    Green       = Color3.fromRGB(60,  210, 110),
    Red         = Color3.fromRGB(220, 65,  65),
    Yellow      = Color3.fromRGB(240, 190, 50),
    Text        = Color3.fromRGB(220, 220, 220),
    TextSub     = Color3.fromRGB(140, 140, 140),
    TextDim     = Color3.fromRGB(75,  75,  75),
    White       = Color3.fromRGB(255, 255, 255),
    TabActive   = Color3.fromRGB(80,  140, 255),
    TabInactive = Color3.fromRGB(18,  18,  18),
}

-- ══════════════════════════════════════════
--  UTILS
-- ══════════════════════════════════════════
local function rnd(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
end
local function brd(p, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or Theme.Border
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
end
local function tw(obj, props, dur, style)
    TweenSvc:Create(obj,
        TweenInfo.new(dur or 0.15, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props):Play()
end
local function newLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextColor3 = Theme.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    for k,v in pairs(props or {}) do l[k]=v end
    l.Parent = parent
    return l
end

-- ══════════════════════════════════════════
--  NOTIFICATION
-- ══════════════════════════════════════════
local function notify(title, body, dur, color)
    local pg = LP:FindFirstChildOfClass("PlayerGui") if not pg then return end
    local g = Instance.new("ScreenGui")
    g.Name="CobaltNotif" g.ResetOnSpawn=false g.IgnoreGuiInset=true g.DisplayOrder=10002 g.Parent=pg

    local f = Instance.new("Frame")
    f.Size=UDim2.new(0,280,0,60) f.Position=UDim2.new(1,10,0,16)
    f.BackgroundColor3=Theme.Panel f.BorderSizePixel=0 f.Parent=g
    rnd(f,8) brd(f,color or Theme.Accent,1)

    local bar=Instance.new("Frame") bar.Size=UDim2.new(0,3,1,-14) bar.Position=UDim2.new(0,7,0,7)
    bar.BackgroundColor3=color or Theme.Accent bar.BorderSizePixel=0 bar.Parent=f rnd(bar,2)

    newLabel(f,{Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,18,0,7),
        Text=title,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=color or Theme.AccentGlow})
    newLabel(f,{Size=UDim2.new(1,-20,0,18),Position=UDim2.new(0,18,0,28),
        Text=body,TextSize=11,TextColor3=Theme.TextSub})

    tw(f,{Position=UDim2.new(1,-292,0,16)},0.3,Enum.EasingStyle.Quint)
    task.delay(dur or 4,function()
        tw(f,{Position=UDim2.new(1,10,0,16)},0.25,Enum.EasingStyle.Quint)
        task.wait(0.3) g:Destroy()
    end)
end

-- ══════════════════════════════════════════
--  FIND TYCOON
-- ══════════════════════════════════════════
local userTycoon=(function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:match("Tycoon%d") then
            if v:FindFirstChild("Owner") and v.Owner.Value==LP then return v end
        end
    end
end)()
if not userTycoon then notify("Cobalt","No tycoon found — claim one first.",8,Theme.Red) return end

-- ══════════════════════════════════════════
--  GAME STATE
-- ══════════════════════════════════════════
local AutoBuy=false local AutoUpgrade=false local AutoFruit=false
local AutoRebirth=false local AutoEvolve=false local AutoPowerLevel=false
local FlyEnabled=false local NoclipEnabled=false local SpeedEnabled=false local InfJump=false
local stats={buys=0,upgrades=0,fruit=0,rebirths=0,evolves=0}

-- ══════════════════════════════════════════
--  SAVED POSITIONS  (in-memory)
-- ══════════════════════════════════════════
local savedPositions = {}  -- {name=string, cf=CFrame}

-- ══════════════════════════════════════════
--  AUTO BUY
-- ══════════════════════════════════════════
local function buyAll()
    local p=userTycoon:FindFirstChild("Purchases") if not p then return end
    for _,obj in ipairs(p:GetDescendants()) do
        if obj:IsA("Model") and obj:GetAttribute("Shown")==true and obj:GetAttribute("Purchased")~=true then
            local r=obj:FindFirstChild("Purchase")
            if r and r:IsA("RemoteFunction") then pcall(function() r:InvokeServer() end) stats.buys=stats.buys+1 end
        end
    end
end
task.spawn(function() while true do task.wait(0.05) if AutoBuy then pcall(buyAll) end end end)

-- ══════════════════════════════════════════
--  AUTO UPGRADE
-- ══════════════════════════════════════════
local upRemotes={} local upLevel={} local lastScan=0
local function refreshUpgrades()
    upRemotes={} upLevel={}
    local p=userTycoon:FindFirstChild("Purchases") if not p then return end
    for _,obj in ipairs(p:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name=="Upgrade" then upRemotes[#upRemotes+1]=obj end
    end
end
task.spawn(function()
    while true do task.wait(0.25)
        if AutoUpgrade then
            if tick()-lastScan>3 then refreshUpgrades() lastScan=tick() end
            for _,r in ipairs(upRemotes) do if r.Parent then
                local lvl=(upLevel[r] or 0)+1
                while lvl<=100 do
                    local ok,res=pcall(function() return r:InvokeServer(lvl) end)
                    if(not ok)or res==false then break end
                    upLevel[r]=lvl stats.upgrades=stats.upgrades+1 lvl=lvl+1
                end
            end end
        end
    end
end)

-- ══════════════════════════════════════════
--  REBIRTH / EVOLVE helpers
-- ══════════════════════════════════════════
local NUM_SCALE={thousand=1e3,million=1e6,billion=1e9,trillion=1e12,quadrillion=1e15,
    quintillion=1e18,k=1e3,m=1e6,b=1e9,t=1e12,qd=1e15,qn=1e18}
local function parseNum(s)
    if not s then return nil end
    s=tostring(s):gsub(",",""):lower()
    local v=tonumber(s:match("[%d%.]+")) if not v then return nil end
    local w=s:match("[%d%.%s]+([a-z]+)")
    if w and NUM_SCALE[w] then v=v*NUM_SCALE[w] end return v
end
local function getRemote(name)
    local r=userTycoon:FindFirstChild("Remotes") return r and r:FindFirstChild(name)
end
local function investorQty(name)
    local pg=LP:FindFirstChildOfClass("PlayerGui")
    local r=pg and pg:FindFirstChild("Rebirth")
    local im=r and r:FindFirstChild("InvestorsMenu")
    local b=im and im:FindFirstChild("Body")
    local f=b and b:FindFirstChild(name)
    local q=f and f:FindFirstChild("Quantity")
    return q and parseNum(q.Text)
end
local function getEvoProg()
    local pg=LP:FindFirstChildOfClass("PlayerGui")
    local r=pg and pg:FindFirstChild("Rebirth")
    local em=r and r:FindFirstChild("EvolutionMenu")
    local b=em and em:FindFirstChild("Body")
    local p=b and b:FindFirstChild("Progress")
    return p and tonumber(tostring(p.Text):match("[%d%.]+"))
end

-- ══════════════════════════════════════════
--  AUTO REBIRTH
-- ══════════════════════════════════════════
local rebirthBusy=false
task.spawn(function()
    while true do task.wait(0.5)
        if AutoRebirth and not rebirthBusy then
            local rem=getRemote("Rebirth")
            local pot=investorQty("Potential") local cur=investorQty("Amount") or 0
            if rem and pot and pot>=1 and pot>=cur*1.0 then
                rebirthBusy=true
                pcall(function()
                    local done=false local sig=getRemote("Rebirthed") local conn
                    if sig and sig:IsA("RemoteEvent") then conn=sig.OnClientEvent:Connect(function() done=true end) end
                    rem:InvokeServer() stats.rebirths=stats.rebirths+1
                    local t=0 while not done and t<8 do task.wait(0.1) t=t+0.1 end
                    if conn then conn:Disconnect() end
                end)
                task.wait(2) rebirthBusy=false
            end
        end
    end
end)

-- ══════════════════════════════════════════
--  AUTO EVOLVE
-- ══════════════════════════════════════════
local evolveBusy=false
task.spawn(function()
    while true do task.wait(0.5)
        if AutoEvolve and not evolveBusy then
            local rem=getRemote("Evolve") local prog=getEvoProg()
            if rem and prog and prog>=100 then
                evolveBusy=true
                pcall(function()
                    local done=false local sig=getRemote("Evolved") local conn
                    if sig and sig:IsA("RemoteEvent") then conn=sig.OnClientEvent:Connect(function() done=true end) end
                    rem:InvokeServer() stats.evolves=stats.evolves+1
                    local t=0 while not done and t<8 do task.wait(0.1) t=t+0.1 end
                    if conn then conn:Disconnect() end
                end)
                task.wait(2) evolveBusy=false
            end
        end
    end
end)

-- ══════════════════════════════════════════
--  AUTO POWER LEVEL
-- ══════════════════════════════════════════
task.spawn(function()
    while true do task.wait(0.25)
        if AutoPowerLevel then local r=getRemote("UpgradePowerLevel") if r then pcall(function() r:InvokeServer() end) end end
    end
end)

-- ══════════════════════════════════════════
--  SEWER
-- ══════════════════════════════════════════
local function touchPart(hrp,part) pcall(function() firetouchinterest(hrp,part,0) firetouchinterest(hrp,part,1) end) end
local function pullAllLevers()
    local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return 0 end
    local sewer=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
    local n=0
    for _,o in ipairs((sewer or workspace):GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name),"lever",1,true) then
            pcall(function() firetouchinterest(hrp,o,0) firetouchinterest(hrp,o,1) end) n=n+1
        end
    end
    if sewer then
        for _,o in ipairs(sewer:GetDescendants()) do
            if o:IsA("BasePart") and(o.Name=="VineKey" or o.Name=="UFOKey") then
                pcall(function() firetouchinterest(hrp,o,0) firetouchinterest(hrp,o,1) end)
            end
        end
    end
    return n
end
local function doSewerRun()
    local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false,"no character" end
    local sewer=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
    if not sewer then return false,"sewer not loaded" end
    for _,o in ipairs(sewer:GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name),"lever",1,true) then touchPart(hrp,o) end
    end
    for _,fn in ipairs({"CashVine","SewerAlien"}) do
        local f=sewer:FindFirstChild(fn) if f then
            for _,o in ipairs(f:GetDescendants()) do
                if o:IsA("BasePart") and(o.Name=="VineKey" or o.Name=="UFOKey") then touchPart(hrp,o) end
            end
        end
    end
    task.wait(0.3)
    local cv=sewer:FindFirstChild("CashVine")
    if cv then local vd=cv:FindFirstChild("VineDoor") if vd then for _,o in ipairs(vd:GetDescendants()) do if o:IsA("BasePart") then touchPart(hrp,o) end end end end
    task.wait(0.3)
    if cv then local vm=cv:FindFirstChild("CashVine") if vm then
        pcall(function() hrp.CFrame=vm:GetPivot()+Vector3.new(0,3,0) end)
        task.wait(0.2)
        for _,o in ipairs(vm:GetDescendants()) do if o:IsA("BasePart") then touchPart(hrp,o) end end
    end end
    return true
end

-- ══════════════════════════════════════════
--  AUTO FRUIT
-- ══════════════════════════════════════════
local Trees={}
workspace.DescendantAdded:Connect(function(o) if o:IsA("Model") and o.Name=="LemonTree" and not table.find(Trees,o) then table.insert(Trees,o) end end)
workspace.DescendantRemoving:Connect(function(o) local i=table.find(Trees,o) if i then table.remove(Trees,i) end end)
for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("Model") and v.Name=="LemonTree" then table.insert(Trees,v) end end
task.spawn(function()
    while true do task.wait(0.1)
        if AutoFruit then for _,tree in ipairs(Trees) do if not AutoFruit then break end
            if tree and tree.Parent then pcall(function()
                local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return end
                for _,o in ipairs(tree:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide=false end end
                hrp.CFrame=tree:GetPivot()+Vector3.new(0,5,0)
                for _,o in ipairs(tree:GetDescendants()) do
                    if o:IsA("BasePart") and o.Name=="Fruit" then
                        o.CanCollide=false
                        local cp=o:FindFirstChild("ClickPart") if cp then
                            local d=cp:FindFirstChildOfClass("ClickDetector") if d then
                                task.wait(0.45) pcall(function() fireclickdetector(d) end) stats.fruit=stats.fruit+1
                            end
                        end
                    end
                end
            end) end
        end end
    end
end)

-- ══════════════════════════════════════════
--  FLY
-- ══════════════════════════════════════════
local flyConn
local function startFly()
    local char=LP.Character or LP.CharacterAdded:Wait()
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local bg=Instance.new("BodyGyro") bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.D=100 bg.Parent=hrp
    local bv=Instance.new("BodyVelocity") bv.Velocity=Vector3.zero bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Parent=hrp
    hum.PlatformStand=true
    flyConn=RunService.RenderStepped:Connect(function()
        if not FlyEnabled then bg:Destroy() bv:Destroy() hum.PlatformStand=false flyConn:Disconnect() return end
        local cam=workspace.CurrentCamera local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        bv.Velocity=dir.Magnitude>0 and dir.Unit*60 or Vector3.zero
        bg.CFrame=cam.CFrame
    end)
end

-- ══════════════════════════════════════════
--  NOCLIP
-- ══════════════════════════════════════════
local noclipConn
local function startNoclip()
    noclipConn=RunService.Stepped:Connect(function()
        if not NoclipEnabled then noclipConn:Disconnect() return end
        local char=LP.Character if not char then return end
        for _,o in ipairs(char:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide=false end end
    end)
end

-- ══════════════════════════════════════════
--  SPEED / INF JUMP
-- ══════════════════════════════════════════
local function setSpeed(v)
    local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed=v and 80 or 16 end
end
LP.CharacterAdded:Connect(function(char)
    if SpeedEnabled then local hum=char:WaitForChild("Humanoid") hum.WalkSpeed=80 end
end)
UIS.JumpRequest:Connect(function()
    if InfJump then local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  BUILD GUI
-- ══════════════════════════════════════════════════════════════════
local guiParent=LP:FindFirstChildOfClass("PlayerGui")
if not guiParent then local ok,h=pcall(gethui) guiParent=(ok and h) or game:GetService("CoreGui") end
for _,n in ipairs({"CobaltGui","CobaltNotif"}) do
    local old=guiParent:FindFirstChild(n) if old then old:Destroy() end
end

local SG=Instance.new("ScreenGui")
SG.Name="CobaltGui" SG.ResetOnSpawn=false SG.IgnoreGuiInset=true SG.DisplayOrder=9999 SG.Parent=guiParent

-- ── WINDOW ──
local W,H=370,490
local Win=Instance.new("Frame")
Win.Name="Win" Win.Size=UDim2.new(0,W,0,H) Win.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
Win.BackgroundColor3=Theme.Bg Win.BorderSizePixel=0 Win.ClipsDescendants=true Win.Parent=SG
rnd(Win,10) brd(Win,Theme.Border,1)

-- top accent strip
local strip=Instance.new("Frame") strip.Size=UDim2.new(1,0,0,2) strip.BackgroundColor3=Theme.Accent strip.BorderSizePixel=0 strip.Parent=Win

-- ── TITLE BAR ──
local TB=Instance.new("Frame") TB.Size=UDim2.new(1,0,0,46) TB.Position=UDim2.new(0,0,0,2)
TB.BackgroundColor3=Theme.Panel TB.BorderSizePixel=0 TB.Parent=Win

-- dot
local dot=Instance.new("Frame") dot.Size=UDim2.new(0,7,0,7) dot.Position=UDim2.new(0,14,0.5,-3.5)
dot.BackgroundColor3=Theme.Accent dot.BorderSizePixel=0 dot.Parent=TB rnd(dot,4)

newLabel(TB,{Size=UDim2.new(0,120,0,22),Position=UDim2.new(0,28,0,6),
    Text="cobalt",TextSize=17,Font=Enum.Font.GothamBold,TextColor3=Theme.Text})
newLabel(TB,{Size=UDim2.new(0,160,0,15),Position=UDim2.new(0,28,0,26),
    Text="sell lemons  •  by poetry",TextSize=10,TextColor3=Theme.TextDim})

-- close
local function headerBtn(xOff,bg,txt,cb)
    local b=Instance.new("TextButton") b.Size=UDim2.new(0,22,0,22) b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=bg b.Text=txt b.TextSize=12 b.Font=Enum.Font.GothamBold b.TextColor3=Theme.White
    b.BorderSizePixel=0 b.Parent=TB rnd(b,11)
    b.MouseButton1Click:Connect(cb) return b
end
headerBtn(-10,Theme.Red,"✕",function()
    tw(Win,{Size=UDim2.new(0,W,0,0),Position=UDim2.new(0.5,-W/2,0.5,0)},0.2,Enum.EasingStyle.Quint)
    task.wait(0.25) SG:Destroy()
end)
local minimized=false
headerBtn(-36,Theme.AccentDim,"−",function()
    minimized=not minimized
    tw(Win,{Size=UDim2.new(0,W,0,minimized and 48 or H)},0.2,Enum.EasingStyle.Quint)
end)

-- drag
local drag,ds,dp=false
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true ds=i.Position dp=Win.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-ds Win.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
    end
end)

-- ── TAB BAR ──
local TabBar=Instance.new("Frame") TabBar.Size=UDim2.new(1,-16,0,30) TabBar.Position=UDim2.new(0,8,0,52)
TabBar.BackgroundColor3=Theme.Panel TabBar.BorderSizePixel=0 TabBar.Parent=Win rnd(TabBar,8)
local tbl=Instance.new("UIListLayout") tbl.FillDirection=Enum.FillDirection.Horizontal
tbl.Padding=UDim.new(0,3) tbl.VerticalAlignment=Enum.VerticalAlignment.Center tbl.Parent=TabBar
local tbp=Instance.new("UIPadding") tbp.PaddingLeft=UDim.new(0,4) tbp.PaddingRight=UDim.new(0,4) tbp.Parent=TabBar

-- ── CONTENT ──
local Content=Instance.new("Frame") Content.Size=UDim2.new(1,-16,1,-96) Content.Position=UDim2.new(0,8,0,88)
Content.BackgroundTransparency=1 Content.ClipsDescendants=true Content.Parent=Win

-- ── TAB FACTORY ──
local allTabs={} local activePage=nil
local function switchTo(tab)
    if activePage then
        activePage.page.Visible=false
        tw(activePage.btn,{BackgroundColor3=Theme.TabInactive,TextColor3=Theme.TextSub})
    end
    activePage=tab tab.page.Visible=true
    tw(tab.btn,{BackgroundColor3=Theme.TabActive,TextColor3=Theme.White})
end

local rowOrder=0
local function makeTab(name)
    local btn=Instance.new("TextButton") btn.Size=UDim2.new(0,56,1,-6) btn.BackgroundColor3=Theme.TabInactive
    btn.Text=name btn.TextSize=11 btn.Font=Enum.Font.GothamSemibold btn.TextColor3=Theme.TextSub
    btn.BorderSizePixel=0 btn.Parent=TabBar rnd(btn,6)

    local sf=Instance.new("ScrollingFrame") sf.Size=UDim2.new(1,0,1,0) sf.BackgroundTransparency=1
    sf.BorderSizePixel=0 sf.ScrollBarThickness=3 sf.ScrollBarImageColor3=Theme.Border
    sf.CanvasSize=UDim2.new(0,0,0,0) sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false sf.Parent=Content

    local ll=Instance.new("UIListLayout") ll.SortOrder=Enum.SortOrder.LayoutOrder ll.Padding=UDim.new(0,5) ll.Parent=sf
    local lp=Instance.new("UIPadding") lp.PaddingTop=UDim.new(0,4) lp.PaddingBottom=UDim.new(0,10) lp.Parent=sf

    local tab={btn=btn,page=sf}
    allTabs[#allTabs+1]=tab
    btn.MouseButton1Click:Connect(function() switchTo(tab) end)
    return tab
end

-- ── COMPONENTS ──
local function section(page,text)
    rowOrder=rowOrder+1
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,24) f.BackgroundTransparency=1 f.LayoutOrder=rowOrder f.Parent=page
    newLabel(f,{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),Text=text:upper(),TextSize=9,
        Font=Enum.Font.GothamBold,TextColor3=Theme.Accent,LetterSpacingOffset=3})
    local div=Instance.new("Frame") div.Size=UDim2.new(1,-8,0,1) div.Position=UDim2.new(0,4,1,-1)
    div.BackgroundColor3=Theme.Border div.BorderSizePixel=0 div.Parent=f
end

local function toggle(page,label,desc,cb)
    rowOrder=rowOrder+1
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,52) row.BackgroundColor3=Theme.Card
    row.BorderSizePixel=0 row.LayoutOrder=rowOrder row.Parent=page rnd(row,7) brd(row,Theme.Border)

    newLabel(row,{Size=UDim2.new(1,-62,0,20),Position=UDim2.new(0,12,0,8),Text=label,
        TextSize=13,Font=Enum.Font.GothamSemibold,TextColor3=Theme.Text})
    newLabel(row,{Size=UDim2.new(1,-62,0,16),Position=UDim2.new(0,12,0,28),Text=desc or "",
        TextSize=11,TextColor3=Theme.TextSub})

    local pill=Instance.new("Frame") pill.Size=UDim2.new(0,40,0,20) pill.Position=UDim2.new(1,-52,0.5,-10)
    pill.BackgroundColor3=Theme.Border pill.BorderSizePixel=0 pill.Parent=row rnd(pill,10)
    local knob=Instance.new("Frame") knob.Size=UDim2.new(0,14,0,14) knob.Position=UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3=Theme.TextSub knob.BorderSizePixel=0 knob.Parent=pill rnd(knob,7)

    local on=false
    local function set(v)
        on=v tw(pill,{BackgroundColor3=v and Theme.Accent or Theme.Border})
        tw(knob,{Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=v and Theme.White or Theme.TextSub}) cb(v)
    end
    local clickBtn=Instance.new("TextButton") clickBtn.Size=UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency=1 clickBtn.Text="" clickBtn.Parent=row
    clickBtn.MouseButton1Click:Connect(function() set(not on) end)
    clickBtn.MouseEnter:Connect(function() tw(row,{BackgroundColor3=Theme.CardHover}) end)
    clickBtn.MouseLeave:Connect(function() tw(row,{BackgroundColor3=Theme.Card}) end)
    return set
end

local function button(page,label,desc,cb)
    rowOrder=rowOrder+1
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,52) row.BackgroundColor3=Theme.Card
    row.BorderSizePixel=0 row.LayoutOrder=rowOrder row.Parent=page rnd(row,7) brd(row,Theme.Border)

    newLabel(row,{Size=UDim2.new(1,-52,0,20),Position=UDim2.new(0,12,0,8),Text=label,
        TextSize=13,Font=Enum.Font.GothamSemibold,TextColor3=Theme.Text})
    newLabel(row,{Size=UDim2.new(1,-52,0,16),Position=UDim2.new(0,12,0,28),Text=desc or "",
        TextSize=11,TextColor3=Theme.TextSub})

    local pill=Instance.new("Frame") pill.Size=UDim2.new(0,30,0,30) pill.Position=UDim2.new(1,-40,0.5,-15)
    pill.BackgroundColor3=Theme.AccentDim pill.BorderSizePixel=0 pill.Parent=row rnd(pill,7)
    newLabel(pill,{Size=UDim2.new(1,0,1,0),Text="▶",TextSize=12,Font=Enum.Font.GothamBold,
        TextColor3=Theme.AccentGlow,TextXAlignment=Enum.TextXAlignment.Center})

    local clickBtn=Instance.new("TextButton") clickBtn.Size=UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency=1 clickBtn.Text="" clickBtn.Parent=row
    clickBtn.MouseButton1Click:Connect(function()
        tw(row,{BackgroundColor3=Theme.AccentDim},0.08) task.wait(0.12) tw(row,{BackgroundColor3=Theme.Card},0.2) cb()
    end)
    clickBtn.MouseEnter:Connect(function() tw(row,{BackgroundColor3=Theme.CardHover}) end)
    clickBtn.MouseLeave:Connect(function() tw(row,{BackgroundColor3=Theme.Card}) end)
end

-- ════════════════════════════════════
--  FARM TAB
-- ════════════════════════════════════
local farmTab=makeTab("Farm")
do local p=farmTab.page
    section(p,"Automation")
    toggle(p,"Auto Buy","Instantly purchases all affordable items",function(v) AutoBuy=v notify("Auto Buy",v and"Enabled"or"Disabled",3) end)
    toggle(p,"Auto Upgrade","Upgrades machines as cash grows",function(v) AutoUpgrade=v notify("Auto Upgrade",v and"Enabled"or"Disabled",3) end)
    toggle(p,"Auto Fruit","Teleports to lemon trees and collects fruit",function(v) AutoFruit=v notify("Auto Fruit",v and"Enabled"or"Disabled",3) end)
    toggle(p,"Auto Power Level","Spams UpgradePowerLevel remote",function(v) AutoPowerLevel=v notify("Auto Power Level",v and"Enabled"or"Disabled",3) end)
    section(p,"Progression")
    toggle(p,"Auto Rebirth","Rebirths when investor payout is optimal",function(v)
        AutoRebirth=v
        if v and not getRemote("Rebirth") then notify("Auto Rebirth","Remote not found in tycoon",5,Theme.Yellow) return end
        notify("Auto Rebirth",v and"Enabled"or"Disabled",3)
    end)
    toggle(p,"Auto Evolve","Evolves at 100% — gives ×10 income speed",function(v)
        AutoEvolve=v
        if v and not getRemote("Evolve") then notify("Auto Evolve","Remote not found in tycoon",5,Theme.Yellow) return end
        notify("Auto Evolve",v and"Enabled"or"Disabled",3)
    end)
end

-- ════════════════════════════════════
--  SEWER TAB
-- ════════════════════════════════════
local sewerTab=makeTab("Sewer")
do local p=sewerTab.page
    section(p,"Sewer")
    button(p,"Pull All Levers","Fire all door levers and grab keys",function()
        local n=pullAllLevers()
        notify("Pull Levers",n>0 and("Pulled "..n.." lever(s) + grabbed keys") or "No levers found",4)
    end)
    button(p,"Vine Harvest","Full run: levers → keys → door → vine",function()
        notify("Vine Harvest","Running...",2) task.spawn(function()
            local ok,err=doSewerRun()
            notify("Vine Harvest",ok and"Done — everything collected." or("Failed: "..tostring(err)),5)
        end)
    end)
    button(p,"Teleport to Alien","Jumps to sewer alien (UFO key spot)",function()
        local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hrp then pcall(function() hrp.CFrame=CFrame.new(-42,-41,180) end) notify("Sewer Alien","Teleported.",3)
        else notify("Sewer Alien","No character found.",3,Theme.Red) end
    end)
end

-- ════════════════════════════════════
--  TELEPORT TAB
-- ════════════════════════════════════
local tpTab=makeTab("TP")
do local p=tpTab.page

    -- ── PLAYER TELEPORT ──
    section(p,"Teleport to Player")

    -- dropdown container
    rowOrder=rowOrder+1
    local dropCard=Instance.new("Frame") dropCard.Size=UDim2.new(1,0,0,100) dropCard.BackgroundColor3=Theme.Card
    dropCard.BorderSizePixel=0 dropCard.LayoutOrder=rowOrder dropCard.Parent=p rnd(dropCard,7) brd(dropCard,Theme.Border)
    dropCard.ClipsDescendants=true

    local selectedPlayer=nil

    local selLabel=newLabel(dropCard,{Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,10,0,9),
        Text="Select a player...",TextSize=12,TextColor3=Theme.TextSub})
    local chevron=newLabel(dropCard,{Size=UDim2.new(0,20,0,18),Position=UDim2.new(1,-24,0,9),
        Text="▾",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=Theme.TextDim,
        TextXAlignment=Enum.TextXAlignment.Center})

    -- player list (hidden by default)
    local listFrame=Instance.new("ScrollingFrame") listFrame.Size=UDim2.new(1,0,1,-34) listFrame.Position=UDim2.new(0,0,0,34)
    listFrame.BackgroundColor3=Theme.Panel listFrame.BorderSizePixel=0 listFrame.ScrollBarThickness=3
    listFrame.ScrollBarImageColor3=Theme.Border listFrame.CanvasSize=UDim2.new(0,0,0,0)
    listFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y listFrame.Visible=false listFrame.Parent=dropCard

    local listLayout=Instance.new("UIListLayout") listLayout.SortOrder=Enum.SortOrder.LayoutOrder
    listLayout.Padding=UDim.new(0,1) listLayout.Parent=listFrame

    local listOpen=false
    local function closeList()
        listOpen=false listFrame.Visible=false
        tw(dropCard,{Size=UDim2.new(1,0,0,36)}) chevron.Text="▾"
    end
    local function populateList()
        for _,c in ipairs(listFrame:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LP then
                local entry=Instance.new("TextButton") entry.Size=UDim2.new(1,0,0,28)
                entry.BackgroundColor3=Theme.Panel entry.Text="" entry.BorderSizePixel=0 entry.Parent=listFrame
                newLabel(entry,{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,10,0,0),
                    Text=pl.Name,TextSize=12,TextColor3=Theme.Text})
                entry.MouseEnter:Connect(function() tw(entry,{BackgroundColor3=Theme.CardHover}) end)
                entry.MouseLeave:Connect(function() tw(entry,{BackgroundColor3=Theme.Panel}) end)
                entry.MouseButton1Click:Connect(function()
                    selectedPlayer=pl selLabel.Text=pl.Name selLabel.TextColor3=Theme.Text closeList()
                end)
            end
        end
        if #Players:GetPlayers()<=1 then
            local none=Instance.new("Frame") none.Size=UDim2.new(1,0,0,28) none.BackgroundTransparency=1 none.Parent=listFrame
            newLabel(none,{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,10,0,0),
                Text="No other players in server",TextSize=11,TextColor3=Theme.TextDim})
        end
    end

    local dropBtn=Instance.new("TextButton") dropBtn.Size=UDim2.new(1,0,0,34)
    dropBtn.BackgroundTransparency=1 dropBtn.Text="" dropBtn.Parent=dropCard
    dropBtn.MouseButton1Click:Connect(function()
        listOpen=not listOpen
        if listOpen then
            populateList() listFrame.Visible=true chevron.Text="▴"
            tw(dropCard,{Size=UDim2.new(1,0,0,100)})
        else closeList() end
    end)

    -- teleport button
    button(p,"Teleport to Player","Jumps to the selected player",function()
        if not selectedPlayer then notify("Teleport","No player selected!",3,Theme.Yellow) return end
        local tchar=selectedPlayer.Character
        local thrp=tchar and tchar:FindFirstChild("HumanoidRootPart")
        if not thrp then notify("Teleport","Player has no character.",3,Theme.Red) return end
        local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function() hrp.CFrame=thrp.CFrame+Vector3.new(2,1,0) end)
            notify("Teleport","Teleported to "..selectedPlayer.Name,3)
        end
    end)

    -- ── SAVED POSITIONS ──
    section(p,"Saved Positions")

    -- save current position button
    button(p,"Save Current Position","Saves where you are standing right now",function()
        local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("Save Position","No character found.",3,Theme.Red) return end
        local cf=hrp.CFrame
        local name="Position "..tostring(#savedPositions+1)
        table.insert(savedPositions,{name=name,cf=cf})
        notify("Saved","Saved as \""..name.."\"",3,Theme.Green)
        -- refresh list (fire a re-render by toggling tab)
        -- we'll update the list frame directly
        _G.CobaltRefreshPositions()
    end)

    -- positions list frame
    rowOrder=rowOrder+1
    local posListCard=Instance.new("Frame") posListCard.Size=UDim2.new(1,0,0,10)
    posListCard.BackgroundTransparency=1 posListCard.BorderSizePixel=0
    posListCard.LayoutOrder=rowOrder posListCard.AutomaticSize=Enum.AutomaticSize.Y posListCard.Parent=p

    local posLayout=Instance.new("UIListLayout") posLayout.SortOrder=Enum.SortOrder.LayoutOrder
    posLayout.Padding=UDim.new(0,5) posLayout.Parent=posListCard

    local function refreshPositions()
        for _,c in ipairs(posListCard:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        if #savedPositions==0 then
            local none=Instance.new("Frame") none.Size=UDim2.new(1,0,0,36) none.BackgroundColor3=Theme.Card
            none.BorderSizePixel=0 none.LayoutOrder=1 none.Parent=posListCard rnd(none,7) brd(none,Theme.Border)
            newLabel(none,{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,12,0,0),
                Text="No positions saved yet.",TextSize=12,TextColor3=Theme.TextDim})
            return
        end
        for i,pos in ipairs(savedPositions) do
            local idx=i
            local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,54) row.BackgroundColor3=Theme.Card
            row.BorderSizePixel=0 row.LayoutOrder=idx row.Parent=posListCard rnd(row,7) brd(row,Theme.Border)

            -- editable name
            local nameBox=Instance.new("TextBox") nameBox.Size=UDim2.new(1,-118,0,22) nameBox.Position=UDim2.new(0,10,0,7)
            nameBox.BackgroundColor3=Theme.Panel nameBox.BorderSizePixel=0
            nameBox.Text=pos.name nameBox.TextSize=13 nameBox.Font=Enum.Font.GothamSemibold
            nameBox.TextColor3=Theme.Text nameBox.PlaceholderText="Name..." nameBox.TextXAlignment=Enum.TextXAlignment.Left
            nameBox.ClearTextOnFocus=false nameBox.Parent=row rnd(nameBox,5) brd(nameBox,Theme.Border)
            local nbp=Instance.new("UIPadding") nbp.PaddingLeft=UDim.new(0,6) nbp.Parent=nameBox
            nameBox.FocusLost:Connect(function()
                if nameBox.Text~="" then savedPositions[idx].name=nameBox.Text end
            end)

            -- coords label
            local cf=pos.cf
            local coordStr=string.format("%.0f, %.0f, %.0f",cf.X,cf.Y,cf.Z)
            newLabel(row,{Size=UDim2.new(1,-118,0,16),Position=UDim2.new(0,10,0,30),
                Text=coordStr,TextSize=10,Font=Enum.Font.Code,TextColor3=Theme.TextDim})

            -- TP button
            local tpBtn=Instance.new("TextButton") tpBtn.Size=UDim2.new(0,44,0,38) tpBtn.Position=UDim2.new(1,-108,0.5,-19)
            tpBtn.BackgroundColor3=Theme.AccentDim tpBtn.Text="GO" tpBtn.TextSize=11
            tpBtn.Font=Enum.Font.GothamBold tpBtn.TextColor3=Theme.AccentGlow tpBtn.BorderSizePixel=0 tpBtn.Parent=row rnd(tpBtn,6)
            tpBtn.MouseButton1Click:Connect(function()
                local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
                if hrp then pcall(function() hrp.CFrame=savedPositions[idx].cf end) notify("Teleport","Went to \""..savedPositions[idx].name.."\"",3)
                else notify("Teleport","No character!",3,Theme.Red) end
            end)
            tpBtn.MouseEnter:Connect(function() tw(tpBtn,{BackgroundColor3=Theme.Accent}) end)
            tpBtn.MouseLeave:Connect(function() tw(tpBtn,{BackgroundColor3=Theme.AccentDim}) end)

            -- delete button
            local delBtn=Instance.new("TextButton") delBtn.Size=UDim2.new(0,44,0,38) delBtn.Position=UDim2.new(1,-56,0.5,-19)
            delBtn.BackgroundColor3=Color3.fromRGB(40,14,14) delBtn.Text="DEL" delBtn.TextSize=10
            delBtn.Font=Enum.Font.GothamBold delBtn.TextColor3=Theme.Red delBtn.BorderSizePixel=0 delBtn.Parent=row rnd(delBtn,6)
            delBtn.MouseButton1Click:Connect(function()
                table.remove(savedPositions,idx) refreshPositions() notify("Deleted","\""..pos.name.."\" removed",3)
            end)
            delBtn.MouseEnter:Connect(function() tw(delBtn,{BackgroundColor3=Color3.fromRGB(70,18,18)}) end)
            delBtn.MouseLeave:Connect(function() tw(delBtn,{BackgroundColor3=Color3.fromRGB(40,14,14)}) end)
        end
    end
    _G.CobaltRefreshPositions=refreshPositions
    refreshPositions()
end

-- ════════════════════════════════════
--  MISC TAB
-- ════════════════════════════════════
local miscTab=makeTab("Misc")
do local p=miscTab.page
    section(p,"Movement")
    toggle(p,"Fly","WASD + Space / Shift to fly (camera-relative)",function(v) FlyEnabled=v if v then task.spawn(startFly) end notify("Fly",v and"Enabled"or"Disabled",3) end)
    toggle(p,"Noclip","Walk through walls and parts",function(v) NoclipEnabled=v if v then task.spawn(startNoclip) end notify("Noclip",v and"Enabled"or"Disabled",3) end)
    toggle(p,"Speed (×5)","Sets your walkspeed to 80",function(v) SpeedEnabled=v setSpeed(v) notify("Speed",v and"WalkSpeed → 80"or"WalkSpeed → 16",3) end)
    toggle(p,"Infinite Jump","Jump again mid-air",function(v) InfJump=v notify("Infinite Jump",v and"Enabled"or"Disabled",3) end)
    section(p,"Utility")
    button(p,"Teleport to Spawn","Moves you to the map spawn point",function()
        local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local sp=workspace:FindFirstChildOfClass("SpawnLocation")
            if sp then pcall(function() hrp.CFrame=sp.CFrame+Vector3.new(0,3,0) end) notify("Teleport","Moved to spawn.",3)
            else notify("Teleport","No SpawnLocation found.",3,Theme.Yellow) end
        end
    end)
    button(p,"Reset Character","Kills and respawns your character",function()
        local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health=0 notify("Reset","Character reset.",3) end
    end)
end

-- ════════════════════════════════════
--  STATS TAB
-- ════════════════════════════════════
local statsTab=makeTab("Stats")
do local p=statsTab.page
    section(p,"Live Monitor")
    rowOrder=rowOrder+1
    local card=Instance.new("Frame") card.Size=UDim2.new(1,0,0,256) card.BackgroundColor3=Theme.Card
    card.BorderSizePixel=0 card.LayoutOrder=rowOrder card.Parent=p rnd(card,7) brd(card,Theme.Border)
    local body=Instance.new("TextLabel") body.Size=UDim2.new(1,-20,1,-16) body.Position=UDim2.new(0,10,0,10)
    body.BackgroundTransparency=1 body.RichText=true body.Text="..." body.TextSize=13
    body.Font=Enum.Font.Code body.TextColor3=Theme.Text body.TextXAlignment=Enum.TextXAlignment.Left
    body.TextYAlignment=Enum.TextYAlignment.Top body.Parent=card

    local frames,fps,fpsT=0,0,tick()
    RunService.RenderStepped:Connect(function() frames=frames+1 if tick()-fpsT>=1 then fps=frames frames=0 fpsT=tick() end end)
    local function dot(b) return b and "<font color='#3CD882'>● ON</font>" or "<font color='#444'>○ off</font>" end
    task.spawn(function()
        while card.Parent do
            local cash="?" local ls=LP:FindFirstChild("leaderstats") local c=ls and ls:FindFirstChild("Cash")
            if c then cash=tostring(c.Value) end
            local prog=getEvoProg() or 0
            body.Text=string.format(
                "<font color='#555'>FPS        </font><font color='#aac8ff'>%d</font>\n"
             .. "<font color='#555'>Cash       </font><font color='#aac8ff'>%s</font>\n"
             .. "<font color='#555'>Evolve %%   </font><font color='#aac8ff'>%.1f%%</font>\n\n"
             .. "<font color='#555'>Buys       </font><font color='#aac8ff'>%d  </font>%s\n"
             .. "<font color='#555'>Upgrades   </font><font color='#aac8ff'>%d  </font>%s\n"
             .. "<font color='#555'>Fruit      </font><font color='#aac8ff'>%d  </font>%s\n"
             .. "<font color='#555'>Rebirths   </font><font color='#aac8ff'>%d  </font>%s\n"
             .. "<font color='#555'>Evolves    </font><font color='#aac8ff'>%d  </font>%s",
                fps,cash,prog,
                stats.buys,dot(AutoBuy),stats.upgrades,dot(AutoUpgrade),
                stats.fruit,dot(AutoFruit),stats.rebirths,dot(AutoRebirth),stats.evolves,dot(AutoEvolve))
            task.wait(0.25)
        end
    end)
end

-- ════════════════════════════════════
--  CREDITS TAB
-- ════════════════════════════════════
local credTab=makeTab("Info")
do local p=credTab.page
    section(p,"Credits")
    rowOrder=rowOrder+1
    local card=Instance.new("Frame") card.Size=UDim2.new(1,0,0,110) card.BackgroundColor3=Theme.Card
    card.BorderSizePixel=0 card.LayoutOrder=rowOrder card.Parent=p rnd(card,7) brd(card,Theme.Border)
    newLabel(card,{Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,0,14),Text="cobalt",
        TextSize=34,Font=Enum.Font.GothamBold,TextColor3=Theme.Accent,TextXAlignment=Enum.TextXAlignment.Center})
    newLabel(card,{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,52),
        Text="sell lemons autofarm  •  v4.0",TextSize=11,TextColor3=Theme.TextDim,TextXAlignment=Enum.TextXAlignment.Center})
    newLabel(card,{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,74),
        Text="made by  poetry",TextSize=12,Font=Enum.Font.GothamSemibold,TextColor3=Theme.TextSub,TextXAlignment=Enum.TextXAlignment.Center})

    section(p,"Links")
    button(p,"guns.lol/erode","Click to copy link to clipboard",function()
        pcall(function() setclipboard("https://guns.lol/erode") end)
        notify("Copied","https://guns.lol/erode copied to clipboard",4,Theme.Green)
    end)
end

-- ── activate first tab ──
switchTo(farmTab)

-- ── footer ──
local foot=newLabel(Win,{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-16),
    Text="cobalt  •  poetry",TextSize=9,TextColor3=Theme.TextDim,
    TextXAlignment=Enum.TextXAlignment.Center})

notify("Cobalt","Loaded — tycoon found. Ready.",4)
