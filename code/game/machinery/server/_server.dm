/obj/machinery/server
	name = "Server"
	desc = "You should not be seeing this."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "message_server_off"

	var/efficiency = 1 // 100%
	var/overheated_temp = T0C + 100

	var/datum/gas_mixture/server_air

	var/heat_generation = 0

/obj/machinery/server/Initialize()
	. = ..()
	SSair.start_processing_machine(src)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/server/examine(mob/user)
	. = ..()
	. += "The status display reads: [round(efficiency * 100, 2)]% efficiency."

/obj/machinery/server/LateInitialize()
	. = ..()
	var/turf/turf = get_turf(src)
	if(turf)
		server_air = turf.return_air().copy()
		server_air.set_temperature(T20C)
	else
		server_air = new /datum/gas_mixture
		server_air.set_temperature(T20C)

/obj/machinery/server/process_atmos()
	calculate_temperature()
	if(server_air.return_temperature() > overheated_temp)
		efficiency = 0
		set_machine_stat(machine_stat | OVERHEATED)
	else
		set_machine_stat(machine_stat & ~OVERHEATED)
		efficiency = clamp(1 - ((server_air.return_temperature() - T20C) / (overheated_temp - T20C)), 0, 1)
		server_air.adjust_heat(heat_generation)
		heat_generation = 0

/obj/machinery/server/use_power(amount, chan)
	. = ..()
	heat_generation += amount * 1000

/obj/machinery/server/proc/calculate_temperature()
	var/turf/turf = get_turf(src)
	if(!turf)
		return FALSE
	var/datum/gas_mixture/environment = turf.return_air()

	// Share gas and temperature between the server and the environment
	server_air.share(environment)
	server_air.temperature_share(environment, OPEN_HEAT_TRANSFER_COEFFICIENT)
	// Debug output
	var/efficiency_status = efficiency ? "Efficiency: [efficiency]" : "OVERHEATED"
	debug_world("Server temperature: [server_air.return_temperature()], [efficiency_status]")
