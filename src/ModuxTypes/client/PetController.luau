--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)
local RigAnimator = require(ReplicatedStorage.shared.Rig.RigAnimator)

export type PetRecord = {
	Owner: number,
	Slot: number,
	Pet: string,
	Target: number?,
	Ring: number,
	SkillReadyAt: number,
}
export type PetUnitState = {
	Id: number,
	Owner: number,
	Slot: number,
	Pet: string,
	Target: number?,
	Ring: number,
	SkillReadyAt: number,
	ArriveAt: number,
}
export type Stage = {
	Owns: (self: Stage, unitId: number) -> boolean,
}
export type PetMode = "Follow" | "Assist" | "Frozen"
export type PetMotion = "Idle" | "Run" | "Assist"
export type PetActor = {
	Id: number,
	PetId: string,
	Character: Content.CharacterDef,
	Model: Model,
	Root: BasePart,
	Animator: RigAnimator.RigAnimator,
	RootHeight: number,
	Current: CFrame,
	Placed: boolean,
	Mode: PetMode?,
	Motion: PetMotion?,
	GroundY: number?,
	GroundSampledAt: Vector3?,
	GroundTimer: number,
	HeldByStage: boolean,
}

export type Public = {
	Actors: { [number]: PetActor },
	Folder: Folder?,
	GroundFilterStale: boolean,
	GroundParams: RaycastParams,
	LastStepAt: number,
	MoveCFrames: { CFrame },
	MoveParts: { BasePart },
	MyUnits: Vide.Source<{ PetUnitState }>,
	Stage: Stage,
	Units: { [number]: PetUnitState },
	Setup: (self: Public) -> (),
	PetsFolder: (self: Public) -> Folder,
	UseStage: (self: Public, stage: Stage?) -> (),
	IsMine: (self: Public, unit: PetUnitState) -> boolean,
	Unit: (self: Public, unitId: number) -> PetUnitState?,
	Rig: (self: Public, unitId: number) -> RigAnimator.RigAnimator?,
	Model: (self: Public, unitId: number) -> Model?,
	PublishMyUnits: (self: Public) -> (),
	RingCounts: (self: Public) -> { [number]: number },
	RingGoal: (self: Public, unit: PetUnitState, counts: { [number]: number }) -> CFrame?,
	FollowGoal: (self: Public, unit: PetUnitState) -> CFrame?,
	Goal: (self: Public, unit: PetUnitState, counts: { [number]: number }) -> (CFrame?, PetMode),
	RingCFrame: (self: Public, unitId: number) -> CFrame?,
	RefreshGroundFilter: (self: Public) -> (),
	SampleGround: (self: Public, position: Vector3) -> number?,
	GroundedGoal: (self: Public, actor: PetActor, goal: CFrame, dt: number) -> CFrame,
	SetMotion: (self: Public, actor: PetActor, motion: PetMotion) -> (),
	Teleport: (self: Public, actor: PetActor, unit: PetUnitState, goal: CFrame) -> (),
	StepActor: (self: Public, actor: PetActor, unit: PetUnitState, counts: { [number]: number }, dt: number) -> boolean,
	Step: (self: Public) -> (),
	CreateActor: (self: Public, unit: PetUnitState) -> PetActor?,
	DestroyActor: (self: Public, unitId: number) -> (),
	StateFrom: (self: Public, unitId: number, record: PetRecord, previous: PetUnitState?) -> PetUnitState,
	OnAdded: (self: Public, unitId: number, record: PetRecord) -> (),
	OnChanged: (self: Public, unitId: number, record: PetRecord) -> (),
	OnRemoved: (self: Public, unitId: number) -> (),
	PreloadAssets: (self: Public) -> (),
}

return {}
