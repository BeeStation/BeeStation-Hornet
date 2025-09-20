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
		state = new()
		if(ispath(typepath, /obj))
			var/obj/object = new typepath
			state.max_demand = initial(object.max_demand)
		else if(ispath(typepath, /datum/gas))
			var/datum/gas/gas = new typepath
			state.max_demand = initial(gas.max_demand)

		state.current_demand = rand(1, state.max_demand)
		demand_states[typepath] = state
	return state
