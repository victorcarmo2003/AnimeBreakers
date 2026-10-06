local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Theme = require(script.Parent.Parent.Interface.Components.Theme)

const create = Vide.create
const spring = Vide.spring

export type Props = {
	Health: () -> number,
	MaxHealth: () -> number,
	Name: string,
	Boss: boolean?,
	Visible: (() -> boolean)?,
}

export type BillboardProps = Props & {
	Parent: Instance?,
	MaxDistance: number?,
}

type Layout = {
	Width: number,
	BarHeight: number,
	NameHeight: number,
	TextSize: number,
	NameTextSize: number,
}

const NORMAL_LAYOUT: Layout = {
	Width = 160,
	BarHeight = 22,
	NameHeight = 0,
	TextSize = 14,
	NameTextSize = 0,
}

const BOSS_LAYOUT: Layout = {
	Width = 280,
	BarHeight = 30,
	NameHeight = 26,
	TextSize = 18,
	NameTextSize = 22,
}

const TRACK_COLOR = Color3.fromRGB(28, 28, 34)
const TRAIL_COLOR = Color3.fromRGB(255, 236, 200)
const HIGH_COLOR = Color3.fromRGB(88, 214, 104)
const MID_COLOR = Color3.fromRGB(240, 196, 64)
const LOW_COLOR = Color3.fromRGB(228, 72, 64)
const BOSS_FILL_COLOR = Color3.fromRGB(200, 52, 92)
const BOSS_NAME_COLOR = Color3.fromRGB(255, 208, 92)
const OUTLINE_COLOR = Color3.fromRGB(10, 10, 14)
const FILL_SPRING_PERIOD = 0.12
const TRAIL_SPRING_PERIOD = 0.6
const VERTICAL_LIFT = 0.6

local function layoutOf(boss: boolean): Layout
	return if boss then BOSS_LAYOUT else NORMAL_LAYOUT
end

local function fillColor(ratio: number, boss: boolean): Color3
	if boss then
		return BOSS_FILL_COLOR
	end
	if ratio > 0.5 then
		return MID_COLOR:Lerp(HIGH_COLOR, (ratio - 0.5) * 2)
	end
	return LOW_COLOR:Lerp(MID_COLOR, ratio * 2)
end

local function formatAmount(amount: number): string
	if amount >= 1e6 then
		return string.format("%.1fM", amount / 1e6)
	end
	if amount >= 1e4 then
		return string.format("%.1fK", amount / 1e3)
	end
	return tostring(math.floor(amount))
end

local function stroke(thickness: number): UIStroke
	const instance = Instance.new("UIStroke")
	instance.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	instance.Color = OUTLINE_COLOR
	instance.Thickness = thickness
	return instance
end

local function bar(props: Props): Frame
	const boss = props.Boss == true
	const layout = layoutOf(boss)

	const ratio = function(): number
		const maximum = props.MaxHealth()
		if maximum <= 0 then
			return 0
		end
		return math.clamp(props.Health() / maximum, 0, 1)
	end

	const fillSize = spring(function(): UDim2
		return UDim2.fromScale(ratio(), 1)
	end, FILL_SPRING_PERIOD)

	const trailSize = spring(function(): UDim2
		return UDim2.fromScale(ratio(), 1)
	end, TRAIL_SPRING_PERIOD)

	const nameLabel = if boss
		then create("TextLabel")({
			Name = "BossName",
			Size = UDim2.new(1, 0, 0, layout.NameHeight),
			BackgroundTransparency = 1,
			Font = Theme.Font,
			TextSize = layout.NameTextSize,
			TextColor3 = BOSS_NAME_COLOR,
			TextStrokeTransparency = 0,
			TextStrokeColor3 = OUTLINE_COLOR,
			Text = props.Name,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		else nil

	return create("Frame")({
		Name = "HealthBar",
		Size = UDim2.fromOffset(layout.Width, layout.NameHeight + layout.BarHeight),
		BackgroundTransparency = 1,
		Visible = props.Visible,

		nameLabel,

		create("Frame")({
			Name = "Track",
			Position = UDim2.fromOffset(0, layout.NameHeight),
			Size = UDim2.new(1, 0, 0, layout.BarHeight),
			BackgroundColor3 = TRACK_COLOR,
			ClipsDescendants = true,

			create("UICorner")({ CornerRadius = UDim.new(0, 6) }),
			stroke(if boss then 3 else 2),

			create("Frame")({
				Name = "Trail",
				Size = trailSize,
				BackgroundColor3 = TRAIL_COLOR,
				BorderSizePixel = 0,
				ZIndex = 1,
				create("UICorner")({ CornerRadius = UDim.new(0, 6) }),
			}),

			create("Frame")({
				Name = "Fill",
				Size = fillSize,
				BackgroundColor3 = function(): Color3
					return fillColor(ratio(), boss)
				end,
				BorderSizePixel = 0,
				ZIndex = 2,
				create("UICorner")({ CornerRadius = UDim.new(0, 6) }),
			}),

			create("TextLabel")({
				Name = "Amount",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 3,
				Font = Theme.Font,
				TextSize = layout.TextSize,
				TextColor3 = Theme.TextColor,
				TextStrokeTransparency = 0,
				TextStrokeColor3 = OUTLINE_COLOR,
				Text = function(): string
					return `{formatAmount(math.max(props.Health(), 0))} / {formatAmount(props.MaxHealth())}`
				end,
			}),
		}),
	})
end

local function billboard(props: BillboardProps): BillboardGui
	const layout = layoutOf(props.Boss == true)
	const height = layout.NameHeight + layout.BarHeight

	return create("BillboardGui")({
		Name = "HealthBillboard",
		Size = UDim2.fromOffset(layout.Width, height),
		SizeOffset = Vector2.new(0, VERTICAL_LIFT),
		AlwaysOnTop = true,
		LightInfluence = 0,
		MaxDistance = props.MaxDistance or math.huge,
		Enabled = props.Visible,
		Parent = props.Parent,

		bar({
			Health = props.Health,
			MaxHealth = props.MaxHealth,
			Name = props.Name,
			Boss = props.Boss,
		}),
	})
end

return {
	Bar = bar,
	Billboard = billboard,
}
