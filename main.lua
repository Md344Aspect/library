--[[
    UILibrary — CSGO-style, pixel-perfect, faithful to original dump
    Draggable via tab bar. No title bar. No rounded corners anywhere.

    Usage:
        local UI = loadstring(...)()
        local Window = UI:CreateWindow()
        local Tab    = Window:AddTab("Main")
        Tab:AddToggle("God Mode", false, function(state) print(state) end)
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

-- ─────────────────────────────────────────────────────────────
-- Theme  — every value pulled directly from the original dump
-- ─────────────────────────────────────────────────────────────
local Theme = {
    -- Frames
    Frame1_BG       = Color3.fromRGB(29,  29,  29),   -- outer shadow frame
    Frame2_BG       = Color3.fromRGB(16,  16,  16),   -- inner panel
    Frame2_Bdr      = Color3.fromRGB(75,  75,  75),

    -- Tab bar
    TabBar_BG       = Color3.fromRGB(16,  16,  16),
    TabBar_Bdr      = Color3.fromRGB(75,  75,  75),
    TabInactive_BG  = Color3.fromRGB(30,  30,  30),
    TabActive_BG    = Color3.fromRGB(125,  0,   4),

    -- Content
    Content_BG      = Color3.fromRGB(16,  16,  16),
    Content_Bdr     = Color3.fromRGB(75,  75,  75),

    -- Elements
    Element_BG      = Color3.fromRGB(16,  16,  16),   -- same surface as content
    Text            = Color3.fromRGB(255, 255, 255),
    SubText         = Color3.fromRGB(180, 180, 180),

    -- Checkbox (CSGO-style toggle)
    Checkbox_BG     = Color3.fromRGB(30,  30,  30),   -- unchecked fill
    Checkbox_Bdr    = Color3.fromRGB(75,  75,  75),   -- border colour
    Checkbox_Check  = Color3.fromRGB(125,  0,   4),   -- checked fill (accent)

    Font            = Enum.Font.Code,
    FontSize        = 16,
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
-- Window
-- ─────────────────────────────────────────────────────────────
--[[
    Exact pixel reconstruction of original dump:

    ScreenGui (_index_)
    └── _frame1          630 × 390   BorderSizePixel=0   [centered]
        └── _frame2      620 × 380   at (5, 5)           BorderColor3=RGB(75,75,75)
            ├── __tabs   608 × 45    at (6, 8)           BorderColor3=RGB(75,75,75)
            │   ├── __tabInactive    151 × 45  BorderSizePixel=0
            │   ├── __tabActive      151 × 45  BorderSizePixel=0
            │   └── UIListLayout     Horizontal, Padding=1px
            └── __tabContent  608 × 314  at (6, 59)      BorderColor3=RGB(75,75,75)
                └── UIListLayout     Vertical

    Tab bar bottom edge : 8 + 45      = 53
    Content top edge    : 59          (6px gap between bar bottom and content top)
    Content bottom edge : 59 + 314    = 373  (7px from frame2 bottom at 380)
]]
function UILibrary:CreateWindow()
    local CoreGui = game:GetService("CoreGui")
    local old = CoreGui:FindFirstChild("_index_")
    if old then old:Destroy() end

    -- ── ScreenGui ──────────────────────────────────────
    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        Parent         = CoreGui,
    })

    -- ── _frame1  (outer, 630×390, no border, centered) ─
    local Frame1 = New("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = Theme.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 630, 0, 390),
        Parent           = Gui,
    })

    -- ── _frame2  (inner panel, 620×380 at offset 5,5) ──
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = Theme.Frame2_BG,
        BorderColor3     = Theme.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = Frame1,
    })

    -- ── __tabs  (608×45 at 6,8 inside Frame2) ──────────
    local TabBar = New("Frame", {
        Name             = "__tabs",
        BackgroundColor3 = Theme.TabBar_BG,
        BorderColor3     = Theme.TabBar_Bdr,
        Position         = UDim2.new(0, 6, 0, 8),
        Size             = UDim2.new(0, 608, 0, 45),
        Parent           = Frame2,
    })

    local TabLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, 1),
        Parent        = TabBar,
    })

    -- ── __tabContent  (608×314 at 6,59 inside Frame2) ──
    --    8+45+6 = 59  ✓
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = Theme.Content_BG,
        BorderColor3     = Theme.Content_Bdr,
        Position         = UDim2.new(0, 6, 0, 59),
        Size             = UDim2.new(0, 608, 0, 314),
        ClipsDescendants = true,
        Parent           = Frame2,
    })

    -- Drag entire window by holding tab bar
    MakeDraggable(TabBar, Frame1)

    -- ─────────────────────────────────────────────────────
    -- Window object
    -- ─────────────────────────────────────────────────────
    local Window = {
        _gui         = Gui,
        _tabBar      = TabBar,
        _contentArea = ContentArea,
        _tabs        = {},
        _activeTab   = nil,
    }

    -- ── AddTab ────────────────────────────────────────────
    function Window:AddTab(name)
        local index = #self._tabs + 1

        --[[
            Tab button: 151 × 45, BorderSizePixel = 0
            4 tabs × 151 + 3 gaps × 1 = 607px — fits inside 608px bar
        ]]
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
            Content page: scrollable, fills ContentArea (608×314)
            UIPadding: 8px on all sides → usable area = 592×298
            Elements are stacked vertically with 4px gap
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

        New("UIListLayout", {
            SortOrder        = Enum.SortOrder.LayoutOrder,
            Padding          = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Parent           = Page,
        })

        New("UIPadding", {
            PaddingTop    = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 8),
            Parent        = Page,
        })

        -- ── Tab object ───────────────────────────────────
        local Tab = {
            _btn    = Btn,
            _page   = Page,
            _window = self,
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

        -- ─────────────────────────────────────────────────
        -- Elements
        -- ─────────────────────────────────────────────────

        --[[
            CSGO-style checkbox toggle
            Layout (row height = 26px, full page width):

            ┌──┐  Label text
            │  │
            └──┘
            ^14px square checkbox with 1px border
            Label sits 6px to the right of the checkbox, vertically centred

            Checked   → checkbox filled with accent red (125,0,4)
            Unchecked → checkbox filled with dark (30,30,30), border (75,75,75)
        ]]
        function Tab:AddToggle(label, default, callback)
            default  = (default == true)
            callback = callback or function() end
            local state = default

            -- Row: full width, 26px tall
            local Row = New("Frame", {
                Name             = "Toggle_" .. label,
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 26),
                LayoutOrder      = #Page:GetChildren(),
                Parent           = Page,
            })

            -- Checkbox: 14×14, vertically centred in the 26px row
            local Box = New("TextButton", {
                Name             = "Checkbox",
                BackgroundColor3 = state and Theme.Checkbox_Check or Theme.Checkbox_BG,
                BorderColor3     = Theme.Checkbox_Bdr,
                Position         = UDim2.new(0, 0, 0.5, -7),
                Size             = UDim2.new(0, 14, 0, 14),
                Text             = "",
                AutoButtonColor  = false,
                Parent           = Row,
            })

            -- Label: starts 6px after the 14px box → x=20
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

            -- Clicking label also toggles
            Row.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    Apply(not state)
                end
            end)

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
