--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local CommandController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.CommandController)
local EffectController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.EffectController)
local EnemyController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.EnemyController)
local InputController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.InputController)
local NetController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.NetController)
local PetController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.PetController)
local ProfileController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.ProfileController)

export type AllControllers = {
	CommandController: CommandController.Public,
	EffectController: EffectController.Public,
	EnemyController: EnemyController.Public,
	InputController: InputController.Public,
	NetController: NetController.Public,
	PetController: PetController.Public,
	ProfileController: ProfileController.Public,
}

export type AllComponents = {}

export type ComponentAccess = {}

return {}
