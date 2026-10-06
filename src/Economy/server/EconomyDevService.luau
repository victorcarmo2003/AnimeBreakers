local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Modux = require(ServerScriptService.server.Modux)

export type PayoutReport = {
	Name: string,
	Damage: number,
	Present: boolean,
	Share: number,
}

const EconomyDevService = Modux.Service(
	"EconomyDevService",
	{ Require = { "DevService", "EconomyService", "ProfileService" }, Priority = 100 }
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

function EconomyDevService:Coins(playerName: unknown): number
	const player = resolvePlayer(playerName)
	const profile = self.Dependencies.ProfileService:Get(player)
	if profile == nil then
		error(`{player.Name} has no loaded profile`, 0)
	end
	return profile.Coins()
end

function EconomyDevService:SetCoins(playerName: unknown, amount: unknown): number
	if typeof(amount) ~= "number" or amount ~= amount or amount < 0 then
		error("amount must be a non-negative number", 0)
	end
	const player = resolvePlayer(playerName)
	const profile = self.Dependencies.ProfileService:Get(player)
	if profile == nil then
		error(`{player.Name} has no loaded profile`, 0)
	end
	return profile.Coins(math.floor(amount))
end

function EconomyDevService:LastPayout(uid: unknown): { PayoutReport }
	if typeof(uid) ~= "number" then
		error("uid must be a number", 0)
	end
	const entries = self.Dependencies.EconomyService:LastPayout(uid)
	if entries == nil then
		error(`no payout recorded for enemy {uid}`, 0)
	end

	const report: { PayoutReport } = {}
	for _, entry in entries do
		table.insert(report, {
			Name = entry.Player.Name,
			Damage = entry.Damage,
			Present = entry.Present,
			Share = entry.Share,
		})
	end
	return report
end

EconomyDevService:OnInit(function(self)
	const dev = self.Dependencies.DevService

	dev:Register("Coins", function(playerName: unknown)
		return self:Coins(playerName)
	end)

	dev:Register("SetCoins", function(playerName: unknown, amount: unknown)
		return self:SetCoins(playerName, amount)
	end)

	dev:Register("LastPayout", function(uid: unknown)
		return self:LastPayout(uid)
	end)
end)

return EconomyDevService
