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

/// Creates a object demand state datum and calculates max demand
/datum/controller/subsystem/demand/proc/get_demand_state(typepath)
	var/datum/demand_state/state = demand_states[typepath]
	if(isnull(state))
		state = new typepath()
		demand_states[typepath] = state
	return state

/// Used to return gas value based on demand, expects gas datum and moles.
/datum/controller/subsystem/demand/proc/get_gas_value(datum/gas/g, moles)
	if(moles <= 0)
		return 0
	// Grab demand state for this gas type
	var/datum/demand_state/state = SSdemand.get_demand_state(g)
	var/demand = state.current_demand / state.max_demand
	var/base_value = g.base_value
	var/demand_ratio = max(demand, state.min_price_factor)

	var/total_value = round(base_value * moles * demand_ratio) // 0.2 * 20 * 0.2

	return total_value
