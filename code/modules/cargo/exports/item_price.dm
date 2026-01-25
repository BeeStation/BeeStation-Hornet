/datum/export/item_price
	cost = 0	// This is defined later based on cusgenerated prices
	export_category = EXPORT_CARGO
	include_subtypes = TRUE
	// catch-all
	export_types = list(
		/obj = TRUE,
	)
	catchall = TRUE
