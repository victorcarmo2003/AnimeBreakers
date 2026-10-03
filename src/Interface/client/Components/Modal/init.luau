local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Theme = require(script.Parent.Theme)
local Panel = require(script.Parent.Panel)
local ImageButton = require(script.Parent.ImageButton)
local Modifiers = require(script.Parent.Modifiers)

const create = Vide.create

export type Props = {
	Image: Theme.Reactive<string>,
	CloseImage: Theme.Reactive<string>?,
	Open: () -> boolean,
	OnClose: () -> (),
	CloseOnBackdrop: boolean?,
	Size: Theme.Reactive<UDim2>?,
	ScaleType: Enum.ScaleType?,
	SliceCenter: Rect?,
	ZIndex: number?,
	Children: { any }?,
}

const closeButtonSize = 56
const defaultCloseImage = "ModalCloseButton"

return function(props: Props): Frame
	const closeImage = props.CloseImage or defaultCloseImage
	const zIndex = props.ZIndex or 10

	return create("Frame")({
		Name = "Modal",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = zIndex,
		Visible = props.Open,

		create("TextButton")({
			Name = "Backdrop",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.OverlayColor,
			BackgroundTransparency = Theme.OverlayTransparency,
			AutoButtonColor = false,
			Selectable = false,
			Text = "",
			ZIndex = zIndex,
			Activated = function()
				if props.CloseOnBackdrop ~= false then
					props.OnClose()
				end
			end,
		}),

		Panel({
			Image = props.Image,
			Open = props.Open,
			Size = props.Size or UDim2.fromScale(0.8, 0.8),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = props.ScaleType,
			SliceCenter = props.SliceCenter,
			ZIndex = zIndex + 1,
			Children = {
				Modifiers.MinSize(closeButtonSize * 4, closeButtonSize * 3),

				props.Children,

				ImageButton({
					Image = closeImage,
					Text = function(): string
						return if Theme.ImageId(Theme.ReadText(closeImage)) then "" else "X"
					end,
					OnActivated = props.OnClose,
					Size = UDim2.fromOffset(closeButtonSize, closeButtonSize),
					Position = UDim2.new(1, -8, 0, 8),
					AnchorPoint = Vector2.new(1, 0),
					ZIndex = zIndex + 2,
				}),
			},
		}),
	})
end
