--[[
    UILibrary — Minimal, professional Roblox UI framework
    Author: Generated for your design
    Version: 1.0.0

    Usage:
        local UI = loadstring(...)()
        local Window = UI:CreateWindow("My Script")
        local Tab = Window:AddTab("Main")
        Tab:AddToggle("God Mode", false, function(state) end)
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")

-- ─────────────────────────────────────────
-- Theme
-- ─────────────────────────────────────────
local Theme = {
    Background  = Color3.fromRGB(29, 29, 29),
    Surface     = Color3.fromRGB(16, 16, 16),
    Border      = Color3.fromRGB(75, 75, 75),
    TabInactive = Color3.fromRGB(30, 30, 30),
    TabActive   = Color3.fromRGB(125, 0, 4),
    Text        = Color3.fromRGB(255, 255, 255),
    SubText     = Color3.fromRGB(160, 160, 160),
    Toggle_On   = Color3.fromRGB(125, 0, 4),
    Toggle_Off  = Color3.fromRGB(60, 60, 60),
    Font        = Enum.Font.Code,
    TextSize    = 16,
}

-- ─────────────────────────────────────────
-- Utility
-- ─────────────────────────────────────────
local function Tween(instance, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.15, style, direction),
        props
    ):Play()
end

local function MakeDraggable(dragHandle, dragTarget)
    local dragging, dragInput, startPos, startGuiPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging     = true
            startPos     = input.Position
            startGuiPos  = dragTarget.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - startPos
            dragTarget.Position = UDim2.new(
                startGuiPos.X.Scale,
                startGuiPos.X.Offset + delta.X,
                startGuiPos.Y.Scale,
                startGuiPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

-- ─────────────────────────────────────────
-- Window Constructor
-- ─────────────────────────────────────────
function UILibrary:CreateWindow(title)
    title = title or "UI Library"

    -- Destroy any existing instance to avoid duplicates
    local existing = game:GetService("CoreGui"):FindFirstChild("_index_")
    if existing then existing:Destroy() end

    -- ── Root ScreenGui ──
    local ScreenGui = Create("ScreenGui", {
        Name             = "_index_",
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn     = false,
        Parent           = game:GetService("CoreGui"),
    })

    -- ── Outer frame (shadow / border illusion) ──
    local OuterFrame = Create("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0.5, -315, 0.5, -195),
        Size             = UDim2.new(0, 630, 0, 390),
        Parent           = ScreenGui,
    })

    -- ── Inner frame ──
    local InnerFrame = Create("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = Theme.Surface,
        BorderColor3     = Theme.Border,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 380),
        Parent           = OuterFrame,
    })

    -- ── Title bar (drag handle) ──
    local TitleBar = Create("Frame", {
        Name             = "TitleBar",
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 30),
        Parent           = InnerFrame,
    })

    Create("TextLabel", {
        Name             = "Title",
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 10, 0, 0),
        Size             = UDim2.new(1, -40, 1, 0),
        Font             = Theme.Font,
        Text             = title,
        TextColor3       = Theme.Text,
        TextSize         = Theme.TextSize,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = TitleBar,
    })

    -- Close button
    local CloseBtn = Create("TextButton", {
        Name             = "Close",
        BackgroundTransparency = 1,
        Position         = UDim2.new(1, -30, 0, 0),
        Size             = UDim2.new(0, 30, 1, 0),
        Font             = Theme.Font,
        Text             = "✕",
        TextColor3       = Theme.SubText,
        TextSize         = 16,
        Parent           = TitleBar,
    })
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(OuterFrame, {Size = UDim2.new(0, 630, 0, 0)}, 0.2)
        task.delay(0.22, function() ScreenGui:Destroy() end)
    end)
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 80, 80)}, 0.1) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {TextColor3 = Theme.SubText}, 0.1) end)

    -- Dragging via title bar
    MakeDraggable(TitleBar, OuterFrame)

    -- ── Tab Bar ──
    local TabBar = Create("Frame", {
        Name             = "__tabs",
        BackgroundColor3 = Theme.Surface,
        BorderColor3     = Theme.Border,
        Position         = UDim2.new(0, 6, 0, 36),
        Size             = UDim2.new(0, 608, 0, 45),
        Parent           = InnerFrame,
    })

    Create("UIListLayout", {
        FillDirection    = Enum.FillDirection.Horizontal,
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Padding          = UDim.new(0, 1),
        Parent           = TabBar,
    })

    -- ── Tab Content Area ──
    local ContentArea = Create("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = Theme.Surface,
        BorderColor3     = Theme.Border,
        Position         = UDim2.new(0, 6, 0, 87),
        Size             = UDim2.new(0, 608, 0, 288),
        ClipsDescendants = true,
        Parent           = InnerFrame,
    })

    -- ─────────────────────────────────────────
    -- Window Object
    -- ─────────────────────────────────────────
    local Window = {
        _gui         = ScreenGui,
        _outer       = OuterFrame,
        _tabBar      = TabBar,
        _contentArea = ContentArea,
        _tabs        = {},
        _activeTab   = nil,
    }

    -- ── AddTab ──
    function Window:AddTab(name)
        local tabIndex = #self._tabs + 1

        -- Tab button
        local TabBtn = Create("TextButton", {
            Name             = "__tab_" .. name,
            Font             = Theme.Font,
            Text             = name,
            TextColor3       = Theme.Text,
            TextSize         = Theme.TextSize,
            TextWrapped      = true,
            BackgroundColor3 = Theme.TabInactive,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 151, 0, 45),
            LayoutOrder      = tabIndex,
            Parent           = self._tabBar,
        })

        -- Tab content page
        local Page = Create("ScrollingFrame", {
            Name                  = "__page_" .. name,
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            Size                  = UDim2.new(1, 0, 1, 0),
            CanvasSize            = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
            ScrollBarThickness    = 3,
            ScrollBarImageColor3  = Theme.TabActive,
            Visible               = false,
            Parent                = self._contentArea,
        })

        Create("UIListLayout", {
            SortOrder        = Enum.SortOrder.LayoutOrder,
            Padding          = UDim.new(0, 6),
            Parent           = Page,
        })

        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 8),
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 8),
            Parent        = Page,
        })

        -- Tab object
        local Tab = {
            _btn    = TabBtn,
            _page   = Page,
            _window = self,
        }

        -- ── Switch to this tab ──
        function Tab:Select()
            local win = self._window

            -- Deactivate all tabs
            for _, t in ipairs(win._tabs) do
                t._page.Visible = false
                Tween(t._btn, {BackgroundColor3 = Theme.TabInactive}, 0.12)
            end

            -- Activate this tab
            self._page.Visible = true
            Tween(self._btn, {BackgroundColor3 = Theme.TabActive}, 0.12)
            win._activeTab = self
        end

        TabBtn.MouseButton1Click:Connect(function() Tab:Select() end)

        -- Hover effect for inactive state
        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.1)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Theme.TabInactive}, 0.1)
            end
        end)

        table.insert(self._tabs, Tab)

        -- Auto-select first tab
        if #self._tabs == 1 then
            Tab:Select()
        end

        -- ─────────────────────────────────────
        -- Elements
        -- ─────────────────────────────────────

        -- ── Toggle ──
        function Tab:AddToggle(labelText, default, callback)
            default  = default  or false
            callback = callback or function() end

            local state = default

            local Row = Create("Frame", {
                Name             = "Toggle_" .. labelText,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 42),
                LayoutOrder      = #Page:GetChildren(),
                Parent           = Page,
            })

            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Row })

            Create("TextLabel", {
                Name                  = "Label",
                BackgroundTransparency = 1,
                Position              = UDim2.new(0, 12, 0, 0),
                Size                  = UDim2.new(1, -70, 1, 0),
                Font                  = Theme.Font,
                Text                  = labelText,
                TextColor3            = Theme.Text,
                TextSize              = Theme.TextSize,
                TextXAlignment        = Enum.TextXAlignment.Left,
                Parent                = Row,
            })

            -- Track container
            local TrackBtn = Create("TextButton", {
                Name             = "Track",
                BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off,
                BorderSizePixel  = 0,
                Position         = UDim2.new(1, -56, 0.5, -12),
                Size             = UDim2.new(0, 44, 0, 24),
                Text             = "",
                Parent           = Row,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = TrackBtn })

            -- Knob
            local Knob = Create("Frame", {
                Name             = "Knob",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position         = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                Size             = UDim2.new(0, 20, 0, 20),
                Parent           = TrackBtn,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

            local function SetToggle(value, silent)
                state = value
                Tween(TrackBtn, {BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off}, 0.15)
                Tween(Knob, {
                    Position = state
                        and UDim2.new(1, -22, 0.5, -10)
                        or  UDim2.new(0,  2, 0.5, -10)
                }, 0.15)
                if not silent then callback(state) end
            end

            TrackBtn.MouseButton1Click:Connect(function() SetToggle(not state) end)

            -- Return control object so callers can set/get state
            return {
                Set = function(_, val) SetToggle(val, true) end,
                Get = function(_) return state end,
            }
        end

        return Tab
    end

    -- ── Destroy ──
    function Window:Destroy()
        self._gui:Destroy()
    end

    return Window
end

-- ─────────────────────────────────────────
-- Entry point
-- ─────────────────────────────────────────
return UILibrary
