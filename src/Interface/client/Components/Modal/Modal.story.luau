local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.DevPackages.UILabs)
local Vide = require(ReplicatedStorage.Packages.Vide)
local Modal = require(script.Parent)
local ImageButton = require(script.Parent.Parent.ImageButton)

const create = Vide.create
const source = Vide.source

return UILabs.CreateVideStory({
	vide = Vide,
	controls = {
		Key = "InventoryBackground",
		CloseKey = "InventoryCloseButton",
	},
}, function(props)
	const open = source(true)

	return create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		ImageButton({
			Image = "StoryOpenButton",
			Text = "Open",
			OnActivated = function()
				open(true)
			end,
			Size = UDim2.fromOffset(120, 56),
			Position = UDim2.new(0, 16, 1, -16),
			AnchorPoint = Vector2.new(0, 1),
		}),

		Modal({
			Image = function(): string
				return props.controls.Key()
			end,
			CloseImage = function(): string
				return props.controls.CloseKey()
			end,
			Open = open,
			OnClose = function()
				open(false)
			end,
			Children = {
				create("TextLabel")({
					Size = UDim2.new(1, 0, 0, 32),
					Position = UDim2.fromOffset(0, 16),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					TextSize = 20,
					TextColor3 = Color3.fromRGB(240, 240, 245),
					Text = "Modal",
				}),
			},
		}),
	})
end)
