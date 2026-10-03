local Types = require(script.Parent.Types)

const Tuning: Types.TuningDef = {
	StarterPets = { "PET-001", "PET-002", "PET-003" },
	PersistProfiles = false,
	CombatTickRate = 20,
	CommandRange = 80,
	LeashRange = 120,
	ArriveSeconds = 0.4,
	DefaultAutoSkill = true,
	SkillGap = 0.3,
	SkillRequestTimeout = 1,
	AssistDistance = 6,
	CommandMinInterval = 0.1,
	TeleportThreshold = 25,
	PetFollowSpeed = 24,
	DefaultTurn = { "Enter", "Combat1", "Combat2", "BackOff" },
	DefaultTeleportOut = "BlinkOut",
	DefaultTeleportIn = "BlinkIn",
	DamageNumbers = { PerEnemy = 10, Total = 40, Rise = 2, Lifetime = 0.8 },
	Lod = { OtherPetsHide = 150, EnemyFreeze = 200, EnemyHide = 300 },
	MaxSkillEffects = 6,
}

return Tuning
