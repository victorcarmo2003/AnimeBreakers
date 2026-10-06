--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type SlotState = {
	Unit: number,
	Slot: number,
	Pet: string,
	Status: SlotStatus,
	CanUse: boolean,
	Remaining: number,
	Cooldown: number,
	Progress: number,
}
export type SkillUnit = {
	Id: number,
	Owner: number,
	Slot: number,
	Pet: string,
	Target: number?,
	SkillReadyAt: number,
	ArriveAt: number,
}
export type MoveCommand = {
	Kind: "Attack" | "Recall",
	Enemy: number?,
}
export type SkillRequest = {
	ReadyAt: number,
	SentAt: number?,
}
export type Outbox = {
	Move: MoveCommand?,
	Auto: boolean?,
	Skills: { number },
}
export type SlotStatus = "Auto" | "Requested" | "Cooldown" | "Ready" | "Unavailable"

export type Public = {
	AutoRequested: boolean?,
	AutoSentAt: number,
	AutoSkill: Vide.Source<boolean>,
	Clock: Vide.Source<number>,
	LastSentAt: number,
	Outbox: Outbox,
	PickParams: RaycastParams,
	Revision: Vide.Source<number>,
	SkillRequests: { [number]: SkillRequest },
	Slots: Vide.Source<{ SlotState }>,
	Target: Vide.Source<number?>,
	Ticking: boolean,
	Setup: (self: Public) -> (),
	CurrentTarget: (self: Public) -> number?,
	Bump: (self: Public) -> (),
	SendInterval: (self: Public) -> number,
	HasOutgoing: (self: Public) -> boolean,
	MyUnit: (self: Public, unitId: number) -> SkillUnit?,
	IsTargetActive: (self: Public, uid: number) -> boolean,
	IsOnStage: (self: Public, unit: SkillUnit, now: number) -> boolean,
	CanRequestSkill: (self: Public, unit: SkillUnit, now: number) -> boolean,
	SendMove: (self: Public, command: MoveCommand) -> (),
	SendNextSkill: (self: Public) -> boolean,
	SendOne: (self: Public) -> boolean,
	Flush: (self: Public) -> (),
	ClearSkillRequests: (self: Public) -> (),
	PickEnemy: (self: Public, screenPosition: Vector2) -> number?,
	Attack: (self: Public, uid: number) -> (),
	Recall: (self: Public) -> (),
	SetAutoSkill: (self: Public, enabled: boolean) -> (),
	ToggleAutoSkill: (self: Public) -> (),
	UseSkill: (self: Public, unitId: number) -> boolean,
	UseSkillSlot: (self: Public, slot: number) -> boolean,
	UseNextSkill: (self: Public) -> boolean,
	SlotState: (self: Public, unitId: number) -> SlotState?,
	IsRequestPending: (self: Public, unit: SkillUnit, clock: number) -> boolean,
	BuildSlot: (self: Public, unit: SkillUnit, now: number, clock: number, auto: boolean) -> SlotState,
	NeedsClock: (self: Public, units: { SkillUnit }, now: number) -> boolean,
	ResolveAuto: (self: Public, profileAuto: boolean) -> boolean,
	ConfirmAuto: (self: Public, profileAuto: boolean) -> (),
	RebuildSlots: (self: Public) -> (),
	OnWorldTap: (self: Public, screenPosition: Vector2) -> (),
	WatchTargetDeath: (self: Public) -> (),
	WatchProfileAuto: (self: Public) -> (),
	WatchSlots: (self: Public) -> (),
	IsGameplay: (self: Public) -> boolean,
	BindCommands: (self: Public) -> (),
	Tick: (self: Public) -> (),
}

return {}
