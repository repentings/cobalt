--[[
   ██████╗ ██████╗ ██████╗  █████╗ ██╗  ████████╗
  ██╔════╝██╔═══██╗██╔══██╗██╔══██╗██║  ╚══██╔══╝
  ██║     ██║   ██║██████╔╝███████║██║     ██║
  ██║     ██║   ██║██╔══██╗██╔══██║██║     ██║
  ╚██████╗╚██████╔╝██████╔╝██║  ██║███████╗██║
   ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝
  Sell Lemons  •  v3.0  •  cobalt
--]]

-- ═══════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════
local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenSvc   = game:GetService("TweenService")
local LP         = Players.LocalPlayer

-- ═══════════════════════════════════════════════
--  THEME
-- ═══════════════════════════════════════════════
local BG      = Color3.fromRGB(9,  13, 25)
local PANEL   = Color3.fromRGB(14, 20, 38)
local CARD    = Color3.fromRGB(20, 28, 52)
local BORDER  = Color3.fromRGB(38, 58, 110)
local ACCENT  = Color3.fromRGB(58, 130, 255)
local ADIM    = Color3.fromRGB(24, 58, 140)
local AGLOW   = Color3.fromRGB(100,168,255)
local GREEN   = Color3.fromRGB(60, 220, 130)
local MUTED   = Color3.fromRGB(90, 115, 170)
local TEXT    = Color3.fromRGB(215, 225, 255)
local WHITE   = Color3.fromRGB(255, 255, 255)

-- ═══════════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════════
local function rnd(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
end

local function brdr(p, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or BORDER
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
end

local function tween(obj, props, dur, style)
    TweenSvc:Create(obj, TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quad), props):Play()
end

-- Stats are included in the game tab
do
    local p = gameTab.page
    makeSection(p,"Live Monitor")
    sectionOrder = sectionOrder+1

    card.Size = UDim2.new(1,0,0,260)
    card.BorderSizePixel = 0
    card.LayoutOrder = sectionOrder
    card.Parent = p
    rnd(card,8) brdr(card,BORDER,1)

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1,-20,1,-16)
    body.Position = UDim2.new(0,10,0,10)
    body.BackgroundTransparency = 1
    body.RichText = true
    body.Text = "loading..."
    body.TextSize = 13
    body.Font = Enum.Font.Code
    body.TextColor3 = TEXT
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.Parent = card

    local frames,fps,fpsT = 0,0,tick()
    RunService.RenderStepped:Connect(function()
        frames=frames+1
        if tick()-fpsT>=1 then fps=frames frames=0 fpsT=tick() end
    end)

    local function dot(b)
        return b and "<font color='#3CDC82'>● ON</font>" or "<font color='#556688'>○ off</font>"
    end

    task.spawn(function()
        while card.Parent do
            local cash = "?"
            local ls = LP:FindFirstChild("leaderstats")
            local c  = ls and ls:FindFirstChild("Cash")
            if c then cash = tostring(c.Value) end
            local prog = getEvolveProgress() or 0

            body.Text = string.format(
                "<font color='#5588BB'>FPS        </font><font color='#AACCFF'>%d</font>\n"
             .. "<font color='#5588BB'>Cash       </font><font color='#AACCFF'>%s</font>\n"
             .. "<font color='#5588BB'>Evolve     </font><font color='#AACCFF'>%.1f%%</font>\n\n"
             .. "<font color='#5588BB'>Buys       </font><font color='#AACCFF'>%d  </font>%s\n"
             .. "<font color='#5588BB'>Upgrades   </font><font color='#AACCFF'>%d  </font>%s\n"
             .. "<font color='#5588BB'>Fruit      </font><font color='#AACCFF'>%d  </font>%s\n"
             .. "<font color='#5588BB'>Rebirths   </font><font color='#AACCFF'>%d  </font>%s\n"
             .. "<font color='#5588BB'>Evolves    </font><font color='#AACCFF'>%d  </font>%s",
                fps, cash, prog,
                stats.buys,     dot(AutoBuy),
                stats.upgrades, dot(AutoUpgrade),
                stats.fruit,    dot(AutoFruit),
                stats.rebirths, dot(AutoRebirth),
                stats.evolves,  dot(AutoEvolve)
            )
            task.wait(0.25)
        end
    end)
end
            end
        end
    end
end)()

if not userTycoon then
    notify("Cobalt — Error", "No tycoon found. Claim one first.", 8)
    return
end

-- ═══════════════════════════════════════════════
--  STATE
-- ═══════════════════════════════════════════════
local AutoBuy        = false
local AutoUpgrade    = false
local AutoFruit      = false
local AutoRebirth    = false
local AutoEvolve     = false
local AutoPowerLevel = false
-- speeds (seconds between actions when enabled)
local AutoBuySpeed        = 0.01
local AutoUpgradeSpeed    = 0.05
local AutoFruitSpeed      = 0.1
local AutoRebirthSpeed    = 0.5
local AutoEvolveSpeed     = 0.5
local AutoPowerLevelSpeed = 0.25
local FlyEnabled     = false
local NoclipEnabled  = false
local SpeedEnabled   = false
local InfJumpEnabled = false

local stats = { buys=0, upgrades=0, fruit=0, rebirths=0, evolves=0 }

-- ═══════════════════════════════════════════════
--  AUTO BUY
-- ═══════════════════════════════════════════════
local function buyAllAffordable()
    local purchases = userTycoon:FindFirstChild("Purchases")
    if not purchases then return end
    for _, obj in ipairs(purchases:GetDescendants()) do
        if obj:IsA("Model") then
            if obj:GetAttribute("Shown") == true and obj:GetAttribute("Purchased") ~= true then
                local rem = obj:FindFirstChild("Purchase")
                if rem and rem:IsA("RemoteFunction") then
                    pcall(function() rem:InvokeServer() end)
                    stats.buys = stats.buys + 1
                end
            end
        end
    end
end
task.spawn(function()
    while true do
        if AutoBuy then
            pcall(buyAllAffordable)
            task.wait(AutoBuySpeed or 0.01)
        else
            task.wait(0.5)
        end
    end
end)

-- ═══════════════════════════════════════════════
--  AUTO UPGRADE
-- ═══════════════════════════════════════════════
local upgradeRemotes = {}
local upgradeLevel   = {}
local lastScan       = 0
local function refreshUpgrades()
    upgradeRemotes = {} upgradeLevel = {}
    local p = userTycoon:FindFirstChild("Purchases")
    if not p then return end
    for _, obj in ipairs(p:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name == "Upgrade" then
            upgradeRemotes[#upgradeRemotes+1] = obj
        end
    end
end
task.spawn(function()
    while true do
        if AutoUpgrade then
            if tick()-lastScan > 3 then refreshUpgrades() lastScan=tick() end
            for _, rem in ipairs(upgradeRemotes) do
                if rem.Parent then
                    local lvl = (upgradeLevel[rem] or 0)+1
                    while lvl <= 100 do
                        local ok,res = pcall(function() return rem:InvokeServer(lvl) end)
                        if (not ok) or res == false then break end
                        upgradeLevel[rem] = lvl
                        stats.upgrades = stats.upgrades+1
                        lvl = lvl+1
                    end
                end
            end
            task.wait(AutoUpgradeSpeed or 0.05)
        else
            task.wait(0.5)
        end
    end
end)

-- ═══════════════════════════════════════════════
--  AUTO POWER LEVEL
-- ═══════════════════════════════════════════════
local function getPLRemote()
    local r = userTycoon:FindFirstChild("Remotes")
    return r and r:FindFirstChild("UpgradePowerLevel")
end
task.spawn(function()
    while true do
        if AutoPowerLevel then
            local rem = getPLRemote()
            if rem then pcall(function() rem:InvokeServer() end) end
            task.wait(AutoPowerLevelSpeed or 0.25)
        else
            task.wait(0.5)
        end
    end
end)

-- ═══════════════════════════════════════════════
--  REBIRTH
-- ═══════════════════════════════════════════════
local NUM_SCALE = {
    thousand=1e3,million=1e6,billion=1e9,trillion=1e12,quadrillion=1e15,
    quintillion=1e18,sextillion=1e21,septillion=1e24,
    k=1e3,m=1e6,b=1e9,t=1e12,qd=1e15,qn=1e18,sx=1e21,sp=1e24,
}
local function parseNum(s)
    if not s then return nil end
    s = tostring(s):gsub(",",""):lower()
    local n = s:match("[%d%.]+")
    local v = n and tonumber(n)
    if not v then return nil end
    local w = s:match("[%d%.%s]+([a-z]+)")
    if w and NUM_SCALE[w] then v = v*NUM_SCALE[w] end
    return v
end
local function getRebirthRemote()
    local r = userTycoon:FindFirstChild("Remotes")
    return r and r:FindFirstChild("Rebirth")
end
local function getRebirthedSignal()
    local r = userTycoon:FindFirstChild("Remotes")
    return r and r:FindFirstChild("Rebirthed")
end
local function investorBody()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local r  = pg and pg:FindFirstChild("Rebirth")
    local im = r and r:FindFirstChild("InvestorsMenu")
    return im and im:FindFirstChild("Body")
end
local function readQty(name)
    local b = investorBody()
    local f = b and b:FindFirstChild(name)
    local q = f and f:FindFirstChild("Quantity")
    return q and parseNum(q.Text)
end
local rebirthBusy = false
task.spawn(function()
    while true do
        if AutoRebirth and not rebirthBusy then
            local rem = getRebirthRemote()
            local pot = readQty("Potential")
            local cur = readQty("Amount") or 0
            if rem and pot and pot >= 1 and pot >= cur*1.0 then
                rebirthBusy = true
                pcall(function()
                    local done=false
                    local sig = getRebirthedSignal()
                    local conn
                    if sig and sig:IsA("RemoteEvent") then
                        conn = sig.OnClientEvent:Connect(function() done=true end)
                    end
                    rem:InvokeServer()
                    stats.rebirths = stats.rebirths+1
                    local t=0
                    while not done and t<8 do task.wait(0.1) t=t+0.1 end
                    if conn then conn:Disconnect() end
                end)
                task.wait(2)
                rebirthBusy = false
            end
            task.wait(AutoRebirthSpeed or 0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- ═══════════════════════════════════════════════
--  EVOLVE
-- ═══════════════════════════════════════════════
local function getEvolveRemote()
    local r = userTycoon:FindFirstChild("Remotes")
    return r and r:FindFirstChild("Evolve")
end
local function getEvolvedSignal()
    local r = userTycoon:FindFirstChild("Remotes")
    return r and r:FindFirstChild("Evolved")
end
local function getEvolveProgress()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local r  = pg and pg:FindFirstChild("Rebirth")
    local em = r and r:FindFirstChild("EvolutionMenu")
    local b  = em and em:FindFirstChild("Body")
    local p  = b and b:FindFirstChild("Progress")
    if not p then return nil end
    return tonumber(tostring(p.Text):match("[%d%.]+"))
end
local evolveBusy = false
task.spawn(function()
    while true do
        if AutoEvolve and not evolveBusy then
            local rem  = getEvolveRemote()
            local prog = getEvolveProgress()
            if rem and prog and prog >= 100 then
                evolveBusy = true
                pcall(function()
                    local done=false
                    local sig = getEvolvedSignal()
                    local conn
                    if sig and sig:IsA("RemoteEvent") then
                        conn = sig.OnClientEvent:Connect(function() done=true end)
                    end
                    rem:InvokeServer()
                    stats.evolves = stats.evolves+1
                    local t=0
                    while not done and t<8 do task.wait(0.1) t=t+0.1 end
                    if conn then conn:Disconnect() end
                end)
                task.wait(2)
                evolveBusy = false
            end
            task.wait(AutoEvolveSpeed or 0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- ═══════════════════════════════════════════════
--  SEWER
-- ═══════════════════════════════════════════════
local function touchPart(hrp, part)
    pcall(function() firetouchinterest(hrp,part,0) firetouchinterest(hrp,part,1) end)
end
local function pullAllLevers()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    local sewer = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
    local root  = sewer or workspace
    local n = 0
    for _, o in ipairs(root:GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name),"lever",1,true) then
            pcall(function() firetouchinterest(hrp,o,0) firetouchinterest(hrp,o,1) end)
            n = n+1
        end
    end
    if sewer then
        for _, o in ipairs(sewer:GetDescendants()) do
            if o:IsA("BasePart") and (o.Name=="VineKey" or o.Name=="UFOKey") then
                pcall(function() firetouchinterest(hrp,o,0) firetouchinterest(hrp,o,1) end)
            end
        end
    end
    return n
end
local function doSewerRun()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false,"no character" end
    local sewer = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
    if not sewer then return false,"sewer not loaded" end
    for _, o in ipairs(sewer:GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name),"lever",1,true) then touchPart(hrp,o) end
    end
    for _, fn in ipairs({"CashVine","SewerAlien"}) do
        local f = sewer:FindFirstChild(fn)
        if f then
            for _, o in ipairs(f:GetDescendants()) do
                if o:IsA("BasePart") and (o.Name=="VineKey" or o.Name=="UFOKey") then touchPart(hrp,o) end
            end
        end
    end
    task.wait(0.3)
    local cv = sewer:FindFirstChild("CashVine")
    if cv then
        local vd = cv:FindFirstChild("VineDoor")
        if vd then for _, o in ipairs(vd:GetDescendants()) do if o:IsA("BasePart") then touchPart(hrp,o) end end end
    end
    task.wait(0.3)
    if cv then
        local vm = cv:FindFirstChild("CashVine")
        if vm then
            pcall(function() hrp.CFrame = vm:GetPivot()+Vector3.new(0,3,0) end)
            task.wait(0.2)
            for _, o in ipairs(vm:GetDescendants()) do if o:IsA("BasePart") then touchPart(hrp,o) end end
        end
    end
    return true
end
local function teleportToAlien()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false,"no character" end
    pcall(function() hrp.CFrame = CFrame.new(-42,-41,180) end)
    return true
end

-- ═══════════════════════════════════════════════
--  AUTO FRUIT
-- ═══════════════════════════════════════════════
local Trees = {}
local function addTree(o)
    if o:IsA("Model") and o.Name=="LemonTree" and not table.find(Trees,o) then table.insert(Trees,o) end
end
local function remTree(o)
    local i = table.find(Trees,o) if i then table.remove(Trees,i) end
end
for _, v in ipairs(workspace:GetDescendants()) do addTree(v) end
workspace.DescendantAdded:Connect(addTree)
workspace.DescendantRemoving:Connect(remTree)
task.spawn(function()
    while true do
        if AutoFruit then
            for _, tree in ipairs(Trees) do
                if not AutoFruit then break end
                if tree and tree.Parent then
                    pcall(function()
                        local char = LP.Character
                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        for _, o in ipairs(tree:GetDescendants()) do
                            if o:IsA("BasePart") then o.CanCollide = false end
                        end
                        hrp.CFrame = tree:GetPivot()+Vector3.new(0,5,0)
                        for _, o in ipairs(tree:GetDescendants()) do
                            if o:IsA("BasePart") and o.Name=="Fruit" then
                                o.CanCollide = false
                                local cp = o:FindFirstChild("ClickPart")
                                if cp then
                                    local det = cp:FindFirstChildOfClass("ClickDetector")
                                    if det then
                                        task.wait(0.25)
                                        pcall(function() fireclickdetector(det) end)
                                        stats.fruit = stats.fruit+1
                                    end
                                end
                            end
                        end
                    end)
                end
            end
            task.wait(AutoFruitSpeed or 0.1)
        else
            task.wait(0.5)
        end
    end
end)

-- ═══════════════════════════════════════════════
--  MISC: FLY
-- ═══════════════════════════════════════════════
local flyConn
local function startFly()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.D = 100 bg.Parent = hrp
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = hrp
    hum.PlatformStand = true
    local SPEED = 150
    flyConn = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then
            bg:Destroy() bv:Destroy()
            hum.PlatformStand = false
            flyConn:Disconnect()
            return
        end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit*SPEED or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

-- ═══════════════════════════════════════════════
--  MISC: NOCLIP
-- ═══════════════════════════════════════════════
local noclipConn
local function startNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not NoclipEnabled then noclipConn:Disconnect() return end
        local char = LP.Character
        if not char then return end
        for _, o in ipairs(char:GetDescendants()) do
            if o:IsA("BasePart") then o.CanCollide = false end
        end
    end)
end

-- ═══════════════════════════════════════════════
--  MISC: SPEED
-- ═══════════════════════════════════════════════
local DEFAULT_SPEED = 16
local function setSpeed(enabled)
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = enabled and 80 or DEFAULT_SPEED end
end
LP.CharacterAdded:Connect(function(char)
    if SpeedEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = 80
    end
end)

-- ═══════════════════════════════════════════════
--  MISC: INF JUMP
-- ═══════════════════════════════════════════════
UIS.JumpRequest:Connect(function()
    if InfJumpEnabled then
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════
--  BUILD GUI
-- ═══════════════════════════════════════════════════════════════════
local guiParent = LP:FindFirstChildOfClass("PlayerGui")
if not guiParent then
    local ok,h = pcall(gethui) guiParent = (ok and h) or game:GetService("CoreGui")
end
for _, n in ipairs({"CobaltGui","CobaltNotif","AutoStatusGui"}) do
    local old = guiParent:FindFirstChild(n) if old then old:Destroy() end
end

local SG = Instance.new("ScreenGui")
SG.Name = "CobaltGui"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.DisplayOrder = 9999
SG.Parent = guiParent

-- ── MAIN FRAME ──
local W, H = 360, 480
local Win = Instance.new("Frame")
Win.Name = "Win"
Win.Size = UDim2.new(0,W,0,H)
Win.Position = UDim2.new(0.5,-W/2,0.5,-H/2)
Win.BackgroundColor3 = BG
Win.BorderSizePixel = 0
Win.ClipsDescendants = true
Win.Parent = SG
rnd(Win,10) brdr(Win,BORDER,1)

-- accent line top
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1,0,0,2)
accentLine.BackgroundColor3 = ACCENT
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 5
accentLine.Parent = Win

-- ── TITLE BAR ──
local TB = Instance.new("Frame")
TB.Size = UDim2.new(1,0,0,44)
TB.Position = UDim2.new(0,0,0,2)
TB.BackgroundColor3 = PANEL
TB.BorderSizePixel = 0
TB.Parent = Win

-- logo pill
local logoPill = Instance.new("Frame")
logoPill.Size = UDim2.new(0,8,0,8)
logoPill.Position = UDim2.new(0,14,0.5,-4)
logoPill.BackgroundColor3 = ACCENT
logoPill.BorderSizePixel = 0
logoPill.Parent = TB
rnd(logoPill,4)

local titleTxt = Instance.new("TextLabel")
titleTxt.Size = UDim2.new(0,140,1,0)
titleTxt.Position = UDim2.new(0,30,0,0)
titleTxt.BackgroundTransparency = 1
titleTxt.Text = "cobalt"
titleTxt.TextSize = 16
titleTxt.Font = Enum.Font.GothamBold
titleTxt.TextColor3 = TEXT
titleTxt.TextXAlignment = Enum.TextXAlignment.Left
titleTxt.Parent = TB

local subTxt = Instance.new("TextLabel")
subTxt.Size = UDim2.new(0,160,1,0)
subTxt.Position = UDim2.new(0,30,0,14)
subTxt.BackgroundTransparency = 1
subTxt.Text = "sell lemons"
subTxt.TextSize = 10
subTxt.Font = Enum.Font.Gotham
subTxt.TextColor3 = MUTED
subTxt.TextXAlignment = Enum.TextXAlignment.Left
subTxt.Parent = TB

-- close btn
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-32,0.5,-12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeBtn.Text = "✕"
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = WHITE
closeBtn.BorderSizePixel = 0
closeBtn.Parent = TB
rnd(closeBtn,12)
closeBtn.MouseButton1Click:Connect(function()
    tween(Win,{Size=UDim2.new(0,W,0,0),Position=UDim2.new(0.5,-W/2,0.5,0)},0.25,Enum.EasingStyle.Quint)
    task.wait(0.3) SG:Destroy()
end)

-- minimize btn
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,24,0,24)
minBtn.Position = UDim2.new(1,-60,0.5,-12)
minBtn.BackgroundColor3 = ADIM
minBtn.Text = "−"
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.TextColor3 = AGLOW
minBtn.BorderSizePixel = 0
minBtn.Parent = TB
rnd(minBtn,12)
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tween(Win,{Size=UDim2.new(0,W,0,minimized and 46 or H)},0.25,Enum.EasingStyle.Quint)
end)

-- drag
local drag,ds,dp = false,nil,nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true ds=i.Position dp=Win.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-ds
        Win.Position = UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
    end
end)

-- ── TAB BAR ──
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,-16,0,32)
TabBar.Position = UDim2.new(0,8,0,50)
TabBar.BackgroundColor3 = PANEL
TabBar.BorderSizePixel = 0
TabBar.Parent = Win
rnd(TabBar,8)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0,3)
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = TabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0,4)
tabPad.PaddingRight = UDim.new(0,4)
tabPad.Parent = TabBar

-- ── CONTENT ──
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-16,1,-98)
Content.Position = UDim2.new(0,8,0,88)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Win

-- ══════════════════════════════════════════
--  TAB / TOGGLE / BUTTON FACTORIES
-- ══════════════════════════════════════════

local allTabs = {}
local currentTab = nil

local function switchTab(tab)
    if currentTab then
        currentTab.page.Visible = false
        currentTab.btn.BackgroundColor3 = Color3.fromRGB(20,28,50)
        currentTab.btn.TextColor3 = MUTED
    end
    currentTab = tab
    tab.page.Visible = true
    tab.btn.BackgroundColor3 = ACCENT
    tab.btn.TextColor3 = WHITE
end

local function makeTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,60,1,-6)
    btn.BackgroundColor3 = Color3.fromRGB(20,28,50)
    btn.Text = name
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = MUTED
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    rnd(btn,6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ADIM
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,5)
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0,10)
    pad.PaddingTop = UDim.new(0,4)
    pad.Parent = page

    local tab = {btn=btn, page=page}
    allTabs[#allTabs+1] = tab

    btn.MouseButton1Click:Connect(function() switchTab(tab) end)
    return tab
end

-- section label
local sectionOrder = 0
local function makeSection(page, text)
    sectionOrder = sectionOrder+1
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,22)
    f.BackgroundTransparency = 1
    f.LayoutOrder = sectionOrder
    f.Parent = page

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-8,1,0)
    l.Position = UDim2.new(0,4,0,0)
    l.BackgroundTransparency = 1
    l.Text = "  " .. text:upper()
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = ACCENT
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    -- divider
    local div = Instance.new("Frame")
    div.Size = UDim2.new(1,-8,0,1)
    div.Position = UDim2.new(0,4,1,-1)
    div.BackgroundColor3 = BORDER
    div.BorderSizePixel = 0
    div.Parent = f
end

-- toggle
local function makeToggle(page, labelText, descText, callback)
    sectionOrder = sectionOrder+1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,54)
    row.BackgroundColor3 = CARD
    row.BorderSizePixel = 0
    row.LayoutOrder = sectionOrder
    row.Parent = page
    rnd(row,8) brdr(row,BORDER,1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-62,0,20)
    lbl.Position = UDim2.new(0,12,0,9)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = TEXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1,-62,0,16)
    desc.Position = UDim2.new(0,12,0,30)
    desc.BackgroundTransparency = 1
    desc.Text = descText or ""
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextColor3 = MUTED
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0,42,0,22)
    pill.Position = UDim2.new(1,-54,0.5,-11)
    pill.BackgroundColor3 = BORDER
    pill.BorderSizePixel = 0
    pill.Parent = row
    rnd(pill,11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = MUTED
    knob.BorderSizePixel = 0
    knob.Parent = pill
    rnd(knob,8)

    local on = false
    local function set(v)
        on = v
        tween(pill,{BackgroundColor3 = v and ACCENT or BORDER})
        tween(knob,{
            Position = v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3 = v and WHITE or MUTED,
        })
        callback(v)
    end

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = row
    clickBtn.MouseButton1Click:Connect(function() set(not on) end)
    clickBtn.MouseEnter:Connect(function() tween(row,{BackgroundColor3=Color3.fromRGB(26,36,66)}) end)
    clickBtn.MouseLeave:Connect(function() tween(row,{BackgroundColor3=CARD}) end)

    return set
end

-- action button
local function makeButton(page, labelText, descText, callback)
    sectionOrder = sectionOrder+1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,54)
    row.BackgroundColor3 = CARD
    row.BorderSizePixel = 0
    row.LayoutOrder = sectionOrder
    row.Parent = page
    rnd(row,8) brdr(row,BORDER,1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-52,0,20)
    lbl.Position = UDim2.new(0,12,0,9)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = TEXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1,-52,0,16)
    desc.Position = UDim2.new(0,12,0,30)
    desc.BackgroundTransparency = 1
    desc.Text = descText or ""
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextColor3 = MUTED
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0,32,0,32)
    pill.Position = UDim2.new(1,-42,0.5,-16)
    pill.BackgroundColor3 = ADIM
    pill.BorderSizePixel = 0
    pill.Parent = row
    rnd(pill,8)

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(1,0,1,0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▶"
    arrow.TextSize = 13
    arrow.Font = Enum.Font.GothamBold
    arrow.TextColor3 = AGLOW
    arrow.Parent = pill

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = row
    clickBtn.MouseButton1Click:Connect(function()
        tween(row,{BackgroundColor3=ADIM},0.08)
        tween(pill,{BackgroundColor3=ACCENT},0.08)
        task.wait(0.12)
        tween(row,{BackgroundColor3=CARD},0.2)
        tween(pill,{BackgroundColor3=ADIM},0.2)
        callback()
    end)
    clickBtn.MouseEnter:Connect(function() tween(row,{BackgroundColor3=Color3.fromRGB(26,36,66)}) end)
    clickBtn.MouseLeave:Connect(function() tween(row,{BackgroundColor3=CARD}) end)
end

-- ══════════════════════════════════════════
--  GAME TAB (uses current subtitle as name)
-- ══════════════════════════════════════════
local gameTab = makeTab(subTxt.Text)
do
    local p = gameTab.page
    makeSection(p,"Automation")
    makeToggle(p,"Auto Buy","Buys all affordable items instantly",function(v) AutoBuy=v notify("Auto Buy",v and"Enabled"or"Disabled",3) end)
    makeToggle(p,"Auto Upgrade","Upgrades machines as cash grows",function(v) AutoUpgrade=v notify("Auto Upgrade",v and"Enabled"or"Disabled",3) end)
    makeToggle(p,"Auto Fruit","Teleports to each lemon tree & collects",function(v) AutoFruit=v notify("Auto Fruit",v and"Enabled"or"Disabled",3) end)
    makeToggle(p,"Auto Power Level","Spams UpgradePowerLevel remote",function(v) AutoPowerLevel=v notify("Auto Power Level",v and"Enabled"or"Disabled",3) end)
    makeSection(p,"Progression")
    makeToggle(p,"Auto Rebirth","Rebirths when investors payout is worth it",function(v)
        AutoRebirth=v
        if v and not getRebirthRemote() then notify("Auto Rebirth","Remote not found!",5) return end
        notify("Auto Rebirth",v and"Enabled"or"Disabled",3)
    end)
    makeToggle(p,"Auto Evolve","Evolves at 100% progress (×10 income speed)",function(v)
        AutoEvolve=v
        if v and not getEvolveRemote() then notify("Auto Evolve","Remote not found!",5) return end
        notify("Auto Evolve",v and"Enabled"or"Disabled",3)
    end)
end

-- Sewers/actions are now part of the game tab
do
    local p = gameTab.page
    makeSection(p,"Sewer Actions")
    makeButton(p,"Pull All Levers","Fire all sewer door levers + grab keys",function()
        local n = pullAllLevers()
        notify("Pull Levers", n>0 and("Pulled "..n.." lever(s) + keys grabbed") or "No levers found",4)
    end)
    makeButton(p,"Vine Harvest","Full run: levers → keys → door → vine",function()
        notify("Vine Harvest","Running sewer sequence...",2)
        task.spawn(function()
            local ok,err = doSewerRun()
            notify("Vine Harvest",ok and"Done! Everything collected." or("Failed: "..tostring(err)),5)
        end)
    end)
    makeButton(p,"Teleport to Alien","Jump to sewer alien (UFO key location)",function()
        local ok,err = teleportToAlien()
        notify("Sewer Alien",ok and"Teleported to the UFO alien." or("Failed: "..tostring(err)),3)
    end)
end

-- ══════════════════════════════════════════
--  MISC TAB
-- ══════════════════════════════════════════
local miscTab = makeTab("Misc")
do
    local p = miscTab.page
    makeSection(p,"Movement")
    makeToggle(p,"Fly","WASD + Space/Shift to fly around freely",function(v)
        FlyEnabled=v
        if v then task.spawn(startFly) end
        notify("Fly",v and"Enabled — WASD+Space to fly"or"Disabled",3)
    end)
    makeToggle(p,"Noclip","Walk through walls and parts",function(v)
        NoclipEnabled=v
        if v then task.spawn(startNoclip) end
        notify("Noclip",v and"Enabled"or"Disabled",3)
    end)
    makeToggle(p,"Speed Hack","Sets walkspeed to 80",function(v)
        SpeedEnabled=v
        setSpeed(v)
        notify("Speed",v and"WalkSpeed → 80"or"WalkSpeed → 16",3)
    end)
    makeToggle(p,"Infinite Jump","Jump again in mid-air",function(v)
        InfJumpEnabled=v
        notify("Infinite Jump",v and"Enabled"or"Disabled",3)
    end)
    makeSection(p,"Utility")
    makeButton(p,"Teleport to Spawn","Moves you to spawn point",function()
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                pcall(function() hrp.CFrame = spawn.CFrame + Vector3.new(0,3,0) end)
                notify("Teleport","Moved to spawn.",3)
            else
                notify("Teleport","No SpawnLocation found.",3)
            end
        end
    end)
    makeButton(p,"Reset Character","Kills and respawns your character",function()
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 notify("Reset","Character reset.",3) end
    end)
    makeButton(p,"Execute Cobalt","Downloads and runs the latest Cobalt script",function()
        notify("Execute","Running Cobalt...",2)
        task.spawn(function()
            pcall(function()
                local ok,err = pcall(function()
                    loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()
                end)
                if not ok then notify("Execute","Failed to run Cobalt",4) end
            end)
        end)
    end)
end

-- Stats are included in the game tab
do
    local p = gameTab.page
    makeSection(p,"Live Monitor")
    sectionOrder = sectionOrder+1

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,260)
    card.BackgroundColor3 = CARD
    card.BorderSizePixel = 0
    card.LayoutOrder = sectionOrder
    card.Parent = p
    rnd(card,8) brdr(card,BORDER,1)

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1,-20,1,-16)
    body.Position = UDim2.new(0,10,0,10)
    body.BackgroundTransparency = 1
    body.RichText = true
    body.Text = "loading..."
    body.TextSize = 13
    body.Font = Enum.Font.Code
    body.TextColor3 = TEXT
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.Parent = card

    local frames,fps,fpsT = 0,0,tick()
    RunService.RenderStepped:Connect(function()
        frames=frames+1
        if tick()-fpsT>=1 then fps=frames frames=0 fpsT=tick() end
    end)

    local function dot(b)
        return b and "<font color='#3CDC82'>● ON</font>" or "<font color='#556688'>○ off</font>"
    end

    task.spawn(function()
        while card.Parent do
            local cash = "?"
            local ls = LP:FindFirstChild("leaderstats")
            local c  = ls and ls:FindFirstChild("Cash")
            if c then cash = tostring(c.Value) end
            local prog = getEvolveProgress() or 0

            body.Text = string.format(
                "<font color='#5588BB'>FPS        </font><font color='#AACCFF'>%d</font>\n"
             .. "<font color='#5588BB'>Cash       </font><font color='#AACCFF'>%s</font>\n"
             .. "<font color='#5588BB'>Evolve     </font><font color='#AACCFF'>%.1f%%</font>\n\n"
             .. "<font color='#5588BB'>Buys       </font><font color='#AACCFF'>%d  </font>%s\n"
             .. "<font color='#5588BB'>Upgrades   </font><font color='#AACCFF'>%d  </font>%s\n"
             .. "<font color='#5588BB'>Fruit      </font><font color='#AACCFF'>%d  </font>%s\n"
             .. "<font color='#5588BB'>Rebirths   </font><font color='#AACCFF'>%d  </font>%s\n"
             .. "<font color='#5588BB'>Evolves    </font><font color='#AACCFF'>%d  </font>%s",
                fps, cash, prog,
                stats.buys,     dot(AutoBuy),
                stats.upgrades, dot(AutoUpgrade),
                stats.fruit,    dot(AutoFruit),
                stats.rebirths, dot(AutoRebirth),
                stats.evolves,  dot(AutoEvolve)
            )
            task.wait(0.25)
        end
    end)
end

-- ══════════════════════════════════════════
--  POSITIONS TAB
-- ══════════════════════════════════════════
local positionsTab = makeTab("Positions")
do
    local p = positionsTab.page
    makeSection(p,"Saved Positions")

    local HttpService = game:GetService("HttpService")
    local positions = {}
    local positionsFolder = "cobalt"
    local positionsFile = positionsFolder.."/positions.json"

    local function canWrite()
        return (writefile and isfolder and makefolder and readfile) or (writefile and readfile)
    end

    local function ensureFolder()
        if isfolder and not isfolder(positionsFolder) then
            pcall(function() makefolder(positionsFolder) end)
        end
    end

    local function savePositionsToFile()
        if not writefile then notify("Positions","File API not available",4) return end
        pcall(function()
            ensureFolder()
            writefile(positionsFile, HttpService:JSONEncode(positions))
            notify("Positions","Saved to file.",2)
        end)
    end

    local function loadPositionsFromFile()
        if not readfile then return end
        pcall(function()
            if isfile and not isfile(positionsFile) then return end
            local content = readfile(positionsFile)
            local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
            if ok and type(data)=="table" then positions = data end
        end)
    end

    loadPositionsFromFile()

    local entriesFrame = Instance.new("Frame")
    entriesFrame.Size = UDim2.new(1,0,0,0)
    entriesFrame.BackgroundTransparency = 1
    entriesFrame.Parent = p

    local entriesLayout = Instance.new("UIListLayout")
    entriesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    entriesLayout.Parent = entriesFrame

    local function refreshEntries()
        for _,c in ipairs(entriesFrame:GetChildren()) do if not (c:IsA("UIListLayout") ) then c:Destroy() end end
        for i,pos in ipairs(positions) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,36)
            row.LayoutOrder = i
            row.BackgroundColor3 = CARD
            row.Parent = entriesFrame
            rnd(row,6) brdr(row,BORDER,1)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.5,0,1,0)
            lbl.Position = UDim2.new(0,8,0,0)
            lbl.BackgroundTransparency = 1
            lbl.Text = pos.name or ("Pos "..i)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 12
            lbl.TextColor3 = TEXT
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local loadBtn = Instance.new("TextButton")
            loadBtn.Size = UDim2.new(0,56,0,24)
            loadBtn.Position = UDim2.new(1,-176,0,6)
            loadBtn.BackgroundColor3 = ADIM
            loadBtn.Text = "Load"
            loadBtn.Font = Enum.Font.GothamBold
            loadBtn.TextColor3 = AGLOW
            loadBtn.Parent = row
            rnd(loadBtn,6)
            loadBtn.MouseButton1Click:Connect(function()
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and pos.pos and pos.rot then
                    pcall(function()
                        local cf = CFrame.new(pos.pos.x,pos.pos.y,pos.pos.z) * CFrame.Angles(pos.rot.x,pos.rot.y,pos.rot.z)
                        hrp.CFrame = cf
                        notify("Positions","Teleported to "..(pos.name or "position"),3)
                    end)
                else
                    notify("Positions","Unable to teleport.",3)
                end
            end)

            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.new(0,56,0,24)
            copyBtn.Position = UDim2.new(1,-112,0,6)
            copyBtn.BackgroundColor3 = ADIM
            copyBtn.Text = "Copy"
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextColor3 = AGLOW
            copyBtn.Parent = row
            rnd(copyBtn,6)
            copyBtn.MouseButton1Click:Connect(function()
                if pos.pos and pos.rot then
                    local s = HttpService:JSONEncode(pos)
                    pcall(function() setclipboard(s) end)
                    notify("Positions","Copied JSON to clipboard.",3)
                end
            end)

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0,56,0,24)
            delBtn.Position = UDim2.new(1,-48,0,6)
            delBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
            delBtn.Text = "Del"
            delBtn.Font = Enum.Font.GothamBold
            delBtn.TextColor3 = WHITE
            delBtn.Parent = row
            rnd(delBtn,6)
            delBtn.MouseButton1Click:Connect(function()
                table.remove(positions, i)
                savePositionsToFile()
                refreshEntries()
            end)
        end
        -- layout sizing
        local total = #positions * 40
        entriesFrame.Size = UDim2.new(1,0,0, total)
    end

    -- input & save controls
    sectionOrder = sectionOrder + 1
    local inputRow = Instance.new("Frame")
    inputRow.Size = UDim2.new(1,0,0,44)
    inputRow.BackgroundColor3 = CARD
    inputRow.LayoutOrder = sectionOrder
    inputRow.Parent = p
    rnd(inputRow,8) brdr(inputRow,BORDER,1)

    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(0.6,0,0,28)
    nameBox.Position = UDim2.new(0,8,0,8)
    nameBox.BackgroundColor3 = Color3.fromRGB(20,24,38)
    nameBox.PlaceholderText = "Name for position"
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 12
    nameBox.TextColor3 = TEXT
    nameBox.Parent = inputRow
    rnd(nameBox,6) brdr(nameBox,BORDER,1)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0,100,0,28)
    saveBtn.Position = UDim2.new(1,-108,0,8)
    saveBtn.BackgroundColor3 = ADIM
    saveBtn.Text = "Save Position"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextColor3 = AGLOW
    saveBtn.Parent = inputRow
    rnd(saveBtn,6)
    saveBtn.MouseButton1Click:Connect(function()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("Positions","No character found.",3) return end
        local posv = hrp.Position
        local rx,ry,rz = hrp.CFrame:ToOrientation()
        local name = nameBox.Text or ("Pos "..(#positions+1))
        if name=="" then name = "Pos "..(#positions+1) end
        local entry = {name = name, pos = {x=posv.X,y=posv.Y,z=posv.Z}, rot = {x=rx,y=ry,z=rz}}
        table.insert(positions, entry)
        savePositionsToFile()
        refreshEntries()
        nameBox.Text = ""
    end)

    refreshEntries()
end

-- ══════════════════════════════════════════
--  CREDITS TAB
-- ══════════════════════════════════════════
local creditsTab = makeTab("Credits")
do
    local p = creditsTab.page
    makeSection(p,"About")
    sectionOrder = sectionOrder+1

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,180)
    card.BackgroundColor3 = CARD
    card.BorderSizePixel = 0
    card.LayoutOrder = sectionOrder
    card.Parent = p
    rnd(card,8) brdr(card,BORDER,1)

    -- cobalt wordmark
    local bigName = Instance.new("TextLabel")
    bigName.Size = UDim2.new(1,0,0,48)
    bigName.Position = UDim2.new(0,0,0,18)
    bigName.BackgroundTransparency = 1
    bigName.Text = "cobalt"
    bigName.TextSize = 36
    bigName.Font = Enum.Font.GothamBold
    bigName.TextColor3 = ACCENT
    bigName.TextXAlignment = Enum.TextXAlignment.Center
    bigName.Parent = card

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1,0,0,18)
    version.Position = UDim2.new(0,0,0,58)
    version.BackgroundTransparency = 1
    version.Text = "sell lemons autofarm  •  v3.0"
    version.TextSize = 11
    version.Font = Enum.Font.Gotham
    version.TextColor3 = MUTED
    version.TextXAlignment = Enum.TextXAlignment.Center
    version.Parent = card

    -- divider
    local div = Instance.new("Frame")
    div.Size = UDim2.new(0.7,0,0,1)
    div.Position = UDim2.new(0.15,0,0,88)
    div.BackgroundColor3 = BORDER
    div.BorderSizePixel = 0
    div.Parent = card

    local madeBy = Instance.new("TextLabel")
    madeBy.Size = UDim2.new(1,0,0,18)
    madeBy.Position = UDim2.new(0,0,0,100)
    madeBy.BackgroundTransparency = 1
    madeBy.Text = "made by"
    madeBy.TextSize = 11
    madeBy.Font = Enum.Font.Gotham
    madeBy.TextColor3 = MUTED
    madeBy.TextXAlignment = Enum.TextXAlignment.Center
    madeBy.Parent = card

    local poetryLabel = Instance.new("TextLabel")
    poetryLabel.Size = UDim2.new(1,0,0,26)
    poetryLabel.Position = UDim2.new(0,0,0,118)
    poetryLabel.BackgroundTransparency = 1
    poetryLabel.Text = "poetry"
    poetryLabel.TextSize = 20
    poetryLabel.Font = Enum.Font.GothamBold
    poetryLabel.TextColor3 = TEXT
    poetryLabel.TextXAlignment = Enum.TextXAlignment.Center
    poetryLabel.Parent = card

    -- link button
    sectionOrder = sectionOrder+1
    local linkRow = Instance.new("Frame")
    linkRow.Size = UDim2.new(1,0,0,44)
    linkRow.BackgroundColor3 = ADIM
    linkRow.BorderSizePixel = 0
    linkRow.LayoutOrder = sectionOrder
    linkRow.Parent = p
    rnd(linkRow,8) brdr(linkRow,ACCENT,1)

    local linkIcon = Instance.new("TextLabel")
    linkIcon.Size = UDim2.new(0,40,1,0)
    linkIcon.BackgroundTransparency = 1
    linkIcon.Text = "🔗"
    linkIcon.TextSize = 18
    linkIcon.Font = Enum.Font.Gotham
    linkIcon.Parent = linkRow

    local linkLbl = Instance.new("TextLabel")
    linkLbl.Size = UDim2.new(1,-80,0,20)
    linkLbl.Position = UDim2.new(0,40,0,5)
    linkLbl.BackgroundTransparency = 1
    linkLbl.Text = "guns.lol/erode"
    linkLbl.TextSize = 13
    linkLbl.Font = Enum.Font.GothamBold
    linkLbl.TextColor3 = AGLOW
    linkLbl.TextXAlignment = Enum.TextXAlignment.Left
    linkLbl.Parent = linkRow

    local linkSub = Instance.new("TextLabel")
    linkSub.Size = UDim2.new(1,-80,0,14)
    linkSub.Position = UDim2.new(0,40,0,25)
    linkSub.BackgroundTransparency = 1
    linkSub.Text = "click to open in browser"
    linkSub.TextSize = 10
    linkSub.Font = Enum.Font.Gotham
    linkSub.TextColor3 = MUTED
    linkSub.TextXAlignment = Enum.TextXAlignment.Left
    linkSub.Parent = linkRow

    local linkBtn = Instance.new("TextButton")
    linkBtn.Size = UDim2.new(1,0,1,0)
    linkBtn.BackgroundTransparency = 1
    linkBtn.Text = ""
    linkBtn.Parent = linkRow
    linkBtn.MouseButton1Click:Connect(function()
        tween(linkRow,{BackgroundColor3=ACCENT},0.1)
        task.wait(0.15)
        tween(linkRow,{BackgroundColor3=ADIM},0.2)
        pcall(function()
            if syn and syn.request then
                syn.request({Url="guns.lol/erode",Method="GET"})
            end
        end)
        -- standard executor open url
        pcall(function() setclipboard("https://guns.lol/erode") end)
        notify("Link Copied","guns.lol/erode copied to clipboard",4)
    end)
    linkBtn.MouseEnter:Connect(function() tween(linkRow,{BackgroundColor3=Color3.fromRGB(30,65,155)}) end)
    linkBtn.MouseLeave:Connect(function() tween(linkRow,{BackgroundColor3=ADIM}) end)
end

-- ── ACTIVATE FARM TAB ──
switchTab(gameTab)

-- ── FOOTER ──
local foot = Instance.new("TextLabel")
foot.Size = UDim2.new(1,0,0,14)
foot.Position = UDim2.new(0,0,1,-16)
foot.BackgroundTransparency = 1
foot.Text = "cobalt  •  poetry"
foot.TextSize = 9
foot.Font = Enum.Font.Gotham
foot.TextColor3 = Color3.fromRGB(50,70,110)
foot.TextXAlignment = Enum.TextXAlignment.Center
foot.Parent = Win

notify("Cobalt","Loaded successfully. Tycoon found.",4)
