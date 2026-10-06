export type Phase = "Open" | "Closed"

export type Engagement = {
	Owner: Player,
	EnemyUid: number,
	Units: { number },
	Phase: Phase,
	Featured: number?,
}

const Engagement = {}

function Engagement.new(owner: Player, enemyUid: number): Engagement
	return {
		Owner = owner,
		EnemyUid = enemyUid,
		Units = {},
		Phase = "Open",
		Featured = nil,
	}
end

function Engagement.AddUnit(engagement: Engagement, unitId: number)
	if table.find(engagement.Units, unitId) == nil then
		table.insert(engagement.Units, unitId)
	end
end

function Engagement.RemoveUnit(engagement: Engagement, unitId: number): boolean
	const index = table.find(engagement.Units, unitId)
	if index == nil then
		return false
	end
	table.remove(engagement.Units, index)
	if engagement.Featured == unitId then
		engagement.Featured = nil
	end
	return true
end

function Engagement.IsEmpty(engagement: Engagement): boolean
	return #engagement.Units == 0
end

function Engagement.Close(engagement: Engagement)
	engagement.Phase = "Closed"
	engagement.Featured = nil
end

return Engagement
