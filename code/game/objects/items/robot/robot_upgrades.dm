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
	// if true, is not stored in the robot to be ejected
	// if model is reset
	var/one_use = FALSE

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/robot, user = usr)
	if(robot.stat == DEAD)
		to_chat(user, span_notice("[src] will not function on a deceased cyborg."))
		return FALSE
	if(model_type && !is_type_in_list(robot.model, model_type))
		to_chat(robot, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(user, "There's no mounting point for the module!")
		return FALSE
	return TRUE

/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/robot, user = usr)
	if (!(src in robot.upgrades))
		return FALSE
	return TRUE

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = ""
	one_use = TRUE

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = sanitize_name(stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN))
	log_game("[key_name(user)] have set \"[heldname]\" as a name in a cyborg reclassification board at [loc_name(user)]")

/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		var/oldname = robot.real_name
		var/oldkeyname = key_name(robot)
		robot.custom_name = heldname
		robot.updatename()
		if(oldname == robot.real_name)
			robot.notify_ai(RENAME, oldname, robot.real_name)
		log_game("[key_name(user)] have used a cyborg reclassification board to rename [oldkeyname] to [key_name(robot)] at [loc_name(user)]")

/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"
	one_use = TRUE

/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/robot, user = usr)
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

/obj/item/borg/upgrade/vtec/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		if(robot.speed < 0)
			to_chat(robot, span_notice("A VTEC unit is already installed!"))
			to_chat(user, span_notice("There's no room for another VTEC unit!"))
			return FALSE

		robot.speed = -2 // Gotta go fast.

/obj/item/borg/upgrade/vtec/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		robot.speed = initial(robot.speed)

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		if(robot.ionpulse)
			to_chat(user, span_notice("This unit already has ion thrusters installed!"))
			return FALSE

		robot.ionpulse = TRUE
		robot.toggle_ionpulse() //Enabled by default

/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		robot.ionpulse = FALSE

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/pickaxe/drill/cyborg/D in robot.model)
			robot.model.remove_module(D, TRUE)
		for(var/obj/item/shovel/S in robot.model)
			robot.model.remove_module(S, TRUE)

		var/obj/item/pickaxe/drill/cyborg/diamond/DD = new /obj/item/pickaxe/drill/cyborg/diamond(robot.model)
		robot.model.basic_modules += DD
		robot.model.add_module(DD, FALSE, TRUE)

/obj/item/borg/upgrade/ddrill/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/pickaxe/drill/cyborg/diamond/DD in robot.model)
			robot.model.remove_module(DD, TRUE)

		var/obj/item/pickaxe/drill/cyborg/D = new (robot.model)
		robot.model.basic_modules += D
		robot.model.add_module(D, FALSE, TRUE)
		var/obj/item/shovel/S = new (robot.model)
		robot.model.basic_modules += S
		robot.model.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner, /obj/item/robot_model/guard, /obj/item/robot_model/standard)
	model_flags = BORG_MODEL_MINER

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/robot)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/ore/cyborg/S in robot.model)
			robot.model.remove_module(S, TRUE)

		var/obj/item/storage/bag/ore/holding/H = new /obj/item/storage/bag/ore/holding(robot.model)
		robot.model.basic_modules += H
		robot.model.add_module(H, FALSE, TRUE)

/obj/item/borg/upgrade/soh/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/storage/bag/ore/holding/H in robot.model)
			robot.model.remove_module(H, TRUE)

		var/obj/item/storage/bag/ore/cyborg/S = new (robot.model)
		robot.model.basic_modules += S
		robot.model.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/cutter
	name = "mining cyborg plasma cutter"
	desc = "An upgrade to the mining module granting a self-recharging plasma cutter."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)

/obj/item/borg/upgrade/cutter/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		var/obj/item/gun/energy/plasmacutter/cyborg/P = new(robot.model)
		robot.model.basic_modules += P
		robot.model.add_module(P, FALSE, TRUE)

/obj/item/borg/upgrade/cutter/deactivate(mob/living/silicon/robot/robot, user = usr)
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

/obj/item/borg/upgrade/tboh/action(mob/living/silicon/robot/robot)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/trash/cyborg/TB in robot.model.modules)
			robot.model.remove_module(TB, TRUE)

		var/obj/item/storage/bag/trash/bluespace/cyborg/B = new /obj/item/storage/bag/trash/bluespace/cyborg(robot.model)
		robot.model.basic_modules += B
		robot.model.add_module(B, FALSE, TRUE)

/obj/item/borg/upgrade/tboh/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/trash/bluespace/cyborg/B in robot.model.modules)
			robot.model.remove_module(B, TRUE)

		var/obj/item/storage/bag/trash/cyborg/TB = new (robot.model)
		robot.model.basic_modules += TB
		robot.model.add_module(TB, FALSE, TRUE)

/obj/item/borg/upgrade/amop
	name = "janitor cyborg advanced mop"
	desc = "An advanced mop replacement for the janiborg's standard mop."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR

/obj/item/borg/upgrade/amop/action(mob/living/silicon/robot/robot)
	. = ..()
	if(.)
		for(var/obj/item/mop/cyborg/M in robot.model.modules)
			robot.model.remove_module(M, TRUE)

		var/obj/item/mop/advanced/cyborg/A = new /obj/item/mop/advanced/cyborg(robot.model)
		robot.model.basic_modules += A
		robot.model.add_module(A, FALSE, TRUE)

/obj/item/borg/upgrade/amop/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/mop/advanced/cyborg/A in robot.model.modules)
			robot.model.remove_module(A, TRUE)

		var/obj/item/mop/cyborg/M = new (robot.model)
		robot.model.basic_modules += M
		robot.model.add_module(M, FALSE, TRUE)

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		if(robot.emagged)
			return FALSE

		robot.SetEmagged(1)
		robot.logevent("WARN: hardware installed with missing security certificate!") //A bit of fluff to hint it was an illegal tech item
		robot.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error

		return TRUE

/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		robot.SetEmagged(FALSE)

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		ADD_TRAIT(robot, TRAIT_LAVA_IMMUNE, type)

/obj/item/borg/upgrade/lavaproof/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		REMOVE_TRAIT(robot, TRAIT_LAVA_IMMUNE, type)

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	require_model = TRUE
	var/repair_amount = -5
	/// world.time of next repair
	var/next_repair = 0
	/// Minimum time between repairs
	var/mode = STANDARD
	var/repair_cooldown = 10 SECONDS
	var/msg_cooldown = 0
	var/on = FALSE
	var/powercost = 10
	var/mob/living/silicon/robot/cyborg
	var/datum/action/toggle_action

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/upgrade/selfrepair/U = locate() in robot
		if(U)
			to_chat(user, span_warning("This unit is already equipped with a self-repair module."))
			return FALSE

		cyborg = robot
		icon_state = "selfrepair_off"
		toggle_action = new /datum/action/item_action/toggle(src)
		toggle_action.Grant(robot)

/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		if(toggle_action)
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
		playsound(cyborg.loc, 'sound/machines/terminal_processing.ogg', 30)
		to_chat(cyborg, span_notice("You activate the self-repair module."))
		START_PROCESSING(SSobj, src)
	else
		playsound(cyborg.loc, 'sound/effects/turbolift/turbolift-close.ogg', 90)
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
	playsound(cyborg.loc, 'sound/effects/turbolift/turbolift-close.ogg', 90)
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
			playsound(cyborg.loc, 'sound/items/welder2.ogg', 10) //Quiet so it isn't obnoxious, but still making itself known
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

/obj/item/borg/upgrade/hypospray/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/reagent_containers/borghypo/H in robot.model.modules)
			if(H.accepts_reagent_upgrades)
				for(var/re in additional_reagents)
					H.add_reagent(re)

/obj/item/borg/upgrade/hypospray/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/reagent_containers/borghypo/H in robot.model.modules)
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

/obj/item/borg/upgrade/piercing_hypospray/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		var/found_hypo = FALSE
		for(var/obj/item/reagent_containers/borghypo/H in robot.model.modules)
			H.bypass_protection = TRUE
			found_hypo = TRUE

		if(!found_hypo)
			return FALSE

/obj/item/borg/upgrade/piercing_hypospray/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/reagent_containers/borghypo/H in robot.model.modules)
			H.bypass_protection = initial(H.bypass_protection)

/obj/item/borg/upgrade/defib
	name = "medical cyborg defibrillator"
	desc = "An upgrade to the Medical module, installing a built-in \
		defibrillator, for on the scene revival."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/defib/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		var/obj/item/shockpaddles/cyborg/S = new(robot.model)
		robot.model.basic_modules += S
		robot.model.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/defib/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		var/obj/item/shockpaddles/cyborg/S = locate() in robot.model
		robot.model.remove_module(S, TRUE)


/obj/item/borg/upgrade/processor
	name = "medical cyborg surgical processor"
	desc = "An upgrade to the Medical module, installing a processor \
		capable of scanning surgery disks and carrying \
		out procedures"
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/processor/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		var/obj/item/surgical_processor/SP = new(robot.model)
		robot.model.basic_modules += SP
		robot.model.add_module(SP, FALSE, TRUE)

/obj/item/borg/upgrade/processor/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		var/obj/item/surgical_processor/SP = locate() in robot.model
		robot.model.remove_module(SP, TRUE)

/obj/item/borg/upgrade/ai
	name = "B.O.robot.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon_state = "boris"

/obj/item/borg/upgrade/ai/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		if(locate(/obj/item/borg/upgrade/ai) in robot.upgrades)
			to_chat(user, span_warning("This unit is already an AI shell!"))
			return FALSE
		if(robot.key) //You cannot replace a player unless the key is completely removed.
			to_chat(user, span_warning("Intelligence patterns detected in this [robot.braintype]. Aborting."))
			return FALSE

		robot.make_shell(src)

/obj/item/borg/upgrade/ai/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		if(robot.shell)
			robot.undeploy()
			robot.notify_ai(AI_SHELL)

/obj/item/borg/upgrade/expand
	name = "borg expander"
	desc = "A cyborg resizer, it makes a cyborg huge."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/expand/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)

		if(robot.hasExpanded)
			to_chat(usr, span_notice("This unit already has an expand module installed!"))
			return FALSE

		robot.notransform = TRUE
		var/prev_lockcharge = robot.lockcharge
		robot.SetLockdown(TRUE)
		robot.set_anchored(TRUE)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(TRUE, robot.loc)
		smoke.start()
		sleep(2)
		for(var/i in 1 to 4)
			playsound(robot, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
			sleep(12)
		if(!prev_lockcharge)
			robot.SetLockdown(FALSE)
		robot.set_anchored(FALSE)
		robot.notransform = FALSE
		robot.resize = 2
		robot.hasExpanded = TRUE
		robot.update_transform()

/obj/item/borg/upgrade/expand/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		if (robot.hasExpanded)
			robot.hasExpanded = FALSE
			robot.resize = 0.5
			robot.update_transform()

/obj/item/borg/upgrade/rped
	name = "engineering cyborg RPED"
	desc = "A rapid part exchange device for the engineering cyborg."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "borgrped"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/rped/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)

		var/obj/item/storage/part_replacer/cyborg/RPED = locate() in robot
		if(RPED)
			to_chat(user, span_warning("This unit is already equipped with a RPED module."))
			return FALSE

		RPED = new(robot.model)
		robot.model.basic_modules += RPED
		robot.model.add_module(RPED, FALSE, TRUE)

/obj/item/borg/upgrade/rped/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		var/obj/item/storage/part_replacer/cyborg/RPED = locate() in robot.model
		if (RPED)
			robot.model.remove_module(RPED, TRUE)

/obj/item/borg/upgrade/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg. Permits remote access to the crew monitor."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer_crew"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL
	var/datum/action/crew_monitor

/obj/item/borg/upgrade/pinpointer/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)

		var/obj/item/pinpointer/crew/PP = locate() in robot.model
		if(PP)
			to_chat(user, span_warning("This unit is already equipped with a pinpointer module."))
			return FALSE

		PP = new(robot.model)
		robot.model.basic_modules += PP
		robot.model.add_module(PP, FALSE, TRUE)
		crew_monitor = new /datum/action/item_action/crew_monitor(src)
		crew_monitor.Grant(robot)
		icon_state = "scanner"

/datum/action/item_action/crew_monitor
	name = "Interface With Crew Monitor"

/obj/item/borg/upgrade/pinpointer/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		icon_state = "pinpointer_crew"
		crew_monitor.Remove(robot)
		QDEL_NULL(crew_monitor)
		var/obj/item/pinpointer/crew/PP = locate() in robot.model
		robot.model.remove_module(PP, TRUE)

/obj/item/borg/upgrade/pinpointer/ui_action_click()
	if(..())
		return
	var/mob/living/silicon/robot/Cyborg = usr
	GLOB.crewmonitor.show(Cyborg,Cyborg)


/obj/item/borg/upgrade/transform
	name = "borg module picker (Standard)"
	desc = "Allows you to to turn a cyborg into a standard cyborg."
	icon_state = "cyborg_upgrade3"
	var/obj/item/robot_model/new_model = /obj/item/robot_model/standard

/obj/item/borg/upgrade/transform/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		robot.model.transform_to(new_model)

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

/obj/item/borg/upgrade/transform/security/action(mob/living/silicon/robot/robot, user = usr)
	if(CONFIG_GET(flag/disable_guardianborg))
		to_chat(user, span_warning("Nanotrasen policy disallows the use of weapons of mass destruction."))
		return FALSE
	return ..()

/obj/item/borg/upgrade/circuit_app
	name = "circuit manipulation apparatus"
	desc = "An engineering cyborg upgrade allowing for manipulation of circuit boards."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/circuit_app/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/apparatus/circuit/C = locate() in robot.model.modules
		if(C)
			to_chat(user, span_warning("This unit is already equipped with a circuit apparatus."))
			return FALSE

		C = new(robot.model)
		robot.model.basic_modules += C
		robot.model.add_module(C, FALSE, TRUE)

/obj/item/borg/upgrade/circuit_app/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		var/obj/item/borg/apparatus/circuit/C = locate() in robot.model.modules
		if (C)
			robot.model.remove_module(C, TRUE)

/obj/item/borg/upgrade/beaker_app
	name = "container storage apparatus"
	desc = "A supplementary container storage apparatus for medical cyborgs."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/beaker_app/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/apparatus/container/extra/E = locate() in robot.model.modules
		if(E)
			to_chat(user, span_warning("This unit has no room for additional beaker storage."))
			return FALSE

		E = new(robot.model)
		robot.model.basic_modules += E
		robot.model.add_module(E, FALSE, TRUE)

/obj/item/borg/upgrade/beaker_app/deactivate(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if (.)
		var/obj/item/borg/apparatus/container/extra/E = locate() in robot.model.modules
		if (E)
			robot.model.remove_module(E, TRUE)

/obj/item/borg/upgrade/speciality
	name = "Speciality Module"
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/service)
	var/obj/item/hat
	var/addmodules = list()
	var/list/additional_reagents = list()
	model_flags = BORG_MODEL_SPECIALITY

/obj/item/borg/upgrade/speciality/action(mob/living/silicon/robot/robot, user = usr)
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

/obj/item/borg/upgrade/speciality/deactivate(mob/living/silicon/robot/robot, user = usr)
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
