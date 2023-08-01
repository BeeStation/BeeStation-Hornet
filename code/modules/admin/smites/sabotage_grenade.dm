GLOBAL_LIST_EMPTY(grenade_sabotages_by_ckey)

/// Sabotages any grenades this player attempts to use or rig.
/datum/smite/sabotage_grenade
	name = "Sabotage Grenade"
	/// A list of premade sabotages.
	var/static/list/sabotages = list(
		// Just foam that makes everything funny colors
		"Colorful Reagent (Rainbow) Foam" = list(
			list(
				/datum/reagent/colorful_reagent = 0.6,
				/datum/reagent/fluorosurfactant = 0.4
			),
			list(
				/datum/reagent/colorful_reagent = 0.6,
				/datum/reagent/water = 0.4
			),
		),
		"Carpet Foam" = list(
			list(
				/datum/reagent/carpet = 0.6,
				/datum/reagent/fluorosurfactant = 0.4
			),
			list(
				/datum/reagent/carpet = 0.6,
				/datum/reagent/water = 0.4
			),
		),
		// hardcoded, just makes the grenade do nothing
		"Nothing" = TRUE,
		// hardcoded, just makes the grenade do nothing except honk
		"Nothing (but it honks)" = TRUE,
		// hardcoded, pulls reagents from admin's marked grenade
		"Marked Grenade" = TRUE,
		// hardcoded, just cluwnes the person we smited
		"Cluwneify" = TRUE,
		// hardcoded, just nuggets the person we smited
		"Nugget" = TRUE
	)

/datum/smite/sabotage_grenade/effect(client/user, mob/living/target)
	. = ..()
	var/target_ckey = target.ckey || (target.mind && ckey(target.mind.key))
	var/effect = tgui_input_list(user, "Which grenade effect would you like to use to sabotage?", "Griffman Pranking Tool", assoc_list_strip_value(sabotages), default = "Nothing (but it honks)")
	if(!effect || !user.holder || !sabotages[effect])
		return
	var/datum/callback/sabotage
	switch(effect)
		if("Nothing")
			sabotage = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sabotage_effect_nothing), FALSE)
		if("Nothing (but it honks)")
			sabotage = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sabotage_effect_nothing), TRUE)
		if("Marked Grenade")
			var/datum/admins/admin_holder = user.holder
			var/obj/item/grenade/chem_grenade/marked_grenade = admin_holder.marked_datum
			if(!istype(marked_grenade) || marked_grenade.stage != GRENADE_READY || !length(marked_grenade.beakers))
				to_chat(user, "<span class='warning'>You must have a finished chemical grenade marked through VV in order to use the Marked Grenade sabotage!</span>")
				return
			var/list/datum/reagents/reagents = list()
			for(var/obj/item/reagent_containers/beaker in marked_grenade.beakers)
				if(!beaker.reagents)
					continue
				var/datum/reagents/new_reagents = new(beaker.reagents.maximum_volume, beaker.reagents.flags)
				beaker.reagents.copy_to(new_reagents, beaker.reagents.maximum_volume)
				reagents += new_reagents
			sabotage = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sabotage_effect_marked), reagents)
		if("Cluwneify")
			sabotage = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sabotage_effect_cluwne), target_ckey)
		if("Nugget")
			sabotage = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sabotage_effect_nugget), target_ckey)
		else
			var/list/sabotage_reagents = sabotages[effect]
			if(!length(sabotage_reagents))
				return
			sabotage = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sabotage_effect_premade), sabotage_reagents.Copy())
	if(!sabotage)
		return
	var/list/grenades_sabotaged = list()
	for(var/obj/item/grenade/chem_grenade/grenade in target.GetAllContents())
		grenade.sabotage = sabotage
		grenades_sabotaged |= grenade
	for(var/obj/item/grenade/chem_grenade/grenade as() in GLOB.chem_grenades)
		var/datum/wires/explosive/chem_grenade/wiring = grenade.wires
		if(!istype(wiring))
			continue
		if(wiring.fingerprint == target_ckey)
			grenade.sabotage = sabotage
			grenades_sabotaged |= grenade
	if(target_ckey)
		GLOB.grenade_sabotages_by_ckey[target_ckey] = sabotage
	log_admin("[key_name_admin(usr)] sabotaged all grenades belonging to [key_name_admin(target)] with the effect '[effect]', affecting [length(grenades_sabotaged)] grenades")
	message_admins("[key_name_admin(usr)] sabotaged all grenades belonging to [ADMIN_LOOKUPFLW(target)] with the effect '[effect]', affecting [length(grenades_sabotaged)] grenades")

/proc/sabotage_effect_nothing(honk = TRUE, obj/item/grenade/chem_grenade/grenade)
	for(var/obj/item/reagent_containers/beaker in grenade.beakers)
		beaker.reagents?.clear_reagents()
	if(honk)
		playsound(get_turf(grenade), 'sound/items/bikehorn.ogg', vol = 100, vary = TRUE)
	return FALSE

/proc/sabotage_effect_premade(list/reagents, obj/item/grenade/chem_grenade/grenade)
	var/reagents_len = length(reagents)
	if(!reagents_len)
		return FALSE
	for(var/i = 1 to length(grenade.beakers))
		var/obj/item/reagent_containers/beaker = grenade.beakers[i]
		if(!istype(beaker) || !beaker.reagents)
			continue
		beaker.reagents.clear_reagents()
		if(i <= reagents_len)
			var/list/new_contents = reagents[i]
			for(var/reagent_type in new_contents)
				beaker.reagents.add_reagent(reagent_type, beaker.reagents.maximum_volume * new_contents[reagent_type])
	return TRUE

/proc/sabotage_effect_marked(list/datum/reagents/reagents, obj/item/grenade/chem_grenade/grenade)
	var/reagents_len = length(reagents)
	if(!reagents_len)
		return FALSE
	for(var/i = 1 to length(grenade.beakers))
		var/obj/item/reagent_containers/beaker = grenade.beakers[i]
		if(!istype(beaker) || !beaker.reagents)
			continue
		beaker.reagents.clear_reagents()
		if(i <= reagents_len)
			var/datum/reagents/new_reagents = reagents[i]
			beaker.reagents.maximum_volume = new_reagents.maximum_volume
			beaker.reagents.flags = new_reagents.flags
			new_reagents.copy_to(beaker.reagents, new_reagents.maximum_volume)
	return TRUE

/proc/sabotage_effect_cluwne(ckey, obj/item/grenade/chem_grenade/grenade)
	var/mob/living/target = get_mob_by_ckey(ckey)
	if(istype(target))
		target.cluwne()
	return FALSE

/proc/sabotage_effect_nugget(ckey, obj/item/grenade/chem_grenade/grenade)
	var/mob/living/target = get_mob_by_ckey(ckey)
	if(istype(target))
		if(iscarbon(target))
			var/mob/living/carbon/nugget = target
			for (var/obj/item/bodypart/limb in nugget.bodyparts)
				if(limb.body_part == HEAD || limb.body_part == CHEST)
					continue
				INVOKE_ASYNC(limb, TYPE_PROC_REF(/obj/item/bodypart, dismember))
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), nugget, 'sound/effects/cartoon_pop.ogg', 75, TRUE)
		else
			target.gib(TRUE, TRUE, TRUE)
	return FALSE

/proc/get_grenade_sabotage(mob/user, obj/item/grenade/chem_grenade/grenade)
	if(grenade.sabotage)
		return grenade.sabotage
	if(!istype(user))
		return
	var/target_ckey = user.ckey || (user.mind && ckey(user.mind.key))
	if(target_ckey && GLOB.grenade_sabotages_by_ckey[target_ckey])
		return GLOB.grenade_sabotages_by_ckey[target_ckey]
