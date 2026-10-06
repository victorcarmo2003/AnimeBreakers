local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Content = require(ReplicatedStorage.shared.Content)
local PetTypes = require(ServerScriptService.server.ModuxTypes.PetService)
local Engagement = require(script.Parent.Engagement)

export type PetUnit = PetTypes.PetUnit
export type ResolveUnit = (unitId: number) -> PetUnit?
export type EmitBeat = (unitId: number, move: Content.Move) -> ()

const Choreography = {}

local function animationSetOf(unit: PetUnit): Content.AnimationSet
	return Content.AnimationSet(Content.Character(unit.Def.Character).AnimationSet)
end

function Choreography.Duration(unit: PetUnit, move: Content.Move): number
	const track = animationSetOf(unit).Tracks[move]
	if track == nil then
		return 0
	end
	return track.Duration
end

function Choreography.Turn(unit: PetUnit): { Content.Move }
	const declared = animationSetOf(unit).Turn or Content.Tuning.DefaultTurn
	const moves: { Content.Move } = {}
	for _, move in declared do
		table.insert(moves, move)
	end
	return moves
end

function Choreography.IsOnStage(engagement: Engagement.Engagement, unit: PetUnit, at: number): boolean
	return unit.Target == engagement.EnemyUid
		and at >= unit.ArriveAt
		and table.find(engagement.Units, unit.Id) ~= nil
end

local function nextPerformer(engagement: Engagement.Engagement, at: number, resolve: ResolveUnit): PetUnit?
	const count = #engagement.Units
	if count == 0 then
		return nil
	end
	const start = ((engagement.Cursor - 1) % count) + 1
	for offset = 0, count - 1 do
		const index = ((start - 1 + offset) % count) + 1
		const unit = resolve(engagement.Units[index])
		if unit ~= nil and Choreography.IsOnStage(engagement, unit, at) then
			engagement.Cursor = (index % count) + 1
			return unit
		end
	end
	return nil
end

local function playMove(
	engagement: Engagement.Engagement,
	unit: PetUnit,
	move: Content.Move,
	at: number,
	emit: EmitBeat
)
	engagement.MoveEndsAt = at + Choreography.Duration(unit, move)
	emit(unit.Id, move)
end

local function startTurn(engagement: Engagement.Engagement, at: number, resolve: ResolveUnit, emit: EmitBeat)
	const unit = nextPerformer(engagement, at, resolve)
	if unit == nil then
		return
	end
	const moves = Choreography.Turn(unit)
	const first = table.remove(moves, 1)
	if first == nil then
		return
	end
	engagement.Featured = unit.Id
	engagement.Script = moves
	engagement.Phase:Transition("Exchange")
	playMove(engagement, unit, first, at, emit)
end

function Choreography.Step(engagement: Engagement.Engagement, at: number, resolve: ResolveUnit, emit: EmitBeat)
	if Engagement.IsClosed(engagement) then
		return
	end

	const featuredId = engagement.Featured
	if featuredId ~= nil then
		const featured = resolve(featuredId)
		if featured == nil or featured.Target ~= engagement.EnemyUid then
			Engagement.ClearStage(engagement)
			engagement.Phase:Transition("Open")
		elseif at < engagement.MoveEndsAt then
			return
		else
			const move = table.remove(engagement.Script, 1)
			if move ~= nil then
				playMove(engagement, featured, move, at, emit)
				return
			end
			Engagement.ClearStage(engagement)
			engagement.Phase:Transition("Open")
		end
	end

	if engagement.Phase:Is("Open") then
		startTurn(engagement, at, resolve, emit)
	end
end

function Choreography.CastSkill(engagement: Engagement.Engagement, unit: PetUnit, at: number, emit: EmitBeat)
	engagement.Featured = unit.Id
	engagement.Script = { "BackOff" }
	engagement.Phase:Transition("Skill")
	playMove(engagement, unit, "Skill", at, emit)
end

return Choreography
