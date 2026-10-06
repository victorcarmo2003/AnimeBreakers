--!strict

local StarterPlayer = game:GetService("StarterPlayer")

return {
	StarterPlayer.StarterPlayerScripts.client.Effect.EffectController,
	StarterPlayer.StarterPlayerScripts.client.Enemy.EnemyController,
	StarterPlayer.StarterPlayerScripts.client.Input.InputController,
	StarterPlayer.StarterPlayerScripts.client.Net.NetController,
	StarterPlayer.StarterPlayerScripts.client.Profile.ProfileController,
} :: { ModuleScript }
