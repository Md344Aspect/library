--[[
    UILibrary — CSGO-style  |  pixel-perfect against original dump
    ═══════════════════════════════════════════════════════════════════════

    LAYOUT TREE  (all px from parent inner rect unless noted)
    ══════════════════════════════════════════════════════════

    ScreenGui (_index_)   ZIndexBehavior=Sibling
    │
    └── _frame1           630 × 390   BorderSizePixel=0   centered via AnchorPoint
        │                 BG: RGB(29,29,29)
        │                 inner = 630 × 390  (no border)
        │
        └── _frame2       620 × 380   pos=(5,5) from _frame1 inner
            │             BG: RGB(16,16,16)   Border: RGB(75,75,75)  1px
            │             inner = 618 × 378
            │
            ├── __tabs    608 × 45    pos=(6,8) from _frame2 inner
            │   │         BG: RGB(16,16,16)   Border: RGB(75,75,75)  1px
            │   │         outer bottom = 8+45 = 53
            │   │
            │   ├── [tab buttons]   151×45 each   BorderSizePixel=0
            │   └── UIListLayout    Horizontal  Padding=1px
            │         4 tabs: 4×151+3×1 = 607px  fits 608px outer ✓
            │
            └── __tabContent   608 × 314   pos=(6,59) from _frame2 inner
                │         BG: RGB(16,16,16)   Border: RGB(75,75,75)  1px
                │         outer bottom = 59+314 = 373
                │         _frame2 inner height = 378 → bottom gap = 5px
                │         gap from tab bar: 59-53 = 6px ✓
                │         inner = 606 × 312
                │
                └── [per-tab ScrollingFrame]   Size(1,0,1,0)
                    │     fills 606×312 inner rect
                    │     BG transparent   BorderSizePixel=0
                    │     UIPadding: 8px all sides
                    │     usable = 590 × 296
                    │     ScrollBarThickness=2  ScrollingDirection=Y
                    │
                    └── ColumnHolder   Size(1,0, 0,0)  AutomaticSize=Y
                        │  width=590px   BG transparent
                        │
                        ├── LeftColumn    291×auto   pos x=0
                        │   UIListLayout  vertical   Padding=10px
                        │
                        └── RightColumn   291×auto   pos x=299
                            UIListLayout  vertical   Padding=10px
                            right edge = 299+291 = 590 ✓

    COLUMN MATH
    ───────────
      scrollframe inner width  = 606 - 16(pad) = 590px
      gap between cols         = 8px
      each col                 = (590 - 8) / 2 = 291px  ✓
      right col x              = 291 + 8 = 299px  ✓
      right col right edge     = 299 + 291 = 590px ✓

    SECTION (per col, 291px wide)
    ─────────────────────────────
      SectionFrame  291×auto  AutomaticSize=Y
      ├── Header    291×20    BG transparent
      │   ├── Title  TextLabel  full wdith  FontSize=11  RGB(180,180,180)
      │   └── Sep    Frame 291×1  y=19  BG RGB(75,75,75)  BorderSizePixel=0
      └── Body      291×auto  pos y=21  AutomaticSize=Y
          UIPadding PaddingTop=5px
          UIListLayout vertical  Padding=4px

    TOGGLE ROW (inside Body, 291px wide, 26px tall)
    ────────────────────────────────────────────────
      Row    291×26  BG transparent
      ├── Checkbox   14×14   pos x=0  y=6   (26-14)/2=6 centred ✓
      └── Label      x=20  w=271  h=26    (291-20=271)

    NOTIFICATION SYSTEM
    ───────────────────
      Separate ScreenGui ("_notifs_") always on top, ZIndex=10
      Container: anchored bottom-right of screen, stacks upward
        pos  = (1,-10, 1,-10)  AnchorPoint=(1,1)
        size = (0,300, 0,0)   AutomaticSize=Y
        UIListLayout vertical  VerticalAlignment=Bottom  Padding=6px

      Each notification card: 300×60
        BG: RGB(16,16,16)   Border: RGB(75,75,75)  1px
        ├── Accent bar   4×60  pos x=0  BG=type colour  BorderSizePixel=0
        ├── Title        x=12  y=8   w=230  h=18   FontSize=14  white
        ├── Message      x=12  y=28  w=230  h=24   FontSize=12  RGB(180,180,180)
        └── Timer bar    full width×2  pos y=58   BG=type colour  shrinks over duration

      Types & accent colours:
        "info"    → RGB(75,  75,  75)   grey
        "success" → RGB(50,  160, 80)   green
        "warning" → RGB(200, 150, 0)    yellow
        "error"   → RGB(125, 0,   4)    red  (matches theme accent)

      Lifecycle:
        1. Card slides in from right  (0.2s Linear)
        2. Timer bar tweens width 1→0 over `duration` seconds
        3. Card slides out to right   (0.2s Linear)  then Destroy

    ═══════════════════════════════════════════════════════════════════════

    USAGE
    ─────
      local UI = loadstring(...)()

      local Window = UI:CreateWindow({ key = Enum.KeyCode.RightShift })

      local Tab    = Window:AddTab("Legit")
      local Sect   = Tab:AddSection("Aimbot", "left")
      Sect:AddToggle("Enable", false, function(v) end)

      UI:Notify("Title", "This is a message", "success", 4)
      UI:Notify("Warning", "Be careful", "warning", 3)
      UI:Notify("Error", "Something broke", "error", 5)
      UI:Notify("Info", "Just so you know", "info", 3)
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ─────────────────────────────────────────────────────────────
-- Theme
-- ─────────────────────────────────────────────────────────────
local Theme = {
    Frame1_BG      = Color3.fromRGB(29,  29,  29),
    Frame2_BG      = Color3.fromRGB(16,  16,  16),
    Frame2_Bdr     = Color3.fromRGB(75,  75,  75),
    TabBar_BG      = Color3.fromRGB(16,  16,  16),
    TabBar_Bdr     = Color3.fromRGB(75,  75,  75),
    TabInactive_BG = Color3.fromRGB(30,  30,  30),
    TabActive_BG   = Color3.fromRGB(125,  0,   4),
    Content_BG     = Color3.fromRGB(16,  16,  16),
    Content_Bdr    = Color3.fromRGB(75,  75,  75),
    Separator      = Color3.fromRGB(75,  75,  75),
    SectionTitle   = Color3.fromRGB(180, 180, 180),
    Text           = Color3.fromRGB(255, 255, 255),
    SubText        = Color3.fromRGB(180, 180, 180),
    Checkbox_BG    = Color3.fromRGB(30,  30,  30),
    Checkbox_Bdr   = Color3.fromRGB(75,  75,  75),
    Checkbox_On    = Color3.fromRGB(125,  0,   4),
    Font           = Enum.Font.Nunito,
    FontSize       = 16,
    HeaderFontSize = 11,

    -- Notification accent colours by type
    Notif = {
        info    = Color3.fromRGB(75,  75,  75),
        success = Color3.fromRGB(50,  160, 80),
        warning = Color3.fromRGB(200, 150, 0),
        error   = Color3.fromRGB(125, 0,   4),
    },
}

-- ─────────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────────
local function Tween(obj, props, t, style)
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.12, style or Enum.EasingStyle.Linear),
        props
    ):Play()
end

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
-- Notification ScreenGui  (built once, shared across calls)
-- ─────────────────────────────────────────────────────────────
local NotifGui, NotifContainer

local function EnsureNotifGui()
    if NotifGui and NotifGui.Parent then return end

    local cg = game:GetService("CoreGui")
    local old = cg:FindFirstChild("_notifs_")
    if old then old:Destroy() end

    --[[
        Notification container
        ──────────────────────
        Anchored bottom-right with 10px margin.
        AnchorPoint(1,1) + Position(1,-10, 1,-10) puts the
        bottom-right corner 10px from the screen edge.
        AutomaticSize=Y grows upward as cards are added.
        UIListLayout VerticalAlignment=Bottom stacks new cards
        at the bottom, pushing older ones up.
    ]]
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
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        Padding             = UDim.new(0, 6),
        Parent              = NotifContainer,
    })
end

-- ─────────────────────────────────────────────────────────────
-- UILibrary:Notify
-- ─────────────────────────────────────────────────────────────
--[[
    Notification card  (300×60, flat)
    ───────────────────────────────────────────────────────────
    300 ─────────────────────────────────────────────
    │████│ Title                              │  ← y=0  h=60
    │ 4px│ Message text                       │
    │████│_________timer bar (2px at y=58)____|
    ─────────────────────────────────────────────────
    ^accent bar: 4×60  BorderSizePixel=0

    Title:   x=12  y=8   w=284  h=18  FontSize=14  white
    Message: x=12  y=28  w=284  h=24  FontSize=12  RGB(180,180,180)

    Timer bar: 300×2  y=58  BorderSizePixel=0
      starts at Size(1,0, 0,2) → tweens to Size(0,0, 0,2) over duration

    Slide in:  card starts at x=310 (off-screen right), tweens to x=0
    Slide out: tweens back to x=310, then Destroy

    LayoutOrder = os.clock()*1000 ensures newest card always sorts last
    (bottom of container = most recent, older ones above)
]]
function UILibrary:Notify(title, message, notifType, duration)
    EnsureNotifGui()

    notifType = notifType or "info"
    duration  = duration  or 3
    title     = title     or "Notification"
    message   = message   or ""

    local accent = Theme.Notif[notifType] or Theme.Notif.info

    -- LayoutOrder: monotonically increasing so newest = highest order = bottom
    local order = math.floor(os.clock() * 1000) % 2147483647

    --[[
        Card: 300×60
        Outer wrapper clips the slide animation cleanly.
        The actual card is positioned inside at x=310 initially,
        then slides to x=0. The wrapper is 300px wide so content
        outside is clipped and invisible.
    ]]
    local Wrapper = New("Frame", {
        Name                  = "Notif_" .. order,
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Size                  = UDim2.new(1, 0, 0, 60),
        LayoutOrder           = order,
        ClipsDescendants      = true,
        Parent                = NotifContainer,
    })

    -- Card body: starts off-screen right (x=310), slides to x=0
    local Card = New("Frame", {
        Name             = "Card",
        BackgroundColor3 = Theme.Frame2_BG,
        BorderColor3     = Theme.Content_Bdr,
        Position         = UDim2.new(0, 310, 0, 0),
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = Wrapper,
    })

    -- Accent bar: 4×60  full height  no border
    New("Frame", {
        Name             = "Accent",
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 0),
        Size             = UDim2.new(0, 4, 1, 0),
        Parent           = Card,
    })

    -- Title: x=12  y=8  w fills to right edge (minus right padding 8px)
    --        300 card - 4 accent - 12 left gap - 8 right pad = 276px
    New("TextLabel", {
        Name                  = "Title",
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Position              = UDim2.new(0, 12, 0, 8),
        Size                  = UDim2.new(1, -20, 0, 18),
        Font                  = Theme.Font,
        Text                  = title,
        TextColor3            = Theme.Text,
        TextSize              = 14,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextTruncate          = Enum.TextTruncate.AtEnd,
        Parent                = Card,
    })

    -- Message: x=12  y=28  same width rule
    New("TextLabel", {
        Name                  = "Message",
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Position              = UDim2.new(0, 12, 0, 28),
        Size                  = UDim2.new(1, -20, 0, 24),
        Font                  = Theme.Font,
        Text                  = message,
        TextColor3            = Theme.SubText,
        TextSize              = 12,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextWrapped           = true,
        Parent                = Card,
    })

    -- Timer bar: 300×2  at y=58 (last 2px of the 60px card)
    -- Starts full width, shrinks to 0 over `duration` seconds
    local TimerBar = New("Frame", {
        Name             = "Timer",
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 58),
        Size             = UDim2.new(1, 0, 0, 2),
        Parent           = Card,
    })

    -- ── Animate in: slide from x=310 → x=0  over 0.2s ──
    Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, 0.2)

    -- ── Timer bar drains over duration ──
    TweenService:Create(
        TimerBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { Size = UDim2.new(0, 0, 0, 2) }
    ):Play()

    -- ── Slide out and destroy after duration ──
    task.delay(duration, function()
        if not Card or not Card.Parent then return end
        -- Slide out to the right
        local t = TweenService:Create(
            Card,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear),
            { Position = UDim2.new(0, 310, 0, 0) }
        )
        t:Play()
        t.Completed:Connect(function()
            if Wrapper and Wrapper.Parent then
                Wrapper:Destroy()
            end
        end)
    end)
end

-- ─────────────────────────────────────────────────────────────
-- CreateWindow
-- ─────────────────────────────────────────────────────────────
function UILibrary:CreateWindow(cfg)
    cfg = cfg or {}
    local toggleKey = cfg.key or Enum.KeyCode.RightShift

    local CoreGui = game:GetService("CoreGui")
    do
        local old = CoreGui:FindFirstChild("_index_")
        if old then old:Destroy() end
    end

    -- ── ScreenGui ─────────────────────────────────────────────
    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        Parent         = CoreGui,
    })

    -- ── _frame1   630×390   no border   centered ──────────────
    local Frame1 = New("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = Theme.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 630, 0, 390),
        Parent           = Gui,
    })

    -- ── _frame2   620×380   at (5,5)   1px border ─────────────
    --    inner = 618 × 378
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = Theme.Frame2_BG,
        BorderColor3     = Theme.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- ── __tabs   608×45   at (6,8) in Frame2 inner ────────────
    --    outer bottom = 8+45 = 53
    local TabBar = New("Frame", {
        Name             = "__tabs",
        BackgroundColor3 = Theme.TabBar_BG,
        BorderColor3     = Theme.TabBar_Bdr,
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

    -- ── __tabContent   608×314   at (6,59) in Frame2 inner ────
    --    outer bottom = 59+314 = 373
    --    Frame2 inner height = 378 → bottom gap = 5px
    --    gap from tab bar: 59-53 = 6px ✓
    --    inner = 606 × 312
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = Theme.Content_BG,
        BorderColor3     = Theme.Content_Bdr,
        Position         = UDim2.new(0, 6, 0, 59),
        Size             = UDim2.new(0, 608, 0, 314),
        ClipsDescendants = true,
        Parent           = Frame2,
    })

    MakeDraggable(TabBar, Frame1)

    -- ── Menu visibility toggle ─────────────────────────────────
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
    }

    function Window:SetVisible(v) self._frame.Visible = v end
    function Window:Destroy()    self._gui:Destroy()    end

    -- ─────────────────────────────────────────────────────────
    -- AddTab
    -- ─────────────────────────────────────────────────────────
    function Window:AddTab(name)
        local index = #self._tabs + 1

        -- Tab button: 151×45   BorderSizePixel=0
        -- 4×151 + 3×1 = 607px fits 608px bar ✓
        local Btn = New("TextButton", {
            Name             = "__tabInactive",
            Font             = Theme.Font,
            Text             = name,
            TextColor3       = Theme.Text,
            TextSize         = Theme.FontSize,
            TextWrapped      = true,
            BackgroundColor3 = Theme.TabInactive_BG,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 151, 0, 45),
            LayoutOrder      = index,
            AutoButtonColor  = false,
            Parent           = self._tabBar,
        })

        -- ── Per-tab ScrollingFrame ─────────────────────────────
        --    Fills ContentArea inner rect (606×312).
        --    UIPadding 8px → usable = 590×296.
        --    ScrollBarThickness=2 overlaps right padding, no content lost.
        local Page = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            ScrollBarThickness     = 2,
            ScrollBarImageColor3   = Theme.TabActive_BG,
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

        -- ColumnHolder: full width (590px), grows in Y
        local Holder = New("Frame", {
            Name                  = "ColumnHolder",
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            Size                  = UDim2.new(1, 0, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            Parent                = Page,
        })

        -- Left column: 291px wide   x=0
        local LeftCol = New("Frame", {
            Name                  = "LeftColumn",
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

        -- Right column: 291px wide   x=299  (291+8=299)   right edge=590 ✓
        local RightCol = New("Frame", {
            Name                  = "RightColumn",
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

        -- ── Tab object ────────────────────────────────────────
        local Tab = {
            _btn      = Btn,
            _page     = Page,
            _leftCol  = LeftCol,
            _rightCol = RightCol,
            _window   = self,
        }

        function Tab:Select()
            for _, t in ipairs(self._window._tabs) do
                t._page.Visible = false
                Tween(t._btn, { BackgroundColor3 = Theme.TabInactive_BG }, 0.1)
            end
            self._page.Visible = true
            Tween(self._btn, { BackgroundColor3 = Theme.TabActive_BG }, 0.1)
            self._window._activeTab = self
        end

        Btn.MouseButton1Click:Connect(function() Tab:Select() end)

        Btn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                Tween(Btn, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }, 0.08)
            end
        end)
        Btn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                Tween(Btn, { BackgroundColor3 = Theme.TabInactive_BG }, 0.08)
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

            -- Count existing Frame children for stable LayoutOrder
            local sectionOrder = 0
            for _, c in ipairs(Col:GetChildren()) do
                if c:IsA("Frame") then sectionOrder += 1 end
            end

            -- SectionFrame: full column width, grows with content
            local SectionFrame = New("Frame", {
                Name                  = "Section_" .. sectionName,
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Size                  = UDim2.new(1, 0, 0, 0),
                AutomaticSize         = Enum.AutomaticSize.Y,
                LayoutOrder           = sectionOrder,
                Parent                = Col,
            })

            -- Header: 20px tall
            local Header = New("Frame", {
                Name                  = "Header",
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Size                  = UDim2.new(1, 0, 0, 20),
                Parent                = SectionFrame,
            })

            New("TextLabel", {
                Name                  = "Title",
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Size                  = UDim2.new(1, 0, 1, 0),
                Font                  = Theme.Font,
                Text                  = string.upper(sectionName),
                TextColor3            = Theme.SectionTitle,
                TextSize              = Theme.HeaderFontSize,
                TextXAlignment        = Enum.TextXAlignment.Left,
                TextYAlignment        = Enum.TextYAlignment.Center,
                Parent                = Header,
            })

            -- Separator: 1px line at y=19 (last pixel of header)
            New("Frame", {
                Name             = "Separator",
                BackgroundColor3 = Theme.Separator,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 0, 0, 19),
                Size             = UDim2.new(1, 0, 0, 1),
                Parent           = Header,
            })

            -- Body: starts at y=21, 5px top padding, elements stack 4px apart
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
            local Section = { _body = Body }

            -- ── AddToggle ─────────────────────────────────────
            --   Row: full width × 26px
            --   Checkbox: 14×14  at x=0  y=6   centred: (26-14)/2=6 ✓
            --   Label:    x=20   w=271   h=26   (col 291 - 20 = 271)
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

                local Box = New("TextButton", {
                    Name             = "Checkbox",
                    BackgroundColor3 = state and Theme.Checkbox_On or Theme.Checkbox_BG,
                    BorderColor3     = Theme.Checkbox_Bdr,
                    Position         = UDim2.new(0, 0, 0, 6),
                    Size             = UDim2.new(0, 14, 0, 14),
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = Row,
                })

                New("TextLabel", {
                    Name                  = "Label",
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Position              = UDim2.new(0, 20, 0, 0),
                    Size                  = UDim2.new(1, -20, 1, 0),
                    Font                  = Theme.Font,
                    Text                  = label,
                    TextColor3            = Theme.Text,
                    TextSize              = Theme.FontSize,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    TextYAlignment        = Enum.TextYAlignment.Center,
                    Parent                = Row,
                })

                local function Apply(val, silent)
                    state = val
                    Tween(Box, {
                        BackgroundColor3 = state and Theme.Checkbox_On or Theme.Checkbox_BG
                    }, 0.1)
                    if not silent then callback(state) end
                end

                Box.MouseButton1Click:Connect(function() Apply(not state) end)

                return {
                    Set = function(_, v) Apply(v, true) end,
                    Get = function(_)    return state    end,
                }
            end

            return Section
        end

        return Tab
    end

    return Window
end

return UILibrary
