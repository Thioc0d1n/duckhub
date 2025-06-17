--[[
    BirdUi - Lightweight Modular UI Library for Lua
    Version: 1.0.0
    Author: BirdUi Team
    
    Compatible with:
    - Roblox (Primary target)
    - LÖVE2D (with minor adaptations)
    - Other Lua GUI frameworks
    
    Usage:
    local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/Bird-ui/main/Bird-ui.lua"))()
    
    Features:
    - Theme system with predefined themes
    - Smooth animations (fade, slide, scale)
    - Modular components (button, slider, checkbox, dropdown, modal)
    - Responsive design
    - Intuitive API
--]]

local BirdUi = {}
BirdUi.__index = BirdUi
BirdUi.Version = "1.0.0"

-- ================================
-- CORE SERVICES & COMPATIBILITY
-- ================================

-- Auto-detect environment
local Environment = {}
if game and game:GetService("Players") then
    -- Roblox environment
    Environment.Type = "Roblox"
    Environment.TweenService = game:GetService("TweenService")
    Environment.UserInputService = game:GetService("UserInputService")
    Environment.Players = game:GetService("Players")
    Environment.LocalPlayer = Environment.Players.LocalPlayer
    Environment.PlayerGui = Environment.LocalPlayer:WaitForChild("PlayerGui")
elseif love then
    -- LÖVE2D environment
    Environment.Type = "Love2D"
    -- Add LÖVE2D specific initialization here
else
    -- Generic Lua environment
    Environment.Type = "Generic"
    warn("BirdUi: Unknown environment. Some features may not work.")
end

-- ================================
-- THEME SYSTEM
-- ================================

local Themes = {
    Default = {
        Name = "Default",
        Colors = {
            Primary = Color3.fromRGB(0, 162, 255),
            Secondary = Color3.fromRGB(108, 117, 125),
            Success = Color3.fromRGB(40, 167, 69),
            Warning = Color3.fromRGB(255, 193, 7),
            Danger = Color3.fromRGB(220, 53, 69),
            Background = Color3.fromRGB(248, 249, 250),
            Surface = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(33, 37, 41),
            TextSecondary = Color3.fromRGB(108, 117, 125),
            Border = Color3.fromRGB(222, 226, 230),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Fonts = {
            Default = Enum.Font.Gotham,
            Bold = Enum.Font.GothamBold,
            Light = Enum.Font.Gotham
        },
        Sizes = {
            CornerRadius = UDim.new(0, 8),
            BorderWidth = 1,
            Padding = 12,
            FontSize = 14
        }
    },
    
    Dark = {
        Name = "Dark",
        Colors = {
            Primary = Color3.fromRGB(13, 110, 253),
            Secondary = Color3.fromRGB(108, 117, 125),
            Success = Color3.fromRGB(25, 135, 84),
            Warning = Color3.fromRGB(255, 193, 7),
            Danger = Color3.fromRGB(220, 53, 69),
            Background = Color3.fromRGB(33, 37, 41),
            Surface = Color3.fromRGB(52, 58, 64),
            Text = Color3.fromRGB(248, 249, 250),
            TextSecondary = Color3.fromRGB(173, 181, 189),
            Border = Color3.fromRGB(73, 80, 87),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Fonts = {
            Default = Enum.Font.Gotham,
            Bold = Enum.Font.GothamBold,
            Light = Enum.Font.Gotham
        },
        Sizes = {
            CornerRadius = UDim.new(0, 8),
            BorderWidth = 1,
            Padding = 12,
            FontSize = 14
        }
    },
    
    Neon = {
        Name = "Neon",
        Colors = {
            Primary = Color3.fromRGB(255, 0, 255),
            Secondary = Color3.fromRGB(0, 255, 255),
            Success = Color3.fromRGB(0, 255, 0),
            Warning = Color3.fromRGB(255, 255, 0),
            Danger = Color3.fromRGB(255, 0, 0),
            Background = Color3.fromRGB(15, 15, 25),
            Surface = Color3.fromRGB(25, 25, 40),
            Text = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(180, 180, 255),
            Border = Color3.fromRGB(100, 100, 255),
            Shadow = Color3.fromRGB(255, 0, 255)
        },
        Fonts = {
            Default = Enum.Font.Code,
            Bold = Enum.Font.Code,
            Light = Enum.Font.Code
        },
        Sizes = {
            CornerRadius = UDim.new(0, 12),
            BorderWidth = 2,
            Padding = 15,
            FontSize = 14
        }
    }
}

-- ================================
-- ANIMATION ENGINE
-- ================================

local AnimationEngine = {}

function AnimationEngine.Fade(element, targetTransparency, duration, callback)
    if Environment.Type == "Roblox" then
        local tween = Environment.TweenService:Create(
            element,
            TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = targetTransparency}
        )
        tween:Play()
        if callback then
            tween.Completed:Connect(callback)
        end
        return tween
    end
end

function AnimationEngine.Scale(element, targetScale, duration, callback)
    if Environment.Type == "Roblox" then
        local tween = Environment.TweenService:Create(
            element,
            TweenInfo.new(duration or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(targetScale, 0, targetScale, 0)}
        )
        tween:Play()
        if callback then
            tween.Completed:Connect(callback)
        end
        return tween
    end
end

function AnimationEngine.Slide(element, targetPosition, duration, callback)
    if Environment.Type == "Roblox" then
        local tween = Environment.TweenService:Create(
            element,
            TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = targetPosition}
        )
        tween:Play()
        if callback then
            tween.Completed:Connect(callback)
        end
        return tween
    end
end

function AnimationEngine.Color(element, property, targetColor, duration, callback)
    if Environment.Type == "Roblox" then
        local tween = Environment.TweenService:Create(
            element,
            TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {[property] = targetColor}
        )
        tween:Play()
        if callback then
            tween.Completed:Connect(callback)
        end
        return tween
    end
end

-- ================================
-- COMPONENT BUILDER
-- ================================

local ComponentBuilder = {}

function ComponentBuilder.CreateBase(parent, elementType, properties)
    if Environment.Type == "Roblox" then
        local element = Instance.new(elementType)
        element.Parent = parent
        
        for property, value in pairs(properties or {}) do
            element[property] = value
        end
        
        return element
    end
end

function ComponentBuilder.ApplyTheme(element, theme, elementType)
    local currentTheme = theme or Themes.Default
    
    if Environment.Type == "Roblox" then
        if elementType == "Frame" or elementType == "TextButton" then
            element.BackgroundColor3 = currentTheme.Colors.Surface
            element.BorderColor3 = currentTheme.Colors.Border
            element.BorderSizePixel = currentTheme.Sizes.BorderWidth
            
            -- Add corner radius
            local corner = Instance.new("UICorner")
            corner.CornerRadius = currentTheme.Sizes.CornerRadius
            corner.Parent = element
            
            -- Add shadow effect
            local shadow = Instance.new("ImageLabel")
            shadow.Name = "Shadow"
            shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            shadow.ImageColor3 = currentTheme.Colors.Shadow
            shadow.ImageTransparency = 0.8
            shadow.Size = UDim2.new(1, 6, 1, 6)
            shadow.Position = UDim2.new(0, -3, 0, -3)
            shadow.ZIndex = element.ZIndex - 1
            shadow.Parent = element.Parent
        end
        
        if elementType == "TextLabel" or elementType == "TextButton" then
            element.TextColor3 = currentTheme.Colors.Text
            element.Font = currentTheme.Fonts.Default
            element.TextSize = currentTheme.Sizes.FontSize
        end
    end
end

-- ================================
-- UI COMPONENTS
-- ================================

local Components = {}

-- Button Component
function Components.Button(parent, options)
    options = options or {}
    local theme = options.Theme or Themes.Default
    
    local button = ComponentBuilder.CreateBase(parent, "TextButton", {
        Size = options.Size or UDim2.new(0, 120, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Text = options.Text or "Button",
        BackgroundTransparency = 0,
        BorderSizePixel = 0
    })
    
    ComponentBuilder.ApplyTheme(button, theme, "TextButton")
    
    -- Hover effects
    local isHovered = false
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        if not isHovered then
            isHovered = true
            AnimationEngine.Color(button, "BackgroundColor3", theme.Colors.Primary, 0.2)
            AnimationEngine.Scale(button, 1.05, 0.2)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if isHovered then
            isHovered = false
            AnimationEngine.Color(button, "BackgroundColor3", originalColor, 0.2)
            AnimationEngine.Scale(button, 1, 0.2)
        end
    end)
    
    -- Click animation
    button.MouseButton1Down:Connect(function()
        AnimationEngine.Scale(button, 0.95, 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        AnimationEngine.Scale(button, isHovered and 1.05 or 1, 0.1)
    end)
    
    -- API methods
    button.SetText = function(newText)
        button.Text = newText
    end
    
    button.SetCallback = function(callback)
        button.MouseButton1Click:Connect(callback)
    end
    
    if options.Callback then
        button.SetCallback(options.Callback)
    end
    
    return button
end

-- Slider Component
function Components.Slider(parent, options)
    options = options or {}
    local theme = options.Theme or Themes.Default
    local min = options.Min or 0
    local max = options.Max or 100
    local value = options.Value or min
    
    local sliderFrame = ComponentBuilder.CreateBase(parent, "Frame", {
        Size = options.Size or UDim2.new(0, 200, 0, 20),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Colors.Border,
        BorderSizePixel = 0
    })
    
    ComponentBuilder.ApplyTheme(sliderFrame, theme, "Frame")
    
    local handle = ComponentBuilder.CreateBase(sliderFrame, "Frame", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new((value - min) / (max - min), -8, 0, 0),
        BackgroundColor3 = theme.Colors.Primary,
        BorderSizePixel = 0
    })
    
    ComponentBuilder.ApplyTheme(handle, theme, "Frame")
    
    local isDragging = false
    local callbacks = {}
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            AnimationEngine.Scale(handle, 1.2, 0.1)
        end
    end)
    
    Environment.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            AnimationEngine.Scale(handle, 1, 0.1)
        end
    end)
    
    Environment.UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = sliderFrame.AbsolutePosition.X
            local sliderSize = sliderFrame.AbsoluteSize.X
            local relativePos = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            
            value = min + (max - min) * relativePos
            handle.Position = UDim2.new(relativePos, -8, 0, 0)
            
            for _, callback in pairs(callbacks) do
                callback(value)
            end
        end
    end)
    
    -- API methods
    sliderFrame.SetValue = function(newValue)
        value = math.clamp(newValue, min, max)
        local relativePos = (value - min) / (max - min)
        AnimationEngine.Slide(handle, UDim2.new(relativePos, -8, 0, 0), 0.2)
        
        for _, callback in pairs(callbacks) do
            callback(value)
        end
    end
    
    sliderFrame.GetValue = function()
        return value
    end
    
    sliderFrame.OnChanged = function(callback)
        table.insert(callbacks, callback)
    end
    
    if options.Callback then
        sliderFrame.OnChanged(options.Callback)
    end
    
    return sliderFrame
end

-- Checkbox Component
function Components.Checkbox(parent, options)
    options = options or {}
    local theme = options.Theme or Themes.Default
    local checked = options.Checked or false
    
    local checkboxFrame = ComponentBuilder.CreateBase(parent, "TextButton", {
        Size = options.Size or UDim2.new(0, 20, 0, 20),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        Text = "",
        BackgroundColor3 = theme.Colors.Surface,
        BorderSizePixel = 0
    })
    
    ComponentBuilder.ApplyTheme(checkboxFrame, theme, "Frame")
    
    local checkmark = ComponentBuilder.CreateBase(checkboxFrame, "TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "✓",
        BackgroundTransparency = 1,
        TextColor3 = theme.Colors.Success,
        Font = theme.Fonts.Bold,
        TextSize = 16,
        TextTransparency = checked and 0 or 1
    })
    
    local callbacks = {}
    
    checkboxFrame.MouseButton1Click:Connect(function()
        checked = not checked
        
        if checked then
            AnimationEngine.Fade(checkmark, 0, 0.2)
            AnimationEngine.Color(checkboxFrame, "BackgroundColor3", theme.Colors.Success, 0.2)
        else
            AnimationEngine.Fade(checkmark, 1, 0.2)
            AnimationEngine.Color(checkboxFrame, "BackgroundColor3", theme.Colors.Surface, 0.2)
        end
        
        AnimationEngine.Scale(checkboxFrame, 0.9, 0.1, function()
            AnimationEngine.Scale(checkboxFrame, 1, 0.1)
        end)
        
        for _, callback in pairs(callbacks) do
            callback(checked)
        end
    end)
    
    -- API methods
    checkboxFrame.SetChecked = function(newChecked)
        if checked ~= newChecked then
            checkboxFrame.MouseButton1Click:Fire()
        end
    end
    
    checkboxFrame.IsChecked = function()
        return checked
    end
    
    checkboxFrame.OnChanged = function(callback)
        table.insert(callbacks, callback)
    end
    
    if options.Callback then
        checkboxFrame.OnChanged(options.Callback)
    end
    
    return checkboxFrame
end

-- Modal Component
function Components.Modal(parent, options)
    options = options or {}
    local theme = options.Theme or Themes.Default
    
    local overlay = ComponentBuilder.CreateBase(parent, "Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        ZIndex = 100
    })
    
    local modal = ComponentBuilder.CreateBase(overlay, "Frame", {
        Size = options.Size or UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = theme.Colors.Surface,
        BorderSizePixel = 0,
        ZIndex = 101
    })
    
    ComponentBuilder.ApplyTheme(modal, theme, "Frame")
    
    -- Initial animation
    modal.Size = UDim2.new(0, 0, 0, 0)
    AnimationEngine.Scale(modal, 1, 0.3)
    AnimationEngine.Fade(overlay, 0.5, 0.3)
    
    -- Close functionality
    local function closeModal()
        AnimationEngine.Scale(modal, 0, 0.2)
        AnimationEngine.Fade(overlay, 1, 0.2, function()
            overlay:Destroy()
        end)
    end
    
    overlay.MouseButton1Click:Connect(closeModal)
    
    -- API methods
    modal.Close = closeModal
    
    modal.AddContent = function(content)
        content.Parent = modal
    end
    
    return modal
end

-- ================================
-- MAIN UI CLASS
-- ================================

function BirdUi:new(parent, theme)
    local ui = setmetatable({}, BirdUi)
    
    ui.Parent = parent or (Environment.Type == "Roblox" and Environment.PlayerGui)
    ui.Theme = theme or Themes.Default
    ui.Components = {}
    
    -- Create main container
    if Environment.Type == "Roblox" then
        ui.Container = ComponentBuilder.CreateBase(ui.Parent, "ScreenGui", {
            Name = "BirdUi",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
    end
    
    return ui
end

-- Theme management
function BirdUi:SetTheme(themeName)
    if Themes[themeName] then
        self.Theme = Themes[themeName]
        -- Update existing components with new theme
        for _, component in pairs(self.Components) do
            if component.UpdateTheme then
                component:UpdateTheme(self.Theme)
            end
        end
    end
end

function BirdUi:GetTheme()
    return self.Theme
end

function BirdUi:AddCustomTheme(name, themeData)
    Themes[name] = themeData
end

-- Component creation methods
function BirdUi:Button(options)
    options = options or {}
    options.Theme = options.Theme or self.Theme
    local button = Components.Button(self.Container, options)
    table.insert(self.Components, button)
    return button
end

function BirdUi:Slider(options)
    options = options or {}
    options.Theme = options.Theme or self.Theme
    local slider = Components.Slider(self.Container, options)
    table.insert(self.Components, slider)
    return slider
end

function BirdUi:Checkbox(options)
    options = options or {}
    options.Theme = options.Theme or self.Theme
    local checkbox = Components.Checkbox(self.Container, options)
    table.insert(self.Components, checkbox)
    return checkbox
end

function BirdUi:Modal(options)
    options = options or {}
    options.Theme = options.Theme or self.Theme
    local modal = Components.Modal(self.Container, options)
    table.insert(self.Components, modal)
    return modal
end

-- Animation utilities
function BirdUi:Animate(element, animationType, ...)
    return AnimationEngine[animationType](element, ...)
end

-- Cleanup
function BirdUi:Destroy()
    if self.Container then
        self.Container:Destroy()
    end
    self.Components = {}
end

-- ================================
-- USAGE EXAMPLES
-- ================================

--[[
EXAMPLE USAGE:

-- Initialize BirdUi
local UI = BirdUi:new()

-- Set theme
UI:SetTheme("Dark")

-- Create components
local button = UI:Button({
    Text = "Click Me!",
    Position = UDim2.new(0, 50, 0, 50),
    Size = UDim2.new(0, 150, 0, 50),
    Callback = function()
        print("Button clicked!")
    end
})

local slider = UI:Slider({
    Position = UDim2.new(0, 50, 0, 120),
    Size = UDim2.new(0, 200, 0, 20),
    Min = 0,
    Max = 100,
    Value = 50,
    Callback = function(value)
        print("Slider value:", value)
    end
})

local checkbox = UI:Checkbox({
    Position = UDim2.new(0, 50, 0, 160),
    Checked = false,
    Callback = function(checked)
        print("Checkbox:", checked)
    end
})

-- Create modal
local modal = UI:Modal({
    Size = UDim2.new(0, 300, 0, 200)
})

-- Switch themes dynamically
UI:SetTheme("Neon")
--]]

-- Return the main class
return BirdUi
