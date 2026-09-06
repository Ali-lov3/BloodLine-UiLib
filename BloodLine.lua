local BloodLine = {}
BloodLine.__index = BloodLine

local core        = game:GetService("CoreGui")
local tween       = game:GetService("TweenService")
local uis         = game:GetService("UserInputService")
local plrs        = game:GetService("Players")
local runService  = game:GetService("RunService")
local http        = game:GetService("HttpService")
local lp          = plrs.LocalPlayer

local themes = {
    Red = {
        Accent      = Color3.fromRGB(220, 40, 60),
        AccentDark  = Color3.fromRGB(110, 15, 25),
        Background  = Color3.fromRGB(10, 10, 13),
        Surface     = Color3.fromRGB(16, 16, 20),
        Element     = Color3.fromRGB(22, 22, 28),
        Stroke      = Color3.fromRGB(36, 36, 46),
        Text        = Color3.fromRGB(240, 240, 245),
        Muted       = Color3.fromRGB(130, 130, 148)
    },
    Blue = {
        Accent      = Color3.fromRGB(50, 140, 255),
        AccentDark  = Color3.fromRGB(18, 65, 145),
        Background  = Color3.fromRGB(9, 12, 20),
        Surface     = Color3.fromRGB(14, 20, 30),
        Element     = Color3.fromRGB(20, 28, 42),
        Stroke      = Color3.fromRGB(35, 50, 72),
        Text        = Color3.fromRGB(240, 248, 255),
        Muted       = Color3.fromRGB(130, 155, 178)
    },
    Green = {
        Accent      = Color3.fromRGB(50, 210, 115),
        AccentDark  = Color3.fromRGB(18, 105, 60),
        Background  = Color3.fromRGB(9, 16, 12),
        Surface     = Color3.fromRGB(14, 26, 18),
        Element     = Color3.fromRGB(20, 36, 26),
        Stroke      = Color3.fromRGB(35, 62, 45),
        Text        = Color3.fromRGB(240, 255, 246),
        Muted       = Color3.fromRGB(130, 170, 148)
    },
    Purple = {
        Accent      = Color3.fromRGB(165, 90, 255),
        AccentDark  = Color3.fromRGB(82, 32, 145),
        Background  = Color3.fromRGB(14, 10, 20),
        Surface     = Color3.fromRGB(22, 16, 32),
        Element     = Color3.fromRGB(30, 22, 44),
        Stroke      = Color3.fromRGB(54, 38, 72),
        Text        = Color3.fromRGB(250, 245, 255),
        Muted       = Color3.fromRGB(160, 145, 182)
    },
    Midnight = {
        Accent      = Color3.fromRGB(95, 175, 255),
        AccentDark  = Color3.fromRGB(30, 80, 150),
        Background  = Color3.fromRGB(6, 9, 14),
        Surface     = Color3.fromRGB(11, 15, 24),
        Element     = Color3.fromRGB(16, 23, 36),
        Stroke      = Color3.fromRGB(28, 44, 64),
        Text        = Color3.fromRGB(235, 245, 255),
        Muted       = Color3.fromRGB(125, 148, 172)
    }
}

local function copyTheme(theme)
    local result = {}
    for key, value in pairs(theme) do result[key] = value end
    return result
end

local function resolveTheme(theme)
    if type(theme) == "string" then
        return themes[theme] and copyTheme(themes[theme]) or copyTheme(themes.Red)
    end
    if type(theme) == "table" then
        local result = copyTheme(themes.Red)
        for key, value in pairs(theme) do
            if result[key] ~= nil then result[key] = value end
        end
        return result
    end
    return copyTheme(themes.Red)
end

local currentTheme = resolveTheme("Red")
local accent       = currentTheme.Accent
local accentDark   = currentTheme.AccentDark
local bgDark       = currentTheme.Background
local bgMedium     = currentTheme.Surface
local bgLight      = currentTheme.Element
local strokeDark   = currentTheme.Stroke
local strokeAccent = currentTheme.Accent
local textMain     = currentTheme.Text
local textMuted    = currentTheme.Muted

local function setCurrentTheme(theme)
    currentTheme  = resolveTheme(theme)
    accent        = currentTheme.Accent
    accentDark    = currentTheme.AccentDark
    bgDark        = currentTheme.Background
    bgMedium      = currentTheme.Surface
    bgLight       = currentTheme.Element
    strokeDark    = currentTheme.Stroke
    strokeAccent  = currentTheme.Accent
    textMain      = currentTheme.Text
    textMuted     = currentTheme.Muted
end

local function snapshotTheme()
    return {
        Accent     = accent,
        AccentDark = accentDark,
        Background = bgDark,
        Surface    = bgMedium,
        Element    = bgLight,
        Stroke     = strokeDark,
        Text       = textMain,
        Muted      = textMuted
    }
end

local function colorFor(value, oldTheme, newTheme)
    local names = {"Accent","AccentDark","Background","Surface","Element","Stroke","Text","Muted"}
    for _, name in ipairs(names) do
        if value == oldTheme[name] then return newTheme[name] end
    end
    return value
end

local function sequenceFor(sequence, oldTheme, newTheme)
    local points = {}
    for _, point in ipairs(sequence.Keypoints) do
        table.insert(points, ColorSequenceKeypoint.new(point.Time, colorFor(point.Value, oldTheme, newTheme)))
    end
    return ColorSequence.new(points)
end

local function refreshTheme(root, oldTheme, newTheme)
    if not root then return end
    local objects = {root}
    for _, object in ipairs(root:GetDescendants()) do table.insert(objects, object) end
    for _, object in ipairs(objects) do
        pcall(function()
            if object:IsA("GuiObject") then
                object.BackgroundColor3 = colorFor(object.BackgroundColor3, oldTheme, newTheme)
            end
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                object.TextColor3 = colorFor(object.TextColor3, oldTheme, newTheme)
            end
            if object:IsA("TextBox") then
                object.PlaceholderColor3 = colorFor(object.PlaceholderColor3, oldTheme, newTheme)
            end
            if object:IsA("ImageLabel") or object:IsA("ImageButton") then
                object.ImageColor3 = colorFor(object.ImageColor3, oldTheme, newTheme)
            end
            if object:IsA("UIStroke") then
                object.Color = colorFor(object.Color, oldTheme, newTheme)
            end
            if object:IsA("ScrollingFrame") then
                object.ScrollBarImageColor3 = colorFor(object.ScrollBarImageColor3, oldTheme, newTheme)
            end
            if object:IsA("UIGradient") then
                object.Color = sequenceFor(object.Color, oldTheme, newTheme)
            end
        end)
    end
end

local configFolder   = "BloodLine"
local memoryConfigs  = {}
local memorySettings = {}

local function fileSupport()
    return type(isfile) == "function" and type(writefile) == "function" and type(readfile) == "function"
end

local function prepareFolder()
    if type(makefolder) == "function" and type(isfolder) == "function" then
        if not isfolder(configFolder) then pcall(makefolder, configFolder) end
    end
end

local function safeName(name)
    return tostring(name or ""):gsub("[^%w_%-%.]", "_")
end

local function readJson(path)
    if not fileSupport() then return nil end
    local ok, value = pcall(function()
        if not isfile(path) then return nil end
        return http:JSONDecode(readfile(path))
    end)
    return ok and value or nil
end

local function writeJson(path, value)
    if not fileSupport() then return false end
    prepareFolder()
    local ok = pcall(function() writefile(path, http:JSONEncode(value)) end)
    return ok
end

local function configPath(name)
    return configFolder .. "/" .. safeName(name) .. ".json"
end

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return {__type = "Color3", r = value.R, g = value.G, b = value.B}
    end
    if type(value) == "table" then
        local result = {}
        for key, item in pairs(value) do result[key] = encodeValue(item) end
        return result
    end
    return value
end

local function decodeValue(value)
    if type(value) ~= "table" then return value end
    if value.__type == "Color3" then
        return Color3.new(value.r or 0, value.g or 0, value.b or 0)
    end
    local result = {}
    for key, item in pairs(value) do result[key] = decodeValue(item) end
    return result
end

local function readSettings()
    return readJson(configFolder .. "/settings.json") or memorySettings
end

local function writeSettings(settings)
    memorySettings = settings
    writeJson(configFolder .. "/settings.json", settings)
end

local fastTween   = TweenInfo.new(0.10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local smoothTween = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local bounceTween = TweenInfo.new(0.22, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)

local Lucide
pcall(function()
    Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function ToVector2(v)
    if typeof(v) == "Vector2" then return v end
    if type(v) == "table" then return Vector2.new(v[1] or v.X or 0, v[2] or v.Y or 0) end
    return Vector2.new(0, 0)
end

local function ResolveIcon(icon)
    if type(icon) == "number" then return "rbxassetid://" .. icon end
    if type(icon) == "string" then
        if string.match(icon, "^rbxassetid://") then return icon end
        if string.match(icon, "^%d+$") then return "rbxassetid://" .. icon end
        local name = string.lower(icon)
        if type(Lucide) == "function" then
            local ok, data = pcall(Lucide, name)
            if ok and type(data) == "table" then
                local id  = data.id or data.Id or data[1]
                local sz  = data.imageRectSize   or data.ImageRectSize   or data[2]
                local off = data.imageRectOffset or data.ImageRectOffset or data[3]
                if id then return "rbxassetid://" .. tostring(id), off, sz end
            end
        elseif type(Lucide) == "table" then
            for _, set in { Lucide["48px"], Lucide["256px"], Lucide } do
                if type(set) == "table" then
                    local d = set[name]
                    if type(d) == "table" and d[1] then
                        return "rbxassetid://" .. tostring(d[1]), d[3], d[2]
                    end
                end
            end
        end
    end
    return "rbxassetid://0"
end

local function ApplyIcon(obj, icon)
    if not icon then return end
    local img, off, sz = ResolveIcon(icon)
    obj.Image = img
    obj.ImageRectOffset = off and ToVector2(off) or Vector2.new(0, 0)
    obj.ImageRectSize   = sz  and ToVector2(sz)  or Vector2.new(0, 0)
end

local notifyContainer
local notifyList

local function Notify(titleText, descText, duration, iconId)
    if not notifyContainer then return end
    duration = duration or 3

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = bgMedium
    card.ClipsDescendants = true
    card.Position = UDim2.new(1, 60, 0, 0)
    card.Parent = notifyContainer
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", card)
    stroke.Color = strokeDark
    stroke.Transparency = 0.2
    stroke.Thickness = 1

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 2, 1, -12)
    accentBar.Position = UDim2.new(0, 0, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = card
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local nIcon = Instance.new("ImageLabel")
    nIcon.Size = UDim2.new(0, 13, 0, 13)
    nIcon.Position = UDim2.new(0, 12, 0.5, -13)
    nIcon.BackgroundTransparency = 1
    nIcon.ImageColor3 = accent
    ApplyIcon(nIcon, iconId or "bell")
    nIcon.Parent = card

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -36, 0, 14)
    tLbl.Position = UDim2.new(0, 32, 0, 8)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = string.upper(titleText or "NOTIFICATION")
    tLbl.TextColor3 = textMain
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 9
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Size = UDim2.new(1, -36, 0, 13)
    dLbl.Position = UDim2.new(0, 32, 0, 24)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = descText or ""
    dLbl.TextColor3 = textMuted
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextSize = 8
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.Parent = card

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, 1)
    barBg.Position = UDim2.new(0, 0, 1, -1)
    barBg.BackgroundColor3 = strokeDark
    barBg.BorderSizePixel = 0
    barBg.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    tween:Create(card, smoothTween, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    tween:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

    task.delay(duration, function()
        local tw = tween:Create(card, smoothTween, {Position = UDim2.new(1, 60, 0, 0)})
        tween:Create(card,   smoothTween, {BackgroundTransparency = 1}):Play()
        tween:Create(stroke, smoothTween, {Transparency = 1}):Play()
        tween:Create(tLbl,   smoothTween, {TextTransparency = 1}):Play()
        tween:Create(dLbl,   smoothTween, {TextTransparency = 1}):Play()
        tween:Create(nIcon,  smoothTween, {ImageTransparency = 1}):Play()
        tw:Play()
        tw.Completed:Connect(function() card:Destroy() end)
    end)
end

local function addGroupBox(parent, titleText)
    local gb = Instance.new("Frame")
    gb.Size = UDim2.new(1, 0, 0, 0)
    gb.AutomaticSize = Enum.AutomaticSize.Y
    gb.BackgroundColor3 = bgMedium
    gb.ClipsDescendants = true
    gb.Parent = parent
    Instance.new("UICorner", gb).CornerRadius = UDim.new(0, 6)

    local gbStroke = Instance.new("UIStroke", gb)
    gbStroke.Color = strokeDark
    gbStroke.Thickness = 1

    Instance.new("UIListLayout", gb).SortOrder = Enum.SortOrder.LayoutOrder

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 28)
    topBar.BackgroundTransparency = 1
    topBar.LayoutOrder = 1
    topBar.Parent = gb

    local accentDot = Instance.new("Frame")
    accentDot.Size = UDim2.new(0, 3, 0, 10)
    accentDot.Position = UDim2.new(0, 10, 0.5, -5)
    accentDot.BackgroundColor3 = accent
    accentDot.BorderSizePixel = 0
    accentDot.Parent = topBar
    Instance.new("UICorner", accentDot).CornerRadius = UDim.new(1, 0)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -30, 1, 0)
    titleLbl.Position = UDim2.new(0, 18, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = string.upper(titleText)
    titleLbl.TextColor3 = textMain
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 9
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = topBar

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = strokeDark
    line.BorderSizePixel = 0
    line.Parent = topBar

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = 2
    container.Parent = gb

    local list = Instance.new("UIListLayout", container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 4)

    local pad = Instance.new("UIPadding", container)
    pad.PaddingTop    = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft   = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 10)

    return container
end

local function addLabel(parent, text, iconId)
    local lblFrame = Instance.new("Frame")
    lblFrame.Size = UDim2.new(1, 0, 0, 18)
    lblFrame.BackgroundTransparency = 1
    lblFrame.Parent = parent

    local lIcon = Instance.new("ImageLabel")
    lIcon.Size = UDim2.new(0, 11, 0, 11)
    lIcon.Position = UDim2.new(0, 2, 0.5, -5)
    lIcon.BackgroundTransparency = 1
    lIcon.ImageColor3 = textMuted
    ApplyIcon(lIcon, iconId or "info")
    lIcon.Parent = lblFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -18, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = lblFrame
end

local function addToggle(parent, text, iconId, defaultState, callback)
    local tgl = Instance.new("Frame")
    tgl.Size = UDim2.new(1, 0, 0, 24)
    tgl.BackgroundColor3 = bgLight
    tgl.Parent = parent
    Instance.new("UICorner", tgl).CornerRadius = UDim.new(0, 5)
    local tStroke = Instance.new("UIStroke", tgl)
    tStroke.Color = strokeDark
    tStroke.Thickness = 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = tgl

    local tIcon = Instance.new("ImageLabel")
    tIcon.Size = UDim2.new(0, 12, 0, 12)
    tIcon.Position = UDim2.new(0, 8, 0.5, -6)
    tIcon.BackgroundTransparency = 1
    tIcon.ImageColor3 = textMuted
    ApplyIcon(tIcon, iconId or "power")
    tIcon.Parent = tgl

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = tgl

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(0, 26, 0, 14)
    trackBg.Position = UDim2.new(1, -32, 0.5, -7)
    trackBg.BackgroundColor3 = strokeDark
    trackBg.Parent = tgl
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 10, 0, 10)
    circle.Position = UDim2.new(0, 2, 0.5, -5)
    circle.BackgroundColor3 = textMuted
    circle.Parent = trackBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = defaultState == true

    local function setState(nextState, silent)
        state = nextState == true
        tween:Create(trackBg, fastTween, {BackgroundColor3 = state and accent or strokeDark}):Play()
        tween:Create(circle,  bounceTween, {Position = state and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5), BackgroundColor3 = state and textMain or textMuted}):Play()
        tween:Create(tStroke, fastTween, {Color = state and accent or strokeDark}):Play()
        tween:Create(tIcon,   fastTween, {ImageColor3 = state and accent or textMuted}):Play()
        tween:Create(lbl,     fastTween, {TextColor3 = state and textMain or textMuted}):Play()
        if not silent and callback then callback(state) end
    end

    if state then
        trackBg.BackgroundColor3 = accent
        circle.Position = UDim2.new(1, -12, 0.5, -5)
        circle.BackgroundColor3 = textMain
        tStroke.Color = accent
        tIcon.ImageColor3 = accent
        lbl.TextColor3 = textMain
    end

    btn.MouseButton1Click:Connect(function()
        setState(not state)
        Notify(text, state and "Enabled" or "Disabled", 2, iconId or "power")
    end)

    return {
        Key  = text,
        Kind = "Toggle",
        Get  = function() return state end,
        Set  = setState
    }
end

local function addButton(parent, text, iconId, callback)
    local btnBg = Instance.new("Frame")
    btnBg.Size = UDim2.new(1, 0, 0, 24)
    btnBg.BackgroundColor3 = bgLight
    btnBg.Parent = parent
    Instance.new("UICorner", btnBg).CornerRadius = UDim.new(0, 5)

    local stroke = Instance.new("UIStroke", btnBg)
    stroke.Color = strokeDark
    stroke.Thickness = 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = btnBg

    local bIcon = Instance.new("ImageLabel")
    bIcon.Size = UDim2.new(0, 12, 0, 12)
    bIcon.Position = UDim2.new(0, 8, 0.5, -6)
    bIcon.BackgroundTransparency = 1
    bIcon.ImageColor3 = textMuted
    ApplyIcon(bIcon, iconId or "mouse-pointer-click")
    bIcon.Parent = btnBg

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -28, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btnBg

    btn.MouseEnter:Connect(function()
        tween:Create(stroke, fastTween, {Color = accent}):Play()
        tween:Create(lbl,    fastTween, {TextColor3 = textMain}):Play()
        tween:Create(bIcon,  fastTween, {ImageColor3 = accent}):Play()
        tween:Create(btnBg,  fastTween, {BackgroundColor3 = Color3.new(bgLight.R*1.15, bgLight.G*1.15, bgLight.B*1.15)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        tween:Create(stroke, fastTween, {Color = strokeDark}):Play()
        tween:Create(lbl,    fastTween, {TextColor3 = textMuted}):Play()
        tween:Create(bIcon,  fastTween, {ImageColor3 = textMuted}):Play()
        tween:Create(btnBg,  fastTween, {BackgroundColor3 = bgLight}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        tween:Create(btnBg, fastTween, {BackgroundColor3 = accentDark}):Play()
        tween:Create(stroke, fastTween, {Color = accent}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        tween:Create(btnBg,  smoothTween, {BackgroundColor3 = bgLight}):Play()
        tween:Create(stroke, smoothTween, {Color = strokeDark}):Play()
        Notify(text, "Action Executed", 2, iconId or "check")
        if callback then callback() end
    end)

    return {
        Key  = text,
        Kind = "Button",
        Get  = function() return nil end,
        Set  = function() end
    }
end

local function addSlider(parent, text, min, max, iconId, callback)
    local sl = Instance.new("Frame")
    sl.Size = UDim2.new(1, 0, 0, 32)
    sl.BackgroundColor3 = bgLight
    sl.Parent = parent
    Instance.new("UICorner", sl).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", sl).Color = strokeDark

    local sIcon = Instance.new("ImageLabel")
    sIcon.Size = UDim2.new(0, 12, 0, 12)
    sIcon.Position = UDim2.new(0, 8, 0, 6)
    sIcon.BackgroundTransparency = 1
    sIcon.ImageColor3 = textMuted
    ApplyIcon(sIcon, iconId or "sliders")
    sIcon.Parent = sl

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 0, 14)
    lbl.Position = UDim2.new(0, 26, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sl

    local valBg = Instance.new("Frame")
    valBg.Size = UDim2.new(0, 28, 0, 13)
    valBg.Position = UDim2.new(1, -32, 0, 4)
    valBg.BackgroundColor3 = bgDark
    valBg.Parent = sl
    Instance.new("UICorner", valBg).CornerRadius = UDim.new(0, 4)
    local vStroke = Instance.new("UIStroke", valBg)
    vStroke.Color = strokeDark

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, 0, 1, 0)
    val.BackgroundTransparency = 1
    val.Text = tostring(min)
    val.TextColor3 = textMain
    val.Font = Enum.Font.GothamBold
    val.TextSize = 8
    val.Parent = valBg

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -14, 0, 3)
    barBg.Position = UDim2.new(0, 7, 1, -7)
    barBg.BackgroundColor3 = strokeDark
    barBg.Parent = sl
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = accent
    fill.Parent = barBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 8, 0, 8)
    knob.Position = UDim2.new(1, -4, 0.5, -4)
    knob.BackgroundColor3 = textMain
    knob.Parent = fill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = bgDark
    knobStroke.Thickness = 1.5

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 10)
    btn.Position = UDim2.new(0, 0, 0, -5)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = barBg

    local value = min
    local draggingSlider = false

    local function setValue(nextValue, silent)
        value = math.clamp(tonumber(nextValue) or min, min, max)
        local position = (value - min) / (max - min)
        fill.Size = UDim2.new(position, 0, 1, 0)
        val.Text = tostring(math.floor(value))
        if not silent and callback then callback(math.floor(value)) end
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            tween:Create(knob,    fastTween, {Size = UDim2.new(0,10,0,10), Position = UDim2.new(1,-5,0.5,-5), BackgroundColor3 = accent}):Play()
            tween:Create(val,     fastTween, {TextColor3 = accent}):Play()
            tween:Create(vStroke, fastTween, {Color = accent}):Play()
            tween:Create(sIcon,   fastTween, {ImageColor3 = accent}):Play()
            tween:Create(lbl,     fastTween, {TextColor3 = textMain}):Play()
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if draggingSlider then
                Notify(text, "Set to " .. val.Text, 2, iconId or "sliders")
            end
            draggingSlider = false
            tween:Create(knob,    fastTween, {Size = UDim2.new(0,8,0,8), Position = UDim2.new(1,-4,0.5,-4), BackgroundColor3 = textMain}):Play()
            tween:Create(val,     fastTween, {TextColor3 = textMain}):Play()
            tween:Create(vStroke, fastTween, {Color = strokeDark}):Play()
            tween:Create(sIcon,   fastTween, {ImageColor3 = textMuted}):Play()
            tween:Create(lbl,     fastTween, {TextColor3 = textMuted}):Play()
        end
    end)
    uis.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            setValue(min + (max - min) * pos)
        end
    end)

    return {
        Key  = text,
        Kind = "Slider",
        Get  = function() return math.floor(value) end,
        Set  = setValue
    }
end

local function addDropdown(parent, text, items, iconId, callback)
    items = items or {}
    local dp = Instance.new("Frame")
    dp.Size = UDim2.new(1, 0, 0, 24)
    dp.BackgroundColor3 = bgLight
    dp.ClipsDescendants = true
    dp.Parent = parent
    Instance.new("UICorner", dp).CornerRadius = UDim.new(0, 5)
    local dpStroke = Instance.new("UIStroke", dp)
    dpStroke.Color = strokeDark
    dpStroke.Thickness = 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = dp

    local dIcon = Instance.new("ImageLabel")
    dIcon.Size = UDim2.new(0, 12, 0, 12)
    dIcon.Position = UDim2.new(0, 8, 0.5, -6)
    dIcon.BackgroundTransparency = 1
    dIcon.ImageColor3 = textMuted
    ApplyIcon(dIcon, iconId or "list")
    dIcon.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -44, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 11, 0, 11)
    arrow.Position = UDim2.new(1, -18, 0.5, -5)
    arrow.BackgroundTransparency = 1
    arrow.ImageColor3 = textMuted
    ApplyIcon(arrow, "chevron-down")
    arrow.Parent = btn

    local dpList = Instance.new("UIListLayout", dp)
    dpList.SortOrder            = Enum.SortOrder.LayoutOrder
    dpList.Padding              = UDim.new(0, 3)
    dpList.HorizontalAlignment  = Enum.HorizontalAlignment.Center

    local pdd = Instance.new("UIPadding", dp)
    pdd.PaddingBottom = UDim.new(0, 3)

    local itemsCont = Instance.new("Frame")
    itemsCont.Size = UDim2.new(1, 0, 0, 0)
    itemsCont.BackgroundTransparency = 1
    itemsCont.Parent = dp

    local iList = Instance.new("UIListLayout", itemsCont)
    iList.SortOrder            = Enum.SortOrder.LayoutOrder
    iList.Padding              = UDim.new(0, 2)
    iList.HorizontalAlignment  = Enum.HorizontalAlignment.Center

    local open = false
    local selected
    local currentItems = {}
    local itemButtons  = {}
    local targetSize   = 24

    for _, item in ipairs(items) do
        table.insert(currentItems, item)
        local iBtn = Instance.new("TextButton")
        iBtn.Size = UDim2.new(1, -8, 0, 20)
        iBtn.BackgroundColor3 = bgDark
        iBtn.AutoButtonColor = false
        iBtn.Text = ""
        iBtn.Parent = itemsCont
        Instance.new("UICorner", iBtn).CornerRadius = UDim.new(0, 4)

        local iStroke = Instance.new("UIStroke", iBtn)
        iStroke.Color = strokeDark

        local iText = Instance.new("TextLabel")
        iText.Size = UDim2.new(1, -12, 1, 0)
        iText.Position = UDim2.new(0, 8, 0, 0)
        iText.BackgroundTransparency = 1
        iText.Text = item
        iText.TextColor3 = textMuted
        iText.Font = Enum.Font.Gotham
        iText.TextSize = 8.5
        iText.TextXAlignment = Enum.TextXAlignment.Left
        iText.Parent = iBtn
        table.insert(itemButtons, iBtn)

        targetSize = targetSize + 22

        iBtn.MouseEnter:Connect(function()
            tween:Create(iBtn,  fastTween, {BackgroundColor3 = bgMedium}):Play()
            tween:Create(iText, fastTween, {TextColor3 = textMain}):Play()
        end)
        iBtn.MouseLeave:Connect(function()
            tween:Create(iBtn,  fastTween, {BackgroundColor3 = bgDark}):Play()
            tween:Create(iText, fastTween, {TextColor3 = textMuted}):Play()
        end)
        iBtn.MouseButton1Click:Connect(function()
            selected = item
            lbl.Text = text .. ": " .. item
            open = false
            tween:Create(arrow,    fastTween, {Rotation = 0}):Play()
            tween:Create(dpStroke, fastTween, {Color = strokeDark}):Play()
            tween:Create(dIcon,    fastTween, {ImageColor3 = textMuted}):Play()
            tween:Create(lbl,      fastTween, {TextColor3 = textMuted}):Play()
            tween:Create(dp,       fastTween, {Size = UDim2.new(1,0,0,24)}):Play()
            Notify(text, "Selected " .. item, 2, iconId or "list")
            if callback then callback(item) end
        end)
    end

    targetSize = targetSize + 3
    itemsCont.Size = UDim2.new(1, 0, 0, targetSize - 24)

    btn.MouseButton1Click:Connect(function()
        open = not open
        tween:Create(arrow,    bounceTween, {Rotation = open and 180 or 0}):Play()
        tween:Create(dpStroke, fastTween,   {Color = open and accent or strokeDark}):Play()
        tween:Create(dIcon,    fastTween,   {ImageColor3 = open and accent or textMuted}):Play()
        tween:Create(lbl,      fastTween,   {TextColor3 = open and textMain or textMuted}):Play()
        tween:Create(dp,       fastTween,   {Size = UDim2.new(1,0,0, open and targetSize or 24)}):Play()
    end)

    local function setValue(value, silent)
        for _, item in ipairs(currentItems) do
            if item == value then
                selected = value
                lbl.Text = text .. ": " .. tostring(value)
                if not silent and callback then callback(value) end
                return true
            end
        end
        return false
    end

    local function setItems(nextItems)
        local template = itemButtons[1]
        if not template then return end
        template = template:Clone()
        for _, child in ipairs(itemsCont:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        currentItems  = nextItems or {}
        itemButtons   = {}
        selected      = nil
        targetSize    = 24
        for _, item in ipairs(currentItems) do
            local iBtn = template:Clone()
            iBtn.Parent = itemsCont
            local iText = iBtn:FindFirstChildWhichIsA("TextLabel")
            if iText then iText.Text = tostring(item) end
            table.insert(itemButtons, iBtn)
            targetSize = targetSize + 22
            iBtn.MouseEnter:Connect(function()
                tween:Create(iBtn, fastTween, {BackgroundColor3 = bgMedium}):Play()
                if iText then tween:Create(iText, fastTween, {TextColor3 = textMain}):Play() end
            end)
            iBtn.MouseLeave:Connect(function()
                tween:Create(iBtn, fastTween, {BackgroundColor3 = bgDark}):Play()
                if iText then tween:Create(iText, fastTween, {TextColor3 = textMuted}):Play() end
            end)
            iBtn.MouseButton1Click:Connect(function()
                setValue(item)
                open = false
                tween:Create(arrow,    fastTween, {Rotation = 0}):Play()
                tween:Create(dpStroke, fastTween, {Color = strokeDark}):Play()
                tween:Create(dIcon,    fastTween, {ImageColor3 = textMuted}):Play()
                tween:Create(lbl,      fastTween, {TextColor3 = textMuted}):Play()
                tween:Create(dp,       fastTween, {Size = UDim2.new(1, 0, 0, 24)}):Play()
                Notify(text, "Selected " .. tostring(item), 2, iconId or "list")
            end)
        end
        targetSize = targetSize + 3
        itemsCont.Size = UDim2.new(1, 0, 0, targetSize - 24)
    end

    return {
        Key      = text,
        Kind     = "Dropdown",
        Get      = function() return selected end,
        Set      = setValue,
        SetItems = setItems,
        GetItems = function() return currentItems end
    }
end

local function addMultiDropdown(parent, text, items, iconId, callback)
    local dp = Instance.new("Frame")
    dp.Size = UDim2.new(1, 0, 0, 24)
    dp.BackgroundColor3 = bgLight
    dp.ClipsDescendants = true
    dp.Parent = parent
    Instance.new("UICorner", dp).CornerRadius = UDim.new(0, 5)
    local dpStroke = Instance.new("UIStroke", dp)
    dpStroke.Color = strokeDark
    dpStroke.Thickness = 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = dp

    local dIcon = Instance.new("ImageLabel")
    dIcon.Size = UDim2.new(0, 12, 0, 12)
    dIcon.Position = UDim2.new(0, 8, 0.5, -6)
    dIcon.BackgroundTransparency = 1
    dIcon.ImageColor3 = textMuted
    ApplyIcon(dIcon, iconId or "layers")
    dIcon.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -44, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": None"
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 11, 0, 11)
    arrow.Position = UDim2.new(1, -18, 0.5, -5)
    arrow.BackgroundTransparency = 1
    arrow.ImageColor3 = textMuted
    ApplyIcon(arrow, "chevron-down")
    arrow.Parent = btn

    local dpList = Instance.new("UIListLayout", dp)
    dpList.SortOrder            = Enum.SortOrder.LayoutOrder
    dpList.Padding              = UDim.new(0, 3)
    dpList.HorizontalAlignment  = Enum.HorizontalAlignment.Center

    local pdd = Instance.new("UIPadding", dp)
    pdd.PaddingBottom = UDim.new(0, 3)

    local itemsCont = Instance.new("Frame")
    itemsCont.Size = UDim2.new(1, 0, 0, 0)
    itemsCont.BackgroundTransparency = 1
    itemsCont.Parent = dp

    local iList = Instance.new("UIListLayout", itemsCont)
    iList.SortOrder            = Enum.SortOrder.LayoutOrder
    iList.Padding              = UDim.new(0, 2)
    iList.HorizontalAlignment  = Enum.HorizontalAlignment.Center

    local selected   = {}
    local open       = false
    local targetSize = 24

    local function updateText(silent)
        local list = {}
        for item, st in pairs(selected) do
            if st then table.insert(list, item) end
        end
        lbl.Text = text .. ": " .. (#list == 0 and "None" or table.concat(list, ", "))
        if not silent and callback then callback(selected) end
    end

    for _, item in ipairs(items) do
        selected[item] = false

        local iBtn = Instance.new("TextButton")
        iBtn.Size = UDim2.new(1, -8, 0, 20)
        iBtn.BackgroundColor3 = bgDark
        iBtn.AutoButtonColor = false
        iBtn.Text = ""
        iBtn.Parent = itemsCont
        Instance.new("UICorner", iBtn).CornerRadius = UDim.new(0, 4)

        local iStroke = Instance.new("UIStroke", iBtn)
        iStroke.Color = strokeDark

        local iText = Instance.new("TextLabel")
        iText.Size = UDim2.new(1, -24, 1, 0)
        iText.Position = UDim2.new(0, 8, 0, 0)
        iText.BackgroundTransparency = 1
        iText.Text = item
        iText.TextColor3 = textMuted
        iText.Font = Enum.Font.Gotham
        iText.TextSize = 8.5
        iText.TextXAlignment = Enum.TextXAlignment.Left
        iText.Parent = iBtn

        local checkBox = Instance.new("Frame")
        checkBox.Size = UDim2.new(0, 8, 0, 8)
        checkBox.Position = UDim2.new(1, -12, 0.5, -4)
        checkBox.BackgroundColor3 = strokeDark
        checkBox.Parent = iBtn
        Instance.new("UICorner", checkBox).CornerRadius = UDim.new(0, 2)

        local checkMark = Instance.new("Frame")
        checkMark.Size = UDim2.new(0, 4, 0, 4)
        checkMark.Position = UDim2.new(0.5, -2, 0.5, -2)
        checkMark.BackgroundColor3 = textMain
        checkMark.BackgroundTransparency = 1
        checkMark.Parent = checkBox
        Instance.new("UICorner", checkMark).CornerRadius = UDim.new(0, 1)

        targetSize = targetSize + 22

        iBtn.MouseButton1Click:Connect(function()
            selected[item] = not selected[item]
            local st = selected[item]
            tween:Create(iStroke,   fastTween, {Color = st and accent or strokeDark}):Play()
            tween:Create(iText,     fastTween, {TextColor3 = st and textMain or textMuted}):Play()
            tween:Create(checkBox,  fastTween, {BackgroundColor3 = st and accent or strokeDark}):Play()
            tween:Create(checkMark, fastTween, {BackgroundTransparency = st and 0 or 1}):Play()
            updateText()
        end)
    end

    targetSize = targetSize + 3
    itemsCont.Size = UDim2.new(1, 0, 0, targetSize - 24)

    btn.MouseButton1Click:Connect(function()
        open = not open
        tween:Create(arrow,    bounceTween, {Rotation = open and 180 or 0}):Play()
        tween:Create(dpStroke, fastTween,   {Color = open and accent or strokeDark}):Play()
        tween:Create(dIcon,    fastTween,   {ImageColor3 = open and accent or textMuted}):Play()
        tween:Create(lbl,      fastTween,   {TextColor3 = open and textMain or textMuted}):Play()
        tween:Create(dp,       fastTween,   {Size = UDim2.new(1,0,0, open and targetSize or 24)}):Play()
    end)

    local function setValues(values, silent)
        for item in pairs(selected) do selected[item] = false end
        if type(values) == "table" then
            for item, state in pairs(values) do
                if selected[item] ~= nil then selected[item] = state == true end
            end
        end
        for _, itemButton in ipairs(itemsCont:GetChildren()) do
            if itemButton:IsA("TextButton") then
                local itemText   = itemButton:FindFirstChildWhichIsA("TextLabel")
                local name       = itemText and itemText.Text
                local itemState  = name and selected[name] == true
                local itemStroke = itemButton:FindFirstChildWhichIsA("UIStroke")
                local box        = itemButton:FindFirstChildWhichIsA("Frame")
                if itemStroke then itemStroke.Color = itemState and accent or strokeDark end
                if itemText   then itemText.TextColor3 = itemState and textMain or textMuted end
                if box        then box.BackgroundColor3 = itemState and accent or strokeDark end
            end
        end
        updateText(silent)
    end

    return {
        Key  = text,
        Kind = "MultiDropdown",
        Get  = function()
            local result = {}
            for item, state in pairs(selected) do result[item] = state end
            return result
        end,
        Set  = setValues
    }
end

local function addColorpicker(parent, text, defaultColor, iconId, callback)
    local cp = Instance.new("Frame")
    cp.Size = UDim2.new(1, 0, 0, 24)
    cp.BackgroundColor3 = bgLight
    cp.ClipsDescendants = true
    cp.Parent = parent
    Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 5)
    local cpStroke = Instance.new("UIStroke", cp)
    cpStroke.Color = strokeDark
    cpStroke.Thickness = 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = cp

    local cIcon = Instance.new("ImageLabel")
    cIcon.Size = UDim2.new(0, 12, 0, 12)
    cIcon.Position = UDim2.new(0, 8, 0.5, -6)
    cIcon.BackgroundTransparency = 1
    cIcon.ImageColor3 = textMuted
    ApplyIcon(cIcon, iconId or "palette")
    cIcon.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -56, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 16, 0, 16)
    preview.Position = UDim2.new(1, -22, 0.5, -8)
    preview.BackgroundColor3 = defaultColor or accent
    preview.Parent = btn
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", preview).Color = strokeDark

    local pickerBox = Instance.new("Frame")
    pickerBox.Size = UDim2.new(1, -10, 0, 134)
    pickerBox.Position = UDim2.new(0, 5, 0, 27)
    pickerBox.BackgroundColor3 = bgDark
    pickerBox.Parent = cp
    Instance.new("UICorner", pickerBox).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", pickerBox).Color = strokeDark

    local hexInput = Instance.new("TextBox")
    hexInput.Size = UDim2.new(1, -10, 0, 16)
    hexInput.Position = UDim2.new(0, 5, 0, 5)
    hexInput.BackgroundColor3 = bgMedium
    hexInput.TextColor3 = textMain
    hexInput.Font = Enum.Font.Code
    hexInput.TextSize = 9
    hexInput.Parent = pickerBox
    Instance.new("UICorner", hexInput).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", hexInput).Color = strokeDark

    local satValCanvas = Instance.new("ImageLabel")
    satValCanvas.Size = UDim2.new(1, -28, 0, 78)
    satValCanvas.Position = UDim2.new(0, 5, 0, 25)
    satValCanvas.Image = "rbxassetid://4155801252"
    satValCanvas.BackgroundColor3 = defaultColor or accent
    satValCanvas.Parent = pickerBox
    Instance.new("UICorner", satValCanvas).CornerRadius = UDim.new(0, 4)

    local cursor = Instance.new("Frame")
    cursor.Size = UDim2.new(0, 6, 0, 6)
    cursor.AnchorPoint = Vector2.new(0.5, 0.5)
    cursor.BackgroundColor3 = textMain
    cursor.Parent = satValCanvas
    Instance.new("UICorner", cursor).CornerRadius = UDim.new(1, 0)
    local cStroke = Instance.new("UIStroke", cursor)
    cStroke.Color = bgDark
    cStroke.Thickness = 1.5

    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.new(0, 10, 0, 78)
    hueSlider.Position = UDim2.new(1, -14, 0, 25)
    hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSlider.Parent = pickerBox
    Instance.new("UICorner", hueSlider).CornerRadius = UDim.new(0, 4)

    local hueGrad = Instance.new("UIGradient", hueSlider)
    hueGrad.Rotation = 90
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,     Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.5,   Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(1,     Color3.fromRGB(255,0,0))
    })

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(1, 4, 0, 2)
    hueBar.AnchorPoint = Vector2.new(0, 0.5)
    hueBar.Position = UDim2.new(0, -2, 0, 0)
    hueBar.BackgroundColor3 = textMain
    hueBar.Parent = hueSlider
    Instance.new("UIStroke", hueBar).Color = bgDark

    local rgbDisplay = Instance.new("TextLabel")
    rgbDisplay.Size = UDim2.new(1, -10, 0, 16)
    rgbDisplay.Position = UDim2.new(0, 5, 0, 107)
    rgbDisplay.BackgroundColor3 = accent
    rgbDisplay.TextColor3 = textMain
    rgbDisplay.Font = Enum.Font.GothamBold
    rgbDisplay.TextSize = 8
    rgbDisplay.Parent = pickerBox
    Instance.new("UICorner", rgbDisplay).CornerRadius = UDim.new(0, 4)

    local h, s, v = Color3.toHSV(defaultColor or accent)

    local function updateColor(silent)
        local color = Color3.fromHSV(h, s, v)
        satValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        preview.BackgroundColor3 = color
        rgbDisplay.BackgroundColor3 = color
        rgbDisplay.Text = string.format("rgb(%d, %d, %d)", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
        hexInput.Text = "#" .. color:ToHex():upper()
        if not silent and callback then callback(color) end
    end
    updateColor()

    local draggingHue = false
    local draggingSV  = false

    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
        end
    end)
    satValCanvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = false
            draggingSV  = false
        end
    end)
    uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if draggingHue then
                local y = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                hueBar.Position = UDim2.new(0, -2, y, 0)
                h = 1 - y
                updateColor()
            elseif draggingSV then
                local x = math.clamp((input.Position.X - satValCanvas.AbsolutePosition.X) / satValCanvas.AbsoluteSize.X, 0, 1)
                local y = math.clamp((input.Position.Y - satValCanvas.AbsolutePosition.Y) / satValCanvas.AbsoluteSize.Y, 0, 1)
                cursor.Position = UDim2.new(x, 0, y, 0)
                s = x
                v = 1 - y
                updateColor()
            end
        end
    end)

    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        local ok, newColor = pcall(function() return Color3.fromHex(hex) end)
        if ok and newColor then
            h, s, v = Color3.toHSV(newColor)
            cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueBar.Position = UDim2.new(0, -2, 1 - h, 0)
            updateColor()
        end
    end)

    local open = false
    btn.MouseButton1Click:Connect(function()
        open = not open
        tween:Create(cpStroke, fastTween, {Color = open and accent or strokeDark}):Play()
        tween:Create(cIcon,    fastTween, {ImageColor3 = open and accent or textMuted}):Play()
        tween:Create(lbl,      fastTween, {TextColor3 = open and textMain or textMuted}):Play()
        tween:Create(cp,       fastTween, {Size = UDim2.new(1,0,0, open and 165 or 24)}):Play()
    end)

    return {
        Key  = text,
        Kind = "Colorpicker",
        Get  = function() return Color3.fromHSV(h, s, v) end,
        Set  = function(value, silent)
            if typeof(value) ~= "Color3" then return false end
            h, s, v = Color3.toHSV(value)
            cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueBar.Position = UDim2.new(0, -2, 1 - h, 0)
            updateColor(silent)
            return true
        end
    }
end

local function addTextBox(parent, text, placeholder, iconId, callback)
    local tbFrame = Instance.new("Frame")
    tbFrame.Size = UDim2.new(1, 0, 0, 24)
    tbFrame.BackgroundColor3 = bgLight
    tbFrame.Parent = parent
    Instance.new("UICorner", tbFrame).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke", tbFrame)
    stroke.Color = strokeDark
    stroke.Thickness = 1

    local tbIcon = Instance.new("ImageLabel")
    tbIcon.Size = UDim2.new(0, 12, 0, 12)
    tbIcon.Position = UDim2.new(0, 8, 0.5, -6)
    tbIcon.BackgroundTransparency = 1
    tbIcon.ImageColor3 = textMuted
    ApplyIcon(tbIcon, iconId or "terminal")
    tbIcon.Parent = tbFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.38, 0, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = tbFrame

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(0.58, -8, 0, 16)
    inputBg.Position = UDim2.new(0.42, 0, 0.5, -8)
    inputBg.BackgroundColor3 = bgDark
    inputBg.Parent = tbFrame
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 4)
    local inStroke = Instance.new("UIStroke", inputBg)
    inStroke.Color = strokeDark

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -8, 1, 0)
    box.Position = UDim2.new(0, 4, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = ""
    box.PlaceholderText = placeholder or "..."
    box.TextColor3 = textMain
    box.PlaceholderColor3 = Color3.fromRGB(75, 75, 92)
    box.Font = Enum.Font.Gotham
    box.TextSize = 8.5
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = inputBg

    box.Focused:Connect(function()
        tween:Create(stroke,   fastTween, {Color = accent}):Play()
        tween:Create(inStroke, fastTween, {Color = accent}):Play()
        tween:Create(tbIcon,   fastTween, {ImageColor3 = accent}):Play()
        tween:Create(lbl,      fastTween, {TextColor3 = textMain}):Play()
    end)
    box.FocusLost:Connect(function(enterPressed)
        tween:Create(stroke,   fastTween, {Color = strokeDark}):Play()
        tween:Create(inStroke, fastTween, {Color = strokeDark}):Play()
        tween:Create(tbIcon,   fastTween, {ImageColor3 = textMuted}):Play()
        tween:Create(lbl,      fastTween, {TextColor3 = textMuted}):Play()
        if enterPressed and box.Text ~= "" then
            Notify(text, "Input: " .. box.Text, 2, iconId or "terminal")
            if callback then callback(box.Text) end
        end
    end)

    return {
        Key  = text,
        Kind = "TextBox",
        Get  = function() return box.Text end,
        Set  = function(value, silent)
            box.Text = tostring(value or "")
            if not silent and callback then callback(box.Text) end
        end
    }
end

local function addKeybind(parent, text, defaultKey, iconId, callback)
    local kbFrame = Instance.new("Frame")
    kbFrame.Size = UDim2.new(1, 0, 0, 24)
    kbFrame.BackgroundColor3 = bgLight
    kbFrame.Parent = parent
    Instance.new("UICorner", kbFrame).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke", kbFrame)
    stroke.Color = strokeDark
    stroke.Thickness = 1

    local kIcon = Instance.new("ImageLabel")
    kIcon.Size = UDim2.new(0, 12, 0, 12)
    kIcon.Position = UDim2.new(0, 8, 0.5, -6)
    kIcon.BackgroundTransparency = 1
    kIcon.ImageColor3 = textMuted
    ApplyIcon(kIcon, iconId or "command")
    kIcon.Parent = kbFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -66, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = kbFrame

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 50, 0, 15)
    bindBtn.Position = UDim2.new(1, -56, 0.5, -7)
    bindBtn.BackgroundColor3 = bgDark
    bindBtn.AutoButtonColor = false
    bindBtn.Text = defaultKey or "NONE"
    bindBtn.TextColor3 = accent
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 7.5
    bindBtn.Parent = kbFrame
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)
    local btnStroke = Instance.new("UIStroke", bindBtn)
    btnStroke.Color = strokeDark

    local waiting = false
    bindBtn.MouseButton1Click:Connect(function()
        waiting = true
        bindBtn.Text = "..."
        tween:Create(btnStroke, fastTween, {Color = accent}):Play()
        tween:Create(kIcon,     fastTween, {ImageColor3 = accent}):Play()
        tween:Create(lbl,       fastTween, {TextColor3 = textMain}):Play()
    end)
    uis.InputBegan:Connect(function(input)
        if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            bindBtn.Text = string.upper(key)
            waiting = false
            tween:Create(btnStroke, fastTween, {Color = strokeDark}):Play()
            tween:Create(kIcon,     fastTween, {ImageColor3 = textMuted}):Play()
            tween:Create(lbl,       fastTween, {TextColor3 = textMuted}):Play()
            Notify(text, "Bound to " .. key, 2, iconId or "command")
            if callback then callback(key) end
        end
    end)

    return {
        Key  = text,
        Kind = "Keybind",
        Get  = function() return bindBtn.Text end,
        Set  = function(value, silent)
            bindBtn.Text = tostring(value or "NONE")
            if not silent and callback then callback(bindBtn.Text) end
        end
    }
end

local function makeGroupBoxObject(container, window, tab)
    local GB = {}

    function GB:AddToggle(text, icon, default, callback)
        local control = addToggle(container, text, icon, default, callback)
        if window then window:_registerControl(control, tab) end
        return GB
    end

    function GB:AddButton(text, icon, callback)
        local control = addButton(container, text, icon, callback)
        if window then window:_registerControl(control, tab) end
        return GB
    end

    function GB:AddSlider(text, min, max, icon, callback)
        local control = addSlider(container, text, min, max, icon, callback)
        if window then window:_registerControl(control, tab) end
        return GB
    end

    function GB:AddDropdown(text, items, icon, callback)
        local control = addDropdown(container, text, items, icon, callback)
        if window then window:_registerControl(control, tab) end
        return GB
    end

    function GB:AddMultiDropdown(text, items, icon, callback)
        local control = addMultiDropdown(container, text, items, icon, callback)
        if window then window:_registerControl(control, tab) end
        return GB
    end

    function GB:AddColorpicker(text, default, icon, callback)
        local control = addColorpicker(container, text, default, icon, callback)
        if window then window:_registerControl(control, tab) end
        return GB
    end

    function GB:AddTextBox(text, placeholder, icon, callback)
        local control = addTextBox(container, text, placeholder, icon, callback)
        if window then window:_registerControl(control, tab) end
        return GB
    end

    function GB:AddKeybind(text, defaultKey, icon, callback)
        local control = addKeybind(container, text, defaultKey, icon, callback)
        if window then window:_registerControl(control, tab) end
        return GB
    end

    function GB:AddLabel(text, icon)
        addLabel(container, text, icon)
        return GB
    end

    return GB
end

function BloodLine:CreateWindow(config)
    config = config or {}
    if config.Theme then setCurrentTheme(config.Theme) end
    local windowTitle  = config.Title  or "BloodLine"
    local windowFooter = config.Footer or "BloodLine UI"
    local windowLogo   = config.Logo   or "rbxassetid://13848130837"
    local uiName       = config.Name   or "BloodLine_" .. tostring(math.random(1000, 9999))

    if core:FindFirstChild(uiName) then core[uiName]:Destroy() end
    if lp:WaitForChild("PlayerGui"):FindFirstChild(uiName) then
        lp.PlayerGui[uiName]:Destroy()
    end

    local ui = Instance.new("ScreenGui")
    ui.Name = uiName
    ui.ResetOnSpawn = false
    local ok = pcall(function() ui.Parent = core end)
    if not ok then ui.Parent = lp:WaitForChild("PlayerGui") end

    local wmFrame = Instance.new("Frame")
    wmFrame.AutomaticSize = Enum.AutomaticSize.X
    wmFrame.Size = UDim2.new(0, 0, 0, 26)
    wmFrame.Position = UDim2.new(0, 14, 0, 14)
    wmFrame.BackgroundColor3 = bgMedium
    wmFrame.Parent = ui
    Instance.new("UICorner", wmFrame).CornerRadius = UDim.new(0, 6)

    local wmStroke = Instance.new("UIStroke", wmFrame)
    wmStroke.Color = strokeDark
    wmStroke.Thickness = 1

    local wmPad = Instance.new("UIPadding", wmFrame)
    wmPad.PaddingLeft  = UDim.new(0, 8)
    wmPad.PaddingRight = UDim.new(0, 10)

    local wmLayout = Instance.new("UIListLayout", wmFrame)
    wmLayout.FillDirection      = Enum.FillDirection.Horizontal
    wmLayout.SortOrder          = Enum.SortOrder.LayoutOrder
    wmLayout.Padding            = UDim.new(0, 6)
    wmLayout.VerticalAlignment  = Enum.VerticalAlignment.Center

    local wmBar = Instance.new("Frame")
    wmBar.Size = UDim2.new(0, 2, 0, 12)
    wmBar.BackgroundColor3 = accent
    wmBar.BorderSizePixel = 0
    wmBar.LayoutOrder = 1
    wmBar.Parent = wmFrame
    Instance.new("UICorner", wmBar).CornerRadius = UDim.new(1, 0)

    local wmIcon = Instance.new("ImageLabel")
    wmIcon.Size = UDim2.new(0, 13, 0, 13)
    wmIcon.BackgroundTransparency = 1
    wmIcon.ImageColor3 = accent
    wmIcon.Image = windowLogo
    wmIcon.LayoutOrder = 2
    wmIcon.Parent = wmFrame

    local wmText = Instance.new("TextLabel")
    wmText.AutomaticSize = Enum.AutomaticSize.X
    wmText.Size = UDim2.new(0, 0, 1, 0)
    wmText.BackgroundTransparency = 1
    wmText.Text = string.upper(windowTitle) .. "  |  " .. lp.Name
    wmText.TextColor3 = textMain
    wmText.Font = Enum.Font.GothamBold
    wmText.TextSize = 9
    wmText.TextXAlignment = Enum.TextXAlignment.Left
    wmText.LayoutOrder = 3
    wmText.Parent = wmFrame

    local wmStats = Instance.new("TextLabel")
    wmStats.AutomaticSize = Enum.AutomaticSize.X
    wmStats.Size = UDim2.new(0, 0, 1, 0)
    wmStats.BackgroundTransparency = 1
    wmStats.Text = "|  60 FPS"
    wmStats.TextColor3 = textMuted
    wmStats.Font = Enum.Font.Gotham
    wmStats.TextSize = 9
    wmStats.TextXAlignment = Enum.TextXAlignment.Left
    wmStats.LayoutOrder = 4
    wmStats.Parent = wmFrame

    local fpsTimer = 0
    runService.RenderStepped:Connect(function(dt)
        fpsTimer = fpsTimer + dt
        if fpsTimer >= 0.25 then
            fpsTimer = 0
            local fps = math.floor(1 / dt)
            wmStats.Text = "|  " .. fps .. " FPS"
        end
    end)

    notifyContainer = Instance.new("Frame")
    notifyContainer.Size = UDim2.new(0, 230, 1, -20)
    notifyContainer.Position = UDim2.new(1, -240, 0, 10)
    notifyContainer.BackgroundTransparency = 1
    notifyContainer.Parent = ui

    notifyList = Instance.new("UIListLayout")
    notifyList.SortOrder         = Enum.SortOrder.LayoutOrder
    notifyList.Padding           = UDim.new(0, 6)
    notifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifyList.Parent            = notifyContainer

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 34, 0, 34)
    toggleBtn.Position = UDim2.new(0.014, 0, 0.15, 0)
    toggleBtn.BackgroundColor3 = bgMedium
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = ""
    toggleBtn.Parent = ui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

    local tGlow = Instance.new("UIStroke", toggleBtn)
    tGlow.Color = accent
    tGlow.Transparency = 0.2
    tGlow.Thickness = 1

    local tBtnIcon = Instance.new("ImageLabel")
    tBtnIcon.Size = UDim2.new(0, 17, 0, 17)
    tBtnIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    tBtnIcon.BackgroundTransparency = 1
    tBtnIcon.ImageColor3 = accent
    tBtnIcon.Image = windowLogo
    tBtnIcon.Parent = toggleBtn

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 640, 0, 345)
    main.Position = UDim2.new(0.5, -320, 0.5, -172)
    main.BackgroundColor3 = bgDark
    main.ClipsDescendants = true
    main.Parent = ui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local mStroke = Instance.new("UIStroke", main)
    mStroke.Color = strokeDark
    mStroke.Thickness = 1
    mStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = bgMedium
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main

    local tBarCornerFix = Instance.new("UICorner", titleBar)
    tBarCornerFix.CornerRadius = UDim.new(0, 8)

    local tBarFix = Instance.new("Frame")
    tBarFix.Size = UDim2.new(1, 0, 0.5, 0)
    tBarFix.Position = UDim2.new(0, 0, 0.5, 0)
    tBarFix.BackgroundColor3 = bgMedium
    tBarFix.BorderSizePixel = 0
    tBarFix.Parent = titleBar

    local tLine = Instance.new("Frame")
    tLine.Size = UDim2.new(1, 0, 0, 1)
    tLine.Position = UDim2.new(0, 0, 1, -1)
    tLine.BackgroundColor3 = strokeDark
    tLine.BorderSizePixel = 0
    tLine.Parent = titleBar

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(0, 40, 0, 2)
    accentLine.Position = UDim2.new(0, 10, 1, -2)
    accentLine.BackgroundColor3 = accent
    accentLine.BorderSizePixel = 0
    accentLine.Parent = titleBar
    Instance.new("UICorner", accentLine).CornerRadius = UDim.new(1, 0)

    local titleIcon = Instance.new("ImageLabel")
    titleIcon.Size = UDim2.new(0, 15, 0, 15)
    titleIcon.Position = UDim2.new(0, 12, 0.5, -7)
    titleIcon.BackgroundTransparency = 1
    titleIcon.ImageColor3 = accent
    titleIcon.Image = windowLogo
    titleIcon.Parent = titleBar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0, 120, 1, 0)
    titleLbl.Position = UDim2.new(0, 32, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = string.upper(windowTitle)
    titleLbl.TextColor3 = textMain
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = titleBar

    local tabsContainer = Instance.new("Frame")
    tabsContainer.Size = UDim2.new(1, -168, 1, 0)
    tabsContainer.Position = UDim2.new(0, 160, 0, 0)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = titleBar

    local tabList = Instance.new("UIListLayout", tabsContainer)
    tabList.FillDirection      = Enum.FillDirection.Horizontal
    tabList.SortOrder          = Enum.SortOrder.LayoutOrder
    tabList.Padding            = UDim.new(0, 4)
    tabList.VerticalAlignment  = Enum.VerticalAlignment.Center

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 1, -58)
    contentContainer.Position = UDim2.new(0, 0, 0, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = main

    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 18)
    footer.Position = UDim2.new(0, 0, 1, -18)
    footer.BackgroundColor3 = bgMedium
    footer.BorderSizePixel = 0
    footer.Parent = main

    local fBgFix = Instance.new("Frame")
    fBgFix.Size = UDim2.new(1, 0, 0.5, 0)
    fBgFix.BackgroundColor3 = bgMedium
    fBgFix.BorderSizePixel = 0
    fBgFix.Parent = footer

    local fLine = Instance.new("Frame")
    fLine.Size = UDim2.new(1, 0, 0, 1)
    fLine.BackgroundColor3 = strokeDark
    fLine.BorderSizePixel = 0
    fLine.Parent = footer

    local fText = Instance.new("TextLabel")
    fText.Size = UDim2.new(0.5, -8, 1, 0)
    fText.Position = UDim2.new(0, 10, 0, 0)
    fText.BackgroundTransparency = 1
    fText.Text = windowFooter
    fText.TextColor3 = textMuted
    fText.Font = Enum.Font.Code
    fText.TextSize = 8
    fText.TextXAlignment = Enum.TextXAlignment.Left
    fText.Parent = footer

    local fTextRight = Instance.new("TextLabel")
    fTextRight.Size = UDim2.new(0.5, -8, 1, 0)
    fTextRight.Position = UDim2.new(0.5, 0, 0, 0)
    fTextRight.BackgroundTransparency = 1
    fTextRight.Text = lp.Name
    fTextRight.TextColor3 = accent
    fTextRight.Font = Enum.Font.Code
    fTextRight.TextSize = 8
    fTextRight.TextXAlignment = Enum.TextXAlignment.Right
    fTextRight.Parent = footer

    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos  = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    uis.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local isOpen = true
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        main.Visible = isOpen
        tween:Create(tBtnIcon, bounceTween, {Rotation = isOpen and 0 or 180}):Play()
        tween:Create(tGlow,    smoothTween, {Color = isOpen and accent or strokeDark, Transparency = isOpen and 0.2 or 0.8}):Play()
        tween:Create(tBtnIcon, smoothTween, {ImageColor3 = isOpen and accent or textMuted}):Play()
    end)

    local tabRegistry      = {}
    local controls         = {}
    local windowThemeName  = config.Theme or "Red"
    local firstTab         = true

    local Window = {}

    function Window:_registerControl(control, tab)
        if not control then return end
        control.Tab = tab
        table.insert(controls, control)
    end

    function Window:GetControl(key)
        for index = #controls, 1, -1 do
            if controls[index].Key == key then return controls[index] end
        end
    end

    function Window:GetThemeNames()
        local names = {}
        for name in pairs(themes) do table.insert(names, name) end
        table.sort(names)
        return names
    end

    function Window:ApplyTheme(theme, targetTab, setDefault)
        local nextTheme = resolveTheme(theme)
        if targetTab and targetTab._entry then
            local entry = targetTab._entry
            local oldTheme = entry.theme or snapshotTheme()
            refreshTheme(entry.frame, oldTheme, nextTheme)
            entry.theme = nextTheme
            entry.themeName = type(theme) == "string" and theme or nil
            if setDefault and type(theme) == "string" then self:SetDefaultTheme(theme) end
            return entry.themeName
        end
        local oldTheme = snapshotTheme()
        setCurrentTheme(nextTheme)
        windowThemeName = type(theme) == "string" and theme or windowThemeName
        refreshTheme(ui, oldTheme, nextTheme)
        wmBar.BackgroundColor3 = accent
        wmIcon.ImageColor3 = accent
        wmText.TextColor3 = textMain
        wmStats.TextColor3 = textMuted
        tGlow.Color = accent
        tBtnIcon.ImageColor3 = accent
        mStroke.Color = strokeDark
        fText.TextColor3 = textMuted
        fTextRight.TextColor3 = accent
        titleIcon.ImageColor3 = accent
        titleLbl.TextColor3 = textMain
        accentLine.BackgroundColor3 = accent
        for _, entry in ipairs(tabRegistry) do
            entry.theme = nextTheme
            entry.themeName = windowThemeName
        end
        if setDefault then self:SetDefaultTheme(type(theme) == "string" and theme or windowThemeName) end
        return windowThemeName
    end

    function Window:SetDefaultTheme(theme)
        if type(theme) ~= "string" or not themes[theme] then return false end
        local settings = readSettings()
        settings.DefaultTheme = theme
        writeSettings(settings)
        return true
    end

    function Window:GetDefaultTheme()
        return readSettings().DefaultTheme
    end

    function Window:_collectConfig()
        local values = {}
        for _, control in ipairs(controls) do
            if control.Kind ~= "Button" and control.Get then
                values[control.Key] = encodeValue(control.Get())
            end
        end
        return {
            Theme    = encodeValue(currentTheme),
            Controls = values
        }
    end

    function Window:GetConfigNames()
        local names = {}
        if type(listfiles) == "function" and fileSupport() then
            prepareFolder()
            local ok2, files = pcall(listfiles, configFolder)
            if ok2 and type(files) == "table" then
                for _, path in ipairs(files) do
                    local name = tostring(path):match("([^/\\]+)%.json$")
                    if name and name ~= "settings" then table.insert(names, name) end
                end
            end
        end
        for name in pairs(memoryConfigs) do
            local found = false
            for _, current in ipairs(names) do
                if current == name then found = true break end
            end
            if not found then table.insert(names, name) end
        end
        table.sort(names)
        return names
    end

    function Window:SaveConfig(name, overwrite)
        name = tostring(name or ""):match("^%s*(.-)%s*$")
        if name == "" then return false, "Config name is empty" end
        local existing = readJson(configPath(name)) or memoryConfigs[name]
        if existing and not overwrite then return false, "Config already exists" end
        local data = self:_collectConfig()
        memoryConfigs[name] = data
        if fileSupport() then writeJson(configPath(name), data) end
        return true
    end

    function Window:OverwriteConfig(name)
        return self:SaveConfig(name, true)
    end

    function Window:LoadConfig(name)
        local data = readJson(configPath(name)) or memoryConfigs[name]
        if not data then return false, "Config not found" end
        return self:ApplyConfig(data)
    end

    function Window:ApplyConfig(configData)
        local data = configData
        if type(configData) == "string" then
            data = readJson(configPath(configData)) or memoryConfigs[configData]
        end
        if type(data) ~= "table" then return false, "Invalid config" end
        if data.Theme then self:ApplyTheme(decodeValue(data.Theme)) end
        for _, control in ipairs(controls) do
            local value = data.Controls and data.Controls[control.Key]
            if value ~= nil and control.Set then control.Set(decodeValue(value), false) end
        end
        return true
    end

    function Window:SetAutoLoad(name)
        name = tostring(name or "")
        if name == "" then return false end
        if not (readJson(configPath(name)) or memoryConfigs[name]) then return false end
        local settings = readSettings()
        settings.AutoLoad = name
        writeSettings(settings)
        return true
    end

    function Window:UnsetAutoLoad()
        local settings = readSettings()
        settings.AutoLoad = nil
        writeSettings(settings)
        return true
    end

    function Window:GetAutoLoad()
        return readSettings().AutoLoad
    end

    function Window:SetWatermarkVisible(state)
        wmFrame.Visible = state == true
        return wmFrame.Visible
    end

    function Window:DeleteConfig(name)
        memoryConfigs[name] = nil
        if fileSupport() and type(delfile) == "function" then
            pcall(function()
                if isfile(configPath(name)) then delfile(configPath(name)) end
            end)
        end
        if self:GetAutoLoad() == name then self:UnsetAutoLoad() end
        return true
    end

    function Window:Notify(t, d, dur, icon)
        Notify(t, d, dur, icon)
    end

    function Window:CreateTab(name, iconId)
        local isFirst = firstTab
        firstTab = false

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 88, 1, -14)
        tabBtn.BackgroundColor3 = isFirst and bgLight or Color3.new(0, 0, 0)
        tabBtn.BackgroundTransparency = isFirst and 0 or 1
        tabBtn.AutoButtonColor = false
        tabBtn.Text = ""
        tabBtn.Parent = tabsContainer
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 5)

        local tbStroke = Instance.new("UIStroke", tabBtn)
        tbStroke.Color = isFirst and accent or Color3.new(0, 0, 0)
        tbStroke.Transparency = isFirst and 1 or 1
        tbStroke.Thickness = 1

        local centerContent = Instance.new("Frame")
        centerContent.Size = UDim2.new(1, 0, 1, 0)
        centerContent.BackgroundTransparency = 1
        centerContent.Parent = tabBtn

        local tLayout = Instance.new("UIListLayout", centerContent)
        tLayout.FillDirection       = Enum.FillDirection.Horizontal
        tLayout.SortOrder           = Enum.SortOrder.LayoutOrder
        tLayout.Padding             = UDim.new(0, 5)
        tLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tLayout.VerticalAlignment   = Enum.VerticalAlignment.Center

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size = UDim2.new(0, 12, 0, 12)
        tabIcon.BackgroundTransparency = 1
        tabIcon.ImageColor3 = isFirst and textMain or textMuted
        ApplyIcon(tabIcon, iconId)
        tabIcon.Parent = centerContent

        local tabLbl = Instance.new("TextLabel")
        tabLbl.Size = UDim2.new(0, 0, 1, 0)
        tabLbl.AutomaticSize = Enum.AutomaticSize.X
        tabLbl.BackgroundTransparency = 1
        tabLbl.Text = string.upper(name)
        tabLbl.TextColor3 = isFirst and textMain or textMuted
        tabLbl.Font = Enum.Font.GothamBold
        tabLbl.TextSize = 9
        tabLbl.Parent = centerContent

        local tabUnderline = Instance.new("Frame")
        tabUnderline.Size = UDim2.new(isFirst and 0.6 or 0, 0, 0, 2)
        tabUnderline.Position = UDim2.new(0.5, 0, 1, -2)
        tabUnderline.AnchorPoint = Vector2.new(0.5, 0)
        tabUnderline.BackgroundColor3 = accent
        tabUnderline.BackgroundTransparency = isFirst and 0 or 1
        tabUnderline.BorderSizePixel = 0
        tabUnderline.Parent = tabBtn
        Instance.new("UICorner", tabUnderline).CornerRadius = UDim.new(1, 0)

        local tabFrame = Instance.new("Frame")
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = isFirst
        tabFrame.Parent = contentContainer

        local entry = {btn = tabBtn, lbl = tabLbl, icon = tabIcon, frame = tabFrame, stroke = tbStroke, underline = tabUnderline, theme = snapshotTheme()}
        table.insert(tabRegistry, entry)

        local hLayout = Instance.new("UIListLayout", tabFrame)
        hLayout.FillDirection = Enum.FillDirection.Horizontal
        hLayout.Padding = UDim.new(0, 10)

        local tabPad = Instance.new("UIPadding", tabFrame)
        tabPad.PaddingTop    = UDim.new(0, 10)
        tabPad.PaddingBottom = UDim.new(0, 10)
        tabPad.PaddingLeft   = UDim.new(0, 10)
        tabPad.PaddingRight  = UDim.new(0, 10)

        local leftScroll = Instance.new("ScrollingFrame")
        leftScroll.Size = UDim2.new(0.5, -5, 1, 0)
        leftScroll.BackgroundTransparency = 1
        leftScroll.ScrollBarThickness = 2
        leftScroll.ScrollBarImageColor3 = accent
        leftScroll.ScrollBarImageTransparency = 0.5
        leftScroll.BorderSizePixel = 0
        leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        leftScroll.Parent = tabFrame

        local lPad = Instance.new("UIPadding", leftScroll)
        lPad.PaddingRight  = UDim.new(0, 4)
        lPad.PaddingLeft   = UDim.new(0, 2)
        lPad.PaddingTop    = UDim.new(0, 2)
        lPad.PaddingBottom = UDim.new(0, 4)

        local lLayout = Instance.new("UIListLayout", leftScroll)
        lLayout.SortOrder = Enum.SortOrder.LayoutOrder
        lLayout.Padding   = UDim.new(0, 6)

        local rightScroll = Instance.new("ScrollingFrame")
        rightScroll.Size = UDim2.new(0.5, -5, 1, 0)
        rightScroll.BackgroundTransparency = 1
        rightScroll.ScrollBarThickness = 2
        rightScroll.ScrollBarImageColor3 = accent
        rightScroll.ScrollBarImageTransparency = 0.5
        rightScroll.BorderSizePixel = 0
        rightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        rightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        rightScroll.Parent = tabFrame

        local rPad = Instance.new("UIPadding", rightScroll)
        rPad.PaddingRight  = UDim.new(0, 4)
        rPad.PaddingLeft   = UDim.new(0, 2)
        rPad.PaddingTop    = UDim.new(0, 2)
        rPad.PaddingBottom = UDim.new(0, 4)

        local rLayout = Instance.new("UIListLayout", rightScroll)
        rLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rLayout.Padding   = UDim.new(0, 6)

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabRegistry) do
                tween:Create(t.lbl,       fastTween, {TextColor3 = textMuted}):Play()
                tween:Create(t.icon,      fastTween, {ImageColor3 = textMuted}):Play()
                tween:Create(t.btn,       fastTween, {BackgroundTransparency = 1}):Play()
                tween:Create(t.underline, fastTween, {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,2)}):Play()
                t.frame.Visible = false
            end
            tween:Create(tabLbl,      fastTween, {TextColor3 = textMain}):Play()
            tween:Create(tabIcon,     fastTween, {ImageColor3 = textMain}):Play()
            tween:Create(tabBtn,      fastTween, {BackgroundTransparency = 0, BackgroundColor3 = bgLight}):Play()
            tween:Create(tabUnderline,fastTween, {BackgroundTransparency = 0, Size = UDim2.new(0.6,0,0,2)}):Play()
            tabFrame.Visible = true
        end)

        local Tab = {}
        Tab._entry = entry

        function Tab:ApplyTheme(theme, setDefault)
            return Window:ApplyTheme(theme, self, setDefault)
        end

        function Tab:LeftGroup(title)
            local container = addGroupBox(leftScroll, title)
            return makeGroupBoxObject(container, Window, Tab)
        end

        function Tab:RightGroup(title)
            local container = addGroupBox(rightScroll, title)
            return makeGroupBoxObject(container, Window, Tab)
        end

        return Tab
    end

    local settings = readSettings()
    if settings.DefaultTheme and themes[settings.DefaultTheme] then
        Window:ApplyTheme(settings.DefaultTheme)
    end
    if settings.AutoLoad then
        task.defer(function()
            Window:ApplyConfig(settings.AutoLoad)
        end)
    end

    BloodLine._activeWindow = Window
    Notify(windowTitle, "UI Loaded", 4, "shield-check")

    return Window
end

function BloodLine:Notify(title, desc, duration, icon)
    Notify(title, desc, duration, icon)
end

function BloodLine:ApplyTheme(theme, targetTab, setDefault)
    if self._activeWindow then
        return self._activeWindow:ApplyTheme(theme, targetTab, setDefault)
    end
    setCurrentTheme(theme)
    return type(theme) == "string" and theme or "Red"
end

function BloodLine:ApplyConfig(configData)
    if self._activeWindow then
        return self._activeWindow:ApplyConfig(configData)
    end
    return false, "No active window"
end

function BloodLine:GetThemes()
    local names = {}
    for name in pairs(themes) do table.insert(names, name) end
    table.sort(names)
    return names
end

return BloodLine
