/datum/discipline/fortitude
	name = "Fortitude"
	discipline_explanation = "Fortitude is a Discipline that grants Kindred unearthly toughness."
	icon_state = "fortitude"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/fortitude)
	level_2 = list(/datum/action/vampire/fortitude/two)
	level_3 = list(/datum/action/vampire/fortitude/three)
	level_4 = list(/datum/action/vampire/fortitude/four)
	level_5 = null

/**
 *	FORTITUDE
 *	All levels: Incrementally increasing brute and stamina resistance.
 *	Level 1: Pierce resistance
 * 	Level 2: Push immunity
 * 	Level 3: Dismember resistance
 * 	Level 4: Complete stun immunity
 */

/datum/action/vampire/fortitude
	name = "Fortitude"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_fortitude"
	power_explanation = "Grants increasing levels of brute and stamina resistance, as well as various immunities to physical harm.\n\
						At level 1: Gain pierce resistance.\n\
						At level 2: Gain push immunity.\n\
						At level 3: Gain dismember resistance.\n\
						At level 4: Gain complete stun immunity."
	power_flags = BP_AM_TOGGLE | BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED
	vitaecost = 50
	cooldown_time = 5 SECONDS
	constant_vitaecost = 1

	var/resistance = 0.8

	// Flags for what immunities to turn on at which level
	var/pierce = TRUE
	var/push = FALSE
	var/dismember = FALSE
	var/stun = FALSE

	var/calculated_burn_resist // do not touch

/datum/action/vampire/fortitude/two
	vitaecost = 40
	constant_vitaecost = 2
	resistance = 0.6
	pierce = TRUE
	push = TRUE

/datum/action/vampire/fortitude/three
	vitaecost = 30
	constant_vitaecost = 3
	resistance = 0.4
	pierce = TRUE
	push = TRUE
	dismember = TRUE

/datum/action/vampire/fortitude/four
	vitaecost = 20
	constant_vitaecost = 4
	resistance = 0.3
	pierce = TRUE
	push = TRUE
	dismember = TRUE
	stun = TRUE

/datum/action/vampire/fortitude/activate_power()
	. = ..()
	owner.balloon_alert(owner, "fortitude turned on.")
	to_chat(owner, span_notice("Your flesh has become as hard as steel!"))

	calculated_burn_resist = min(1, resistance * 3)

	// Traits & Effects
	if(pierce)
		ADD_TRAIT(owner, TRAIT_PIERCEIMMUNE, TRAIT_VAMPIRE)
	if(dismember)
		ADD_TRAIT(owner, TRAIT_NODISMEMBER, TRAIT_VAMPIRE)
	if(push)
		ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_VAMPIRE)
	if(stun)
		ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_VAMPIRE) // They'll get stun resistance + this, who cares.

	var/mob/living/carbon/human/user = owner
	user.physiology.brute_mod *= resistance
	user.physiology.stamina_mod *= resistance * 2 // Stamina resistance is half as effective because they have it inherently.
	user.physiology.burn_mod *= calculated_burn_resist // they get burn resistance, but way less

/datum/action/vampire/fortitude/UsePower()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/user = owner
	if(user.buckled && istype(user.buckled, /obj/vehicle))
		user.buckled.unbuckle_mob(src, force = TRUE)

/datum/action/vampire/fortitude/deactivate_power()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/vampire_user = owner
	vampire_user.physiology.brute_mod /= resistance
	vampire_user.physiology.burn_mod /= calculated_burn_resist

	if(!HAS_TRAIT_FROM(vampire_user, TRAIT_STUNIMMUNE, TRAIT_VAMPIRE))
		vampire_user.physiology.stamina_mod /= resistance

	// Remove Traits & Effects
	REMOVE_TRAIT(owner, TRAIT_PIERCEIMMUNE, TRAIT_VAMPIRE)
	REMOVE_TRAIT(owner, TRAIT_NODISMEMBER, TRAIT_VAMPIRE)
	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_VAMPIRE)
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_VAMPIRE)

	owner.balloon_alert(owner, "fortitude turned off.")

	return ..()
