-- NCH v5 | TuexxHn/vblspins — rank probe + farm
local ok, err = pcall(function()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local pgui = lp.PlayerGui

if pgui:FindFirstChild("NCH_v5") then pgui.NCH_v5:Destroy() end

_G.AutoLucky = false
_G.AutoYen   = false
_G.AutoSkills = false
_G.Speed = 0.7
_G.ValidArgs = {}  -- preenchido pelo probe

local KNIT = "sleitnick_knit@1.7.0"

local function log(tag, msg)
    print("[NCH]["..tag.."] "..tostring(msg or ""))
end

local function getPath(root, a, b, c, d, e, f, g, h)
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

-- remote principal — mesmo do original
local Remote = getPath(RS, "Packages", "_Index", KNIT, "knit", "Services", "SeasonService", "RF", "RequestRankedReward")
-- ranked service para checar rank
local RankRemote = getPath(RS, "Packages", "_Index", KNIT, "knit", "Services", "RankedService", "RF", "FetchPlayerRankId")

if not Remote then
    print("[NCH] ERRO: RequestRankedReward nao encontrado")
    return
end

log("BOOT", "remotes ok")
if RankRemote then
    local rankOk, rankVal = pcall(function() return RankRemote:InvokeServer() end)
    if rankOk and rankVal ~= nil then
        log("RANK", "rank atual: "..tostring(rankVal))
    else
        log("RANK", "nao retornou rank")
    end
end

-- ══ UI ══
local NetworkUI = Instance.new("ScreenGui")
NetworkUI.Name = "NCH_v5"
NetworkUI.ResetOnSpawn = false
NetworkUI.Parent = pgui

local Theme = {
    Bg=Color3.fromRGB(20,10,35), BgLight=Color3.fromRGB(35,20,55),
    Active=Color3.fromRGB(45,25,70), Cyan=Color3.fromRGB(0,200,255),
    Orange=Color3.fromRGB(255,100,0), Green=Color3.fromRGB(0,220,100),
    White=Color3.fromRGB(255,255,255),
}

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
Main.Size = UDim2.new(0, 250, 0, 390)
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
Title.Text = "<font color='#00C8FF'>NETWORK</font> <font color='#FF6400'>CODE</font> <font color='#00DC64'>v5</font>"
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
        _G[key] = not _G[key]
        local a = _G[key]
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

CreateToggle("Lucky Spin",  58,  "AutoLucky",  Theme.Cyan)
CreateToggle("Yen Farm",    108, "AutoYen",    Theme.Orange)
CreateToggle("Habilidades", 158, "AutoSkills", Theme.Cyan)

-- Probe: testa args 1–20 no teu rank atual e salva os que retornam algo
ActionBtn("Probe Rank Args", 215, function()
    _G.ValidArgs = {}
    log("PROBE", "iniciando probe 1-20")
    Notify("Probe iniciado...", Theme.Cyan)
    for i = 1, 20 do
        task.wait(0.6)
        local ok2, r = pcall(function() return Remote:InvokeServer(i) end)
        if ok2 and r ~= nil then
            local rtype = type(r)
            local rval = rtype == "boolean" and tostring(r) or (rtype == "table" and "table" or tostring(r))
            log("PROBE", "arg "..i.." -> "..rval)
            if r ~= false then
                table.insert(_G.ValidArgs, i)
                log("PROBE", "arg "..i.." VALIDO")
            end
        end
    end
    local found = #_G.ValidArgs
    if found > 0 then
        local argstr = ""
        for idx, v in ipairs(_G.ValidArgs) do
            argstr = argstr..(idx > 1 and "," or "")..tostring(v)
        end
        log("PROBE", "args validos: "..argstr)
        Notify("Probe: args ["..argstr.."] validos!", Theme.Green)
    else
        log("PROBE", "nenhum arg valido no rank atual")
        Notify("Probe: nenhum arg valido (rank insuficiente?)", Theme.Orange)
    end
end, Theme.Cyan)

ActionBtn("Check Rank", 260, function()
    if not RankRemote then
        Notify("RankRemote nao encontrado", Theme.Orange)
        return
    end
    local ok2, r = pcall(function() return RankRemote:InvokeServer() end)
    if ok2 and r ~= nil then
        log("RANK", tostring(r))
        Notify("Rank: "..tostring(r), Theme.Green)
    else
        Notify("Rank nao retornou valor", Theme.Orange)
    end
end, Theme.Green)

-- ══ FARM ENGINE — igual ao original + args dinâmicos ══
task.spawn(function()
    while true do
        task.wait(_G.Speed + math.random() * 0.3)
        -- usa args do probe se disponíveis, senão usa os originais
        if _G.AutoLucky then
            local arg = (_G.ValidArgs and _G.ValidArgs[1]) or 1
            pcall(function() Remote:InvokeServer(arg) end)
        end
        if _G.AutoYen then
            local arg = (_G.ValidArgs and _G.ValidArgs[2]) or 2
            pcall(function() Remote:InvokeServer(arg) end)
        end
        if _G.AutoSkills then
            local arg = (_G.ValidArgs and _G.ValidArgs[3]) or 4
            pcall(function() Remote:InvokeServer(arg) end)
        end
    end
end)

Notify("NCH v5 carregado", Theme.Cyan)
log("BOOT", "completo v5")

end)
if not ok then print("[NCH] ERRO FATAL: "..tostring(err)) end
