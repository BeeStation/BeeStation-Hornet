/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon_state = "m_shield"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	can_atmos_pass = ATMOS_PASS_DENSITY
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	/// If set, how long the force field lasts after it's created. Set to 0 to have infinite duration forcefields.
	var/initial_duration = 30 SECONDS

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/forcefield)

/obj/effect/forcefield/Initialize(mapload, ntimeleft)
	. = ..()
	if(initial_duration > 0 SECONDS)
		QDEL_IN(src, initial_duration)

/obj/effect/forcefield/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return

/// The wizard's forcefield, summoned by forcewall
/obj/effect/forcefield/wizard
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE
	/// A weakref to whoever casted our forcefield.
	var/datum/weakref/caster_weakref

/obj/effect/forcefield/wizard/Initialize(mapload, mob/caster, flags = MAGIC_RESISTANCE)
	. = ..()
	if(caster)
		caster_weakref = WEAKREF(caster)
	antimagic_flags = flags

/obj/effect/forcefield/wizard/CanAllowThrough(atom/movable/mover, border_dir)
	if(IS_WEAKREF_OF(mover, caster_weakref))
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.can_block_magic(antimagic_flags))
			return TRUE

	return ..()

/obj/effect/forcefield/cult
	desc = "An unholy shield that blocks all attacks."
	name = "glowing wall"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "cultshield"
	can_atmos_pass = ATMOS_PASS_NO
	initial_duration = 20 SECONDS

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = "nothing"
	name = "invisible wall"
	desc = "You have a bad feeling about this."

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You're gonna be here awhile."
	initial_duration = 1 MINUTES

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/forcefield/mime)

/obj/effect/forcefield/mime/Initialize(mapload, ntimeleft)
	. = ..()
	SSvis_overlays.add_obj_alpha(src, 'icons/turf/walls/snow_wall.dmi', "snow_wall-0")
