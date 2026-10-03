--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)

type Snapshot = { Health: number, Armor: number, Stamina: number }

const VitalController = Modux.Controller("VitalController", { Priority = 800 })

function VitalController:Setup()
	self.Health = Vide.source(100) :: Vide.Source<number>
	self.Armor = Vide.source(0) :: Vide.Source<number>
	self.Stamina = Vide.source(100) :: Vide.Source<number>
end

function VitalController:Apply(snapshot: Snapshot)
	self.Health(snapshot.Health)
	self.Armor(snapshot.Armor)
	self.Stamina(snapshot.Stamina)
end

function VitalController:Of(player: Player): Snapshot?
	return self.Libs.Net.Vitals:get(player.UserId)
end

VitalController:OnInit(function(self)
	self:Setup()

	const userId = Players.LocalPlayer.UserId

	self.Libs.Net.Vitals:onAdded(function(id, record)
		if id == userId then
			self:Apply(record)
		end
	end)

	self.Libs.Net.Vitals:onChanged(function(id, record)
		if id == userId then
			self:Apply(record)
		end
	end)
end)

return VitalController
