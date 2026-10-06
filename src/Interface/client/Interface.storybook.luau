local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.DevPackages.UILabs)

return {
	name = "AnimeBreakers",
	storyRoots = { script.Parent.Components, script.Parent.Parent.Enemy },
} :: UILabs.Storybook
