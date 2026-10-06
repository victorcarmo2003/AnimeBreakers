--!strict

local ServerScriptService = game:GetService("ServerScriptService")

return {
	ServerScriptService.server.Content.ContentService,
	ServerScriptService.server.Dev.DevService,
	ServerScriptService.server.Enemy.EnemyDevService,
	ServerScriptService.server.Enemy.EnemyService,
	ServerScriptService.server.Enemy.EnemySpawn,
	ServerScriptService.server.Net.NetService,
	ServerScriptService.server.Pet.PetService,
	ServerScriptService.server.Player.PlayerService,
	ServerScriptService.server.Profile.ProfileService,
} :: { ModuleScript }
