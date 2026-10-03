--!strict

local StarterPlayer = game:GetService("StarterPlayer")

return {
	StarterPlayer.StarterPlayerScripts.client.Input.InputController,
	StarterPlayer.StarterPlayerScripts.client.Net.NetController,
	StarterPlayer.StarterPlayerScripts.client.Profile.ProfileController,
	StarterPlayer.StarterPlayerScripts.client.Round.RoundController,
	StarterPlayer.StarterPlayerScripts.client.Vital.VitalController,
} :: { ModuleScript }
