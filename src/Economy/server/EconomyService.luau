local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(ServerScriptService.server.Modux)

export type Ledger = { [Player]: number }

export type PayoutEntry = {
	Player: Player,
	Damage: number,
	Present: boolean,
	Share: number,
}

const EconomyService = Modux.Service(
	"EconomyService",
	{ Require = { "EnemyService", "ProfileService", "NetService" }, Priority = 550 }
)

local function computeShare(pool: number, damage: number, total: number): number
	if pool <= 0 or damage <= 0 or total <= 0 then
		return 0
	end
	return math.max(1, math.floor(pool * damage / total))
end

function EconomyService:Setup()
	self.Payouts = {} :: { [number]: { PayoutEntry } }
end

function EconomyService:LastPayout(uid: number): { PayoutEntry }?
	return self.Payouts[uid]
end

function EconomyService:Split(ledger: Ledger, pool: number): { PayoutEntry }
	local total = 0
	for _, damage in ledger do
		if damage > 0 then
			total += damage
		end
	end

	const entries: { PayoutEntry } = {}
	for player, damage in ledger do
		const present = player.Parent == Players
		table.insert(entries, {
			Player = player,
			Damage = damage,
			Present = present,
			Share = if present then computeShare(pool, damage, total) else 0,
		})
	end
	table.sort(entries, function(a: PayoutEntry, b: PayoutEntry)
		return a.Damage > b.Damage
	end)
	return entries
end

function EconomyService:Credit(player: Player, coins: number): boolean
	const profile = self.Dependencies.ProfileService:Get(player)
	if profile == nil then
		return false
	end
	profile.Coins(profile.Coins() + coins)
	return true
end

function EconomyService:SendReward(player: Player, uid: number, coins: number)
	const net = self.Dependencies.NetService
	if not net:IsRunning() or not net:IsReady(player) then
		return
	end
	self.Libs.Net.Reward:fireClient(player, { Enemy = uid, Coins = coins })
end

function EconomyService:Pay(uid: number, ledger: Ledger, def: Content.EnemyDef)
	const entries = self:Split(ledger, def.Rewards.Coins)
	for _, entry in entries do
		if not entry.Present or entry.Share <= 0 then
			continue
		end
		if self:Credit(entry.Player, entry.Share) then
			self:SendReward(entry.Player, uid, entry.Share)
		end
	end
	self.Payouts[uid] = entries
end

EconomyService:OnInit(function(self)
	self:Setup()
	self.Dependencies.EnemyService.Died:Connect(function(uid, ledger, def)
		self:Pay(uid, ledger, def)
	end)
end)

return EconomyService
