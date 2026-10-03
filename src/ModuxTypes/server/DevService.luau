--!strict

export type Handler = (...any) -> ...any

export type Public = {
	Enabled: boolean,
	Endpoint: BindableFunction?,
	Handlers: { [string]: Handler },
	Setup: (self: Public) -> (),
	Register: (self: Public, name: string, handler: Handler) -> (),
	Invoke: (self: Public, name: unknown, arguments: { n: number, [number]: any }) -> ...any,
}

return {}
