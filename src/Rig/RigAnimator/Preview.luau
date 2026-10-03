local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage.shared.Content)
local RigAnimator = require(script.Parent)

type TrackKey = Content.TrackKey

export type Report = {
	Key: TrackKey,
	Length: number,
	Speed: number,
	Duration: number,
	DurationOk: boolean,
	SeekRequested: number,
	SeekObserved: number,
	SeekOk: boolean,
}

const KEYS_BY_KIND: { [string]: { TrackKey } } = {
	Pet = { "Idle", "Run", "Assist", "Enter", "Combat1", "Combat2", "Skill", "BackOff" },
	Enemy = { "Idle", "Defend", "Hit", "HitHeavy", "Death", "Spawn" },
}

const DURATION_TOLERANCE = 0.05
const SEEK_TOLERANCE = 0.02
const LOAD_TIMEOUT = 5

local function waitForLength(track: AnimationTrack): number
	const started = os.clock()
	while track.Length <= 0 and os.clock() - started < LOAD_TIMEOUT do
		task.wait()
	end
	return track.Length
end

local function preview(rig: Model, animationSetKey: string?): { Report }
	const setKey = animationSetKey or Content.Character(rig.Name).AnimationSet
	const animationSet = Content.AnimationSet(setKey)
	const animator = RigAnimator.new(rig, animationSet)
	const reports: { Report } = {}

	for _, key in KEYS_BY_KIND[animationSet.Kind] do
		const definition = animationSet.Tracks[key]
		const track = animator:Load(key)
		if not definition or not track then
			warn(`[RigAnimator.Preview] {setKey}.{key} missing`)
			continue
		end

		const speed = definition.Speed or 1
		const length = waitForLength(track)
		const seekRequested = definition.Duration / 2
		animator:Play(key, { Seek = seekRequested, Fade = 0 })
		const seekObserved = track.TimePosition
		const expectedPosition = seekRequested * speed

		const report: Report = {
			Key = key,
			Length = length,
			Speed = speed,
			Duration = definition.Duration,
			DurationOk = math.abs(length / speed - definition.Duration) <= DURATION_TOLERANCE,
			SeekRequested = seekRequested,
			SeekObserved = seekObserved,
			SeekOk = math.abs(seekObserved - expectedPosition) <= SEEK_TOLERANCE,
		}
		table.insert(reports, report)

		const status = if report.DurationOk and report.SeekOk then "OK" else "FAIL"
		print(
			`[RigAnimator.Preview] {status} {setKey}.{key} length={string.format("%.3f", length)} speed={speed} duration={definition.Duration} seek={string.format("%.3f", seekObserved)}/{string.format("%.3f", expectedPosition)}`
		)

		task.wait(math.max(definition.Duration - seekRequested, 0.5))
		animator:Stop(key)
	end

	animator:StopAll()
	return reports
end

return preview
