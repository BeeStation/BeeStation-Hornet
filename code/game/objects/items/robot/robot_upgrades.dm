#define STANDARD "standard" //repair module is operating in standard repair mode
#define CRITICAL "critical" //repair module is operating in critical repair mode

// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = FALSE
	var/installed = 0
	var/require_model = FALSE
	var/list/model_type = null
	///	Bitflags listing model compatibility. Used in the exosuit fabricator for creating sub-categories.
	var/list/model_flags = NONE

	/// List of items to add with the module, if any
	var/list/items_to_add
	/// List of items to remove with the module, if any
	var/list/items_to_remove
	// if true, is not stored in the robot to be ejected if model is reset
	var/one_use = FALSE
	// If the module allows duplicates of itself to exist within the borg.
	// one_use technically makes this value not mean anything, maybe could be just one variable with flags?
	var/allow_duplicates = FALSE

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	if(borg.stat == DEAD)
		to_chat(user, span_warning("[src] will not function on a deceased cyborg!"))
		return FALSE
	if(model_type && !is_type_in_list(borg.model, model_type))
		to_chat(borg, span_alert("Upgrade mounting error! No suitable hardpoint detected."))
		to_chat(user, span_warning("There's no mounting point for the module!"))
		return FALSE
	if(!allow_duplicates && (locate(type) in borg.contents))
		to_chat(borg, span_alert("Upgrade mounting error! Hardpoint already occupied!"))
		to_chat(user, span_warning("The mounting point for the module is already occupied!"))
		return FALSE
	// Handles adding/removing items.
	if(length(items_to_add))
		install_items(borg, user, items_to_add)
	if(length(items_to_remove))
		remove_items(borg, user, items_to_remove)
	return TRUE

/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	if (!(src in borg.upgrades))
		return FALSE

	// Handles reverting the items back
	if(length(items_to_add))
		remove_items(borg, user, items_to_add)
	if(length(items_to_remove))
		install_items(borg, user, items_to_remove)
	return TRUE

// Handles adding items with the module
/obj/item/borg/upgrade/proc/install_items(mob/living/silicon/robot/borg, mob/living/user = usr, list/items)
	for(var/item_to_add in items)
		var/obj/item/module_item = new item_to_add(borg.model.modules)
		borg.model.basic_modules += module_item
		borg.model.add_module(module_item, FALSE, TRUE)
	return TRUE

// Handles removing some items as the module is installed
/obj/item/borg/upgrade/proc/remove_items(mob/living/silicon/robot/borg, mob/living/user = usr, list/items)
	for(var/item_to_remove in items)
		var/obj/item/module_item = locate(item_to_remove) in borg.model.modules
		if (module_item)
			borg.model.remove_module(module_item, TRUE)
	return TRUE

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = ""
	one_use = TRUE

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = sanitize_name(stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN), allow_numbers = TRUE)
	log_game("[key_name(user)] have set \"[heldname]\" as a name in a cyborg reclassification board at [loc_name(user)]")

/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/oldname = borg.real_name
	var/oldkeyname = key_name(borg)
	borg.custom_name = heldname
	borg.updatename()
	if(oldname == borg.real_name)
		borg.notify_ai(AI_NOTIFICATION_CYBORG_RENAMED, oldname, borg.real_name)
	user.log_message("used a cyborg reclassification board to rename [oldkeyname] to [key_name(borg)]", LOG_GAME)

/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"
	one_use = TRUE

/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/robot, mob/living/user = usr)
	if(robot.health < 0)
		to_chat(user, span_warning("You have to repair the cyborg before using this module!"))
		return FALSE

	if(robot.mind)
		robot.mind.grab_ghost()
		playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)

	robot.revive()
	robot.logevent("WARN -- System recovered from unexpected shutdown.")
	robot.logevent("System brought online.")

/obj/item/borg/upgrade/vtec
	name = "cyborg VTEC module"
	desc = "Used to kick in a cyborg's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_model = TRUE

/obj/item/borg/upgrade/vtec/action(mob/living/silicon/robot/robot, mob/living/user = usr)
	. = ..()
	if(.)
		if(robot.speed < 0)
			to_chat(robot, span_notice("A VTEC unit is already installed!"))
			to_chat(user, span_notice("There's no room for another VTEC unit!"))
			return FALSE

		robot.speed = -2 // Gotta go fast.

/obj/item/borg/upgrade/vtec/deactivate(mob/living/silicon/robot/robot, mob/living/user = usr)
	. = ..()
	if (.)
		robot.speed = initial(robot.speed)

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if(borg.ionpulse)
		to_chat(user, span_warning("This unit already has ion thrusters installed!"))
		return FALSE

	borg.ionpulse = TRUE
	borg.toggle_ionpulse() //Enabled by default

/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	borg.ionpulse = FALSE

/obj/item/borg/upgrade/diamond_drill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER

	items_to_add = list(/obj/item/pickaxe/drill/diamonddrill)
	items_to_remove = list(/obj/item/pickaxe/drill, /obj/item/shovel)

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner, /obj/item/robot_model/guard, /obj/item/robot_model/standard)
	model_flags = BORG_MODEL_MINER

	items_to_add = list(/obj/item/storage/bag/ore/holding)
	items_to_remove = list(/obj/item/storage/bag/ore/cyborg)

/obj/item/borg/upgrade/cutter
	name = "mining cyborg plasma cutter"
	desc = "An upgrade to the mining module granting a self-recharging plasma cutter."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)

/obj/item/borg/upgrade/cutter/action(mob/living/silicon/robot/robot, mob/living/user = usr)
	. = ..()
	if(.)
		var/obj/item/gun/energy/plasmacutter/cyborg/P = new(robot.model)
		robot.model.basic_modules += P
		robot.model.add_module(P, FALSE, TRUE)

/obj/item/borg/upgrade/cutter/deactivate(mob/living/silicon/robot/robot, mob/living/user = usr)
	. = ..()
	if (.)
		var/obj/item/gun/energy/plasmacutter/cyborg/P = locate() in robot.model
		robot.model.remove_module(P, TRUE)

/obj/item/borg/upgrade/tboh
	name = "janitor cyborg trash bag of holding"
	desc = "A trash bag of holding replacement for the janiborg's standard trash bag."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR

	items_to_add = list(/obj/item/storage/bag/trash/bluespace/cyborg)
	items_to_remove = list(/obj/item/storage/bag/trash)

/obj/item/borg/upgrade/amop
	name = "janitor cyborg advanced mop"
	desc = "An advanced mop replacement for the janiborg's standard mop."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR

	items_to_add = list(/obj/item/mop/advanced)
	items_to_remove = list(/obj/item/mop)

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if(borg.emagged)
		return FALSE

	borg.SetEmagged(TRUE)
	borg.logevent("WARN: hardware installed with missing security certificate!") //A bit of fluff to hint it was an illegal tech item
	borg.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error

	return TRUE

/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	borg.SetEmagged(FALSE)

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	borg.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), type)

/obj/item/borg/upgrade/lavaproof/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	borg.remove_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), type)

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	require_model = TRUE
	var/repair_amount = -5
	/// world.time of next repair
	var/next_repair = 0
	var/mode = STANDARD
	/// Minimum time between repairs
	var/repair_cooldown = 10 SECONDS
	var/msg_cooldown = 0
	var/on = FALSE
	var/powercost = 10
	var/mob/living/silicon/robot/cyborg
	var/datum/action/toggle_action

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	cyborg = borg
	icon_state = "selfrepair_off"
	toggle_action = new /datum/action/item_action/toggle(src)
	toggle_action.Grant(borg)

/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if(toggle_action)
		toggle_action.Remove(borg)
		QDEL_NULL(toggle_action)
	cyborg = null
	deactivate_sr()

/obj/item/borg/upgrade/selfrepair/dropped()
	..()
	addtimer(CALLBACK(src, PROC_REF(check_dropped)), 1)

/obj/item/borg/upgrade/selfrepair/proc/check_dropped()
	if(loc != cyborg)
		if(toggle_action)
			QDEL_NULL(toggle_action)
		cyborg = null
		deactivate_sr()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	on = !on
	if(on)
		playsound(cyborg, 'sound/machines/terminal_processing.ogg', 30)
		to_chat(cyborg, span_notice("You activate the self-repair module."))
		START_PROCESSING(SSobj, src)
	else
		playsound(cyborg, 'sound/effects/turbolift/turbolift-close.ogg', 90)
		to_chat(cyborg, span_notice("You deactivate the self-repair module."))
		STOP_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/borg/upgrade/selfrepair/update_icon_state()
	if(cyborg)
		icon_state = "selfrepair_[on ? "on" : "off"]"
	else
		icon_state = "cyborg_upgrade5"
	return ..()

/obj/item/borg/upgrade/selfrepair/proc/deactivate_sr()
	playsound(cyborg, 'sound/effects/turbolift/turbolift-close.ogg', 90)
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_appearance()

/obj/item/borg/upgrade/selfrepair/process()
	if(world.time < next_repair)
		return

	if(cyborg && (cyborg.stat != DEAD) && on)
		if(!cyborg.cell)
			to_chat(cyborg, span_warning("[src] deactivated. Please, insert the power cell."))
			deactivate_sr()
			return

		if(cyborg.cell.charge < powercost * 20)
			to_chat(cyborg, span_warning("Low power levels detected. [src] deactivated."))
			deactivate_sr()
			return

		if(cyborg.health < cyborg.maxHealth)
			if(cyborg.health < cyborg.maxHealth / 2 && mode == STANDARD)
				mode = CRITICAL
				to_chat(cyborg, span_notice("[src] now operating in [span_boldnotice("[mode]")] mode."))
				repair_amount = initial(repair_amount) * 2
				powercost = initial(repair_amount) * 3
			else if (cyborg.health >= cyborg.maxHealth / 2 && mode == CRITICAL)
				mode = STANDARD
				to_chat(cyborg, span_notice("[src] now operating in [span_boldnotice("[mode]")] mode."))
				repair_amount = initial(repair_amount)
				powercost = initial(powercost)
			if(cyborg.getBruteLoss())
				cyborg.adjustBruteLoss(repair_amount)
			else if(cyborg.getFireLoss())
				cyborg.adjustFireLoss(repair_amount)
			playsound(cyborg, 'sound/items/welder2.ogg', 10) //Quiet so it isn't obnoxious, but still making itself known
			cyborg.cell.use(powercost)
			cyborg.updatehealth()
		else
			to_chat(cyborg, span_warning("Unit fully repaired. [src] deactivated."))
			deactivate_sr()
		next_repair = world.time + repair_cooldown
	else
		deactivate_sr()

/obj/item/borg/upgrade/hypospray
	name = "medical cyborg hypospray advanced synthesiser"
	desc = "An upgrade to the Medical module cyborg's hypospray, allowing it \
		to produce more advanced and complex medical reagents."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL
	var/list/additional_reagents = list()

/obj/item/borg/upgrade/hypospray/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/reagent_containers/borghypo/H in borg.model.modules)
		if(H.accepts_reagent_upgrades)
			for(var/re in additional_reagents)
				H.add_reagent(re)

/obj/item/borg/upgrade/hypospray/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/reagent_containers/borghypo/H in borg.model.modules)
		if(H.accepts_reagent_upgrades)
			for(var/re in additional_reagents)
				H.del_reagent(re)

/obj/item/borg/upgrade/hypospray/expanded
	name = "medical cyborg expanded hypospray"
	desc = "An upgrade to the Medical module's hypospray, allowing it \
		to treat a wider range of conditions and problems."
	additional_reagents = list(/datum/reagent/medicine/mannitol, /datum/reagent/medicine/oculine, /datum/reagent/medicine/inacusiate,
		/datum/reagent/medicine/mutadone, /datum/reagent/medicine/oxandrolone, /datum/reagent/medicine/sal_acid, /datum/reagent/medicine/rezadone,
		/datum/reagent/medicine/pen_acid)

/obj/item/borg/upgrade/piercing_hypospray
	name = "cyborg piercing hypospray"
	desc = "An upgrade to a cyborg's hypospray, allowing it to \
		pierce armor and thick material."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/piercing_hypospray/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/found_hypo = FALSE
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.modules)
		hypo.bypass_protection = TRUE
		found_hypo = TRUE
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.emag_modules)
		hypo.bypass_protection = TRUE
		found_hypo = TRUE

	if(!found_hypo)
		to_chat(user, span_warning("This unit is already equipped with a piercing hypospray upgrade!")) //check to see if we already have this module
		return FALSE

/obj/item/borg/upgrade/piercing_hypospray/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.modules)
		hypo.bypass_protection = initial(hypo.bypass_protection)
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.emag_modules)
		hypo.bypass_protection = initial(hypo.bypass_protection)

/obj/item/borg/upgrade/defib
	name = "medical cyborg defibrillator"
	desc = "An upgrade to the Medical module, installing a built-in \
		defibrillator, for on the scene revival."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL

	items_to_add = list(/obj/item/shockpaddles/cyborg)

/obj/item/borg/upgrade/defib/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/obj/item/borg/upgrade/defib/backpack/defib_pack = locate() in borg //If a full defib unit was used to upgrade prior, we can just pop it out now and replace
	if(defib_pack)
		defib_pack.deactivate(borg, user)
		to_chat(user, span_notice("The defibrillator pops out of the chassis as the compact upgrade installs."))

///A version of the above that also acts as a holder of an actual defibrillator item used in place of the upgrade chip.
/obj/item/borg/upgrade/defib/backpack
	var/obj/item/defibrillator/defib_instance

/obj/item/borg/upgrade/defib/backpack/Initialize(mapload, obj/item/defibrillator/defib)
	. = ..()
	if(isnull(defib))
		defib = new /obj/item/defibrillator
	defib_instance = defib
	name = defib_instance.name
	defib_instance.moveToNullspace()
	RegisterSignals(defib_instance, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(on_defib_instance_qdel_or_moved))

/obj/item/borg/upgrade/defib/backpack/proc/on_defib_instance_qdel_or_moved(obj/item/defibrillator/defib)
	SIGNAL_HANDLER
	defib_instance = null
	if(!QDELETED(src))
		qdel(src)

/obj/item/borg/upgrade/defib/backpack/Destroy()
	if(!QDELETED(defib_instance))
		QDEL_NULL(defib_instance)
	return ..()

/obj/item/borg/upgrade/defib/backpack/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	defib_instance?.forceMove(borg.drop_location()) // [on_defib_instance_qdel_or_moved()] handles the rest.

/obj/item/borg/upgrade/processor
	name = "medical cyborg surgical processor"
	desc = "An upgrade to the Medical module, installing a processor \
		capable of scanning surgery disks and carrying \
		out procedures"
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL

	items_to_add = list(/obj/item/surgical_processor)

/obj/item/borg/upgrade/ai
	name = "B.O.robot.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon_state = "boris"

/obj/item/borg/upgrade/ai/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if(borg.key) //You cannot replace a player unless the key is completely removed.
		to_chat(user, span_warning("Intelligence patterns detected in this [borg.braintype]. Aborting."))
		return FALSE

	borg.make_shell(src)

/obj/item/borg/upgrade/ai/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!. || !borg.shell)
		return .

	borg.undeploy()
	borg.notify_ai(AI_NOTIFICATION_AI_SHELL)

/obj/item/borg/upgrade/expand
	name = "borg expander"
	desc = "A cyborg resizer, it makes a cyborg huge."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/expand/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!. || HAS_TRAIT(borg, TRAIT_NO_TRANSFORM))
		return FALSE

	if(borg.hasExpanded)
		to_chat(usr, span_warning("This unit already has an expand module installed!"))
		return FALSE

	ADD_TRAIT(borg, TRAIT_NO_TRANSFORM, REF(src))
	var/prev_lockcharge = borg.lockcharge
	borg.SetLockdown(TRUE)
	borg.set_anchored(TRUE)
	do_smoke(1, borg, borg.loc)
	sleep(0.2 SECONDS)
	for(var/i in 1 to 4)
		playsound(borg, pick(
			'sound/items/drill_use.ogg',
			'sound/items/jaws_cut.ogg',
			'sound/items/jaws_pry.ogg',
			'sound/items/welder.ogg',
			'sound/items/ratchet.ogg',
			), 80, TRUE, -1)
		sleep(1.2 SECONDS)
	if(!prev_lockcharge)
		borg.SetLockdown(FALSE)
	borg.set_anchored(FALSE)
	REMOVE_TRAIT(borg, TRAIT_NO_TRANSFORM, REF(src))
	borg.hasExpanded = TRUE
	borg.update_transform(2)

/obj/item/borg/upgrade/expand/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if (borg.hasExpanded)
		borg.hasExpanded = FALSE
		borg.update_transform(0.5)

/obj/item/borg/upgrade/rped
	name = "engineering cyborg RPED (expanded)"
	desc = "An expanded rapid part exchange device for the engineering cyborg."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "borgrped"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING

	items_to_add = list(/obj/item/storage/part_replacer/cyborg)

/obj/item/borg/upgrade/smallrped
	name = "engineering cyborg RPED"
	desc = "A regular version of rapid part exchange device for the engineering cyborg."
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING
	items_to_add = list(/obj/item/storage/part_replacer/cyborg/small)

/obj/item/borg/upgrade/rped/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/obj/item/borg/upgrade/smallrped/upgrade = locate() in borg
	var/obj/item/storage/part_replacer/cyborg/small/replacer = locate() in borg.model.modules
	if(upgrade)
		to_chat(user, span_notice("The old RPED module is now expanded and gets more space"))
		replacer.emptyStorage()
		replacer.forceMove(get_turf(borg))
		qdel(upgrade)

/obj/item/borg/upgrade/inducer
	name = "engineering integrated power inducer"
	desc = "An integrated inducer that can charge a device's internal cell from power provided by the cyborg."
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING

	items_to_add = list(/obj/item/inducer/cyborg)

/obj/item/borg/upgrade/bslightreplacer
	name = "janitor cyborg BS Light Replacer"
	desc = "A bluespace rapid part exchange device for the janitor cyborg."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer_blue0"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR

/obj/item/borg/upgrade/bslightreplacer/action(mob/living/silicon/robot/robot, mob/living/user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/upgrade/bslightreplacer/BSLR = locate() in robot.contents
		if(BSLR)
			to_chat(user, span_warning("This unit is already equipped with a BS Light Replacer module."))
			return FALSE

		var/obj/item/lightreplacer/bluespace/cyborg/newBSLR = new(robot.model)
		robot.model.basic_modules += newBSLR
		robot.model.add_module(newBSLR, FALSE, TRUE)

/obj/item/borg/upgrade/bslightreplacer/deactivate(mob/living/silicon/robot/robot, mob/living/user = usr)
	. = ..()
	if (.)
		var/obj/item/lightreplacer/bluespace/cyborg/BSLR = locate() in robot.model
		if (BSLR)
			robot.model.remove_module(BSLR, TRUE)

/obj/item/borg/upgrade/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg. Permits remote access to the crew monitor."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer_crew"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL

	items_to_add = list(/obj/item/pinpointer/crew)
	var/datum/action/crew_monitor

/obj/item/borg/upgrade/pinpointer/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	crew_monitor = new /datum/action/item_action/crew_monitor(src)
	crew_monitor.Grant(borg)
	icon_state = "scanner"

/obj/item/borg/upgrade/pinpointer/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	icon_state = "pinpointer_crew"
	crew_monitor.Remove(borg)
	QDEL_NULL(crew_monitor)

/obj/item/borg/upgrade/pinpointer/ui_action_click()
	if(..())
		return
	var/mob/living/silicon/robot/borg = usr
	GLOB.crewmonitor.show(borg,borg)

/datum/action/item_action/crew_monitor
	name = "Interface With Crew Monitor"

/obj/item/borg/upgrade/transform
	name = "borg module picker (Standard)"
	desc = "Allows you to to turn a cyborg into a standard cyborg."
	icon_state = "cyborg_upgrade3"
	var/obj/item/robot_model/new_model = /obj/item/robot_model/standard

/obj/item/borg/upgrade/transform/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(.)
		borg.model.transform_to(new_model)

/obj/item/borg/upgrade/transform/clown
	name = "borg module picker (Clown)"
	desc = "Allows you to to turn a cyborg into a clown, honk."
	icon_state = "cyborg_upgrade3"
	new_model = /obj/item/robot_model/clown

/obj/item/borg/upgrade/transform/guard
	name = "borg module picker (Guard)"
	desc = "Allows you to turn a cyborg into a hunter, HALT!"
	icon_state = "cyborg_upgrade3"
	new_model = /obj/item/robot_model/guard
	model_flags = BORG_MODEL_SECURITY

/obj/item/borg/upgrade/transform/security/action(mob/living/silicon/robot/robot, mob/living/user = usr)
	if(CONFIG_GET(flag/disable_guardianborg))
		to_chat(user, span_warning("Nanotrasen policy disallows the use of weapons of mass destruction."))
		return FALSE
	return ..()

/obj/item/borg/upgrade/engineering_app
	name = "engineering manipulation apparatus"
	desc = "An engineering cyborg upgrade allowing for manipulation of circuit boards and other engineering matter."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING

	items_to_add = list(/obj/item/borg/apparatus/engineering)

/obj/item/borg/upgrade/beaker_app
	name = "container storage apparatus"
	desc = "A supplementary container storage apparatus for medical cyborgs."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL

	items_to_add = list(/obj/item/borg/apparatus/beaker/extra)

/obj/item/borg/upgrade/bs_syringe
	name = "advanced syringe"
	desc = "Bluespace technology that expands capacity of your standard cyborg syringe."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL

	items_to_add = list(/obj/item/reagent_containers/syringe/bluespace)
	items_to_remove = list(/obj/item/reagent_containers/syringe)

/obj/item/borg/upgrade/speciality
	name = "Speciality Module"
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/service)
	var/obj/item/hat
	var/addmodules = list()
	var/list/additional_reagents = list()
	model_flags = BORG_MODEL_SPECIALITY

/obj/item/borg/upgrade/speciality/action(mob/living/silicon/robot/robot, mob/living/user = usr)
	. = ..()
	if(.)
		for(var/obj/item/borg/upgrade/SPEC in robot.upgrades)
			if (istype(SPEC,/obj/item/borg/upgrade/speciality) && SPEC != src)
				SPEC.deactivate(robot)
				robot.upgrades -= SPEC
				qdel(SPEC)


		for(var/module in src.addmodules)
			var/obj/item/nmodule = locate(module) in robot
			if (!nmodule)
				nmodule = new module(robot.model)
				robot.model.basic_modules += nmodule
				robot.model.add_module(nmodule, FALSE, TRUE)

		for(var/obj/item/reagent_containers/borghypo/borgshaker/H in robot.model.modules)
			for(var/re in additional_reagents)
				H.add_reagent(re)

		if(hat && robot.hat_offset != INFINITY && !robot.hat)
			var/obj/item/equipt = new hat(src)
			if (equipt )
				robot.place_on_head(equipt)

/obj/item/borg/upgrade/speciality/deactivate(mob/living/silicon/robot/robot, mob/living/user = usr)
	. = ..()
	if (.)
		//Remove existing modules indiscriminately
		for(var/module in src.addmodules)
			var/dmod = locate(module) in robot.model.modules
			if (dmod)
				robot.model.remove_module(dmod, TRUE)
		for(var/obj/item/reagent_containers/borghypo/borgshaker/H in robot.model.modules)
			for(var/re in additional_reagents)
				H.del_reagent(re)

/obj/item/borg/upgrade/speciality/kitchen
	name = "Cook Speciality"
	desc = "A service cyborg upgrade allowing for basic food handling."
	hat = /obj/item/clothing/head/utility/chefhat
	addmodules = list (
		/obj/item/knife/kitchen,
		/obj/item/kitchen/rollingpin,
	)
	additional_reagents = list(
		/datum/reagent/consumable/enzyme,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/flour,
		/datum/reagent/water,
	)

/obj/item/borg/upgrade/speciality/botany
	name = "Botany Speciality"
	desc = "A service cyborg upgrade allowing for plant tending and manipulation."
	hat = /obj/item/clothing/head/costume/rice_hat
	addmodules = list (
		/obj/item/storage/bag/plants/portaseeder,
		/obj/item/cultivator,
		/obj/item/plant_analyzer,
		/obj/item/shovel/spade,
	)
	additional_reagents = list(
		/datum/reagent/water,
	)


/obj/item/borg/upgrade/speciality/casino
	name = "Gambler Speciality"
	desc = "It's not crew harm if they do it themselves!"
	hat = /obj/item/clothing/head/costume/rabbitears
	addmodules = list (
		/obj/item/gobbler,
		/obj/item/storage/pill_bottle/dice_cup/cyborg,
		/obj/item/toy/cards/deck/cyborg,
	)

/obj/item/borg/upgrade/speciality/party
	name = "Party Speciality"
	desc = "The night's still young..."
	hat = /obj/item/clothing/head/beanie/rasta
	addmodules = list (
		/obj/item/stack/tile/light/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/dance_trance,
	)

#undef STANDARD
#undef CRITICAL
