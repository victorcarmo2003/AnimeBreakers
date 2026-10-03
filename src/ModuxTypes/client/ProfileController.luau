--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type InventoryEntry = {
	Uid: number,
	Pet: string,
	Level: number,
	Stars: number,
}
export type Reward = {
	Enemy: number,
	Coins: number,
}

export type Public = {
	AutoSkill: Vide.Source<boolean>,
	Coins: Vide.Source<number>,
	Equipped: Vide.Source<{ number }>,
	LastReward: Vide.Source<Reward?>,
	Pets: Vide.Source<{ InventoryEntry }>,
	Ready: Vide.Source<boolean>,
	Setup: (self: Public) -> (),
}

return {}
