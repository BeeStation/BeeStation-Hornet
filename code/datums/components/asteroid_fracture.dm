/datum/component/asteroid_fracture
	var/cavity_opened = FALSE
	var/setup = FALSE
	var/broken = FALSE
	var/list/linked_fractures = list()
	var/turf/center
	var/width
	var/height
	var/list/asteroid_biome
	var/list/asteroid_ore_list

/datum/component/asteroid_fracture/Initialize(turf/center_turf, width, height, asteroid_biome, asteroid_ore_list)
	. = ..()
	if (!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	src.width = width
	src.height = height
	src.center = center_turf
	src.asteroid_biome = asteroid_biome
	src.asteroid_ore_list = asteroid_ore_list
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(on_explosion))
	RegisterSignal(parent, COMSIG_POST_TURF_CHANGE, PROC_REF(on_turf_change))
	on_turf_change(parent, parent.type, null, null, null)

/datum/component/asteroid_fracture/Destroy(force, silent)
	// Break this fracture
	for (var/datum/component/asteroid_fracture/other_fracture in linked_fractures)
		other_fracture.linked_fractures -= src
	break_fracture()
	message_admins("fracture destroy called")
	return ..()

/datum/component/asteroid_fracture/proc/on_turf_change(datum/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	// We are already setup, this just means we were broken
	if (setup)
		message_admins("Deleting fracture")
		qdel(src)
		return
	// The fracture is now ready to go
	// This would be better if it used overlays in all honesty
	if (ispath(path, /turf/open/floor/plating/asteroid/rupture))
		message_admins("Setup fracture")
		setup = TRUE
	// If we were changed to any other rupture turf, replace it
	else if (ispath(path, /turf/open/floor/plating/asteroid))
		// This will retrigger this proc
		var/turf/T = parent
		message_admins("Changing fracture")
		T.ChangeTurf(/turf/open/floor/plating/asteroid/rupture, flags = CHANGETURF_IGNORE_AIR)

/datum/component/asteroid_fracture/proc/on_explosion(datum/source, severity, atom/target)
	SIGNAL_HANDLER
	message_admins("fracture exploded")
	// If this is an open turf, break the fracture
	break_fracture()

/datum/component/asteroid_fracture/proc/break_fracture()
	broken = TRUE
	check_broken()

/datum/component/asteroid_fracture/proc/check_broken()
	if (!broken || cavity_opened)
		return FALSE
	for (var/datum/component/asteroid_fracture/fracture in linked_fractures)
		if (!fracture.broken)
			return FALSE
	for (var/datum/component/asteroid_fracture/fracture in linked_fractures)
		fracture.cavity_opened = TRUE
	message_admins("cavity opened")
	// Open the cavity
	INVOKE_ASYNC(src, PROC_REF(open_cavity))
	return TRUE

/datum/component/asteroid_fracture/proc/open_cavity()
	SSasteroid_generation.generate_asteroid_cavity(center, width, height, asteroid_biome, asteroid_ore_list)
