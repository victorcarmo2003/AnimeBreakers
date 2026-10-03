--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)

const ProfileController = Modux.Controller("ProfileController", { Priority = 800 })

function ProfileController:Setup()
	self.Coins = Vide.source(0) :: Vide.Source<number>
	self.Level = Vide.source(1) :: Vide.Source<number>
	self.Playtime = Vide.source(0) :: Vide.Source<number>
	self.Ready = Vide.source(false) :: Vide.Source<boolean>
end

ProfileController:OnInit(function(self)
	self:Setup()

	self.Libs.Net.Profile:onClient(function(data)
		self.Coins(data.Coins)
		self.Level(data.Level)
		self.Playtime(data.Playtime)
		self.Ready(true)
	end)
end)

return ProfileController
