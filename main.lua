--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║  UILibrary  —  CSGO-style  |  Font.Code  |  Colorways  |  Watermark         ║
║  Version 4.0  —  Pixel-perfect  |  Full bug-fix pass  |  Draggable header   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  COLORWAYS  (cfg.theme)                                                      ║
║    "red"    → RGB(125,  0,   4)   default                                    ║
║    "blue"   → RGB(  0,100, 200)                                              ║
║    "green"  → RGB( 30,140,  60)                                              ║
║    "purple" → RGB(100,  0, 160)                                              ║
║    "orange" → RGB(200, 90,   0)                                              ║
║    "cyan"   → RGB(  0,160, 180)                                              ║
║    "pink"   → RGB(200,  0, 120)                                              ║
║    "white"  → RGB(200,200, 200)                                              ║
║                                                                              ║
║  LAYOUT  (px)                                                                ║
║    Window    630 × 416  centered                                             ║
║    Frame2    620 × 406  offset (5,5)   1px border                           ║
║    TitleBar  620 × 26   offset (0,0)   drag handle  (replaces TabBar drag)  ║
║      ScriptName  x=10  h=26  left                                            ║
║      CloseBtn    x=(1,-26) w=26  right                                       ║
║    TabBar    608 × 32   offset (6,32)  1px border  (no drag)                ║
║    Content   608 × 326  offset (6,70)  1px border  (no drag)                ║
║    Padding   8px all sides → usable 592 × 310                               ║
║    Columns   (592-8)/2 = 292px each   gap=8   RightCol x=300                ║
║                                                                              ║
║  ELEMENTS  (292px wide)                                                      ║
║    Toggle          292 × 26                                                  ║
║    Slider          292 × 40   (18 label + 4 gap + 12 track + 6 thumb)       ║
║    Dropdown        292 × 26 closed  /  27 + n×22 open                       ║
║    MultiDropdown   292 × 26 closed  /  27 + n×22 + 22 footer open           ║
║    TextInput       292 × 44   (18 label + 4 gap + 22 field)                 ║
║    Button          292 × 26                                                  ║
║    Label           292 × 18                                                  ║
║    Separator       292 × 9    (1px line centred in 9px wrapper)             ║
║                                                                              ║
║  TOOLTIP                                                                     ║
║    Any element accepts an optional last arg: tooltip = "string"              ║
║    Shows a floating panel near the cursor on hover                           ║
║    Auto-repositions to stay inside screen bounds                             ║
║                                                                              ║
║  USAGE                                                                       ║
║    local UI  = loadstring(...)()                                             ║
║    local Win = UI:CreateWindow({                                             ║
║        key   = Enum.KeyCode.RightShift,                                      ║
║        theme = "blue",                                                       ║
║        name  = "MyScript",                                                   ║
║        fps   = true,                                                         ║
║        clock = true,                                                         ║
║    })                                                                        ║
║    local Tab  = Win:AddTab("Combat")                                         ║
║    local Sect = Tab:AddSection("Aimbot", "left")                             ║
║    Sect:AddToggle("Enable", false, function(v) end, "Enables aimbot")        ║
║    Sect:AddSlider("FOV", 1, 360, 90, 0, function(v) end, "Field of view")   ║
║    Sect:AddDropdown("Bone",{"Head","Neck"},"Head",function(v) end,"Target")  ║
║    Sect:AddButton("Fire", function() end, "Shoot now")                       ║
║    UI:Notify("Loaded", "Ready to use", "success", 3)                        ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- ─────────────────────────────────────────────────────────────────────────────
-- Version
-- ─────────────────────────────────────────────────────────────────────────────
local UILibrary      = {}
UILibrary.__index    = UILibrary
UILibrary.Version    = "4.0"

-- ─────────────────────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")

-- ─────────────────────────────────────────────────────────────────────────────
-- Colorways
-- ─────────────────────────────────────────────────────────────────────────────
local Colorways = {
    red    = Color3.fromRGB(125,   0,   4),
    blue   = Color3.fromRGB(  0, 100, 200),
    green  = Color3.fromRGB( 30, 140,  60),
    purple = Color3.fromRGB(100,   0, 160),
    orange = Color3.fromRGB(200,  90,   0),
    cyan   = Color3.fromRGB(  0, 160, 180),
    pink   = Color3.fromRGB(200,   0, 120),
    white  = Color3.fromRGB(200, 200, 200),
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Theme
-- ─────────────────────────────────────────────────────────────────────────────
local function BuildTheme(accent)
    return {
        -- Frames
        Frame1_BG       = Color3.fromRGB( 29,  29,  29),
        Frame2_BG       = Color3.fromRGB( 16,  16,  16),
        Frame2_Bdr      = Color3.fromRGB( 55,  55,  55),
        -- TitleBar
        TitleBar_BG     = Color3.fromRGB( 20,  20,  20),
        TitleBar_Bdr    = Color3.fromRGB( 55,  55,  55),
        -- Tab bar
        TabBar_BG       = Color3.fromRGB( 18,  18,  18),
        TabBar_Bdr      = Color3.fromRGB( 55,  55,  55),
        TabInactive_BG  = Color3.fromRGB( 26,  26,  26),
        TabHover_BG     = Color3.fromRGB( 36,  36,  36),
        TabActive_BG    = accent,
        -- Content
        Content_BG      = Color3.fromRGB( 14,  14,  14),
        Content_Bdr     = Color3.fromRGB( 55,  55,  55),
        -- Text
        Text            = Color3.fromRGB(240, 240, 240),
        SubText         = Color3.fromRGB(150, 150, 150),
        DimText         = Color3.fromRGB( 75,  75,  75),
        SectionTitle    = Color3.fromRGB(170, 170, 170),
        -- Misc
        Separator       = Color3.fromRGB( 55,  55,  55),
        Accent          = accent,
        -- Checkbox / Toggle
        Checkbox_BG     = Color3.fromRGB( 24,  24,  24),
        Checkbox_Bdr    = Color3.fromRGB( 60,  60,  60),
        Checkbox_On     = accent,
        -- Dropdown
        Dropdown_BG     = Color3.fromRGB( 26,  26,  26),
        Dropdown_List   = Color3.fromRGB( 20,  20,  20),
        Dropdown_Hover  = Color3.fromRGB( 34,  34,  34),
        Dropdown_Sel    = accent,
        -- Slider
        Slider_Track    = Color3.fromRGB( 36,  36,  36),
        Slider_Fill     = accent,
        Slider_Thumb    = accent,
        Slider_ValBox   = Color3.fromRGB( 20,  20,  20),
        -- Button
        Button_BG       = Color3.fromRGB( 26,  26,  26),
        Button_Hover    = Color3.fromRGB( 36,  36,  36),
        Button_Active   = accent,
        Button_Bdr      = Color3.fromRGB( 55,  55,  55),
        -- Tooltip
        Tooltip_BG      = Color3.fromRGB( 20,  20,  20),
        Tooltip_Bdr     = Color3.fromRGB( 65,  65,  65),
        Tooltip_Text    = Color3.fromRGB(200, 200, 200),
        -- Disabled state
        Disabled_BG     = Color3.fromRGB( 20,  20,  20),
        Disabled_Text   = Color3.fromRGB( 60,  60,  60),
        -- Notification type colours
        Notif = {
            info    = Color3.fromRGB( 70,  70,  70),
            success = Color3.fromRGB( 30, 140,  60),
            warning = Color3.fromRGB(200, 150,   0),
            error   = Color3.fromRGB(125,   0,   4),
        },
        -- Typography
        Font     = Enum.Font.Code,
        FontSize = 13,
        HdrSize  = 11,
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Pure helpers
-- ─────────────────────────────────────────────────────────────────────────────
local function Clamp(v, mn, mx)
    return math.max(mn, math.min(mx, v))
end

local function Round(v, decimals)
    if not decimals or decimals <= 0 then return math.floor(v + 0.5) end
    local m = 10 ^ decimals
    return math.floor(v * m + 0.5) / m
end

local function FormatNum(v, decimals)
    if not decimals or decimals <= 0 then return tostring(math.floor(v + 0.5)) end
    return string.format("%." .. decimals .. "f", v)
end

local function Map(v, a, b, c, d)
    if a == b then return c end
    return c + (v - a) / (b - a) * (d - c)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Monotonic notification counter
-- FIX: replaces os.clock() * 1000 % MAX which wraps and sorts wrong.
-- ─────────────────────────────────────────────────────────────────────────────
local _notifCounter = 0
local function NextNotifOrder()
    _notifCounter += 1
    return _notifCounter
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Tween helpers
-- ─────────────────────────────────────────────────────────────────────────────
local function TweenQuad(obj, t, props)
    TweenService:Create(obj,
        TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props):Play()
end

local function TweenLinear(obj, t, props)
    TweenService:Create(obj,
        TweenInfo.new(t, Enum.EasingStyle.Linear),
        props):Play()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Instance factory
-- Parent is always set LAST so the engine does not trigger layout
-- recalculations before all properties are applied.
-- ─────────────────────────────────────────────────────────────────────────────
local function New(class, props)
    local o      = Instance.new(class)
    local parent = nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            o[k] = v
        end
    end
    if parent then o.Parent = parent end
    return o
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MakeDraggable
--   handle     — GuiObject the user grabs
--   target     — GuiObject that physically moves
--   getEnabled — optional () → bool  returning false blocks dragging
--
-- A global UserInputService.InputEnded connection acts as a safety net
-- for mouse-up events that fire outside the handle (alt-tab, etc.).
-- ─────────────────────────────────────────────────────────────────────────────
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
        end
    end)

    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp ~= dragInput then return end
        if getEnabled and not getEnabled() then dragging = false return end
        local d = inp.Position - startMouse
        target.Position = UDim2.new(
            startPos.X.Scale,  startPos.X.Offset + d.X,
            startPos.Y.Scale,  startPos.Y.Offset + d.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Global dropdown registry
-- Tracks all open dropdowns so clicking outside any of them closes all.
-- ─────────────────────────────────────────────────────────────────────────────
local _openDropdowns = {}  -- { closeFunc, rowRef }[]

local function RegisterDropdown(rowRef, closeFunc)
    table.insert(_openDropdowns, { row = rowRef, close = closeFunc })
end

local function UnregisterDropdown(rowRef)
    for i = #_openDropdowns, 1, -1 do
        if _openDropdowns[i].row == rowRef then
            table.remove(_openDropdowns, i)
        end
    end
end

-- Global click listener: close any open dropdown whose Row is not an ancestor
-- of the clicked GuiObject.
UserInputService.InputBegan:Connect(function(inp, processed)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    for _, entry in ipairs(_openDropdowns) do
        -- GuiService:GetGuiObjectsAtPosition is unavailable in most exploit
        -- contexts, so we check AbsolutePosition + AbsoluteSize instead.
        local row  = entry.row
        local pos  = row.AbsolutePosition
        local size = row.AbsoluteSize
        local mp   = UserInputService:GetMouseLocation()
        local inside = mp.X >= pos.X and mp.X <= pos.X + size.X
                   and mp.Y >= pos.Y and mp.Y <= pos.Y + size.Y
        if not inside then
            entry.close()
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Tooltip system  (module-level singleton, DisplayOrder = 20)
-- ─────────────────────────────────────────────────────────────────────────────
local Tooltip = (function()
    local gui, frame, label
    local moveConn = nil
    local PADDING  = { x = 14, y = 6 }

    local function Ensure()
        if gui and gui.Parent and gui.Parent == CoreGui then return end
        local old = CoreGui:FindFirstChild("_tooltip_")
        if old then old:Destroy() end

        gui = New("ScreenGui", {
            Name           = "_tooltip_",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder   = 20,
            ResetOnSpawn   = false,
            Enabled        = false,
            Parent         = CoreGui,
        })

        frame = New("Frame", {
            Name             = "TooltipFrame",
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3     = Color3.fromRGB(65, 65, 65),
            Size             = UDim2.new(0, 0, 0, 22),
            AutomaticSize    = Enum.AutomaticSize.X,
            AnchorPoint      = Vector2.new(0, 0),
            Position         = UDim2.new(0, 0, 0, 0),
            Parent           = gui,
        })
        New("UIPadding", {
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 8),
            PaddingTop    = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            Parent        = frame,
        })
        label = New("TextLabel", {
            Name                   = "Lbl",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, 0, 1, 0),
            AutomaticSize          = Enum.AutomaticSize.X,
            Font                   = Enum.Font.Code,
            Text                   = "",
            TextColor3             = Color3.fromRGB(200, 200, 200),
            TextSize               = 11,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextYAlignment         = Enum.TextYAlignment.Center,
            Parent                 = frame,
        })
    end

    local function UpdatePosition(mousePos)
        if not frame then return end
        local vp    = workspace.CurrentCamera.ViewportSize
        local fSize = frame.AbsoluteSize
        local x = mousePos.X + PADDING.x
        local y = mousePos.Y + PADDING.y
        if x + fSize.X > vp.X - 4 then x = mousePos.X - fSize.X - PADDING.x end
        if y + fSize.Y > vp.Y - 4 then y = mousePos.Y - fSize.Y - PADDING.y end
        frame.Position = UDim2.new(0, math.floor(x), 0, math.floor(y))
    end

    local function Show(text)
        Ensure()
        label.Text  = tostring(text)
        gui.Enabled = true
        if moveConn then moveConn:Disconnect() end
        moveConn = UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                UpdatePosition(inp.Position)
            end
        end)
        UpdatePosition(UserInputService:GetMouseLocation())
    end

    local function Hide()
        if gui then gui.Enabled = false end
        if moveConn then moveConn:Disconnect() moveConn = nil end
    end

    return { Show = Show, Hide = Hide }
end)()

-- ─────────────────────────────────────────────────────────────────────────────
-- AttachTooltip
-- ─────────────────────────────────────────────────────────────────────────────
local function AttachTooltip(guiObj, tooltipText)
    if not tooltipText or tooltipText == "" then return end
    guiObj.MouseEnter:Connect(function() Tooltip.Show(tooltipText) end)
    guiObj.MouseLeave:Connect(function() Tooltip.Hide() end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Notification system  (module-level singleton, DisplayOrder = 10)
-- FIX: Uses a boolean init guard instead of IsDescendantOf check every call.
-- FIX: Uses monotonic counter for LayoutOrder.
-- FIX: Caps visible notifications at 6; queues the rest.
-- ─────────────────────────────────────────────────────────────────────────────
local NotifGui         = nil
local NotifContainer   = nil
local _notifInited     = false
local _notifQueue      = {}
local _notifActive     = 0
local NOTIF_MAX        = 6

local function EnsureNotifGui()
    if _notifInited then return end
    _notifInited = true
    local old = CoreGui:FindFirstChild("_notifs_")
    if old then old:Destroy() end
    NotifGui = New("ScreenGui", {
        Name           = "_notifs_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 10,
        ResetOnSpawn   = false,
        Parent         = CoreGui,
    })
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

local function _SpawnNotif(title, message, accent, duration)
    _notifActive += 1
    local order = NextNotifOrder()

    local Wrapper = New("Frame", {
        Name                   = "Notif_" .. order,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 60),
        LayoutOrder            = order,
        ClipsDescendants       = true,
        Parent                 = NotifContainer,
    })
    local Card = New("Frame", {
        Name             = "Card",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        BorderColor3     = Color3.fromRGB(55, 55, 55),
        Position         = UDim2.new(0, 310, 0, 0),
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = Wrapper,
    })
    New("Frame", {   -- accent sidebar 4px
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 0),
        Size             = UDim2.new(0, 4, 1, 0),
        Parent           = Card,
    })
    New("TextLabel", {   -- title  y=8 h=18
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 12, 0, 8),
        Size                   = UDim2.new(1, -16, 0, 18),
        Font                   = Enum.Font.Code,
        Text                   = title,
        TextColor3             = Color3.fromRGB(240, 240, 240),
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Center,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        Parent                 = Card,
    })
    New("TextLabel", {   -- message  y=28 h=24
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 12, 0, 28),
        Size                   = UDim2.new(1, -16, 0, 24),
        Font                   = Enum.Font.Code,
        Text                   = message,
        TextColor3             = Color3.fromRGB(150, 150, 150),
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Top,
        TextWrapped            = true,
        Parent                 = Card,
    })
    local TimerBar = New("Frame", {   -- timer bar  y=58 h=2
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 58),
        Size             = UDim2.new(1, 0, 0, 2),
        Parent           = Card,
    })

    TweenQuad(Card, 0.22, { Position = UDim2.new(0, 0, 0, 0) })
    TweenLinear(TimerBar, duration, { Size = UDim2.new(0, 0, 0, 2) })

    task.delay(duration, function()
        if not Card or not Card.Parent then return end
        local tw = TweenService:Create(Card,
            TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 310, 0, 0) })
        tw:Play()
        tw.Completed:Connect(function()
            if Wrapper and Wrapper.Parent then Wrapper:Destroy() end
            _notifActive -= 1
            -- Drain queue
            if #_notifQueue > 0 then
                local next = table.remove(_notifQueue, 1)
                _SpawnNotif(next.title, next.message, next.accent, next.duration)
            end
        end)
    end)
end

function UILibrary:Notify(title, message, ntype, duration)
    EnsureNotifGui()
    ntype    = ntype    or "info"
    duration = duration or 3
    title    = tostring(title   or "Notification")
    message  = tostring(message or "")

    local notifColors = {
        info    = Color3.fromRGB( 70,  70,  70),
        success = Color3.fromRGB( 30, 140,  60),
        warning = Color3.fromRGB(200, 150,   0),
        error   = Color3.fromRGB(125,   0,   4),
    }
    local accent = notifColors[ntype] or notifColors.info

    if _notifActive >= NOTIF_MAX then
        table.insert(_notifQueue, {
            title    = title,
            message  = message,
            accent   = accent,
            duration = duration,
        })
    else
        _SpawnNotif(title, message, accent, duration)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CreateWindow
-- ─────────────────────────────────────────────────────────────────────────────
--[[
  PIXEL MATH  (all figures in px)
  ─────────────────────────────────────────────────────────────────────────────
  Frame1 (outer shell)   630 × 416
  Frame2 (inner)         620 × 406  offset (5,5)   1px border

  TitleBar               620 × 26   offset (0,0)   — DRAG HANDLE
    AccentBar  4 × 26   left edge
    ScriptName  x=12   Left/Center  Code 13
    CloseBtn    x=(1,-26)  Size(0,26,0,26)  "×"
    bottom separator  1px at y=25

  TabBar                 608 × 32   offset (6,32)  1px border
    Tab buttons   each Size(0,151,0,32)  — NO drag
    active underbar  2px at bottom of button

  gap below TitleBar bottom  = 32 - 26 = 6px  ✓
  gap below TabBar bottom    = 70 - (32+32) = 6px  ✓

  Content                608 × 326  offset (6,70)  1px border
    content bottom = 70 + 326 = 396px
    Frame2 inner h = 406 - 2 = 404px
    bottom gap     = 404 - 396 = 8px  ✓

  ScrollingFrame inside Content  1,0,1,0
  UIPadding 8px all → usable  592 × 310
  ColumnHolder width  592px
  Column width  (592-8)/2 = 292px
  RightCol x = 292 + 8 = 300px
  RightCol right edge = 300 + 292 = 592px  ✓
]]
function UILibrary:CreateWindow(cfg)
    cfg = cfg or {}
    local toggleKey   = cfg.key    or Enum.KeyCode.RightShift
    local accentColor = Colorways[cfg.theme] or Colorways.red
    local scriptName  = tostring(cfg.name  or "Script")
    local showFPS     = cfg.fps   ~= false
    local showClock   = cfg.clock ~= false
    local T           = BuildTheme(accentColor)

    -- Clean up any previous instance
    for _, n in ipairs({"_index_", "_wmk_"}) do
        local o = CoreGui:FindFirstChild(n)
        if o then o:Destroy() end
    end

    -- ── Main ScreenGui ───────────────────────────────────────────────────────
    local Gui = New("ScreenGui", {
        Name           = "_index_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 1,
        ResetOnSpawn   = false,
        Parent         = CoreGui,
    })

    -- ── Frame1: 630×416  no border  centered ────────────────────────────────
    local Frame1 = New("Frame", {
        Name             = "_frame1",
        BackgroundColor3 = T.Frame1_BG,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 630, 0, 416),
        Parent           = Gui,
    })

    -- ── Frame2: 620×406  offset (5,5)  1px border ───────────────────────────
    local Frame2 = New("Frame", {
        Name             = "_frame2",
        BackgroundColor3 = T.Frame2_BG,
        BorderColor3     = T.Frame2_Bdr,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(0, 620, 0, 406),
        Parent           = Frame1,
    })

    -- ── TitleBar: 620×26  offset (0,0)  — DRAG HANDLE ───────────────────────
    --    This is the ONLY drag surface for the main window.
    --    TabBar and ContentArea are NOT draggable.
    local TitleBar = New("Frame", {
        Name             = "TitleBar",
        BackgroundColor3 = T.TitleBar_BG,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 0),
        Size             = UDim2.new(0, 620, 0, 26),
        Parent           = Frame2,
    })

    -- TitleBar accent bar: 4×26 on the left edge
    New("Frame", {
        Name             = "AccentBar",
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 0),
        Size             = UDim2.new(0, 4, 1, 0),
        Parent           = TitleBar,
    })

    -- Script name label
    New("TextLabel", {
        Name                   = "ScriptName",
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 12, 0, 0),
        Size                   = UDim2.new(1, -38, 1, 0),
        Font                   = T.Font,
        Text                   = scriptName,
        TextColor3             = T.Text,
        TextSize               = T.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Center,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        Parent                 = TitleBar,
    })

    -- Close button: 26×26 on the right
    local CloseBtn = New("TextButton", {
        Name                   = "CloseBtn",
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(1, -26, 0, 0),
        Size                   = UDim2.new(0, 26, 0, 26),
        Font                   = T.Font,
        Text                   = "×",
        TextColor3             = T.SubText,
        TextSize               = 16,
        TextXAlignment         = Enum.TextXAlignment.Center,
        TextYAlignment         = Enum.TextYAlignment.Center,
        AutoButtonColor        = false,
        ZIndex                 = 2,
        Parent                 = TitleBar,
    })
    CloseBtn.MouseEnter:Connect(function()
        TweenQuad(CloseBtn, 0.08, { TextColor3 = Color3.fromRGB(220, 60, 60) })
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenQuad(CloseBtn, 0.08, { TextColor3 = T.SubText })
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Frame1.Visible = false
    end)

    -- TitleBar bottom separator
    New("Frame", {
        Name             = "Sep",
        BackgroundColor3 = T.TitleBar_Bdr,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -1),
        Size             = UDim2.new(1, 0, 0, 1),
        Parent           = TitleBar,
    })

    -- ── TabBar: 608×32  offset (6,32)  1px border  — NOT a drag handle ──────
    local TabBar = New("Frame", {
        Name             = "__tabs",
        BackgroundColor3 = T.TabBar_BG,
        BorderColor3     = T.TabBar_Bdr,
        Position         = UDim2.new(0, 6, 0, 32),
        Size             = UDim2.new(0, 608, 0, 32),
        Parent           = Frame2,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, 1),
        Parent        = TabBar,
    })

    -- ── ContentArea: 608×326  offset (6,70)  1px border  clips ──────────────
    local ContentArea = New("Frame", {
        Name             = "__tabContent",
        BackgroundColor3 = T.Content_BG,
        BorderColor3     = T.Content_Bdr,
        Position         = UDim2.new(0, 6, 0, 70),
        Size             = UDim2.new(0, 608, 0, 326),
        ClipsDescendants = true,
        Parent           = Frame2,
    })

    -- ── Dragging: ONLY TitleBar is the drag handle ───────────────────────────
    MakeDraggable(TitleBar, Frame1, function()
        -- Block drag if click is on the CloseBtn
        local mp = UserInputService:GetMouseLocation()
        local cp = CloseBtn.AbsolutePosition
        local cs = CloseBtn.AbsoluteSize
        local onClose = mp.X >= cp.X and mp.X <= cp.X + cs.X
                    and mp.Y >= cp.Y and mp.Y <= cp.Y + cs.Y
        return not onClose
    end)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Watermark  (always visible, draggable only when main GUI is open)
    -- ─────────────────────────────────────────────────────────────────────────
    --[[
      WmkF1  auto×28  outer (Frame1_BG colour acts as 1px "shadow")
      WmkF2  offset(1,1)  size(1,-2,0,26)  auto-X  actual visible bar
        UIListLayout Horizontal  VerticalAlignment=Center
        AccentBar  4×26
        Spacer 6
        ScriptName  auto
        Divider  (4 gap + 1px line + 4 gap = 9px)
        UserName  auto
        [Divider + FPSLbl]    optional
        [Divider + ClockLbl]  optional
        Spacer 8
    ]]
    local WmkGui = New("ScreenGui", {
        Name           = "_wmk_",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 5,
        ResetOnSpawn   = false,
        Enabled        = true,
        Parent         = CoreGui,
    })
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
    local WmkF2 = New("Frame", {
        Name             = "WmkF2",
        BackgroundColor3 = T.Frame2_BG,
        BorderColor3     = T.Frame2_Bdr,
        Position         = UDim2.new(0, 1, 0, 1),
        Size             = UDim2.new(1, -2, 0, 26),
        AutomaticSize    = Enum.AutomaticSize.X,
        Parent           = WmkF1,
    })
    New("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 0),
        Parent            = WmkF2,
    })

    -- Watermark builder helpers
    local wmkOrder = 0
    local function WmkSpacer(w)
        wmkOrder += 1
        New("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, w, 0, 26),
            LayoutOrder            = wmkOrder,
            Parent                 = WmkF2,
        })
    end
    local function WmkDivider()
        WmkSpacer(4)
        wmkOrder += 1
        New("Frame", {
            BackgroundColor3 = T.Separator,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 1, 0, 14),
            LayoutOrder      = wmkOrder,
            Parent           = WmkF2,
        })
        WmkSpacer(4)
    end
    local function WmkLabel(text, size, color)
        wmkOrder += 1
        return New("TextLabel", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, 0, 0, 26),
            AutomaticSize          = Enum.AutomaticSize.X,
            Font                   = T.Font,
            Text                   = text,
            TextColor3             = color,
            TextSize               = size,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextYAlignment         = Enum.TextYAlignment.Center,
            LayoutOrder            = wmkOrder,
            Parent                 = WmkF2,
        })
    end

    -- AccentBar 4×26
    wmkOrder += 1
    New("Frame", {
        Name             = "AccentBar",
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 4, 0, 26),
        LayoutOrder      = wmkOrder,
        Parent           = WmkF2,
    })
    WmkSpacer(8)
    WmkLabel(scriptName, 13, T.Text)
    WmkDivider()
    local localName = (Players.LocalPlayer and Players.LocalPlayer.Name) or "Player"
    WmkLabel(localName, 11, T.SubText)

    local FpsLabel   = nil
    local ClockLabel = nil

    if showFPS then
        WmkDivider()
        FpsLabel      = WmkLabel("FPS: --", 11, T.SubText)
        FpsLabel.Name = "FPS"
    end
    if showClock then
        WmkDivider()
        ClockLabel      = WmkLabel("00:00", 11, T.SubText)
        ClockLabel.Name = "Clock"
    end
    WmkSpacer(8)

    -- FPS loop (samples every 0.5s)
    if FpsLabel then
        local frames, timer = 0, 0
        RunService.RenderStepped:Connect(function(dt)
            frames += 1
            timer  += dt
            if timer >= 0.5 then
                local fps   = math.floor(frames / timer + 0.5)
                frames, timer = 0, 0
                local col
                if fps >= 60 then
                    col = Color3.fromRGB(30, 160, 60)
                elseif fps >= 30 then
                    col = Color3.fromRGB(200, 150, 0)
                else
                    col = Color3.fromRGB(180, 40, 40)
                end
                FpsLabel.Text       = "FPS: " .. fps
                FpsLabel.TextColor3 = col
            end
        end)
    end

    -- Clock loop (only writes when minute changes)
    if ClockLabel then
        local lastClock = ""
        RunService.Heartbeat:Connect(function()
            local t = os.date("*t")
            local s = string.format("%02d:%02d", t.hour, t.min)
            if s ~= lastClock then
                lastClock       = s
                ClockLabel.Text = s
            end
        end)
    end

    -- Watermark dragging: only when main GUI is visible
    --   FIX: Only one drag handle (WmkF2 → WmkF1 target).
    --        Previously both WmkF1 and WmkF2 were registered, causing
    --        two simultaneous drag operations.
    local function wmkEnabled() return Frame1.Visible end
    MakeDraggable(WmkF2, WmkF1, wmkEnabled)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(inp, processed)
        if not processed and inp.KeyCode == toggleKey then
            Frame1.Visible = not Frame1.Visible
        end
    end)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Window object
    -- ─────────────────────────────────────────────────────────────────────────
    local Window = {
        _gui         = Gui,
        _wmkGui      = WmkGui,
        _frame       = Frame1,
        _titleBar    = TitleBar,
        _tabBar      = TabBar,
        _contentArea = ContentArea,
        _tabs        = {},
        _activeTab   = nil,
        _theme       = T,
    }

    function Window:SetVisible(v)  self._frame.Visible = v              end
    function Window:IsVisible()    return self._frame.Visible           end
    function Window:Toggle()       self:SetVisible(not self:IsVisible()) end
    function Window:Destroy()      self._gui:Destroy(); self._wmkGui:Destroy() end

    -- ─────────────────────────────────────────────────────────────────────────
    -- AddTab
    -- ─────────────────────────────────────────────────────────────────────────
    --[[
      Tab button  151 × 32  no border
        4 tabs × 151 + 3 × 1(gap) = 607px ≤ 608px  ✓
      Active underbar  2px at very bottom of button
      ScrollingFrame   fills ContentArea  (1,0,1,0)
      UIPadding  8px all  → usable 592 × 310
      ColumnHolder  592px wide  AutomaticSize=Y
        LeftCol   x=0    w=292
        RightCol  x=300  w=292  (300+292=592 ✓)
    ]]
    function Window:AddTab(name)
        local index = #self._tabs + 1

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
            Size             = UDim2.new(0, 151, 0, 32),
            LayoutOrder      = index,
            AutoButtonColor  = false,
            Parent           = self._tabBar,
        })

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

        local Holder = New("Frame", {
            Name                   = "ColumnHolder",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = Page,
        })

        local LeftCol = New("Frame", {
            Name                   = "LeftCol",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0, 0, 0, 0),
            Size                   = UDim2.new(0, 292, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = Holder,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 10),
            Parent    = LeftCol,
        })

        local RightCol = New("Frame", {
            Name                   = "RightCol",
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0, 300, 0, 0),
            Size                   = UDim2.new(0, 292, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = Holder,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 10),
            Parent    = RightCol,
        })

        local Tab = {
            _btn      = Btn,
            _bar      = ActiveBar,
            _page     = Page,
            _leftCol  = LeftCol,
            _rightCol = RightCol,
            _window   = self,
        }

        function Tab:Select()
            local prev = self._window._activeTab
            if prev and prev ~= self then
                prev._page.Visible = false
                prev._bar.Visible  = false
                TweenQuad(prev._btn, 0.10, { BackgroundColor3 = T.TabInactive_BG })
            end
            self._page.Visible = true
            self._bar.Visible  = true
            TweenQuad(self._btn, 0.10, { BackgroundColor3 = T.TabActive_BG })
            self._window._activeTab = self
        end

        Btn.MouseButton1Click:Connect(function() Tab:Select() end)

        -- FIX: MouseLeave guard — don't reset active tab's bg to inactive.
        Btn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                TweenQuad(Btn, 0.08, { BackgroundColor3 = T.TabHover_BG })
            end
        end)
        Btn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                TweenQuad(Btn, 0.08, { BackgroundColor3 = T.TabInactive_BG })
            end
        end)

        table.insert(self._tabs, Tab)
        if #self._tabs == 1 then Tab:Select() end

        -- ─────────────────────────────────────────────────────────────────────
        -- AddSection
        -- ─────────────────────────────────────────────────────────────────────
        function Tab:AddSection(sectionName, side)
            side = (side == "right") and "right" or "left"
            local Col   = (side == "right") and self._rightCol or self._leftCol
            local order = #Col:GetChildren()

            local SectionFrame = New("Frame", {
                Name                   = "Sec_" .. sectionName,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                LayoutOrder            = order,
                Parent                 = Col,
            })

            -- Header: 292×20  (section title + bottom separator)
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
            New("Frame", {
                Name             = "Sep",
                BackgroundColor3 = T.Separator,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 0, 0, 19),
                Size             = UDim2.new(1, 0, 0, 1),
                Parent           = Header,
            })

            -- Body: y=21  5px top-padding  4px gap between elements
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

            local function NextOrder()
                elementCount += 1
                return elementCount
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddToggle  292×26
            -- ─────────────────────────────────────────────────────────────────
            --[[
              Box    14×14  x=4  y=6  centred: (26-14)/2 = 6 ✓
              Label  x=24  Size(1,-24,1,0)
            ]]
            function Section:AddToggle(label, default, callback, tooltip)
                default  = (default == true)
                callback = callback or function() end
                local state = default

                local Row = New("Frame", {
                    Name                   = "Toggle_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 26),
                    LayoutOrder            = NextOrder(),
                    Parent                 = Body,
                })

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
                    TweenQuad(Box, 0.10, {
                        BackgroundColor3 = state and T.Checkbox_On or T.Checkbox_BG,
                    })
                    if not silent then callback(state) end
                end

                Box.MouseButton1Click:Connect(function() Apply(not state, false) end)
                AttachTooltip(Row, tooltip)

                return {
                    Set    = function(_, v) Apply(v, true)         end,
                    Get    = function(_)    return state            end,
                    Toggle = function(_)    Apply(not state, false) end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddSlider  292×40
            -- ─────────────────────────────────────────────────────────────────
            --[[
              Label   pos(0,0)      Size(1,-50,0,18)  left
              ValBox  pos(1,-48,0,0) Size(0,48,0,18)  BG=Slider_ValBox
                ValLbl  fills ValBox  Code 11  click → manual entry TextBox
              TrackBG pos(0,26)     Size(1,0,0,6)
                Fill   pos(0,0)     Size(frac,0,1,0)
                Thumb  Size(0,8,0,16) pos(frac,-4,0,-5)  ZIndex=3
                  thumb y = -5 centres 16px on 6px track: (6-16)/2 = -5 ✓
              FIX: ValBox text shows FormatNum(value) before TextBox destroyed.
              FIX: Connections created ONLY while sliding; disconnected on end.
            ]]
            function Section:AddSlider(label, min, max, default, decimals, callback, tooltip)
                min      = tonumber(min)      or 0
                max      = tonumber(max)      or 100
                default  = tonumber(default)  or min
                decimals = tonumber(decimals) or 0
                callback = callback           or function() end
                default  = Clamp(default, min, max)
                local value = Round(default, decimals)

                local Row = New("Frame", {
                    Name                   = "Slider_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 40),
                    LayoutOrder            = NextOrder(),
                    Parent                 = Body,
                })

                New("TextLabel", {
                    Name                   = "Lbl",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 0, 0, 0),
                    Size                   = UDim2.new(1, -50, 0, 18),
                    Font                   = T.Font,
                    Text                   = label,
                    TextColor3             = T.Text,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    Parent                 = Row,
                })

                -- ValBox: 48×18 (2px breathing room on each side vs old 46)
                local ValBox = New("Frame", {
                    Name             = "ValBox",
                    BackgroundColor3 = T.Slider_ValBox,
                    BorderColor3     = T.Separator,
                    Position         = UDim2.new(1, -48, 0, 0),
                    Size             = UDim2.new(0, 48, 0, 18),
                    Parent           = Row,
                })

                local ValLbl = New("TextButton", {
                    Name                   = "ValLbl",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 1, 0),
                    Font                   = T.Font,
                    Text                   = FormatNum(value, decimals),
                    TextColor3             = T.SubText,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = ValBox,
                })

                local TrackBG = New("Frame", {
                    Name             = "TrackBG",
                    BackgroundColor3 = T.Slider_Track,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 26),
                    Size             = UDim2.new(1, 0, 0, 6),
                    Parent           = Row,
                })

                local Fill = New("Frame", {
                    Name             = "Fill",
                    BackgroundColor3 = T.Slider_Fill,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 0),
                    Size             = UDim2.new(0, 0, 1, 0),
                    Parent           = TrackBG,
                })

                local Thumb = New("Frame", {
                    Name             = "Thumb",
                    BackgroundColor3 = T.Slider_Thumb,
                    BorderSizePixel  = 0,
                    Size             = UDim2.new(0, 8, 0, 16),
                    Position         = UDim2.new(0, -4, 0, -5),
                    ZIndex           = 3,
                    Parent           = TrackBG,
                })

                local function SetValue(v, silent)
                    value = Round(Clamp(v, min, max), decimals)
                    local frac = Map(value, min, max, 0, 1)
                    Fill.Size      = UDim2.new(frac, 0, 1, 0)
                    Thumb.Position = UDim2.new(frac, -4, 0, -5)
                    ValLbl.Text    = FormatNum(value, decimals)
                    if not silent then callback(value) end
                end

                SetValue(value, true)

                local sliding     = false
                local moveConn    = nil
                local releaseConn = nil

                local function StopSliding()
                    sliding = false
                    if moveConn    then moveConn:Disconnect();    moveConn    = nil end
                    if releaseConn then releaseConn:Disconnect(); releaseConn = nil end
                end

                local function StartSliding(inp)
                    sliding = true
                    local absX = TrackBG.AbsolutePosition.X
                    local absW = TrackBG.AbsoluteSize.X
                    local frac = Clamp((inp.Position.X - absX) / absW, 0, 1)
                    SetValue(Map(frac, 0, 1, min, max), false)

                    moveConn = UserInputService.InputChanged:Connect(function(i)
                        if not sliding then return end
                        if i.UserInputType ~= Enum.UserInputType.MouseMovement
                        and i.UserInputType ~= Enum.UserInputType.Touch then return end
                        local fx = Clamp((i.Position.X - absX) / absW, 0, 1)
                        SetValue(Map(fx, 0, 1, min, max), false)
                    end)

                    releaseConn = UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1
                        or i.UserInputType == Enum.UserInputType.Touch then
                            StopSliding()
                        end
                    end)
                end

                TrackBG.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        StartSliding(inp)
                    end
                end)
                Thumb.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        StartSliding(inp)
                    end
                end)

                -- Manual entry via TextBox overlay on ValBox click
                ValLbl.MouseButton1Click:Connect(function()
                    if sliding then return end
                    local TB = New("TextBox", {
                        Name             = "_SliderInput",
                        BackgroundColor3 = T.Slider_ValBox,
                        BorderColor3     = T.Accent,
                        Size             = UDim2.new(1, 0, 1, 0),
                        Font             = T.Font,
                        Text             = FormatNum(value, decimals),
                        TextColor3       = T.Text,
                        TextSize         = 11,
                        TextXAlignment   = Enum.TextXAlignment.Center,
                        ClearTextOnFocus = true,
                        Parent           = ValBox,
                    })
                    TB:CaptureFocus()
                    TB.FocusLost:Connect(function()
                        local n = tonumber(TB.Text)
                        -- FIX: update display to properly formatted value before destroy
                        if n then SetValue(n, false) end
                        ValLbl.Text = FormatNum(value, decimals)
                        TB:Destroy()
                    end)
                end)

                AttachTooltip(Row, tooltip)

                return {
                    Set = function(_, v) SetValue(v, true) end,
                    Get = function(_)    return value      end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddDropdown  292×26 closed / 27+n×22 open
            -- ─────────────────────────────────────────────────────────────────
            --[[
              FIX: Registers with global dropdown registry for outside-click close.
              FIX: Set() accepts a silent flag.
              FIX: Arrow double-fire guard kept.
              DHeader  292×26  BG=Dropdown_BG  border=Separator
                SelLabel  x=6  Size(1,-26,1,0)  TruncateAtEnd
                Arrow     x=(1,-20)  Size(0,20,1,0)  ZIndex=2
              List  pos y=27  Size(1,0,0,n×22)  Visible toggled
                Item[i]  292×22  hover tween
            ]]
            function Section:AddDropdown(label, options, default, callback, tooltip)
                options  = options  or {}
                callback = callback or function() end
                local selected = default or options[1] or ""
                local isOpen   = false

                local CLOSED_H = 26
                local LIST_H   = #options * 22
                local OPEN_H   = 27 + LIST_H

                local Row = New("Frame", {
                    Name                   = "DD_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, CLOSED_H),
                    LayoutOrder            = NextOrder(),
                    ClipsDescendants       = true,
                    Parent                 = Body,
                })

                local DHeader = New("Frame", {
                    Name             = "DHeader",
                    BackgroundColor3 = T.Dropdown_BG,
                    BorderColor3     = T.Separator,
                    Size             = UDim2.new(1, 0, 0, 26),
                    Parent           = Row,
                })

                local SelLabel = New("TextLabel", {
                    Name                   = "SelLabel",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 8, 0, 0),
                    Size                   = UDim2.new(1, -28, 1, 0),
                    Font                   = T.Font,
                    Text                   = selected,
                    TextColor3             = T.Text,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    TextTruncate           = Enum.TextTruncate.AtEnd,
                    Parent                 = DHeader,
                })

                local Arrow = New("TextButton", {
                    Name                   = "Arrow",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(1, -20, 0, 0),
                    Size                   = UDim2.new(0, 20, 1, 0),
                    Font                   = T.Font,
                    Text                   = "▾",
                    TextColor3             = T.SubText,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    ZIndex                 = 2,
                    Parent                 = DHeader,
                })

                local List = New("Frame", {
                    Name             = "List",
                    BackgroundColor3 = T.Dropdown_List,
                    BorderColor3     = T.Separator,
                    Position         = UDim2.new(0, 0, 0, 27),
                    Size             = UDim2.new(1, 0, 0, LIST_H),
                    Visible          = false,
                    Parent           = Row,
                })

                local function SetOpen(open)
                    isOpen       = open
                    Arrow.Text   = isOpen and "▴" or "▾"
                    List.Visible = isOpen
                    Row.Size     = UDim2.new(1, 0, 0, isOpen and OPEN_H or CLOSED_H)
                    if isOpen then
                        RegisterDropdown(Row, function() SetOpen(false) end)
                    else
                        UnregisterDropdown(Row)
                    end
                end

                local function Toggle() SetOpen(not isOpen) end

                -- Guard DHeader so it doesn't double-fire with Arrow
                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    local mp = UserInputService:GetMouseLocation()
                    local ap = Arrow.AbsolutePosition
                    local as = Arrow.AbsoluteSize
                    if mp.X >= ap.X and mp.X <= ap.X + as.X
                    and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y then return end
                    Toggle()
                end)
                Arrow.MouseButton1Click:Connect(Toggle)

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
                        PaddingLeft = UDim.new(0, 8),
                        Parent      = ItemBtn,
                    })
                    itemRefs[opt] = ItemBtn

                    Item.MouseEnter:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_Hover })
                    end)
                    Item.MouseLeave:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_List })
                    end)

                    ItemBtn.MouseButton1Click:Connect(function()
                        if itemRefs[selected] then
                            itemRefs[selected].TextColor3 = T.Text
                        end
                        selected           = opt
                        SelLabel.Text      = selected
                        ItemBtn.TextColor3 = T.Dropdown_Sel
                        SetOpen(false)
                        callback(selected)
                    end)
                end

                AttachTooltip(DHeader, tooltip)

                return {
                    -- FIX: Set() now accepts optional silent parameter
                    Set = function(_, v, silent)
                        if itemRefs[selected] then
                            itemRefs[selected].TextColor3 = T.Text
                        end
                        selected      = v
                        SelLabel.Text = v
                        if itemRefs[v] then
                            itemRefs[v].TextColor3 = T.Dropdown_Sel
                        end
                        if isOpen then SetOpen(false) end
                        if not silent then callback(selected) end
                    end,
                    Get = function(_) return selected end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddMultiDropdown  292×26 closed / 27+n×22+22 open
            -- ─────────────────────────────────────────────────────────────────
            --[[
              FIX: selected table fully reset in Set() before iterating new values.
              FIX: Registers with global dropdown registry.
              FIX: Set() silent flag added.
              Checkbox per item  12×12  x=6  y=5  centred: (22-12)/2=5 ✓
              ItemLbl  x=24  Size(1,-30,1,0)
              Footer   22px  "Select All" | 1px | "Clear"
            ]]
            function Section:AddMultiDropdown(label, options, defaults, callback, tooltip)
                options  = options  or {}
                defaults = defaults or {}
                callback = callback or function() end

                local selected = {}
                for _, v in ipairs(defaults) do selected[v] = true end

                local isOpen   = false
                local CLOSED_H = 26
                local ITEM_H   = 22
                local FOOTER_H = 22
                local LIST_H   = #options * ITEM_H + FOOTER_H
                local OPEN_H   = 27 + LIST_H

                local Row = New("Frame", {
                    Name                   = "MDD_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, CLOSED_H),
                    LayoutOrder            = NextOrder(),
                    ClipsDescendants       = true,
                    Parent                 = Body,
                })

                local DHeader = New("Frame", {
                    Name             = "DHeader",
                    BackgroundColor3 = T.Dropdown_BG,
                    BorderColor3     = T.Separator,
                    Size             = UDim2.new(1, 0, 0, 26),
                    Parent           = Row,
                })

                local SelLabel = New("TextLabel", {
                    Name                   = "SelLabel",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 8, 0, 0),
                    Size                   = UDim2.new(1, -28, 1, 0),
                    Font                   = T.Font,
                    Text                   = label,
                    TextColor3             = T.DimText,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    TextTruncate           = Enum.TextTruncate.AtEnd,
                    Parent                 = DHeader,
                })

                local Arrow = New("TextButton", {
                    Name                   = "Arrow",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(1, -20, 0, 0),
                    Size                   = UDim2.new(0, 20, 1, 0),
                    Font                   = T.Font,
                    Text                   = "▾",
                    TextColor3             = T.SubText,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    ZIndex                 = 2,
                    Parent                 = DHeader,
                })

                local List = New("Frame", {
                    Name             = "List",
                    BackgroundColor3 = T.Dropdown_List,
                    BorderColor3     = T.Separator,
                    Position         = UDim2.new(0, 0, 0, 27),
                    Size             = UDim2.new(1, 0, 0, LIST_H),
                    Visible          = false,
                    Parent           = Row,
                })

                local function SetOpen(open)
                    isOpen       = open
                    Arrow.Text   = isOpen and "▴" or "▾"
                    List.Visible = isOpen
                    Row.Size     = UDim2.new(1, 0, 0, isOpen and OPEN_H or CLOSED_H)
                    if isOpen then
                        RegisterDropdown(Row, function() SetOpen(false) end)
                    else
                        UnregisterDropdown(Row)
                    end
                end

                local function Toggle() SetOpen(not isOpen) end

                local function GetSelection()
                    local out = {}
                    for _, opt in ipairs(options) do
                        if selected[opt] then table.insert(out, opt) end
                    end
                    return out
                end

                local function RefreshHeader()
                    local parts = {}
                    for _, opt in ipairs(options) do
                        if selected[opt] then table.insert(parts, opt) end
                    end
                    if #parts == 0 then
                        SelLabel.Text       = label
                        SelLabel.TextColor3 = T.DimText
                    else
                        SelLabel.Text       = table.concat(parts, ", ")
                        SelLabel.TextColor3 = T.Text
                    end
                end

                DHeader.InputBegan:Connect(function(inp)
                    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    local mp = UserInputService:GetMouseLocation()
                    local ap = Arrow.AbsolutePosition
                    local as = Arrow.AbsoluteSize
                    if mp.X >= ap.X and mp.X <= ap.X + as.X
                    and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y then return end
                    Toggle()
                end)
                Arrow.MouseButton1Click:Connect(Toggle)

                local itemBoxes = {}

                for i, opt in ipairs(options) do
                    local Item = New("Frame", {
                        Name             = "Item_" .. i,
                        BackgroundColor3 = T.Dropdown_List,
                        BorderSizePixel  = 0,
                        Position         = UDim2.new(0, 0, 0, (i - 1) * ITEM_H),
                        Size             = UDim2.new(1, 0, 0, ITEM_H),
                        Parent           = List,
                    })

                    local CB = New("Frame", {
                        Name             = "CB",
                        BackgroundColor3 = selected[opt] and T.Checkbox_On or T.Checkbox_BG,
                        BorderColor3     = T.Separator,
                        Position         = UDim2.new(0, 6, 0, 5),
                        Size             = UDim2.new(0, 12, 0, 12),
                        Parent           = Item,
                    })
                    itemBoxes[opt] = CB

                    local ItemLbl = New("TextLabel", {
                        Name                   = "Lbl",
                        BackgroundTransparency = 1,
                        BorderSizePixel        = 0,
                        Position               = UDim2.new(0, 24, 0, 0),
                        Size                   = UDim2.new(1, -30, 1, 0),
                        Font                   = T.Font,
                        Text                   = opt,
                        TextColor3             = selected[opt] and T.Dropdown_Sel or T.Text,
                        TextSize               = T.FontSize,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        TextYAlignment         = Enum.TextYAlignment.Center,
                        TextTruncate           = Enum.TextTruncate.AtEnd,
                        Parent                 = Item,
                    })

                    local ItemBtn = New("TextButton", {
                        BackgroundTransparency = 1,
                        BorderSizePixel        = 0,
                        Size                   = UDim2.new(1, 0, 1, 0),
                        Text                   = "",
                        AutoButtonColor        = false,
                        ZIndex                 = 2,
                        Parent                 = Item,
                    })

                    Item.MouseEnter:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_Hover })
                    end)
                    Item.MouseLeave:Connect(function()
                        TweenQuad(Item, 0.08, { BackgroundColor3 = T.Dropdown_List })
                    end)

                    ItemBtn.MouseButton1Click:Connect(function()
                        selected[opt] = not selected[opt]
                        TweenQuad(CB, 0.10, {
                            BackgroundColor3 = selected[opt] and T.Checkbox_On or T.Checkbox_BG,
                        })
                        ItemLbl.TextColor3 = selected[opt] and T.Dropdown_Sel or T.Text
                        RefreshHeader()
                        callback(GetSelection())
                    end)
                end

                -- Footer: "Select All" | 1px divider | "Clear"
                local Footer = New("Frame", {
                    Name             = "Footer",
                    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, #options * ITEM_H),
                    Size             = UDim2.new(1, 0, 0, FOOTER_H),
                    Parent           = List,
                })
                New("Frame", {   -- top 1px separator
                    BackgroundColor3 = T.Separator,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 0),
                    Size             = UDim2.new(1, 0, 0, 1),
                    Parent           = Footer,
                })
                local BtnAll = New("TextButton", {
                    Name                   = "BtnAll",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 0, 0, 1),
                    Size                   = UDim2.new(0.5, -1, 0, FOOTER_H - 1),
                    Font                   = T.Font,
                    Text                   = "Select All",
                    TextColor3             = T.SubText,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = Footer,
                })
                New("Frame", {   -- centre divider
                    BackgroundColor3 = T.Separator,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0.5, 0, 0, 1),
                    Size             = UDim2.new(0, 1, 0, FOOTER_H - 1),
                    Parent           = Footer,
                })
                local BtnClear = New("TextButton", {
                    Name                   = "BtnClear",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0.5, 1, 0, 1),
                    Size                   = UDim2.new(0.5, -1, 0, FOOTER_H - 1),
                    Font                   = T.Font,
                    Text                   = "Clear",
                    TextColor3             = T.SubText,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Center,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    AutoButtonColor        = false,
                    Parent                 = Footer,
                })

                BtnAll.MouseEnter:Connect(function()
                    TweenQuad(BtnAll, 0.08, { TextColor3 = T.Text })
                end)
                BtnAll.MouseLeave:Connect(function()
                    TweenQuad(BtnAll, 0.08, { TextColor3 = T.SubText })
                end)
                BtnClear.MouseEnter:Connect(function()
                    TweenQuad(BtnClear, 0.08, { TextColor3 = T.Text })
                end)
                BtnClear.MouseLeave:Connect(function()
                    TweenQuad(BtnClear, 0.08, { TextColor3 = T.SubText })
                end)

                local function ApplyAll(state)
                    for i, opt in ipairs(options) do
                        selected[opt] = state
                        TweenQuad(itemBoxes[opt], 0.10, {
                            BackgroundColor3 = state and T.Checkbox_On or T.Checkbox_BG,
                        })
                        local item = List:FindFirstChild("Item_" .. i)
                        if item then
                            local lbl = item:FindFirstChild("Lbl")
                            if lbl then
                                lbl.TextColor3 = state and T.Dropdown_Sel or T.Text
                            end
                        end
                    end
                    RefreshHeader()
                    callback(GetSelection())
                end

                BtnAll.MouseButton1Click:Connect(function()   ApplyAll(true)  end)
                BtnClear.MouseButton1Click:Connect(function() ApplyAll(false) end)

                AttachTooltip(DHeader, tooltip)
                RefreshHeader()

                return {
                    -- FIX: selected table fully reset before applying new values
                    Set = function(_, tbl, silent)
                        selected = {}
                        for _, v in ipairs(tbl) do selected[v] = true end
                        for i, opt in ipairs(options) do
                            local on = selected[opt] == true
                            TweenQuad(itemBoxes[opt], 0.10, {
                                BackgroundColor3 = on and T.Checkbox_On or T.Checkbox_BG,
                            })
                            local item = List:FindFirstChild("Item_" .. i)
                            if item then
                                local lbl = item:FindFirstChild("Lbl")
                                if lbl then
                                    lbl.TextColor3 = on and T.Dropdown_Sel or T.Text
                                end
                            end
                        end
                        RefreshHeader()
                        if not silent then callback(GetSelection()) end
                    end,
                    Get       = function(_) return GetSelection() end,
                    Clear     = function(_) ApplyAll(false)       end,
                    SelectAll = function(_) ApplyAll(true)        end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddTextInput  292×44
            -- ─────────────────────────────────────────────────────────────────
            --[[
              Lbl    pos(0,0)   Size(1,0,0,18)
              Field  pos(0,22)  Size(1,0,0,22)  BG=Slider_ValBox  border
                TB   fills Field  PaddingLeft/Right=6px
                     border → accent on focus, Separator on blur
                     FocusLost → callback(text, enterPressed)
                     live mode → callback(text, false) on every char change
            ]]
            function Section:AddTextInput(label, placeholder, callback, cfg)
                cfg         = cfg or {}
                placeholder = placeholder or ""
                callback    = callback    or function() end
                local live   = cfg.live == true
                local maxLen = tonumber(cfg.maxLength) or 0
                local tip    = cfg.tooltip

                local Row = New("Frame", {
                    Name                   = "TextInput_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 44),
                    LayoutOrder            = NextOrder(),
                    Parent                 = Body,
                })

                New("TextLabel", {
                    Name                   = "Lbl",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 0, 0, 0),
                    Size                   = UDim2.new(1, 0, 0, 18),
                    Font                   = T.Font,
                    Text                   = label,
                    TextColor3             = T.Text,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    Parent                 = Row,
                })

                local Field = New("Frame", {
                    Name             = "Field",
                    BackgroundColor3 = T.Slider_ValBox,
                    BorderColor3     = T.Separator,
                    Position         = UDim2.new(0, 0, 0, 22),
                    Size             = UDim2.new(1, 0, 0, 22),
                    Parent           = Row,
                })

                local TB = New("TextBox", {
                    Name                   = "TB",
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 1, 0),
                    Font                   = T.Font,
                    PlaceholderText        = placeholder,
                    PlaceholderColor3      = T.DimText,
                    Text                   = "",
                    TextColor3             = T.Text,
                    TextSize               = T.FontSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    ClearTextOnFocus       = false,
                    ClipsDescendants       = true,
                    Parent                 = Field,
                })
                New("UIPadding", {
                    PaddingLeft  = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    Parent       = TB,
                })

                if maxLen > 0 then
                    TB:GetPropertyChangedSignal("Text"):Connect(function()
                        if #TB.Text > maxLen then
                            TB.Text = string.sub(TB.Text, 1, maxLen)
                        end
                    end)
                end

                TB.Focused:Connect(function()
                    Field.BorderColor3 = T.Accent
                end)
                TB.FocusLost:Connect(function(enter)
                    Field.BorderColor3 = T.Separator
                    callback(TB.Text, enter)
                end)

                if live then
                    TB:GetPropertyChangedSignal("Text"):Connect(function()
                        callback(TB.Text, false)
                    end)
                end

                AttachTooltip(Row, tip)

                return {
                    Set   = function(_, v)  TB.Text = tostring(v or "") end,
                    Get   = function(_)     return TB.Text              end,
                    Clear = function(_)     TB.Text = ""                end,
                    Focus = function(_)     TB:CaptureFocus()           end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddButton  292×26
            -- ─────────────────────────────────────────────────────────────────
            --[[
              BG=Button_BG  border=Button_Bdr
              4px left accent stripe on hover/press only  (hidden when idle)
              Hover  → Button_Hover  fade 0.08s
              Press  → Button_Active flash 0.06s  then back to Button_Hover
              Text   Left/Center  PaddingLeft=10  Code 13
              Disabled state grays out text and blocks clicks.
            ]]
            function Section:AddButton(label, callback, tooltip)
                callback = callback or function() end
                local enabled = true

                local Row = New("Frame", {
                    Name                   = "Btn_" .. label,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 26),
                    LayoutOrder            = NextOrder(),
                    Parent                 = Body,
                })

                local Btn = New("TextButton", {
                    Name             = "Btn",
                    BackgroundColor3 = T.Button_BG,
                    BorderColor3     = T.Button_Bdr,
                    Size             = UDim2.new(1, 0, 1, 0),
                    Font             = T.Font,
                    Text             = label,
                    TextColor3       = T.Text,
                    TextSize         = T.FontSize,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextYAlignment   = Enum.TextYAlignment.Center,
                    AutoButtonColor  = false,
                    Parent           = Row,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    Parent      = Btn,
                })

                -- Accent stripe: 3px left edge, visible on hover/active only
                local Stripe = New("Frame", {
                    Name             = "Stripe",
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 0),
                    Size             = UDim2.new(0, 3, 1, 0),
                    Visible          = false,
                    ZIndex           = 2,
                    Parent           = Btn,
                })

                Btn.MouseEnter:Connect(function()
                    if not enabled then return end
                    Stripe.Visible = true
                    TweenQuad(Btn, 0.08, { BackgroundColor3 = T.Button_Hover })
                end)
                Btn.MouseLeave:Connect(function()
                    if not enabled then return end
                    Stripe.Visible = false
                    TweenQuad(Btn, 0.08, { BackgroundColor3 = T.Button_BG })
                end)
                Btn.MouseButton1Down:Connect(function()
                    if not enabled then return end
                    TweenQuad(Btn, 0.06, { BackgroundColor3 = T.Button_Active })
                end)
                Btn.MouseButton1Up:Connect(function()
                    if not enabled then return end
                    TweenQuad(Btn, 0.10, { BackgroundColor3 = T.Button_Hover })
                end)
                Btn.MouseButton1Click:Connect(function()
                    if not enabled then return end
                    callback()
                end)

                AttachTooltip(Row, tooltip)

                return {
                    SetEnabled = function(_, v)
                        enabled = v
                        Btn.TextColor3       = v and T.Text or T.Disabled_Text
                        Btn.BackgroundColor3 = v and T.Button_BG or T.Disabled_BG
                        Stripe.Visible       = false
                    end,
                    SetLabel = function(_, v) Btn.Text = tostring(v) end,
                    GetLabel = function(_)    return Btn.Text        end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddLabel  292×18  (read-only info text)
            -- FIX: NextOrder() was not called — elementCount wasn't incrementing.
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddLabel(text, tooltip)
                local Lbl = New("TextLabel", {
                    Name                   = "Label_" .. NextOrder(),   -- FIX
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 18),
                    Font                   = T.Font,
                    Text                   = text,
                    TextColor3             = T.DimText,
                    TextSize               = T.HdrSize,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    LayoutOrder            = elementCount,
                    Parent                 = Body,
                })
                AttachTooltip(Lbl, tooltip)
                return {
                    Set = function(_, v) Lbl.Text = tostring(v) end,
                    Get = function(_)    return Lbl.Text         end,
                }
            end

            -- ─────────────────────────────────────────────────────────────────
            -- AddSeparator  292×9  (1px line centred in 9px wrapper)
            -- ─────────────────────────────────────────────────────────────────
            function Section:AddSeparator()
                local Wrap = New("Frame", {
                    Name                   = "Sep_" .. NextOrder(),
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 9),
                    LayoutOrder            = elementCount,
                    Parent                 = Body,
                })
                New("Frame", {
                    BackgroundColor3 = T.Separator,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 4),
                    Size             = UDim2.new(1, 0, 0, 1),
                    Parent           = Wrap,
                })
            end

            return Section
        end  -- AddSection

        return Tab
    end  -- AddTab

    return Window
end  -- CreateWindow

return UILibrary
