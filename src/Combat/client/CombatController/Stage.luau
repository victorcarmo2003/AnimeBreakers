local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Content = require(ReplicatedStorage.shared.Content)
local ModuxTypes = StarterPlayer.StarterPlayerScripts.client.ModuxTypes
local PetTypes = require(ModuxTypes.PetController)
local EnemyTypes = require(ModuxTypes.EnemyController)
local EffectTypes = require(ModuxTypes.EffectController)

type Move = Content.Move
type TrackKey = Content.TrackKey
type PetActor = PetTypes.PetActor
type PetUnitState = PetTypes.PetUnitState
type EnemyActor = EnemyTypes.EnemyActor

export type Controllers = {
	Pets: PetTypes.Public,
	Enemies: EnemyTypes.Public,
	Effects: EffectTypes.Public,
}

export type Performance = {
	UnitId: number,
	EnemyUid: number,
	Move: Move,
	EndsAt: number,
	ImpactAt: number?,
	ImpactEffect: string?,
	ImpactReaction: TrackKey?,
}

type Fields = {
	Controllers: Controllers,
	Current: Performance?,
}

const Stage = {}
Stage.__index = Stage

export type Stage = setmetatable<Fields, typeof(Stage)>

const STALE_GRACE = 1.5
const MIN_DIRECTION = 1e-3
const DEFAULT_SKILL_REACTION: TrackKey = "HitHeavy"

local function flat(vector: Vector3): Vector3
	return Vector3.new(vector.X, 0, vector.Z)
end

function Stage.new(controllers: Controllers): Stage
	const fields: Fields = {
		Controllers = controllers,
		Current = nil,
	}
	return setmetatable(fields, Stage)
end

function Stage.Owns(self: Stage, unitId: number): boolean
	const current = self.Current
	return current ~= nil and current.UnitId == unitId
end

function Stage.Performer(self: Stage, unitId: number): (PetUnitState?, PetActor?)
	const pets = self.Controllers.Pets
	const unit = pets:Unit(unitId)
	const actor = pets.Actors[unitId]
	if unit == nil or actor == nil or not actor.Placed or not pets:IsMine(unit) then
		return nil, nil
	end
	return unit, actor
end

function Stage.LiveEnemy(self: Stage, enemyUid: number?): EnemyActor?
	if enemyUid == nil then
		return nil
	end
	const enemy = self.Controllers.Enemies.Actors[enemyUid]
	if enemy == nil or not enemy.Alive() or enemy.Model.Parent == nil then
		return nil
	end
	return enemy
end

function Stage.StrikeCFrame(_self: Stage, actor: PetActor, enemy: EnemyActor): CFrame
	const center = enemy.Pivot.Position
	const height = actor.Root.Position.Y
	local direction = flat(actor.Root.Position - center)
	if direction.Magnitude < MIN_DIRECTION then
		direction = flat(enemy.Pivot.LookVector)
	end
	if direction.Magnitude < MIN_DIRECTION then
		direction = Vector3.zAxis
	end
	const distance = enemy.Character.Radius + actor.Character.Reach
	const level = Vector3.new(center.X, height, center.Z)
	return CFrame.lookAt(level + direction.Unit * distance, level)
end

function Stage.Teleport(self: Stage, actor: PetActor, goal: CFrame)
	const effects = actor.Character.Effects
	const effectController = self.Controllers.Effects
	effectController:Play(effects.TeleportOut or Content.Tuning.DefaultTeleportOut, actor.Root.CFrame)
	actor.Root.CFrame = goal
	effectController:Play(effects.TeleportIn or Content.Tuning.DefaultTeleportIn, goal)
end

function Stage.FaceEnemy(_self: Stage, enemy: EnemyActor, actor: PetActor)
	const center = enemy.Pivot.Position
	const toward = flat(actor.Root.Position - center)
	if toward.Magnitude < MIN_DIRECTION then
		return
	end
	enemy.Model:PivotTo(CFrame.lookAt(center, center + toward))
end

function Stage.RestoreEnemy(_self: Stage, enemy: EnemyActor)
	if not enemy.Alive() or enemy.Model.Parent == nil then
		return
	end
	enemy.Animator:StopGroup("Reaction")
	enemy.Animator:Play("Idle")
	enemy.Model:PivotTo(enemy.Pivot)
end

function Stage.React(_self: Stage, enemy: EnemyActor, reaction: TrackKey?, seek: number)
	enemy.Animator:Play("Idle")
	if reaction == nil then
		enemy.Animator:StopGroup("Reaction")
		return
	end
	enemy.Animator:Play(reaction, { Seek = seek })
end

function Stage.Release(self: Stage, returnToRing: boolean)
	const current = self.Current
	if current == nil then
		return
	end
	self.Current = nil
	const pets = self.Controllers.Pets
	const actor = pets.Actors[current.UnitId]
	if actor then
		actor.Animator:StopGroup("Combat")
		if returnToRing and actor.Placed then
			const ring = pets:RingCFrame(current.UnitId)
			if ring then
				self:Teleport(actor, ring)
			end
		end
	end
	const enemy = self.Controllers.Enemies.Actors[current.EnemyUid]
	if enemy == nil then
		return
	end
	if returnToRing then
		if enemy.Alive() and enemy.Model.Parent ~= nil then
			enemy.Animator:StopGroup("Reaction")
			enemy.Animator:Play("Idle")
		end
	else
		self:RestoreEnemy(enemy)
	end
end

function Stage.Expire(self: Stage, unitId: number, move: Move)
	if self.Current == nil then
		return
	end
	if not self:Owns(unitId) or move == "BackOff" then
		self:Release(true)
	end
end

function Stage.Play(self: Stage, unitId: number, move: Move, late: number, now: number)
	const unit, actor = self:Performer(unitId)
	if unit == nil or actor == nil then
		return
	end
	const duration = actor.Animator:Duration(move)
	if late >= duration then
		self:Expire(unitId, move)
		return
	end
	const enemy = self:LiveEnemy(unit.Target)
	if enemy == nil then
		self:Release(false)
		return
	end

	const owned = self:Owns(unitId)
	if not owned then
		self:Release(true)
	end
	if move == "Enter" or move == "Skill" or not owned then
		self:Teleport(actor, self:StrikeCFrame(actor, enemy))
	end
	self:FaceEnemy(enemy, actor)

	actor.Animator:StopGroup("Support")
	actor.Animator:Play("Idle")
	actor.Animator:Play(move, { Seek = late })

	const startedAt = now - late
	const performance: Performance = {
		UnitId = unitId,
		EnemyUid = enemy.Uid,
		Move = move,
		EndsAt = startedAt + duration,
		ImpactAt = nil,
		ImpactEffect = nil,
		ImpactReaction = nil,
	}
	self.Current = performance

	const reactions = enemy.Animator.Set.Reactions
	const reaction = if reactions then reactions[move] else nil
	if move == "Skill" then
		self:CastSkill(actor, performance, late, startedAt, reaction or DEFAULT_SKILL_REACTION)
		return
	end
	self:React(enemy, reaction, late)
end

function Stage.CastSkill(
	self: Stage,
	actor: PetActor,
	performance: Performance,
	late: number,
	startedAt: number,
	reaction: TrackKey
)
	const pet = Content.Pets[actor.PetId]
	const ability = if pet then Content.Abilities[pet.Ability] else nil
	if ability == nil then
		return
	end
	const castEffect = ability.CastEffect
	if castEffect and late < ability.HitDelay then
		self.Controllers.Effects:Play(castEffect, actor.Model)
	end
	performance.ImpactAt = startedAt + ability.HitDelay
	performance.ImpactEffect = ability.Effect
	performance.ImpactReaction = reaction
end

function Stage.Impact(self: Stage, performance: Performance, enemy: EnemyActor, now: number)
	const impactAt = performance.ImpactAt
	if impactAt == nil then
		return
	end
	performance.ImpactAt = nil
	const effect = performance.ImpactEffect
	if effect then
		self.Controllers.Effects:Play(effect, enemy.Model)
	end
	self:React(enemy, performance.ImpactReaction, math.max(now - impactAt, 0))
end

function Stage.Step(self: Stage, now: number)
	const current = self.Current
	if current == nil then
		return
	end
	const unit, actor = self:Performer(current.UnitId)
	if unit == nil or actor == nil then
		self:Release(false)
		return
	end
	const enemy = self:LiveEnemy(current.EnemyUid)
	if enemy == nil or unit.Target ~= current.EnemyUid then
		self:Release(false)
		return
	end
	const impactAt = current.ImpactAt
	if impactAt ~= nil and now >= impactAt then
		self:Impact(current, enemy, now)
	end
	if now < current.EndsAt then
		return
	end
	if current.Move == "BackOff" or now >= current.EndsAt + STALE_GRACE then
		self:Release(true)
	end
end

function Stage.Clear(self: Stage)
	self:Release(false)
end

return Stage
