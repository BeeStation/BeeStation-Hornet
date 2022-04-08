/obj/docking_port/mobile
	//Contains a list of items and either:
	// - Their value list[obj] = 50
	// - Another list with the same format for that item's contents list[obj] = list(obj = 50)
	var/list/sellable_goods_cache
	//Valid export categories
	var/export_categories = EXPORT_CARGO

/obj/docking_port/mobile/proc/can_recieve_goods()
	var/datum/orbital_object/shuttle/shuttleObject = SSorbits.assoc_shuttles[id]
	if(!shuttleObject)
		return FALSE
	return istype(shuttleObject.docking_target, /datum/orbital_object/z_linked/phobos)

/// Called when a shopping area is entered
/// Calculates all items on the shuttle that can be sold
/// Registers signals so new dropped items will be sellable
/obj/docking_port/mobile/proc/enter_shop()
	//Start the list
	sellable_goods_cache = list()
	//Register all items in the area
	//Register the areas to track when items are entered
	for(var/area/shuttle/shuttle_area as() in shuttle_areas)
		for(var/atom/movable/AM in shuttle_area)
			register_good(AM)
		RegisterSignal(shuttle_area, COMSIG_AREA_ENTERED, .proc/_on_good_entered)

/// Clears the sellable goods cache to save memory
/// and decrease the work needed to handle hard-dels
/obj/docking_port/mobile/proc/leave_shop()
	//Stop listening for item drop events
	for(var/area/shuttle/shuttle_area as() in shuttle_areas)
		UnregisterSignal(shuttle_area, COMSIG_AREA_ENTERED)
	//Unregister cached thing signals
	for(var/sellable_good_ref as() in sellable_goods_cache)
		UnregisterSignal(locate(sellable_good_ref), COMSIG_PARENT_QDELETING)
	//Clear the memory of sold goods to remove hard-del possibilities
	sellable_goods_cache = null

/obj/docking_port/mobile/proc/_on_good_entered(area/source, atom/movable/arrived, area/old_area)
	register_good(arrived)

/obj/docking_port/mobile/proc/_on_goods_deleted(datum/source)
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	sellable_goods_cache -= REF(source)

/obj/docking_port/mobile/proc/register_good(atom/movable/sellable)
	//Generate the exports list if required
	if(!GLOB.exports_list.len)
		setupExports()
	//Ignored types (We don't want to sell people)
	if(ismob(sellable) || iseffect(sellable))
		return
	var/price = 0
	//Contents
	var/allContents = sellable.GetAllContents()
	for(var/atom/movable/subContent in allContents)
		for(var/datum/export/E in GLOB.exports_list)
			if(E.applies_to(subContent, export_categories, TRUE))
				price += E.sell_object(sellable, TRUE, export_categories, TRUE)
				break
	//No price, no value
	if(!price)
		return
	//Start tracking it
	sellable_goods_cache[REF(sellable)] = list(
		"name" = sellable.name,
		"price" = price,
		"contents" = allContents - sellable
	)
	RegisterSignal(sellable, COMSIG_PARENT_QDELETING, .proc/_on_goods_deleted)

/obj/docking_port/mobile/proc/sell_item(object_ref)
	if(!GLOB.exports_list.len) // No exports list? Generate it!
		setupExports()
	if(!sellable_goods_cache[object_ref])
		return
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/datum/export_report/ex = new
	var/atom/movable/located_sold = locate(object_ref)
	if(!(located_sold.loc.loc in shuttle_areas))
		return
	bounty_ship_item_and_contents(located_sold, dry_run = FALSE)
	if(!located_sold.anchored || istype(located_sold, /obj/mecha))
		export_item_and_contents(located_sold, export_categories , dry_run = FALSE, external_report = ex)
	else
		//Exports the contents of things but not the item itself, so you can have conveyor belt that won't get sold
		export_contents(located_sold, export_categories , dry_run = FALSE, external_report = ex)
	var/creds = 0
	for(var/datum/export/E in ex.total_amount)
		D.adjust_money(ex.total_value[E])
		creds += ex.total_value[E]
	investigate_log("[located_sold] sold for [creds] credits", INVESTIGATE_CARGO)
