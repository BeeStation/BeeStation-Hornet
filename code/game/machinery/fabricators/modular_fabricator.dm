#define MODFAB_MAX_POWER_USE 2000

/obj/machinery/modular_fabricator
	name = "modular fabricator"
	desc = "It produces items using iron, copper, and glass."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	layer = BELOW_OBJ_LAYER

	var/operating = FALSE
	var/wants_operate = FALSE
	var/disabled = 0

	var/busy = FALSE
	///the multiplier for how much materials the created object takes from this machines stored materials
	var/creation_efficiency = 1.6

	var/can_sync = FALSE
	var/can_be_hacked_or_unlocked = FALSE
	var/can_print_category = FALSE

	var/datum/design/being_built
	var/process_completion_world_tick = 0
	var/total_build_time = 0
	var/datum/techweb/stored_research

	var/list/categories = list(
		"Tools",
		"Electronics",
		"Construction",
		"T-Comm",
		"Security",
		"Machinery",
		"Medical",
		"Misc",
		"Dinnerware",
		"Imported"
		)

	var/output_direction = 0
	var/accepts_disks = FALSE
	var/obj/item/disk/design_disk/inserted_disk

	var/remote_materials = FALSE
	var/auto_link = FALSE

	//A list of all the printable items

	//Queue items

	//Viewing mobs of the UI to update
	var/list/mob/viewing_mobs = list()
	//Associative list: item_queue[design_id] = list("amount" = int, "repeating" = bool, "build_mat" = something)
	//The items in the item queue
	var/list/item_queue = list()
	//If true, once an item is processed it will be stuck right back on again
	var/queue_repeating = FALSE
	//The amount to readd to the queue when processing is done
	var/stored_item_amount
	//Minimum construction time per component
	var/minimum_construction_time = 35

	var/stored_research_type = /datum/techweb/specialized/autounlocking/autolathe

/obj/machinery/modular_fabricator/Initialize(mapload)
	if(remote_materials)
		AddComponent(/datum/component/remote_materials, "modfab", mapload, TRUE, auto_link)
	else
		AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/glass, /datum/material/copper, /datum/material/gold, /datum/material/gold, /datum/material/silver, /datum/material/diamond, /datum/material/uranium, /datum/material/plasma, /datum/material/bluespace, /datum/material/bananium, /datum/material/titanium), 0, TRUE, null, null, CALLBACK(src, PROC_REF(AfterMaterialInsert)))
	. = ..()
	stored_research = new stored_research_type

/obj/machinery/modular_fabricator/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/modular_fabricator/proc/get_material_container()
	var/datum/component/remote_materials/materials = GetComponent(/datum/component/remote_materials)
	if(materials?.mat_container)
		return materials.mat_container
	var/datum/component/material_container/container = GetComponent(/datum/component/material_container)
	return container

/obj/machinery/modular_fabricator/RefreshParts()
	var/mat_capacity = 0
	for(var/obj/item/stock_parts/matter_bin/new_matter_bin in component_parts)
		mat_capacity += new_matter_bin.rating*75000
	//Material container
	var/datum/component/remote_materials/materials = GetComponent(/datum/component/remote_materials)
	if(materials)
		materials.set_local_size(mat_capacity)
	else
		var/datum/component/material_container/container = GetComponent(/datum/component/material_container)
		container.max_amount = mat_capacity

	var/efficiency = 1.8
	for(var/obj/item/stock_parts/manipulator/new_manipulator in component_parts)
		efficiency -= new_manipulator.rating*0.2
	creation_efficiency = max(1,efficiency) // creation_efficiency goes 1.6 -> 1.4 -> 1.2 -> 1 per level of manipulator efficiency

	update_viewer_statics()

/obj/machinery/modular_fabricator/examine(mob/user)
	. += ..()
	var/datum/component/material_container/materials = get_material_container()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[creation_efficiency*100]%</b>.</span>"

/obj/machinery/modular_fabricator/ui_state()
	return GLOB.default_state

/obj/machinery/modular_fabricator/ui_interact(mob/user, datum/tgui/ui = null)
	if(!is_operational)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularFabricator")
		ui.open()
		ui.set_autoupdate(TRUE)
		viewing_mobs += user

/obj/machinery/modular_fabricator/ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	viewing_mobs -= user

/obj/machinery/modular_fabricator/ui_static_data(mob/user)
	var/list/data = list()
	data["acceptsDisk"] = accepts_disks
	data["show_unlock_bar"] = can_be_hacked_or_unlocked
	data["allow_add_category"] = can_print_category
	data["can_sync"] = can_sync

	//Items
	data["items"] = list()
	var/list/categories_associative = list()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		for(var/cat in D.category)
			//Check if printable
			if(!(cat in categories))
				continue
			if(!islist(categories_associative[cat]))
				categories_associative[cat] = list()

			//Calculate cost
			var/list/material_cost = list()
			for(var/material_id in D.materials)
				material_cost += list(list(
					"name" = material_id,
					"amount" = ( D.materials[material_id] / MINERAL_MATERIAL_AMOUNT) * creation_efficiency,
				))

			//Add
			categories_associative[cat] += list(list(
				"name" = D.name,
				"design_id" = D.id,
				"material_cost" = material_cost,
			))

	//Categories and their items
	for(var/category in categories_associative)
		data["items"] += list(list(
			"category_name" = category,
			"category_items" = categories_associative[category],
		))

	//Inserted data disk
	data["diskInserted"] = inserted_disk
	return data

/obj/machinery/modular_fabricator/ui_data(mob/user)
	var/list/data = list()
	//Output direction
	data["outputDir"] = output_direction

	//Queue
	data["queue"] = list()

	//Real queue at the bottom
	for(var/item_design_id in item_queue)
		var/datum/design/D = SSresearch.techweb_design_by_id(item_design_id)
		var/list/additional_data = item_queue[item_design_id]
		data["queue"] += list(list(
			"name" = D.name,
			"amount" = additional_data["amount"],
			"repeat" = additional_data["repeating"],
			"design_id" = item_design_id,
		))

	//Materials
	data["materials"] = list()
	var/datum/component/material_container/materials = get_material_container()
	for(var/material in materials.materials)
		var/datum/material/M = material
		var/mineral_amount = materials.materials[material] / MINERAL_MATERIAL_AMOUNT
		data["materials"] += list(list(
			"name" = M.name,
			"amount" = mineral_amount,
			"datum" = M.type
		))

	//Thing being made
	if(being_built && total_build_time && process_completion_world_tick)
		data["being_build"] = list(
			"design_id" = being_built.id,
			"name" = being_built.name,
			"progress" = 100-(100*((process_completion_world_tick - world.time)/total_build_time)),
		)
	else
		data["being_build"] = null

	//Being Build
	return data

/obj/machinery/modular_fabricator/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)

		if("resync_rd")
			if(!can_sync)
				return
			resync_research()
			. = TRUE

		if("queue_category")
			if(!can_print_category)
				return
			var/category_to_queue = params["category_name"]
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = SSresearch.techweb_design_by_id(v)
				if(category_to_queue in D.category)
					add_to_queue(item_queue, v, 1)

		if("output_dir")
			output_direction = text2num(params["direction"])
			. = TRUE

		if("upload_disk")
			if(!accepts_disks)
				return
			var/obj/item/disk/design_disk/D = inserted_disk
			if(!istype(D))
				return
			for(var/B in D.blueprints)
				if(B)
					stored_research.add_design(B)
			update_viewer_statics()
			. = TRUE

		if("eject_disk")
			if(!inserted_disk || !accepts_disks)
				return
			var/obj/item/disk/design_disk/disk = inserted_disk
			disk.forceMove(get_turf(src))
			inserted_disk = null
			update_viewer_statics()
			. = TRUE

		if("eject_material")
			var/datum/component/material_container/materials = get_material_container()
			var/material_datum = params["material_datum"]	//Comes out as text
			var/amount = text2num(params["amount"])
			if(amount <= 0 || amount > 50)
				return
			for(var/mat in materials.materials)
				var/datum/material/M = mat
				if("[M.type]" == material_datum)
					materials.retrieve_sheets(amount, M, get_release_turf())
					. = TRUE
					break

		if("queue_repeat")
			queue_repeating = text2num(params["repeating"])
			. = TRUE

		if("clear_queue")
			item_queue.Cut()
			. = TRUE

		if("item_repeat")
			var/design_id = params["design_id"]
			var/repeating_mode = text2num(params["repeating"])
			if(!item_queue["[design_id]"])
				return
			item_queue["[design_id]"]["repeating"] = repeating_mode
			. = TRUE

		if("clear_item")
			var/design_id = params["design_id"]
			item_queue -= design_id
			. = TRUE

		if("queue_item")
			var/design_id = params["design_id"]
			var/amount = text2num(params["amount"])
			add_to_queue(item_queue, design_id, amount)
			. = TRUE

		if("begin_process")
			begin_process()
			. = TRUE

/obj/machinery/modular_fabricator/proc/resync_research()
	for(var/obj/machinery/computer/rdconsole/RDC in orange(7, src))
		RDC.stored_research.copy_research_to(stored_research)
		update_viewer_statics()
		say("Successfully synchronized with R&D server.")
		return

/obj/machinery/modular_fabricator/proc/update_viewer_statics()
	for(var/mob/M in viewing_mobs)
		if(QDELETED(M) || !(M.client || M.mind))
			continue
		update_static_data(M)

/obj/machinery/modular_fabricator/proc/add_to_queue(queue_list, design_id, amount, repeat=null)
	if(queue_list["[design_id]"])
		queue_list["[design_id]"]["amount"] += amount
		if(queue_list["[design_id]"]["amount"] <= 0)
			queue_list -= "[design_id]"
		return
	if(amount <= 0)
		return
	//Check if the item uses custom materials
	var/datum/design/requested_item = stored_research.isDesignResearchedID(design_id)
	var/datum/material/used_material = repeat
	if(!istype(used_material))
		for(var/MAT in requested_item.materials)
			used_material = MAT
			if(istext(used_material)) //This means its a category
				var/datum/component/material_container/materials = get_material_container()
				var/list/list_to_show = list()
				for(var/i in SSmaterials.materials_by_category[used_material])
					if(materials.materials[i] > 0)
						list_to_show += i
				used_material = input("Choose [used_material]", "Custom Material") as null|anything in sort_list(list_to_show, GLOBAL_PROC_REF(cmp_typepaths_asc))
				if(!used_material)
					return //Didn't pick any material, so you can't build shit either.

	queue_list["[design_id]"] = list(
		"amount" = amount,
		"repeating" = repeat,
		"build_mat" = used_material,
	)

/obj/machinery/modular_fabricator/proc/get_release_turf()
	var/turf/T
	if(output_direction)
		T = get_step(src, output_direction)
		if(is_blocked_turf(T, TRUE))
			T = get_turf(src)
	else
		T = get_turf(src)
	return T

/obj/machinery/modular_fabricator/on_deconstruction()
	var/datum/component/material_container/materials = get_material_container()
	materials.retrieve_all()

/obj/machinery/modular_fabricator/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		use_power(min(1000, amount_inserted / 100))
	//Begin processing to continue the queue if we had items in the queue
	if(wants_operate)
		begin_process()

/obj/machinery/modular_fabricator/proc/begin_process()
	if(busy || operating || disabled)
		return
	var/requested_design_id = null
	if(LAZYLEN(item_queue))
		requested_design_id = item_queue[1]
	//Queue processing done
	if(!requested_design_id)
		say("Queue processing completed.")
		operating = FALSE
		return
	operating = TRUE
	//Doubles as protection from bad things and makes sure we can still make the item.
	being_built = stored_research.isDesignResearchedID(requested_design_id)
	if(!being_built)
		playsound(src, 'sound/machines/buzz-two.ogg', 50)
		say("Unknown design requested, removing from queue.")
		item_queue -= requested_design_id
		addtimer(CALLBACK(src, PROC_REF(restart_process)), 50)
		return

	var/multiplier = 1
	var/is_stack = ispath(being_built.build_path, /obj/item/stack)
	//Only items that can stack should be build en mass, since we now have queues.
	if(is_stack)
		multiplier = item_queue[requested_design_id]["amount"]
	multiplier = CLAMP(multiplier,1,50)

	/////////////////

	var/coeff = (is_stack ? 1 : creation_efficiency) //stacks are unaffected by production coefficient
	var/total_amount = 0

	for(var/MAT in being_built.materials)
		total_amount += being_built.materials[MAT]

	var/power = max(MODFAB_MAX_POWER_USE, (total_amount)*multiplier/5) //Change this to use all materials

	var/datum/component/material_container/materials = get_material_container()

	var/list/materials_used = list()
	var/list/custom_materials = list() //These will apply their material effect, This should usually only be one.

	for(var/MAT in being_built.materials)
		var/datum/material/used_material = MAT
		var/amount_needed = being_built.materials[MAT] * coeff * multiplier
		if(istext(used_material)) //This means its a category
			used_material = item_queue[requested_design_id]["build_mat"]
			if(!used_material)
				item_queue -= requested_design_id
				addtimer(CALLBACK(src, PROC_REF(restart_process)), 50)
				return //Didn't pick any material, so you can't build shit either.
			custom_materials[used_material] += amount_needed

		materials_used[used_material] = amount_needed

	if(materials.has_materials(materials_used))
		busy = TRUE
		use_power(power)
		set_working_sprite()
		var/construction_time = max(being_built.construction_time, minimum_construction_time)
		var/time = is_stack ? construction_time : (construction_time * coeff * multiplier) ** 0.8
		time *= being_built.lathe_time_factor
		//===Repeating mode===
		//Remove from queue
		var/list/queue_data = item_queue[requested_design_id]
		item_queue[requested_design_id]["amount"] -= multiplier
		var/removed = FALSE
		if(item_queue[requested_design_id]["amount"] <= 0)
			item_queue -= requested_design_id
			removed = TRUE
		//Requeue if necessary
		if(queue_repeating || queue_data["repdeating"])
			stored_item_amount ++
			if(removed)
				add_to_queue(item_queue, requested_design_id, stored_item_amount, queue_data["build_mat"])
				stored_item_amount = 0
		//Create item and restart
		process_completion_world_tick = world.time + time
		total_build_time = time
		addtimer(CALLBACK(src, PROC_REF(make_item), power, materials_used, custom_materials, multiplier, coeff, is_stack, requested_design_id, queue_data), time)
		addtimer(CALLBACK(src, PROC_REF(restart_process)), time + 5)
	else
		say("Insufficient materials, operation will proceed when sufficient materials are available.")
		operating = FALSE
		wants_operate = TRUE

/obj/machinery/modular_fabricator/proc/restart_process()
	operating = FALSE
	wants_operate = FALSE
	if(disabled)
		return
	begin_process()

/obj/machinery/modular_fabricator/proc/make_item(power, var/list/materials_used, var/list/picked_materials, multiplier, coeff, is_stack, requested_design_id, queue_data)
	if(QDELETED(src))
		return
	//Stops the queue
	if(disabled)
		operating = FALSE
		busy = FALSE
		set_default_sprite()
		// requeue the item
		add_to_queue(item_queue, requested_design_id, stored_item_amount + 1, queue_data["build_mat"])
		stored_item_amount = 0
		return
	var/datum/component/material_container/materials = get_material_container()
	if(!materials.has_materials(materials_used))
		operating = FALSE
		wants_operate = TRUE
		busy = FALSE
		set_default_sprite()
		// requeue the item
		add_to_queue(item_queue, requested_design_id, stored_item_amount + 1, queue_data["build_mat"])
		stored_item_amount = 0
		return
	var/turf/A = get_release_turf()
	use_power(power)
	materials.use_materials(materials_used)
	if(is_stack)
		var/obj/item/stack/N = new being_built.build_path(A, multiplier)
		N.update_icon()
	else
		for(var/i in 1 to multiplier)
			var/obj/item/new_item = new being_built.build_path(A)
			new_item.materials.Cut()	//appearantly the material datum gets initialized in a subsystem so there is no need to qdelete it but we still need to empty the list
			for(var/mat in materials_used)
				new_item.materials[mat] = materials_used[mat] / multiplier

			if(length(picked_materials))
				new_item.set_custom_materials(picked_materials, 1 / multiplier) //Ensure we get the non multiplied amount
	being_built = null
	set_default_sprite()
	busy = FALSE

/obj/machinery/modular_fabricator/proc/set_default_sprite()
	return

/obj/machinery/modular_fabricator/proc/set_working_sprite()
	return
