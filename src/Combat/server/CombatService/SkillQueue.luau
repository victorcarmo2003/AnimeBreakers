export type SkillQueue = {
	Units: { number },
}

const SkillQueue = {}

function SkillQueue.new(): SkillQueue
	return { Units = {} }
end

function SkillQueue.Contains(queue: SkillQueue, unitId: number): boolean
	return table.find(queue.Units, unitId) ~= nil
end

function SkillQueue.Push(queue: SkillQueue, unitId: number): boolean
	if SkillQueue.Contains(queue, unitId) then
		return false
	end
	table.insert(queue.Units, unitId)
	return true
end

function SkillQueue.Pop(queue: SkillQueue): number?
	if #queue.Units == 0 then
		return nil
	end
	return table.remove(queue.Units, 1)
end

function SkillQueue.Remove(queue: SkillQueue, unitId: number): boolean
	const index = table.find(queue.Units, unitId)
	if index == nil then
		return false
	end
	table.remove(queue.Units, index)
	return true
end

function SkillQueue.IsEmpty(queue: SkillQueue): boolean
	return #queue.Units == 0
end

function SkillQueue.Clear(queue: SkillQueue)
	table.clear(queue.Units)
end

function SkillQueue.Snapshot(queue: SkillQueue): { number }
	return table.clone(queue.Units)
end

return SkillQueue
