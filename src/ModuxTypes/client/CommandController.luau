--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Public = {
	LastCommandAt: number,
	PickParams: RaycastParams,
	Target: Vide.Source<number?>,
	Setup: (self: Public) -> (),
	CurrentTarget: (self: Public) -> number?,
	CanCommand: (self: Public) -> boolean,
	PickEnemy: (self: Public, screenPosition: Vector2) -> number?,
	IsTargetActive: (self: Public, uid: number) -> boolean,
	Attack: (self: Public, uid: number) -> (),
	Recall: (self: Public) -> (),
	OnWorldTap: (self: Public, screenPosition: Vector2) -> (),
	WatchTargetDeath: (self: Public) -> (),
	BindRecall: (self: Public) -> (),
}

return {}
