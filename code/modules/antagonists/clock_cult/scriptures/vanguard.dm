/datum/clockcult/scripture/slab/vanguard
	name = "Vanguard"
	use_time = 300
	slab_overlay = "vanguard"
	desc = "Provides the user with 30 seconds of stun immunity, but half of the stun absorbed will be applied at once, knocking you unconscious if you receive more than 15 seconds of stuns."
	tip = "Gain temporary immunity against batons and disablers."
	invokation_time = 10
	button_icon_state = "Vanguard"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 150
	var/last_recorded_stam_dam = 0
	var/total_stamina_damage = 0

/datum/clockcult/scripture/slab/vanguard/click_on(atom/A)
	return FALSE

/datum/clockcult/scripture/slab/vanguard/invoke_success()
	ADD_TRAIT(invoker, TRAIT_STUNIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_PUSHIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_CONFUSEIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_IGNOREDAMAGESLOWDOWN, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOSTAMCRIT, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOLIMBDISABLE, VANGUARD_TRAIT)
	to_chat(invoker, "<span class='sevtug'>You feel like nothing can stop you!</span>")

/datum/clockcult/scripture/slab/vanguard/count_down()
	. = ..()
	if(time_left == 50)
		to_chat(invoker, "<span class='sevtug'>You start to feel tired again.</span>")
	var/delta_stamdam = max(invoker.getStaminaLoss() - last_recorded_stam_dam, 0)
	total_stamina_damage += delta_stamdam
	last_recorded_stam_dam = invoker.getStaminaLoss()

/datum/clockcult/scripture/slab/vanguard/end_invoke()
	REMOVE_TRAIT(invoker, TRAIT_STUNIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_PUSHIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_CONFUSEIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_IGNOREDAMAGESLOWDOWN, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOSTAMCRIT, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOLIMBDISABLE, VANGUARD_TRAIT)
	to_chat(invoker, "<span class='sevtug'>You suddenly collapse from exhaustion!</span>")
	if(!ishuman(invoker))
		invoker.Unconscious(50)
	else if(total_stamina_damage > 100)
		invoker.Unconscious(total_stamina_damage / 4)
	else
		invoker.Paralyze(total_stamina_damage / 2)
	..()
