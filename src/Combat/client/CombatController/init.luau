local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)
local Stage = require(script.Stage)

export type Beat = {
	Unit: number,
	Move: Content.Move,
}

const CombatController = Modux.Controller(
	"CombatController",
	{ Require = { "EnemyController", "PetController", "EffectController" }, Priority = 650 }
)

function CombatController:Setup()
	self.Stage = Stage.new({
		Pets = self.Dependencies.PetController,
		Enemies = self.Dependencies.EnemyController,
		Effects = self.Dependencies.EffectController,
	}) :: Stage.Stage
end

function CombatController:Owns(unitId: number): boolean
	return self.Stage:Owns(unitId)
end

function CombatController:OnBeat(beat: Beat, sent: number?)
	const now = Workspace:GetServerTimeNow()
	const late = if sent then math.max(now - sent, 0) else 0
	self.Stage:Play(beat.Unit, beat.Move, late, now)
end

function CombatController:ShareStage()
	const stage = self.Stage
	self.Dependencies.PetController:UseStage({
		Owns = function(_view, unitId: number): boolean
			return stage:Owns(unitId)
		end,
	})
end

CombatController:OnInit(function(self)
	self:Setup()

	self.Libs.Net.Beat:onClient(function(beat, sent)
		self:OnBeat(beat, sent)
	end)
end)

CombatController:OnStart(function(self)
	self:ShareStage()
end)

CombatController:OnTick(function(self)
	self.Stage:Step(Workspace:GetServerTimeNow())
end, 60)

return CombatController
