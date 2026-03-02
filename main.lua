--[[
    UILibrary — CSGO-style, pixel-perfect audit v2
    ════════════════════════════════════════════════════════════════════

    FULL PIXEL LAYOUT TREE
    ══════════════════════
    All measurements verified. Origin = top-left of each parent.
    Roblox default BorderSizePixel = 1 when BorderColor3 is set.
    Frame2 / TabBar / ContentArea carry their own 1px border —
    children position relative to the inner content rect automatically.

    ScreenGui (_index_)
    └── _frame1         630 × 390   BorderSizePixel=0   AnchorPoint(0.5,0.5)
        │               BackgroundColor3 RGB(29,29,29)
        │               inner content rect = 630 × 390  (no border)
        │
        └── _frame2     620 × 380   at (5, 5)
            │           BackgroundColor3 RGB(16,16,16)
            │           BorderColor3 RGB(75,75,75)  BorderSizePixel=1 (default)
            │           inner content rect = 618 × 378
            │           children are positioned within this inner rect
            │
            ├── __tabs          608 × 45    at (5, 7) inside Frame2 inner
            │   │               BackgroundColor3 RGB(16,16,16)
            │   │               BorderColor3 RGB(75,75,75)  BorderSizePixel=1
            │   │               inner rect = 606 × 43
            │   │               bottom edge (outer) = 7+45 = 52
            │   │
            │   └── tab buttons     151 × 45 each  BorderSizePixel=0
            │       UIListLayout    Horizontal  Padding=1px
            │       4 tabs: 4×151 + 3×1 = 607px ← fits 608px outer / 606px inner
            │       (buttons overflow 1px into border — fine, BorderSizePixel=0 on btn)
            │
            └── __tabContent    608 × 312   at (5, 58) inside Frame2 inner
                │               BackgroundColor3 RGB(16,16,16)
                │               BorderColor3 RGB(75,75,75)  BorderSizePixel=1
                │               bottom edge (outer) = 58+312 = 370
                │               Frame2 inner height = 378 → bottom gap = 8px ✓
                │               Gap from tab bar bottom to content top:
                │                 Tab bar outer bottom = 7+45 = 52
                │                 Content outer top    = 58
                │                 Gap                  = 58-52 = 6px ✓
                │
                └── per-tab ScrollingFrame    fills ContentArea exactly 1:1
                    │   Size UDim2(1,0,1,0)  BackgroundTransparency=1
                    │   UIPadding 8px all sides
                    │   inner usable = (608-2-16) × (312-2-16) = 590 × 294
                    │   (subtracting 1px border each side + 8px padding each side)
                    │   ScrollBarThickness=2  right-side → eats 2px from right
                    │   effective draw width  = 590 - 2 = 588px  (scrollbar overlap)
                    │
                    └── ColumnHolder    Size(1,0, 0,0)  AutomaticSize=Y
                        │   BackgroundTransparency=1   no border
                        │   width = 590px (padding-adjusted, scrollbar sits outside)
                        │
                        ├── LeftColumn      291 × auto   at x=0
                        │   UIListLayout vertical  Padding=10px between sections
                        │
                        └── RightColumn     291 × auto   at x=299
                            UIListLayout vertical  Padding=10px between sections
                            Right edge: 299+291 = 590 ✓  fills exactly

    COLUMN MATH (verified):
        Inner usable width after padding   = 590px
        Scrollbar thickness                = 2px  (overlaps, doesn't shrink content)
        Gap between columns                = 8px
        Each column                        = (590 - 8) / 2 = 291px  ✓
        Right column x                     = 291 + 8 = 299px  ✓
        Right col right edge               = 299 + 291 = 590px ✓

    SECTION LAYOUT (per column, 291px wide):
        SectionFrame    291 × auto     AutomaticSize=Y
        ├── Header      291 × 20       BackgroundTransparency=1
        │   ├── Title   TextLabel  full width, FontSize=11, RGB(180,180,180)
        │   └── Sep     Frame 291×1  at y=19  RGB(75,75,75)  BorderSizePixel=0
        └── Body        291 × auto    at y=21 (20 header + 1 sep)
            UIPadding PaddingTop=5px
            UIListLayout vertical Padding=4px

    TOGGLE ROW (per element, inside Body, 291px wide):
        Row         291 × 26    BackgroundTransparency=1
        ├── Box     14 × 14     at x=0, y=6   (26-14)/2=6 → vertically centred ✓
        └── Label   x=20, w=271, h=26  TextXAlignment=Left  TextYAlignment=Center

    MENU TOGGLE:
        UserInputService.InputBegan  key=cfg.key (default RightShift)
        Toggles Frame1.Visible — hides/shows entire GUI

    ════════════════════════════════════════════════════════════════════

    USAGE:
        local UI = loadstring(...)()
        local Window = UI:CreateWindow({ key = Enum.KeyCode.RightShift })

        local Tab     = Window:AddTab("Legit")
        local Aimbot  = Tab:AddSection("Aimbot",  "left")
        local AntiAim = Tab:AddSection("Anti-Aim","right")

        Aimbot:AddToggle("Enable", false, function(v) end)
        AntiAim:AddToggle("Enable", false, function(v) end)
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ─────────────────────────────────────────────────────────────
-- Theme  (all RGB values from original dump)
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
    Checkbox_BG    = Color3.fromRGB(30,  30,  30),
    Checkbox_Bdr   = Color3.fromRGB(75,  75,  75),
    Checkbox_On    = Color3.fromRGB(125,  0,   4),
    Font           = Enum.Font.Code,
    FontSize       = 16,
    HeaderFontSize = 11,
}

-- ─────────────────────────────────────────────────────────────
-- Helpers
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
-- CreateWindow
-- ─────────────────────────────────────────────────────────────
function UILibrary:CreateWindow(cfg)
    cfg = cfg or {}
    local toggleKey = cfg.key or Enum.KeyCode.RightShift

    local CoreGui = game:GetService("CoreGui")
    do local old = CoreGui:FindFirstChild("_index_") if old then old:Destroy() end end

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
    --    inner rect = 618×378
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = Theme.Frame2_BG,
        BorderColor3     = Theme.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- ── __tabs   608×45   at (5,7) in Frame2 inner ────────────
    --    outer bottom edge = 7+45 = 52
    --    1px border → inner = 606×43
    local TabBar = New("Frame", {
        Name             = "__tabs",
        BackgroundColor3 = Theme.TabBar_BG,
        BorderColor3     = Theme.TabBar_Bdr,
        Position         = UDim2.new(0, 5, 0, 7),
        Size             = UDim2.new(0, 608, 0, 45),
        Parent           = Frame2,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, 1),
        Parent        = TabBar,
    })

    -- ── __tabContent   608×312   at (5,58) in Frame2 inner ────
    --    gap from tab bar bottom: 58-52 = 6px ✓
    --    outer bottom edge: 58+312 = 370
    --    Frame2 inner height: 378 → bottom gap: 8px ✓
    --    1px border → inner = 606×310
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = Theme.Content_BG,
        BorderColor3     = Theme.Content_Bdr,
        Position         = UDim2.new(0, 5, 0, 58),
        Size             = UDim2.new(0, 608, 0, 312),
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
        -- 4 tabs × 151 + 3 gaps × 1 = 607px — fits 608px bar ✓
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
        -- Fills ContentArea inner rect (606×310 accounting for 1px border).
        -- Size(1,0,1,0) = relative fill → Roblox clips to ContentArea bounds.
        -- UIPadding 8px all sides:
        --   usable width  = 606 - 16 = 590px
        --   usable height = 310 - 16 = 294px
        -- ScrollBarThickness=2, sits on right side inside padding area.
        -- Content draw width = 590px (scrollbar overlaps padding, not content).
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

        -- ── ColumnHolder ──────────────────────────────────────
        -- Direct child of Page. Width = 1,0 (590px after padding).
        -- AutomaticSize=Y → grows to fit the taller of the two columns.
        -- No layout manager — columns are manually positioned.
        local Holder = New("Frame", {
            Name                  = "ColumnHolder",
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            Size                  = UDim2.new(1, 0, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            Parent                = Page,
        })

        -- ── Left column   291×auto   x=0 ─────────────────────
        -- (590 - 8) / 2 = 291px each column
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

        -- ── Right column   291×auto   x=299 ──────────────────
        -- x = 291 + 8 = 299    right edge = 299+291 = 590 ✓
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
        --[[
            Section inside a column (291px wide):

            SectionFrame   291×auto   AutomaticSize=Y
            ├── Header     291×20     BackgroundTransparency=1
            │   ├── Title  TextLabel  full width  FontSize=11  RGB(180,180,180)
            │   └── Sep    Frame 291×1  y=19  BorderSizePixel=0  RGB(75,75,75)
            └── Body       291×auto   at y=21 (20px header + 1px sep)
                UIPadding PaddingTop=5
                UIListLayout vertical Padding=4px

            Header sits from y=0 to y=20.
            Separator at y=19 is the last pixel of the header (1px thick).
            Body starts at y=21, padded 5px top → first element at y=26.
        ]]
        function Tab:AddSection(sectionName, side)
            side = (side == "right") and "right" or "left"
            local Col = (side == "right") and self._rightCol or self._leftCol

            -- Dedicated section counter using a stable LayoutOrder
            local sectionOrder = 0
            for _, c in ipairs(Col:GetChildren()) do
                if c:IsA("Frame") then
                    sectionOrder = sectionOrder + 1
                end
            end

            local SectionFrame = New("Frame", {
                Name              = "Section_" .. sectionName,
                BackgroundTransparency = 1,
                BorderSizePixel   = 0,
                Size              = UDim2.new(1, 0, 0, 0),
                AutomaticSize     = Enum.AutomaticSize.Y,
                LayoutOrder       = sectionOrder,
                Parent            = Col,
            })

            -- Header 291×20
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

            -- Separator: 1px, at y=19 (last pixel of the 20px header)
            New("Frame", {
                Name             = "Separator",
                BackgroundColor3 = Theme.Separator,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 0, 0, 19),
                Size             = UDim2.new(1, 0, 0, 1),
                Parent           = Header,
            })

            -- Body: starts at y=21 (clears header + separator)
            -- PaddingTop=5 → first element sits 5px below separator
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

            -- ── Section object ────────────────────────────────
            local elementCount = 0
            local Section = { _body = Body }

            -- ── AddToggle ─────────────────────────────────────
            --[[
                Toggle row inside Body (291px wide):

                Row         291×26   BackgroundTransparency=1
                ├── Box     14×14    x=0  y=6   (26-14)/2=6 → centred ✓
                └── Label   x=20  w=271  h=26
                             (291 - 14 - 6 = 271px remaining for label)

                Box border is the 1px default from BorderColor3=RGB(75,75,75).
                Box BackgroundColor3 flips between Checkbox_BG / Checkbox_On.
            ]]
            function Section:AddToggle(label, default, callback)
                default  = (default == true)
                callback = callback or function() end
                local state = default

                elementCount = elementCount + 1

                local Row = New("Frame", {
                    Name                  = "Toggle_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Size                  = UDim2.new(1, 0, 0, 26),
                    LayoutOrder           = elementCount,
                    Parent                = Body,
                })

                -- Checkbox 14×14 centred vertically: y=(26-14)/2=6
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

                -- Label: x=20 (14px box + 6px gap)   w=271 (291-20)
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
                    Set = function(_, v) Apply(v, true)  end,
                    Get = function(_)    return state     end,
                }
            end

            return Section
        end

        return Tab
    end

    return Window
end

return UILibrary
