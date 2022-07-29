/datum/clockcult/scripture/slab/sentinelscompromise
	name = "Sentinel's Compromise"
	use_time = 80
	slab_overlay = "compromise"
	desc = "Heal any servant within view, but will stun the user and deal large amounts of toxin damage."
	tip = "Use on any servant in trouble to heal their wounds."
	after_use_text = "Darkness never prevails"
	invokation_time = 10
	button_icon_state = "Sentinel's Compromise"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 80

/datum/clockcult/scripture/slab/sentinelscompromise/click_on(atom/A)
	if(!(invoker in viewers(4, get_turf(A))))
		to_chat(invoker, "<span class='warning'>The target is too far away.</span>")
		return
	if(!ishuman(invoker))
		to_chat(invoker, "<span class='warning'>Non humanoid servants can't use this power!</span>")
		return
	if(invoker.has_status_effect(STATUS_EFFECT_SENTINELS_COOLDOWN))
		to_chat(invoker, "<span class='warning'>You are not ready to use sentinel's compromise yet!</span>")
		return
	var/mob/living/M = A
	if(!istype(M))
		return
	if(!is_servant_of_ratvar(M))
		return
	if(apply_effects(A))
		uses_left --
		if(uses_left <= 0)
			if(after_use_text)
				clockwork_say(invoker, text2ratvar(after_use_text), TRUE)
			end_invokation()

/datum/clockcult/scripture/slab/sentinelscompromise/apply_effects(mob/living/M)
	if(M.stat == DEAD)
		return FALSE
	invoker.apply_status_effect(STATUS_EFFECT_SENTINELS_COOLDOWN)
	var/total_damage = (M.getBruteLoss() + M.getFireLoss() + M.getOxyLoss() + M.getCloneLoss()) * 0.6
	M.adjustBruteLoss(-M.getBruteLoss() * 0.6, FALSE)
	M.adjustFireLoss(-M.getFireLoss() * 0.6, FALSE)
	M.adjustOxyLoss(-M.getOxyLoss() * 0.6, FALSE)
	M.adjustCloneLoss(-M.getCloneLoss() * 0.6, TRUE)
	M.blood_volume = BLOOD_VOLUME_NORMAL
	M.reagents?.remove_reagent(/datum/reagent/water/holywater, INFINITY)
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
	playsound(invoker, 'sound/magic/magic_missile.ogg', 50, TRUE)
	invoker.adjustToxLoss(min(total_damage * 0.5, 80), TRUE, TRUE)
	invoker.Knockdown(min(total_damage * 0.5, 60))
	invoker.emote("scream")
	return TRUE

/datum/status_effect/sentinels_cooldown
	id = "sentcooldown"
	duration = 15 SECONDS

/datum/status_effect/sentinels_cooldown/on_remove()
	to_chat(owner, "<span class='sevtug'>You are ready to use sentinel's compromise again!</span>")
