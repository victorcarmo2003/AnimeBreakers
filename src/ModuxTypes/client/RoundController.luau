--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Status = "Waiting" | "Playing" | "Ending"

export type Public = {
	Seconds: Vide.Source<number>,
	Status: Vide.Source<Status>,
	Setup: (self: Public) -> (),
}

return {}
