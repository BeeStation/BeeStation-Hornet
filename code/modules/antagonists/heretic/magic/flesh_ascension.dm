/datum/action/spell/shapeshift/shed_human_form
	name = "Shed form"
	desc = "Shed your fragile form, become one with the arms, become one with the emperor. \
		Causes heavy amounts of brain damage and sanity loss to nearby mortals."
	background_icon_state = "bg_heretic"
	button_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "worm_ascend"

	school = SCHOOL_FORBIDDEN

	invocation = "REALITY UNCOIL!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	convert_damage = FALSE // Functionally meaningless on Armsy, we track how many segments it had instead
	possible_shapes = list(/mob/living/simple_animal/hostile/heretic_summon/armsy/prime)

	/// The length of our new wormy when we shed.
	var/segment_length = 10
	/// The radius around us that we cause brain damage / sanity damage to.
	var/scare_radius = 9

/datum/action/spell/shapeshift/shed_human_form/do_shapeshift(mob/living/caster)
	// When we transform into the worm, everyone nearby gets freaked out
	for(var/mob/living/carbon/human/nearby_human in view(scare_radius, caster))
		if(IS_HERETIC_OR_MONSTER(nearby_human) || nearby_human == caster)
			continue

		// 25% chance to cause a trauma
		if(prob(25))
			var/datum/brain_trauma/trauma = pick(subtypesof(BRAIN_TRAUMA_MILD) + subtypesof(BRAIN_TRAUMA_SEVERE))
			nearby_human.gain_trauma(trauma, TRAUMA_RESILIENCE_LOBOTOMY)
		// And a negative moodlet
		SEND_SIGNAL(nearby_human, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

	return ..()

/datum/action/spell/shapeshift/shed_human_form/do_unshapeshift(mob/living/simple_animal/hostile/heretic_summon/armsy/caster)
	if(istype(caster))
		segment_length = caster.get_length()

	return ..()

/datum/action/spell/shapeshift/shed_human_form/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc, TRUE, segment_length)

/datum/action/spell/worm_contract
	name = "Force Contract"
	desc = "Forces your body to contract onto a single tile."
	background_icon_state = "bg_heretic"
	button_icon = 'icons/hud/actions/actions_ecult.dmi'
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
