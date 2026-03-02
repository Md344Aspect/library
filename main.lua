--[[
    UILibrary — CSGO-style, pixel-perfect
    ════════════════════════════════════════════════════════════════

    Full layout tree (all values in pixels, origin top-left):

    ScreenGui (_index_)
    └── _frame1          630 × 390   no border     [screen center]
        └── _frame2      620 × 380   at (5, 5)     border RGB(75,75,75)
            ├── __tabs   608 × 45    at (6, 8)     border RGB(75,75,75)
            │   └── tab buttons  151 × 45  each, 1px gap, BorderSizePixel=0
            └── __tabContent  608 × 314  at (6, 59) border RGB(75,75,75)
                └── per-tab ScrollingFrame  608 × 314
                    └── UIPadding 8px all sides → inner = 592 × 298
                        └── column holder Frame  592 × auto
                            ├── Left column   292 × auto  (sections stack here)
                            └── Right column  292 × auto  (sections stack here)
                                └── Section
                                    ├── Header row  292 × 20
                                    │   ├── TextLabel  "SECTION NAME"
                                    │   └── separator  292 × 1  at y=19
                                    └── Body Frame  292 × auto  (elements stack, 4px gap)
                                        └── Toggle row  292 × 26
                                            ├── Checkbox  14 × 14  at (0, 6)
                                            └── Label     258 × 26 at (20, 0)

    Column math:
        inner width          = 592
        gap between columns  = 8
        each column          = (592 - 8) / 2 = 292  ✓

    Section header height    = 20px
    Separator                = 1px line at bottom of header
    Element row height       = 26px
    Element gap              = 4px
    Checkbox size            = 14 × 14, centred in 26px row → y offset = (26-14)/2 = 6
    Label x offset           = 14 + 6 = 20px

    Menu toggle key          = configurable, default RightShift
    ════════════════════════════════════════════════════════════════

    Usage:
        local UI = loadstring(...)()

        local Window = UI:CreateWindow({
            key = Enum.KeyCode.RightShift,   -- optional, default RightShift
        })

        local Tab = Window:AddTab("Legit")

        local Aimbot = Tab:AddSection("Aimbot", "left")
        Aimbot:AddToggle("Enable", false, function(v) end)
        Aimbot:AddToggle("Silent Aim", false, function(v) end)

        local Visuals = Tab:AddSection("Visuals", "right")
        Visuals:AddToggle("ESP", true, function(v) end)
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
    Section_Bdr    = Color3.fromRGB(75,  75,  75),
    Section_Header = Color3.fromRGB(180, 180, 180),
    Text           = Color3.fromRGB(255, 255, 255),
    Checkbox_BG    = Color3.fromRGB(30,  30,  30),
    Checkbox_Bdr   = Color3.fromRGB(75,  75,  75),
    Checkbox_Check = Color3.fromRGB(125,  0,   4),
    Font           = Enum.Font.Nunito,
    FontSize       = 16,
    HeaderFontSize = 11,
}

-- ─────────────────────────────────────────────────────────────
-- Utility
-- ─────────────────────────────────────────────────────────────
local function Tween(obj, props, t)
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.12, Enum.EasingStyle.Linear),
        props
    ):Play()
end

local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        o[k] = v
    end
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
-- Window
-- ─────────────────────────────────────────────────────────────
function UILibrary:CreateWindow(cfg)
    cfg = cfg or {}
    local toggleKey = cfg.key or Enum.KeyCode.RightShift

    local CoreGui = game:GetService("CoreGui")
    local old = CoreGui:FindFirstChild("_index_")
    if old then old:Destroy() end

    -- ── ScreenGui ─────────────────────────────────────────────
    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        Parent         = CoreGui,
    })

    -- ── _frame1  630×390, centered, no border ─────────────────
    local Frame1 = New("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = Theme.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 630, 0, 390),
        Parent           = Gui,
    })

    -- ── _frame2  620×380 at (5,5) ─────────────────────────────
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = Theme.Frame2_BG,
        BorderColor3     = Theme.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- ── __tabs  608×45 at (6,8) ───────────────────────────────
    --    bottom edge = 8+45 = 53
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

    -- ── __tabContent  608×314 at (6,59) ──────────────────────
    --    gap: 59 - 53 = 6px between tab bar bottom and content top  ✓
    --    bottom edge: 59+314 = 373, frame2 height=380 → 7px bottom gap  ✓
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

    -- ── Menu toggle key ───────────────────────────────────────
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

    function Window:SetVisible(v)
        self._frame.Visible = v
    end

    function Window:Destroy()
        self._gui:Destroy()
    end

    -- ── AddTab ────────────────────────────────────────────────
    function Window:AddTab(name)
        local index = #self._tabs + 1

        -- button: 151×45, no border
        -- 4 buttons × 151 + 3 gaps × 1 = 607px ← fits 608px bar  ✓
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

        --[[
            Per-tab ScrollingFrame: 608×314 (fills ContentArea exactly)
            UIPadding 8px all sides → inner usable = 592×298

            Inside: a horizontal holder frame that contains two column frames.
                Holder:        592px wide, AutomaticSize Y
                Left column:   292px wide, AutomaticSize Y
                Right column:  292px wide, AutomaticSize Y
                Gap:           8px  (592 - 292 - 292 = 8, split as 8px offset on right col)

            Columns use UIListLayout (vertical) to stack sections.
            Sections use UIListLayout (vertical) to stack elements.
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

        -- Holder: 592px wide, grows vertically with content
        -- Position (0,0) — padding above handles the 8px inset
        local Holder = New("Frame", {
            Name                = "ColumnHolder",
            BackgroundTransparency = 1,
            BorderSizePixel     = 0,
            Size                = UDim2.new(1, 0, 0, 0),
            AutomaticSize       = Enum.AutomaticSize.Y,
            Parent              = Page,
        })

        -- Left column: 292px wide, grows with content, at x=0
        local LeftCol = New("Frame", {
            Name              = "LeftColumn",
            BackgroundTransparency = 1,
            BorderSizePixel   = 0,
            Position          = UDim2.new(0, 0, 0, 0),
            Size              = UDim2.new(0, 292, 0, 0),
            AutomaticSize     = Enum.AutomaticSize.Y,
            Parent            = Holder,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 10),  -- gap between sections within a column
            Parent    = LeftCol,
        })

        -- Right column: 292px wide, at x = 292+8 = 300
        local RightCol = New("Frame", {
            Name              = "RightColumn",
            BackgroundTransparency = 1,
            BorderSizePixel   = 0,
            Position          = UDim2.new(0, 300, 0, 0),
            Size              = UDim2.new(0, 292, 0, 0),
            AutomaticSize     = Enum.AutomaticSize.Y,
            Parent            = Holder,
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

        -- ── AddSection ────────────────────────────────────────
        --[[
            Section layout inside its column (292px wide):

            ┌──────────────────────────────────────────┐  ← SectionFrame (292×auto)
            │ SECTION NAME                             │  ← Header 292×20
            ├──────────────────────────────────────────┤  ← 1px separator
            │ ☐  Toggle label                          │  ← element row 26px
            │ ☐  Toggle label                          │
            └──────────────────────────────────────────┘

            Header:
                TextLabel  292×20, uppercase-ish small text RGB(180,180,180)
                Separator  Frame 292×1 at y=19, RGB(75,75,75)

            Body (elements):
                UIListLayout vertical, 4px gap
                UIPadding: top=6px (breathing room after separator)

            Element row (toggle):
                Height    = 26px
                Width     = 292px (full section width)
                Checkbox  = 14×14 at x=0, y=(26-14)/2=6  → centred vertically
                Label     = x=20, y=0, w=272, h=26
        ]]
        function Tab:AddSection(sectionName, side)
            side = (side == "right") and "right" or "left"
            local parentCol = (side == "right") and self._rightCol or self._leftCol
            local sectionIndex = #parentCol:GetChildren()

            -- Outer section frame, 292px wide, grows with content
            local SectionFrame = New("Frame", {
                Name              = "Section_" .. sectionName,
                BackgroundTransparency = 1,
                BorderSizePixel   = 0,
                Size              = UDim2.new(1, 0, 0, 0),
                AutomaticSize     = Enum.AutomaticSize.Y,
                LayoutOrder       = sectionIndex,
                Parent            = parentCol,
            })

            -- Header: 292×20
            local Header = New("Frame", {
                Name             = "Header",
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 20),
                Parent           = SectionFrame,
            })

            New("TextLabel", {
                Name                  = "Title",
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                Size                  = UDim2.new(1, 0, 1, 0),
                Font                  = Theme.Font,
                Text                  = string.upper(sectionName),
                TextColor3            = Theme.Section_Header,
                TextSize              = Theme.HeaderFontSize,
                TextXAlignment        = Enum.TextXAlignment.Left,
                TextYAlignment        = Enum.TextYAlignment.Center,
                Parent                = Header,
            })

            -- Separator: 1px line at y=19 (bottom of header), full width
            New("Frame", {
                Name             = "Separator",
                BackgroundColor3 = Theme.Section_Bdr,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 0, 0, 19),
                Size             = UDim2.new(1, 0, 0, 1),
                Parent           = Header,
            })

            -- Body: stacks elements, grows with content
            --       top padding = 6px (space after separator)
            local Body = New("Frame", {
                Name              = "Body",
                BackgroundTransparency = 1,
                BorderSizePixel   = 0,
                Position          = UDim2.new(0, 0, 0, 20),
                Size              = UDim2.new(1, 0, 0, 0),
                AutomaticSize     = Enum.AutomaticSize.Y,
                Parent            = SectionFrame,
            })

            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 4),
                Parent    = Body,
            })

            New("UIPadding", {
                PaddingTop = UDim.new(0, 6),
                Parent     = Body,
            })

            -- ── Section object ────────────────────────────────
            local Section = { _body = Body }

            --[[
                AddToggle — CSGO checkbox

                Row: 292×26  (full section width, 26px tall)
                Checkbox: TextButton 14×14
                    Position x=0, y=(26-14)/2=6
                    BackgroundColor3: unchecked=RGB(30,30,30) checked=RGB(125,0,4)
                    BorderColor3: RGB(75,75,75)
                Label: TextLabel x=20, y=0, w=272, h=26
            ]]
            function Section:AddToggle(label, default, callback)
                default  = (default == true)
                callback = callback or function() end
                local state = default

                local Row = New("Frame", {
                    Name                  = "Toggle_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Size                  = UDim2.new(1, 0, 0, 26),
                    LayoutOrder           = #Body:GetChildren(),
                    Parent                = Body,
                })

                -- Checkbox: 14×14, vertically centred: (26-14)/2 = 6px top offset
                local Box = New("TextButton", {
                    Name             = "Checkbox",
                    BackgroundColor3 = state and Theme.Checkbox_Check or Theme.Checkbox_BG,
                    BorderColor3     = Theme.Checkbox_Bdr,
                    Position         = UDim2.new(0, 0, 0, 6),
                    Size             = UDim2.new(0, 14, 0, 14),
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = Row,
                })

                -- Label: x=20 (14px box + 6px gap), full remaining width
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
                        BackgroundColor3 = state and Theme.Checkbox_Check or Theme.Checkbox_BG
                    }, 0.1)
                    if not silent then callback(state) end
                end

                Box.MouseButton1Click:Connect(function() Apply(not state) end)

                return {
                    Set = function(_, v) Apply(v, true) end,
                    Get = function(_) return state end,
                }
            end

            return Section
        end

        return Tab
    end

    return Window
end

return UILibrary
