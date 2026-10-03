local Types = require(script.Parent.Types)

const Rarities: { [string]: Types.RarityDef } = {
	Common = { Id = "Common", Order = 1, Name = "Comum", Color = Color3.fromRGB(180, 180, 180) },
	Uncommon = { Id = "Uncommon", Order = 2, Name = "Incomum", Color = Color3.fromRGB(90, 200, 90) },
	Rare = { Id = "Rare", Order = 3, Name = "Raro", Color = Color3.fromRGB(70, 140, 235) },
	Legendary = { Id = "Legendary", Order = 4, Name = "Lendário", Color = Color3.fromRGB(245, 170, 40) },
	Epic = { Id = "Epic", Order = 5, Name = "Épico", Color = Color3.fromRGB(165, 85, 225) },
	Mythic = { Id = "Mythic", Order = 6, Name = "Mítico", Color = Color3.fromRGB(235, 60, 80) },
}

return Rarities
