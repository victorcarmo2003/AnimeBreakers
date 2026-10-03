--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lync = require(ReplicatedStorage.Packages.Lync)

return Lync.define("game", {
	Profile = Lync.packet(Lync.struct({
		Coins = Lync.int(0, 2147483647),
		Level = Lync.int(1, 1000),
		Playtime = Lync.f32(),
	})),

	Vitals = Lync.replicate(Lync.struct({
		Health = Lync.int(0, 100),
		Armor = Lync.int(0, 100),
		Stamina = Lync.int(0, 100),
	})),

	Round = Lync.packet(Lync.struct({
		Status = Lync.enum({ "Waiting", "Playing", "Ending" }),
		Seconds = Lync.int(0, 3600),
	})),

	Ready = Lync.packet(Lync.empty()),
})
