local Types = require(script.Parent.Types)

const Characters: { [string]: Types.CharacterDef } = {
	DummyR6Red = {
		Id = "DummyR6Red",
		Model = "DummyR6Red",
		Rig = "R6",
		AnimationSet = "PetR6",
		Scale = 1,
		Radius = 1.5,
		Height = 5,
		Reach = 2,
		Effects = {},
	},
	DummyR6Blue = {
		Id = "DummyR6Blue",
		Model = "DummyR6Blue",
		Rig = "R6",
		AnimationSet = "PetR6Blue",
		Scale = 1,
		Radius = 1.5,
		Height = 5,
		Reach = 2,
		Effects = {},
	},
	DummyR6Green = {
		Id = "DummyR6Green",
		Model = "DummyR6Green",
		Rig = "R6",
		AnimationSet = "PetR6",
		Scale = 1,
		Radius = 1.5,
		Height = 5,
		Reach = 2,
		Effects = {},
	},
	DummyR6Grey = {
		Id = "DummyR6Grey",
		Model = "DummyR6Grey",
		Rig = "R6",
		AnimationSet = "EnemyR6",
		Scale = 1.4,
		Radius = 2,
		Height = 7,
		Reach = 0,
		PickSize = Vector3.new(7, 9, 7),
		Effects = {},
	},
}

return Characters
