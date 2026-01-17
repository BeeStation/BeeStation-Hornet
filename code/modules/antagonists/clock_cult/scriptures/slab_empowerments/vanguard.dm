/datum/clockcult/scripture/slab/vanguard
	name = "Vanguard"
	use_time = 300
	slab_overlay = "vanguard"
	desc = "Provides the user with 30 seconds of stun immunity, however other spells cannot be invoked while it is active."
	tip = "Gain temporary immunity against batons and disablers."
	invokation_time = 10
	button_icon_state = "Vanguard"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 150
	var/last_recorded_stam_dam = 0
	var/total_stamina_damage = 0

//Only you are safe :)

/datum/clockcult/scripture/slab/vanguard/invoke_success()
	invoker.add_traits(list(TRAIT_STUNIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_NOSTAMCRIT, TRAIT_NOLIMBDISABLE), VANGUARD_TRAIT)
	to_chat(invoker, span_sevtug("You feel like nothing can stop you!"))

/datum/clockcult/scripture/slab/vanguard/count_down()
	. = ..()
	if(time_left == 50)
		to_chat(invoker, span_sevtug("You start to feel tired again."))

/datum/clockcult/scripture/slab/vanguard/end_invoke()
	invoker.remove_traits(list(TRAIT_STUNIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_NOSTAMCRIT, TRAIT_NOLIMBDISABLE), VANGUARD_TRAIT)
	..()

// Due to how files are formatted this is put here.

#undef KINDLE
#undef MANACLES
#undef COMPROMISE
