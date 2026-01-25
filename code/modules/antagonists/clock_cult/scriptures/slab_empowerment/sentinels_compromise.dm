/datum/clockcult/scripture/slab/sentinels_compromise
	name = "Sentinel's Compromise"
	desc = "Heal any servant within view, but half of their damage healed will be given to you in the form of toxin damage."
	tip = "Use on any servant in trouble to heal their wounds."
	invokation_time = 1 SECONDS
	max_time = 8 SECONDS
	button_icon_state = "Sentinel's Compromise"
	slab_overlay = "compromise"
	power_cost = 80
	cogs_required = 1
	category = SPELLTYPE_PRESERVATION

/datum/clockcult/scripture/slab/sentinels_compromise/can_invoke()
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(invoker))
		invoker.balloon_alert(invoker, "not a human!")
		return FALSE

/datum/clockcult/scripture/slab/sentinels_compromise/apply_effects(atom/target_atom)
	. = ..()
	if(!isliving(target_atom))
		return FALSE

	var/mob/living/living_target = target_atom

	if(living_target.stat == DEAD)
		living_target.balloon_alert(invoker, "[living_target.p_theyre()] dead!")
		return FALSE

	// Heal our target and add toxins to the invoker
	var/total_damage = (living_target.getBruteLoss() + living_target.getFireLoss() + living_target.getOxyLoss() + living_target.getCloneLoss()) * 0.6

	var/needs_health_update = 0
	needs_health_update += living_target.adjustBruteLoss(-living_target.getBruteLoss() * 0.6, updating_health = FALSE)
	needs_health_update += living_target.adjustFireLoss(-living_target.getFireLoss() * 0.6, updating_health = FALSE)
	needs_health_update += living_target.adjustOxyLoss(-living_target.getOxyLoss() * 0.6, updating_health = FALSE)
	needs_health_update += living_target.adjustCloneLoss(-living_target.getCloneLoss() * 0.6, updating_health = FALSE)
	if(needs_health_update)
		living_target.updatehealth()

	invoker.adjustToxLoss(min(total_damage / 2, 80), updating_health = TRUE, forced = TRUE)

	// Purge holywater
	living_target.reagents.remove_reagent(/datum/reagent/water/holywater, INFINITY)

	// Set nutrition and body temp back to normal
	living_target.set_nutrition(NUTRITION_LEVEL_FULL)

	// Clear sight problems and husk
	living_target.fully_heal(HEAL_BODY)

	// Effect and sounds
	new /obj/effect/temp_visual/heal(get_turf(living_target), "#f8d984")

	playsound(living_target, 'sound/magic/magic_missile.ogg', 50, TRUE)
	playsound(invoker, 'sound/magic/magic_missile.ogg', 50, TRUE)
