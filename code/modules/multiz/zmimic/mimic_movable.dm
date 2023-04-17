/atom/movable
	/// The mimic (if any) that's *directly* copying us.
	var/tmp/atom/movable/openspace/mimic/bound_overlay
	/// General MultiZ flags, not entirely related to zmimic but better than using obj_flags
	var/z_flags = NONE
	/// Movable-level Z-Mimic flags. This uses ZMM_* flags, not ZM_* flags.
	var/zmm_flags = NONE

/atom/movable/setDir(ndir)
	. = ..()
	if (. && bound_overlay)
		bound_overlay.setDir(ndir)

/atom/movable/update_above()
	if (!bound_overlay || !isturf(loc))
		return

	if (MOVABLE_IS_BELOW_ZTURF(src))
		SSzcopy.queued_overlays += bound_overlay
		bound_overlay.queued += 1
	else if (bound_overlay && !bound_overlay.destruction_timer)
		bound_overlay.destruction_timer = QDEL_IN(bound_overlay, 10 SECONDS)

// Grabs a list of every openspace mimic that's directly or indirectly copying this object. Returns an empty list if none found.
/atom/movable/proc/get_associated_mimics()
	. = list()
	var/atom/movable/curr = src
	while (curr.bound_overlay)
		. += curr.bound_overlay
		curr = curr.bound_overlay

// -- Openspace movables --

/atom/movable/openspace
	name = ""
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/openspace/ex_act(severity, target)
	return

/atom/movable/openspace/singularity_act()
	return

/atom/movable/openspace/singularity_pull()
	return

/atom/movable/openspace/attackby(obj/item/W, mob/user, params)
	return

/atom/movable/openspace/fire_act(exposed_temperature, exposed_volume)
	return

/atom/movable/openspace/acid_act()
	return

/atom/movable/openspace/mech_melee_attack(obj/mecha/M)
	return 0

/atom/movable/openspace/blob_act(obj/structure/blob/B)
	return

/atom/movable/openspace/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	return 0

/atom/movable/openspace/experience_pressure_difference()
	return

/atom/movable/openspace/ex_act(severity, target)
	return

/atom/movable/openspace/singularity_pull()
	return

/atom/movable/openspace/singularity_act()
	return

/atom/movable/openspace/has_gravity(turf/T)
	return FALSE

// -- MULTIPLIER / SHADOWER --

// Holder object used for dimming openspaces & copying lighting of below turf.
/atom/movable/openspace/multiplier
	name = "openspace multiplier"
	desc = "You shouldn't see this."
	icon = LIGHTING_ICON
	icon_state = "dark"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ZMIMIC_MAX_PLANE
	layer = MIMICKED_LIGHTING_LAYER
	blend_mode = BLEND_MULTIPLY
	color = SHADOWER_DARKENING_COLOR

/atom/movable/openspace/multiplier/Destroy(force)
	if(!force)
		stack_trace("Turf shadower improperly qdel'd.")
		return QDEL_HINT_LETMELIVE
	var/turf/myturf = loc
	if (istype(myturf))
		myturf.shadower = null

	return ..()

/atom/movable/openspace/multiplier/proc/copy_lighting(atom/movable/lighting_object/LO, area/A)
	ASSERT(LO != null)
	// Underlay lighting stuff, if it gets ported: appearance = LO.current_underlay
	appearance = LO
	layer = MIMICKED_LIGHTING_LAYER
	plane = ZMIMIC_MAX_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = 0
	if (islist(color))
		// We're using a color matrix, so just darken the colors across the board.
		var/list/c_list = color
		if(A?.lighting_overlay)
			c_list[CL_MATRIX_CR] = A.lighting_overlay_matrix_cr
			c_list[CL_MATRIX_CG] = A.lighting_overlay_matrix_cg
			c_list[CL_MATRIX_CB] = A.lighting_overlay_matrix_cb
		c_list = color_matrix_multiply_fixed(c_list, SHADOWER_DARKENING_FACTOR)
		color = c_list
	else
		// Not a color matrix, so we can just use the color var ourselves.
		if(A?.lighting_overlay)
			if(!islist(A.lighting_overlay_cached_darkening_matrix))
				var/list/c_list = color_hex2color_matrix(SHADOWER_DARKENING_COLOR)
				c_list[CL_MATRIX_CR] = A.lighting_overlay_matrix_cr
				c_list[CL_MATRIX_CG] = A.lighting_overlay_matrix_cg
				c_list[CL_MATRIX_CB] = A.lighting_overlay_matrix_cb
				A.lighting_overlay_cached_darkening_matrix = c_list
			color = A.lighting_overlay_cached_darkening_matrix
		else
			color = SHADOWER_DARKENING_COLOR
	UPDATE_OO_IF_PRESENT

/proc/color_matrix_multiply_fixed(list/c_list, factor)
	c_list[CL_MATRIX_RR] *= factor
	c_list[CL_MATRIX_RG] *= factor
	c_list[CL_MATRIX_RB] *= factor
	c_list[CL_MATRIX_GR] *= factor
	c_list[CL_MATRIX_GG] *= factor
	c_list[CL_MATRIX_GB] *= factor
	c_list[CL_MATRIX_BR] *= factor
	c_list[CL_MATRIX_BG] *= factor
	c_list[CL_MATRIX_BB] *= factor
	c_list[CL_MATRIX_AR] *= factor
	c_list[CL_MATRIX_AG] *= factor
	c_list[CL_MATRIX_AB] *= factor
	return c_list

//! -- OPENSPACE MIMIC --
/// Object used to hold a mimiced atom's appearance.
/atom/movable/openspace/mimic
	plane = ZMIMIC_MAX_PLANE
	var/atom/movable/associated_atom
	var/depth
	var/queued = 0
	var/destruction_timer
	var/mimiced_type
	var/original_z
	var/override_depth
	var/have_performed_fixup = FALSE

/atom/movable/openspace/mimic/New()
	flags_1 |= INITIALIZED_1
	SSzcopy.openspace_overlays += 1

/atom/movable/openspace/mimic/Destroy()
	SSzcopy.openspace_overlays -= 1
	queued = 0
	if (associated_atom)
		associated_atom.bound_overlay = null
		associated_atom = null
	if (destruction_timer)
		deltimer(destruction_timer)
	return ..()

/atom/movable/openspace/mimic/attackby(obj/item/W, mob/user)
	to_chat(user, "<span class='notice'>\The [src] is too far away.</span>")
	return TRUE

/atom/movable/openspace/mimic/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>You cannot reach \the [src] from here.</span>")
	return TRUE

/atom/movable/openspace/mimic/examine(...)
	SHOULD_CALL_PARENT(FALSE)
	. = associated_atom.examine(arglist(args))	// just pass all the args to the copied atom

/atom/movable/openspace/mimic/forceMove(turf/dest)
	. = ..()
	if (MOVABLE_IS_BELOW_ZTURF(associated_atom))
		if (destruction_timer)
			deltimer(destruction_timer)
			destruction_timer = null
	else if (!destruction_timer)
		destruction_timer = QDEL_IN(src, 10 SECONDS)

// Called when the turf we're on is deleted/changed.
/atom/movable/openspace/mimic/proc/owning_turf_changed()
	if (!destruction_timer)
		destruction_timer = QDEL_IN(src, 10 SECONDS)

// -- TURF PROXY --
// This thing holds the mimic appearance for non-OVERWRITE turfs.
/atom/movable/openspace/turf_proxy
	plane = ZMIMIC_MAX_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	zmm_flags = ZMM_IGNORE  // Only one of these should ever be visible at a time, the mimic logic will handle that.

/atom/movable/openspace/turf_proxy/attackby(obj/item/W, mob/user)
	return loc.attackby(W, user)

/atom/movable/openspace/turf_proxy/attack_hand(mob/user as mob)
	return loc.attack_hand(user)

/atom/movable/openspace/turf_proxy/examine(mob/examiner)
	SHOULD_CALL_PARENT(FALSE)
	. = loc.examine(examiner)


// -- TURF MIMIC --
// A type for copying non-overwrite turfs' self-appearance.
/atom/movable/openspace/turf_mimic
	plane = ZMIMIC_MAX_PLANE	// These *should* only ever be at the top?
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/turf/delegate

/atom/movable/openspace/turf_mimic/Initialize(mapload, ...)
	. = ..()
	ASSERT(isturf(loc))
	delegate = loc:below

/atom/movable/openspace/turf_mimic/attackby(obj/item/W, mob/user)
	loc.attackby(W, user)

/atom/movable/openspace/turf_mimic/attack_hand(mob/user as mob)
	to_chat(user, "<span class='notice'>You cannot reach \the [src] from here.</span>")
	return TRUE

/atom/movable/openspace/turf_mimic/examine(mob/examiner)
	SHOULD_CALL_PARENT(FALSE)
	. = delegate.examine(examiner)
