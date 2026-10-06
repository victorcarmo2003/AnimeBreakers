--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local EnemyController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.EnemyController)
local InputController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.InputController)
local NetController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.NetController)
local ProfileController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.ProfileController)

export type AllControllers = {
	EnemyController: EnemyController.Public,
	InputController: InputController.Public,
	NetController: NetController.Public,
	ProfileController: ProfileController.Public,
}

export type AllComponents = {}

export type ComponentAccess = {}

return {}
