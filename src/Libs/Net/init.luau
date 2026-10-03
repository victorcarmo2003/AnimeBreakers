local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lync = require(ReplicatedStorage.Packages.Lync)

return Lync.define("game", {
	Profile = Lync.packet(Lync.struct({
		Coins = Lync.int(0, 2147483647),
		Level = Lync.int(1, 1000),
		Playtime = Lync.f32(),
	})),

	Ready = Lync.packet(Lync.empty()),
})
