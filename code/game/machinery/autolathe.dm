#define AUTOLATHE_MAX_POWER_USE 2000

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using iron, copper, and glass."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/autolathe
	layer = BELOW_OBJ_LAYER

	var/operating = FALSE
	var/wants_operate = FALSE
	var/disabled = 0
	var/shocked = FALSE
	var/hack_wire
	var/disable_wire
	var/shock_wire

	//Security modes
	var/security_interface_locked = TRUE
	var/hacked = FALSE

	var/busy = FALSE
	var/prod_coeff = 1

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
	var/obj/item/disk/design_disk/inserted_disk

	//A list of all the printable items

	//Queue items

	//Viewing mobs of the UI to update
	var/list/mob/viewing_mobs = list()
	//Associative list: item_queue[design_id] = list("amount" = int, "repeating" = bool, "build_mat" = something)
	//These are the items in the build queue. (It's a queue that takes priority over item_queue)
	var/list/build_queue = list()
	//Associative list: item_queue[design_id] = list("amount" = int, "repeating" = bool, "build_mat" = something)
	//The items in the item queue
	var/list/item_queue = list()
	//If true, once an item is processed it will be stuck right back on again
	var/queue_repeating = FALSE
	//The amount to readd to the queue when processing is done
	var/stored_item_amount

/obj/machinery/autolathe/Initialize()
	AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/glass, /datum/material/copper, /datum/material/gold, /datum/material/gold, /datum/material/silver, /datum/material/diamond, /datum/material/uranium, /datum/material/plasma, /datum/material/bluespace, /datum/material/bananium, /datum/material/titanium), 0, TRUE, null, null, CALLBACK(src, .proc/AfterMaterialInsert))
	. = ..()

	wires = new /datum/wires/autolathe(src)
	stored_research = new /datum/techweb/specialized/autounlocking/autolathe

/obj/machinery/autolathe/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/autolathe/ui_state()
	return GLOB.default_state

/obj/machinery/autolathe/ui_interact(mob/user, datum/tgui/ui = null)
	if(!is_operational())
		return

	if(shocked && !(stat & NOPOWER))
		shock(user,50)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularFabricator")
		ui.open()
		ui.set_autoupdate(TRUE)
		viewing_mobs += user

/obj/machinery/autolathe/ui_close(mob/user)
	. = ..()
	viewing_mobs -= user

/obj/machinery/autolathe/ui_static_data(mob/user)
	var/list/data = list()
	data["acceptsDisk"] = TRUE

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
					"amount" = D.materials[material_id] / MINERAL_MATERIAL_AMOUNT,
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

/obj/machinery/autolathe/ui_data(mob/user)
	var/list/data = list()
	//Output direction
	data["outputDir"] = output_direction

	//Queue
	data["queue"] = list()

	//Build queue at the top
	for(var/item_design_id in build_queue)
		var/datum/design/D = SSresearch.techweb_design_by_id(item_design_id)
		var/list/additional_data = build_queue[item_design_id]
		data["queue"] += list(list(
			"name" = D.name,
			"amount" = additional_data["amount"],
			"repeat" = additional_data["repeating"],
			"design_id" = item_design_id,
			"build_queue" = 1,
		))

	//Real queue at the bottom
	for(var/item_design_id in item_queue)
		var/datum/design/D = SSresearch.techweb_design_by_id(item_design_id)
		var/list/additional_data = item_queue[item_design_id]
		data["queue"] += list(list(
			"name" = D.name,
			"amount" = additional_data["amount"],
			"repeat" = additional_data["repeating"],
			"design_id" = item_design_id,
			"build_queue" = 0,
		))

	//Materials
	data["materials"] = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/material in materials.materials)
		var/datum/material/M = material
		var/mineral_amount = materials.materials[material]
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

	//Security interface
	data["sec_interface_unlock"] = !security_interface_locked
	data["hacked"] = hacked

	//Being Build
	return data

/obj/machinery/autolathe/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("toggle_safety")
			if(security_interface_locked)
				return
			adjust_hacked(!hacked)

		if("toggle_lock")
			if(obj_flags & EMAGGED)
				return
			security_interface_locked = TRUE

		if("output_dir")
			output_direction = text2num(params["direction"])

		if("upload_disk")
			var/obj/item/disk/design_disk/D = inserted_disk
			if(!istype(D))
				return
			for(var/B in D.blueprints)
				if(B)
					stored_research.add_design(B)
			update_viewer_statics()

		if("eject_disk")
			if(!inserted_disk)
				return
			var/obj/item/disk/design_disk/disk = inserted_disk
			disk.forceMove(get_turf(src))
			update_viewer_statics()

		if("eject_material")
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/material_datum = params["material_datum"]	//Comes out as text
			var/amount = text2num(params["amount"])
			if(amount <= 0 || amount > 50)
				return
			for(var/mat in materials.materials)
				var/datum/material/M = mat
				if("[M.type]" == material_datum)
					materials.retrieve_sheets(amount, M, get_release_turf())
					break

		if("queue_repeat")
			queue_repeating = text2num(params["repeating"])

		if("clear_queue")
			item_queue.Cut()

		if("item_repeat")
			var/design_id = params["design_id"]
			var/repeating_mode = text2num(params["repeating"])
			if(!item_queue["[design_id]"])
				return
			item_queue["[design_id]"]["repeating"] = repeating_mode

		if("clear_item")
			var/design_id = params["design_id"]
			var/queue_type = text2num(params["build_queue"])
			if(queue_type)
				build_queue -= design_id
			else
				item_queue -= design_id

		if("queue_item")
			var/design_id = params["design_id"]
			var/amount = text2num(params["amount"])
			add_to_queue(item_queue, design_id, amount)

		if("build_item")
			var/design_id = params["design_id"]
			var/amount = text2num(params["amount"])
			add_to_queue(build_queue, design_id, amount)

		if("begin_process")
			begin_process()

	//Update the UI for them so it's smooth
	ui_interact(usr)

/obj/machinery/autolathe/proc/update_viewer_statics()
	for(var/mob/M in viewing_mobs)
		if(QDELETED(M) || !(M.client || M.mind))
			continue
		update_static_data(M)

/obj/machinery/autolathe/proc/add_to_queue(queue_list, design_id, amount, repeat=null)
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
				var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
				var/list/list_to_show = list()
				for(var/i in SSmaterials.materials_by_category[used_material])
					if(materials.materials[i] > 0)
						list_to_show += i
				used_material = input("Choose [used_material]", "Custom Material") as null|anything in sortList(list_to_show, /proc/cmp_typepaths_asc)
				if(!used_material)
					return //Didn't pick any material, so you can't build shit either.

	queue_list["[design_id]"] = list(
		"amount" = amount,
		"repeating" = repeat,
		"build_mat" = used_material,
	)

/obj/machinery/autolathe/proc/get_release_turf()
	var/turf/T
	if(output_direction)
		T = get_step(src, output_direction)
		if(is_blocked_turf(T, TRUE))
			T = get_turf(src)
	else
		T = get_turf(src)
	return T

/obj/machinery/autolathe/on_deconstruction()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

/obj/machinery/autolathe/attackby(obj/item/O, mob/user, params)

	if(ACCESS_SECURITY in O.GetAccess() && !(obj_flags & EMAGGED))
		security_interface_locked = !security_interface_locked
		to_chat(user, "<span class='warning'>You [security_interface_locked?"lock":"unlock"] the security controls of [src].</span>")
		return TRUE

	if (busy)
		to_chat(user, "<span class=\"alert\">The autolathe is busy. Please wait for completion of previous operation.</span>")
		return TRUE

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(stat)
		return TRUE

	if(istype(O, /obj/item/disk/design_disk))
		user.visible_message("[user] loads \the [O] into \the [src]...",
			"You load a design from \the [O]...",
			"You hear the chatter of a floppy drive.")
		inserted_disk = O
		O.forceMove(src)
		update_viewer_statics()
		return TRUE

	return ..()


/obj/machinery/autolathe/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		switch(id_inserted)
			if (/datum/material/iron)
				flick("autolathe_o",src)//plays metal insertion animation
			if(/datum/material/copper)
				flick("autolathe_c",src)//plays metal insertion animation
			else
				flick("autolathe_r",src)//plays glass insertion animation by default otherwise
		use_power(min(1000, amount_inserted / 100))
	//Begin processing to continue the queue if we had items in the queue
	if(wants_operate)
		begin_process()

/obj/machinery/autolathe/proc/begin_process()
	if(busy || operating || disabled)
		return
	var/requested_design_id = null
	var/from_build_queue = FALSE
	if(LAZYLEN(build_queue))
		requested_design_id = build_queue[1]
		from_build_queue = TRUE
	else if(LAZYLEN(item_queue))
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
		build_queue -= requested_design_id
		item_queue -= requested_design_id
		addtimer(CALLBACK(src, .proc/restart_process), 50)
		return

	var/multiplier = 1
	var/is_stack = ispath(being_built.build_path, /obj/item/stack)
	//Only items that can stack should be build en mass, since we now have queues.
	if(is_stack)
		if(from_build_queue)
			multiplier = build_queue[requested_design_id]["amount"]
		else
			multiplier = item_queue[requested_design_id]["amount"]
	multiplier = CLAMP(multiplier,1,50)

	/////////////////

	var/coeff = (is_stack ? 1 : prod_coeff) //stacks are unaffected by production coefficient
	var/total_amount = 0

	for(var/MAT in being_built.materials)
		total_amount += being_built.materials[MAT]

	var/power = max(AUTOLATHE_MAX_POWER_USE, (total_amount)*multiplier/5) //Change this to use all materials

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	var/list/materials_used = list()
	var/list/custom_materials = list() //These will apply their material effect, This should usually only be one.

	for(var/MAT in being_built.materials)
		var/datum/material/used_material = MAT
		var/amount_needed = being_built.materials[MAT] * coeff * multiplier
		if(istext(used_material)) //This means its a category
			if(from_build_queue)
				used_material = build_queue[requested_design_id]["build_mat"]
			else
				used_material = item_queue[requested_design_id]["build_mat"]
			if(!used_material)
				build_queue -= requested_design_id
				item_queue -= requested_design_id
				addtimer(CALLBACK(src, .proc/restart_process), 50)
				return //Didn't pick any material, so you can't build shit either.
			custom_materials[used_material] += amount_needed

		materials_used[used_material] = amount_needed

	if(materials.has_materials(materials_used))
		busy = TRUE
		use_power(power)
		icon_state = "autolathe_n"
		var/time = is_stack ? 32 : (32 * coeff * multiplier) ** 0.8
		//===Repeating mode===
		//Remove from queue
		if(from_build_queue)
			build_queue[requested_design_id]["amount"] -= multiplier
			if(build_queue[requested_design_id]["amount"] <= 0)
				build_queue -= requested_design_id
		else
			var/list/queue_data = item_queue[requested_design_id]
			item_queue[requested_design_id]["amount"] -= multiplier
			var/removed = FALSE
			if(item_queue[requested_design_id]["amount"] <= 0)
				item_queue -= requested_design_id
				removed = TRUE
			//Requeue if necessary
			if(queue_repeating || queue_data["repeating"])
				stored_item_amount ++
				if(removed)
					add_to_queue(item_queue, requested_design_id, stored_item_amount, queue_data["build_mat"])
					stored_item_amount = 0
		//Create item and restart
		process_completion_world_tick = world.time + time
		total_build_time = time
		addtimer(CALLBACK(src, .proc/make_item, power, materials_used, custom_materials, multiplier, coeff, is_stack), time)
		addtimer(CALLBACK(src, .proc/restart_process), time + 5)
	else
		say("Insufficient materials, operation will proceed when sufficient materials are available.")
		operating = FALSE
		wants_operate = TRUE

/obj/machinery/autolathe/proc/restart_process()
	operating = FALSE
	wants_operate = FALSE
	if(disabled)
		return
	begin_process()

/obj/machinery/autolathe/proc/make_item(power, var/list/materials_used, var/list/picked_materials, multiplier, coeff, is_stack)
	if(QDELETED(src))
		return
	//Stops the queue
	if(disabled)
		operating = FALSE
		return
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/turf/A = get_release_turf()
	use_power(power)
	materials.use_materials(materials_used)
	if(is_stack)
		var/obj/item/stack/N = new being_built.build_path(A, multiplier)
		N.update_icon()
		N.autolathe_crafted(src)
	else
		for(var/i=1, i<=multiplier, i++)
			var/obj/item/new_item = new being_built.build_path(A)
			new_item.materials = new_item.materials.Copy()
			for(var/mat in materials_used)
				new_item.materials[mat] = materials_used[mat] / multiplier
			new_item.autolathe_crafted(src)

			if(length(picked_materials))
				new_item.set_custom_materials(picked_materials, 1 / multiplier) //Ensure we get the non multiplied amount
	being_built = null
	icon_state = "autolathe"
	busy = FALSE

/obj/machinery/autolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		T += MB.rating*75000
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = T
	T=1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = min(1,max(0,T)) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/autolathe/examine(mob/user)
	. += ..()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[prod_coeff*100]%</b>.<span>"

/obj/machinery/autolathe/proc/can_build(datum/design/D, amount = 1)
	if(D.make_reagents.len)
		return FALSE

	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)

	var/list/required_materials = list()

	for(var/i in D.materials)
		required_materials[i] = D.materials[i] * coeff * amount

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	return materials.has_materials(required_materials)

/obj/machinery/autolathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/autolathe/proc/adjust_hacked(state)
	hacked = state
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(id)
		if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
			if(hacked)
				stored_research.add_design(D)
			else
				stored_research.remove_design(D)
	update_viewer_statics()

/obj/machinery/autolathe/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	security_interface_locked = FALSE
	adjust_hacked(TRUE)
	playsound(src, "sparks", 100, 1)
	obj_flags |= EMAGGED

/obj/machinery/autolathe/hacked/Initialize()
	. = ..()
	adjust_hacked(TRUE)

//Called when the object is constructed by an autolathe
//Has a reference to the autolathe so you can do !!FUN!! things with hacked lathes
/obj/item/proc/autolathe_crafted(obj/machinery/autolathe/A)
	return
