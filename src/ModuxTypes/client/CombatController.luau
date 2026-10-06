--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Content = require(ReplicatedStorage.shared.Content)
local Stage = require(StarterPlayer.StarterPlayerScripts.client.Combat.CombatController.Stage)

export type Beat = {
	Unit: number,
	Move: Content.Move,
}

export type Public = {
	Stage: Stage.Stage,
	Setup: (self: Public) -> (),
	Owns: (self: Public, unitId: number) -> boolean,
	OnBeat: (self: Public, beat: Beat, sent: number?) -> (),
	ShareStage: (self: Public) -> (),
}

return {}
