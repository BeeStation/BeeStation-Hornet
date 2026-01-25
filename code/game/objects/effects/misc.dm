//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "strangepresent"
	density = TRUE
	anchored = FALSE

/obj/effect/beam
	name = "beam"
	var/def_zone
	pass_flags = PASSTABLE

/obj/effect/beam/singularity_act()
	return

/obj/effect/beam/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return

/obj/effect/spawner
	name = "object spawner"

// Brief explanation:
// Rather then setting up and then deleting spawners, we block all atomlike setup
// and do the absolute bare minimum
// This is with the intent of optimizing mapload
/obj/effect/spawner/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	moveToNullspace()
	return QDEL_HINT_QUEUE

/// Override to define loot blacklist behavior
/obj/effect/spawner/proc/can_spawn(atom/loot)
	return TRUE

/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/effect/overlay/thermite
	name = "thermite"
	desc = "Looks hot."
	icon = 'icons/effects/fire.dmi'
	icon_state = "medium" //what?
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	layer = FLY_LAYER

/obj/effect/overlay/thermite/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/overlay/thermite/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM))
		var/mob/living/L = AM
		L.adjust_fire_stacks(5)
		L.ignite_mob()

//Makes a tile fully lit no matter what
/obj/effect/fullbright
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_ADD

/obj/effect/fullbright/starlight
	plane = STARLIGHT_PLANE
	transform = matrix(2, 0, 0, 0, 2, 0)

/obj/effect/fullbright/starlight/starfloor
	icon_state = "grey"
	transform = matrix(1.5, 0, 0, 0, 1.5, 0)

/obj/effect/abstract/marker
	name = "marker"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	icon_state = "wave3"
	layer = RIPPLE_LAYER

/obj/effect/abstract/marker/Initialize(mapload)
	. = ..()
	GLOB.all_abstract_markers += src

/obj/effect/abstract/marker/Destroy()
	GLOB.all_abstract_markers -= src
	. = ..()

/obj/effect/abstract/marker/at
	name = "active turf marker"

/obj/effect/abstract/directional_lighting
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
