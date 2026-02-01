/datum/clockcult/scripture/slab/vanguard
	name = "Vanguard"
	desc = "Provides the user with 30 seconds of stun immunity, however other spells cannot be invoked while it is active."
	tip = "Gain temporary immunity against batons and disablers."
	invokation_time = 1 SECONDS
	max_time = 30 SECONDS
	button_icon_state = "Vanguard"
	slab_overlay = "vanguard"
	power_cost = 150
	cogs_required = 1
	should_set_click_ability = FALSE
	category = SPELLTYPE_PRESERVATION

	/// Traits applied by Vanguard
	var/static/list/vanguard_traits = list(
		TRAIT_STUNIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NOSTAMCRIT,
		TRAIT_NOLIMBDISABLE
	)

/datum/clockcult/scripture/slab/vanguard/on_invoke_success()
	invoker.add_traits(vanguard_traits, VANGUARD_TRAIT)
	to_chat(invoker, span_sevtug("You feel like nothing can stop you!"))
	return ..()

/datum/clockcult/scripture/slab/vanguard/on_invoke_end()
	invoker.remove_traits(vanguard_traits, VANGUARD_TRAIT)
	return ..()

/datum/clockcult/scripture/slab/vanguard/count_down()
	. = ..()
	if(max_time == 5 SECONDS)
		to_chat(invoker, span_sevtug("You start to feel tired again."))
