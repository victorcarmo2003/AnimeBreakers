local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)
local RigAnimator = require(ReplicatedStorage.shared.Rig.RigAnimator)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)
local HealthBar = require(script.Parent.HealthBar)

export type EnemyRecord = {
	Enemy: string,
	Position: Vector3,
	Yaw: number,
	Health: number,
	MaxHealth: number,
	Alive: boolean,
	Life: number,
}

export type EnemyActor = {
	Uid: number,
	Def: Content.EnemyDef,
	Character: Content.CharacterDef,
	Model: Model,
	PickBox: BasePart,
	Animator: RigAnimator.RigAnimator,
	Pivot: CFrame,
	Health: Vide.Source<number>,
	MaxHealth: Vide.Source<number>,
	Alive: Vide.Source<boolean>,
	Life: number,
	HideThread: thread?,
	DisposeInterface: () -> (),
}

const EnemyController = Modux.Controller("EnemyController", { Priority = 750 })

const PICK_BOX_NAME = "PickBox"
const OVERHEAD_NAME = "HealthBarAnchor"
const OVERHEAD_MARGIN = 0.5

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

local function pivotOf(record: EnemyRecord): CFrame
	return CFrame.new(record.Position) * CFrame.Angles(0, math.rad(record.Yaw), 0)
end

local function silenceParts(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
		end
	end
	if model.PrimaryPart then
		model.PrimaryPart.Anchored = true
	end
end

local function createPickBox(model: Model, character: Content.CharacterDef, pivot: CFrame): BasePart
	const size = character.PickSize or Vector3.new(character.Radius * 2, character.Height, character.Radius * 2)
	const pickBox = Instance.new("Part")
	pickBox.Name = PICK_BOX_NAME
	pickBox.Size = size
	pickBox.CFrame = pivot * CFrame.new(0, size.Y / 2, 0)
	pickBox.Transparency = 1
	pickBox.Anchored = true
	pickBox.CanCollide = false
	pickBox.CanTouch = false
	pickBox.CanQuery = true
	pickBox.Massless = true
	pickBox.CastShadow = false
	pickBox.Parent = model

	const overhead = Instance.new("Attachment")
	overhead.Name = OVERHEAD_NAME
	overhead.Position = Vector3.new(0, character.Height + OVERHEAD_MARGIN - size.Y / 2, 0)
	overhead.Parent = pickBox
	return pickBox
end

function EnemyController:Setup()
	self.Actors = {} :: { [number]: EnemyActor }
	self.UidByModel = {} :: { [Model]: number }
	self.Folder = nil :: Folder?
end

function EnemyController:EnemiesFolder(): Folder
	const current = self.Folder
	if current and current.Parent then
		return current
	end
	const folder = visualsFolder("Enemies")
	self.Folder = folder
	return folder
end

function EnemyController:Pick(instance: Instance?): number?
	const folder = self.Folder
	if instance == nil or folder == nil then
		return nil
	end
	local current: Instance? = instance
	while current and current.Parent ~= folder do
		current = current.Parent
	end
	if current and current:IsA("Model") then
		return self.UidByModel[current]
	end
	return nil
end

function EnemyController:Rig(uid: number): RigAnimator.RigAnimator?
	const actor = self.Actors[uid]
	return if actor then actor.Animator else nil
end

function EnemyController:Model(uid: number): Model?
	const actor = self.Actors[uid]
	return if actor then actor.Model else nil
end

function EnemyController:Health(uid: number): Vide.Source<number>?
	const actor = self.Actors[uid]
	return if actor then actor.Health else nil
end

function EnemyController:MaxHealth(uid: number): Vide.Source<number>?
	const actor = self.Actors[uid]
	return if actor then actor.MaxHealth else nil
end

function EnemyController:Alive(uid: number): Vide.Source<boolean>?
	const actor = self.Actors[uid]
	return if actor then actor.Alive else nil
end

function EnemyController:CancelHide(actor: EnemyActor)
	const pending = actor.HideThread
	if pending then
		actor.HideThread = nil
		if coroutine.status(pending) == "suspended" then
			task.cancel(pending)
		end
	end
end

function EnemyController:Show(actor: EnemyActor)
	actor.Model.Parent = self:EnemiesFolder()
	actor.Model:PivotTo(actor.Pivot)
	actor.PickBox.CFrame = actor.Pivot * CFrame.new(0, actor.PickBox.Size.Y / 2, 0)
	actor.PickBox.CanQuery = true
end

function EnemyController:Hide(actor: EnemyActor)
	actor.PickBox.CanQuery = false
	actor.Animator:StopAll(0)
	actor.Model.Parent = nil
end

function EnemyController:PlayDeath(actor: EnemyActor)
	self:CancelHide(actor)
	actor.PickBox.CanQuery = false
	if actor.Model.Parent == nil then
		return
	end
	actor.Animator:StopGroup("Combat", 0)
	actor.Animator:StopGroup("Support", 0)
	actor.Animator:Play("Death")
	actor.HideThread = task.delay(actor.Animator:Duration("Death"), function()
		actor.HideThread = nil
		if not actor.Alive() then
			self:Hide(actor)
		end
	end)
end

function EnemyController:PlaySpawn(actor: EnemyActor)
	self:CancelHide(actor)
	self:Show(actor)
	actor.Animator:StopGroup("Reaction", 0)
	actor.Animator:StopGroup("Combat", 0)
	actor.Animator:Play("Idle")
	actor.Animator:Play("Spawn")
end

function EnemyController:CreateActor(uid: number, record: EnemyRecord): EnemyActor?
	const def = Content.Enemies[record.Enemy]
	if def == nil then
		warn(`[EnemyController] unknown enemy "{record.Enemy}" for uid {uid}`)
		return nil
	end
	const character = Content.Character(def.Character)
	const template = characterTemplate(character)
	if template == nil then
		warn(`[EnemyController] missing model ReplicatedStorage.Assets.Characters.{character.Model}`)
		return nil
	end

	const model = template:Clone()
	model.Name = `{def.Id}#{uid}`
	if character.Scale ~= 1 then
		model:ScaleTo(character.Scale)
	end
	silenceParts(model)

	const pivot = pivotOf(record)
	model:PivotTo(pivot)
	const pickBox = createPickBox(model, character, pivot)

	const health = Vide.source(record.Health)
	const maxHealth = Vide.source(record.MaxHealth)
	const alive = Vide.source(record.Alive)

	const disposeInterface = Vide.root(function()
		HealthBar.Billboard({
			Name = def.Name,
			Boss = def.Boss,
			Health = health,
			MaxHealth = maxHealth,
			Visible = alive,
			MaxDistance = Content.Tuning.Lod.EnemyHide,
			Parent = pickBox:FindFirstChild(OVERHEAD_NAME),
		})
	end)

	model.Parent = self:EnemiesFolder()

	const actor: EnemyActor = {
		Uid = uid,
		Def = def,
		Character = character,
		Model = model,
		PickBox = pickBox,
		Animator = RigAnimator.new(model, Content.AnimationSet(character.AnimationSet)),
		Pivot = pivot,
		Health = health,
		MaxHealth = maxHealth,
		Alive = alive,
		Life = record.Life,
		HideThread = nil,
		DisposeInterface = disposeInterface,
	}

	if record.Alive then
		actor.Animator:Play("Idle")
	else
		self:Hide(actor)
	end

	return actor
end

function EnemyController:OnAdded(uid: number, record: EnemyRecord)
	if self.Actors[uid] then
		self:OnRemoved(uid)
	end
	const actor = self:CreateActor(uid, record)
	if actor == nil then
		return
	end
	self.Actors[uid] = actor
	self.UidByModel[actor.Model] = uid
end

function EnemyController:OnChanged(uid: number, record: EnemyRecord)
	const actor = self.Actors[uid]
	if actor == nil then
		return
	end

	const wasAlive = actor.Alive()
	const reborn = record.Alive and (not wasAlive or record.Life ~= actor.Life)
	actor.Life = record.Life

	const pivot = pivotOf(record)
	const moved = pivot ~= actor.Pivot
	actor.Pivot = pivot

	Vide.batch(function()
		actor.MaxHealth(record.MaxHealth)
		actor.Health(record.Health)
		actor.Alive(record.Alive)
	end)

	if reborn then
		self:PlaySpawn(actor)
	elseif wasAlive and not record.Alive then
		self:PlayDeath(actor)
	elseif moved and actor.Model.Parent then
		self:Show(actor)
	end
end

function EnemyController:OnRemoved(uid: number)
	const actor = self.Actors[uid]
	if actor == nil then
		return
	end
	self.Actors[uid] = nil
	self.UidByModel[actor.Model] = nil
	self:CancelHide(actor)
	actor.DisposeInterface()
	actor.Animator:Destroy()
	actor.Model:Destroy()
end

function EnemyController:PreloadAssets()
	const assets: { Instance } = {}
	const seenModels: { [string]: boolean } = {}
	const seenSets: { [string]: boolean } = {}
	const seenAnimations: { [string]: boolean } = {}

	for _, def in Content.Enemies do
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

EnemyController:OnInit(function(self)
	self:Setup()

	self.Libs.Net.Enemies:onAdded(function(uid, record)
		self:OnAdded(uid, record)
	end)

	self.Libs.Net.Enemies:onChanged(function(uid, record)
		self:OnChanged(uid, record)
	end)

	self.Libs.Net.Enemies:onRemoved(function(uid)
		self:OnRemoved(uid)
	end)
end)

EnemyController:OnStart(function(self)
	self:EnemiesFolder()
	task.spawn(function()
		self:PreloadAssets()
	end)
end)

return EnemyController
