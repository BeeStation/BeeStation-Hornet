/obj/machinery/rnd/production
	name = "technology fabricator"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER

	/// The efficiency coefficient. Material costs and print times are multiplied by this number;
	var/efficiency_coeff = 1
	/// The material storage used by this fabricator.
	var/datum/component/remote_materials/materials
	/// Which departments are allowed to process this design
	var/allowed_department_flags = ALL
	/// The icon_state when production starts
	var/production_animation
	/// The types of designs this fabricator can print.
	var/allowed_buildtypes = NONE
	/// All designs in the techweb that can be fabricated by this machine, since the last update.
	var/list/datum/design/cached_designs
	/// What color is this machine's stripe? Leave null to not have a stripe.
	var/stripe_color = null
	/// Looping sound for printing items
	var/datum/looping_sound/lathe_print/print_sound
	/// Made so we dont call addtimer() 40,000 times in on_techweb_update(). only allows addtimer() to be called on the first update
	var/techweb_updating = FALSE

	/// TGUI stuff
	var/list/categories = list()
	var/search = null
	var/selected_category = null

/obj/machinery/rnd/production/Initialize(mapload)
	print_sound = new(src, FALSE)
	materials = AddComponent(
		/datum/component/remote_materials, \
		"lathe", \
		mapload, \
		mat_container_flags = BREAKDOWN_FLAGS_LATHE, \
	)

	. = ..()

	cached_designs = list()
	create_reagents(100, OPENCONTAINER)

	RegisterSignal(src, COMSIG_MATERIAL_CONTAINER_CHANGED, PROC_REF(on_materials_changed))
	RegisterSignal(src, COMSIG_REMOTE_MATERIALS_CHANGED, PROC_REF(on_materials_changed))

/obj/machinery/rnd/production/Destroy()
	QDEL_NULL(print_sound)
	custom_materials = null
	cached_designs = null
	return ..()

// Stuff for the stripe on the department machines
/obj/machinery/rnd/production/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/rnd/production/update_overlays()
	. = ..()
	if(!stripe_color)
		return

	var/mutable_appearance/stripe = mutable_appearance('icons/obj/machines/research.dmi', "protolathe_stripe[panel_open ? "_t" : ""]")
	stripe.color = stripe_color
	. += stripe

/obj/machinery/rnd/production/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_info("Material usage cost at <b>[efficiency_coeff * 100]%</b>")
	. += span_info("Build time at <b>[efficiency_coeff * 100]%</b>")

/obj/machinery/rnd/production/connect_techweb(datum/techweb/new_techweb)
	if(stored_research)
		UnregisterSignal(stored_research, list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN))
	return ..()

/obj/machinery/rnd/production/on_connected_techweb()
	. = ..()
	RegisterSignals(
		stored_research,
		list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN),
		TYPE_PROC_REF(/obj/machinery/rnd/production, on_techweb_update)
	)
	update_designs()

/obj/machinery/rnd/production/proc/on_techweb_update()
	SIGNAL_HANDLER

	if(!techweb_updating) //so we batch these updates together
		techweb_updating = TRUE
		addtimer(CALLBACK(src, PROC_REF(update_designs)), 2 SECONDS)

/// Updates the list of designs this fabricator can print.
/obj/machinery/rnd/production/proc/update_designs()
	PROTECTED_PROC(TRUE)
	techweb_updating = FALSE

	var/previous_design_count = length(cached_designs)

	cached_designs.Cut()

	for(var/design_id in stored_research.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)

		if((isnull(allowed_department_flags) || (design.departmental_flags & allowed_department_flags)) && (design.build_type & allowed_buildtypes))
			cached_designs |= design

	var/design_delta = length(cached_designs) - previous_design_count

	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)

	update_static_data_for_all_viewers()

/obj/machinery/rnd/production/proc/on_materials_changed()
	SIGNAL_HANDLER
	ui_update()

/obj/machinery/rnd/production/on_reagent_change(changetype)
	. = ..()
	ui_update()

/obj/machinery/rnd/production/RefreshParts()
	calculate_efficiency()
	ui_update()

/obj/machinery/rnd/production/attackby(obj/item/attacking_item, mob/user, params)
	if(is_refillable() && attacking_item.is_drainable())
		return FALSE // it's stupid that this has to be false, but whatever
	return ..()

/obj/machinery/rnd/production/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TechFab")
		ui.open()

/obj/machinery/rnd/production/ui_data(mob/user)
	var/list/data = list()

	data["busy"] = busy
	data["efficiency"] = efficiency_coeff

	data["category"] = selected_category
	data["search"] = search

	var/list/material_data = build_materials()
	if(material_data)
		data += material_data

	var/list/reagents_data = build_reagents()
	if(reagents_data)
		data += reagents_data

	return data

/obj/machinery/rnd/production/proc/build_materials()
	if(!materials || !materials.mat_container)
		return null

	var/list/materials_list = list()
	for(var/datum/material/material as anything in materials.mat_container.materials)
		materials_list[material.name] = list(
			"name" = material.name,
			"amount" = materials.mat_container.materials[material] / MINERAL_MATERIAL_AMOUNT,
		)

	return list(
		"materials" = materials_list,
		"materials_label" = materials.format_amount()
	)

/obj/machinery/rnd/production/proc/build_reagents()
	if(!reagents)
		return null

	var/list/reagents_list = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		reagents_list["[reagent.type]"] = list(
			"name" = reagent.name,
			"volume" = reagent.volume,
			"id" = "[reagent.type]",
		)

	return list(
		"reagents" = reagents_list,
		"reagents_label" = "[reagents.total_volume] / [reagents.maximum_volume]"
	)

/obj/machinery/rnd/production/ui_static_data(mob/user)
	var/list/data = list()

	data["recipes"] = build_recipes()
	data["categories"] = categories
	data["stack_to_mineral"] = MINERAL_MATERIAL_AMOUNT

	return data

/obj/machinery/rnd/production/proc/build_recipes()
	var/list/recipes_list = list()
	for(var/datum/design/design as anything in cached_designs)
		recipes_list += list(build_design(design))
	return recipes_list

/obj/machinery/rnd/production/proc/build_design(datum/design/design)
	return list(
		"name" = design.name,
		"description" = design.desc,
		"id" = design.id,
		"category" = design.category,
		"efficiency_affects" = efficient_with(design.build_path),
		"materials" = design.materials,
		"reagents" = build_recipe_reagents(design.reagents_list),
	)

/obj/machinery/rnd/production/proc/build_recipe_reagents(list/reagents)
	var/list/recipe_reagents_data = list()

	for(var/id, volume in reagents)
		recipe_reagents_data[id] = list(
			"name" = CallMaterialName(id),
			"volume" = volume,
		)

	return recipe_reagents_data

/obj/machinery/rnd/production/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("build")
			if(busy)
				say("Warning: Fabricators busy!")
				return

			return user_try_print_id(params["design_id"], params["amount"])

		if("dispose")
			var/R = text2path(params["reagent_id"])
			if(R)
				reagents.del_reagent(R)
				return TRUE

		if("disposeall")
			reagents.clear_reagents()
			return TRUE

		if("ejectsheet")
			if(!materials || !materials.mat_container)
				return

			var/datum/material/material_to_eject
			for(var/datum/material/potential_material as anything in materials.mat_container.materials)
				if(potential_material.name == params["material_id"])
					material_to_eject = potential_material
					break
			if(material_to_eject)
				eject_sheets(material_to_eject, params["amount"])
				return TRUE

		if("search")
			var/new_search = params["value"]
			if(new_search != search)
				search = new_search
				return TRUE

		if("category")
			var/new_category = params["category"]
			if(new_category != selected_category)
				search = null
				selected_category = new_category
				return TRUE

		if("mainmenu")
			if(isnull(search) && isnull(selected_category))
				return
			search = null
			selected_category = null
			return TRUE

/obj/machinery/rnd/production/proc/calculate_efficiency()
	efficiency_coeff = 1
	if(reagents)		//If reagents/materials aren't initialized, don't bother, we'll be doing this again after reagents init anyways.
		reagents.maximum_volume = 0
		for(var/obj/item/reagent_containers/cup/G in component_parts)
			reagents.maximum_volume += G.volume
			G.reagents.trans_to(src, G.reagents.total_volume)
	if(materials)
		var/total_storage = 0
		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			total_storage += M.rating * 75000
		materials.set_local_size(total_storage)
	var/total_rating = 1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating = (total_rating - (M.rating * 0.1))
	total_rating = clamp(total_rating, 0, 1.2)
	if(total_rating == 0)
		efficiency_coeff = INFINITY
	else
		efficiency_coeff = 1/total_rating

//we eject the materials upon deconstruction.
/obj/machinery/rnd/production/on_deconstruction()
	for(var/obj/item/reagent_containers/cup/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	return ..()

/obj/machinery/rnd/production/proc/do_print(path, amount, notify_admins)
	if(notify_admins && ismob(usr))
		usr.investigate_log("built [amount] of [path] at [src]([type]).", INVESTIGATE_RESEARCH)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has built [amount] of [path] at \a [src]([type]).")
	for(var/i in 1 to amount)
		new path(drop_location())
	SSblackbox.record_feedback("nested tally", "item_printed", amount, list("[type]", "[path]"))

/obj/machinery/rnd/production/proc/check_mat(datum/design/being_built, mat)	// now returns how many times the item can be built with the material
	if (!materials.mat_container)  // no connected silo
		return 0
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.mat_container.get_material_amount(mat)
	if(!A)
		A = reagents.get_reagent_amount(mat)

	// these types don't have their .materials set in do_print, so don't allow
	// them to be constructed efficiently
	var/ef = efficient_with(being_built.build_path) ? efficiency_coeff : 1
	return round(A / max(1, all_materials[mat] / ef))

/// efficiency_coeff doesn't apply if you're printing a sheet. NO MATERIAL DUPLICATION!
/obj/machinery/rnd/production/proc/efficient_with(path)
	return !ispath(path, /obj/item/stack/sheet) && !ispath(path, /obj/item/stack/ore/bluespace_crystal)

/obj/machinery/rnd/production/proc/user_try_print_id(design_id, amount = 1)
	if(!design_id)
		return FALSE
	if(istext(amount))
		amount = text2num(amount)
	amount = clamp(amount, 1, 10)

	var/datum/design/design = stored_research.researched_designs[design_id] ? SSresearch.techweb_design_by_id(design_id) : null
	if(!istype(design))
		return FALSE

	if(!(isnull(allowed_department_flags) || (design.departmental_flags & allowed_department_flags)))
		say("This fabricator does not have the necessary keys to decrypt this design.")
		return FALSE
	if(design.build_type && !(design.build_type & allowed_buildtypes))
		say("This fabricator does not have the necessary manipulation systems for this design.")
		return FALSE
	if(!materials.mat_container)
		say("No connection to material storage, please contact the quartermaster.")
		return FALSE
	if(materials.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE

	var/coeff = efficient_with(design.build_path) ? efficiency_coeff : 1
	var/list/materials_to_consume = list()
	for(var/material_type, material_amount in design.materials)
		materials_to_consume[material_type] = material_amount / coeff

	if(!materials.mat_container.has_materials(materials_to_consume, amount))
		say("Not enough materials to complete prototype[amount > 1 ? "s" : ""].")
		return FALSE
	for(var/datum/reagent/reagent as anything in design.reagents_list)
		if(!reagents.has_reagent(reagent, design.reagents_list[reagent] * amount))
			say("Not enough reagents to complete prototype[amount > 1 ? "s" : ""].")
			return FALSE

	// Consume power
	var/power = 1000
	for(var/M in design.materials)
		power += round(design.materials[M] * amount / 35)
	power = min(3000, power)
	use_power(power)

	// Consume materials & reagents
	materials.mat_container.use_materials(materials_to_consume, amount)
	materials.silo_log(src, "built", -amount, "[design.name]", materials_to_consume)
	for(var/datum/reagent/reagent as anything in design.reagents_list)
		reagents.remove_reagent(reagent, design.reagents_list[reagent] * amount)

	// Start production
	busy = TRUE
	print_sound.start()
	if(production_animation)
		icon_state = production_animation

	var/timecoeff = design.lathe_time_factor / efficiency_coeff
	addtimer(CALLBACK(src, PROC_REF(reset_busy)), (30 * timecoeff * amount) ** 0.6)
	addtimer(CALLBACK(src, PROC_REF(do_print), design.build_path, amount, design.dangerous_construction), (32 * timecoeff * amount) ** 0.5)
	return TRUE

/obj/machinery/rnd/production/proc/eject_sheets(eject_sheet, eject_amt)
	var/datum/component/material_container/mat_container = materials.mat_container
	if (!mat_container)
		say("No access to material storage, please contact the quartermaster.")
		return 0
	if (materials.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return 0
	var/count = mat_container.retrieve_sheets(text2num(eject_amt), eject_sheet, drop_location())
	var/list/matlist = list()
	matlist[eject_sheet] = MINERAL_MATERIAL_AMOUNT
	materials.silo_log(src, "ejected", -count, "sheets", matlist)
	return count

/obj/machinery/rnd/production/reset_busy()
	. = ..()
	print_sound.stop()
	icon_state = initial(icon_state)
	SStgui.update_uis(src)
