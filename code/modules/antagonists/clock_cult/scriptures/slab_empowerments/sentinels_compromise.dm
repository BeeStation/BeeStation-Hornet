/datum/clockcult/scripture/slab/sentinelscompromise
	name = "Sentinel's Compromise"
	use_time = 80
	slab_overlay = "compromise"
	desc = "Heal any servant within view, but half of their damage healed will be given to you in the form of toxin damage."
	tip = "Use on any servant in trouble to heal their wounds."
	invokation_time = 10
	button_icon_state = "Sentinel's Compromise"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 80

/datum/action/cooldown/spell/slab/sentinelscompromise
	name = "Sentinel's Compromies"
	// Deadline 2030 port yogs clockies

/datum/action/cooldown/spell/slab/sentinelscompromise/can_cast_spell(feedback)
	. = ..()
	if(!ishuman(scripture.invoker))
		to_chat(scripture.invoker, "<span class='warning'>Non humanoid servants can't use this power!</span>")
		return


/datum/action/cooldown/spell/slab/sentinelscompromise/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/M = cast_on
	if(M.stat == DEAD || !is_servant_of_ratvar(M))
		return FALSE
	var/total_damage = (M.getBruteLoss() + M.getFireLoss() + M.getOxyLoss() + M.getCloneLoss()) * 0.6
	M.adjustBruteLoss(-M.getBruteLoss() * 0.6, FALSE)
	M.adjustFireLoss(-M.getFireLoss() * 0.6, FALSE)
	M.adjustOxyLoss(-M.getOxyLoss() * 0.6, FALSE)
	M.adjustCloneLoss(-M.getCloneLoss() * 0.6, TRUE)
	M.blood_volume = BLOOD_VOLUME_NORMAL
	M.reagents.remove_reagent(/datum/reagent/water/holywater, INFINITY)
	M.set_nutrition(NUTRITION_LEVEL_FULL)
	M.bodytemperature = BODYTEMP_NORMAL
	M.set_blindness(0)
	M.set_blurriness(0)
	M.set_dizziness(0)
	M.cure_nearsighted()
	M.cure_blind()
	M.cure_husk()
	M.hallucination = 0
	new /obj/effect/temp_visual/heal(get_turf(M), "#f8d984")
	playsound(M, 'sound/magic/magic_missile.ogg', 50, TRUE)
	playsound(scripture.invoker, 'sound/magic/magic_missile.ogg', 50, TRUE)
	scripture.invoker.adjustToxLoss(min(total_damage/2, 80), TRUE, TRUE)
	return TRUE
