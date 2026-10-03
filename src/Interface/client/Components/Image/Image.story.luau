local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.DevPackages.UILabs)
local Vide = require(ReplicatedStorage.Packages.Vide)
local Image = require(script.Parent)

return UILabs.CreateVideStory({
	vide = Vide,
	controls = {
		Key = "HudCoinIcon",
	},
}, function(props)
	return Image({
		Image = function(): string
			return props.controls.Key()
		end,
		Size = UDim2.fromOffset(96, 96),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
	})
end)
