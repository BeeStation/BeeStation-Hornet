///BSA unlocked by head ID swipes
GLOBAL_VAR_INIT(bsa_unlock, FALSE)

// Crew has to build a bluespace cannon
// Cargo orders part for high price
// Requires high amount of power
// Requires high level stock parts
/datum/station_goal/bluespace_cannon
	name = "Bluespace Artillery"

/datum/station_goal/bluespace_cannon/get_report()
	return list(
		"<blockquote>Our military presence is inadequate in your sector.",
		"We need you to construct BSA-[rand(1,99)] Artillery position aboard your station.",
		"",
		"Base parts are available for shipping via cargo.",
		"-Nanotrasen Naval Command</blockquote>",
	).Join("\n")

/datum/station_goal/bluespace_cannon/on_report()
	//Unlock BSA parts
	var/datum/supply_pack/engineering/bsa/P = SSsupply.supply_packs[/datum/supply_pack/engineering/bsa]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_cannon/check_completion()
	if(..())
		return TRUE
	var/obj/machinery/power/bsa/full/B = locate()
	if(B && !B.machine_stat)
		return TRUE
	return FALSE

/obj/machinery/bsa
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	density = TRUE
	anchored = TRUE

/obj/machinery/bsa/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I, 10)
	return TRUE

/obj/machinery/bsa/back
	name = "Bluespace Artillery Generator"
	desc = "Generates cannon pulse. Needs to be linked with a fusor."
	icon_state = "power_box"

REGISTER_BUFFER_HANDLER(/obj/machinery/bsa/back)

DEFINE_BUFFER_HANDLER(/obj/machinery/bsa/back)
	if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, span_notice("You store linkage information in [buffer_parent]'s buffer."))
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/bsa/front
	name = "Bluespace Artillery Bore"
	desc = "Do not stand in front of cannon during operation. Needs to be linked with a fusor."
	icon_state = "emitter_center"

REGISTER_BUFFER_HANDLER(/obj/machinery/bsa/front)

DEFINE_BUFFER_HANDLER(/obj/machinery/bsa/front)
	if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, span_notice("You store linkage information in [buffer_parent]'s buffer."))
	return COMPONENT_BUFFER_RECEIVED

/obj/machinery/bsa/middle
	name = "Bluespace Artillery Fusor"
	desc = "Contents classified by Nanotrasen Naval Command. Needs to be linked with the other BSA parts using multitool."
	icon_state = "fuel_chamber"
	var/datum/weakref/back_ref
	var/datum/weakref/front_ref

REGISTER_BUFFER_HANDLER(/obj/machinery/bsa/middle)

DEFINE_BUFFER_HANDLER(/obj/machinery/bsa/middle)
	if(buffer)
		if(istype(buffer, /obj/machinery/bsa/back))
			back_ref = WEAKREF(buffer)
			to_chat(user, span_notice("You link [src] with [buffer]."))
			FLUSH_BUFFER(buffer_parent)
			to_chat(user, span_notice("You link [src] with [buffer]."))
		else if(istype(buffer, /obj/machinery/bsa/front))
			front_ref = WEAKREF(buffer)
			to_chat(user, span_notice("You link [src] with [buffer]."))
			FLUSH_BUFFER(buffer_parent)
	else
		to_chat(user, span_warning("[buffer_parent]'s data buffer is empty!"))
	return COMPONENT_BUFFER_RECEIVED

/obj/machinery/bsa/middle/proc/check_completion()
	var/obj/machinery/bsa/front/front = front_ref?.resolve()
	var/obj/machinery/bsa/back/back = back_ref?.resolve()
	if(!front || !back)
		return "No linked parts detected!"
	if(!front.anchored || !back.anchored || !anchored)
		return "Linked parts unwrenched!"
	if(front.y != y || back.y != y || !(front.x > x && back.x < x || front.x < x && back.x > x) || front.z != z || back.z != z)
		return "Parts misaligned!"
	if(!has_space())
		return "Not enough free space!"

/obj/machinery/bsa/middle/proc/has_space()
	var/cannon_dir = get_cannon_direction()
	var/x_min
	var/x_max
	switch(cannon_dir)
		if(EAST)
			x_min = x - 4 //replace with defines later
			x_max = x + 6
		if(WEST)
			x_min = x + 4
			x_max = x - 6

	for(var/turf/T in block(locate(x_min,y-1,z),locate(x_max,y+1,z)))
		if(T.density || isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/bsa/middle/proc/get_cannon_direction()
	var/obj/machinery/bsa/front/front = front_ref?.resolve()
	var/obj/machinery/bsa/back/back = back_ref?.resolve()
	if(!front || !back)
		return
	if(front.x > x && back.x < x)
		return EAST
	else if(front.x < x && back.x > x)
		return WEST


/obj/machinery/power/bsa/full
	name = "Bluespace Artillery"
	desc = "Long range bluespace artillery."
	icon = 'icons/obj/lavaland/cannon.dmi'
	icon_state = "cannon_west"
	var/base_battery_icon_state = "bsa_west_capacitor"
	var/static/mutable_appearance/top_layer
	var/ex_power = 3
	var/ready

	var/power_used_per_shot = 20 MEGAWATT
	var/obj/item/stock_parts/cell/cell
	var/obj/machinery/power/terminal/invisible/terminal
	use_power = NO_POWER_USE
	idle_power_usage = 50 // when idle
	active_power_usage = INFINITY // how much you can charge at once
	var/charge_efficiency = 0.6 // 60% of power is stored in the cell

	pixel_y = -32
	pixel_x = -192
	bound_width = 352
	bound_x = -192
	density = TRUE
	appearance_flags = LONG_GLIDE //Removes default TILE_BOUND
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/sound/select_sound = 'sound/machines/bsa/bsa_charge.ogg'
	var/select_sound_length = 17 SECONDS

	var/sound/fire_sound = 'sound/machines/bsa/bsa_fire.ogg'
	var/winding_up = FALSE // if true, sparks will be generated in the bullseye

	var/last_charge_quarter = 0

	var/firing = FALSE



/obj/machinery/power/bsa/full/wrench_act(mob/living/user, obj/item/I)
	return FALSE

/obj/machinery/power/bsa/full/Destroy()
	. = ..()
	QDEL_NULL(cell)
	QDEL_NULL(terminal)

/obj/machinery/power/bsa/full/proc/get_front_turf()
	switch(dir)
		if(WEST)
			return locate(x - 7,y,z)
		if(EAST)
			return locate(x + 4,y,z)
	return get_turf(src)

/obj/machinery/power/bsa/full/proc/get_back_turf()
	switch(dir)
		if(WEST)
			return locate(x + 4,y,z)
		if(EAST)
			return locate(x - 6,y,z)
	return get_turf(src)

/obj/machinery/power/bsa/full/proc/get_target_turf()
	switch(dir)
		if(WEST)
			return locate(1,y,z)
		if(EAST)
			return locate(world.maxx,y,z)
	return get_turf(src)

/obj/machinery/power/bsa/full/proc/make_terminal(turf/T)
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new /obj/machinery/power/terminal/invisible(T)
	terminal.master = src

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/power/bsa/full)

/obj/machinery/power/bsa/full/Initialize(mapload, cannon_direction = WEST)
	. = ..()
	cell = new /obj/item/stock_parts/cell(src, 20 MEGAWATT)
	cell.charge = 0
	top_layer = top_layer || mutable_appearance(icon, layer = ABOVE_MOB_LAYER)
	switch(cannon_direction)
		if(WEST)
			setDir(WEST)
			pixel_x = -192
		if(EAST)
			setDir(EAST)
	update_icon_state()
	make_terminal(get_back_turf())


/obj/machinery/power/bsa/full/update_icon_state()
	. = ..()
	icon_state = "cannon_[dir2text(dir)]"
	base_battery_icon_state = "bsa_[dir2text(dir)]_capacitor"

/obj/machinery/power/bsa/full/update_overlays()
	. = ..()
	cut_overlays()
	add_overlay(top_layer)
	top_layer.icon_state = "top_[dir2text(dir)]"

	var/charge_quarter = FLOOR(cell.percent() / 25, 1)
	var/charge_sound = 'sound/machines/apc/PowerSwitch_Off.ogg'
	if(charge_quarter >= 1)
		add_overlay("[base_battery_icon_state]_25")
	if(charge_quarter >= 2)
		add_overlay("[base_battery_icon_state]_50")
	if(charge_quarter >= 3)
		add_overlay("[base_battery_icon_state]_75")
	if(charge_quarter >= 4)
		add_overlay("[base_battery_icon_state]_100")
		charge_sound = 'sound/machines/apc/PowerUp_001.ogg'
	if(charge_quarter > last_charge_quarter)
		playsound(get_turf(src), charge_sound, 25, TRUE)


/obj/machinery/power/bsa/full/proc/charge_up(mob/user, turf/bullseye)
	if(!cell.use(power_used_per_shot))
		return FALSE
	firing = TRUE
	var/sound/charge_up = sound(select_sound)
	playsound(get_turf(src), charge_up, 10, 1, pressure_affected = FALSE)
	var/timerid = addtimer(CALLBACK(src, PROC_REF(fire), user, bullseye), select_sound_length, TIMER_STOPPABLE)
	winding_up = TRUE
	var/list/turfs = spiral_range_turfs(ex_power * 2, bullseye)
	var/base_cooldown = 2 SECONDS
	var/cooldown = base_cooldown
	while(winding_up)
		if(QDELETED(src))
			break
		new /obj/effect/particle_effect/sparks/shield(pick(turfs))
		cooldown = base_cooldown * ((timeleft(timerid)) / select_sound_length)
		sleep(cooldown)

/obj/machinery/power/bsa/full/proc/fire(mob/user, turf/bullseye)
	winding_up = FALSE
	playsound(get_turf(src), fire_sound, 15, 1, world.maxx, pressure_affected = FALSE, ignore_walls = TRUE)
	// we shake camera of every mob with client on the same zlevel as cannon, explosion itself handles shaking camera on target zlevel
	for(var/mob/M in GLOB.mob_living_list)
		if(!M.client || !compare_z(M.get_virtual_z_level(), get_virtual_z_level()))
			continue
		shake_camera(M, 8, 1)

	var/turf/point = get_front_turf()
	var/turf/target = get_target_turf()
	var/atom/movable/blocker
	for(var/T in get_line(get_step(point, dir), target))
		var/turf/tile = T
		if(SEND_SIGNAL(tile, COMSIG_ATOM_BSA_BEAM) & COMSIG_ATOM_BLOCKS_BSA_BEAM)
			blocker = tile
		else
			for(var/AM in tile)
				var/atom/movable/stuff = AM
				if(SEND_SIGNAL(stuff, COMSIG_ATOM_BSA_BEAM) & COMSIG_ATOM_BLOCKS_BSA_BEAM)
					blocker = stuff
					break
		if(blocker)
			target = tile
			break
		else
			SSexplosions.highturf += tile

	point.Beam(target, icon_state = "bsa_beam", time = 5 SECONDS, maxdistance = world.maxx) //ZZZAP
	new /obj/effect/temp_visual/bsa_splash(point, dir)

	if(!blocker)
		message_admins("[ADMIN_LOOKUPFLW(user)] has launched an artillery strike targeting [ADMIN_VERBOSEJMP(bullseye)].")
		log_game("[key_name(user)] has launched an artillery strike targeting [AREACOORD(bullseye)].")
		explosion(bullseye, ex_power, ex_power*2, ex_power*4)
	else
		message_admins("[ADMIN_LOOKUPFLW(user)] has launched an artillery strike targeting [ADMIN_VERBOSEJMP(bullseye)] but it was blocked by [blocker] at [ADMIN_VERBOSEJMP(target)].")
		log_game("[key_name(user)] has launched an artillery strike targeting [AREACOORD(bullseye)] but it was blocked by [blocker] at [AREACOORD(target)].")
	firing = FALSE


/obj/machinery/power/bsa/full/proc/reload()
	ready = FALSE
	ui_update()
	addtimer(CALLBACK(src,"ready_cannon"),600)

/obj/machinery/power/bsa/full/proc/ready_cannon()
	ready = TRUE
	ui_update()

/obj/machinery/power/bsa/full/process(delta_time)
	var/excess = terminal.surplus()
	if(cell.percent() >= 100 || excess < idle_power_usage) // do we have full charge or is there not enough power for basic charging?
		return
	var/avail_power = excess - idle_power_usage
	var/power = clamp(avail_power, 0, active_power_usage)
	var/avail_charge = power * charge_efficiency
	terminal.add_load(power + idle_power_usage)
	cell.give(avail_charge)
	update_appearance(UPDATE_OVERLAYS)
	last_charge_quarter = FLOOR(cell.percent() / 25, 1)
	ui_update()

/obj/structure/filler
	name = "big machinery part"
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	var/obj/machinery/parent

/obj/structure/filler/ex_act()
	return

/obj/machinery/computer/bsa_control
	name = "bluespace artillery control"
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/computer/bsa_control
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_boxp"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null


	var/datum/weakref/cannon_ref
	var/notice
	var/datum/weakref/target_ref


/obj/machinery/computer/bsa_control/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/computer/bsa_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceArtillery")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/bsa_control/ui_data()
	var/obj/machinery/power/bsa/full/cannon = cannon_ref?.resolve()
	var/datum/component/gps/target = target_ref?.resolve()
	var/list/data = list()
	data["ready"] = cannon ? cannon.ready : FALSE
	data["connected"] = cannon
	data["notice"] = notice
	data["unlocked"] = GLOB.bsa_unlock
	data["charge"] = cannon ? cannon.cell.charge : 0
	data["max_charge"] = cannon ? cannon.cell.maxcharge : 0
	data["formatted_charge"] = cannon ? display_power(cannon.cell.charge) : "0 W"
	data["targets"] = get_available_targets()
	if(target_ref?.resolve())
		data["target_ref"] = FAST_REF(target)
		data["target_name"] = get_target_name()
	else

		data["target_ref"] = null
		data["target_name"] = null
		target_ref = null
	return data

/obj/machinery/computer/bsa_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("build")
			cannon_ref = WEAKREF(deploy())
			. = TRUE
		if("fire")
			fire(usr)
			. = TRUE
		if("set_target")
			var/datum/component/gps/target = locate(params["chosen_target"])
			target_ref = WEAKREF(target)
			. = TRUE
	if(.)
		update_icon()

/obj/machinery/computer/bsa_control/proc/get_available_targets()
	var/list/targets = list()
	// Find all active GPS
	for(var/datum/component/gps/G in GLOB.GPS_list)
		if(G.tracking)
			targets[FAST_REF(G)] = G.gpstag
	return targets


/obj/machinery/computer/bsa_control/proc/get_target_name()
	var/target = target_ref?.resolve()
	if(istype(target, /area))
		return get_area_name(target, TRUE)
	else if(istype(target, /datum/component/gps))
		var/datum/component/gps/G = target
		return G.gpstag

/obj/machinery/computer/bsa_control/proc/get_impact_turf()
	var/target = target_ref?.resolve()
	if(istype(target, /area))
		return pick(get_area_turfs(target))
	else if(istype(target, /datum/component/gps))
		var/datum/component/gps/G = target
		return get_turf(G.parent)


/obj/machinery/computer/bsa_control/proc/fire(mob/user)
	var/obj/machinery/power/bsa/full/cannon = cannon_ref?.resolve()
	var/target = target_ref?.resolve()
	if(!target)
		notice = "Target lost!"
		return
	if(!cannon)
		notice = "No Cannon Exists!"
		return
	if(cannon.cell.percent() < 100)
		notice = "Cannon doesn't have enough charge!"
		return
	if(cannon.firing)
		notice = "Cannon is already firing!"
		return
	notice = null
	cannon.charge_up(user, get_impact_turf())
	ui_update()

/obj/machinery/computer/bsa_control/proc/deploy(force=FALSE)
	var/obj/machinery/power/bsa/full/prebuilt = locate() in range(7) //In case of adminspawn
	if(prebuilt)
		return prebuilt

	var/obj/machinery/bsa/middle/centerpiece = locate() in range(7)
	if(!centerpiece)
		notice = "No BSA parts detected nearby."
		return null
	notice = centerpiece.check_completion()
	if(notice)
		return null
	//Totally nanite construction system not an immersion breaking spawning
	var/datum/effect_system/smoke_spread/s = new
	s.set_up(4,get_turf(centerpiece))
	s.start()
	var/obj/machinery/power/bsa/full/cannon = new(get_turf(centerpiece),centerpiece.get_cannon_direction())
	QDEL_NULL(centerpiece.front_ref)
	QDEL_NULL(centerpiece.back_ref)
	qdel(centerpiece)
	return cannon
