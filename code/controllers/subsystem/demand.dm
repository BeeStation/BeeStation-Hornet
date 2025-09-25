SUBSYSTEM_DEF(demand)
	name = "Demand"
	wait = 2.5 MINUTES
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME
	var/list/datum/demand_state/demand_states = list()

/datum/controller/subsystem/demand/fire()
	if(world.time < SSticker.round_start_time + 10 MINUTES)
		return
	recover_obj_demands()

/// Increases object demand with a slight chance to decrease
/datum/controller/subsystem/demand/proc/recover_obj_demands()
	for(var/typepath in demand_states)
		var/datum/demand_state/state = demand_states[typepath]
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
	// TO_DO: Add radio message to cargo or smt (i don't know how to)

/// Creates a object demand state datum and calculates max demand
/datum/controller/subsystem/demand/proc/get_demand_state(typepath)
	var/datum/demand_state/state = demand_states[typepath]
	if(isnull(state))
		state = new(typepath)
		demand_states[typepath] = state
	return state

/// Used to return gas value based on demand, expects gas datum and moles.
/datum/controller/subsystem/demand/proc/get_gas_value(datum/gas/current_gas, moles)
	if(moles <= 0)
		return 0
	// Grab demand state for this gas type
	var/datum/demand_state/state = SSdemand.get_demand_state(current_gas)
	var/demand = state.current_demand / state.max_demand
	var/base_value = current_gas.base_value
	var/demand_ratio = max(demand, state.min_price_factor)

	var/total_value = round(base_value * moles * demand_ratio) // 0.2 * 20 * 0.2

	return total_value
