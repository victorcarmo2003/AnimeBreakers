local Types = require(script.Parent.Types)

const Enemies: { [string]: Types.EnemyDef } = {
	["ENM-001"] = {
		Id = "ENM-001",
		Name = "Boneco de Treino",
		Character = "DummyR6Grey",
		Health = 1000,
		Rewards = { Coins = 100 },
		RespawnSeconds = 5,
		Boss = false,
	},
	["ENM-002"] = {
		Id = "ENM-002",
		Name = "Chefe de Treino",
		Character = "DummyR6Grey",
		Health = 10000,
		Rewards = { Coins = 1000 },
		RespawnSeconds = 5,
		Boss = true,
	},
}

return Enemies
