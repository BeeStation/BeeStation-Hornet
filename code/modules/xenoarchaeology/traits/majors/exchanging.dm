/*
	Exchanging
	Swaps the damage of the last two targets
*/
/datum/xenoartifact_trait/major/exchange
	label_name = "Exchanging"
	label_desc = "Exchanging: The artifact seems to contain exchanging components. Triggering these components will exchange the damage of the last two targets."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 9
	weight = 12
	///What damage type do we exchange
	var/damage_type = BRUTE
	///How long until the window for exchange closes
	var/exchange_window = 13 SECONDS //5 second window, in theory?

/datum/xenoartifact_trait/major/exchange/trigger(datum/source, _priority, atom/override)
	//Collect some targets
	. = ..()
	if(!.)
		return
	var/atom/atom_parent = component_parent.parent
	var/final_time = exchange_window*(component_parent.trait_strength/100)
	for(var/mob/living/target in focus)
		//Build exchange hint
		if(!atom_parent.render_target)
			atom_parent.render_target = "[REF(atom_parent)]"
		target.add_filter("exchange_overlay", 100, layering_filter(render_source = atom_parent.render_target))
		//Animate it
		var/filter = target.get_filter("exchange_overlay")
		if(filter)
			animate(filter, color = "#00000000", time = final_time)
		//Timer to undo
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/xenoartifact_trait, un_trigger), target), final_time)
	clear_focus()
	//Run targets
	var/mob/living/victim_a
	var/mob/living/victim_b
	for(var/mob/living/target in targets)
		if(target.stat > SOFT_CRIT)
			playsound(get_turf(target), 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			continue
		if(!victim_a)
			victim_a = target
			continue
		if(!victim_b)
			victim_b = target
		//swap damage

		var/a_damage = victim_a.get_damage_amount(damage_type)
		var/b_damage = victim_b.get_damage_amount(damage_type)

		victim_a.apply_damage_type(a_damage*-1, damage_type) //Heal
		victim_b.apply_damage_type(b_damage*-1, damage_type)

		victim_a.apply_damage_type(b_damage, damage_type) //Apply
		victim_b.apply_damage_type(a_damage, damage_type)

		victim_a.updatehealth()
		victim_b.updatehealth()

		//Remove filters
		victim_a.remove_filter("exchange_overlay")
		victim_b.remove_filter("exchange_overlay")
		//Reset holders
		unregister_target(victim_a)
		unregister_target(victim_b)
		victim_a = null
		victim_b = null

/datum/xenoartifact_trait/major/exchange/un_trigger(atom/override, handle_parent = FALSE)
	focus = override ? list(override) : targets
	if(!length(focus))
		return ..()
	for(var/mob/living/target in focus)
		target.remove_filter("exchange_overlay")
	return ..()

/datum/xenoartifact_trait/major/exchange/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("exchange brute damage between two targets"))

//Burn variant
/datum/xenoartifact_trait/major/exchange/burn
	label_name = "Exchanging Δ"
	label_desc = "Exchanging Δ: The artifact seems to contain exchanging components. Triggering these components will exchange the damage of the last two targets."
	damage_type = BURN
	conductivity = 3

/datum/xenoartifact_trait/major/exchange/burn/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("exchange burn damage between two targets"))
