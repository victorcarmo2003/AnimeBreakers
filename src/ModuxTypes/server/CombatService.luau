--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Content = require(ReplicatedStorage.shared.Content)
local PetTypes = require(ServerScriptService.server.ModuxTypes.PetService)
local Engagement = require(ServerScriptService.server.Combat.CombatService.Engagement)

export type PetUnit = PetTypes.PetUnit
export type Engagement = Engagement.Engagement
export type Move = Content.Move
export type Hit = {
	Enemy: number,
	Unit: number,
	Amount: number,
	Kind: HitKind,
}
export type HitKind = "Basic" | "Skill"

export type Public = {
	Engagements: { [Player]: Engagement },
	LastCommandAt: { [Player]: number },
	OutgoingHits: { [Player]: { Hit } },
	Random: Random,
	Rings: { [number]: { [number]: number } },
	Setup: (self: Public) -> (),
	Engagement: (self: Public, player: Player) -> Engagement?,
	PassRateLimit: (self: Public, player: Player) -> boolean,
	ClaimRing: (self: Public, enemyUid: number, unitId: number) -> number,
	ReleaseRing: (self: Public, enemyUid: number?, index: number, unitId: number) -> (),
	AssignUnit: (self: Public, engagement: Engagement, unit: PetUnit, at: number) -> (),
	ReleaseUnit: (self: Public, unit: PetUnit) -> (),
	Engage: (self: Public, player: Player, enemyUid: number) -> boolean,
	Disengage: (self: Public, player: Player) -> (),
	CloseEnemy: (self: Public, enemyUid: number) -> (),
	HandleAttack: (self: Public, player: Player, data: unknown) -> boolean,
	HandleRecall: (self: Public, player: Player) -> boolean,
	IsAutoSkill: (self: Public, player: Player) -> boolean,
	HandleUseSkill: (self: Public, player: Player, data: unknown) -> boolean,
	HandleSetAutoSkill: (self: Public, player: Player, data: unknown) -> boolean,
	IsCurrent: (self: Public, engagement: Engagement) -> boolean,
	SendBeat: (self: Public, player: Player, unitId: number, move: Move) -> (),
	BeatEmitter: (self: Public, player: Player) -> (unitId: number, move: Move) -> (),
	EnqueueAutoSkills: (self: Public, engagement: Engagement, at: number) -> (),
	Cast: (self: Public, engagement: Engagement, unit: PetUnit, at: number) -> (),
	CastNext: (self: Public, engagement: Engagement, at: number) -> (),
	ApplyPendingHits: (self: Public, engagement: Engagement, at: number) -> (),
	Choreograph: (self: Public, engagement: Engagement, at: number) -> (),
	Advance: (self: Public, engagement: Engagement, at: number) -> (),
	QueueHit: (self: Public, player: Player, hit: Hit) -> (),
	StrikeBasic: (self: Public, engagement: Engagement, at: number) -> (),
	FlushHits: (self: Public) -> (),
	Step: (self: Public) -> (),
	CheckLeash: (self: Public) -> (),
	OnUnitAdded: (self: Public, unit: PetUnit) -> (),
	OnUnitRemoved: (self: Public, unit: PetUnit) -> (),
	Forget: (self: Public, player: Player) -> (),
}

return {}
