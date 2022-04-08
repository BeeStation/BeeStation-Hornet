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
		RegisterSignal(shuttle_area, COMSIG_AREA_ENTERED, .proc/register_good)

/// Clears the sellable goods cache to save memory
/// and decrease the work needed to handle hard-dels
/obj/docking_port/mobile/proc/leave_shop()
	//Stop listening for item drop events
	for(var/area/shuttle/shuttle_area as() in shuttle_areas)
		UnregisterSignal(shuttle_area, COMSIG_AREA_ENTERED)
	//Unregister cached thing signals
	for(var/atom/movable/sellable_good as() in sellable_goods_cache)
		UnregisterSignal(sellable_good, COMSIG_PARENT_QDELETING)
	//Clear the memory of sold goods to remove hard-del possibilities
	sellable_goods_cache = null

/obj/docking_port/mobile/proc/_on_good_entered(area/source, atom/movable/arrived, area/old_area)
	register_good(arrived)

/obj/docking_port/mobile/proc/_on_goods_deleted(datum/source)
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	sellable_goods_cache -= source

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
			if(E.applies_to(sellable, export_categories, TRUE))
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
