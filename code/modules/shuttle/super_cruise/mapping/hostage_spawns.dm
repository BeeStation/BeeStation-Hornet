/obj/effect/hostage_spawn
	name = "hostage spawn point"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/hostage_spawn/Initialize(mapload)
	. = ..()
	. = INITIALIZE_HINT_LATELOAD

/obj/effect/hostage_spawn/LateInitialize()
	//Register ourselfs to the shuttle we are on board
	var/area/shuttle/A = get_area(src)
	//Initialized in an invalid location
	if(!istype(A))
		qdel(src)
		return
	//Add it to a global list
	SSorbits.hostage_spawns += src

/obj/effect/hostage_spawn/Destroy(force)
	SSorbits.hostage_spawns -= src
	. = ..()

/obj/effect/hostage_spawn/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	. = ..()
	//Force delete this if moved to another location that isn't transit
	if (!is_reserved_level(newT))
		qdel(src, TRUE)

/obj/effect/hostage_loot_point
	name = "hostage loot spawn point"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x3"
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/datum/outfit/hostage
	name = "Hostage"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	//Give them a map to have something to watch
	l_pocket = /obj/item/navigation_map
	//Give them a radio to beg for help when the ship interdicts someone
	r_pocket = /obj/item/radio
