local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Theme = require(script.Parent.Theme)
local Image = require(script.Parent.Image)
local Modifiers = require(script.Parent.Modifiers)

const spring = Vide.spring

export type Props = {
	Image: Theme.Reactive<string>,
	Open: (() -> boolean)?,
	Size: Theme.Reactive<UDim2>?,
	Position: Theme.Reactive<UDim2>?,
	AnchorPoint: Vector2?,
	ScaleType: Enum.ScaleType?,
	SliceCenter: Rect?,
	ZIndex: number?,
	LayoutOrder: number?,
	Children: { any }?,
}

const closedScale = 0.9
const openSpringPeriod = 0.18

return function(props: Props): ImageLabel
	const isOpen = props.Open or function(): boolean
		return true
	end

	const scale = spring(function()
		return if isOpen() then 1 else closedScale
	end, openSpringPeriod)

	return Image({
		Image = props.Image,
		Visible = isOpen,
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ScaleType = props.ScaleType,
		SliceCenter = props.SliceCenter,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
		Children = {
			Modifiers.Scale(scale),
			props.Children,
		},
	})
end
