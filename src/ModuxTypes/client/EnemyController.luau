--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)
local RigAnimator = require(ReplicatedStorage.shared.Rig.RigAnimator)

export type EnemyRecord = {
	Enemy: string,
	Position: Vector3,
	Yaw: number,
	Health: number,
	MaxHealth: number,
	Alive: boolean,
	Life: number,
}
export type EnemyActor = {
	Uid: number,
	Def: Content.EnemyDef,
	Character: Content.CharacterDef,
	Model: Model,
	PickBox: BasePart,
	Animator: RigAnimator.RigAnimator,
	Pivot: CFrame,
	Health: Vide.Source<number>,
	MaxHealth: Vide.Source<number>,
	Alive: Vide.Source<boolean>,
	Life: number,
	HideThread: thread?,
	DisposeInterface: () -> (),
}

export type Public = {
	Actors: { [number]: EnemyActor },
	Folder: Folder?,
	UidByModel: { [Model]: number },
	Setup: (self: Public) -> (),
	EnemiesFolder: (self: Public) -> Folder,
	Pick: (self: Public, instance: Instance?) -> number?,
	Rig: (self: Public, uid: number) -> RigAnimator.RigAnimator?,
	Model: (self: Public, uid: number) -> Model?,
	Health: (self: Public, uid: number) -> Vide.Source<number>?,
	MaxHealth: (self: Public, uid: number) -> Vide.Source<number>?,
	Alive: (self: Public, uid: number) -> Vide.Source<boolean>?,
	CancelHide: (self: Public, actor: EnemyActor) -> (),
	Show: (self: Public, actor: EnemyActor) -> (),
	Hide: (self: Public, actor: EnemyActor) -> (),
	PlayDeath: (self: Public, actor: EnemyActor) -> (),
	PlaySpawn: (self: Public, actor: EnemyActor) -> (),
	CreateActor: (self: Public, uid: number, record: EnemyRecord) -> EnemyActor?,
	OnAdded: (self: Public, uid: number, record: EnemyRecord) -> (),
	OnChanged: (self: Public, uid: number, record: EnemyRecord) -> (),
	OnRemoved: (self: Public, uid: number) -> (),
	PreloadAssets: (self: Public) -> (),
}

return {}
