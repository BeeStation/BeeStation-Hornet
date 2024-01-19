/*
	Activators
	These traits cause the xenoartifact to trigger, activate
	
	* weight - All activators MUST have a weight that is a multiple of 8
	* conductivity - If an activator should have conductivity, it will be a multiple of 8 too
*/

/datum/xenoartifact_trait/activator
	register_targets = FALSE
	weight = 8
	conductivity = 0
	///Do we override the artifact's generic cooldown?
	var/override_cooldown = FALSE

//Throw custom cooldown logic in here
/datum/xenoartifact_trait/activator/proc/trigger_artifact(atom/target, type = XENOA_ACTIVATION_CONTACT, force)
	SIGNAL_HANDLER

	parent.register_target(target, force, type)
	parent.trigger()
	return

/datum/xenoartifact_trait/activator/proc/translation_type_a(datum/source, atom/target)
	SIGNAL_HANDLER

	trigger_artifact(target)

/datum/xenoartifact_trait/activator/proc/translation_type_b(datum/source, atom/item, atom/target)
	SIGNAL_HANDLER

	if(check_item_safety(item))
		return
	trigger_artifact(target)

/datum/xenoartifact_trait/activator/proc/translation_type_c(datum/source, atom/target, atom/item)
	SIGNAL_HANDLER

	if(check_item_safety(item))
		return
	trigger_artifact(target)

/datum/xenoartifact_trait/activator/proc/translation_type_d(datum/source, atom/target)
	SIGNAL_HANDLER

	var/atom/A = parent?.parent
	if(!A.density)
		return
	trigger_artifact(target)

/datum/xenoartifact_trait/activator/proc/check_item_safety(atom/item)
	var/datum/component/anti_artifact/A = item.GetComponent(/datum/component/anti_artifact)
	if(A?.charges)
		A.charges -= 1
		return TRUE
	return FALSE

/*
	Sturdy
	This trait activates the artifact when it's used, like a generic item
*/
/datum/xenoartifact_trait/activator/strudy
	material_desc = "sturdy"
	label_name = "Sturdy"
	label_desc = "Sturdy: The artifact seems to be made of a sturdy material. This material seems to be triggered by physical interaction."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 16

/datum/xenoartifact_trait/activator/strudy/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	//Register all the relevant signals we trigger from
	RegisterSignal(parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))
	RegisterSignal(parent?.parent, COMSIG_MOVABLE_IMPACT, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))
	RegisterSignal(parent?.parent, COMSIG_ITEM_ATTACK_SELF, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))
	RegisterSignal(parent?.parent, COMSIG_ITEM_AFTERATTACK, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_c))
	RegisterSignal(parent?.parent, COMSIG_ATOM_ATTACK_HAND, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_d))

/datum/xenoartifact_trait/activator/strudy/translation_type_b(datum/source, atom/item, atom/target)
	if(check_item_safety(item))
		return
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/strudy/translation_type_d(datum/source, atom/item, atom/target)
	var/atom/A = parent?.parent
	if(!isliving(A.loc) || check_item_safety(item))
		return
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/strudy/translation_type_a(datum/source, atom/target)
	var/atom/A = parent?.parent
	if(A.loc == target)
		trigger_artifact(target, XENOA_ACTIVATION_TOUCH)
		return
	trigger_artifact(target)

/datum/xenoartifact_trait/activator/strudy/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_MATERIAL)
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

/datum/xenoartifact_trait/activator/flammable/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	RegisterSignal(parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))

/datum/xenoartifact_trait/activator/flammable/translation_type_b(datum/source, atom/item, atom/target)
	var/obj/item/I = item
	if(isitem(I) && I.is_hot() && !check_item_safety(item))
		lit = TRUE
		search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)
		START_PROCESSING(SSobj, src)

/datum/xenoartifact_trait/activator/flammable/process(delta_time)
	if(!lit)
		return ..()
	if(search_cooldown_timer)
		return
	for(var/atom/target in oview(parent.target_range, get_turf(parent?.parent)))
		//Only add mobs
		if(!ismob(target))
			continue
		trigger_artifact(target)
		lit = FALSE
		break
	//We can atleast try triggering with no targets, for traits that don't need 'em
	if(!length(parent.targets))
		parent.trigger()
	search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)

/datum/xenoartifact_trait/activator/flammable/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_TRIGGER("'hot' tool"), list("icon" = "exclamation", "desc" = "This trait will, after an arming time, activate on the nearest living target."))

/datum/xenoartifact_trait/activator/flammable/proc/reset_timer()
	if(search_cooldown_timer)
		deltimer(search_cooldown_timer)
	search_cooldown_timer = null

/*
	Timed
	This trait activates the artifact on a timer, which can be toggled on & off
*/
/datum/xenoartifact_trait/activator/timed
	label_name = "Timed"
	label_desc = "Timed: The artifact seems to be made of a harmonizing material. This material seems to activate on a timer, which can be enabled or disabled."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 32
	///Are we looking for targets
	var/searching = FALSE
	///Search cooldown logic
	var/search_cooldown = 4 SECONDS
	var/search_cooldown_timer

/datum/xenoartifact_trait/activator/timed/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	//Register all the relevant signals we trigger from
	RegisterSignal(parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))
	RegisterSignal(parent?.parent, COMSIG_MOVABLE_IMPACT, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))
	RegisterSignal(parent?.parent, COMSIG_ITEM_ATTACK_SELF, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))
	RegisterSignal(parent?.parent, COMSIG_ITEM_AFTERATTACK, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_c))
	RegisterSignal(parent?.parent, COMSIG_ATOM_ATTACK_HAND, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_d))

	search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)
	START_PROCESSING(SSobj, src)

/datum/xenoartifact_trait/activator/timed/trigger_artifact(atom/target, type, force)
	if(force)
		return ..()
	else 
		searching = !searching

/datum/xenoartifact_trait/activator/timed/process(delta_time)
	if(!searching)
		return
	if(search_cooldown_timer)
		return
	playsound(get_turf(parent?.parent), 'sound/effects/clock_tick.ogg', 60, TRUE)
	for(var/atom/target in oview(parent.target_range, get_turf(parent?.parent)))
		//Only add mobs
		if(!ismob(target))
			continue
		trigger_artifact(target, XENOA_ACTIVATION_CONTACT, TRUE)
		break
	if(!length(parent.targets))
		parent.trigger()
	search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)

/datum/xenoartifact_trait/activator/timed/translation_type_b(datum/source, atom/item, atom/target)
	if(check_item_safety(item))
		return
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/timed/translation_type_d(datum/source, atom/item, atom/target)
	var/atom/A = parent?.parent
	if(!isliving(A.loc) || check_item_safety(item))
		return
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/timed/translation_type_a(datum/source, atom/target)
	var/atom/A = parent?.parent
	if(A.loc == target)
		trigger_artifact(target, XENOA_ACTIVATION_TOUCH)
		return
	trigger_artifact(target)

/datum/xenoartifact_trait/activator/timed/get_dictionary_hint()
	. = ..()
	return list(list("icon" = "exclamation", "desc" = "This trait will, after an arming time, activate on the nearest living target, periodically."))

/datum/xenoartifact_trait/activator/timed/proc/reset_timer()
	if(search_cooldown_timer)
		deltimer(search_cooldown_timer)
	search_cooldown_timer = null

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

	///Reference to our particle holder - we need to use holders & vis contents, otherwise shit gets fucky with filters
	//TODO: Make this a dedicated subtype with no mouse opacity - Racc
	var/atom/movable/particle_holder

/datum/xenoartifact_trait/activator/signal/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	//Code
	code = rand(0, 100)
	//Signal
	signal = new(list("code" = code))
	//Frequency
	radio_connection = SSradio.add_object(src, FREQ_SIGNALER, "[RADIO_XENOA]_[REF(src)]")
	radio_connection.add_listener(src)

	setup_generic_item_hint()
	addtimer(CALLBACK(src, PROC_REF(do_sonar)), 5 SECONDS)

/datum/xenoartifact_trait/minor/signaller/Destroy(force, ...)
	SSradio.remove_object(src, FREQ_SIGNALER)
	QDEL_NULL(signal)
	return ..()

/datum/xenoartifact_trait/activator/signal/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	//Build particle holder
	particle_holder = new(parent?.parent)
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
	return list(XENOA_TRAIT_HINT_TRIGGER("signaller assembly"), XENOA_TRAIT_HINT_DETECT("analyzer, which will also reveal its trigger code & frequency"), list("icon" = "exclamation", "desc" = "This trait will activate on the nearest living target."))

/datum/xenoartifact_trait/activator/signal/proc/receive_signal(datum/signal/signal)
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	for(var/atom/target in oview(parent.target_range, get_turf(parent?.parent)))
		//Only add mobs
		if(!ismob(target))
			continue
		trigger_artifact(target, XENOA_ACTIVATION_CONTACT)
		break
	if(!length(parent.targets))
		parent.trigger()

/datum/xenoartifact_trait/activator/signal/proc/do_sonar(repeat = TRUE)
	if(QDELETED(src))
		return
	playsound(get_turf(parent?.parent), 'sound/effects/ping.ogg', 60, TRUE)
	var/rand_time = rand(5, 15) SECONDS
	addtimer(CALLBACK(src, PROC_REF(do_sonar)), rand_time)

/*
	Cell
	This trait activates the artifact when a battery is used
*/
/datum/xenoartifact_trait/activator/cell
	label_name = "Cell"
	label_desc = "Cell: The artifact seems to be made of a capacitive material. This material seems to be triggered by eletric currents, such as cells."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 32

/datum/xenoartifact_trait/activator/cell/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	RegisterSignal(parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))

/datum/xenoartifact_trait/activator/cell/translation_type_b(datum/source, atom/item, atom/target)
	do_hint(target, item)
	var/obj/item/stock_parts/cell/C = item
	if(istype(C) && C.charge-(C.maxcharge*0.25) >= 0 && !check_item_safety(item))
		C.use(C.maxcharge*0.25)
		trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/cell/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='warning'>[item] detects a capacitive draw of 25%!</span>")
		return ..()

/datum/xenoartifact_trait/activator/cell/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("charged cell"), XENOA_TRAIT_HINT_DETECT("multitool"))

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

/datum/xenoartifact_trait/activator/weighted/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	RegisterSignal(parent?.parent, COMSIG_ATOM_ATTACK_HAND, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_d))

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

/datum/xenoartifact_trait/activator/pitched/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	RegisterSignal(parent?.parent, COMSIG_MOVABLE_IMPACT, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))
