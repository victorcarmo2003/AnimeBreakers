local Types = require(script.Parent.Types)

const R6_IDLE = "rbxassetid://180435571"
const R6_RUN = "rbxassetid://180426354"
const R6_JUMP = "rbxassetid://125750702"
const R6_FALL = "rbxassetid://180436148"
const R6_CLIMB = "rbxassetid://180436334"
const R6_SIT = "rbxassetid://178130996"
const R6_POINT = "rbxassetid://128853357"
const R6_WAVE = "rbxassetid://128777973"
const R6_CHEER = "rbxassetid://129423030"
const R6_TOOL_NONE = "rbxassetid://182393478"
const R6_TOOL_SLASH = "rbxassetid://129967390"
const R6_TOOL_LUNGE = "rbxassetid://129967478"

const AnimationSets: { [string]: Types.AnimationSet } = {
	PetR6 = {
		Id = "PetR6",
		Kind = "Pet",
		Turn = { "Enter", "Combat1", "Combat2", "BackOff" },
		Tracks = {
			Idle = { Id = R6_IDLE, Duration = 1, Looped = true, Placeholder = true },
			Run = { Id = R6_RUN, Duration = 0.667, Looped = true, Placeholder = true },
			Assist = { Id = R6_POINT, Duration = 1.125, Looped = true, Placeholder = true },
			Enter = { Id = R6_JUMP, Duration = 0.625, Placeholder = true },
			Combat1 = { Id = R6_TOOL_SLASH, Duration = 0.5, Placeholder = true },
			Combat2 = { Id = R6_TOOL_LUNGE, Duration = 1, Speed = 1.5, Placeholder = true },
			Skill = { Id = R6_CHEER, Duration = 1.042, Placeholder = true },
			BackOff = { Id = R6_FALL, Duration = 0.65, Looped = false, Placeholder = true },
		},
	},
	PetR6Blue = {
		Id = "PetR6Blue",
		Kind = "Pet",
		Inherits = "PetR6",
		Tracks = {
			Combat1 = { Id = R6_TOOL_LUNGE, Duration = 0.75, Speed = 2, Placeholder = true },
		},
	},
	EnemyR6 = {
		Id = "EnemyR6",
		Kind = "Enemy",
		Reactions = { Combat1 = "Defend", Combat2 = "Hit", Skill = "HitHeavy" },
		Tracks = {
			Idle = { Id = R6_IDLE, Duration = 1, Looped = true, Placeholder = true },
			Defend = { Id = R6_TOOL_NONE, Duration = 0.5, Looped = false, Placeholder = true },
			Hit = { Id = R6_CLIMB, Duration = 0.458, Looped = false, Placeholder = true },
			HitHeavy = { Id = R6_JUMP, Duration = 0.625, Placeholder = true },
			Death = { Id = R6_SIT, Duration = 2, Looped = false, Placeholder = true },
			Spawn = { Id = R6_WAVE, Duration = 1.5, Placeholder = true },
		},
	},
}

return AnimationSets
