// Base stack export datum - provides shared get_amount logic for stack subtypes.
// Does NOT export anything on its own. Only specific subtypes in sheets.dm define
// what stacks are actually sellable (plasma, plasma products, bluespace crystals).
/datum/export/stack
	cost = 0
	export_category = EXPORT_CARGO
	include_subtypes = FALSE
	export_types = list()

/datum/export/stack/get_amount(obj/item/stack/exported)
	if(!exported.amount)
		return 0
	if(!isitem(exported))
		return 0

	return exported.amount
