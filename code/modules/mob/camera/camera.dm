// Camera mob, used by AI camera and blob.

/mob/camera
	name = "camera mob"
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	status_flags = GODMODE  // You can't damage it.
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	see_in_dark = 7
	invisibility = INVISIBILITY_ABSTRACT // No one can see us. Use 'INVISIBILITY_OBSERVER' for subtypes
	sight = SEE_SELF
	move_on_shuttle = FALSE
	/// Only used at init, assigning to this will do nothing after the camera is initialized
	var/can_hear_init = FALSE

/mob/camera/Initialize(mapload)
	. = ..()
	if(!can_hear_init)
		// Cameras should not be able to hear by default despite being mobs
		REMOVE_TRAIT(src, TRAIT_HEARING_SENSITIVE, TRAIT_GENERIC)

/mob/camera/experience_pressure_difference()
	return

/mob/camera/canUseStorage()
	return FALSE

/mob/camera/emote(act, m_type=1, message = null, intentional = FALSE)
	return

// Cameras can't fall
/mob/camera/has_gravity(turf/T)
	return FALSE
