local Types = require(script.Parent.Types)

const Abilities: { [string]: Types.AbilityDef } = {
	["ABL-001"] = {
		Id = "ABL-001",
		Name = "Golpe Carregado",
		Kind = "Strike",
		Power = 5,
		Hits = 1,
		HitSpacing = 0.1,
		HitDelay = 0.4,
		Cooldown = 8,
		Effect = "SkillBurst",
		CastEffect = "SkillCharge",
	},
}

return Abilities
