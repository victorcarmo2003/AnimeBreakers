--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ContentService = require(ServerScriptService.server.ModuxTypes.ContentService)
local NetService = require(ServerScriptService.server.ModuxTypes.NetService)
local PlayerService = require(ServerScriptService.server.ModuxTypes.PlayerService)
local ProfileService = require(ServerScriptService.server.ModuxTypes.ProfileService)

export type AllServices = {
	ContentService: ContentService.Public,
	NetService: NetService.Public,
	PlayerService: PlayerService.Public,
	ProfileService: ProfileService.Public,
}

export type AllComponents = {}

export type ComponentAccess = {}

return {}
