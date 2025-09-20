/datum/demand_state
	var/current_demand = 0
	var/max_demand = 50          // default max demand if object has none
	var/min_price_factor = 0.2
	var/min_recovery = 1
	var/max_recovery = 5

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

/// Used to return gas value based on demand, expects gas datum and moles.
/proc/get_gas_value(datum/gas/g, moles)
	if(moles <= 0)
		return 0
	// Grab demand state for this gas type
	var/datum/demand_state/state = SSdemand.get_demand_state(g)
	var/demand = state.current_demand / state.max_demand
	var/base_value = g.base_value
	var/demand_ratio = max(demand, state.min_price_factor)

	var/total_value = round(base_value * moles * demand_ratio) // 0.2 * 20 * 0.2

	return total_value
