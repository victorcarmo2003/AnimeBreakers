--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)

export type Status = "Waiting" | "Playing" | "Ending"

const RoundController = Modux.Controller("RoundController", { Priority = 800 })

function RoundController:Setup()
	self.Status = Vide.source("Waiting") :: Vide.Source<Status>
	self.Seconds = Vide.source(0) :: Vide.Source<number>
end

RoundController:OnInit(function(self)
	self:Setup()

	self.Libs.Net.Round:onClient(function(payload)
		self.Status(payload.Status)
		self.Seconds(payload.Seconds)
	end)
end)

return RoundController
