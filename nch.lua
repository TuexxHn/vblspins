-- NCH v4 | TuexxHn/vblspins — stealth build
local ok, err = pcall(function()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local pgui = lp.PlayerGui

if pgui:FindFirstChild("NCH_v4") then pgui.NCH_v4:Destroy() end

-- jitter humano: 3–9s entre qualquer fire
local CFG = {
    MinWait = 3.0,
    MaxWait = 6.0,
    KNIT_PKG = "sleitnick_knit@1.7.0",
}

local State = {
    AutoIdle=false, AutoQuest=false, AutoChallenge=false,
    AutoDaily=false, AutoAbility=false,
    Remotes={},
}

local Theme = {
    Bg=Color3.fromRGB(20,10,35), BgLight=Color3.fromRGB(35,20,55),
    Active=Color3.fromRGB(45,25,70), Cyan=Color3.fromRGB(0,200,255),
    Orange=Color3.fromRGB(255,100,0), Green=Color3.fromRGB(0,220,100),
    White=Color3.fromRGB(255,255,255),
}

local function humanWait()
    -- espera humana com ruido gaussiano simulado
    local base = CFG.MinWait + math.random() * (CFG.MaxWait - CFG.MinWait)
    local noise = (math.random() - 0.5) * 1.2
    task.wait(math.max(2.0, base + noise))
end

local function log(tag, msg)
    print("[NCH]["..tag.."] "..tostring(msg or ""))
end

-- invoke seguro sem retentativa — falhou, passou
local function safeInvoke(rf, arg1)
    local ok2, r = pcall(function()
        if arg1 ~= nil then return rf:InvokeServer(arg1)
        else return rf:InvokeServer() end
    end)
    if ok2 then return r end
    return nil
end

local function safeFireServer(re, arg1)
    pcall(function()
        if arg1 ~= nil then re:FireServer(arg1)
        else re:FireServer() end
    end)
end

local function resolvePath(root, a, b, c, d, e, f, g, h)
    local cur = root
    local parts = {a, b, c, d, e, f, g, h}
    for _, name in ipairs(parts) do
        if name == nil then break end
        if not cur then return nil end
        local child = cur:FindFirstChild(name)
        if not child then
            local ok2, c2 = pcall(function() return cur:WaitForChild(name, 2) end)
            child = ok2 and c2 or nil
        end
        if not child then return nil end
        cur = child
    end
    return cur
end

local function fireRemote(key, arg1)
    local r = State.Remotes[key]
    if not r then return end
    if r:IsA("RemoteFunction") then safeInvoke(r, arg1)
    else safeFireServer(r, arg1) end
end

-- ══ UI ══
local NetworkUI = Instance.new("ScreenGui")
NetworkUI.Name = "NCH_v4"
NetworkUI.ResetOnSpawn = false
NetworkUI.Parent = pgui
log("BOOT", "UI criada")

local function makeDraggable(frame)
    local drag, di, ds, sp
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = input.Position; sp = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then di = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == di and drag then
            local d = input.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
end

local function Notify(txt, color)
    task.spawn(function()
        local n = Instance.new("Frame", NetworkUI)
        n.Size = UDim2.new(0, 400, 0, 45)
        n.Position = UDim2.new(0.5, -200, -0.1, 0)
        n.BackgroundColor3 = Theme.Bg
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 10)
        local s = Instance.new("UIStroke", n)
        s.Color = color or Theme.Cyan; s.Thickness = 1.5
        local t = Instance.new("TextLabel", n)
        t.Size = UDim2.new(1, -10, 1, 0); t.Position = UDim2.new(0, 5, 0, 0)
        t.BackgroundTransparency = 1; t.Text = txt
        t.TextColor3 = Theme.White; t.Font = Enum.Font.GothamMedium
        t.TextSize = 13; t.TextWrapped = true
        n:TweenPosition(UDim2.new(0.5, -200, 0.05, 0), "Out", "Back", 0.5, true)
        task.wait(3)
        n:TweenPosition(UDim2.new(0.5, -200, -0.1, 0), "In", "Quad", 0.5, true)
        game:GetService("Debris"):AddItem(n, 0.6)
    end)
end

local NBtn = Instance.new("TextButton", NetworkUI)
NBtn.Size = UDim2.new(0, 55, 0, 55)
NBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
NBtn.BackgroundColor3 = Theme.Bg
NBtn.Text = "N"; NBtn.TextColor3 = Theme.Cyan
NBtn.Font = Enum.Font.GothamBlack; NBtn.TextSize = 28
Instance.new("UICorner", NBtn).CornerRadius = UDim.new(1, 0)
local nSt = Instance.new("UIStroke", NBtn)
nSt.Color = Theme.Cyan; nSt.Thickness = 2
makeDraggable(NBtn)
NBtn.MouseEnter:Connect(function()
    TweenService:Create(NBtn, TweenInfo.new(0.2), {BackgroundColor3=Theme.Active, TextColor3=Theme.Orange}):Play()
end)
NBtn.MouseLeave:Connect(function()
    TweenService:Create(NBtn, TweenInfo.new(0.2), {BackgroundColor3=Theme.Bg, TextColor3=Theme.Cyan}):Play()
end)

local Main = Instance.new("Frame", NetworkUI)
Main.Size = UDim2.new(0, 250, 0, 400)
Main.Position = UDim2.new(0.5, -125, 1.2, 0)
Main.BackgroundColor3 = Theme.Bg; Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
local mSt = Instance.new("UIStroke", Main)
mSt.Color = Theme.Orange; mSt.Thickness = 1.5
makeDraggable(Main)

task.spawn(function()
    while task.wait(1.5) do
        TweenService:Create(mSt, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Color=Theme.Cyan}):Play()
    end
end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "<font color='#00C8FF'>NETWORK</font> <font color='#FF6400'>CODE</font> <font color='#00DC64'>v4</font>"
Title.RichText = true; Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16; Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.White

NBtn.MouseButton1Click:Connect(function()
    local isOpen = Main.Position.Y.Scale < 1
    Main:TweenPosition(
        isOpen and UDim2.new(0.5, -125, 1.2, 0) or UDim2.new(0.5, -125, 0.2, 0),
        "Out", "Back", 0.5, true)
end)

local function CreateToggle(name, y, key, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.88, 0, 0, 42)
    btn.Position = UDim2.new(0.06, 0, 0, y)
    btn.BackgroundColor3 = Theme.BgLight; btn.Text = name
    btn.TextColor3 = Theme.Cyan; btn.Font = Enum.Font.Gotham; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = color or Theme.Cyan; bs.Transparency = 0.5
    btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        local a = State[key]
        btn.Text = a and (name.."\n<font size='9'>[ ON ]</font>") or name
        btn.RichText = true
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = a and Theme.Active or Theme.BgLight,
            TextColor3 = a and (color or Theme.Orange) or Theme.Cyan,
        }):Play()
        TweenService:Create(bs, TweenInfo.new(0.2), {
            Color = a and (color or Theme.Orange) or (color or Theme.Cyan),
            Transparency = a and 0 or 0.5,
        }):Play()
        if a then Notify("NCH: "..name.." ON", color) end
    end)
end

local function Sep(y)
    local l = Instance.new("Frame", Main)
    l.Size = UDim2.new(0.88, 0, 0, 1); l.Position = UDim2.new(0.06, 0, 0, y)
    l.BackgroundColor3 = Theme.Cyan; l.BackgroundTransparency = 0.7; l.BorderSizePixel = 0
end

local function ActionBtn(label, y, fn, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.88, 0, 0, 36)
    btn.Position = UDim2.new(0.06, 0, 0, y)
    btn.BackgroundColor3 = color or Theme.Cyan; btn.Text = label
    btn.TextColor3 = Theme.Bg; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        task.spawn(function()
            fn()
            btn.Text = label.." ok"; task.wait(2); btn.Text = label
        end)
    end)
end

-- toggles — só remotes passivos/seguros
CreateToggle("Idle Reward",     58,  "AutoIdle",      Theme.Cyan)
CreateToggle("Quest Claim",     108, "AutoQuest",     Theme.Orange)
CreateToggle("Challenge Claim", 158, "AutoChallenge", Theme.Cyan)
CreateToggle("Daily Present",   208, "AutoDaily",     Theme.Green)
Sep(258)
CreateToggle("Auto Ability",    268, "AutoAbility",   Theme.Cyan)
Sep(318)

-- Discover silencioso — sem log agressivo
ActionBtn("Discover Remotes", 328, function()
    local idx = resolvePath(RS, "Packages", "_Index")
    if not idx then Notify("ERRO: _Index", Theme.Orange) return end
    local kpkg = idx:FindFirstChild(CFG.KNIT_PKG)
    if not kpkg then
        for _, v in ipairs(idx:GetChildren()) do
            if v.Name:find("sleitnick_knit") then kpkg = v break end
        end
    end
    if not kpkg then Notify("ERRO: knit pkg", Theme.Orange) return end
    local svcs = resolvePath(kpkg, "knit", "Services")
    if not svcs then Notify("ERRO: Services", Theme.Orange) return end
    for _, svc in ipairs(svcs:GetChildren()) do
        for _, folder in ipairs({"RF", "RE"}) do
            local f = svc:FindFirstChild(folder)
            if f then
                for _, r in ipairs(f:GetChildren()) do
                    if r:IsA("RemoteFunction") or r:IsA("RemoteEvent") then
                        State.Remotes[svc.Name.."."..r.Name] = r
                    end
                end
            end
        end
    end
    local c = 0
    for _ in pairs(State.Remotes) do c = c + 1 end
    Notify("Discovery: "..c.." remotes", Theme.Cyan)
end, Theme.Cyan)

-- ══ FARM ENGINE — cadência humana ══
task.spawn(function()
    while true do
        humanWait()

        -- Idle reward — o server chama de volta, cliente só pede
        if State.AutoIdle then
            fireRemote("IdleService.OnReward", nil)
        end

        humanWait()

        -- Quest/Challenge — só claim quando já completou no servidor
        if State.AutoQuest then
            fireRemote("QuestService.Claim", nil)
            task.wait(1.5)
            fireRemote("QuestService.ClaimAll", nil)
        end

        humanWait()

        if State.AutoChallenge then
            fireRemote("ChallengeService.ClaimReward", nil)
        end

        humanWait()

        if State.AutoDaily then
            fireRemote("SeasonService.ClaimDailyPresent", nil)
        end

        humanWait()

        -- Ability — ação de gameplay normal, não suspeita
        if State.AutoAbility then
            fireRemote("AbilityService.UseAbility", nil)
            task.wait(0.8)
            fireRemote("AbilityService.SelectSlot", 1)
        end
    end
end)

Notify("NCH v4 carregado — stealth mode", Theme.Cyan)
log("BOOT", "completo v4")

end)
if not ok then print("[NCH] ERRO FATAL: "..tostring(err)) end
