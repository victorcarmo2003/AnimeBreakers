local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
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

export type EngagementReport = {
	EnemyUid: number?,
	Phase: string,
	Featured: number?,
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
		return { EnemyUid = nil, Phase = "Closed", Featured = nil }
	end
	return {
		EnemyUid = engagement.EnemyUid,
		Phase = engagement.Phase,
		Featured = engagement.Featured,
	}
end

function CombatDevService:FireAs(playerName: unknown, packet: unknown, payload: unknown): boolean
	const player = resolvePlayer(playerName)
	const combat = self.Dependencies.CombatService
	if packet == "Attack" then
		return combat:HandleAttack(player, payload)
	elseif packet == "Recall" then
		return combat:HandleRecall(player)
	end
	error(`unsupported packet "{tostring(packet)}". Supported: Attack, Recall`, 0)
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
end)

return CombatDevService
