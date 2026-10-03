local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)

export type Reactive<T> = T | () -> T

const unpublishedImageIds: { [string]: boolean } = {
	[""] = true,
	["rbxassetid://0"] = true,
}

const Theme = {
	MinTouchSize = 44,
	MinTextSize = 14,
	MaxTextSize = 32,
	Font = Enum.Font.GothamBold,
	TextColor = Color3.fromRGB(240, 240, 245),
	NeutralColor = Color3.fromRGB(58, 58, 68),
	NeutralPressedColor = Color3.fromRGB(42, 42, 50),
	NeutralStrokeColor = Color3.fromRGB(110, 110, 125),
	DisabledTransparency = 0.5,
	PressedTint = Color3.fromRGB(190, 190, 190),
	PressedScale = 0.92,
	PressSpringPeriod = 0.12,
	OverlayColor = Color3.new(0, 0, 0),
	OverlayTransparency = 0.45,
	CornerRadius = UDim.new(0, 12),
	StrokeThickness = 2,
}

function Theme.ImageId(key: string): string?
	const id = Content.Interface.Images[key]
	if id == nil or unpublishedImageIds[id] then
		return nil
	end
	return id
end

function Theme.ReadText(value: Reactive<string>): string
	return if type(value) == "function" then value() else value
end

function Theme.ReadFlag(value: Reactive<boolean>?): boolean
	if value == nil then
		return false
	end
	return if type(value) == "function" then value() else value
end

return Theme
