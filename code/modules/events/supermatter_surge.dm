/datum/round_event_control/supermatter_surge
	name = "Supermatter Surge"
	typepath = /datum/round_event/supermatter_surge
	weight = 20
	max_occurrences = 4
	earliest_start = 10 MINUTES

/datum/round_event_control/supermatter_surge/canSpawnEvent()
	if(GLOB.main_supermatter_engine?.has_been_powered)
		return ..()

/datum/round_event/supermatter_surge
	announceWhen = 1
	var/power = 2000

/datum/round_event/supermatter_surge/setup()
	if(prob(70))
		power = rand(200,100000)
	else
		power = rand(200,200000)
/datum/round_event/supermatter_surge/announce()
	var/severity = ""
	switch(power)
		if(-INFINITY to 100000)
			var/low_threat_perc = 100-round(100*((power-200)/(100000-200)))
			if(prob(low_threat_perc))
				if(prob(low_threat_perc))
					severity = "low; the supermatter should return to normal operation shortly."
				else
					severity = "medium; the supermatter should return to normal operation, but regardless, check if the emitters may need to be turned off temporarily."
			else
				severity = "high; the emitters likely need to be turned off, and if the supermatter's cooling loop is not fortified, pre-cooled gas may need to be added."
		if(100000 to INFINITY)
			severity = "extreme; emergency action is likely to be required even if coolant loop is fine. Turn off the emitters and make sure the loop is properly cooling gases."
	if(power > 20000 || prob(round(power/200)))
		priority_announce("Supermatter surge detected. Estimated severity is [severity]", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/supermatter_surge/start()
	var/obj/machinery/power/supermatter_crystal/supermatter = GLOB.main_supermatter_engine
	var/power_proportion = supermatter.powerloss_inhibitor/2 // what % of the power goes into matter power, at most 50%
	// we reduce the proportion that goes into actual matter power based on powerloss inhibitor
	// primarily so the supermatter doesn't tesla the instant these happen
	supermatter.matter_power += power * power_proportion
	var/datum/gas_mixture/gas_puff = new
	var/selected_gas = pick(4;GAS_CO2, 4;GAS_H2O, 1;GAS_BZ)
	gas_puff.set_moles(selected_gas, 500)
	gas_puff.set_temperature(500)
	var/energy_ratio = (power * 500 * (1-power_proportion)) / gas_puff.thermal_energy()
	if(energy_ratio < 1) // energy output we want is lower than current energy, reduce the amount of gas we puff out
		gas_puff.set_moles(GAS_H2O, energy_ratio * 500)
	else // energy output we want is higher than current energy, increase its actual heat
		gas_puff.set_temperature(energy_ratio * 500)
	supermatter.assume_air(gas_puff)
