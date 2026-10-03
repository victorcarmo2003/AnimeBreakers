local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Content = require(ReplicatedStorage.shared.Content)
local Atomic = require(ReplicatedStorage.shared.Types.Atomic)
local SignalLib = require(ReplicatedStorage.shared.Libs.Signal)
local Struct = require(ReplicatedStorage.shared.Types.Struct)
local Template = require(script.Template)
local Migrations = require(script.Migrations)
local Modux = require(ServerScriptService.server.Modux)

export type Data = typeof(Template)
export type Profile = Atomic.Table<Data>
export type OwnedPet = Template.OwnedPet

export type ProfilePayload = {
	Coins: number,
	AutoSkill: boolean,
}

export type InventoryEntry = {
	Uid: number,
	Pet: string,
	Level: number,
	Stars: number,
}

export type InventoryPayload = {
	Pets: { InventoryEntry },
	Equipped: { number },
}

const STORE_NAME = "Player"
const CURRENT_VERSION = Template.Version

local function deepClone(value: any): any
	if typeof(value) ~= "table" then
		return value
	end
	const copy = {}
	for key, inner in value do
		copy[key] = deepClone(inner)
	end
	return copy
end

const ProfileService = Modux.Service(
	"ProfileService",
	{ Require = { "PlayerService", "NetService" }, Priority = 800 }
)

function ProfileService:Setup()
	const store = ProfileStore.New(STORE_NAME, Template :: any)
	self.Store = (if Content.Tuning.PersistProfiles then store else store.Mock) :: any
	self.Sessions = {} :: { [Player]: any }
	self.Profiles = {} :: { [Player]: Profile }
	self.Disposers = {} :: { [Player]: { () -> () } }
	self.Loaded = self.Libs.Signal.new() :: SignalLib.Signal<Player, Profile>
end

function ProfileService:Get(player: Player): Profile?
	return self.Profiles[player]
end

function ProfileService:Update(player: Player, patch: Struct.Partial<Data>)
	const profile = self.Profiles[player]
	if not profile then
		warn(`[ProfileService] {player.Name} has no loaded profile`)
		return
	end

	const fields: { [string]: (any) -> any } = profile :: any
	self.Libs.Charm.batch(function()
		for key, value in patch :: { [string]: any } do
			const field = fields[key]
			if field == nil then
				warn(`[ProfileService] {key} is not a profile field`)
				continue
			end
			field(value)
		end
	end)
end

function ProfileService:Mutate(player: Player, field: string, mutate: (value: any) -> ())
	const profile = self.Profiles[player]
	if not profile then
		warn(`[ProfileService] {player.Name} has no loaded profile`)
		return
	end

	const atom = (profile :: any)[field] :: ((any) -> any)?
	if atom == nil then
		warn(`[ProfileService] {field} is not a profile field`)
		return
	end

	const current = atom()
	if typeof(current) ~= "table" then
		warn(`[ProfileService] {field} is not a table field`)
		return
	end

	const copy = deepClone(current)
	mutate(copy)
	atom(copy)
end

function ProfileService:ProfilePayload(profile: Profile): ProfilePayload
	return {
		Coins = profile.Coins(),
		AutoSkill = profile.AutoSkill(),
	}
end

function ProfileService:InventoryPayload(profile: Profile): InventoryPayload
	const pets: { InventoryEntry } = {}
	for key, owned in profile.Pets() do
		const uid = tonumber(key)
		if uid == nil then
			continue
		end
		table.insert(pets, {
			Uid = uid,
			Pet = owned.Pet,
			Level = owned.Level,
			Stars = owned.Stars,
		})
	end
	table.sort(pets, function(left: InventoryEntry, right: InventoryEntry)
		return left.Uid < right.Uid
	end)

	const equipped: { number } = {}
	for _, key in profile.Equipped() do
		const uid = tonumber(key)
		if uid ~= nil then
			table.insert(equipped, uid)
		end
	end

	return { Pets = pets, Equipped = equipped }
end

function ProfileService:CanSend(player: Player): boolean
	const net = self.Dependencies.NetService
	return net:IsRunning() and net:IsReady(player) and self.Profiles[player] ~= nil
end

function ProfileService:SendProfile(player: Player, payload: ProfilePayload)
	if not self:CanSend(player) then
		return
	end
	self.Libs.Net.Profile:fireClient(player, payload)
end

function ProfileService:SendInventory(player: Player, payload: InventoryPayload)
	if not self:CanSend(player) then
		return
	end
	self.Libs.Net.Inventory:fireClient(player, payload)
end

function ProfileService:Replicate(player: Player)
	const profile = self.Profiles[player]
	if not profile then
		return
	end

	self:SendProfile(player, self:ProfilePayload(profile))
	self:SendInventory(player, self:InventoryPayload(profile))
end

function ProfileService:Bind(player: Player, session: any): Profile
	const Charm = self.Libs.Charm
	const atoms: { [string]: (any) -> any } = {}
	for key in Template :: { [string]: any } do
		atoms[key] = Charm.atom(session.Data[key])
	end
	const profile: Profile = atoms :: any
	self.Profiles[player] = profile

	self.Disposers[player] = {
		Charm.effect(function()
			for key, field in atoms do
				session.Data[key] = field()
			end
		end),
		Charm.effect(function()
			self:SendProfile(player, self:ProfilePayload(profile))
		end),
		Charm.effect(function()
			self:SendInventory(player, self:InventoryPayload(profile))
		end),
	}

	return profile
end

function ProfileService:Migrate(data: { [string]: any }): boolean
	const stored = data.Version
	const version = if typeof(stored) == "number" then stored else 1
	if version > CURRENT_VERSION then
		return false
	end

	data.Version = version
	for target = version + 1, CURRENT_VERSION do
		const migration = Migrations[target]
		if migration == nil then
			error(`[ProfileService] missing migration to version {target}`)
		end
		migration(data)
		data.Version = target
	end
	return true
end

function ProfileService:Load(player: Player)
	const session = self.Store:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if not session then
		player:Kick("Could not load your data. Please rejoin.")
		return
	end

	if not self:Migrate(session.Data) then
		session:EndSession()
		player:Kick("The game was updated. Please rejoin.")
		return
	end

	session:AddUserId(player.UserId)
	session:Reconcile()
	session.OnSessionEnd:Connect(function()
		if self.Sessions[player] == nil then
			return
		end
		self:Forget(player)
		player:Kick("Your data session ended. Please rejoin.")
	end)

	if player.Parent ~= Players then
		session:EndSession()
		return
	end

	self.Sessions[player] = session
	self.Loaded:Fire(player, self:Bind(player, session))
end

function ProfileService:Forget(player: Player)
	const disposers = self.Disposers[player]
	if disposers then
		for _, dispose in disposers do
			dispose()
		end
		self.Disposers[player] = nil
	end
	self.Profiles[player] = nil
	self.Sessions[player] = nil
end

function ProfileService:Unload(player: Player)
	const session = self.Sessions[player]
	self:Forget(player)
	if session then
		session:EndSession()
	end
end

ProfileService:OnInit(function(self)
	self:Setup()

	self.Dependencies.PlayerService.PlayerAdded:Connect(function(player)
		task.spawn(function()
			self:Load(player)
		end)
	end)
	self.Dependencies.PlayerService.PlayerRemoving:Connect(function(player)
		self:Unload(player)
	end)

	self.Dependencies.NetService.ClientReady:Connect(function(player)
		self:Replicate(player)
	end)
end)

return ProfileService
