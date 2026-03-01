/datum/action/vampire/fortitude
	name = "Fortitude"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_fortitude"
	power_explanation = "Activating Fortitude will provide pierce, dismember, and push immunity.\n\
		You will additionally gain Brute and Stamina resistance, scaling with your rank.\n\
		At level 4, you gain complete stun immunity."
	power_flags = BP_AM_TOGGLE | BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY
	purchase_flags = VAMPIRE_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 30
	cooldown_time = 8 SECONDS
	constant_bloodcost = 0.2
	var/fortitude_resist // So we can raise and lower your brute resist based on what your level_current WAS.

/datum/action/vampire/fortitude/activate_power()
	. = ..()
	owner.balloon_alert(owner, "fortitude turned on.")
	to_chat(owner, span_notice("Your flesh has become as hard as steel!"))
	// Traits & Effects
	ADD_TRAIT(owner, TRAIT_PIERCEIMMUNE, TRAIT_VAMPIRE)
	ADD_TRAIT(owner, TRAIT_NODISMEMBER, TRAIT_VAMPIRE)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_VAMPIRE)
	if(level_current >= 4)
		ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_VAMPIRE) // They'll get stun resistance + this, who cares.

	var/mob/living/carbon/human/user = owner
	fortitude_resist = max(0.3, 0.7 - level_current * 0.1)
	user.physiology.brute_mod *= fortitude_resist
	user.physiology.stamina_mod *= fortitude_resist

	owner.add_movespeed_modifier(/datum/movespeed_modifier/fortitude)

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
	vampire_user.physiology.brute_mod /= fortitude_resist

	if(!HAS_TRAIT_FROM(vampire_user, TRAIT_STUNIMMUNE, TRAIT_VAMPIRE))
		vampire_user.physiology.stamina_mod /= fortitude_resist

	// Remove Traits & Effects
	REMOVE_TRAIT(owner, TRAIT_PIERCEIMMUNE, TRAIT_VAMPIRE)
	REMOVE_TRAIT(owner, TRAIT_NODISMEMBER, TRAIT_VAMPIRE)
	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_VAMPIRE)
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_VAMPIRE)

	owner.remove_movespeed_modifier(/datum/movespeed_modifier/fortitude)
	owner.balloon_alert(owner, "fortitude turned off.")

	return ..()

/datum/movespeed_modifier/fortitude
	multiplicative_slowdown = 1.5
