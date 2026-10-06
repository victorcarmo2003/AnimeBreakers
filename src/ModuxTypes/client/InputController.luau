--!strict

export type Context = "Gameplay" | "Menu"
export type Binding = {
	Name: string,
	Key: InputKey,
	Keys: { InputKey }?,
	TouchButton: boolean?,
	Priority: number?,
	Position: UDim2?,
}
export type Handle = {
	OnPress: (callback: () -> ()) -> Handle,
	OnRelease: (callback: () -> ()) -> Handle,
	Unbind: () -> (),
	_press: { () -> () },
	_release: { () -> () },
}
export type WorldTapCallback = (screenPosition: Vector2) -> ()
export type InputKey = Enum.KeyCode | Enum.UserInputType

export type Public = {
	ClickOrigin: Vector2?,
	Context: Context,
	Handles: { [string]: Handle },
	Listeners: { (Context) -> () },
	WorldTapListeners: { WorldTapCallback },
	Setup: (self: Public) -> (),
	Dispatch: (self: Public, name: string, state: Enum.UserInputState) -> Enum.ContextActionResult,
	Bind: (self: Public, binding: Binding) -> Handle,
	Unbind: (self: Public, name: string) -> (),
	OnContextChange: (self: Public, callback: (Context) -> ()) -> (),
	SetContext: (self: Public, context: Context) -> (),
	OnWorldTap: (self: Public, callback: WorldTapCallback) -> () -> (),
	FireWorldTap: (self: Public, screenPosition: Vector2) -> (),
	ScreenCenter: (self: Public) -> Vector2,
	OnClickBegan: (self: Public, input: InputObject, gameProcessed: boolean) -> (),
	OnClickMoved: (self: Public, input: InputObject) -> (),
	OnClickEnded: (self: Public, input: InputObject) -> (),
	ListenWorldTap: (self: Public) -> (),
}

return {}
