/mob/living/silicon/robot
	name = JOB_NAME_CYBORG
	real_name = JOB_NAME_CYBORG
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 200
	health = 200
	bubble_icon = "robot"
	designation = "Default" //used for displaying the prefix & getting the current module of cyborg
	has_limbs = 1
	hud_type = /datum/hud/robot
	radio = /obj/item/radio/borg
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	var/custom_name = ""
	var/braintype = "Cyborg"
	var/obj/item/robot_suit/robot_suit = null //Used for deconstruction to remember what the borg was constructed out of..
	var/obj/item/mmi/mmi = null
	///The last time this mob was flashed. Used for flash cooldowns
	var/last_flashed = 0

	var/shell = FALSE
	var/deployed = FALSE
	var/mob/living/silicon/ai/mainframe = null
	var/datum/action/innate/undeployment/undeployment_action = new

	var/obj/item/clockwork/clockwork_slab/internal_clock_slab = null
	var/ratvar = FALSE

	var/datum/action/cleaning_toggle/autoclean_toggle

//Hud stuff

	var/atom/movable/screen/inv1 = null
	var/atom/movable/screen/inv2 = null
	var/atom/movable/screen/inv3 = null
	var/atom/movable/screen/hands = null

	var/shown_robot_modules = 0	//Used to determine whether they have the module menu shown or not
	var/atom/movable/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/robot_module/module = null
	var/obj/item/module_active = null
	held_items = list(null, null, null) //we use held_items for the module holding, because that makes sense to do!

	var/mutable_appearance/eye_lights

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high ///If this is a path, this gets created as an object in Initialize.

	var/opened = 0
	var/emagged = FALSE
	var/emag_cooldown = 0
	var/wiresexposed = 0

	var/ident = 0
	var/locked = TRUE
	var/list/req_access = list(ACCESS_ROBOTICS)

	/// Station alert datum for showing alerts UI
	var/datum/station_alert/alert_control

	var/speed = 0 // VTEC speed boost.
	var/magpulse = FALSE // Magboot-like effect.
	var/ionpulse = FALSE // Jetpack-like effect.
	var/ionpulse_on = FALSE // Jetpack-like effect.
	var/datum/effect_system/trail_follow/ion/ion_trail // Ionpulse effect.

	var/low_power_mode = 0 //whether the robot has no charge left.
	var/datum/effect_system/spark_spread/spark_system // So they can initialize sparks whenever/N

	var/lawupdate = TRUE //Cyborgs will sync their laws with their AI by default
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/lockcharge //Boolean of whether the borg is locked down or not

	var/toner = 0
	var/tonermax = 40

	///If the lamp isn't broken.
	var/lamp_functional = TRUE
	///If the lamp is turned on
	var/lamp_enabled = FALSE
	///Set lamp color
	var/lamp_color = COLOR_WHITE
	///Lamp brightness. Starts at 3, but can be 1 - 5.
	var/lamp_intensity = 3
	///Lamp button reference
	var/atom/movable/screen/robot/lamp/lampButton

	var/sight_mode = 0
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD)

	var/atom/movable/screen/robot/modpc/interfaceButton

	var/list/upgrades = list()

	var/hasExpanded = FALSE
	var/obj/item/hat
	var/hat_offset = -3
	var/list/blacklisted_hats = list( //Hats that don't really work on borgos
	/obj/item/clothing/head/helmet/space/santahat,
	/obj/item/clothing/head/welding,
	/obj/item/clothing/head/helmet/space/eva,
	)

	can_buckle = TRUE
	buckle_lying = FALSE
	var/static/list/can_ride_typecache = typecacheof(/mob/living/carbon/human)

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/Initialize(mapload)
	default_access_list = get_all_accesses()

	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	wires = new /datum/wires/robot(src)
	AddComponent(/datum/component/empprotection, EMP_PROTECT_WIRES)
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
		builtInCamera.network = list("ss13")
		builtInCamera.internal_light = FALSE
		if(wires.is_cut(WIRE_CAMERA))
			builtInCamera.status = 0
	module = new /obj/item/robot_module(src)
	module.rebuild_modules()
	update_icons()
	. = ..()
	add_sensors()

	//If this body is meant to be a borg controlled by the AI player
	if(shell)
		make_shell()

	//MMI stuff. Held togheter by magic. ~Miauw
	else if(!mmi || !mmi.brainmob)
		mmi = new (src)
		mmi.brain = new /obj/item/organ/brain(mmi)
		mmi.brain.organ_flags |= ORGAN_FROZEN
		mmi.brain.name = "[real_name]'s brain"
		mmi.name = "[initial(mmi.name)]: [real_name]"
		mmi.brainmob = new(mmi)
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
	alert_control.listener.RegisterSignal(src, COMSIG_LIVING_DEATH, /datum/alarm_listener/proc/prevent_alarm_changes)
	alert_control.listener.RegisterSignal(src, COMSIG_LIVING_REVIVE, /datum/alarm_listener/proc/allow_alarm_changes)

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
	if(istype(module, /obj/item/robot_module/syndicate) || emagged)
		modularInterface.device_theme = THEME_SYNDICATE
		modularInterface.icon_state = "tablet-silicon-syndicate"
		modularInterface.icon_state_powered = "tablet-silicon-syndicate"
		modularInterface.icon_state_unpowered = "tablet-silicon-syndicate"
	else
		modularInterface.device_theme = THEME_NTOS
		modularInterface.icon_state = "tablet-silicon"
		modularInterface.icon_state_powered = "tablet-silicon"
		modularInterface.icon_state_unpowered = "tablet-silicon"
	modularInterface.update_icon()

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
/mob/living/silicon/robot/Destroy()
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
			to_chat(src, "<span class='boldannounce'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>")
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
		autoclean_toggle.Remove(usr)
	QDEL_NULL(autoclean_toggle)
	QDEL_NULL(wires)
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

/mob/living/silicon/robot/proc/pick_module()
	if(module.type != /obj/item/robot_module)
		return

	if(wires.is_cut(WIRE_RESET_MODULE))
		to_chat(src,"<span class='userdanger'>ERROR: Module installer reply timeout. Please check internal connections.</span>")
		return

	var/list/modulelist = list("Standard" = /obj/item/robot_module/standard, \
	"Engineering" = /obj/item/robot_module/engineering, \
	"Medical" = /obj/item/robot_module/medical, \
	"Miner" = /obj/item/robot_module/miner, \
	"Janitor" = /obj/item/robot_module/janitor, \
	"Service" = /obj/item/robot_module/butler)
	if(!CONFIG_GET(flag/disable_peaceborg))
		modulelist["Peacekeeper"] = /obj/item/robot_module/peacekeeper

	// Create radial menu for choosing borg model *smug* module
	var/list/module_icons = list()
	for(var/option in modulelist)
		var/obj/item/robot_module/module = modulelist[option]
		var/module_icon = initial(module.cyborg_base_icon)
		module_icons[option] = image(icon = 'icons/mob/robots.dmi', icon_state = module_icon)

	var/input_module = show_radial_menu(src, src, module_icons, radius = 42)
	if(!input_module || module.type != /obj/item/robot_module)
		return

	module.transform_to(modulelist[input_module])


/mob/living/silicon/robot/proc/updatename(client/C)
	if(shell)
		return
	if(!C)
		C = client
	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	if(changed_name == "" && C && C.prefs.active_character.custom_names["cyborg"] != DEFAULT_CYBORG_NAME)
		if(apply_pref_name("cyborg", C))
			return //built in camera handled in proc
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
		to_chat(src, "<span class='notice'>No thrusters are installed!</span>")
		return

	if(!ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

	ionpulse_on = !ionpulse_on
	to_chat(src, "<span class='notice'>You [ionpulse_on ? null :"de"]activate your ion thrusters.</span>")
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

	if(module)
		for(var/datum/robot_energy_storage/st in module.storages)
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

/mob/living/silicon/robot/restrained(ignore_grab)
	. = 0

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

/mob/living/silicon/robot/attackby(obj/item/W, mob/user, params)
	if(length(user.progressbars))
		if(W.tool_behaviour == TOOL_WELDER || istype(W, /obj/item/stack/cable_coil))
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, "<span class='notice'>You are already busy!</span>")
			return
	if(W.tool_behaviour == TOOL_WELDER && (user.a_intent != INTENT_HARM))
		user.changeNext_move(CLICK_CD_MELEE)
		if(user == src)
			to_chat(user, "<span class='warning'>You are unable to maneuver [W] properly to repair yourself, seek assistance!</span>")
			return
		if (!getBruteLoss())
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
			return
		//repeatedly repairs until the cyborg is fully repaired
		while(getBruteLoss() && W.tool_start_check(user, amount=0) && W.use_tool(src, user, 3 SECONDS))
			W.use(1) //use one fuel for each repair step
			adjustBruteLoss(-10)
			updatehealth()
			add_fingerprint(user)
			user.visible_message("[user] has fixed some of the dents on [src].", "<span class='notice'>You fix some of the dents on [src].</span>")
		return TRUE

	else if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		user.changeNext_move(CLICK_CD_MELEE)
		if(!(getFireLoss() || getToxLoss()))
			to_chat(user, "The wires seem fine, there's no need to fix them.")
			return
		var/obj/item/stack/cable_coil/coil = W
		while((getFireLoss() || getToxLoss()) && do_after(user, 30, target = src))
			if(coil.use(1))
				adjustFireLoss(-20)
				adjustToxLoss(-20)
				updatehealth()
				add_fingerprint(user)
				user.visible_message("[user] has fixed some of the burnt wires on [src].", "<span class='notice'>You fix some of the burnt wires on [src].</span>")
			else
				to_chat(user, "<span class='warning'>You need more cable to repair [src]!</span>")

	else if(W.tool_behaviour == TOOL_CROWBAR)	// crowbar means open or close the cover
		if(opened)
			to_chat(user, "<span class='notice'>You close the cover.</span>")
			opened = 0
			update_icons()
		else
			if(locked)
				to_chat(user, "<span class='warning'>The cover is locked and cannot be opened!</span>")
			else
				to_chat(user, "<span class='notice'>You open the cover.</span>")
				if(IsParalyzed() && (last_flashed + 5 SECONDS >= world.time)) //second half of this prevents someone from stunlocking via open/close spam
					Paralyze(5 SECONDS)
				opened = 1
				update_icons()
	else if(istype(W, /obj/item/stock_parts/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			to_chat(user, "<span class='warning'>Close the cover first!</span>")
		else if(cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed!</span>")
		else
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>You insert the power cell.</span>")
		update_icons()
		diag_hud_set_borgcell()

	else if(is_wire_tool(W))
		if (wiresexposed)
			wires.interact(user)
		else
			to_chat(user, "<span class='warning'>You can't reach the wiring!</span>")

	else if(W.tool_behaviour == TOOL_SCREWDRIVER && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		update_icons()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER && opened && cell)	// radio
		if(shell)
			to_chat(user, "You cannot seem to open the radio compartment.")	//Prevent AI radio key theft
		else if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			to_chat(user, "<span class='warning'>Unable to locate a radio!</span>")
		update_icons()

	else if(W.tool_behaviour == TOOL_WRENCH && opened && !cell) //Deconstruction. The flashes break from the fall, to prevent this from being a ghetto reset module.
		if(!lockcharge)
			to_chat(user, "<span class='boldannounce'>[src]'s bolts spark! Maybe you should lock them down first!</span>")
			spark_system.start()
			return
		else
			to_chat(user, "<span class='notice'>You start to unfasten [src]'s securing bolts.</span>")
			if(W.use_tool(src, user, 50, volume=50) && !cell)
				user.visible_message("[user] deconstructs [src]!", "<span class='notice'>You unfasten the securing bolts, and [src] falls to pieces!</span>")
				log_attack("[key_name(user)] deconstructed [name] at [AREACOORD(src)].")
				deconstruct()

	else if(istype(W, /obj/item/aiModule))
		var/obj/item/aiModule/MOD = W
		if(!opened)
			to_chat(user, "<span class='warning'>You need access to the robot's insides to do that!</span>")
			return
		if(wiresexposed)
			to_chat(user, "<span class='warning'>You need to close the wire panel to do that!</span>")
			return
		if(!cell)
			to_chat(user, "<span class='warning'>You need to install a power cell to do that!</span>")
			return
		if(shell) //AI shells always have the laws of the AI
			to_chat(user, "<span class='warning'>[src] is controlled remotely! You cannot upload new laws this way!</span>")
			return
		if(emagged || (connected_ai && lawupdate)) //Can't be sure which, metagamers
			emote("buzz-[user.name]")
			return
		if(!mind) //A player mind is required for law procs to run antag checks.
			to_chat(user, "<span class='warning'>[src] is entirely unresponsive!</span>")
			return
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
		return

	else if(istype(W, /obj/item/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "<span class='warning'>Unable to locate a radio!</span>")

	else if (istype(W, /obj/item/card/id)||istype(W, /obj/item/modular_computer/tablet/pda))			// trying to unlock the interface with an ID card
		togglelock(user)

	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			to_chat(user, "<span class='warning'>You must access the borg's internals!</span>")
		else if(!src.module && U.require_module)
			to_chat(user, "<span class='warning'>The borg must choose a module before it can be upgraded!</span>")
		else if(U.locked)
			to_chat(user, "<span class='warning'>The upgrade is locked and cannot be used yet!</span>")
		else
			if(!user.temporarilyRemoveItemFromInventory(U))
				return
			if(U.action(src))
				to_chat(user, "<span class='notice'>You apply the upgrade to [src].</span>")
				to_chat(src, "----------------\nNew hardware detected...Identified as \"<b>[U]</b>\"...Setup complete.\n----------------")
				if(U.one_use)
					qdel(U)
					logevent("Firmware [U] run successfully.")
				else
					U.forceMove(src)
					upgrades += U
					logevent("Hardware [U] installed successfully.")
			else
				to_chat(user, "<span class='danger'>Upgrade error.</span>")
				U.forceMove(drop_location())
	else if(istype(W, /obj/item/toner))
		if(toner >= tonermax)
			to_chat(user, "<span class='warning'>The toner level of [src] is at its highest level possible!</span>")
		else
			if(!user.temporarilyRemoveItemFromInventory(W))
				return
			toner = tonermax
			qdel(W)
			to_chat(user, "<span class='notice'>You fill the toner level of [src] to its max capacity.</span>")

	else if(istype(W, /obj/item/flashlight))
		if(!opened)
			to_chat(user, "<span class='warning'>You need to open the panel to repair the headlamp!</span>")
		else if(lamp_functional)
			to_chat(user, "<span class='warning'>The headlamp is already functional!</span>")
		else
			if(!user.temporarilyRemoveItemFromInventory(W))
				to_chat(user, "<span class='warning'>[W] seems to be stuck to your hand. You'll have to find a different light.</span>")
				return
			lamp_functional = TRUE
			qdel(W)
			to_chat(user, "<span class='notice'>You replace the headlamp bulbs.</span>")
	else if(istype(W, /obj/item/computer_hardware/hard_drive/portable)) //Allows borgs to install new programs with human help
		if(!modularInterface)
			stack_trace("Cyborg [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
			create_modularInterface()
		var/obj/item/computer_hardware/hard_drive/portable/floppy = W
		if(modularInterface.install_component(floppy, user))
			return
	else
		return ..()

/mob/living/silicon/robot/proc/togglelock(mob/user)
	if(opened)
		to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card!</span>")
	else
		if(allowed(usr))
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] [src]'s cover.</span>")
			update_icons()
			if(emagged)
				to_chat(user, "<span class='notice'>The cover interface glitches out for a split second.</span>")
			logevent("[emagged ? "ChÃ¥vÃis" : "Chassis"] cover lock has been [locked ? "engaged" : "released"]") //ChÃ¥vÃis: see above line
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")

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
	icon_state = module.cyborg_base_icon
	if(stat != DEAD && !(IsUnconscious() || IsStun() || IsParalyzed() || low_power_mode)) //Not dead, not stunned.
		if(!eye_lights)
			eye_lights = new()
		if(last_flashed && last_flashed + 30 SECONDS >= world.time) //We want to make sure last_flashed isn't zero because otherwise roundstart borgs blink for 30 seconds
			eye_lights.icon_state = "[module.special_light_key ? "[module.special_light_key]":"[module.cyborg_base_icon]"]_fl"
		else if(lamp_enabled)
			eye_lights.icon_state = "[module.special_light_key ? "[module.special_light_key]":"[module.cyborg_base_icon]"]_l"
			eye_lights.color = lamp_color
			eye_lights.plane = ABOVE_LIGHTING_PLANE //glowy eyes
		else
			eye_lights.icon_state = "[module.special_light_key ? "[module.special_light_key]":"[module.cyborg_base_icon]"]_e[ratvar ? "_r" : ""]"
			eye_lights.color = COLOR_WHITE
			eye_lights.plane = ABOVE_LIGHTING_PLANE //still glowy, but don't emit actual light
		eye_lights.icon = icon
		add_overlay(eye_lights)

	if(opened)
		if(wiresexposed)
			add_overlay("ov-opencover +w")
		else if(cell)
			add_overlay("ov-opencover +c")
		else
			add_overlay("ov-opencover -c")
	if(hat)
		var/mutable_appearance/head_overlay = hat.build_worn_icon(default_layer = 20, default_icon_file = 'icons/mob/clothing/head.dmi')
		head_overlay.pixel_y += hat_offset
		add_overlay(head_overlay)
	update_fire()

/mob/living/silicon/robot/proc/self_destruct(mob/usr)
	var/turf/groundzero = get_turf(src)
	message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(src, client)] at [ADMIN_VERBOSEJMP(groundzero)]!</span>")
	log_game("\<span class='notice'>[key_name(usr)] detonated [key_name(src)]!</span>")
	log_combat(usr, src, "detonated cyborg")
	if(connected_ai)
		to_chat(connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [name]</span><br>")

	if(emagged)
		explosion(src.loc,1,2,4,flame_range = 2)
	else
		explosion(src.loc,-1,0,2)
	gib()

/mob/living/silicon/robot/proc/UnlinkSelf()
	if(src.connected_ai)
		connected_ai.connected_robots -= src
		src.connected_ai = null
	lawupdate = FALSE
	lockcharge = FALSE
	mobility_flags |= MOBILITY_FLAGS_DEFAULT
	scrambledcodes = TRUE_DEVIL
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
	var/obj/item/W = get_active_held_item()
	if(W)
		W.attack_self(src)


/mob/living/silicon/robot/proc/SetLockdown(state = TRUE)
	// They stay locked down if their wire is cut.
	if(wires.is_cut(WIRE_LOCKDOWN))
		state = TRUE
	if(state)
		throw_alert("locked", /atom/movable/screen/alert/locked)
	else
		clear_alert("locked")
	lockcharge = state
	update_mobility()
	logevent("System lockdown [lockcharge?"triggered":"released"].")

/mob/living/silicon/robot/proc/SetEmagged(new_state)
	emagged = new_state
	module.rebuild_modules()
	update_icons()
	if(emagged)
		throw_alert("hacked", /atom/movable/screen/alert/hacked)
	else
		clear_alert("hacked")
	set_modularInterface_theme()

/mob/living/silicon/robot/proc/SetRatvar(new_state, rebuild=TRUE)
	ratvar = new_state
	if(rebuild)
		module.rebuild_modules()
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
	to_chat(src, "<span class='danger'>Your headlamp is broken! You'll need a human to help replace it.</span>")

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
		new /obj/item/bodypart/l_leg/robot(T)
		new /obj/item/bodypart/r_leg/robot(T)
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/bodypart/chest/robot(T)
		new /obj/item/bodypart/l_arm/robot(T)
		new /obj/item/bodypart/r_arm/robot(T)
		new /obj/item/bodypart/head/robot(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/assembly/flash/handheld/F = new /obj/item/assembly/flash/handheld(T)
			F.burn_out()
	if (cell) //Sanity check.
		cell.forceMove(T)
		cell = null
	qdel(src)

///This is the subtype that gets created by robot suits. It's needed so that those kind of borgs don't have a useless cell in them
/mob/living/silicon/robot/nocell
	cell = null

/mob/living/silicon/robot/modules
	var/set_module = null

/mob/living/silicon/robot/modules/Initialize(mapload)
	. = ..()
	module.transform_to(set_module)

/mob/living/silicon/robot/modules/standard
	set_module = /obj/item/robot_module/standard

/mob/living/silicon/robot/modules/medical
	set_module = /obj/item/robot_module/medical
	icon_state = "medical"

/mob/living/silicon/robot/modules/engineering
	set_module = /obj/item/robot_module/engineering
	icon_state = "engineer"

/mob/living/silicon/robot/modules/security
	set_module = /obj/item/robot_module/security
	icon_state = "sec"

/mob/living/silicon/robot/modules/clown
	set_module = /obj/item/robot_module/clown
	icon_state = "clown"

/mob/living/silicon/robot/modules/peacekeeper
	set_module = /obj/item/robot_module/peacekeeper
	icon_state = "peace"

/mob/living/silicon/robot/modules/miner
	set_module = /obj/item/robot_module/miner
	icon_state = "miner"

/mob/living/silicon/robot/modules/janitor
	set_module = /obj/item/robot_module/janitor
	icon_state = "janitor"

/mob/living/silicon/robot/modules/syndicate
	icon_state = "synd_sec"
	faction = list(FACTION_SYNDICATE)
	bubble_icon = "syndibot"
	req_access = list(ACCESS_SYNDICATE)
	lawupdate = FALSE
	scrambledcodes = TRUE // These are rogue borgs.
	ionpulse = TRUE
	var/playstyle_string = "<span class='big bold'>You are a Syndicate assault cyborg!</span><br>\
							<b>You are armed with powerful offensive tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
							Your cyborg LMG will slowly produce ammunition from your power supply, and your operative pinpointer will find and locate fellow nuclear operatives. \
							<i>Help the operatives secure the disk at all costs!</i></b>"
	set_module = /obj/item/robot_module/syndicate
	cell = /obj/item/stock_parts/cell/hyper
	radio = /obj/item/radio/borg/syndicate

/mob/living/silicon/robot/modules/syndicate/Initialize(mapload)
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	//Add in syndicate access to their ID card.
	create_access_card(get_all_syndicate_access())
	addtimer(CALLBACK(src, PROC_REF(show_playstyle)), 5)

/mob/living/silicon/robot/modules/syndicate/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated/syndicate(src)
		modularInterface.saved_identification = real_name
		modularInterface.saved_job = "Cyborg"
	return ..()

/mob/living/silicon/robot/modules/syndicate/proc/show_playstyle()
	if(playstyle_string)
		to_chat(src, playstyle_string)

/mob/living/silicon/robot/modules/syndicate/ResetModule()
	return


/mob/living/silicon/robot/modules/syndicate/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated/syndicate(src)
	return ..()

/mob/living/silicon/robot/modules/syndicate/medical
	icon_state = "synd_medical"
	playstyle_string = "<span class='big bold'>You are a Syndicate medical cyborg!</span><br>\
						<b>You are armed with powerful medical tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your hypospray will produce Restorative Nanites, a wonder-drug that will heal most types of bodily damages, including clone and brain damage. It also produces morphine for offense. \
						Your defibrillator paddles can revive operatives through their hardsuits, or can be used on harm intent to shock enemies! \
						Your energy saw functions as a circular saw, but can be activated to deal more damage, and your operative pinpointer will find and locate fellow nuclear operatives. \
						<i>Help the operatives secure the disk at all costs!</i></b>"
	set_module = /obj/item/robot_module/syndicate_medical

/mob/living/silicon/robot/modules/syndicate/saboteur
	icon_state = "synd_engi"
	playstyle_string = "<span class='big bold'>You are a Syndicate saboteur cyborg!</span><br>\
						<b>You are armed with robust engineering tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your destination tagger will allow you to stealthily traverse the disposal network across the station \
						Your welder will allow you to repair the operatives' exosuits, but also yourself and your fellow cyborgs \
						Your cyborg chameleon projector allows you to assume the appearance and registered name of a Nanotrasen engineering borg, and undertake covert actions on the station \
						Be aware that almost any physical contact or incidental damage will break your camouflage \
						<i>Help the operatives secure the disk at all costs!</i></b>"
	set_module = /obj/item/robot_module/saboteur

/mob/living/silicon/robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(NEW_BORG) //New Cyborg
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New cyborg connection detected: <a href='?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a></span><br>")
		if(NEW_MODULE) //New Module
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.</span><br>")
		if(RENAME) //New Name
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].</span><br>")
		if(AI_SHELL) //New Shell
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New cyborg shell detected: <a href='?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a></span><br>")
		if(DISCONNECT) //Tampering with the wires
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Remote telemetry lost with [name].</span><br>")

/mob/living/silicon/robot/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	if(stat || lockcharge || low_power_mode)
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/living/silicon/robot/updatehealth()
	..()
	if(health < maxHealth*0.75) //Gradual break down of modules as more damage is sustained
		var/speedpenalty = (maxHealth - health) / 150
		add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN, override = TRUE, multiplicative_slowdown = speedpenalty, blacklisted_movetypes = FLOATING)
		if(uneq_module(held_items[3]))
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, 1, 1)
			audible_message("<span class='warning'>[src] sounds an alarm! \"SYSTEM ERROR: Module 3 OFFLINE.\"</span>")
			to_chat(src, "<span class='userdanger'>SYSTEM ERROR: Module 3 OFFLINE.</span>")
		if(health < maxHealth*0.5)
			if(uneq_module(held_items[2]))
				audible_message("<span class='warning'>[src] sounds an alarm! \"SYSTEM ERROR: Module 2 OFFLINE.\"</span>")
				to_chat(src, "<span class='userdanger'>SYSTEM ERROR: Module 2 OFFLINE.</span>")
				playsound(loc, 'sound/machines/warning-buzzer.ogg', 60, 1, 1)
			if(health < maxHealth*0.25)
				if(uneq_module(held_items[1]))
					audible_message("<span class='warning'>[src] sounds an alarm! \"CRITICAL ERROR: All modules OFFLINE.\"</span>")
					to_chat(src, "<span class='userdanger'>CRITICAL ERROR: All modules OFFLINE.</span>")
					playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, 1, 1)
	else
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN)

/mob/living/silicon/robot/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
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
		see_in_dark = 8

	if(sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		see_invisible = min(see_invisible, SEE_INVISIBLE_LIVING)
		see_in_dark = 8

	if(see_override)
		see_invisible = see_override
	sync_lighting_plane_alpha()

/mob/living/silicon/robot/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0) //die only once
			death()
			toggle_headlamp(1)
			return
		if(IsUnconscious() || IsStun() || IsKnockdown() || IsParalyzed() || getOxyLoss() > maxHealth*0.5)
			if(stat == CONSCIOUS)
				set_stat(UNCONSCIOUS)
				become_blind(UNCONSCIOUS_BLIND)
				update_mobility()
		else
			if(stat == UNCONSCIOUS)
				set_stat(CONSCIOUS)
				cure_blind(UNCONSCIOUS_BLIND)
				update_mobility()
	diag_hud_set_status()
	diag_hud_set_health()
	diag_hud_set_aishell()
	update_health_hud()
	update_icons() //Updates eye_light overlay

/mob/living/silicon/robot/revive(full_heal = 0, admin_revive = 0)
	if(..()) //successfully ressuscitated from death
		if(!QDELETED(builtInCamera) && !wires.is_cut(WIRE_CAMERA))
			builtInCamera.toggle_cam(src,0)
		if(admin_revive)
			locked = TRUE
		notify_ai(NEW_BORG)
		wires.ui_update()
		. = 1

/mob/living/silicon/robot/fully_replace_character_name(oldname, newname)
	..()
	if(oldname != real_name)
		notify_ai(RENAME, oldname, newname)
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name
		modularInterface.saved_identification = real_name
	custom_name = newname


/mob/living/silicon/robot/proc/ResetModule()
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
	module.transform_to(/obj/item/robot_module)

	// Remove upgrades.
	for(var/obj/item/borg/upgrade/I in upgrades)
		I.deactivate(src)
		I.forceMove(get_turf(src))

	upgrades.Cut()

	speed = 0
	ionpulse = FALSE
	revert_shell()

	return 1

/mob/living/silicon/robot/proc/has_module()
	if(!module || module.type == /obj/item/robot_module)
		. = FALSE
	else
		. = TRUE

/mob/living/silicon/robot/proc/update_module_innate()
	designation = module.name
	if(hands)
		hands.icon_state = module.moduleselect_icon
	if(module.can_be_pushed)
		status_flags |= CANPUSH
	else
		status_flags &= ~CANPUSH

	if(module.clean_on_move)
		AddElement(/datum/element/cleaning)
		autoclean_toggle = new()
		autoclean_toggle.toggle_target = usr
		autoclean_toggle.Grant(usr)
	else
		RemoveElement(/datum/element/cleaning)
		if(autoclean_toggle)
			autoclean_toggle.Remove(usr)
			QDEL_NULL(autoclean_toggle)

	hat_offset = module.hat_offset

	magpulse = module.magpulsing
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
	update_icons()
	. = ..()

/mob/living/silicon/robot/proc/make_shell(var/obj/item/borg/upgrade/ai/board)
	if(!board)
		upgrades |= new /obj/item/borg/upgrade/ai(src)
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

/mob/living/silicon/robot/proc/deploy_init(var/mob/living/silicon/ai/AI)
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
	icon_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/undeployment/Trigger()
	if(!..())
		return FALSE
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
	cell = null

/mob/living/silicon/robot/mouse_buckle_handling(mob/living/M, mob/living/user)
	if(can_buckle && istype(M) && !(M in buckled_mobs) && ((user!=src)||(a_intent != INTENT_HARM)))
		if(buckle_mob(M))
			return TRUE

/mob/living/silicon/robot/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!is_type_in_typecache(M, can_ride_typecache))
		M.visible_message("<span class='warning'>[M] really can't seem to mount [src]...</span>")
		return
	var/datum/component/riding/riding_datum = LoadComponent(/datum/component/riding/cyborg)
	if(has_buckled_mobs())
		if(buckled_mobs.len >= max_buckled_mobs)
			return
		if(M in buckled_mobs)
			return
	if(stat)
		return
	if(incapacitated())
		return
	if(M.incapacitated())
		return
	if(module)
		if(!module.allow_riding)
			M.visible_message("<span class='boldwarning'>Unfortunately, [M] just can't seem to hold onto [src]!</span>")
			return
	if(iscarbon(M) && (!riding_datum.equip_buckle_inhands(M, 1)))
		if (M.get_num_arms() <= 0)
			M.visible_message("<span class='boldwarning'>[M] can't climb onto [src] because [M.p_they()] don't have any usable arms!</span>")
		else
			M.visible_message("<span class='boldwarning'>[M] can't climb onto [src] because [M.p_their()] hands are full!</span>")
		return
	. = ..(M, force, check_loc)

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

	if(module)
		module.respawn_consumable(src, amount * 0.005)
	if(cell)
		cell.charge = min(cell.charge + amount, cell.maxcharge)
	if(repairs)
		heal_bodypart_damage(repairs, repairs - 1)
