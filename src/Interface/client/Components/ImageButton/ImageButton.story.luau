local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.DevPackages.UILabs)
local Vide = require(ReplicatedStorage.Packages.Vide)
local ImageButton = require(script.Parent)

const create = Vide.create
const source = Vide.source

return UILabs.CreateVideStory({
	vide = Vide,
	controls = {
		Key = "HudStopButton",
		Text = "Stop",
		Disabled = false,
	},
}, function(props)
	const presses = source(0)

	return create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		ImageButton({
			Image = function(): string
				return props.controls.Key()
			end,
			Text = function(): string
				return `{props.controls.Text()} ({presses()})`
			end,
			Disabled = function(): boolean
				return props.controls.Disabled()
			end,
			OnActivated = function()
				presses(presses() + 1)
			end,
			Size = UDim2.fromOffset(160, 64),
			Position = UDim2.fromScale(0.5, 0.4),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),

		ImageButton({
			Image = "StoryMissingKey",
			Text = "X",
			OnActivated = function()
				presses(0)
			end,
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.fromScale(0.5, 0.65),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),
	})
end)
