--[[
    UILibrary — CSGO-style  |  Font.Code  |  Colorways  |  No animations
    ═══════════════════════════════════════════════════════════════════════

    COLORWAYS  (cfg.theme = "red"|"blue"|"green"|"purple")
    ───────────────────────────────────────────────────────
      "red"    → RGB(125, 0,   4)   default
      "blue"   → RGB(0,   100, 200)
      "green"  → RGB(30,  140, 60)
      "purple" → RGB(100, 0,   160)

    LAYOUT  (pixel-perfect, all values in absolute px)
    ═══════════════════════════════════════════════════
    ScreenGui (_index_)
    └── _frame1   630×390   BorderSizePixel=0   AnchorPoint(0.5,0.5)
        │         BG RGB(29,29,29)   draggable
        └── _frame2   620×380   pos=(5,5)   Border RGB(75,75,75) 1px
            │         BG RGB(16,16,16)   draggable
            ├── __tabs   608×45   pos=(6,8)   Border RGB(75,75,75) 1px
            │   │         BG RGB(16,16,16)   draggable
            │   │         UIListLayout Horizontal Padding=1px
            │   └── [tab buttons]   151×45 each   BorderSizePixel=0
            │             Font=Code FontSize=14   TextXAlignment=Center
            │             4×151 + 3×1 = 607px fits 608px bar ✓
            └── __tabContent   608×314   pos=(6,59)
                │         Border RGB(75,75,75) 1px   BG RGB(16,16,16)
                │         ClipsDescendants=true
                │         gap from tab bar: 59 - (8+45) = 6px ✓
                │         bottom: 59+314=373, frame2 inner 378, gap=5px ✓
                └── [per-tab ScrollingFrame]   Size(1,0,1,0)
                    │     BG transparent   BorderSizePixel=0
                    │     UIPadding: 8px all sides → usable 590×296
                    │     ScrollBarThickness=2   ScrollingDirection=Y
                    └── ColumnHolder   Size(1,0,0,0)   AutomaticSize=Y
                        │             BG transparent
                        ├── LeftColumn    291×auto   pos x=0
                        │   UIListLayout vertical Padding=10px
                        └── RightColumn   291×auto   pos x=299
                            UIListLayout vertical Padding=10px
                            right edge = 299+291 = 590 ✓

    COLUMN MATH
    ───────────
      scrollframe inner w = 606 - 16(pad) = 590px
      gap between cols    = 8px
      each col            = (590-8)/2 = 291px ✓
      right col x         = 291+8 = 299px ✓

    SECTION  (291px wide)
    ──────────────────────
      SectionFrame   291×auto   AutomaticSize=Y   BG transparent
      Header         291×20     BG transparent
        Title        TextLabel  full size  Font=Code FontSize=11
                     TextXAlignment=Left  TextYAlignment=Center
                     Text=UPPER  Color=RGB(180,180,180)
        Separator    Frame 291×1  pos y=19  BG RGB(75,75,75)
      Body           291×auto   pos y=21   AutomaticSize=Y   BG transparent
                     UIListLayout vertical Padding=4px
                     UIPadding PaddingTop=5px

    TOGGLE  (291×26)
    ─────────────────
      Row   291×26   BG transparent
      Box   14×14    pos x=4  y=6   ← 4px left margin keeps it off the edge
                     Border RGB(75,75,75)   BG RGB(30,30,30) or accent
      Label pos x=24  Size(1,-24,1,0)   Font=Code FontSize=14
            TextXAlignment=Left  TextYAlignment=Center

    DROPDOWN  (291×auto, NO AutomaticSize — fixed height switching)
    ─────────────────────────────────────────────────────────────────
      Row         291×26 closed,  291×(26+1+n×22) open
                  BG transparent   height set manually via Row.Size
      DHeader     291×26   BG RGB(30,30,30)   Border RGB(75,75,75) 1px
        SelLabel  pos x=6  Size(1,-26,1,0)   Font=Code FontSize=14
                  Left/Center   TextTruncate=AtEnd
        Arrow     pos x=(1,-20)  Size(0,20,1,0)   Text "v"/"^"
                  Font=Code FontSize=12   Center   BG transparent
      List        291×(n×22)   pos y=27   BG RGB(22,22,22)
                  Border RGB(75,75,75) 1px   Visible=false when closed
                  ClipsDescendants=false  (no animation clipping needed)
        Each item   Frame 291×22   BG RGB(22,22,22)   pos y=(i-1)*22
          ItemBtn   TextButton full size   Font=Code FontSize=14
                    Left/Center   PaddingLeft=6px   AutoButtonColor=false
                    Color=white normal, accent if selected

    KEY FIX: Row has a FIXED size (not AutomaticSize). When closed, Row.Size.Y=26.
    When open, Row.Size.Y = 26+1+n×22. List Visible toggles. No tween needed.
    This avoids the gap bug caused by AutomaticSize seeing a zero-height but
    still-present List frame keeping layout space.

    DRAGGING
    ────────
      MakeDraggable called on: TabBar → Frame1, Frame2 → Frame1, Frame1 → Frame1
      All three drag handles move Frame1 (the root). Frame1 has AnchorPoint(0.5,0.5)
      so Position starts at scale(0.5,0.5). After first drag it becomes offset-based.
      Works correctly because we preserve the current Position as startPos.

    NOTIFICATION  (300×60, bottom-right, DisplayOrder=10)
    ──────────────────────────────────────────────────────
      Wrapper 300×60  ClipsDescendants
      Card    BG RGB(16,16,16)  Border RGB(75,75,75)
              pos x=310 → 0  (instant, no tween)
        Accent bar  4×60  BG=type colour
        Title       x=12 y=8  h=18  FontSize=13  Left/Center
        Message     x=12 y=28  h=24  FontSize=11  Left/Top  Wrapped
        Timer bar   x=0 y=58  h=2  BG=type colour  shrinks over duration (Linear tween only)

    USAGE
    ─────
      local UI  = loadstring(...)()
      local Win = UI:CreateWindow({ key=Enum.KeyCode.RightShift, theme="blue" })
      local Tab  = Win:AddTab("Legit")
      local Sect = Tab:AddSection("Aimbot","left")
      Sect:AddToggle("Enable", false, function(v) end)
      Sect:AddDropdown("Bone",{"Head","Neck","Chest"},"Head",function(v) end)
      UI:Notify("Loaded","Ready","success",3)
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ─────────────────────────────────────────────────────────────
-- Colorways
-- ─────────────────────────────────────────────────────────────
local Colorways = {
    red    = Color3.fromRGB(125, 0,   4),
    blue   = Color3.fromRGB(0,   100, 200),
    green  = Color3.fromRGB(30,  140, 60),
    purple = Color3.fromRGB(100, 0,   160),
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
            success = Color3.fromRGB(30,  140, 60),
            warning = Color3.fromRGB(200, 150, 0),
            error   = Color3.fromRGB(125, 0,   4),
        },
    }
end

-- ─────────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────────
local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    return o
end

-- Only tween used: Linear for the notification timer bar drain.
-- Everything else is instant (no animation).
local function DrainTween(obj, duration)
    TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { Size = UDim2.new(0, 0, 0, 2) }
    ):Play()
end

-- ─────────────────────────────────────────────────────────────
-- MakeDraggable
-- Attaches drag behaviour: clicking handle moves target.
-- Works with AnchorPoint(0.5,0.5) since we store startPos each drag.
-- ─────────────────────────────────────────────────────────────
local function MakeDraggable(handle, target)
    local dragging   = false
    local dragInput  = nil
    local startMouse = nil
    local startPos   = nil

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
                startPos.X.Scale,
                startPos.X.Offset + d.X,
                startPos.Y.Scale,
                startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- Notification system
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
    Card 300×60:
    ┌────────────────────────────────────────────────┐
    │▓▓▓▓│ Title                                     │  y=8   h=18
    │ 4px│ message text here                          │  y=28  h=24
    │▓▓▓▓│▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬│  y=58  h=2
    └────────────────────────────────────────────────┘

    Card appears instantly at x=0 (no slide animation).
    Timer bar drains via Linear tween over `duration` seconds.
    After duration: Card destroyed instantly (no slide out).
]]
function UILibrary:Notify(title, message, ntype, duration)
    EnsureNotifGui()
    ntype    = ntype    or "info"
    duration = duration or 3
    title    = title    or "Notification"
    message  = message  or ""

    local notifColors = {
        info    = Color3.fromRGB(75,  75,  75),
        success = Color3.fromRGB(30,  140, 60),
        warning = Color3.fromRGB(200, 150, 0),
        error   = Color3.fromRGB(125, 0,   4),
    }
    local accent = notifColors[ntype] or notifColors.info
    local order  = math.floor(os.clock() * 1000) % 2147483647

    local Wrapper = New("Frame", {
        Name                  = "Notif_" .. order,
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Size                  = UDim2.new(1, 0, 0, 60),
        LayoutOrder           = order,
        ClipsDescendants      = true,
        Parent                = NotifContainer,
    })

    -- Card at x=0 immediately — no slide animation
    local Card = New("Frame", {
        Name             = "Card",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        BorderColor3     = Color3.fromRGB(75, 75, 75),
        Position         = UDim2.new(0, 0, 0, 0),
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = Wrapper,
    })

    -- Accent bar: 4px wide, full height
    New("Frame", {
        Name             = "Accent",
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 0),
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

    -- Timer bar: y=58  h=2  drains linearly over duration
    local TimerBar = New("Frame", {
        Name             = "Timer",
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 58),
        Size             = UDim2.new(1, 0, 0, 2),
        Parent           = Card,
    })

    DrainTween(TimerBar, duration)

    -- Destroy after duration (instant, no slide out)
    task.delay(duration, function()
        if Wrapper and Wrapper.Parent then
            Wrapper:Destroy()
        end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- CreateWindow
-- ─────────────────────────────────────────────────────────────
function UILibrary:CreateWindow(cfg)
    cfg = cfg or {}
    local toggleKey   = cfg.key   or Enum.KeyCode.RightShift
    local accentColor = Colorways[cfg.theme] or Colorways.red
    local T           = BuildTheme(accentColor)

    local CoreGui = game:GetService("CoreGui")
    do local o = CoreGui:FindFirstChild("_index_") if o then o:Destroy() end end

    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
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

    -- ── _frame2: 620×380  at (5,5)  1px border ────────────────
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = T.Frame2_BG,
        BorderColor3     = T.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- ── __tabs: 608×45  at (6,8)  1px border ──────────────────
    --    outer bottom = 8+45 = 53
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

    -- ── __tabContent: 608×314  at (6,59)  1px border ──────────
    --    gap from tab bar: 59 - 53 = 6px ✓
    --    bottom: 59+314=373, frame2 inner=378, bottom gap=5px ✓
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = T.Content_BG,
        BorderColor3     = T.Content_Bdr,
        Position         = UDim2.new(0, 6, 0, 59),
        Size             = UDim2.new(0, 608, 0, 314),
        ClipsDescendants = true,
        Parent           = Frame2,
    })

    -- ── Dragging ───────────────────────────────────────────────
    -- All three handles move Frame1 (the root window frame).
    -- This lets the user grab the tab bar, the content area border,
    -- or the outer frame1 margin strip — all move the window.
    MakeDraggable(Frame1,  Frame1)
    MakeDraggable(Frame2,  Frame1)
    MakeDraggable(TabBar,  Frame1)

    -- ── Menu toggle key ────────────────────────────────────────
    UserInputService.InputBegan:Connect(function(inp, processed)
        if not processed and inp.KeyCode == toggleKey then
            Frame1.Visible = not Frame1.Visible
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

    function Window:SetVisible(v) self._frame.Visible = v end
    function Window:Destroy()    self._gui:Destroy()    end

    -- ─────────────────────────────────────────────────────────
    -- AddTab
    -- ─────────────────────────────────────────────────────────
    function Window:AddTab(name)
        local index = #self._tabs + 1

        -- Tab button: 151×45  BorderSizePixel=0
        -- 4×151 + 3×1 = 607px fits 608px tab bar ✓
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

        -- 2px accent bar at the bottom of the active tab button
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

        -- Per-tab ScrollingFrame: fills ContentArea inner (606×312)
        -- UIPadding 8px all sides → usable 590×296
        -- ScrollBarThickness=2 Y-only
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
            Name                  = "LeftCol",
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            Position              = UDim2.new(0, 0, 0, 0),
            Size                  = UDim2.new(0, 291, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            Parent                = Holder,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 10),
            Parent    = LeftCol,
        })

        -- Right column: 291×auto  x=299  right edge=590 ✓
        local RightCol = New("Frame", {
            Name                  = "RightCol",
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            Position              = UDim2.new(0, 299, 0, 0),
            Size                  = UDim2.new(0, 291, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            Parent                = Holder,
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
                t._page.Visible          = false
                t._btn.BackgroundColor3  = T.TabInactive_BG
                t._bar.Visible           = false
            end
            -- Activate this tab
            self._page.Visible          = true
            self._btn.BackgroundColor3  = T.TabActive_BG
            self._bar.Visible           = true
            self._window._activeTab     = self
        end

        Btn.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        -- Simple hover: lighten inactive bg
        Btn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                Btn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
            end
        end)
        Btn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                Btn.BackgroundColor3 = T.TabInactive_BG
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

            -- Count Frame children for LayoutOrder (skip UIListLayout)
            local order = 0
            for _, c in ipairs(Col:GetChildren()) do
                if c:IsA("Frame") then order += 1 end
            end

            local SectionFrame = New("Frame", {
                Name                  = "Sec_" .. sectionName,
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Size                  = UDim2.new(1, 0, 0, 0),
                AutomaticSize         = Enum.AutomaticSize.Y,
                LayoutOrder           = order,
                Parent                = Col,
            })

            -- Header: 291×20
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
                TextSize              = T.HdrSize,
                TextXAlignment        = Enum.TextXAlignment.Left,
                TextYAlignment        = Enum.TextYAlignment.Center,
                Parent                = Header,
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

            -- Body: starts at y=21, 5px top padding, 4px gap between elements
            local Body = New("Frame", {
                Name                  = "Body",
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Position              = UDim2.new(0, 0, 0, 21),
                Size                  = UDim2.new(1, 0, 0, 0),
                AutomaticSize         = Enum.AutomaticSize.Y,
                Parent                = SectionFrame,
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
                Row  291×26   BG transparent
                Box  14×14    pos x=4  y=6     4px left margin
                              (26-14)/2 = 6px vertical centre ✓
                              Border RGB(75,75,75)
                              BG: unchecked=RGB(30,30,30) checked=accent
                Lbl  pos x=24  Size(1,-24,1,0)
                              Font=Code FontSize=14   Left/Center
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
                    Parent                = Body,
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

                -- Label: x=24  full remaining width  Font=Code FontSize=14
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Position              = UDim2.new(0, 24, 0, 0),
                    Size                  = UDim2.new(1, -24, 1, 0),
                    Font                  = T.Font,
                    Text                  = label,
                    TextColor3            = T.Text,
                    TextSize              = T.FontSize,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    TextYAlignment        = Enum.TextYAlignment.Center,
                    Parent                = Row,
                })

                local function Apply(val, silent)
                    state                = val
                    Box.BackgroundColor3 = state and T.Checkbox_On or T.Checkbox_BG
                    if not silent then callback(state) end
                end

                Box.MouseButton1Click:Connect(function() Apply(not state, false) end)

                return {
                    Set = function(_, v) Apply(v, true)  end,
                    Get = function(_)    return state     end,
                }
            end

            -- ── AddDropdown ───────────────────────────────────
            --[[
                KEY DESIGN: Row has a FIXED explicit Size.Y.
                  Closed: Size.Y = 26
                  Open:   Size.Y = 26 + 1 + (#options × 22)
                            = header(26) + border_gap(1) + list(n×22)
                No AutomaticSize on Row — avoids the gap bug.
                No ClipsDescendants needed (no animation).
                List frame is simply Visible=true/false.

                Row          291×26(closed) or 291×(27+n×22)(open)
                DHeader      291×26   BG RGB(30,30,30)   Border RGB(75,75,75) 1px
                  SelLabel   pos x=6   Size(1,-26,1,0)
                             Font=Code FontSize=14   Left/Center   TextTruncate
                  Arrow      pos (1,-20,0,0)  Size(0,20,1,0)
                             "v"/"^"   Font=Code FontSize=12   Center   BG transparent
                List         pos y=27   Size(1,0,0,n×22)
                             BG RGB(22,22,22)   Border RGB(75,75,75) 1px
                             Visible=false when closed
                  Item[i]    pos y=(i-1)×22   Size(1,0,0,22)   BG RGB(22,22,22)
                    ItemBtn  full size   Font=Code FontSize=14   Left/Center
                             PaddingLeft=6   AutoButtonColor=false
                             TextColor3: T.Text normal, T.Dropdown_Sel if selected
            ]]
            function Section:AddDropdown(label, options, default, callback)
                options      = options  or {}
                callback     = callback or function() end
                local selected   = default or options[1] or ""
                local isOpen     = false
                elementCount    += 1

                local CLOSED_H  = 26
                local LIST_H    = #options * 22
                local OPEN_H    = CLOSED_H + 1 + LIST_H  -- 1px gap between header border and list

                -- Row: fixed height, NO AutomaticSize
                local Row = New("Frame", {
                    Name                  = "Dropdown_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Size                  = UDim2.new(1, 0, 0, CLOSED_H),
                    LayoutOrder           = elementCount,
                    ClipsDescendants      = true,   -- clip list when closed
                    Parent                = Body,
                })

                -- DHeader: full width of Row × 26px
                local DHeader = New("Frame", {
                    Name             = "DHeader",
                    BackgroundColor3 = T.Dropdown_BG,
                    BorderColor3     = T.Separator,
                    Size             = UDim2.new(1, 0, 0, 26),
                    Parent           = Row,
                })

                -- SelLabel: x=6  fills DHeader minus 20px arrow on right
                local SelLabel = New("TextLabel", {
                    Name                  = "SelLabel",
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
                    Parent                = DHeader,
                })

                -- Arrow: rightmost 20px of DHeader
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
                    Parent                = DHeader,
                })

                -- List: pos y=27  height=LIST_H  hidden when closed
                -- y=27 = 26(header outer) + 1(gap to clear header's bottom border)
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
                        Name                  = "Btn",
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
                        Parent                = Item,
                    })
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0, 6),
                        Parent      = ItemBtn,
                    })

                    itemRefs[opt] = ItemBtn

                    -- Hover: instant BG swap
                    Item.MouseEnter:Connect(function()
                        Item.BackgroundColor3 = T.Dropdown_Hover
                    end)
                    Item.MouseLeave:Connect(function()
                        Item.BackgroundColor3 = T.Dropdown_List
                    end)

                    -- Select
                    ItemBtn.MouseButton1Click:Connect(function()
                        -- Reset old selection colour
                        if itemRefs[selected] then
                            itemRefs[selected].TextColor3 = T.Text
                        end
                        selected              = opt
                        SelLabel.Text         = selected
                        ItemBtn.TextColor3    = T.Dropdown_Sel

                        -- Close dropdown
                        isOpen       = false
                        Arrow.Text   = "v"
                        List.Visible = false
                        Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)

                        callback(selected)
                    end)
                end

                -- Toggle open/close — instant, no animation
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

                -- Clicking the header row or arrow both toggle
                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggle()
                    end
                end)
                Arrow.MouseButton1Click:Connect(function()
                    Toggle()
                end)

                return {
                    Set = function(_, v)
                        if itemRefs[selected] then itemRefs[selected].TextColor3 = T.Text end
                        selected      = v
                        SelLabel.Text = v
                        if itemRefs[v] then itemRefs[v].TextColor3 = T.Dropdown_Sel end
                        -- Close if open
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
