local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Modux = require(ServerScriptService.server.Modux)

export type LedgerEntry = {
	Name: string,
	Damage: number,
	Present: boolean,
}

export type LedgerReport = {
	Entries: { LedgerEntry },
	Total: number,
}

const EnemyDevService = Modux.Service(
	"EnemyDevService",
	{ Require = { "DevService", "EnemyService" }, Priority = 100 }
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

local function resolveUid(uid: unknown): number
	if typeof(uid) ~= "number" then
		error("uid must be a number", 0)
	end
	return uid
end

function EnemyDevService:Ledger(uid: unknown): LedgerReport
	const enemy = self.Dependencies.EnemyService:Get(resolveUid(uid))
	if enemy == nil then
		error(`no enemy with uid {uid}`, 0)
	end

	const entries: { LedgerEntry } = {}
	local total = 0
	for player, damage in enemy.Ledger do
		total += damage
		table.insert(entries, {
			Name = player.Name,
			Damage = damage,
			Present = player.Parent == Players,
		})
	end
	table.sort(entries, function(a: LedgerEntry, b: LedgerEntry)
		return a.Damage > b.Damage
	end)
	return { Entries = entries, Total = total }
end

EnemyDevService:OnInit(function(self)
	const dev = self.Dependencies.DevService
	const enemies = self.Dependencies.EnemyService

	dev:Register("Enemies", function()
		return enemies:Snapshot()
	end)

	dev:Register("Damage", function(uid: unknown, amount: unknown, playerName: unknown)
		if typeof(amount) ~= "number" then
			error("amount must be a number", 0)
		end
		const target = resolveUid(uid)
		if enemies:Get(target) == nil then
			error(`no enemy with uid {target}`, 0)
		end
		return enemies:ApplyDamage(target, amount, resolvePlayer(playerName))
	end)

	dev:Register("Kill", function(uid: unknown, playerName: unknown)
		const target = resolveUid(uid)
		const enemy = enemies:Get(target)
		if enemy == nil then
			error(`no enemy with uid {target}`, 0)
		end
		return enemies:ApplyDamage(target, enemy.Health, resolvePlayer(playerName))
	end)

	dev:Register("Ledger", function(uid: unknown)
		return self:Ledger(uid)
	end)
end)

return EnemyDevService
