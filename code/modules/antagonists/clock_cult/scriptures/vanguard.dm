/datum/clockcult/scripture/slab/vanguard
	name = "Vanguard"
	use_time = 300
	slab_overlay = "vanguard"
	desc = "Disconnects the user's soul from the corporeal plane, allowing them to overcome death for a period of 30 seconds."
	tip = "Gain temporary immunity to death. Be careful, if you are too damaged at the end of the spell, you will instantly die."
	invokation_time = 10
	button_icon_state = "Vanguard"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 150
	var/mutable_appearance/overlay_image

/datum/clockcult/scripture/slab/vanguard/New()
	. = ..()
	overlay_image = mutable_appearance('icons/effects/clockwork_effects.dmi', "clock_shield", layer = -30)

/datum/clockcult/scripture/slab/vanguard/Destroy()
	QDEL_NULL(overlay_image)
	. = ..()

/datum/clockcult/scripture/slab/vanguard/click_on(atom/A)
	return FALSE

/datum/clockcult/scripture/slab/vanguard/invoke_success()
	invoker.say(text2ratvar("NOTHING CAN STOP ME!"), forced = TRUE)
	invoker.add_overlay(overlay_image)
	//Full stun immunity
	ADD_TRAIT(invoker, TRAIT_STUNIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_PUSHIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_CONFUSEIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_IGNOREDAMAGESLOWDOWN, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOSTAMCRIT, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOLIMBDISABLE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOSOFTCRIT, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOHARDCRIT, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NODEATH, VANGUARD_TRAIT)
	to_chat(invoker, "<span class='sevtug'>You feel like nothing can stop you!</span>")

/datum/clockcult/scripture/slab/vanguard/count_down()
	. = ..()
	if(time_left == 50)
		to_chat(invoker, "<span class='sevtug big'>You start to feel tired again...</span>")

/datum/clockcult/scripture/slab/vanguard/end_invoke()
	invoker.cut_overlay(overlay_image)
	REMOVE_TRAIT(invoker, TRAIT_STUNIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_PUSHIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_CONFUSEIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_IGNOREDAMAGESLOWDOWN, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOSTAMCRIT, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOLIMBDISABLE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOSOFTCRIT, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOHARDCRIT, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NODEATH, VANGUARD_TRAIT)
	//Stun
	invoker.adjustStaminaLoss(200, TRUE, TRUE)
	..()
