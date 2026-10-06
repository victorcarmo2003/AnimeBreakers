local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)

export type SlotStatus = "Auto" | "Requested" | "Cooldown" | "Ready" | "Unavailable"

export type SlotState = {
	Unit: number,
	Slot: number,
	Pet: string,
	Status: SlotStatus,
	CanUse: boolean,
	Remaining: number,
	Cooldown: number,
	Progress: number,
}

export type SkillUnit = {
	Id: number,
	Owner: number,
	Slot: number,
	Pet: string,
	Target: number?,
	SkillReadyAt: number,
	ArriveAt: number,
}

export type MoveCommand = {
	Kind: "Attack" | "Recall",
	Enemy: number?,
}

export type SkillRequest = {
	ReadyAt: number,
	SentAt: number?,
}

export type Outbox = {
	Move: MoveCommand?,
	Auto: boolean?,
	Skills: { number },
}

const CommandController = Modux.Controller(
	"CommandController",
	{ Require = { "InputController", "EnemyController", "ProfileController", "PetController" }, Priority = 600 }
)

const PICK_RAY_LENGTH = 1024
const SEND_MARGIN = 0.05
const AUTO_CONFIRM_TIMEOUT = 2
const CLOCK_TICK_RATE = 30
const RECALL_ACTION = "Recall"
const RECALL_KEY = Enum.KeyCode.X
const RECALL_GAMEPAD_KEY = Enum.KeyCode.ButtonB
const AUTO_SKILL_ACTION = "ToggleAutoSkill"
const AUTO_SKILL_KEY = Enum.KeyCode.Q
const AUTO_SKILL_GAMEPAD_KEY = Enum.KeyCode.ButtonY
const NEXT_SKILL_ACTION = "UseNextSkill"
const NEXT_SKILL_GAMEPAD_KEY = Enum.KeyCode.ButtonX
const SLOT_SKILL_ACTION = "UseSkillSlot"
const SLOT_KEYS = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
}

local function serverNow(): number
	return Workspace:GetServerTimeNow()
end

local function cooldownOf(petId: string): number
	const pet = Content.Pets[petId]
	if pet == nil then
		return 0
	end
	const ability = Content.Abilities[pet.Ability]
	return if ability then ability.Cooldown else 0
end

function CommandController:Setup()
	self.Target = Vide.source(nil) :: Vide.Source<number?>
	self.AutoSkill = Vide.source(Content.Tuning.DefaultAutoSkill) :: Vide.Source<boolean>
	self.Slots = Vide.source({}) :: Vide.Source<{ SlotState }>
	self.Clock = Vide.source(serverNow()) :: Vide.Source<number>
	self.Revision = Vide.source(0) :: Vide.Source<number>
	self.AutoRequested = nil :: boolean?
	self.AutoSentAt = 0 :: number
	self.SkillRequests = {} :: { [number]: SkillRequest }
	self.Outbox = { Move = nil, Auto = nil, Skills = {} } :: Outbox
	self.LastSentAt = 0 :: number
	self.Ticking = false :: boolean
	const pickParams = RaycastParams.new()
	pickParams.FilterType = Enum.RaycastFilterType.Include
	self.PickParams = pickParams :: RaycastParams
end

function CommandController:CurrentTarget(): number?
	const read = self.Target :: () -> number?
	return read()
end

function CommandController:Bump()
	const revision = self.Revision :: Vide.Source<number>
	revision(revision() + 1)
end

function CommandController:SendInterval(): number
	return Content.Tuning.CommandMinInterval + SEND_MARGIN
end

function CommandController:HasOutgoing(): boolean
	const outbox = self.Outbox
	return outbox.Move ~= nil or outbox.Auto ~= nil or #outbox.Skills > 0
end

function CommandController:MyUnit(unitId: number): SkillUnit?
	const unit = self.Dependencies.PetController:Unit(unitId)
	const localPlayer = Players.LocalPlayer
	if unit == nil or localPlayer == nil or unit.Owner ~= localPlayer.UserId then
		return nil
	end
	return unit
end

function CommandController:IsTargetActive(uid: number): boolean
	const alive = self.Dependencies.EnemyController:Alive(uid)
	return alive ~= nil and alive()
end

function CommandController:IsOnStage(unit: SkillUnit, now: number): boolean
	const target = unit.Target
	if target == nil or now < unit.ArriveAt then
		return false
	end
	return self:IsTargetActive(target)
end

function CommandController:CanRequestSkill(unit: SkillUnit, now: number): boolean
	const readAuto = self.AutoSkill :: () -> boolean
	return not readAuto() and now >= unit.SkillReadyAt and self:IsOnStage(unit, now)
end

function CommandController:SendMove(command: MoveCommand)
	const net = self.Libs.Net
	if command.Kind == "Attack" and command.Enemy ~= nil then
		net.Attack:fireServer({ Enemy = command.Enemy })
	else
		net.Recall:fireServer()
	end
end

function CommandController:SendNextSkill(): boolean
	const skills = self.Outbox.Skills
	const now = serverNow()
	while #skills > 0 do
		const unitId = table.remove(skills, 1) :: number
		const request = self.SkillRequests[unitId]
		const unit = self:MyUnit(unitId)
		if unit ~= nil and request ~= nil and self:CanRequestSkill(unit, now) then
			request.SentAt = os.clock()
			self.Libs.Net.UseSkill:fireServer({ Unit = unitId })
			return true
		end
		self.SkillRequests[unitId] = nil
	end
	return false
end

function CommandController:SendOne(): boolean
	const outbox = self.Outbox
	const move = outbox.Move
	if move ~= nil then
		outbox.Move = nil
		self:SendMove(move)
		return true
	end
	const auto = outbox.Auto
	if auto ~= nil then
		outbox.Auto = nil
		self.AutoSentAt = os.clock()
		self.Libs.Net.SetAutoSkill:fireServer({ Enabled = auto })
		return true
	end
	return self:SendNextSkill()
end

function CommandController:Flush()
	if not self:HasOutgoing() then
		return
	end
	const clock = os.clock()
	if clock - self.LastSentAt < self:SendInterval() then
		return
	end
	if self:SendOne() then
		self.LastSentAt = clock
	end
	self:Bump()
end

function CommandController:ClearSkillRequests()
	table.clear(self.Outbox.Skills)
	table.clear(self.SkillRequests)
	self:Bump()
end

function CommandController:PickEnemy(screenPosition: Vector2): number?
	const camera = Workspace.CurrentCamera
	if camera == nil then
		return nil
	end
	const enemyController = self.Dependencies.EnemyController
	self.PickParams.FilterDescendantsInstances = { enemyController:EnemiesFolder() }
	const ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
	const result = Workspace:Raycast(ray.Origin, ray.Direction * PICK_RAY_LENGTH, self.PickParams)
	if result == nil then
		return nil
	end
	return enemyController:Pick(result.Instance)
end

function CommandController:Attack(uid: number)
	self.Target(uid)
	self.Outbox.Move = { Kind = "Attack", Enemy = uid }
	self:ClearSkillRequests()
	self:Flush()
end

function CommandController:Recall()
	self.Target(nil)
	self.Outbox.Move = { Kind = "Recall", Enemy = nil }
	self:ClearSkillRequests()
	self:Flush()
end

function CommandController:SetAutoSkill(enabled: boolean)
	self.AutoRequested = enabled
	self.Outbox.Auto = enabled
	self.AutoSkill(enabled)
	if enabled then
		self:ClearSkillRequests()
	end
	self:Flush()
end

function CommandController:ToggleAutoSkill()
	const readAuto = self.AutoSkill :: () -> boolean
	self:SetAutoSkill(not readAuto())
end

function CommandController:UseSkill(unitId: number): boolean
	const unit = self:MyUnit(unitId)
	if unit == nil or self.SkillRequests[unitId] ~= nil then
		return false
	end
	if not self:CanRequestSkill(unit, serverNow()) then
		return false
	end
	self.SkillRequests[unitId] = { ReadyAt = unit.SkillReadyAt, SentAt = nil }
	table.insert(self.Outbox.Skills, unitId)
	self:Bump()
	self:Flush()
	return true
end

function CommandController:UseSkillSlot(slot: number): boolean
	const readUnits = self.Dependencies.PetController.MyUnits :: () -> { SkillUnit }
	for _, unit in readUnits() do
		if unit.Slot == slot then
			return self:UseSkill(unit.Id)
		end
	end
	return false
end

function CommandController:UseNextSkill(): boolean
	const readSlots = self.Slots :: () -> { SlotState }
	for _, state in readSlots() do
		if state.CanUse and self:UseSkill(state.Unit) then
			return true
		end
	end
	return false
end

function CommandController:SlotState(unitId: number): SlotState?
	const readSlots = self.Slots :: () -> { SlotState }
	for _, state in readSlots() do
		if state.Unit == unitId then
			return state
		end
	end
	return nil
end

function CommandController:IsRequestPending(unit: SkillUnit, clock: number): boolean
	const request = self.SkillRequests[unit.Id]
	if request == nil then
		return false
	end
	const sentAt = request.SentAt
	const stale = unit.SkillReadyAt ~= request.ReadyAt
		or (sentAt ~= nil and clock - sentAt >= Content.Tuning.SkillRequestTimeout)
	if stale then
		self.SkillRequests[unit.Id] = nil
		const index = table.find(self.Outbox.Skills, unit.Id)
		if index then
			table.remove(self.Outbox.Skills, index)
		end
		return false
	end
	return true
end

function CommandController:BuildSlot(unit: SkillUnit, now: number, clock: number, auto: boolean): SlotState
	const cooldown = cooldownOf(unit.Pet)
	const remaining = math.max(unit.SkillReadyAt - now, 0)
	const progress = if cooldown > 0 then 1 - math.clamp(remaining / cooldown, 0, 1) else 1
	local status: SlotStatus = "Unavailable"
	if auto then
		status = "Auto"
	elseif self:IsRequestPending(unit, clock) then
		status = "Requested"
	elseif remaining > 0 then
		status = "Cooldown"
	elseif self:IsOnStage(unit, now) then
		status = "Ready"
	end
	return {
		Unit = unit.Id,
		Slot = unit.Slot,
		Pet = unit.Pet,
		Status = status,
		CanUse = status == "Ready",
		Remaining = remaining,
		Cooldown = cooldown,
		Progress = progress,
	}
end

function CommandController:NeedsClock(units: { SkillUnit }, now: number): boolean
	if self.AutoRequested ~= nil or next(self.SkillRequests) ~= nil or self:HasOutgoing() then
		return true
	end
	for _, unit in units do
		if now < unit.SkillReadyAt or (unit.Target ~= nil and now < unit.ArriveAt) then
			return true
		end
	end
	return false
end

function CommandController:ResolveAuto(profileAuto: boolean): boolean
	const requested = self.AutoRequested
	if requested == nil then
		return profileAuto
	end
	if self.Outbox.Auto == nil and os.clock() - self.AutoSentAt >= AUTO_CONFIRM_TIMEOUT then
		self.AutoRequested = nil
		return profileAuto
	end
	return requested
end

function CommandController:ConfirmAuto(profileAuto: boolean)
	if self.AutoRequested == profileAuto and self.Outbox.Auto == nil then
		self.AutoRequested = nil
	end
end

function CommandController:RebuildSlots()
	const readUnits = self.Dependencies.PetController.MyUnits :: () -> { SkillUnit }
	const readProfileAuto = self.Dependencies.ProfileController.AutoSkill :: () -> boolean
	const readClock = self.Clock :: () -> number
	const readRevision = self.Revision :: () -> number
	const units = readUnits()
	const profileAuto = readProfileAuto()
	readClock()
	readRevision()

	const now = serverNow()
	const clock = os.clock()
	const auto = Vide.untrack(function(): boolean
		return self:ResolveAuto(profileAuto)
	end)
	self.AutoSkill(auto)

	const slots: { SlotState } = {}
	for _, unit in units do
		table.insert(slots, self:BuildSlot(unit, now, clock, auto))
	end
	self.Slots(slots)
	self.Ticking = self:NeedsClock(units, now)
end

function CommandController:OnWorldTap(screenPosition: Vector2)
	const uid = self:PickEnemy(screenPosition)
	if uid == nil then
		return
	end
	const current = self:CurrentTarget()
	if current == uid and self:IsTargetActive(uid) then
		self:Recall()
	else
		self:Attack(uid)
	end
end

function CommandController:WatchTargetDeath()
	Vide.effect(function()
		const current = self:CurrentTarget()
		if current == nil then
			return
		end
		const alive = self.Dependencies.EnemyController:Alive(current)
		if alive == nil or not alive() then
			self.Target(nil)
		end
	end)
end

function CommandController:WatchProfileAuto()
	local previous: boolean? = nil
	Vide.effect(function()
		const readProfileAuto = self.Dependencies.ProfileController.AutoSkill :: () -> boolean
		const profileAuto = readProfileAuto()
		if previous ~= nil and previous ~= profileAuto then
			self:ConfirmAuto(profileAuto)
		end
		previous = profileAuto
	end)
end

function CommandController:WatchSlots()
	Vide.effect(function()
		self:RebuildSlots()
	end)
end

function CommandController:IsGameplay(): boolean
	return self.Dependencies.InputController.Context == "Gameplay"
end

function CommandController:BindCommands()
	const inputController = self.Dependencies.InputController
	inputController:Bind({
		Name = RECALL_ACTION,
		Key = RECALL_KEY,
		Keys = { RECALL_GAMEPAD_KEY },
	}).OnPress(function()
		if self:IsGameplay() then
			self:Recall()
		end
	end)

	inputController:Bind({
		Name = AUTO_SKILL_ACTION,
		Key = AUTO_SKILL_KEY,
		Keys = { AUTO_SKILL_GAMEPAD_KEY },
	}).OnPress(function()
		if self:IsGameplay() then
			self:ToggleAutoSkill()
		end
	end)

	inputController:Bind({
		Name = NEXT_SKILL_ACTION,
		Key = NEXT_SKILL_GAMEPAD_KEY,
	}).OnPress(function()
		if self:IsGameplay() then
			self:UseNextSkill()
		end
	end)

	for slot, key in SLOT_KEYS do
		inputController:Bind({
			Name = `{SLOT_SKILL_ACTION}{slot}`,
			Key = key,
		}).OnPress(function()
			if self:IsGameplay() then
				self:UseSkillSlot(slot)
			end
		end)
	end
end

function CommandController:Tick()
	self:Flush()
	if self.Ticking then
		self.Clock(serverNow())
	end
end

CommandController:OnInit(function(self)
	self:Setup()
end)

CommandController:OnStart(function(self)
	Vide.root(function()
		self:WatchTargetDeath()
		self:WatchProfileAuto()
		self:WatchSlots()
	end)
	self:BindCommands()
	self.Dependencies.InputController:OnWorldTap(function(screenPosition: Vector2)
		self:OnWorldTap(screenPosition)
	end)
end)

CommandController:OnTick(function(self)
	self:Tick()
end, CLOCK_TICK_RATE)

return CommandController
