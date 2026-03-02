--[[
    UILibrary — CSGO-style | Font.Code | Colorways | Watermark | QOL Anims
    ═══════════════════════════════════════════════════════════════════════

    COLORWAYS  (cfg.theme)
    ───────────────────────
      "red"    → RGB(125,  0,   4)   default
      "blue"   → RGB(0,   100, 200)
      "green"  → RGB(30,  140,  60)
      "purple" → RGB(100,  0,  160)

    QOL ANIMATIONS  (colour tweens only — zero layout impact)
    ──────────────────────────────────────────────────────────
      Tab BG on select    Quad.Out  0.10s
      Tab BG on hover     Quad.Out  0.08s
      Checkbox BG toggle  Quad.Out  0.10s
      Dropdown item hover Quad.Out  0.08s
      Notif slide-in      Quad.Out  0.22s   x=310→0   (wrapper clips)
      Notif slide-out     Quad.Out  0.16s   x=0→310   then Destroy
      Notif timer drain   Linear    duration seconds

    MAIN WINDOW
    ═══════════
    ScreenGui (_index_)  DisplayOrder=1  ZIndexBehavior=Sibling
    └── _frame1  630×390  BorderSizePixel=0  AnchorPoint(0.5,0.5)  centered
        │        BG RGB(29,29,29)   draggable via frame1+frame2+tabbar
        └── _frame2  620×380  pos=(5,5)  Border RGB(75,75,75) 1px
            │        BG RGB(16,16,16)   inner=618×378
            ├── __tabs  608×45  pos=(6,8)  Border RGB(75,75,75) 1px
            │   │        BG RGB(16,16,16)   UIListLayout Horiz Padding=1px
            │   └── [tab buttons]  151×45 each  BorderSizePixel=0
            │             Font=Code FontSize=14  TextXAlign=Center
            │             4×151+3×1=607px fits 608px ✓
            │             ActiveBar: 2px bottom  BG=accent  Visible on active
            └── __tabContent  608×314  pos=(6,59)
                │        Border RGB(75,75,75) 1px  BG RGB(16,16,16)
                │        ClipsDescendants=true
                │        tab bar bottom=53  content top=59  gap=6px ✓
                │        content bottom=373  frame2 inner=378  gap=5px ✓
                └── [ScrollingFrame per tab]  Size(1,0,1,0)
                    │     UIPadding 8px all sides → usable 590×296
                    │     ScrollBarThickness=2  ScrollingDirection=Y
                    └── ColumnHolder  Size(1,0,0,0)  AutomaticSize=Y
                        ├── LeftCol   291×auto  pos x=0   UIListLayout Padding=10px
                        └── RightCol  291×auto  pos x=299  UIListLayout Padding=10px
                            right edge=299+291=590 ✓

    COLUMN MATH
    ───────────
      usable w = 606(inner) - 16(pad) = 590px
      each col = (590-8)/2 = 291px ✓   right x = 291+8 = 299px ✓

    SECTION  (291px wide)
    ──────────────────────
      SectionFrame  291×auto  AutomaticSize=Y  BG transparent
      Header        291×20    BG transparent
        Title       TextLabel  full size  Font=Code FontSize=11
                    Left/Center  UPPER  RGB(180,180,180)
        Sep         Frame 291×1  y=19  BG RGB(75,75,75)  BorderSizePixel=0
      Body          291×auto  pos y=21  AutomaticSize=Y  BG transparent
                    UIListLayout Padding=4px  UIPadding PaddingTop=5px

    TOGGLE  (291×26)
    ─────────────────
      Row  291×26   BG transparent
      Box  14×14    pos x=4  y=6   4px margin  (26-14)/2=6 centred ✓
                    Border RGB(75,75,75)   BG↔accent  Quad.Out 0.10s
      Lbl  pos x=24  Size(1,-24,1,0)  Font=Code FontSize=14  Left/Center

    DROPDOWN  (fixed-height row)
    ─────────────────────────────
      Row     291×CLOSED_H(26) or 291×OPEN_H(27+n×22)
              BG transparent  ClipsDescendants=true  fixed Size.Y
      DHeader 291×26  BG RGB(30,30,30)  Border RGB(75,75,75) 1px
        SelLabel  x=6  Size(1,-26,1,0)  Font=Code FontSize=14  Left/Center
        Arrow     x=(1,-20)  Size(0,20,1,0)  "v"/"^"  FontSize=12  Center
      List    pos y=27  Size(1,0,0,n×22)  BG RGB(22,22,22)
              Border RGB(75,75,75) 1px  Visible=false when closed
        Item[i]  pos y=(i-1)×22  Size(1,0,0,22)  BG RGB(22,22,22)
          Hover: Quad.Out 0.08s BG colour
          ItemBtn  full size  Font=Code FontSize=14  Left/Center  PaddingLeft=6
                   TextColor3: white or accent

    WATERMARK
    ══════════
    ScreenGui (_wmk_)  DisplayOrder=5  ZIndexBehavior=Sibling
    Enabled=true when GUI visible, Enabled=false when GUI hidden
    (Enabled=false → invisible + zero input passthrough)

    └── WmkF1  auto×28  BorderSizePixel=0  BG RGB(29,29,29)
        │       pos=(0,10,0,10)  AnchorPoint(0,0)  AutomaticSize=X
        │       Draggable. Guard: only drags when Frame1.Visible==true
        └── WmkF2  pos=(1,1)  Size=(1,-2,0,26)  AutomaticSize=X
                    BG RGB(16,16,16)  Border RGB(75,75,75) 1px
                    UIListLayout Horizontal VerticalAlignment=Center Padding=0

            Layout children (all 26px tall, AutomaticSize=X on labels):
              AccentBar   4×26   BG=accent  BorderSizePixel=0  LayoutOrder=1
              Spacer1     6×26   BG transparent                LayoutOrder=2
              NameLbl     auto×26  Font=Code FontSize=13  white Left/Center LayoutOrder=3
              Spacer2     6×26   BG transparent                LayoutOrder=4
              Divider     1×14   BG RGB(75,75,75)  BorderSizePixel=0  LayoutOrder=5
              Spacer3     6×26   BG transparent                LayoutOrder=6
              UserLbl     auto×26  Font=Code FontSize=11  RGB(160,160,160)  LayoutOrder=7
              RightEnd    8×26   BG transparent                LayoutOrder=8

            WmkF1 height=28 = WmkF2(26) + top(1) + bottom(1) ✓
            WmkF2 inner (after 1px border each side) = auto×24
            AccentBar 4×26 occupies full inner height including borders
            Divider 1×14: VerticalAlignment=Center on UIListLayout centres it ✓

    NOTIFICATION  (300×60  bottom-right  DisplayOrder=10)
    ──────────────────────────────────────────────────────
      Wrapper 300×60  ClipsDescendants
      Card  BG RGB(16,16,16)  Border RGB(75,75,75)
            slide-in:  x=310→0  Quad.Out 0.22s
            slide-out: x=0→310  Quad.Out 0.16s  then Destroy
        Accent bar  4×60  BG=type colour  BorderSizePixel=0
        Title       x=12  y=8   h=18  FontSize=13  Left/Center
        Message     x=12  y=28  h=24  FontSize=11  Left/Top  Wrapped
        Timer bar   x=0   y=58  h=2   BG=type colour  Linear drain

    USAGE
    ─────
      local UI  = loadstring(...)()
      local Win = UI:CreateWindow({
          key   = Enum.KeyCode.RightShift,
          theme = "blue",        -- "red"|"blue"|"green"|"purple"
          name  = "MyScript",    -- watermark left label
      })
      local Tab  = Win:AddTab("Legit")
      local Sect = Tab:AddSection("Aimbot", "left")
      Sect:AddToggle("Enable", false, function(v) end)
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
local Players          = game:GetService("Players")

-- ─────────────────────────────────────────────────────────────
-- Colorways
-- ─────────────────────────────────────────────────────────────
local Colorways = {
    red    = Color3.fromRGB(125,  0,   4),
    blue   = Color3.fromRGB(0,   100, 200),
    green  = Color3.fromRGB(30,  140,  60),
    purple = Color3.fromRGB(100,  0,  160),
}

-- ─────────────────────────────────────────────────────────────
-- Theme builder
-- ─────────────────────────────────────────────────────────────
local function BuildTheme(accent)
    return {
        Frame1_BG      = Color3.fromRGB(29,  29,  29),
        Frame2_BG      = Color3.fromRGB(16,  16,  16),
        Frame2_Bdr     = Color3.fromRGB(75,  75,  75),
        TabBar_BG      = Color3.fromRGB(16,  16,  16),
        TabBar_Bdr     = Color3.fromRGB(75,  75,  75),
        TabInactive_BG = Color3.fromRGB(30,  30,  30),
        TabActive_BG   = accent,
        Content_BG     = Color3.fromRGB(16,  16,  16),
        Content_Bdr    = Color3.fromRGB(75,  75,  75),
        Separator      = Color3.fromRGB(75,  75,  75),
        SectionTitle   = Color3.fromRGB(180, 180, 180),
        Text           = Color3.fromRGB(255, 255, 255),
        SubText        = Color3.fromRGB(160, 160, 160),
        Checkbox_BG    = Color3.fromRGB(30,  30,  30),
        Checkbox_Bdr   = Color3.fromRGB(75,  75,  75),
        Checkbox_On    = accent,
        Dropdown_BG    = Color3.fromRGB(30,  30,  30),
        Dropdown_List  = Color3.fromRGB(22,  22,  22),
        Dropdown_Hover = Color3.fromRGB(40,  40,  40),
        Dropdown_Sel   = accent,
        Accent         = accent,
        Font           = Enum.Font.Code,
        FontSize       = 14,
        HdrSize        = 11,
        Notif = {
            info    = Color3.fromRGB(75,  75,  75),
            success = Color3.fromRGB(30,  140,  60),
            warning = Color3.fromRGB(200, 150,   0),
            error   = Color3.fromRGB(125,  0,    4),
        },
    }
end

-- ─────────────────────────────────────────────────────────────
-- Tween helpers  (colour tweens only — no Size/Position tweens
--                 that could interfere with layout)
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
-- New — instance factory
-- ─────────────────────────────────────────────────────────────
local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    return o
end

-- ─────────────────────────────────────────────────────────────
-- MakeDraggable
--   handle     — frame the user clicks to start dragging
--   target     — frame that actually moves
--   getEnabled — optional fn() → bool  (return false to block drag)
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
    -- Container: 300px wide, bottom-right, 10px margin
    -- AutomaticSize=Y grows upward, VerticalAlignment=Bottom → newest at bottom
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
-- UILibrary:Notify
-- ─────────────────────────────────────────────────────────────
--[[
    Card 300×60:
    ┌──────────────────────────────────────────────────────────┐
    │▓▓▓▓│ Title                                               │  y=8  h=18  FontSize=13
    │ 4px│ message text                                        │  y=28 h=24  FontSize=11
    │▓▓▓▓│▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬│  y=58 h=2
    └──────────────────────────────────────────────────────────┘

    Slide-in:  Card pos x=310→0  Quad.Out 0.22s
    Slide-out: Card pos x=0→310  Quad.Out 0.16s  then Wrapper:Destroy()
    Timer:     Size(1,0,0,2) → Size(0,0,0,2)  Linear over duration
]]
function UILibrary:Notify(title, message, ntype, duration)
    EnsureNotifGui()
    ntype    = ntype    or "info"
    duration = duration or 3
    title    = title    or "Notification"
    message  = message  or ""

    local notifColors = {
        info    = Color3.fromRGB(75,  75,  75),
        success = Color3.fromRGB(30,  140,  60),
        warning = Color3.fromRGB(200, 150,   0),
        error   = Color3.fromRGB(125,  0,    4),
    }
    local accent = notifColors[ntype] or notifColors.info
    local order  = math.floor(os.clock() * 1000) % 2147483647

    -- Wrapper: 300×60, clips the horizontal card animation
    local Wrapper = New("Frame", {
        Name                   = "Notif_" .. order,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 60),
        LayoutOrder            = order,
        ClipsDescendants       = true,
        Parent                 = NotifContainer,
    })

    -- Card: starts off-screen right (x=310), slides to x=0
    local Card = New("Frame", {
        Name             = "Card",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        BorderColor3     = Color3.fromRGB(75, 75, 75),
        Position         = UDim2.new(0, 310, 0, 0),
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = Wrapper,
    })

    -- Accent bar: 4×60 full height no border
    New("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 0),
        Size             = UDim2.new(0, 4, 1, 0),
        Parent           = Card,
    })

    -- Title: x=12  y=8  h=18  FontSize=13  Left/Center
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

    -- Message: x=12  y=28  h=24  FontSize=11  Left/Top  Wrapped
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

    -- Timer bar: y=58  h=2  drains left → right over duration
    local TimerBar = New("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 58),
        Size             = UDim2.new(1, 0, 0, 2),
        Parent           = Card,
    })

    -- Slide in: Quad.Out 0.22s
    TweenQuad(Card, 0.22, { Position = UDim2.new(0, 0, 0, 0) })

    -- Drain timer: Linear over duration
    TweenLinear(TimerBar, duration, { Size = UDim2.new(0, 0, 0, 2) })

    -- After duration: slide out Quad.Out 0.16s then destroy
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
    local toggleKey   = cfg.key   or Enum.KeyCode.RightShift
    local accentColor = Colorways[cfg.theme] or Colorways.red
    local scriptName  = tostring(cfg.name  or "Script")
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

    -- ── _frame2: 620×380  pos=(5,5)  1px border  inner=618×378
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = T.Frame2_BG,
        BorderColor3     = T.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- ── __tabs: 608×45  pos=(6,8)  1px border  outer bottom=53
    local TabBar = New("Frame", {
        Name             = "__tabs",
        BackgroundColor3 = T.TabBar_BG,
        BorderColor3     = T.TabBar_Bdr,
        Position         = UDim2.new(0, 6, 0, 4),
        Size             = UDim2.new(0, 608, 0, 45),
        Parent           = Frame2,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, 1),
        Parent        = TabBar,
    })

    -- ── __tabContent: 608×314  pos=(6,59)  1px border
    --    gap from tab bar: 59-53=6px ✓   bottom: 59+314=373 → gap=5px ✓
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = T.Content_BG,
        BorderColor3     = T.Content_Bdr,
        Position         = UDim2.new(0, 6, 0, 59),
        Size             = UDim2.new(0, 608, 0, 314),
        ClipsDescendants = true,
        Parent           = Frame2,
    })

    -- ── Dragging: all three handles move Frame1 ────────────────
    MakeDraggable(Frame1, Frame1)
    MakeDraggable(Frame2, Frame1)
    MakeDraggable(TabBar, Frame1)

    -- ─────────────────────────────────────────────────────────
    -- Watermark
    -- ─────────────────────────────────────────────────────────
    --[[
        Two-frame shell identical in design language to the main GUI.

        WmkF1 (outer, like _frame1):
          auto×28   BorderSizePixel=0   BG RGB(29,29,29)
          pos=(0,10,0,10)  AnchorPoint(0,0)  AutomaticSize=X

        WmkF2 (inner, like _frame2):
          pos=(1,1) inside WmkF1 → 1px visible border all sides
          Size=(1,-2,0,26)  →  WmkF1 inner minus 1px each side = 26px tall
          BG RGB(16,16,16)   Border RGB(75,75,75) 1px
          AutomaticSize=X   UIListLayout Horizontal VerticalAlignment=Center

        Content children (all in UIListLayout, 26px tall each):
          AccentBar   4×26   BG=accent   BorderSizePixel=0
          Spacer1     6×26   transparent
          NameLbl     auto×26  Font=Code FontSize=13  white
          Spacer2     6×26   transparent
          Divider     1×14   BG RGB(75,75,75)   (VerticalAlignment=Center centres it)
          Spacer3     6×26   transparent
          UserLbl     auto×26  Font=Code FontSize=11  RGB(160,160,160)
          RightEnd    8×26   transparent  (right breathing room)

        Height proof:
          WmkF2 = 26px  pos y=1  bottom edge=27px
          WmkF1 = 28px  →  bottom gap = 28-27 = 1px ✓  (border visible)

        Drag guard:  getEnabled = function() return Frame1.Visible end
          When GUI hidden: Frame1.Visible=false → guard blocks drag start
          WmkGui.Enabled=false → ScreenGui fully non-interactive + invisible
    ]]
    local WmkGui = New("ScreenGui", {
        Name           = "_wmk_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 5,
        ResetOnSpawn   = false,
        Enabled        = true,
        Parent         = CoreGui,
    })

    -- WmkF1: outer shell  auto-width × 28px
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

    -- WmkF2: inner panel  pos=(1,1)  Size=(1,-2,0,26)  auto-width
    local WmkF2 = New("Frame", {
        Name             = "WmkF2",
        BackgroundColor3 = T.Frame2_BG,
        BorderColor3     = T.Frame2_Bdr,
        Position         = UDim2.new(0, 1, 0, 1),
        Size             = UDim2.new(1, -2, 0, 26),
        AutomaticSize    = Enum.AutomaticSize.X,
        Parent           = WmkF1,
    })

    -- UIListLayout: horizontal, children centred vertically
    New("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 0),
        Parent            = WmkF2,
    })

    -- Helper: make a fixed-size spacer (transparent, in UIListLayout)
    local function Spacer(w, order)
        New("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, w, 0, 26),
            LayoutOrder            = order,
            Parent                 = WmkF2,
        })
    end

    -- AccentBar: 4×26  BG=accent  no border  LayoutOrder=1
    New("Frame", {
        Name             = "AccentBar",
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 4, 0, 26),
        LayoutOrder      = 1,
        Parent           = WmkF2,
    })

    Spacer(6, 2)   -- gap between accent bar and script name

    -- Script name: AutomaticSize=X  Font=Code FontSize=13  white
    local localName = (Players.LocalPlayer and Players.LocalPlayer.Name) or "Player"
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
        LayoutOrder            = 3,
        Parent                 = WmkF2,
    })

    Spacer(6, 4)   -- gap before divider

    -- Divider: 1×14  BG=separator colour  VerticalAlignment centres it
    New("Frame", {
        Name             = "Divider",
        BackgroundColor3 = T.Separator,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 1, 0, 14),
        LayoutOrder      = 5,
        Parent           = WmkF2,
    })

    Spacer(6, 6)   -- gap after divider

    -- Username: AutomaticSize=X  Font=Code FontSize=11  SubText grey
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
        LayoutOrder            = 7,
        Parent                 = WmkF2,
    })

    Spacer(8, 8)   -- right breathing room

    -- Watermark drag: guard blocks dragging when GUI is hidden
    local function wmkEnabled() return Frame1.Visible end
    MakeDraggable(WmkF1, WmkF1, wmkEnabled)
    MakeDraggable(WmkF2, WmkF1, wmkEnabled)

    -- ── Toggle key: syncs both GUI and watermark ────────────────
    UserInputService.InputBegan:Connect(function(inp, processed)
        if not processed and inp.KeyCode == toggleKey then
            local show       = not Frame1.Visible
            Frame1.Visible   = show
            WmkGui.Enabled   = show   -- false → invisible + non-interactive
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

    function Window:SetVisible(v)
        self._frame.Visible  = v
        self._wmkGui.Enabled = v
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
        -- 4×151+3×1=607px fits 608px tab bar ✓
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

        -- Active indicator bar: 2px at very bottom of button  BG=accent
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

        -- Per-tab ScrollingFrame: fills ContentArea inner 606×312
        -- UIPadding 8px → usable 590×296   ScrollBar=2px Y-only
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

        -- RightCol: 291×auto  x=299  right edge=590 ✓
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

        -- Tab object
        local Tab = {
            _btn      = Btn,
            _bar      = ActiveBar,
            _page     = Page,
            _leftCol  = LeftCol,
            _rightCol = RightCol,
            _window   = self,
        }

        function Tab:Select()
            -- Deactivate all tabs
            for _, t in ipairs(self._window._tabs) do
                t._page.Visible = false
                t._bar.Visible  = false
                TweenQuad(t._btn, 0.10, { BackgroundColor3 = T.TabInactive_BG })
            end
            -- Activate this tab
            self._page.Visible = true
            self._bar.Visible  = true
            TweenQuad(self._btn, 0.10, { BackgroundColor3 = T.TabActive_BG })
            self._window._activeTab = self
        end

        Btn.MouseButton1Click:Connect(function() Tab:Select() end)

        -- Hover: Quad.Out 0.08s colour shift
        Btn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                TweenQuad(Btn, 0.08, { BackgroundColor3 = Color3.fromRGB(42, 42, 42) })
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

            -- ── AddToggle ─────────────────────────────────────
            --[[
                Row  291×26  BG transparent
                Box  14×14   pos x=4  y=6   (26-14)/2=6 centred ✓
                             Border RGB(75,75,75)
                             BG ↔ accent  Quad.Out 0.10s
                Lbl  pos x=24  Size(1,-24,1,0)  Left/Center
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

                -- Checkbox: 14×14  x=4  y=6
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
                    -- QOL: colour-only tween, zero layout risk
                    TweenQuad(Box, 0.10, {
                        BackgroundColor3 = state and T.Checkbox_On or T.Checkbox_BG
                    })
                    if not silent then callback(state) end
                end

                Box.MouseButton1Click:Connect(function() Apply(not state, false) end)

                return {
                    Set = function(_, v) Apply(v, true) end,
                    Get = function(_)    return state   end,
                }
            end

            -- ── AddDropdown ───────────────────────────────────
            --[[
                Fixed-height Row — NO AutomaticSize, avoids layout gaps.
                  CLOSED_H = 26   (header only)
                  OPEN_H   = 27 + n×22  (header + 1px gap + list)
                Row.Size.Y switches instantly. ClipsDescendants hides list.

                DHeader  291×26  BG RGB(30,30,30)  Border RGB(75,75,75) 1px
                  SelLabel  x=6  Size(1,-26,1,0)  Left/Center  TextTruncate
                  Arrow     x=(1,-20)  Size(0,20,1,0)  "v"/"^"  FontSize=12  Center
                List  pos y=27  Size(1,0,0,n×22)  BG RGB(22,22,22)  Border 1px
                  Item[i]  pos y=(i-1)×22  Size(1,0,0,22)  BG RGB(22,22,22)
                    hover: Quad.Out 0.08s BG colour
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

                -- Row: fixed height, clips list when closed
                local Row = New("Frame", {
                    Name                   = "DD_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, CLOSED_H),
                    LayoutOrder            = elementCount,
                    ClipsDescendants       = true,
                    Parent                 = Body,
                })

                -- DHeader: full width × 26px
                local DHeader = New("Frame", {
                    Name             = "DHeader",
                    BackgroundColor3 = T.Dropdown_BG,
                    BorderColor3     = T.Separator,
                    Size             = UDim2.new(1, 0, 0, 26),
                    Parent           = Row,
                })

                -- SelLabel: x=6  Size(1,-26,1,0)  (leaves 20px for arrow)
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
                    Text                   = "v",
                    TextColor3             = T.SubText,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = DHeader,
                })

                -- List: y=27  Size(1,0,0,LIST_H)  hidden initially
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

                    -- Hover: Quad.Out 0.08s colour shift
                    Item.MouseEnter:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_Hover })
                    end)
                    Item.MouseLeave:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_List })
                    end)

                    -- Select
                    ItemBtn.MouseButton1Click:Connect(function()
                        if itemRefs[selected] then
                            itemRefs[selected].TextColor3 = T.Text
                        end
                        selected           = opt
                        SelLabel.Text      = selected
                        ItemBtn.TextColor3 = T.Dropdown_Sel
                        -- Close instantly
                        isOpen       = false
                        Arrow.Text   = "v"
                        List.Visible = false
                        Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
                        callback(selected)
                    end)
                end

                -- Toggle open/close — instant size switch
                local function Toggle()
                    isOpen     = not isOpen
                    Arrow.Text = isOpen and "^" or "v"
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
                            Arrow.Text   = "v"
                            List.Visible = false
                            Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
                        end
                        callback(selected)
                    end,
                    Get = function(_) return selected end,
                }
            end

            return Section
        end

        return Tab
    end

    return Window
end

return UILibrary
