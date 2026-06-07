/datum/export/stack
	cost = 0	// This is defined later based on cusgenerated prices
	export_category = EXPORT_CARGO
	include_subtypes = TRUE
	export_types = list(
		/obj/item/stack = TRUE,
	)

/datum/export/stack/get_amount(obj/item/stack/exported)
	if(!exported.amount)
		return 0
	if(!isitem(exported))
		return 0

	return exported.amount
