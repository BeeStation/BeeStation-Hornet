
#define GASMINER_POWER_NONE 0
#define GASMINER_POWER_STATIC 1
#define GASMINER_POWER_MOLES 2	//Scaled from here on down.
#define GASMINER_POWER_KPA 3
#define GASMINER_POWER_FULLSCALE 4


/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/components/miners.dmi'
	icon_state = "miner"
	density = FALSE
	resistance_flags = INDESTRUCTIBLE|ACID_PROOF|FIRE_PROOF
	interacts_with_air = TRUE
	var/spawn_id = null
	var/spawn_temp = T20C
	/// Moles of gas to spawn per second
	var/spawn_mol = MOLES_CELLSTANDARD * 5
	var/max_ext_mol = INFINITY
	var/max_ext_kpa = 6500
	var/overlay_color = "#FFFFFF"
	var/active = TRUE
	var/power_draw = 0
	var/power_draw_static = 2000
	var/power_draw_dynamic_mol_coeff = 5	//DO NOT USE DYNAMIC SETTINGS UNTIL SOMEONE MAKES A USER INTERFACE/CONTROLLER FOR THIS!
	var/power_draw_dynamic_kpa_coeff = 0.5
	var/broken = FALSE
	var/broken_message = "ERROR"
	idle_power_usage = 150
	active_power_usage = 3000

/obj/machinery/atmospherics/miner/Initialize(mapload)
	. = ..()
	set_active(active)				//Force overlay update.

/obj/machinery/atmospherics/miner/examine(mob/user)
	. = ..()
	if(broken)
		. += {"Its debug output is printing "[broken_message]"."}

/obj/machinery/atmospherics/miner/proc/check_operation()
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	if(!isopenturf(T))
		broken_message = "<span class='boldnotice'>VENT BLOCKED</span>"
		set_broken(TRUE)
		return FALSE
	var/turf/open/OT = T
	if(OT.planetary_atmos)
		broken_message = "<span class='boldwarning'>DEVICE NOT ENCLOSED IN A PRESSURIZED ENVIRONMENT</span>"
		set_broken(TRUE)
		return FALSE
	if(isspaceturf(T))
		broken_message = "<span class='boldnotice'>AIR VENTING TO SPACE</span>"
		set_broken(TRUE)
		return FALSE
	var/datum/gas_mixture/G = OT.return_air()
	if(G.return_pressure() > (max_ext_kpa - ((spawn_mol*spawn_temp*R_IDEAL_GAS_EQUATION)/(CELL_VOLUME))))
		broken_message = "<span class='boldwarning'>EXTERNAL PRESSURE OVER THRESHOLD</span>"
		set_broken(TRUE)
		return FALSE
	if(G.total_moles() > max_ext_mol)
		broken_message = "<span class='boldwarning'>EXTERNAL AIR CONCENTRATION OVER THRESHOLD</span>"
		set_broken(TRUE)
		return FALSE
	if(broken)
		set_broken(FALSE)
		broken_message = ""
	return TRUE

/obj/machinery/atmospherics/miner/proc/set_active(setting)
	if(active != setting)
		active = setting
		update_icon()

/obj/machinery/atmospherics/miner/proc/set_broken(setting)
	if(broken != setting)
		broken = setting
		update_icon()

/obj/machinery/atmospherics/miner/proc/update_power()
	if(!active)
		active_power_usage = idle_power_usage
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()
	var/P = G.return_pressure()
	switch(power_draw)
		if(GASMINER_POWER_NONE)
			update_use_power(ACTIVE_POWER_USE, 0)
		if(GASMINER_POWER_STATIC)
			update_use_power(ACTIVE_POWER_USE, power_draw_static)
		if(GASMINER_POWER_MOLES)
			update_use_power(ACTIVE_POWER_USE, spawn_mol * power_draw_dynamic_mol_coeff)
		if(GASMINER_POWER_KPA)
			update_use_power(ACTIVE_POWER_USE, P * power_draw_dynamic_kpa_coeff)
		if(GASMINER_POWER_FULLSCALE)
			update_use_power(ACTIVE_POWER_USE, (spawn_mol * power_draw_dynamic_mol_coeff) + (P * power_draw_dynamic_kpa_coeff))

/obj/machinery/atmospherics/miner/proc/do_use_power(amount)
	var/turf/T = get_turf(src)
	if(T && istype(T))
		var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
		if(C && C.powernet && (C.powernet.avail > amount))
			C.powernet.load += amount
			return TRUE
	if(powered())
		use_power(amount)
		return TRUE
	return FALSE

/obj/machinery/atmospherics/miner/update_icon()
	cut_overlays()
	if(broken)
		add_overlay("broken")
	else if(active)
		var/mutable_appearance/on_overlay = mutable_appearance(icon, "on")
		on_overlay.color = overlay_color
		add_overlay(on_overlay)

/obj/machinery/atmospherics/miner/process_atmos() //TODO figure out delta_time for this
	update_power()
	check_operation()
	if(active && !broken)
		if(isnull(spawn_id))
			return FALSE
		if(do_use_power(active_power_usage))
			mine_gas()

/obj/machinery/atmospherics/miner/proc/mine_gas(delta_time = 2)
	var/turf/open/O = get_turf(src)
	if(!isopenturf(O))
		return FALSE
	var/datum/gas_mixture/merger = new
	merger.set_moles(spawn_id, spawn_mol * delta_time)
	merger.set_temperature(spawn_temp)
	O.assume_air(merger)
	O.air_update_turf(TRUE)

/obj/machinery/atmospherics/miner/attack_ai(mob/living/silicon/user)
	if(broken)
		to_chat(user, "[src] seems to be broken. Its debug interface outputs: [broken_message]")
	..()

/obj/machinery/atmospherics/miner/n2o
	name = "\improper N2O Gas Miner"
	overlay_color = "#FFCCCC"
	spawn_id = GAS_NITROUS

/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	overlay_color = "#CCFFCC"
	spawn_id = GAS_N2

/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	overlay_color = "#007FFF"
	spawn_id = GAS_O2

/obj/machinery/atmospherics/miner/toxins
	name = "\improper Plasma Gas Miner"
	overlay_color = "#FF0000"
	spawn_id = GAS_PLASMA

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	overlay_color = "#CDCDCD"
	spawn_id = GAS_CO2

/obj/machinery/atmospherics/miner/bz
	name = "\improper BZ Gas Miner"
	overlay_color = "#FAFF00"
	spawn_id = GAS_BZ

/obj/machinery/atmospherics/miner/water_vapor
	name = "\improper Water Vapor Gas Miner"
	overlay_color = "#99928E"
	spawn_id = GAS_H2O

/obj/machinery/atmospherics/miner/station
	power_draw = GASMINER_POWER_FULLSCALE
	spawn_mol = MOLES_CELLSTANDARD / 10
	max_ext_kpa = 2500

/obj/machinery/atmospherics/miner/station/n2o
	name = "\improper N2O Gas Miner"
	overlay_color = "#FFCCCC"
	spawn_id = GAS_NITROUS

/obj/machinery/atmospherics/miner/station/nitrogen
	name = "\improper N2 Gas Miner"
	overlay_color = "#CCFFCC"
	spawn_id = GAS_N2

/obj/machinery/atmospherics/miner/station/oxygen
	name = "\improper O2 Gas Miner"
	overlay_color = "#007FFF"
	spawn_id = GAS_O2

/obj/machinery/atmospherics/miner/station/toxins
	name = "\improper Plasma Gas Miner"
	overlay_color = "#FF0000"
	spawn_id = GAS_PLASMA

/obj/machinery/atmospherics/miner/station/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	overlay_color = "#CDCDCD"
	spawn_id = GAS_CO2

/obj/machinery/atmospherics/miner/station/bz
	name = "\improper BZ Gas Miner"
	overlay_color = "#FAFF00"
	spawn_id = GAS_BZ

/obj/machinery/atmospherics/miner/station/water_vapor
	name = "\improper Water Vapor Gas Miner"
	overlay_color = "#99928E"
	spawn_id = GAS_H2O


#undef GASMINER_POWER_NONE
#undef GASMINER_POWER_STATIC
#undef GASMINER_POWER_MOLES
#undef GASMINER_POWER_KPA
#undef GASMINER_POWER_FULLSCALE
