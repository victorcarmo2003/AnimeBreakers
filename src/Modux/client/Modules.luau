--!strict

local StarterPlayer = game:GetService("StarterPlayer")

return {
	StarterPlayer.StarterPlayerScripts.client.Combat.CommandController,
	StarterPlayer.StarterPlayerScripts.client.Effect.EffectController,
	StarterPlayer.StarterPlayerScripts.client.Enemy.EnemyController,
	StarterPlayer.StarterPlayerScripts.client.Input.InputController,
	StarterPlayer.StarterPlayerScripts.client.Net.NetController,
	StarterPlayer.StarterPlayerScripts.client.Pet.PetController,
	StarterPlayer.StarterPlayerScripts.client.Profile.ProfileController,
} :: { ModuleScript }
