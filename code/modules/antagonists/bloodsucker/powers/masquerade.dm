/**
 *	# WITHOUT THIS POWER:
 *
 *	- Mid-Blood: SHOW AS PALE
 *	- Low-Blood: SHOW AS DEAD
 *	- No Heartbeat
 *  - Examine shows actual blood
 *	- Thermal homeostasis (ColdBlooded)
 * 		WITH THIS POWER:
 *	- Normal body temp -- remove Cold Blooded (return on deactivate)
 */

/datum/action/cooldown/bloodsucker/masquerade
	name = "Masquerade"
	desc = "Feign the vital signs of a mortal, and escape both casual and medical notice as the monster you truly are."
	button_icon_state = "power_human"
	power_explanation = "Masquerade:\n\
		Activating Masquerade will forge your identity to be practically identical to that of a human;\n\
		- You lose nearly all Bloodsucker benefits, including healing, sleep, radiation, crit, virus and cold immunity.\n\
		- Your eyes turn to that of a regular human as your heart begins to beat.\n\
		- You gain a Genetic sequence, and appear to have 100% blood when scanned by a Health Analyzer.\n\
		- You will not appear as Pale when examined. Anything further than Pale, however, will not be hidden.\n\
		At the end of a Masquerade, you will re-gain your Vampiric abilities, as well as lose any Disease & Gene you might have."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN|BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_FRENZY
	purchase_flags = BLOODSUCKER_CAN_BUY|BLOODSUCKER_DEFAULT_POWER
	bloodcost = 10
	cooldown_time = 5 SECONDS
	constant_bloodcost = 0.1

/datum/action/cooldown/bloodsucker/masquerade/ActivatePower(trigger_flags)
	. = ..()
	var/mob/living/carbon/user = owner
	owner.balloon_alert(owner, "masquerade turned on.")
	to_chat(user, "<span class='notice'>Your heart beats falsely within your lifeless chest. You may yet pass for a mortal.</span>")
	to_chat(user, "<span class='warning'>Your vampiric healing is halted while imitating life.</span>")

	// Give status effect
	user.apply_status_effect(/datum/status_effect/masquerade)

	// Handle Traits
	user.remove_traits(bloodsuckerdatum_power.bloodsucker_traits, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_MASQUERADE, BLOODSUCKER_TRAIT)
	// Handle organs
	var/obj/item/organ/heart/vampheart = user.getorgan(/obj/item/organ/heart)
	vampheart?.Restart()
	var/obj/item/organ/eyes/eyes = user.getorgan(/obj/item/organ/eyes)
	eyes?.flash_protect = initial(eyes.flash_protect)

/datum/action/cooldown/bloodsucker/masquerade/DeactivatePower()
	. = ..()
	var/mob/living/carbon/user = owner
	owner.balloon_alert(owner, "masquerade turned off.")

	// Remove status effect, mutations & diseases that you got while on masq.
	user.remove_status_effect(/datum/status_effect/masquerade)
	user.dna.remove_all_mutations()
	for(var/datum/disease/diseases as anything in user.diseases)
		diseases.cure()

	// Handle Traits
	user.add_traits(bloodsuckerdatum_power.bloodsucker_traits, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_MASQUERADE, BLOODSUCKER_TRAIT)

	// Handle organs
	var/obj/item/organ/heart/vampheart = user.getorganslot(ORGAN_SLOT_HEART)
	vampheart?.Stop()
	var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	eyes?.flash_protect = max(initial(eyes.flash_protect) - 1, - 1)
	to_chat(user, "<span class='notice'>Your heart beats one final time, while your skin dries out and your icy pallor returns.</span>")

/**
 * # Status effect
 *
 * This is what the Masquerade power gives, handles their bonuses and gives them a neat icon to tell them they're on Masquerade.
 */

/datum/status_effect/masquerade
	id = "masquerade"
	duration = -1
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/masquerade

/atom/movable/screen/alert/status_effect/masquerade
	name = "Masquerade"
	desc = "You are currently hiding your identity using the Masquerade power. This halts Vampiric healing."
	icon_state = "masquerade_active"
	alerttooltipstyle = "cult"

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()
