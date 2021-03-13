GLOBAL_LIST(br_spawns)

/obj/effect/landmark/battle_royale
	name = "Battle Royale Spawn"

/obj/effect/landmark/battle_royale/Initialize()
	. = ..()
	if(!GLOB.br_spawns)
		GLOB.br_spawns = list()
	GLOB.br_spawns += src
