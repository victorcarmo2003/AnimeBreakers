--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Atomic = require(ReplicatedStorage.shared.Types.Atomic)
local SignalLib = require(ReplicatedStorage.shared.Libs.Signal)
local Struct = require(ReplicatedStorage.shared.Types.Struct)
local Template = require(ServerScriptService.server.Profile.ProfileService.Template)

export type Data = typeof(Template)
export type Profile = Atomic.Table<Data>
export type ProfilePayload = {
	Coins: number,
	AutoSkill: boolean,
}
export type InventoryPayload = {
	Pets: { InventoryEntry },
	Equipped: { number },
}
export type InventoryEntry = {
	Uid: number,
	Pet: string,
	Level: number,
	Stars: number,
}

export type Public = {
	Disposers: { [Player]: { () -> () } },
	Loaded: SignalLib.Signal<Player, Profile>,
	Profiles: { [Player]: Profile },
	Sessions: { [Player]: any },
	Store: any,
	Setup: (self: Public) -> (),
	Get: (self: Public, player: Player) -> Profile?,
	Update: (self: Public, player: Player, patch: Struct.Partial<Data>) -> (),
	Mutate: (self: Public, player: Player, field: string, mutate: (value: any) -> ()) -> (),
	ProfilePayload: (self: Public, profile: Profile) -> ProfilePayload,
	InventoryPayload: (self: Public, profile: Profile) -> InventoryPayload,
	CanSend: (self: Public, player: Player) -> boolean,
	SendProfile: (self: Public, player: Player, payload: ProfilePayload) -> (),
	SendInventory: (self: Public, player: Player, payload: InventoryPayload) -> (),
	Replicate: (self: Public, player: Player) -> (),
	Bind: (self: Public, player: Player, session: any) -> Profile,
	Migrate: (self: Public, data: { [string]: any }) -> boolean,
	Load: (self: Public, player: Player) -> (),
	Forget: (self: Public, player: Player) -> (),
	Unload: (self: Public, player: Player) -> (),
}

return {}
