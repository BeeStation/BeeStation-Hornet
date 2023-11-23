/obj/machinery/server
    name = "Server"
    desc = "You should not be seeing this."
    icon = 'icons/obj/machines/telecomms.dmi'
    icon_state = "message_server_off"

    var/efficiency = 1 // 100%
    var/temperature = T20C
    var/overheated_temp = T0C + 100
    var/heat_generation = 500000
    var/cooling_factor = 0.1


/obj/machinery/server/Initialize()
    . = ..()
    SSair.start_processing_machine(src)

/obj/machinery/server/process_atmos()
    calculate_temperature()
    if(temperature > overheated_temp)
        efficiency = 0
    else
        efficiency = max(0, 1 - ((temperature - T20C) / (overheated_temp - T20C)))

/obj/machinery/server/proc/calculate_temperature()
    var/turf/turf = get_turf(src)
    if(!turf)
        return 0
    var/datum/gas_mixture/environment = turf.return_air()

    var/heat_capacity = environment.heat_capacity()
    var/mass = environment.total_moles()

    var/env_temperature = environment.return_temperature()
    var/deltaTemperature = env_temperature - temperature

    if(deltaTemperature > 0) // environment is hotter
        var/req_power = deltaTemperature * heat_capacity
        req_power = min(req_power, heat_generation)

        var/transfered = req_power / heat_capacity
        temperature += transfered / (mass * heat_capacity)
        environment.adjust_heat(-transfered) // adjust environment's heat based on the heat transferred
    else if(deltaTemperature < 0) // environment is cooler
        temperature += deltaTemperature * cooling_factor
    if(temperature < overheated_temp)
        temperature += heat_generation / (mass * heat_capacity)
        environment.adjust_heat(heat_generation) // adjust environment's heat based on the heat generated

    debug_world("ST: [temperature], SE: [env_temperature], HC:[heat_capacity], SD: [deltaTemperature]")
    air_update_turf()
    return temperature
