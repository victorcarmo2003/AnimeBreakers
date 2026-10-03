--!strict

export type LedgerReport = {
	Entries: { LedgerEntry },
	Total: number,
}
export type LedgerEntry = {
	Name: string,
	Damage: number,
	Present: boolean,
}

export type Public = {
	Ledger: (self: Public, uid: unknown) -> LedgerReport,
}

return {}
