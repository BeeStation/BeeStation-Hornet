/datum/export/produce
	cost = 0	// This is defined later based on cusgenerated prices
	export_category = EXPORT_CARGO
	include_subtypes = TRUE
	export_types = list(
		/obj/item/food/grown = TRUE,
	)

/datum/export/produce/get_cost(obj/item/food/grown/produce, allowed_categories = NONE)
	var/amount = get_amount(produce)
	if(amount <= 0)
		return 0

	// Grab demand state for this object type
	var/datum/demand_state/state = SSdemand.get_demand_state(produce.type)

	// Determine base price
	var/base_price = state.generated_price || cost

	var/demand_ratio = state.current_demand / state.max_demand
	demand_ratio = max(demand_ratio, state.min_price_factor)

	if(state.current_demand == 0)
		// If we at CC are at full stock then this item is worth 0 thus, won't be sold
		base_price = 0
	if(produce.trade_flags & TRADE_NOT_SELLABLE)
		base_price = 0

	// Scale price by
	var/potency_multiplier = produce.seed.potency / 100
	if(base_price)	// Makes sure items that HAVE a value don't get completely dogged by the calculations causing it to return 0
		return max(1, round(base_price * demand_ratio) * potency_multiplier)
	else
		return round(base_price * demand_ratio * potency_multiplier)
