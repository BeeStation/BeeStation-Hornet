// Approved manifest.
// +200 credits flat.
/datum/export/manifest_correct
	cost = 200
	unit_name = "approved manifest"
	export_types = list(
		/obj/item/paper/fluff/jobs/cargo/manifest = TRUE,
	)

/datum/export/manifest_correct/applies_to(obj/thing, allowed_categories = NONE)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = thing
	if(manifest.is_approved() && !manifest.errors)
		return TRUE
	return FALSE

// Correctly denied manifest.
// Refunds the package cost minus the cost of crate.
/datum/export/manifest_error_denied
	cost = -500
	unit_name = "correctly denied manifest"
	export_types = list(
		/obj/item/paper/fluff/jobs/cargo/manifest = TRUE,
	)

/datum/export/manifest_error_denied/applies_to(obj/thing, allowed_categories = NONE)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = thing
	if(manifest.is_denied() && manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error_denied/get_cost(obj/thing)
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = thing
	return ..() + manifest.order_cost


// Erroneously approved manifest.
// Substracts the package cost.
/datum/export/manifest_error
	unit_name = "erroneously approved manifest"
	export_types = list(
		/obj/item/paper/fluff/jobs/cargo/manifest = TRUE,
	)
	allow_negative_cost = TRUE

/datum/export/manifest_error/applies_to(obj/thing, allowed_categories = NONE)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = thing
	if(manifest.is_approved() && manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error/get_cost(obj/thing)
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = thing
	return -manifest.order_cost


// Erroneously denied manifest.
// Substracts the package cost minus the cost of crate.
/datum/export/manifest_correct_denied
	cost = -500
	unit_name = "erroneously denied manifest"
	export_types = list(
		/obj/item/paper/fluff/jobs/cargo/manifest = TRUE,
	)
	allow_negative_cost = TRUE

/datum/export/manifest_correct_denied/applies_to(obj/thing, allowed_categories = NONE)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = thing
	if(manifest.is_denied() && !manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_correct_denied/get_cost(obj/thing)
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = thing
	return ..() - manifest.order_cost
