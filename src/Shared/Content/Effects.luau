local Types = require(script.Parent.Types)

const Effects: { [string]: Types.EffectDef } = {
	BlinkOut = { Id = "BlinkOut", Asset = "BlinkOut", Lifetime = 0.6, Anchor = "Root" },
	BlinkIn = { Id = "BlinkIn", Asset = "BlinkIn", Lifetime = 0.6, Anchor = "Root" },
	SkillBurst = { Id = "SkillBurst", Asset = "SkillBurst", Lifetime = 0.8, Anchor = "Root" },
	SkillCharge = { Id = "SkillCharge", Asset = "SkillCharge", Lifetime = 0.6, Anchor = "Root" },
}

return Effects
