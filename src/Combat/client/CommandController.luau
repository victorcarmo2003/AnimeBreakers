local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Content = require(ReplicatedStorage.shared.Content)
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)

const CommandController = Modux.Controller(
	"CommandController",
	{ Require = { "InputController", "EnemyController" }, Priority = 600 }
)

const PICK_RAY_LENGTH = 1024
const RECALL_ACTION = "Recall"
const RECALL_KEY = Enum.KeyCode.X
const RECALL_GAMEPAD_KEY = Enum.KeyCode.ButtonB

function CommandController:Setup()
	self.Target = Vide.source(nil) :: Vide.Source<number?>
	self.LastCommandAt = 0 :: number
	const pickParams = RaycastParams.new()
	pickParams.FilterType = Enum.RaycastFilterType.Include
	self.PickParams = pickParams :: RaycastParams
end

function CommandController:CurrentTarget(): number?
	const read = self.Target :: () -> number?
	return read()
end

function CommandController:CanCommand(): boolean
	const now = os.clock()
	if now - self.LastCommandAt < Content.Tuning.CommandMinInterval then
		return false
	end
	self.LastCommandAt = now
	return true
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

function CommandController:IsTargetActive(uid: number): boolean
	const alive = self.Dependencies.EnemyController:Alive(uid)
	return alive ~= nil and alive()
end

function CommandController:Attack(uid: number)
	if not self:CanCommand() then
		return
	end
	self.Target(uid)
	self.Libs.Net.Attack:fireServer({ Enemy = uid })
end

function CommandController:Recall()
	if not self:CanCommand() then
		return
	end
	self.Target(nil)
	self.Libs.Net.Recall:fireServer()
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
	Vide.root(function()
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
	end)
end

function CommandController:BindRecall()
	const inputController = self.Dependencies.InputController
	inputController:Bind({
		Name = RECALL_ACTION,
		Key = RECALL_KEY,
		Keys = { RECALL_GAMEPAD_KEY },
	}).OnPress(function()
		if inputController.Context == "Gameplay" then
			self:Recall()
		end
	end)
end

CommandController:OnInit(function(self)
	self:Setup()
end)

CommandController:OnStart(function(self)
	self:WatchTargetDeath()
	self:BindRecall()
	self.Dependencies.InputController:OnWorldTap(function(screenPosition: Vector2)
		self:OnWorldTap(screenPosition)
	end)
end)

return CommandController
