local Types = require(script.Parent.Types)

const Effects: { [string]: Types.EffectDef } = {
	BlinkOut = { Id = "BlinkOut", Asset = "BlinkOut", Lite = "BlinkOutLite", Lifetime = 0.6, Anchor = "Root" },
	BlinkIn = { Id = "BlinkIn", Asset = "BlinkIn", Lite = "BlinkInLite", Lifetime = 0.6, Anchor = "Root" },
	SkillBurst = { Id = "SkillBurst", Asset = "SkillBurst", Lite = "SkillBurstLite", Lifetime = 0.8, Anchor = "Root" },
	SkillCharge = { Id = "SkillCharge", Asset = "SkillCharge", Lite = "SkillChargeLite", Lifetime = 0.6, Anchor = "Root" },
}

return Effects
