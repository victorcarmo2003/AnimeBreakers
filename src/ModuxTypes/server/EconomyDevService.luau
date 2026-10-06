--!strict

export type PayoutReport = {
	Name: string,
	Damage: number,
	Present: boolean,
	Share: number,
}

export type Public = {
	Coins: (self: Public, playerName: unknown) -> number,
	SetCoins: (self: Public, playerName: unknown, amount: unknown) -> number,
	LastPayout: (self: Public, uid: unknown) -> { PayoutReport },
}

return {}
