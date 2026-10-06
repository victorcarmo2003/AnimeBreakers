--!strict

export type UnitReport = {
	Id: number,
	Slot: number,
	PetId: string,
	Target: number?,
	Ring: number,
	ArriveAt: number,
	NextHitAt: number,
	SkillReadyAt: number,
}
export type EngagementReport = {
	EnemyUid: number?,
	Phase: string,
	Featured: number?,
}

export type Public = {
	Units: (self: Public, playerName: unknown) -> { UnitReport },
	Engagement: (self: Public, playerName: unknown) -> EngagementReport,
	FireAs: (self: Public, playerName: unknown, packet: unknown, payload: unknown) -> boolean,
}

return {}
