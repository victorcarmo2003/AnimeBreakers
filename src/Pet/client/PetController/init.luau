local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)
local RigAnimator = require(ReplicatedStorage.shared.Rig.RigAnimator)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)
local Formation = require(script.Formation)

export type PetRecord = {
	Owner: number,
	Slot: number,
	Pet: string,
	Target: number?,
	Ring: number,
	SkillReadyAt: number,
}

export type PetUnitState = {
	Id: number,
	Owner: number,
	Slot: number,
	Pet: string,
	Target: number?,
	Ring: number,
	SkillReadyAt: number,
	ArriveAt: number,
}

export type Stage = {
	Owns: (self: Stage, unitId: number) -> boolean,
}

export type PetMode = "Follow" | "Assist" | "Frozen"

export type PetMotion = "Idle" | "Run" | "Assist"

export type PetActor = {
	Id: number,
	PetId: string,
	Character: Content.CharacterDef,
	Model: Model,
	Root: BasePart,
	Animator: RigAnimator.RigAnimator,
	RootHeight: number,
	Current: CFrame,
	Placed: boolean,
	Mode: PetMode?,
	Motion: PetMotion?,
	GroundY: number?,
	GroundSampledAt: Vector3?,
	GroundTimer: number,
	HeldByStage: boolean,
}

const PetController = Modux.Controller(
	"PetController",
	{ Require = { "EnemyController", "EffectController" }, Priority = 700 }
)

const GROUND_INTERVAL = 0.1
const GROUND_RESAMPLE_DISTANCE = 6
const GROUND_PROBE_UP = 10
const GROUND_PROBE_DOWN = 60
const MAX_FRAME_DELTA = 0.1

const NO_STAGE: Stage = {
	Owns = function(_stage: Stage, _unitId: number): boolean
		return false
	end,
}

local function visualsFolder(name: string): Folder
	local visuals = Workspace:FindFirstChild("Visuals")
	if not visuals then
		const created = Instance.new("Folder")
		created.Name = "Visuals"
		created.Parent = Workspace
		visuals = created
	end
	const existing = (visuals :: Instance):FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end
	const folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = visuals
	return folder
end

local function characterTemplate(character: Content.CharacterDef): Model?
	const assets = ReplicatedStorage:FindFirstChild("Assets")
	const characters = assets and assets:FindFirstChild("Characters")
	const template = characters and characters:FindFirstChild(character.Model)
	if template and template:IsA("Model") then
		return template
	end
	return nil
end

local function rootOf(model: Model): BasePart?
	const primary = model.PrimaryPart
	if primary then
		return primary
	end
	const humanoidRoot = model:FindFirstChild("HumanoidRootPart")
	if humanoidRoot and humanoidRoot:IsA("BasePart") then
		model.PrimaryPart = humanoidRoot
		return humanoidRoot
	end
	return nil
end

local function silenceParts(model: Model, root: BasePart)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
		end
	end
	root.Anchored = true
end

local function rootHeightOf(model: Model, root: BasePart): number
	const box, size = model:GetBoundingBox()
	return root.Position.Y - (box.Position.Y - size.Y / 2)
end

local function ownerRoot(userId: number): BasePart?
	const owner = Players:GetPlayerByUserId(userId)
	const character = owner and owner.Character
	if character == nil then
		return nil
	end
	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= 0 then
		return nil
	end
	const root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

function PetController:Setup()
	self.Units = {} :: { [number]: PetUnitState }
	self.Actors = {} :: { [number]: PetActor }
	self.MyUnits = Vide.source({}) :: Vide.Source<{ PetUnitState }>
	self.Stage = NO_STAGE :: Stage
	self.Folder = nil :: Folder?
	self.GroundParams = RaycastParams.new() :: RaycastParams
	self.GroundFilterStale = true :: boolean
	self.LastStepAt = os.clock() :: number
	self.MoveParts = {} :: { BasePart }
	self.MoveCFrames = {} :: { CFrame }
end

function PetController:PetsFolder(): Folder
	const current = self.Folder
	if current and current.Parent then
		return current
	end
	const folder = visualsFolder("Pets")
	self.Folder = folder
	return folder
end

function PetController:UseStage(stage: Stage?)
	self.Stage = stage or NO_STAGE
end

function PetController:IsMine(unit: PetUnitState): boolean
	const localPlayer = Players.LocalPlayer
	return localPlayer ~= nil and unit.Owner == localPlayer.UserId
end

function PetController:Unit(unitId: number): PetUnitState?
	return self.Units[unitId]
end

function PetController:Rig(unitId: number): RigAnimator.RigAnimator?
	const actor = self.Actors[unitId]
	return if actor then actor.Animator else nil
end

function PetController:Model(unitId: number): Model?
	const actor = self.Actors[unitId]
	return if actor then actor.Model else nil
end

function PetController:PublishMyUnits()
	const mine: { PetUnitState } = {}
	for _, unit in self.Units do
		if self:IsMine(unit) then
			table.insert(mine, unit)
		end
	end
	table.sort(mine, function(a: PetUnitState, b: PetUnitState): boolean
		if a.Slot ~= b.Slot then
			return a.Slot < b.Slot
		end
		return a.Id < b.Id
	end)
	self.MyUnits(mine)
end

function PetController:RingCounts(): { [number]: number }
	const counts: { [number]: number } = {}
	for _, unit in self.Units do
		const target = unit.Target
		if target ~= nil then
			counts[target] = math.max((counts[target] or 0) + 1, unit.Ring + 1)
		end
	end
	return counts
end

function PetController:RingGoal(unit: PetUnitState, counts: { [number]: number }): CFrame?
	const target = unit.Target
	if target == nil then
		return nil
	end
	const enemyActors = self.Dependencies.EnemyController.Actors
	const enemy = enemyActors[target]
	if enemy == nil or not enemy.Alive() then
		return nil
	end
	const radius = enemy.Character.Radius + Content.Tuning.AssistDistance
	return Formation.RingCFrame(enemy.Pivot, unit.Ring, counts[target] or 1, radius)
end

function PetController:FollowGoal(unit: PetUnitState): CFrame?
	const root = ownerRoot(unit.Owner)
	if root == nil then
		return nil
	end
	return Formation.FollowCFrame(root.CFrame, unit.Slot)
end

function PetController:Goal(unit: PetUnitState, counts: { [number]: number }): (CFrame?, PetMode)
	const ring = self:RingGoal(unit, counts)
	if ring then
		return ring, "Assist"
	end
	const follow = self:FollowGoal(unit)
	if follow then
		return follow, "Follow"
	end
	return nil, "Frozen"
end

function PetController:RingCFrame(unitId: number): CFrame?
	const unit = self.Units[unitId]
	if unit == nil then
		return nil
	end
	const goal = self:RingGoal(unit, self:RingCounts())
	if goal == nil then
		return nil
	end
	const actor = self.Actors[unitId]
	if actor and actor.Mode == "Assist" and actor.GroundY then
		return Formation.AtHeight(goal, actor.GroundY + actor.RootHeight)
	end
	return goal
end

function PetController:RefreshGroundFilter()
	const pets = self:PetsFolder()
	const excluded: { Instance } = { pets.Parent or pets }
	for _, player in Players:GetPlayers() do
		const character = player.Character
		if character then
			table.insert(excluded, character)
		end
	end
	self.GroundParams.FilterType = Enum.RaycastFilterType.Exclude
	self.GroundParams.FilterDescendantsInstances = excluded
	self.GroundParams.RespectCanCollide = true
	self.GroundFilterStale = false
end

function PetController:SampleGround(position: Vector3): number?
	if self.GroundFilterStale then
		self:RefreshGroundFilter()
	end
	const origin = position + Vector3.new(0, GROUND_PROBE_UP, 0)
	const hit = Workspace:Raycast(origin, Vector3.new(0, -(GROUND_PROBE_UP + GROUND_PROBE_DOWN), 0), self.GroundParams)
	return if hit then hit.Position.Y else nil
end

function PetController:GroundedGoal(actor: PetActor, goal: CFrame, dt: number): CFrame
	actor.GroundTimer -= dt
	const sampledAt = actor.GroundSampledAt
	const drifted = sampledAt == nil
		or Vector3.new(goal.X - sampledAt.X, 0, goal.Z - sampledAt.Z).Magnitude > GROUND_RESAMPLE_DISTANCE
	if actor.GroundTimer <= 0 or drifted then
		actor.GroundTimer = GROUND_INTERVAL
		actor.GroundSampledAt = goal.Position
		actor.GroundY = self:SampleGround(goal.Position)
	end
	const groundY = actor.GroundY
	if groundY == nil then
		return goal
	end
	return Formation.AtHeight(goal, groundY + actor.RootHeight)
end

function PetController:SetMotion(actor: PetActor, motion: PetMotion)
	if actor.Motion == motion then
		return
	end
	actor.Motion = motion
	if motion == "Assist" then
		actor.Animator:Play("Idle")
		actor.Animator:Play("Assist")
		return
	end
	actor.Animator:StopGroup("Support")
	actor.Animator:Play(motion)
end

function PetController:Teleport(actor: PetActor, unit: PetUnitState, goal: CFrame)
	const from = actor.Current
	actor.Current = goal
	if not self:IsMine(unit) then
		return
	end
	const effects = actor.Character.Effects
	const effectController = self.Dependencies.EffectController
	effectController:Play(effects.TeleportOut or Content.Tuning.DefaultTeleportOut, from)
	effectController:Play(effects.TeleportIn or Content.Tuning.DefaultTeleportIn, goal)
end

function PetController:StepActor(actor: PetActor, unit: PetUnitState, counts: { [number]: number }, dt: number): boolean
	if self.Stage:Owns(actor.Id) then
		actor.HeldByStage = true
		return false
	end
	if actor.HeldByStage then
		actor.HeldByStage = false
		actor.Current = actor.Root.CFrame
		actor.Motion = nil
	end

	const rawGoal, mode = self:Goal(unit, counts)
	if mode ~= actor.Mode then
		actor.Mode = mode
		actor.GroundSampledAt = nil
	end
	if rawGoal == nil then
		if actor.Placed then
			self:SetMotion(actor, "Idle")
		end
		return false
	end

	const goal = self:GroundedGoal(actor, rawGoal, dt)
	if not actor.Placed then
		actor.Placed = true
		actor.Current = goal
		actor.Model.Parent = self:PetsFolder()
	elseif (goal.Position - actor.Current.Position).Magnitude > Content.Tuning.TeleportThreshold then
		self:Teleport(actor, unit, goal)
	else
		actor.Current = Formation.Approach(actor.Current, goal, dt, Content.Tuning.PetFollowSpeed)
	end

	const remaining = (goal.Position - actor.Current.Position).Magnitude
	if remaining > Formation.RunDistance then
		self:SetMotion(actor, "Run")
	elseif mode == "Assist" then
		self:SetMotion(actor, "Assist")
	else
		self:SetMotion(actor, "Idle")
	end
	return true
end

function PetController:Step()
	const now = os.clock()
	const dt = math.min(now - self.LastStepAt, MAX_FRAME_DELTA)
	self.LastStepAt = now
	if next(self.Actors) == nil then
		return
	end

	self.GroundFilterStale = true
	const counts = self:RingCounts()
	const parts = self.MoveParts
	const cframes = self.MoveCFrames
	table.clear(parts)
	table.clear(cframes)

	for id, actor in self.Actors do
		const unit = self.Units[id]
		if unit == nil then
			continue
		end
		if self:StepActor(actor, unit, counts, dt) then
			table.insert(parts, actor.Root)
			table.insert(cframes, actor.Current)
		end
	end

	if #parts > 0 then
		Workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

function PetController:CreateActor(unit: PetUnitState): PetActor?
	const def = Content.Pets[unit.Pet]
	if def == nil then
		warn(`[PetController] unknown pet "{unit.Pet}" for unit {unit.Id}`)
		return nil
	end
	const character = Content.Character(def.Character)
	const template = characterTemplate(character)
	if template == nil then
		warn(`[PetController] missing model ReplicatedStorage.Assets.Characters.{character.Model}`)
		return nil
	end

	const model = template:Clone()
	model.Name = `{def.Id}#{unit.Id}`
	if character.Scale ~= 1 then
		model:ScaleTo(character.Scale)
	end
	const root = rootOf(model)
	if root == nil then
		warn(`[PetController] model "{character.Model}" has no PrimaryPart or HumanoidRootPart`)
		model:Destroy()
		return nil
	end
	silenceParts(model, root)

	return {
		Id = unit.Id,
		PetId = def.Id,
		Character = character,
		Model = model,
		Root = root,
		Animator = RigAnimator.new(model, Content.AnimationSet(character.AnimationSet)),
		RootHeight = rootHeightOf(model, root),
		Current = root.CFrame,
		Placed = false,
		Mode = nil,
		Motion = nil,
		GroundY = nil,
		GroundSampledAt = nil,
		GroundTimer = math.random() * GROUND_INTERVAL,
		HeldByStage = false,
	}
end

function PetController:DestroyActor(unitId: number)
	const actor = self.Actors[unitId]
	if actor == nil then
		return
	end
	self.Actors[unitId] = nil
	actor.Animator:Destroy()
	actor.Model:Destroy()
end

function PetController:StateFrom(unitId: number, record: PetRecord, previous: PetUnitState?): PetUnitState
	local arriveAt = 0
	const target = record.Target
	if target ~= nil then
		if previous and previous.Target == target then
			arriveAt = previous.ArriveAt
		else
			arriveAt = Workspace:GetServerTimeNow() + Content.Tuning.ArriveSeconds
		end
	end
	return {
		Id = unitId,
		Owner = record.Owner,
		Slot = record.Slot,
		Pet = record.Pet,
		Target = target,
		Ring = record.Ring,
		SkillReadyAt = record.SkillReadyAt,
		ArriveAt = arriveAt,
	}
end

function PetController:OnAdded(unitId: number, record: PetRecord)
	if self.Units[unitId] then
		self:OnRemoved(unitId)
	end
	const unit = self:StateFrom(unitId, record, nil)
	self.Units[unitId] = unit
	const actor = self:CreateActor(unit)
	if actor then
		self.Actors[unitId] = actor
	end
	if self:IsMine(unit) then
		self:PublishMyUnits()
	end
end

function PetController:OnChanged(unitId: number, record: PetRecord)
	const previous = self.Units[unitId]
	if previous == nil then
		self:OnAdded(unitId, record)
		return
	end
	const unit = self:StateFrom(unitId, record, previous)
	self.Units[unitId] = unit

	if unit.Pet ~= previous.Pet then
		self:DestroyActor(unitId)
		const actor = self:CreateActor(unit)
		if actor then
			self.Actors[unitId] = actor
		end
	end

	if self:IsMine(unit) or self:IsMine(previous) then
		self:PublishMyUnits()
	end
end

function PetController:OnRemoved(unitId: number)
	const unit = self.Units[unitId]
	self.Units[unitId] = nil
	self:DestroyActor(unitId)
	if unit and self:IsMine(unit) then
		self:PublishMyUnits()
	end
end

function PetController:PreloadAssets()
	const assets: { Instance } = {}
	const seenModels: { [string]: boolean } = {}
	const seenSets: { [string]: boolean } = {}
	const seenAnimations: { [string]: boolean } = {}

	for _, def in Content.Pets do
		const character = Content.Characters[def.Character]
		if character == nil then
			continue
		end
		if not seenModels[character.Model] then
			seenModels[character.Model] = true
			const template = characterTemplate(character)
			if template then
				table.insert(assets, template)
			end
		end
		if not seenSets[character.AnimationSet] then
			seenSets[character.AnimationSet] = true
			for _, track in Content.AnimationSet(character.AnimationSet).Tracks do
				if not seenAnimations[track.Id] then
					seenAnimations[track.Id] = true
					const animation = Instance.new("Animation")
					animation.AnimationId = track.Id
					table.insert(assets, animation)
				end
			end
		end
	end

	if #assets > 0 then
		ContentProvider:PreloadAsync(assets)
	end
end

PetController:OnInit(function(self)
	self:Setup()

	self.Libs.Net.Pets:onAdded(function(unitId, record)
		self:OnAdded(unitId, record)
	end)

	self.Libs.Net.Pets:onChanged(function(unitId, record)
		self:OnChanged(unitId, record)
	end)

	self.Libs.Net.Pets:onRemoved(function(unitId)
		self:OnRemoved(unitId)
	end)
end)

PetController:OnStart(function(self)
	self:PetsFolder()
	self.LastStepAt = os.clock()
	task.spawn(function()
		self:PreloadAssets()
	end)
end)

PetController:OnTick(function(self)
	self:Step()
end, 60)

return PetController
