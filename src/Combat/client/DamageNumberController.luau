local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)
local Theme = require(script.Parent.Parent.Interface.Components.Theme)

export type HitKind = "Basic" | "Skill"

export type Hit = {
	Enemy: number,
	Unit: number,
	Amount: number,
	Kind: HitKind,
}

type Style = {
	Width: number,
	Height: number,
	TextSize: number,
	Color: Color3,
	PopScale: number,
}

type Entry = {
	Billboard: BillboardGui,
	Label: TextLabel,
	Scale: UIScale,
	Rise: Tween,
	Fade: Tween,
	Pop: Tween,
	Enemy: number,
	InUse: boolean,
}

const DamageNumberController = Modux.Controller(
	"DamageNumberController",
	{ Require = { "EnemyController" }, Priority = 640 }
)

const VISUALS_FOLDER = "Visuals"
const NUMBERS_FOLDER = "DamageNumbers"
const OUTLINE_COLOR = Color3.fromRGB(10, 10, 14)
const HORIZONTAL_SPREAD = 0.45
const VERTICAL_SPREAD = 0.4
const FADE_SHARE = 0.4
const POP_DURATION = 0.14
const GROUP_THRESHOLD = 3

const STYLES: { [HitKind]: Style } = {
	Basic = {
		Width = 140,
		Height = 40,
		TextSize = 24,
		Color = Color3.fromRGB(255, 222, 89),
		PopScale = 1.3,
	},
	Skill = {
		Width = 200,
		Height = 56,
		TextSize = 34,
		Color = Color3.fromRGB(255, 84, 120),
		PopScale = 1.7,
	},
}

local function formatAmount(amount: number): string
	if amount >= 1e6 then
		return string.format("%.1fM", amount / 1e6)
	end
	if amount >= 1e4 then
		return string.format("%.1fK", amount / 1e3)
	end
	return tostring(math.floor(amount))
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

local function createEntry(parent: Instance): Entry
	const tuning = Content.Tuning.DamageNumbers

	const billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageNumber"
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = Content.Tuning.Lod.EnemyHide
	billboard.Enabled = false

	const label = Instance.new("TextLabel")
	label.Name = "Amount"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Theme.Font
	label.TextStrokeColor3 = OUTLINE_COLOR
	label.TextScaled = false
	label.Parent = billboard

	const scale = Instance.new("UIScale")
	scale.Parent = label

	billboard.Parent = parent

	const fadeDelay = tuning.Lifetime * (1 - FADE_SHARE)
	const rise = TweenService:Create(
		billboard,
		TweenInfo.new(tuning.Lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ StudsOffset = Vector3.new(0, tuning.Rise, 0) }
	)
	const fade = TweenService:Create(
		label,
		TweenInfo.new(tuning.Lifetime * FADE_SHARE, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, fadeDelay),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)
	const pop = TweenService:Create(
		scale,
		TweenInfo.new(POP_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	)

	return {
		Billboard = billboard,
		Label = label,
		Scale = scale,
		Rise = rise,
		Fade = fade,
		Pop = pop,
		Enemy = 0,
		InUse = false,
	}
end

function DamageNumberController:Setup()
	self.Active = {} :: { Entry }
	self.Free = {} :: { Entry }
	self.CountByEnemy = {} :: { [number]: number }
	self.Folder = nil :: Instance?
	self.Rng = Random.new() :: Random
end

function DamageNumberController:NumbersFolder(): Instance
	const current = self.Folder
	if current and current.Parent then
		return current
	end
	const folder = ensureFolder(ensureFolder(Workspace, VISUALS_FOLDER), NUMBERS_FOLDER)
	self.Folder = folder
	for _, entry in self.Active do
		entry.Billboard.Parent = folder
	end
	for _, entry in self.Free do
		entry.Billboard.Parent = folder
	end
	return folder
end

function DamageNumberController:Release(entry: Entry)
	if not entry.InUse then
		return
	end
	entry.InUse = false
	const index = table.find(self.Active, entry)
	if index then
		table.remove(self.Active, index)
	end
	const remaining = (self.CountByEnemy[entry.Enemy] or 1) - 1
	self.CountByEnemy[entry.Enemy] = if remaining > 0 then remaining else nil
	entry.Rise:Cancel()
	entry.Fade:Cancel()
	entry.Pop:Cancel()
	entry.Billboard.Enabled = false
	table.insert(self.Free, entry)
end

function DamageNumberController:OldestOf(enemy: number): Entry?
	for _, entry in self.Active do
		if entry.Enemy == enemy then
			return entry
		end
	end
	return nil
end

function DamageNumberController:Acquire(enemy: number): Entry
	const tuning = Content.Tuning.DamageNumbers
	if (self.CountByEnemy[enemy] or 0) >= tuning.PerEnemy then
		const oldest = self:OldestOf(enemy)
		if oldest then
			self:Release(oldest)
		end
	elseif #self.Active >= tuning.Total then
		self:Release(self.Active[1])
	end

	local entry = table.remove(self.Free)
	if entry == nil then
		const created = createEntry(self:NumbersFolder())
		created.Rise.Completed:Connect(function()
			if created.InUse and created.Rise.PlaybackState == Enum.PlaybackState.Completed then
				self:Release(created)
			end
		end)
		entry = created
	end

	const acquired = entry :: Entry
	acquired.InUse = true
	acquired.Enemy = enemy
	table.insert(self.Active, acquired)
	self.CountByEnemy[enemy] = (self.CountByEnemy[enemy] or 0) + 1
	return acquired
end

function DamageNumberController:Show(enemy: number, amount: number, kind: HitKind)
	const actor = self.Dependencies.EnemyController.Actors[enemy]
	if actor == nil or actor.Model.Parent == nil or amount <= 0 then
		return
	end

	const style = STYLES[kind]
	const entry = self:Acquire(enemy)
	const billboard = entry.Billboard
	const label = entry.Label
	const pickBox = actor.PickBox
	const headHeight = actor.Character.Height - pickBox.Size.Y / 2

	billboard.Size = UDim2.fromOffset(style.Width, style.Height)
	billboard.Adornee = pickBox
	billboard.StudsOffsetWorldSpace = Vector3.new(0, headHeight + self.Rng:NextNumber(0, VERTICAL_SPREAD), 0)
	billboard.StudsOffset = Vector3.zero
	billboard.SizeOffset = Vector2.new(self.Rng:NextNumber(-HORIZONTAL_SPREAD, HORIZONTAL_SPREAD), 0)

	label.Text = formatAmount(amount)
	label.TextSize = style.TextSize
	label.TextColor3 = style.Color
	label.TextTransparency = 0
	label.TextStrokeTransparency = 0
	entry.Scale.Scale = style.PopScale

	billboard.Enabled = true
	entry.Rise:Play()
	entry.Fade:Play()
	entry.Pop:Play()
end

function DamageNumberController:OnHits(hits: { Hit })
	self:NumbersFolder()

	const order: { number } = {}
	const byEnemy: { [number]: { Hit } } = {}
	for _, hit in hits do
		local list = byEnemy[hit.Enemy]
		if list == nil then
			list = {}
			byEnemy[hit.Enemy] = list
			table.insert(order, hit.Enemy)
		end
		table.insert(list :: { Hit }, hit)
	end

	for _, enemy in order do
		const list = byEnemy[enemy]
		if #list <= GROUP_THRESHOLD then
			for _, hit in list do
				self:Show(enemy, hit.Amount, hit.Kind)
			end
			continue
		end
		local basicTotal = 0
		local skillTotal = 0
		for _, hit in list do
			if hit.Kind == "Skill" then
				skillTotal += hit.Amount
			else
				basicTotal += hit.Amount
			end
		end
		self:Show(enemy, basicTotal, "Basic")
		self:Show(enemy, skillTotal, "Skill")
	end
end

DamageNumberController:OnInit(function(self)
	self:Setup()

	self.Libs.Net.Hits:onClient(function(hits)
		self:OnHits(hits)
	end)
end)

DamageNumberController:OnStart(function(self)
	self:NumbersFolder()
end)

return DamageNumberController
