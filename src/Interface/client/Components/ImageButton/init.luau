local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Theme = require(script.Parent.Theme)
local Modifiers = require(script.Parent.Modifiers)

const create = Vide.create
const source = Vide.source
const spring = Vide.spring

export type Props = {
	Image: Theme.Reactive<string>,
	OnActivated: () -> (),
	Text: Theme.Reactive<string>?,
	Disabled: Theme.Reactive<boolean>?,
	Visible: Theme.Reactive<boolean>?,
	Size: Theme.Reactive<UDim2>?,
	Position: Theme.Reactive<UDim2>?,
	AnchorPoint: Vector2?,
	ScaleType: Enum.ScaleType?,
	ZIndex: number?,
	LayoutOrder: number?,
	Children: { any }?,
}

const pressInputTypes: { [Enum.UserInputType]: boolean } = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true,
}

return function(props: Props): ImageButton
	const pressed = source(false)

	const imageId = function(): string?
		return Theme.ImageId(Theme.ReadText(props.Image))
	end

	const isDisabled = function(): boolean
		return Theme.ReadFlag(props.Disabled)
	end

	const scale = spring(function()
		return if pressed() then Theme.PressedScale else 1
	end, Theme.PressSpringPeriod)

	const label = if props.Text ~= nil
		then create("TextLabel")({
			Name = "Label",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Font = Theme.Font,
			TextColor3 = Theme.TextColor,
			TextScaled = true,
			Text = props.Text,
			TextTransparency = function()
				return if isDisabled() then Theme.DisabledTransparency else 0
			end,

			Modifiers.TextSize(Theme.MinTextSize, Theme.MaxTextSize),
			Modifiers.Padding(8, 4),
		})
		else nil

	return create("ImageButton")({
		Name = function()
			return Theme.ReadText(props.Image)
		end,
		Visible = props.Visible,
		Size = props.Size or UDim2.fromOffset(Theme.MinTouchSize, Theme.MinTouchSize),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
		AutoButtonColor = false,
		Selectable = true,
		Active = function()
			return not isDisabled()
		end,
		ScaleType = props.ScaleType or Enum.ScaleType.Fit,
		Image = function()
			return imageId() or ""
		end,
		ImageColor3 = function()
			return if pressed() then Theme.PressedTint else Color3.new(1, 1, 1)
		end,
		ImageTransparency = function()
			return if isDisabled() then Theme.DisabledTransparency else 0
		end,
		BackgroundColor3 = function()
			return if pressed() then Theme.NeutralPressedColor else Theme.NeutralColor
		end,
		BackgroundTransparency = function()
			if imageId() then
				return 1
			end
			return if isDisabled() then Theme.DisabledTransparency else 0
		end,

		MouseButton1Down = function()
			if not isDisabled() then
				pressed(true)
			end
		end,
		InputEnded = function(input: InputObject)
			if pressInputTypes[input.UserInputType] then
				pressed(false)
			end
		end,
		MouseLeave = function()
			pressed(false)
		end,
		Activated = function()
			pressed(false)
			if not isDisabled() then
				props.OnActivated()
			end
		end,

		Modifiers.MinSize(Theme.MinTouchSize, Theme.MinTouchSize),
		Modifiers.Scale(scale),

		create("UICorner")({
			CornerRadius = function()
				return if imageId() then UDim.new(0, 0) else Theme.CornerRadius
			end,
		}),

		Modifiers.Stroke(Theme.NeutralStrokeColor, Theme.StrokeThickness, function()
			return imageId() == nil
		end),

		label,

		props.Children,
	})
end
