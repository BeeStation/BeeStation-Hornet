#define MAX_MANIFEST_PENALTY CARGO_CRATE_VALUE * 2.5

// Approved manifest.
// +80 credits flat.
/datum/export/manifest_correct
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "approved manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_correct/applies_to(obj/thing, allowed_categories = NONE)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = thing
	if(manifest.is_approved() && !manifest.errors)
		return TRUE
	return FALSE

// Correctly denied manifest.
// Refunds package cost minus the value of the crate.
/datum/export/manifest_error_denied
	cost = -CARGO_CRATE_VALUE
	unit_name = "correctly denied manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

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
// Subtracts half the package cost. (max -500 credits)
/datum/export/manifest_error
	unit_name = "erroneously approved manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)
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
	return -min(manifest.order_cost * 0.5, MAX_MANIFEST_PENALTY)


// Erroneously denied manifest.
// Subtracts half the package cost. (max -500 credits)
/datum/export/manifest_correct_denied
	unit_name = "erroneously denied manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)
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
	return -min(manifest.order_cost * 0.5, MAX_MANIFEST_PENALTY)

#undef MAX_MANIFEST_PENALTY
