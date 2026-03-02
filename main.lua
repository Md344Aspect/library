--[[
    UILibrary — CSGO-style | Font.Code | Colorways | Watermark | QOL Anims
    Version 2.0 — Slider | Advanced Watermark | Pixel-Perfect | Helpers
    ═══════════════════════════════════════════════════════════════════════

    COLORWAYS  (cfg.theme)
    ───────────────────────
      "red"    → RGB(125,  0,   4)   default
      "blue"   → RGB(0,   100, 200)
      "green"  → RGB(30,  140,  60)
      "purple" → RGB(100,  0,  160)
      "orange" → RGB(200,  90,   0)
      "cyan"   → RGB(0,   160, 180)
      "pink"   → RGB(200,   0, 120)
      "white"  → RGB(200, 200, 200)

    QOL ANIMATIONS  (colour tweens only — zero layout impact)
    ──────────────────────────────────────────────────────────
      Tab BG on select       Quad.Out  0.10s
      Tab BG on hover        Quad.Out  0.08s
      Checkbox BG toggle     Quad.Out  0.10s
      Dropdown item hover    Quad.Out  0.08s
      Slider fill            Quad.Out  0.06s
      Notif slide-in         Quad.Out  0.22s   x=310→0
      Notif slide-out        Quad.Out  0.16s   x=0→310 then Destroy
      Notif timer drain      Linear    duration seconds

    MAIN WINDOW  (all measurements in pixels)
    ══════════════════════════════════════════
    ScreenGui (_index_)  DisplayOrder=1  ZIndexBehavior=Sibling
    └── _frame1  630×390  BorderSizePixel=0  AnchorPoint(0.5,0.5)  centered
        │        BG RGB(29,29,29)   draggable via frame1+frame2+tabbar
        └── _frame2  620×380  pos=(5,5)  Border RGB(75,75,75) 1px
            │        BG RGB(16,16,16)
            ├── __tabs  608×45  pos=(6,8)  Border RGB(75,75,75) 1px
            │   │        BG RGB(16,16,16)   UIListLayout Horiz Padding=1px
            │   └── [tab buttons]  151×45 each  BorderSizePixel=0
            │             Active underbar 2px bottom  BG=accent
            └── __tabContent  608×314  pos=(6,59)
                │        Border RGB(75,75,75) 1px  BG RGB(16,16,16)
                │        ClipsDescendants=true
                └── [ScrollingFrame per tab]  Size(1,0,1,0)
                    │     UIPadding 8px all sides → usable 590×296
                    │     ScrollBarThickness=2
                    └── ColumnHolder  Size(1,0,0,0)  AutomaticSize=Y
                        ├── LeftCol   291×auto  x=0
                        └── RightCol  291×auto  x=299

    COLUMN MATH
    ───────────
      usable w = 606 - 16(pad) = 590px
      col w    = (590-8)/2 = 291px   right x = 291+8 = 299px

    SECTION  (291px wide)
    ──────────────────────
      SectionFrame  291×auto  AutomaticSize=Y  BG transparent
      Header        291×20
        Title       Font=Code FontSize=11  Left/Center  UPPER  RGB(180,180,180)
        Sep         Frame 291×1  y=19  RGB(75,75,75)
      Body          pos y=21  PaddingTop=5  gap=4px

    TOGGLE  (291×26)
    ─────────────────
      Row  291×26
      Box  14×14  x=4  y=6  Border RGB(75,75,75)  BG↔accent Quad.Out 0.10s
      Lbl  x=24  Size(1,-24,1,0)  Font=Code FontSize=14  Left/Center

    SLIDER  (291×38)
    ─────────────────
      Row  291×38  BG transparent
      ┌─ TopRow ─────────────────────────── 291×18 ─────────────────────┐
      │  Lbl   x=0   Size(1,-40,0,18)  Left/Center  Font=Code FontSize=14
      │  ValBox x=(1,-38)  Size(0,38,0,18)  BG RGB(22,22,22)
      │         Border RGB(75,75,75)  Font=Code FontSize=11  Center
      └──────────────────────────────────────────────────────────────────┘
      ┌─ Track ───────────────────────────  291×6  y=26 ─────────────────┐
      │  TrackBG  291×6  y=26  BG RGB(40,40,40)  BorderSizePixel=0
      │  Fill     pos=(0,0)  Size(fraction,0,1,0)  BG=accent
      │  Thumb    8×16  centered on fill right edge  BG=accent  circle hint
      └──────────────────────────────────────────────────────────────────┘
      Decimals: if decimals>0 → math.floor(v * 10^d) / 10^d

    DROPDOWN  (variable height)
    ─────────────────────────────
      CLOSED_H=26  OPEN_H=27+n×22
      DHeader 291×26  BG RGB(30,30,30)  Border RGB(75,75,75)
        SelLabel  x=6  Size(1,-26,1,0)  Font=Code FontSize=14
        Arrow     x=(1,-20)  Size(0,20,1,0)  "▾"/"▴"  FontSize=12
      List  y=27  Size(1,0,0,n×22)  BG RGB(22,22,22)

    WATERMARK  (always visible, draggable when GUI open)
    ════════════════════════════════════════════════════
    ScreenGui (_wmk_)  DisplayOrder=5  ZIndexBehavior=Sibling
    Enabled=true always  (watermark stays visible even when GUI closed)
    Interactable flag controlled via getEnabled guard on drag

    WmkF1  auto×28  BG RGB(29,29,29)  BorderSizePixel=0
           pos=(10,10)  AnchorPoint(0,0)  AutomaticSize=X
    └── WmkF2  pos=(1,1)  Size=(1,-2,0,26)  AutomaticSize=X
               BG RGB(16,16,16)  Border RGB(75,75,75)  UIListLayout Horiz Center

        Children (all 26px tall):
          AccentBar   4×26   BG=accent  LayoutOrder=1
          Spacer1     6×26              LayoutOrder=2
          ScriptLbl   auto×26  FontSize=13  white  LayoutOrder=3
          Spacer2     4×26              LayoutOrder=4
          Divider     1×14   BG RGB(75,75,75)  LayoutOrder=5
          Spacer3     4×26              LayoutOrder=6
          UserLbl     auto×26  FontSize=11  RGB(160,160,160)  LayoutOrder=7
          Spacer4     4×26              LayoutOrder=8
          Divider2    1×14   BG RGB(75,75,75)  LayoutOrder=9
          Spacer5     4×26              LayoutOrder=10
          FPSLbl      auto×26  FontSize=11  RGB(160,160,160)  LayoutOrder=11
          Spacer6     4×26              LayoutOrder=12
          Divider3    1×14   BG RGB(75,75,75)  LayoutOrder=13
          Spacer7     4×26              LayoutOrder=14
          TimeLbl     auto×26  FontSize=11  RGB(160,160,160)  LayoutOrder=15
          RightEnd    8×26              LayoutOrder=16

    NOTIFICATION  (300×60  bottom-right  DisplayOrder=10)
    ──────────────────────────────────────────────────────
      Wrapper 300×60  ClipsDescendants
      Card   BG RGB(16,16,16)  Border RGB(75,75,75)
        Accent bar  4×60
        Title       x=12  y=8   h=18  FontSize=13
        Message     x=12  y=28  h=24  FontSize=11  Wrapped
        Timer bar   x=0   y=58  h=2   Linear drain

    USAGE
    ─────
      local UI  = loadstring(...)()
      local Win = UI:CreateWindow({
          key    = Enum.KeyCode.RightShift,
          theme  = "blue",
          name   = "MyScript",
          fps    = true,   -- show FPS in watermark
          clock  = true,   -- show clock in watermark
      })
      local Tab  = Win:AddTab("Legit")
      local Sect = Tab:AddSection("Aimbot", "left")
      Sect:AddToggle("Enable", false, function(v) end)
      Sect:AddSlider("FOV", 1, 360, 90, 1, function(v) end)
      Sect:AddSlider("Smoothness", 0, 10, 2, 2, function(v) end)  -- 2 decimals
      Sect:AddDropdown("Bone", {"Head","Neck","Chest"}, "Head", function(v) end)
      UI:Notify("Loaded", "Ready", "success", 3)
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

-- ─────────────────────────────────────────────────────────────
-- Colorways
-- ─────────────────────────────────────────────────────────────
local Colorways = {
    red    = Color3.fromRGB(125,   0,   4),
    blue   = Color3.fromRGB(  0, 100, 200),
    green  = Color3.fromRGB( 30, 140,  60),
    purple = Color3.fromRGB(100,   0, 160),
    orange = Color3.fromRGB(200,  90,   0),
    cyan   = Color3.fromRGB(  0, 160, 180),
    pink   = Color3.fromRGB(200,   0, 120),
    white  = Color3.fromRGB(200, 200, 200),
}

-- ─────────────────────────────────────────────────────────────
-- Theme builder
-- ─────────────────────────────────────────────────────────────
local function BuildTheme(accent)
    return {
        Frame1_BG        = Color3.fromRGB( 29,  29,  29),
        Frame2_BG        = Color3.fromRGB( 16,  16,  16),
        Frame2_Bdr       = Color3.fromRGB( 75,  75,  75),
        TabBar_BG        = Color3.fromRGB( 16,  16,  16),
        TabBar_Bdr       = Color3.fromRGB( 75,  75,  75),
        TabInactive_BG   = Color3.fromRGB( 30,  30,  30),
        TabHover_BG      = Color3.fromRGB( 42,  42,  42),
        TabActive_BG     = accent,
        Content_BG       = Color3.fromRGB( 16,  16,  16),
        Content_Bdr      = Color3.fromRGB( 75,  75,  75),
        Separator        = Color3.fromRGB( 75,  75,  75),
        SectionTitle     = Color3.fromRGB(180, 180, 180),
        Text             = Color3.fromRGB(255, 255, 255),
        SubText          = Color3.fromRGB(160, 160, 160),
        DimText          = Color3.fromRGB(100, 100, 100),
        Checkbox_BG      = Color3.fromRGB( 30,  30,  30),
        Checkbox_Bdr     = Color3.fromRGB( 75,  75,  75),
        Checkbox_On      = accent,
        Dropdown_BG      = Color3.fromRGB( 30,  30,  30),
        Dropdown_List    = Color3.fromRGB( 22,  22,  22),
        Dropdown_Hover   = Color3.fromRGB( 40,  40,  40),
        Dropdown_Sel     = accent,
        Slider_Track     = Color3.fromRGB( 40,  40,  40),
        Slider_Fill      = accent,
        Slider_Thumb     = accent,
        Slider_ValBox    = Color3.fromRGB( 22,  22,  22),
        Accent           = accent,
        Font             = Enum.Font.Code,
        FontSize         = 14,
        HdrSize          = 11,
        Notif = {
            info    = Color3.fromRGB( 75,  75,  75),
            success = Color3.fromRGB( 30, 140,  60),
            warning = Color3.fromRGB(200, 150,   0),
            error   = Color3.fromRGB(125,   0,   4),
        },
    }
end

-- ─────────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────────

-- Clamp a number between min and max
local function Clamp(v, mn, mx)
    return math.max(mn, math.min(mx, v))
end

-- Round to N decimal places
local function Round(v, decimals)
    if not decimals or decimals <= 0 then
        return math.floor(v + 0.5)
    end
    local m = 10 ^ decimals
    return math.floor(v * m + 0.5) / m
end

-- Format number as string with fixed decimals
local function FormatNum(v, decimals)
    if not decimals or decimals <= 0 then
        return tostring(math.floor(v + 0.5))
    end
    return string.format("%." .. decimals .. "f", v)
end

-- Map value from [a,b] to [c,d]
local function Map(v, a, b, c, d)
    if a == b then return c end
    return c + (v - a) / (b - a) * (d - c)
end

-- ─────────────────────────────────────────────────────────────
-- Tween helpers  (colour tweens — zero layout risk)
-- ─────────────────────────────────────────────────────────────
local function TweenQuad(obj, t, props)
    TweenService:Create(
        obj,
        TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function TweenLinear(obj, t, props)
    TweenService:Create(
        obj,
        TweenInfo.new(t, Enum.EasingStyle.Linear),
        props
    ):Play()
end

-- ─────────────────────────────────────────────────────────────
-- Instance factory
-- ─────────────────────────────────────────────────────────────
local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    return o
end

-- ─────────────────────────────────────────────────────────────
-- MakeDraggable
--   handle     — frame the user clicks/touches to start drag
--   target     — frame that actually moves
--   getEnabled — optional fn() → bool  (false = block drag)
-- ─────────────────────────────────────────────────────────────
local function MakeDraggable(handle, target, getEnabled)
    local dragging   = false
    local dragInput  = nil
    local startMouse = nil
    local startPos   = nil

    handle.InputBegan:Connect(function(inp)
        if getEnabled and not getEnabled() then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            startMouse = inp.Position
            startPos   = target.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging or inp ~= dragInput then return end
        if getEnabled and not getEnabled() then dragging = false return end
        local d = inp.Position - startMouse
        target.Position = UDim2.new(
            startPos.X.Scale,  startPos.X.Offset + d.X,
            startPos.Y.Scale,  startPos.Y.Offset + d.Y
        )
    end)
end

-- ─────────────────────────────────────────────────────────────
-- Notification system  (module-level singleton)
-- ─────────────────────────────────────────────────────────────
local NotifGui, NotifContainer

local function EnsureNotifGui()
    if NotifGui and NotifGui.Parent then return end
    local cg = game:GetService("CoreGui")
    do local o = cg:FindFirstChild("_notifs_") if o then o:Destroy() end end

    NotifGui = New("ScreenGui", {
        Name           = "_notifs_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 10,
        ResetOnSpawn   = false,
        Parent         = cg,
    })
    NotifContainer = New("Frame", {
        Name                   = "Container",
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        AnchorPoint            = Vector2.new(1, 1),
        Position               = UDim2.new(1, -10, 1, -10),
        Size                   = UDim2.new(0, 300, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        Parent                 = NotifGui,
    })
    New("UIListLayout", {
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding           = UDim.new(0, 6),
        Parent            = NotifContainer,
    })
end

-- ─────────────────────────────────────────────────────────────
-- UILibrary:Notify(title, message, ntype, duration)
-- ─────────────────────────────────────────────────────────────
--[[
    Card 300×60:
    ┌──────────────────────────────────────────────────────────┐
    │▓▓▓▓│ Title                                               │  y=8  h=18  FontSize=13
    │ 4px│ message text                                        │  y=28 h=24  FontSize=11
    │▓▓▓▓├────────────────────────────────────────────────────┤  y=58 h=2  timer bar
    └──────────────────────────────────────────────────────────┘
    Slide-in:  x=310→0  Quad.Out 0.22s
    Slide-out: x=0→310  Quad.Out 0.16s → Wrapper:Destroy()
    Timer:     Size.X (1→0)  Linear over duration
]]
function UILibrary:Notify(title, message, ntype, duration)
    EnsureNotifGui()
    ntype    = ntype    or "info"
    duration = duration or 3
    title    = tostring(title   or "Notification")
    message  = tostring(message or "")

    local notifColors = {
        info    = Color3.fromRGB( 75,  75,  75),
        success = Color3.fromRGB( 30, 140,  60),
        warning = Color3.fromRGB(200, 150,   0),
        error   = Color3.fromRGB(125,   0,   4),
    }
    local accent = notifColors[ntype] or notifColors.info
    local order  = math.floor(os.clock() * 1000) % 2147483647

    local Wrapper = New("Frame", {
        Name                   = "Notif_" .. order,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 60),
        LayoutOrder            = order,
        ClipsDescendants       = true,
        Parent                 = NotifContainer,
    })

    local Card = New("Frame", {
        Name             = "Card",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        BorderColor3     = Color3.fromRGB(75, 75, 75),
        Position         = UDim2.new(0, 310, 0, 0),
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = Wrapper,
    })

    New("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 0),
        Size             = UDim2.new(0, 4, 1, 0),
        Parent           = Card,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 12, 0, 8),
        Size                   = UDim2.new(1, -20, 0, 18),
        Font                   = Enum.Font.Code,
        Text                   = title,
        TextColor3             = Color3.fromRGB(255, 255, 255),
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Center,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        Parent                 = Card,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 12, 0, 28),
        Size                   = UDim2.new(1, -20, 0, 24),
        Font                   = Enum.Font.Code,
        Text                   = message,
        TextColor3             = Color3.fromRGB(160, 160, 160),
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Top,
        TextWrapped            = true,
        Parent                 = Card,
    })

    local TimerBar = New("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 58),
        Size             = UDim2.new(1, 0, 0, 2),
        Parent           = Card,
    })

    TweenQuad(Card, 0.22, { Position = UDim2.new(0, 0, 0, 0) })
    TweenLinear(TimerBar, duration, { Size = UDim2.new(0, 0, 0, 2) })

    task.delay(duration, function()
        if not Card or not Card.Parent then return end
        local t = TweenService:Create(
            Card,
            TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 310, 0, 0) }
        )
        t:Play()
        t.Completed:Connect(function()
            if Wrapper and Wrapper.Parent then Wrapper:Destroy() end
        end)
    end)
end

-- ─────────────────────────────────────────────────────────────
-- CreateWindow
-- ─────────────────────────────────────────────────────────────
function UILibrary:CreateWindow(cfg)
    cfg = cfg or {}
    local toggleKey   = cfg.key    or Enum.KeyCode.RightShift
    local accentColor = Colorways[cfg.theme] or Colorways.red
    local scriptName  = tostring(cfg.name   or "Script")
    local showFPS     = cfg.fps   ~= false   -- default true
    local showClock   = cfg.clock ~= false   -- default true
    local T           = BuildTheme(accentColor)

    local CoreGui = game:GetService("CoreGui")
    do local o = CoreGui:FindFirstChild("_index_") if o then o:Destroy() end end
    do local o = CoreGui:FindFirstChild("_wmk_")   if o then o:Destroy() end end

    -- ── ScreenGui ──────────────────────────────────────────────
    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 1,
        ResetOnSpawn   = false,
        Parent         = CoreGui,
    })

    -- ── _frame1: 630×390  no border  centered ─────────────────
    local Frame1 = New("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = T.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 630, 0, 390),
        Parent           = Gui,
    })

    -- ── _frame2: 620×380  pos=(5,5)  1px border ───────────────
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = T.Frame2_BG,
        BorderColor3     = T.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- ── __tabs: 608×45  pos=(6,8)  1px border ─────────────────
    --    outer bottom = 8+45 = 53px
    local TabBar = New("Frame", {
        Name             = "__tabs",
        BackgroundColor3 = T.TabBar_BG,
        BorderColor3     = T.TabBar_Bdr,
        Position         = UDim2.new(0, 6, 0, 8),
        Size             = UDim2.new(0, 608, 0, 45),
        Parent           = Frame2,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, 1),
        Parent        = TabBar,
    })

    -- ── __tabContent: 608×314  pos=(6,59) ─────────────────────
    --    top gap from tab bar: 59-53=6px ✓
    --    bottom: 59+314=373  frame2 inner bottom=378  gap=5px ✓
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = T.Content_BG,
        BorderColor3     = T.Content_Bdr,
        Position         = UDim2.new(0, 6, 0, 59),
        Size             = UDim2.new(0, 608, 0, 314),
        ClipsDescendants = true,
        Parent           = Frame2,
    })

    -- ── Dragging: Frame1 outer shell + TabBar only ─────────────
    -- Frame2 is intentionally excluded — it sits behind the entire
    -- content area, so registering it as a drag handle would eat
    -- all mouse-down events on sliders, dropdowns, and toggles.
    MakeDraggable(Frame1, Frame1)
    MakeDraggable(TabBar, Frame1)

    -- ─────────────────────────────────────────────────────────
    -- Watermark  (always visible, non-interactive when GUI closed)
    -- ─────────────────────────────────────────────────────────
    --[[
        The watermark ScreenGui stays Enabled=true at all times so it
        remains visible.  When the main GUI is hidden, the drag guard
        (wmkEnabled) returns false, preventing any position changes.
        This satisfies "visible at all times, non-interactive when closed".

        FPS and Clock are optional sections.
        Layout is purely UIListLayout Horizontal — zero absolute positions.
    ]]
    local WmkGui = New("ScreenGui", {
        Name           = "_wmk_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 5,
        ResetOnSpawn   = false,
        Enabled        = true,   -- ALWAYS visible
        Parent         = CoreGui,
    })

    local WmkF1 = New("Frame", {
        Name             = "WmkF1",
        BackgroundColor3 = T.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0, 0),
        Position         = UDim2.new(0, 10, 0, 10),
        Size             = UDim2.new(0, 0, 0, 28),
        AutomaticSize    = Enum.AutomaticSize.X,
        Parent           = WmkGui,
    })

    -- WmkF2: pos=(1,1) → 1px gap on all sides acts as border
    local WmkF2 = New("Frame", {
        Name             = "WmkF2",
        BackgroundColor3 = T.Frame2_BG,
        BorderColor3     = T.Frame2_Bdr,
        Position         = UDim2.new(0, 1, 0, 1),
        Size             = UDim2.new(1, -2, 0, 26),
        AutomaticSize    = Enum.AutomaticSize.X,
        Parent           = WmkF1,
    })

    New("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 0),
        Parent            = WmkF2,
    })

    -- Watermark spacer helper
    local wmkOrder = 0
    local function WmkSpacer(w)
        wmkOrder += 1
        New("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, w, 0, 26),
            LayoutOrder            = wmkOrder,
            Parent                 = WmkF2,
        })
    end

    local function WmkDivider()
        wmkOrder += 1
        WmkSpacer(4)
        wmkOrder += 1
        New("Frame", {
            Name             = "Div_" .. wmkOrder,
            BackgroundColor3 = T.Separator,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 1, 0, 14),
            LayoutOrder      = wmkOrder,
            Parent           = WmkF2,
        })
        WmkSpacer(4)
    end

    -- AccentBar: 4×26
    wmkOrder += 1
    New("Frame", {
        Name             = "AccentBar",
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 4, 0, 26),
        LayoutOrder      = wmkOrder,
        Parent           = WmkF2,
    })

    WmkSpacer(6)  -- gap: accent → name

    -- Script name label
    wmkOrder += 1
    New("TextLabel", {
        Name                   = "ScriptName",
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(0, 0, 0, 26),
        AutomaticSize          = Enum.AutomaticSize.X,
        Font                   = T.Font,
        Text                   = scriptName,
        TextColor3             = T.Text,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Center,
        LayoutOrder            = wmkOrder,
        Parent                 = WmkF2,
    })

    -- Divider → username
    WmkDivider()

    local localName = (Players.LocalPlayer and Players.LocalPlayer.Name) or "Player"
    wmkOrder += 1
    New("TextLabel", {
        Name                   = "UserName",
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(0, 0, 0, 26),
        AutomaticSize          = Enum.AutomaticSize.X,
        Font                   = T.Font,
        Text                   = localName,
        TextColor3             = T.SubText,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Center,
        LayoutOrder            = wmkOrder,
        Parent                 = WmkF2,
    })

    -- Optional FPS section
    local FpsLabel = nil
    if showFPS then
        WmkDivider()
        wmkOrder += 1
        FpsLabel = New("TextLabel", {
            Name                   = "FPS",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, 0, 0, 26),
            AutomaticSize          = Enum.AutomaticSize.X,
            Font                   = T.Font,
            Text                   = "FPS: --",
            TextColor3             = T.SubText,
            TextSize               = 11,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextYAlignment         = Enum.TextYAlignment.Center,
            LayoutOrder            = wmkOrder,
            Parent                 = WmkF2,
        })
    end

    -- Optional Clock section
    local ClockLabel = nil
    if showClock then
        WmkDivider()
        wmkOrder += 1
        ClockLabel = New("TextLabel", {
            Name                   = "Clock",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, 0, 0, 26),
            AutomaticSize          = Enum.AutomaticSize.X,
            Font                   = T.Font,
            Text                   = "00:00",
            TextColor3             = T.SubText,
            TextSize               = 11,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextYAlignment         = Enum.TextYAlignment.Center,
            LayoutOrder            = wmkOrder,
            Parent                 = WmkF2,
        })
    end

    -- Right breathing room
    WmkSpacer(8)

    -- FPS update loop
    if FpsLabel then
        local fpsFrames = 0
        local fpsTimer  = 0
        local lastFPS   = 0
        RunService.RenderStepped:Connect(function(dt)
            fpsFrames += 1
            fpsTimer  += dt
            if fpsTimer >= 0.5 then
                lastFPS   = math.floor(fpsFrames / fpsTimer + 0.5)
                fpsFrames = 0
                fpsTimer  = 0
                -- Colour-code: green=60+  yellow=30-59  red<30
                local col
                if lastFPS >= 60 then
                    col = Color3.fromRGB(30, 160, 60)
                elseif lastFPS >= 30 then
                    col = Color3.fromRGB(200, 150, 0)
                else
                    col = Color3.fromRGB(180, 40, 40)
                end
                FpsLabel.Text       = "FPS: " .. lastFPS
                FpsLabel.TextColor3 = col
            end
        end)
    end

    -- Clock update loop
    if ClockLabel then
        RunService.Heartbeat:Connect(function()
            local t = os.date("*t")
            ClockLabel.Text = string.format("%02d:%02d", t.hour, t.min)
        end)
    end

    -- Drag guard: watermark is always visible but only draggable when GUI is open
    local function wmkEnabled() return Frame1.Visible end
    MakeDraggable(WmkF1, WmkF1, wmkEnabled)
    MakeDraggable(WmkF2, WmkF1, wmkEnabled)

    -- ── Toggle key: hides/shows main GUI only, watermark stays ─
    UserInputService.InputBegan:Connect(function(inp, processed)
        if not processed and inp.KeyCode == toggleKey then
            Frame1.Visible = not Frame1.Visible
            -- WmkGui intentionally NOT toggled — always visible
        end
    end)

    -- ─────────────────────────────────────────────────────────
    -- Window object
    -- ─────────────────────────────────────────────────────────
    local Window = {
        _gui         = Gui,
        _wmkGui      = WmkGui,
        _frame       = Frame1,
        _tabBar      = TabBar,
        _contentArea = ContentArea,
        _tabs        = {},
        _activeTab   = nil,
        _theme       = T,
    }

    -- Public helpers
    function Window:SetVisible(v)
        self._frame.Visible = v
        -- Watermark stays visible regardless
    end

    function Window:IsVisible()
        return self._frame.Visible
    end

    function Window:Toggle()
        self:SetVisible(not self:IsVisible())
    end

    function Window:Destroy()
        self._gui:Destroy()
        self._wmkGui:Destroy()
    end

    -- ─────────────────────────────────────────────────────────
    -- AddTab
    -- ─────────────────────────────────────────────────────────
    function Window:AddTab(name)
        local index = #self._tabs + 1

        -- Button: 151×45  BorderSizePixel=0
        -- 4×151 + 3×1 = 607px fits 608px ✓
        local Btn = New("TextButton", {
            Name             = "Tab_" .. name,
            Font             = T.Font,
            Text             = name,
            TextColor3       = T.Text,
            TextSize         = T.FontSize,
            TextXAlignment   = Enum.TextXAlignment.Center,
            TextYAlignment   = Enum.TextYAlignment.Center,
            TextWrapped      = false,
            BackgroundColor3 = T.TabInactive_BG,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 151, 0, 45),
            LayoutOrder      = index,
            AutoButtonColor  = false,
            Parent           = self._tabBar,
        })

        -- Active indicator: 2px at bottom of button  BG=accent
        local ActiveBar = New("Frame", {
            Name             = "ActiveBar",
            BackgroundColor3 = T.Accent,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 0, 1, -2),
            Size             = UDim2.new(1, 0, 0, 2),
            Visible          = false,
            ZIndex           = 2,
            Parent           = Btn,
        })

        -- ScrollingFrame per tab  fills ContentArea 608×314
        -- UIPadding 8px → usable 590×296   ScrollBar 2px  Y-only
        local Page = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            ScrollBarThickness     = 2,
            ScrollBarImageColor3   = T.Accent,
            ScrollingDirection     = Enum.ScrollingDirection.Y,
            Visible                = false,
            Parent                 = self._contentArea,
        })
        New("UIPadding", {
            PaddingTop    = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 8),
            Parent        = Page,
        })

        -- ColumnHolder: 590px wide  AutomaticSize=Y
        local Holder = New("Frame", {
            Name                   = "ColumnHolder",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = Page,
        })

        -- LeftCol: 291×auto  x=0
        local LeftCol = New("Frame", {
            Name                   = "LeftCol",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0, 0, 0, 0),
            Size                   = UDim2.new(0, 291, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = Holder,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 10),
            Parent    = LeftCol,
        })

        -- RightCol: 291×auto  x=299  (right edge = 299+291 = 590 ✓)
        local RightCol = New("Frame", {
            Name                   = "RightCol",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0, 299, 0, 0),
            Size                   = UDim2.new(0, 291, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = Holder,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 10),
            Parent    = RightCol,
        })

        local Tab = {
            _btn      = Btn,
            _bar      = ActiveBar,
            _page     = Page,
            _leftCol  = LeftCol,
            _rightCol = RightCol,
            _window   = self,
        }

        function Tab:Select()
            for _, t in ipairs(self._window._tabs) do
                t._page.Visible = false
                t._bar.Visible  = false
                TweenQuad(t._btn, 0.10, { BackgroundColor3 = T.TabInactive_BG })
            end
            self._page.Visible = true
            self._bar.Visible  = true
            TweenQuad(self._btn, 0.10, { BackgroundColor3 = T.TabActive_BG })
            self._window._activeTab = self
        end

        Btn.MouseButton1Click:Connect(function() Tab:Select() end)

        Btn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                TweenQuad(Btn, 0.08, { BackgroundColor3 = T.TabHover_BG })
            end
        end)
        Btn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                TweenQuad(Btn, 0.08, { BackgroundColor3 = T.TabInactive_BG })
            end
        end)

        table.insert(self._tabs, Tab)
        if #self._tabs == 1 then Tab:Select() end

        -- ─────────────────────────────────────────────────────
        -- AddSection
        -- ─────────────────────────────────────────────────────
        function Tab:AddSection(sectionName, side)
            side = (side == "right") and "right" or "left"
            local Col = (side == "right") and self._rightCol or self._leftCol

            local order = 0
            for _, c in ipairs(Col:GetChildren()) do
                if c:IsA("Frame") then order += 1 end
            end

            -- SectionFrame: 291×auto
            local SectionFrame = New("Frame", {
                Name                   = "Sec_" .. sectionName,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                LayoutOrder            = order,
                Parent                 = Col,
            })

            -- Header: 291×20
            local Header = New("Frame", {
                Name                   = "Header",
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 20),
                Parent                 = SectionFrame,
            })
            New("TextLabel", {
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 1, 0),
                Font                   = T.Font,
                Text                   = string.upper(sectionName),
                TextColor3             = T.SectionTitle,
                TextSize               = T.HdrSize,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextYAlignment         = Enum.TextYAlignment.Center,
                Parent                 = Header,
            })
            -- Separator: 1px at y=19 (last pixel of 20px header)
            New("Frame", {
                Name             = "Sep",
                BackgroundColor3 = T.Separator,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 0, 0, 19),
                Size             = UDim2.new(1, 0, 0, 1),
                Parent           = Header,
            })

            -- Body: pos y=21  PaddingTop=5  element gap=4px
            local Body = New("Frame", {
                Name                   = "Body",
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0, 0, 0, 21),
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                Parent                 = SectionFrame,
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 4),
                Parent    = Body,
            })
            New("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                Parent     = Body,
            })

            local elementCount = 0
            local Section      = { _body = Body }

            -- ─────────────────────────────────────────────────
            -- AddToggle
            -- ─────────────────────────────────────────────────
            --[[
                Row  291×26  BG transparent
                Box  14×14   pos x=4   y=(26-14)/2=6  ✓  centred vertically
                             Border RGB(75,75,75)
                             BG ↔ accent  Quad.Out 0.10s
                Lbl  pos x=24  Size(1,-24,1,0)  Left/Center  Font=Code 14
            ]]
            function Section:AddToggle(label, default, callback)
                default  = (default == true)
                callback = callback or function() end
                local state = default
                elementCount += 1

                local Row = New("Frame", {
                    Name                   = "Toggle_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 26),
                    LayoutOrder            = elementCount,
                    Parent                 = Body,
                })

                local Box = New("TextButton", {
                    Name             = "Box",
                    BackgroundColor3 = state and T.Checkbox_On or T.Checkbox_BG,
                    BorderColor3     = T.Checkbox_Bdr,
                    Position         = UDim2.new(0, 4, 0, 6),
                    Size             = UDim2.new(0, 14, 0, 14),
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = Row,
                })

                New("TextLabel", {
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 24, 0, 0),
                    Size                   = UDim2.new(1, -24, 1, 0),
                    Font                   = T.Font,
                    Text                   = label,
                    TextColor3             = T.Text,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    Parent                 = Row,
                })

                local function Apply(val, silent)
                    state = val
                    TweenQuad(Box, 0.10, {
                        BackgroundColor3 = state and T.Checkbox_On or T.Checkbox_BG
                    })
                    if not silent then callback(state) end
                end

                Box.MouseButton1Click:Connect(function() Apply(not state, false) end)

                return {
                    Set    = function(_, v)  Apply(v, true)  end,
                    Get    = function(_)     return state    end,
                    Toggle = function(_)     Apply(not state, false) end,
                }
            end

            -- ─────────────────────────────────────────────────
            -- AddSlider
            -- ─────────────────────────────────────────────────
            --[[
                Row  291×38  BG transparent

                TopRow  291×18  pos y=0
                  Lbl     pos x=0   Size(1,-44,0,18)  Left/Center  Font=Code 14
                  ValBox  pos x=(1,-42)  Size(0,42,0,18)
                          BG RGB(22,22,22)  Border RGB(75,75,75)
                          Font=Code 11  Center  (shows formatted value)

                TrackBG  291×6  pos y=26  BG RGB(40,40,40)  BorderSizePixel=0
                  Fill   pos=(0,0,0,0)  Size=(frac,0,1,0)  BG=accent
                  Thumb  Size=(0,8,0,16)  pos=(fill_end - 4, -5)
                         BG=accent  BorderSizePixel=0  draggable

                Interaction: mouse down on TrackBG or Thumb → drag
                  frac = clamp((mx - track.AbsolutePosition.X) / track.AbsoluteSize.X)
                  value = Round(Map(frac, 0, 1, min, max), decimals)

                decimals: 0 → integer display  >0 → "%.Nf" format

                ValBox is also focusable: MouseButton1Click → TextBox overlay
                  for manual numeric entry.
            ]]
            function Section:AddSlider(label, min, max, default, decimals, callback)
                min      = tonumber(min)      or 0
                max      = tonumber(max)      or 100
                default  = tonumber(default)  or min
                decimals = tonumber(decimals) or 0
                callback = callback           or function() end

                default = Clamp(default, min, max)
                local value = Round(default, decimals)

                elementCount += 1

                -- Row: 291×38
                local Row = New("Frame", {
                    Name                   = "Slider_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 38),
                    LayoutOrder            = elementCount,
                    Parent                 = Body,
                })

                -- Top row: label + value box  ──────────────────
                -- Lbl: left edge to (right - 44px)   h=18
                New("TextLabel", {
                    Name                   = "Lbl",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 0, 0, 0),
                    Size                   = UDim2.new(1, -44, 0, 18),
                    Font                   = T.Font,
                    Text                   = label,
                    TextColor3             = T.Text,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    Parent                 = Row,
                })

                -- ValBox: rightmost 42×18  BG=dark  Border
                local ValBox = New("Frame", {
                    Name             = "ValBox",
                    BackgroundColor3 = T.Slider_ValBox,
                    BorderColor3     = T.Separator,
                    Position         = UDim2.new(1, -42, 0, 0),
                    Size             = UDim2.new(0, 42, 0, 18),
                    Parent           = Row,
                })

                local ValLbl = New("TextButton", {
                    Name                   = "ValLbl",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 1, 0),
                    Font                   = T.Font,
                    Text                   = FormatNum(value, decimals),
                    TextColor3             = T.SubText,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = ValBox,
                })

                -- Track background: 291×6  pos y=26
                local TrackBG = New("Frame", {
                    Name             = "TrackBG",
                    BackgroundColor3 = T.Slider_Track,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 26),
                    Size             = UDim2.new(1, 0, 0, 6),
                    Parent           = Row,
                })

                -- Fill: lives inside TrackBG
                local Fill = New("Frame", {
                    Name             = "Fill",
                    BackgroundColor3 = T.Slider_Fill,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 0),
                    Size             = UDim2.new(0, 0, 1, 0),
                    Parent           = TrackBG,
                })

                -- Thumb: 8×16  centered vertically on track  BG=accent
                -- pos y = (6-16)/2 = -5  (extends 5px above and below 6px track)
                local Thumb = New("Frame", {
                    Name             = "Thumb",
                    BackgroundColor3 = T.Slider_Thumb,
                    BorderSizePixel  = 0,
                    Size             = UDim2.new(0, 8, 0, 16),
                    Position         = UDim2.new(0, 0, 0, -5),
                    ZIndex           = 3,
                    Parent           = TrackBG,
                })

                -- ── Internal update function ───────────────────
                local function SetValue(v, silent)
                    value = Round(Clamp(v, min, max), decimals)
                    local frac = Map(value, min, max, 0, 1)

                    -- Size update (no tween — direct for responsiveness)
                    Fill.Size = UDim2.new(frac, 0, 1, 0)

                    -- Thumb x = fill_right - thumbHalf = frac*trackW - 4
                    -- Using Scale-based position on Thumb within TrackBG
                    Thumb.Position = UDim2.new(frac, -4, 0, -5)

                    ValLbl.Text = FormatNum(value, decimals)

                    if not silent then callback(value) end
                end

                -- Set initial position
                SetValue(value, true)

                -- ── Drag interaction ───────────────────────────
                local sliding  = false
                local function HandleInput(inp)
                    if sliding then
                        local absX  = TrackBG.AbsolutePosition.X
                        local absW  = TrackBG.AbsoluteSize.X
                        local frac  = Clamp((inp.Position.X - absX) / absW, 0, 1)
                        local v     = Map(frac, 0, 1, min, max)
                        SetValue(v, false)
                    end
                end

                TrackBG.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        HandleInput(inp)
                    end
                end)

                Thumb.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                    end
                end)

                UserInputService.InputChanged:Connect(function(inp)
                    if not sliding then return end
                    if inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        HandleInput(inp)
                    end
                end)

                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                -- ValBox click: manual text entry overlay
                ValLbl.MouseButton1Click:Connect(function()
                    -- Create a temporary TextBox over the ValBox
                    local TB = New("TextBox", {
                        Name                   = "_SliderInput",
                        BackgroundColor3       = T.Slider_ValBox,
                        BorderColor3           = T.Accent,
                        Size                   = UDim2.new(1, 0, 1, 0),
                        Font                   = T.Font,
                        Text                   = FormatNum(value, decimals),
                        TextColor3             = T.Text,
                        TextSize               = 11,
                        TextXAlignment         = Enum.TextXAlignment.Center,
                        ClearTextOnFocus       = true,
                        Parent                 = ValBox,
                    })
                    TB:CaptureFocus()
                    TB.FocusLost:Connect(function(enter)
                        local n = tonumber(TB.Text)
                        if n then SetValue(n, false) end
                        TB:Destroy()
                    end)
                end)

                return {
                    Set = function(_, v)  SetValue(v, true)   end,
                    Get = function(_)     return value        end,
                }
            end

            -- ─────────────────────────────────────────────────
            -- AddDropdown
            -- ─────────────────────────────────────────────────
            --[[
                Fixed-height Row  291×CLOSED_H or 291×OPEN_H
                ClipsDescendants=true hides list when closed.
                CLOSED_H = 26    OPEN_H = 27 + n×22

                DHeader  291×26  BG RGB(30,30,30)  Border RGB(75,75,75) 1px
                  SelLabel  x=6  Size(1,-26,1,0)  Left/Center  TextTruncate
                  Arrow     x=(1,-20)  Size(0,20,1,0)  "▾"/"▴"  FontSize=12

                List  pos y=27  Size(1,0,0,n×22)  BG RGB(22,22,22)  Border 1px
                  Item[i]  pos=(0,(i-1)×22)  Size(1,0,0,22)  BG RGB(22,22,22)
                    hover: Quad.Out 0.08s
                    ItemBtn  full size  Left/Center  PaddingLeft=6
                             TextColor3: white or accent
            ]]
            function Section:AddDropdown(label, options, default, callback)
                options  = options  or {}
                callback = callback or function() end
                local selected = default or options[1] or ""
                local isOpen   = false
                elementCount  += 1

                local CLOSED_H = 26
                local LIST_H   = #options * 22
                local OPEN_H   = CLOSED_H + 1 + LIST_H

                local Row = New("Frame", {
                    Name                   = "DD_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, CLOSED_H),
                    LayoutOrder            = elementCount,
                    ClipsDescendants       = true,
                    Parent                 = Body,
                })

                local DHeader = New("Frame", {
                    Name             = "DHeader",
                    BackgroundColor3 = T.Dropdown_BG,
                    BorderColor3     = T.Separator,
                    Size             = UDim2.new(1, 0, 0, 26),
                    Parent           = Row,
                })

                -- SelLabel: x=6  Size(1,-26,1,0)  leaves 20px for arrow
                local SelLabel = New("TextLabel", {
                    Name                   = "SelLabel",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 6, 0, 0),
                    Size                   = UDim2.new(1, -26, 1, 0),
                    Font                   = T.Font,
                    Text                   = selected,
                    TextColor3             = T.Text,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    TextTruncate           = Enum.TextTruncate.AtEnd,
                    Parent                 = DHeader,
                })

                -- Arrow: rightmost 20px of DHeader
                local Arrow = New("TextButton", {
                    Name                   = "Arrow",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(1, -20, 0, 0),
                    Size                   = UDim2.new(0, 20, 1, 0),
                    Font                   = T.Font,
                    Text                   = "▾",
                    TextColor3             = T.SubText,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = DHeader,
                })

                -- List: y=27  n×22 tall
                local List = New("Frame", {
                    Name             = "List",
                    BackgroundColor3 = T.Dropdown_List,
                    BorderColor3     = T.Separator,
                    Position         = UDim2.new(0, 0, 0, 27),
                    Size             = UDim2.new(1, 0, 0, LIST_H),
                    Visible          = false,
                    Parent           = Row,
                })

                -- Build items
                local itemRefs = {}
                for i, opt in ipairs(options) do
                    local Item = New("Frame", {
                        Name             = "Item_" .. i,
                        BackgroundColor3 = T.Dropdown_List,
                        BorderSizePixel  = 0,
                        Position         = UDim2.new(0, 0, 0, (i - 1) * 22),
                        Size             = UDim2.new(1, 0, 0, 22),
                        Parent           = List,
                    })

                    local ItemBtn = New("TextButton", {
                        BackgroundTransparency = 1,
                        BorderSizePixel        = 0,
                        Size                   = UDim2.new(1, 0, 1, 0),
                        Font                   = T.Font,
                        Text                   = opt,
                        TextColor3             = (opt == selected) and T.Dropdown_Sel or T.Text,
                        TextSize               = T.FontSize,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        TextYAlignment         = Enum.TextYAlignment.Center,
                        AutoButtonColor        = false,
                        Parent                 = Item,
                    })
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0, 6),
                        Parent      = ItemBtn,
                    })

                    itemRefs[opt] = ItemBtn

                    Item.MouseEnter:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_Hover })
                    end)
                    Item.MouseLeave:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_List })
                    end)

                    ItemBtn.MouseButton1Click:Connect(function()
                        if itemRefs[selected] then
                            itemRefs[selected].TextColor3 = T.Text
                        end
                        selected           = opt
                        SelLabel.Text      = selected
                        ItemBtn.TextColor3 = T.Dropdown_Sel
                        isOpen       = false
                        Arrow.Text   = "▾"
                        List.Visible = false
                        Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
                        callback(selected)
                    end)
                end

                local function Toggle()
                    isOpen     = not isOpen
                    Arrow.Text = isOpen and "▴" or "▾"
                    if isOpen then
                        List.Visible = true
                        Row.Size     = UDim2.new(1, 0, 0, OPEN_H)
                    else
                        List.Visible = false
                        Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
                    end
                end

                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggle()
                    end
                end)
                Arrow.MouseButton1Click:Connect(Toggle)

                return {
                    Set = function(_, v)
                        if itemRefs[selected] then itemRefs[selected].TextColor3 = T.Text end
                        selected      = v
                        SelLabel.Text = v
                        if itemRefs[v] then itemRefs[v].TextColor3 = T.Dropdown_Sel end
                        if isOpen then
                            isOpen       = false
                            Arrow.Text   = "▾"
                            List.Visible = false
                            Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
                        end
                        callback(selected)
                    end,
                    Get = function(_) return selected end,
                }
            end

            -- ─────────────────────────────────────────────────
            -- AddLabel  (static info text — 291×20)
            -- ─────────────────────────────────────────────────
            function Section:AddLabel(text)
                elementCount += 1
                local Lbl = New("TextLabel", {
                    Name                   = "Label_" .. elementCount,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 20),
                    Font                   = T.Font,
                    Text                   = text,
                    TextColor3             = T.DimText,
                    TextSize               = T.HdrSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    LayoutOrder            = elementCount,
                    Parent                 = Body,
                })
                return {
                    Set = function(_, v) Lbl.Text = tostring(v) end,
                    Get = function(_)    return Lbl.Text         end,
                }
            end

            -- ─────────────────────────────────────────────────
            -- AddSeparator  (thin visual divider — 291×1 + 4px margins)
            -- ─────────────────────────────────────────────────
            function Section:AddSeparator()
                elementCount += 1
                local Wrap = New("Frame", {
                    Name                   = "Sep_" .. elementCount,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 9),
                    LayoutOrder            = elementCount,
                    Parent                 = Body,
                })
                New("Frame", {
                    BackgroundColor3 = T.Separator,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 4),
                    Size             = UDim2.new(1, 0, 0, 1),
                    Parent           = Wrap,
                })
            end

            -- ─────────────────────────────────────────────────
            -- AddTextInput
            -- ─────────────────────────────────────────────────
            --[[
                Row  291×44  BG transparent  LayoutOrder=N

                ┌─ LabelRow ──────────────────────── 291×18  y=0 ──┐
                │  Lbl  Size(1,0,0,18)  Left/Center  Font=Code 14  │
                └──────────────────────────────────────────────────┘
                ┌─ Field ─────────────────────────── 291×22  y=22 ─┐
                │  BG RGB(22,22,22)  Border RGB(75,75,75) 1px      │
                │  inner: 289×20  PaddingLeft/Right=6  → 277px text│
                │  TextBox: placeholder RGB(75,75,75)               │
                │           active text  RGB(255,255,255)           │
                │           cursor accent colour                    │
                │           FontSize=13  Left/Center                │
                └──────────────────────────────────────────────────┘

                Total height = 18 (label) + 4 (gap) + 22 (field) = 44px

                Callback fires on FocusLost(enterPressed) and on each
                changed character if cfg.live == true.

                API:
                  obj.Set(_, text)   → set value programmatically
                  obj.Get(_)         → return current text
                  obj.Clear(_)       → clear to ""
                  obj.Focus(_)       → capture focus on TextBox
            ]]
            function Section:AddTextInput(label, placeholder, callback, cfg)
                cfg         = cfg         or {}
                placeholder = placeholder or ""
                callback    = callback    or function() end
                local live  = cfg.live    == true   -- fire on every keystroke
                local maxLen = tonumber(cfg.maxLength) or 0  -- 0 = unlimited
                elementCount += 1

                -- Row: 291×44
                local Row = New("Frame", {
                    Name                   = "TextInput_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 44),
                    LayoutOrder            = elementCount,
                    Parent                 = Body,
                })

                -- Label: full width × 18px  top-aligned
                New("TextLabel", {
                    Name                   = "Lbl",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 0, 0, 0),
                    Size                   = UDim2.new(1, 0, 0, 18),
                    Font                   = T.Font,
                    Text                   = label,
                    TextColor3             = T.Text,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    Parent                 = Row,
                })

                -- Field background: 291×22  pos y=22
                local Field = New("Frame", {
                    Name             = "Field",
                    BackgroundColor3 = T.Slider_ValBox,   -- RGB(22,22,22)
                    BorderColor3     = T.Separator,        -- RGB(75,75,75)
                    Position         = UDim2.new(0, 0, 0, 22),
                    Size             = UDim2.new(1, 0, 0, 22),
                    Parent           = Row,
                })

                -- TextBox: fills Field inner (1px border → -2 each axis)
                -- UIPadding adds 6px left/right breathing room
                local TB = New("TextBox", {
                    Name                   = "TB",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 0, 0, 0),
                    Size                   = UDim2.new(1, 0, 1, 0),
                    Font                   = T.Font,
                    PlaceholderText        = placeholder,
                    PlaceholderColor3      = T.DimText,
                    Text                   = "",
                    TextColor3             = T.Text,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    ClearTextOnFocus       = false,
                    ClipsDescendants       = true,
                    Parent                 = Field,
                })
                -- 6px padding left/right, 0 top/bottom (TextYAlignment handles it)
                New("UIPadding", {
                    PaddingLeft  = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    Parent       = TB,
                })

                -- Max length enforcement
                if maxLen > 0 then
                    TB:GetPropertyChangedSignal("Text"):Connect(function()
                        if #TB.Text > maxLen then
                            TB.Text = string.sub(TB.Text, 1, maxLen)
                        end
                    end)
                end

                -- Border highlight: accent on focus, separator on blur
                TB.Focused:Connect(function()
                    Field.BorderColor3 = T.Accent
                end)
                TB.FocusLost:Connect(function(enter)
                    Field.BorderColor3 = T.Separator
                    callback(TB.Text, enter)
                end)

                -- Live mode: fire on every character change
                if live then
                    TB:GetPropertyChangedSignal("Text"):Connect(function()
                        callback(TB.Text, false)
                    end)
                end

                return {
                    Set   = function(_, v)  TB.Text = tostring(v or "") end,
                    Get   = function(_)     return TB.Text              end,
                    Clear = function(_)     TB.Text = ""                end,
                    Focus = function(_)     TB:CaptureFocus()           end,
                }
            end

            -- ─────────────────────────────────────────────────
            -- AddMultiDropdown
            -- ─────────────────────────────────────────────────
            --[[
                Identical shell to AddDropdown but each item has a
                checkbox and multiple items can be active simultaneously.

                Row  291×CLOSED_H(26) or 291×OPEN_H(27+n×22)
                     ClipsDescendants=true  fixed Size.Y

                DHeader  291×26  BG RGB(30,30,30)  Border RGB(75,75,75) 1px
                  SelLabel  x=6  Size(1,-26,1,0)  Left/Center
                            shows: comma-joined selected, or placeholder,
                            truncated with TextTruncate.AtEnd
                  Arrow     x=(1,-20)  Size(0,20,1,0)  "▾"/"▴"  FontSize=12

                List  pos y=27  Size(1,0,0,n×22)  BG RGB(22,22,22)  Border 1px
                  Item[i]  pos=(0,(i-1)×22)  Size(1,0,0,22)
                    Checkbox  12×12  x=6   y=(22-12)/2=5  centred ✓
                              Border RGB(75,75,75)
                              BG: accent if selected, RGB(30,30,30) if not
                              Quad.Out 0.10s
                    ItemLbl   pos x=24  Size(1,-30,1,0)  Left/Center
                              TextColor3: accent if selected, white if not
                    hover: Quad.Out 0.08s Item BG

                  "Select All" / "Clear" footer strip  22px
                    Two equal TextButtons split across the row

                Callback: fires with table of selected option strings

                API:
                  obj.Set(_, tbl)   → set selection to array of strings
                  obj.Get(_)        → return array of selected strings
                  obj.Clear(_)      → deselect all
                  obj.SelectAll(_)  → select all
            ]]
            function Section:AddMultiDropdown(label, options, defaults, callback)
                options   = options   or {}
                defaults  = defaults  or {}
                callback  = callback  or function() end
                local placeholder = label  -- header shows label name when nothing selected
                elementCount += 1

                -- Build initial selection set from defaults array
                local selected = {}
                for _, v in ipairs(defaults) do selected[v] = true end

                local isOpen   = false
                local CLOSED_H = 26
                local ITEM_H   = 22
                local FOOTER_H = 22
                local LIST_H   = #options * ITEM_H + FOOTER_H
                local OPEN_H   = CLOSED_H + 1 + LIST_H

                -- Row
                local Row = New("Frame", {
                    Name                   = "MDD_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, CLOSED_H),
                    LayoutOrder            = elementCount,
                    ClipsDescendants       = true,
                    Parent                 = Body,
                })

                -- DHeader
                local DHeader = New("Frame", {
                    Name             = "DHeader",
                    BackgroundColor3 = T.Dropdown_BG,
                    BorderColor3     = T.Separator,
                    Size             = UDim2.new(1, 0, 0, 26),
                    Parent           = Row,
                })

                local SelLabel = New("TextLabel", {
                    Name                   = "SelLabel",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 6, 0, 0),
                    Size                   = UDim2.new(1, -26, 1, 0),
                    Font                   = T.Font,
                    Text                   = placeholder,
                    TextColor3             = T.DimText,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    TextTruncate           = Enum.TextTruncate.AtEnd,
                    Parent                 = DHeader,
                })

                local Arrow = New("TextButton", {
                    Name                   = "Arrow",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(1, -20, 0, 0),
                    Size                   = UDim2.new(0, 20, 1, 0),
                    Font                   = T.Font,
                    Text                   = "▾",
                    TextColor3             = T.SubText,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = DHeader,
                })

                -- List
                local List = New("Frame", {
                    Name             = "List",
                    BackgroundColor3 = T.Dropdown_List,
                    BorderColor3     = T.Separator,
                    Position         = UDim2.new(0, 0, 0, 27),
                    Size             = UDim2.new(1, 0, 0, LIST_H),
                    Visible          = false,
                    Parent           = Row,
                })

                -- ── Helper: rebuild header text ────────────────
                local function RefreshHeader()
                    local parts = {}
                    for _, opt in ipairs(options) do
                        if selected[opt] then
                            table.insert(parts, opt)
                        end
                    end
                    if #parts == 0 then
                        SelLabel.Text      = placeholder
                        SelLabel.TextColor3 = T.DimText
                    else
                        SelLabel.Text      = table.concat(parts, ", ")
                        SelLabel.TextColor3 = T.Text
                    end
                end

                -- ── Helper: get selection as ordered array ─────
                local function GetSelection()
                    local out = {}
                    for _, opt in ipairs(options) do
                        if selected[opt] then table.insert(out, opt) end
                    end
                    return out
                end

                -- ── Build item rows ────────────────────────────
                local itemBoxes = {}   -- opt → checkbox Frame ref

                for i, opt in ipairs(options) do
                    local Item = New("Frame", {
                        Name             = "Item_" .. i,
                        BackgroundColor3 = T.Dropdown_List,
                        BorderSizePixel  = 0,
                        Position         = UDim2.new(0, 0, 0, (i - 1) * ITEM_H),
                        Size             = UDim2.new(1, 0, 0, ITEM_H),
                        Parent           = List,
                    })

                    -- Checkbox: 12×12  x=6  y=(22-12)/2=5  centred ✓
                    local CB = New("Frame", {
                        Name             = "CB",
                        BackgroundColor3 = selected[opt] and T.Checkbox_On or T.Checkbox_BG,
                        BorderColor3     = T.Separator,
                        Position         = UDim2.new(0, 6, 0, 5),
                        Size             = UDim2.new(0, 12, 0, 12),
                        Parent           = Item,
                    })
                    itemBoxes[opt] = CB

                    -- Item label: x=24  right-pad 6 → Size(1,-30,1,0)
                    local ItemLbl = New("TextLabel", {
                        Name                   = "Lbl",
                        BackgroundTransparency = 1,
                        BorderSizePixel        = 0,
                        Position               = UDim2.new(0, 24, 0, 0),
                        Size                   = UDim2.new(1, -30, 1, 0),
                        Font                   = T.Font,
                        Text                   = opt,
                        TextColor3             = selected[opt] and T.Dropdown_Sel or T.Text,
                        TextSize               = T.FontSize,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        TextYAlignment         = Enum.TextYAlignment.Center,
                        TextTruncate           = Enum.TextTruncate.AtEnd,
                        Parent                 = Item,
                    })

                    -- Clickable button over entire item row
                    local ItemBtn = New("TextButton", {
                        BackgroundTransparency = 1,
                        BorderSizePixel        = 0,
                        Size                   = UDim2.new(1, 0, 1, 0),
                        Text                   = "",
                        AutoButtonColor        = false,
                        ZIndex                 = 2,
                        Parent                 = Item,
                    })

                    -- Hover
                    Item.MouseEnter:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_Hover })
                    end)
                    Item.MouseLeave:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_List })
                    end)

                    -- Toggle selection
                    ItemBtn.MouseButton1Click:Connect(function()
                        selected[opt] = not selected[opt]
                        -- Animate checkbox
                        TweenQuad(CB, 0.10, {
                            BackgroundColor3 = selected[opt] and T.Checkbox_On or T.Checkbox_BG
                        })
                        ItemLbl.TextColor3 = selected[opt] and T.Dropdown_Sel or T.Text
                        RefreshHeader()
                        callback(GetSelection())
                    end)
                end

                -- ── Footer: "All" | "None" buttons ────────────
                -- Sits at y = #options × 22  height=22
                -- Divided into two equal halves with a 1px divider in the centre
                -- Each half: (291/2) wide = 145.5 → left=145px  right=146px
                local Footer = New("Frame", {
                    Name             = "Footer",
                    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, #options * ITEM_H),
                    Size             = UDim2.new(1, 0, 0, FOOTER_H),
                    Parent           = List,
                })

                -- Top separator line of footer
                New("Frame", {
                    BackgroundColor3 = T.Separator,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 0),
                    Size             = UDim2.new(1, 0, 0, 1),
                    Parent           = Footer,
                })

                -- "Select All" left half: x=0  w=50%  h=21  (below 1px sep)
                local BtnAll = New("TextButton", {
                    Name                   = "BtnAll",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 0, 0, 1),
                    Size                   = UDim2.new(0.5, -1, 0, FOOTER_H - 1),
                    Font                   = T.Font,
                    Text                   = "Select All",
                    TextColor3             = T.SubText,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = Footer,
                })

                -- Centre divider of footer
                New("Frame", {
                    BackgroundColor3 = T.Separator,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0.5, -1, 0, 1),
                    Size             = UDim2.new(0, 1, 0, FOOTER_H - 1),
                    Parent           = Footer,
                })

                -- "Clear" right half: x=50%+1  w=50%-1  h=21
                local BtnClear = New("TextButton", {
                    Name                   = "BtnClear",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0.5, 1, 0, 1),
                    Size                   = UDim2.new(0.5, -1, 0, FOOTER_H - 1),
                    Font                   = T.Font,
                    Text                   = "Clear",
                    TextColor3             = T.SubText,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = Footer,
                })

                -- Footer button hover colour tweens
                BtnAll.MouseEnter:Connect(function()
                    TweenQuad(BtnAll, 0.08, { TextColor3 = T.Text })
                end)
                BtnAll.MouseLeave:Connect(function()
                    TweenQuad(BtnAll, 0.08, { TextColor3 = T.SubText })
                end)
                BtnClear.MouseEnter:Connect(function()
                    TweenQuad(BtnClear, 0.08, { TextColor3 = T.Text })
                end)
                BtnClear.MouseLeave:Connect(function()
                    TweenQuad(BtnClear, 0.08, { TextColor3 = T.SubText })
                end)

                -- Select All
                BtnAll.MouseButton1Click:Connect(function()
                    for idx, opt in ipairs(options) do
                        selected[opt] = true
                        TweenQuad(itemBoxes[opt], 0.10, { BackgroundColor3 = T.Checkbox_On })
                        local item = List:FindFirstChild("Item_" .. idx)
                        if item then
                            local lbl = item:FindFirstChild("Lbl")
                            if lbl then lbl.TextColor3 = T.Dropdown_Sel end
                        end
                    end
                    RefreshHeader()
                    callback(GetSelection())
                end)

                -- Clear All
                BtnClear.MouseButton1Click:Connect(function()
                    for idx, opt in ipairs(options) do
                        selected[opt] = false
                        TweenQuad(itemBoxes[opt], 0.10, { BackgroundColor3 = T.Checkbox_BG })
                        local item = List:FindFirstChild("Item_" .. idx)
                        if item then
                            local lbl = item:FindFirstChild("Lbl")
                            if lbl then lbl.TextColor3 = T.Text end
                        end
                    end
                    RefreshHeader()
                    callback(GetSelection())
                end)

                -- ── Open / Close ───────────────────────────────
                local function Toggle()
                    isOpen     = not isOpen
                    Arrow.Text = isOpen and "▴" or "▾"
                    if isOpen then
                        List.Visible = true
                        Row.Size     = UDim2.new(1, 0, 0, OPEN_H)
                    else
                        List.Visible = false
                        Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
                    end
                end

                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggle()
                    end
                end)
                Arrow.MouseButton1Click:Connect(Toggle)

                -- Initial header state
                RefreshHeader()

                -- ── Public API ─────────────────────────────────
                return {
                    -- Set selection from array: e.g. obj:Set({"Head","Neck"})
                    Set = function(_, tbl)
                        selected = {}
                        for _, v in ipairs(tbl) do selected[v] = true end
                        for idx, opt in ipairs(options) do
                            local isOn = selected[opt] == true
                            TweenQuad(itemBoxes[opt], 0.10, {
                                BackgroundColor3 = isOn and T.Checkbox_On or T.Checkbox_BG
                            })
                            local item = List:FindFirstChild("Item_" .. idx)
                            if item then
                                local lbl = item:FindFirstChild("Lbl")
                                if lbl then lbl.TextColor3 = isOn and T.Dropdown_Sel or T.Text end
                            end
                        end
                        RefreshHeader()
                        callback(GetSelection())
                    end,
                    Get       = function(_) return GetSelection()   end,
                    Clear     = function(_)
                        for idx, opt in ipairs(options) do
                            selected[opt] = false
                            TweenQuad(itemBoxes[opt], 0.10, { BackgroundColor3 = T.Checkbox_BG })
                            local item = List:FindFirstChild("Item_" .. idx)
                            if item then
                                local lbl = item:FindFirstChild("Lbl")
                                if lbl then lbl.TextColor3 = T.Text end
                            end
                        end
                        RefreshHeader()
                        callback(GetSelection())
                    end,
                    SelectAll = function(_)
                        for idx, opt in ipairs(options) do
                            selected[opt] = true
                            TweenQuad(itemBoxes[opt], 0.10, { BackgroundColor3 = T.Checkbox_On })
                            local item = List:FindFirstChild("Item_" .. idx)
                            if item then
                                local lbl = item:FindFirstChild("Lbl")
                                if lbl then lbl.TextColor3 = T.Dropdown_Sel end
                            end
                        end
                        RefreshHeader()
                        callback(GetSelection())
                    end,
                }
            end

            return Section
        end

        return Tab
    end

    return Window
end

return UILibrary
