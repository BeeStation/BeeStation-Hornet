/obj/machinery/camera
	name = "security camera"
	desc = "A wireless camera used to monitor rooms. It is powered by a long-life internal battery."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "camera" //mapping icon to represent upgrade states. if you want a different base icon, update default_camera_icon as well as this.
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 50 WATT
	active_power_usage = 200 WATT
	layer = WALL_OBJ_LAYER
	resistance_flags = FIRE_PROOF
	damage_deflection = 12

	armor_type = /datum/armor/machinery_camera
	max_integrity = 100
	integrity_failure = 0.5
	var/default_camera_icon = "camera" //the camera's base icon used by update_icon - icon_state is primarily used for mapping display purposes.
	var/list/network
	var/c_tag = null
	var/status = TRUE
	var/current_state = TRUE
	var/start_active = FALSE //If it ignores the random chance to start broken on round start
	var/invuln = null
	var/obj/item/camera_bug/bug = null
	var/datum/weakref/assembly_ref = null
	var/area/myarea = null

	//Emp tracking
	var/thisemp
	var/list/previous_network

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/emped = FALSE  //Number of consecutive EMP's on this camera
	var/in_use_lights = 0

	// Upgrades bitflag
	var/upgrades = 0

	var/internal_light = TRUE //Whether it can light up when an AI views it

	/// A copy of the last paper object that was shown to this camera.
	var/obj/item/paper/last_shown_paper

	///Represents a signel source of camera alarms about movement or camera tampering
	var/datum/alarm_handler/alarm_manager
	///Proximity monitor associated with this atom, for motion sensitive cameras.
	var/datum/proximity_monitor/proximity_monitor

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera/emp_proof, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera/motion, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera/xray, 0)

/datum/armor/machinery_camera
	melee = 50
	bullet = 20
	laser = 20
	energy = 20
	fire = 90
	acid = 50

/obj/machinery/camera/preset/toxins //Bomb test site in space
	name = "Hardened Bomb-Test Camera"
	desc = "A specially-reinforced camera with a long lasting battery, used to monitor the bomb testing site. An external light is attached to the top."
	c_tag = "Bomb Testing Site"
	network = list(CAMERA_NETWORK_RESEARCH, CAMERA_NETWORK_TOXINS_TEST)
	use_power = NO_POWER_USE //Test site is an unpowered area
	invuln = TRUE
	light_range = 10
	start_active = TRUE

/obj/machinery/camera/preset/theathre
	name = "Stage Camera"
	desc = "A camera used to watch the play on the scene."
	network = list(CAMERA_NETWORK_THEATHRE)

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/camera)

/obj/machinery/camera/Initialize(mapload, obj/structure/camera_assembly/CA)
	. = ..()
	var/static/list/autonames_in_areas = list()

	// Calculate area code
	var/area/camera_area = get_area(src)
	if (istype(camera_area, /area/space))
		var/turf/connected_wall = get_step(src, dir)
		camera_area = get_area(connected_wall)

	// Calculate the camera tag
	if (!c_tag)
		c_tag = "[format_text(camera_area.name)] #[++autonames_in_areas[camera_area]]"
		if (get_area(src) != camera_area)
			c_tag = "[c_tag] (External)"
	if (!islist(network))
		if (camera_area.camera_networks)
			network = camera_area.camera_networks
		else if (is_station_level(z))
			network = list(CAMERA_NETWORK_STATION)
	var/obj/structure/camera_assembly/assembly
	if(CA)
		assembly = CA
		if(assembly.malf_xray_firmware_present) //if it was secretly upgraded via the MALF AI Upgrade Camera Network ability
			upgradeXRay(TRUE)

		if(assembly.emp_module)
			upgradeEmpProof()
		else if(assembly.malf_xray_firmware_present) //if it was secretly upgraded via the MALF AI Upgrade Camera Network ability
			upgradeEmpProof(TRUE)

		if(assembly.proxy_module)
			upgradeMotion()
	else
		assembly = new(src)
		assembly.state = 4 //STATE_FINISHED
	assembly_ref = WEAKREF(assembly)
	GLOB.cameranet.cameras += src
	GLOB.cameranet.addCamera(src)
	if (isturf(loc))
		myarea = get_area(src)
		LAZYADD(myarea.cameras, src)

	if(mapload && is_station_level(z) && prob(3) && !start_active)
		toggle_cam()
	else //this is handled by toggle_camera, so no need to update it twice.
		update_appearance()

	alarm_manager = new(src)

	AddComponent(/datum/component/jam_receiver, JAMMER_PROTECTION_CAMERAS)
	RegisterSignal(src, COMSIG_ATOM_JAMMED, PROC_REF(update_jammed))
	RegisterSignal(src, COMSIG_ATOM_UNJAMMED, PROC_REF(update_jammed))

/obj/machinery/camera/proc/update_jammed(datum/source)
	SIGNAL_HANDLER
	update_camera(null, FALSE)

/obj/machinery/camera/proc/create_prox_monitor()
	if(!proximity_monitor)
		proximity_monitor = new(src, 1)

/obj/machinery/camera/proc/set_area_motion(area/A)
	area_motion = A
	create_prox_monitor()

/obj/machinery/camera/Destroy()
	if(current_state)
		toggle_cam(null, 0) //kick anyone viewing out and remove from the camera chunks
	GLOB.cameranet.removeCamera(src)
	GLOB.cameranet.cameras -= src
	if(isarea(myarea))
		LAZYREMOVE(myarea.cameras, src)
	QDEL_NULL(alarm_manager)
	QDEL_NULL(assembly_ref)
	if(bug)
		bug.bugged_cameras -= c_tag
		if(bug.current == src)
			bug.current = null
		bug = null

	QDEL_NULL(last_shown_paper)
	return ..()

/obj/machinery/camera/examine(mob/user)
	. += ..()
	if(isEmpProof(TRUE)) //don't reveal it's upgraded if was done via MALF AI Upgrade Camera Network ability
		. += "It has electromagnetic interference shielding installed."
	else
		. += span_info("It can be shielded against electromagnetic interference with some <b>plasma</b>.")
	if(isMotion())
		. += "It has a proximity sensor installed."
	else
		. += span_info("It can be upgraded with a <b>proximity sensor</b>.")

	if(!status)
		. += span_info("It's currently deactivated.")
		if(!panel_open && powered())
			. += span_notice("You'll need to open its maintenance panel with a <b>screwdriver</b> to turn it back on.")
	if(panel_open)
		. += span_info("Its maintenance panel is currently open.")
		if(!status && powered())
			. += span_info("It can reactivated with a <b>wirecutters</b>.")

/obj/machinery/camera/vv_edit_var(vname, vval)
	// Can't mess with these since they are references
	if (vname == NAMEOF(src, network))
		return FALSE
	return ..()

/obj/machinery/camera/emp_act(severity)
	. = ..()
	if(!status)
		return
	if(!(. & EMP_PROTECT_SELF))
		if(prob(150/severity))
			update_appearance()
			previous_network = network
			network = list()
			GLOB.cameranet.removeCamera(src)
			set_light(0)
			emped = emped+1  //Increase the number of consecutive EMP's
			update_appearance()
			thisemp = emped //Take note of which EMP this proc is for
			for(var/i in GLOB.player_list)
				var/mob/M = i
				if (M.client.eye == src)
					M.unset_machine()
					M.reset_perspective(null)
					to_chat(M, "The screen bursts into static.")

/obj/machinery/camera/emp_reset()
	..()
	if(emped == thisemp) //Only fix it if the camera hasn't been EMP'd again
		network = previous_network
		update_appearance()
		if(can_use())
			GLOB.cameranet.addCamera(src)
		emped = 0 //Resets the consecutive EMP count

/obj/machinery/camera/ex_act(severity, target)
	if(invuln)
		return
	..()

/obj/machinery/camera/proc/setViewRange(num = 7)
	src.view_range = num
	GLOB.cameranet.updateVisibility(src, 0)

/obj/machinery/camera/proc/shock(mob/living/user)
	if(!istype(user))
		return
	user.electrocute_act(10, src)

/obj/machinery/camera/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	if (status && current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects and the camera is still active, turn off the camera as it gets ripped off the wall.
		toggle_cam(null, 0)
	..()

// Construction/Deconstruction
/obj/machinery/camera/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	panel_open = !panel_open
	to_chat(user, span_notice("You screw the camera's panel [panel_open ? "open" : "closed"]."))
	I.play_tool_sound(src)
	update_appearance()
	return TRUE

/obj/machinery/camera/wirecutter_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return FALSE
	toggle_cam(user, 1)
	atom_integrity = max_integrity //this is a pretty simplistic way to heal the camera, but there's no reason for this to be complex.
	I.play_tool_sound(src)
	return TRUE

/obj/machinery/camera/multitool_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return FALSE

	setViewRange((view_range == initial(view_range)) ? short_range : initial(view_range))
	to_chat(user, span_notice("You [(view_range == initial(view_range)) ? "restore" : "mess up"] the camera's focus."))
	return TRUE

/obj/machinery/camera/welder_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return FALSE

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	to_chat(user, span_notice("You start to weld [src]..."))
	if(I.use_tool(src, user, 100, volume=50))
		user.visible_message(span_warning("[user] unwelds [src], leaving it as just a frame bolted to the wall."),
			span_warning("You unweld [src], leaving it as just a frame bolted to the wall."))
		deconstruct(TRUE)

	return TRUE

/obj/machinery/camera/attackby(obj/item/attacking_item, mob/living/user, params)
	// UPGRADES
	if(panel_open)
		var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
		if(!assembly)
			assembly_ref = null

		if(istype(attacking_item, /obj/item/stack/sheet/mineral/plasma))
			if(!isEmpProof(TRUE)) //don't reveal it was already upgraded if was done via MALF AI Upgrade Camera Network ability
				if(attacking_item.use_tool(src, user, 0, amount=1))
					upgradeEmpProof(FALSE, TRUE)
					to_chat(user, span_notice("You attach [attacking_item] into [assembly]'s inner circuits."))
			else
				to_chat(user, span_notice("[src] already has that upgrade!"))
			return

		else if(istype(attacking_item, /obj/item/assembly/prox_sensor))
			if(!isMotion())
				if(!user.temporarilyRemoveItemFromInventory(attacking_item))
					return
				upgradeMotion()
				to_chat(user, span_notice("You attach [attacking_item] into [assembly]'s inner circuits."))
				qdel(attacking_item)
			else
				to_chat(user, span_notice("[src] already has that upgrade!"))
			return

	// OTHER
	if(istype(attacking_item, /obj/item/modular_computer/tablet) && isliving(user))
		var/itemname = ""
		var/info = ""
		var/obj/item/modular_computer/tablet/computer = attacking_item
		itemname = computer.name
		info = computer.note

		itemname = sanitize(itemname)
		to_chat(user, span_notice("You hold \the [itemname] up to the camera..."))
		user.log_talk(itemname, LOG_GAME, log_globally=TRUE, tag="Pressed to camera")
		user.changeNext_move(CLICK_CD_MELEE)

		for(var/mob/O in GLOB.player_list)
			if(isAI(O))
				var/mob/living/silicon/ai/AI = O
				if(AI.control_disabled || (AI.stat == DEAD))
					return

				AI.last_tablet_note_seen = HTML_SKELETON_TITLE(itemname, "<tt>[info]</tt>")

				if(user.name == "Unknown")
					to_chat(AI, "<b>[user]</b> holds <a href='byond://?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				else
					to_chat(AI, "<b><a href='byond://?src=[REF(AI)];track=[html_encode(user.name)]'>[user]</a></b> holds <a href='byond://?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				continue

			if (O.client?.eye == src)
				to_chat(O, "[user] holds \a [itemname] up to one of the cameras ...")
				O << browse(HTML_SKELETON_TITLE(itemname, "<tt>[info]</tt>"), "window=[itemname]")
		return

	if(istype(attacking_item, /obj/item/paper))
		// Grab the paper, sanitise the name as we're about to just throw it into chat wrapped in HTML tags.
		var/obj/item/paper/paper = attacking_item

		// Make a complete copy of the paper, store a ref to it locally on the camera.
		last_shown_paper = paper.copy(paper.type, null)

		// Then sanitise the name because we're putting it directly in chat later.
		var/item_name = sanitize(last_shown_paper.name)

		// Start the process of holding it up to the camera.
		to_chat(user, span_notice("You hold \the [item_name] up to the camera..."))
		user.log_talk(item_name, LOG_GAME, log_globally=TRUE, tag="Pressed to camera")
		user.changeNext_move(CLICK_CD_MELEE)

		// And make a weakref we can throw around to all potential viewers.
		last_shown_paper.camera_holder = WEAKREF(src)

		// Iterate over all living mobs and check if anyone is elibile to view the paper.
		// This is backwards, but cameras don't store a list of people that are looking through them,
		// and we'll have to iterate this list anyway so we can use it to pull out AIs too.
		for(var/mob/potential_viewer in GLOB.player_list)
			// All AIs view through cameras, so we need to check them regardless.
			if(isAI(potential_viewer))
				var/mob/living/silicon/ai/ai = potential_viewer
				if(ai.control_disabled || (ai.stat == DEAD))
					continue

				log_paper("[key_name(user)] held [last_shown_paper] up to [src], requesting [key_name(ai)] read it.")

				if(user.name == "Unknown")
					to_chat(ai, "[span_name(user)] holds <a href='byond://?_src_=usr;show_paper_note=[REF(last_shown_paper)];'>\a [item_name]</a> up to one of your cameras ...")
				else
					to_chat(ai, "<b><a href='byond://?src=[REF(ai)];track=[html_encode(user.name)]'>[user]</a></b> holds <a href='byond://?_src_=usr;show_paper_note=[REF(last_shown_paper)];'>\a [item_name]</a> up to one of your cameras ...")
				continue

			// If it's not an AI, eye if the client's eye is set to the camera. I wonder if this even works anymore with tgui camera apps and stuff?
			if (potential_viewer.client?.eye == src)
				log_paper("[key_name(user)] held [last_shown_paper] up to [src], and [key_name(potential_viewer)] may read it.")
				to_chat(potential_viewer, "[span_name(user)] holds <a href='byond://?_src_=usr;show_paper_note=[REF(last_shown_paper)];'>\a [item_name]</a> up to your camera...")
		return

	else if(istype(attacking_item, /obj/item/camera_bug))
		if(!can_use())
			to_chat(user, span_notice("Camera non-functional."))
			return
		if(bug)
			to_chat(user, span_notice("Camera bug removed."))
			bug.bugged_cameras -= src.c_tag
			bug = null
		else
			to_chat(user, span_notice("Camera bugged."))
			bug = attacking_item
			bug.bugged_cameras[src.c_tag] = WEAKREF(src)
		return

	return ..()

/obj/machinery/camera/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(machine_stat & BROKEN)
		return damage_amount
	. = ..()

/obj/machinery/camera/atom_break(damage_flag)
	if(!status)
		return
	. = ..()
	if(.)
		toggle_cam(null, 0)

/obj/machinery/camera/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
			if(!assembly)
				assembly = new()
			assembly.forceMove(drop_location())
			assembly.state = 1
			assembly.setDir(dir)
			assembly_ref = null
		else
			var/obj/item/I = new /obj/item/wallframe/camera (loc)
			I.update_integrity(I.max_integrity * 0.5)
			new /obj/item/stack/cable_coil(loc, 2)
	qdel(src)

/obj/machinery/camera/update_icon_state() //TO-DO: Make panel open states, xray camera, and indicator lights overlays instead.
	if(!current_state)
		icon_state = "[default_camera_icon]_off"
	else if (machine_stat & EMPED)
		icon_state = "[default_camera_icon]_emp"
	else
		icon_state = "[default_camera_icon][in_use_lights ? "_in_use" : ""]"
	return ..()

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = TRUE)
	status = !status
	if(status)
		update_use_power(IDLE_POWER_USE)
	else
		update_use_power(ACTIVE_POWER_USE)
	update_camera(user, displaymessage)

/obj/machinery/camera/proc/update_camera(mob/user, displaymessage = TRUE)
	if(can_use())
		if (current_state)
			return
		current_state = TRUE
		GLOB.cameranet.addCamera(src)
		if (isturf(loc))
			myarea = get_area(src)
			LAZYADD(myarea.cameras, src)
		else
			myarea = null
	else
		if (!current_state)
			return
		current_state = FALSE
		set_light(0)
		GLOB.cameranet.removeCamera(src)
		if (isarea(myarea))
			LAZYREMOVE(myarea.cameras, src)
	GLOB.cameranet.updateChunk(x, y, z)
	var/change_msg = "deactivates"
	if(status)
		change_msg = "reactivates"
	if(displaymessage)
		if(user)
			visible_message(span_danger("[user] [change_msg] [src]!"))
			add_hiddenprint(user)
		else
			visible_message(span_danger("\The [src] [change_msg]!"))

		playsound(src, 'sound/items/wirecutter.ogg', 100, TRUE)
	update_appearance() //update Initialize() if you remove this.

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in GLOB.player_list)
		if (O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_perspective(null)
			to_chat(O, "The screen bursts into static.")

/obj/machinery/camera/proc/can_use()
	if(!status)
		return FALSE
	if(machine_stat & EMPED)
		return FALSE
	if(is_jammed(JAMMER_PROTECTION_CAMERAS))
		return FALSE
	return TRUE

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = get_hear(view_range, pos)
	return see

/obj/machinery/camera/proc/Togglelight(on=0)
	for(var/mob/living/silicon/ai/A as anything in GLOB.ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		set_light(AI_CAMERA_LUMINOSITY)
	else
		set_light(0)

/obj/machinery/camera/get_remote_view_fullscreens(mob/user)
	if(view_range == short_range) //unfocused
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)

/obj/machinery/camera/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING //can't see ghosts through cameras
	if(isXRay())
		user.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		user.see_in_dark = max(user.see_in_dark, 8)
	else
		user.sight = 0
		user.see_in_dark = 2
	return 1
