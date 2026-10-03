local Types = require(script.Parent.Types)

const PLACEHOLDER_ID = "rbxassetid://0"

const AnimationSets: { [string]: Types.AnimationSet } = {
	PetR6 = {
		Id = "PetR6",
		Kind = "Pet",
		Turn = { "Enter", "Combat1", "Combat2", "BackOff" },
		Tracks = {
			Idle = { Id = PLACEHOLDER_ID, Duration = 2, Looped = true, Placeholder = true },
			Run = { Id = PLACEHOLDER_ID, Duration = 0.8, Looped = true, Placeholder = true },
			Assist = { Id = PLACEHOLDER_ID, Duration = 1.5, Looped = true, Placeholder = true },
			Enter = { Id = PLACEHOLDER_ID, Duration = 0.25, Placeholder = true },
			Combat1 = { Id = PLACEHOLDER_ID, Duration = 0.8, Placeholder = true },
			Combat2 = { Id = PLACEHOLDER_ID, Duration = 0.8, Placeholder = true },
			Skill = { Id = PLACEHOLDER_ID, Duration = 1.2, Placeholder = true },
			BackOff = { Id = PLACEHOLDER_ID, Duration = 0.5, Placeholder = true },
		},
	},
	PetR6Blue = {
		Id = "PetR6Blue",
		Kind = "Pet",
		Inherits = "PetR6",
		Tracks = {
			Combat1 = { Id = PLACEHOLDER_ID, Duration = 0.6, Placeholder = true },
		},
	},
	EnemyR6 = {
		Id = "EnemyR6",
		Kind = "Enemy",
		Reactions = { Combat1 = "Defend", Combat2 = "Hit", Skill = "HitHeavy" },
		Tracks = {
			Idle = { Id = PLACEHOLDER_ID, Duration = 2, Looped = true, Placeholder = true },
			Defend = { Id = PLACEHOLDER_ID, Duration = 0.5, Placeholder = true },
			Hit = { Id = PLACEHOLDER_ID, Duration = 0.4, Placeholder = true },
			HitHeavy = { Id = PLACEHOLDER_ID, Duration = 0.6, Placeholder = true },
			Death = { Id = PLACEHOLDER_ID, Duration = 1, Placeholder = true },
			Spawn = { Id = PLACEHOLDER_ID, Duration = 0.8, Placeholder = true },
		},
	},
}

return AnimationSets
