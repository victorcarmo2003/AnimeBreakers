local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Lync = require(ReplicatedStorage.Packages.Lync)
local Content = require(ReplicatedStorage.shared.Content)
local SignalLib = require(ReplicatedStorage.shared.Libs.Signal)
local Modux = require(ServerScriptService.server.Modux)

export type OwnedPet = {
	Pet: string,
	Level: number,
	Stars: number,
	Xp: number,
	Gear: { [string]: number },
}

export type PetUnit = {
	Id: number,
	Owner: Player,
	Slot: number,
	OwnedUid: number,
	PetId: string,
	Def: Content.PetDef,
	Damage: number,
	AttackInterval: number,
	AbilityId: string,
	Cooldown: number,
	SkillReadyAt: number,
	Target: number?,
	Ring: number,
	ArriveAt: number,
	NextHitAt: number,
}

const MAX_SLOTS = 8

const PetService = Modux.Service(
	"PetService",
	{ Require = { "PlayerService", "ProfileService", "NetService" }, Priority = 650 }
)

local function levelMultiplier(_owned: OwnedPet): number
	return 1
end

local function starMultiplier(_owned: OwnedPet): number
	return 1
end

local function gearMultiplier(_owned: OwnedPet): number
	return 1
end

function PetService:Setup()
	self.LastUnitId = 0 :: number
	self.Registry = {} :: { [number]: PetUnit }
	self.ByOwner = {} :: { [Player]: { PetUnit } }
	self.UnitAdded = self.Libs.Signal.new() :: SignalLib.Signal<PetUnit>
	self.UnitRemoved = self.Libs.Signal.new() :: SignalLib.Signal<PetUnit>
end

function PetService:NewOwnedPet(petId: string): OwnedPet
	Content.Pet(petId)
	return {
		Pet = petId,
		Level = 1,
		Stars = 1,
		Xp = 0,
		Gear = {},
	}
end

function PetService:NextUnitId(): number
	self.LastUnitId += 1
	return self.LastUnitId
end

function PetService:CanPublish(): boolean
	return self.Dependencies.NetService:IsRunning()
end

function PetService:GrantStarterPets(player: Player)
	const profileService = self.Dependencies.ProfileService
	const profile = profileService:Get(player)
	if profile == nil or next(profile.Pets()) ~= nil then
		return
	end

	const slots = math.min(profile.EquipSlots(), MAX_SLOTS)
	const pets: { [string]: OwnedPet } = {}
	const equipped: { string } = {}
	local nextUid = profile.NextPetUid()

	for _, petId in Content.Tuning.StarterPets do
		const key = tostring(nextUid)
		pets[key] = self:NewOwnedPet(petId)
		nextUid += 1
		if #equipped < slots then
			table.insert(equipped, key)
		end
	end

	profileService:Update(player, {
		Pets = pets,
		Equipped = equipped,
		NextPetUid = nextUid,
	})
end

function PetService:CreateUnit(player: Player, slot: number, ownedUid: number, owned: OwnedPet): PetUnit?
	const def = Content.Pets[owned.Pet]
	if def == nil then
		warn(`[PetService] {player.Name} owns unknown pet "{owned.Pet}"; slot {slot} skipped`)
		return nil
	end
	const ability = Content.Ability(def.Ability)

	return {
		Id = self:NextUnitId(),
		Owner = player,
		Slot = slot,
		OwnedUid = ownedUid,
		PetId = def.Id,
		Def = def,
		Damage = def.Damage * levelMultiplier(owned) * starMultiplier(owned) * gearMultiplier(owned),
		AttackInterval = def.AttackInterval,
		AbilityId = ability.Id,
		Cooldown = ability.Cooldown,
		SkillReadyAt = 0,
		Target = nil,
		Ring = 0,
		ArriveAt = 0,
		NextHitAt = 0,
	}
end

function PetService:Publish(unit: PetUnit)
	if not self:CanPublish() then
		return
	end
	self.Libs.Net.Pets:add(unit.Id, {
		Owner = unit.Owner.UserId,
		Slot = unit.Slot,
		Pet = unit.PetId,
		Target = unit.Target,
		Ring = unit.Ring,
		SkillReadyAt = unit.SkillReadyAt,
	})
end

function PetService:BuildUnits(player: Player)
	const profile = self.Dependencies.ProfileService:Get(player)
	if profile == nil then
		return
	end

	self:RemoveUnits(player)

	const owned = profile.Pets()
	const units: { PetUnit } = {}
	self.ByOwner[player] = units

	for slot, key in profile.Equipped() do
		if slot > MAX_SLOTS then
			warn(`[PetService] {player.Name} has more than {MAX_SLOTS} equipped pets; extra skipped`)
			break
		end
		const entry = owned[key]
		const ownedUid = tonumber(key)
		if entry == nil or ownedUid == nil then
			warn(`[PetService] {player.Name} has equipped uid "{key}" without a pet; slot {slot} skipped`)
			continue
		end
		const unit = self:CreateUnit(player, slot, ownedUid, entry)
		if unit == nil then
			continue
		end
		table.insert(units, unit)
		self.Registry[unit.Id] = unit
		self:Publish(unit)
		self.UnitAdded:Fire(unit)
	end
end

function PetService:RemoveUnits(player: Player)
	const units = self.ByOwner[player]
	if units == nil then
		return
	end
	self.ByOwner[player] = nil

	const pets = self.Libs.Net.Pets
	for _, unit in units do
		self.Registry[unit.Id] = nil
		if self:CanPublish() and pets:get(unit.Id) then
			pets:remove(unit.Id)
		end
		self.UnitRemoved:Fire(unit)
	end
end

function PetService:Units(player: Player): { PetUnit }
	const units = self.ByOwner[player]
	return if units then table.clone(units) else {}
end

function PetService:Unit(id: number): PetUnit?
	return self.Registry[id]
end

function PetService:IsLive(unit: PetUnit): boolean
	return self.Registry[unit.Id] == unit
end

function PetService:SetTarget(unit: PetUnit, enemyUid: number?, ring: number)
	if not self:IsLive(unit) then
		return
	end
	unit.Target = enemyUid
	unit.Ring = ring
	if not self:CanPublish() then
		return
	end
	self.Libs.Net.Pets:update(unit.Id, {
		Target = if enemyUid ~= nil then enemyUid else Lync.none,
		Ring = ring,
	})
end

function PetService:SetSkillReady(unit: PetUnit, at: number)
	if not self:IsLive(unit) then
		return
	end
	unit.SkillReadyAt = at
	if not self:CanPublish() then
		return
	end
	self.Libs.Net.Pets:update(unit.Id, { SkillReadyAt = at })
end

PetService:OnInit(function(self)
	self:Setup()

	self.Dependencies.ProfileService.Loaded:Connect(function(player)
		self:GrantStarterPets(player)
		self:BuildUnits(player)
	end)

	self.Dependencies.PlayerService.PlayerRemoving:Connect(function(player)
		self:RemoveUnits(player)
	end)
end)

return PetService
