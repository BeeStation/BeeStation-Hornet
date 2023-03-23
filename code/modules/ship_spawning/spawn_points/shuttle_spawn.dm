/obj/docking_port/stationary/spawn_point
	var/faction_allowed = NONE

/obj/docking_port/stationary/spawn_point/Initialize(mapload)
	. = ..()
	SSship_spawning.spawn_points += src

/obj/docking_port/stationary/spawn_point/proc/can_spawn_here(faction_tags)
	// All faction tags must be allowed to spawn here
	if ((faction_tags & faction_allowed) != faction_tags)
		return FALSE
	return TRUE
