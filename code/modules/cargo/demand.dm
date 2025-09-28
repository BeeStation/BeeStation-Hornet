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
