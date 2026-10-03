--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local InputController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.InputController)
local NetController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.NetController)
local ProfileController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.ProfileController)
local RoundController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.RoundController)
local VitalController = require(StarterPlayer.StarterPlayerScripts.client.ModuxTypes.VitalController)

export type AllControllers = {
	InputController: InputController.Public,
	NetController: NetController.Public,
	ProfileController: ProfileController.Public,
	RoundController: RoundController.Public,
	VitalController: VitalController.Public,
}

export type AllComponents = {}

export type ComponentAccess = {}

return {}
