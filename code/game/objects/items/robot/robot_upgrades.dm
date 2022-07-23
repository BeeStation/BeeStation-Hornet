// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = FALSE
	var/installed = 0
	var/require_module = 0
	var/list/module_type = null
	///	Bitflags listing module compatibility. Used in the exosuit fabricator for creating sub-categories.
	var/list/module_flags = NONE
	// if true, is not stored in the robot to be ejected
	// if module is reset
	var/one_use = FALSE

/obj/item/borg/upgrade/proc/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	if(R.stat == DEAD)
		to_chat(user, "<span class='notice'>[src] will not function on a deceased cyborg.</span>")
		return FALSE
	if(module_type && !is_type_in_list(R.module, module_type))
		to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(user, "There's no mounting point for the module!")
		return FALSE
	return TRUE

/obj/item/borg/upgrade/proc/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	if (!(src in R.upgrades))
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

/obj/item/borg/upgrade/rename/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/oldname = R.real_name
		var/oldkeyname = key_name(R)
		R.custom_name = heldname
		R.updatename()
		if(oldname == R.real_name)
			R.notify_ai(RENAME, oldname, R.real_name)
		log_game("[key_name(user)] have used a cyborg reclassification board to rename [oldkeyname] to [key_name(R)] at [loc_name(user)]")

/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"
	one_use = TRUE

/obj/item/borg/upgrade/restart/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	if(R.health < 0)
		to_chat(user, "<span class='warning'>You have to repair the cyborg before using this module!</span>")
		return FALSE

	if(R.mind)
		R.mind.grab_ghost()
		playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)

	R.revive()

/obj/item/borg/upgrade/vtec
	name = "cyborg VTEC module"
	desc = "Used to kick in a cyborg's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/borg/upgrade/vtec/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.speed < 0)
			to_chat(R, "<span class='notice'>A VTEC unit is already installed!</span>")
			to_chat(user, "<span class='notice'>There's no room for another VTEC unit!</span>")
			return FALSE

		R.speed = -2 // Gotta go fast.

/obj/item/borg/upgrade/vtec/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.speed = initial(R.speed)

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/security)
	module_flags = BORG_MODULE_SECURITY

/obj/item/borg/upgrade/disablercooler/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
		if(!T)
			to_chat(user, "<span class='notice'>There's no disabler in this unit!</span>")
			return FALSE
		if(T.charge_delay <= 2)
			to_chat(R, "<span class='notice'>A cooling unit is already installed!</span>")
			to_chat(user, "<span class='notice'>There's no room for another cooling unit!</span>")
			return FALSE

		T.charge_delay = max(2 , T.charge_delay - 4)

/obj/item/borg/upgrade/disablercooler/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
		if(!T)
			return FALSE
		T.charge_delay = initial(T.charge_delay)

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/thrusters/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.ionpulse)
			to_chat(user, "<span class='notice'>This unit already has ion thrusters installed!</span>")
			return FALSE

		R.ionpulse = TRUE

/obj/item/borg/upgrade/thrusters/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.ionpulse = FALSE

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/miner)
	module_flags = BORG_MODULE_MINER

/obj/item/borg/upgrade/ddrill/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/pickaxe/drill/cyborg/D in R.module)
			R.module.remove_module(D, TRUE)
		for(var/obj/item/shovel/S in R.module)
			R.module.remove_module(S, TRUE)

		var/obj/item/pickaxe/drill/cyborg/diamond/DD = new /obj/item/pickaxe/drill/cyborg/diamond(R.module)
		R.module.basic_modules += DD
		R.module.add_module(DD, FALSE, TRUE)

/obj/item/borg/upgrade/ddrill/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/pickaxe/drill/cyborg/diamond/DD in R.module)
			R.module.remove_module(DD, TRUE)

		var/obj/item/pickaxe/drill/cyborg/D = new (R.module)
		R.module.basic_modules += D
		R.module.add_module(D, FALSE, TRUE)
		var/obj/item/shovel/S = new (R.module)
		R.module.basic_modules += S
		R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/miner)
	module_flags = BORG_MODULE_MINER

/obj/item/borg/upgrade/soh/apply_upgrade(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/ore/cyborg/S in R.module)
			R.module.remove_module(S, TRUE)

		var/obj/item/storage/bag/ore/holding/H = new /obj/item/storage/bag/ore/holding(R.module)
		R.module.basic_modules += H
		R.module.add_module(H, FALSE, TRUE)

/obj/item/borg/upgrade/soh/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/storage/bag/ore/holding/H in R.module)
			R.module.remove_module(H, TRUE)

		var/obj/item/storage/bag/ore/cyborg/S = new (R.module)
		R.module.basic_modules += S
		R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/cutter
	name = "mining cyborg plasma cutter"
	desc = "An upgrade to the mining module granting a self-recharging plasma cutter."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/miner)

/obj/item/borg/upgrade/cutter/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/gun/energy/plasmacutter/cyborg/P = new(R.module)
		R.module.basic_modules += P
		R.module.add_module(P, FALSE, TRUE)

/obj/item/borg/upgrade/cutter/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/gun/energy/plasmacutter/cyborg/P = locate() in R.module
		R.module.remove_module(P, TRUE)

/obj/item/borg/upgrade/tboh
	name = "janitor cyborg trash bag of holding"
	desc = "A trash bag of holding replacement for the janiborg's standard trash bag."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/janitor)
	module_flags = BORG_MODULE_JANITOR

/obj/item/borg/upgrade/tboh/apply_upgrade(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/trash/cyborg/TB in R.module.modules)
			R.module.remove_module(TB, TRUE)

		var/obj/item/storage/bag/trash/bluespace/cyborg/B = new /obj/item/storage/bag/trash/bluespace/cyborg(R.module)
		R.module.basic_modules += B
		R.module.add_module(B, FALSE, TRUE)

/obj/item/borg/upgrade/tboh/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/trash/bluespace/cyborg/B in R.module.modules)
			R.module.remove_module(B, TRUE)

		var/obj/item/storage/bag/trash/cyborg/TB = new (R.module)
		R.module.basic_modules += TB
		R.module.add_module(TB, FALSE, TRUE)

/obj/item/borg/upgrade/amop
	name = "janitor cyborg advanced mop"
	desc = "An advanced mop replacement for the janiborg's standard mop."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/janitor)
	module_flags = BORG_MODULE_JANITOR

/obj/item/borg/upgrade/amop/apply_upgrade(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		for(var/obj/item/mop/cyborg/M in R.module.modules)
			R.module.remove_module(M, TRUE)

		var/obj/item/mop/advanced/cyborg/A = new /obj/item/mop/advanced/cyborg(R.module)
		R.module.basic_modules += A
		R.module.add_module(A, FALSE, TRUE)

/obj/item/borg/upgrade/amop/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/mop/advanced/cyborg/A in R.module.modules)
			R.module.remove_module(A, TRUE)

		var/obj/item/mop/cyborg/M = new (R.module)
		R.module.basic_modules += M
		R.module.add_module(M, FALSE, TRUE)

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/syndicate/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.emagged)
			return FALSE

		R.SetEmagged(1)

		return TRUE

/obj/item/borg/upgrade/syndicate/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.SetEmagged(FALSE)

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_module = 1
	module_type = list(/obj/item/robot_module/miner)
	module_flags = BORG_MODULE_MINER

/obj/item/borg/upgrade/lavaproof/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		R.weather_immunities += "lava"

/obj/item/borg/upgrade/lavaproof/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.weather_immunities -= "lava"

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will provide rapid repairs, provided it has had time to charge since its last use"
	icon_state = "cyborg_upgrade5"
	require_module = 1
	icon_state = "selfrepair_off"

	var/mutable_appearance/timer_overlay  // This entire block is used for the cooldown overlay
	var/mutable_appearance/text_overlay
	var/timer_overlay_active = FALSE
	var/timer_icon = 'icons/effects/cooldown.dmi'
	var/timer_icon_state_active = "second"
	COOLDOWN_DECLARE(recharging_repmod)

	///How many repair ticks we have left.
	var/repairs_used = 0
	///Amount of damage repaired per tick.
	var/repair_amount = -5
	///Power cell cost per tick. Repair aborts early if there is not at least 10x this much remaining at the start of a tick in order to preserve some power.
	var/powercost = 50
	///The cyborg which we're attached to
	var/mob/living/silicon/robot/cyborg
	///The action we're going to be using to activate/deactivate
	var/datum/action/item_action/action
	///Are we currently repairing?
	var/working = FALSE
	var/activation_sound = 'sound/machines/terminal_processing.ogg'
	var/working_sounds = list('sound/machines/generator/generator_mid1.ogg', 'sound/machines/generator/generator_mid2.ogg', 'sound/machines/generator/generator_mid3.ogg')
	var/deactivation_sound = 'sound/effects/turbolift/turbolift-close.ogg'

/obj/item/borg/upgrade/selfrepair/proc/begin_timer_animation()
	if(!(action?.button) || timer_overlay_active)
		return

	timer_overlay_active = TRUE
	timer_overlay = mutable_appearance(timer_icon, timer_icon_state_active)
	timer_overlay.alpha = 180

	if(!text_overlay)
		text_overlay = image(loc = action.button, layer=ABOVE_HUD_LAYER)
		text_overlay.maptext_width = 64
		text_overlay.maptext_height = 64
		text_overlay.maptext_x = -8
		text_overlay.maptext_y = -6
		text_overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(action.owner?.client)
		action.owner.client.images += text_overlay

	action.button.add_overlay(timer_overlay, TRUE)
	action.has_cooldown_timer = TRUE
	update_timer_animation()
	START_PROCESSING(SSfastprocess, src)

/obj/item/borg/upgrade/selfrepair/proc/update_timer_animation()
	if(!(action?.button))
		return
	text_overlay.maptext = "<center><span class='chatOverhead' style='font-weight: bold;color: #eeeeee;'>[FLOOR(COOLDOWN_TIMELEFT(src, recharging_repmod)/10, 1)]</span></center>"

/obj/item/borg/upgrade/selfrepair/proc/end_timer_animation()
	if(!(action?.button) || !timer_overlay_active)
		return
	timer_overlay_active = FALSE
	if(action.owner?.client)
		action.owner.client.images -= text_overlay
	action.button.cut_overlay(timer_overlay, TRUE)
	timer_overlay = null
	qdel(text_overlay)
	text_overlay = null
	action.has_cooldown_timer = FALSE

	STOP_PROCESSING(SSfastprocess, src)

/obj/item/borg/upgrade/selfrepair/Destroy()
	end_timer_animation()
	QDEL_NULL(action)
	cyborg = null
	return ..()

/obj/item/borg/upgrade/selfrepair/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	var/obj/item/borg/upgrade/selfrepair/U = locate() in R
	if(U)
		to_chat(user, "<span class='warning'>This unit is already equipped with a self-repair module.</span>")
		return FALSE

	cyborg = R
	action = new /datum/action/item_action(src)
	action.name = name
	action.Grant(R)

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	if(COOLDOWN_FINISHED(src, recharging_repmod) && !working)
		to_chat(cyborg, "<span class='notice'>You activate the self-repair module.</span>")
		working = TRUE
		START_PROCESSING(SSobj, src)
		playsound(cyborg.loc, activation_sound, 30)
		update_icon()
	else
		to_chat(cyborg, "<span class='notice'>Your self-repair module is not ready to be activated again yet.</span>")

/obj/item/borg/upgrade/selfrepair/update_icon()
	. = ..()
	if(!cyborg)
		icon_state = "cyborg_upgrade5"
		return
	icon_state = working ? "selfrepair_on" : "selfrepair_off"
	if(timer_overlay_active && COOLDOWN_FINISHED(src, recharging_repmod))
		end_timer_animation()
	if(action)
		action.UpdateButtonIcon()

/obj/item/borg/upgrade/selfrepair/process(delta_time)
	. = ..()
	if(!cyborg)
		STOP_PROCESSING(SSobj, src)
		CRASH("[src] somehow processed without a cyborg attached.")
	if(!cyborg.cell || cyborg.cell.charge < powercost * 10)
		to_chat(cyborg, "<span class='notice'>Power level critically low! Your self-repair module has been deactivated early.</span>")
		working = FALSE
		update_icon()
		STOP_PROCESSING(SSobj, src)
		return
	if(cyborg.getBruteLoss() || cyborg.getBruteLoss())
		playsound(cyborg.loc, pick(working_sounds), 30)
		cyborg.heal_overall_damage(repair_amount * delta_time, repair_amount * delta_time)
		cyborg.cell.use(powercost)
		repairs_used++
		update_icon()
	else
		to_chat(cyborg, "<span class='notice'>You are fully repaired, so your repair module deactivates automatically.</span>")
		working = FALSE
		update_icon()
		STOP_PROCESSING(SSobj, src)
	if(repairs_used > 10)
		to_chat(cyborg, "<span class='warning'>Your self-repair module has ran out of material, shutting off and beginning further fabrication.</span>")
		working = FALSE
		update_icon()
		playsound(cyborg.loc, deactivation_sound, 60)
		begin_timer_animation()

/*
/obj/item/borg/upgrade/selfrepair/proc/startrepair()
	while(repair_ticks)
		sleep(10)
		if(!cyborg)
			return FALSE
		if(!cyborg.cell || cyborg.cell.charge <= powercost * 10)
			repair_ticks = 0
			to_chat(cyborg, "<span class='notice'>Power level critically low! Your self-repair module has been deactivated early.</span>")
		else if(cyborg.getFireLoss())
			playsound(cyborg.loc, pick(working_sounds), 30)
			cyborg.adjustFireLoss(repair_amount)
			cyborg.cell.use(powercost)
			repair_ticks--
		else if(cyborg.getBruteLoss())
			playsound(cyborg.loc, pick(working_sounds), 30)
			cyborg.adjustBruteLoss(repair_amount)
			cyborg.cell.use(powercost)
			repair_ticks--
		else
			to_chat(cyborg, "<span class='notice'>You are fully repaired, so your module deactivates automatically.</span>")
			cooldown_start(repair_ticks)
			repair_ticks = 0
	cooldown_start(0)

/obj/item/borg/upgrade/selfrepair/process(delta_time)
	if(!cyborg) //Sanity check to reset the module in case it is somehow removed while running.
		update_icon()
		COOLDOWN_RESET(src, recharging_repmod)
		repair_ticks = 10
		deactivate_sr()
	if(!COOLDOWN_FINISHED(src, recharging_repmod))
		update_timer_animation()
	if(COOLDOWN_FINISHED(src, recharging_repmod) && icon_state == "selfrepair_off")
		end_timer_animation()
		action.UpdateButtonIcon()
		repair_ticks = 10
		deactivate_sr()
*/

/obj/item/borg/upgrade/hypospray
	name = "medical cyborg hypospray advanced synthesiser"
	desc = "An upgrade to the Medical module cyborg's hypospray, allowing it \
		to produce more advanced and complex medical reagents."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/medical)
	module_flags = BORG_MODULE_MEDICAL
	var/list/additional_reagents = list()

/obj/item/borg/upgrade/hypospray/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
			if(H.accepts_reagent_upgrades)
				for(var/re in additional_reagents)
					H.add_reagent(re)

/obj/item/borg/upgrade/hypospray/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
			if(H.accepts_reagent_upgrades)
				for(var/re in additional_reagents)
					H.del_reagent(re)

/obj/item/borg/upgrade/hypospray/expanded
	name = "medical cyborg expanded hypospray"
	desc = "An upgrade to the Medical module's hypospray, allowing it \
		to treat a wider range of conditions and problems."
	additional_reagents = list(/datum/reagent/medicine/mannitol, /datum/reagent/medicine/oculine, /datum/reagent/medicine/inacusiate,
		/datum/reagent/medicine/mutadone, /datum/reagent/medicine/haloperidol, /datum/reagent/medicine/oxandrolone, /datum/reagent/medicine/sal_acid, /datum/reagent/medicine/rezadone,
		/datum/reagent/medicine/pen_acid)

/obj/item/borg/upgrade/piercing_hypospray
	name = "cyborg piercing hypospray"
	desc = "An upgrade to a cyborg's hypospray, allowing it to \
		pierce armor and thick material."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/piercing_hypospray/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/found_hypo = FALSE
		for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
			H.bypass_protection = TRUE
			found_hypo = TRUE

		if(!found_hypo)
			return FALSE

/obj/item/borg/upgrade/piercing_hypospray/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
			H.bypass_protection = initial(H.bypass_protection)

/obj/item/borg/upgrade/defib
	name = "medical cyborg defibrillator"
	desc = "An upgrade to the Medical module, installing a built-in \
		defibrillator, for on the scene revival."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/medical)
	module_flags = BORG_MODULE_MEDICAL

/obj/item/borg/upgrade/defib/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/shockpaddles/cyborg/S = new(R.module)
		R.module.basic_modules += S
		R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/defib/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/shockpaddles/cyborg/S = locate() in R.module
		R.module.remove_module(S, TRUE)


/obj/item/borg/upgrade/processor
	name = "medical cyborg surgical processor"
	desc = "An upgrade to the Medical module, installing a processor \
		capable of scanning surgery disks and carrying \
		out procedures"
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/medical, /obj/item/robot_module/syndicate_medical)
	module_flags = BORG_MODULE_MEDICAL

/obj/item/borg/upgrade/processor/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/surgical_processor/SP = new(R.module)
		R.module.basic_modules += SP
		R.module.add_module(SP, FALSE, TRUE)

/obj/item/borg/upgrade/processor/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/surgical_processor/SP = locate() in R.module
		R.module.remove_module(SP, TRUE)

/obj/item/borg/upgrade/ai
	name = "B.O.R.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon_state = "boris"

/obj/item/borg/upgrade/ai/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.shell)
			to_chat(user, "<span class='warning'>This unit is already an AI shell!</span>")
			return FALSE
		if(R.key) //You cannot replace a player unless the key is completely removed.
			to_chat(user, "<span class='warning'>Intelligence patterns detected in this [R.braintype]. Aborting.</span>")
			return FALSE

		R.make_shell(src)

/obj/item/borg/upgrade/ai/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		if(R.shell)
			R.undeploy()
			R.notify_ai(AI_SHELL)

/obj/item/borg/upgrade/expand
	name = "borg expander"
	desc = "A cyborg resizer, it makes a cyborg huge."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/expand/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		if(R.hasExpanded)
			to_chat(usr, "<span class='notice'>This unit already has an expand module installed!</span>")
			return FALSE

		R.notransform = TRUE
		var/prev_lockcharge = R.lockcharge
		R.SetLockdown(TRUE)
		R.anchored = TRUE
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(TRUE, R.loc)
		smoke.start()
		sleep(2)
		for(var/i in 1 to 4)
			playsound(R, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
			sleep(12)
		if(!prev_lockcharge)
			R.SetLockdown(FALSE)
		R.anchored = FALSE
		R.notransform = FALSE
		R.resize = 2
		R.hasExpanded = TRUE
		R.update_transform()

/obj/item/borg/upgrade/expand/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		if (R.hasExpanded)
			R.hasExpanded = FALSE
			R.resize = 0.5
			R.update_transform()

/obj/item/borg/upgrade/rped
	name = "engineering cyborg RPED"
	desc = "A rapid part exchange device for the engineering cyborg."
	icon = 'icons/obj/storage.dmi'
	icon_state = "borgrped"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/engineering, /obj/item/robot_module/saboteur)
	module_flags = BORG_MODULE_ENGINEERING

/obj/item/borg/upgrade/rped/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		var/obj/item/storage/part_replacer/cyborg/RPED = locate() in R
		if(RPED)
			to_chat(user, "<span class='warning'>This unit is already equipped with a RPED module.</span>")
			return FALSE

		RPED = new(R.module)
		R.module.basic_modules += RPED
		R.module.add_module(RPED, FALSE, TRUE)

/obj/item/borg/upgrade/rped/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/storage/part_replacer/cyborg/RPED = locate() in R.module
		if (RPED)
			R.module.remove_module(RPED, TRUE)

/obj/item/borg/upgrade/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg. Permits remote access to the crew monitor."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer_crew"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/medical, /obj/item/robot_module/syndicate_medical)
	module_flags = BORG_MODULE_MEDICAL
	var/datum/action/crew_monitor

/obj/item/borg/upgrade/pinpointer/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		var/obj/item/pinpointer/crew/PP = locate() in R.module
		if(PP)
			to_chat(user, "<span class='warning'>This unit is already equipped with a pinpointer module.</span>")
			return FALSE

		PP = new(R.module)
		R.module.basic_modules += PP
		R.module.add_module(PP, FALSE, TRUE)
		crew_monitor = new /datum/action/item_action/crew_monitor(src)
		crew_monitor.Grant(R)
		icon_state = "scanner"


/obj/item/borg/upgrade/pinpointer/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		icon_state = "pinpointer_crew"
		crew_monitor.Remove(R)
		QDEL_NULL(crew_monitor)
		var/obj/item/pinpointer/crew/PP = locate() in R.module
		R.module.remove_module(PP, TRUE)

/obj/item/borg/upgrade/pinpointer/ui_action_click()
	if(..())
		return
	var/mob/living/silicon/robot/Cyborg = usr
	GLOB.crewmonitor.show(Cyborg,Cyborg)


/obj/item/borg/upgrade/transform
	name = "borg module picker (Standard)"
	desc = "Allows you to to turn a cyborg into a standard cyborg."
	icon_state = "cyborg_upgrade3"
	var/obj/item/robot_module/new_module = /obj/item/robot_module/standard

/obj/item/borg/upgrade/transform/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		R.module.transform_to(new_module)

/obj/item/borg/upgrade/transform/clown
	name = "borg module picker (Clown)"
	desc = "Allows you to to turn a cyborg into a clown, honk."
	icon_state = "cyborg_upgrade3"
	new_module = /obj/item/robot_module/clown

/obj/item/borg/upgrade/transform/security
	name = "borg module picker (Security)"
	desc = "Allows you to turn a cyborg into a hunter, HALT!"
	icon_state = "cyborg_upgrade3"
	new_module = /obj/item/robot_module/security
	module_flags = BORG_MODULE_SECURITY

/obj/item/borg/upgrade/transform/borgi
	name = "borg module picker (Borgi)"
	desc = "Allows you to to turn a cyborg into a weapon to surpass Ian-gear."
	icon_state = "cyborg_upgrade3"
	new_module = /obj/item/robot_module/borgi

/obj/item/borg/upgrade/transform/security/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	if(CONFIG_GET(flag/disable_secborg))
		to_chat(user, "<span class='warning'>Nanotrasen policy disallows the use of weapons of mass destruction.</span>")
		return FALSE
	return ..()

/obj/item/borg/upgrade/circuit_app
	name = "circuit manipulation apparatus"
	desc = "An engineering cyborg upgrade allowing for manipulation of circuit boards."
	icon_state = "cyborg_upgrade3"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/engineering, /obj/item/robot_module/saboteur)
	module_flags = BORG_MODULE_ENGINEERING

/obj/item/borg/upgrade/circuit_app/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/apparatus/circuit/C = locate() in R.module.modules
		if(C)
			to_chat(user, "<span class='warning'>This unit is already equipped with a circuit apparatus.</span>")
			return FALSE

		C = new(R.module)
		R.module.basic_modules += C
		R.module.add_module(C, FALSE, TRUE)

/obj/item/borg/upgrade/circuit_app/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/borg/apparatus/circuit/C = locate() in R.module.modules
		if (C)
			R.module.remove_module(C, TRUE)

/obj/item/borg/upgrade/beaker_app
	name = "beaker storage apparatus"
	desc = "A supplementary beaker storage apparatus for medical cyborgs."
	icon_state = "cyborg_upgrade3"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/medical)
	module_flags = BORG_MODULE_MEDICAL

/obj/item/borg/upgrade/beaker_app/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/apparatus/beaker/extra/E = locate() in R.module.modules
		if(E)
			to_chat(user, "<span class='warning'>This unit has no room for additional beaker storage.</span>")
			return FALSE

		E = new(R.module)
		R.module.basic_modules += E
		R.module.add_module(E, FALSE, TRUE)

/obj/item/borg/upgrade/beaker_app/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/borg/apparatus/beaker/extra/E = locate() in R.module.modules
		if (E)
			R.module.remove_module(E, TRUE)


/obj/item/borg/upgrade/speciality
	name = "Speciality Module"
	icon_state = "cyborg_upgrade3"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/butler)
	var/obj/item/hat
	var/addmodules = list()
	var/list/additional_reagents = list()
	module_flags = BORG_MODULE_SPECIALITY

/obj/item/borg/upgrade/speciality/apply_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/borg/upgrade/SPEC in R.upgrades)
			if (istype(SPEC,/obj/item/borg/upgrade/speciality) && SPEC != src)
				SPEC.remove_upgrade(R)
				R.upgrades -= SPEC
				qdel(SPEC)


		for(var/module in src.addmodules)
			var/obj/item/nmodule = locate(module) in R
			if (!nmodule)
				nmodule = new module(R.module)
				R.module.basic_modules += nmodule
				R.module.add_module(nmodule, FALSE, TRUE)

		for(var/obj/item/reagent_containers/borghypo/borgshaker/H in R.module.modules)
			for(var/re in additional_reagents)
				H.add_reagent(re)

		if(hat && R.hat_offset != INFINITY && !R.hat)
			var/obj/item/equipt = new hat(src)
			if (equipt )
				R.place_on_head(equipt)

/obj/item/borg/upgrade/speciality/remove_upgrade(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		//Remove existing modules indiscriminately
		for(var/module in src.addmodules)
			var/dmod = locate(module) in R.module.modules
			if (dmod)
				R.module.remove_module(dmod, TRUE)
		for(var/obj/item/reagent_containers/borghypo/borgshaker/H in R.module.modules)
			for(var/re in additional_reagents)
				H.del_reagent(re)

/obj/item/borg/upgrade/speciality/kitchen
	name = "Cook Speciality"
	desc = "A service cyborg upgrade allowing for basic food handling."
	hat = /obj/item/clothing/head/chefhat
	addmodules = list (
		/obj/item/kitchen/knife,
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
	hat = /obj/item/clothing/head/rice_hat
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
	hat = /obj/item/clothing/head/rabbitears
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
