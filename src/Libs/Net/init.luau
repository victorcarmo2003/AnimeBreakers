local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lync = require(ReplicatedStorage.Packages.Lync)

const ContentId = Lync.str(1, 24)

return Lync.define("game", {
	Ready = Lync.packet(Lync.empty()),

	Profile = Lync.packet(Lync.struct({
		Coins = Lync.vlq(),
		AutoSkill = Lync.bool(),
	})),

	Inventory = Lync.packet(Lync.struct({
		Pets = Lync.array(
			Lync.struct({
				Uid = Lync.vlq(),
				Pet = ContentId,
				Level = Lync.int(1, 1000),
				Stars = Lync.int(1, 10),
			}),
			0,
			500
		),
		Equipped = Lync.array(Lync.vlq(), 0, 8),
	})),

	Reward = Lync.packet(Lync.struct({
		Enemy = Lync.vlq(),
		Coins = Lync.vlq(),
	})),

	Enemies = Lync.replicate(Lync.struct({
		Enemy = ContentId,
		Position = Lync.vec3(),
		Yaw = Lync.int(0, 359),
		Health = Lync.vlq(),
		MaxHealth = Lync.vlq(),
		Alive = Lync.bool(),
		Life = Lync.vlq(),
	})),

	Pets = Lync.replicate(Lync.struct({
		Owner = Lync.vli(),
		Slot = Lync.int(1, 8),
		Pet = ContentId,
		Target = Lync.optional(Lync.vlq()),
		Ring = Lync.int(0, 63),
		SkillReadyAt = Lync.f64(),
	})),

	Attack = Lync.packet(Lync.struct({
		Enemy = Lync.vlq(),
	})),

	Recall = Lync.packet(Lync.empty()),

	UseSkill = Lync.packet(Lync.struct({
		Unit = Lync.vlq(),
	})),

	SetAutoSkill = Lync.packet(Lync.struct({
		Enabled = Lync.bool(),
	})),

	Beat = Lync.packet(Lync.struct({
		Unit = Lync.vlq(),
		Move = Lync.enum({ "Enter", "Combat1", "Combat2", "Skill", "BackOff" }),
	})):timestamped(),

	Hits = Lync.packet(Lync.array(
		Lync.struct({
			Enemy = Lync.vlq(),
			Unit = Lync.vlq(),
			Amount = Lync.vlq(),
			Kind = Lync.enum({ "Basic", "Skill" }),
		}),
		1,
		255
	)),
})
