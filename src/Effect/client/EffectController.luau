local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)

export type Target = Model | CFrame

const EffectController = Modux.Controller("EffectController", { Priority = 760 })

const LOW_QUALITY_LEVEL = 3
const DEFAULT_EMIT_COUNT = 10
const VISUALS_FOLDER = "Visuals"
const EFFECTS_FOLDER = "Effects"

local function isLowQualityDevice(): boolean
	const gameSettings = UserSettings():GetService("UserGameSettings")
	const level = gameSettings.SavedQualityLevel
	if level == Enum.SavedQualitySetting.Automatic then
		return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	end
	return level.Value <= LOW_QUALITY_LEVEL
end

local function ensureFolder(parent: Instance, name: string): Instance
	const existing = parent:FindFirstChild(name)
	if existing then
		return existing
	end
	const folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function rootOf(rig: Model): BasePart?
	return rig.PrimaryPart or rig:FindFirstChildWhichIsA("BasePart", true)
end

local function anchorCFrame(rig: Model, root: BasePart, definition: Content.EffectDef): CFrame
	if definition.Anchor == "Ground" then
		return rig:GetPivot()
	end
	if definition.Anchor == "Overhead" then
		const pivot = rig:GetPivot()
		return pivot + pivot.UpVector * rig:GetExtentsSize().Y
	end
	return root.CFrame
end

local function ignite(instance: Instance)
	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			const count = descendant:GetAttribute("EmitCount")
			descendant:Emit(if typeof(count) == "number" then count else DEFAULT_EMIT_COUNT)
		elseif descendant:IsA("Beam") or descendant:IsA("Trail") then
			descendant.Enabled = true
		end
	end
end

local function extinguish(instance: Instance)
	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant:Clear()
		elseif descendant:IsA("Trail") then
			descendant.Enabled = false
			descendant:Clear()
		elseif descendant:IsA("Beam") then
			descendant.Enabled = false
		end
	end
end

function EffectController:Setup()
	self.LowQuality = Vide.source(false) :: Vide.Source<boolean>
	self.Active = Vide.source(0) :: Vide.Source<number>
	self.Pools = {} :: { [string]: { Instance } }
	self.Library = nil :: Instance?
	self.Container = nil :: Instance?
end

function EffectController:AssetFor(definition: Content.EffectDef): Instance?
	const library = self.Library
	if not library then
		return nil
	end
	const lite = definition.Lite
	if lite and self.LowQuality() then
		const liteAsset = library:FindFirstChild(lite)
		if liteAsset then
			return liteAsset
		end
	end
	return library:FindFirstChild(definition.Asset)
end

function EffectController:Acquire(asset: Instance): Instance
	const pool = self.Pools[asset.Name]
	if pool then
		const pooled = table.remove(pool)
		if pooled then
			return pooled
		end
	end
	return asset:Clone()
end

function EffectController:Place(instance: Instance, definition: Content.EffectDef, target: Target): boolean
	local world: CFrame
	local root: BasePart? = nil

	if typeof(target) == "CFrame" then
		world = target
	else
		root = rootOf(target)
		if not root or not target:IsDescendantOf(Workspace) then
			return false
		end
		world = anchorCFrame(target, root, definition)
	end

	if instance:IsA("Attachment") then
		if root then
			instance.Parent = root
			instance.CFrame = root.CFrame:ToObjectSpace(world)
		else
			instance.Parent = Workspace.Terrain
			instance.WorldCFrame = world
		end
		return true
	end

	if instance:IsA("PVInstance") then
		instance:PivotTo(world)
		instance.Parent = self.Container
		return true
	end

	return false
end

function EffectController:Release(poolKey: string, instance: Instance)
	self.Active(math.max(self.Active() - 1, 0))
	if instance.Parent == nil then
		return
	end
	extinguish(instance)
	instance.Parent = nil
	const pool = self.Pools[poolKey]
	if pool then
		table.insert(pool, instance)
	else
		self.Pools[poolKey] = { instance }
	end
end

function EffectController:Play(effectKey: string, target: Target): boolean
	const definition = Content.Effect(effectKey)
	if self.Active() >= Content.Tuning.MaxSkillEffects then
		return false
	end

	const asset = self:AssetFor(definition)
	if not asset then
		warn(`[EffectController] asset for effect "{effectKey}" not found in ReplicatedStorage.Assets.Effects`)
		return false
	end

	const instance = self:Acquire(asset)
	if not self:Place(instance, definition, target) then
		instance:Destroy()
		return false
	end

	ignite(instance)
	self.Active(self.Active() + 1)

	const poolKey = asset.Name
	task.delay(definition.Lifetime, function()
		self:Release(poolKey, instance)
	end)
	return true
end

EffectController:OnInit(function(self)
	self:Setup()
end)

EffectController:OnStart(function(self)
	const assets = ReplicatedStorage:FindFirstChild("Assets")
	const library = if assets then assets:FindFirstChild("Effects") else nil
	if not library then
		warn("[EffectController] ReplicatedStorage.Assets.Effects not found")
	end
	self.Library = library
	self.Container = ensureFolder(ensureFolder(Workspace, VISUALS_FOLDER), EFFECTS_FOLDER)

	self.LowQuality(isLowQualityDevice())
	UserSettings():GetService("UserGameSettings"):GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
		self.LowQuality(isLowQualityDevice())
	end)

	if library then
		task.spawn(function()
			ContentProvider:PreloadAsync({ library })
		end)
	end
end)

return EffectController
