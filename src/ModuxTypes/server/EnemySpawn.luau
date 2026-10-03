--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)

export type Public = {
	Instance: Instance,
	Active: boolean,
	Alive: boolean,
	Def: Content.EnemyDef,
	Health: number,
	Ledger: { [Player]: number },
	Life: number,
	MaxHealth: number,
	Position: Vector3,
	RespawnSeconds: number,
	RespawnThread: thread?,
	Uid: number,
	Yaw: number,
	Setup: (self: Public, part: BasePart, def: Content.EnemyDef) -> (),
	Publish: (self: Public, fields: { Health: number?, Alive: boolean?, Life: number? }) -> (),
	TakeDamage: (self: Public, amount: number, player: Player) -> number,
	ScheduleRespawn: (self: Public) -> (),
	Respawn: (self: Public) -> (),
}

return {}
