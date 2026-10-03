local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)

export type OwnedPet = {
	Pet: string,
	Level: number,
	Stars: number,
	Xp: number,
	Gear: { [string]: number },
}

const Template = {
	Version = 1,
	Coins = 0,
	AutoSkill = Content.Tuning.DefaultAutoSkill,
	Pets = {} :: { [string]: OwnedPet },
	Equipped = {} :: { string },
	NextPetUid = 1,
	EquipSlots = 3,
}

return Template
