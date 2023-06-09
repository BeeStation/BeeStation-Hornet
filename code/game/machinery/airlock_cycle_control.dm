// Embedded controller is great and all, but it is really unwieldy to map with. In addition, you can't build it in-game.
// This serves to make it really easy to make it really easy to make cycling airlocks both in-game and in the map editor.
// Instead of editing vars, this involves placing a couple of mapping helpers.

// also can I say how much I hate the whole radio control thing in this game. It's not even exposed to the player at all.
// All it does is making coding a massive pain in the rear end.

// Anyways for a functioning airlock, you need an interior and an exterior door. Vents are optional.
// If setup right, you can even make an airlock that cycles between two rooms of different atmospheres!
// Perfect for the plasmaman atmos tech.

// NOTE FOR MAPPERS:
// PLEASE DON'T PUT THIS ON THE SAME TILE AS A VENT IF THE AIRLOCK IS BIGGER THAN 1X1.
// (If this is a 1x2 airlock and there is a pressurizing and a depressurizing vent
// then put the depressurizing vent under the controller)

#define AIRLOCK_CYCLESTATE_INOPEN 0
#define AIRLOCK_CYCLESTATE_INOPENING 1
#define AIRLOCK_CYCLESTATE_INCLOSING 2
#define AIRLOCK_CYCLESTATE_CLOSED 3
#define AIRLOCK_CYCLESTATE_OUTCLOSING 4
#define AIRLOCK_CYCLESTATE_OUTOPENING 5
#define AIRLOCK_CYCLESTATE_OUTOPEN 6
#define AIRLOCK_CYCLESTATE_DOCKED -1
#define AIRLOCK_CYCLESTATE_ERROR -2

#define AIRLOCK_CYCLEROLE_INT_PRESSURIZE 1
#define AIRLOCK_CYCLEROLE_INT_DEPRESSURIZE 2
#define AIRLOCK_CYCLEROLE_EXT_PRESSURIZE 4
#define AIRLOCK_CYCLEROLE_EXT_DEPRESSURIZE 8

/obj/item/electronics/advanced_airlock_controller
	name = "airlock controller electronics"
	custom_price = 5
	icon_state = "airalarm_electronics"

/obj/item/wallframe/advanced_airlock_controller
	name = "airlock controller frame"
	desc = "Used for building advanced airlock controllers."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "aac_bitem"
	result_path = /obj/machinery/advanced_airlock_controller

/obj/machinery/advanced_airlock_controller
	name = "advanced airlock controller"
	desc = "A machine designed to control the operation of cycling airlocks"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "aac"
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = AREA_USAGE_ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS)
	max_integrity = 250
	integrity_failure = 80
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 90, ACID = 30, STAMINA = 0)
	resistance_flags = FIRE_PROOF
	layer = ABOVE_WINDOW_LAYER

	var/cyclestate = AIRLOCK_CYCLESTATE_INOPEN
	var/interior_pressure = ONE_ATMOSPHERE
	var/exterior_pressure = 0

	var/locked = TRUE
	var/aidisabled = 0
	var/shorted = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone
	var/config_error_str = "Needs Scan"
	var/scan_on_late_init = FALSE
	var/depressurization_margin = 10 // use a lower value to reduce cross-contamination
	var/overlays_hash = null
	var/skip_delay = 150
	var/skip_timer = 0
	var/is_skipping = FALSE

	var/list/airlocks = list()
	var/list/vents = list()
	var/obj/vis_target = null

/obj/machinery/advanced_airlock_controller/lavaland
	exterior_pressure = WARNING_LOW_PRESSURE + 10
	depressurization_margin = ONE_ATMOSPHERE
	skip_delay = 30

/obj/machinery/advanced_airlock_controller/mix_chamber
	depressurization_margin = 0.15 // The minimum - We really don't want contamination.

/obj/machinery/advanced_airlock_controller/directional //NSV13 makes directinal versions of advanced airlock controllers mapping QOL

/obj/machinery/advanced_airlock_controller/directional/north
	pixel_y = 24

/obj/machinery/advanced_airlock_controller/directional/south
	pixel_y = -24

/obj/machinery/advanced_airlock_controller/directional/east
	pixel_x = 24

/obj/machinery/advanced_airlock_controller/directional/west
	pixel_x = -24

/obj/machinery/advanced_airlock_controller/New(loc, ndir, nbuild)
	..()
	wires = new /datum/wires/advanced_airlock_controller(src)
	if(ndir)
		setDir(ndir)

	if(nbuild)
		buildstage = 0
		panel_open = TRUE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir == 1 ? -24 : 24) : 0

	update_icon()

/obj/machinery/advanced_airlock_controller/Destroy()
	qdel(wires)
	wires = null
	cut_links()
	SSair.start_processing_machine(src)
	return ..()

/obj/machinery/advanced_airlock_controller/Initialize(mapload)
	. = ..()
	SSair.stop_processing_machine(src)
	scan_on_late_init = mapload
	if(mapload && (. != INITIALIZE_HINT_QDEL))
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/advanced_airlock_controller/LateInitialize(mapload)
	. = ..()
	if(scan_on_late_init)
		scan(TRUE)
		update_error_status()
		update_docked_status(FALSE)
		for(var/A in airlocks)
			var/obj/machinery/door/airlock/airlock = A
			if(airlock.density && (cyclestate == AIRLOCK_CYCLESTATE_CLOSED || (airlocks[A] && cyclestate == AIRLOCK_CYCLESTATE_INOPEN) || (!airlocks[A] && cyclestate == AIRLOCK_CYCLESTATE_OUTOPEN)))
				airlock.bolt()

/obj/machinery/advanced_airlock_controller/update_icon(use_hash = FALSE)
	var/turf/location = get_turf(src)
	if(!location)
		return
	var/pressure = 0
	if(location)
		var/datum/gas_mixture/environment = location.return_air()
		if(environment)
			pressure = environment.return_pressure()
	var/maxpressure = (exterior_pressure && (cyclestate == AIRLOCK_CYCLESTATE_OUTCLOSING || cyclestate == AIRLOCK_CYCLESTATE_OUTOPENING || cyclestate == AIRLOCK_CYCLESTATE_OUTOPEN)) ? exterior_pressure : interior_pressure
	var/pressure_bars
	if(maxpressure == 0)
		//1 is the lowest value found in monitors.dmi
		pressure_bars = 1
	else
		pressure_bars = round(pressure / maxpressure * 5 + 0.01)

	var/new_overlays_hash = "[pressure_bars]-[cyclestate]-[buildstage]-[panel_open]-[machine_stat]-[shorted]-[locked]-\ref[vis_target]"
	if(use_hash && new_overlays_hash == overlays_hash)
		return
	overlays_hash = new_overlays_hash

	cut_overlays()
	if(panel_open)
		switch(buildstage)
			if(2)
				icon_state = "aac_b3"
			if(1)
				icon_state = "aac_b2"
			if(0)
				icon_state = "aac_b1"
		return

	icon_state = "aac"

	if((machine_stat & (NOPOWER|BROKEN)) || shorted)
		return

	var/is_exterior_pressure = (cyclestate == AIRLOCK_CYCLESTATE_OUTCLOSING || cyclestate == AIRLOCK_CYCLESTATE_OUTOPENING || cyclestate == AIRLOCK_CYCLESTATE_OUTOPEN)
	add_overlay("aac_[is_exterior_pressure ? "ext" : "int"]p_[pressure_bars]")
	add_overlay("aac_cyclestate_[cyclestate]")
	if(obj_flags & EMAGGED)
		add_overlay("aac_emagged")
	else if(!locked)
		add_overlay("aac_unlocked")

	if(vis_target)
		var/f_dx = ((vis_target.pixel_x - pixel_x) / world.icon_size) + (vis_target.x - x)
		var/f_dy = ((vis_target.pixel_y - pixel_y) / world.icon_size) + (vis_target.y - y)
		var/dist = sqrt(f_dx*f_dx+f_dy*f_dy)
		var/s_dx = f_dy/dist
		var/s_dy = -f_dx/dist
		var/matrix/TR = new
		TR.Translate(0, 16)
		TR.Multiply(new /matrix(s_dx, f_dx, 0, s_dy, f_dy, 0))
		var/mutable_appearance/M = mutable_appearance(icon, "hologram-line", FLOAT_LAYER, ABOVE_LIGHTING_PLANE)
		M.transform = TR
		add_overlay(M)

/obj/machinery/advanced_airlock_controller/proc/reset(wire)
	switch(wire)
		if(WIRE_POWER)
			if(!wires.is_cut(WIRE_POWER))
				shorted = FALSE
				update_icon()
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE

/obj/machinery/advanced_airlock_controller/proc/shock(mob/user, prb)
	if((machine_stat & (NOPOWER)))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if (electrocute_mob(user, get_area(src), src, 1, TRUE))
		return 1
	else
		return 0

/obj/machinery/advanced_airlock_controller/proc/update_docked_status(process_on_changed = FALSE)
	if(cyclestate == AIRLOCK_CYCLESTATE_ERROR)
		return
	var/is_docked = FALSE
	for(var/A in airlocks)
		var/obj/machinery/door/airlock/airlock = A
		if(!airlocks[A]) // only exterior airlocks are checked for docks
			continue
		var/turf/T = get_turf(airlock)
		if(!T)
			continue
		for(var/cdir in GLOB.cardinals)
			var/turf/T2 = get_step(T, cdir)
			if(!T2)
				continue
			if(T2.loc != T.loc && (locate(/obj/machinery/door/airlock) in T2))
				is_docked = TRUE
				break
		if(is_docked)
			break
	if(is_docked && cyclestate != AIRLOCK_CYCLESTATE_DOCKED)
		cyclestate = AIRLOCK_CYCLESTATE_DOCKED
		if(process_on_changed)
			process_atmos()
	if(!is_docked && cyclestate == AIRLOCK_CYCLESTATE_DOCKED)
		cyclestate = AIRLOCK_CYCLESTATE_INOPENING
		reset_skip()
		for(var/airlock in airlocks)
			coerce_door(airlock, TRUE)
		if(process_on_changed)
			process_atmos()

/obj/machinery/advanced_airlock_controller/proc/update_error_status()
	if(!airlocks.len)
		cyclestate = AIRLOCK_CYCLESTATE_ERROR
		return
	var/has_interior = FALSE
	var/has_exterior = FALSE
	for(var/A in airlocks)
		if(airlocks[A] == 1)
			has_exterior = TRUE
		if(airlocks[A] == 0)
			has_interior = TRUE
	if(!has_interior || !has_exterior)
		if(!has_interior)
			config_error_str = "No interior door"
		else if(!has_exterior)
			config_error_str = "No exterior door"
		cyclestate = AIRLOCK_CYCLESTATE_ERROR
		return
	if(cyclestate == AIRLOCK_CYCLESTATE_ERROR)
		cyclestate = AIRLOCK_CYCLESTATE_CLOSED
		update_docked_status()

/obj/machinery/advanced_airlock_controller/proc/coerce_door(obj/machinery/door/airlock/door, target_density = 0)
	if(door.density == target_density && !door.operating)
		door.bolt()
		return TRUE
	if(door.operating || door.welded || !door.hasPower() || door.wires.is_cut(WIRE_BOLTS))
		return FALSE
	door.unbolt()
	if(door.density != target_density)
		if(target_density)
			spawn(0)
				door.close()
				door.bolt()
		else
			spawn(0)
				door.open()
				door.bolt()
	return FALSE

/obj/machinery/advanced_airlock_controller/proc/unbolt_door(obj/machinery/door/airlock/door)
	if(!door.wires.is_cut(WIRE_BOLTS))
		door.unbolt()

/obj/machinery/advanced_airlock_controller/process()
	process_atmos()

/obj/machinery/advanced_airlock_controller/process_atmos()
	if((machine_stat & (NOPOWER|BROKEN)) || shorted)
		update_icon(TRUE)
		return

	var/turf/location = get_turf(src)
	if(!location)
		update_icon(TRUE)
		return
	var/pressure = 0
	if(location)
		var/datum/gas_mixture/environment = location.return_air()
		if(environment)
			pressure = environment.return_pressure()

	update_error_status()
	var/doors_valid = TRUE
	var/vents_valid = TRUE
	switch(cyclestate)
		if(AIRLOCK_CYCLESTATE_ERROR)
			return
		if(AIRLOCK_CYCLESTATE_CLOSED)
			return
		if(AIRLOCK_CYCLESTATE_DOCKED)
			for(var/airlock in airlocks)
				unbolt_door(airlock)
			for(var/V in vents)
				var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
				if(vents[vent] & AIRLOCK_CYCLEROLE_INT_PRESSURIZE)
					vent.pump_direction = 1
					vent.pressure_checks = 1
					vent.external_pressure_bound = interior_pressure
					vent.on = TRUE
					vent.update_icon()
				else
					vent.on = FALSE
					vent.update_icon()
			return
		if(AIRLOCK_CYCLESTATE_INCLOSING)
			for(var/airlock in airlocks)
				doors_valid = doors_valid && coerce_door(airlock, TRUE)
			if(doors_valid || is_skipping)
				for(var/V in vents)
					var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
					if(vents[vent] & AIRLOCK_CYCLEROLE_INT_DEPRESSURIZE)
						vent.pump_direction = 0
						vent.pressure_checks = 1
						vent.external_pressure_bound = 0
						vents_valid = FALSE
						vent.on = TRUE
						vent.update_icon()
					else
						vent.on = FALSE
						vent.update_icon()
				if(pressure < depressurization_margin)
					vents_valid = TRUE
				if((doors_valid && vents_valid) || is_skipping)
					cyclestate = AIRLOCK_CYCLESTATE_OUTOPENING
					reset_skip()
		if(AIRLOCK_CYCLESTATE_OUTCLOSING)
			for(var/airlock in airlocks)
				doors_valid = doors_valid && coerce_door(airlock, TRUE)
			if(doors_valid || is_skipping)
				for(var/V in vents)
					var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
					if(vents[vent] & AIRLOCK_CYCLEROLE_EXT_DEPRESSURIZE)
						vent.pump_direction = 0
						vent.pressure_checks = 1
						vent.external_pressure_bound = 0
						vents_valid = FALSE
						vent.on = TRUE
						vent.update_icon()
					else
						vent.on = FALSE
						vent.update_icon()
				if(pressure < depressurization_margin)
					vents_valid = TRUE
				if(vents_valid || is_skipping)
					cyclestate = AIRLOCK_CYCLESTATE_INOPENING
					reset_skip()
		if(AIRLOCK_CYCLESTATE_INOPENING)
			for(var/airlock in airlocks)
				if(airlocks[airlock])
					doors_valid = doors_valid && coerce_door(airlock, 1)
			for(var/V in vents)
				var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
				if(vents[vent] & AIRLOCK_CYCLEROLE_INT_PRESSURIZE)
					vent.pump_direction = 1
					vent.pressure_checks = 1
					vent.external_pressure_bound = interior_pressure
					vents_valid = FALSE
					vent.on = TRUE
					vent.update_icon()
				else
					vent.on = FALSE
					vent.update_icon()
			if(pressure > interior_pressure - 0.5)
				vents_valid = TRUE
			if(vents_valid || is_skipping)
				for(var/airlock in airlocks)
					if(!airlocks[airlock])
						doors_valid = doors_valid && coerce_door(airlock, 0)
				if(doors_valid || is_skipping)
					cyclestate = AIRLOCK_CYCLESTATE_INOPEN
					reset_skip()
		if(AIRLOCK_CYCLESTATE_OUTOPENING)
			for(var/airlock in airlocks)
				if(!airlocks[airlock])
					doors_valid = doors_valid && coerce_door(airlock, 1)
			for(var/V in vents)
				var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
				if(vents[vent] & AIRLOCK_CYCLEROLE_EXT_PRESSURIZE)
					vent.pump_direction = 1
					vent.pressure_checks = 1
					vent.external_pressure_bound = exterior_pressure
					vents_valid = FALSE
					vent.on = TRUE
					vent.update_icon()
				else
					vent.on = FALSE
					vent.update_icon()
			if(pressure > exterior_pressure - 0.5)
				vents_valid = TRUE
			if(vents_valid || is_skipping)
				for(var/airlock in airlocks)
					if(airlocks[airlock])
						doors_valid = doors_valid && coerce_door(airlock, 0)
				if(doors_valid || is_skipping)
					cyclestate = AIRLOCK_CYCLESTATE_OUTOPEN
					reset_skip()
		if(AIRLOCK_CYCLESTATE_INOPEN)
			for(var/V in vents)
				var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
				vent.on = FALSE
				vent.update_icon()
		if(AIRLOCK_CYCLESTATE_OUTOPEN)
			for(var/V in vents)
				var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
				vent.on = FALSE
				vent.update_icon()
	update_icon(TRUE)

/obj/machinery/advanced_airlock_controller/attackby(obj/item/W, mob/user, params)
	switch(buildstage)
		if(2)
			if(W.tool_behaviour == TOOL_WIRECUTTER && panel_open && wires.is_all_cut())
				W.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You cut the final wires.</span>")
				new /obj/item/stack/cable_coil(loc, 5)
				buildstage = 1
				update_icon()
				return
			else if(W.tool_behaviour == TOOL_SCREWDRIVER)  // Opening that up.
				W.play_tool_sound(src)
				panel_open = !panel_open
				to_chat(user, "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>")
				update_icon()
				return
			else if(istype(W, /obj/item/card/id) || istype(W, /obj/item/modular_computer/tablet/pda))// trying to unlock the interface with an ID card
				togglelock(user)
				return
			else if(panel_open && is_wire_tool(W))
				wires.interact(user)
				return
		if(1)
			if(W.tool_behaviour == TOOL_CROWBAR)
				user.visible_message("[user.name] removes the electronics from [src.name].",\
									"<span class='notice'>You start prying out the circuit...</span>")
				W.play_tool_sound(src)
				if (W.use_tool(src, user, 20))
					if (buildstage == 1)
						to_chat(user, "<span class='notice'>You remove the airlock controller electronics.</span>")
						new /obj/item/electronics/advanced_airlock_controller( src.loc )
						playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
						buildstage = 0
						update_icon()
				return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/cable = W
				if(cable.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the airlock controller!</span>")
					return
				user.visible_message("[user.name] wires the airlock controller.", \
									"<span class='notice'>You start wiring the airlock controller...</span>")
				if (do_after(user, 20, target = src))
					if (cable.get_amount() >= 5 && buildstage == 1)
						cable.use(5)
						to_chat(user, "<span class='notice'>You wire the airlock controller.</span>")
						wires.repair()
						aidisabled = 0
						locked = FALSE
						cyclestate = AIRLOCK_CYCLESTATE_ERROR
						cut_links()
						shorted = 0
						buildstage = 2
						update_icon()
				return
		if(0)
			if(istype(W, /obj/item/electronics/advanced_airlock_controller))
				if(user.temporarilyRemoveItemFromInventory(W))
					to_chat(user, "<span class='notice'>You insert the circuit.</span>")
					buildstage = 1
					update_icon()
					qdel(W)
				return

			if(istype(W, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/P = W
				if(!P.adapt_circuit(user, 25))
					return
				user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
				"<span class='notice'>You adapt an airlock controller circuit and slot it into the assembly.</span>")
				buildstage = 1
				update_icon()
				return

			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You detach \the [src] from the wall.</span>")
				W.play_tool_sound(src)
				new /obj/item/wallframe/advanced_airlock_controller( user.loc )
				qdel(src)
				return

	return ..()

/obj/machinery/advanced_airlock_controller/proc/cut_links()
	for(var/obj/machinery/door/airlock/A in airlocks)
		if(A.aac == src)
			A.aac = null
	for(var/V in vents)
		var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
		if(vent.aac == src)
			vent.aac = null
	airlocks.Cut()
	vents.Cut()

/obj/machinery/advanced_airlock_controller/proc/scan(assume_roles = FALSE)
	cut_links()
	config_error_str = "Unknown error (bug coders)"

	var/turf/open/initial_turf = get_turf(src)
	if(!istype(initial_turf))
		config_error_str = "Scan blocked by wall"
		return
	var/list/turfs = list()
	turfs[initial_turf] = 1
	for(var/I = 1; I <= turfs.len; I++)
		var/turf/open/T = turfs[I]
		if(assume_roles)
			T.ImmediateCalculateAdjacentTurfs()
		for(var/turf/open/T2 in T.atmos_adjacent_turfs)
			if(get_dist(initial_turf, T2) > 5)
				config_error_str = "Airlock too big"
				return
			if(locate(/obj/machinery/door/airlock) in T2)
				continue
			turfs[T2] = 1
		if(turfs.len > 16) // I will allow a 4x4 airlock for a shitty poor-man's spacepod bay.
			config_error_str = "Airlock too big"
		for(var/cdir in GLOB.cardinals)
			var/turf/T2 = get_step(T, cdir)
			for(var/obj/machinery/door/airlock/A in T2)
				if(!A.aac || A.aac == src)
					A.aac = src
					airlocks[A] = 0
					if(assume_roles)
						for(var/adir in GLOB.cardinals)
							var/turf/check_turf = get_step(T2, adir)
							if(check_turf.loc != T2.loc)
								airlocks[A] = 1
								break
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in T)
			if(!vent.aac || vent.aac == src)
				vent.aac = src
				vents[vent] = 0
				if(assume_roles)
					if(istype(vent, /obj/machinery/atmospherics/components/unary/vent_pump/siphon))
						vents[vent] = AIRLOCK_CYCLEROLE_INT_DEPRESSURIZE | AIRLOCK_CYCLEROLE_EXT_DEPRESSURIZE
					else
						vents[vent] = AIRLOCK_CYCLEROLE_INT_PRESSURIZE
		for(var/obj/machinery/atmospherics/components/binary/dp_vent_pump/vent in T)
			if(!vent.aac || vent.aac == src)
				vent.aac = src
				vents[vent] = 0
				if(assume_roles)
					vents[vent] = AIRLOCK_CYCLEROLE_INT_DEPRESSURIZE | AIRLOCK_CYCLEROLE_EXT_DEPRESSURIZE | AIRLOCK_CYCLEROLE_INT_PRESSURIZE
	if(!airlocks.len)
		config_error_str = "No airlocks"
		return
	config_error_str = null

/obj/machinery/advanced_airlock_controller/ui_status(mob/user)
	if(user.has_unlimited_silicon_privilege && aidisabled)
		to_chat(user, "AI control has been disabled.")
	else if(!shorted)
		return ..()
	return UI_CLOSE


/obj/machinery/advanced_airlock_controller/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/advanced_airlock_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdvancedAirlockController")
		ui.set_autoupdate(TRUE) // Pressure display, mode changes as part of the cycle process
		ui.open()

/obj/machinery/advanced_airlock_controller/ui_data(mob/user)
	var/turf/T = get_turf(src)
	var/pressure = 0
	if(T)
		var/datum/gas_mixture/environment = T.return_air()
		if(environment)
			pressure = environment.return_pressure()

	var/data = list(
		"locked" = locked,
		"siliconUser" = user.has_unlimited_silicon_privilege,
		"emagged" = (obj_flags & EMAGGED ? 1 : 0),
		"cyclestate" = cyclestate,
		"pressure" = pressure,
		"maxpressure" = (exterior_pressure && (cyclestate == AIRLOCK_CYCLESTATE_OUTCLOSING || cyclestate == AIRLOCK_CYCLESTATE_OUTOPENING || cyclestate == AIRLOCK_CYCLESTATE_OUTOPEN)) ? exterior_pressure : interior_pressure,
		"vents" = list(),
		"airlocks" = list(),
		"skip_timer" = (world.time - skip_timer),
		"skip_delay" = skip_delay,
		"vis_target" = "\ref[vis_target]"
	)

	if((locked && !user.has_unlimited_silicon_privilege) || (user.has_unlimited_silicon_privilege && aidisabled))
		return data

	data["config_error_str"] = config_error_str
	data["interior_pressure"] = interior_pressure
	data["exterior_pressure"] = exterior_pressure
	data["depressurization_margin"] = depressurization_margin

	for(var/V in vents)
		// it could also be a dpvent.
		var/obj/machinery/atmospherics/components/unary/vent_pump/vent = V
		data["vents"] += list(list(
			"role" = vents[vent],
			"vent_id" = "\ref[vent]",
			"name" = vent.name
		))
	for(var/A in airlocks)
		var/obj/machinery/door/airlock/airlock = A
		var/access_str = "None"
		airlock.gen_access()
		if(islist(airlock.req_access) && airlock.req_access.len)
			access_str = airlock.req_access.len > 1 ? "All of " : ""
			for(var/I in 1 to airlock.req_access.len)
				if(I != 1)
					access_str += ", "
				access_str += get_access_desc(airlock.req_access[I])
		if(islist(airlock.req_one_access) && airlock.req_one_access.len)
			access_str = airlock.req_one_access.len > 1 ? "One of " : ""
			for(var/I in 1 to airlock.req_one_access.len)
				if(I != 1)
					access_str += ", "
				access_str += get_access_desc(airlock.req_one_access[I])

		data["airlocks"] += list(list(
			"role" = airlocks[airlock],
			"airlock_id" = "\ref[airlock]",
			"name" = airlock.name,
			"access" = access_str
		))
	return data

/obj/machinery/advanced_airlock_controller/ui_close()
	. = ..()
	vis_target = null

/obj/machinery/advanced_airlock_controller/ui_act(action, params)
	if(..() || buildstage != 2)
		return
	// these actions can be done by anyone
	switch(action)
		if("cycle")
			var/is_allowed = TRUE
			for(var/obj/machinery/door/airlock/A in airlocks)
				if(!A.allowed(usr))
					if(is_allowed)
						is_allowed = FALSE
						to_chat(usr, "<span class='danger'>Access denied.</span>")
					if(A.density)
						spawn()
							A.do_animate("deny")
			if(is_allowed)
				cycle_to(text2num(params["exterior"]))
				. = TRUE
		if("skip")
			if((world.time - skip_timer) >= skip_delay && (cyclestate == AIRLOCK_CYCLESTATE_OUTCLOSING || cyclestate == AIRLOCK_CYCLESTATE_OUTOPENING || cyclestate == AIRLOCK_CYCLESTATE_INOPENING || cyclestate == AIRLOCK_CYCLESTATE_INCLOSING))
				is_skipping = TRUE
				. = TRUE
	if(!. && ((locked && !usr.has_unlimited_silicon_privilege) || (usr.has_unlimited_silicon_privilege && aidisabled)))
		return
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege && !wires.is_cut(WIRE_IDSCAN))
				locked = !locked
				. = TRUE
				vis_target = null
		if("toggle_role")
			var/vent = locate(params["vent_id"])
			if(vent == null || vents[vent] == null)
				return
			var/curr_role = vents[vent]
			var/role_to_toggle = text2num(params["val"]) & 15
			if(curr_role & role_to_toggle)
				vents[vent] = curr_role & ~(role_to_toggle)
			else
				vents[vent] = curr_role | role_to_toggle
			. = TRUE
		if("set_airlock_role")
			var/airlock = locate(params["airlock_id"])
			if(airlock == null || airlocks[airlock] == null)
				return
			airlocks[airlock] = !!text2num(params["val"])
			. = TRUE
		if("clear_vis")
			vis_target = null
			. = TRUE
		if("set_vis_vent")
			var/vent = locate(params["vent_id"])
			if(vent == null || vents[vent] == null)
				return
			vis_target = vent
			. = TRUE
		if("set_vis_airlock")
			var/airlock = locate(params["airlock_id"])
			if(airlock == null || airlocks[airlock] == null)
				return
			vis_target = airlock
			. = TRUE
		if("scan")
			scan()
			. = TRUE
		if("interior_pressure")
			interior_pressure = CLAMP(text2num(params["pressure"]), 0, ONE_ATMOSPHERE)
			. = TRUE
		if("exterior_pressure")
			exterior_pressure = CLAMP(text2num(params["pressure"]), 0, ONE_ATMOSPHERE)
			. = TRUE
		if("depressurization_margin")
			depressurization_margin = CLAMP(text2num(params["pressure"]), 0.15, 40)
			. = TRUE
		if("skip_delay")
			skip_delay = CLAMP(text2num(params["skip_delay"]), 0, 1200)
			. = TRUE

	if(.)
		update_icon(TRUE)

/obj/machinery/advanced_airlock_controller/proc/request_from_door(airlock)
	var/role = airlocks[airlock]
	if(role == null)
		return
	cycle_to(role)

/obj/machinery/advanced_airlock_controller/proc/cycle_to(exterior)
	if(!exterior)
		if(cyclestate == AIRLOCK_CYCLESTATE_OUTOPEN || cyclestate == AIRLOCK_CYCLESTATE_CLOSED || cyclestate == AIRLOCK_CYCLESTATE_OUTOPENING)
			cyclestate = AIRLOCK_CYCLESTATE_OUTCLOSING
			reset_skip()
			process_atmos()
		else if(cyclestate == AIRLOCK_CYCLESTATE_INCLOSING)
			cyclestate = AIRLOCK_CYCLESTATE_INOPENING
			reset_skip()
			process_atmos()
	else
		if(cyclestate == AIRLOCK_CYCLESTATE_INOPEN || cyclestate == AIRLOCK_CYCLESTATE_CLOSED || cyclestate == AIRLOCK_CYCLESTATE_INOPENING)
			cyclestate = AIRLOCK_CYCLESTATE_INCLOSING
			reset_skip()
		else if(cyclestate == AIRLOCK_CYCLESTATE_OUTCLOSING)
			cyclestate = AIRLOCK_CYCLESTATE_OUTOPENING
			reset_skip()

/obj/machinery/advanced_airlock_controller/proc/reset_skip()
	is_skipping = FALSE
	skip_timer = world.time

/obj/machinery/advanced_airlock_controller/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	else
		togglelock(user)

/obj/machinery/advanced_airlock_controller/proc/togglelock(mob/living/user)
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>It does nothing!</span>")
	else
		if(src.allowed(usr) && !wires.is_cut(WIRE_IDSCAN))
			locked = !locked
			update_icon()
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the airlock controller interface.</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")
	return

/obj/machinery/advanced_airlock_controller/power_change()
	..()
	update_icon()

/obj/machinery/advanced_airlock_controller/on_emag(mob/user)
	..()
	visible_message("<span class='warning'>Sparks fly out of [src]!</span>", "<span class='notice'>You emag [src], disabling its safeties.</span>")
	playsound(src, "sparks", 50, 1)

/obj/machinery/advanced_airlock_controller/obj_break(damage_flag)
	..()
	update_icon()

/obj/machinery/advanced_airlock_controller/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 2)
		var/obj/item/I = new /obj/item/electronics/advanced_airlock_controller(loc)
		if(!disassembled)
			I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

/obj/machinery/door/airlock
	var/obj/machinery/advanced_airlock_controller/aac

/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()
	update_aac_docked()
/obj/machinery/door/airlock/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	if(aac)
		aac.airlocks -= src
		aac = null
	if(T)
		update_aac_docked(T)

/obj/machinery/door/airlock/proc/update_aac_docked(atom/point = src)
	if(aac)
		aac.update_docked_status(TRUE)
	var/turf/our_turf = get_turf(point)
	if(!our_turf)
		return
	for(var/cdir in GLOB.cardinals)
		var/turf/T = get_step(point, cdir)
		if(!T || (T.loc == our_turf.loc))
			continue
		for(var/obj/machinery/door/airlock/A in T)
			if(A.aac)
				A.aac.update_docked_status(TRUE)
