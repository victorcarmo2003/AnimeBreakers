--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)

export type Ledger = { [Player]: number }
export type PayoutEntry = {
	Player: Player,
	Damage: number,
	Present: boolean,
	Share: number,
}

export type Public = {
	Payouts: { [number]: { PayoutEntry } },
	Setup: (self: Public) -> (),
	LastPayout: (self: Public, uid: number) -> { PayoutEntry }?,
	Split: (self: Public, ledger: Ledger, pool: number) -> { PayoutEntry },
	Credit: (self: Public, player: Player, coins: number) -> boolean,
	SendReward: (self: Public, player: Player, uid: number, coins: number) -> (),
	Pay: (self: Public, uid: number, ledger: Ledger, def: Content.EnemyDef) -> (),
}

return {}
