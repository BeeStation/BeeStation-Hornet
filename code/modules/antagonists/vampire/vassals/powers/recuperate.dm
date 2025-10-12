/// Used by Vassals
/datum/action/vampire/recuperate
	name = "Sanguine Recuperation"
	desc = "Slowly heals you overtime using your master's blood, in exchange for some of your own blood and effort."
	button_icon_state = "power_recup"
	power_explanation = "Activating this Power will begin to heal your wounds.\n\
		You will heal Brute and Toxin damage at the cost of your Stamina and blood.\n\
		If you aren't a bloodless race, you will additionally heal Burn damage."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = NONE
	bloodcost = 1.5
	cooldown_time = 10 SECONDS

/datum/action/vampire/recuperate/can_use()
	. = ..()
	if(!.)
		return FALSE

	if(owner.stat >= DEAD || owner.incapacitated())
		owner.balloon_alert(owner, "you are incapacitated...")
		return FALSE

/datum/action/vampire/recuperate/activate_power()
	. = ..()
	to_chat(owner, span_notice("Your muscles clench as your master's immortal blood mixes with your own, knitting your wounds."))
	owner.balloon_alert(owner, "recuperate turned on.")

/datum/action/vampire/recuperate/UsePower()
	. = ..()
	if(!. || !currently_active)
		return

	var/mob/living/carbon/carbon_owner = owner
	if(!istype(carbon_owner))
		return

	carbon_owner.Jitter(5)
	carbon_owner.adjustStaminaLoss(bloodcost * 1.1)
	carbon_owner.adjustBruteLoss(-2.5)
	carbon_owner.adjustToxLoss(-2, forced = TRUE)
	// Plasmamen won't lose blood, they don't have any, so they don't heal from Burn.
	if(!HAS_TRAIT(carbon_owner, TRAIT_NO_BLOOD))
		carbon_owner.blood_volume -= bloodcost
		carbon_owner.adjustFireLoss(-1.5)
	// Stop Bleeding
	if(istype(carbon_owner) && carbon_owner.is_bleeding())
		carbon_owner.cauterise_wounds(-0.5)

/datum/action/vampire/recuperate/continue_active()
	if(owner.stat == DEAD)
		return FALSE
	if(owner.incapacitated())
		owner.balloon_alert(owner, "too exhausted...")
		return FALSE
	return TRUE

/datum/action/vampire/recuperate/deactivate_power()
	owner.balloon_alert(owner, "recuperate turned off.")
	return ..()
