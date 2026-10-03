local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)

export type InventoryEntry = {
	Uid: number,
	Pet: string,
	Level: number,
	Stars: number,
}

export type Reward = {
	Enemy: number,
	Coins: number,
}

const ProfileController = Modux.Controller("ProfileController", { Priority = 800 })

function ProfileController:Setup()
	self.Coins = Vide.source(0) :: Vide.Source<number>
	self.AutoSkill = Vide.source(Content.Tuning.DefaultAutoSkill) :: Vide.Source<boolean>
	self.Pets = Vide.source({}) :: Vide.Source<{ InventoryEntry }>
	self.Equipped = Vide.source({}) :: Vide.Source<{ number }>
	self.Ready = Vide.source(false) :: Vide.Source<boolean>
	self.LastReward = Vide.source(nil) :: Vide.Source<Reward?>
end

ProfileController:OnInit(function(self)
	self:Setup()

	self.Libs.Net.Profile:onClient(function(data)
		self.Coins(data.Coins)
		self.AutoSkill(data.AutoSkill)
		self.Ready(true)
	end)

	self.Libs.Net.Inventory:onClient(function(data)
		const pets: { InventoryEntry } = {}
		for _, entry in data.Pets do
			table.insert(pets, {
				Uid = entry.Uid,
				Pet = entry.Pet,
				Level = entry.Level,
				Stars = entry.Stars,
			})
		end
		self.Pets(pets)
		self.Equipped(table.clone(data.Equipped))
	end)

	self.Libs.Net.Reward:onClient(function(data)
		self.LastReward({ Enemy = data.Enemy, Coins = data.Coins })
	end)
end)

return ProfileController
