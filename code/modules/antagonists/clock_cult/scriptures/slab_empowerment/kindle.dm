/datum/clockcult/scripture/slab/kindle
	name = "Kindle"
	desc = "Stuns and mutes a target from a short range. Significantly less effective on Reebe."
	tip = "Stuns and mutes a target from a short range."
	invokation_text = list("Divinity, show them your light!")
	after_use_text = "Let the power flow through you!"
	invokation_time = 3 SECONDS
	max_time = 15 SECONDS
	button_icon_state = "Kindle"
	slab_overlay = "volt"
	power_cost = 125
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/slab/kindle/apply_effects(atom/target_atom)
	. = ..()
	if(!isliving(target_atom))
		return FALSE

	var/mob/living/living_target = target_atom

	if(IS_SERVANT_OF_RATVAR(living_target))
		return FALSE

	// Holy reaction
	if(living_target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		// Lighting and overlay
		living_target.mob_light(color = LIGHT_COLOR_HOLY_MAGIC, range = 2, duration = 10 SECONDS)

		var/mutable_appearance/forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", CALCULATE_MOB_OVERLAY_LAYER(MUTATIONS_LAYER))
		living_target.add_overlay(forbearance)
		addtimer(CALLBACK(living_target, TYPE_PROC_REF(/atom, cut_overlay), forbearance), 10 SECONDS)

		// Flavor text
		living_target.visible_message(
			span_warning("[living_target] stares blankly, as a field of energy flows around them."),
			span_userdanger("You feel a slight shock as a wave of energy flows past you.")
		)

		// Sound
		playsound(invoker, 'sound/magic/mm_hit.ogg', 50, TRUE)

		return TRUE

	// Blood Cultist reaction
	if(IS_CULTIST(living_target))
		living_target.mob_light(color = LIGHT_COLOR_BLOOD_MAGIC, range = 2, duration = 30 SECONDS)
		var/previous_color = living_target.color
		living_target.color = LIGHT_COLOR_BLOOD_MAGIC
		animate(living_target, color = previous_color, time = 30 SECONDS)

		living_target.adjust_stutter(30 SECONDS)
		living_target.set_jitter_if_lower(30 SECONDS)

		living_target.say("Fwebar uloft'gib mirlig yro'fara!")
		to_chat(invoker, span_brass("You fail to stun [living_target]!"))

		playsound(invoker, 'sound/magic/mm_hit.ogg', 50, TRUE)
		return TRUE

	// Light
	invoker.mob_light(color = LIGHT_COLOR_CLOCKWORK, range = 2, duration = 1 SECONDS)

	// If not on Reebe and does not have a mindshield, paralyze for 15 seconds
	if(!is_on_reebe(living_target))
		if(HAS_TRAIT(living_target, TRAIT_MINDSHIELD))
			to_chat(invoker, span_brass("[living_target] seems somewhat resistant to your powers!"))
			living_target.adjust_confusion_up_to(5 SECONDS, 5 SECONDS)
		else
			living_target.Paralyze(15 SECONDS)


	if(issilicon(living_target))
		var/mob/living/silicon/silicon_target = living_target
		silicon_target.emp_act(EMP_HEAVY)
	else
		living_target.adjust_silence(12 SECONDS)
		living_target.adjust_stutter(30 SECONDS)
		living_target.set_jitter_if_lower(30 SECONDS)

	// Apply color to the client's screen
	if(living_target.client)
		var/previous_client_color = living_target.client.color
		living_target.client.color = "#BE8700"
		animate(living_target.client, color = previous_client_color, time = 3 SECONDS)

	playsound(invoker, 'sound/magic/staff_animation.ogg', 50, TRUE)
