/**
 * Main atmos processes
 * process() Organizes all other calls, and is the best starting point for top-level logic.
 */

/obj/machinery/atmospherics/components/unary/rbmk/core/process(seconds_per_tick)
	//Pre-Checks

	//first check if the machine is active
	if(!active)
		return

	//then check if the other machines are still there
	if(!check_part_connectivity())
		deactivate()
		return
	// Run the reaction if it is either live or being started
	if (start_power || power)
		atmos_process(seconds_per_tick)
		damage_handler()
		check_alert()
	update_pipenets()
	update_appearance()

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/atmos_process(seconds_per_tick)
	var/datum/gas_mixture/coolant_input = linked_input.airs[1]
	var/datum/gas_mixture/moderator_input = linked_moderator.airs[1]
	var/datum/gas_mixture/coolant_output = linked_output.airs[1]

	//Firstly, heat up the reactor based off of K.
	var/input_moles = coolant_input.total_moles() //Firstly. Do we have enough moles of coolant?
	if(input_moles >= minimum_coolant_level)
		last_coolant_temperature = coolant_input.return_temperature()-273.15
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		var/heat_delta = ((coolant_input.return_temperature()-273.15) / 100) * gas_absorption_effectiveness //Take in the gas as a cooled input, cool the reactor a bit. The optimum, 100% balanced reaction sits at K=1, coolant input temp of 200K / -73 celsius.
		last_heat_delta = heat_delta
		temperature += heat_delta
		coolant_output.merge(coolant_input) //And now, shove the input into the output.
		coolant_input.clear() //Clear out anything left in the input gate.
		no_coolant_ticks = max(0, no_coolant_ticks-2)	//Needs half as much time to recover the ticks than to acquire them
	else
		if(has_fuel())
			no_coolant_ticks++
			if(no_coolant_ticks > RBMK_NO_COOLANT_TOLERANCE)
				temperature += temperature / 500 //This isn't really harmful early game, but when your reactor is up to full power, this can get out of hand quite quickly.
				critical_threshold_proximity += temperature / 200 //Think fast loser.
				take_damage(10) //Just for the sound effect, to let you know you've fucked up.

	//Now, heat up the output and set our pressure.
	coolant_output.set_temperature(temperature+273.15) //Heat the coolant output gas that we just had pass through us.
	last_output_temperature = coolant_output.return_temperature()-273.15
	pressure = coolant_output.return_pressure()
	power = (temperature / RBMK_TEMPERATURE_CRITICAL) * 100
	if(power < 0) // Not letting power get into the negatives, because -22% power is just absurd.
		temperature = 0
	var/radioactivity_spice_multiplier = 1 //Some gasses make the reactor a bit spicy.
	var/depletion_modifier = 0.035 //How rapidly do your rods decay
	gas_absorption_effectiveness = gas_absorption_constant
	//Next up, handle moderators!
	if(moderator_input.total_moles() >= minimum_coolant_level)
		var/total_fuel_moles = moderator_input.get_moles(GAS_PLASMA) + (moderator_input.get_moles(GAS_NITROUS)*2)+ (moderator_input.get_moles(GAS_TRITIUM)*10) //n2o is 50% more efficient as fuel than plasma, but is harder to produce
		var/power_modifier = max((moderator_input.get_moles(GAS_O2) / moderator_input.total_moles() * 10), 1) //You can never have negative IPM. For now.
		if(total_fuel_moles >= minimum_coolant_level) //You at least need SOME fuel.
			var/power_produced = max((total_fuel_moles / moderator_input.total_moles() * 10), 1)
			last_power_produced = max(0,((power_produced*power_modifier)*moderator_input.total_moles()))
			last_power_produced *= (max(0,power)/100) //Aaaand here comes the cap. Hotter reactor => more power.
			last_power_produced *= base_power_modifier //Finally, we turn it into actual usable numbers.
			radioactivity_spice_multiplier += moderator_input.get_moles(GAS_TRITIUM) / 5 //Chernobyl 2.
			if(power >= 20)
				coolant_output.adjust_moles(GAS_TRITIUM, total_fuel_moles/20) //Shove out tritium into the air when it's fuelled. You need to filter this off, or you're gonna have a bad time.
			var/turf/T = get_turf(src)
			var/obj/structure/cable/C = T.get_cable_node()
			if (!C)
				return
			C.get_connections()
			C.add_avail(last_power_produced)

		var/total_control_moles = moderator_input.get_moles(GAS_N2) + (moderator_input.get_moles(GAS_CO2)*4) + (moderator_input.get_moles(GAS_PLUOXIUM)*8) //N2 helps you control the reaction at the cost of making it absolutely blast you with rads. Pluoxium has the same effect but without the rads!
		if(total_control_moles >= minimum_coolant_level)
			var/control_bonus = total_control_moles / 250 //1 mol of n2 -> 0.002 bonus control rod effectiveness, if you want a super controlled reaction, you'll have to sacrifice some power.
			control_rod_effectiveness = initial(control_rod_effectiveness) + control_bonus
			radioactivity_spice_multiplier += moderator_input.get_moles(GAS_N2) / 25 //An example setup of 50 moles of n2 (for dealing with spent fuel) leaves us with a radioactivity spice multiplier of 3.
			radioactivity_spice_multiplier += moderator_input.get_moles(GAS_CO2) / 12.5
		var/total_permeability_moles = moderator_input.get_moles(GAS_BZ) + (moderator_input.get_moles(GAS_H2O)*2) + (moderator_input.get_moles(GAS_HYPERNOB)*10)
		if(total_permeability_moles >= minimum_coolant_level)
			var/permeability_bonus = total_permeability_moles / 500
			gas_absorption_effectiveness = gas_absorption_constant + permeability_bonus
		var/total_degradation_moles = moderator_input.get_moles(GAS_NITRYL) //Because it's quite hard to get.
		if(total_degradation_moles >= minimum_coolant_level*0.5) //I'll be nice.
			depletion_modifier += total_degradation_moles / 15 //Oops! All depletion. This causes your fuel rods to get SPICY.
			playsound(src, pick('sound/machines/sm/accent/normal/1.ogg','sound/machines/sm/accent/normal/2.ogg','sound/machines/sm/accent/normal/3.ogg','sound/machines/sm/accent/normal/4.ogg','sound/machines/sm/accent/normal/5.ogg'), 100, TRUE)
		//From this point onwards, we clear out the remaining gasses.
		moderator_input.clear() //Woosh. And the soul is gone.
		K += total_fuel_moles / 1000
	var/fuel_power = 0 //So that you can't magically generate K with your control rods.
	if(!has_fuel())  //Reactor must be fuelled and ready to go before we can heat it up boys.
		K = 0
	else
		for(var/obj/item/fuel_rod/FR in fuel_rods)
			K += FR.fuel_power
			fuel_power += FR.fuel_power
			FR.deplete(depletion_modifier)
	//Firstly, find the difference between the two numbers.
	var/difference = abs(K - desired_k)
	//Then, hit as much of that goal with our cooling per tick as we possibly can.
	difference = clamp(difference, 0, control_rod_effectiveness) //And we can't instantly zap the K to what we want, so let's zap as much of it as we can manage....
	if(difference > fuel_power && desired_k > K)
		difference = fuel_power //Again, to stop you being able to run off of 1 fuel rod.
	if(K != desired_k)
		if(desired_k > K)
			K += difference
		else if(desired_k < K)
			K -= difference

	K = clamp(K, 0, RBMK_MAX_CRITICALITY)
	if(has_fuel())
		temperature += K
	else
		temperature -= 10 //Nothing to heat us up, so.
	check_alert() //Let's check if they're about to die, and let them know.
	update_icon()
	radiation_pulse(src, temperature*radioactivity_spice_multiplier)
	if(power >= 90 && world.time >= next_flicker) //You're overloading the reactor. Give a more subtle warning that power is getting out of control.
		next_flicker = world.time + 1 MINUTES
		for(var/obj/machinery/light/L in GLOB.machines)
			if(DT_PROB(75, seconds_per_tick)) //If youre running the reactor cold though, no need to flicker the lights.
				L.flicker()
	for(var/atom/movable/I in get_turf(src))
		if(isliving(I) && temperature > 0)
			var/mob/living/L = I
			L.adjust_bodytemperature(clamp(temperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!
	if(grilled_item)
		SEND_SIGNAL(grilled_item, COMSIG_ITEM_GRILLED, grilled_item, seconds_per_tick)
		grill_time += seconds_per_tick
		grilled_item.AddComponent(/datum/component/sizzle)

