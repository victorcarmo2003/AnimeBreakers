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
}

return Enemies
