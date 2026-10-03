local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.DevPackages.UILabs)
local Vide = require(ReplicatedStorage.Packages.Vide)
local Panel = require(script.Parent)

const create = Vide.create

return UILabs.CreateVideStory({
	vide = Vide,
	controls = {
		Key = "InventoryBackground",
		Open = true,
	},
}, function(props)
	return Panel({
		Image = function(): string
			return props.controls.Key()
		end,
		Open = function(): boolean
			return props.controls.Open()
		end,
		Size = UDim2.fromOffset(320, 220),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Children = {
			create("TextLabel")({
				Size = UDim2.new(1, 0, 0, 32),
				Position = UDim2.fromOffset(0, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 20,
				TextColor3 = Color3.fromRGB(240, 240, 245),
				Text = "Panel",
			}),
		},
	})
end)
