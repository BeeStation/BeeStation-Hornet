#define NO_BOUND	3

/obj/machinery/atmospherics/components/unary/vent_pump
	icon_state = "vent_map-3"

	name = "air vent"
	desc = "Has a valve and pump attached to it."

	use_power = IDLE_POWER_USE
	can_unwrench = TRUE
	welded = FALSE
	layer = GAS_SCRUBBER_LAYER
	hide = TRUE
	shift_underlay_only = FALSE
	pipe_state = "uvent"

	interacts_with_air = TRUE

	///Direction of pumping the gas (ATMOS_DIRECTION_RELEASING or ATMOS_DIRECTION_SIPHONING)
	var/pump_direction = ATMOS_DIRECTION_RELEASING
	///Should we check internal pressure, external pressure, both or none? (ATMOS_EXTERNAL_BOUND, ATMOS_INTERNAL_BOUND, NO_BOUND)
	var/pressure_checks = ATMOS_EXTERNAL_BOUND
	///The external pressure threshold (default 101 kPa)
	var/external_pressure_bound = ONE_ATMOSPHERE
	///The internal pressure threshold (default 0 kPa)
	var/internal_pressure_bound = 0
	// ATMOS_EXTERNAL_BOUND: Do not pass external_pressure_bound
	// ATMOS_INTERNAL_BOUND: Do not pass internal_pressure_bound
	// NO_BOUND: Do not pass either

	/// id of air sensor its connected to
	var/chamber_id

	///area this vent is assigned to
	var/area/assigned_area

/obj/machinery/atmospherics/components/unary/vent_pump/Initialize(mapload)
	. = ..()

	assign_to_area()

/obj/machinery/atmospherics/components/unary/vent_pump/Destroy()
	disconnect_from_area()

	var/area/vent_area = get_area(src)
	if (vent_area)
		vent_area.air_vents -= src

	return ..()

/obj/machinery/atmospherics/components/unary/vent_pump/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	var/area/old_area = get_area(old_loc)
	var/area/new_area = get_area(src)

	if (old_area == new_area)
		return

	disconnect_from_area()
	assign_to_area()

/obj/machinery/atmospherics/components/unary/vent_pump/proc/assign_to_area()
	var/area/area = get_area(src)
	area?.air_vents += src

/obj/machinery/atmospherics/components/unary/vent_pump/proc/disconnect_from_area()
	var/area/area = get_area(src)
	area?.air_vents -= src

/obj/machinery/atmospherics/components/unary/vent_pump/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = get_pipe_image(icon, "vent_cap", initialize_directions)
		add_overlay(cap)
	else
		PIPING_LAYER_SHIFT(src, PIPING_LAYER_DEFAULT)

	if(welded)
		icon_state = "vent_welded"
		return

	if(!nodes[1] || !on || !is_operational)
		if(icon_state == "vent_welded")
			icon_state = "vent_off"
			return

		if(pump_direction & ATMOS_DIRECTION_RELEASING)
			icon_state = "vent_out-off"
		else // pump_direction == SIPHONING
			icon_state = "vent_in-off"
		return

	if(icon_state == ("vent_out-off" || "vent_in-off" || "vent_off"))
		if(pump_direction & ATMOS_DIRECTION_RELEASING)
			icon_state = "vent_out"
			flick("vent_out-starting", src)
		else // pump_direction == SIPHONING
			icon_state = "vent_in"
			flick("vent_in-starting", src)
		return

	if(pump_direction & ATMOS_DIRECTION_RELEASING)
		icon_state = "vent_out"
	else // pump_direction == SIPHONING
		icon_state = "vent_in"

/obj/machinery/atmospherics/components/unary/vent_pump/process_atmos()
	..()
	if(!is_operational || !isopenturf(loc))
		return
	if(!nodes[1])
		on = FALSE
	if(!on || welded)
		return

	var/datum/gas_mixture/air_contents = airs[1]
	var/datum/gas_mixture/environment = loc.return_air()

	if(environment == null)
		return

	var/environment_pressure = environment.return_pressure()

	if(pump_direction & ATMOS_DIRECTION_RELEASING) // internal -> external
		var/pressure_delta = 10000

		if(pressure_checks&ATMOS_EXTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks&ATMOS_INTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (air_contents.return_pressure() - internal_pressure_bound))

		if(pressure_delta > 0)
			if(air_contents.return_temperature() > 0 && air_contents.return_volume() > 0)
				var/transfer_moles = (pressure_delta*environment.return_volume())/(air_contents.return_temperature() * R_IDEAL_GAS_EQUATION)

				loc.assume_air_moles(air_contents, transfer_moles)

	else // external -> internal
		if(environment.return_pressure() > 0)
			var/our_multiplier = air_contents.return_volume() / (environment.return_temperature() * R_IDEAL_GAS_EQUATION)
			var/moles_delta = 10000 * our_multiplier
			if(pressure_checks&ATMOS_EXTERNAL_BOUND)
				moles_delta = min(moles_delta, (environment_pressure - external_pressure_bound) * environment.return_volume() / (environment.return_temperature() * R_IDEAL_GAS_EQUATION))
			if(pressure_checks&ATMOS_INTERNAL_BOUND)
				moles_delta = min(moles_delta, (internal_pressure_bound - air_contents.return_pressure()) * our_multiplier)

			if(moles_delta > 0)
				loc.transfer_air(air_contents, moles_delta)
	update_parents()

/obj/machinery/atmospherics/components/unary/vent_pump/update_name()
	. = ..()
	if(override_naming)
		return
	var/area/vent_area = get_area(src)
	name = "\proper [vent_area.name] [name] [id_tag]"

/obj/machinery/atmospherics/components/unary/vent_pump/welder_act(mob/living/user, obj/item/I)
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	to_chat(user, "<span class='notice'>You begin welding the vent...</span>")
	if(I.use_tool(src, user, 20, volume=50))
		if(!welded)
			user.visible_message("[user] welds the vent shut.", "<span class='notice'>You weld the vent shut.</span>", "<span class='italics'>You hear welding.</span>")
			welded = TRUE
		else
			user.visible_message("[user] unwelded the vent.", "<span class='notice'>You unweld the vent.</span>", "<span class='italics'>You hear welding.</span>")
			welded = FALSE
		update_icon()
		pipe_vision_img = image(src, loc, dir = dir)
		pipe_vision_img.plane = ABOVE_HUD_PLANE
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/examine(mob/user)
	. = ..()
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/components/unary/vent_pump/can_crawl_through()
	return !(machine_stat & BROKEN) && !welded

/obj/machinery/atmospherics/components/unary/vent_pump/power_change()
	. = ..()
	update_icon_nopipes()

/obj/machinery/atmospherics/components/unary/vent_pump/attack_alien(mob/user)
	if(!welded || !(do_after(user, 20, target = src)))
		return
	user.visible_message("<span class='warning'>[user] furiously claws at [src]!</span>", "<span class='notice'>You manage to clear away the stuff blocking the vent.</span>", "<span class='warning'>You hear loud scraping noises.</span>")
	welded = FALSE
	update_icon()
	pipe_vision_img = image(src, loc, dir = dir)
	pipe_vision_img.plane = ABOVE_HUD_PLANE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, 1)

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	name = "large air vent"
	power_channel = AREA_USAGE_EQUIP

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.volume = 1000

// mapping

/obj/machinery/atmospherics/components/unary/vent_pump/layer2
	piping_layer = 2
	icon_state = "vent_map-2"

/obj/machinery/atmospherics/components/unary/vent_pump/layer4
	piping_layer = 4
	icon_state = "vent_map-4"

/obj/machinery/atmospherics/components/unary/vent_pump/on
	on = TRUE
	icon_state = "vent_map_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/on/layer2
	piping_layer = 2
	icon_state = "vent_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/on/layer4
	piping_layer = 4
	icon_state = "vent_map_on-4"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon
	pump_direction = ATMOS_DIRECTION_SIPHONING
	pressure_checks = ATMOS_INTERNAL_BOUND
	internal_pressure_bound = 4000
	external_pressure_bound = 0

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/layer2
	piping_layer = 2
	icon_state = "vent_map-2"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/layer4
	piping_layer = 4
	icon_state = "vent_map-4"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on
	on = TRUE
	icon_state = "vent_map_siphon_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on/layer2
	piping_layer = 2
	icon_state = "vent_map_siphon_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on/layer4
	piping_layer = 4
	icon_state = "vent_map_siphon_on-4"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/layer2
	piping_layer = 2
	icon_state = "vent_map-2"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/layer4
	piping_layer = 4
	icon_state = "vent_map-4"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/on
	on = TRUE
	icon_state = "vent_map_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/on/layer2
	piping_layer = 2
	icon_state = "vent_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/on/layer4
	piping_layer = 4
	icon_state = "vent_map_on-4"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon
	pump_direction = ATMOS_DIRECTION_SIPHONING
	pressure_checks = ATMOS_INTERNAL_BOUND
	internal_pressure_bound = 2000
	external_pressure_bound = 0

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/layer2
	piping_layer = 2
	icon_state = "vent_map-2"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/layer4
	piping_layer = 4
	icon_state = "vent_map-4"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/on
	on = TRUE
	icon_state = "vent_map_siphon_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/on/layer2
	piping_layer = 2
	icon_state = "vent_map_siphon_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/on/layer4
	piping_layer = 4
	icon_state = "vent_map_siphon_on-4"

#undef NO_BOUND
