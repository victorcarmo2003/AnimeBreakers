local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Theme = require(script.Parent.Theme)

const create = Vide.create

export type Props = {
	Image: Theme.Reactive<string>,
	Visible: Theme.Reactive<boolean>?,
	Size: Theme.Reactive<UDim2>?,
	Position: Theme.Reactive<UDim2>?,
	AnchorPoint: Vector2?,
	ScaleType: Enum.ScaleType?,
	SliceCenter: Rect?,
	ImageColor3: Theme.Reactive<Color3>?,
	ZIndex: number?,
	LayoutOrder: number?,
	Children: { any }?,
}

return function(props: Props): ImageLabel
	const imageId = function(): string?
		return Theme.ImageId(Theme.ReadText(props.Image))
	end

	return create("ImageLabel")({
		Name = function()
			return Theme.ReadText(props.Image)
		end,
		Visible = props.Visible,
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
		ScaleType = props.ScaleType or Enum.ScaleType.Fit,
		SliceCenter = props.SliceCenter,
		ImageColor3 = props.ImageColor3,
		Image = function()
			return imageId() or ""
		end,
		BackgroundColor3 = Theme.NeutralColor,
		BackgroundTransparency = function()
			return if imageId() then 1 else 0
		end,

		create("UICorner")({
			CornerRadius = function()
				return if imageId() then UDim.new(0, 0) else Theme.CornerRadius
			end,
		}),

		props.Children,
	})
end
