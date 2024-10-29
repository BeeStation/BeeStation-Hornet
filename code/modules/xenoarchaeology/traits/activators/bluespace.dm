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
	Flammable
	This trait activates the artifact when it's lit
*/
/datum/xenoartifact_trait/activator/flammable
	material_desc = "flammable"
	label_name = "Flammable"
	label_desc = "Flammable: The artifact seems to be made of a flammable material. This material seems to be triggered by heat interaction."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///Are we 'lit' and looking for targets
	var/lit = FALSE
	///Search cooldown logic
	var/search_cooldown = 4 SECONDS
	var/search_cooldown_timer

/datum/xenoartifact_trait/activator/flammable/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	RegisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))
	RegisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACK_HAND, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_d))
	RegisterSignal(component_parent?.parent, COMSIG_ITEM_ATTACK_SELF, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))

/datum/xenoartifact_trait/activator/flammable/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACK_HAND)
	UnregisterSignal(component_parent?.parent, COMSIG_ITEM_ATTACK_SELF)
	return ..()

/datum/xenoartifact_trait/activator/flammable/translation_type_a(datum/source, atom/target)
	lit = FALSE
	//Indicator hint
	indicator_hint()

/datum/xenoartifact_trait/activator/flammable/translation_type_b(datum/source, atom/item, atom/target)
	var/obj/item/I = item
	if(isitem(I) && I.is_hot() && !check_item_safety(item))
		if(HAS_TRAIT(item, TRAIT_ARTIFACT_IGNORE))
			return FALSE
		if(component_parent.anti_check(target, XENOA_ACTIVATION_TOUCH))
			return FALSE
		lit = TRUE
		indicator_hint(1)
		search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)
		START_PROCESSING(SSobj, src)

/datum/xenoartifact_trait/activator/flammable/translation_type_d(datum/source, atom/target)
	var/atom/atom_parent = component_parent?.parent
	if(atom_parent?.density)
		lit = FALSE
		indicator_hint()

/datum/xenoartifact_trait/activator/flammable/process(delta_time)
	if(!lit)
		return ..()
	if(search_cooldown_timer)
		return
	for(var/atom/target in oview(component_parent.target_range, get_turf(component_parent?.parent)))
		//Only add mobs
		if(!ismob(target))
			continue
		trigger_artifact(target)
		lit = FALSE
		indicator_hint()
		break
	search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)

/datum/xenoartifact_trait/activator/flammable/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_TRIGGER("'hot' tool"), list("icon" = "exclamation", "desc" = "This trait will, after an arming time, activate on the nearest living target."))

/datum/xenoartifact_trait/activator/flammable/proc/reset_timer()
	if(search_cooldown_timer)
		deltimer(search_cooldown_timer)
	search_cooldown_timer = null

/datum/xenoartifact_trait/activator/flammable/proc/indicator_hint(engaging = FALSE)
	var/atom/atom_parent = component_parent?.parent
	atom_parent?.balloon_alert_to_viewers("[atom_parent] [engaging ? "flicks on" : "snuffs out."]!")

/*
	Signal
	This trait activates the artifact when it's signalled
*/
/datum/xenoartifact_trait/activator/signal
	label_name = "Signal"
	label_desc = "Signal: The artifact seems to be made of a radio sensitive material. This material seems to be triggered by radio pulses."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///Signal code
	var/code
	///Signal frequency
	var/datum/radio_frequency/radio_connection
	//Signal
	var/datum/signal/signal
	///Annoying soung
	var/sound_timer

	///Reference to our particle holder - we need to use holders & vis contents, otherwise shit gets fucky with filters
	var/atom/movable/artifact_particle_holder/particle_holder

/datum/xenoartifact_trait/activator/signal/New(atom/_parent)
	. = ..()
	//Code
	code = rand(0, 100)
	//Signal
	signal = new(list("code" = code))
	//Frequency
	radio_connection = SSradio.add_object(src, FREQ_SIGNALER, "[RADIO_XENOA]_[REF(src)]")
	radio_connection.add_listener(src)

/datum/xenoartifact_trait/minor/signaller/Destroy(force, ...)
	SSradio.remove_object(src, FREQ_SIGNALER)
	QDEL_NULL(signal)
	return ..()

/datum/xenoartifact_trait/activator/signal/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	setup_generic_item_hint()
	sound_timer = addtimer(CALLBACK(src, PROC_REF(do_sonar)), 5 SECONDS)

/datum/xenoartifact_trait/activator/signal/remove_parent(datum/source, pensive)
	if(sound_timer)
		deltimer(sound_timer)
	return ..()

/datum/xenoartifact_trait/activator/signal/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	//Build particle holder
	particle_holder = new(component_parent?.parent)
	particle_holder.add_emitter(/obj/emitter/sonar, "sonar", 9)
	//Layer onto parent
	target.vis_contents += particle_holder

/datum/xenoartifact_trait/activator/signal/cut_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	target.vis_contents -= particle_holder
	QDEL_NULL(particle_holder)

/datum/xenoartifact_trait/activator/signal/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='warning'>[item] detects an input frequency & code of [FREQ_SIGNALER]-[code]!</span>")
		return ..()

/datum/xenoartifact_trait/activator/signal/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("signaller assembly"),
	XENOA_TRAIT_HINT_DETECT("analyzer, which will also reveal its trigger code & frequency"),
	XENOA_TRAIT_HINT_RANDOMISED, list("icon" = "exclamation", "desc" = "This trait will activate on the nearest living target."),
	XENOA_TRAIT_HINT_APPEARANCE("This trait will make radar particles appear around the artifact."),
	XENOA_TRAIT_HINT_SOUND("sonar pings"))

/datum/xenoartifact_trait/activator/signal/proc/receive_signal(datum/signal/signal)
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	for(var/atom/target in oview(component_parent.target_range, get_turf(component_parent?.parent)))
		//Only add mobs
		if(!ismob(target))
			continue
		trigger_artifact(target, XENOA_ACTIVATION_CONTACT)
		break
	if(!length(component_parent.targets))
		component_parent.trigger()

/datum/xenoartifact_trait/activator/signal/proc/do_sonar(repeat = TRUE)
	if(QDELETED(src))
		return
	var/atom/atom_parent = component_parent.parent
	if(isturf(atom_parent.loc))
		playsound(get_turf(component_parent?.parent), 'sound/effects/ping.ogg', 60, TRUE)
	var/rand_time = rand(5, 15) SECONDS
	sound_timer = addtimer(CALLBACK(src, PROC_REF(do_sonar)), rand_time / (isturf(atom_parent.loc) ? 2 : 1))

/*
	ABSTRACT
	Item key
	This trait activates when an item key is used on it
*/
/datum/xenoartifact_trait/activator/item_key
	flags = XENOA_HIDE_TRAIT
	///What item type activates us?
	var/obj/item/key_item
	///Is the key item a strict type?
	var/is_strict = FALSE

/datum/xenoartifact_trait/activator/item_key/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	RegisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))

/datum/xenoartifact_trait/activator/item_key/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY)
	return ..()

/datum/xenoartifact_trait/activator/item_key/translation_type_b(datum/source, atom/item, atom/target)
	if(is_strict)
		. = item?.type == key_item.type
	else
		. = istype(item, key_item)
	return (. && !component_parent.use_cooldown_timer)

/*
	Cell
	This trait activates the artifact when a battery is used
*/
/datum/xenoartifact_trait/activator/item_key/cell
	label_name = "Cell"
	label_desc = "Cell: The artifact seems to be made of a capacitive material. This material seems to be triggered by eletric currents, such as cells."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 32
	key_item = /obj/item/stock_parts/cell

/datum/xenoartifact_trait/activator/item_key/cell/translation_type_b(datum/source, atom/item, atom/target)
	. = ..()
	do_hint(target, item)
	if(!.)
		return
	var/obj/item/stock_parts/cell/C = item
	if(C.charge-(C.maxcharge*0.25) >= 0 && !check_item_safety(item))
		C.use(C.maxcharge*0.25)
		trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/item_key/cell/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='warning'>[item] detects a capacitive draw of 25%!</span>")
		return ..()

/datum/xenoartifact_trait/activator/item_key/cell/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("charged cell"), XENOA_TRAIT_HINT_DETECT("multitool"))

/*
	Greedy
	This trait activates the artifact when a coin is used
*/
/datum/xenoartifact_trait/activator/item_key/greedy
	material_desc = "slotted"
	label_name = "Greedy"
	label_desc = "Greedy: The artifact seems to be made of a collective material. This material seems to be triggered by inserting coins."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 32
	key_item = /obj/item/coin

/datum/xenoartifact_trait/activator/item_key/greedy/translation_type_b(datum/source, atom/item, atom/target)
	. = ..()
	if(!.)
		return
	handle_input(item, target)

/datum/xenoartifact_trait/activator/item_key/greedy/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("coin"), XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("accept coins to activate"))

/datum/xenoartifact_trait/activator/item_key/greedy/proc/handle_input(atom/item, atom/target)
	var/atom/movable/movable = item
	movable.forceMove(component_parent.parent)
	playsound(component_parent.parent, 'sound/items/coinflip.ogg', 50, TRUE)
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

//Credit variant
/datum/xenoartifact_trait/activator/item_key/greedy/credit
	label_name = "Greedy Δ"
	label_desc = "Greedy Δ: The artifact seems to be made of a collective material. This material seems to be triggered by inserting credit holochips."
	key_item = /obj/item/holochip
	conductivity = 8
	///How many credits we need to activate
	var/credit_requirement = 1

/datum/xenoartifact_trait/activator/item_key/greedy/credit/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("credit holochip"), XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("accept credit holochips to activate"))

/datum/xenoartifact_trait/activator/item_key/greedy/credit/handle_input(atom/item, atom/target)
	var/obj/item/holochip/C = item
	if(C.credits < credit_requirement)
		to_chat(target, "<span class='warning'>[component_parent.parent] demands more than your meager offering!</span>")
		playsound(component_parent.parent, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	C.forceMove(component_parent.parent)
	playsound(component_parent.parent, 'sound/machines/terminal_insert_disc.ogg', 50, TRUE)
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)
	credit_requirement += 1

/*
	Weighted
	This trait activates the artifact when it is picked up
*/
/datum/xenoartifact_trait/activator/weighted
	label_name = "Weighted"
	label_desc = "Weighted: The artifact seems to be made of a weighted material. This material seems to be triggered by motion, such as being picked up."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = 32
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE

/datum/xenoartifact_trait/activator/weighted/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	RegisterSignal(component_parent?.parent, COMSIG_ITEM_EQUIPPED, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_d))

/datum/xenoartifact_trait/activator/weighted/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_ITEM_EQUIPPED)
	return ..()

/datum/xenoartifact_trait/activator/weighted/translation_type_d(datum/source, atom/target)
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/*
	Pitched
	This trait activates the artifact when it is thrown
*/
/datum/xenoartifact_trait/activator/pitched
	label_name = "Pitched"
	label_desc = "Pitched: The artifact seems to be made of an aerodynamic material. This material seems to be triggered by motion, such as being thrown."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = -8
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE

/datum/xenoartifact_trait/activator/pitched/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	RegisterSignal(component_parent?.parent, COMSIG_MOVABLE_IMPACT, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))

/datum/xenoartifact_trait/activator/pitched/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_MOVABLE_IMPACT)
	return ..()

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

/*
	Edible
	This trait activates the artifact when it is eaten
*/
/datum/xenoartifact_trait/activator/edible
	material_desc = "edible"
	label_name = "Edible"
	label_desc = "Edible: The artifact seems to be made of an edible material. This material seems to be triggered by being consumed."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = 16
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///What reagents does this artifact provide when eaten?
	var/food_reagents = list(/datum/reagent/consumable/nutriment = INFINITY)
	///How long does it take us to bite thise?
	var/bite_time = 4 SECONDS
	///How many reagents do we get per bite, maximum
	var/max_bite_reagents = 2

/datum/xenoartifact_trait/activator/edible/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	component_parent.parent.AddComponent(/datum/component/edible,\
		initial_reagents = food_reagents,\
		foodtypes = RAW | MEAT | GORE,\
		volume = INFINITY,\
		pre_eat = CALLBACK(src, PROC_REF(pre_eat)),\
		after_eat = CALLBACK(src, PROC_REF(after_eat)),\
		eat_time = bite_time,\
		bite_consumption = (max_bite_reagents * (component_parent.trait_strength/100)))
	RegisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))

/datum/xenoartifact_trait/activator/edible/remove_parent(datum/source, pensive = TRUE)
	if(!component_parent?.parent)
		return ..()
	var/datum/component/edible/E = component_parent.parent.GetComponent(/datum/component/edible)
	E.RemoveComponent()
	return ..()

/datum/xenoartifact_trait/activator/edible/translation_type_b(datum/source, atom/item, atom/target)
	do_hint(target, item)

/datum/xenoartifact_trait/activator/edible/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_TWIN,  XENOA_TRAIT_HINT_DETECT("health analyzer"), XENOA_TRAIT_HINT_TWIN_VARIANT("start with nutrients"))

/datum/xenoartifact_trait/activator/edible/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/healthanalyzer))
		var/message = ""
		var/index = 0
		for(var/datum/reagent/r as() in food_reagents)
			message = "[message][initial(r.name)][index+1 < length(food_reagents) ? ", " : ""]"
			index += 1
		to_chat(user, "<span class='notice'>[item] detects [message].</span>")
		return ..()

/datum/xenoartifact_trait/activator/edible/proc/pre_eat(eater, feeder)
	return TRUE

/datum/xenoartifact_trait/activator/edible/proc/after_eat(mob/living/eater, mob/feeder, bitecount, bitesize)
	trigger_artifact(eater, XENOA_ACTIVATION_CONTACT)

//CRAZY WACKY VARIANT!
/datum/xenoartifact_trait/activator/edible/random
	label_name = "Edible Δ"
	label_desc = "Edible Δ: The artifact seems to be made of an edible material. This material seems to be triggered by being consumed."
	bite_time = 6 SECONDS
	food_reagents = list()
	conductivity = 8
	///How many random reaagents we're rocking with
	var/random_reagents

/datum/xenoartifact_trait/activator/edible/random/register_parent(datum/source)
	random_reagents = rand(1, 3)
	for(var/i in 1 to random_reagents)
		food_reagents += list(get_random_reagent_id(CHEMICAL_RNG_GENERAL) = 300/random_reagents)
	max_bite_reagents = random_reagents * 2
	return ..()

/datum/xenoartifact_trait/activator/edible/random/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_DETECT("health analyzer"), XENOA_TRAIT_HINT_TWIN_VARIANT("start with 1-3 random chemicals"))

/datum/xenoartifact_trait/activator/edible/random/after_eat(mob/living/eater, mob/feeder, bitecount, bitesize)
	. = ..()
	var/atom/atom_parent = component_parent.parent
	for(var/datum/reagent/R in atom_parent.reagents.reagent_list)
		if(R.type in food_reagents)
			R.volume = 300/random_reagents
	atom_parent.reagents.update_total()

/*
	Observational
	This trait activates the artifact when it's examined
*/
/datum/xenoartifact_trait/activator/examine
	label_name = "Observational"
	label_desc = "Observational: The artifact seems to be made of a light-sensitive material. This material seems to be triggered by observational interaction."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 16

/datum/xenoartifact_trait/activator/examine/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	//Register all the relevant signals we trigger from
	RegisterSignal(component_parent?.parent, COMSIG_PARENT_EXAMINE, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))

/datum/xenoartifact_trait/activator/examine/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/xenoartifact_trait/activator/examine/translation_type_a(datum/source, atom/target)
	if(isliving(target))
		trigger_artifact(target, XENOA_ACTIVATION_SPECIAL)
		return
