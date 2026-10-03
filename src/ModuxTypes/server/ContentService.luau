--!strict

type Issues = { string }

export type Public = {
	Validate: (self: Public) -> Issues,
}

return {}
