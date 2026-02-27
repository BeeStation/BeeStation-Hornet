// ============================================================================
// LEGACY SUPPLY PACK SYSTEM - DEPRECATED
// ============================================================================
// The old /datum/supply_pack system has been replaced by:
//   /datum/cargo_item  - Individual orderable items (see cargo_products.dm)
//   /datum/cargo_crate - Pre-assembled crate orders (see cargo_products.dm)
//
// Category definitions live in code/modules/cargo/cargo_categories/
// This file is kept for backwards compatibility with any code that
// still references /datum/supply_pack (e.g. station goals during transition).
// ============================================================================

/// Legacy supply_pack datum — kept as a stub for backwards compatibility.
/// New code should use /datum/cargo_item or /datum/cargo_crate instead.
/datum/supply_pack
	var/name = "Crate"
	var/group = ""
	var/subgroup = ""
	var/hidden = FALSE
	var/contraband = FALSE
	var/current_supply
	var/max_supply = 5
	var/cost = 400
	var/access = null
	var/access_budget = FALSE
	var/list/contains = null
	var/desc = ""
	var/crate_type = /obj/structure/closet/crate
	var/dangerous = FALSE
	var/special = FALSE
	var/special_enabled = FALSE
	var/DropPodOnly = FALSE
	var/admin_spawned = FALSE
	var/small_item = FALSE
	var/can_secure = TRUE

/datum/supply_pack/New()
	. = ..()
	current_supply = rand(0, rand(1, max_supply))

/datum/supply_pack/proc/generate(atom/A, datum/bank_account/paying_account)
	var/obj/structure/closet/crate/C
	if(paying_account && can_secure)
		C = new /obj/structure/closet/crate/secure/owned(A, paying_account)
	else
		C = new crate_type(A)
	if(access && !paying_account)
		if(islist(access))
			C.req_one_access = access
		else
			C.req_one_access = list(access)
	fill(C)
	return C

/datum/supply_pack/proc/get_cost()
	. = cost
	if(HAS_TRAIT(SSstation, STATION_TRAIT_DISTANT_SUPPLY_LINES))
		. *= 1.2
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_STRONG_SUPPLY_LINES))
		. *= 0.8

/datum/supply_pack/proc/get_contents_readable()
	var/list/readable = list()
	if(!contains)
		return readable
	for(var/item_path in contains)
		if(ispath(item_path))
			var/atom/A = item_path
			readable += initial(A.name)
	return readable

/datum/supply_pack/proc/fill(obj/structure/closet/crate/C)
	if(admin_spawned)
		for(var/item in contains)
			var/atom/A = new item(C)
			A.flags_1 |= ADMIN_SPAWNED_1
	else
		for(var/item in contains)
			if(ispath(item))
				new item(C)
			else if(ismovable(item))
				var/atom/movable/MA = item
				MA.forceMove(C)

// No supply_pack subtypes are defined here anymore.
// All orderable content has been migrated to:
//   /datum/cargo_item subtypes in cargo_categories/*.dm
//   /datum/cargo_crate subtypes in cargo_categories/*.dm
