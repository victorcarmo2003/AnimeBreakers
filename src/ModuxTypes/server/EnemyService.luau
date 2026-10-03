--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)
local SignalLib = require(ReplicatedStorage.shared.Libs.Signal)

export type Ledger = { [Player]: number }
export type Enemy = {
	Uid: number,
	Def: Content.EnemyDef,
	Health: number,
	MaxHealth: number,
	Alive: boolean,
	Life: number,
	Position: Vector3,
	Ledger: Ledger,
	TakeDamage: (self: any, amount: number, player: Player) -> number,
}
export type EnemySnapshot = {
	Uid: number,
	EnemyId: string,
	Health: number,
	MaxHealth: number,
	Alive: boolean,
	Life: number,
}

export type Public = {
	Died: SignalLib.Signal<number, Ledger, Content.EnemyDef>,
	LastUid: number,
	Registry: { [number]: Enemy },
	Spawned: SignalLib.Signal<number>,
	Setup: (self: Public) -> (),
	NextUid: (self: Public) -> number,
	CanPublish: (self: Public) -> boolean,
	Register: (self: Public, enemy: Enemy) -> (),
	Unregister: (self: Public, uid: number) -> (),
	NotifyRespawned: (self: Public, uid: number) -> (),
	NotifyDied: (self: Public, uid: number, ledger: Ledger, def: Content.EnemyDef) -> (),
	Get: (self: Public, uid: number) -> Enemy?,
	Position: (self: Public, uid: number) -> Vector3?,
	ApplyDamage: (self: Public, uid: number, amount: number, player: Player) -> number,
	Snapshot: (self: Public) -> { EnemySnapshot },
}

return {}
