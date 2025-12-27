// Thruster jet emitter for orbital thrusters
/obj/emitter/thruster_jet
	alpha = 225
	particles = new /particles/thruster_jet

/obj/emitter/thruster_jet/Initialize(mapload)
	. = ..()
	// Blue-cyan-purple glow filters instead of orange
	add_filter("bloom", 2, list(type = "bloom", threshold = rgb(199, 255, 254), size = 6, offset = 3, alpha = 150))
