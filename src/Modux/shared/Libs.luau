--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.shared.Libs.Charm)
local FSM = require(ReplicatedStorage.shared.Libs.FSM)
local Net = require(ReplicatedStorage.shared.Libs.Net)
local Promise = require(ReplicatedStorage.shared.Libs.Promise)
local Signal = require(ReplicatedStorage.shared.Libs.Signal)

export type Api = {
	Charm: typeof(Charm),
	FSM: typeof(FSM),
	Net: typeof(Net),
	Promise: typeof(Promise),
	Signal: typeof(Signal),
}

return {
	Charm = Charm,
	FSM = FSM,
	Net = Net,
	Promise = Promise,
	Signal = Signal,
} :: Api
