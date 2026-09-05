-- =========================================================
--   BloodLine UI Library - Example Script
--   Replace the URL below with your raw GitHub link
-- =========================================================

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/BloodLine.lua"
))()

-- =========================================================
--   Create the main window
--   Title  = text shown in the title bar and watermark
--   Footer = text shown in the bottom bar
--   Logo   = rbxassetid or image URL for the logo icon
-- =========================================================

local Window = Library:CreateWindow({
    Title  = "BloodLine",
    Footer = "SYS // RED EDITION // v1.0",
    Logo   = "rbxassetid://13848130837",
})

-- =========================================================
--   Tab 1: Combat
--   CreateTab(name, icon)
--   icon can be any Lucide icon name (e.g. "Sword", "Eye")
-- =========================================================

local CombatTab = Window:CreateTab("Combat", "Sword")

--  LeftGroup / RightGroup split the tab into two columns
local AimbotGroup = CombatTab:LeftGroup("Aimbot")

-- AddToggle(text, icon, defaultState, callback)
AimbotGroup:AddToggle("Aimbot Enabled", "Target", false, function(state)
    print("Aimbot:", state)
end)

AimbotGroup:AddToggle("Silent Aim", "Crosshair", false, function(state)
    print("Silent Aim:", state)
end)

-- AddSlider(text, min, max, icon, callback)
AimbotGroup:AddSlider("FOV", 1, 500, "Circle", function(value)
    print("FOV:", value)
end)

AimbotGroup:AddSlider("Smoothness", 1, 100, "Activity", function(value)
    print("Smoothness:", value)
end)

-- AddDropdown(text, items, icon, callback)
AimbotGroup:AddDropdown("Aim Part", {"Head", "HumanoidRootPart", "Torso"}, "Locate", function(selected)
    print("Aim Part:", selected)
end)

local PredictionGroup = CombatTab:RightGroup("Prediction")

-- AddToggle with default ON
PredictionGroup:AddToggle("Bullet Prediction", "Zap", true, function(state)
    print("Prediction:", state)
end)

PredictionGroup:AddSlider("Prediction Amount", 0, 10, "Sliders", function(value)
    print("Prediction:", value)
end)

-- AddButton(text, icon, callback)
PredictionGroup:AddButton("Reset Settings", "RefreshCw", function()
    print("Settings reset!")
end)

-- AddLabel(text, icon)  -- read-only info line
PredictionGroup:AddLabel("FOV Circle shown in-game", "Info")

-- =========================================================
--   Tab 2: Visuals
-- =========================================================

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

-- AddColorpicker(text, defaultColor, icon, callback)
ESPGroup:AddColorpicker("ESP Color", Color3.fromRGB(255, 35, 65), "Palette", function(color)
    print("ESP Color:", color)
end)

-- AddMultiDropdown(text, items, icon, callback)
-- callback receives a table: { ["Option 1"] = true/false, ... }
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

-- =========================================================
--   Tab 3: Player
-- =========================================================

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

-- AddTextBox(text, placeholder, icon, callback)  -- fires on Enter
MiscGroup:AddTextBox("Jump To Player", "Player name...", "Search", function(text)
    print("Jump to:", text)
end)

-- =========================================================
--   Tab 4: Settings
-- =========================================================

local SettingsTab = Window:CreateTab("Settings", "Settings")

local UIGroup = SettingsTab:LeftGroup("UI Settings")

UIGroup:AddToggle("Toggle Watermark", "Tv", true, function(state)
    -- watermark is handled internally; this is just an example toggle
    print("Watermark:", state)
end)

UIGroup:AddDropdown("Theme", {"Red (Default)", "Blue", "Green", "Purple"}, "Paintbrush", function(theme)
    print("Theme:", theme)
end)

UIGroup:AddColorpicker("Accent Color", Color3.fromRGB(255, 35, 65), "Palette", function(color)
    print("Accent:", color)
end)

local KeybindGroup = SettingsTab:RightGroup("Keybinds")

-- AddKeybind(text, defaultKey, icon, callback)
KeybindGroup:AddKeybind("Toggle Menu", "RightShift", "Layout", function(key)
    print("Menu key:", key)
end)

KeybindGroup:AddKeybind("Toggle ESP", "F2", "Eye", function(key)
    print("ESP key:", key)
end)

KeybindGroup:AddKeybind("Toggle Aimbot", "F3", "Target", function(key)
    print("Aimbot key:", key)
end)

KeybindGroup:AddButton("Unload Script", "LogOut", function()
    Library:Notify("Goodbye", "Script unloaded", 3, "log-out")
    task.wait(3)
    -- put unload logic here
end)

-- =========================================================
--   Manual notification example
-- =========================================================
-- Library:Notify(title, description, duration, icon)
Library:Notify("BloodLine", "Script loaded successfully!", 5, "shield-check")
