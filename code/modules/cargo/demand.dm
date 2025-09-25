/datum/demand_state
	/// How much of this item will CC buy currently, the lower it is the less the item is worth, if it reaches 0 CC won't buy it and it will be sent back.
	var/current_demand = 0
	/// Maximum possible amount of this item that CC will buy. Demand will often try to correct itself to maximum demand during the round.
	var/max_demand
	/// Minimum price multiplier for the item related to demand. The less the demand the lower the multiplyer is until it reaches this value.
	var/min_price_factor = 0.2
	/// Minimum demand recovered during recover_obj_demands(), this is an increase to the demand.
	var/min_recovery = 1
	/// Maximum demand recovered during recover_obj_demands(), this is an increase to the demand.
	var/max_recovery = 5
	/// The random generated price for the item. This is determined by generate_price()
	var/generated_price = 0

/datum/demand_state/New(typepath)
	if(ispath(typepath, /obj))
		var/obj/object = typepath
		max_demand = initial(object.max_demand)
	else if(ispath(typepath, /datum/gas))
		var/datum/gas/gas = typepath
		max_demand = initial(gas.max_demand)
	if(isnull(max_demand))	// If the item isnt getting a max_demand then give it a random one
		max_demand = 5 * rand(5, 12) // Makes sure it increases in increments of 5
	generate_price(typepath)
	current_demand = rand(1, max_demand)

/datum/demand_state/proc/generate_price(obj/object)
	var/price_to_use
	if(ispath(object, /obj/item))
		var/obj/item/thing = object
		if(initial(thing.w_class))	// This ensures item price will not be higher than custom price, if it is set.
			if(initial(thing.custom_price))
				price_to_use = max(5 * rand(1, 5)* initial(thing.w_class) * ECONOMY_MULTIPLIER, initial(thing.custom_price) * PRICE_MARKUP)
			else
				price_to_use = 5 * rand(1, 5) * initial(thing.w_class) * ECONOMY_MULTIPLIER
		else
			price_to_use = max(5 * rand(1, 5) * ECONOMY_MULTIPLIER, initial(thing.custom_price) * PRICE_MARKUP)
	else	// Rand from 5 - 25 (in increments of 5) * the economy multiplier
		price_to_use = 5 * rand(1, 5) * ECONOMY_MULTIPLIER
	generated_price = price_to_use

/datum/demand_state/proc/get_price()
	return generated_price

/// Increases object demand with a slight chance to decrease
/proc/recover_obj_demands()
	for(var/typepath in SSdemand.demand_states)
		var/datum/demand_state/state = SSdemand.demand_states[typepath]
		if(state.current_demand < state.max_demand)
			var/scaled_min_recovery = max(state.min_recovery, round((state.min_recovery / 50) * state.max_demand))
			var/scaled_max_recovery = max(state.max_recovery, round((state.max_recovery / 50) * state.max_demand))
			// Decide if demand goes up or down
			if(prob(45)) // 45% chance to decrease demand
				if(state.max_demand > 10)
					// Reduce demand, but never below 0
					state.current_demand = max(0, state.current_demand - rand(scaled_min_recovery, scaled_max_recovery))
				else
					state.current_demand = max(0, state.current_demand - 1)
			else
				if(state.max_demand > 10)
					state.current_demand += rand(scaled_min_recovery, scaled_max_recovery)
				else
					state.current_demand = max(0, state.current_demand + 1)

			// Cap at max_demand
			if(state.current_demand > state.max_demand)
				state.current_demand = state.max_demand
	// Add radio message to cargo or smt
