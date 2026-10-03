local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.DevPackages.UILabs)

return {
	name = "ModuxTemplate",
	storyRoots = { script.Parent.Components },
} :: UILabs.Storybook
