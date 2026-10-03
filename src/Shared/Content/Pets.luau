local Types = require(script.Parent.Types)

const Pets: { [string]: Types.PetDef } = {
	["PET-001"] = {
		Id = "PET-001",
		Name = "Placeholder Vermelho",
		Character = "DummyR6Red",
		Rarity = "Common",
		Damage = 10,
		AttackInterval = 1,
		Ability = "ABL-001",
	},
	["PET-002"] = {
		Id = "PET-002",
		Name = "Placeholder Azul",
		Character = "DummyR6Blue",
		Rarity = "Common",
		Damage = 10,
		AttackInterval = 1,
		Ability = "ABL-001",
	},
	["PET-003"] = {
		Id = "PET-003",
		Name = "Placeholder Verde",
		Character = "DummyR6Green",
		Rarity = "Common",
		Damage = 10,
		AttackInterval = 1,
		Ability = "ABL-001",
	},
}

return Pets
