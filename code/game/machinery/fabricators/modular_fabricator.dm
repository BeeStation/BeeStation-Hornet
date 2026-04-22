#define MODFAB_MAX_POWER_USE 2 KILOWATT

/obj/machinery/modular_fabricator
	name = "modular fabricator"
	desc = "It produces items using iron, copper, and glass."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	layer = BELOW_OBJ_LAYER

	/// If we are currently running through the design queue or not
	var/operating = FALSE
	/// If this is TRUE, we will attempt to restart fabrication after material is added
	/// Set to TRUE when we attempt to fabricate something, but run out of materials
	var/wants_to_operate = FALSE
	/// When this is TRUE, designs cannot be fabricated
	var/disabled = FALSE

	/// The multiplier for how much materials the created object takes from this machines stored materials
	var/creation_efficiency = 1.6

	/// If TRUE, security_interface_locked is enabled and the ID-unlock section shows up on the ModularFabricator UI
	var/can_be_hacked_or_unlocked = FALSE
	/// If TRUE, allows the user to toggle the hacked status. Swiping an ID with security access will toggle this bool.
	/// If can_be_hacked_or_unlocked is FALSE, this variable is unused
	var/security_interface_locked = TRUE
	/// If TRUE, designs in the RND_CATEGORY_HACKED category become available
	var/hacked = FALSE

	/// If TRUE, we can print an entire category at once
	var/can_print_entire_categories = FALSE

	/// The design that we are currently building
	var/datum/design/being_built
	/// The world.time that our current build will be completed at
	var/process_completion_world_tick = 0
	/// The total time it will take to finish the current build
	var/total_build_time = 0

	/// The cardinal direction built designs outputted on
	/// When set to 0, the design is outputted on the modfab's turf
	var/output_direction = 0

	/// If TRUE, disks can be inserted into this machine
	var/accepts_disks = FALSE
	/// Reference to the disk inside
	var/obj/item/disk/design_disk/inserted_disk
	/// Designs imported from design disks. Only initialized if accepts_disks is TRUE.
	var/list/imported_designs

	/// If TRUE, connect to the ore silo. If FALSE, create our own material container
	var/remote_materials = FALSE
	/// If TRUE, we will automatically connect to an ore silo
	/// Only matters if remote_materials is also TRUE
	var/auto_link = TRUE

	/// looping sound for printing items
	var/datum/looping_sound/lathe_print/print_sound

	// Queue items

	/// An associative list of the designs in the queue
	/// design_queue[design_id] = list("amount" = int, "repeating" = bool, "build_mat" = something)
	var/list/design_queue = list()
	/// If TRUE, once a design is processed, it will be stuck right back onto the queue again
	var/queue_repeating = FALSE
	/// The amount to re-add to the queue when processing is done
	var/stored_item_amount
	/// Minimum construction time per component
	var/minimum_construction_time = 3.5 SECONDS

	// Techweb crap
	/// Ref to our internal techweb. Set to the typepath of your desired techweb (irrelevant if use_station_research is TRUE).
	var/datum/techweb/stored_research = /datum/techweb/autounlocking
	/// If TRUE, we connect to the science techweb instead of creating our own
	var/use_station_research = FALSE

	// The vars below are only used if use_station_research is TRUE
	/// Made so we dont call addtimer() 40,000 times in on_techweb_update(). only allows addtimer() to be called on the first update.
	var/techweb_updating = FALSE
	/// The types of designs this fabricator can print.
	var/allowed_buildtypes = NONE
	/// All designs in the techweb that can be fabricated by this machine, since the last update.
	var/list/datum/design/cached_designs

/obj/machinery/modular_fabricator/Initialize(mapload)
	print_sound = new(src, FALSE)

	if(ispath(stored_research) && !use_station_research)
		if(!GLOB.autounlock_techwebs[stored_research])
			GLOB.autounlock_techwebs[stored_research] = new stored_research()
		stored_research = GLOB.autounlock_techwebs[stored_research]

	if(accepts_disks)
		imported_designs = list()
	if(use_station_research)
		cached_designs = list()

	if(remote_materials)
		AddComponent(/datum/component/remote_materials, "modfab", mapload, auto_link, mat_container_flags = BREAKDOWN_FLAGS_LATHE)
	else
		AddComponent(/datum/component/material_container, SSmaterials.materialtypes_by_category[MAT_CATEGORY_RIGID], _mat_container_flags = MATCONTAINER_EXAMINE, _after_insert = CALLBACK(src, PROC_REF(after_material_insert)))
	return ..()

/obj/machinery/modular_fabricator/LateInitialize()
	. = ..()
	if(use_station_research && !istype(stored_research))
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)
		on_connected_techweb()

/obj/machinery/modular_fabricator/Destroy()
	stored_research = null
	inserted_disk = null
	being_built = null
	QDEL_NULL(print_sound)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/modular_fabricator/on_deconstruction(disassembled)
	if(inserted_disk)
		inserted_disk.forceMove(drop_location())
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

/obj/machinery/modular_fabricator/examine(mob/user)
	. += ..()
	var/datum/component/material_container/materials = get_material_container()
	if(in_range(user, src) || isobserver(user))
		. += span_info("The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[creation_efficiency*100]%</b>.")

/obj/machinery/modular_fabricator/attackby(obj/item/attacking_item, mob/living/user, params)
	if(can_be_hacked_or_unlocked && (ACCESS_SECURITY in attacking_item.GetAccess()) && !(obj_flags & EMAGGED))
		security_interface_locked = !security_interface_locked
		to_chat(user, span_warning("You [security_interface_locked ? "lock" : "unlock"] \the [src]'s security controls."))
		return TRUE

	if(accepts_disks && istype(attacking_item, /obj/item/disk/design_disk) && isnull(inserted_disk))
		user.visible_message(
			message = "[user] loads \the [attacking_item] into \the [src]...",
			self_message = "You load a design from \the [attacking_item]...",
			blind_message = "You hear the chatter of a floppy drive.",
		)
		inserted_disk = attacking_item
		attacking_item.forceMove(src)
		ui_update()
		return TRUE

	return ..()

/obj/machinery/modular_fabricator/proc/connect_techweb(datum/techweb/new_techweb)
	if(stored_research)
		UnregisterSignal(stored_research, list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN))
	stored_research = new_techweb
	if(!isnull(stored_research))
		on_connected_techweb()

/obj/machinery/modular_fabricator/proc/on_connected_techweb()
	RegisterSignals(
		stored_research,
		list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN),
		PROC_REF(on_techweb_update)
	)
	update_designs()

/obj/machinery/modular_fabricator/proc/on_techweb_update()
	SIGNAL_HANDLER

	if(!techweb_updating) //so we batch these updates together
		techweb_updating = TRUE
		addtimer(CALLBACK(src, PROC_REF(update_designs)), 2 SECONDS)

/// Updates the list of designs this fabricator can print.
/obj/machinery/modular_fabricator/proc/update_designs()
	PROTECTED_PROC(TRUE)
	techweb_updating = FALSE

	var/previous_design_count = length(cached_designs)

	cached_designs.Cut()

	for(var/design_id in stored_research.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)

		if(design.build_type & allowed_buildtypes)
			cached_designs |= design

	var/design_delta = length(cached_designs) - previous_design_count
	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)

	update_static_data_for_all_viewers()

REGISTER_BUFFER_HANDLER(/obj/machinery/modular_fabricator)
DEFINE_BUFFER_HANDLER(/obj/machinery/modular_fabricator)
	if(use_station_research && istype(buffer, /datum/techweb))
		balloon_alert(user, "techweb connected")
		connect_techweb(buffer)
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/// Gets our material container
/obj/machinery/modular_fabricator/proc/get_material_container()
	var/datum/component/remote_materials/materials = GetComponent(/datum/component/remote_materials)
	return materials?.mat_container || GetComponent(/datum/component/material_container)

/obj/machinery/modular_fabricator/RefreshParts()
	var/new_capacity = 0
	for(var/obj/item/stock_parts/matter_bin/new_matter_bin in component_parts)
		new_capacity += new_matter_bin.rating * 75000

	//Material container
	if(remote_materials)
		var/datum/component/remote_materials/materials = GetComponent(/datum/component/remote_materials)
		materials.set_local_size(new_capacity)
	else
		var/datum/component/material_container/container = GetComponent(/datum/component/material_container)
		container.max_amount = new_capacity

	var/efficiency = 1.8
	for(var/obj/item/stock_parts/manipulator/new_manipulator in component_parts)
		efficiency -= new_manipulator.rating * 0.2
	creation_efficiency = max(1, efficiency) // creation_efficiency goes 1.6 -> 1.4 -> 1.2 -> 1 per level of manipulator efficiency

	update_static_data_for_all_viewers()

/obj/machinery/modular_fabricator/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularFabricator")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/modular_fabricator/ui_static_data(mob/user)
	var/list/data = list()
	data["accepts_disk"] = accepts_disks
	data["show_unlock_bar"] = can_be_hacked_or_unlocked
	data["allow_add_category"] = can_print_entire_categories

	// Used cached_designs if we're using the station's techweb
	data["available_categories"] = handle_designs((use_station_research ? cached_designs : stored_research.researched_designs)) // these extra brackets are necessary
	if(length(imported_designs))
		data["available_categories"] += handle_designs(imported_designs)
	if(hacked && istype(stored_research, /datum/techweb/autounlocking))
		var/datum/techweb/autounlocking/autounlocking_web = stored_research
		data["available_categories"] += handle_designs(autounlocking_web.hacked_designs)

	return data

/**
 * Converts all the designs supported by this modular fabricator into UI data
 * Arguments
 *
 * * list/designs - the list of techweb designs we are trying to send to the UI
 */
/obj/machinery/modular_fabricator/proc/handle_designs(list/designs)
	PROTECTED_PROC(TRUE)

	var/list/categories_associative = list()
	for(var/design_id in designs)
		var/datum/design/design = astype(design_id, /datum/design) || SSresearch.techweb_design_by_id(design_id)
		if(!(design.build_type & allowed_buildtypes))
			continue

		for(var/category in design.category)
			if(category == RND_CATEGORY_INITIAL || category == RND_CATEGORY_HACKED)
				continue

			if(!islist(categories_associative[category]))
				categories_associative[category] = list()

			// Calculate cost
			var/list/material_cost = list()
			for(var/material_id, material_amount in design.materials)
				material_cost += list(list(
					"name" = material_id,
					"amount" = (material_amount / MINERAL_MATERIAL_AMOUNT) * creation_efficiency,
				))

			// Add
			categories_associative[category] += list(list(
				"name" = design.name,
				"desc" = design.desc,
				"design_id" = design.id,
				"material_cost" = material_cost,
			))

	var/list/output = list()
	for(var/category, items in categories_associative)
		output += list(list(
			"category_name" = category,
			"category_items" = items,
		))

	return output

/obj/machinery/modular_fabricator/ui_data(mob/user)
	var/list/data = list()

	// Disk
	data["disk_inserted"] = !!inserted_disk
	data["can_upload_disk"] = FALSE
	if(inserted_disk) // A disk can only be uploaded only if it has at least one design we don't already have
		for(var/datum/design/blueprint in inserted_disk.blueprints)
			if(!imported_designs[blueprint.id])
				data["can_upload_disk"] = TRUE
				break

	// Security interface
	data["sec_interface_unlock"] = !security_interface_locked
	data["hacked"] = hacked

	// Output direction
	data["output_direction"] = output_direction

	// Queue
	data["design_queue"] = list()
	for(var/queued_design_id, queue_data in design_queue)
		var/datum/design/design = SSresearch.techweb_design_by_id(queued_design_id)
		data["design_queue"] += list(list(
			"name" = design.name,
			"amount" = queue_data["amount"],
			"repeat" = queue_data["repeating"],
			"design_id" = queued_design_id,
		))

	// Materials
	data["contained_materials"] = list()
	var/datum/component/material_container/material_container = get_material_container()
	for(var/datum/material/material, material_amount in material_container.materials)
		data["contained_materials"] += list(list(
			"name" = material.name,
			"amount" = material_amount / MINERAL_MATERIAL_AMOUNT,
			"typepath" = material.type,
		))

	// Thing being made
	if(being_built && total_build_time && process_completion_world_tick)
		data["being_built"] = list(
			"design_id" = being_built.id,
			"name" = being_built.name,
			"progress" = 100 - (100 * ((process_completion_world_tick - world.time) / total_build_time)),
		)
	else
		data["being_built"] = null

	//Being Build
	return data

/obj/machinery/modular_fabricator/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		// Safeties
		if("toggle_safety")
			if(security_interface_locked)
				return
			hacked = !hacked
			update_static_data_for_all_viewers()
			wires.ui_update()
			return FALSE // Lets avoid an unnecessary UI update, update_static_data_for_all_viewers() already did it for us

		if("toggle_lock")
			if(obj_flags & EMAGGED)
				return FALSE
			if (!security_interface_locked)
				security_interface_locked = TRUE
			else
				var/obj/item/id_slot = usr.get_idcard(TRUE)
				if((ACCESS_SECURITY in id_slot.GetAccess()) && !(obj_flags & EMAGGED))
					security_interface_locked = FALSE
					to_chat(usr, span_warning("You unlock the security controls of [src]."))
			return TRUE

		// Disk
		if("upload_disk")
			if(!accepts_disks || isnull(inserted_disk))
				return

			var/previous_design_count = length(imported_designs)
			for(var/datum/design/blueprint in inserted_disk.blueprints)
				imported_designs[blueprint.id] = TRUE

			var/design_delta = length(imported_designs) - previous_design_count
			if(design_delta > 0)
				say("Uploaded [design_delta] new design[design_delta == 1 ? "" : "s"].")
				playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
				update_static_data_for_all_viewers()

			return FALSE // update_static_data_for_all_viewers() already called a UI update

		if("eject_disk")
			if(!accepts_disks || isnull(inserted_disk))
				return

			inserted_disk.forceMove(drop_location())
			inserted_disk = null
			return TRUE

		// Misc
		if("eject_material")
			var/datum/material/material_datum = text2path(params["material_datum"])
			if(!ispath(material_datum, /datum/material))
				return

			var/amount = text2num(params["amount"])
			if(amount <= 0 || amount > MAX_STACK_SIZE)
				return

			var/datum/component/material_container/materials = get_material_container()
			for(var/datum/material/material_to_eject as anything in materials.materials)
				if(material_to_eject.type == material_datum)
					materials.retrieve_sheets(amount, material_to_eject, get_release_turf())
					return TRUE

		if("output_dir")
			output_direction = text2num(params["direction"])
			return TRUE

		// Queue
		if("queue_category")
			if(!can_print_entire_categories)
				return
			var/category_to_queue = params["category_name"]
			for(var/design_id in stored_research.researched_designs)
				var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
				if(category_to_queue in design.category)
					add_to_queue(design_id, 1)
			return TRUE

		if("queue_repeat")
			queue_repeating = text2num(params["repeating"])
			return TRUE

		if("clear_queue")
			design_queue.Cut()
			return TRUE

		if("item_repeat")
			var/design_id = params["design_id"]
			if(!design_queue["[design_id]"])
				return

			var/repeating_mode = text2num(params["repeating"])
			design_queue["[design_id]"]["repeating"] = repeating_mode
			return TRUE

		if("clear_item")
			var/design_id = params["design_id"]
			design_queue -= design_id
			return TRUE

		if("queue_item")
			var/design_id = params["design_id"]
			var/amount = text2num(params["amount"])
			add_to_queue(design_id, amount)
			return TRUE

		// Go button
		if("begin_process")
			begin_process()
			return TRUE

/**
 * Adds a design to the designs queue.
 *
 * Arguments:
 * * design_id - The design ID eventually fabricate
 * * amount - The amount of the design to fabricate
 * * used_material - The material that the design will be made of
 */
/obj/machinery/modular_fabricator/proc/add_to_queue(design_id, amount, datum/material/used_material)
	if(design_queue["[design_id]"])
		design_queue["[design_id]"]["amount"] += amount
		if(design_queue["[design_id]"]["amount"] <= 0)
			design_queue -= "[design_id]"
		return
	if(amount <= 0)
		return

	var/is_valid_design = stored_research.researched_designs[design_id]
	is_valid_design ||= imported_designs[design_id]
	if(hacked)
		is_valid_design ||= astype(stored_research, /datum/techweb/autounlocking)?.hacked_designs[design_id]
	if(!is_valid_design)
		return

	//Check if the item uses custom materials
	var/datum/design/requested_item = SSresearch.techweb_design_by_id(design_id)

	if(!istype(used_material))
		for(var/material_or_category in requested_item.materials)
			used_material = material_or_category
			if(istext(material_or_category)) //This means its a category. e.g: "rigid material"
				var/datum/component/material_container/materials = get_material_container()
				var/list/material_options = list()
				for(var/datum/material/category_material in SSmaterials.materials_by_category[used_material])
					if(materials.materials[category_material] > 0)
						material_options += category_material

				used_material = tgui_input_list(usr, "Choose [used_material]", "Custom Material", sort_list(material_options, GLOBAL_PROC_REF(cmp_typepaths_asc)))
				if(!used_material)
					return //Didn't pick any material, so you can't build shit either.

	design_queue["[design_id]"] = list(
		"amount" = amount,
		"repeating" = FALSE, // by default we aren't repeating
		"build_mat" = used_material,
	)

/obj/machinery/modular_fabricator/proc/get_release_turf()
	var/turf/release_turf
	if(output_direction)
		release_turf = get_step(src, output_direction)
		if(release_turf.is_blocked_turf(TRUE))
			release_turf = get_turf(src)
	else
		release_turf = get_turf(src)
	return release_turf

/**
 * Called when materials are inserted into this fabricator.
 * Use power based on the amount of materials inserted and if we want to begin operation, do so.
 */
/obj/machinery/modular_fabricator/proc/after_material_insert(item_inserted, id_inserted, amount_inserted)
	if(istype(item_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		use_power(min(1000, amount_inserted / 100))
	//Begin processing to continue the queue if we had items in the queue
	if(wants_to_operate)
		begin_process()

/obj/machinery/modular_fabricator/proc/begin_process()
	if(operating || disabled)
		return

	var/requested_design_id
	if(length(design_queue))
		requested_design_id = design_queue[1]
	else
		//Queue processing done
		say("Queue processing completed.")
		operating = FALSE
		return
	operating = TRUE

	// Get our design
	var/is_valid_design = stored_research.researched_designs[requested_design_id]
	is_valid_design ||= imported_designs[requested_design_id]
	if(hacked)
		is_valid_design ||= astype(stored_research, /datum/techweb/autounlocking)?.hacked_designs[requested_design_id]
	if(!is_valid_design)
		playsound(src, 'sound/machines/buzz-two.ogg', 50)
		say("Unknown design requested, removing from queue.")
		design_queue -= requested_design_id
		addtimer(CALLBACK(src, PROC_REF(restart_process)), 5 SECONDS)
		return

	being_built = SSresearch.techweb_design_by_id(requested_design_id)

	var/items_to_build = 1
	var/is_stack = ispath(being_built.build_path, /obj/item/stack)
	//Only items that can stack should be build en-mass, since we now have queues.
	if(is_stack)
		items_to_build = design_queue[requested_design_id]["amount"]
	items_to_build = clamp(items_to_build, 1, MAX_STACK_SIZE)

	/////////////////

	var/coeff = (is_stack ? 1 : creation_efficiency) //stacks are unaffected by production coefficient
	var/total_amount = 0

	for(var/material_type, material_amount in being_built.materials)
		total_amount += material_amount

	var/power = max(MODFAB_MAX_POWER_USE, total_amount * items_to_build / 5) //Change this to use all materials

	var/datum/component/material_container/materials = get_material_container()

	var/list/materials_used = list() // The materials we draw
	var/list/custom_materials = list() //These will apply their material effect, This should usually only be one.

	for(var/material_type, material_amount in being_built.materials)
		var/datum/material/used_material = material_type
		var/amount_needed = material_amount * coeff * items_to_build

		if(istext(used_material)) //This means its a category
			used_material = design_queue[requested_design_id]["build_mat"]
			if(!used_material)
				design_queue -= requested_design_id
				addtimer(CALLBACK(src, PROC_REF(restart_process)), 0.5 SECONDS)
				return //Didn't pick any material, so you can't build shit either.
			custom_materials[used_material] += amount_needed

		materials_used[used_material] = amount_needed

	// Check for materials
	if(!materials.has_materials(materials_used))
		say("Insufficient materials, operation will proceed when sufficient materials are available.")
		operating = FALSE
		wants_to_operate = TRUE
		being_built = null
		ui_update()
		return

	use_power(power)
	set_working_sprite()
	print_sound.start()

	var/construction_time = max(being_built.construction_time, minimum_construction_time)
	var/time = is_stack ? construction_time : (construction_time * coeff * items_to_build) ** 0.8
	time *= being_built.lathe_time_factor

	//===Repeating mode===
	//Remove from queue
	var/list/queue_data = design_queue[requested_design_id]
	design_queue[requested_design_id]["amount"] -= items_to_build
	var/removed = FALSE
	if(design_queue[requested_design_id]["amount"] <= 0)
		design_queue -= requested_design_id
		removed = TRUE

	// Requeue if necessary
	if(queue_repeating || queue_data["repeating"])
		stored_item_amount ++
		if(removed)
			add_to_queue(requested_design_id, stored_item_amount, queue_data["build_mat"])
			stored_item_amount = 0

	// Create item & restart
	process_completion_world_tick = world.time + time
	total_build_time = time
	addtimer(CALLBACK(src, PROC_REF(make_item), power, materials_used, custom_materials, items_to_build, coeff, is_stack, requested_design_id, queue_data), time)
	addtimer(CALLBACK(src, PROC_REF(restart_process)), time + 0.5 SECONDS)

/obj/machinery/modular_fabricator/proc/restart_process()
	operating = FALSE
	wants_to_operate = FALSE
	if(disabled || QDELETED(src))
		return
	begin_process()

/obj/machinery/modular_fabricator/proc/make_item(power, list/materials_used, list/picked_materials, items_to_build, coeff, is_stack, requested_design_id, queue_data)
	if(QDELETED(src))
		return

	// Stops the queue
	if(disabled)
		operating = FALSE
		set_default_sprite()
		print_sound.stop()
		// requeue the item
		add_to_queue(requested_design_id, stored_item_amount + 1, queue_data["build_mat"])
		stored_item_amount = 0
		return

	var/datum/component/material_container/materials = get_material_container()
	if(!materials.has_materials(materials_used))
		operating = FALSE
		wants_to_operate = TRUE
		set_default_sprite()
		print_sound.stop()
		// requeue the item
		add_to_queue(requested_design_id, stored_item_amount + 1, queue_data["build_mat"])
		stored_item_amount = 0
		return

	// Consume power & materials
	use_power(power)
	materials.use_materials(materials_used)

	// Actually make the item
	var/turf/release_turf = get_release_turf()
	if(is_stack)
		var/obj/item/stack/new_stack = new being_built.build_path(loc, items_to_build)
		new_stack.forceMove(release_turf) //Forcemove to the release turf to trigger ZFall
	else
		for(var/i = 1 to items_to_build)
			var/obj/item/new_item = new being_built.build_path(loc)
			// Detect if the printed item has embedded itself in another item. Used for Circuit Templates which self insert themselves into shells.
			if(isobj(new_item.loc))
				var/obj/new_obj = new_item.loc //Get the object it is now embedded in.
				new_obj.forceMove(release_turf) //Forcemove to the release turf to trigger ZFall
			else
				new_item.forceMove(release_turf) //Forcemove to the release turf to trigger ZFall

			if(length(picked_materials))
				new_item.set_custom_materials(picked_materials, 1 / items_to_build) //Ensure we get the non multiplied amount

	being_built = null
	set_default_sprite()
	print_sound.stop()

/obj/machinery/modular_fabricator/proc/set_default_sprite()
	return

/obj/machinery/modular_fabricator/proc/set_working_sprite()
	return

#undef MODFAB_MAX_POWER_USE
