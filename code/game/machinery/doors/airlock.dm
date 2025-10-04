/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	hasPower - 1 if the main or backup power are functioning, 0 if not.
	id_scan_hacked - Whether the AI has disabled the ID scanner, or the wire has been cut.
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

/// Overlay cache.  Why isn't this just in /obj/machinery/door/airlock?  Because its used just a
/// tiny bit in door_assembly.dm  Refactored so you don't have to make a null copy of airlock
/// to get to the damn thing
/// Someone, for the love of god, profile this.  Is there a reason to cache mutable_appearance
/// if so, why are we JUST doing the airlocks when we can put this in mutable_appearance.dm for
/// everything
/proc/get_airlock_overlay(icon_state, icon_file)
	var/static/list/airlock_overlays = list()
	var/iconkey = "[icon_state][icon_file]"
	if((!(. = airlock_overlays[iconkey])))
		. = airlock_overlays[iconkey] = mutable_appearance(icon_file, icon_state)
// Before you say this is a bad implmentation, look at what it was before then ask yourself
// "Would this be better with a global var"

// Wires for the airlock are located in the datum folder, inside the wires datum folder.

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	appearance_flags = TILE_BOUND | LONG_GLIDE | PIXEL_SCALE | KEEP_TOGETHER
	max_integrity = 300
	var/normal_integrity = AIRLOCK_INTEGRITY_N
	integrity_failure = 0.25
	damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
	autoclose = TRUE
	explosion_block = 1
	hud_possible = list(DIAG_AIRLOCK_HUD)
	flags_1 = PREVENT_CLICK_UNDER_1 & HTML_USE_INITAL_ICON_1
	var/allow_repaint = TRUE //Set to FALSE if the airlock should not be allowed to be repainted.

	FASTDMM_PROP(\
		pinned_vars = list("req_access_txt", "req_one_access_txt", "name")\
	)

	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN

	///The type of door frame to drop during deconstruction
	var/assemblytype = /obj/structure/door_assembly
	var/security_level = AIRLOCK_SECURITY_NONE //How much are wires secured
	var/wire_security_level = 0	//How difficult the door is to hack
	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = FALSE // if true, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = FALSE
	var/lights = TRUE // bolt lights show by default
	var/aiDisabledIdScanner = FALSE
	var/aiHacking = FALSE
	var/closeOtherId //Cyclelinking for airlocks that aren't on the same x or y coord as the target.
	var/list/obj/machinery/door/airlock/close_others = list()
	var/obj/item/electronics/airlock/electronics
	COOLDOWN_DECLARE(shockCooldown) //Prevents multiple shocks from happening
	var/obj/item/grenade/charge //If applied, will explode the next time the door opens
	var/obj/item/note //Any papers pinned to the airlock
	var/detonated = FALSE
	var/abandoned = FALSE
	///Controls if the door closes quickly or not. FALSE = the door autocloses in 1.5 seconds, TRUE = 8 seconds - see autoclose_in()
	var/normalspeed = TRUE
	var/cut_ai_wire = FALSE
	var/autoname = FALSE
	var/doorOpen = 'sound/machines/airlock.ogg'
	var/doorClose = 'sound/machines/airlockclose.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg' // i'm thinkin' Deni's
	var/boltUp = 'sound/machines/boltsup.ogg'
	var/boltDown = 'sound/machines/boltsdown.ogg'
	var/noPower = 'sound/machines/doorclick.ogg'
	var/previous_airlock = /obj/structure/door_assembly //what airlock assembly mineral plating was applied to
	var/airlock_material //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/note_overlay_file = 'icons/obj/doors/airlocks/station/overlays.dmi' //Used for papers and photos pinned to the airlock

	/// Airlock pump that overrides airlock controlls when set up for cycling
	var/obj/machinery/atmospherics/components/unary/airlock_pump/cycle_pump

	/* Note mask_file needed some change due to the change from 513 to 514(the behavior of alpha filters seems to have changed) thats the reason why the mask
	dmi file for normal airlocks is not 32x32 but 64x64 and for the large airlocks instead of 64x32 its now 96x64 due to the fix to this problem*/
	var/mask_file = 'icons/obj/doors/mask_32x32_doors.dmi' // because filters aren't allowed to have icon_states :(
	var/mask_x = 0
	var/mask_y = 0
	var/anim_parts = "left=-14,0;right=13,0" //format is "airlock_part=open_px,open_py,move_start_time,move_end_time,aperture_angle"
	var/list/part_overlays
	var/panel_attachment = "right"
	var/note_attachment = "left"

	var/cyclelinkeddir = 0
	var/obj/machinery/door/airlock/cyclelinkedairlock
	var/shuttledocked = 0
	var/delayed_close_requested = FALSE // TRUE means the door will automatically close the next time it's opened.

	var/prying_so_hard = FALSE
	///Logging for door electrification.
	var/shockedby
	///How many seconds remain until the door is no longer electrified. -1/MACHINE_ELECTRIFIED_PERMANENT = permanently electrified until someone fixes it.
	var/secondsElectrified = MACHINE_NOT_ELECTRIFIED
	var/protected_door = FALSE // Protects the door against any form of power outage, AI control, screwdrivers and welders.
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	rad_insulation = RAD_MEDIUM_INSULATION

	var/electrification_timing // Set to true while electrified_loop is running, to prevent multiple being started

	network_id = NETWORK_DOOR_AIRLOCKS

/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()

	//Get the area hack difficulty
	if (mapload)
		var/area/A = get_area(src)
		wire_security_level = max(wire_security_level, A.airlock_hack_difficulty)

	wires = set_wires(wire_security_level)
	if(glass)
		airlock_material = "glass"
	if(security_level > AIRLOCK_SECURITY_IRON)
		atom_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
		max_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
	else
		atom_integrity = normal_integrity
		max_integrity = normal_integrity
	if(damage_deflection == AIRLOCK_DAMAGE_DEFLECTION_N && security_level > AIRLOCK_SECURITY_IRON)
		damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_electrified()

	rebuild_parts()

	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, PROC_REF(ntnet_receive))
	RegisterSignal(src, COMSIG_MACHINERY_BROKEN, PROC_REF(on_break))

	// Click on the floor to close airlocks
	var/static/list/connections = list(
		COMSIG_ATOM_ATTACK_HAND = PROC_REF(on_attack_hand)
	)
	AddElement(/datum/element/connect_loc, src, connections)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/airlock/proc/rebuild_parts()
	if(part_overlays)
		vis_contents -= part_overlays
		QDEL_LIST(part_overlays)
	else
		part_overlays = list()
	var/list/parts_desc = params2list(anim_parts)
	var/list/door_time = list()
	for(var/part_id in parts_desc)
		var/obj/effect/overlay/airlock_part/P = new
		P.side_id = part_id
		var/list/open_offset = splittext(parts_desc[part_id], ",")
		P.open_px = text2num(open_offset[1])
		P.open_py = text2num(open_offset[2])
		if(open_offset.len >= 3)
			P.move_start_time = text2num(open_offset[3])
		if(open_offset.len >= 4)
			P.move_end_time = text2num(open_offset[4])
		if(open_offset.len >= 5)
			P.aperture_angle = text2num(open_offset[5])
		vis_contents += P
		part_overlays += P
		P.icon = icon
		P.icon_state = part_id
		P.name = name
		door_time += P.move_end_time
	open_speed = max(door_time) //open_speed is max animation time
	add_filter("mask_filter", 1, list(type="alpha",icon=mask_file,x=mask_x,y=mask_y))

/obj/machinery/door/airlock/proc/update_other_id()
	for(var/obj/machinery/door/airlock/Airlock in GLOB.airlocks)
		if(Airlock.closeOtherId == closeOtherId && Airlock != src)
			if(!(Airlock in close_others))
				close_others += Airlock
			if(!(src in Airlock.close_others))
				Airlock.close_others += src

/obj/machinery/door/airlock/proc/cyclelinkairlock()
	if (cyclelinkedairlock)
		cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if (!cyclelinkeddir)
		return
	var/limit = 15
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/FoundDoor
	do
		T = get_step(T, cyclelinkeddir)
		FoundDoor = locate() in T
		if (FoundDoor && FoundDoor.cyclelinkeddir != get_dir(FoundDoor, src))
			FoundDoor = null
		limit--
	while(!FoundDoor && limit)
	if (!FoundDoor)
		log_mapping("[src] at [AREACOORD(src)] failed to find a valid airlock to cyclelink with!")
		return
	FoundDoor.cyclelinkedairlock = src
	cyclelinkedairlock = FoundDoor

/obj/machinery/door/airlock/vv_edit_var(var_name, vval)
	. = ..()
	switch (var_name)
		if (NAMEOF(src, cyclelinkeddir))
			cyclelinkairlock()
		if (NAMEOF(src, secondsElectrified))
			set_electrified(vval < MACHINE_NOT_ELECTRIFIED ? MACHINE_ELECTRIFIED_PERMANENT : vval) //negative values are bad mkay (unless they're the intended negative value!)

/obj/machinery/door/airlock/check_access_ntnet(datum/netdata/data)
	// Cutting WIRE_IDSCAN grants remote access
	return id_scan_hacked() || ..()

/obj/machinery/door/airlock/proc/ntnet_receive(datum/source, datum/netdata/data)
	// Check if the airlock is powered and can accept control packets.
	if(!hasPower() || !canAIControl())
		return

	//Check radio signal jamming
	if(is_jammed(JAMMER_PROTECTION_WIRELESS))
		return


	// Handle received packet.
	var/command = data.data["data"]
	var/command_value = data.data["data_secondary"]
	switch(command)
		if("open")
			if(command_value == "on" && !density)
				return

			if(command_value == "off" && density)
				return

			if(density)
				INVOKE_ASYNC(src, PROC_REF(open))
			else
				INVOKE_ASYNC(src, PROC_REF(close))

		if("bolt")
			if(command_value == "on" && locked)
				return

			if(command_value == "off" && !locked)
				return

			if(locked)
				unbolt()
			else
				bolt()

		if("emergency")
			if(command_value == "on" && emergency)
				return

			if(command_value == "off" && !emergency)
				return

			emergency = !emergency
			update_appearance()

/obj/machinery/door/airlock/lock()
	bolt()

/obj/machinery/door/airlock/proc/bolt()
	if(locked || protected_door)
		return
	set_bolt(TRUE)
	playsound(src, boltDown, 30, 0, 3)
	audible_message(span_italics("You hear a click from the bottom of the door."), null,  1)
	update_appearance()

/obj/machinery/door/airlock/proc/set_bolt(should_bolt)
	if(locked == should_bolt)
		return
	SEND_SIGNAL(src, COMSIG_AIRLOCK_SET_BOLT, should_bolt)
	ui_update()
	. = locked
	locked = should_bolt

/obj/machinery/door/airlock/unlock()
	unbolt()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	set_bolt(FALSE)
	playsound(src,boltUp,30,0,3)
	audible_message(span_italics("You hear a click from the bottom of the door."), null,  1)
	update_appearance()

/obj/machinery/door/airlock/narsie_act()
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/cult/A
	if(GLOB.narsie)
		var/runed = prob(20)
		if(glass)
			if(runed)
				A = new/obj/machinery/door/airlock/cult/glass(T)
			else
				A = new/obj/machinery/door/airlock/cult/unruned/glass(T)
		else
			if(runed)
				A = new/obj/machinery/door/airlock/cult(T)
			else
				A = new/obj/machinery/door/airlock/cult/unruned(T)
		A.name = name
	else
		A = new /obj/machinery/door/airlock/cult/weak(T)
	qdel(src)

/obj/machinery/door/airlock/ratvar_act() //Airlocks become pinion airlocks that only allow servants
	var/obj/machinery/door/airlock/clockwork/A
	if(glass)
		A = new/obj/machinery/door/airlock/clockwork/glass(get_turf(src))
	else
		A = new/obj/machinery/door/airlock/clockwork(get_turf(src))
	A.name = name
	qdel(src)

/obj/machinery/door/airlock/eminence_act(mob/living/simple_animal/eminence/eminence)
	..()
	to_chat(usr, span_brass("You begin manipulating [src]!"))
	if(do_after(eminence, 20, target=get_turf(eminence)))
		if(welded)
			to_chat(eminence, "The airlock has been welded shut!")
		else if(locked)
			to_chat(eminence, "The door bolts are down!")
		else if(!density)
			close()
		else
			open()

/obj/machinery/door/airlock/Destroy()
	QDEL_NULL(wires)
	if(charge)
		qdel(charge)
		charge = null
	QDEL_NULL(electronics)
	if (cyclelinkedairlock)
		if (cyclelinkedairlock.cyclelinkedairlock == src)
			cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if(close_others) //remove this airlock from the list of every linked airlock
		closeOtherId = null
		for(var/obj/machinery/door/airlock/otherlock as anything in close_others)
			otherlock.close_others -= src
		close_others.Cut()
	qdel(note)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(src)
	return ..()

/obj/machinery/door/airlock/handle_atom_del(atom/A)
	if(A == note)
		note = null
		update_appearance()

/obj/machinery/door/airlock/bumpopen(mob/living/user)
	if(!hasPower())
		return

	if(issilicon(user) || !iscarbon(user))
		return ..()

	if(isElectrified() && shock(user, 100))
		return

	if(SEND_SIGNAL(user, COMSIG_CARBON_BUMPED_AIRLOCK_OPEN, src) & STOP_BUMP)
		return

	return ..()

/obj/machinery/door/airlock/proc/isElectrified()
	return (secondsElectrified != MACHINE_NOT_ELECTRIFIED)

/obj/machinery/door/airlock/proc/canAIControl(mob/user)
	if(protected_door)
		return FALSE
	if(is_jammed(JAMMER_PROTECTION_WIRELESS))
		return FALSE
	return ((aiControlDisabled != 1) && !isAllPowerCut())

/obj/machinery/door/airlock/proc/canAIHack()
	if(protected_door)
		return FALSE
	if(is_jammed(JAMMER_PROTECTION_WIRELESS))
		return FALSE
	return ((aiControlDisabled==1) && (!hackProof) && (!isAllPowerCut()));

/obj/machinery/door/airlock/hasPower()
	if(protected_door)
		return TRUE
	return ((!secondsMainPowerLost || !secondsBackupPowerLost) && !(machine_stat & NOPOWER))

/obj/machinery/door/airlock/id_scan_hacked()
	return wires.is_cut(WIRE_IDSCAN) || aiDisabledIdScanner

/obj/machinery/door/airlock/proc/isAllPowerCut()
	if(protected_door)
		return FALSE
	if((wires.is_cut(WIRE_POWER1) || wires.is_cut(WIRE_POWER2)) && (wires.is_cut(WIRE_BACKUP1) || wires.is_cut(WIRE_BACKUP2)))
		return TRUE

/obj/machinery/door/airlock/proc/regainMainPower()
	if(secondsMainPowerLost > 0)
		secondsMainPowerLost = 0
	update_appearance()

/obj/machinery/door/airlock/proc/handlePowerRestoreLoop()
	var/cont = TRUE
	if(QDELETED(src))
		return
	cont = FALSE
	if(secondsMainPowerLost>0)
		if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
			secondsMainPowerLost -= 1
		cont = TRUE
	if(secondsBackupPowerLost>0)
		if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
			secondsBackupPowerLost -= 1
		cont = TRUE
	if (!cont)
		restorePower()
	else
		addtimer(CALLBACK(src, PROC_REF(handlePowerRestoreLoop)), 1 SECONDS)

/obj/machinery/door/airlock/proc/restorePower()
	spawnPowerRestoreRunning = FALSE
	ui_update()
	update_appearance()

/obj/machinery/door/airlock/proc/loseMainPower(emagged_powerloss)
	if(emagged_powerloss)
		secondsMainPowerLost = 36000 //Ten hours, effectively indefinite - may be reset by power cycling the airlock with a multitool or wirecutters
		secondsBackupPowerLost = 36000
	else
		secondsMainPowerLost = 60
		secondsBackupPowerLost = clamp(10, secondsBackupPowerLost, 60)
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
		handlePowerRestoreLoop()
	update_appearance()

/obj/machinery/door/airlock/proc/loseBackupPower()
	secondsBackupPowerLost = 60
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
		handlePowerRestoreLoop()
	update_appearance()

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(secondsBackupPowerLost > 0)
		secondsBackupPowerLost = 0
	update_appearance()

// shock user with probability prb (if all connections & power are working)
// returns TRUE if shocked, FALSE otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!hasPower())		// unpowered, no shock
		return FALSE
	if(!COOLDOWN_FINISHED(src, shockCooldown))
		return FALSE	//Already shocked someone recently?
	if(!prob(prb))
		return FALSE //you lucked out, no shock for you
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 1, check_range))
		COOLDOWN_START(src, shockCooldown, 1 SECONDS)
		return TRUE
	else
		return FALSE

/obj/machinery/door/airlock/update_icon(updates=ALL, state=0, override=FALSE)
	if(operating && !override)
		return

	if(!state)
		state = density ? AIRLOCK_CLOSED : AIRLOCK_OPEN
	airlock_state = state

	. = ..()

	if(hasPower() && unres_sides)
		set_light(2, 1)
	else
		set_light(0)

/obj/machinery/door/airlock/update_icon_state()
	. = ..()
	switch(airlock_state)
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
			icon_state = ""
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate" //MADNESS

/obj/machinery/door/airlock/proc/set_side_overlays(obj/effect/overlay/airlock_part/base, show_lights = FALSE)
	var/side = base.side_id
	base.icon = icon
	base.cut_overlays()
	if(airlock_material)
		base.add_overlay(get_airlock_overlay("[airlock_material]_[side]", overlays_file))
	else
		base.add_overlay(get_airlock_overlay("fill_[side]", icon))
	if(panel_open && panel_attachment == side)
		if(security_level)
			base.add_overlay(get_airlock_overlay("panel_closed_protected", overlays_file))
		else
			base.add_overlay(get_airlock_overlay("panel_closed", overlays_file))
	if(show_lights && lights && hasPower())
		base.add_overlay(get_airlock_overlay("lights_[side]", overlays_file))

	if(note && note_attachment == side)
		var/notetype = note_type()
		base.add_overlay(get_airlock_overlay(notetype, note_overlay_file))

/obj/machinery/door/airlock/update_overlays()
	. = ..()

	for(var/obj/effect/overlay/airlock_part/part as() in part_overlays)
		set_side_overlays(part, airlock_state == AIRLOCK_CLOSING || airlock_state == AIRLOCK_OPENING)
		if(part.aperture_angle)
			var/matrix/T
			if(airlock_state == AIRLOCK_OPEN || airlock_state == AIRLOCK_OPENING || airlock_state == AIRLOCK_CLOSING)
				T = matrix()
				T.Translate(-part.open_px,-part.open_py)
				T.Turn(part.aperture_angle)
				T.Translate(part.open_px,part.open_py)
			switch(airlock_state)
				if(AIRLOCK_CLOSED, AIRLOCK_DENY, AIRLOCK_EMAG)
					part.transform = matrix()
				if(AIRLOCK_OPEN)
					part.transform = T
				if(AIRLOCK_CLOSING)
					part.transform = T
					animate(part, transform = T, time = open_speed - part.move_end_time, easing =  CIRCULAR_EASING, flags = ANIMATION_LINEAR_TRANSFORM)
					animate(transform = matrix(), time = part.move_end_time - part.move_start_time, easing = CIRCULAR_EASING, flags = ANIMATION_LINEAR_TRANSFORM)
				if(AIRLOCK_OPENING)
					part.transform = matrix()
					animate(part, transform = matrix(), time = part.move_start_time, easing = CIRCULAR_EASING, flags = ANIMATION_LINEAR_TRANSFORM)
					animate(transform = T, time = part.move_end_time - part.move_start_time, easing = CIRCULAR_EASING, flags = ANIMATION_LINEAR_TRANSFORM)
		else
			switch(airlock_state)
				if(AIRLOCK_CLOSED, AIRLOCK_DENY, AIRLOCK_EMAG)
					part.pixel_x = 0
					part.pixel_y = 0
				if(AIRLOCK_OPEN)
					part.pixel_x = part.open_px
					part.pixel_y = part.open_py
				if(AIRLOCK_CLOSING)
					part.pixel_x = part.open_px
					part.pixel_y = part.open_py
					animate(part, pixel_x = part.open_px, pixel_y = part.open_py, time = open_speed - part.move_end_time, easing = CIRCULAR_EASING)
					animate(pixel_x = 0, pixel_y = 0, time = part.move_end_time - part.move_start_time, easing = CIRCULAR_EASING)
				if(AIRLOCK_OPENING)
					part.pixel_x = 0
					part.pixel_y = 0
					animate(part, pixel_x = 0, pixel_y = 0, time = part.move_start_time, easing = CIRCULAR_EASING)
					animate(pixel_x = part.open_px, pixel_y = part.open_py, time = part.move_end_time - part.move_start_time, easing = CIRCULAR_EASING)

	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

	SSvis_overlays.add_vis_overlay(src, overlays_file, "frame", FLOAT_LAYER, FLOAT_PLANE, dir)

	switch(airlock_state)
		if(AIRLOCK_CLOSED)
			if(lights && hasPower())
				if(locked)
					SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_bolts", FLOAT_LAYER, FLOAT_PLANE, dir)
				else if(emergency)
					SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_emergency", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(welded)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "welded", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(atom_integrity < integrity_failure * max_integrity)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_broken", FLOAT_LAYER, FLOAT_PLANE, dir)
			else if(atom_integrity < (0.75 * max_integrity))
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_damaged", FLOAT_LAYER, FLOAT_PLANE, dir)

		if(AIRLOCK_DENY)
			if(!hasPower())
				return
			SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_denied", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(welded)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "welded", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(atom_integrity < integrity_failure * max_integrity)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_broken", FLOAT_LAYER, FLOAT_PLANE, dir)
			else if(atom_integrity < (0.75 * max_integrity))
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_damaged", FLOAT_LAYER, FLOAT_PLANE, dir)

		if(AIRLOCK_EMAG)
			if(welded)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "welded", FLOAT_LAYER, FLOAT_PLANE, dir)
			SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(atom_integrity < integrity_failure * max_integrity)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_broken", FLOAT_LAYER, FLOAT_PLANE, dir)
			else if(atom_integrity < (0.75 * max_integrity))
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_damaged", FLOAT_LAYER, FLOAT_PLANE, dir)
		if(AIRLOCK_CLOSING)
			if(lights && hasPower())
				SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_closing", FLOAT_LAYER, FLOAT_PLANE, dir)

		if(AIRLOCK_OPEN)
			if(atom_integrity < (0.75 * max_integrity))
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_open", FLOAT_LAYER, FLOAT_PLANE, dir)

		if(AIRLOCK_OPENING)
			if(lights && hasPower())
				SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_opening", FLOAT_LAYER, FLOAT_PLANE, dir)
	check_unres()


/obj/machinery/door/airlock/proc/check_unres() //unrestricted sides. This overlay indicates which directions the player can access even without an ID
	if(hasPower() && unres_sides)
		if(unres_sides & NORTH)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_n")
			I.appearance_flags |= KEEP_APART
			I.pixel_y = 32
			. += I
		if(unres_sides & SOUTH)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_s")
			I.appearance_flags |= KEEP_APART
			I.pixel_y = -32
			. += I
		if(unres_sides & EAST)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_e")
			I.appearance_flags |= KEEP_APART
			I.pixel_x = 32
			. += I
		if(unres_sides & WEST)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_w")
			I.appearance_flags |= KEEP_APART
			I.pixel_x = -32
			. += I

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(ALL, AIRLOCK_OPENING)
		if("closing")
			update_icon(ALL, AIRLOCK_CLOSING)
		if("deny")
			if(!machine_stat)
				update_icon(ALL, AIRLOCK_DENY)
				playsound(src,doorDeni,50,0,3)
				addtimer(CALLBACK(src, PROC_REF(finish_close_animation)), AIRLOCK_DENY_ANIMATION_TIME)

/obj/machinery/door/airlock/proc/finish_close_animation()
	if(airlock_state == AIRLOCK_DENY)
		update_icon(ALL, AIRLOCK_CLOSED)

/obj/machinery/door/airlock/examine(mob/user)
	. = ..()
	if(closeOtherId)
		. += span_warning("This airlock cycles on ID: [sanitize(closeOtherId)].")
	else if(cyclelinkedairlock)
		. += span_warning("This airlock cycles with: [cyclelinkedairlock.name].")
	else
		. += span_warning("This airlock does not cycle.")
	if(obj_flags & EMAGGED)
		. += span_warning("Its access panel is smoking slightly.")
	if(charge && panel_open)
		. += span_warning("Something is wired up to the airlock's electronics!")
	if(note)
		if(!in_range(user, src))
			. += "There's a [note.name] pinned to the front. You can't read it from here."
		else
			. += "There's a [note.name] pinned to the front..."
			. += note.examine(user)

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				. += "Its wires are exposed!"
			if(AIRLOCK_SECURITY_IRON)
				. += "Its wires are hidden behind a welded metal cover."
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				. += "There is some shredded plasteel inside."
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				. += "Its wires are behind an inner layer of plasteel."
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				. += "There is some shredded plasteel inside."
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				. += "There is a welded plasteel cover hiding its wires."
			if(AIRLOCK_SECURITY_PLASTEEL)
				. += "There is a protective grille over its panel."
	else if(security_level)
		if(security_level == AIRLOCK_SECURITY_IRON)
			. += "It looks a bit stronger."
		else
			. += "It looks very robust."

	if(issilicon(user) && !(machine_stat & BROKEN))
		. += span_notice("Shift-click [src] to [ density ? "open" : "close"] it.")
		. += span_notice("Ctrl-click [src] to [ locked ? "raise" : "drop"] its bolts.")
		. += span_notice("Alt-click [src] to [ secondsElectrified ? "un-electrify" : "permanently electrify"] it.")
		. += span_notice("Ctrl-Shift-click [src] to [ emergency ? "disable" : "enable"] emergency access.")

/obj/machinery/door/airlock/MouseDrop_T(atom/dropping, mob/user, params)
	. = ..()

	//Adds the component only once. We do it here & not in Initialize() because there are tons of airlocks & we don't want to add to their init times
	LoadComponent(/datum/component/leanable, dropping)

/obj/machinery/door/airlock/attack_silicon(mob/user)
	if(!canAIControl(user))
		if(canAIHack())
			hack(user)
			return
		else
			to_chat(user, span_warning("Airlock AI control has been blocked with a firewall. Unable to hack."))
	if(detonated)
		to_chat(user, span_warning("Unable to interface. Airlock control panel damaged."))
		return
	if(is_jammed(JAMMER_PROTECTION_WIRELESS))
		to_chat(user, span_warning("Unable to interface. Remote communications not responding."))
		return

	ui_interact(user)
	return TRUE

/obj/machinery/door/airlock/proc/hack(mob/user)
	set waitfor = 0
	if(!aiHacking)
		aiHacking = TRUE
		to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
		sleep(50)
		if(canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
		sleep(20)
		to_chat(user, "Attempting to hack into airlock. This may take some time.")
		sleep(200)
		if(canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
		sleep(170)
		if(canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Transfer complete. Forcing airlock to execute program.")
		sleep(50)
		//disable blocked control
		aiControlDisabled = 2
		to_chat(user, "Receiving control information from airlock.")
		sleep(10)
		//bring up airlock dialog
		aiHacking = FALSE
		if(user)
			attack_ai(user)

/obj/machinery/door/airlock/attack_animal(mob/user)
	if(isElectrified() && shock(user, 100))
		return
	return ..()

/obj/machinery/door/airlock/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/door/airlock/proc/on_attack_hand(atom/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, /atom/proc/attack_hand, user, modifiers)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/door/airlock/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!(issilicon(user) || IsAdminGhost(user)))
		if(isElectrified() && shock(user, 100))
			return

	if(ishuman(user) && prob(40) && density)
		var/mob/living/carbon/human/H = user
		if((HAS_TRAIT(H, TRAIT_DUMB)) && Adjacent(user))
			playsound(src, 'sound/effects/bang.ogg', 25, TRUE)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				H.visible_message(span_danger("[user] headbutts the airlock."), \
									span_userdanger("You headbutt the airlock!"))
				H.Paralyze(100)
				H.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
			else
				visible_message(span_danger("[user] headbutts the airlock. Good thing [user.p_theyre()] wearing a helmet."))

/obj/machinery/door/airlock/attempt_wire_interaction(mob/user)
	if(security_level)
		to_chat(user, span_warning("Wires are protected!"))
		return WIRE_INTERACTION_FAIL
	return ..()

/obj/machinery/door/airlock/proc/electrified_loop()
	while (secondsElectrified > MACHINE_NOT_ELECTRIFIED)
		sleep(10)
		if(QDELETED(src))
			return

		if(secondsElectrified <= MACHINE_NOT_ELECTRIFIED) //make sure they weren't unelectrified during the sleep.
			break
		secondsElectrified = max(MACHINE_NOT_ELECTRIFIED, secondsElectrified - 1) //safety to make sure we don't end up permanently electrified during a timed electrification.
	// This is to protect against changing to permanent, mid loop.
	if(secondsElectrified == MACHINE_NOT_ELECTRIFIED)
		set_electrified(MACHINE_NOT_ELECTRIFIED)
	else
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT)
	ui_update()

//This code might be completely unused, but I'm too afraid to touch it.
//That said, commenting it out didn't seem to break anything.
/obj/machinery/door/airlock/Topic(href, href_list, nowindow = 0)
	// If you add an if(..()) check you must first remove the var/nowindow parameter.
	// Otherwise it will runtime with this kind of error: null.Topic()
	if(!nowindow)
		..()
	if(!usr.canUseTopic(src) && !IsAdminGhost(usr))
		return
	add_fingerprint(usr)

	if((in_range(src, usr) && isturf(loc)) && panel_open)
		usr.set_machine(src)

	add_fingerprint(usr)
	if(!nowindow)
		updateUsrDialog()
	else
		updateDialog()

/obj/machinery/door/airlock/screwdriver_act(mob/living/user, obj/item/tool)
	if(panel_open && detonated)
		to_chat(user, span_warning("[src] has no maintenance panel!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	panel_open = !panel_open
	to_chat(user, span_notice("You [panel_open ? "open":"close"] the maintenance panel of the airlock."))
	tool.play_tool_sound(src)
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/airlock/wirecutter_act(mob/living/user, obj/item/tool)
	if(panel_open && security_level == AIRLOCK_SECURITY_PLASTEEL)
		. = TOOL_ACT_TOOLTYPE_SUCCESS  // everything after this shouldn't result in attackby
		if(hasPower() && shock(user, 60)) // Protective grille of wiring is electrified
			return .
		to_chat(user, span_notice("You start cutting through the outer grille."))
		if(!tool.use_tool(src, user, 10, volume=100))
			return .
		if(!panel_open)  // double check it wasn't closed while we were trying to snip
			return .
		user.visible_message(span_notice("[user] cut through [src]'s outer grille."),
							span_notice("You cut through [src]'s outer grille."))
		security_level = AIRLOCK_SECURITY_PLASTEEL_O
		return .
	if(note)
		if(user.CanReach(src))
			user.visible_message(span_notice("[user] cuts down [note] from [src]."), span_notice("You remove [note] from [src]."))
		else //telekinesis
			visible_message(span_notice("[tool] cuts down [note] from [src]."))
		tool.play_tool_sound(src)
		note.forceMove(tool.drop_location())
		note = null
		update_appearance()
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/airlock/crowbar_act(mob/living/user, obj/item/tool)

	if(!panel_open || security_level == AIRLOCK_SECURITY_NONE)
		return ..()

	var/layer_flavor
	var/next_level
	var/starting_level = security_level

	switch(security_level)
		if(AIRLOCK_SECURITY_PLASTEEL_O_S)
			layer_flavor = "outer layer of shielding"
			next_level = AIRLOCK_SECURITY_PLASTEEL_I

		if(AIRLOCK_SECURITY_PLASTEEL_I_S)
			layer_flavor = "inner layer of shielding"
			next_level = AIRLOCK_SECURITY_NONE
		else
			return TOOL_ACT_TOOLTYPE_SUCCESS

	user.visible_message(span_notice("You start prying away [src]'s [layer_flavor]."))
	if(!tool.use_tool(src, user, 40, volume=100))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!panel_open || security_level != starting_level)
		// if the plating's already been broken, don't break it again
		return TOOL_ACT_TOOLTYPE_SUCCESS
	user.visible_message(span_notice("[user] removes [src]'s shielding."),
							span_notice("You remove [src]'s [layer_flavor]."))
	security_level = next_level
	spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
	if(next_level == AIRLOCK_SECURITY_NONE)
		modify_max_integrity(max_integrity / AIRLOCK_INTEGRITY_MULTIPLIER)
		damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
		update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/airlock/welder_act(mob/living/user, obj/item/tool)

	if(!panel_open || security_level == AIRLOCK_SECURITY_NONE)
		return ..()

	var/layer_flavor
	var/next_level
	var/starting_level = security_level

	var/material_to_spawn
	var/amount_to_spawn

	switch(security_level)
		if(AIRLOCK_SECURITY_IRON)
			layer_flavor = "panel's shielding"
			next_level = AIRLOCK_SECURITY_NONE
			material_to_spawn = /obj/item/stack/sheet/iron
			amount_to_spawn = 2
		if(AIRLOCK_SECURITY_PLASTEEL_O)
			layer_flavor = "outer layer of shielding"
			next_level = AIRLOCK_SECURITY_PLASTEEL_O_S
		if(AIRLOCK_SECURITY_PLASTEEL_I)
			layer_flavor = "inner layer of shielding"
			next_level = AIRLOCK_SECURITY_PLASTEEL_I_S
		else
			return TOOL_ACT_TOOLTYPE_SUCCESS

	if(!tool.tool_start_check(user, amount=2))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	to_chat(user, span_notice("You begin cutting the [layer_flavor]..."))

	if(!tool.use_tool(src, user, 4 SECONDS, volume=50, amount=2))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(!panel_open || security_level != starting_level)
		// see if anyone's screwing with us
		return TOOL_ACT_TOOLTYPE_SUCCESS

	user.visible_message(
		span_notice("[user] cuts through [src]'s shielding."),  // passers-by don't get the full picture
		span_notice("You cut through [src]'s [layer_flavor]."),
		span_hear("You hear welding.")
	)

	security_level = next_level

	if(material_to_spawn)
		spawn_atom_to_turf(material_to_spawn, user.loc, amount_to_spawn)

	if(security_level == AIRLOCK_SECURITY_NONE)
		update_appearance()

	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/airlock/proc/try_reinforce(mob/user, obj/item/stack/sheet/material, amt_required, new_security_level)
	if(material.get_amount() < amt_required)
		to_chat(user, span_warning("You need at least [amt_required] sheets of [material] to reinforce [src]."))
		return FALSE
	to_chat(user, span_notice("You start reinforcing [src]."))
	if(!do_after(user, 2 SECONDS, src))
		return FALSE
	if(!panel_open || !material.use(amt_required))
		return FALSE
	user.visible_message(span_notice("[user] reinforces [src] with [material]."),
						span_notice("You reinforce [src] with [material]."))
	security_level = new_security_level
	update_appearance()
	return TRUE

/obj/machinery/door/airlock/attackby(obj/item/C, mob/living/user, params)
	if(!issilicon(user) && !IsAdminGhost(user))
		if(isElectrified() && C?.siemens_coefficient && shock(user, 75))
			return
	add_fingerprint(user)

	if(is_wire_tool(C) && panel_open)
		attempt_wire_interaction(user)
		return
	else if(panel_open && security_level == AIRLOCK_SECURITY_NONE && istype(C, /obj/item/stack/sheet))
		if(istype(C, /obj/item/stack/sheet/iron))
			return try_reinforce(user, C, 2, AIRLOCK_SECURITY_IRON)

		else if(istype(C, /obj/item/stack/sheet/plasteel))
			if(!try_reinforce(user, C, 2, AIRLOCK_SECURITY_PLASTEEL))
				return FALSE
			modify_max_integrity(max_integrity * AIRLOCK_INTEGRITY_MULTIPLIER)
			damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
			update_appearance()
			return TRUE

	else if(istype(C, /obj/item/pai_cable))
		var/obj/item/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/airlock_painter))
		change_paintjob(C, user)
	else if(istype(C, /obj/item/grenade))
		if(!panel_open || security_level)
			to_chat(user, span_warning("The maintenance panel must be open to apply [C]!"))
			return
		if(charge && !detonated)
			to_chat(user, span_warning("There's already a charge hooked up to this door!"))
			return
		if(detonated)
			to_chat(user, span_warning("The maintenance panel is destroyed!"))
			return
		to_chat(user, span_warning("You apply [C]. Next time someone opens the door, it will explode."))
		panel_open = FALSE
		update_appearance()
		user.transferItemToLoc(C, src, TRUE)
		charge = C
		return
	else if(istype(C, /obj/item/paper) || istype(C, /obj/item/photo))
		if(note)
			to_chat(user, span_warning("There's already something pinned to this airlock! Use wirecutters to remove it."))
			return
		if(!user.transferItemToLoc(C, src))
			to_chat(user, span_warning("For some reason, you can't attach [C]!"))
			return
		user.visible_message(span_notice("[user] pins [C] to [src]."), span_notice("You pin [C] to [src]."))
		note = C
		update_appearance()
	else
		return ..()

/obj/machinery/door/airlock/try_to_weld(obj/item/weldingtool/W, mob/living/user)
	if(!operating && density)

		if(atom_integrity < max_integrity)
			if(protected_door || !W.tool_start_check(user, amount=0))
				return
			user.visible_message(span_notice("[user] begins welding the airlock."), \
							span_notice("You begin repairing the airlock..."), \
							span_hear("You hear welding."))
			if(W.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, PROC_REF(weld_checks), W, user)))
				atom_integrity = max_integrity
				set_machine_stat(machine_stat & ~BROKEN)
				user.visible_message(span_notice("[user] finishes welding [src]."), \
									span_notice("You finish repairing the airlock."))
				update_appearance()
		else
			to_chat(user, span_notice("The airlock doesn't need repairing."))

/obj/machinery/door/airlock/try_to_weld_secondary(obj/item/weldingtool/tool, mob/user)
	if(!tool.tool_start_check(user, amount=0))
		return
	user.visible_message(span_notice("[user] begins [welded ? "unwelding":"welding"] the airlock."), \
		span_notice("You begin [welded ? "unwelding":"welding"] the airlock..."), \
		span_hear("You hear welding."))
	if(!tool.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, PROC_REF(weld_checks), tool, user)))
		return
	welded = !welded
	user.visible_message(span_notice("[user] [welded? "welds shut":"unwelds"] [src]."), \
		span_notice("You [welded ? "weld the airlock shut":"unweld the airlock"]."))
	log_combat(user, tool, "[key_name(user)] [welded ? "welded":"unwelded"] airlock [src] with [tool] at [AREACOORD(src)]", important = FALSE)
	update_appearance()

/obj/machinery/door/airlock/proc/weld_checks(obj/item/weldingtool/W, mob/user)
	return !operating && density

/// Returns if a crowbar would remove the airlock electronics
/obj/machinery/door/airlock/proc/should_try_removing_electronics()
	if (security_level != 0)
		return FALSE

	if (!panel_open)
		return FALSE

	if (!density)
		return FALSE

	if (!welded)
		return FALSE

	if (hasPower())
		return FALSE

	if (locked)
		return FALSE

	return TRUE

/obj/machinery/door/airlock/try_to_crowbar(obj/item/I, mob/living/user, forced = FALSE)
	//Airlock Charges
	if(panel_open && charge)
		to_chat(user, span_notice("You carefully start removing [charge] from [src]..."))
		if(!I.use_tool(src, user, 150, volume=50))
			to_chat(user, span_warning("You slip and [charge] detonates!"))
			charge.forceMove(user.loc)
			charge.prime()
			return
		user.visible_message(span_notice("[user] removes [charge] from [src]."), \
							span_notice("You gently pry out [charge] from [src] and unhook its wires."))
		charge.forceMove(get_turf(user))
		charge = null
		return
	//End Airlock Charges
	if(I?.tool_behaviour == TOOL_CROWBAR && should_try_removing_electronics() && !operating)
		user.visible_message("[user] removes the electronics from the airlock assembly.", \
			span_notice("You start to remove electronics from the airlock assembly..."))
		if(I.use_tool(src, user, 40, volume=100))
			deconstruct(TRUE, user)
			return TRUE
	if(locked)
		to_chat(user, span_warning("The airlock's bolts prevent it from being forced!"))
		return
	if(welded)
		to_chat(user, span_warning("It's welded, it won't budge!"))
		return
	if(hasPower())
		if(forced)
			var/check_electrified = isElectrified() //setting this so we can check if the mob got shocked during the do_after below
			if(check_electrified && shock(user,100))
				return //it's like sticking a fork in a power socket

			if(!density)//already open
				return

			if(!prying_so_hard)
				var/time_to_open = 50
				playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE) //is it aliens or just the CE being a dick?
				prying_so_hard = TRUE
				if(do_after(user, time_to_open, src))
					if(check_electrified && shock(user,100))
						prying_so_hard = FALSE
						return
					open(2)
					if(density && !open(2))
						to_chat(user, span_warning("Despite your attempts, [src] refuses to open."))
				prying_so_hard = FALSE
				return
		to_chat(user, span_warning("The airlock's motors resist your efforts to force it!"))
		return

	if(!operating)
		if(istype(I, /obj/item/fireaxe) && !HAS_TRAIT(I, TRAIT_WIELDED)) //being fireaxe'd
			to_chat(user, span_warning("You need to be wielding the fire axe to do that!"))
			return
		INVOKE_ASYNC(src, (density ? PROC_REF(open) : PROC_REF(close)), 2)

/obj/machinery/door/airlock/open(forced = FALSE)
	if(cycle_pump && !operating && !welded && locked && density)
		cycle_pump.airlock_act(src)
		return FALSE // The rest will be handled by the pump

	if( operating || welded || locked )
		return FALSE

	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_OPEN))
			return FALSE
	if(charge && !detonated)
		panel_open = TRUE
		update_icon(state=AIRLOCK_OPENING)
		visible_message(span_warning("[src]'s panel flies open!"))
		charge.forceMove(drop_location())
		addtimer(CALLBACK(charge, TYPE_PROC_REF(/obj/item/grenade, prime)), 3)
		detonated = 1
		charge = null
	if(forced < 2)
		if(!protected_door)
			use_power(50)
		playsound(src, doorOpen, 30, 1)
	else
		playsound(src, 'sound/machines/airlockforced.ogg', 30, TRUE)

	if(!density)
		return TRUE

	if(autoclose)
		autoclose_in(normalspeed ? 150 : 15)

	if(close_others)
		for(var/obj/machinery/door/airlock/otherlock as anything in close_others)
			if(!shuttledocked && !emergency && !otherlock.shuttledocked && !otherlock.emergency)
				if(otherlock.operating)
					otherlock.delayed_close_requested = TRUE
				else
					addtimer(CALLBACK(otherlock, PROC_REF(close)), 2)

	if(cyclelinkedairlock)
		if(!shuttledocked && !emergency && !cyclelinkedairlock.shuttledocked && !cyclelinkedairlock.emergency)
			if(cyclelinkedairlock.operating)
				cyclelinkedairlock.delayed_close_requested = TRUE
			else
				addtimer(CALLBACK(cyclelinkedairlock, PROC_REF(close)), 2)

	ui_update()

	SEND_SIGNAL(src, COMSIG_AIRLOCK_OPEN, forced)
	operating = TRUE
	update_icon(ALL, AIRLOCK_OPENING, TRUE)
	sleep(1)
	set_opacity(0)
	update_freelook_sight()
	sleep(open_speed - 1)
	density = FALSE
	z_flags &= ~(Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP)
	air_update_turf(TRUE, FALSE)
	sleep(1)
	layer = OPEN_DOOR_LAYER
	update_icon(ALL, AIRLOCK_OPEN, TRUE)
	operating = FALSE
	ui_update()
	if(delayed_close_requested)
		delayed_close_requested = FALSE
		addtimer(CALLBACK(src, PROC_REF(close)), 1)
	return TRUE


/obj/machinery/door/airlock/close(forced=0)
	if(operating || welded || locked)
		return
	if(density)
		return TRUE
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_BOLTS))
			return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && !(M.flags_1 & ON_BORDER_1) && M != src) //something is blocking the door
				autoclose_in(60)
				return

	if(forced < 2)
		if(!protected_door)
			use_power(50)
		playsound(src, doorClose, 30, TRUE)
	else
		playsound(src, 'sound/machines/airlockforced.ogg', 30, TRUE)

	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		SSexplosions.med_mov_atom += killthis

	SEND_SIGNAL(src, COMSIG_AIRLOCK_CLOSE, forced)
	ui_update()
	operating = TRUE
	update_icon(ALL, AIRLOCK_CLOSING, TRUE)
	layer = CLOSED_DOOR_LAYER
	if(air_tight)
		set_density(TRUE)
		z_flags |= (Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP)
		air_update_turf(TRUE, TRUE)
	sleep(1)
	if(!air_tight)
		set_density(TRUE)
		z_flags |= (Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP)
		air_update_turf(TRUE, TRUE)
	sleep(open_speed - 1)
	if(!safe)
		crush()
	if(visible && !glass)
		set_opacity(1)
	update_freelook_sight()
	sleep(1)
	update_icon(ALL, AIRLOCK_CLOSED, TRUE)
	operating = FALSE
	delayed_close_requested = FALSE
	ui_update()
	if(safe)
		CheckForMobs()
	ui_update()
	return TRUE

/obj/machinery/door/airlock/proc/prison_open()
	locked = FALSE
	open()
	locked = TRUE
	return


/obj/machinery/door/airlock/proc/change_paintjob(obj/item/airlock_painter/painter, mob/user)
	if(!allow_repaint)
		to_chat(user, span_warning("The airlock painter does not support this airlock."))
		return

	if((!in_range(src, user) && loc != user) || !painter.can_use(user)) // user should be adjacent to the airlock, and the painter should have a toner cartridge that isn't empty
		return

	// reads from the airlock painter's `available paintjob` list. lets the player choose a paint option, or cancel painting
	var/current_paintjob = input(user, "Please select a paintjob for this airlock.") as null|anything in sort_list(painter.available_paint_jobs)
	if(!current_paintjob) // if the user clicked cancel on the popup, return
		return

	var/airlock_type = painter.available_paint_jobs["[current_paintjob]"] // get the airlock type path associated with the airlock name the user just chose
	var/obj/machinery/door/airlock/airlock = airlock_type // we need to create a new typed variable of the airlock and assembly to read initial values from them
	var/obj/structure/door_assembly/assembly = initial(airlock.assemblytype)
	if(airlock_material == "glass" && initial(assembly.noglass)) // prevents painting glass airlocks with a paint job that doesn't have a glass version, such as the freezer
		to_chat(user, span_warning("This paint job can only be applied to non-glass airlocks."))
		return
	// applies the user-chosen airlock's icon, overlays, assemblytype anim_parts, panel_attachement and note_attachment to the src airlock
	painter.use_paint(user)
	icon = initial(airlock.icon)
	overlays_file = initial(airlock.overlays_file)
	note_overlay_file = initial(airlock.note_overlay_file)
	assemblytype = initial(airlock.assemblytype)
	anim_parts = initial(airlock.anim_parts)
	panel_attachment = initial(airlock.panel_attachment)
	note_attachment = initial(airlock.note_attachment)
	rebuild_parts()
	update_appearance()

/obj/machinery/door/airlock/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/passing_atom)
//Airlock is passable if it is open (!density), bot has access, and is not bolted shut or powered off)
	return !density || (check_access(ID) && !locked && hasPower())

///This does not call parent because airlocks should be possible to emag multiple times. We only care that the door is closed, not protected and has power.
/obj/machinery/door/airlock/should_emag(mob/user)
	if(protected_door)
		to_chat(user, span_warning("[src] has no maintenance panel!"))
		return FALSE
	if(!hasPower())
		to_chat(user, span_warning("The cryptographic sequencer connects to \the [src]'s ID scanner, but nothing happens."))
		return FALSE
	// Don't allow emag if the door is currently open or moving
	return !operating && density

/obj/machinery/door/airlock/on_emag(mob/user)
	..()
	operating = TRUE
	update_icon(ALL, AIRLOCK_EMAG, TRUE)
	addtimer(CALLBACK(src, PROC_REF(after_emag)), 6)

/obj/machinery/door/airlock/proc/after_emag()
	if(QDELETED(src))
		return
	operating = FALSE
	if(!open())
		update_icon(ALL, AIRLOCK_CLOSED, TRUE)
	bolt()
	loseMainPower(TRUE)

/obj/machinery/door/airlock/attack_alien(mob/living/carbon/alien/humanoid/user)
	add_fingerprint(user)
	if(isElectrified() && shock(user, 100)) //Mmm, fried xeno!
		add_fingerprint(user)
		return
	if(!density) //Already open
		return ..()
	if(locked || welded) //Extremely generic, as aliens only understand the basics of how airlocks work.
		if(user.combat_mode)
			return ..()
		to_chat(user, span_warning("[src] refuses to budge!"))
		return
	add_fingerprint(user)
	user.visible_message(span_warning("[user] begins prying open [src]."),\
						span_noticealien("You begin digging your claws into [src] with all your might!"),\
						span_warning("You hear groaning metal..."))
	var/time_to_open = 5
	if(hasPower())
		time_to_open = 5 SECONDS //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1)


	if(do_after(user, time_to_open, src))
		if(density && !open(2)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			to_chat(user, span_warning("Despite your efforts, [src] managed to resist your attempts to open it!"))

/obj/machinery/door/airlock/hostile_lockdown(mob/origin)
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !machine_stat)
		locked = FALSE //For airlocks that were bolted open.
		safe = FALSE //DOOR CRUSH
		close()
		bolt() //Bolt it!
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT)  //Shock it!
		if(origin)
			LAZYADD(shockedby, "\[[time_stamp()]\] [key_name(origin)]")


/obj/machinery/door/airlock/disable_lockdown()
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !machine_stat)
		unbolt()
		set_electrified(MACHINE_NOT_ELECTRIFIED)
		open()
		safe = TRUE

/obj/machinery/door/airlock/proc/on_break()
	if(!panel_open)
		panel_open = TRUE
	wires.cut_all(null)

/obj/machinery/door/airlock/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(prob(severity*10 - 20) && (secondsElectrified < 30) && (secondsElectrified != MACHINE_ELECTRIFIED_PERMANENT))
		set_electrified(30)
		LAZYADD(shockedby, "\[[time_stamp()]\]EM Pulse")

/obj/machinery/door/airlock/proc/set_electrified(seconds, mob/user)
	secondsElectrified = seconds
	diag_hud_set_electrified()
	ui_update()
	if(secondsElectrified > MACHINE_NOT_ELECTRIFIED)
		INVOKE_ASYNC(src, PROC_REF(electrified_loop))

	if(user)
		var/message
		switch(secondsElectrified)
			if(MACHINE_ELECTRIFIED_PERMANENT)
				message = "permanently shocked"
			if(MACHINE_NOT_ELECTRIFIED)
				message = "unshocked"
			else
				message = "temp shocked for [secondsElectrified] seconds"
		LAZYADD(shockedby, "\[[time_stamp()]\] [key_name(user)] - ([uppertext(message)])")
		log_combat(user, src, message, important = FALSE)
		add_hiddenprint(user)

/obj/machinery/door/airlock/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	if((damage_amount >= atom_integrity) && (damage_flag == BOMB))
		flags_1 |= NODECONSTRUCT_1  //If an explosive took us out, don't drop the assembly
	. = ..()
	if(atom_integrity < (0.75 * max_integrity))
		update_appearance()

/obj/machinery/door/airlock/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/door_assembly/A
		if(assemblytype)
			A = new assemblytype(loc)
		else
			A = new /obj/structure/door_assembly(loc)
			//If you come across a null assemblytype, it will produce the default assembly instead of disintegrating.
		A.heat_proof_finished = heat_proof //tracks whether there's rglass in
		A.set_anchored(TRUE)
		A.glass = glass
		A.state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
		A.created_name = name
		A.previous_assembly = previous_airlock
		A.update_name()
		A.update_appearance()

		if(!disassembled)
			A?.update_integrity(A.max_integrity * 0.5)
		else
			if(user)
				to_chat(user, span_notice("You remove the airlock electronics."))

			var/obj/item/electronics/airlock/ae
			if(!electronics)
				ae = new/obj/item/electronics/airlock(loc)
				gen_access()
				if(req_one_access.len)
					ae.one_access = 1
					ae.accesses = req_one_access
				else
					ae.accesses = req_access
			else
				ae = electronics
				electronics = null
				ae.forceMove(drop_location())
	qdel(src)

/obj/machinery/door/airlock/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			if(security_level != AIRLOCK_SECURITY_NONE)
				to_chat(user, span_notice("[src]'s reinforcement needs to be removed first."))
				return FALSE
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 32)
	return FALSE

/obj/machinery/door/airlock/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(RCD_DECONSTRUCT == passed_mode)
		to_chat(user, span_notice("You deconstruct the airlock."))
		log_attack("[key_name(user)] has deconstructed [src] at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
		qdel(src)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/note_type() //Returns a string representing the type of note pinned to this airlock
	if(!note)
		return
	else if(istype(note, /obj/item/paper))
		return "note"
	else if(istype(note, /obj/item/photo))
		return "photo"


/obj/machinery/door/airlock/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(secondsMainPowerLost || secondsBackupPowerLost || secondsElectrified)
		. = TRUE // Autoupdate while counters are counting down

/obj/machinery/door/airlock/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/door/airlock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiAirlock")
		ui.open()
	return TRUE

/obj/machinery/door/airlock/ui_data()
	var/list/data = list()

	var/list/power = list()
	power["main"] = secondsMainPowerLost ? 0 : 2 // boolean
	power["main_timeleft"] = secondsMainPowerLost
	power["backup"] = secondsBackupPowerLost ? 0 : 2 // boolean
	power["backup_timeleft"] = secondsBackupPowerLost
	data["power"] = power

	data["shock"] = secondsElectrified == MACHINE_NOT_ELECTRIFIED ? 2 : 0
	data["shock_timeleft"] = secondsElectrified
	data["id_scanner"] = !aiDisabledIdScanner
	data["emergency"] = emergency // access
	data["locked"] = locked // bolted
	data["lights"] = lights // bolt lights
	data["safe"] = safe // safeties
	data["speed"] = normalspeed // safe speed
	data["welded"] = welded // welded
	data["opened"] = !density // opened

	var/list/wire = list()
	wire["main_1"] = !wires.is_cut(WIRE_POWER1)
	wire["main_2"] = !wires.is_cut(WIRE_POWER2)
	wire["backup_1"] = !wires.is_cut(WIRE_BACKUP1)
	wire["backup_2"] = !wires.is_cut(WIRE_BACKUP2)
	wire["shock"] = !wires.is_cut(WIRE_SHOCK)
	wire["id_scanner"] = !wires.is_cut(WIRE_IDSCAN)
	wire["bolts"] = !wires.is_cut(WIRE_BOLTS)
	wire["lights"] = !wires.is_cut(WIRE_LIGHT)
	wire["safe"] = !wires.is_cut(WIRE_SAFETY)
	wire["timing"] = !wires.is_cut(WIRE_TIMING)

	data["wires"] = wire
	return data

/obj/machinery/door/airlock/ui_act(action, params)
	if(..())
		return
	if(!user_allowed(usr))
		return
	switch(action)
		if("disrupt-main")
			if(!secondsMainPowerLost)
				loseMainPower()
				update_appearance()
			else
				to_chat(usr, "Main power is already offline.")
			. = TRUE
		if("disrupt-backup")
			if(!secondsBackupPowerLost)
				loseBackupPower()
				update_appearance()
			else
				to_chat(usr, "Backup power is already offline.")
			. = TRUE
		if("shock-restore")
			shock_restore(usr)
			. = TRUE
		if("shock-temp")
			shock_temp(usr)
			. = TRUE
		if("shock-perm")
			shock_perm(usr)
			. = TRUE
		if("idscan-toggle")
			aiDisabledIdScanner = !aiDisabledIdScanner
			. = TRUE
		if("emergency-toggle")
			toggle_emergency(usr)
			. = TRUE
		if("bolt-toggle")
			toggle_bolt(usr)
			. = TRUE
		if("light-toggle")
			lights = !lights
			update_appearance()
			. = TRUE
		if("safe-toggle")
			safe = !safe
			. = TRUE
		if("speed-toggle")
			normalspeed = !normalspeed
			. = TRUE
		if("open-close")
			user_toggle_open(usr)
			. = TRUE

/obj/machinery/door/airlock/proc/user_allowed(mob/user)
	return (issilicon(user) && allowed(user) && canAIControl(user)) || IsAdminGhost(user)

/obj/machinery/door/airlock/proc/shock_restore(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "Can't un-electrify the airlock - The electrification wire is cut.")
	else if(isElectrified())
		set_electrified(MACHINE_NOT_ELECTRIFIED, user)

/obj/machinery/door/airlock/proc/shock_temp(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "The electrification wire has been cut")
	else
		set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, user)

/obj/machinery/door/airlock/proc/shock_perm(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "The electrification wire has been cut")
	else
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT, user)

/obj/machinery/door/airlock/proc/toggle_bolt(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_BOLTS))
		to_chat(user, span_warning("The door bolt drop wire is cut - you can't toggle the door bolts."))
		return
	if(locked)
		if(!hasPower())
			to_chat(user, span_warning("The door has no power - you can't raise the door bolts."))
		else
			unbolt()
			log_combat(user, src, "unbolted", important = FALSE)
	else
		bolt()
		log_combat(user, src, "bolted", important = FALSE)
/obj/machinery/door/airlock/proc/toggle_emergency(mob/user)
	if(!user_allowed(user))
		return
	emergency = !emergency
	update_appearance()
	ui_update()

/obj/machinery/door/airlock/proc/user_toggle_open(mob/user)
	if(!user_allowed(user))
		return
	if(welded)
		to_chat(user, "The airlock has been welded shut!")
	else if(locked)
		to_chat(user, "The door bolts are down!")
	else if(!density)
		close()
	else
		open()

/obj/machinery/door/airlock/proc/set_wires(wire_security_level)
	return new /datum/wires/airlock(src, wire_security_level)

/obj/machinery/door/airlock/add_context_self(datum/screentip_context/context, mob/user)
	if (machine_stat & BROKEN)
		return

	//Silicons
	if (context.accept_silicons())
		context.add_left_click_action("Interface with", canAIControl(user))
		context.add_shift_click_action("Open", (lights && locked) ? "Blocked" : null, (!lights || !locked) && canAIControl(user))
		context.add_ctrl_click_action("[locked ? "Raise" : "Drop"] Bolts", "Blocked", canAIControl(user))
		context.add_alt_click_action("[secondsElectrified ? "Un-electrify" : "Electrify"]", "Blocked", canAIControl(user))
		context.add_ctrl_shift_click_action("[emergency ? "Disable" : "Enable"] Emergency Access", "Blocked", canAIControl(user))
	else
		context.add_left_click_action("Open", (lights && locked) ? "Bolted" : null, (!lights || !locked))

	if(!isliving(user))
		return

	//Tools
	context.add_left_click_tool_action("[panel_open ? "Close" : "Open"] Maintenance Panel", TOOL_SCREWDRIVER)
	if (panel_open)
		switch (security_level)
			if (AIRLOCK_SECURITY_IRON, AIRLOCK_SECURITY_PLASTEEL_I, AIRLOCK_SECURITY_PLASTEEL_O)
				context.add_left_click_tool_action("Cut Shielding", TOOL_WELDER)
		context.add_left_click_tool_action("Hack Wires", TOOL_MULTITOOL)
		context.add_left_click_tool_action("Cut Wires", TOOL_WIRECUTTER)
	if (!hasPower())
		context.add_left_click_tool_action("Pry Open", TOOL_CROWBAR)
		return

	context.add_left_click_tool_action("Weld Shut", TOOL_WELDER)
	context.add_left_click_tool_action("Repair", TOOL_WELDER)


	// Handle lazy initalisation of access
	if (length(req_access) || length(req_one_access) || req_access_txt != "0" || req_one_access_txt != "0")
		context.add_access_context("Access Required", allowed(user))

/obj/machinery/door/airlock/proc/set_cycle_pump(obj/machinery/atmospherics/components/unary/airlock_pump/pump)
	RegisterSignal(pump, COMSIG_QDELETING, PROC_REF(unset_cycle_pump))
	cycle_pump = pump

/obj/machinery/door/airlock/proc/unset_cycle_pump()
	SIGNAL_HANDLER
	if(locked)
		unbolt()
		say("Link broken, unbolting.")
	cycle_pump = null

/obj/machinery/door/airlock/on_magic_unlock(datum/source, datum/action/spell/aoe/knock/spell, mob/living/caster)
	// Airlocks should unlock themselves when knock is casted, THEN open up.
	locked = FALSE
	return ..()
