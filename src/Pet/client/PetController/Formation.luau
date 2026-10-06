const Formation = {}

const FOLLOW_OFFSETS: { Vector3 } = {
	Vector3.new(0, 0, 5),
	Vector3.new(-4, 0, 4),
	Vector3.new(4, 0, 4),
	Vector3.new(-2.5, 0, 8.5),
	Vector3.new(2.5, 0, 8.5),
	Vector3.new(-6.5, 0, 8),
	Vector3.new(6.5, 0, 8),
	Vector3.new(0, 0, 12),
}

const MIN_RING_SLOTS = 6
const FOLLOW_SHARPNESS = 8
const TURN_DISTANCE = 0.5

Formation.RunDistance = 1

local function flatBasis(origin: CFrame): CFrame
	const look = origin.LookVector
	const flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 1e-3 then
		return CFrame.new(origin.Position)
	end
	return CFrame.lookAt(origin.Position, origin.Position + flat.Unit)
end

function Formation.FollowOffset(slot: number): Vector3
	const offset = FOLLOW_OFFSETS[slot]
	if offset then
		return offset
	end
	return Vector3.new(0, 0, 4 + slot * 2)
end

function Formation.FollowCFrame(ownerRoot: CFrame, slot: number): CFrame
	return flatBasis(ownerRoot) * CFrame.new(Formation.FollowOffset(slot))
end

function Formation.RingAngle(ring: number, count: number): number
	return ring * 2 * math.pi / math.max(count, MIN_RING_SLOTS)
end

function Formation.RingCFrame(center: CFrame, ring: number, count: number, radius: number): CFrame
	const direction = (flatBasis(center) * CFrame.Angles(0, Formation.RingAngle(ring, count), 0)).LookVector
	const position = center.Position + direction * radius
	return CFrame.lookAt(position, Vector3.new(center.X, position.Y, center.Z))
end

function Formation.AtHeight(goal: CFrame, height: number): CFrame
	return goal + Vector3.new(0, height - goal.Y, 0)
end

function Formation.Approach(current: CFrame, goal: CFrame, dt: number, maxSpeed: number): CFrame
	const offset = goal.Position - current.Position
	const flat = Vector3.new(offset.X, 0, offset.Z)
	const facing = if flat.Magnitude > TURN_DISTANCE
		then CFrame.lookAt(goal.Position, goal.Position + flat.Unit)
		else goal
	const alpha = 1 - math.exp(-FOLLOW_SHARPNESS * dt)
	const blended = current:Lerp(facing, alpha)
	const step = blended.Position - current.Position
	const maxStep = maxSpeed * dt
	if step.Magnitude <= maxStep then
		return blended
	end
	return blended.Rotation + current.Position + step.Unit * maxStep
end

return Formation
