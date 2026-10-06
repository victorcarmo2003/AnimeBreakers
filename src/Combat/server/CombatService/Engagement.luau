local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)
local FSM = require(ReplicatedStorage.shared.Libs.FSM)
local SkillQueue = require(script.Parent.SkillQueue)

export type Phase = "Open" | "Exchange" | "Skill" | "Closed"

export type PendingHit = {
	At: number,
	Unit: number,
	Amount: number,
	Kind: "Skill",
}

export type Engagement = {
	Owner: Player,
	EnemyUid: number,
	Units: { number },
	Phase: FSM.FSM<Phase>,
	Featured: number?,
	Script: { Content.Move },
	MoveEndsAt: number,
	Cursor: number,
	Queue: SkillQueue.SkillQueue,
	LastCastAt: number,
	PendingHits: { PendingHit },
}

const PHASE_TRANSITIONS: { [Phase]: { Phase } } = {
	Open = { "Exchange", "Skill", "Closed" },
	Exchange = { "Open", "Skill", "Closed" },
	Skill = { "Open", "Closed" },
	Closed = {},
}

const Engagement = {}

function Engagement.new(owner: Player, enemyUid: number): Engagement
	return {
		Owner = owner,
		EnemyUid = enemyUid,
		Units = {},
		Phase = FSM.new("Open" :: Phase, PHASE_TRANSITIONS),
		Featured = nil,
		Script = {},
		MoveEndsAt = 0,
		Cursor = 1,
		Queue = SkillQueue.new(),
		LastCastAt = -math.huge,
		PendingHits = {},
	}
end

function Engagement.PhaseName(engagement: Engagement): Phase
	return engagement.Phase:GetState()
end

function Engagement.IsClosed(engagement: Engagement): boolean
	return engagement.Phase:Is("Closed")
end

function Engagement.AddUnit(engagement: Engagement, unitId: number)
	if table.find(engagement.Units, unitId) == nil then
		table.insert(engagement.Units, unitId)
	end
end

function Engagement.ClearStage(engagement: Engagement)
	engagement.Featured = nil
	table.clear(engagement.Script)
	engagement.MoveEndsAt = 0
end

function Engagement.RemoveUnit(engagement: Engagement, unitId: number): boolean
	const index = table.find(engagement.Units, unitId)
	if index == nil then
		return false
	end
	table.remove(engagement.Units, index)
	if index < engagement.Cursor then
		engagement.Cursor -= 1
	end
	SkillQueue.Remove(engagement.Queue, unitId)
	for position = #engagement.PendingHits, 1, -1 do
		if engagement.PendingHits[position].Unit == unitId then
			table.remove(engagement.PendingHits, position)
		end
	end
	if engagement.Featured == unitId then
		Engagement.ClearStage(engagement)
		engagement.Phase:Transition("Open")
	end
	return true
end

function Engagement.IsEmpty(engagement: Engagement): boolean
	return #engagement.Units == 0
end

function Engagement.SchedulePendingHit(engagement: Engagement, hit: PendingHit)
	table.insert(engagement.PendingHits, hit)
end

function Engagement.TakeDueHits(engagement: Engagement, at: number): { PendingHit }
	const due: { PendingHit } = {}
	const kept: { PendingHit } = {}
	for _, hit in engagement.PendingHits do
		if at >= hit.At then
			table.insert(due, hit)
		else
			table.insert(kept, hit)
		end
	end
	if #due == 0 then
		return due
	end
	engagement.PendingHits = kept
	table.sort(due, function(left: PendingHit, right: PendingHit)
		return left.At < right.At
	end)
	return due
end

function Engagement.Close(engagement: Engagement)
	engagement.Phase:Transition("Closed")
	Engagement.ClearStage(engagement)
	SkillQueue.Clear(engagement.Queue)
	table.clear(engagement.PendingHits)
end

return Engagement
