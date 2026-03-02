--[[
    UILibrary — CSGO-style  |  Enum.Font.Code  |  pixel-perfect
    ═══════════════════════════════════════════════════════════════════════

    LAYOUT TREE  (all px relative to parent inner rect)
    ════════════════════════════════════════════════════

    ScreenGui (_index_)   ZIndexBehavior=Sibling
    └── _frame1           630×390   BorderSizePixel=0   AnchorPoint(0.5,0.5)
        │                 BG RGB(29,29,29)
        └── _frame2       620×380   pos=(5,5)   Border RGB(75,75,75) 1px
            │             inner = 618×378
            ├── __tabs    608×45    pos=(6,8)   Border RGB(75,75,75) 1px
            │   │         tab buttons 151×45 each  BorderSizePixel=0
            │   │         UIListLayout Horizontal Padding=1px
            │   │         4 tabs: 4×151+3×1=607px ✓
            │   │         tab text: Font=Code FontSize=14 TextXAlignment=Center
            └── __tabContent  608×314   pos=(6,59)   Border RGB(75,75,75) 1px
                │         inner=606×312
                │         gap from tab bar bottom (53) to content top (59) = 6px ✓
                │         bottom edge 59+314=373, Frame2 inner 378, gap=5px
                └── ScrollingFrame  Size(1,0,1,0)  BG transparent
                    │     UIPadding 8px all sides → usable = 590×296
                    │     ScrollBarThickness=2  ScrollingDirection=Y
                    └── ColumnHolder   Size(1,0,0,0)  AutomaticSize=Y
                        ├── LeftColumn   291×auto  x=0
                        │   UIListLayout vertical Padding=10px
                        └── RightColumn  291×auto  x=299  (291+8=299, edge=590✓)
                            UIListLayout vertical Padding=10px

    COLUMN MATH
    ───────────
      usable width  = 606(inner) - 16(pad) = 590px
      gap           = 8px
      each col      = (590-8)/2 = 291px ✓
      right col x   = 291+8 = 299px ✓

    SECTION (per col, 291px wide)
    ─────────────────────────────
      SectionFrame  291×auto  AutomaticSize=Y
      ├── Header    291×20    BG transparent
      │   ├── Title  TextLabel  full width  Font=Code  FontSize=11
      │   │          TextXAlignment=Left  TextYAlignment=Center
      │   │          Text=string.upper(name)  Color=RGB(180,180,180)
      │   └── Sep    Frame 291×1  y=19  BG RGB(75,75,75)  BorderSizePixel=0
      └── Body      291×auto  pos y=21  AutomaticSize=Y
          UIPadding PaddingTop=5px
          UIListLayout vertical Padding=4px

    TOGGLE ROW  (inside Body, 291×26)
    ──────────────────────────────────
      Row     291×26  BG transparent
      ├── Box  14×14  pos x=0  y=6  (26-14)/2=6 centred ✓
      │         Border RGB(75,75,75)  BG flips RGB(30,30,30)↔RGB(125,0,4)
      └── Lbl  x=20  w=271  h=26  Font=Code  FontSize=14
               TextXAlignment=Left  TextYAlignment=Center

    DROPDOWN ROW  (inside Body, 291px wide)
    ────────────────────────────────────────
      Wrapper     291×auto  AutomaticSize=Y  BG transparent
      ├── Header  291×26   BG RGB(30,30,30)  Border RGB(75,75,75) 1px
      │   ├── SelLabel  x=6  y=0  w=265  h=26  Font=Code  FontSize=14
      │   │             TextXAlignment=Left  TextYAlignment=Center
      │   │             Color=RGB(255,255,255)
      │   └── Arrow     x=271  y=0  w=20  h=26  TextButton  "v"/"^"
      │                 Font=Code  FontSize=12  BG transparent  no border
      │                 TextXAlignment=Center  TextYAlignment=Center
      └── List  291×(22×n)  pos y=27 (26 header + 1px border gap)
                BG RGB(22,22,22)  Border RGB(75,75,75) 1px
                Visible=false when closed
                Each item: Frame 291×22
                  ├── BG frame  full size  BG transparent initially
                  └── TextLabel x=6 y=0 w=285 h=22 Font=Code FontSize=14
                      TextXAlignment=Left TextYAlignment=Center
                      Color=RGB(255,255,255) normal, RGB(125,0,4) if selected

      Arrow text: "v" closed, "^" open  (Code font, monospace, clean)
      List item height=22px: (26+22)/2=24 avg, compact but readable in Code font
      Selected item label turns accent red RGB(125,0,4)
      Hover: item BG tweens to RGB(38,38,38)
      ZIndex of List = 3, other elements = 1 (renders on top within Body)

    NOTIFICATION CARD  (300×60, bottom-right, slides in from right)
    ────────────────────────────────────────────────────────────────
      Card BG RGB(16,16,16)  Border RGB(75,75,75) 1px  300×60
      ├── Accent bar   4×60  x=0  BG=type colour  BorderSizePixel=0
      ├── Title        x=12  y=8   w=(1,0,-20)  h=18  Font=Code FontSize=13
      ├── Message      x=12  y=28  w=(1,0,-20)  h=24  Font=Code FontSize=11
      └── Timer bar    x=0   y=58  w=(1,0,0)    h=2   BG=type colour
                       tweens Size.X.Scale 1→0 over duration seconds
      Slide in: x=310→0  0.2s Linear
      Slide out: x=0→310  0.2s Linear then Destroy

    ═══════════════════════════════════════════════════════════════════════

    USAGE
    ─────
      local UI = loadstring(...)()
      local Win = UI:CreateWindow({ key = Enum.KeyCode.RightShift })

      local Tab  = Win:AddTab("Legit")
      local Sect = Tab:AddSection("Aimbot", "left")

      Sect:AddToggle("Enable", false, function(v) end)
      Sect:AddDropdown("Bone", {"Head","Neck","Chest"}, "Head", function(v) end)

      UI:Notify("Title", "Message", "success", 3)
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
    Dropdown_BG    = Color3.fromRGB(30,  30,  30),
    Dropdown_List  = Color3.fromRGB(22,  22,  22),
    Dropdown_Hover = Color3.fromRGB(38,  38,  38),
    Dropdown_Sel   = Color3.fromRGB(125,  0,   4),
    Accent         = Color3.fromRGB(125,  0,   4),
    Font           = Enum.Font.Code,
    FontSize       = 14,
    HeaderFontSize = 11,
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
-- Notification ScreenGui  (lazy-init, module-level singleton)
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

    --[[
        Container: 300px wide, bottom-right corner, 10px margin.
        AutomaticSize=Y grows upward as cards are added.
        VerticalAlignment=Bottom keeps newest card at bottom,
        older cards stack above it.
    ]]
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
    Card: 300×60 flat box
    ┌─────────────────────────────────────────┐  y=0
    │████│ Title                         │    │  y=8  h=18  FontSize=13
    │ 4px│ message text                  │    │  y=28 h=24  FontSize=11
    │████│▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬│    │  y=58 h=2  timer bar
    └─────────────────────────────────────────┘  y=60

    Accent bar:  4×60 at x=0  BorderSizePixel=0  BG=type colour
    Title:       x=12  y=8   Size(1,0,-20, 0,18)  TextTruncate=AtEnd
    Message:     x=12  y=28  Size(1,0,-20, 0,24)  TextWrapped=true
    Timer bar:   x=0   y=58  Size(1,0, 0,  0, 2)  shrinks to Size(0,0,0,2)

    Slide in:  Card pos x=310→0  0.2s
    Slide out: Card pos x=0→310  0.2s then Wrapper:Destroy()
]]
function UILibrary:Notify(title, message, ntype, duration)
    EnsureNotifGui()
    ntype    = ntype    or "info"
    duration = duration or 3
    title    = title    or "Notification"
    message  = message  or ""

    local accent = Theme.Notif[ntype] or Theme.Notif.info
    local order  = math.floor(os.clock() * 1000) % 2147483647

    -- Wrapper clips the slide animation; card lives inside it
    local Wrapper = New("Frame", {
        Name                  = "Notif_" .. order,
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Size                  = UDim2.new(1, 0, 0, 60),
        LayoutOrder           = order,
        ClipsDescendants      = true,
        Parent                = NotifContainer,
    })

    local Card = New("Frame", {
        Name             = "Card",
        BackgroundColor3 = Theme.Frame2_BG,
        BorderColor3     = Theme.Content_Bdr,
        Position         = UDim2.new(0, 310, 0, 0),  -- off-screen right
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = Wrapper,
    })

    -- Accent bar: 4px wide, full height, no border
    New("Frame", {
        Name             = "Accent",
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 4, 1, 0),
        Parent           = Card,
    })

    -- Title: x=12  y=8  h=18  FontSize=13
    -- width: Size(1,0,-20,0,18) → card width minus 12px left + 8px right margin
    New("TextLabel", {
        Name                  = "Title",
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Position              = UDim2.new(0, 12, 0, 8),
        Size                  = UDim2.new(1, -20, 0, 18),
        Font                  = Theme.Font,
        Text                  = title,
        TextColor3            = Theme.Text,
        TextSize              = 13,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextYAlignment        = Enum.TextYAlignment.Center,
        TextTruncate          = Enum.TextTruncate.AtEnd,
        Parent                = Card,
    })

    -- Message: x=12  y=28  h=24  FontSize=11
    New("TextLabel", {
        Name                  = "Message",
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        Position              = UDim2.new(0, 12, 0, 28),
        Size                  = UDim2.new(1, -20, 0, 24),
        Font                  = Theme.Font,
        Text                  = message,
        TextColor3            = Theme.SubText,
        TextSize              = 11,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextYAlignment        = Enum.TextYAlignment.Top,
        TextWrapped           = true,
        Parent                = Card,
    })

    -- Timer bar: 2px tall at y=58, drains left over duration
    local TimerBar = New("Frame", {
        Name             = "Timer",
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 58),
        Size             = UDim2.new(1, 0, 0, 2),
        Parent           = Card,
    })

    -- Slide in
    Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, 0.2)

    -- Drain timer bar
    TweenService:Create(
        TimerBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { Size = UDim2.new(0, 0, 0, 2) }
    ):Play()

    -- Slide out then destroy
    task.delay(duration, function()
        if not Card or not Card.Parent then return end
        local t = TweenService:Create(
            Card,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear),
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
    local toggleKey = cfg.key or Enum.KeyCode.RightShift

    local CoreGui = game:GetService("CoreGui")
    do local o = CoreGui:FindFirstChild("_index_") if o then o:Destroy() end end

    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        Parent         = CoreGui,
    })

    -- _frame1: 630×390  no border  centered
    local Frame1 = New("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = Theme.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 630, 0, 390),
        Parent           = Gui,
    })

    -- _frame2: 620×380 at (5,5)  1px border  inner=618×378
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = Theme.Frame2_BG,
        BorderColor3     = Theme.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- __tabs: 608×45 at (6,8)  1px border  outer bottom=53
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

    -- __tabContent: 608×314 at (6,59)  1px border  inner=606×312
    -- gap from tab bar: 59-53=6px ✓   bottom edge: 59+314=373  Frame2 inner 378  gap=5px
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

        --[[
            Tab button: 151×45  BorderSizePixel=0
            4×151 + 3×1 = 607px  fits 608px bar ✓
            Font=Code  FontSize=14  TextXAlignment=Center  TextYAlignment=Center
        ]]
        local Btn = New("TextButton", {
            Name             = "__tabInactive",
            Font             = Theme.Font,
            Text             = name,
            TextColor3       = Theme.Text,
            TextSize         = Theme.FontSize,
            TextXAlignment   = Enum.TextXAlignment.Center,
            TextYAlignment   = Enum.TextYAlignment.Center,
            TextWrapped      = true,
            BackgroundColor3 = Theme.TabInactive_BG,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 151, 0, 45),
            LayoutOrder      = index,
            AutoButtonColor  = false,
            Parent           = self._tabBar,
        })

        --[[
            Per-tab ScrollingFrame: fills ContentArea inner (606×312)
            UIPadding 8px all sides → usable 590×296
            ScrollBarThickness=2  ScrollingDirection=Y
        ]]
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
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 10),
            Parent    = LeftCol,
        })

        -- Right column: 291×auto  x=299  right edge=299+291=590 ✓
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

            -- Header: 291×20
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
            -- Separator: 1px at y=19
            New("Frame", {
                Name             = "Separator",
                BackgroundColor3 = Theme.Separator,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 0, 0, 19),
                Size             = UDim2.new(1, 0, 0, 1),
                Parent           = Header,
            })

            -- Body: starts at y=21, PaddingTop=5, elements gap=4px
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
            --[[
                Row: 291×26  BG transparent
                Box: 14×14   pos x=0  y=6   (26-14)/2=6 centred ✓
                Lbl: x=20  w=271  h=26  Font=Code  FontSize=14
                     TextXAlignment=Left  TextYAlignment=Center
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

                -- Checkbox: 14×14, centred vertically: (26-14)/2=6
                local Box = New("TextButton", {
                    Name             = "Checkbox",
                    BackgroundColor3 = state and Theme.Checkbox_On or Theme.Checkbox_BG,
                    BorderColor3     = Theme.Checkbox_Bdr,
                    Position         = UDim2.new(0, 0, 0, 6),
                    Size             = UDim2.new(0, 14, 0, 14),
                    Text             = "",
                    AutoButtonColor  = false,
                    ZIndex           = 1,
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
                    ZIndex                = 1,
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

            -- ── AddDropdown ───────────────────────────────────
            --[[
                Wrapper: 291×auto  AutomaticSize=Y  BG transparent
                ├── DHeader: 291×26  BG RGB(30,30,30)  Border RGB(75,75,75) 1px
                │   ├── SelLabel: x=6  y=0  w=265  h=26  Font=Code  FontSize=14
                │   │             TextXAlignment=Left  TextYAlignment=Center
                │   └── Arrow:    x=271  y=0  w=20  h=26
                │                 TextButton  "v"/"^"  Font=Code  FontSize=12
                │                 BG transparent  BorderSizePixel=0
                │                 TextXAlignment=Center  TextYAlignment=Center
                └── List: 291×(22×n)  pos y=27  BG RGB(22,22,22)  Border RGB(75,75,75) 1px
                          Visible=false when closed  ZIndex=3
                    Each item: 291×22
                        ├── ItemBG: full size  BG transparent  BorderSizePixel=0  ZIndex=3
                        └── ItemLbl: x=6  y=0  w=285  h=22  Font=Code  FontSize=14
                                     TextXAlignment=Left  TextYAlignment=Center
                                     Color: white=normal  RGB(125,0,4)=selected

                DHeader pos x=0 y=0 inside Wrapper (no offset needed, Wrapper BG is transparent)
                List pos y=27 = 26(header outer height) + 1(gap to clear header border)

                Arrow text: "v" closed  "^" open
                  x=271: 291(col) - 20(arrow width) = 271  ✓
                  w=20: arrow column width
                  Both label and arrow sit inside DHeader (291×26 with 1px border → inner 289×24)
                  SelLabel width: 291 - 6(left pad) - 20(arrow) - 6(right pad) = 259
                    → use Size(1,-26, 1,0) relative to DHeader inner: 289-26=263... 
                    → simpler: absolute x=6  Size(0,259, 1,0)
                  Arrow: x=265  w=20  (6+259+6=271... let's use x=265 w=24 for slight overlap safety)
                    Actually: 291 outer, 1px border each side → inner=289
                    SelLabel: pos x=6 in inner → absolute from DHeader left edge = 7px
                    Arrow: right-aligned, 20px wide → x from inner right = 20+6(pad) = 26 → x=289-20=269 in inner
                    → pos x=269  w=20  (269+20=289=inner width ✓)
                    SelLabel w: 269-6-6=257 (6px left pad, 6px gap before arrow)
                    → SelLabel: x=6  Size(0,257, 1,0)

                Item height: 22px
                  List height = n×22 (no gap, items are flush)
                  Each item ZIndex=3 so it renders above subsequent Body elements
            ]]
            function Section:AddDropdown(label, options, default, callback)
                options  = options  or {}
                callback = callback or function() end
                local selected = default or options[1] or ""
                local isOpen   = false
                elementCount  += 1

                -- Wrapper: transparent, grows to fit header + list when open
                local Wrapper = New("Frame", {
                    Name                  = "Dropdown_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Size                  = UDim2.new(1, 0, 0, 0),
                    AutomaticSize         = Enum.AutomaticSize.Y,
                    LayoutOrder           = elementCount,
                    ZIndex                = 2,
                    Parent                = Body,
                })

                -- DHeader: 291×26 (outer). Border adds 1px each side → inner=289×24
                local DHeader = New("Frame", {
                    Name             = "DHeader",
                    BackgroundColor3 = Theme.Dropdown_BG,
                    BorderColor3     = Theme.Separator,
                    Size             = UDim2.new(1, 0, 0, 26),
                    ZIndex           = 2,
                    Parent           = Wrapper,
                })

                --[[
                    Inside DHeader inner rect (289×24):
                    SelLabel: x=6  y=0  w=257  h=24(full)
                    Arrow:    x=269  y=0  w=20  h=24(full)
                    6 + 257 + 6(gap) + 20 = 289 ✓
                ]]
                local SelLabel = New("TextLabel", {
                    Name                  = "Selected",
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Position              = UDim2.new(0, 6, 0, 0),
                    Size                  = UDim2.new(1, -26, 1, 0),
                    Font                  = Theme.Font,
                    Text                  = selected,
                    TextColor3            = Theme.Text,
                    TextSize              = Theme.FontSize,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    TextYAlignment        = Enum.TextYAlignment.Center,
                    TextTruncate          = Enum.TextTruncate.AtEnd,
                    ZIndex                = 2,
                    Parent                = DHeader,
                })

                -- Arrow: rightmost 20px of DHeader inner, centred vertically
                local Arrow = New("TextButton", {
                    Name                  = "Arrow",
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Position              = UDim2.new(1, -20, 0, 0),
                    Size                  = UDim2.new(0, 20, 1, 0),
                    Font                  = Theme.Font,
                    Text                  = "v",
                    TextColor3            = Theme.SubText,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Center,
                    TextYAlignment        = Enum.TextYAlignment.Center,
                    AutoButtonColor       = false,
                    ZIndex                = 2,
                    Parent                = DHeader,
                })

                --[[
                    List: sits at y=27 inside Wrapper (26px header + 1px gap).
                    Height = #options × 22px.
                    BG RGB(22,22,22)  Border RGB(75,75,75) 1px  ZIndex=3
                    Starts hidden.
                ]]
                local listHeight = #options * 22
                local List = New("Frame", {
                    Name             = "List",
                    BackgroundColor3 = Theme.Dropdown_List,
                    BorderColor3     = Theme.Separator,
                    Position         = UDim2.new(0, 0, 0, 27),
                    Size             = UDim2.new(1, 0, 0, listHeight),
                    Visible          = false,
                    ZIndex           = 3,
                    Parent           = Wrapper,
                })

                -- Build list items
                local itemRefs = {}
                for i, opt in ipairs(options) do
                    --[[
                        Item frame: full width × 22px  BG transparent  ZIndex=3
                        ItemLabel: x=6  y=0  w=full  h=22
                                   Color=white normally, accent if selected
                    ]]
                    local Item = New("Frame", {
                        Name             = "Item_" .. opt,
                        BackgroundColor3 = Theme.Dropdown_List,
                        BorderSizePixel  = 0,
                        Position         = UDim2.new(0, 0, 0, (i-1)*22),
                        Size             = UDim2.new(1, 0, 0, 22),
                        ZIndex           = 3,
                        Parent           = List,
                    })

                    local ItemLbl = New("TextButton", {
                        Name                  = "Label",
                        BackgroundTransparency = 1,
                        BorderSizePixel       = 0,
                        Size                  = UDim2.new(1, 0, 1, 0),
                        Font                  = Theme.Font,
                        Text                  = opt,
                        TextColor3            = (opt == selected) and Theme.Dropdown_Sel or Theme.Text,
                        TextSize              = Theme.FontSize,
                        TextXAlignment        = Enum.TextXAlignment.Left,
                        TextYAlignment        = Enum.TextYAlignment.Center,
                        AutoButtonColor       = false,
                        ZIndex                = 3,
                        Parent                = Item,
                    })

                    -- left padding on label text via UIPadding
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0, 6),
                        Parent      = ItemLbl,
                    })

                    itemRefs[opt] = ItemLbl

                    -- Hover
                    Item.MouseEnter:Connect(function()
                        Tween(Item, { BackgroundColor3 = Theme.Dropdown_Hover }, 0.08)
                    end)
                    Item.MouseLeave:Connect(function()
                        Tween(Item, { BackgroundColor3 = Theme.Dropdown_List }, 0.08)
                    end)

                    -- Select
                    ItemLbl.MouseButton1Click:Connect(function()
                        -- Reset previous selection colour
                        if itemRefs[selected] then
                            itemRefs[selected].TextColor3 = Theme.Text
                        end
                        selected = opt
                        SelLabel.Text = selected
                        ItemLbl.TextColor3 = Theme.Dropdown_Sel

                        -- Close
                        isOpen = false
                        List.Visible = false
                        Arrow.Text   = "v"

                        callback(selected)
                    end)
                end

                -- Toggle open/close on header or arrow click
                local function ToggleList()
                    isOpen = not isOpen
                    List.Visible = isOpen
                    Arrow.Text   = isOpen and "^" or "v"
                end

                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        ToggleList()
                    end
                end)
                Arrow.MouseButton1Click:Connect(ToggleList)

                return {
                    Set = function(_, v)
                        if itemRefs[selected] then itemRefs[selected].TextColor3 = Theme.Text end
                        selected = v
                        SelLabel.Text = v
                        if itemRefs[v] then itemRefs[v].TextColor3 = Theme.Dropdown_Sel end
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
