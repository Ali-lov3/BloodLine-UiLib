local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ali-lov3/BloodLine-UiLib/refs/heads/main/BloodLine.lua"))()

local Window = Library:CreateWindow({
    Title = "BloodLine",
    Footer = "Hi Guys!",
    Logo = "rbxassetid://110389542822391",
})

local CombatTab = Window:CreateTab("Combat", "Sword")
local AimbotGroup = CombatTab:LeftGroup("Aimbot")

AimbotGroup:AddToggle("This is a Toggle", "Target", false, function(state)
    print("Toggle:", state)
end)

AimbotGroup:AddToggle("This is a Toggle", "Crosshair", false, function(state)
    print("Toggle:", state)
end)

AimbotGroup:AddSlider("This is a Slider", 1, 500, "Circle", function(value)
    print("Slider:", value)
end)

AimbotGroup:AddSlider("This is a Slider", 1, 100, "Activity", function(value)
    print("Slider:", value)
end)

AimbotGroup:AddDropdown("This is a Dropdown", {"Option 1", "Option 2", "Option 3"}, "Locate", function(selected)
    print("Dropdown:", selected)
end)

local PredictionGroup = CombatTab:RightGroup("Prediction")

PredictionGroup:AddToggle("This is a Toggle", "Zap", true, function(state)
    print("Toggle:", state)
end)

PredictionGroup:AddSlider("This is a Slider", 0, 10, "Sliders", function(value)
    print("Slider:", value)
end)

PredictionGroup:AddButton("This is a Button", "RefreshCw", function()
    print("Button clicked!")
end)

PredictionGroup:AddLabel("This is a Label", "Info")

local VisualsTab = Window:CreateTab("Visuals", "Eye")
local ESPGroup = VisualsTab:LeftGroup("ESP")

ESPGroup:AddToggle("This is a Toggle", "Users", false, function(state)
    print("Toggle:", state)
end)

ESPGroup:AddToggle("This is a Toggle", "Square", false, function(state)
    print("Toggle:", state)
end)

ESPGroup:AddToggle("This is a Toggle", "Tag", false, function(state)
    print("Toggle:", state)
end)

ESPGroup:AddColorpicker("This is a Colorpicker", Color3.fromRGB(255, 35, 65), "Palette", function(color)
    print("Colorpicker:", color)
end)

ESPGroup:AddMultiDropdown("This is a MultiDropdown", {"Option 1", "Option 2", "Option 3", "Option 4"}, "Layers", function(selected)
    for option, state in pairs(selected) do
        if state then print("Selected:", option) end
    end
end)

local ChamsGroup = VisualsTab:RightGroup("Chams")

ChamsGroup:AddToggle("This is a Toggle", "Layers", false, function(state)
    print("Toggle:", state)
end)

ChamsGroup:AddColorpicker("This is a Colorpicker", Color3.fromRGB(255, 255, 255), "Palette", function(color)
    print("Colorpicker:", color)
end)

ChamsGroup:AddDropdown("This is a Dropdown", {"Style 1", "Style 2", "Style 3"}, "Box", function(style)
    print("Dropdown:", style)
end)

local PlayerTab = Window:CreateTab("Player", "User")
local MovementGroup = PlayerTab:LeftGroup("Movement")

MovementGroup:AddToggle("This is a Toggle", "Zap", false, function(state)
    print("Toggle:", state)
end)

MovementGroup:AddSlider("This is a Slider", 16, 500, "Activity", function(value)
    local character = game.Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = value end
end)

MovementGroup:AddToggle("This is a Toggle", "Wind", false, function(state)
    print("Toggle:", state)
end)

MovementGroup:AddSlider("This is a Slider", 1, 200, "Wind", function(value)
    print("Slider:", value)
end)

local MiscGroup = PlayerTab:RightGroup("Misc")

MiscGroup:AddToggle("This is a Toggle", "ChevronsUp", false, function(state)
    print("Toggle:", state)
end)

MiscGroup:AddToggle("This is a Toggle", "Ghost", false, function(state)
    print("Toggle:", state)
end)

MiscGroup:AddTextBox("This is a TextBox", "Input text...", "Search", function(text)
    print("TextBox:", text)
end)

local SettingsTab = Window:CreateTab("Settings", "Settings")
local AppearanceGroup = SettingsTab:LeftGroup("Appearance")
local selectedTheme = "Red"

AppearanceGroup:AddToggle("Show WaterMark", "Tv", true, function(state)
    Window:SetWatermarkVisible(state)
end)

AppearanceGroup:AddDropdown("Theme", Library:GetThemes(), "Paintbrush", function(theme)
    selectedTheme = theme
    Window:ApplyTheme(theme)
end)

AppearanceGroup:AddColorpicker("Accent Color", Color3.fromRGB(255, 35, 65), "Palette", function(color)
    Window:ApplyTheme({
        Accent = color,
        AccentDark = color:Lerp(Color3.new(0, 0, 0), 0.5)
    })
end)

AppearanceGroup:AddButton("Set Theme as Default", "Bookmark", function()
    Window:SetDefaultTheme(selectedTheme)
    Window:Notify("Theme", selectedTheme .. " is now the default theme", 3, "check")
end)

AppearanceGroup:AddButton("Apply Theme to This Tab", "PanelsTopLeft", function()
    SettingsTab:ApplyTheme(selectedTheme)
end)

local ConfigGroup = SettingsTab:RightGroup("Configs")
local selectedConfig = ""

ConfigGroup:AddTextBox("Config Name", "MyConfig", "FilePlus", function()
end)

ConfigGroup:AddDropdown("Saved Config", {"No saved configs"}, "FolderOpen", function(name)
    if name ~= "No saved configs" then selectedConfig = name end
end)

local configInput = Window:GetControl("Config Name")
local configDropdown = Window:GetControl("Saved Config")

local function refreshConfigDropdown()
    local names = Window:GetConfigNames()
    if #names == 0 then names = {"No saved configs"} end
    configDropdown:SetItems(names)
    selectedConfig = #names == 1 and names[1] == "No saved configs" and "" or names[1]
end

ConfigGroup:AddButton("Save Config", "Save", function()
    local name = configInput:Get()
    local ok, message = Window:SaveConfig(name, false)
    if ok then
        selectedConfig = name
        refreshConfigDropdown()
        Window:Notify("Config", "Saved " .. name, 3, "check")
    else
        Window:Notify("Config", message or "Could not save config", 3, "x")
    end
end)

ConfigGroup:AddButton("Load Config", "Upload", function()
    if selectedConfig ~= "" then
        local ok, message = Window:LoadConfig(selectedConfig)
        Window:Notify("Config", ok and "Loaded " .. selectedConfig or (message or "Could not load config"), 3, ok and "check" or "x")
    end
end)

ConfigGroup:AddButton("Overwrite Config", "RefreshCw", function()
    if selectedConfig ~= "" then
        local ok, message = Window:OverwriteConfig(selectedConfig)
        Window:Notify("Config", ok and "Overwritten " .. selectedConfig or (message or "Could not overwrite config"), 3, ok and "check" or "x")
    end
end)

ConfigGroup:AddButton("Set as AutoLoad", "Play", function()
    if selectedConfig ~= "" then
        local ok = Window:SetAutoLoad(selectedConfig)
        Window:Notify("Config", ok and selectedConfig .. " will load automatically" or "Save the config first", 3, ok and "check" or "x")
    end
end)

ConfigGroup:AddButton("Unset AutoLoad", "Square", function()
    Window:UnsetAutoLoad()
    Window:Notify("Config", "AutoLoad disabled", 3, "check")
end)

ConfigGroup:AddButton("Delete Config", "Trash2", function()
    if selectedConfig ~= "" then
        local name = selectedConfig
        Window:DeleteConfig(name)
        selectedConfig = ""
        refreshConfigDropdown()
        Window:Notify("Config", "Deleted " .. name, 3, "check")
    end
end)

local KeybindGroup = SettingsTab:RightGroup("Keybinds")

KeybindGroup:AddKeybind("Toggle Menu", "RightShift", "Layout", function(key)
    print("Menu key:", key)
end)

KeybindGroup:AddKeybind("Toggle ESP", "F2", "Eye", function(key)
    print("ESP key:", key)
end)

KeybindGroup:AddKeybind("Toggle Aimbot", "F3", "Target", function(key)
    print("Aimbot key:", key)
end)

refreshConfigDropdown()
Library:Notify("BloodLine", "Script loaded successfully!", 5, "shield-check")
