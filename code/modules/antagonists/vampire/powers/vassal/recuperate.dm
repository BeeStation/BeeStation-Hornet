/// Used by Vassals
/datum/action/cooldown/vampire/recuperate
	name = "Sanguine Recuperation"
	desc = "Slowly heals you overtime using your master's blood, in exchange for some of your own blood and effort."
	button_icon_state = "power_recup"
	power_explanation = "\
		Activating this Power will begin to heal your wounds. \
		You will heal Brute and Toxin damage at the cost of your Stamina and blood from both you and your Master. \
		If you aren't a bloodless race, you will additionally heal Burn damage."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = NONE
	bloodcost = 1.5
	cooldown_time = 10 SECONDS

/datum/action/cooldown/vampire/recuperate/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return
	if(user.stat >= DEAD || user.incapacitated())
		user.balloon_alert(user, "you are incapacitated...")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/recuperate/ActivatePower(trigger_flags)
	. = ..()
	to_chat(owner, span_notice("Your muscles clench as your master's immortal blood mixes with your own, knitting your wounds."))
	owner.balloon_alert(owner, "recuperate turned on.")

/datum/action/cooldown/vampire/recuperate/UsePower(seconds_per_tick)
	. = ..()
	if(!.)
		return

	if(!active)
		return
	var/mob/living/carbon/user = owner
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(user)
	vassaldatum.master.AddBloodVolume(-1)
	user.Jitter(5 SECONDS)
	user.adjustStaminaLoss(bloodcost * 1.1)
	user.adjustBruteLoss(-2.5)
	user.adjustToxLoss(-2, forced = TRUE)
	// Plasmamen won't lose blood, they don't have any, so they don't heal from Burn.
	if(!HAS_TRAIT(user, TRAIT_NO_BLOOD))
		user.blood_volume -= bloodcost
		user.adjustFireLoss(-1.5)
	// Stop Bleeding
	if(istype(user) && user.is_bleeding())
		for(var/obj/item/bodypart/part in user.bodyparts)
			user.add_bleeding(-10)

/datum/action/cooldown/vampire/recuperate/ContinueActive(mob/living/user, mob/living/target)
	if(user.stat >= DEAD)
		return FALSE
	if(user.incapacitated())
		owner.balloon_alert(owner, "too exhausted...")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/recuperate/DeactivatePower()
	owner.balloon_alert(owner, "recuperate turned off.")
	return ..()
