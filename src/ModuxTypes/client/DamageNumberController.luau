--!strict

export type HitKind = "Basic" | "Skill"
export type Hit = {
	Enemy: number,
	Unit: number,
	Amount: number,
	Kind: HitKind,
}
type Entry = {
	Billboard: BillboardGui,
	Label: TextLabel,
	Scale: UIScale,
	Rise: Tween,
	Fade: Tween,
	Pop: Tween,
	Enemy: number,
	InUse: boolean,
}

export type Public = {
	Active: { Entry },
	CountByEnemy: { [number]: number },
	Folder: Instance?,
	Free: { Entry },
	Rng: Random,
	Setup: (self: Public) -> (),
	NumbersFolder: (self: Public) -> Instance,
	Release: (self: Public, entry: Entry) -> (),
	OldestOf: (self: Public, enemy: number) -> Entry?,
	Acquire: (self: Public, enemy: number) -> Entry,
	Show: (self: Public, enemy: number, amount: number, kind: HitKind) -> (),
	OnHits: (self: Public, hits: { Hit }) -> (),
}

return {}
