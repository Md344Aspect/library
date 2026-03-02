--[[
    UILibrary — Faithful to original design, pixel-perfect
    No title bar. Draggable via tab bar.

    Usage:
        local UI = loadstring(...)()
        local Window = UI:CreateWindow()
        local Tab = Window:AddTab("Main")
        Tab:AddToggle("God Mode", false, function(state) print(state) end)
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ─────────────────────────────────────────
-- Theme  (mirrors original RGB values exactly)
-- ─────────────────────────────────────────
local Theme = {
    Frame1_BG    = Color3.fromRGB(29,  29,  29),
    Frame2_BG    = Color3.fromRGB(16,  16,  16),
    Frame2_Bdr   = Color3.fromRGB(75,  75,  75),
    TabBar_BG    = Color3.fromRGB(16,  16,  16),
    TabBar_Bdr   = Color3.fromRGB(75,  75,  75),
    TabInactive  = Color3.fromRGB(30,  30,  30),
    TabActive    = Color3.fromRGB(125,  0,   4),
    Content_BG   = Color3.fromRGB(16,  16,  16),
    Content_Bdr  = Color3.fromRGB(75,  75,  75),
    Text         = Color3.fromRGB(255, 255, 255),
    SubText      = Color3.fromRGB(160, 160, 160),
    Element_BG   = Color3.fromRGB(22,  22,  22),
    Toggle_On    = Color3.fromRGB(125,  0,   4),
    Toggle_Off   = Color3.fromRGB(55,  55,  55),
    Font         = Enum.Font.Nunito,
    FontSize     = 16,
}

-- ─────────────────────────────────────────
-- Utility
-- ─────────────────────────────────────────
local function Tween(obj, props, t)
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function New(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
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

-- ─────────────────────────────────────────
-- Window
-- ─────────────────────────────────────────
function UILibrary:CreateWindow()
    local cg  = game:GetService("CoreGui")
    local old = cg:FindFirstChild("_index_")
    if old then old:Destroy() end

    --[[
        Pixel layout (exact to original dump):

        _frame1      630 × 390   centered on screen via AnchorPoint
        └── _frame2  620 × 380   at pixel offset (5, 5)
            ├── __tabs        608 × 45   at (6, 7)
            └── __tabContent  608 × 314  at (6, 59)

        Tabs bar bottom  = 7 + 45 = 52
        Content top      = 59    → 7px breathing room between bar & content
        Content bottom   = 59 + 314 = 373 → 7px from frame2 bottom (380)
    ]]

    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        Parent         = cg,
    })

    local Frame1 = New("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = Theme.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 630, 0, 390),
        Parent           = Gui,
    })

    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = Theme.Frame2_BG,
        BorderColor3     = Theme.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- Tab bar: 608 × 45, offset (6, 7) inside Frame2
    local TabBar = New("Frame", {
        Name             = "__tabs",
        BackgroundColor3 = Theme.TabBar_BG,
        BorderColor3     = Theme.TabBar_Bdr,
        Position         = UDim2.new(0, 6, 0, 7),
        Size             = UDim2.new(0, 608, 0, 45),
        Parent           = Frame2,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, 1),
        Parent        = TabBar,
    })

    -- Content area: 608 × 314, offset (6, 59) inside Frame2
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = Theme.Content_BG,
        BorderColor3     = Theme.Content_Bdr,
        Position         = UDim2.new(0, 6, 0, 59),
        Size             = UDim2.new(0, 608, 0, 314),
        ClipsDescendants = true,
        Parent           = Frame2,
    })

    -- Drag the whole window by grabbing the tab bar
    MakeDraggable(TabBar, Frame1)

    -- ─────────────────────────────────────────
    -- Window object
    -- ─────────────────────────────────────────
    local Window = {
        _gui         = Gui,
        _tabBar      = TabBar,
        _contentArea = ContentArea,
        _tabs        = {},
        _activeTab   = nil,
    }

    function Window:AddTab(name)
        local index = #self._tabs + 1

        -- Tab button: 151 × 45
        -- Four tabs × 151px + three 1px gaps = 607px (fits 608px bar)
        local Btn = New("TextButton", {
            Name             = "__tabInactive",
            Font             = Theme.Font,
            Text             = name,
            TextColor3       = Theme.Text,
            TextSize         = Theme.FontSize,
            TextWrapped      = true,
            BackgroundColor3 = Theme.TabInactive,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 151, 0, 45),
            LayoutOrder      = index,
            AutoButtonColor  = false,
            Parent           = self._tabBar,
        })

        -- Scrollable content page, fills ContentArea
        local Page = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            ScrollBarThickness     = 3,
            ScrollBarImageColor3   = Theme.TabActive,
            Visible                = false,
            Parent                 = self._contentArea,
        })

        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 6),
            Parent    = Page,
        })

        New("UIPadding", {
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 10),
            Parent        = Page,
        })

        local Tab = {
            _btn    = Btn,
            _page   = Page,
            _window = self,
        }

        function Tab:Select()
            for _, t in ipairs(self._window._tabs) do
                t._page.Visible = false
                Tween(t._btn, { BackgroundColor3 = Theme.TabInactive }, 0.12)
            end
            self._page.Visible = true
            Tween(self._btn, { BackgroundColor3 = Theme.TabActive }, 0.12)
            self._window._activeTab = self
        end

        Btn.MouseButton1Click:Connect(function() Tab:Select() end)

        Btn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                Tween(Btn, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }, 0.1)
            end
        end)
        Btn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                Tween(Btn, { BackgroundColor3 = Theme.TabInactive }, 0.1)
            end
        end)

        table.insert(self._tabs, Tab)
        if #self._tabs == 1 then Tab:Select() end

        -- ─────────────────────────────────────
        -- Elements
        -- ─────────────────────────────────────

        --[[
            Toggle row (full width of Page minus padding = 588px, height 42px):
            ┌─────────────────────────────────────────┐
            │  Label text            [track ●]        │
            └─────────────────────────────────────────┘
        ]]
        function Tab:AddToggle(label, default, callback)
            default  = (default == true)
            callback = callback or function() end
            local state = default

            local Row = New("Frame", {
                Name             = "Toggle_" .. label,
                BackgroundColor3 = Theme.Element_BG,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 42),
                LayoutOrder      = #Page:GetChildren(),
                Parent           = Page,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Row })

            New("TextLabel", {
                BackgroundTransparency = 1,
                Position       = UDim2.new(0, 12, 0, 0),
                Size           = UDim2.new(1, -68, 1, 0),
                Font           = Theme.Font,
                Text           = label,
                TextColor3     = Theme.Text,
                TextSize       = Theme.FontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent         = Row,
            })

            local Track = New("TextButton", {
                BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0.5, 0),
                Size             = UDim2.new(0, 44, 0, 24),
                Text             = "",
                AutoButtonColor  = false,
                Parent           = Row,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

            local Knob = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = state
                    and UDim2.new(1, -22, 0.5, 0)
                    or  UDim2.new(0,   2, 0.5, 0),
                Size             = UDim2.new(0, 20, 0, 20),
                Parent           = Track,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

            local function Apply(val, silent)
                state = val
                Tween(Track, {
                    BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off
                }, 0.15)
                Tween(Knob, {
                    Position = state
                        and UDim2.new(1, -22, 0.5, 0)
                        or  UDim2.new(0,   2, 0.5, 0)
                }, 0.15)
                if not silent then callback(state) end
            end

            Track.MouseButton1Click:Connect(function() Apply(not state) end)

            return {
                Set = function(_, v) Apply(v, true) end,
                Get = function(_) return state end,
            }
        end

        return Tab
    end

    function Window:Destroy()
        self._gui:Destroy()
    end

    return Window
end

return UILibrary
