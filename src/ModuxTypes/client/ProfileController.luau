--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Public = {
	Coins: Vide.Source<number>,
	Level: Vide.Source<number>,
	Playtime: Vide.Source<number>,
	Ready: Vide.Source<boolean>,
	Setup: (self: Public) -> (),
}

return {}
