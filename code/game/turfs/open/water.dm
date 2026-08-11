/turf/open/water
	gender = PLURAL
	name = "water"
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/water
	planetary_atmos = TRUE
	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	/// Whether the immerse element has been added yet or not
	var/immerse_added = FALSE
	///The transparency of the immerse element's overlay
	var/immerse_overlay_alpha = 180
	///Icon state to use for the immersion mask
	var/immerse_overlay = "immerse"

/turf/open/water/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_inited))

///We lazily add the immerse element when something is spawned or crosses this turf and not before.
/turf/open/water/proc/on_atom_inited(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	make_immersed(movable)

/**
 * turf/Initialize() calls Entered on its contents too, however
 * we need to wait for movables that still need to be initialized
 * before we add the immerse element.
 */
/turf/open/water/Entered(atom/movable/arrived)
	. = ..()
	make_immersed(arrived)

///Makes this turf immersable, return true if we actually did anything so child procs don't have to repeat our checks
/turf/open/water/proc/make_immersed(atom/movable/triggering_atom)
	if(immerse_added || is_type_in_typecache(triggering_atom, GLOB.immerse_ignored_movable))
		return FALSE
	AddElement(/datum/element/immerse, immerse_overlay, immerse_overlay_alpha)
	immerse_added = TRUE
	return TRUE

/turf/open/water/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	return ..()

/turf/open/water/red
	icon_state = "abyssal_water"

/turf/open/water/air
	planetary_atmos = FALSE

