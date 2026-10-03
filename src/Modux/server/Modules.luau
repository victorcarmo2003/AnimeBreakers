--!strict

local ServerScriptService = game:GetService("ServerScriptService")

return {
	ServerScriptService.server.Net.NetService,
	ServerScriptService.server.Player.PlayerService,
	ServerScriptService.server.Profile.ProfileService,
	ServerScriptService.server.Round.RoundService,
	ServerScriptService.server.Vital.Vital,
	ServerScriptService.server.Vital.VitalService,
} :: { ModuleScript }
