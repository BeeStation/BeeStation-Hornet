/**
 * # Cargo Product
 *
 * Base datum for anything orderable through the cargo system.
 * Both individual items (/datum/cargo_item) and pre-built crates (/datum/cargo_crate)
 * inherit from this, giving the order system and UI a single interface to work with.
 */
/datum/cargo_product
	/// Display name in the cargo console UI
	var/name = "Product"
	/// Category this product appears under in the UI (e.g. "Engineering", "Emergency")
	var/category = ""
	/// Description shown in the UI
	var/desc = ""
	/// Base cost in cargo credits
	var/cost = 400
	/// Current available stock. Restocked over time by SSsupply.
	var/current_supply
	/// Maximum stock this product can have
	var/max_supply = 5
	/// Access required to open the delivered crate (null = no restriction)
	var/access = null
	/// Access required to order via department budget app
	var/access_budget = FALSE
	/// Is this a contraband item? (requires emagged/hacked console)
	var/contraband = FALSE
	/// Is this hidden? (requires emagged console to see)
	var/hidden = FALSE
	/// Is this a special/event/station-goal product? (requires special_enabled = TRUE to show)
	var/special = FALSE
	/// Has this special product been enabled? (set by station goals, admin, etc.)
	var/special_enabled = FALSE
	/// Should we message admins when this is ordered?
	var/dangerous = FALSE
	/// Only usable via the Bluespace Drop Pod express cargo console
	var/DropPodOnly = FALSE
	/// Was this spawned by an admin?
	var/admin_spawned = FALSE
	/// The type of crate to deliver this in
	var/crate_type = /obj/structure/closet/crate
	/// Can this order be secured (owned crate on personal purchase)?
	var/can_secure = TRUE

/datum/cargo_product/New()
	. = ..()
	// Randomise starting supply for variation. Bias toward lower values since stock builds over time.
	current_supply = rand(0, rand(1, max_supply))

/// Get the effective cost after station traits
/datum/cargo_product/proc/get_cost()
	. = cost
	if(HAS_TRAIT(SSstation, STATION_TRAIT_DISTANT_SUPPLY_LINES))
		. *= 1.2
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_STRONG_SUPPLY_LINES))
		. *= 0.8

/// Returns a human-readable list of item names for UI display
/datum/cargo_product/proc/get_contents_readable()
	return list()

/// Generate the delivered crate at the given location
/datum/cargo_product/proc/generate(atom/A, datum/bank_account/paying_account)
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

/// Fill the crate with this product's contents. Override in subtypes.
/datum/cargo_product/proc/fill(obj/structure/closet/crate/C)
	return

/**
 * # Cargo Item
 *
 * Represents a single orderable item in the cargo catalogue.
 * Each datum defines one purchasable thing. The subsystem collects all subtypes
 * at init and builds the catalogue from them.
 *
 * Items with small_item = TRUE can be grouped together into a single crate.
 */
/datum/cargo_item
	/// Display name in the cargo console UI. Defaults to the item's name if unset.
	var/name
	/// The item type path this cargo item delivers
	var/item_path
	/// Category this item appears under (e.g. "Engineering", "Medical")
	var/category = ""
	/// Description shown in the UI. Defaults to item's desc if unset.
	var/desc = ""
	/// Base cost in cargo credits
	var/cost = 400
	/// Maximum stock
	var/max_supply = 5
	/// Current available stock
	var/current_supply
	/// Access required to open delivered crate
	var/access = null
	/// Access required for department budget ordering
	var/access_budget = FALSE
	/// Is this contraband?
	var/contraband = FALSE
	/// Is this hidden?
	var/hidden = FALSE
	/// Is this dangerous (admin alert)?
	var/dangerous = FALSE
	/// Only available via express console drop pod?
	var/DropPodOnly = FALSE
	/// Small items can be grouped into a single crate
	var/small_item = FALSE
	/// Crate type to deliver in
	var/crate_type = /obj/structure/closet/crate
	/// Can be secured on personal purchase?
	var/can_secure = TRUE

/datum/cargo_item/New()
	. = ..()
	current_supply = rand(0, rand(1, max_supply))
	// Auto-fill name from the item path if not set
	if(!name && item_path)
		var/atom/A = item_path
		name = initial(A.name)

/// Get the effective cost after station traits
/datum/cargo_item/proc/get_cost()
	. = cost
	if(HAS_TRAIT(SSstation, STATION_TRAIT_DISTANT_SUPPLY_LINES))
		. *= 1.2
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_STRONG_SUPPLY_LINES))
		. *= 0.8

/// Returns a human-readable list (just this item's name)
/datum/cargo_item/proc/get_contents_readable()
	if(item_path)
		var/atom/A = item_path
		return list(initial(A.name))
	return list()

/**
 * # Cargo Crate
 *
 * Represents a pre-assembled crate order — a fixed bundle of items delivered together.
 * Used for station goals, special event packs, and any multi-item package that
 * logically belongs in a single crate.
 *
 * In the UI, all cargo_crate datums appear under the "Packs" category by default,
 * but can specify their own category.
 */
/datum/cargo_crate
	/// Display name
	var/name = "Crate"
	/// UI category. Defaults to "Packs".
	var/category = "Packs"
	/// Description shown in the UI
	var/desc = ""
	/// Base cost
	var/cost = 400
	/// List of item type paths contained in this crate
	var/list/contains = null
	/// Current available stock
	var/current_supply
	/// Maximum stock
	var/max_supply = 5
	/// Access required to open the crate
	var/access = null
	/// Access required for department budget ordering
	var/access_budget = FALSE
	/// Crate type
	var/crate_type = /obj/structure/closet/crate
	/// Is this contraband?
	var/contraband = FALSE
	/// Is this hidden?
	var/hidden = FALSE
	/// Is this a special/station goal crate?
	var/special = FALSE
	/// Has this been enabled? (station goals set this to TRUE)
	var/special_enabled = FALSE
	/// Should we alert admins?
	var/dangerous = FALSE
	/// Only available via express drop pod?
	var/DropPodOnly = FALSE
	/// Admin spawned?
	var/admin_spawned = FALSE
	/// Can be secured?
	var/can_secure = TRUE
	/// Is this a small item (for grouping)?
	var/small_item = FALSE

/datum/cargo_crate/New()
	. = ..()
	current_supply = rand(0, rand(1, max_supply))

/// Get the effective cost after station traits
/datum/cargo_crate/proc/get_cost()
	. = cost
	if(HAS_TRAIT(SSstation, STATION_TRAIT_DISTANT_SUPPLY_LINES))
		. *= 1.2
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_STRONG_SUPPLY_LINES))
		. *= 0.8

/// Returns a human-readable list of item names in this crate
/datum/cargo_crate/proc/get_contents_readable()
	var/list/readable = list()
	if(!contains)
		return readable
	for(var/item_path in contains)
		if(ispath(item_path))
			var/atom/A = item_path
			readable += initial(A.name)
	return readable

/// Generate the delivered crate at the given location
/datum/cargo_crate/proc/generate(atom/A, datum/bank_account/paying_account)
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

/// Fill the crate with this crate's contents
/datum/cargo_crate/proc/fill(obj/structure/closet/crate/C)
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
