/datum/action/vampire/masquerade
	name = "Masquerade"
	desc = "Feign the vital signs of a mortal, and escape both casual and medical notice as the monster you truly are."
	button_icon_state = "power_human"
	power_explanation = "Masquerade will forge your identity to be practically identical to that of a human.\n\
		You lose nearly all Vampire benefits, including your passive healing.\n\
		You gain a Genetic sequence, and appear to have 100% blood when scanned by a Health Analyzer.\n\
		You won't appear as pale when examined. Anything further than pale, however, will not be hidden.\n\
		After deactivating Masquerade, you will re-gain your Vampiric abilities, as well as lose any Diseases or mutations you might have gained."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN | BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_FRENZY | BP_CANT_USE_DURING_SOL
	purchase_flags = VAMPIRE_DEFAULT_POWER | VASSAL_CAN_BUY
	bloodcost = 10
	cooldown_time = 5 SECONDS
	constant_bloodcost = 0.1

/datum/action/vampire/masquerade/activate_power()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.balloon_alert(carbon_owner, "masquerade turned on.")
	carbon_owner.apply_status_effect(/datum/status_effect/masquerade)

/datum/action/vampire/masquerade/deactivate_power()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.balloon_alert(carbon_owner, "masquerade turned off.")
	carbon_owner.remove_status_effect(/datum/status_effect/masquerade)

/datum/status_effect/masquerade
	id = "masquerade"
	duration = -1
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/masquerade

/atom/movable/screen/alert/status_effect/masquerade
	name = "Masquerade"
	desc = "You are currently hiding your identity using the Masquerade power. This halts Vampiric healing."
	icon = 'icons/vampires/actions_vampire.dmi'
	icon_state = "masquerade_alert"
	alerttooltipstyle = "cult"

/datum/status_effect/masquerade/on_apply()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(carbon_owner)
	if(!vampiredatum)
		return

	// Handle Traits
	carbon_owner.remove_traits(vampiredatum.vampire_traits, TRAIT_VAMPIRE)
	ADD_TRAIT(carbon_owner, TRAIT_MASQUERADE, TRAIT_VAMPIRE)

	// Handle organs
	var/obj/item/organ/heart/vampheart = carbon_owner.get_organ_by_type(/obj/item/organ/heart)
	vampheart?.Restart()
	var/obj/item/organ/eyes/eyes = carbon_owner.get_organ_by_type(/obj/item/organ/eyes)
	eyes?.flash_protect = initial(eyes.flash_protect)

	to_chat(carbon_owner, span_notice("Your heart beats falsely within your lifeless chest. You may yet pass for a mortal."))
	to_chat(carbon_owner, span_warning("Your vampiric healing is halted while imitating life."))

/datum/status_effect/masquerade/on_remove()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(carbon_owner)
	if(!vampiredatum)
		return

	// Clear mutations and diseases
	carbon_owner.dna.remove_all_mutations()
	for(var/datum/disease/diseases in carbon_owner.diseases)
		diseases.cure()

	// Handle Traits
	carbon_owner.add_traits(vampiredatum.vampire_traits, TRAIT_VAMPIRE)
	REMOVE_TRAIT(carbon_owner, TRAIT_MASQUERADE, TRAIT_VAMPIRE)

	// Handle organs
	var/obj/item/organ/heart/vampheart = carbon_owner.get_organ_slot(ORGAN_SLOT_HEART)
	vampheart?.Stop()
	var/obj/item/organ/eyes/eyes = carbon_owner.get_organ_slot(ORGAN_SLOT_EYES)
	eyes?.flash_protect = max(initial(eyes.flash_protect) - 1, - 1)

	to_chat(carbon_owner, span_notice("Your heart beats one final time, while your skin dries out and your icy pallor returns."))
