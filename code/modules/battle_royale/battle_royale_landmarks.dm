GLOBAL_LIST(br_spawns)

/obj/effect/landmark/battle_royale
	name = "Battle Royale Spawn"

/obj/effect/landmark/battle_royale/Initialize()
	. = ..()
	if(!GLOB.br_spawns)
		GLOB.br_spawns = list()
	GLOB.br_spawns += src

GLOBAL_LIST(br_lootdrop)

/obj/effect/landmark/battle_royale_Loot
	name = "Battle Royale Loot Spawn"

/obj/effect/landmark/battle_royale_Loot/Initialize()
	. = ..()
	if(!GLOB.br_lootdrop)
		GLOB.br_lootdrop = list()
	GLOB.br_lootdrop += src

