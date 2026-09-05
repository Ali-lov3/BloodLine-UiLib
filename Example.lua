local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Ali-lov3/BloodLine-UiLib/refs/heads/main/BloodLine.lua"
))()

local configFolder = "BloodLine"

local Window = Library:CreateWindow({
    Title  = "BloodLine",
    Footer = "SYS // RED EDITION // v1.0",
    Logo   = "rbxassetid://13848130837",
})

local CombatTab = Window:CreateTab("Combat", "Sword")

local AimbotGroup = CombatTab:LeftGroup("Aimbot")

AimbotGroup:AddToggle("Aimbot Enabled", "Target", false, function(state)
    print("Aimbot:", state)
end)

AimbotGroup:AddToggle("Silent Aim", "Crosshair", false, function(state)
    print("Silent Aim:", state)
end)

AimbotGroup:AddSlider("FOV", 1, 500, "Circle", function(value)
    print("FOV:", value)
end)

AimbotGroup:AddSlider("Smoothness", 1, 100, "Activity", function(value)
    print("Smoothness:", value)
end)

AimbotGroup:AddDropdown("Aim Part", {"Head", "HumanoidRootPart", "Torso"}, "Locate", function(selected)
    print("Aim Part:", selected)
end)

local PredictionGroup = CombatTab:RightGroup("Prediction")

PredictionGroup:AddToggle("Bullet Prediction", "Zap", true, function(state)
    print("Prediction:", state)
end)

PredictionGroup:AddSlider("Prediction Amount", 0, 10, "Sliders", function(value)
    print("Prediction:", value)
end)

PredictionGroup:AddButton("Reset Settings", "RefreshCw", function()
    print("Settings reset!")
end)

PredictionGroup:AddLabel("FOV Circle shown in-game", "Info")

local VisualsTab = Window:CreateTab("Visuals", "Eye")

local ESPGroup = VisualsTab:LeftGroup("ESP")

ESPGroup:AddToggle("Player ESP", "Users", false, function(state)
    print("ESP:", state)
end)

ESPGroup:AddToggle("Box ESP", "Square", false, function(state)
    print("Box ESP:", state)
end)

ESPGroup:AddToggle("Name ESP", "Tag", false, function(state)
    print("Name ESP:", state)
end)

ESPGroup:AddColorpicker("ESP Color", Color3.fromRGB(255, 35, 65), "Palette", function(color)
    print("ESP Color:", color)
end)

ESPGroup:AddMultiDropdown("ESP Parts", {"Head","Torso","Arms","Legs"}, "Layers", function(selected)
    for part, state in pairs(selected) do
        if state then print("Showing:", part) end
    end
end)

local ChamsGroup = VisualsTab:RightGroup("Chams")

ChamsGroup:AddToggle("Player Chams", "Layers", false, function(state)
    print("Chams:", state)
end)

ChamsGroup:AddColorpicker("Chams Color", Color3.fromRGB(255, 255, 255), "Palette", function(color)
    print("Chams Color:", color)
end)

ChamsGroup:AddDropdown("Chams Style", {"Flat","Outline","Wireframe"}, "Box", function(style)
    print("Chams Style:", style)
end)

local PlayerTab = Window:CreateTab("Player", "User")

local MovementGroup = PlayerTab:LeftGroup("Movement")

MovementGroup:AddToggle("Speed Hack", "Zap", false, function(state)
    print("Speed:", state)
end)

MovementGroup:AddSlider("Walk Speed", 16, 500, "Activity", function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

MovementGroup:AddToggle("Fly", "Wind", false, function(state)
    print("Fly:", state)
end)

MovementGroup:AddSlider("Fly Speed", 1, 200, "Wind", function(value)
    print("Fly Speed:", value)
end)

local MiscGroup = PlayerTab:RightGroup("Misc")

MiscGroup:AddToggle("Infinite Jump", "ChevronsUp", false, function(state)
    print("Inf Jump:", state)
end)

MiscGroup:AddToggle("NoClip", "Ghost", false, function(state)
    print("NoClip:", state)
end)

MiscGroup:AddTextBox("Jump To Player", "Player name...", "Search", function(text)
    print("Jump to:", text)
end)

local SettingsTab = Window:CreateTab("Settings", "Settings")

local ThemeGroup = SettingsTab:LeftGroup("Theme")

local selectedThemeName = nil
local themeDropdown = ThemeGroup:AddDynamicDropdown(
    "Theme",
    function() return Library:GetAllThemeNames and Library:GetAllThemeNames() or {"Red (Default)","Blue","Green","Purple","Cyan"} end,
    "Paintbrush",
    function(name)
        selectedThemeName = name
    end
)

ThemeGroup:AddColorpicker("Accent Color", Color3.fromRGB(255, 35, 65), "Palette", function(color)
    Library:ApplyTheme({ accent = color, accentDark = Color3.fromRGB(
        math.floor(color.R * 255 * 0.5),
        math.floor(color.G * 255 * 0.5),
        math.floor(color.B * 255 * 0.5)
    )})
end)

ThemeGroup:AddButton2("Apply Theme", "Check", function()
    if selectedThemeName then
        Library:ApplyTheme(selectedThemeName)
        Library:Notify("Theme", "Applied: " .. selectedThemeName, 3, "paintbrush")
    else
        Library:Notify("Theme", "Select a theme first", 3, "alert-circle")
    end
end)

ThemeGroup:AddButton2("Set as Default", "Star", function()
    if selectedThemeName then
        Library:SetDefaultTheme(selectedThemeName)
        Library:Notify("Theme", selectedThemeName .. " set as default", 3, "star")
    else
        Library:Notify("Theme", "Select a theme first", 3, "alert-circle")
    end
end)

local ConfigGroup = SettingsTab:RightGroup("Config")

local configNameBox = ConfigGroup:AddTextBox("Config Name", "Enter name...", "Terminal", function(name)
end)

local folderDropdown = ConfigGroup:AddDynamicDropdown(
    "Folder",
    function()
        local folders = {"BloodLine", "Scripts", "Cheats", "Configs"}
        return folders
    end,
    "Folder",
    function(folder)
        configFolder = folder
    end
)

local selectedConfigName = nil
local configDropdown = ConfigGroup:AddDynamicDropdown(
    "Config",
    function() return Library:GetAllConfigNames and Library:GetAllConfigNames() or {} end,
    "File",
    function(name)
        selectedConfigName = name
    end
)

ConfigGroup:AddButton2("Save", "Save", function()
    local name = configNameBox and configNameBox.Text or ""
    if name == "" then
        Library:Notify("Config", "Enter a config name", 3, "alert-circle")
        return
    end
    local data = Library:GetCurrentConfig()
    Library:SaveConfig(name, configFolder, data)
    Library:Notify("Config", "Saved: " .. name, 3, "save")
end)

ConfigGroup:AddButton2("Load", "Upload", function()
    if not selectedConfigName then
        Library:Notify("Config", "Select a config first", 3, "alert-circle")
        return
    end
    local data = Library:LoadConfig(selectedConfigName)
    if data then
        Library:ApplyConfig(data)
        Library:Notify("Config", "Loaded: " .. selectedConfigName, 3, "upload")
    end
end)

ConfigGroup:AddButton2("Set as Autoload", "RefreshCw", function()
    if not selectedConfigName then
        Library:Notify("Config", "Select a config first", 3, "alert-circle")
        return
    end
    Library:SetAutoloadConfig(selectedConfigName)
    Library:Notify("Config", "Autoload: " .. selectedConfigName, 3, "refresh-cw")
end)

ConfigGroup:AddButton2("Unset Autoload", "X", function()
    Library:UnsetAutoloadConfig()
    Library:Notify("Config", "Autoload cleared", 3, "x")
end)

ConfigGroup:AddButton2("Delete", "Trash", function()
    if not selectedConfigName then
        Library:Notify("Config", "Select a config first", 3, "alert-circle")
        return
    end
    Library:DeleteConfig(selectedConfigName)
    Library:Notify("Config", "Deleted: " .. selectedConfigName, 3, "trash")
    selectedConfigName = nil
end)

ConfigGroup:AddButton2("Overwrite", "Edit", function()
    if not selectedConfigName then
        Library:Notify("Config", "Select a config first", 3, "alert-circle")
        return
    end
    local data = Library:GetCurrentConfig()
    Library:SaveConfig(selectedConfigName, configFolder, data)
    Library:Notify("Config", "Overwritten: " .. selectedConfigName, 3, "edit")
end)

local wmToggleRef = ConfigGroup:AddRawToggle("Show Watermark", "Tv", true, function(state)
    Window:SetWatermarkVisible(state)
end)

local autoloadName = Library:GetAutoloadConfig()
if autoloadName then
    local data = Library:LoadConfig(autoloadName)
    if data then
        Library:ApplyConfig(data)
        Library:Notify("Config", "Autoloaded: " .. autoloadName, 3, "refresh-cw")
    end
end

Library:Notify("BloodLine", "Script loaded successfully!", 5, "shield-check")
