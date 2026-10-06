--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)
local SignalLib = require(ReplicatedStorage.shared.Libs.Signal)

export type OwnedPet = {
	Pet: string,
	Level: number,
	Stars: number,
	Xp: number,
	Gear: { [string]: number },
}
export type PetUnit = {
	Id: number,
	Owner: Player,
	Slot: number,
	OwnedUid: number,
	PetId: string,
	Def: Content.PetDef,
	Damage: number,
	AttackInterval: number,
	AbilityId: string,
	Cooldown: number,
	SkillReadyAt: number,
	Target: number?,
	Ring: number,
	ArriveAt: number,
	NextHitAt: number,
}

export type Public = {
	ByOwner: { [Player]: { PetUnit } },
	LastUnitId: number,
	Registry: { [number]: PetUnit },
	UnitAdded: SignalLib.Signal<PetUnit>,
	UnitRemoved: SignalLib.Signal<PetUnit>,
	Setup: (self: Public) -> (),
	NewOwnedPet: (self: Public, petId: string) -> OwnedPet,
	NextUnitId: (self: Public) -> number,
	CanPublish: (self: Public) -> boolean,
	GrantStarterPets: (self: Public, player: Player) -> (),
	CreateUnit: (self: Public, player: Player, slot: number, ownedUid: number, owned: OwnedPet) -> PetUnit?,
	Publish: (self: Public, unit: PetUnit) -> (),
	BuildUnits: (self: Public, player: Player) -> (),
	RemoveUnits: (self: Public, player: Player) -> (),
	Units: (self: Public, player: Player) -> { PetUnit },
	Unit: (self: Public, id: number) -> PetUnit?,
	IsLive: (self: Public, unit: PetUnit) -> boolean,
	SetTarget: (self: Public, unit: PetUnit, enemyUid: number?, ring: number) -> (),
	SetSkillReady: (self: Public, unit: PetUnit, at: number) -> (),
}

return {}
