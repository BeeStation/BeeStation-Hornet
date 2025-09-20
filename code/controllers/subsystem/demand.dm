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
			var/obj/object = typepath
			state.max_demand = initial(object.max_demand)
		else if(ispath(typepath, /datum/gas))
			var/datum/gas/gas = typepath
			state.max_demand = initial(gas.max_demand)
		if(!isnull(state.max_demand))	// If the item isnt getting a max_demand then give it a random one
			state.max_demand = (5 * rand(5, 12)) // Makes sure it increases in increments of 5 - 6 * 5 = 25, 12 * 5 = 60
		state.current_demand = rand(1, state.max_demand)
		demand_states[typepath] = state
	return state

/datum/controller/subsystem/demand/proc/generate_price(obj/object)
	var/price_to_use
	if(istype(object, /obj/item))
		var/obj/item/thing = object
		if(initial(thing.w_class))	// This ensures item price will not be higher than custom price, if it is set.
			if(initial(thing.custom_price))
				price_to_use = max(((5 * rand(1, 5))* initial(thing.w_class)) * ECONOMY_MULTIPLYER, initial(thing.custom_price) * PRICE_MARKUP)
			else
				price_to_use = ((5 * rand(1, 5)) * initial(thing.w_class)) * ECONOMY_MULTIPLYER
	else	// Rand from 5 - 25 (in increments of 5) * the economy multiplier
		price_to_use = (5 * rand(1, 5)) * ECONOMY_MULTIPLYER
	return price_to_use
