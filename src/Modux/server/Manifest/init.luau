--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local NetService = require(ServerScriptService.server.ModuxTypes.NetService)
local PlayerService = require(ServerScriptService.server.ModuxTypes.PlayerService)
local ProfileService = require(ServerScriptService.server.ModuxTypes.ProfileService)
local RoundService = require(ServerScriptService.server.ModuxTypes.RoundService)
local Vital = require(ServerScriptService.server.ModuxTypes.Vital)
local VitalService = require(ServerScriptService.server.ModuxTypes.VitalService)

export type AllServices = {
	NetService: NetService.Public,
	PlayerService: PlayerService.Public,
	ProfileService: ProfileService.Public,
	RoundService: RoundService.Public,
	VitalService: VitalService.Public,
}

export type AllComponents = {
	Vital: Vital.Public,
}

export type ComponentAccess = {
	Vital: {
		Get: (self: any, instance: Instance) -> Vital.Public?,
		Create: (self: any, instance: Instance) -> Vital.Public,
		All: (self: any) -> { Vital.Public },
		Destroy: (self: any, instance: Instance) -> (),
	},
}

return {}
