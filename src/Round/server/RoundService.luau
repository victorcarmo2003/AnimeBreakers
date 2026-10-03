--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Charm = require(ReplicatedStorage.Packages.Charm)
local Lync = require(ReplicatedStorage.Packages.Lync)
local Modux = require(ServerScriptService.server.Modux)

export type Status = "Waiting" | "Playing" | "Ending"

const INTERMISSION = 15
const ROUND = 120
const ENDING = 5

const RoundService = Modux.Service("RoundService", { Require = { "NetService", "VitalService" }, Priority = 600 })

function RoundService:Setup()
	self.Status = self.Libs.Charm.atom("Waiting") :: Charm.Atom<Status>
	self.Seconds = self.Libs.Charm.atom(INTERMISSION) :: Charm.Atom<number>
end

function RoundService:Enter(status: Status, seconds: number)
	self.Libs.Charm.batch(function()
		self.Status(status)
		self.Seconds(seconds)
	end)
end

function RoundService:Advance()
	const status = self.Status()
	if status == "Waiting" then
		self:Enter("Playing", ROUND)
	elseif status == "Playing" then
		self:Enter("Ending", ENDING)
	else
		self:Enter("Waiting", INTERMISSION)
	end
end

function RoundService:Publish(to: Lync.Recipient)
	if not self.Dependencies.NetService:IsRunning() then
		return
	end
	self.Libs.Net.Round:fireClient(to, {
		Status = self.Status(),
		Seconds = self.Seconds(),
	})
end

RoundService:OnInit(function(self)
	self:Setup()
end)

RoundService:OnStart(function(self)
	self.Dependencies.NetService.ClientReady:Connect(function(player)
		self:Publish(player)
	end)

	self.Libs.Charm.effect(function()
		self:Publish(self.Dependencies.NetService.Audience)
	end)
end)

RoundService:OnTick(function(self)
	const remaining = self.Seconds() - 1
	if remaining > 0 then
		self.Seconds(remaining)
		return
	end
	self:Advance()
end, 1)

return RoundService
