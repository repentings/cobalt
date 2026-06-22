--[[
  COBALT  •  sell lemons  •  v4.1  •  by poetry
--]]

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenSvc   = game:GetService("TweenService")
local LP         = Players.LocalPlayer

-- ╔══════════════════════════════════════╗
-- ║  THEME  — edit freely                ║
-- ╚══════════════════════════════════════╝
local T = {
    Bg        = Color3.fromRGB(6,   6,   6),
    Panel     = Color3.fromRGB(11,  11,  11),
    Card      = Color3.fromRGB(17,  17,  17),
    CardHov   = Color3.fromRGB(23,  23,  23),
    Border    = Color3.fromRGB(36,  36,  36),
    Accent    = Color3.fromRGB(75,  135, 255),
    AccentDim = Color3.fromRGB(25,  50,  120),
    AccentGlo = Color3.fromRGB(130, 180, 255),
    Green     = Color3.fromRGB(55,  205, 105),
    Red       = Color3.fromRGB(215, 60,  60),
    Yellow    = Color3.fromRGB(235, 185, 45),
    Text      = Color3.fromRGB(215, 215, 215),
    Sub       = Color3.fromRGB(120, 120, 120),
    Dim       = Color3.fromRGB(55,  55,  55),
    White     = Color3.fromRGB(255, 255, 255),
}

-- ╔══════════════════════════════════════╗
-- ║  HELPERS                             ║
-- ╚══════════════════════════════════════╝
local function rnd(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 6) c.Parent=p end
local function brd(p,col,t) local s=Instance.new("UIStroke") s.Color=col or T.Border s.Thickness=t or 1 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=p end
local function tw(o,props,d,s) TweenSvc:Create(o,TweenInfo.new(d or .15,s or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play() end

local function lbl(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font       = props.Font or Enum.Font.GothamMedium
    l.TextSize   = props.TextSize or 13
    l.TextColor3 = props.TextColor3 or T.Text
    l.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.RichText   = props.RichText or false
    l.Size       = props.Size or UDim2.new(1,0,1,0)
    l.Position   = props.Position or UDim2.new(0,0,0,0)
    l.Text       = props.Text or ""
    l.Parent     = parent
    return l
end

-- ╔══════════════════════════════════════╗
-- ║  NOTIFICATION                        ║
-- ╚══════════════════════════════════════╝
local function notify(title, body, dur, col)
    local pg = LP:FindFirstChildOfClass("PlayerGui") if not pg then return end
    local g = Instance.new("ScreenGui") g.Name="CobaltNotif" g.ResetOnSpawn=false g.IgnoreGuiInset=true g.DisplayOrder=10002 g.Parent=pg
    local f = Instance.new("Frame") f.Size=UDim2.new(0,280,0,60) f.Position=UDim2.new(1,10,0,16) f.BackgroundColor3=T.Panel f.BorderSizePixel=0 f.Parent=g rnd(f,8) brd(f,col or T.Accent,1)
    local bar=Instance.new("Frame") bar.Size=UDim2.new(0,3,1,-14) bar.Position=UDim2.new(0,7,0,7) bar.BackgroundColor3=col or T.Accent bar.BorderSizePixel=0 bar.Parent=f rnd(bar,2)
    lbl(f,{Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,18,0,7),Text=title,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=col or T.AccentGlo})
    lbl(f,{Size=UDim2.new(1,-20,0,18),Position=UDim2.new(0,18,0,29),Text=body,TextSize=11,TextColor3=T.Sub})
    tw(f,{Position=UDim2.new(1,-292,0,16)},0.3,Enum.EasingStyle.Quint)
    task.delay(dur or 4,function() tw(f,{Position=UDim2.new(1,10,0,16)},0.25) task.wait(0.3) g:Destroy() end)
end

-- ╔══════════════════════════════════════╗
-- ║  FIND TYCOON                         ║
-- ╚══════════════════════════════════════╝
local userTycoon = (function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:match("Tycoon%d") and v:FindFirstChild("Owner") and v.Owner.Value==LP then return v end
    end
end)()
if not userTycoon then notify("Cobalt","No tycoon found — claim one first.",8,T.Red) return end

-- ╔══════════════════════════════════════╗
-- ║  STATE                               ║
-- ╚══════════════════════════════════════╝
local AutoBuy=false local AutoUpgrade=false local AutoFruit=false
local AutoRebirth=false local AutoEvolve=false local AutoPL=false
local Fly=false local Noclip=false local Speed=false local InfJump=false
local stats={buys=0,upgrades=0,fruit=0,rebirths=0,evolves=0}
local savedPos={}

-- ╔══════════════════════════════════════╗
-- ║  GAME LOGIC                          ║
-- ╚══════════════════════════════════════╝

-- auto buy
local function buyAll()
    local p=userTycoon:FindFirstChild("Purchases") if not p then return end
    for _,o in ipairs(p:GetDescendants()) do
        if o:IsA("Model") and o:GetAttribute("Shown")==true and o:GetAttribute("Purchased")~=true then
            local r=o:FindFirstChild("Purchase")
            if r and r:IsA("RemoteFunction") then pcall(function() r:InvokeServer() end) stats.buys+=1 end
        end
    end
end
task.spawn(function() while true do task.wait(0.05) if AutoBuy then pcall(buyAll) end end end)

-- auto upgrade
local upR={} local upL={} local upT=0
local function scanUpgrades()
    upR={} upL={}
    local p=userTycoon:FindFirstChild("Purchases") if not p then return end
    for _,o in ipairs(p:GetDescendants()) do if o:IsA("RemoteFunction") and o.Name=="Upgrade" then upR[#upR+1]=o end end
end
task.spawn(function()
    while true do task.wait(0.25)
        if AutoUpgrade then
            if tick()-upT>3 then scanUpgrades() upT=tick() end
            for _,r in ipairs(upR) do if r.Parent then
                local l=(upL[r] or 0)+1
                while l<=100 do local ok,res=pcall(function() return r:InvokeServer(l) end) if(not ok)or res==false then break end upL[r]=l stats.upgrades+=1 l+=1 end
            end end
        end
    end
end)

-- helpers
local NUM={thousand=1e3,million=1e6,billion=1e9,trillion=1e12,k=1e3,m=1e6,b=1e9,t=1e12,qd=1e15,qn=1e18}
local function pNum(s) if not s then return nil end s=tostring(s):gsub(",",""):lower() local v=tonumber(s:match("[%d%.]+")) if not v then return nil end local w=s:match("[%d%.%s]+([a-z]+)") if w and NUM[w] then v*=NUM[w] end return v end
local function getR(n) local r=userTycoon:FindFirstChild("Remotes") return r and r:FindFirstChild(n) end
local function iQty(n) local pg=LP:FindFirstChildOfClass("PlayerGui") local r=pg and pg:FindFirstChild("Rebirth") local im=r and r:FindFirstChild("InvestorsMenu") local b=im and im:FindFirstChild("Body") local f=b and b:FindFirstChild(n) local q=f and f:FindFirstChild("Quantity") return q and pNum(q.Text) end
local function evoProg() local pg=LP:FindFirstChildOfClass("PlayerGui") local r=pg and pg:FindFirstChild("Rebirth") local em=r and r:FindFirstChild("EvolutionMenu") local b=em and em:FindFirstChild("Body") local p=b and b:FindFirstChild("Progress") return p and tonumber(tostring(p.Text):match("[%d%.]+")) end

-- auto rebirth
local rbBusy=false
task.spawn(function()
    while true do task.wait(0.5)
        if AutoRebirth and not rbBusy then
            local rem=getR("Rebirth") local pot=iQty("Potential") local cur=iQty("Amount") or 0
            if rem and pot and pot>=1 and pot>=cur then rbBusy=true
                pcall(function()
                    local done=false local sig=getR("Rebirthed") local conn
                    if sig and sig:IsA("RemoteEvent") then conn=sig.OnClientEvent:Connect(function() done=true end) end
                    rem:InvokeServer() stats.rebirths+=1
                    local t=0 while not done and t<8 do task.wait(0.1) t+=0.1 end if conn then conn:Disconnect() end
                end)
                task.wait(2) rbBusy=false
            end
        end
    end
end)

-- auto evolve
local evBusy=false
task.spawn(function()
    while true do task.wait(0.5)
        if AutoEvolve and not evBusy then
            local rem=getR("Evolve") local prog=evoProg()
            if rem and prog and prog>=100 then evBusy=true
                pcall(function()
                    local done=false local sig=getR("Evolved") local conn
                    if sig and sig:IsA("RemoteEvent") then conn=sig.OnClientEvent:Connect(function() done=true end) end
                    rem:InvokeServer() stats.evolves+=1
                    local t=0 while not done and t<8 do task.wait(0.1) t+=0.1 end if conn then conn:Disconnect() end
                end)
                task.wait(2) evBusy=false
            end
        end
    end
end)

-- auto power level
task.spawn(function() while true do task.wait(0.25) if AutoPL then local r=getR("UpgradePowerLevel") if r then pcall(function() r:InvokeServer() end) end end end end)

-- auto fruit
-- NOTE: no longer teleports the player. It only fires ClickDetectors on fruit
-- that are within FruitRange studs of the player's current position, so you
-- stay in full control of movement and it just collects whatever is nearby
-- as you walk past trees naturally.
local Trees={}
local FruitRange = 18  -- studs; raise/lower to taste
workspace.DescendantAdded:Connect(function(o) if o:IsA("Model") and o.Name=="LemonTree" and not table.find(Trees,o) then table.insert(Trees,o) end end)
workspace.DescendantRemoving:Connect(function(o) local i=table.find(Trees,o) if i then table.remove(Trees,i) end end)
for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("Model") and v.Name=="LemonTree" then table.insert(Trees,v) end end

task.spawn(function()
    while true do task.wait(0.15)
        if AutoFruit then
            local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if h then
                local myPos = h.Position
                for _,tree in ipairs(Trees) do
                    if not AutoFruit then break end
                    if tree and tree.Parent then
                        pcall(function()
                            -- skip trees outside range entirely (cheap distance check first)
                            local treePos = tree:GetPivot().Position
                            if (treePos - myPos).Magnitude > (FruitRange + 40) then return end

                            for _,o in ipairs(tree:GetDescendants()) do
                                if o:IsA("BasePart") and o.Name=="Fruit" then
                                    o.CanCollide=false
                                    -- only collect fruit actually within range of the player
                                    if (o.Position - myPos).Magnitude <= FruitRange then
                                        local cp=o:FindFirstChild("ClickPart")
                                        if cp then
                                            local d=cp:FindFirstChildOfClass("ClickDetector")
                                            if d then
                                                pcall(function() fireclickdetector(d) end)
                                                stats.fruit+=1
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- sewer
local function tp(h,p) pcall(function() firetouchinterest(h,p,0) firetouchinterest(h,p,1) end) end
local function pullLevers()
    local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not h then return 0 end
    local sew=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
    local n=0
    for _,o in ipairs((sew or workspace):GetDescendants()) do if o:IsA("BasePart") and string.find(string.lower(o.Name),"lever",1,true) then pcall(function() firetouchinterest(h,o,0) firetouchinterest(h,o,1) end) n+=1 end end
    if sew then for _,o in ipairs(sew:GetDescendants()) do if o:IsA("BasePart") and(o.Name=="VineKey" or o.Name=="UFOKey") then pcall(function() firetouchinterest(h,o,0) firetouchinterest(h,o,1) end) end end end
    return n
end
local function sewerRun()
    local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not h then return false,"no character" end
    local sew=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer") if not sew then return false,"sewer not loaded" end
    for _,o in ipairs(sew:GetDescendants()) do if o:IsA("BasePart") and string.find(string.lower(o.Name),"lever",1,true) then tp(h,o) end end
    for _,fn in ipairs({"CashVine","SewerAlien"}) do local f=sew:FindFirstChild(fn) if f then for _,o in ipairs(f:GetDescendants()) do if o:IsA("BasePart") and(o.Name=="VineKey" or o.Name=="UFOKey") then tp(h,o) end end end end
    task.wait(0.3)
    local cv=sew:FindFirstChild("CashVine")
    if cv then local vd=cv:FindFirstChild("VineDoor") if vd then for _,o in ipairs(vd:GetDescendants()) do if o:IsA("BasePart") then tp(h,o) end end end end
    task.wait(0.3)
    if cv then local vm=cv:FindFirstChild("CashVine") if vm then pcall(function() h.CFrame=vm:GetPivot()+Vector3.new(0,3,0) end) task.wait(0.2) for _,o in ipairs(vm:GetDescendants()) do if o:IsA("BasePart") then tp(h,o) end end end end
    return true
end

-- fly
local flyConn
local function startFly()
    local char=LP.Character or LP.CharacterAdded:Wait()
    local h=char:FindFirstChild("HumanoidRootPart") local hum=char:FindFirstChildOfClass("Humanoid") if not h or not hum then return end
    local bg=Instance.new("BodyGyro") bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.D=100 bg.Parent=h
    local bv=Instance.new("BodyVelocity") bv.Velocity=Vector3.zero bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Parent=h
    hum.PlatformStand=true
    flyConn=RunService.RenderStepped:Connect(function()
        if not Fly then bg:Destroy() bv:Destroy() hum.PlatformStand=false flyConn:Disconnect() return end
        local cam=workspace.CurrentCamera local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
        bv.Velocity=dir.Magnitude>0 and dir.Unit*60 or Vector3.zero bg.CFrame=cam.CFrame
    end)
end

-- noclip
local ncConn
local function startNoclip()
    ncConn=RunService.Stepped:Connect(function()
        if not Noclip then ncConn:Disconnect() return end
        local c=LP.Character if not c then return end
        for _,o in ipairs(c:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide=false end end
    end)
end

-- speed / inf jump
local function setSpeed(v) local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=v and 80 or 16 end end
LP.CharacterAdded:Connect(function(c) if Speed then task.wait(0.1) local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=80 end end end)
UIS.JumpRequest:Connect(function() if InfJump then local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  BUILD GUI                                           ║
-- ╚══════════════════════════════════════════════════════╝
local guiParent=LP:FindFirstChildOfClass("PlayerGui")
if not guiParent then local ok,h=pcall(gethui) guiParent=(ok and h) or game:GetService("CoreGui") end
for _,n in ipairs({"CobaltGui","CobaltNotif"}) do local old=guiParent:FindFirstChild(n) if old then old:Destroy() end end

local SG=Instance.new("ScreenGui") SG.Name="CobaltGui" SG.ResetOnSpawn=false SG.IgnoreGuiInset=true SG.DisplayOrder=9999 SG.Parent=guiParent

-- window
local W,H=370,490
local Win=Instance.new("Frame") Win.Size=UDim2.new(0,W,0,H) Win.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
Win.BackgroundColor3=T.Bg Win.BorderSizePixel=0 Win.ClipsDescendants=true Win.Parent=SG rnd(Win,10) brd(Win,T.Border,1)

-- accent line
local al=Instance.new("Frame") al.Size=UDim2.new(1,0,0,2) al.BackgroundColor3=T.Accent al.BorderSizePixel=0 al.ZIndex=3 al.Parent=Win

-- title bar
local TB=Instance.new("Frame") TB.Size=UDim2.new(1,0,0,46) TB.Position=UDim2.new(0,0,0,2) TB.BackgroundColor3=T.Panel TB.BorderSizePixel=0 TB.Parent=Win
local dot=Instance.new("Frame") dot.Size=UDim2.new(0,7,0,7) dot.Position=UDim2.new(0,14,0.5,-3.5) dot.BackgroundColor3=T.Accent dot.BorderSizePixel=0 dot.Parent=TB rnd(dot,4)
lbl(TB,{Size=UDim2.new(0,130,0,22),Position=UDim2.new(0,28,0,5),Text="cobalt",TextSize=17,Font=Enum.Font.GothamBold})
lbl(TB,{Size=UDim2.new(0,200,0,15),Position=UDim2.new(0,28,0,25),Text="sell lemons  •  by poetry",TextSize=10,TextColor3=T.Dim})

local function hBtn(xOff,bg,txt,cb)
    local b=Instance.new("TextButton") b.Size=UDim2.new(0,22,0,22) b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=bg b.Text=txt b.TextSize=12 b.Font=Enum.Font.GothamBold b.TextColor3=T.White b.BorderSizePixel=0 b.Parent=TB rnd(b,11)
    b.MouseButton1Click:Connect(cb)
end
hBtn(-10,T.Red,"✕",function() tw(Win,{Size=UDim2.new(0,W,0,0),Position=UDim2.new(0.5,-W/2,0.5,0)},0.2,Enum.EasingStyle.Quint) task.wait(0.25) SG:Destroy() end)
local mini=false
hBtn(-36,T.AccentDim,"−",function() mini=not mini tw(Win,{Size=UDim2.new(0,W,0,mini and 48 or H)},0.2,Enum.EasingStyle.Quint) end)

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
TabBar.BackgroundColor3=T.Panel TabBar.BorderSizePixel=0 TabBar.Parent=Win rnd(TabBar,8)
local tLayout=Instance.new("UIListLayout") tLayout.FillDirection=Enum.FillDirection.Horizontal
tLayout.Padding=UDim.new(0,3) tLayout.VerticalAlignment=Enum.VerticalAlignment.Center tLayout.Parent=TabBar
local tPad=Instance.new("UIPadding") tPad.PaddingLeft=UDim.new(0,4) tPad.PaddingRight=UDim.new(0,4) tPad.Parent=TabBar

-- ── CONTENT FRAME ──
local Content=Instance.new("Frame") Content.Size=UDim2.new(1,-16,1,-96) Content.Position=UDim2.new(0,8,0,88)
Content.BackgroundTransparency=1 Content.ClipsDescendants=true Content.Parent=Win

-- ╔══════════════════════════════════════╗
-- ║  TAB / COMPONENT FACTORIES           ║
-- ╚══════════════════════════════════════╝
local activeTab=nil

local function newTab(name)
    -- tab button
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,56,1,-6)
    btn.BackgroundColor3=T.Panel
    btn.Text=name btn.TextSize=11 btn.Font=Enum.Font.GothamSemibold
    btn.TextColor3=T.Sub btn.BorderSizePixel=0 btn.Parent=TabBar rnd(btn,6)

    -- scrolling page — ClipsDescendants OFF so content isn't hidden
    local sf=Instance.new("ScrollingFrame")
    sf.Size=UDim2.new(1,0,1,0)
    sf.BackgroundTransparency=1
    sf.BorderSizePixel=0
    sf.ScrollBarThickness=3
    sf.ScrollBarImageColor3=T.Border
    sf.CanvasSize=UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false
    sf.Parent=Content

    -- layout inside the scrollframe  — each tab gets its OWN counter
    local layout=Instance.new("UIListLayout")
    layout.SortOrder=Enum.SortOrder.LayoutOrder
    layout.Padding=UDim.new(0,5)
    layout.Parent=sf

    local pad=Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,4)
    pad.PaddingBottom=UDim.new(0,10)
    pad.Parent=sf

    -- per-tab order counter
    local order=0
    local tab={btn=btn, page=sf, nextOrder=function() order+=1 return order end}

    btn.MouseButton1Click:Connect(function()
        if activeTab then
            activeTab.page.Visible=false
            tw(activeTab.btn,{BackgroundColor3=T.Panel,TextColor3=T.Sub})
        end
        activeTab=tab
        sf.Visible=true
        tw(btn,{BackgroundColor3=T.Accent,TextColor3=T.White})
    end)

    return tab
end

-- section header
local function section(tab, text)
    local o=tab.nextOrder()
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,24) f.BackgroundTransparency=1 f.LayoutOrder=o f.Parent=tab.page
    lbl(f,{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),Text=text:upper(),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=T.Accent,LetterSpacingOffset=3})
    local div=Instance.new("Frame") div.Size=UDim2.new(1,-8,0,1) div.Position=UDim2.new(0,4,1,-1) div.BackgroundColor3=T.Border div.BorderSizePixel=0 div.Parent=f
end

-- toggle row
local function toggle(tab, label, desc, cb)
    local o=tab.nextOrder()
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,54) row.BackgroundColor3=T.Card row.BorderSizePixel=0 row.LayoutOrder=o row.Parent=tab.page rnd(row,7) brd(row,T.Border)
    lbl(row,{Size=UDim2.new(1,-62,0,20),Position=UDim2.new(0,12,0,8),Text=label,TextSize=13,Font=Enum.Font.GothamSemibold})
    lbl(row,{Size=UDim2.new(1,-62,0,16),Position=UDim2.new(0,12,0,29),Text=desc or "",TextSize=11,TextColor3=T.Sub})
    local pill=Instance.new("Frame") pill.Size=UDim2.new(0,40,0,20) pill.Position=UDim2.new(1,-52,0.5,-10) pill.BackgroundColor3=T.Border pill.BorderSizePixel=0 pill.Parent=row rnd(pill,10)
    local knob=Instance.new("Frame") knob.Size=UDim2.new(0,14,0,14) knob.Position=UDim2.new(0,3,0.5,-7) knob.BackgroundColor3=T.Sub knob.BorderSizePixel=0 knob.Parent=pill rnd(knob,7)
    local on=false
    local function set(v) on=v tw(pill,{BackgroundColor3=v and T.Accent or T.Border}) tw(knob,{Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),BackgroundColor3=v and T.White or T.Sub}) cb(v) end
    local c=Instance.new("TextButton") c.Size=UDim2.new(1,0,1,0) c.BackgroundTransparency=1 c.Text="" c.Parent=row
    c.MouseButton1Click:Connect(function() set(not on) end)
    c.MouseEnter:Connect(function() tw(row,{BackgroundColor3=T.CardHov}) end)
    c.MouseLeave:Connect(function() tw(row,{BackgroundColor3=T.Card}) end)
    return set
end

-- action button row
local function actionBtn(tab, label, desc, cb)
    local o=tab.nextOrder()
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,54) row.BackgroundColor3=T.Card row.BorderSizePixel=0 row.LayoutOrder=o row.Parent=tab.page rnd(row,7) brd(row,T.Border)
    lbl(row,{Size=UDim2.new(1,-52,0,20),Position=UDim2.new(0,12,0,8),Text=label,TextSize=13,Font=Enum.Font.GothamSemibold})
    lbl(row,{Size=UDim2.new(1,-52,0,16),Position=UDim2.new(0,12,0,29),Text=desc or "",TextSize=11,TextColor3=T.Sub})
    local pill=Instance.new("Frame") pill.Size=UDim2.new(0,30,0,30) pill.Position=UDim2.new(1,-40,0.5,-15) pill.BackgroundColor3=T.AccentDim pill.BorderSizePixel=0 pill.Parent=row rnd(pill,7)
    lbl(pill,{Text="▶",TextSize=12,Font=Enum.Font.GothamBold,TextColor3=T.AccentGlo,TextXAlignment=Enum.TextXAlignment.Center})
    local c=Instance.new("TextButton") c.Size=UDim2.new(1,0,1,0) c.BackgroundTransparency=1 c.Text="" c.Parent=row
    c.MouseButton1Click:Connect(function() tw(row,{BackgroundColor3=T.AccentDim},0.08) task.wait(0.12) tw(row,{BackgroundColor3=T.Card},0.2) task.spawn(cb) end)
    c.MouseEnter:Connect(function() tw(row,{BackgroundColor3=T.CardHov}) end)
    c.MouseLeave:Connect(function() tw(row,{BackgroundColor3=T.Card}) end)
end

-- ╔══════════════════════════════════════╗
-- ║  FARM TAB                            ║
-- ╚══════════════════════════════════════╝
local farmTab=newTab("Farm")
section(farmTab,"Automation")
toggle(farmTab,"Auto Buy","Instantly purchases all affordable items",function(v) AutoBuy=v notify("Auto Buy",v and"Enabled"or"Disabled",3) end)
toggle(farmTab,"Auto Upgrade","Upgrades machines as cash grows",function(v) AutoUpgrade=v notify("Auto Upgrade",v and"Enabled"or"Disabled",3) end)
toggle(farmTab,"Auto Fruit","Collects nearby fruit as you walk — no teleport",function(v) AutoFruit=v notify("Auto Fruit",v and"Enabled"or"Disabled",3) end)
toggle(farmTab,"Auto Power Level","Spams UpgradePowerLevel remote",function(v) AutoPL=v notify("Auto Power Level",v and"Enabled"or"Disabled",3) end)
section(farmTab,"Progression")
toggle(farmTab,"Auto Rebirth","Rebirths when investor payout is optimal",function(v)
    AutoRebirth=v
    if v and not getR("Rebirth") then notify("Auto Rebirth","Remote not found!",5,T.Yellow) return end
    notify("Auto Rebirth",v and"Enabled"or"Disabled",3)
end)
toggle(farmTab,"Auto Evolve","Evolves at 100% progress (×10 income speed)",function(v)
    AutoEvolve=v
    if v and not getR("Evolve") then notify("Auto Evolve","Remote not found!",5,T.Yellow) return end
    notify("Auto Evolve",v and"Enabled"or"Disabled",3)
end)

-- ╔══════════════════════════════════════╗
-- ║  SEWER TAB                           ║
-- ╚══════════════════════════════════════╝
local sewTab=newTab("Sewer")
section(sewTab,"Sewer")
actionBtn(sewTab,"Pull All Levers","Fire all door levers and grab keys",function()
    local n=pullLevers() notify("Pull Levers",n>0 and("Pulled "..n.." lever(s) + grabbed keys") or "No levers found",4)
end)
actionBtn(sewTab,"Vine Harvest","Full run: levers → keys → door → vine",function()
    notify("Vine Harvest","Running...",2)
    local ok,err=sewerRun() notify("Vine Harvest",ok and"Done — everything collected." or("Failed: "..tostring(err)),5)
end)
actionBtn(sewTab,"Teleport to Alien","Jumps to sewer alien / UFO key spot",function()
    local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if h then pcall(function() h.CFrame=CFrame.new(-42,-41,180) end) notify("Sewer Alien","Teleported.",3)
    else notify("Sewer Alien","No character found.",3,T.Red) end
end)

-- ╔══════════════════════════════════════╗
-- ║  TELEPORT TAB                        ║
-- ╚══════════════════════════════════════╝
local tpTab=newTab("TP")

-- ── Player dropdown ──
section(tpTab,"Teleport to Player")

do
    local o=tpTab.nextOrder()

    -- dropdown card (collapsible)
    local dropCard=Instance.new("Frame")
    dropCard.Size=UDim2.new(1,0,0,36)
    dropCard.BackgroundColor3=T.Card
    dropCard.BorderSizePixel=0
    dropCard.LayoutOrder=o
    dropCard.ClipsDescendants=true
    dropCard.Parent=tpTab.page
    rnd(dropCard,7) brd(dropCard,T.Border)

    local selLbl=lbl(dropCard,{Size=UDim2.new(1,-30,0,20),Position=UDim2.new(0,10,0,8),Text="Select a player...",TextSize=12,TextColor3=T.Sub})
    local chev=lbl(dropCard,{Size=UDim2.new(0,22,0,20),Position=UDim2.new(1,-26,0,8),Text="▾",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=T.Dim,TextXAlignment=Enum.TextXAlignment.Center})

    -- list inside
    local listSF=Instance.new("ScrollingFrame")
    listSF.Size=UDim2.new(1,0,1,-36) listSF.Position=UDim2.new(0,0,0,36)
    listSF.BackgroundColor3=T.Panel listSF.BorderSizePixel=0
    listSF.ScrollBarThickness=3 listSF.ScrollBarImageColor3=T.Border
    listSF.CanvasSize=UDim2.new(0,0,0,0) listSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
    listSF.Visible=true listSF.Parent=dropCard
    local listLL=Instance.new("UIListLayout") listLL.SortOrder=Enum.SortOrder.LayoutOrder listLL.Padding=UDim.new(0,1) listLL.Parent=listSF

    local listOpen=false
    local selectedPl=nil

    local function closeDD()
        listOpen=false chev.Text="▾"
        tw(dropCard,{Size=UDim2.new(1,0,0,36)},0.2)
    end
    local function buildList()
        for _,c in ipairs(listSF:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        local all=Players:GetPlayers()
        local others={}
        for _,pl in ipairs(all) do if pl~=LP then others[#others+1]=pl end end
        if #others==0 then
            local none=Instance.new("Frame") none.Size=UDim2.new(1,0,0,30) none.BackgroundTransparency=1 none.LayoutOrder=1 none.Parent=listSF
            lbl(none,{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,10,0,0),Text="No other players in server",TextSize=11,TextColor3=T.Dim})
            return
        end
        for i,pl in ipairs(others) do
            local entry=Instance.new("TextButton") entry.Size=UDim2.new(1,0,0,30) entry.BackgroundColor3=T.Panel
            entry.Text="" entry.BorderSizePixel=0 entry.LayoutOrder=i entry.Parent=listSF
            lbl(entry,{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,10,0,0),Text=pl.Name,TextSize=12})
            entry.MouseEnter:Connect(function() tw(entry,{BackgroundColor3=T.CardHov}) end)
            entry.MouseLeave:Connect(function() tw(entry,{BackgroundColor3=T.Panel}) end)
            entry.MouseButton1Click:Connect(function()
                selectedPl=pl selLbl.Text=pl.Name selLbl.TextColor3=T.Text closeDD()
            end)
        end
    end

    -- toggle button over header
    local ddBtn=Instance.new("TextButton") ddBtn.Size=UDim2.new(1,0,0,36) ddBtn.BackgroundTransparency=1 ddBtn.Text="" ddBtn.Parent=dropCard
    ddBtn.MouseButton1Click:Connect(function()
        listOpen=not listOpen
        if listOpen then
            buildList()
            local count=math.max(1, #Players:GetPlayers()-1)
            local h=36+math.min(count*31,120)
            chev.Text="▴"
            tw(dropCard,{Size=UDim2.new(1,0,0,h)},0.2)
        else closeDD() end
    end)

    -- GO button
    actionBtn(tpTab,"Teleport to Player","Jumps to the selected player above",function()
        if not selectedPl then notify("Teleport","No player selected!",3,T.Yellow) return end
        local tc=selectedPl.Character local th=tc and tc:FindFirstChild("HumanoidRootPart")
        if not th then notify("Teleport","Player has no character.",3,T.Red) return end
        local mh=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if mh then pcall(function() mh.CFrame=th.CFrame+Vector3.new(2,1,0) end) notify("Teleport","Teleported to "..selectedPl.Name,3) end
    end)
end

-- ── Saved Positions ──
section(tpTab,"Saved Positions")

actionBtn(tpTab,"Save Current Position","Saves where you are standing right now",function()
    local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not h then notify("Save","No character found.",3,T.Red) return end
    local name="Position "..tostring(#savedPos+1)
    table.insert(savedPos,{name=name,cf=h.CFrame})
    notify("Saved","Saved as \""..name.."\"",3,T.Green)
    _G.__cobaltRefreshPos()
end)

-- positions container
do
    local o=tpTab.nextOrder()
    local posFrame=Instance.new("Frame")
    posFrame.Size=UDim2.new(1,0,0,10)
    posFrame.AutomaticSize=Enum.AutomaticSize.Y
    posFrame.BackgroundTransparency=1
    posFrame.LayoutOrder=o
    posFrame.Parent=tpTab.page

    local posLL=Instance.new("UIListLayout") posLL.SortOrder=Enum.SortOrder.LayoutOrder posLL.Padding=UDim.new(0,5) posLL.Parent=posFrame

    local function refresh()
        for _,c in ipairs(posFrame:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        if #savedPos==0 then
            local none=Instance.new("Frame") none.Size=UDim2.new(1,0,0,36) none.BackgroundColor3=T.Card none.BorderSizePixel=0 none.LayoutOrder=1 none.Parent=posFrame rnd(none,7) brd(none,T.Border)
            lbl(none,{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,12,0,0),Text="No positions saved yet.",TextSize=12,TextColor3=T.Dim})
            return
        end
        for i,pos in ipairs(savedPos) do
            local idx=i
            local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,56) row.BackgroundColor3=T.Card row.BorderSizePixel=0 row.LayoutOrder=idx row.Parent=posFrame rnd(row,7) brd(row,T.Border)

            -- name textbox
            local nb=Instance.new("TextBox") nb.Size=UDim2.new(1,-116,0,22) nb.Position=UDim2.new(0,10,0,7)
            nb.BackgroundColor3=T.Panel nb.BorderSizePixel=0 nb.Text=pos.name nb.TextSize=13
            nb.Font=Enum.Font.GothamSemibold nb.TextColor3=T.Text nb.PlaceholderText="Name..."
            nb.TextXAlignment=Enum.TextXAlignment.Left nb.ClearTextOnFocus=false nb.Parent=row rnd(nb,5) brd(nb,T.Border)
            local nbp=Instance.new("UIPadding") nbp.PaddingLeft=UDim.new(0,6) nbp.Parent=nb
            nb.FocusLost:Connect(function() if nb.Text~="" then savedPos[idx].name=nb.Text end end)

            -- coords
            local cf=pos.cf
            lbl(row,{Size=UDim2.new(1,-116,0,16),Position=UDim2.new(0,10,0,30),
                Text=string.format("%.0f, %.0f, %.0f",cf.X,cf.Y,cf.Z),
                TextSize=10,Font=Enum.Font.Code,TextColor3=T.Dim})

            -- GO
            local goB=Instance.new("TextButton") goB.Size=UDim2.new(0,44,0,38) goB.Position=UDim2.new(1,-106,0.5,-19)
            goB.BackgroundColor3=T.AccentDim goB.Text="GO" goB.TextSize=11 goB.Font=Enum.Font.GothamBold
            goB.TextColor3=T.AccentGlo goB.BorderSizePixel=0 goB.Parent=row rnd(goB,6)
            goB.MouseButton1Click:Connect(function()
                local mh=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if mh then pcall(function() mh.CFrame=savedPos[idx].cf end) notify("TP","Went to \""..savedPos[idx].name.."\"",3)
                else notify("TP","No character!",3,T.Red) end
            end)
            goB.MouseEnter:Connect(function() tw(goB,{BackgroundColor3=T.Accent}) end)
            goB.MouseLeave:Connect(function() tw(goB,{BackgroundColor3=T.AccentDim}) end)

            -- DEL
            local delB=Instance.new("TextButton") delB.Size=UDim2.new(0,44,0,38) delB.Position=UDim2.new(1,-54,0.5,-19)
            delB.BackgroundColor3=Color3.fromRGB(38,12,12) delB.Text="DEL" delB.TextSize=10
            delB.Font=Enum.Font.GothamBold delB.TextColor3=T.Red delB.BorderSizePixel=0 delB.Parent=row rnd(delB,6)
            delB.MouseButton1Click:Connect(function()
                local n=savedPos[idx].name table.remove(savedPos,idx) refresh()
                notify("Deleted","\""..n.."\" removed",3)
            end)
            delB.MouseEnter:Connect(function() tw(delB,{BackgroundColor3=Color3.fromRGB(65,16,16)}) end)
            delB.MouseLeave:Connect(function() tw(delB,{BackgroundColor3=Color3.fromRGB(38,12,12)}) end)
        end
    end

    _G.__cobaltRefreshPos=refresh
    refresh()
end

-- ╔══════════════════════════════════════╗
-- ║  MISC TAB                            ║
-- ╚══════════════════════════════════════╝
local miscTab=newTab("Misc")
section(miscTab,"Movement")
toggle(miscTab,"Fly","WASD + Space / Shift — camera-relative flight",function(v) Fly=v if v then task.spawn(startFly) end notify("Fly",v and"Enabled"or"Disabled",3) end)
toggle(miscTab,"Noclip","Walk through all parts and walls",function(v) Noclip=v if v then task.spawn(startNoclip) end notify("Noclip",v and"Enabled"or"Disabled",3) end)
toggle(miscTab,"Speed Hack","Sets walkspeed to 80",function(v) Speed=v setSpeed(v) notify("Speed",v and"WalkSpeed → 80"or"WalkSpeed → 16",3) end)
toggle(miscTab,"Infinite Jump","Jump again mid-air",function(v) InfJump=v notify("Infinite Jump",v and"Enabled"or"Disabled",3) end)
section(miscTab,"Utility")
actionBtn(miscTab,"Teleport to Spawn","Moves you to the map spawn point",function()
    local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if h then local sp=workspace:FindFirstChildOfClass("SpawnLocation")
        if sp then pcall(function() h.CFrame=sp.CFrame+Vector3.new(0,3,0) end) notify("Teleport","Moved to spawn.",3)
        else notify("Teleport","No SpawnLocation found.",3,T.Yellow) end
    end
end)
actionBtn(miscTab,"Reset Character","Kills and respawns your character",function()
    local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then h.Health=0 notify("Reset","Character reset.",3) end
end)

-- ╔══════════════════════════════════════╗
-- ║  STATS TAB                           ║
-- ╚══════════════════════════════════════╝
local statsTab=newTab("Stats")
section(statsTab,"Live Monitor")
do
    local o=statsTab.nextOrder()
    local card=Instance.new("Frame") card.Size=UDim2.new(1,0,0,250) card.BackgroundColor3=T.Card card.BorderSizePixel=0 card.LayoutOrder=o card.Parent=statsTab.page rnd(card,7) brd(card,T.Border)
    local body=Instance.new("TextLabel") body.Size=UDim2.new(1,-20,1,-16) body.Position=UDim2.new(0,10,0,10) body.BackgroundTransparency=1 body.RichText=true body.Text="..." body.TextSize=13 body.Font=Enum.Font.Code body.TextColor3=T.Text body.TextXAlignment=Enum.TextXAlignment.Left body.TextYAlignment=Enum.TextYAlignment.Top body.Parent=card
    local frames,fps,fpsT=0,0,tick()
    RunService.RenderStepped:Connect(function() frames+=1 if tick()-fpsT>=1 then fps=frames frames=0 fpsT=tick() end end)
    local function dot(b) return b and "<font color='#37CC77'>● ON</font>" or "<font color='#3a3a3a'>○ off</font>" end
    task.spawn(function()
        while card.Parent do
            local cash="?" local ls=LP:FindFirstChild("leaderstats") local c=ls and ls:FindFirstChild("Cash") if c then cash=tostring(c.Value) end
            local prog=evoProg() or 0
            body.Text=string.format(
                "<font color='#484848'>FPS        </font><font color='#99bbff'>%d</font>\n"
             .. "<font color='#484848'>Cash       </font><font color='#99bbff'>%s</font>\n"
             .. "<font color='#484848'>Evolve %%   </font><font color='#99bbff'>%.1f%%</font>\n\n"
             .. "<font color='#484848'>Buys       </font><font color='#99bbff'>%d  </font>%s\n"
             .. "<font color='#484848'>Upgrades   </font><font color='#99bbff'>%d  </font>%s\n"
             .. "<font color='#484848'>Fruit      </font><font color='#99bbff'>%d  </font>%s\n"
             .. "<font color='#484848'>Rebirths   </font><font color='#99bbff'>%d  </font>%s\n"
             .. "<font color='#484848'>Evolves    </font><font color='#99bbff'>%d  </font>%s",
                fps,cash,prog,
                stats.buys,dot(AutoBuy),stats.upgrades,dot(AutoUpgrade),
                stats.fruit,dot(AutoFruit),stats.rebirths,dot(AutoRebirth),stats.evolves,dot(AutoEvolve))
            task.wait(0.25)
        end
    end)
end

-- ╔══════════════════════════════════════╗
-- ║  CREDITS TAB                         ║
-- ╚══════════════════════════════════════╝
local credTab=newTab("Info")
section(credTab,"Credits")
do
    local o=credTab.nextOrder()
    local card=Instance.new("Frame") card.Size=UDim2.new(1,0,0,108) card.BackgroundColor3=T.Card card.BorderSizePixel=0 card.LayoutOrder=o card.Parent=credTab.page rnd(card,7) brd(card,T.Border)
    lbl(card,{Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,0,12),Text="cobalt",TextSize=34,Font=Enum.Font.GothamBold,TextColor3=T.Accent,TextXAlignment=Enum.TextXAlignment.Center})
    lbl(card,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,50),Text="sell lemons autofarm  •  v4.1",TextSize=11,TextColor3=T.Dim,TextXAlignment=Enum.TextXAlignment.Center})
    lbl(card,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,70),Text="made by  poetry",TextSize=12,Font=Enum.Font.GothamSemibold,TextColor3=T.Sub,TextXAlignment=Enum.TextXAlignment.Center})
end
section(credTab,"Links")
actionBtn(credTab,"guns.lol/erode","Click to copy profile link to clipboard",function()
    pcall(function() setclipboard("https://guns.lol/erode") end)
    notify("Copied","guns.lol/erode copied to clipboard",4,T.Green)
end)

-- ── activate Farm tab ──
do
    farmTab.page.Visible=true
    farmTab.btn.BackgroundColor3=T.Accent
    farmTab.btn.TextColor3=T.White
    activeTab=farmTab
end

-- footer
lbl(Win,{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-16),Text="cobalt  •  poetry",TextSize=9,TextColor3=T.Dim,TextXAlignment=Enum.TextXAlignment.Center})

notify("Cobalt","Loaded — tycoon found.",4)
