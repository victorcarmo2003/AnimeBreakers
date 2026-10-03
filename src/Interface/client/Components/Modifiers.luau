local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

const effect = Vide.effect

const Modifiers = {}

function Modifiers.Scale(scale: () -> number): UIScale
	const instance = Instance.new("UIScale")
	effect(function()
		instance.Scale = scale()
	end)
	return instance
end

function Modifiers.MinSize(width: number, height: number): UISizeConstraint
	const instance = Instance.new("UISizeConstraint")
	instance.MinSize = Vector2.new(width, height)
	return instance
end

function Modifiers.TextSize(minSize: number, maxSize: number): UITextSizeConstraint
	const instance = Instance.new("UITextSizeConstraint")
	instance.MinTextSize = minSize
	instance.MaxTextSize = maxSize
	return instance
end

function Modifiers.Padding(horizontal: number, vertical: number): UIPadding
	const instance = Instance.new("UIPadding")
	instance.PaddingLeft = UDim.new(0, horizontal)
	instance.PaddingRight = UDim.new(0, horizontal)
	instance.PaddingTop = UDim.new(0, vertical)
	instance.PaddingBottom = UDim.new(0, vertical)
	return instance
end

function Modifiers.Stroke(color: Color3, thickness: number, enabled: () -> boolean): UIStroke
	const instance = Instance.new("UIStroke")
	instance.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	instance.Color = color
	instance.Thickness = thickness
	effect(function()
		instance.Enabled = enabled()
	end)
	return instance
end

return Modifiers
