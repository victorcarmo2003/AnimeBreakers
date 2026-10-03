local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Content = require(ReplicatedStorage.shared.Content)
local SignalLib = require(ReplicatedStorage.shared.Libs.Signal)
local Modux = require(ServerScriptService.server.Modux)

export type Ledger = { [Player]: number }

export type Enemy = {
	Uid: number,
	Def: Content.EnemyDef,
	Health: number,
	MaxHealth: number,
	Alive: boolean,
	Life: number,
	Position: Vector3,
	Ledger: Ledger,
	TakeDamage: (self: any, amount: number, player: Player) -> number,
}

export type EnemySnapshot = {
	Uid: number,
	EnemyId: string,
	Health: number,
	MaxHealth: number,
	Alive: boolean,
	Life: number,
}

const EnemyService = Modux.Service("EnemyService", { Require = { "NetService" }, Priority = 700 })

function EnemyService:Setup()
	self.LastUid = 0 :: number
	self.Registry = {} :: { [number]: Enemy }
	self.Spawned = self.Libs.Signal.new() :: SignalLib.Signal<number>
	self.Died = self.Libs.Signal.new() :: SignalLib.Signal<number, Ledger, Content.EnemyDef>
end

function EnemyService:NextUid(): number
	self.LastUid += 1
	return self.LastUid
end

function EnemyService:CanPublish(): boolean
	return self.Dependencies.NetService:IsRunning()
end

function EnemyService:Register(enemy: Enemy)
	self.Registry[enemy.Uid] = enemy
	self.Spawned:Fire(enemy.Uid)
end

function EnemyService:Unregister(uid: number)
	self.Registry[uid] = nil
end

function EnemyService:NotifyRespawned(uid: number)
	self.Spawned:Fire(uid)
end

function EnemyService:NotifyDied(uid: number, ledger: Ledger, def: Content.EnemyDef)
	self.Died:Fire(uid, ledger, def)
end

function EnemyService:Get(uid: number): Enemy?
	return self.Registry[uid]
end

function EnemyService:Position(uid: number): Vector3?
	const enemy = self.Registry[uid]
	return if enemy then enemy.Position else nil
end

function EnemyService:ApplyDamage(uid: number, amount: number, player: Player): number
	const enemy = self.Registry[uid]
	if enemy == nil or not enemy.Alive then
		return 0
	end
	if typeof(amount) ~= "number" or amount ~= amount or amount < 1 then
		return 0
	end
	return enemy:TakeDamage(amount, player)
end

function EnemyService:Snapshot(): { EnemySnapshot }
	const snapshot = {}
	for uid, enemy in self.Registry do
		table.insert(snapshot, {
			Uid = uid,
			EnemyId = enemy.Def.Id,
			Health = enemy.Health,
			MaxHealth = enemy.MaxHealth,
			Alive = enemy.Alive,
			Life = enemy.Life,
		})
	end
	table.sort(snapshot, function(a: EnemySnapshot, b: EnemySnapshot)
		return a.Uid < b.Uid
	end)
	return snapshot
end

EnemyService:OnInit(function(self)
	self:Setup()
end)

return EnemyService
