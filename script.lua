--[[
   ██████╗ ██████╗ ██████╗  █████╗ ██╗  ████████╗
  ██╔════╝██╔═══██╗██╔══██╗██╔══██╗██║  ╚══██╔══╝
  ██║     ██║   ██║██████╔╝███████║██║     ██║   
  ██║     ██║   ██║██╔══██╗██╔══██║██║     ██║   
  ╚██████╗╚██████╔╝██████╔╝██║  ██║███████╗██║   
   ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  
  Sell Lemons Autofarm  •  v2.0  •  cobalt edition
--]]

-- ─────────────────────────────────────────────────────────
--  COBALT THEME (native ScreenGui – no external library)
-- ─────────────────────────────────────────────────────────
local C = {
    bg          = Color3.fromRGB(10,  14,  28),
    panel       = Color3.fromRGB(16,  22,  44),
    card        = Color3.fromRGB(22,  32,  60),
    border      = Color3.fromRGB(40,  62, 120),
    accent      = Color3.fromRGB(64, 140, 255),
    accentDim   = Color3.fromRGB(30,  70, 160),
    accentGlow  = Color3.fromRGB(100,170,255),
    green       = Color3.fromRGB( 72, 230, 140),
    red         = Color3.fromRGB(255,  80,  80),
    textPrimary = Color3.fromRGB(220, 230, 255),
    textMuted   = Color3.fromRGB(110, 130, 180),
    textData    = Color3.fromRGB(160, 200, 255),
    white       = Color3.fromRGB(255, 255, 255),
}

-- ─────────────────────────────────────────────────────────
--  SERVICES & PLAYER
-- ─────────────────────────────────────────────────────────
local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RunService  = game:GetService("RunService")
local TweenSvc    = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ─────────────────────────────────────────────────────────
--  FIND TYCOON
-- ─────────────────────────────────────────────────────────
local userTycoon = (function()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:match("Tycoon%d") then
            if v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer then
                return v
            end
        end
    end
end)()

-- ─────────────────────────────────────────────────────────
--  GUI BUILDER HELPERS
-- ─────────────────────────────────────────────────────────
local function corner(parent, r)
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, r or 6)
    c2.Parent = parent
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
end

local function label(parent, text, size, color, font, xalign, yalign)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 13
    l.TextColor3 = color or C.textPrimary
    l.Font = font or Enum.Font.GothamMedium
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextYAlignment = yalign or Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function notify(title, body, duration)
    local parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not parent then return end

    local g = Instance.new("ScreenGui")
    g.Name = "CobaltNotif"
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    g.DisplayOrder = 10001
    g.Parent = parent

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 280, 0, 64)
    f.Position = UDim2.new(1, -296, 0, 16)
    f.BackgroundColor3 = C.panel
    f.BorderSizePixel = 0
    f.Parent = g
    corner(f, 8)
    stroke(f, C.accent, 1)

    -- left accent bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -12)
    bar.Position = UDim2.new(0, 6, 0, 6)
    bar.BackgroundColor3 = C.accent
    bar.BorderSizePixel = 0
    bar.Parent = f
    corner(bar, 2)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -24, 0, 20)
    t.Position = UDim2.new(0, 18, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextSize = 13
    t.Font = Enum.Font.GothamBold
    t.TextColor3 = C.accentGlow
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = f

    local b = Instance.new("TextLabel")
    b.Size = UDim2.new(1, -24, 0, 20)
    b.Position = UDim2.new(0, 18, 0, 30)
    b.BackgroundTransparency = 1
    b.Text = body
    b.TextSize = 12
    b.Font = Enum.Font.Gotham
    b.TextColor3 = C.textMuted
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = f

    -- slide in
    f.Position = UDim2.new(1, 20, 0, 16)
    TweenSvc:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, -296, 0, 16)
    }):Play()

    task.delay(duration or 4, function()
        TweenSvc:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 20, 0, 16)
        }):Play()
        task.wait(0.35)
        g:Destroy()
    end)
end

-- ─────────────────────────────────────────────────────────
--  TYCOON GUARD
-- ─────────────────────────────────────────────────────────
if not userTycoon then
    notify("Cobalt — Error", "Tycoon not found! Join a tycoon first.", 8)
    return
end

-- ─────────────────────────────────────────────────────────
--  STATE
-- ─────────────────────────────────────────────────────────
local AutoBuy        = false
local AutoUpgrade    = false
local AutoFruit      = false
local AutoRebirth    = false
local AutoEvolve     = false
local AutoPowerLevel = false

local stats = { buys=0, upgrades=0, fruit=0, rebirths=0, evolves=0 }

-- ─────────────────────────────────────────────────────────
--  AUTO BUY
-- ─────────────────────────────────────────────────────────
local function buyAllAffordable()
    for _, obj in ipairs(userTycoon.Purchases:GetDescendants()) do
        if obj:IsA("Model") then
            local shown     = obj:GetAttribute("Shown")
            local purchased = obj:GetAttribute("Purchased")
            if shown == true and purchased ~= true then
                local purchase = obj:FindFirstChild("Purchase")
                if purchase and purchase:IsA("RemoteFunction") then
                    pcall(function() purchase:InvokeServer() end)
                    stats.buys = stats.buys + 1
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if AutoBuy then pcall(buyAllAffordable) end
    end
end)

-- ─────────────────────────────────────────────────────────
--  AUTO UPGRADE
-- ─────────────────────────────────────────────────────────
local upgradeRemotes  = {}
local upgradeLevel    = {}
local lastUpgradeScan = 0

local function refreshUpgradeRemotes()
    upgradeRemotes = {}
    upgradeLevel   = {}
    local purchases = userTycoon:FindFirstChild("Purchases")
    if not purchases then return end
    for _, obj in ipairs(purchases:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name == "Upgrade" then
            upgradeRemotes[#upgradeRemotes + 1] = obj
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.25)
        if AutoUpgrade then
            if tick() - lastUpgradeScan > 3 then
                refreshUpgradeRemotes()
                lastUpgradeScan = tick()
            end
            for _, remote in ipairs(upgradeRemotes) do
                if remote.Parent then
                    local lvl = (upgradeLevel[remote] or 0) + 1
                    while lvl <= 100 do
                        local ok, res = pcall(function() return remote:InvokeServer(lvl) end)
                        if (not ok) or res == false then break end
                        upgradeLevel[remote] = lvl
                        stats.upgrades = stats.upgrades + 1
                        lvl = lvl + 1
                    end
                end
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────
--  AUTO POWER LEVEL
-- ─────────────────────────────────────────────────────────
local function getPowerLevelRemote()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("UpgradePowerLevel")
end

task.spawn(function()
    while true do
        task.wait(0.25)
        if AutoPowerLevel then
            local remote = getPowerLevelRemote()
            if remote then pcall(function() remote:InvokeServer() end) end
        end
    end
end)

-- ─────────────────────────────────────────────────────────
--  AUTO REBIRTH
-- ─────────────────────────────────────────────────────────
local RebirthGainMultiple = 1.0
local MinPotential        = 1
local RebirthCooldown     = 2
local RebirthTimeout      = 8
local rebirthBusy         = false

local NUM_SCALE = {
    thousand=1e3, million=1e6, billion=1e9, trillion=1e12, quadrillion=1e15,
    quintillion=1e18, sextillion=1e21, septillion=1e24, octillion=1e27,
    nonillion=1e30, decillion=1e33, undecillion=1e36, duodecillion=1e39,
    tredecillion=1e42, quattuordecillion=1e45, quindecillion=1e48,
    sexdecillion=1e51, septendecillion=1e54, octodecillion=1e57,
    novemdecillion=1e60, vigintillion=1e63,
    k=1e3, m=1e6, b=1e9, t=1e12, qd=1e15, qn=1e18, sx=1e21, sp=1e24,
}
local function parseNumber(s)
    if not s then return nil end
    s = tostring(s):gsub(",",""):lower()
    local num = s:match("[%d%.]+")
    local val = num and tonumber(num)
    if not val then return nil end
    local word = s:match("[%d%.%s]+([a-z]+)")
    if word and NUM_SCALE[word] then val = val * NUM_SCALE[word] end
    return val
end

local function investorBody()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local r  = pg and pg:FindFirstChild("Rebirth")
    local im = r and r:FindFirstChild("InvestorsMenu")
    return im and im:FindFirstChild("Body")
end
local function readQuantity(frameName)
    local body  = investorBody()
    local frame = body and body:FindFirstChild(frameName)
    local q     = frame and frame:FindFirstChild("Quantity")
    return q and parseNumber(q.Text)
end
local function getCurrentInvestors()   return readQuantity("Amount")  or 0 end
local function getPotentialInvestors() return readQuantity("Potential")     end

local function getRebirthRemote()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("Rebirth")
end
local function getRebirthedSignal()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("Rebirthed")
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoRebirth and not rebirthBusy then
            local remote    = getRebirthRemote()
            local potential = getPotentialInvestors()
            local current   = getCurrentInvestors()
            local worthIt   = remote and potential
                and potential >= MinPotential
                and potential >= current * RebirthGainMultiple
            if worthIt then
                rebirthBusy = true
                pcall(function()
                    local done   = false
                    local signal = getRebirthedSignal()
                    local conn
                    if signal and signal:IsA("RemoteEvent") then
                        conn = signal.OnClientEvent:Connect(function() done = true end)
                    end
                    remote:InvokeServer()
                    stats.rebirths = stats.rebirths + 1
                    local t = 0
                    while not done and t < RebirthTimeout do task.wait(0.1); t = t+0.1 end
                    if conn then conn:Disconnect() end
                end)
                task.wait(RebirthCooldown)
                rebirthBusy = false
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────
--  AUTO EVOLVE
-- ─────────────────────────────────────────────────────────
local EvolveAt       = 100
local EvolveCooldown = 2
local EvolveTimeout  = 8
local evolveBusy     = false

local function getEvolveRemote()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("Evolve")
end
local function getEvolvedSignal()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("Evolved")
end
local function getEvolveProgress()
    local pg   = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local r    = pg and pg:FindFirstChild("Rebirth")
    local em   = r and r:FindFirstChild("EvolutionMenu")
    local body = em and em:FindFirstChild("Body")
    local p    = body and body:FindFirstChild("Progress")
    if not p then return nil end
    return tonumber(tostring(p.Text):match("[%d%.]+"))
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoEvolve and not evolveBusy then
            local remote   = getEvolveRemote()
            local progress = getEvolveProgress()
            if remote and progress and progress >= EvolveAt then
                evolveBusy = true
                pcall(function()
                    local done   = false
                    local signal = getEvolvedSignal()
                    local conn
                    if signal and signal:IsA("RemoteEvent") then
                        conn = signal.OnClientEvent:Connect(function() done = true end)
                    end
                    remote:InvokeServer()
                    stats.evolves = stats.evolves + 1
                    local t = 0
                    while not done and t < EvolveTimeout do task.wait(0.1); t = t+0.1 end
                    if conn then conn:Disconnect() end
                end)
                task.wait(EvolveCooldown)
                evolveBusy = false
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────
--  SEWER ACTIONS
-- ─────────────────────────────────────────────────────────
local function touchPart(hrp, part)
    pcall(function()
        firetouchinterest(hrp, part, 0)
        firetouchinterest(hrp, part, 1)
    end)
end

local function pullAllLevers()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    local map   = workspace:FindFirstChild("Map")
    local sewer = map and map:FindFirstChild("Sewer")
    local root  = sewer or workspace
    local pulled = 0
    for _, o in ipairs(root:GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name), "lever", 1, true) then
            pcall(function()
                firetouchinterest(hrp, o, 0)
                firetouchinterest(hrp, o, 1)
            end)
            pulled = pulled + 1
        end
    end
    if sewer then
        for _, o in ipairs(sewer:GetDescendants()) do
            if o:IsA("BasePart") and (o.Name=="VineKey" or o.Name=="UFOKey") then
                pcall(function()
                    firetouchinterest(hrp, o, 0)
                    firetouchinterest(hrp, o, 1)
                end)
            end
        end
    end
    return pulled
end

local function doSewerRun()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "no character" end
    local map   = workspace:FindFirstChild("Map")
    local sewer = map and map:FindFirstChild("Sewer")
    if not sewer then return false, "sewer not loaded" end
    for _, o in ipairs(sewer:GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name), "lever", 1, true) then
            touchPart(hrp, o)
        end
    end
    for _, folderName in ipairs({"CashVine","SewerAlien"}) do
        local folder = sewer:FindFirstChild(folderName)
        if folder then
            for _, o in ipairs(folder:GetDescendants()) do
                if o:IsA("BasePart") and (o.Name=="VineKey" or o.Name=="UFOKey") then
                    touchPart(hrp, o)
                end
            end
        end
    end
    task.wait(0.3)
    local cashVine = sewer:FindFirstChild("CashVine")
    if cashVine then
        local vineDoor = cashVine:FindFirstChild("VineDoor")
        if vineDoor then
            for _, o in ipairs(vineDoor:GetDescendants()) do
                if o:IsA("BasePart") then touchPart(hrp, o) end
            end
        end
    end
    task.wait(0.3)
    if cashVine then
        local vineModel = cashVine:FindFirstChild("CashVine")
        if vineModel then
            local pivot = vineModel:GetPivot()
            pcall(function() hrp.CFrame = pivot + Vector3.new(0,3,0) end)
            task.wait(0.2)
            for _, o in ipairs(vineModel:GetDescendants()) do
                if o:IsA("BasePart") then touchPart(hrp, o) end
            end
        end
    end
    return true
end

local SEWER_ALIEN_POS = Vector3.new(-42, -41, 180)
local function teleportToAlien()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "no character" end
    pcall(function() hrp.CFrame = CFrame.new(SEWER_ALIEN_POS) end)
    return true
end

-- ─────────────────────────────────────────────────────────
--  AUTO FRUIT
-- ─────────────────────────────────────────────────────────
local Trees = {}
local function addTree(obj)
    if obj:IsA("Model") and obj.Name == "LemonTree" and not table.find(Trees, obj) then
        table.insert(Trees, obj)
    end
end
local function removeTree(obj)
    local i = table.find(Trees, obj)
    if i then table.remove(Trees, i) end
end
for _, v in ipairs(workspace:GetDescendants()) do addTree(v) end
workspace.DescendantAdded:Connect(addTree)
workspace.DescendantRemoving:Connect(removeTree)

local function collectFruit(tree)
    for _, obj in ipairs(tree:GetDescendants()) do
        if obj:IsA("BasePart") then obj.CanCollide = false end
    end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = tree:GetPivot() + Vector3.new(0,5,0)
    for _, obj in ipairs(tree:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Fruit" then
            obj.CanCollide = false
            local clickPart = obj:FindFirstChild("ClickPart")
            if clickPart then
                local detector = clickPart:FindFirstChildOfClass("ClickDetector")
                if detector then
                    task.wait(0.45)
                    pcall(function() fireclickdetector(detector) end)
                    stats.fruit = stats.fruit + 1
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoFruit then
            for _, tree in ipairs(Trees) do
                if not AutoFruit then break end
                if tree and tree.Parent then
                    pcall(function() collectFruit(tree) end)
                end
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────
--  BUILD COBALT GUI
-- ─────────────────────────────────────────────────────────
local guiParent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not guiParent then
    local ok, h = pcall(gethui)
    guiParent = (ok and h) or game:GetService("CoreGui")
end

-- cleanup old instances
for _, n in ipairs({"CobaltGui","AutoStatusGui","CobaltNotif"}) do
    local old = guiParent:FindFirstChild(n)
    if old then old:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CobaltGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9998
ScreenGui.Parent = guiParent

-- ── MAIN WINDOW ──────────────────────────────────────────
local WIN_W, WIN_H = 340, 440
local Window = Instance.new("Frame")
Window.Name = "CobaltWindow"
Window.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Window.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Window.BackgroundColor3 = C.bg
Window.BorderSizePixel = 0
Window.Active = true
Window.Parent = ScreenGui
corner(Window, 12)
stroke(Window, C.border, 1)

-- subtle top gradient glow
local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.new(1, 0, 0, 3)
topGlow.BackgroundColor3 = C.accent
topGlow.BorderSizePixel = 0
topGlow.Parent = Window
local tgCorner = Instance.new("UICorner")
tgCorner.CornerRadius = UDim.new(0, 12)
tgCorner.Parent = topGlow

-- ── TITLE BAR ────────────────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = C.panel
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Window
corner(TitleBar, 12)
-- mask bottom corners
local titleMask = Instance.new("Frame")
titleMask.Size = UDim2.new(1, 0, 0, 12)
titleMask.Position = UDim2.new(0,0,1,-12)
titleMask.BackgroundColor3 = C.panel
titleMask.BorderSizePixel = 0
titleMask.Parent = TitleBar

-- logo dot
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 10, 0, 10)
dot.Position = UDim2.new(0, 16, 0.5, -5)
dot.BackgroundColor3 = C.accent
dot.BorderSizePixel = 0
dot.Parent = TitleBar
corner(dot, 5)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 34, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "COBALT"
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = C.textPrimary
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TitleBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, -100, 0, 14)
subtitleLabel.Position = UDim2.new(0, 34, 0.5, 4)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Sell Lemons Autofarm"
subtitleLabel.TextSize = 11
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextColor3 = C.textMuted
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = TitleBar

-- close / minimize buttons
local function makeHeaderBtn(xOffset, col, symbol, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(1, xOffset, 0.5, -11)
    btn.BackgroundColor3 = col
    btn.Text = symbol
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = C.white
    btn.BorderSizePixel = 0
    btn.Parent = TitleBar
    corner(btn, 11)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

makeHeaderBtn(-12, Color3.fromRGB(255,80,80), "×", function()
    TweenSvc:Create(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, WIN_W, 0, 0),
        BackgroundTransparency = 1,
    }):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

local minimized = false
makeHeaderBtn(-40, C.accentDim, "−", function()
    minimized = not minimized
    local targetH = minimized and 48 or WIN_H
    TweenSvc:Create(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, WIN_W, 0, targetH)
    }):Play()
end)

-- draggable title bar
local dragging, ds, sp
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging, ds, sp = true, i.Position, Window.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (
        i.UserInputType == Enum.UserInputType.MouseMovement or
        i.UserInputType == Enum.UserInputType.Touch
    ) then
        local d = i.Position - ds
        Window.Position = UDim2.new(
            sp.X.Scale, sp.X.Offset + d.X,
            sp.Y.Scale, sp.Y.Offset + d.Y
        )
    end
end)

-- ── TAB BAR ──────────────────────────────────────────────
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 30)
TabBar.Position = UDim2.new(0, 12, 0, 54)
TabBar.BackgroundColor3 = C.card
TabBar.BorderSizePixel = 0
TabBar.Parent = Window
corner(TabBar, 8)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 2)
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = TabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 4)
tabPad.PaddingRight = UDim.new(0, 4)
tabPad.PaddingTop = UDim.new(0, 4)
tabPad.PaddingBottom = UDim.new(0, 4)
tabPad.Parent = TabBar

-- ── CONTENT AREA ─────────────────────────────────────────
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -24, 1, -102)
ContentArea.Position = UDim2.new(0, 12, 0, 92)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.Parent = Window

-- ── SCROLL FRAME ─────────────────────────────────────────
local function makeScrollPage()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = C.accentDim
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Parent = ContentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = sf

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = sf

    return sf
end

-- ── TOGGLE COMPONENT ─────────────────────────────────────
local function makeToggle(parent, order, labelText, desc, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    corner(row, 8)
    stroke(row, C.border, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = C.textPrimary
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -60, 0, 16)
    sub.Position = UDim2.new(0, 12, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text = desc or ""
    sub.TextSize = 11
    sub.Font = Enum.Font.Gotham
    sub.TextColor3 = C.textMuted
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = row

    -- toggle pill
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 40, 0, 22)
    pill.Position = UDim2.new(1, -52, 0.5, -11)
    pill.BackgroundColor3 = C.border
    pill.BorderSizePixel = 0
    pill.Parent = row
    corner(pill, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = C.textMuted
    knob.BorderSizePixel = 0
    knob.Parent = pill
    corner(knob, 8)

    local state = false
    local function update(v)
        state = v
        TweenSvc:Create(pill, TweenInfo.new(0.2), {
            BackgroundColor3 = v and C.accent or C.border
        }):Play()
        TweenSvc:Create(knob, TweenInfo.new(0.2), {
            Position = v
                and UDim2.new(1, -19, 0.5, -8)
                or  UDim2.new(0,  3,  0.5, -8),
            BackgroundColor3 = v and C.white or C.textMuted,
        }):Play()
        callback(v)
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row
    btn.MouseButton1Click:Connect(function()
        update(not state)
    end)

    -- hover highlight
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28,40,74)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = C.card}):Play()
    end)

    return update  -- returns setter for external control
end

-- ── BUTTON COMPONENT ─────────────────────────────────────
local function makeButton(parent, order, labelText, desc, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    corner(row, 8)
    stroke(row, C.border, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -56, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = C.textPrimary
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -56, 0, 16)
    sub.Position = UDim2.new(0, 12, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text = desc or ""
    sub.TextSize = 11
    sub.Font = Enum.Font.Gotham
    sub.TextColor3 = C.textMuted
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = row

    -- arrow icon
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 28, 0, 28)
    arrow.Position = UDim2.new(1, -40, 0.5, -14)
    arrow.BackgroundColor3 = C.accentDim
    arrow.Text = "›"
    arrow.TextSize = 20
    arrow.Font = Enum.Font.GothamBold
    arrow.TextColor3 = C.accent
    arrow.BorderSizePixel = 0
    arrow.Parent = row
    corner(arrow, 6)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        TweenSvc:Create(row, TweenInfo.new(0.08), {BackgroundColor3 = C.accentDim}):Play()
        task.wait(0.1)
        TweenSvc:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = C.card}):Play()
        callback()
    end)
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28,40,74)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = C.card}):Play()
    end)
end

-- ── SECTION HEADER ───────────────────────────────────────
local function makeSection(parent, order, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text:upper()
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = C.accent
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LetterSpacingOffset = 2
    l.Parent = f
end

-- ── BUILD TABS ───────────────────────────────────────────
local tabs = {}
local activeTab = nil

local function makeTab(name, icon, pageBuilder)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 76, 1, 0)
    btn.BackgroundColor3 = C.panel
    btn.Text = (icon or "") .. "  " .. name
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = C.textMuted
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    corner(btn, 6)

    local page = makeScrollPage()
    page.Visible = false
    pageBuilder(page)

    local tab = { btn=btn, page=page }

    btn.MouseButton1Click:Connect(function()
        if activeTab then
            activeTab.page.Visible = false
            TweenSvc:Create(activeTab.btn, TweenInfo.new(0.15), {
                BackgroundColor3 = C.panel,
                TextColor3 = C.textMuted,
            }):Play()
        end
        activeTab = tab
        page.Visible = true
        TweenSvc:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = C.accent,
            TextColor3 = C.white,
        }):Play()
    end)

    tabs[#tabs+1] = tab
    return tab
end

-- ── TAB: FARM ────────────────────────────────────────────
makeTab("Farm", "🌿", function(page)
    makeSection(page, 1, "Automation")

    makeToggle(page, 2, "Auto Buy", "Purchase all affordable items", function(v)
        AutoBuy = v
        notify("Auto Buy", v and "Enabled" or "Disabled", 3)
    end)

    makeToggle(page, 3, "Auto Upgrade", "Upgrade machines as cash grows", function(v)
        AutoUpgrade = v
        notify("Auto Upgrade", v and "Enabled" or "Disabled", 3)
    end)

    makeToggle(page, 4, "Auto Fruit", "Teleport & collect lemon fruit", function(v)
        AutoFruit = v
        notify("Auto Fruit", v and "Enabled" or "Disabled", 3)
    end)

    makeToggle(page, 5, "Auto Power Level", "Spam UpgradePowerLevel remote", function(v)
        AutoPowerLevel = v
        notify("Auto Power Level", v and "Enabled" or "Disabled", 3)
    end)
end)

-- ── TAB: REBIRTH ─────────────────────────────────────────
makeTab("Rebirth", "♻", function(page)
    makeSection(page, 1, "Progression")

    makeToggle(page, 2, "Auto Rebirth", "Rebirths when payout is worth it", function(v)
        AutoRebirth = v
        if v and not getRebirthRemote() then
            notify("Auto Rebirth", "Remote not found in your tycoon!", 5)
            return
        end
        notify("Auto Rebirth", v and "Enabled" or "Disabled", 3)
    end)

    makeToggle(page, 3, "Auto Evolve", "Evolves at 100% progress (×10 speed)", function(v)
        AutoEvolve = v
        if v and not getEvolveRemote() then
            notify("Auto Evolve", "Remote not found in your tycoon!", 5)
            return
        end
        notify("Auto Evolve", v and "Enabled" or "Disabled", 3)
    end)
end)

-- ── TAB: SEWER ───────────────────────────────────────────
makeTab("Sewer", "🚧", function(page)
    makeSection(page, 1, "Sewer Actions")

    makeButton(page, 2, "Pull All Levers", "Activates sewer doors & grabs keys", function()
        local n = pullAllLevers()
        notify("Pull Levers",
            n > 0 and ("Pulled " .. n .. " lever(s) + grabbed keys")
                  or  "No levers found — is the sewer loaded?",
            4)
    end)

    makeButton(page, 3, "Vine Harvest", "Full sewer run — levers → keys → vine", function()
        notify("Vine Harvest", "Running sewer sequence…", 2)
        task.spawn(function()
            local ok, err = doSewerRun()
            notify("Vine Harvest",
                ok and "Done! Levers, keys, vine all collected."
                   or ("Failed: " .. tostring(err)),
                5)
        end)
    end)

    makeButton(page, 4, "Teleport to Alien", "Jump to sewer alien (UFO key spot)", function()
        local ok, err = teleportToAlien()
        notify("Sewer Alien",
            ok and "Teleported to the UFO alien."
               or ("Failed: " .. tostring(err)),
            3)
    end)
end)

-- ── TAB: STATS ───────────────────────────────────────────
makeTab("Stats", "📊", function(page)
    makeSection(page, 1, "Live Monitor")

    local statCard = Instance.new("Frame")
    statCard.Size = UDim2.new(1, 0, 0, 240)
    statCard.BackgroundColor3 = C.card
    statCard.BorderSizePixel = 0
    statCard.LayoutOrder = 2
    statCard.Parent = page
    corner(statCard, 8)
    stroke(statCard, C.border, 1)

    local statBody = Instance.new("TextLabel")
    statBody.Size = UDim2.new(1, -20, 1, -12)
    statBody.Position = UDim2.new(0, 10, 0, 8)
    statBody.BackgroundTransparency = 1
    statBody.RichText = true
    statBody.Text = "…"
    statBody.TextSize = 13
    statBody.Font = Enum.Font.Code
    statBody.TextColor3 = C.textData
    statBody.TextXAlignment = Enum.TextXAlignment.Left
    statBody.TextYAlignment = Enum.TextYAlignment.Top
    statBody.Parent = statCard

    -- fps counter
    local frames, fps, fpsT = 0, 0, tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - fpsT >= 1 then fps, frames, fpsT = frames, 0, tick() end
    end)

    local function fmtOn(b)
        return b and "<font color='#48E68C'>● ON</font>"
                  or "<font color='#6688AA'>○ off</font>"
    end

    task.spawn(function()
        while statCard.Parent do
            local cashStr = "?"
            local ls = LocalPlayer:FindFirstChild("leaderstats")
            local c  = ls and ls:FindFirstChild("Cash")
            if c then cashStr = tostring(c.Value) end

            local progress = getEvolveProgress() or 0

            statBody.Text = string.format(
                "<font color='#6688BB'>FPS</font>         <font color='#C0D8FF'>%d</font>\n"
             .. "<font color='#6688BB'>Cash</font>        <font color='#C0D8FF'>%s</font>\n"
             .. "<font color='#6688BB'>Evolve %%</font>   <font color='#C0D8FF'>%.1f%%</font>\n"
             .. "\n"
             .. "<font color='#6688BB'>Buys</font>        <font color='#C0D8FF'>%d</font>   %s\n"
             .. "<font color='#6688BB'>Upgrades</font>    <font color='#C0D8FF'>%d</font>   %s\n"
             .. "<font color='#6688BB'>Fruit</font>       <font color='#C0D8FF'>%d</font>   %s\n"
             .. "<font color='#6688BB'>Rebirths</font>    <font color='#C0D8FF'>%d</font>   %s\n"
             .. "<font color='#6688BB'>Evolves</font>     <font color='#C0D8FF'>%d</font>   %s",
                fps, cashStr, progress,
                stats.buys,     fmtOn(AutoBuy),
                stats.upgrades, fmtOn(AutoUpgrade),
                stats.fruit,    fmtOn(AutoFruit),
                stats.rebirths, fmtOn(AutoRebirth),
                stats.evolves,  fmtOn(AutoEvolve)
            )
            task.wait(0.25)
        end
    end)
end)

-- ── ACTIVATE FIRST TAB ───────────────────────────────────
tabs[1].btn.MouseButton1Click:Fire()

-- ── FOOTER ───────────────────────────────────────────────
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 18)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.Text = "cobalt  •  sell lemons autofarm"
footer.TextSize = 10
footer.Font = Enum.Font.Gotham
footer.TextColor3 = C.textMuted
footer.Parent = Window

-- ─────────────────────────────────────────────────────────
--  BOOT NOTIFICATION
-- ─────────────────────────────────────────────────────────
notify("Cobalt Loaded", "Tycoon found. Autofarm ready.", 4)
