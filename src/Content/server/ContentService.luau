local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(ServerScriptService.server.Modux)

type Issues = { string }

type ResolvedSet = {
	Kind: string,
	Tracks: { [string]: Content.AnimationDef },
	Turn: { Content.TurnMove }?,
	Reactions: { [Content.Move]: Content.TrackKey }?,
}

type ResolveState = {
	Issues: Issues,
	Resolved: { [string]: ResolvedSet },
	Failed: { [string]: boolean },
	Path: { string },
}

const TURN_MOVES: { [string]: boolean } = {
	Enter = true,
	Combat1 = true,
	Combat2 = true,
	BackOff = true,
}

const MOVES: { [string]: boolean } = {
	Enter = true,
	Combat1 = true,
	Combat2 = true,
	Skill = true,
	BackOff = true,
}

const REQUIRED_TRACKS: { [string]: { string } } = {
	Pet = { "Idle", "Run", "Assist", "Enter", "Combat1", "Combat2", "Skill", "BackOff" },
	Enemy = { "Idle", "Defend", "Hit", "Death", "Spawn" },
}

const LOOPED_TRACKS: { [string]: boolean } = {
	Idle = true,
	Run = true,
	Assist = true,
}

const TIMED_TRACKS: { [string]: boolean } = {
	Enter = true,
	Combat1 = true,
	Combat2 = true,
	Skill = true,
	BackOff = true,
	Defend = true,
	Hit = true,
	HitHeavy = true,
	Death = true,
	Spawn = true,
}

const REACTION_FALLBACKS: { [string]: string } = {
	HitHeavy = "Hit",
}

const ContentService = Modux.Service("ContentService", { Priority = 950 })

local function report(issues: Issues, file: string, id: string, problem: string)
	table.insert(issues, `{file}.luau [{id}] {problem}`)
end

local function checkId(issues: Issues, file: string, key: string, id: string)
	if key ~= id then
		report(issues, file, key, `key does not match Id "{id}"`)
	end
end

local function checkReference(
	issues: Issues,
	file: string,
	id: string,
	field: string,
	value: string,
	targetFile: string,
	exists: boolean
)
	if not exists then
		report(issues, file, id, `{field} "{value}" does not exist in {targetFile}.luau`)
	end
end

local function checkNonNegative(issues: Issues, file: string, id: string, field: string, value: number?)
	if value ~= nil and value < 0 then
		report(issues, file, id, `{field} is negative ({value})`)
	end
end

local function checkTurn(issues: Issues, file: string, id: string, field: string, turn: { Content.TurnMove })
	if #turn == 0 then
		report(issues, file, id, `{field} is empty`)
		return
	end
	for index, move in turn do
		if not TURN_MOVES[move] then
			report(issues, file, id, `{field}[{index}] "{move}" is not Enter, Combat1, Combat2 or BackOff`)
		end
	end
	if turn[#turn] ~= "BackOff" then
		report(issues, file, id, `{field} must end with BackOff`)
	end
end

local function hasAsset(folder: Instance?, name: string): boolean
	return folder ~= nil and folder:FindFirstChild(name) ~= nil
end

local function resolveSet(state: ResolveState, key: string): ResolvedSet?
	const cached = state.Resolved[key]
	if cached then
		return cached
	end
	if state.Failed[key] then
		return nil
	end

	const cycleStart = table.find(state.Path, key)
	if cycleStart ~= nil then
		const chain = table.concat(state.Path, " -> ", cycleStart)
		report(state.Issues, "AnimationSets", key, `Inherits cycle: {chain} -> {key}`)
		state.Failed[key] = true
		return nil
	end

	const declared = Content.AnimationSets[key]
	local parent: ResolvedSet? = nil
	local failed = false

	const parentKey = declared.Inherits
	if parentKey ~= nil then
		if Content.AnimationSets[parentKey] == nil then
			report(state.Issues, "AnimationSets", key, `Inherits "{parentKey}" does not exist in AnimationSets.luau`)
			failed = true
		else
			table.insert(state.Path, key)
			parent = resolveSet(state, parentKey)
			table.remove(state.Path)
			if parent == nil then
				failed = true
			elseif parent.Kind ~= declared.Kind then
				report(
					state.Issues,
					"AnimationSets",
					key,
					`Kind {declared.Kind} inherits "{parentKey}" of Kind {parent.Kind}`
				)
				failed = true
			end
		end
	end

	if failed then
		state.Failed[key] = true
		return nil
	end

	const tracks: { [string]: Content.AnimationDef } = {}
	local turn = declared.Turn
	local reactions = declared.Reactions
	if parent ~= nil then
		for trackKey, track in parent.Tracks do
			tracks[trackKey] = track
		end
		turn = turn or parent.Turn
		reactions = reactions or parent.Reactions
	end
	for trackKey, track in declared.Tracks do
		tracks[trackKey] = track
	end

	const resolved: ResolvedSet = {
		Kind = declared.Kind,
		Tracks = tracks,
		Turn = turn,
		Reactions = reactions,
	}
	state.Resolved[key] = resolved
	return resolved
end

local function checkDeclaredTracks(issues: Issues, key: string, set: Content.AnimationSet)
	for trackKey, track in set.Tracks do
		if TIMED_TRACKS[trackKey] and track.Duration <= 0 then
			report(issues, "AnimationSets", key, `track {trackKey} has Duration {track.Duration} (must be > 0)`)
		end
		if LOOPED_TRACKS[trackKey] and track.Looped ~= true then
			report(issues, "AnimationSets", key, `track {trackKey} must have Looped = true`)
		end
	end
end

local function checkResolvedSet(issues: Issues, key: string, set: ResolvedSet)
	const required = REQUIRED_TRACKS[set.Kind]
	if required == nil then
		report(issues, "AnimationSets", key, `Kind "{set.Kind}" is not Pet or Enemy`)
		return
	end
	for _, trackKey in required do
		if set.Tracks[trackKey] == nil then
			report(issues, "AnimationSets", key, `missing required {set.Kind} track {trackKey}`)
		end
	end

	const turn = set.Turn
	if turn ~= nil then
		checkTurn(issues, "AnimationSets", key, "Turn", turn)
	end

	const reactions = set.Reactions
	if reactions ~= nil then
		for move, trackKey in reactions do
			if not MOVES[move] then
				report(issues, "AnimationSets", key, `Reactions key "{move}" is not a Move`)
				continue
			end
			local target: string = trackKey
			if set.Tracks[target] == nil and REACTION_FALLBACKS[target] ~= nil then
				target = REACTION_FALLBACKS[target]
			end
			if set.Tracks[target] == nil then
				report(issues, "AnimationSets", key, `Reactions.{move} points to missing track {trackKey}`)
			end
		end
	end
end

local function checkAnimationSets(issues: Issues)
	const state: ResolveState = {
		Issues = issues,
		Resolved = {},
		Failed = {},
		Path = {},
	}
	for key, set in Content.AnimationSets do
		checkId(issues, "AnimationSets", key, set.Id)
		checkDeclaredTracks(issues, key, set)
	end
	for key in Content.AnimationSets do
		const resolved = resolveSet(state, key)
		if resolved ~= nil then
			checkResolvedSet(issues, key, resolved)
		end
	end
end

local function checkCharacters(issues: Issues, characterFolder: Instance?)
	for key, character in Content.Characters do
		checkId(issues, "Characters", key, character.Id)
		checkReference(
			issues,
			"Characters",
			key,
			"AnimationSet",
			character.AnimationSet,
			"AnimationSets",
			Content.AnimationSets[character.AnimationSet] ~= nil
		)
		if not hasAsset(characterFolder, character.Model) then
			report(issues, "Characters", key, `Model "{character.Model}" not found in ReplicatedStorage.Assets.Characters`)
		end
		const effects = character.Effects
		const effectFields: { [string]: string? } = {
			TeleportOut = effects.TeleportOut,
			TeleportIn = effects.TeleportIn,
			Assist = effects.Assist,
		}
		for field, effect in effectFields do
			if effect ~= nil then
				checkReference(issues, "Characters", key, `Effects.{field}`, effect, "Effects", Content.Effects[effect] ~= nil)
			end
		end
	end
end

local function checkEffects(issues: Issues, effectFolder: Instance?)
	for key, effect in Content.Effects do
		checkId(issues, "Effects", key, effect.Id)
		if not hasAsset(effectFolder, effect.Asset) then
			report(issues, "Effects", key, `Asset "{effect.Asset}" not found in ReplicatedStorage.Assets.Effects`)
		end
	end
end

local function checkAbilities(issues: Issues)
	for key, ability in Content.Abilities do
		checkId(issues, "Abilities", key, ability.Id)
		checkNonNegative(issues, "Abilities", key, "Cooldown", ability.Cooldown)
		const effect = ability.Effect
		if effect ~= nil then
			checkReference(issues, "Abilities", key, "Effect", effect, "Effects", Content.Effects[effect] ~= nil)
		end
		const castEffect = ability.CastEffect
		if castEffect ~= nil then
			checkReference(issues, "Abilities", key, "CastEffect", castEffect, "Effects", Content.Effects[castEffect] ~= nil)
		end
	end
end

local function checkPets(issues: Issues)
	for key, pet in Content.Pets do
		checkId(issues, "Pets", key, pet.Id)
		checkReference(issues, "Pets", key, "Character", pet.Character, "Characters", Content.Characters[pet.Character] ~= nil)
		checkReference(issues, "Pets", key, "Rarity", pet.Rarity, "Rarities", Content.Rarities[pet.Rarity] ~= nil)
		checkReference(issues, "Pets", key, "Ability", pet.Ability, "Abilities", Content.Abilities[pet.Ability] ~= nil)
		checkNonNegative(issues, "Pets", key, "Damage", pet.Damage)
		checkNonNegative(issues, "Pets", key, "AttackInterval", pet.AttackInterval)
	end
end

local function checkEnemies(issues: Issues)
	for key, enemy in Content.Enemies do
		checkId(issues, "Enemies", key, enemy.Id)
		checkReference(
			issues,
			"Enemies",
			key,
			"Character",
			enemy.Character,
			"Characters",
			Content.Characters[enemy.Character] ~= nil
		)
		checkNonNegative(issues, "Enemies", key, "Health", enemy.Health)
		checkNonNegative(issues, "Enemies", key, "Rewards.Coins", enemy.Rewards.Coins)
		checkNonNegative(issues, "Enemies", key, "Rewards.PetXp", enemy.Rewards.PetXp)
	end
end

local function checkEggs(issues: Issues)
	for key, egg in Content.Eggs do
		checkId(issues, "Eggs", key, egg.Id)
		for index, entry in egg.Pool do
			checkReference(issues, "Eggs", key, `Pool[{index}].Pet`, entry.Pet, "Pets", Content.Pets[entry.Pet] ~= nil)
			checkNonNegative(issues, "Eggs", key, `Pool[{index}].Weight`, entry.Weight)
		end
	end
end

local function checkRarities(issues: Issues)
	for key, rarity in Content.Rarities do
		checkId(issues, "Rarities", key, rarity.Id)
	end
end

local function checkTuning(issues: Issues)
	const tuning = Content.Tuning
	for index, pet in tuning.StarterPets do
		checkReference(issues, "Tuning", "Tuning", `StarterPets[{index}]`, pet, "Pets", Content.Pets[pet] ~= nil)
	end
	checkNonNegative(issues, "Tuning", "Tuning", "SkillGap", tuning.SkillGap)
	checkTurn(issues, "Tuning", "Tuning", "DefaultTurn", tuning.DefaultTurn)
	checkReference(
		issues,
		"Tuning",
		"Tuning",
		"DefaultTeleportOut",
		tuning.DefaultTeleportOut,
		"Effects",
		Content.Effects[tuning.DefaultTeleportOut] ~= nil
	)
	checkReference(
		issues,
		"Tuning",
		"Tuning",
		"DefaultTeleportIn",
		tuning.DefaultTeleportIn,
		"Effects",
		Content.Effects[tuning.DefaultTeleportIn] ~= nil
	)
end

local function countPlaceholders(): (number, { string })
	local total = 0
	const perSet: { string } = {}
	for key, set in Content.AnimationSets do
		local count = 0
		for _, track in set.Tracks do
			if track.Placeholder == true then
				count += 1
			end
		end
		if count > 0 then
			total += count
			table.insert(perSet, `{key}: {count}`)
		end
	end
	table.sort(perSet)
	return total, perSet
end

function ContentService:Validate(): Issues
	const issues: Issues = {}
	const assets = ReplicatedStorage:FindFirstChild("Assets")
	const characterFolder = if assets then assets:FindFirstChild("Characters") else nil
	const effectFolder = if assets then assets:FindFirstChild("Effects") else nil

	checkRarities(issues)
	checkAnimationSets(issues)
	checkCharacters(issues, characterFolder)
	checkEffects(issues, effectFolder)
	checkAbilities(issues)
	checkPets(issues)
	checkEnemies(issues)
	checkEggs(issues)
	checkTuning(issues)

	table.sort(issues)
	return issues
end

ContentService:OnInit(function(self)
	const placeholders, perSet = countPlaceholders()
	if placeholders > 0 then
		warn(`[ContentService] {placeholders} placeholder animations to replace ({table.concat(perSet, ", ")})`)
	end

	const issues = self:Validate()
	if #issues > 0 then
		error(`[ContentService] {#issues} content error(s):\n  {table.concat(issues, "\n  ")}`, 0)
	end
end)

return ContentService
