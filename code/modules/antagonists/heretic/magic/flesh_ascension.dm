/datum/action/spell/shed_human_form
	name = "Shed form"
	desc = "Shed your fragile form, become one with the arms, become one with the emperor. \
		Causes heavy amounts of brain damage and sanity loss to nearby mortals."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "worm_ascend"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 10 SECONDS

	invocation = "REALITY UNCOIL!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	/// The length of our new wormy when we shed.
	var/segment_length = 10
	/// The radius around us that we cause brain damage / sanity damage to.
	var/scare_radius = 9

/datum/action/spell/shed_human_form/is_valid_spell(mob/user, atom/target)
	return isliving(user)

/datum/action/spell/shed_human_form/on_cast(mob/living/user, atom/target)
	. = ..()
	if(istype(user, /mob/living/simple_animal/hostile/heretic_summon/armsy/prime))
		var/mob/living/simple_animal/hostile/heretic_summon/armsy/prime/old_armsy = user
		var/mob/living/our_heretic = locate() in old_armsy

		if(our_heretic.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_ASCENSION_EFFECT))
			our_heretic.forceMove(old_armsy.loc)

		old_armsy.mind.transfer_to(our_heretic, TRUE)
		segment_length = old_armsy.get_length()
		qdel(old_armsy)

	else
		var/mob/living/simple_animal/hostile/heretic_summon/armsy/prime/new_armsy = new(user.loc, TRUE, segment_length)

		user.mind.transfer_to(new_armsy, TRUE)
		user.forceMove(new_armsy)
		user.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_ASCENSION_EFFECT)

		// They see the very reality uncoil before their eyes.
		for(var/mob/living/carbon/human/nearby_human in view(scare_radius, new_armsy))
			if(IS_HERETIC_OR_MONSTER(nearby_human))
				continue
			SEND_SIGNAL(nearby_human, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

			if(prob(25))
				var/datum/brain_trauma/trauma = pick(subtypesof(BRAIN_TRAUMA_MILD) + subtypesof(BRAIN_TRAUMA_SEVERE))
				nearby_human.gain_trauma(trauma, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/action/spell/worm_contract
	name = "Force Contract"
	desc = "Forces your body to contract onto a single tile."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "worm_contract"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

/datum/action/spell/worm_contract/is_valid_spell(mob/user, atom/target)
	return istype(user, /mob/living/simple_animal/hostile/heretic_summon/armsy)

/datum/action/spell/worm_contract/on_cast(mob/living/simple_animal/hostile/heretic_summon/armsy/user, atom/target)
	. = ..()
	user.contract_next_chain_into_single_tile()
