local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)

export type Group = "Locomotion" | "Support" | "Combat" | "Reaction"

export type PlayOptions = {
	Seek: number?,
	Fade: number?,
}

type TrackKey = Content.TrackKey

type Fields = {
	Rig: Model,
	Set: Content.AnimationSet,
	Animator: Animator,
	Tracks: { [TrackKey]: AnimationTrack },
	Playing: { [Group]: TrackKey },
	Destroyed: boolean,
}

const RigAnimator = {}
RigAnimator.__index = RigAnimator

export type RigAnimator = setmetatable<Fields, typeof(RigAnimator)>

const DEFAULT_FADE = 0.1

const GROUP_OF_KEY: { [TrackKey]: Group } = {
	Idle = "Locomotion",
	Run = "Locomotion",
	Assist = "Support",
	Enter = "Combat",
	Combat1 = "Combat",
	Combat2 = "Combat",
	BackOff = "Combat",
	Skill = "Combat",
	Defend = "Reaction",
	Hit = "Reaction",
	HitHeavy = "Reaction",
	Death = "Reaction",
	Spawn = "Reaction",
}

const PRIORITY_OF_GROUP: { [Group]: Enum.AnimationPriority } = {
	Locomotion = Enum.AnimationPriority.Movement,
	Support = Enum.AnimationPriority.Action,
	Combat = Enum.AnimationPriority.Action2,
	Reaction = Enum.AnimationPriority.Action3,
}

const FALLBACK_KEY: { [TrackKey]: TrackKey } = {
	HitHeavy = "Hit",
}

const animationsById: { [string]: Animation } = {}
const animatorsByRig: { [Model]: RigAnimator } = setmetatable({}, { __mode = "k" }) :: any

local function animationFor(id: string): Animation
	const cached = animationsById[id]
	if cached then
		return cached
	end
	const animation = Instance.new("Animation")
	animation.AnimationId = id
	animationsById[id] = animation
	return animation
end

local function findAnimator(rig: Model): Animator
	const controller = rig:FindFirstChildWhichIsA("AnimationController", true)
	const animator = if controller
		then controller:FindFirstChildWhichIsA("Animator")
		else rig:FindFirstChildWhichIsA("Animator", true)
	if not animator then
		error(`[RigAnimator] rig "{rig:GetFullName()}" has no Animator`, 3)
	end
	return animator
end

function RigAnimator.new(rig: Model, animationSet: Content.AnimationSet): RigAnimator
	const existing = animatorsByRig[rig]
	if existing and not existing.Destroyed and existing.Set == animationSet then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	const fields: Fields = {
		Rig = rig,
		Set = animationSet,
		Animator = findAnimator(rig),
		Tracks = {},
		Playing = {},
		Destroyed = false,
	}
	const animator = setmetatable(fields, RigAnimator)
	animatorsByRig[rig] = animator
	return animator
end

function RigAnimator.GroupOf(key: TrackKey): Group
	return GROUP_OF_KEY[key]
end

function RigAnimator.Resolve(self: RigAnimator, key: TrackKey): TrackKey?
	if self.Set.Tracks[key] then
		return key
	end
	const fallback = FALLBACK_KEY[key]
	if fallback and self.Set.Tracks[fallback] then
		return fallback
	end
	return nil
end

function RigAnimator.Has(self: RigAnimator, key: TrackKey): boolean
	return self:Resolve(key) ~= nil
end

function RigAnimator.Load(self: RigAnimator, key: TrackKey): AnimationTrack?
	if self.Destroyed then
		return nil
	end
	const resolved = self:Resolve(key)
	if not resolved then
		return nil
	end
	const cached = self.Tracks[resolved]
	if cached then
		return cached
	end
	const definition = self.Set.Tracks[resolved]
	const track = self.Animator:LoadAnimation(animationFor(definition.Id))
	track.Looped = definition.Looped == true
	track.Priority = definition.Priority or PRIORITY_OF_GROUP[GROUP_OF_KEY[resolved]]
	self.Tracks[resolved] = track
	return track
end

function RigAnimator.Duration(self: RigAnimator, key: TrackKey): number
	const resolved = self:Resolve(key)
	if not resolved then
		return 0
	end
	return self.Set.Tracks[resolved].Duration
end

function RigAnimator.Play(self: RigAnimator, key: TrackKey, options: PlayOptions?): AnimationTrack?
	const track = self:Load(key)
	if not track then
		return nil
	end
	const resolved = self:Resolve(key) :: TrackKey
	const definition = self.Set.Tracks[resolved]
	const group = GROUP_OF_KEY[resolved]
	const fade = if options and options.Fade then options.Fade else definition.Fade or DEFAULT_FADE
	const seek = if options then options.Seek else nil

	const current = self.Playing[group]
	if current and current ~= resolved then
		const previous = self.Tracks[current]
		if previous then
			previous:Stop(fade)
		end
	end

	if current == resolved and track.IsPlaying and seek == nil then
		return track
	end

	track:Play(fade, 1, definition.Speed or 1)
	if seek then
		const position = math.max(seek * (definition.Speed or 1), 0)
		track.TimePosition = if track.Length > 0 then math.min(position, track.Length) else position
	end
	self.Playing[group] = resolved
	return track
end

function RigAnimator.Stop(self: RigAnimator, key: TrackKey, fade: number?)
	const resolved = self:Resolve(key)
	if not resolved then
		return
	end
	const track = self.Tracks[resolved]
	if track then
		track:Stop(fade or self.Set.Tracks[resolved].Fade or DEFAULT_FADE)
	end
	const group = GROUP_OF_KEY[resolved]
	if self.Playing[group] == resolved then
		self.Playing[group] = nil
	end
end

function RigAnimator.StopGroup(self: RigAnimator, group: Group, fade: number?)
	const current = self.Playing[group]
	if current then
		self:Stop(current, fade)
	end
end

function RigAnimator.StopAll(self: RigAnimator, fade: number?)
	for _, group in { "Locomotion", "Support", "Combat", "Reaction" } :: { Group } do
		self:StopGroup(group, fade)
	end
end

function RigAnimator.Destroy(self: RigAnimator)
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	for _, track in self.Tracks do
		track:Stop(0)
		track:Destroy()
	end
	table.clear(self.Tracks)
	table.clear(self.Playing)
	if animatorsByRig[self.Rig] == self then
		animatorsByRig[self.Rig] = nil
	end
end

return RigAnimator
