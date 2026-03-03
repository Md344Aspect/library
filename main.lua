--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║  UILibrary  —  CSGO-style  |  Font.Code  |  Colorways  |  Watermark         ║
║  Version 4.0  —  Full CSGO ImGui redesign                                   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  CHANGES IN v4.0                                                             ║
║    1.  Sections     — ImGui groupbox: 1px border, title inside w/ separator  ║
║    2.  Toggles      — 22px, 12×12 checkbox, instant (no tween), row hitbox   ║
║    3.  Sliders      — 32px, value text inside track, no thumb knob           ║
║    4.  Dropdowns    — 22px closed, 20px items                                ║
║    5.  Buttons      — 22px, 1px border, instant hover + accent press flash   ║
║    6.  ColorPicker  — 22px header, 40px wide swatch, 192px open              ║
║    7.  Labels       — 16px (was 18)                                          ║
║    8.  Separators   — 8px (was 9)                                            ║
║    9.  TextInput    — 40px (was 44)                                          ║
║   10.  Watermark    — authentic CSGO style: single rect + RichText string    ║
║                                                                              ║
║  COLORWAYS  (cfg.theme)                                                      ║
║    "crimson" "blood" "rose" "cobalt" "navy" "sky" "arctic"                  ║
║    "emerald" "forest" "lime" "mint" "violet" "grape" "lavender"             ║
║    "amber" "fire" "gold" "magenta" "sakura" "silver" "slate" "ash"          ║
║    Legacy: "red" "blue" "green" "purple" "orange" "cyan" "pink" "white"     ║
║                                                                              ║
║  USAGE                                                                       ║
║    local UI  = loadstring(...)()                                             ║
║    local Win = UI:CreateWindow({ key="RightShift", theme="cobalt",           ║
║                                  name="MyScript", fps=true, clock=true })   ║
║    local Tab  = Win:AddTab("Combat")                                         ║
║    local Sect = Tab:AddSection("Aimbot", "left")                             ║
║    Sect:AddToggle("Enable", false, function(v) end, "Enables aimbot")        ║
║    Sect:AddSlider("FOV", 1, 360, 90, 0, function(v) end, "Field of view")   ║
║    Sect:AddDropdown("Bone",{"Head","Neck"},"Head",function(v) end,"Target") ║
║    Sect:AddButton("Reset", function() end, "Reset values")                  ║
║    Sect:AddColorPicker("Color", Color3.new(1,0,0), function(c) end)         ║
║    UI:Notify("Loaded", "Ready", "success", 3)                               ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")

-- ─────────────────────────────────────────────────────────────────────────────
-- Safe CoreGui parenting with PlayerGui fallback
-- ─────────────────────────────────────────────────────────────────────────────
local function SafeParent(gui)
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then
        local lp = Players.LocalPlayer
        if lp then gui.Parent = lp:WaitForChild("PlayerGui", 5) end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Colorways
-- ─────────────────────────────────────────────────────────────────────────────
local Colorways = {
    crimson  = { accent=Color3.fromRGB(220, 30,  60),  shell=Color3.fromRGB(30,17,18),  border=Color3.fromRGB(90,40,45),  surface=Color3.fromRGB(26,14,15),  hover=Color3.fromRGB(42,22,24),  track=Color3.fromRGB(50,22,24) },
    blood    = { accent=Color3.fromRGB(160,  0,  20),  shell=Color3.fromRGB(28,15,15),  border=Color3.fromRGB(80,30,35),  surface=Color3.fromRGB(22,12,12),  hover=Color3.fromRGB(38,18,18),  track=Color3.fromRGB(46,18,18) },
    rose     = { accent=Color3.fromRGB(230, 80, 110),  shell=Color3.fromRGB(30,18,20),  border=Color3.fromRGB(90,48,58),  surface=Color3.fromRGB(25,15,17),  hover=Color3.fromRGB(42,24,28),  track=Color3.fromRGB(50,26,30) },
    cobalt   = { accent=Color3.fromRGB( 30,120,255),   shell=Color3.fromRGB(16,18,30),  border=Color3.fromRGB(35,55,90),  surface=Color3.fromRGB(13,15,26),  hover=Color3.fromRGB(22,26,44),  track=Color3.fromRGB(26,30,52) },
    navy     = { accent=Color3.fromRGB( 20, 60,160),   shell=Color3.fromRGB(15,17,28),  border=Color3.fromRGB(28,42,80),  surface=Color3.fromRGB(12,14,24),  hover=Color3.fromRGB(18,22,40),  track=Color3.fromRGB(22,26,48) },
    sky      = { accent=Color3.fromRGB( 55,170,255),   shell=Color3.fromRGB(16,19,30),  border=Color3.fromRGB(36,60,90),  surface=Color3.fromRGB(13,16,26),  hover=Color3.fromRGB(22,28,44),  track=Color3.fromRGB(26,32,52) },
    arctic   = { accent=Color3.fromRGB( 80,200,230),   shell=Color3.fromRGB(16,20,28),  border=Color3.fromRGB(36,65,80),  surface=Color3.fromRGB(13,17,24),  hover=Color3.fromRGB(22,29,40),  track=Color3.fromRGB(26,34,48) },
    emerald  = { accent=Color3.fromRGB( 20,200,100),   shell=Color3.fromRGB(15,28,20),  border=Color3.fromRGB(30,75,48),  surface=Color3.fromRGB(12,23,16),  hover=Color3.fromRGB(18,38,26),  track=Color3.fromRGB(20,44,28) },
    forest   = { accent=Color3.fromRGB( 30,120, 50),   shell=Color3.fromRGB(15,26,17),  border=Color3.fromRGB(28,65,36),  surface=Color3.fromRGB(12,22,14),  hover=Color3.fromRGB(18,34,22),  track=Color3.fromRGB(20,40,24) },
    lime     = { accent=Color3.fromRGB(140,210, 40),   shell=Color3.fromRGB(20,28,14),  border=Color3.fromRGB(55,80,28),  surface=Color3.fromRGB(17,24,11),  hover=Color3.fromRGB(28,38,16),  track=Color3.fromRGB(32,44,18) },
    mint     = { accent=Color3.fromRGB( 60,210,160),   shell=Color3.fromRGB(15,28,24),  border=Color3.fromRGB(30,75,60),  surface=Color3.fromRGB(12,23,20),  hover=Color3.fromRGB(18,38,32),  track=Color3.fromRGB(20,44,36) },
    violet   = { accent=Color3.fromRGB(130, 40,255),   shell=Color3.fromRGB(20,15,30),  border=Color3.fromRGB(58,35,90),  surface=Color3.fromRGB(17,12,26),  hover=Color3.fromRGB(28,18,44),  track=Color3.fromRGB(32,20,52) },
    grape    = { accent=Color3.fromRGB( 90, 20,140),   shell=Color3.fromRGB(19,14,28),  border=Color3.fromRGB(50,28,78),  surface=Color3.fromRGB(16,11,24),  hover=Color3.fromRGB(26,16,38),  track=Color3.fromRGB(30,18,46) },
    lavender = { accent=Color3.fromRGB(160,120,240),   shell=Color3.fromRGB(22,18,30),  border=Color3.fromRGB(65,52,90),  surface=Color3.fromRGB(18,15,26),  hover=Color3.fromRGB(30,24,44),  track=Color3.fromRGB(36,28,52) },
    amber    = { accent=Color3.fromRGB(255,160,  0),   shell=Color3.fromRGB(30,24,14),  border=Color3.fromRGB(90,68,25),  surface=Color3.fromRGB(26,20,11),  hover=Color3.fromRGB(42,32,16),  track=Color3.fromRGB(50,36,18) },
    fire     = { accent=Color3.fromRGB(240, 70, 20),   shell=Color3.fromRGB(30,18,14),  border=Color3.fromRGB(88,42,25),  surface=Color3.fromRGB(26,15,11),  hover=Color3.fromRGB(42,22,16),  track=Color3.fromRGB(50,24,18) },
    gold     = { accent=Color3.fromRGB(220,180, 30),   shell=Color3.fromRGB(28,26,13),  border=Color3.fromRGB(82,72,22),  surface=Color3.fromRGB(24,22,10),  hover=Color3.fromRGB(38,34,14),  track=Color3.fromRGB(44,38,16) },
    magenta  = { accent=Color3.fromRGB(220,  0,180),   shell=Color3.fromRGB(30,14,28),  border=Color3.fromRGB(88,25,80),  surface=Color3.fromRGB(26,11,24),  hover=Color3.fromRGB(42,16,38),  track=Color3.fromRGB(50,18,44) },
    sakura   = { accent=Color3.fromRGB(240,140,180),   shell=Color3.fromRGB(30,18,24),  border=Color3.fromRGB(90,52,68),  surface=Color3.fromRGB(26,15,20),  hover=Color3.fromRGB(42,22,32),  track=Color3.fromRGB(50,26,36) },
    silver   = { accent=Color3.fromRGB(180,190,200),   shell=Color3.fromRGB(20,21,23),  border=Color3.fromRGB(65,68,72),  surface=Color3.fromRGB(17,18,19),  hover=Color3.fromRGB(32,34,36),  track=Color3.fromRGB(38,40,42) },
    slate    = { accent=Color3.fromRGB(100,120,150),   shell=Color3.fromRGB(17,19,23),  border=Color3.fromRGB(44,52,66),  surface=Color3.fromRGB(14,16,19),  hover=Color3.fromRGB(24,27,33),  track=Color3.fromRGB(28,32,40) },
    ash      = { accent=Color3.fromRGB(150,150,155),   shell=Color3.fromRGB(20,20,21),  border=Color3.fromRGB(62,62,65),  surface=Color3.fromRGB(17,17,18),  hover=Color3.fromRGB(30,30,32),  track=Color3.fromRGB(36,36,38) },
}
Colorways.red    = Colorways.crimson
Colorways.blue   = Colorways.cobalt
Colorways.green  = Colorways.emerald
Colorways.purple = Colorways.violet
Colorways.orange = Colorways.amber
Colorways.cyan   = Colorways.arctic
Colorways.pink   = Colorways.magenta
Colorways.white  = Colorways.silver

-- ─────────────────────────────────────────────────────────────────────────────
-- BuildTheme
-- ─────────────────────────────────────────────────────────────────────────────
local function BuildTheme(cw)
    local accent, shell, border, surface, hover, track
    if typeof(cw) == "Color3" then
        accent=cw; shell=Color3.fromRGB(29,29,29); border=Color3.fromRGB(72,72,72)
        surface=Color3.fromRGB(22,22,22); hover=Color3.fromRGB(40,40,40); track=Color3.fromRGB(44,44,44)
    else
        accent=cw.accent; shell=cw.shell; border=cw.border
        surface=cw.surface; hover=cw.hover; track=cw.track
    end
    local function Lift(c,n)
        return Color3.fromRGB(
            math.min(255,math.floor(c.R*255+.5)+n),
            math.min(255,math.floor(c.G*255+.5)+n),
            math.min(255,math.floor(c.B*255+.5)+n))
    end
    local panel2 = Lift(shell,14)
    local panel3 = Lift(shell,20)
    return {
        Frame1_BG      = Lift(shell,12),
        Frame2_BG      = shell,
        Frame2_Bdr     = border,
        TabBar_BG      = shell,
        TabBar_Bdr     = border,
        TabInactive_BG = panel2,
        TabHover_BG    = panel3,
        TabActive_BG   = accent,
        Content_BG     = shell,
        Content_Bdr    = border,
        Text           = Color3.fromRGB(242,242,242),
        SubText        = Color3.fromRGB(155,158,165),
        DimText        = Color3.fromRGB(80,82,88),
        SectionTitle   = Color3.fromRGB(185,188,195),
        Separator      = border,
        Accent         = accent,
        Checkbox_BG    = surface,
        Checkbox_Bdr   = border,
        Checkbox_On    = accent,
        Dropdown_BG    = panel2,
        Dropdown_List  = surface,
        Dropdown_Hover = hover,
        Dropdown_Sel   = accent,
        Slider_Track   = track,
        Slider_Fill    = accent,
        Slider_Thumb   = accent,
        Slider_ValBox  = surface,
        Tooltip_BG     = surface,
        Tooltip_Bdr    = border,
        Tooltip_Text   = Color3.fromRGB(210,212,218),
        Notif = {
            info    = Color3.fromRGB(70,75,88),
            success = Color3.fromRGB(25,175,85),
            warning = Color3.fromRGB(210,145,0),
            error   = Color3.fromRGB(200,30,50),
        },
        Font     = Enum.Font.Code,
        FontSize = 14,
        HdrSize  = 11,
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Pure helpers
-- ─────────────────────────────────────────────────────────────────────────────
local function Clamp(v,mn,mx) return math.max(mn,math.min(mx,v)) end
local function Round(v,d)
    if not d or d<=0 then return math.floor(v+.5) end
    local m=10^d; return math.floor(v*m+.5)/m
end
local function FormatNum(v,d)
    if not d or d<=0 then return tostring(math.floor(v+.5)) end
    return string.format("%."..d.."f",v)
end
local function Map(v,a,b,c,d)
    if a==b then return c end
    return c+(v-a)/(b-a)*(d-c)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Tween helpers
-- ─────────────────────────────────────────────────────────────────────────────
local function TweenQuad(obj,t,props)
    TweenService:Create(obj,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end
local function TweenLinear(obj,t,props)
    TweenService:Create(obj,TweenInfo.new(t,Enum.EasingStyle.Linear),props):Play()
end
local function TweenQuadHandle(obj,t,props)
    local tw=TweenService:Create(obj,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props)
    tw:Play(); return tw
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Instance factory
-- ─────────────────────────────────────────────────────────────────────────────
local function New(class,props)
    local o=Instance.new(class); local parent=nil
    for k,v in pairs(props or {}) do
        if k=="Parent" then parent=v else o[k]=v end
    end
    if parent then o.Parent=parent end
    return o
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MakeDraggable
-- ─────────────────────────────────────────────────────────────────────────────
local function MakeDraggable(handle,target,getEnabled)
    local dragging,startMouse,startPos,globalMove=false,nil,nil,nil
    handle.InputBegan:Connect(function(inp)
        if getEnabled and not getEnabled() then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true; startMouse=inp.Position; startPos=target.Position
            if globalMove then globalMove:Disconnect() end
            globalMove=UserInputService.InputChanged:Connect(function(i)
                if not dragging then return end
                if i.UserInputType~=Enum.UserInputType.MouseMovement
                and i.UserInputType~=Enum.UserInputType.Touch then return end
                if getEnabled and not getEnabled() then
                    dragging=false; globalMove:Disconnect(); globalMove=nil; return
                end
                local d=i.Position-startMouse
                target.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                          startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=false
            if globalMove then globalMove:Disconnect(); globalMove=nil end
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Tooltip system
-- ─────────────────────────────────────────────────────────────────────────────
local Tooltip=(function()
    local gui,frame,label,moveConn
    local function Ensure()
        if gui and gui.Parent then return end
        local old=CoreGui:FindFirstChild("_tooltip_")
        if old then old:Destroy() end
        gui=New("ScreenGui",{Name="_tooltip_",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
            DisplayOrder=20,ResetOnSpawn=false,Enabled=false})
        SafeParent(gui)
        frame=New("Frame",{BackgroundColor3=Color3.fromRGB(22,22,22),
            BorderColor3=Color3.fromRGB(75,75,75),Size=UDim2.new(0,0,0,22),
            AutomaticSize=Enum.AutomaticSize.X,Parent=gui})
        New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),
            PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),Parent=frame})
        label=New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            Font=Enum.Font.Code,Text="",TextColor3=Color3.fromRGB(200,200,200),
            TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=frame})
    end
    local function UpdatePos(mp)
        if not frame then return end
        local vp=workspace.CurrentCamera.ViewportSize
        local fs=frame.AbsoluteSize
        local x,y=mp.X+14,mp.Y+6
        if x+fs.X>vp.X-4 then x=mp.X-fs.X-14 end
        if y+fs.Y>vp.Y-4 then y=mp.Y-fs.Y-6 end
        frame.Position=UDim2.new(0,math.floor(x),0,math.floor(y))
    end
    local function Show(text)
        Ensure(); label.Text=tostring(text); gui.Enabled=true
        if moveConn then moveConn:Disconnect() end
        moveConn=UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement then UpdatePos(inp.Position) end
        end)
        UpdatePos(UserInputService:GetMouseLocation())
    end
    local function Hide()
        if gui then gui.Enabled=false end
        if moveConn then moveConn:Disconnect(); moveConn=nil end
    end
    return {Show=Show,Hide=Hide}
end)()

local function AttachTooltip(obj,tip)
    if not tip or tip=="" then return end
    obj.MouseEnter:Connect(function() Tooltip.Show(tip) end)
    obj.MouseLeave:Connect(function() Tooltip.Hide() end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Notification system
-- ─────────────────────────────────────────────────────────────────────────────
local NotifGui,NotifContainer
local function EnsureNotifGui()
    local ga=NotifGui       and NotifGui:IsDescendantOf(game)
    local ca=NotifContainer and NotifContainer:IsDescendantOf(game)
    if ga and ca then return end
    if NotifGui and NotifGui.Parent then pcall(function() NotifGui:Destroy() end) end
    local old=CoreGui:FindFirstChild("_notifs_")
    if old then old:Destroy() end
    NotifGui=New("ScreenGui",{Name="_notifs_",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=10,ResetOnSpawn=false})
    SafeParent(NotifGui)
    NotifContainer=New("Frame",{Name="Container",BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-10,1,-10),
        Size=UDim2.new(0,300,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=NotifGui})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,6),Parent=NotifContainer})
end

function UILibrary:Notify(title,message,ntype,duration)
    EnsureNotifGui()
    ntype=ntype or "info"; duration=duration or 3
    title=tostring(title or "Notification"); message=tostring(message or "")
    local notifColors={info=Color3.fromRGB(75,75,75),success=Color3.fromRGB(30,140,60),
        warning=Color3.fromRGB(200,150,0),error=Color3.fromRGB(125,0,4)}
    local accent=notifColors[ntype] or notifColors.info
    local order=math.floor(os.clock()*1000)%2147483647
    local Wrapper=New("Frame",{Name="Notif_"..order,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,60),LayoutOrder=order,ClipsDescendants=true,Parent=NotifContainer})
    local Card=New("Frame",{Name="Card",BackgroundColor3=Color3.fromRGB(16,16,16),
        BorderColor3=Color3.fromRGB(75,75,75),Position=UDim2.new(0,310,0,0),
        Size=UDim2.new(1,0,1,0),Parent=Wrapper})
    New("Frame",{BackgroundColor3=accent,BorderSizePixel=0,
        Position=UDim2.new(0,0,0,0),Size=UDim2.new(0,4,1,0),Parent=Card})
    New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.new(0,12,0,8),Size=UDim2.new(1,-16,0,18),
        Font=Enum.Font.Code,Text=title,TextColor3=Color3.fromRGB(255,255,255),TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=Card})
    New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.new(0,12,0,28),Size=UDim2.new(1,-16,0,24),
        Font=Enum.Font.Code,Text=message,TextColor3=Color3.fromRGB(160,160,160),TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=Card})
    local TimerBar=New("Frame",{BackgroundColor3=accent,BorderSizePixel=0,
        Position=UDim2.new(0,0,0,58),Size=UDim2.new(1,0,0,2),Parent=Card})
    TweenQuad(Card,.22,{Position=UDim2.new(0,0,0,0)})
    TweenLinear(TimerBar,duration,{Size=UDim2.new(0,0,0,2)})
    task.delay(duration,function()
        if not Card or not Card.Parent then return end
        local tw=TweenService:Create(Card,TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {Position=UDim2.new(0,310,0,0)})
        tw:Play()
        tw.Completed:Connect(function() if Wrapper and Wrapper.Parent then Wrapper:Destroy() end end)
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CreateWindow
-- ─────────────────────────────────────────────────────────────────────────────
function UILibrary:CreateWindow(cfg)
    cfg=cfg or {}
    local toggleKey  = cfg.key   or Enum.KeyCode.RightShift
    local scriptName = tostring(cfg.name  or "Script")
    local showFPS    = cfg.fps   ~= false
    local showClock  = cfg.clock ~= false

    local cw
    if type(cfg.theme)=="string" then
        cw=Colorways[cfg.theme] or Colorways.crimson
    elseif type(cfg.theme)=="table" then
        cw=cfg.theme
    elseif typeof(cfg.theme)=="Color3" then
        cw=cfg.theme
    else
        cw=Colorways.crimson
    end
    local T=BuildTheme(cw)

    for _,n in ipairs({"_index_","_wmk_"}) do
        local o=CoreGui:FindFirstChild(n)
        if o then o:Destroy() end
    end

    -- ── Main ScreenGui ────────────────────────────────────────────────────────
    local Gui=New("ScreenGui",{Name="_index_",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=1,ResetOnSpawn=false})
    SafeParent(Gui)

    local Frame1=New("Frame",{Name="_frame1",BackgroundColor3=T.Frame1_BG,BorderSizePixel=0,
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),
        Size=UDim2.new(0,630,0,390),Parent=Gui})

    local Frame2=New("Frame",{Name="_frame2",BackgroundColor3=T.Frame2_BG,BorderColor3=T.Frame2_Bdr,
        Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,620,0,380),Parent=Frame1})

    local TabBar=New("Frame",{Name="__tabs",BackgroundColor3=T.TabBar_BG,BorderColor3=T.TabBar_Bdr,
        Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,608,0,45),Parent=Frame2})
    New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,
        SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,1),Parent=TabBar})

    local ContentArea=New("Frame",{Name="__tabContent",BackgroundColor3=T.Content_BG,
        BorderColor3=T.Content_Bdr,Position=UDim2.new(0,6,0,59),Size=UDim2.new(0,608,0,314),
        ClipsDescendants=true,Parent=Frame2})

    MakeDraggable(TabBar,Frame1)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Watermark — authentic old CSGO style
    -- Single dark rect + one RichText TextLabel
    -- Format: "SCRIPTNAME | username | fps 142 | 14:32"
    -- Name = accent color, pipes = dim, fps number = green/amber/red, rest = subtext
    -- ─────────────────────────────────────────────────────────────────────────
    local oldWmk=CoreGui:FindFirstChild("_wmk_")
    if oldWmk then oldWmk:Destroy() end

    local WmkGui=New("ScreenGui",{Name="_wmk_",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=5,ResetOnSpawn=false,Enabled=true})
    SafeParent(WmkGui)

    local WmkFrame=New("Frame",{Name="WmkFrame",BackgroundColor3=T.Frame2_BG,
        BackgroundTransparency=0.15,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0),Position=UDim2.new(0,10,0,10),
        Size=UDim2.new(0,0,0,0),AutomaticSize=Enum.AutomaticSize.XY,Parent=WmkGui})
    New("UIPadding",{PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5),
        PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),Parent=WmkFrame})

    local WmkLabel=New("TextLabel",{Name="WmkLabel",BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(0,0,0,0),AutomaticSize=Enum.AutomaticSize.XY,
        Font=T.Font,Text="",TextColor3=T.SubText,TextSize=12,RichText=true,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
        Parent=WmkFrame})

    local function RGBStr(c)
        return string.format("rgb(%d,%d,%d)",
            math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5))
    end
    local accentHex = RGBStr(T.Accent)
    local dimHex    = RGBStr(T.DimText)
    local subHex    = RGBStr(T.SubText)
    local localName = (Players.LocalPlayer and Players.LocalPlayer.Name) or "Player"
    local pipe      = ' <font color="'..dimHex..'">|</font> '
    local curFps    = 0
    local curFpsCol = T.SubText
    local curClock  = "00:00"

    local function RebuildWmk()
        local fpsHex = RGBStr(curFpsCol)
        local parts  = {
            '<font color="'..accentHex..'">'..string.upper(scriptName)..'</font>',
            pipe,
            '<font color="'..subHex..'">'..localName..'</font>',
        }
        if showFPS then
            table.insert(parts,pipe)
            table.insert(parts,'<font color="'..dimHex..'">fps</font> <font color="'..fpsHex..'">'..curFps..'</font>')
        end
        if showClock then
            table.insert(parts,pipe)
            table.insert(parts,'<font color="'..subHex..'">'..curClock..'</font>')
        end
        WmkLabel.Text=table.concat(parts)
    end

    if showFPS then
        local frames,timer=0,0
        RunService.RenderStepped:Connect(function(dt)
            frames+=1; timer+=dt
            if timer>=.5 then
                local fps=math.floor(frames/timer+.5); frames,timer=0,0; curFps=fps
                curFpsCol = fps>=60 and Color3.fromRGB(30,160,60)
                         or fps>=30 and Color3.fromRGB(200,150,0)
                         or              Color3.fromRGB(180,40,40)
                RebuildWmk()
            end
        end)
    end
    if showClock then
        local lastClock=""
        RunService.Heartbeat:Connect(function()
            local t=os.date("*t")
            local s=string.format("%02d:%02d",t.hour,t.min)
            if s~=lastClock then lastClock=s; curClock=s; RebuildWmk() end
        end)
    end
    RebuildWmk()

    local function wmkEnabled() return Frame1.Visible end
    MakeDraggable(WmkFrame,WmkFrame,wmkEnabled)

    UserInputService.InputBegan:Connect(function(inp,processed)
        if not processed and inp.KeyCode==toggleKey then
            Frame1.Visible=not Frame1.Visible
        end
    end)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Window object
    -- ─────────────────────────────────────────────────────────────────────────
    local Window={
        _gui=Gui,_wmkGui=WmkGui,_frame=Frame1,
        _tabBar=TabBar,_contentArea=ContentArea,
        _tabs={},_activeTab=nil,_theme=T,
    }
    function Window:SetVisible(v) self._frame.Visible=v end
    function Window:IsVisible()   return self._frame.Visible end
    function Window:Toggle()      self:SetVisible(not self:IsVisible()) end
    function Window:Destroy()     self._gui:Destroy(); self._wmkGui:Destroy() end

    -- ─────────────────────────────────────────────────────────────────────────
    -- AddTab
    -- ─────────────────────────────────────────────────────────────────────────
    function Window:AddTab(name)
        local index=#self._tabs+1

        local Btn=New("TextButton",{Name="Tab_"..name,Font=T.Font,Text=name,
            TextColor3=T.Text,TextSize=T.FontSize,TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=false,
            BackgroundColor3=T.TabInactive_BG,BorderSizePixel=0,
            Size=UDim2.new(0,151,0,45),LayoutOrder=index,AutoButtonColor=false,
            Parent=self._tabBar})

        local ActiveBar=New("Frame",{Name="ActiveBar",BackgroundColor3=T.Accent,BorderSizePixel=0,
            Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),Visible=false,ZIndex=2,Parent=Btn})

        local Page=New("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,
            ScrollBarImageColor3=T.Accent,ScrollingDirection=Enum.ScrollingDirection.Y,
            Visible=false,Parent=self._contentArea})
        New("UIPadding",{PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),
            PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),Parent=Page})

        local Holder=New("Frame",{Name="ColumnHolder",BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=Page})

        local LeftCol=New("Frame",{Name="LeftCol",BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0,0,0,0),Size=UDim2.new(0,292,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,Parent=Holder})
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10),Parent=LeftCol})

        local RightCol=New("Frame",{Name="RightCol",BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0,300,0,0),Size=UDim2.new(0,292,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,Parent=Holder})
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10),Parent=RightCol})

        local Tab={_btn=Btn,_bar=ActiveBar,_page=Page,_leftCol=LeftCol,_rightCol=RightCol,
            _window=self,_btnTween=nil}

        function Tab:Select()
            local prev=self._window._activeTab
            if prev and prev~=self then
                prev._page.Visible=false; prev._bar.Visible=false
                if prev._btnTween then prev._btnTween:Cancel() end
                prev._btnTween=TweenQuadHandle(prev._btn,.10,{BackgroundColor3=T.TabInactive_BG})
            end
            self._page.Visible=true; self._bar.Visible=true
            if self._btnTween then self._btnTween:Cancel() end
            self._btnTween=TweenQuadHandle(self._btn,.10,{BackgroundColor3=T.TabActive_BG})
            self._window._activeTab=self
        end

        Btn.MouseButton1Click:Connect(function() Tab:Select() end)
        Btn.MouseEnter:Connect(function()
            if self._activeTab~=Tab then TweenQuad(Btn,.08,{BackgroundColor3=T.TabHover_BG}) end
        end)
        Btn.MouseLeave:Connect(function()
            if self._activeTab~=Tab then TweenQuad(Btn,.08,{BackgroundColor3=T.TabInactive_BG}) end
        end)

        table.insert(self._tabs,Tab)
        if #self._tabs==1 then Tab:Select() end

        -- ─────────────────────────────────────────────────────────────────────
        -- AddSection
        -- ─────────────────────────────────────────────────────────────────────
        function Tab:AddSection(sectionName,side)
            side=(side=="right") and "right" or "left"
            local Col=(side=="right") and self._rightCol or self._leftCol
            local order=#Col:GetChildren()

            -- ImGui groupbox: 1px visible border, dark bg, title row + sep inside
            local SectionFrame=New("Frame",{Name="Sec_"..sectionName,
                BackgroundColor3=T.Frame2_BG,BorderColor3=T.Frame2_Bdr,
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
                LayoutOrder=order,Parent=Col})

            -- Title row: 20px, uppercase label + 1px sep at bottom
            local TitleRow=New("Frame",{Name="TitleRow",BackgroundTransparency=1,
                BorderSizePixel=0,Size=UDim2.new(1,0,0,20),Parent=SectionFrame})
            New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-6,1,0),
                Font=T.Font,Text=string.upper(sectionName),TextColor3=T.SubText,TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                Parent=TitleRow})
            New("Frame",{Name="TitleSep",BackgroundColor3=T.Separator,BorderSizePixel=0,
                Position=UDim2.new(0,0,0,19),Size=UDim2.new(1,0,0,1),Parent=TitleRow})

            -- Body: starts at y=20, 5px padding all sides, 3px item gap
            local Body=New("Frame",{Name="Body",BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,Parent=SectionFrame})
            New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,
                Padding=UDim.new(0,3),Parent=Body})
            New("UIPadding",{PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5),
                PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5),Parent=Body})

            local elementCount=0
            local sectionDropdowns={}
            local function NextOrder() elementCount+=1; return elementCount end

            local Section={_body=Body}

            -- ─────────────────────────────────────────────────────────────────
            -- AddToggle
            -- 22px row. Checkbox 12×12 at pos(4,5) — (22-12)/2=5 ✓
            -- Label at x=20 — 4+12+4=20 ✓
            -- Instant color change (no tween). Full-row hitbox.
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddToggle(label,default,callback,tooltip)
                default=(default==true); callback=callback or function() end
                local state=default

                local Row=New("Frame",{Name="Toggle_"..label,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,22),LayoutOrder=NextOrder(),Parent=Body})

                local Box=New("TextButton",{Name="Box",
                    BackgroundColor3=state and T.Checkbox_On or T.Checkbox_BG,
                    BorderColor3=T.Checkbox_Bdr,
                    Position=UDim2.new(0,4,0,5),Size=UDim2.new(0,12,0,12),
                    Text="",AutoButtonColor=false,Parent=Row})

                New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,20,0,0),Size=UDim2.new(1,-20,1,0),
                    Font=T.Font,Text=label,TextColor3=T.Text,TextSize=T.FontSize,
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                    Parent=Row})

                local HitBox=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0),Text="",AutoButtonColor=false,ZIndex=2,Parent=Row})

                local function Apply(val,silent)
                    state=val
                    Box.BackgroundColor3=state and T.Checkbox_On or T.Checkbox_BG
                    if not silent then callback(state) end
                end

                HitBox.MouseButton1Click:Connect(function() Apply(not state,false) end)
                Box.MouseButton1Click:Connect(function()    Apply(not state,false) end)
                AttachTooltip(Row,tooltip)

                return {
                    Set    = function(_,v) Apply(v,true)          end,
                    Get    = function(_)   return state            end,
                    Toggle = function(_)   Apply(not state,false)  end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddSlider
            -- 32px row. Label 14px top row. Track at y=18, height=14.
            -- Value text overlaid centered on track in white.
            -- No thumb. ValBox on right for manual entry.
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddSlider(label,min,max,default,decimals,callback,tooltip)
                min=tonumber(min) or 0; max=tonumber(max) or 100
                default=tonumber(default) or min; decimals=tonumber(decimals) or 0
                callback=callback or function() end
                default=Clamp(default,min,max)
                local value=Round(default,decimals)

                local Row=New("Frame",{Name="Slider_"..label,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,32),LayoutOrder=NextOrder(),Parent=Body})

                New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,-46,0,14),
                    Font=T.Font,Text=label,TextColor3=T.Text,TextSize=T.FontSize,
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                    Parent=Row})

                local ValBox=New("Frame",{Name="ValBox",BackgroundColor3=T.Slider_ValBox,
                    BorderColor3=T.Separator,Position=UDim2.new(1,-46,0,0),
                    Size=UDim2.new(0,46,0,14),Parent=Row})
                local ValBtn=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0),Font=T.Font,Text=FormatNum(value,decimals),
                    TextColor3=T.SubText,TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,
                    TextYAlignment=Enum.TextYAlignment.Center,AutoButtonColor=false,Parent=ValBox})

                -- Track: y=18 (14px label + 4px gap), h=14 — thick for value text readability
                local TrackBG=New("Frame",{Name="TrackBG",BackgroundColor3=T.Slider_Track,
                    BorderSizePixel=0,Position=UDim2.new(0,0,0,18),
                    Size=UDim2.new(1,0,0,14),ClipsDescendants=true,Parent=Row})
                local Fill=New("Frame",{Name="Fill",BackgroundColor3=T.Slider_Fill,
                    BorderSizePixel=0,Size=UDim2.new(0,0,1,0),Parent=TrackBG})
                -- Value text overlay: centered on full track width, always white
                local ValOverlay=New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0),Font=T.Font,Text=FormatNum(value,decimals),
                    TextColor3=Color3.new(1,1,1),TextSize=11,
                    TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,
                    ZIndex=2,Parent=TrackBG})

                local function SetValue(v,silent)
                    value=Round(Clamp(v,min,max),decimals)
                    local frac=Map(value,min,max,0,1)
                    Fill.Size=UDim2.new(frac,0,1,0)
                    ValOverlay.Text=FormatNum(value,decimals)
                    ValBtn.Text=FormatNum(value,decimals)
                    if not silent then callback(value) end
                end
                SetValue(value,true)

                local sliding,moveConn,releaseConn=false,nil,nil
                local function StopSlide()
                    sliding=false
                    if moveConn    then moveConn:Disconnect();    moveConn=nil    end
                    if releaseConn then releaseConn:Disconnect(); releaseConn=nil end
                end
                local function SlideTo(inp)
                    local ax=TrackBG.AbsolutePosition.X; local aw=TrackBG.AbsoluteSize.X
                    SetValue(Map(Clamp((inp.Position.X-ax)/aw,0,1),0,1,min,max),false)
                end
                local function StartSlide(inp)
                    sliding=true; SlideTo(inp)
                    if moveConn    then moveConn:Disconnect()    end
                    if releaseConn then releaseConn:Disconnect() end
                    moveConn=UserInputService.InputChanged:Connect(function(i)
                        if not sliding then return end
                        if i.UserInputType~=Enum.UserInputType.MouseMovement
                        and i.UserInputType~=Enum.UserInputType.Touch then return end
                        SlideTo(i)
                    end)
                    releaseConn=UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType==Enum.UserInputType.MouseButton1
                        or i.UserInputType==Enum.UserInputType.Touch then StopSlide() end
                    end)
                end
                TrackBG.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1
                    or inp.UserInputType==Enum.UserInputType.Touch then StartSlide(inp) end
                end)
                ValBtn.MouseButton1Click:Connect(function()
                    if sliding then return end
                    if not ValBox or not ValBox.Parent then return end
                    local TB=New("TextBox",{BackgroundColor3=T.Slider_ValBox,BorderColor3=T.Accent,
                        Size=UDim2.new(1,0,1,0),Font=T.Font,Text=FormatNum(value,decimals),
                        TextColor3=T.Text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,
                        ClearTextOnFocus=true,Parent=ValBox})
                    TB:CaptureFocus()
                    TB.FocusLost:Connect(function()
                        pcall(function()
                            if not TB or not TB.Parent then return end
                            local n=tonumber(TB.Text); if n then SetValue(n,false) end
                            TB:Destroy()
                        end)
                    end)
                end)
                AttachTooltip(Row,tooltip)
                return {
                    Set=function(_,v) SetValue(v,true) end,
                    Get=function(_)   return value      end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddDropdown
            -- 22px closed. Arrow 18px. Items 20px.
            -- Label size(1,-24): 6px left + 18px arrow = 24 ✓
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddDropdown(label,options,default,callback,tooltip)
                options=options or {}; callback=callback or function() end
                local selected=default or options[1] or ""
                local isOpen=false
                local CLOSED_H=22; local ITEM_H=20
                local OPEN_H=CLOSED_H+1+(#options*ITEM_H)

                local Row=New("Frame",{Name="DD_"..label,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,CLOSED_H),
                    LayoutOrder=NextOrder(),ClipsDescendants=true,Parent=Body})
                local DHeader=New("Frame",{Name="DHeader",BackgroundColor3=T.Dropdown_BG,
                    BorderColor3=T.Separator,Size=UDim2.new(1,0,0,CLOSED_H),Parent=Row})
                local SelLbl=New("TextLabel",{Name="SelLabel",BackgroundTransparency=1,
                    BorderSizePixel=0,Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-24,1,0),
                    Font=T.Font,Text=selected,TextColor3=T.Text,TextSize=T.FontSize,
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                    TextTruncate=Enum.TextTruncate.AtEnd,Parent=DHeader})
                local Arrow=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(1,-18,0,0),Size=UDim2.new(0,18,1,0),
                    Font=T.Font,Text="▾",TextColor3=T.SubText,TextSize=11,
                    TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,
                    AutoButtonColor=false,ZIndex=2,Parent=DHeader})
                local List=New("Frame",{BackgroundColor3=T.Dropdown_List,BorderColor3=T.Separator,
                    Position=UDim2.new(0,0,0,CLOSED_H+1),
                    Size=UDim2.new(1,0,0,#options*ITEM_H),Visible=false,Parent=Row})

                local ddEntry={}
                local function SetOpen(open)
                    if open then
                        for _,e in ipairs(sectionDropdowns) do
                            if e~=ddEntry and e.isOpen then e.Close() end
                        end
                    end
                    isOpen=open; ddEntry.isOpen=open
                    Arrow.Text=open and "▴" or "▾"; List.Visible=open
                    Row.Size=UDim2.new(1,0,0,open and OPEN_H or CLOSED_H)
                end
                ddEntry.isOpen=false
                ddEntry.Close=function()
                    isOpen=false; ddEntry.isOpen=false; Arrow.Text="▾"
                    List.Visible=false; Row.Size=UDim2.new(1,0,0,CLOSED_H)
                end
                table.insert(sectionDropdowns,ddEntry)

                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                    local mp=UserInputService:GetMouseLocation()
                    local ap,as=Arrow.AbsolutePosition,Arrow.AbsoluteSize
                    if mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y then return end
                    SetOpen(not isOpen)
                end)
                Arrow.MouseButton1Click:Connect(function() SetOpen(not isOpen) end)

                local itemRefs={}
                for i,opt in ipairs(options) do
                    local Item=New("Frame",{BackgroundColor3=T.Dropdown_List,BorderSizePixel=0,
                        Position=UDim2.new(0,0,0,(i-1)*ITEM_H),Size=UDim2.new(1,0,0,ITEM_H),Parent=List})
                    local ItemBtn=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
                        Size=UDim2.new(1,0,1,0),Font=T.Font,Text=opt,
                        TextColor3=(opt==selected) and T.Dropdown_Sel or T.Text,TextSize=T.FontSize,
                        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                        AutoButtonColor=false,Parent=Item})
                    New("UIPadding",{PaddingLeft=UDim.new(0,6),Parent=ItemBtn})
                    itemRefs[opt]=ItemBtn
                    Item.MouseEnter:Connect(function() Item.BackgroundColor3=T.Dropdown_Hover end)
                    Item.MouseLeave:Connect(function() Item.BackgroundColor3=T.Dropdown_List  end)
                    ItemBtn.MouseButton1Click:Connect(function()
                        if itemRefs[selected] then itemRefs[selected].TextColor3=T.Text end
                        selected=opt; SelLbl.Text=selected; ItemBtn.TextColor3=T.Dropdown_Sel
                        SetOpen(false); callback(selected)
                    end)
                end
                AttachTooltip(DHeader,tooltip)
                return {
                    Set=function(_,v,silent)
                        if itemRefs[selected] then itemRefs[selected].TextColor3=T.Text end
                        selected=v; SelLbl.Text=v
                        if itemRefs[v] then itemRefs[v].TextColor3=T.Dropdown_Sel end
                        if isOpen then SetOpen(false) end
                        if not silent then callback(selected) end
                    end,
                    Get=function(_) return selected end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddMultiDropdown
            -- Same proportions as AddDropdown. Items 20px, footer 20px.
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddMultiDropdown(label,options,defaults,callback,tooltip)
                options=options or {}; defaults=defaults or {}; callback=callback or function() end
                local selected={}
                for _,v in ipairs(defaults) do selected[v]=true end
                local CLOSED_H=22; local ITEM_H=20; local FOOT_H=20
                local OPEN_H=CLOSED_H+1+(#options*ITEM_H)+FOOT_H

                local Row=New("Frame",{Name="MDD_"..label,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,CLOSED_H),
                    LayoutOrder=NextOrder(),ClipsDescendants=true,Parent=Body})
                local DHeader=New("Frame",{BackgroundColor3=T.Dropdown_BG,BorderColor3=T.Separator,
                    Size=UDim2.new(1,0,0,CLOSED_H),Parent=Row})
                local SelLabel=New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-24,1,0),
                    Font=T.Font,Text=label,TextColor3=T.DimText,TextSize=T.FontSize,
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                    TextTruncate=Enum.TextTruncate.AtEnd,Parent=DHeader})
                local Arrow=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(1,-18,0,0),Size=UDim2.new(0,18,1,0),
                    Font=T.Font,Text="▾",TextColor3=T.SubText,TextSize=11,
                    TextXAlignment=Enum.TextXAlignment.Center,AutoButtonColor=false,ZIndex=2,Parent=DHeader})
                local List=New("Frame",{BackgroundColor3=T.Dropdown_List,BorderColor3=T.Separator,
                    Position=UDim2.new(0,0,0,CLOSED_H+1),
                    Size=UDim2.new(1,0,0,#options*ITEM_H+FOOT_H),Visible=false,Parent=Row})

                local mddEntry={}
                local function SetOpen(open)
                    if open then
                        for _,e in ipairs(sectionDropdowns) do
                            if e~=mddEntry and e.isOpen then e.Close() end
                        end
                    end
                    isOpen=open; mddEntry.isOpen=open
                    Arrow.Text=open and "▴" or "▾"; List.Visible=open
                    Row.Size=UDim2.new(1,0,0,open and OPEN_H or CLOSED_H)
                end
                mddEntry.isOpen=false
                mddEntry.Close=function()
                    isOpen=false; mddEntry.isOpen=false; Arrow.Text="▾"
                    List.Visible=false; Row.Size=UDim2.new(1,0,0,CLOSED_H)
                end
                table.insert(sectionDropdowns,mddEntry)

                local function GetSelection()
                    local out={}
                    for _,opt in ipairs(options) do if selected[opt] then table.insert(out,opt) end end
                    return out
                end
                local function RefreshHeader()
                    local parts={}
                    for _,opt in ipairs(options) do if selected[opt] then table.insert(parts,opt) end end
                    if #parts==0 then SelLabel.Text=label; SelLabel.TextColor3=T.DimText
                    else SelLabel.Text=table.concat(parts,", "); SelLabel.TextColor3=T.Text end
                end

                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                    local mp=UserInputService:GetMouseLocation()
                    local ap,as=Arrow.AbsolutePosition,Arrow.AbsoluteSize
                    if mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y then return end
                    SetOpen(not isOpen)
                end)
                Arrow.MouseButton1Click:Connect(function() SetOpen(not isOpen) end)

                local itemBoxes={}
                for i,opt in ipairs(options) do
                    local Item=New("Frame",{BackgroundColor3=T.Dropdown_List,BorderSizePixel=0,
                        Position=UDim2.new(0,0,0,(i-1)*ITEM_H),Size=UDim2.new(1,0,0,ITEM_H),Parent=List})
                    local CB=New("Frame",{
                        BackgroundColor3=selected[opt] and T.Checkbox_On or T.Checkbox_BG,
                        BorderColor3=T.Separator,Position=UDim2.new(0,6,0,4),
                        Size=UDim2.new(0,12,0,12),Parent=Item})
                    itemBoxes[opt]=CB
                    local ItemLbl=New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                        Position=UDim2.new(0,24,0,0),Size=UDim2.new(1,-30,1,0),
                        Font=T.Font,Text=opt,
                        TextColor3=selected[opt] and T.Dropdown_Sel or T.Text,TextSize=T.FontSize,
                        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                        TextTruncate=Enum.TextTruncate.AtEnd,Parent=Item})
                    local ItemBtn=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
                        Size=UDim2.new(1,0,1,0),Text="",AutoButtonColor=false,ZIndex=2,Parent=Item})
                    Item.MouseEnter:Connect(function() Item.BackgroundColor3=T.Dropdown_Hover end)
                    Item.MouseLeave:Connect(function() Item.BackgroundColor3=T.Dropdown_List  end)
                    ItemBtn.MouseButton1Click:Connect(function()
                        selected[opt]=not selected[opt]
                        CB.BackgroundColor3=selected[opt] and T.Checkbox_On or T.Checkbox_BG
                        ItemLbl.TextColor3=selected[opt] and T.Dropdown_Sel or T.Text
                        RefreshHeader(); callback(GetSelection())
                    end)
                end

                local Footer=New("Frame",{BackgroundColor3=T.Dropdown_List,BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,#options*ITEM_H),
                    Size=UDim2.new(1,0,0,FOOT_H),Parent=List})
                New("Frame",{BackgroundColor3=T.Separator,BorderSizePixel=0,
                    Size=UDim2.new(1,0,0,1),Parent=Footer})
                New("Frame",{BackgroundColor3=T.Separator,BorderSizePixel=0,
                    Position=UDim2.new(0.5,0,0,1),Size=UDim2.new(0,1,0,FOOT_H-1),Parent=Footer})
                local function FootBtn(txt,xScale,xOff)
                    local b=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
                        Position=UDim2.new(xScale,xOff,0,1),Size=UDim2.new(0.5,-1,0,FOOT_H-1),
                        Font=T.Font,Text=txt,TextColor3=T.SubText,TextSize=11,
                        TextXAlignment=Enum.TextXAlignment.Center,AutoButtonColor=false,Parent=Footer})
                    b.MouseEnter:Connect(function() b.TextColor3=T.Text    end)
                    b.MouseLeave:Connect(function() b.TextColor3=T.SubText end)
                    return b
                end
                local BtnAll=FootBtn("Select All",0,0)
                local BtnClear=FootBtn("Clear",0.5,1)

                local function ApplyAll(state)
                    for _,opt in ipairs(options) do
                        selected[opt]=state
                        itemBoxes[opt].BackgroundColor3=state and T.Checkbox_On or T.Checkbox_BG
                    end
                    for i=1,#options do
                        local item=List:GetChildren()[i]
                        if item then
                            local lbl=item:FindFirstChildWhichIsA("TextLabel")
                            if lbl then lbl.TextColor3=state and T.Dropdown_Sel or T.Text end
                        end
                    end
                    RefreshHeader(); callback(GetSelection())
                end
                BtnAll.MouseButton1Click:Connect(function()   ApplyAll(true)  end)
                BtnClear.MouseButton1Click:Connect(function() ApplyAll(false) end)

                AttachTooltip(DHeader,tooltip)
                RefreshHeader()
                return {
                    Set=function(_,tbl,silent)
                        selected={}
                        for _,v in ipairs(tbl) do selected[v]=true end
                        for i,opt in ipairs(options) do
                            local on=selected[opt]==true
                            itemBoxes[opt].BackgroundColor3=on and T.Checkbox_On or T.Checkbox_BG
                            local item=List:GetChildren()[i]
                            if item then
                                local lbl=item:FindFirstChildWhichIsA("TextLabel")
                                if lbl then lbl.TextColor3=on and T.Dropdown_Sel or T.Text end
                            end
                        end
                        RefreshHeader()
                        if not silent then callback(GetSelection()) end
                    end,
                    Get=function(_) return GetSelection() end,
                    Clear=function(_) ApplyAll(false) end,
                    SelectAll=function(_) ApplyAll(true) end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddTextInput  (40px total: 16px label + 4px gap + 20px field)
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddTextInput(label,placeholder,callback,cfg)
                cfg=cfg or {}; placeholder=placeholder or ""; callback=callback or function() end
                local live=cfg.live==true; local maxLen=tonumber(cfg.maxLength) or 0

                local Row=New("Frame",{Name="TextInput_"..label,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,40),LayoutOrder=NextOrder(),Parent=Body})
                New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0,16),
                    Font=T.Font,Text=label,TextColor3=T.Text,TextSize=T.FontSize,
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                    Parent=Row})
                local Field=New("Frame",{BackgroundColor3=T.Slider_ValBox,BorderColor3=T.Separator,
                    Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,20),Parent=Row})
                local TB=New("TextBox",{BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0),Font=T.Font,PlaceholderText=placeholder,
                    PlaceholderColor3=T.DimText,Text="",TextColor3=T.Text,TextSize=13,
                    TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=Field})
                New("UIPadding",{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5),Parent=TB})
                if maxLen>0 then
                    TB:GetPropertyChangedSignal("Text"):Connect(function()
                        if #TB.Text>maxLen then TB.Text=string.sub(TB.Text,1,maxLen) end
                    end)
                end
                TB.Focused:Connect(function()     Field.BorderColor3=T.Accent    end)
                TB.FocusLost:Connect(function(e)  Field.BorderColor3=T.Separator; callback(TB.Text,e) end)
                if live then TB:GetPropertyChangedSignal("Text"):Connect(function() callback(TB.Text,false) end) end
                AttachTooltip(Row,cfg.tooltip)
                return {
                    Set=function(_,v) TB.Text=tostring(v or "") end,
                    Get=function(_)   return TB.Text end,
                    Clear=function(_) TB.Text="" end,
                    Focus=function(_) TB:CaptureFocus() end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddLabel  (16px)
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddLabel(text,tooltip)
                local order=NextOrder()
                local Lbl=New("TextLabel",{Name="Label_"..order,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,16),
                    Font=T.Font,Text=text,TextColor3=T.DimText,TextSize=T.HdrSize,
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                    LayoutOrder=order,Parent=Body})
                AttachTooltip(Lbl,tooltip)
                return {
                    Set=function(_,v) Lbl.Text=tostring(v) end,
                    Get=function(_)   return Lbl.Text end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddSeparator  (8px, line at y=3)
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddSeparator()
                local order=NextOrder()
                local Wrap=New("Frame",{Name="Sep_"..order,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,8),LayoutOrder=order,Parent=Body})
                New("Frame",{BackgroundColor3=T.Separator,BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,3),Size=UDim2.new(1,0,0,1),Parent=Wrap})
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddButton
            -- 22px. 1px border. Instant hover. Accent flash on press.
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddButton(label,callback,tooltip)
                callback=callback or function() end

                local Row=New("Frame",{Name="Btn_"..label,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,22),LayoutOrder=NextOrder(),Parent=Body})
                local Btn=New("TextButton",{Name="Face",BackgroundColor3=T.Dropdown_BG,
                    BorderColor3=T.Separator,Size=UDim2.new(1,0,1,0),
                    Font=T.Font,Text=label,TextColor3=T.Text,TextSize=T.FontSize,
                    TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,
                    AutoButtonColor=false,Parent=Row})

                local hovered=false
                Btn.MouseEnter:Connect(function()
                    hovered=true; Btn.BackgroundColor3=T.Dropdown_Hover end)
                Btn.MouseLeave:Connect(function()
                    hovered=false; Btn.BackgroundColor3=T.Dropdown_BG end)
                Btn.MouseButton1Down:Connect(function()
                    Btn.BackgroundColor3=T.Accent; Btn.TextColor3=Color3.new(1,1,1) end)
                Btn.MouseButton1Up:Connect(function()
                    Btn.BackgroundColor3=hovered and T.Dropdown_Hover or T.Dropdown_BG
                    Btn.TextColor3=T.Text end)
                Btn.MouseButton1Click:Connect(callback)
                AttachTooltip(Row,tooltip)
                return {
                    SetLabel=function(_,v) Btn.Text=tostring(v) end,
                    GetLabel=function(_)   return Btn.Text end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddColorPicker
            --
            -- HEADER (292px × 22px):
            --   Arrow:  pos(1,-18,0,0) size(0,18,1,0)  → left=274
            --   Swatch: pos(1,-62,0,4) size(0,40,0,14) → left=230, right=270
            --           gap to arrow = 274-270 = 4px ✓
            --   Label:  pos(0,6,0,0)   size(1,-72,1,0) → right=226
            --           gap to swatch = 230-226 = 4px ✓
            --
            -- OPEN PANEL (170px):
            --   y=4   SV  280×130
            --   y=138 Hue 280×8
            --   y=150 RGB 280×16
            --   y=170 (bottom pad 4px → total 170) ✓
            --   OPEN_H = 22+170 = 192
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddColorPicker(label,default,callback,tooltip)
                callback=callback or function() end
                default=default or Color3.fromRGB(255,0,0)

                local function C3toHSV(c)
                    local r,g,b=c.R,c.G,c.B
                    local mx=math.max(r,g,b); local mn=math.min(r,g,b); local d=mx-mn
                    local h,s,v=0,(mx==0) and 0 or d/mx,mx
                    if d~=0 then
                        if mx==r then h=((g-b)/d)%6/6
                        elseif mx==g then h=((b-r)/d+2)/6
                        else h=((r-g)/d+4)/6 end
                    end
                    return h,s,v
                end
                local function HSVtoC3(h,s,v)
                    local i=math.floor(h*6); local f=h*6-i
                    local p=v*(1-s); local q=v*(1-f*s); local t=v*(1-(1-f)*s)
                    local r,g,b
                    local seg=i%6
                    if     seg==0 then r,g,b=v,t,p
                    elseif seg==1 then r,g,b=q,v,p
                    elseif seg==2 then r,g,b=p,v,t
                    elseif seg==3 then r,g,b=p,q,v
                    elseif seg==4 then r,g,b=t,p,v
                    else               r,g,b=v,p,q end
                    return Color3.new(Clamp(r,0,1),Clamp(g,0,1),Clamp(b,0,1))
                end

                local curH,curS,curV=C3toHSV(default)
                local isOpen=false
                local CLOSED_H=22; local INNER_W=280
                local SV_H=130; local HUE_H=8; local RGB_H=16
                local PANEL_H=4+SV_H+4+HUE_H+4+RGB_H+4  -- 170
                local OPEN_H=CLOSED_H+PANEL_H             -- 192

                local Row=New("Frame",{Name="CP_"..label,BackgroundTransparency=1,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,CLOSED_H),
                    LayoutOrder=NextOrder(),ClipsDescendants=true,Parent=Body})

                -- Header
                local DHeader=New("Frame",{BackgroundColor3=T.Dropdown_BG,BorderColor3=T.Separator,
                    Size=UDim2.new(1,0,0,CLOSED_H),Parent=Row})
                New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-72,1,0),
                    Font=T.Font,Text=label,TextColor3=T.Text,TextSize=T.FontSize,
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
                    TextTruncate=Enum.TextTruncate.AtEnd,Parent=DHeader})
                local Swatch=New("Frame",{BackgroundColor3=default,BorderColor3=T.Separator,
                    Position=UDim2.new(1,-62,0,4),Size=UDim2.new(0,40,0,14),ZIndex=2,Parent=DHeader})
                local Arrow=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(1,-18,0,0),Size=UDim2.new(0,18,1,0),
                    Font=T.Font,Text="▾",TextColor3=T.SubText,TextSize=11,
                    TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,
                    AutoButtonColor=false,ZIndex=2,Parent=DHeader})

                -- Panel
                local Panel=New("Frame",{BackgroundColor3=T.Dropdown_BG,BorderColor3=T.Separator,
                    Position=UDim2.new(0,0,0,CLOSED_H),Size=UDim2.new(1,0,0,PANEL_H),Parent=Row})

                -- SV canvas (280×130, panel y=4)
                local SVCanvas=New("Frame",{BackgroundColor3=Color3.new(1,0,0),
                    BorderColor3=T.Separator,Position=UDim2.new(0,0,0,4),
                    Size=UDim2.new(1,0,0,SV_H),ClipsDescendants=true,Parent=Panel})
                local WhiteOvr=New("Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0),ZIndex=2,Parent=SVCanvas})
                New("UIGradient",{Transparency=NumberSequence.new({{Time=0,Value=0},{Time=1,Value=1}}),
                    Rotation=0,Parent=WhiteOvr})
                local BlackOvr=New("Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0),ZIndex=3,Parent=SVCanvas})
                New("UIGradient",{Transparency=NumberSequence.new({{Time=0,Value=1},{Time=1,Value=0}}),
                    Rotation=90,Parent=BlackOvr})
                local SVCursor=New("Frame",{BackgroundTransparency=1,BorderColor3=Color3.new(1,1,1),
                    BorderSizePixel=1,Size=UDim2.new(0,6,0,6),ZIndex=4,Parent=SVCanvas})

                -- Hue bar (280×8, panel y=4+130+4=138)
                local HueBar=New("Frame",{BackgroundColor3=Color3.new(1,1,1),
                    BorderColor3=T.Separator,Position=UDim2.new(0,0,0,4+SV_H+4),
                    Size=UDim2.new(1,0,0,HUE_H),ZIndex=2,Parent=Panel})
                New("UIGradient",{Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0/6,Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(1/6,Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(2/6,Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(3/6,Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(4/6,Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(5/6,Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(6/6,Color3.fromRGB(255,0,0)),
                }),Rotation=0,Parent=HueBar})
                local HueCursor=New("Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,
                    Size=UDim2.new(0,2,0,12),Position=UDim2.new(0,0,0,-2),ZIndex=3,Parent=HueBar})

                -- RGB row (280×16, panel y=4+130+4+8+4=150)
                local RGBRow=New("Frame",{BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,4+SV_H+4+HUE_H+4),
                    Size=UDim2.new(1,0,0,RGB_H),Parent=Panel})
                local function MakeRGB(ch,xPos,w)
                    local box=New("Frame",{BackgroundColor3=T.Slider_ValBox,BorderColor3=T.Separator,
                        Position=UDim2.new(0,xPos,0,0),Size=UDim2.new(0,w,1,0),Parent=RGBRow})
                    return New("TextLabel",{BackgroundTransparency=1,BorderSizePixel=0,
                        Size=UDim2.new(1,0,1,0),Font=T.Font,Text=ch..": 0",TextColor3=T.SubText,
                        TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,
                        TextYAlignment=Enum.TextYAlignment.Center,Parent=box})
                end
                -- R x=0 w=90 | G x=94 w=90 | B x=188 w=92 → total=280 ✓
                local RLbl=MakeRGB("R",0,90); local GLbl=MakeRGB("G",94,90); local BLbl=MakeRGB("B",188,92)

                -- Update helpers
                local function UpdSV(s,v)
                    local x=math.max(0,math.min(INNER_W-6,math.floor(s*(INNER_W-1)-3+.5)))
                    local y=math.max(0,math.min(SV_H-6,  math.floor((1-v)*(SV_H-1)-3+.5)))
                    SVCursor.Position=UDim2.new(0,x,0,y)
                end
                local function UpdHue(h)
                    local x=math.max(0,math.min(INNER_W-2,math.floor(h*(INNER_W-1)-1+.5)))
                    HueCursor.Position=UDim2.new(0,x,0,-2)
                end
                local function Refresh(silent)
                    SVCanvas.BackgroundColor3=HSVtoC3(curH,1,1)
                    UpdSV(curS,curV); UpdHue(curH)
                    local col=HSVtoC3(curH,curS,curV)
                    Swatch.BackgroundColor3=col
                    RLbl.Text="R: "..math.floor(col.R*255+.5)
                    GLbl.Text="G: "..math.floor(col.G*255+.5)
                    BLbl.Text="B: "..math.floor(col.B*255+.5)
                    if not silent then callback(col) end
                end
                Refresh(true)

                -- Open/close
                local function SetOpen(open)
                    isOpen=open; Arrow.Text=open and "▴" or "▾"
                    Row.Size=UDim2.new(1,0,0,open and OPEN_H or CLOSED_H)
                end
                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                    local mp=UserInputService:GetMouseLocation()
                    local ap,as=Arrow.AbsolutePosition,Arrow.AbsoluteSize
                    if mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y then return end
                    SetOpen(not isOpen)
                end)
                Arrow.MouseButton1Click:Connect(function() SetOpen(not isOpen) end)

                -- SV drag
                local svDrag,svMove,svRel=false,nil,nil
                local function SVFrom(inp)
                    local ap=SVCanvas.AbsolutePosition; local as=SVCanvas.AbsoluteSize
                    curS=Clamp((inp.Position.X-ap.X)/as.X,0,1)
                    curV=1-Clamp((inp.Position.Y-ap.Y)/as.Y,0,1)
                    Refresh(false)
                end
                local function StartSV(inp)
                    svDrag=true; SVFrom(inp)
                    if svMove then svMove:Disconnect() end
                    if svRel  then svRel:Disconnect()  end
                    svMove=UserInputService.InputChanged:Connect(function(i)
                        if not svDrag then return end
                        if i.UserInputType~=Enum.UserInputType.MouseMovement
                        and i.UserInputType~=Enum.UserInputType.Touch then return end
                        SVFrom(i)
                    end)
                    svRel=UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType==Enum.UserInputType.MouseButton1
                        or i.UserInputType==Enum.UserInputType.Touch then
                            svDrag=false
                            if svMove then svMove:Disconnect(); svMove=nil end
                            if svRel  then svRel:Disconnect();  svRel=nil  end
                        end
                    end)
                end
                SVCanvas.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1
                    or inp.UserInputType==Enum.UserInputType.Touch then StartSV(inp) end
                end)

                -- Hue drag
                local hueDrag,hueMove,hueRel=false,nil,nil
                local function HueFrom(inp)
                    local ap=HueBar.AbsolutePosition; local as=HueBar.AbsoluteSize
                    curH=Clamp((inp.Position.X-ap.X)/as.X,0,1); Refresh(false)
                end
                local function StartHue(inp)
                    hueDrag=true; HueFrom(inp)
                    if hueMove then hueMove:Disconnect() end
                    if hueRel  then hueRel:Disconnect()  end
                    hueMove=UserInputService.InputChanged:Connect(function(i)
                        if not hueDrag then return end
                        if i.UserInputType~=Enum.UserInputType.MouseMovement
                        and i.UserInputType~=Enum.UserInputType.Touch then return end
                        HueFrom(i)
                    end)
                    hueRel=UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType==Enum.UserInputType.MouseButton1
                        or i.UserInputType==Enum.UserInputType.Touch then
                            hueDrag=false
                            if hueMove then hueMove:Disconnect(); hueMove=nil end
                            if hueRel  then hueRel:Disconnect();  hueRel=nil  end
                        end
                    end)
                end
                HueBar.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1
                    or inp.UserInputType==Enum.UserInputType.Touch then StartHue(inp) end
                end)

                AttachTooltip(DHeader,tooltip)
                return {
                    Set=function(_,c)
                        c=c or Color3.new(1,0,0); curH,curS,curV=C3toHSV(c); Refresh(true)
                    end,
                    Get=function(_) return HSVtoC3(curH,curS,curV) end,
                }
            end

            return Section
        end  -- AddSection

        return Tab
    end  -- AddTab

    return Window
end  -- CreateWindow

return UILibrary
