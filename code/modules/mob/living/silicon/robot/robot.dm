/mob/living/silicon/robot/Initialize(mapload)
	GLOB.cyborg_list += src
	default_access_list = get_all_accesses()

	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	ADD_TRAIT(src, TRAIT_FORCED_STANDING, INNATE_TRAIT)
	AddComponent(/datum/component/tippable, \
		tip_time = 3 SECONDS, \
		untip_time = 2 SECONDS, \
		self_right_time = 60 SECONDS, \
		post_tipped_callback = CALLBACK(src, PROC_REF(after_tip_over)), \
		post_untipped_callback = CALLBACK(src, PROC_REF(after_righted)), \
		roleplay_friendly = TRUE, \
		roleplay_emotes = list(/datum/emote/silicon/buzz, /datum/emote/silicon/buzz2, /datum/emote/silicon/boop, /datum/emote/silicon/alarm), \
		roleplay_callback = CALLBACK(src, PROC_REF(untip_roleplay)))

	wires = new /datum/wires/robot(src)
	AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/cyborg)
	RegisterSignal(src, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.plane = HUD_PLANE

	ident = rand(1, 999)

	if(ispath(cell))
		cell = new cell(src)

	create_modularInterface()

	if(lawupdate)
		make_laws()
		if(!TryConnectToAI())
			lawupdate = FALSE
			wires.ui_update()

	if(!scrambledcodes && !builtInCamera)
		builtInCamera = new (src)
		builtInCamera.c_tag = real_name
		builtInCamera.network = list(CAMERA_NETWORK_STATION)
		builtInCamera.internal_light = FALSE
		if(wires.is_cut(WIRE_CAMERA))
			builtInCamera.status = 0

	model = new /obj/item/robot_model(src)
	model.rebuild_modules()
	update_icons()
	. = ..()
	add_sensors()

	//If this body is meant to be a borg controlled by the AI player
	if(shell)
		var/obj/item/borg/upgrade/ai/board = new(src)
		make_shell(board)
		add_to_upgrades(board)

	//MMI stuff. Held togheter by magic. ~Miauw
	else if(!mmi || !mmi.brainmob)
		mmi = new (src)
		mmi.brain = new /obj/item/organ/brain(mmi)
		mmi.brain.organ_flags |= ORGAN_FROZEN
		mmi.brain.name = "[real_name]'s brain"
		mmi.name = "[initial(mmi.name)]: [real_name]"
		mmi.set_brainmob(new /mob/living/brain(mmi))
		mmi.brainmob.name = src.real_name
		mmi.brainmob.real_name = src.real_name
		mmi.brainmob.container = mmi
		mmi.update_icon()

	updatename()

	blacklisted_hats = typecacheof(blacklisted_hats)

	playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)
	aicamera = new/obj/item/camera/siliconcam/robot_camera(src)
	toner = tonermax
	diag_hud_set_borgcell()

	alert_control = new(src, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER, ALARM_CAMERA, ALARM_BURGLAR, ALARM_MOTION), list(z))
	RegisterSignal(alert_control.listener, COMSIG_ALARM_TRIGGERED, PROC_REF(alarm_triggered))
	RegisterSignal(alert_control.listener, COMSIG_ALARM_CLEARED, PROC_REF(alarm_cleared))
	alert_control.listener.RegisterSignal(src, COMSIG_LIVING_DEATH, TYPE_PROC_REF(/datum/alarm_listener, prevent_alarm_changes))
	alert_control.listener.RegisterSignal(src, COMSIG_LIVING_REVIVE, TYPE_PROC_REF(/datum/alarm_listener, allow_alarm_changes))

	RegisterSignal(src, COMSIG_ATOM_ON_EMAG, PROC_REF(on_emag))
	RegisterSignal(src, COMSIG_ATOM_SHOULD_EMAG, PROC_REF(should_emag))
	logevent("System brought online.")

/**
 * Sets the tablet theme and icon
 *
 * These variables are based on if the borg is a syndicate type or is emagged. This gets used in model change code
 * and also borg emag code.
 */
/mob/living/silicon/robot/proc/set_modularInterface_theme()
	if(istype(model, /obj/item/robot_model/syndicate) || emagged)
		modularInterface.device_theme = THEME_SYNDICATE
		modularInterface.icon_state = "tablet-silicon-syndicate"
	else
		modularInterface.device_theme = THEME_NTOS
		modularInterface.icon_state = "tablet-silicon"
	modularInterface.update_icon()

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
/mob/living/silicon/robot/Destroy()
	GLOB.cyborg_list -= src
	var/atom/T = drop_location()//To hopefully prevent run time errors.
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		if(T)
			mmi.forceMove(T)
		if(mmi.brainmob)
			if(mmi.brainmob.stat == DEAD)
				mmi.brainmob.set_stat(CONSCIOUS)
				mmi.brainmob.remove_from_dead_mob_list()
				mmi.brainmob.add_to_alive_mob_list()
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			to_chat(src, span_boldannounce("Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug."))
			ghostize()
			stack_trace("Borg MMI lacked a brainmob")
		mmi = null
	if(modularInterface)
		QDEL_NULL(modularInterface)
	if(connected_ai)
		connected_ai.connected_robots -= src
	if(shell)
		GLOB.available_ai_shells -= src
	else
		if(T && istype(radio) && istype(radio.keyslot))
			radio.keyslot.forceMove(T)
			radio.keyslot = null
	if(autoclean_toggle)
		autoclean_toggle.Remove(src)
	QDEL_NULL(autoclean_toggle)
	QDEL_NULL(wires)
	QDEL_NULL(model)
	QDEL_NULL(eye_lights)
	QDEL_NULL(inv1)
	QDEL_NULL(inv2)
	QDEL_NULL(inv3)
	QDEL_NULL(spark_system)
	QDEL_NULL(alert_control)
	cell = null
	UnregisterSignal(src, COMSIG_ATOM_ON_EMAG)
	UnregisterSignal(src, COMSIG_ATOM_SHOULD_EMAG)
	return ..()

/mob/living/silicon/robot/proc/pick_model()
	if(model.type != /obj/item/robot_model)
		return

	if(wires.is_cut(WIRE_RESET_MODEL))
		to_chat(src, span_userdanger("ERROR: Model installer reply timeout. Please check internal connections."))
		return

	var/list/model_list = list(
		"Standard" = /obj/item/robot_model/standard,
		"Engineering" = /obj/item/robot_model/engineering,
		"Medical" = /obj/item/robot_model/medical,
		"Miner" = /obj/item/robot_model/miner,
		"Janitor" = /obj/item/robot_model/janitor,
		"Service" = /obj/item/robot_model/service
	)

	if(!CONFIG_GET(flag/disable_peaceborg))
		model_list["Peacekeeper"] = /obj/item/robot_model/peacekeeper

	if(!CONFIG_GET(flag/disable_guardianborg))
		model_list["Guardian"] = /obj/item/robot_model/guard

	// Create radial menu for choosing borg model
	var/list/module_icons = list()
	for(var/option in model_list)
		var/obj/item/robot_model/module = model_list[option]
		var/module_icon = initial(module.cyborg_base_icon)
		module_icons[option] = image(icon = 'icons/mob/robots.dmi', icon_state = module_icon)

	var/input_model = show_radial_menu(src, src, module_icons, radius = 42)
	if(!input_model || model.type != /obj/item/robot_model)
		return

	model.transform_to(model_list[input_model])


/mob/living/silicon/robot/proc/updatename(client/C)
	if(shell)
		return
	if(!C)
		C = client
	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	if(changed_name == "" && C && C.prefs.read_character_preference(/datum/preference/name/cyborg) != DEFAULT_CYBORG_NAME)
		if(check_cyborg_name(C, mmi))
			if(apply_pref_name(/datum/preference/name/cyborg, C))
				return //built in camera handled in proc
		else
			//Failed the vibe check on name theft, time to randomize it
			changed_name = get_standard_name()
	if(!changed_name)
		changed_name = get_standard_name()

	real_name = changed_name
	name = real_name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too

/mob/living/silicon/robot/proc/get_standard_name()
	return "[(designation ? "[designation] " : "")][mmi.braintype]-[ident]"

/mob/living/silicon/robot/proc/ionpulse(thrust = 0.01, use_fuel = TRUE)
	if(!ionpulse_on)
		return FALSE

	if(cell.charge <= 10)
		toggle_ionpulse()
		return FALSE

	if(use_fuel)
		cell.charge -= (thrust * 1000)
	return TRUE

/mob/living/silicon/robot/proc/toggle_ionpulse()
	if(!ionpulse)
		to_chat(src, span_notice("No thrusters are installed!"))
		return

	if(!ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

	ionpulse_on = !ionpulse_on
	to_chat(src, span_notice("You [ionpulse_on ? null :"de"]activate your ion thrusters."))
	if(ionpulse_on)
		ion_trail.start()
	else
		ion_trail.stop()

/mob/living/silicon/robot/get_stat_tab_status()
	var/list/tab_data = ..()
	if(cell)
		tab_data["Charge Left"] = GENERATE_STAT_TEXT("[cell.charge]/[cell.maxcharge]")
	else
		tab_data["Charge Left"] = GENERATE_STAT_TEXT("No Cell Inserted!")

	if(model)
		for(var/datum/robot_energy_storage/st in model.storages)
			tab_data["[st.name]"] = GENERATE_STAT_TEXT("[st.energy]/[st.max_energy]")
	if(connected_ai)
		tab_data["Master AI"] = GENERATE_STAT_TEXT("[connected_ai.name]")
	return tab_data

/mob/living/silicon/robot/proc/alarm_triggered(datum/source, alarm_type, area/source_area)
	SIGNAL_HANDLER
	queueAlarm("--- [alarm_type] alarm detected in [source_area.name]!", alarm_type)

/mob/living/silicon/robot/proc/alarm_cleared(datum/source, alarm_type, area/source_area)
	SIGNAL_HANDLER
	queueAlarm("--- [alarm_type] alarm in [source_area.name] has been cleared.", alarm_type, FALSE)

/mob/living/silicon/robot/can_interact_with(atom/A)
	if (A == modularInterface)
		return TRUE //bypass for borg tablets
	if (low_power_mode)
		return FALSE
	var/turf/T0 = get_turf(src)
	var/turf/T1 = get_turf(A)
	if (!T0 || ! T1)
		return FALSE
	if(A.is_jammed(JAMMER_PROTECTION_WIRELESS))
		return FALSE
	return ISINRANGE(T1.x, T0.x - interaction_range, T0.x + interaction_range) && ISINRANGE(T1.y, T0.y - interaction_range, T0.y + interaction_range)

/mob/living/silicon/robot/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	togglelock(user)

/mob/living/silicon/robot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(length(user.progressbars))
		if(attacking_item.tool_behaviour == TOOL_WELDER || istype(attacking_item, /obj/item/stack/cable_coil))
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, span_notice("You are already busy!"))
			return
	if(attacking_item.tool_behaviour == TOOL_WELDER && (!user.combat_mode))
		user.changeNext_move(CLICK_CD_MELEE)
		if(user == src)
			to_chat(user, span_warning("You are unable to maneuver [attacking_item] properly to repair yourself, seek assistance!"))
			return
		if (!getBruteLoss())
			to_chat(user, span_warning("[src] is already in good condition!"))
			return
		//repeatedly repairs until the cyborg is fully repaired
		while(getBruteLoss() && attacking_item.tool_start_check(user, amount=0) && attacking_item.use_tool(src, user, 3 SECONDS))
			attacking_item.use(1) //use one fuel for each repair step
			adjustBruteLoss(-10)
			updatehealth()
			add_fingerprint(user)
			user.visible_message("[user] has fixed some of the dents on [src].", span_notice("You fix some of the dents on [src]."))
		return TRUE

	else if(istype(attacking_item, /obj/item/stack/cable_coil) && wiresexposed)
		user.changeNext_move(CLICK_CD_MELEE)
		if(!(getFireLoss() || getToxLoss()))
			to_chat(user, "The wires seem fine, there's no need to fix them.")
			return
		var/obj/item/stack/cable_coil/coil = attacking_item
		while((getFireLoss() || getToxLoss()) && do_after(user, 30, target = src))
			if(coil.use(1))
				adjustFireLoss(-20)
				adjustToxLoss(-20)
				updatehealth()
				add_fingerprint(user)
				user.visible_message("[user] has fixed some of the burnt wires on [src].", span_notice("You fix some of the burnt wires on [src]."))
			else
				to_chat(user, span_warning("You need more cable to repair [src]!"))

	else if(attacking_item.tool_behaviour == TOOL_CROWBAR)	// crowbar means open or close the cover
		if(opened)
			to_chat(user, span_notice("You close the cover."))
			opened = 0
			update_icons()
		else
			if(locked)
				to_chat(user, span_warning("The cover is locked and cannot be opened!"))
			else
				to_chat(user, span_notice("You open the cover."))
				opened = 1
				update_icons()
	else if(istype(attacking_item, /obj/item/stock_parts/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			to_chat(user, span_warning("Close the cover first!"))
		else if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
		else
			if(!user.transferItemToLoc(attacking_item, src))
				return
			cell = attacking_item
			to_chat(user, span_notice("You insert the power cell."))
		update_icons()
		diag_hud_set_borgcell()

	else if(is_wire_tool(attacking_item))
		if (wiresexposed)
			wires.interact(user)
		else
			to_chat(user, span_warning("You can't reach the wiring!"))

	else if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		update_icons()

	else if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER && opened && cell)	// radio
		if(shell)
			to_chat(user, "You cannot seem to open the radio compartment.")	//Prevent AI radio key theft
		else if(radio)
			radio.attackby(attacking_item,user)//Push it to the radio to let it handle everything
		else
			to_chat(user, span_warning("Unable to locate a radio!"))
		update_icons()

	else if(attacking_item.tool_behaviour == TOOL_WRENCH && opened && !cell) //Deconstruction. The flashes break from the fall, to prevent this from being a ghetto reset module.
		if(!lockcharge)
			to_chat(user, span_boldannounce("[src]'s bolts spark! Maybe you should lock them down first!"))
			spark_system.start()
			return
		else
			to_chat(user, span_notice("You start to unfasten [src]'s securing bolts."))
			if(attacking_item.use_tool(src, user, 50, volume=50) && !cell)
				user.visible_message("[user] deconstructs [src]!", span_notice("You unfasten the securing bolts, and [src] falls to pieces!"))
				log_attack("[key_name(user)] deconstructed [name] at [AREACOORD(src)].")
				deconstruct()

	else if(istype(attacking_item, /obj/item/ai_module))
		var/obj/item/ai_module/MOD = attacking_item
		if(!opened)
			to_chat(user, span_warning("You need access to the robot's insides to do that!"))
			return
		if(wiresexposed)
			to_chat(user, span_warning("You need to close the wire panel to do that!"))
			return
		if(!cell)
			to_chat(user, span_warning("You need to install a power cell to do that!"))
			return
		if(shell) //AI shells always have the laws of the AI
			to_chat(user, span_warning("[src] is controlled remotely! You cannot upload new laws this way!"))
			return
		if(emagged || (connected_ai && lawupdate)) //Can't be sure which, metagamers
			emote("buzz-[user.name]")
			return
		if(!mind) //A player mind is required for law procs to run antag checks.
			to_chat(user, span_warning("[src] is entirely unresponsive!"))
			return
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
		return

	else if(istype(attacking_item, /obj/item/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(attacking_item,user)//GTFO, you have your own procs
		else
			to_chat(user, span_warning("Unable to locate a radio!"))

	else if (istype(attacking_item, /obj/item/card/id)||istype(attacking_item, /obj/item/modular_computer/tablet/pda))			// trying to unlock the interface with an ID card
		togglelock(user)

	else if(istype(attacking_item, /obj/item/borg/upgrade))
		var/obj/item/borg/upgrade/upgrade = attacking_item
		if(!opened)
			to_chat(user, span_warning("You must access the borg's internals!"))
			return
		if(!model && upgrade.require_model)
			to_chat(user, span_warning("The borg must choose a module before it can be upgraded!"))
			return
		if(upgrade.locked)
			to_chat(user, span_warning("The upgrade is locked and cannot be used yet!"))
			return
		if(!user.canUnEquip(upgrade))
			to_chat(user, span_warning("The upgrade is stuck to you and you can't seem to let go of it!"))
			return
		apply_upgrade(upgrade, user)
		return

	else if(istype(attacking_item, /obj/item/toner))
		if(toner >= tonermax)
			to_chat(user, span_warning("The toner level of [src] is at its highest level possible!"))
		else
			if(!user.temporarilyRemoveItemFromInventory(attacking_item))
				return
			toner = tonermax
			qdel(attacking_item)
			to_chat(user, span_notice("You fill the toner level of [src] to its max capacity."))

	else if(istype(attacking_item, /obj/item/flashlight))
		if(!opened)
			to_chat(user, span_warning("You need to open the panel to repair the headlamp!"))
		else if(lamp_functional)
			to_chat(user, span_warning("The headlamp is already functional!"))
		else
			if(!user.temporarilyRemoveItemFromInventory(attacking_item))
				to_chat(user, span_warning("[attacking_item] seems to be stuck to your hand. You'll have to find a different light."))
				return
			lamp_functional = TRUE
			qdel(attacking_item)
			to_chat(user, span_notice("You replace the headlamp bulbs."))
	else if(istype(attacking_item, /obj/item/computer_hardware/hard_drive/portable)) //Allows borgs to install new programs with human help
		if(!modularInterface)
			stack_trace("Cyborg [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
			create_modularInterface()
		var/obj/item/computer_hardware/hard_drive/portable/floppy = attacking_item
		if(modularInterface.install_component(floppy, user))
			return
	else
		return ..()

/mob/living/silicon/robot/proc/togglelock(mob/user)
	if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
	else
		if(allowed(user))
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] [src]'s cover."))
			update_icons()
			if(emagged)
				to_chat(user, span_notice("The cover interface glitches out for a split second."))
			logevent("[emagged ? "ChÃ¥vÃis" : "Chassis"] cover lock has been [locked ? "engaged" : "released"]") //ChÃ¥vÃis: see above line
		else
			to_chat(user, span_danger("Access denied."))

///For any special cases for robots after being righted.
/mob/living/silicon/robot/proc/after_righted(mob/user)
	return

/mob/living/silicon/robot/proc/after_tip_over(mob/user)
	if(hat)
		hat.forceMove(drop_location())
	unbuckle_all_mobs()

/mob/living/silicon/robot/proc/untip_roleplay()
	to_chat(src, span_notice("Your frustration has empowered you! You can now right yourself faster!"))

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || check_access(H.wear_id))
			return 1
	else if(ismonkey(M))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(isitem(george.get_active_held_item()))
			return check_access(george.get_active_held_item())
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1

	if(!istype(I, /obj/item/card/id) && isitem(I))
		I = I.GetID()

	if(!I || !length(I.access)) //not ID or no access
		return 0
	for(var/req in req_access)
		if(!(req in I.access))
			return 0 //doesn't have this access
	return 1

/mob/living/silicon/robot/regenerate_icons()
	return update_icons()

/mob/living/silicon/robot/update_icons()
	cut_overlays()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	icon_state = model.cyborg_base_icon
	if(stat != DEAD && !(IsUnconscious() || low_power_mode)) //Not dead, not stunned.
		if(!eye_lights)
			eye_lights = new()
		if(has_status_effect(/datum/status_effect/cyborg_malfunction)) //Blinky red error lights
			eye_lights.icon_state = "[model.special_light_key ? "[model.special_light_key]":"[model.cyborg_base_icon]"]_fl"
		else if(lamp_enabled || lamp_doom)
			eye_lights.icon_state = "[model.special_light_key ? "[model.special_light_key]":"[model.cyborg_base_icon]"]_l"
			eye_lights.color = lamp_doom ? COLOR_RED : lamp_color
			eye_lights.plane = ABOVE_LIGHTING_PLANE //glowy eyes
		else
			eye_lights.icon_state = "[model.special_light_key ? "[model.special_light_key]":"[model.cyborg_base_icon]"]_e[ratvar ? "_r" : ""]"
			eye_lights.color = COLOR_WHITE
			eye_lights.plane = ABOVE_LIGHTING_PLANE //still glowy, but don't emit actual light
		eye_lights.icon = icon
		add_overlay(eye_lights)

	if(opened)
		if(wiresexposed)
			add_overlay("[model.special_cover_key]-opencover +w")
		else if(cell)
			add_overlay("[model.special_cover_key]-opencover +c")
		else
			add_overlay("[model.special_cover_key]-opencover -c")
	if(hat)
		var/mutable_appearance/head_overlay = hat.build_worn_icon(default_layer = 20, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		head_overlay.pixel_y += hat_offset
		add_overlay(head_overlay)
	update_fire()

/mob/living/silicon/robot/proc/self_destruct(mob/user)
	var/turf/groundzero = get_turf(src)
	message_admins(span_notice("[ADMIN_LOOKUPFLW(user)] detonated [key_name_admin(src, client)] at [ADMIN_VERBOSEJMP(groundzero)]!"))
	log_game(span_notice("[key_name(user)] detonated [key_name(src)]!"))
	log_combat(user, src, "detonated cyborg", "cyborg_detonation")
	if(connected_ai)
		to_chat(connected_ai, "<br><br>[span_alert("ALERT - Cyborg detonation detected: [name]")]<br>")

	if(emagged)
		explosion(src.loc,1,2,4,flame_range = 2)
	else
		explosion(src.loc,-1,0,2)
	investigate_log("has self-destructed.", INVESTIGATE_DEATHS)
	gib()

/mob/living/silicon/robot/proc/UnlinkSelf()
	if(src.connected_ai)
		connected_ai.connected_robots -= src
		src.connected_ai = null
	lawupdate = FALSE
	set_lockcharge(FALSE)
	scrambledcodes = TRUE
	//Disconnect it's camera so it's not so easily tracked.
	if(!QDELETED(builtInCamera))
		QDEL_NULL(builtInCamera)
		// I'm trying to get the Cyborg to not be listed in the camera list
		// Instead of being listed as "deactivated". The downside is that I'm going
		// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
		// I could change the network to null but I don't know what would happen, and it seems too hacky for me.
	wires.ui_update()

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	if(incapacitated())
		return
	var/obj/item/held_item = get_active_held_item()
	if(held_item)
		held_item.attack_self(src)


/mob/living/silicon/robot/proc/SetLockdown(state = TRUE)
	// They stay locked down if their wire is cut.
	if(wires.is_cut(WIRE_LOCKDOWN))
		state = TRUE
	if(state)
		throw_alert("locked", /atom/movable/screen/alert/locked)
	else
		clear_alert("locked")
	set_lockcharge(state)

///Reports the event of the change in value of the lockcharge variable.
/mob/living/silicon/robot/proc/set_lockcharge(new_lockcharge)
	if(new_lockcharge == lockcharge)
		return
	. = lockcharge
	lockcharge = new_lockcharge
	if(lockcharge)
		if(!.)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LOCKED_BORG_TRAIT)
	else if(.)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LOCKED_BORG_TRAIT)
	logevent("System lockdown [lockcharge?"triggered":"released"].")


/mob/living/silicon/robot/proc/SetEmagged(new_state)
	emagged = new_state
	model.rebuild_modules()
	update_icons()
	if(emagged)
		throw_alert("hacked", /atom/movable/screen/alert/hacked)
	else
		clear_alert("hacked")
	set_modularInterface_theme()

/mob/living/silicon/robot/proc/SetRatvar(new_state, rebuild=TRUE)
	ratvar = new_state
	if(rebuild)
		model.rebuild_modules()
	update_icons()
	if(ratvar)
		internal_clock_slab = new(src)
		throw_alert("ratvar", /atom/movable/screen/alert/ratvar)
	else
		qdel(internal_clock_slab)
		clear_alert("ratvar")

/**
  * Handles headlamp smashing
  *
  * When called (such as by the shadowperson lighteater's attack), this proc will break the borg's headlamp
  * and then call toggle_headlamp to disable the light. It also plays a sound effect of glass breaking, and
  * tells the borg what happened to its chat. Broken lights can be repaired by using a flashlight on the borg.
  */
/mob/living/silicon/robot/proc/smash_headlamp()
	if(!lamp_functional)
		return
	lamp_functional = FALSE
	playsound(src, 'sound/effects/glass_step.ogg', 50)
	toggle_headlamp(TRUE)
	to_chat(src, span_danger("Your headlamp is broken! You'll need a human to help replace it."))

/**
  * Handles headlamp toggling, disabling, and color setting.
  *
  * The initial if statment is a bit long, but the gist of it is that should the lamp be on AND the update_color
  * arg be true, we should simply change the color of the lamp but not disable it. Otherwise, should the turn_off
  * arg be true, the lamp already be enabled, any of the normal reasons the lamp would turn off happen, or the
  * update_color arg be passed with the lamp not on, we should set the lamp off. The update_color arg is only
  * ever true when this proc is called from the borg tablet, when the color selection feature is used.
  *
  * Arguments:
  * * arg1 - turn_off, if enabled will force the lamp into an off state (rather than toggling it if possible)
  * * arg2 - update_color, if enabled, will adjust the behavior of the proc to change the color of the light if it is already on.
  */
/mob/living/silicon/robot/proc/toggle_headlamp(turn_off = FALSE, update_color = FALSE)
	//if both lamp is enabled AND the update_color flag is on, keep the lamp on. Otherwise, if anything listed is true, disable the lamp.
	if(!(update_color && lamp_enabled) && (turn_off || lamp_enabled || update_color || !lamp_functional || stat || low_power_mode))
		set_light_on(FALSE)
		lamp_enabled = FALSE
		lampButton.update_icon()
		update_icons()
		return
	set_light_range(lamp_intensity)
	set_light_color(lamp_color)
	set_light_on(TRUE)
	lamp_enabled = TRUE
	lampButton.update_icon()
	update_icons()

/mob/living/silicon/robot/proc/deconstruct()
	SEND_SIGNAL(src, COMSIG_BORG_SAFE_DECONSTRUCT)
	var/turf/T = get_turf(src)
	if (robot_suit)
		robot_suit.forceMove(T)
		robot_suit.l_leg.forceMove(T)
		robot_suit.l_leg = null
		robot_suit.r_leg.forceMove(T)
		robot_suit.r_leg = null
		new /obj/item/stack/cable_coil(T, robot_suit.chest.wired)
		robot_suit.chest.forceMove(T)
		robot_suit.chest.wired = 0
		robot_suit.chest = null
		robot_suit.l_arm.forceMove(T)
		robot_suit.l_arm = null
		robot_suit.r_arm.forceMove(T)
		robot_suit.r_arm = null
		robot_suit.head.forceMove(T)
		robot_suit.head.flash1.forceMove(T)
		robot_suit.head.flash1.burn_out()
		robot_suit.head.flash1 = null
		robot_suit.head.flash2.forceMove(T)
		robot_suit.head.flash2.burn_out()
		robot_suit.head.flash2 = null
		robot_suit.head = null
		robot_suit.update_icon()
	else
		new /obj/item/robot_suit(T)
		new /obj/item/bodypart/leg/left/robot(T)
		new /obj/item/bodypart/leg/right/robot(T)
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/bodypart/chest/robot(T)
		new /obj/item/bodypart/arm/left/robot(T)
		new /obj/item/bodypart/arm/right/robot(T)
		new /obj/item/bodypart/head/robot(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/assembly/flash/handheld/F = new /obj/item/assembly/flash/handheld(T)
			F.burn_out()
	if (cell) //Sanity check.
		cell.forceMove(T)
		cell = null
	// Call destroy() before deleting to ensure that the borg's brain stays connected
	Destroy()
	qdel(src)

/mob/living/silicon/robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(NEW_BORG) //New Cyborg
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - New cyborg connection detected: <a href='byond://?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a>")]<br>")
		if(NEW_MODEL) //New Model
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg model change detected: [name] has loaded the [designation] model.")]<br>")
		if(RENAME) //New Name
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].")]<br>")
		if(AI_SHELL) //New Shell
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - New cyborg shell detected: <a href='byond://?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a>")]<br>")
		if(DISCONNECT) //Tampering with the wires
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Remote telemetry lost with [name].")]<br>")

/mob/living/silicon/robot/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE, need_hands = FALSE, floor_okay=FALSE)
	if(lockcharge || low_power_mode)
		to_chat(src, span_warning("You can't do that right now!"))
		return FALSE
	return ..()

/mob/living/silicon/robot/updatehealth()
	..()
	if(health < maxHealth * 0.75) //Gradual break down of modules as more damage is sustained
		var/speedpenalty = (maxHealth - health) / 150
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, multiplicative_slowdown = speedpenalty)
		if(uneq_module(held_items[3]))
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, 1, 1)
			audible_message(span_warning("[src] sounds an alarm! \"SYSTEM ERROR: Module 3 OFFLINE.\""))
			to_chat(src, span_userdanger("SYSTEM ERROR: Module 3 OFFLINE."))
		if(health < maxHealth*0.5)
			if(uneq_module(held_items[2]))
				audible_message(span_warning("[src] sounds an alarm! \"SYSTEM ERROR: Module 2 OFFLINE.\""))
				to_chat(src, span_userdanger("SYSTEM ERROR: Module 2 OFFLINE."))
				playsound(loc, 'sound/machines/warning-buzzer.ogg', 60, 1, 1)
			if(health < maxHealth*0.25)
				if(uneq_module(held_items[1]))
					audible_message(span_warning("[src] sounds an alarm! \"CRITICAL ERROR: All modules OFFLINE.\""))
					to_chat(src, span_userdanger("CRITICAL ERROR: All modules OFFLINE."))
					playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, 1, 1)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)

/mob/living/silicon/robot/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = NIGHTVISION_FOV_RANGE
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(sight_mode & BORGMESON)
		sight |= SEE_TURFS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		see_in_dark = 1

	if(sight_mode & BORGMATERIAL)
		sight |= SEE_OBJS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		see_in_dark = 1

	if(sight_mode & BORGXRAY)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_invisible = SEE_INVISIBLE_LIVING
		see_in_dark = NIGHTVISION_FOV_RANGE

	if(sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		see_invisible = min(see_invisible, SEE_INVISIBLE_LIVING)
		see_in_dark = NIGHTVISION_FOV_RANGE

	if(HAS_TRAIT(src, TRAIT_NIGHT_VISION))
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
		see_in_dark = max(see_in_dark, 8)

	if(see_override)
		see_invisible = see_override
	sync_lighting_plane_alpha()

/mob/living/silicon/robot/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		if(health <= 0) //die only once
			death()
			toggle_headlamp(1)
			return
		if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || IsStun() || IsKnockdown() || IsParalyzed())
			set_stat(UNCONSCIOUS)
		else
			set_stat(CONSCIOUS)
	diag_hud_set_status()
	diag_hud_set_health()
	diag_hud_set_aishell()
	update_health_hud()
	update_icons() //Updates eye_light overlay

/mob/living/silicon/robot/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return

	if(!QDELETED(builtInCamera) && !wires.is_cut(WIRE_CAMERA))
		builtInCamera.toggle_cam(src, 0)
	if(full_heal_flags & HEAL_ADMIN)
		locked = TRUE
	notify_ai(NEW_BORG)
	toggle_headlamp(FALSE, TRUE) //This will reenable borg headlamps if doomsday is currently going on still.
	wires.ui_update()
	return TRUE

/mob/living/silicon/robot/fully_replace_character_name(oldname, newname)
	..()
	if(oldname != real_name)
		notify_ai(RENAME, oldname, newname)
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name
		modularInterface.saved_identification = real_name
	custom_name = newname


/mob/living/silicon/robot/proc/ResetModel()
	SEND_SIGNAL(src, COMSIG_BORG_SAFE_DECONSTRUCT)
	uneq_all()
	shown_robot_modules = FALSE
	if(hud_used)
		hud_used.update_robot_modules_display()

	if (hasExpanded)
		resize = 0.5
		hasExpanded = FALSE
		update_transform()
	logevent("Chassis configuration has been reset.")
	model.transform_to(/obj/item/robot_model)

	// Remove upgrades.
	for(var/obj/item/borg/upgrade/I in upgrades)
		I.forceMove(get_turf(src))

	speed = 0
	ionpulse = FALSE
	revert_shell()

	return TRUE

/mob/living/silicon/robot/model/syndicate/ResetModel()
	return

/mob/living/silicon/robot/proc/has_model()
	if(!model || model.type == /obj/item/robot_model)
		return FALSE
	else
		return TRUE

/mob/living/silicon/robot/proc/update_module_innate()
	designation = model.name

	if(hands)
		hands.icon_state = model.model_select_icon

	REMOVE_TRAITS_IN(src, MODULE_TRAIT)
	if(model.module_traits)
		for(var/trait in model.module_traits)
			ADD_TRAIT(src, trait, MODULE_TRAIT)

	if(model.clean_on_move)
		AddElement(/datum/element/cleaning)
		autoclean_toggle = new()
		autoclean_toggle.toggle_target = src
		autoclean_toggle.Grant(src)
	else
		RemoveElement(/datum/element/cleaning)
		if(autoclean_toggle)
			autoclean_toggle.Remove(src)
			QDEL_NULL(autoclean_toggle)

	hat_offset = model.hat_offset

	updatename()

/mob/living/silicon/robot/proc/place_on_head(obj/item/new_hat)
	if(hat)
		hat.forceMove(get_turf(src))
	hat = new_hat
	new_hat.forceMove(src)
	update_icons()

/**
	*Checking Exited() to detect if a hat gets up and walks off.
	*Drones and pAIs might do this, after all.
*/
/mob/living/silicon/robot/Exited(atom/A)
	if(hat && hat == A)
		hat = null
		if(!QDELETED(src)) //Don't update icons if we are deleted.
			update_icons()
	return ..()

///Called when a mob uses an upgrade on an open borg. Checks to make sure the upgrade can be applied
/mob/living/silicon/robot/proc/apply_upgrade(obj/item/borg/upgrade/new_upgrade, mob/user)
	if(isnull(user))
		return FALSE
	if(new_upgrade in upgrades)
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(new_upgrade)) //calling the upgrade's dropped() proc /before/ we add action buttons
		return FALSE
	if(!new_upgrade.action(src, user))
		to_chat(user, "<span class='danger'>Upgrade error.</span>")
		new_upgrade.forceMove(loc) //gets lost otherwise
		return FALSE
	to_chat(user, "<span class='notice'>You apply the upgrade to [src].</span>")
	add_to_upgrades(new_upgrade)

///Moves the upgrade inside the robot and registers relevant signals.
/mob/living/silicon/robot/proc/add_to_upgrades(obj/item/borg/upgrade/new_upgrade)
	to_chat(src, "----------------\nNew hardware detected...Identified as \"<b>[new_upgrade]</b>\"...Setup complete.\n----------------")
	if(new_upgrade.one_use)
		logevent("Firmware [new_upgrade] run successfully.")
		qdel(new_upgrade)
		return FALSE
	upgrades += new_upgrade
	new_upgrade.forceMove(src)
	RegisterSignal(new_upgrade, COMSIG_MOVABLE_MOVED, PROC_REF(remove_from_upgrades))
	RegisterSignal(new_upgrade, COMSIG_QDELETING, PROC_REF(on_upgrade_deleted))
	logevent("Hardware [new_upgrade] installed successfully.")

///Called when an upgrade is moved outside the robot. So don't call this directly, use forceMove etc.
/mob/living/silicon/robot/proc/remove_from_upgrades(obj/item/borg/upgrade/old_upgrade)
	SIGNAL_HANDLER
	if(loc == src)
		return
	old_upgrade.deactivate(src)
	upgrades -= old_upgrade
	UnregisterSignal(old_upgrade, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

///Called when an applied upgrade is deleted.
/mob/living/silicon/robot/proc/on_upgrade_deleted(obj/item/borg/upgrade/old_upgrade)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		old_upgrade.deactivate(src)
	upgrades -= old_upgrade
	UnregisterSignal(old_upgrade, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

/mob/living/silicon/robot/proc/make_shell(obj/item/borg/upgrade/ai/board)
	if(isnull(board))
		stack_trace("make_shell was called without a board argument! This is never supposed to happen!")
		return FALSE

	shell = TRUE
	braintype = "AI Shell"
	name = "[designation] AI Shell [rand(100,999)]"
	real_name = name
	GLOB.available_ai_shells |= src
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too
	diag_hud_set_aishell()
	notify_ai(AI_SHELL)

/mob/living/silicon/robot/proc/revert_shell()
	if(!shell)
		return
	undeploy()
	for(var/obj/item/borg/upgrade/ai/boris in src)
	//A player forced reset of a borg would drop the module before this is called, so this is for catching edge cases
		qdel(boris)
	shell = FALSE
	GLOB.available_ai_shells -= src
	name = "Unformatted Cyborg [rand(100,999)]"
	real_name = name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name
	diag_hud_set_aishell()

/mob/living/silicon/robot/proc/deploy_init(mob/living/silicon/ai/AI)
	real_name = "[AI.real_name] shell [rand(100, 999)] - [designation]"	//Randomizing the name so it shows up separately in the shells list
	name = real_name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too
	mainframe = AI
	deployed = TRUE
	connected_ai = mainframe
	mainframe.connected_robots |= src
	lawupdate = TRUE
	lawsync()
	if(radio && AI.radio) //AI keeps all channels, including Syndie if it is a Traitor
		if(AI.radio.syndie)
			radio.make_syndie()
		radio.subspace_transmission = TRUE
		radio.channels = AI.radio.channels
		for(var/chan in radio.channels)
			radio.secure_radio_connections[chan] = add_radio(radio, GLOB.radiochannels[chan])

	diag_hud_set_aishell()
	undeployment_action.Grant(src)
	wires.ui_update()

/datum/action/innate/undeployment
	name = "Disconnect from shell"
	desc = "Stop controlling your shell and resume normal core operations."
	icon_icon = 'icons/hud/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/undeployment/on_activate(mob/user, atom/target)
	var/mob/living/silicon/robot/R = owner

	R.undeploy()
	return TRUE


/mob/living/silicon/robot/proc/undeploy()
	if(!deployed || !mind || !mainframe)
		return
	mainframe.redeploy_action.Grant(mainframe)
	mainframe.redeploy_action.last_used_shell = src
	mind.transfer_to(mainframe)
	deployed = FALSE
	mainframe.deployed_shell = null
	undeployment_action.Remove(src)
	if(radio) //Return radio to normal
		radio.recalculateChannels()
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too
	diag_hud_set_aishell()
	mainframe.diag_hud_set_deployed()
	if(mainframe.laws)
		mainframe.laws.show_laws(mainframe) //Always remind the AI when switching
	if(!mainframe.eyeobj)
		mainframe.create_eye()
	mainframe.eyeobj.setLoc(get_turf(src))
	transfer_observers_to(mainframe.eyeobj) // borg shell to eyemob
	mainframe.transfer_observers_to(mainframe.eyeobj) // ai core to eyemob
	mainframe = null

/mob/living/silicon/robot/attack_ai(mob/user)
	if(shell && (!connected_ai || connected_ai == user))
		var/mob/living/silicon/ai/AI = user
		AI.deploy_to_shell(src)

/mob/living/silicon/robot/shell
	shell = TRUE
	cell = /obj/item/stock_parts/cell/high

/mob/living/silicon/robot/mouse_buckle_handling(mob/living/M, mob/living/user)
	//Don't try buckling on combat_mode so that silicons can search people's inventories without loading them
	if(can_buckle && isliving(user) && isliving(M) && !(M in buckled_mobs) && ((user != src) || (!combat_mode)))
		return user_buckle_mob(M, user, check_loc = FALSE)

/mob/living/silicon/robot/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE, buckle_mob_flags= RIDER_NEEDS_ARM)
	if(!is_type_in_typecache(M, can_ride_typecache))
		M.visible_message(span_warning("[M] really can't seem to mount [src]..."))
		return

	if(stat || incapacitated())
		return
	if(model && !model.allow_riding)
		M.visible_message(span_boldwarning("Unfortunately, [M] just can't seem to hold onto [src]!"))
		return

	buckle_mob_flags = RIDER_NEEDS_ARM // just in case
	return ..()

/mob/living/silicon/robot/unbuckle_mob(mob/user, force=FALSE)
	if(iscarbon(user))
		var/datum/component/riding/riding_datum = GetComponent(/datum/component/riding)
		if(istype(riding_datum))
			riding_datum.unequip_buckle_inhands(user)
			riding_datum.restore_position(user)
	. = ..(user)

/mob/living/silicon/robot/proc/TryConnectToAI()
	connected_ai = select_active_ai_with_fewest_borgs()
	if(connected_ai)
		connected_ai.connected_robots += src
		lawsync()
		lawupdate = TRUE
		wires.ui_update()
		return TRUE
	picturesync()
	wires.ui_update()
	return FALSE

/mob/living/silicon/robot/proc/picturesync()
	if(connected_ai && connected_ai.aicamera && aicamera)
		for(var/i in aicamera.stored)
			connected_ai.aicamera.stored[i] = TRUE
		for(var/i in connected_ai.aicamera.stored)
			aicamera.stored[i] = TRUE

/mob/living/silicon/robot/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER

	if(model)
		model.respawn_consumable(src, amount * 0.005)
	if(cell)
		cell.charge = min(cell.charge + amount, cell.maxcharge)
	if(repairs)
		heal_bodypart_damage(repairs, repairs - 1)
