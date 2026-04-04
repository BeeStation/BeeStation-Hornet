// Crate refund export - returns the crate's custom_price value when sent back to CentCom.
// This replaces the old catch-all /obj export that let everything with a custom_price be sold.
// On a plasma research station, CentCom only wants plasma, bluespace, artifacts, and bounties -
// not random junk. But they'll still accept their own crates back.
/datum/export/crate_refund
	unit_name = "crate"
	include_subtypes = TRUE
	export_types = list(
		/obj/structure/closet/crate = TRUE,
	)

/datum/export/crate_refund/get_cost(obj/structure/closet/crate/C, allowed_categories = NONE)
	if(!istype(C))
		return 0
	if(!C.custom_price)
		return 0
	return C.custom_price
