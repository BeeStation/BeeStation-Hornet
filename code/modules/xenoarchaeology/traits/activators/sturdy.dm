/*
	Sturdy
	This trait activates the artifact when it's used, like a generic item
*/
/datum/xenoartifact_trait/activator/sturdy
	material_desc = "sturdy"
	label_name = "Sturdy"
	label_desc = "Sturdy: The artifact seems to be made of a sturdy material. This material seems to be triggered by physical interaction."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 16

/datum/xenoartifact_trait/activator/sturdy/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	//Register all the relevant signals we trigger from
	RegisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))
	RegisterSignal(component_parent?.parent, COMSIG_MOVABLE_IMPACT, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))
	RegisterSignal(component_parent?.parent, COMSIG_ITEM_ATTACK_SELF, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))
	RegisterSignal(component_parent?.parent, COMSIG_ITEM_AFTERATTACK, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_c))
	RegisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACK_HAND, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_d))

/datum/xenoartifact_trait/activator/sturdy/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(component_parent?.parent, COMSIG_MOVABLE_IMPACT)
	UnregisterSignal(component_parent?.parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(component_parent?.parent, COMSIG_ITEM_AFTERATTACK)
	UnregisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACK_HAND)
	return ..()

/datum/xenoartifact_trait/activator/sturdy/translation_type_b(datum/source, atom/item, atom/target)
	if(check_item_safety(item))
		return
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/sturdy/translation_type_d(datum/source, atom/item, atom/target)
	var/atom/atom_parent = component_parent?.parent
	if(!isliving(atom_parent?.loc) && !atom_parent?.density || check_item_safety(item))
		return
	trigger_artifact(target || item, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/sturdy/translation_type_a(datum/source, atom/target)
	var/atom/atom_parent = component_parent?.parent
	if(isliving(atom_parent?.loc))
		trigger_artifact(target, XENOA_ACTIVATION_TOUCH)
		return
	trigger_artifact(target)

/datum/xenoartifact_trait/activator/sturdy/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_MATERIAL)

/*
	Timed
	This trait activates the artifact on a timer, which can be toggled on & off
*/
/datum/xenoartifact_trait/activator/sturdy/timed
	label_name = "Timed"
	label_desc = "Timed: The artifact seems to be made of a harmonizing material. This material seems to activate on a timer, which can be enabled or disabled."
	material_desc = null
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 32
	///Are we looking for targets
	var/searching = FALSE
	///Search cooldown logic
	var/search_cooldown = 4 SECONDS
	var/search_cooldown_timer

/datum/xenoartifact_trait/activator/sturdy/timed/New(atom/_parent)
	. = ..()
	search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)
	START_PROCESSING(SSobj, src)

/datum/xenoartifact_trait/activator/sturdy/timed/trigger_artifact(atom/target, type, force, do_real_trigger)
	if(do_real_trigger)
		return ..()
	else
		if(HAS_TRAIT(target, TRAIT_ARTIFACT_IGNORE))
			return FALSE
		if(component_parent.anti_check(target, type))
			return FALSE
		searching = !searching
		indicator_hint(searching)

/datum/xenoartifact_trait/activator/sturdy/timed/process(delta_time)
	if(!searching || search_cooldown_timer || !component_parent)
		return
	playsound(get_turf(component_parent?.parent), 'sound/effects/clock_tick.ogg', 60, TRUE)
	for(var/atom/target in oview(component_parent.target_range, get_turf(component_parent?.parent)))
		//Only add mobs
		if(!ismob(target))
			continue
		trigger_artifact(target, XENOA_ACTIVATION_CONTACT, FALSE, TRUE)
		break
	if(!length(component_parent.targets))
		component_parent.trigger()
	search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)

/datum/xenoartifact_trait/activator/sturdy/timed/get_dictionary_hint()
	. = ..()
	return list(list("icon" = "exclamation", "desc" = "This trait will, after an arming time, activate on the nearest living target, periodically."))

/datum/xenoartifact_trait/activator/sturdy/timed/proc/reset_timer()
	if(search_cooldown_timer)
		deltimer(search_cooldown_timer)
	search_cooldown_timer = null

/datum/xenoartifact_trait/activator/sturdy/timed/proc/indicator_hint(engaging = FALSE)
	var/atom/atom_parent = component_parent?.parent
	atom_parent?.balloon_alert_to_viewers("[atom_parent] [!engaging ? "stops ticking" : "starts ticking"]!")

/*
	Hungry
	This trait activates the artifact when it's fed
*/
/datum/xenoartifact_trait/activator/sturdy/hungry
	material_desc = null
	label_name = "Hungry"
	label_desc = "Hungry: The artifact seems to be made of a semi-living, hungry, material. This material seems to be triggered by feeding interactions."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 32
	///How much damage do we deal per bite?
	var/eat_damage = 15
	///Timer logic for biting people
	var/bite_cooldown = 4 SECONDS
	var/bite_timer
	///Will we tollerate the taste of humans? Used for subtypes
	var/maneater = FALSE

/datum/xenoartifact_trait/activator/sturdy/hungry/trigger_artifact(atom/target, type, force)
	if(component_parent.anti_check(target, type) || component_parent.calcified || get_dist(target, component_parent?.parent) > component_parent?.target_range)
		return FALSE
	//Find a food item
	var/mob/living/M = target
	var/edible
	if(isliving(M))
		var/list/sides = list("left", "right")
		for(var/i in sides)
			var/atom/atom_parent = M.get_held_items_for_side(i)
			if(atom_parent) //Not pre-checking atom_parent can cause some runtimes
				edible = SEND_SIGNAL(atom_parent, COMSIG_FOOD_FEED_ITEM, component_parent?.parent)
	if(!edible && target)
		edible = SEND_SIGNAL(target, COMSIG_FOOD_FEED_ITEM, component_parent?.parent)
	//If food
	var/atom/movable/movable = component_parent.parent
	if(edible)
		playsound(movable.loc, 'sound/items/eatfood.ogg', 60, 1, 1)
		return ..()
	//Otherwise, nibble the target, and spit them out, they're gross, ew
	if(isliving(M) && !bite_timer)
		playsound(movable.loc, 'sound/weapons/bite.ogg', 60, 1, 1)
		movable.do_attack_animation(M)
		var/affecting = M.get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/armour_block = M.run_armor_check(null, MELEE, armour_penetration = 0)
		M.apply_damage(15, BRUTE, affecting, armour_block)
		bite_timer = addtimer(CALLBACK(src, PROC_REF(handle_timer)), bite_cooldown, TIMER_STOPPABLE)
		if(!maneater)
			M.visible_message("<span class='warning'>[movable] bites [M], it didn't quite like the taste!</span>", "<span class='warning'>[movable] bites you!\n[movable] doesn't like that taste!</span>")
			return FALSE
		else
			M.visible_message("<span class='warning'>[movable] bites [M], it loves the taste!</span>", "<span class='warning'>[movable] bites you!\n[movable] loves that taste!</span>")
			return ..()
	return FALSE

/datum/xenoartifact_trait/activator/sturdy/hungry/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("only eat food items"))

/datum/xenoartifact_trait/activator/sturdy/hungry/proc/handle_timer()
	if(bite_timer)
		deltimer(bite_timer)
	bite_timer = null

//maneater variant
/datum/xenoartifact_trait/activator/sturdy/hungry/maneater
	material_desc = null
	label_name = "Hungry Δ"
	label_desc = "Hungry Δ: The artifact seems to be made of a semi-living, hungry, material. This material seems to be triggered by feeding interactions."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	maneater = TRUE
	conductivity = 8

/datum/xenoartifact_trait/activator/sturdy/hungry/maneater/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("eat food items, and mobs"))
