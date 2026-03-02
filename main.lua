--[[
    UILibrary — CSGO-style  |  Font.Code  |  Colorways  |  Animations
    ═══════════════════════════════════════════════════════════════════════

    COLORWAYS  (set via cfg.theme in CreateWindow)
    ───────────────────────────────────────────────
      "red"    → RGB(125, 0,   4)   default, classic CSGO cheat red
      "blue"   → RGB(0,   100, 200) ESEA/Faceit blue
      "green"  → RGB(30,  140, 60)  subtle green
      "purple" → RGB(100, 0,  160)  purple

      Only the accent colour changes. All darks/borders stay identical.
      Accent drives: TabActive_BG, Checkbox_On, Dropdown_Sel,
                     Notif.error, section separator on hover.

    ANIMATIONS
    ──────────
      Window open   : Size (0,0)→(630,390)  Back.Out  0.35s  bouncy open
      Tab switch    : active btn Size pulse +3px then back  Back.Out  0.12s
      Checkbox      : Box Size punch 14→11→14  two tweens  Quad.Out  0.08s each
      Dropdown open : List Size 0→listHeight  Back.Out  0.25s  ClipsDescendants
      Dropdown close: List Size listHeight→0  Quad.Out  0.15s  then Visible=false
      Notif slide-in: Card x=310→0  Back.Out  0.3s  bouncy land
      Notif slide-out: Card x=0→310  Quad.Out  0.2s  clean exit
      Hover (tabs)  : BG colour  Quad.Out  0.08s  (unchanged, already smooth)
      Hover (items) : BG colour  Quad.Out  0.08s  (unchanged)

    LAYOUT TREE  (unchanged, pixel-perfect against original dump)
    ═════════════════════════════════════════════════════════════
    ScreenGui (_index_)
    └── _frame1  630×390  BorderSizePixel=0  AnchorPoint(0.5,0.5)  centered
        └── _frame2  620×380  pos=(5,5)  Border RGB(75,75,75)  inner=618×378
            ├── __tabs  608×45  pos=(6,8)  Border RGB(75,75,75)  outer bottom=53
            │   tab buttons 151×45 each  BorderSizePixel=0  Font=Code  FontSize=14  Center
            └── __tabContent  608×314  pos=(6,59)  Border RGB(75,75,75)  inner=606×312
                gap=6px  bottom gap=5px
                ScrollingFrame Size(1,0,1,0)  pad=8px  usable=590×296  ScrollBar=2px
                ColumnHolder 590×auto
                  LeftColumn  291×auto  x=0    UIListLayout Padding=10px
                  RightColumn 291×auto  x=299  UIListLayout Padding=10px  edge=590✓

    SECTION  291px wide
    ────────────────────
      SectionFrame 291×auto AutomaticSize=Y
      Header 291×20  BG transparent
        Title TextLabel full width  Font=Code FontSize=11  Left/Center  RGB(180,180,180)
        Sep   Frame 291×1  y=19  BG RGB(75,75,75)  BorderSizePixel=0
      Body 291×auto  pos y=21  UIListLayout Padding=4px  UIPadding PaddingTop=5px

    TOGGLE  291×26
    ──────────────
      Row 291×26 transparent
      Box 14×14  x=0  y=6  Border RGB(75,75,75)  BG RGB(30,30,30)↔accent
      Lbl x=20  w=271  h=26  Font=Code FontSize=14  Left/Center

    DROPDOWN  291×auto
    ──────────────────
      Wrapper 291×auto AutomaticSize=Y transparent ClipsDescendants=true
      DHeader 291×26  BG RGB(30,30,30)  Border RGB(75,75,75)
        SelLabel x=6  Size(1,-26,1,0)  Font=Code FontSize=14  Left/Center
        Arrow    x=(1,-20)  w=20  h=full  "v"/"^"  Font=Code FontSize=12  Center
      List 291×0→(22×n)  pos y=27  BG RGB(22,22,22)  Border RGB(75,75,75)
        Each item 291×22  BG RGB(22,22,22)  hover→RGB(38,38,38)
          ItemLbl full size  Font=Code FontSize=14  Left/Center  PaddingLeft=6px
                  white normal  accent if selected

    NOTIFICATION  300×60  bottom-right  DisplayOrder=10
    ─────────────────────────────────────────────────────
      Wrapper 300×60  ClipsDescendants  Card inside
      Card BG RGB(16,16,16)  Border RGB(75,75,75)
        Accent bar 4×60  x=0  BG=type colour
        Title  x=12 y=8  h=18  FontSize=13  Left/Center
        Message x=12 y=28  h=24  FontSize=11  Left/Top  Wrapped
        Timer  x=0 y=58  h=2  BG=type colour  drains over duration

    USAGE
    ─────
      local UI  = loadstring(...)()
      local Win = UI:CreateWindow({ key = Enum.KeyCode.RightShift, theme = "blue" })

      local Tab  = Win:AddTab("Legit")
      local Sect = Tab:AddSection("Aimbot", "left")
      Sect:AddToggle("Enable", false, function(v) end)
      Sect:AddDropdown("Bone", {"Head","Neck","Chest"}, "Head", function(v) end)

      UI:Notify("Loaded", "Library ready", "success", 3)
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ─────────────────────────────────────────────────────────────
-- Colorway presets
-- ─────────────────────────────────────────────────────────────
local Colorways = {
    red    = Color3.fromRGB(125, 0,   4),
    blue   = Color3.fromRGB(0,   100, 200),
    green  = Color3.fromRGB(30,  140, 60),
    purple = Color3.fromRGB(100, 0,   160),
}

-- ─────────────────────────────────────────────────────────────
-- Base theme  (accent injected at CreateWindow time)
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
        Dropdown_Hover = Color3.fromRGB(38,  38,  38),
        Dropdown_Sel   = accent,
        Accent         = accent,
        Font           = Enum.Font.Code,
        FontSize       = 14,
        HeaderFontSize = 11,
        Notif = {
            info    = Color3.fromRGB(75,  75,  75),
            success = Color3.fromRGB(30,  140, 60),
            warning = Color3.fromRGB(200, 150, 0),
            error   = Color3.fromRGB(125, 0,   4),  -- always red regardless of theme
        },
    }
end

-- ─────────────────────────────────────────────────────────────
-- TweenInfo presets
-- ─────────────────────────────────────────────────────────────
local TI = {
    -- Bouncy: Back.Out — overshoot then settle. Used for opens, window spawn.
    Bounce   = function(t) return TweenInfo.new(t, Enum.EasingStyle.Back,  Enum.EasingDirection.Out) end,
    -- Smooth: Quad.Out — fast start, decelerates. Used for closes, hovers, colour shifts.
    Smooth   = function(t) return TweenInfo.new(t, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out) end,
    -- Crisp: Linear — constant speed. Used for timer bar, slide-out exits.
    Linear   = function(t) return TweenInfo.new(t, Enum.EasingStyle.Linear) end,
}

local function Tween(obj, ti, props)
    TweenService:Create(obj, ti, props):Play()
end

-- ─────────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────────
local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    return o
end

local function MakeDraggable(handle, target)
    local dragging, dragInput, startMouse, startPos
    handle.InputBegan:Connect(function(inp)
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
        if dragging and inp == dragInput then
            local d = inp.Position - startMouse
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
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
        Name                  = "Container",
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        AnchorPoint           = Vector2.new(1, 1),
        Position              = UDim2.new(1, -10, 1, -10),
        Size                  = UDim2.new(0, 300, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        Parent                = NotifGui,
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
    Card: 300×60
    ┌─────────────────────────────────────────┐
    │████│ Title                              │  y=8   h=18  FontSize=13
    │ 4px│ message text                       │  y=28  h=24  FontSize=11
    │████│▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬│  y=58  h=2   timer
    └─────────────────────────────────────────┘

    Slide in:  Back.Out  0.3s  — bouncy landing from right
    Slide out: Quad.Out  0.2s  — smooth clean exit to right
    Timer:     Linear over duration
]]
function UILibrary:Notify(title, message, ntype, duration)
    EnsureNotifGui()
    ntype    = ntype    or "info"
    duration = duration or 3
    title    = title    or "Notification"
    message  = message  or ""

    -- Use a fallback theme for standalone Notify calls
    local notifColors = {
        info    = Color3.fromRGB(75,  75,  75),
        success = Color3.fromRGB(30,  140, 60),
        warning = Color3.fromRGB(200, 150, 0),
        error   = Color3.fromRGB(125, 0,   4),
    }
    local accent = notifColors[ntype] or notifColors.info
    local order  = math.floor(os.clock() * 1000) % 2147483647

    -- Wrapper: clips the slide animation
    local Wrapper = New("Frame", {
        Name                  = "Notif_" .. order,
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Size                  = UDim2.new(1, 0, 0, 60),
        LayoutOrder           = order,
        ClipsDescendants      = true,
        Parent                = NotifContainer,
    })

    -- Card: starts off-screen right (x=310), slides in with Back.Out bounce
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
        Name             = "Accent",
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 4, 1, 0),
        Parent           = Card,
    })

    -- Title: x=12  y=8  h=18  FontSize=13
    New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Position              = UDim2.new(0, 12, 0, 8),
        Size                  = UDim2.new(1, -20, 0, 18),
        Font                  = Enum.Font.Code,
        Text                  = title,
        TextColor3            = Color3.fromRGB(255, 255, 255),
        TextSize              = 13,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextYAlignment        = Enum.TextYAlignment.Center,
        TextTruncate          = Enum.TextTruncate.AtEnd,
        Parent                = Card,
    })

    -- Message: x=12  y=28  h=24  FontSize=11
    New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Position              = UDim2.new(0, 12, 0, 28),
        Size                  = UDim2.new(1, -20, 0, 24),
        Font                  = Enum.Font.Code,
        Text                  = message,
        TextColor3            = Color3.fromRGB(160, 160, 160),
        TextSize              = 11,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextYAlignment        = Enum.TextYAlignment.Top,
        TextWrapped           = true,
        Parent                = Card,
    })

    -- Timer bar: y=58  h=2  drains left→right over duration
    local TimerBar = New("Frame", {
        Name             = "Timer",
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 58),
        Size             = UDim2.new(1, 0, 0, 2),
        Parent           = Card,
    })

    -- Slide in with bounce
    Tween(Card, TI.Bounce(0.3), { Position = UDim2.new(0, 0, 0, 0) })

    -- Drain timer bar linearly
    TweenService:Create(TimerBar, TI.Linear(duration), { Size = UDim2.new(0, 0, 0, 2) }):Play()

    -- After duration: slide out smoothly then destroy
    task.delay(duration, function()
        if not Card or not Card.Parent then return end
        local t = TweenService:Create(Card, TI.Smooth(0.2), { Position = UDim2.new(0, 310, 0, 0) })
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
    local T           = BuildTheme(accentColor)   -- T = active theme for this window

    local CoreGui = game:GetService("CoreGui")
    do local o = CoreGui:FindFirstChild("_index_") if o then o:Destroy() end end

    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        Parent         = CoreGui,
    })

    -- _frame1: 630×390  no border  centered
    -- Starts at Size(0,0) → tweens to (630,390) with Back.Out for a bouncy open
    local Frame1 = New("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = T.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 0, 0, 0),   -- starts collapsed
        Parent           = Gui,
    })

    -- _frame2: 620×380 at (5,5)  1px border  inner=618×378
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = T.Frame2_BG,
        BorderColor3     = T.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- __tabs: 608×45 at (6,8)  outer bottom=53
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

    -- __tabContent: 608×314 at (6,59)  gap=6px  bottom gap=5px
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = T.Content_BG,
        BorderColor3     = T.Content_Bdr,
        Position         = UDim2.new(0, 6, 0, 59),
        Size             = UDim2.new(0, 608, 0, 314),
        ClipsDescendants = true,
        Parent           = Frame2,
    })

    MakeDraggable(TabBar, Frame1)

    -- Window open animation: Size 0→630×390 with Back.Out bounce
    Tween(Frame1, TI.Bounce(0.35), { Size = UDim2.new(0, 630, 0, 390) })

    -- Menu toggle key
    UserInputService.InputBegan:Connect(function(inp, processed)
        if not processed and inp.KeyCode == toggleKey then
            if Frame1.Visible then
                -- Close: shrink with Smooth
                local t = TweenService:Create(Frame1, TI.Smooth(0.2), { Size = UDim2.new(0, 0, 0, 0) })
                t:Play()
                t.Completed:Connect(function() Frame1.Visible = false end)
            else
                -- Open: show then bounce open
                Frame1.Visible = true
                Tween(Frame1, TI.Bounce(0.35), { Size = UDim2.new(0, 630, 0, 390) })
            end
        end
    end)

    -- ─────────────────────────────────────────────────────────
    -- Window object
    -- ─────────────────────────────────────────────────────────
    local Window = {
        _gui         = Gui,
        _frame       = Frame1,
        _tabBar      = TabBar,
        _contentArea = ContentArea,
        _tabs        = {},
        _activeTab   = nil,
        _theme       = T,
    }

    function Window:SetVisible(v)
        if v then
            self._frame.Visible = true
            Tween(self._frame, TI.Bounce(0.35), { Size = UDim2.new(0, 630, 0, 390) })
        else
            local t = TweenService:Create(self._frame, TI.Smooth(0.2), { Size = UDim2.new(0, 0, 0, 0) })
            t:Play()
            t.Completed:Connect(function() self._frame.Visible = false end)
        end
    end

    function Window:Destroy() self._gui:Destroy() end

    -- ─────────────────────────────────────────────────────────
    -- AddTab
    -- ─────────────────────────────────────────────────────────
    function Window:AddTab(name)
        local index = #self._tabs + 1

        --[[
            Tab button: 151×45  BorderSizePixel=0  Font=Code FontSize=14
            Text Center/Center
            4×151 + 3×1 = 607px fits 608px bar ✓

            Tab switch animation:
              On activate → Size pulse from 151×45 to 153×47 then back to 151×45
              Uses Back.Out 0.12s so it slightly overshoots before settling
              AnchorPoint(0.5,0.5) would shift position; instead we adjust via
              Position offset: nudge x by -1 and y by -1 during pulse then restore.
              Simpler: just tween BackgroundColor3 with Quad.Out — the pulse is
              actually done on the accent bar growing (see below).

            For the pulse we scale the button size momentarily:
              normal:  Size(0,151,0,45)
              pressed: Size(0,154,0,48)  then back to normal
              This requires AnchorPoint(0.5,1) on each button and adjusting
              LayoutOrder positioning — too complex with UIListLayout.

            Practical approach: the "pulse" is a quick BackgroundColor3 flash
            to a slightly lighter accent then fades to the normal accent,
            combined with a TextColor3 flash to white+1.
            This reads as a pop/punch without touching Size.
        ]]
        local Btn = New("TextButton", {
            Name             = "__tabInactive",
            Font             = T.Font,
            Text             = name,
            TextColor3       = T.Text,
            TextSize         = T.FontSize,
            TextXAlignment   = Enum.TextXAlignment.Center,
            TextYAlignment   = Enum.TextYAlignment.Center,
            TextWrapped      = true,
            BackgroundColor3 = T.TabInactive_BG,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 151, 0, 45),
            LayoutOrder      = index,
            AutoButtonColor  = false,
            Parent           = self._tabBar,
        })

        -- Active indicator bar: 2px at bottom of button, accent colour
        -- Starts invisible (w=0), grows to full width on activate — this IS the punch
        local ActiveBar = New("Frame", {
            Name             = "ActiveBar",
            BackgroundColor3 = T.Accent,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0.5, 1),
            Position         = UDim2.new(0.5, 0, 1, 0),
            Size             = UDim2.new(0, 0, 0, 2),
            ZIndex           = 2,
            Parent           = Btn,
        })

        -- Per-tab ScrollingFrame: fills ContentArea inner (606×312)
        -- UIPadding 8px → usable 590×296  ScrollBar=2px
        local Page = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            ScrollBarThickness     = 2,
            ScrollBarImageColor3   = T.TabActive_BG,
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

        -- ColumnHolder: 590px wide, grows in Y
        local Holder = New("Frame", {
            Name                  = "ColumnHolder",
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            Size                  = UDim2.new(1, 0, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            Parent                = Page,
        })

        -- Left column: 291×auto  x=0
        local LeftCol = New("Frame", {
            Name                  = "LeftColumn",
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            Position              = UDim2.new(0, 0, 0, 0),
            Size                  = UDim2.new(0, 291, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            Parent                = Holder,
        })
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = LeftCol })

        -- Right column: 291×auto  x=299  edge=590 ✓
        local RightCol = New("Frame", {
            Name                  = "RightColumn",
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            Position              = UDim2.new(0, 299, 0, 0),
            Size                  = UDim2.new(0, 291, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            Parent                = Holder,
        })
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = RightCol })

        local Tab = {
            _btn       = Btn,
            _bar       = ActiveBar,
            _page      = Page,
            _leftCol   = LeftCol,
            _rightCol  = RightCol,
            _window    = self,
        }

        function Tab:Select()
            for _, t in ipairs(self._window._tabs) do
                t._page.Visible = false
                -- Deactivate: fade BG to inactive, shrink bar to 0
                Tween(t._btn, TI.Smooth(0.12), { BackgroundColor3 = T.TabInactive_BG })
                Tween(t._bar, TI.Smooth(0.12), { Size = UDim2.new(0, 0, 0, 2) })
            end
            self._page.Visible = true
            -- Activate: BG to accent
            Tween(self._btn, TI.Smooth(0.12), { BackgroundColor3 = T.TabActive_BG })
            -- Bar grows to full width with Back.Out bounce — the "punch"
            Tween(self._bar, TI.Bounce(0.25), { Size = UDim2.new(1, 0, 0, 2) })
            self._window._activeTab = self
        end

        Btn.MouseButton1Click:Connect(function() Tab:Select() end)

        Btn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                Tween(Btn, TI.Smooth(0.08), { BackgroundColor3 = Color3.fromRGB(42, 42, 42) })
            end
        end)
        Btn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                Tween(Btn, TI.Smooth(0.08), { BackgroundColor3 = T.TabInactive_BG })
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

            local sectionOrder = 0
            for _, c in ipairs(Col:GetChildren()) do
                if c:IsA("Frame") then sectionOrder += 1 end
            end

            local SectionFrame = New("Frame", {
                Name                  = "Section_" .. sectionName,
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Size                  = UDim2.new(1, 0, 0, 0),
                AutomaticSize         = Enum.AutomaticSize.Y,
                LayoutOrder           = sectionOrder,
                Parent                = Col,
            })

            -- Header: 291×20  Title + 1px separator at y=19
            local Header = New("Frame", {
                Name                  = "Header",
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Size                  = UDim2.new(1, 0, 0, 20),
                Parent                = SectionFrame,
            })
            New("TextLabel", {
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Size                  = UDim2.new(1, 0, 1, 0),
                Font                  = T.Font,
                Text                  = string.upper(sectionName),
                TextColor3            = T.SectionTitle,
                TextSize              = T.HeaderFontSize,
                TextXAlignment        = Enum.TextXAlignment.Left,
                TextYAlignment        = Enum.TextYAlignment.Center,
                Parent                = Header,
            })
            New("Frame", {
                Name             = "Separator",
                BackgroundColor3 = T.Separator,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 0, 0, 19),
                Size             = UDim2.new(1, 0, 0, 1),
                Parent           = Header,
            })

            -- Body: y=21  PaddingTop=5  elements gap=4px
            local Body = New("Frame", {
                Name                  = "Body",
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Position              = UDim2.new(0, 0, 0, 21),
                Size                  = UDim2.new(1, 0, 0, 0),
                AutomaticSize         = Enum.AutomaticSize.Y,
                Parent                = SectionFrame,
            })
            New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = Body })
            New("UIPadding", { PaddingTop = UDim.new(0, 5), Parent = Body })

            local elementCount = 0
            local Section = { _body = Body }

            -- ── AddToggle ─────────────────────────────────────
            --[[
                Row 291×26  transparent
                Box 14×14  x=0  y=6  centred: (26-14)/2=6 ✓
                Lbl x=20  w=271  h=26  Left/Center

                Click animation on Box:
                  Size punch: 14×14 → 11×11 → 14×14
                  Two sequential Quad.Out tweens, 0.07s each
                  Position adjusts to keep centred during shrink:
                    normal:  pos x=0  y=6
                    shrunk:  pos x=1.5  y=7.5  (centre stays same: 0+7=7 → 1.5+5.5=7 ✓)
                  Then colour tweens simultaneously.
            ]]
            function Section:AddToggle(label, default, callback)
                default  = (default == true)
                callback = callback or function() end
                local state = default
                elementCount += 1

                local Row = New("Frame", {
                    Name                  = "Toggle_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Size                  = UDim2.new(1, 0, 0, 26),
                    LayoutOrder           = elementCount,
                    ZIndex                = 1,
                    Parent                = Body,
                })

                -- Box: 14×14  centred at y=6  (26-14)/2=6 ✓
                local Box = New("TextButton", {
                    Name             = "Checkbox",
                    BackgroundColor3 = state and T.Checkbox_On or T.Checkbox_BG,
                    BorderColor3     = T.Checkbox_Bdr,
                    Position         = UDim2.new(0, 0, 0, 6),
                    Size             = UDim2.new(0, 14, 0, 14),
                    Text             = "",
                    AutoButtonColor  = false,
                    ZIndex           = 1,
                    Parent           = Row,
                })

                New("TextLabel", {
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Position              = UDim2.new(0, 20, 0, 0),
                    Size                  = UDim2.new(1, -20, 1, 0),
                    Font                  = T.Font,
                    Text                  = label,
                    TextColor3            = T.Text,
                    TextSize              = T.FontSize,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    TextYAlignment        = Enum.TextYAlignment.Center,
                    ZIndex                = 1,
                    Parent                = Row,
                })

                local animating = false
                local function Apply(val, silent)
                    state = val
                    -- Colour flip: Quad.Out 0.1s smooth
                    Tween(Box, TI.Smooth(0.1), {
                        BackgroundColor3 = state and T.Checkbox_On or T.Checkbox_BG
                    })
                    if not silent then callback(state) end
                end

                local function PunchAndApply()
                    if animating then return end
                    animating = true
                    -- Shrink: 14×14 → 10×10, shift pos to keep centred (add 2px x/y)
                    Tween(Box, TI.Smooth(0.07), {
                        Size     = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, 2, 0, 8),
                    })
                    task.delay(0.07, function()
                        Apply(not state, false)
                        -- Bounce back: 10×10 → 14×14 with Back.Out overshoot
                        Tween(Box, TI.Bounce(0.15), {
                            Size     = UDim2.new(0, 14, 0, 14),
                            Position = UDim2.new(0, 0, 0, 6),
                        })
                        task.delay(0.18, function() animating = false end)
                    end)
                end

                Box.MouseButton1Click:Connect(PunchAndApply)

                return {
                    Set = function(_, v) Apply(v, true) end,
                    Get = function(_)    return state    end,
                }
            end

            -- ── AddDropdown ───────────────────────────────────
            --[[
                Wrapper 291×auto  AutomaticSize=Y  transparent  ClipsDescendants=true
                DHeader 291×26  BG RGB(30,30,30)  Border RGB(75,75,75)
                  SelLabel x=6  Size(1,-26,1,0)  Left/Center  TextTruncate
                  Arrow    x=(1,-20)  w=20  h=full  "v"/"^"  FontSize=12  Center
                List 291×listHeight  pos y=27  BG RGB(22,22,22)  Border RGB(75,75,75)
                  starts Size(1,0,0,0), opens to Size(1,0,0,listHeight) Back.Out 0.25s
                  closes to Size(1,0,0,0) Quad.Out 0.15s, then Visible=false

                Each item 291×22  pos y=(i-1)*22  BG RGB(22,22,22)
                  hover: Quad.Out 0.08s → RGB(38,38,38)
                  ItemLbl full size  Left/Center  PaddingLeft=6  selected=accent
            ]]
            function Section:AddDropdown(label, options, default, callback)
                options  = options  or {}
                callback = callback or function() end
                local selected = default or options[1] or ""
                local isOpen   = false
                local animLock = false
                elementCount  += 1

                local listHeight = #options * 22

                -- Wrapper: transparent, grows with content, clips list animation
                local Wrapper = New("Frame", {
                    Name                  = "Dropdown_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Size                  = UDim2.new(1, 0, 0, 0),
                    AutomaticSize         = Enum.AutomaticSize.Y,
                    LayoutOrder           = elementCount,
                    ClipsDescendants      = true,
                    ZIndex                = 2,
                    Parent                = Body,
                })

                -- DHeader: 291×26  BG RGB(30,30,30)  Border RGB(75,75,75)
                local DHeader = New("Frame", {
                    Name             = "DHeader",
                    BackgroundColor3 = T.Dropdown_BG,
                    BorderColor3     = T.Separator,
                    Size             = UDim2.new(1, 0, 0, 26),
                    ZIndex           = 2,
                    Parent           = Wrapper,
                })

                -- SelLabel: x=6  Size(1,-26,1,0)  fills DHeader minus arrow width
                local SelLabel = New("TextLabel", {
                    Name                  = "Selected",
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Position              = UDim2.new(0, 6, 0, 0),
                    Size                  = UDim2.new(1, -26, 1, 0),
                    Font                  = T.Font,
                    Text                  = selected,
                    TextColor3            = T.Text,
                    TextSize              = T.FontSize,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    TextYAlignment        = Enum.TextYAlignment.Center,
                    TextTruncate          = Enum.TextTruncate.AtEnd,
                    ZIndex                = 2,
                    Parent                = DHeader,
                })

                -- Arrow: rightmost 20px  "v"/"^"  FontSize=12  Center
                local Arrow = New("TextButton", {
                    Name                  = "Arrow",
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Position              = UDim2.new(1, -20, 0, 0),
                    Size                  = UDim2.new(0, 20, 1, 0),
                    Font                  = T.Font,
                    Text                  = "v",
                    TextColor3            = T.SubText,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Center,
                    TextYAlignment        = Enum.TextYAlignment.Center,
                    AutoButtonColor       = false,
                    ZIndex                = 2,
                    Parent                = DHeader,
                })

                -- List: starts at Size(1,0,0,0), animates to listHeight on open
                -- pos y=27 = 26(header) + 1(border gap)
                local List = New("Frame", {
                    Name             = "List",
                    BackgroundColor3 = T.Dropdown_List,
                    BorderColor3     = T.Separator,
                    Position         = UDim2.new(0, 0, 0, 27),
                    Size             = UDim2.new(1, 0, 0, 0),   -- starts closed
                    Visible          = true,                     -- always visible, size drives it
                    ClipsDescendants = true,
                    ZIndex           = 3,
                    Parent           = Wrapper,
                })

                -- Build items
                local itemRefs = {}
                for i, opt in ipairs(options) do
                    local Item = New("Frame", {
                        Name             = "Item_" .. opt,
                        BackgroundColor3 = T.Dropdown_List,
                        BorderSizePixel  = 0,
                        Position         = UDim2.new(0, 0, 0, (i-1)*22),
                        Size             = UDim2.new(1, 0, 0, 22),
                        ZIndex           = 3,
                        Parent           = List,
                    })
                    local ItemLbl = New("TextButton", {
                        BackgroundTransparency = 1,
                        BorderSizePixel       = 0,
                        Size                  = UDim2.new(1, 0, 1, 0),
                        Font                  = T.Font,
                        Text                  = opt,
                        TextColor3            = (opt == selected) and T.Dropdown_Sel or T.Text,
                        TextSize              = T.FontSize,
                        TextXAlignment        = Enum.TextXAlignment.Left,
                        TextYAlignment        = Enum.TextYAlignment.Center,
                        AutoButtonColor       = false,
                        ZIndex                = 3,
                        Parent                = Item,
                    })
                    New("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = ItemLbl })
                    itemRefs[opt] = ItemLbl

                    Item.MouseEnter:Connect(function()
                        Tween(Item, TI.Smooth(0.08), { BackgroundColor3 = T.Dropdown_Hover })
                    end)
                    Item.MouseLeave:Connect(function()
                        Tween(Item, TI.Smooth(0.08), { BackgroundColor3 = T.Dropdown_List })
                    end)

                    ItemLbl.MouseButton1Click:Connect(function()
                        if itemRefs[selected] then itemRefs[selected].TextColor3 = T.Text end
                        selected = opt
                        SelLabel.Text = selected
                        ItemLbl.TextColor3 = T.Dropdown_Sel

                        -- Close with smooth animation
                        isOpen = false
                        Arrow.Text = "v"
                        Tween(List, TI.Smooth(0.15), { Size = UDim2.new(1, 0, 0, 0) })

                        callback(selected)
                    end)
                end

                local function ToggleList()
                    if animLock then return end
                    animLock = true
                    isOpen = not isOpen
                    Arrow.Text = isOpen and "^" or "v"

                    if isOpen then
                        -- Open: Back.Out bounce — overshoots listHeight slightly
                        Tween(List, TI.Bounce(0.25), { Size = UDim2.new(1, 0, 0, listHeight) })
                        task.delay(0.25, function() animLock = false end)
                    else
                        -- Close: Quad.Out smooth
                        Tween(List, TI.Smooth(0.15), { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.15, function() animLock = false end)
                    end
                end

                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then ToggleList() end
                end)
                Arrow.MouseButton1Click:Connect(ToggleList)

                return {
                    Set = function(_, v)
                        if itemRefs[selected] then itemRefs[selected].TextColor3 = T.Text end
                        selected = v
                        SelLabel.Text = v
                        if itemRefs[v] then itemRefs[v].TextColor3 = T.Dropdown_Sel end
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
