local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.DevPackages.UILabs)
local Vide = require(ReplicatedStorage.Packages.Vide)
local HealthBar = require(script.Parent)

const create = Vide.create

return UILabs.CreateVideStory({
	vide = Vide,
	controls = {
		Health = UILabs.Slider(650, 0, 1000, 10),
		MaxHealth = 1000,
		BossHealth = UILabs.Slider(7200, 0, 10000, 100),
		BossMaxHealth = 10000,
	},
}, function(props)
	return create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 24),
		}),

		HealthBar.Bar({
			Name = "Boneco de Treino",
			Health = function(): number
				return props.controls.Health()
			end,
			MaxHealth = function(): number
				return props.controls.MaxHealth()
			end,
		}),

		HealthBar.Bar({
			Name = "Chefe de Treino",
			Boss = true,
			Health = function(): number
				return props.controls.BossHealth()
			end,
			MaxHealth = function(): number
				return props.controls.BossMaxHealth()
			end,
		}),
	})
end)
