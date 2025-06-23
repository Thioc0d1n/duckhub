local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
	TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	FAST_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	SLOWER_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	SPRING_TWEEN = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	THEMES = {
		Dark = {
			Background = Color3.fromRGB(26, 26, 26),
			Secondary = Color3.fromRGB(35, 35, 35),
			Accent = Color3.fromRGB(0, 212, 255),
			Text = Color3.fromRGB(255, 255, 255),
			TextDim = Color3.fromRGB(200, 200, 200),
			Border = Color3.fromRGB(60, 60, 60),
			Success = Color3.fromRGB(46, 204, 113),
			Warning = Color3.fromRGB(241, 196, 15),
			Error = Color3.fromRGB(231, 76, 60)
		},
		Light = {
			Background = Color3.fromRGB(255, 255, 255),
			Secondary = Color3.fromRGB(245, 245, 245),
			Accent = Color3.fromRGB(0, 123, 255),
			Text = Color3.fromRGB(33, 37, 41),
			TextDim = Color3.fromRGB(108, 117, 125),
			Border = Color3.fromRGB(222, 226, 230),
			Success = Color3.fromRGB(40, 167, 69),
			Warning = Color3.fromRGB(255, 193, 7),
			Error = Color3.fromRGB(220, 53, 69)
		}
	}
}

local Utilities = {}

function Utilities:CreateInstance(className, properties)
	local instance = Instance.new(className)
	for property, value in pairs(properties) do
		if property ~= "Parent" then
			instance[property] = value
		end
	end
	if properties.Parent then
		instance.Parent = properties.Parent
	end
	return instance
end

function Utilities:Tween(object, properties, tweenInfo)
	tweenInfo = tweenInfo or CONFIG.TWEEN_INFO
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

function Utilities:CreateCorner(radius)
	return self:CreateInstance("UICorner", {CornerRadius = UDim.new(0, radius)})
end

function Utilities:CreateStroke(thickness, color, transparency)
	return self:CreateInstance("UIStroke", {
		Thickness = thickness,
		Color = color,
		Transparency = transparency or 0
	})
end

function Utilities:CreateGradient(colorSequence, rotation)
	return self:CreateInstance("UIGradient", {
		Color = colorSequence,
		Rotation = rotation or 0
	})
end


function Utilities:CreateBlur(parent, size)
	local blur = self:CreateInstance("Frame", {
		Name = "BlurFrame",
		Parent = parent,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Size = size or UDim2.new(1, 0, 1, 0),
		ZIndex = 100
	})
	self:CreateCorner(8).Parent = blur
	return blur
end

function Utilities:CreateRipple(parent, position)
	if typeof(position) ~= "Vector2" then return end

	local rippleContainer = self:CreateInstance("Frame", {
		Name = "RippleOverlay",
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = parent.ZIndex + 1,
	})

	local ripple = self:CreateInstance("Frame", {
		Name = "Ripple",
		Parent = rippleContainer,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, position.X, 0, position.Y - 100),
		ZIndex = rippleContainer.ZIndex + 1
	})

	self:CreateCorner(50).Parent = ripple

	local tween = TweenService:Create(ripple, CONFIG.SLOWER_TWEEN, {
		Size = UDim2.new(0, 200, 0, 200),
		Position = UDim2.new(0, position.X - 100, 0, position.Y - 100),
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		rippleContainer:Destroy()
	end)
end

local Library = {
	Windows = {},
	Themes = CONFIG.THEMES,
	Notifications = {},
	Keybinds = {},
	CurrentTheme = "Dark",
	SavedConfigs = {}
}

local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager:Create()
	local self = setmetatable({}, NotificationManager)

	self.Container = Utilities:CreateInstance("Frame", {
		Name = "NotificationContainer",
		Parent = PlayerGui,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -320, 0, 20),
		Size = UDim2.new(0, 300, 1, -40),
		ZIndex = 1000
	})

	Utilities:CreateInstance("UIListLayout", {
		Parent = self.Container,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10)
	})

	return self
end

function NotificationManager:Notify(title, message, type, duration)
	type = type or "info"
	duration = duration or 5

	local colors = {
		info = Library.Themes[Library.CurrentTheme].Accent,
		success = Library.Themes[Library.CurrentTheme].Success,
		warning = Library.Themes[Library.CurrentTheme].Warning,
		error = Library.Themes[Library.CurrentTheme].Error
	}

	local notification = Utilities:CreateInstance("Frame", {
		Name = "Notification",
		Parent = self.Container,
		BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 80),
		Position = UDim2.new(1, 0, 0, 0)
	})

	Utilities:CreateCorner(8).Parent = notification
	Utilities:CreateStroke(2, colors[type]).Parent = notification

	local icon = Utilities:CreateInstance("TextLabel", {
		Name = "Icon",
		Parent = notification,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 10),
		Size = UDim2.new(0, 20, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = type == "success" and "✓" or type == "warning" and "⚠" or type == "error" and "✗" or "ℹ",
		TextColor3 = colors[type],
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Center
	})

	local titleLabel = Utilities:CreateInstance("TextLabel", {
		Name = "Title",
		Parent = notification,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 45, 0, 8),
		Size = UDim2.new(1, -65, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Library.Themes[Library.CurrentTheme].Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local messageLabel = Utilities:CreateInstance("TextLabel", {
		Name = "Message",
		Parent = notification,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 45, 0, 28),
		Size = UDim2.new(1, -65, 0, 40),
		Font = Enum.Font.Gotham,
		Text = message,
		TextColor3 = Library.Themes[Library.CurrentTheme].TextDim,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true
	})

	local closeButton = Utilities:CreateInstance("TextButton", {
		Name = "CloseButton",
		Parent = notification,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -30, 0, 5),
		Size = UDim2.new(0, 25, 0, 25),
		Font = Enum.Font.GothamBold,
		Text = "×",
		TextColor3 = Library.Themes[Library.CurrentTheme].TextDim,
		TextSize = 18
	})

	Utilities:Tween(notification, {Position = UDim2.new(0, 0, 0, 0)})

	local progressBar = Utilities:CreateInstance("Frame", {
		Name = "ProgressBar",
		Parent = notification,
		BackgroundColor3 = colors[type],
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 3)
	})

	Utilities:Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))

	local function closeNotification()
		Utilities:Tween(notification, {
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 0)
		}).Completed:Connect(function()
			notification:Destroy()
		end)
	end

	closeButton.MouseButton1Click:Connect(closeNotification)

	spawn(function()
		wait(duration)
		if notification.Parent then
			closeNotification()
		end
	end)

	return notification
end

local Window = {}
Window.__index = Window

function Window:Create(title, config)
	local self = setmetatable({}, Window)

	config = config or {}
	self.Title = title
	self.Config = config
	self.Tabs = {}
	self.CurrentTab = nil
	self.Minimized = false
	self.Dragging = false

	self.GUI = Utilities:CreateInstance("ScreenGui", {
		Name = "NeuraUI_" .. title,
		Parent = PlayerGui,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})


	self.BlurFrame = Utilities:CreateBlur(self.GUI, UDim2.new(1, 0, 1, 0))
	self.BlurFrame.Visible = false

	self.Main = Utilities:CreateInstance("Frame", {
		Name = "MainWindow",
		Parent = self.GUI,
		BackgroundColor3 = Library.Themes[Library.CurrentTheme].Background,
		BorderSizePixel = 0,
		Position = config.Position or UDim2.new(0.5, -300, 0.5, -200),
		Size = config.Size or UDim2.new(0, 600, 0, 400),
		ClipsDescendants = true
	})

	Utilities:CreateCorner(12).Parent = self.Main
	Utilities:CreateStroke(1, Library.Themes[Library.CurrentTheme].Border).Parent = self.Main

	self.TitleBar = Utilities:CreateInstance("Frame", {
		Name = "TitleBar",
		Parent = self.Main,
		BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 50)
	})

	Utilities:CreateCorner(12).Parent = self.TitleBar
	Utilities:CreateInstance("Frame", {
		Parent = self.TitleBar,
		BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0.5, 0)
	})

	self.TitleLabel = Utilities:CreateInstance("TextLabel", {
		Name = "Title",
		Parent = self.TitleBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Library.Themes[Library.CurrentTheme].Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	self.MinimizeButton = Utilities:CreateInstance("TextButton", {
		Name = "Minimize",
		Parent = self.TitleBar,
		BackgroundColor3 = Library.Themes[Library.CurrentTheme].Warning,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -60, 0.5, -10),
		Size = UDim2.new(0, 20, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = "–",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14
	})
	Utilities:CreateCorner(10).Parent = self.MinimizeButton

	self.CloseButton = Utilities:CreateInstance("TextButton", {
		Name = "Close",
		Parent = self.TitleBar,
		BackgroundColor3 = Library.Themes[Library.CurrentTheme].Error,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -30, 0.5, -10),
		Size = UDim2.new(0, 20, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14
	})
	Utilities:CreateCorner(10).Parent = self.CloseButton

	self.TabContainer = Utilities:CreateInstance("Frame", {
		Name = "TabContainer",
		Parent = self.Main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(0, 150, 1, -50)
	})

	self.TabList = Utilities:CreateInstance("ScrollingFrame", {
		Name = "TabList",
		Parent = self.TabContainer,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Library.Themes[Library.CurrentTheme].Accent
	})

	self.TabListLayout = Utilities:CreateInstance("UIListLayout", {
		Parent = self.TabList,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 20)
	})

	self.ContentArea = Utilities:CreateInstance("Frame", {
		Name = "ContentArea",
		Parent = self.Main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 160, 0, 60),
		Size = UDim2.new(1, -170, 1, -70)
	})

	self:SetupInteractions()

	Library.Windows[title] = self

	return self
end

function Window:SetupInteractions()
	local dragStart, startPos

	self.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Dragging = true
			dragStart = input.Position
			startPos = self.Main.Position

			self.BlurFrame.Visible = true
			Utilities:Tween(self.BlurFrame, {BackgroundTransparency = 0.3})
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Dragging = false
			Utilities:Tween(self.BlurFrame, {BackgroundTransparency = 1}).Completed:Connect(function()
				self.BlurFrame.Visible = false
			end)
		end
	end)

	self.MinimizeButton.MouseButton1Click:Connect(function()
		self:ToggleMinimize()
	end)

	self.CloseButton.MouseButton1Click:Connect(function()
		self:Close()
	end)

	local function setupHoverEffect(button, hoverColor)
		local originalColor = button.BackgroundColor3

		button.MouseEnter:Connect(function()
			Utilities:Tween(button, {BackgroundColor3 = hoverColor})
		end)

		button.MouseLeave:Connect(function()
			Utilities:Tween(button, {BackgroundColor3 = originalColor})
		end)
	end

	setupHoverEffect(self.MinimizeButton, Color3.fromRGB(255, 206, 84))
	setupHoverEffect(self.CloseButton, Color3.fromRGB(255, 96, 92))
end

function Window:ToggleMinimize()
	self.Minimized = not self.Minimized

	if self.Minimized then
		Utilities:Tween(self.Main, {Size = UDim2.new(0, 300, 0, 50)})
		self.MinimizeButton.Text = "+"
	else
		Utilities:Tween(self.Main, {Size = self.Config.Size or UDim2.new(0, 600, 0, 400)})
		self.MinimizeButton.Text = "–"
	end
end

function Window:Close()
	Utilities:Tween(self.Main, {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}).Completed:Connect(function()
		self.GUI:Destroy()
		Library.Windows[self.Title] = nil
	end)
end

function Window:CreateTab(name, icon)
	local Tab = {}
	Tab.Name = name
	Tab.Icon = icon
	Tab.Elements = {}
	Tab.Window = self

	Tab.Button = Utilities:CreateInstance("TextButton", {
		Name = "TabButton_" .. name,
		Parent = self.TabList,
		BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -10, 0, 40),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = Library.Themes[Library.CurrentTheme].Text,
		TextSize = 14
	})

	Utilities:CreateCorner(8).Parent = Tab.Button

	if icon then
		Tab.IconLabel = Utilities:CreateInstance("ImageLabel", {
			Name = "Icon",
			Parent = Tab.Button,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0.5, -8),
			Size = UDim2.new(0, 16, 0, 16),
			Image = icon,
			ImageColor3 = Library.Themes[Library.CurrentTheme].TextDim
		})
	end

	Tab.TextLabel = Utilities:CreateInstance("TextLabel", {
		Name = "Text",
		Parent = Tab.Button,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, icon and 35 or 10, 0, 0),
		Size = UDim2.new(1, icon and -45 or -20, 1, 0),
		Font = Enum.Font.Gotham,
		Text = name,
		TextColor3 = Library.Themes[Library.CurrentTheme].TextDim,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	Tab.Content = Utilities:CreateInstance("ScrollingFrame", {
		Name = "TabContent_" .. name,
		Parent = self.ContentArea,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Library.Themes[Library.CurrentTheme].Accent,
		Visible = false
	})

	Tab.ContentLayout = Utilities:CreateInstance("UIListLayout", {
		Parent = Tab.Content,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10)
	})

	Tab.ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Tab.Content.CanvasSize = UDim2.new(0, 0, 0, Tab.ContentLayout.AbsoluteContentSize.Y + 20)
	end)

	Tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(Tab)
	end)

	Tab.Button.MouseEnter:Connect(function()
		if self.CurrentTab ~= Tab then
			Utilities:Tween(Tab.Button, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border})
		end
	end)

	Tab.Button.MouseLeave:Connect(function()
		if self.CurrentTab ~= Tab then
			Utilities:Tween(Tab.Button, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary})
		end
	end)

	function Tab:CreateToggle(name, callback)
		local Toggle = {}
		Toggle.Name = name
		Toggle.Callback = callback or function() end
		Toggle.Value = false

		Toggle.Container = Utilities:CreateInstance("Frame", {
			Name = "Toggle_" .. name,
			Parent = self.Content,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 0, 50)
		})

		Utilities:CreateCorner(8).Parent = Toggle.Container

		Toggle.Label = Utilities:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Toggle.Container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 0, 0),
			Size = UDim2.new(1, -70, 1, 0),
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		Toggle.Switch = Utilities:CreateInstance("Frame", {
			Name = "Switch",
			Parent = Toggle.Container,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -45, 0.5, -10),
			Size = UDim2.new(0, 40, 0, 20)
		})

		Utilities:CreateCorner(10).Parent = Toggle.Switch

		Toggle.Knob = Utilities:CreateInstance("Frame", {
			Name = "Knob",
			Parent = Toggle.Switch,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 2, 0, 2),
			Size = UDim2.new(0, 16, 0, 16)
		})

		Utilities:CreateCorner(8).Parent = Toggle.Knob

		Toggle.Button = Utilities:CreateInstance("TextButton", {
			Name = "Button",
			Parent = Toggle.Container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Text = ""
		})

		function Toggle:Set(value)
			self.Value = value

			if value then
				Utilities:Tween(self.Switch, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent})
				Utilities:Tween(self.Knob, {Position = UDim2.new(1, -18, 0, 2)})
			else
				Utilities:Tween(self.Switch, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border})
				Utilities:Tween(self.Knob, {Position = UDim2.new(0, 2, 0, 2)})
			end

			self.Callback(value)
		end

		Toggle.Button.MouseButton1Click:Connect(function()
			Toggle:Set(not Toggle.Value)
		end)

		return Toggle
	end

	function Tab:CreateSlider(name, min, max, default, callback)
		local Slider = {}
		Slider.Name = name
		Slider.Min = min
		Slider.Max = max
		Slider.Value = default or min
		Slider.Callback = callback or function() end

		Slider.Container = Utilities:CreateInstance("Frame", {
			Name = "Slider_" .. name,
			Parent = self.Content,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 0, 70)
		})

		Utilities:CreateCorner(8).Parent = Slider.Container

		Slider.Label = Utilities:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Slider.Container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 0, 5),
			Size = UDim2.new(1, -30, 0, 20),
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		Slider.ValueLabel = Utilities:CreateInstance("TextLabel", {
			Name = "ValueLabel",
			Parent = Slider.Container,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -60, 0, 5),
			Size = UDim2.new(0, 45, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = tostring(Slider.Value),
			TextColor3 = Library.Themes[Library.CurrentTheme].Accent,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right
		})

		Slider.Track = Utilities:CreateInstance("Frame", {
			Name = "Track",
			Parent = Slider.Container,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 15, 0, 40),
			Size = UDim2.new(1, -30, 0, 6)
		})

		Utilities:CreateCorner(3).Parent = Slider.Track

		Slider.Fill = Utilities:CreateInstance("Frame", {
			Name = "Fill",
			Parent = Slider.Track,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent,
			BorderSizePixel = 0,
			Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
		})

		Utilities:CreateCorner(3).Parent = Slider.Fill

		Slider.Knob = Utilities:CreateInstance("Frame", {
			Name = "Knob",
			Parent = Slider.Track,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -6, 0.5, -6),
			Size = UDim2.new(0, 12, 0, 12)
		})

		Utilities:CreateCorner(6).Parent = Slider.Knob
		Utilities:CreateStroke(2, Library.Themes[Library.CurrentTheme].Accent).Parent = Slider.Knob

		local dragging = false

		function Slider:Set(value)
			if not self.Min or not self.Max then print("hej") return end
			value = math.clamp(value, self.Min, self.Max)
			self.Value = value

			local percent = (value - self.Min) / (self.Max - self.Min)

			Utilities:Tween(self.Fill, {Size = UDim2.new(percent, 0, 1, 0)})
			Utilities:Tween(self.Knob, {Position = UDim2.new(percent, -6, 0.5, -6)})

			self.ValueLabel.Text = tostring(math.floor(value * 100) / 100)
			self.Callback(value)
		end

		Slider.Track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				local percent = math.clamp((input.Position.X - Slider.Track.AbsolutePosition.X) / Slider.Track.AbsoluteSize.X, 0, 1)
				local value = Slider.Min + (Slider.Max - Slider.Min) * percent
				Slider:Set(value)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local percent = math.clamp((input.Position.X - Slider.Track.AbsolutePosition.X) / Slider.Track.AbsoluteSize.X, 0, 1)
				local value = Slider.Min + (Slider.Max - Slider.Min) * percent
				Slider:Set(value)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		return Slider
	end

	function Tab:CreateDropdown(name, options, callback)
		local Dropdown = {}
		Dropdown.Name = name
		Dropdown.Options = options or {}
		Dropdown.Callback = callback or function() end
		Dropdown.Selected = options[1] or "None"
		Dropdown.Open = false

		Dropdown.Container = Utilities:CreateInstance("Frame", {
			Name = "Dropdown_" .. name,
			Parent = self.Content,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 0, 50),
			ZIndex = 1
		})

		Utilities:CreateCorner(8).Parent = Dropdown.Container

		Dropdown.Label = Utilities:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Dropdown.Container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 0, 0),
			Size = UDim2.new(1, -30, 0, 25),
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		Dropdown.Button = Utilities:CreateInstance("TextButton", {
			Name = "Button",
			Parent = Dropdown.Container,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 15, 0, 25),
			Size = UDim2.new(1, -30, 0, 20),
			Font = Enum.Font.Gotham,
			Text = Dropdown.Selected,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		Utilities:CreateCorner(4).Parent = Dropdown.Button

		Dropdown.Arrow = Utilities:CreateInstance("TextLabel", {
			Name = "Arrow",
			Parent = Dropdown.Button,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -25, 0, 0),
			Size = UDim2.new(0, 20, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = "▼",
			TextColor3 = Library.Themes[Library.CurrentTheme].TextDim,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Center
		})

		Dropdown.List = Utilities:CreateInstance("Frame", {
			Name = "List",
			Parent = Dropdown.Container,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Background,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 15, 0, 50),
			Size = UDim2.new(1, -30, 0, 0),
			ZIndex = 10,
			Visible = false
		})

		Utilities:CreateCorner(4).Parent = Dropdown.List
		Utilities:CreateStroke(1, Library.Themes[Library.CurrentTheme].Border).Parent = Dropdown.List

		Dropdown.ListLayout = Utilities:CreateInstance("UIListLayout", {
			Parent = Dropdown.List,
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		function Dropdown:Toggle()
			self.Open = not self.Open

			if self.Open then
				self.List.Visible = true
				local listHeight = math.min(#self.Options * 25, 150)
				Utilities:Tween(self.List, {Size = UDim2.new(1, -30, 0, listHeight)})
				Utilities:Tween(self.Container, {Size = UDim2.new(1, -20, 0, 50 + listHeight + 5)})
				Utilities:Tween(self.Arrow, {Rotation = 180})
			else
				Utilities:Tween(self.List, {Size = UDim2.new(1, -30, 0, 0)}).Completed:Connect(function()
					self.List.Visible = false
				end)
				Utilities:Tween(self.Container, {Size = UDim2.new(1, -20, 0, 50)})
				Utilities:Tween(self.Arrow, {Rotation = 0})
			end
		end

		function Dropdown:Set(option)
			self.Selected = option
			self.Button.Text = option
			self.Callback(option)
		end

		function Dropdown:AddOption(option)
			table.insert(self.Options, option)
			self:UpdateList()
		end

		function Dropdown:UpdateList()
			for _, child in pairs(self.List:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end

			for _, option in pairs(self.Options) do
				local optionButton = Utilities:CreateInstance("TextButton", {
					Name = "Option_" .. option,
					Parent = self.List,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 25),
					Font = Enum.Font.Gotham,
					Text = option,
					TextColor3 = Library.Themes[Library.CurrentTheme].Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				optionButton.MouseEnter:Connect(function()
					optionButton.BackgroundTransparency = 0.9
				end)

				optionButton.MouseLeave:Connect(function()
					optionButton.BackgroundTransparency = 1
				end)

				optionButton.MouseButton1Click:Connect(function()
					self:Set(option)
					self:Toggle()
				end)
			end
		end

		Dropdown:UpdateList()

		Dropdown.Button.MouseButton1Click:Connect(function()
			Dropdown:Toggle()
		end)

		return Dropdown
	end

	function Tab:CreateTextbox(name, placeholder, callback)
		local Textbox = {}
		Textbox.Name = name
		Textbox.Placeholder = placeholder or ""
		Textbox.Callback = callback or function() end
		Textbox.Value = ""

		Textbox.Container = Utilities:CreateInstance("Frame", {
			Name = "Textbox_" .. name,
			Parent = self.Content,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 0, 50)
		})

		Utilities:CreateCorner(8).Parent = Textbox.Container

		Textbox.Label = Utilities:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Textbox.Container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 0, 0),
			Size = UDim2.new(1, -30, 0, 25),
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		Textbox.Input = Utilities:CreateInstance("TextBox", {
			Name = "Input",
			Parent = Textbox.Container,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 15, 0, 25),
			Size = UDim2.new(1, -30, 0, 20),
			Font = Enum.Font.Gotham,
			PlaceholderText = placeholder,
			PlaceholderColor3 = Library.Themes[Library.CurrentTheme].TextDim,
			Text = "",
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		Utilities:CreateCorner(4).Parent = Textbox.Input

		local focusStroke = Utilities:CreateStroke(2, Library.Themes[Library.CurrentTheme].Accent, 1)
		focusStroke.Parent = Textbox.Input

		Textbox.Input.Focused:Connect(function()
			Utilities:Tween(focusStroke, {Transparency = 0})
		end)

		Textbox.Input.FocusLost:Connect(function()
			Utilities:Tween(focusStroke, {Transparency = 1})
			Textbox.Value = Textbox.Input.Text
			Textbox.Callback(Textbox.Value)
		end)

		function Textbox:Set(text)
			self.Value = text
			self.Input.Text = text
			self.Callback(text)
		end

		return Textbox
	end

	function Tab:CreateButton(name, callback)
		local Button = {}
		Button.Name = name
		Button.Callback = callback or function() end

		Button.Container = Utilities:CreateInstance("TextButton", {
			Name = "Button_" .. name,
			Parent = self.Content,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 0, 40),
			Font = Enum.Font.GothamBold,
			Text = name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14
		})

		Utilities:CreateCorner(8).Parent = Button.Container

		local originalColor = Button.Container.BackgroundColor3

		Button.Container.MouseEnter:Connect(function()
			Utilities:Tween(Button.Container, {
				BackgroundColor3 = Color3.fromRGB(
					math.min(originalColor.R * 255 + 20, 255),
					math.min(originalColor.G * 255 + 20, 255),
					math.min(originalColor.B * 255 + 20, 255)
				)
			})
		end)

		Button.Container.MouseLeave:Connect(function()
			Utilities:Tween(Button.Container, {BackgroundColor3 = originalColor})
		end)

		Button.Container.MouseButton1Click:Connect(function()
			local mousePos = UserInputService:GetMouseLocation()
			local absPos = Button.Container.AbsolutePosition
			local localPos = Vector2.new(mousePos.X - absPos.X, mousePos.Y - absPos.Y)

			Utilities:CreateRipple(Button.Container, localPos)
			Button.Callback()
		end)

		return Button
	end

	function Tab:CreateKeybind(name, default, callback)
		local Keybind = {}
		Keybind.Name = name
		Keybind.Key = default or Enum.KeyCode.Unknown
		Keybind.Callback = callback or function() end
		Keybind.Listening = false

		Keybind.Container = Utilities:CreateInstance("Frame", {
			Name = "Keybind_" .. name,
			Parent = self.Content,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 0, 50)
		})

		Utilities:CreateCorner(8).Parent = Keybind.Container

		Keybind.Label = Utilities:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Keybind.Container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 0, 0),
			Size = UDim2.new(1, -120, 1, 0),
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		Keybind.Button = Utilities:CreateInstance("TextButton", {
			Name = "Button",
			Parent = Keybind.Container,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -100, 0.5, -12),
			Size = UDim2.new(0, 85, 0, 24),
			Font = Enum.Font.Gotham,
			Text = Keybind.Key.Name,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 12
		})

		Utilities:CreateCorner(4).Parent = Keybind.Button

		function Keybind:Set(key)
			self.Key = key
			self.Button.Text = key.Name
			Library.Keybinds[self.Name] = {
				Key = key,
				Callback = self.Callback
			}
		end

		Keybind.Button.MouseButton1Click:Connect(function()
			if not Keybind.Listening then
				Keybind.Listening = true
				Keybind.Button.Text = "..."
				Keybind.Button.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent

				local connection
				connection = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						Keybind:Set(input.KeyCode)
						Keybind.Listening = false
						Keybind.Button.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border
						connection:Disconnect()
					end
				end)
			end
		end)

		if default ~= Enum.KeyCode.Unknown then
			Keybind:Set(default)
		end

		return Keybind
	end

	function Tab:CreateLabel(text)
		local Label = {}
		Label.Text = text

		Label.Container = Utilities:CreateInstance("TextLabel", {
			Name = "Label_" .. text:sub(1, 10),
			Parent = self.Content,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 30),
			Font = Enum.Font.Gotham,
			Text = text,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true
		})

		function Label:Set(text)
			self.Text = text
			self.Container.Text = text
		end

		return Label
	end

	function Tab:CreateSection(name)
		local Section = {}
		Section.Name = name

		Section.Container = Utilities:CreateInstance("Frame", {
			Name = "Section_" .. name,
			Parent = self.Content,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 40)
		})

		Section.Line = Utilities:CreateInstance("Frame", {
			Name = "Line",
			Parent = Section.Container,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 1)
		})

		Section.Label = Utilities:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Section.Container,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Background,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 10),
			Size = UDim2.new(0, 100, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = " " .. name .. " ",
			TextColor3 = Library.Themes[Library.CurrentTheme].Accent,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		return Section
	end

	function Tab:CreateColorPicker(name, default, callback)
		local ColorPicker = {}
		ColorPicker.Name = name
		ColorPicker.Color = default or Color3.fromRGB(255, 255, 255)
		ColorPicker.Callback = callback or function() end
		ColorPicker.Open = false

		ColorPicker.Container = Utilities:CreateInstance("Frame", {
			Name = "ColorPicker_" .. name,
			Parent = self.Content,
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 0, 50)
		})

		Utilities:CreateCorner(8).Parent = ColorPicker.Container

		ColorPicker.Label = Utilities:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = ColorPicker.Container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 0, 0),
			Size = UDim2.new(1, -70, 1, 0),
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = Library.Themes[Library.CurrentTheme].Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		ColorPicker.Preview = Utilities:CreateInstance("TextButton", {
			Name = "Preview",
			Parent = ColorPicker.Container,
			BackgroundColor3 = ColorPicker.Color,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -45, 0.5, -12),
			Size = UDim2.new(0, 30, 0, 24),
			Text = ""
		})

		Utilities:CreateCorner(4).Parent = ColorPicker.Preview
		Utilities:CreateStroke(2, Library.Themes[Library.CurrentTheme].Border).Parent = ColorPicker.Preview

		function ColorPicker:Set(color)
			self.Color = color
			self.Preview.BackgroundColor3 = color
			self.Callback(color)
		end

		ColorPicker.Preview.MouseButton1Click:Connect(function()
			local colors = {
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(0, 255, 0),
				Color3.fromRGB(0, 0, 255),
				Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(255, 0, 255),
				Color3.fromRGB(0, 255, 255),
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(0, 0, 0)
			}

			local randomColor = colors[math.random(1, #colors)]
			ColorPicker:Set(randomColor)
		end)

		return ColorPicker
	end

	self.Tabs[name] = Tab

	if #self.Tabs == 1 then
		self:SelectTab(Tab)
	end

	return Tab
end

function Window:SelectTab(tab)
	if self.CurrentTab then
		self.CurrentTab.Content.Visible = false
		Utilities:Tween(self.CurrentTab.Button, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Secondary})
		Utilities:Tween(self.CurrentTab.TextLabel, {TextColor3 = Library.Themes[Library.CurrentTheme].TextDim})
		if self.CurrentTab.IconLabel then
			Utilities:Tween(self.CurrentTab.IconLabel, {ImageColor3 = Library.Themes[Library.CurrentTheme].TextDim})
		end
	end

	self.CurrentTab = tab
	tab.Content.Visible = true
	Utilities:Tween(tab.Button, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent})
	Utilities:Tween(tab.TextLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)})
	if tab.IconLabel then
		Utilities:Tween(tab.IconLabel, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
	end
end

-- Library Functions
function Library:CreateWindow(title, config)
	return Window:Create(title, config)
end

function Library:Notify(title, message, type, duration)
	if not self.NotificationManager then
		self.NotificationManager = NotificationManager:Create()
	end
	return self.NotificationManager:Notify(title, message, type, duration)
end

function Library:SetTheme(themeName)
	if self.Themes[themeName] then
		self.CurrentTheme = themeName
	end
end

function Library:SaveConfig(name, config)
	self.SavedConfigs[name] = config
end

function Library:LoadConfig(name)
	return self.SavedConfigs[name]
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		for name, keybind in pairs(Library.Keybinds) do
			if keybind.Key == input.KeyCode then
				keybind.Callback()
			end
		end
	end
end)

Library.NotificationManager = NotificationManager:Create()

return Library
