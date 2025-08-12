local Style = {}

Style.colors = {
	background = Color3.fromRGB(253, 252, 250),
	surface = Color3.fromRGB(255, 255, 255),
	surfaceAlt = Color3.fromRGB(246, 248, 252),
	stroke = Color3.fromRGB(222, 226, 235),
	text = Color3.fromRGB(35, 38, 46),
	subtext = Color3.fromRGB(120, 126, 140),
	scrollbar = Color3.fromRGB(180, 185, 200),

	kitty = Color3.fromRGB(255, 64, 64),
	kuromiLav = Color3.fromRGB(200, 190, 255),
	kuromiInk = Color3.fromRGB(38, 38, 46),
	cinnaSky = Color3.fromRGB(186, 214, 255),
	kuromiDark = Color3.fromRGB(22, 22, 26),
	neonPink = Color3.fromRGB(255, 80, 180),
}

Style.radii = {
	panel = 24,
	section = 18,
	cardOuter = 20,
	cardInner = 16,
	pill = 999,
}

Style.stroke = {
	thin = 1,
	regular = 1.5,
	thick = 2,
	neon = 3,
}

Style.fonts = {
	display = function(weight)
		return Font.new("rbxasset://fonts/families/GothamSSm.json", weight or Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	end,
	monoDisplay = function(weight)
		return Font.new("rbxasset://fonts/families/RobotoMono.json", weight or Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	end,
}

function Style.applyCorner(gui, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px)
	c.Parent = gui
	return c
end

function Style.applyStroke(gui, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Style.colors.stroke
	s.Thickness = thickness or Style.stroke.regular
	s.Transparency = transparency or 0
	s.Parent = gui
	return s
end

function Style.setFont(label: TextLabel | TextButton, fontFace: Font, size: number)
	label.FontFace = fontFace
	label.TextSize = size
end

function Style.blendTowardWhite(c: Color3, t: number): Color3
	return Color3.new(c.R + (1 - c.R) * t, c.G + (1 - c.G) * t, c.B + (1 - c.B) * t)
end

return Style