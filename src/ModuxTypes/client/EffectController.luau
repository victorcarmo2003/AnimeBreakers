--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)

export type Target = Model | CFrame

export type Public = {
	Active: Vide.Source<number>,
	Container: Instance?,
	Library: Instance?,
	LowQuality: Vide.Source<boolean>,
	Pools: { [string]: { Instance } },
	Setup: (self: Public) -> (),
	AssetFor: (self: Public, definition: Content.EffectDef) -> Instance?,
	Acquire: (self: Public, asset: Instance) -> Instance,
	Place: (self: Public, instance: Instance, definition: Content.EffectDef, target: Target) -> boolean,
	Release: (self: Public, poolKey: string, instance: Instance) -> (),
	Play: (self: Public, effectKey: string, target: Target) -> boolean,
}

return {}
