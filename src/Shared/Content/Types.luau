export type Move = "Enter" | "Combat1" | "Combat2" | "Skill" | "BackOff"

export type TurnMove = "Enter" | "Combat1" | "Combat2" | "BackOff"

export type RigKind = "R6" | "Custom"

export type AnimationSetKind = "Pet" | "Enemy"

export type PetTrackKey = "Idle" | "Run" | "Assist" | "Enter" | "Combat1" | "Combat2" | "Skill" | "BackOff"

export type EnemyTrackKey = "Idle" | "Defend" | "Hit" | "HitHeavy" | "Death" | "Spawn"

export type TrackKey = PetTrackKey | EnemyTrackKey

export type AbilityKind = "Strike"

export type EffectAnchor = "Root" | "Overhead" | "Ground"

export type RarityDef = {
	Id: string,
	Order: number,
	Name: string,
	Color: Color3,
}

export type CharacterEffects = {
	TeleportOut: string?,
	TeleportIn: string?,
	Assist: string?,
}

export type CharacterDef = {
	Id: string,
	Model: string,
	Rig: RigKind,
	AnimationSet: string,
	Scale: number,
	Radius: number,
	Height: number,
	Reach: number,
	PickSize: Vector3?,
	Effects: CharacterEffects,
}

export type AnimationDef = {
	Id: string,
	Duration: number,
	Speed: number?,
	Looped: boolean?,
	Fade: number?,
	Priority: Enum.AnimationPriority?,
	Placeholder: boolean?,
}

export type Tracks = { [TrackKey]: AnimationDef }

export type AnimationSet = {
	Id: string,
	Kind: AnimationSetKind,
	Inherits: string?,
	Tracks: Tracks,
	Turn: { TurnMove }?,
	Reactions: { [Move]: TrackKey }?,
}

export type AbilityDef = {
	Id: string,
	Name: string,
	Kind: AbilityKind,
	Power: number,
	Hits: number?,
	HitSpacing: number?,
	HitDelay: number,
	Cooldown: number,
	Effect: string?,
	CastEffect: string?,
}

export type EffectDef = {
	Id: string,
	Asset: string,
	Lite: string?,
	Lifetime: number,
	Anchor: EffectAnchor,
}

export type PetDef = {
	Id: string,
	Name: string,
	Character: string,
	Rarity: string,
	Damage: number,
	AttackInterval: number,
	Ability: string,
	SellValue: number?,
}

export type RewardDef = {
	Coins: number,
	PetXp: number?,
	Drops: string?,
}

export type EnemyDef = {
	Id: string,
	Name: string,
	Character: string,
	Health: number,
	Rewards: RewardDef,
	RespawnSeconds: number,
	Boss: boolean?,
}

export type EggPoolEntry = {
	Pet: string,
	Weight: number,
}

export type EggDef = {
	Id: string,
	Name: string,
	Price: number,
	Island: string?,
	Pool: { EggPoolEntry },
}

export type DamageNumbersTuning = {
	PerEnemy: number,
	Total: number,
	Rise: number,
	Lifetime: number,
}

export type LodTuning = {
	OtherPetsHide: number,
	EnemyFreeze: number,
	EnemyHide: number,
}

export type TuningDef = {
	StarterPets: { string },
	PersistProfiles: boolean,
	CombatTickRate: number,
	CommandRange: number,
	LeashRange: number,
	ArriveSeconds: number,
	DefaultAutoSkill: boolean,
	SkillGap: number,
	SkillRequestTimeout: number,
	AssistDistance: number,
	CommandMinInterval: number,
	TeleportThreshold: number,
	PetFollowSpeed: number,
	DefaultTurn: { TurnMove },
	DefaultTeleportOut: string,
	DefaultTeleportIn: string,
	DamageNumbers: DamageNumbersTuning,
	Lod: LodTuning,
	MaxSkillEffects: number,
}

export type InterfaceDef = {
	Images: { [string]: string },
}

return {}
