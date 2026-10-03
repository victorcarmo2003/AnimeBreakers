local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(ServerScriptService.server.Modux)

const EnemySpawn = Modux.Component("EnemySpawn", { Tag = "EnemySpawn", Require = { "EnemyService" } })

local function footPosition(part: BasePart): Vector3
	return (part.CFrame * CFrame.new(0, -part.Size.Y / 2, 0)).Position
end

local function yawDegrees(part: BasePart): number
	const look = part.CFrame.LookVector
	const degrees = math.round(math.deg(math.atan2(-look.X, -look.Z)))
	return degrees % 360
end

local function label(instance: Instance): string
	const custom = instance:GetAttribute("Label")
	return if typeof(custom) == "string" then custom else instance:GetFullName()
end

function EnemySpawn:Setup(part: BasePart, def: Content.EnemyDef)
	const respawnOverride = part:GetAttribute("RespawnSeconds")

	self.Uid = self.Dependencies.EnemyService:NextUid() :: number
	self.Def = def :: Content.EnemyDef
	self.MaxHealth = def.Health :: number
	self.Health = def.Health :: number
	self.Alive = true :: boolean
	self.Life = 1 :: number
	self.Position = footPosition(part) :: Vector3
	self.Yaw = yawDegrees(part) :: number
	self.RespawnSeconds = (
		if typeof(respawnOverride) == "number" and respawnOverride >= 0 then respawnOverride else def.RespawnSeconds
	) :: number
	self.Ledger = {} :: { [Player]: number }
	self.RespawnThread = nil :: thread?
	self.Active = false :: boolean
end

function EnemySpawn:Publish(fields: { Health: number?, Alive: boolean?, Life: number? })
	if not self.Dependencies.EnemyService:CanPublish() then
		return
	end
	self.Libs.Net.Enemies:update(self.Uid, fields)
end

function EnemySpawn:TakeDamage(amount: number, player: Player): number
	if not self.Active or not self.Alive then
		return 0
	end

	const applied = math.min(math.floor(amount), self.Health)
	if applied <= 0 then
		return 0
	end

	self.Health -= applied
	self.Ledger[player] = (self.Ledger[player] or 0) + applied

	if self.Health > 0 then
		self:Publish({ Health = self.Health })
		return applied
	end

	self.Alive = false
	self:Publish({ Health = 0, Alive = false })

	const ledgerCopy = table.clone(self.Ledger)
	self.Dependencies.EnemyService:NotifyDied(self.Uid, ledgerCopy, self.Def)
	self:ScheduleRespawn()
	return applied
end

function EnemySpawn:ScheduleRespawn()
	self.RespawnThread = task.delay(self.RespawnSeconds, function()
		self.RespawnThread = nil
		self:Respawn()
	end)
end

function EnemySpawn:Respawn()
	if not self.Active then
		return
	end

	self.Health = self.MaxHealth
	self.Ledger = {}
	self.Life += 1
	self.Alive = true
	self:Publish({ Health = self.Health, Alive = true, Life = self.Life })
	self.Dependencies.EnemyService:NotifyRespawned(self.Uid)
end

EnemySpawn:OnInit(function(self)
	const instance = self.Instance
	if not instance:IsA("BasePart") then
		warn(`[EnemySpawn] {label(instance)} is a {instance.ClassName}, expected a BasePart; skipped`)
		return
	end

	const enemyId = instance:GetAttribute("EnemyId")
	if typeof(enemyId) ~= "string" then
		warn(`[EnemySpawn] {label(instance)} has no EnemyId attribute; skipped`)
		return
	end

	const def = Content.Enemies[enemyId]
	if def == nil then
		warn(`[EnemySpawn] {label(instance)} has unknown EnemyId "{enemyId}"; skipped`)
		return
	end

	self:Setup(instance, def)

	self.Libs.Net.Enemies:add(self.Uid, {
		Enemy = def.Id,
		Position = self.Position,
		Yaw = self.Yaw,
		Health = self.Health,
		MaxHealth = self.MaxHealth,
		Alive = self.Alive,
		Life = self.Life,
	})
	self.Active = true
	self.Dependencies.EnemyService:Register(self :: any)
end)

EnemySpawn:OnDestroy(function(self)
	if not self.Active then
		return
	end
	self.Active = false

	const pendingRespawn = self.RespawnThread
	if pendingRespawn then
		task.cancel(pendingRespawn)
		self.RespawnThread = nil
	end

	self.Dependencies.EnemyService:Unregister(self.Uid)
	if self.Dependencies.EnemyService:CanPublish() and self.Libs.Net.Enemies:get(self.Uid) then
		self.Libs.Net.Enemies:remove(self.Uid)
	end
end)

return EnemySpawn
