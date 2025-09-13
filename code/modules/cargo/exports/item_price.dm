/datum/export/item_price
	cost = 0	// This is defined later based on custom prices
	export_category = EXPORT_CARGO
	include_subtypes = TRUE
	export_types = list(/obj) // catch-all

/datum/export/item_price/applies_to(obj/O, allowed_categories = NONE)
	if(!(O.custom_price || O.custom_premium_price))
		return FALSE
	return TRUE
