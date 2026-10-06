local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Engagement = require(ServerScriptService.server.Combat.CombatService.Engagement)
local SkillQueue = require(ServerScriptService.server.Combat.CombatService.SkillQueue)
local Modux = require(ServerScriptService.server.Modux)

export type UnitReport = {
	Id: number,
	Slot: number,
	PetId: string,
	Target: number?,
	Ring: number,
	ArriveAt: number,
	NextHitAt: number,
	SkillReadyAt: number,
}

export type PendingHitReport = {
	At: number,
	Unit: number,
	Amount: number,
	Kind: string,
}

export type EngagementReport = {
	EnemyUid: number?,
	Phase: string,
	Featured: number?,
	Queue: { number },
	LastCastAt: number?,
	PendingHits: { PendingHitReport },
}

const CombatDevService = Modux.Service(
	"CombatDevService",
	{ Require = { "DevService", "CombatService", "PetService" }, Priority = 100 }
)

local function resolvePlayer(playerName: unknown): Player
	if typeof(playerName) ~= "string" then
		error("playerName must be a string", 0)
	end
	const found = Players:FindFirstChild(playerName)
	if found == nil or not found:IsA("Player") then
		error(`no player named "{playerName}"`, 0)
	end
	return found
end

function CombatDevService:Units(playerName: unknown): { UnitReport }
	const player = resolvePlayer(playerName)
	const reports: { UnitReport } = {}
	for _, unit in self.Dependencies.PetService:Units(player) do
		table.insert(reports, {
			Id = unit.Id,
			Slot = unit.Slot,
			PetId = unit.PetId,
			Target = unit.Target,
			Ring = unit.Ring,
			ArriveAt = unit.ArriveAt,
			NextHitAt = unit.NextHitAt,
			SkillReadyAt = unit.SkillReadyAt,
		})
	end
	return reports
end

function CombatDevService:Engagement(playerName: unknown): EngagementReport
	const player = resolvePlayer(playerName)
	const engagement = self.Dependencies.CombatService:Engagement(player)
	if engagement == nil then
		return { EnemyUid = nil, Phase = "Closed", Featured = nil, Queue = {}, LastCastAt = nil, PendingHits = {} }
	end
	const pending: { PendingHitReport } = {}
	for _, hit in engagement.PendingHits do
		table.insert(pending, { At = hit.At, Unit = hit.Unit, Amount = hit.Amount, Kind = hit.Kind })
	end
	return {
		EnemyUid = engagement.EnemyUid,
		Phase = Engagement.PhaseName(engagement),
		Featured = engagement.Featured,
		Queue = SkillQueue.Snapshot(engagement.Queue),
		LastCastAt = if engagement.LastCastAt > -math.huge then engagement.LastCastAt else nil,
		PendingHits = pending,
	}
end

function CombatDevService:FireAs(playerName: unknown, packet: unknown, payload: unknown): boolean
	const player = resolvePlayer(playerName)
	const combat = self.Dependencies.CombatService
	if packet == "Attack" then
		return combat:HandleAttack(player, payload)
	elseif packet == "Recall" then
		return combat:HandleRecall(player)
	elseif packet == "UseSkill" then
		return combat:HandleUseSkill(player, payload)
	elseif packet == "SetAutoSkill" then
		return combat:HandleSetAutoSkill(player, payload)
	end
	error(`unsupported packet "{tostring(packet)}". Supported: Attack, Recall, UseSkill, SetAutoSkill`, 0)
end

function CombatDevService:SetSkillReady(playerName: unknown, unitId: unknown, at: unknown): number
	const player = resolvePlayer(playerName)
	if typeof(unitId) ~= "number" then
		error("unitId must be a number", 0)
	end
	if typeof(at) ~= "number" then
		error("at must be a number (server time, workspace:GetServerTimeNow())", 0)
	end
	const pets = self.Dependencies.PetService
	const unit = pets:Unit(unitId)
	if unit == nil or unit.Owner ~= player then
		error(`unit {unitId} does not belong to {player.Name}`, 0)
	end
	pets:SetSkillReady(unit, at)
	return unit.SkillReadyAt
end

CombatDevService:OnInit(function(self)
	const dev = self.Dependencies.DevService

	dev:Register("Units", function(playerName: unknown)
		return self:Units(playerName)
	end)

	dev:Register("Engagement", function(playerName: unknown)
		return self:Engagement(playerName)
	end)

	dev:Register("FireAs", function(playerName: unknown, packet: unknown, payload: unknown)
		return self:FireAs(playerName, packet, payload)
	end)

	dev:Register("SetSkillReady", function(playerName: unknown, unitId: unknown, at: unknown)
		return self:SetSkillReady(playerName, unitId, at)
	end)
end)

return CombatDevService
