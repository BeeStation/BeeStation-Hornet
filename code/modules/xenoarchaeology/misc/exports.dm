/*
	Export datum, so we can sell artifacts for dosh
*/

/datum/export/artifact
	unit_name = "xenoartifact"
	export_types = list(/obj/item/xenoartifact)

/datum/export/artifact/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	cost = O.custom_price
	return ..()

/datum/export/artifact/applies_to(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	. = ..()
	return O.GetComponent(/datum/component/xenoartifact) ? TRUE : .
