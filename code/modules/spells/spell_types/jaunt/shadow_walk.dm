/datum/action/spell/jaunt/shadow_walk
	name = "Shadow Walk"
	desc = "Grants unlimited movement in darkness."
	background_icon_state = "bg_alien"
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

	spell_requirements = NONE
	jaunt_type = /obj/effect/dummy/phased_mob/shadow

/datum/action/spell/jaunt/shadow_walk/on_cast(mob/living/user, atom/target)
	. = ..()
	if(is_jaunting(user))
		exit_jaunt(user)
		return

	var/turf/cast_turf = get_turf(user)
	if(cast_turf.get_lumcount() >= SHADOW_SPECIES_LIGHT_THRESHOLD)
		to_chat(user, ("<span class='warning'>It isn't dark enough here!</span>"))
		return

	playsound(cast_turf, 'sound/magic/ethereal_enter.ogg', 50, TRUE, -1)
	user.visible_message(("<span class='boldwarning'>[user] melts into the shadows!</span>"))
	user.SetAllImmobility(0)
	user.setStaminaLoss(0, FALSE)
	enter_jaunt(user)

/obj/effect/dummy/phased_mob/shadow
	name = "shadows"
	/// The amount that shadow heals us per SSobj tick (times delta_time)
	var/healing_rate = 1.5

/obj/effect/dummy/phased_mob/shadow/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/shadow/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/dummy/phased_mob/shadow/process(delta_time)
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(!jaunter || jaunter.loc != src)
		qdel(src)
		return

	if(check_light_level(T))
		eject_jaunter(TRUE)

	if(light_amount < 0.2 && !QDELETED(jaunter) && isliving(jaunter)) //heal in the dark
		var/mob/living/living_jaunter = jaunter
		living_jaunter.heal_overall_damage((healing_rate * delta_time), (healing_rate * delta_time), 0, BODYTYPE_ORGANIC)

/obj/effect/dummy/phased_mob/shadow/relaymove(mob/living/user, direction)
	var/turf/oldloc = loc
	. = ..()
	if(loc != oldloc && check_light_level(loc))
		eject_jaunter(TRUE)

/obj/effect/dummy/phased_mob/shadow/phased_check(mob/living/user, direction)
	. = ..()
	if(isspaceturf(.))
		to_chat(user, span_warning("It really would not be wise to go into space."))
		return FALSE
	if(check_light_level(.))
		return FALSE

/**
 * Checks the light level. If above the minimum acceptable amount (0.25), returns TRUE.
 * Arguments:
 * * location_to_check - The location to have its light level checked.
 */
/obj/effect/dummy/phased_mob/shadow/proc/check_light_level(atom/location_to_check)
	var/turf/light_turf = get_turf(location_to_check)
	return light_turf.get_lumcount() > SHADOW_SPECIES_LIGHT_THRESHOLD // jaunt ends on TRUE

/obj/effect/dummy/phased_mob/shadow/eject_jaunter(forced_out = FALSE)
	var/turf/reveal_turf = get_turf(src)

	if(istype(reveal_turf))
		if(forced_out)
			reveal_turf.visible_message(span_boldwarning("[jaunter] is revealed by the light!"))
		else
			reveal_turf.visible_message(span_boldwarning("[jaunter] emerges from the darkness!"))
		playsound(reveal_turf, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)

	return ..()
