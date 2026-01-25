/obj/machinery/door/window
	name = "windoor"
	desc = "A thin door with translucent glass paneling."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	closingLayer = ABOVE_WINDOW_LAYER
	resistance_flags = ACID_PROOF
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR
	var/base_state = "left"
	max_integrity = 150 //If you change this, consider changing ../door/window/brigdoor/ max_integrity at the bottom of this .dm file
	integrity_failure = 0
	armor_type = /datum/armor/door_window
	visible = FALSE
	flags_1 = ON_BORDER_1
	opacity = FALSE
	pass_flags_self = PASSTRANSPARENT
	can_atmos_pass = ATMOS_PASS_PROC
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	z_flags = NONE // reset zblock
	opens_with_door_remote = TRUE
	var/operationdelay = 5
	var/obj/item/electronics/airlock/electronics = null
	var/reinf = 0
	var/shards = 2
	var/rods = 2
	var/cable = 1

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/door/window)


/datum/armor/door_window
	melee = 20
	bullet = 50
	laser = 50
	energy = 50
	bomb = 10
	fire = 70
	acid = 100

/obj/machinery/door/window/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	if(set_dir)
		setDir(set_dir)
	if(req_access?.len)
		icon_state = "[icon_state]"
		base_state = icon_state

	if(unres_sides)
		//remove unres_sides from directions it can't be bumped from
		switch(dir)
			if(NORTH,SOUTH)
				unres_sides &= ~EAST
				unres_sides &= ~WEST
			if(EAST,WEST)
				unres_sides &= ~NORTH
				unres_sides &= ~SOUTH

	src.unres_sides = unres_sides
	update_icon()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/atmos_sensitive)

/obj/machinery/door/window/Destroy()
	set_density(FALSE)
	air_update_turf(1)
	if(atom_integrity == 0)
		playsound(src, "shatter", 70, 1)
	electronics = null
	var/turf/floor = get_turf(src)
	floor.air_update_turf(TRUE, FALSE)
	return ..()

/obj/machinery/door/window/update_icon()
	if(density)
		icon_state = base_state
	else
		icon_state = "[base_state]open"

/obj/machinery/door/window/proc/open_and_close()
	if(!open())
		return
	autoclose = TRUE
	if(check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	if(!density && autoclose) //did someone change state while we slept?
		close()

/obj/machinery/door/window/Bumped(atom/movable/AM)
	if(operating || !density)
		return
	if(!ismob(AM))
		if(ismecha(AM))
			var/obj/vehicle/sealed/mecha/mecha = AM
			for(var/O in mecha.occupants)
				var/mob/living/occupant = O
				if(allowed(occupant))
					open_and_close()
					return
			do_animate("deny")
		return
	if(!SSticker)
		return
	var/mob/M = AM
	if(HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) || ((isdrone(M) || iscyborg(M)) && M.stat != CONSCIOUS))
		return
	bumpopen(M)

/obj/machinery/door/window/bumpopen(mob/user)
	if(operating || !density)
		return
	add_fingerprint(user)
	// Cutting WIRE_IDSCAN disables normal entry... or it would, if we could hack windowdoors.
	if(!id_scan_hacked() && allowed(user))
		open_and_close()
	else
		do_animate("deny")
	return

/obj/machinery/door/window/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(border_dir == dir)
		return FALSE

	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/moved_window = mover
		return valid_build_direction(loc, moved_window.dir, is_fulltile = moved_window.fulltile)

	if(istype(mover, /obj/structure/windoor_assembly) || istype(mover, /obj/machinery/door/window))
		return valid_build_direction(loc, mover.dir, is_fulltile = FALSE)

	return TRUE

/obj/machinery/door/window/can_atmos_pass(turf/T, vertical = FALSE)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return TRUE

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return !density || (dir != to_dir) || (check_access_list(pass_info.access) && hasPower() && !pass_info.no_id)

/obj/machinery/door/window/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if(leaving.pass_flags & PASSTRANSPARENT)
		return

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/window/open(forced=FALSE)
	if(operating) //doors can still open when emag-disabled
		return 0

	if(!forced)
		if(!hasPower())
			return 0

	if(forced < 2)
		if(obj_flags & EMAGGED)
			return 0

	if(!operating) //in case of emag
		operating = TRUE

	do_animate("opening")
	playsound(src, 'sound/machines/windowdoor.ogg', 100, TRUE)
	icon_state ="[base_state]open"
	sleep(operationdelay)
	set_density(FALSE)
	air_update_turf(TRUE, FALSE)
	update_freelook_sight()

	if(operating == 1) //emag again
		operating = FALSE

	return 1

/obj/machinery/door/window/close(forced=FALSE)
	if(operating)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return 0
	operating = TRUE
	do_animate("closing")
	playsound(src, 'sound/machines/windowdoor.ogg', 100, 1)
	icon_state = base_state

	set_density(TRUE)
	air_update_turf(TRUE, TRUE)
	update_freelook_sight()
	sleep(operationdelay)

	operating = FALSE
	return 1

/obj/machinery/door/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, 1)


/obj/machinery/door/window/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1) && !disassembled)
		if(shards)
			drop_amount(/obj/item/shard, shards)
		if(rods)
			drop_amount(/obj/item/stack/rods, shards)
		if(cable)
			drop_amount(/obj/item/stack/cable_coil, cable)
	qdel(src)

/obj/machinery/door/window/proc/drop_amount(path, amt)
	if(amt <= 0 || amt > 10) // please no more than 10
		return
	if(!ispath(path, /obj))
		return
	var/turf/T = get_turf(src)
	for(var/i in 1 to amt)
		var/obj/fragment = new path(T)
		transfer_fingerprints_to(fragment)

/obj/machinery/door/window/narsie_act()
	add_atom_colour("#7D1919", FIXED_COLOUR_PRIORITY)

/obj/machinery/door/window/ratvar_act()
	var/obj/machinery/door/window/clockwork/C = new(loc, dir)
	C.name = name
	qdel(src)

/obj/machinery/door/window/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > T0C + (reinf ? 1600 : 800))

/obj/machinery/door/window/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(round(exposed_temperature / 200), BURN, 0, 0)

/obj/machinery/door/window/should_emag(mob/user)
	// Don't allow emag if the door is currently open or moving
	return !operating && density && ..()

/obj/machinery/door/window/on_emag(mob/user)
	..()
	operating = TRUE
	flick("[base_state]spark", src)
	playsound(src, "sparks", 75, 1)
	addtimer(CALLBACK(src, PROC_REF(after_emag)), 6)

/obj/machinery/door/window/proc/after_emag()
	if(QDELETED(src))
		return
	operating = FALSE
	desc += "<BR>[span_warning("Its access panel is smoking slightly.")]"
	open(2)

/obj/machinery/door/window/attackby(obj/item/I, mob/living/user, params)

	if(operating)
		return

	add_fingerprint(user)
	if(!(flags_1&NODECONSTRUCT_1))
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			if(density || operating)
				to_chat(user, span_warning("You need to open the door to access the maintenance panel!"))
				return
			I.play_tool_sound(src)
			panel_open = !panel_open
			to_chat(user, span_notice("You [panel_open ? "open":"close"] the maintenance panel of the [name]."))
			return

		if(I.tool_behaviour == TOOL_CROWBAR)
			if(panel_open && !density && !operating)
				user.visible_message("[user] removes the electronics from the [name].", \
									span_notice("You start to remove electronics from the [name]..."))
				if(I.use_tool(src, user, 40, volume=50))
					if(panel_open && !density && !operating && loc)
						var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(loc)
						switch(base_state)
							if("left")
								WA.facing = "l"
							if("right")
								WA.facing = "r"
							if("leftsecure")
								WA.facing = "l"
								WA.secure = TRUE
							if("rightsecure")
								WA.facing = "r"
								WA.secure = TRUE
						WA.set_anchored(TRUE)
						WA.state= "02"
						WA.setDir(dir)
						WA.update_icon()
						WA.created_name = name

						if(obj_flags & EMAGGED)
							to_chat(user, span_warning("You discard the damaged electronics."))
							qdel(src)
							return

						to_chat(user, span_notice("You remove the airlock electronics."))

						var/obj/item/electronics/airlock/ae
						if(!electronics)
							ae = new/obj/item/electronics/airlock(drop_location())
							if(req_one_access)
								ae.one_access = 1
								ae.accesses = req_one_access
							else
								ae.accesses = req_access
						else
							ae = electronics
							electronics = null
							ae.forceMove(drop_location())

						qdel(src)
				return
	return ..()

/obj/machinery/door/window/interact(mob/user)		//for sillycones
	try_to_activate_door(null, user)

/obj/machinery/door/window/try_to_activate_door(obj/item/I, mob/user)
	if(..())
		autoclose = FALSE

/obj/machinery/door/window/try_to_crowbar(obj/item/acting_object, mob/user, forced = FALSE)
	if(density)
		if(!HAS_TRAIT(acting_object, TRAIT_DOOR_PRYER) && hasPower())
			to_chat(user, span_warning("The windoor's motors resist your efforts to force it!"))
			return
		else if(!hasPower())
			to_chat(user, span_warning("You begin forcing open \the [src], the motors don't resist..."))
			if(!acting_object.use_tool(src, user, 1 SECONDS))
				return
		else
			to_chat(user, span_warning("You begin forcing open \the [src]..."))
			if(!acting_object.use_tool(src, user, 5 SECONDS))
				return
		open(2)
	else
		close(2)

/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_state]opening", src)
		if("closing")
			flick("[base_state]closing", src)
		if("deny")
			flick("[base_state]deny", src)

/obj/machinery/door/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 32)
	return FALSE

/obj/machinery/door/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the windoor."))
			qdel(src)
			return TRUE
	return FALSE

/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = null
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)
	reinf = 1
	explosion_block = 1

/obj/machinery/door/window/brigdoor/security/cell
	name = "cell door"
	desc = "For keeping in criminal scum."
	req_access = list(ACCESS_BRIG)

/obj/machinery/door/window/brigdoor/security/holding
	name = "holding cell door"
	req_one_access = list(ACCESS_SEC_DOORS, ACCESS_LAWYER, ACCESS_BRIGPHYS) //love for the lawyer and Brig Phys

/obj/machinery/door/window/clockwork
	name = "brass windoor"
	desc = "A thin door with translucent brass paneling."
	icon_state = "clockwork"
	base_state = "clockwork"
	shards = 0
	rods = 0
	max_integrity = 50
	armor_type = /datum/armor/window_clockwork
	resistance_flags = FIRE_PROOF | ACID_PROOF
	operationdelay = 10
	var/made_glow = FALSE


/datum/armor/window_clockwork
	bomb = 10
	bio = 100
	fire = 70
	acid = 100

/obj/machinery/door/window/clockwork/deconstruct(disassembled)
	if(!(flags_1 & NODECONSTRUCT_1) && !disassembled)
		drop_amount(/obj/item/clockwork/alloy_shards/medium/gear_bit/large, 2)
	return ..()

/obj/machinery/door/window/clockwork/setDir(direct)
	if(!made_glow)
		var/obj/effect/E = new /obj/effect/temp_visual/ratvar/door/window(get_turf(src))
		E.setDir(direct)
		made_glow = TRUE
	..()

/obj/machinery/door/window/clockwork/Destroy()
	return ..()

/obj/machinery/door/window/clockwork/emp_act(severity)
	if(prob(80/severity))
		open()

/obj/machinery/door/window/clockwork/hasPower()
	return TRUE //yup that's power all right

/obj/machinery/door/window/clockwork/allowed(mob/M)
	if(IS_SERVANT_OF_RATVAR(M))
		return TRUE
	return FALSE

/obj/machinery/door/window/clockwork/narsie_act()
	take_damage(rand(30, 60), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/obj/machinery/door/window/clockwork/ratvar_act()
	return FALSE

/obj/machinery/door/window/clockwork/attackby(obj/item/I, mob/living/user, params)

	if(operating)
		return

	add_fingerprint(user)
	if(!(flags_1&NODECONSTRUCT_1))
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			I.play_tool_sound(src)
			panel_open = !panel_open
			to_chat(user, span_notice("You [panel_open ? "open":"close"] the maintenance panel of the [name]."))
			return

		if(I.tool_behaviour == TOOL_CROWBAR)
			if(panel_open && !density && !operating)
				user.visible_message("[user] begins to deconstruct [name].", \
									span_notice("You start to deconstruct from the [name]..."))
				if(I.use_tool(src, user, 40, volume=50))
					if(panel_open && !density && !operating && loc)
						qdel(src)
				return
	return ..()

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/security/cell/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/security/cell/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/security/cell/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/security/cell/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/security/holding/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/security/holding/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/security/holding/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/security/holding/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/checkpoint
	icon_state = "sec_left"
	base_state = "sec_left"
	layer = ABOVE_MOB_LAYER
	closingLayer = ABOVE_MOB_LAYER
	req_access = list(ACCESS_SEC_DOORS)

/obj/machinery/door/window/checkpoint/northleft
	dir = NORTH

/obj/machinery/door/window/checkpoint/eastleft
	dir = EAST

/obj/machinery/door/window/checkpoint/westleft
	dir = WEST

/obj/machinery/door/window/checkpoint/southleft
	dir = SOUTH

/obj/machinery/door/window/checkpoint/northright
	dir = NORTH
	icon_state = "sec_right"
	base_state = "sec_right"

/obj/machinery/door/window/checkpoint/eastright
	dir = EAST
	icon_state = "sec_right"
	base_state = "sec_right"

/obj/machinery/door/window/checkpoint/westright
	dir = WEST
	icon_state = "sec_right"
	base_state = "sec_right"

/obj/machinery/door/window/checkpoint/southright
	dir = SOUTH
	icon_state = "sec_right"
	base_state = "sec_right"
