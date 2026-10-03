--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local DevService = require(ServerScriptService.server.ModuxTypes.DevService)
local EnemyDevService = require(ServerScriptService.server.ModuxTypes.EnemyDevService)
local EnemyService = require(ServerScriptService.server.ModuxTypes.EnemyService)
local EnemySpawn = require(ServerScriptService.server.ModuxTypes.EnemySpawn)
local NetService = require(ServerScriptService.server.ModuxTypes.NetService)
local PlayerService = require(ServerScriptService.server.ModuxTypes.PlayerService)
local ProfileService = require(ServerScriptService.server.ModuxTypes.ProfileService)

export type AllServices = {
	DevService: DevService.Public,
	EnemyDevService: EnemyDevService.Public,
	EnemyService: EnemyService.Public,
	NetService: NetService.Public,
	PlayerService: PlayerService.Public,
	ProfileService: ProfileService.Public,
}

export type AllComponents = {
	EnemySpawn: EnemySpawn.Public,
}

export type ComponentAccess = {
	EnemySpawn: {
		Get: (self: any, instance: Instance) -> EnemySpawn.Public?,
		Create: (self: any, instance: Instance) -> EnemySpawn.Public,
		All: (self: any) -> { EnemySpawn.Public },
		Destroy: (self: any, instance: Instance) -> (),
	},
}

return {}
