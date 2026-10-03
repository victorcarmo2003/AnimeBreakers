local Types = require(script.Types)
local Rarities = require(script.Rarities)
local Characters = require(script.Characters)
local AnimationSets = require(script.AnimationSets)
local Abilities = require(script.Abilities)
local Effects = require(script.Effects)
local Pets = require(script.Pets)
local Enemies = require(script.Enemies)
local Eggs = require(script.Eggs)
local Tuning = require(script.Tuning)
local Interface = require(script.Interface)

export type Move = Types.Move
export type TurnMove = Types.TurnMove
export type TrackKey = Types.TrackKey
export type PetTrackKey = Types.PetTrackKey
export type EnemyTrackKey = Types.EnemyTrackKey
export type RarityDef = Types.RarityDef
export type CharacterDef = Types.CharacterDef
export type AnimationDef = Types.AnimationDef
export type AnimationSet = Types.AnimationSet
export type AbilityDef = Types.AbilityDef
export type EffectDef = Types.EffectDef
export type PetDef = Types.PetDef
export type RewardDef = Types.RewardDef
export type EnemyDef = Types.EnemyDef
export type EggDef = Types.EggDef
export type TuningDef = Types.TuningDef
export type InterfaceDef = Types.InterfaceDef

const resolvedAnimationSets: { [string]: Types.AnimationSet } = {}

local function lookup<T>(source: { [string]: T }, kind: string, id: string): T
	const entry = source[id]
	if entry == nil then
		error(`[Content] unknown {kind} "{id}"`, 3)
	end
	return entry
end

local function resolveAnimationSet(key: string, visiting: { [string]: boolean }): Types.AnimationSet
	const cached = resolvedAnimationSets[key]
	if cached then
		return cached
	end

	if visiting[key] then
		error(`[Content] AnimationSet inheritance cycle at "{key}"`, 0)
	end

	const declared = AnimationSets[key]
	if declared == nil then
		error(`[Content] unknown AnimationSet "{key}"`, 0)
	end

	visiting[key] = true

	const tracks: Types.Tracks = {}
	local turn = declared.Turn
	local reactions = declared.Reactions

	const parentKey = declared.Inherits
	if parentKey ~= nil then
		const parent = resolveAnimationSet(parentKey, visiting)
		if parent.Kind ~= declared.Kind then
			error(`[Content] AnimationSet "{key}" ({declared.Kind}) inherits "{parentKey}" ({parent.Kind})`, 0)
		end
		for trackKey, track in parent.Tracks do
			tracks[trackKey] = track
		end
		turn = turn or parent.Turn
		reactions = reactions or parent.Reactions
	end

	for trackKey, track in declared.Tracks do
		tracks[trackKey] = track
	end

	const resolved: Types.AnimationSet = {
		Id = declared.Id,
		Kind = declared.Kind,
		Inherits = declared.Inherits,
		Tracks = tracks,
		Turn = turn,
		Reactions = reactions,
	}

	visiting[key] = nil
	resolvedAnimationSets[key] = resolved
	return resolved
end

const Content = {
	Rarities = Rarities,
	Characters = Characters,
	AnimationSets = AnimationSets,
	Abilities = Abilities,
	Effects = Effects,
	Pets = Pets,
	Enemies = Enemies,
	Eggs = Eggs,
	Tuning = Tuning,
	Interface = Interface,
}

function Content.Rarity(key: string): Types.RarityDef
	return lookup(Rarities, "Rarity", key)
end

function Content.Character(key: string): Types.CharacterDef
	return lookup(Characters, "Character", key)
end

function Content.AnimationSet(key: string): Types.AnimationSet
	if AnimationSets[key] == nil then
		error(`[Content] unknown AnimationSet "{key}"`, 2)
	end
	return resolveAnimationSet(key, {})
end

function Content.Ability(id: string): Types.AbilityDef
	return lookup(Abilities, "Ability", id)
end

function Content.Effect(key: string): Types.EffectDef
	return lookup(Effects, "Effect", key)
end

function Content.Pet(id: string): Types.PetDef
	return lookup(Pets, "Pet", id)
end

function Content.Enemy(id: string): Types.EnemyDef
	return lookup(Enemies, "Enemy", id)
end

function Content.Egg(id: string): Types.EggDef
	return lookup(Eggs, "Egg", id)
end

return Content
