local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Content = require(ReplicatedStorage.shared.Content)
local PetTypes = require(ServerScriptService.server.ModuxTypes.PetService)
local Engagement = require(script.Engagement)
local SkillQueue = require(script.SkillQueue)
local Choreography = require(script.Choreography)
local Modux = require(ServerScriptService.server.Modux)

export type PetUnit = PetTypes.PetUnit
export type Engagement = Engagement.Engagement
export type PendingHit = Engagement.PendingHit
export type Move = Content.Move

export type HitKind = "Basic" | "Skill"

export type Hit = {
	Enemy: number,
	Unit: number,
	Amount: number,
	Kind: HitKind,
}

const RING_COUNT = 64
const MAX_HITS_PER_PACKET = 255
const LEASH_CHECK_RATE = 2

const CombatService = Modux.Service(
	"CombatService",
	{ Require = { "NetService", "PlayerService", "ProfileService", "EnemyService", "PetService" }, Priority = 600 }
)

local function aliveRoot(player: Player): BasePart?
	if player.Parent ~= Players then
		return nil
	end
	const character = player.Character
	if character == nil then
		return nil
	end
	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health <= 0 then
		return nil
	end
	const root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return nil
	end
	return root
end

local function now(): number
	return workspace:GetServerTimeNow()
end

function CombatService:Setup()
	self.Engagements = {} :: { [Player]: Engagement }
	self.Rings = {} :: { [number]: { [number]: number } }
	self.LastCommandAt = {} :: { [Player]: number }
	self.OutgoingHits = {} :: { [Player]: { Hit } }
	self.Random = Random.new() :: Random
end

function CombatService:Engagement(player: Player): Engagement?
	return self.Engagements[player]
end

function CombatService:PassRateLimit(player: Player): boolean
	const clock = os.clock()
	const last = self.LastCommandAt[player]
	if last ~= nil and clock - last < Content.Tuning.CommandMinInterval then
		return false
	end
	self.LastCommandAt[player] = clock
	return true
end

function CombatService:ClaimRing(enemyUid: number, unitId: number): number
	local ring = self.Rings[enemyUid]
	if ring == nil then
		ring = {}
		self.Rings[enemyUid] = ring
	end
	for index = 0, RING_COUNT - 1 do
		const holder = ring[index]
		if holder == nil or holder == unitId then
			ring[index] = unitId
			return index
		end
	end
	return unitId % RING_COUNT
end

function CombatService:ReleaseRing(enemyUid: number?, index: number, unitId: number)
	if enemyUid == nil then
		return
	end
	const ring = self.Rings[enemyUid]
	if ring == nil then
		return
	end
	if ring[index] == unitId then
		ring[index] = nil
	end
	if next(ring) == nil then
		self.Rings[enemyUid] = nil
	end
end

function CombatService:AssignUnit(engagement: Engagement, unit: PetUnit, at: number)
	if unit.Target ~= engagement.EnemyUid then
		self:ReleaseRing(unit.Target, unit.Ring, unit.Id)
	end
	const ring = self:ClaimRing(engagement.EnemyUid, unit.Id)
	unit.ArriveAt = at + Content.Tuning.ArriveSeconds
	unit.NextHitAt = unit.ArriveAt + unit.AttackInterval * self.Random:NextNumber()
	Engagement.AddUnit(engagement, unit.Id)
	self.Dependencies.PetService:SetTarget(unit, engagement.EnemyUid, ring)
end

function CombatService:ReleaseUnit(unit: PetUnit)
	self:ReleaseRing(unit.Target, unit.Ring, unit.Id)
	unit.ArriveAt = 0
	unit.NextHitAt = 0
	self.Dependencies.PetService:SetTarget(unit, nil, 0)
end

function CombatService:Engage(player: Player, enemyUid: number): boolean
	const pets = self.Dependencies.PetService
	const units = pets:Units(player)
	if #units == 0 then
		return false
	end

	const previous = self.Engagements[player]
	if previous ~= nil then
		Engagement.Close(previous)
	end

	const engagement = Engagement.new(player, enemyUid)
	self.Engagements[player] = engagement

	const at = now()
	for _, unit in units do
		self:AssignUnit(engagement, unit, at)
	end
	return true
end

function CombatService:Disengage(player: Player)
	const engagement = self.Engagements[player]
	if engagement == nil then
		return
	end
	self.Engagements[player] = nil
	Engagement.Close(engagement)

	const pets = self.Dependencies.PetService
	for _, unitId in engagement.Units do
		const unit = pets:Unit(unitId)
		if unit ~= nil and unit.Target == engagement.EnemyUid then
			self:ReleaseUnit(unit)
		end
	end
end

function CombatService:CloseEnemy(enemyUid: number)
	const owners: { Player } = {}
	for player, engagement in self.Engagements do
		if engagement.EnemyUid == enemyUid then
			table.insert(owners, player)
		end
	end
	for _, player in owners do
		self:Disengage(player)
	end
	self.Rings[enemyUid] = nil
end

function CombatService:HandleAttack(player: Player, data: unknown): boolean
	if not self:PassRateLimit(player) then
		return false
	end
	if typeof(data) ~= "table" then
		return false
	end
	const enemyUid = (data :: { [string]: unknown }).Enemy
	if typeof(enemyUid) ~= "number" then
		return false
	end

	const enemy = self.Dependencies.EnemyService:Get(enemyUid)
	if enemy == nil or not enemy.Alive then
		return false
	end

	const root = aliveRoot(player)
	if root == nil then
		return false
	end
	if (root.Position - enemy.Position).Magnitude > Content.Tuning.CommandRange then
		return false
	end

	const current = self.Engagements[player]
	if current ~= nil and current.EnemyUid == enemyUid then
		self:Disengage(player)
		return true
	end

	return self:Engage(player, enemyUid)
end

function CombatService:HandleRecall(player: Player): boolean
	if not self:PassRateLimit(player) then
		return false
	end
	if self.Engagements[player] == nil then
		return false
	end
	self:Disengage(player)
	return true
end

function CombatService:IsAutoSkill(player: Player): boolean
	const profile = self.Dependencies.ProfileService:Get(player)
	return profile ~= nil and profile.AutoSkill()
end

function CombatService:HandleUseSkill(player: Player, data: unknown): boolean
	if not self:PassRateLimit(player) then
		return false
	end
	if typeof(data) ~= "table" then
		return false
	end
	const unitId = (data :: { [string]: unknown }).Unit
	if typeof(unitId) ~= "number" then
		return false
	end

	const unit = self.Dependencies.PetService:Unit(unitId)
	if unit == nil or unit.Owner ~= player then
		return false
	end
	if self.Dependencies.ProfileService:Get(player) == nil or self:IsAutoSkill(player) then
		return false
	end

	const at = now()
	if at < unit.SkillReadyAt then
		return false
	end

	const engagement = self.Engagements[player]
	if engagement == nil then
		return false
	end
	const enemy = self.Dependencies.EnemyService:Get(engagement.EnemyUid)
	if enemy == nil or not enemy.Alive then
		return false
	end
	if not Choreography.IsOnStage(engagement, unit, at) then
		return false
	end

	return SkillQueue.Push(engagement.Queue, unit.Id)
end

function CombatService:HandleSetAutoSkill(player: Player, data: unknown): boolean
	if not self:PassRateLimit(player) then
		return false
	end
	if typeof(data) ~= "table" then
		return false
	end
	const enabled = (data :: { [string]: unknown }).Enabled
	if typeof(enabled) ~= "boolean" then
		return false
	end
	const profile = self.Dependencies.ProfileService:Get(player)
	if profile == nil then
		return false
	end
	profile.AutoSkill(enabled)
	return true
end

function CombatService:IsCurrent(engagement: Engagement): boolean
	return self.Engagements[engagement.Owner] == engagement
end

function CombatService:SendBeat(player: Player, unitId: number, move: Move)
	const net = self.Dependencies.NetService
	if not net:IsRunning() or player.Parent ~= Players or not net:IsReady(player) then
		return
	end
	self.Libs.Net.Beat:fireClient(player, { Unit = unitId, Move = move })
end

function CombatService:BeatEmitter(player: Player): (unitId: number, move: Move) -> ()
	return function(unitId: number, move: Move)
		self:SendBeat(player, unitId, move)
	end
end

function CombatService:EnqueueAutoSkills(engagement: Engagement, at: number)
	if not self:IsAutoSkill(engagement.Owner) then
		return
	end
	const pets = self.Dependencies.PetService
	const ready: { PetUnit } = {}
	for _, unitId in engagement.Units do
		const unit = pets:Unit(unitId)
		if unit == nil or at < unit.SkillReadyAt or SkillQueue.Contains(engagement.Queue, unitId) then
			continue
		end
		if Choreography.IsOnStage(engagement, unit, at) then
			table.insert(ready, unit)
		end
	end
	table.sort(ready, function(left: PetUnit, right: PetUnit)
		return left.Slot < right.Slot
	end)
	for _, unit in ready do
		SkillQueue.Push(engagement.Queue, unit.Id)
	end
end

function CombatService:Cast(engagement: Engagement, unit: PetUnit, at: number)
	const ability = Content.Ability(unit.AbilityId)
	Choreography.CastSkill(engagement, unit, at, self:BeatEmitter(engagement.Owner))
	engagement.LastCastAt = at

	const hits = math.max(1, ability.Hits or 1)
	const spacing = ability.HitSpacing or 0
	const total = math.floor(ability.Power * unit.Damage)
	const share = math.floor(total / hits)
	for index = 1, hits do
		const amount = if index == hits then total - share * (hits - 1) else share
		if amount > 0 then
			Engagement.SchedulePendingHit(engagement, {
				At = at + ability.HitDelay + spacing * (index - 1),
				Unit = unit.Id,
				Amount = amount,
				Kind = "Skill",
			})
		end
	end

	self.Dependencies.PetService:SetSkillReady(unit, at + ability.Cooldown)
end

function CombatService:CastNext(engagement: Engagement, at: number)
	if SkillQueue.IsEmpty(engagement.Queue) or at < engagement.LastCastAt + Content.Tuning.SkillGap then
		return
	end
	const pets = self.Dependencies.PetService
	while true do
		const unitId = SkillQueue.Pop(engagement.Queue)
		if unitId == nil then
			return
		end
		const unit = pets:Unit(unitId)
		if
			unit ~= nil
			and unit.Owner == engagement.Owner
			and at >= unit.SkillReadyAt
			and Choreography.IsOnStage(engagement, unit, at)
		then
			self:Cast(engagement, unit, at)
			return
		end
	end
end

function CombatService:ApplyPendingHits(engagement: Engagement, at: number)
	const enemies = self.Dependencies.EnemyService
	const owner = engagement.Owner
	const enemyUid = engagement.EnemyUid
	for _, hit in Engagement.TakeDueHits(engagement, at) do
		const applied = enemies:ApplyDamage(enemyUid, hit.Amount, owner)
		if applied > 0 then
			self:QueueHit(owner, { Enemy = enemyUid, Unit = hit.Unit, Amount = applied, Kind = hit.Kind })
		end
		if not self:IsCurrent(engagement) then
			return
		end
	end
end

function CombatService:Choreograph(engagement: Engagement, at: number)
	const pets = self.Dependencies.PetService
	Choreography.Step(engagement, at, function(unitId: number)
		return pets:Unit(unitId)
	end, self:BeatEmitter(engagement.Owner))
end

function CombatService:Advance(engagement: Engagement, at: number)
	self:StrikeBasic(engagement, at)
	if not self:IsCurrent(engagement) then
		return
	end
	self:EnqueueAutoSkills(engagement, at)
	self:CastNext(engagement, at)
	self:ApplyPendingHits(engagement, at)
	if not self:IsCurrent(engagement) then
		return
	end
	self:Choreograph(engagement, at)
end

function CombatService:QueueHit(player: Player, hit: Hit)
	local pending = self.OutgoingHits[player]
	if pending == nil then
		pending = {}
		self.OutgoingHits[player] = pending
	end
	table.insert(pending, hit)
end

function CombatService:StrikeBasic(engagement: Engagement, at: number)
	const pets = self.Dependencies.PetService
	const enemies = self.Dependencies.EnemyService
	const owner = engagement.Owner
	const enemyUid = engagement.EnemyUid

	for _, unitId in table.clone(engagement.Units) do
		if self.Engagements[owner] ~= engagement then
			return
		end
		const unit = pets:Unit(unitId)
		if unit == nil or unit.Target ~= enemyUid or at < unit.ArriveAt or unit.AttackInterval <= 0 then
			continue
		end
		while at >= unit.NextHitAt do
			unit.NextHitAt += unit.AttackInterval
			const applied = enemies:ApplyDamage(enemyUid, unit.Damage, owner)
			if applied > 0 then
				self:QueueHit(owner, { Enemy = enemyUid, Unit = unit.Id, Amount = applied, Kind = "Basic" })
			end
			if self.Engagements[owner] ~= engagement then
				return
			end
		end
	end
end

function CombatService:FlushHits()
	const net = self.Dependencies.NetService
	const running = net:IsRunning()

	for player, pending in self.OutgoingHits do
		if not running or player.Parent ~= Players or not net:IsReady(player) then
			self.OutgoingHits[player] = nil
			continue
		end
		if #pending <= MAX_HITS_PER_PACKET then
			self.OutgoingHits[player] = nil
			self.Libs.Net.Hits:fireClient(player, pending)
			continue
		end
		const batch = table.move(pending, 1, MAX_HITS_PER_PACKET, 1, {})
		self.OutgoingHits[player] = table.move(pending, MAX_HITS_PER_PACKET + 1, #pending, 1, {})
		self.Libs.Net.Hits:fireClient(player, batch)
	end
end

function CombatService:Step()
	const at = now()
	const enemies = self.Dependencies.EnemyService
	const stale: { Player } = {}

	for player, engagement in table.clone(self.Engagements) do
		if self.Engagements[player] ~= engagement then
			continue
		end
		const enemy = enemies:Get(engagement.EnemyUid)
		if enemy == nil or not enemy.Alive then
			table.insert(stale, player)
			continue
		end
		self:Advance(engagement, at)
	end

	for _, player in stale do
		self:Disengage(player)
	end

	self:FlushHits()
end

function CombatService:CheckLeash()
	const enemies = self.Dependencies.EnemyService
	const leashed: { Player } = {}

	for player, engagement in self.Engagements do
		const root = aliveRoot(player)
		const position = enemies:Position(engagement.EnemyUid)
		if root == nil or position == nil then
			continue
		end
		if (root.Position - position).Magnitude > Content.Tuning.LeashRange then
			table.insert(leashed, player)
		end
	end

	for _, player in leashed do
		self:Disengage(player)
	end
end

function CombatService:OnUnitAdded(unit: PetUnit)
	const engagement = self.Engagements[unit.Owner]
	if engagement == nil then
		return
	end
	const enemy = self.Dependencies.EnemyService:Get(engagement.EnemyUid)
	if enemy == nil or not enemy.Alive then
		return
	end
	self:AssignUnit(engagement, unit, now())
end

function CombatService:OnUnitRemoved(unit: PetUnit)
	self:ReleaseRing(unit.Target, unit.Ring, unit.Id)
	const engagement = self.Engagements[unit.Owner]
	if engagement == nil then
		return
	end
	Engagement.RemoveUnit(engagement, unit.Id)
	if Engagement.IsEmpty(engagement) then
		self.Engagements[unit.Owner] = nil
		Engagement.Close(engagement)
	end
end

function CombatService:Forget(player: Player)
	self:Disengage(player)
	self.LastCommandAt[player] = nil
	self.OutgoingHits[player] = nil
end

CombatService:OnInit(function(self)
	self:Setup()

	const net = self.Libs.Net
	net.Attack:onServer(function(data, player)
		self:HandleAttack(player, data)
	end)
	net.Recall:onServer(function(_, player)
		self:HandleRecall(player)
	end)
	net.UseSkill:onServer(function(data, player)
		self:HandleUseSkill(player, data)
	end)
	net.SetAutoSkill:onServer(function(data, player)
		self:HandleSetAutoSkill(player, data)
	end)

	self.Dependencies.EnemyService.Died:Connect(function(uid)
		self:CloseEnemy(uid)
	end)

	const pets = self.Dependencies.PetService
	pets.UnitAdded:Connect(function(unit)
		self:OnUnitAdded(unit)
	end)
	pets.UnitRemoved:Connect(function(unit)
		self:OnUnitRemoved(unit)
	end)

	self.Dependencies.PlayerService.PlayerRemoving:Connect(function(player)
		self:Forget(player)
	end)
end)

CombatService:OnTick(function(self)
	self:Step()
end, Content.Tuning.CombatTickRate)

CombatService:OnTick(function(self)
	self:CheckLeash()
end, LEASH_CHECK_RATE)

return CombatService
