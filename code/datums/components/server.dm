/datum/component/server
	/// Our efficiency from 0% to 100%.
	/// Not used by this component directly, but can be used by machines to determine how well they're working.
	var/efficiency = 1

	/// The current temperature of the server. Dissipates into the enviroment over time
	var/temperature = T20C
	/// The temperature at which we stop working.
	var/overheat_temp = T0C + 100
	/// The heat capacity used in temperature dissipation.
	/// Since we, relatively speaking, don't process frequently, we want this number low
	var/heat_capacity = 250
	/// How much heat power this machine has stored up. Increased when our parent machine uses power.
	var/heat_stored = 0

	COOLDOWN_DECLARE(spark_cooldown)

/datum/component/server/Initialize()
	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSprocessing, src)

/datum/component/server/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MACHINERY_POWER_USED, PROC_REF(on_power_used))

/datum/component/server/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MACHINERY_POWER_USED)

/datum/component/server/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/component/server/proc/on_power_used(obj/machinery/source, amount, chan)
	heat_stored += amount

/datum/component/server/process(delta_time)
	var/obj/machinery/parent_machine = parent

	// Absorb the heat from our parent machine using power
	temperature += heat_stored
	heat_stored = 0

	// Dissipate heat into the environment
	var/turf/open/our_turf = get_turf(parent_machine)
	if(istype(our_turf))
		var/datum/gas_mixture/environment = our_turf.return_air()
		temperature = environment.temperature_share(null, OPEN_HEAT_TRANSFER_COEFFICIENT, temperature, heat_capacity)
		our_turf.air_update_turf(FALSE, FALSE)

	// Handle overheating
	if(temperature > overheat_temp)
		parent_machine.set_machine_stat(parent_machine.machine_stat | OVERHEATED)
		efficiency = 0
		// Try to spark
		if(prob(25) && COOLDOWN_FINISHED(src, spark_cooldown))
			COOLDOWN_START(src, spark_cooldown, 10 SECONDS)
			do_sparks(5, FALSE, parent)
		return
	parent_machine.set_machine_stat(parent_machine.machine_stat & ~OVERHEATED)

	// Update efficiency
	var/efficiency_change = (temperature - T20C) / (overheat_temp - T20C)
	efficiency = clamp(1 - efficiency_change, 0, 1)
