/**
 * Main atmos processes
 * process() Organizes all other calls, and is the best starting point for top-level logic.
 */

/obj/machinery/atmospherics/components/unary/rbmk/core/process(delta_time)
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
		atmos_process(delta_time)
		damage_handler(delta_time)
		check_alert()
		soundloop.volume = clamp((power / 2), 0, 35)
	update_pipenets()
	update_appearance()

	if(COOLDOWN_FINISHED(src, next_stat_interval))
		update_logged_data()

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/atmos_process(delta_time)
	var/datum/gas_mixture/coolant_input = linked_input.airs[1]
	var/datum/gas_mixture/moderator_input = linked_moderator.airs[1]
	var/datum/gas_mixture/coolant_output = linked_output.airs[1]

	// cache gas input parameters
	var/input_moles = coolant_input.total_moles() //Firstly. Do we have enough moles of coolant?
	var/input_pressure = coolant_input.return_pressure()
	var/output_pressure = coolant_output.return_pressure()

	pressure = output_pressure // set our pressure to the pressure of the coolant output (NB: this is taken before adding gases so oscillations are not setup from our output buffer not immediately equalising with the external pipenet)
	last_output_temperature = coolant_output.temperature // used for GUI

	if(temperature < 0) // Not letting temperature get into the negatives, because -22% power is just absurd.
		temperature = 0

	power = (temperature / RBMK_TEMPERATURE_CRITICAL) * 100

	// First, deal with things that heat us up
	var/radioactivity_spice_multiplier = 1 //Some gasses make the reactor a bit spicy.
	var/depletion_modifier = 0.035 //How rapidly do your rods decay
	gas_absorption_effectiveness = gas_absorption_constant
	last_power_produced = 0

	//Next up, handle moderators!
	var/moderator_input_total_mols = moderator_input.total_moles()
	if (has_fuel()) // don't use moderator if there isn't any fuel (where would it go?!)
		if(moderator_input_total_mols >= minimum_coolant_level)
			var/total_fuel_moles = GET_MOLES(/datum/gas/plasma, moderator_input) + (GET_MOLES(/datum/gas/nitrous_oxide, moderator_input)*2) + (GET_MOLES(/datum/gas/tritium, moderator_input)*10) //n2o is 50% more efficient as fuel than plasma, but is harder to produce
			var/power_modifier = max(GET_MOLES(/datum/gas/oxygen, moderator_input) / moderator_input_total_mols * 10, 1) //You can never have a negative power modifier. For now.
			if(total_fuel_moles >= minimum_coolant_level) //You at least need SOME fuel if you want to make some power.
				var/power_produced = max((total_fuel_moles / moderator_input_total_mols * 10), 1)
				last_power_produced = max(0,((power_produced*power_modifier)*moderator_input_total_mols))
				last_power_produced *= (max(0,power)/100) //Aaaand here comes the cap. Hotter reactor => more power.
				radioactivity_spice_multiplier += GET_MOLES(/datum/gas/tritium, moderator_input) / 5 //Chernobyl 2.
				if(power >= 20)
					ADD_MOLES(/datum/gas/tritium, coolant_output, total_fuel_moles/20) //Shove out tritium into the air when it's fuelled. You need to filter this off, or you're gonna have a bad time.

			var/total_control_moles = GET_MOLES(/datum/gas/nitrogen, moderator_input) + (GET_MOLES(/datum/gas/carbon_dioxide, moderator_input)*4) + (GET_MOLES(/datum/gas/pluoxium, moderator_input)*8) //N2 helps you control the reaction at the cost of making it absolutely blast you with rads. Pluoxium has the same effect but without the rads!
			if(total_control_moles >= minimum_coolant_level)
				var/control_bonus = total_control_moles / 250 //1 mol of n2 -> 0.002 bonus control rod effectiveness, if you want a super controlled reaction, you'll have to sacrifice some power.
				control_rod_effectiveness = initial(control_rod_effectiveness) + control_bonus
				radioactivity_spice_multiplier += GET_MOLES(/datum/gas/nitrogen, moderator_input) / 25 //An example setup of 50 moles of n2 (for dealing with spent fuel) leaves us with a radioactivity spice multiplier of 3.
				radioactivity_spice_multiplier += GET_MOLES(/datum/gas/carbon_dioxide, moderator_input) / 12.5
			var/total_permeability_moles = GET_MOLES(/datum/gas/bz, moderator_input) + (GET_MOLES(/datum/gas/water_vapor, moderator_input)*2) + (GET_MOLES(/datum/gas/hypernoblium, moderator_input)*10)
			if(total_permeability_moles >= minimum_coolant_level)
				var/permeability_bonus = total_permeability_moles / 500
				gas_absorption_effectiveness = gas_absorption_constant + permeability_bonus
			var/total_degradation_moles = GET_MOLES(/datum/gas/nitrium, moderator_input) //Because it's quite hard to get.
			if(total_degradation_moles >= minimum_coolant_level*0.5) //I'll be nice.
				depletion_modifier += total_degradation_moles / 15 //Oops! All depletion. This causes your fuel rods to get SPICY.
				playsound(src, pick('sound/machines/sm/accent/normal/1.ogg','sound/machines/sm/accent/normal/2.ogg','sound/machines/sm/accent/normal/3.ogg','sound/machines/sm/accent/normal/4.ogg','sound/machines/sm/accent/normal/5.ogg'), 100, TRUE)
			//From this point onwards, we clear out the remaining gasses.
			moderator_input.remove(moderator_input_total_mols) //Woosh. And the soul is gone.
			rate_of_reaction += total_fuel_moles / 1000

	var/fuel_power = 0 //So that you can't magically generate rate_of_reaction with your control rods.
	if(!has_fuel())  //Reactor must be fuelled and ready to go before we can heat it up boys.
		rate_of_reaction = 0
		last_power_produced = 0 // no free-wheeling power from a hot reactor!
		power = 0
	else
		for(var/obj/item/fuel_rod/reactor_fuel_rod in fuel_rods)
			rate_of_reaction += reactor_fuel_rod.fuel_power
			fuel_power += reactor_fuel_rod.fuel_power
			reactor_fuel_rod.deplete(depletion_modifier)

	// find the difference between the what we want to be at, and the current rate
	var/difference = abs(rate_of_reaction - desired_reate_of_reaction)
	//Then, hit as much of that goal with our control rod effectiveness
	difference = clamp(difference, 0, control_rod_effectiveness) //And we can't instantly zap the rate_of_reaction to what we want, so let's zap as much of it as we can manage....
	if(difference > fuel_power && desired_reate_of_reaction > rate_of_reaction)
		difference = 0 //Again, to stop you being able to run off of 1 fuel rod. (we've already added in one x fuel power in the fuel rod calculation above)
	if(rate_of_reaction != desired_reate_of_reaction)
		if(desired_reate_of_reaction > rate_of_reaction)
			rate_of_reaction += difference
		else if(desired_reate_of_reaction < rate_of_reaction)
			rate_of_reaction -= difference

	rate_of_reaction = clamp(rate_of_reaction, 0, RBMK_MAX_CRITICALITY) // let's try not to go turbonuclear immediately

	// take rate_of_reaction, or the power produced scaled down to a similar range as our temperature gain (if no moderator is applied, this will be just rate_of_reaction. with extra gases it can get interesting!)
	var/equivalent_temperature_gain = last_power_produced * RBMK_POWER_TO_TEMPERATURE_MULTIPLIER
	var/temperature_gain = rate_of_reaction * max(1, equivalent_temperature_gain) * RBMK_TEMPERATURE_MULTIPLIER // as this temperature rise is applied after cooling, if sudden changes in rate_of_reaction occur the temperature can rise very quickly!

	// apply the temperature gain
	if(has_fuel())
		temperature += temperature_gain
	else
		temperature -= 10 //Nothing to heat us up, so.

	// now we've heated, cool the reactor based off of the coolant.
	if((input_moles >= minimum_coolant_level) && (input_pressure > output_pressure))
		last_coolant_temperature = clamp(coolant_input.temperature, TCMB, INFINITY)
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		var/heat_delta = (last_coolant_temperature - temperature) * RBMK_BASE_COOLING_FACTOR * gas_absorption_effectiveness //Take in the gas as a cooled input, cool the reactor a bit. The optimum, 100% balanced reaction sits at rate_of_reaction=1, coolant input temp of 200K / -73 celsius.
		last_heat_delta = heat_delta // HEAT DELTA COULD BE NEGATIVE!!

		temperature += heat_delta
		temperature = clamp(temperature, TCMB, INFINITY) // ensure nothing silly happens

		// calculate how many moles to transfer to equalise pressures
		// use similar calculation to circulators - move the required number of moles to equalise the pressures (with a restriction as we don't want things to be too easy)
		var/pressure_delta = (input_pressure - output_pressure) / 2 * RBMK_COOLANT_FLOW_RESTRICTION
		var/output_temperature = clamp(coolant_output.temperature, last_coolant_temperature, INFINITY) // output should not be lower than input gas (at least until it subtracts heat_delta), and not return 0 if the output is empty
		var/transfer_moles = (pressure_delta*coolant_input.return_volume())/(output_temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = coolant_input.remove(transfer_moles)

		// changed the moved gas' temperature by the heat delta (remembering negative heat delta is cooling the reactor, heating up coolant gas)
		if (heat_delta<0)
			heat_delta *= RBMK_COOLANT_TEMPERATURE_MULTIPLIER // make it harder to cool down output gases

		removed.temperature -= heat_delta

		coolant_output.merge(removed)

		no_coolant_ticks = max(0, no_coolant_ticks-2)	//Needs half as much time to recover the ticks than to acquire them
	else
		if(has_fuel())
			no_coolant_ticks++
			if(no_coolant_ticks > RBMK_NO_COOLANT_TOLERANCE)
				temperature += temperature / 500 //This isn't really harmful early game, but when your reactor is up to full power, this can get out of hand quite quickly.
				critical_threshold_proximity += ((temperature / 200) * delta_time) //Think fast loser.
				check_alert()
				playsound(src, 'sound/weapons/smash.ogg', 50, 1) //Just for the sound effect, to let you know you've fucked up.


	update_icon()
	radiation_pulse(src, max_range = 6, threshold = RAD_EXTREME_INSULATION, intensity = clamp(temperature * radioactivity_spice_multiplier / 100, 0, DEFAULT_RADIATION_INTENSITY))

	if(power >= 90 && world.time >= next_flicker) //You're overloading the reactor. Give a more subtle warning that power is getting out of control.
		next_flicker = world.time + 1 MINUTES
		for(var/obj/machinery/light/light in GLOB.machines)
			if(DT_PROB(75, delta_time)) //If youre running the reactor cold though, no need to flicker the lights.
				light.flicker()
	for(var/atom/movable/object in get_turf(src))
		if(isliving(object) && temperature > 0)
			var/mob/living/living_mob = object
			living_mob.adjust_bodytemperature(clamp(temperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!
	if(grilled_item)
		SEND_SIGNAL(grilled_item, COMSIG_ITEM_GRILLED, grilled_item, delta_time)
		grill_time += delta_time
		grilled_item.AddComponent(/datum/component/sizzle)



	last_power_produced *= 5*fuel_power //Finally, we turn it into actual usable numbers. more fuel power => more power (push people towards using more than 1 fuel rod, otherwise it's boring). 5x scales one new fuel rod = 1.0 multiplier
	last_power_produced = min(RBMK_POWER_FLAVOURISER_LOW * (last_power_produced ** 2), RBMK_POWER_FLAVOURISER_HIGH * last_power_produced) // scale according to square law up until linear relationship takes over
	last_power_produced += fuel_power * 500000 //Passively make 50KW per fuel rod if we dont have moderator

	var/turf/reactor_turf = get_turf(src)
	var/obj/structure/cable/reactor_cable = reactor_turf.get_cable_node()
	if(reactor_cable)
		reactor_cable.get_connections()
		reactor_cable.add_avail(last_power_produced)
