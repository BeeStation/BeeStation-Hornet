#define MAX_SENT 10

/obj/machinery/rnd/production
	name = "technology fabricator"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER
	/// Whether it can be used without a console.
	var/consoleless_interface = FALSE
	/// Used for material distribution among other things.
	var/efficiency_coeff = 1
	var/list/categories = list()
	var/datum/component/remote_materials/materials
	var/allowed_department_flags = ALL
	/// What's flick()'d on print.
	var/production_animation
	var/allowed_buildtypes = NONE
	var/list/datum/design/cached_designs
	var/list/datum/design/matching_designs
	/// Used for material distribution among other things.
	var/department_tag = "Unidentified"
	var/datum/techweb/stored_research
	var/datum/techweb/host_research

	var/search = null
	var/selected_category = null

	/// What color is this machine's stripe? Leave null to not have a stripe.
	var/stripe_color = null

	var/list/mob/viewing_mobs = list()

	/// Only used for storing pending research for examine()
	var/list/pending_research = list()
	var/base_storage = 75000

/obj/machinery/rnd/production/Initialize(mapload)
	. = ..()
	create_reagents(0, OPENCONTAINER)
	matching_designs = list()
	cached_designs = list()
	stored_research = new
	host_research = SSresearch.science_tech
	update_research()
	materials = AddComponent(/datum/component/remote_materials, "lathe", mapload, mat_container_flags=BREAKDOWN_FLAGS_LATHE)
	RefreshParts()
	RegisterSignal(src, COMSIG_MATERIAL_CONTAINER_CHANGED, PROC_REF(on_materials_changed))
	RegisterSignal(src, COMSIG_REMOTE_MATERIALS_CHANGED, PROC_REF(on_materials_changed))
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_RESEARCH, PROC_REF(alert_research))

/obj/machinery/rnd/production/Destroy()
	custom_materials = null
	cached_designs = null
	matching_designs = null
	QDEL_NULL(stored_research)
	host_research = null
	return ..()

/obj/machinery/rnd/production/examine(mob/user)
	. = ..()
	var/num_research = length(pending_research)
	if(num_research)
		. += "\nPENDING RESEARCH:"
		var/list/displayed = reverseList(pending_research)  // newest first
		if(num_research >= MAX_SENT)
			displayed.Cut(MAX_SENT)
			displayed += "..."
		. += displayed.Join("\n")

// Stuff for the stripe on the department machines
/obj/machinery/rnd/production/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	. = ..()
	update_icon()

/obj/machinery/rnd/production/update_icon()
	. = ..()
	cut_overlays()
	if(stripe_color)
		var/mutable_appearance/stripe = mutable_appearance('icons/obj/machines/research.dmi', "protolate_stripe")
		stripe.color = stripe_color
		if(!panel_open)
			cut_overlays()
			stripe.icon_state = "protolathe_stripe"
		else
			stripe.icon_state = "protolathe_stripe_t"
		add_overlay(stripe)
	if(length(pending_research))
		add_overlay("lathe-research")

/obj/machinery/rnd/production/proc/on_materials_changed()
	SIGNAL_HANDLER
	ui_update()

/obj/machinery/rnd/production/on_reagent_change(changetype)
	. = ..()
	ui_update()

/obj/machinery/rnd/production/proc/update_research()
	host_research.copy_research_to(stored_research, TRUE)
	update_designs()

/obj/machinery/rnd/production/proc/alert_research(datum/source, node_id)
	SIGNAL_HANDLER

	var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)

	for(var/i in node.design_ids)
		var/datum/design/d = SSresearch.techweb_design_by_id(i)
		if((isnull(allowed_department_flags) || (d.departmental_flags & allowed_department_flags)) && (d.build_type & allowed_buildtypes))
			pending_research += d.name
	update_icon()

/obj/machinery/rnd/production/proc/update_designs()
	pending_research.Cut()
	cached_designs.Cut()
	for(var/i in stored_research.researched_designs)
		var/datum/design/d = SSresearch.techweb_design_by_id(i)
		if((isnull(allowed_department_flags) || (d.departmental_flags & allowed_department_flags)) && (d.build_type & allowed_buildtypes))
			cached_designs |= d
	update_viewer_statics()
	update_icon()

/obj/machinery/rnd/production/RefreshParts()
	calculate_efficiency()
	ui_update()

/obj/machinery/rnd/production/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TechFab")
		ui.open()
		viewing_mobs += user

/obj/machinery/rnd/production/ui_close(mob/user)
	. = ..()
	viewing_mobs -= user

/obj/machinery/rnd/production/proc/update_viewer_statics()
	for(var/mob/M as() in viewing_mobs)
		if(QDELETED(M) || !(M.client || M.mind))
			continue
		update_static_data(M)

/obj/machinery/rnd/production/ui_data(mob/user)
	var/list/data = list()

	data["busy"] = busy
	data["efficiency"] = efficiency_coeff

	data["category"] = selected_category
	data["search"] = search

	data += build_materials()
	data += build_reagents()

	return data

/obj/machinery/rnd/production/proc/build_materials()
	if(!materials || !materials.mat_container)
		return null

	var/list/L = list()
	for(var/datum/material/material as() in materials.mat_container.materials)
		L[material.name] = list(
				name = material.name,
				amount = materials.mat_container.materials[material]/MINERAL_MATERIAL_AMOUNT,
			)

	return list(
		materials = L,
		materials_label = materials.format_amount()
	)

/obj/machinery/rnd/production/proc/build_reagents()
	if(!reagents)
		return null

	var/list/L = list()
	for(var/datum/reagent/reagent as() in reagents.reagent_list)
		L["[reagent.type]"] = list(
				name = reagent.name,
				volume = reagent.volume,
				id = "[reagent.type]",
			)

	return list(
		reagents = L,
		reagents_label = "[reagents.total_volume] / [reagents.maximum_volume]"
	)

/obj/machinery/rnd/production/ui_static_data(mob/user)
	var/list/data = list()

	data["recipes"] = build_recipes()
	data["categories"] = categories
	data["stack_to_mineral"] = MINERAL_MATERIAL_AMOUNT

	return data

/obj/machinery/rnd/production/proc/build_recipes()
	var/list/L = list()
	for(var/datum/design/design as() in cached_designs)
		L += list(build_design(design))
	return L

/obj/machinery/rnd/production/proc/build_design(datum/design/design)
	return list(
			name = design.name,
			description = design.desc,
			id = design.id,
			category = design.category,
			max_amount = design.maxstack,
			efficiency_affects = efficient_with(design.build_path),
			materials = design.materials,
			reagents = build_recipe_reagents(design.reagents_list),
		)

/obj/machinery/rnd/production/proc/build_recipe_reagents(list/reagents)
	var/list/L = list()

	for(var/id in reagents)
		L[id] = list(
			name = CallMaterialName(id),
			volume = reagents[id],
		)

	return L

/obj/machinery/rnd/production/ui_act(action, params)
	if(..())
		return
	if(action == "build")
		if(busy)
			say("Warning: Fabricators busy!")
		else
			user_try_print_id(params["design_id"], params["amount"])
			. = TRUE
	if(action == "sync_research")
		update_research()
		say("Synchronizing research with host technology database.")
		. = TRUE
	if(action == "dispose")
		var/R = text2path(params["reagent_id"])
		if(R)
			reagents.del_reagent(R)
			. = TRUE
	if(action == "disposeall")
		reagents.clear_reagents()
		. = TRUE
	if(action == "ejectsheet" && materials && materials.mat_container)
		var/datum/material/M
		for(var/datum/material/potential_material as() in materials.mat_container.materials)
			if(potential_material.name == params["material_id"])
				M = potential_material
				break
		if(M)
			eject_sheets(M, params["amount"])
			. = TRUE
	if(action == "search")
		var/new_search = params["value"]
		if(new_search != search)
			search = new_search
			. = TRUE
	if(action == "category")
		var/new_category = params["category"]
		if(new_category != selected_category)
			search = null
			selected_category = new_category
			. = TRUE
	if(action == "mainmenu" && (search != null || selected_category != null))
		search = null
		selected_category = null
		. = TRUE

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
			total_storage += M.rating * base_storage
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

/obj/machinery/rnd/production/proc/do_print(path, amount, list/matlist, notify_admins)
	if(notify_admins && ismob(usr))
		usr.investigate_log(" built [amount] of [path] at [src]([type]).", INVESTIGATE_RESEARCH)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has built [amount] of [path] at \a [src]([type]).")
	for(var/i in 1 to amount)
		new path(get_turf(src))
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

/obj/machinery/rnd/production/proc/efficient_with(path)
	return !ispath(path, /obj/item/stack/sheet) && !ispath(path, /obj/item/stack/ore/bluespace_crystal)

/obj/machinery/rnd/production/proc/user_try_print_id(id, amount)
	if((!istype(linked_console) && requires_console) || !id)
		return FALSE
	if(istext(amount))
		amount = text2num(amount)
	if(isnull(amount))
		amount = 1
	var/datum/design/D = (linked_console || requires_console)? (linked_console.stored_research.researched_designs[id]? SSresearch.techweb_design_by_id(id) : null) : SSresearch.techweb_design_by_id(id)
	if(!istype(D))
		return FALSE
	if(!(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
		say("Warning: Printing failed: This fabricator does not have the necessary keys to decrypt design schematics. Please update the research data with the on-screen button and contact Nanotrasen Support!")
		return FALSE
	if(D.build_type && !(D.build_type & allowed_buildtypes))
		say("This machine does not have the necessary manipulation systems for this design. Please contact Nanotrasen Support!")
		return FALSE
	if(!materials.mat_container)
		say("No connection to material storage, please contact the quartermaster.")
		return FALSE
	if(materials.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE
	var/power = 1000
	amount = clamp(amount, 1, 10)
	for(var/M in D.materials)
		power += round(D.materials[M] * amount / 35)
	power = min(3000, power)
	use_power(power)
	var/coeff = efficient_with(D.build_path) ? efficiency_coeff : 1
	var/list/efficient_mats = list()
	for(var/MAT in D.materials)
		efficient_mats[MAT] = D.materials[MAT]/coeff
	if(!materials.mat_container.has_materials(efficient_mats, amount))
		say("Not enough materials to complete prototype[amount > 1? "s" : ""].")
		return FALSE
	for(var/R in D.reagents_list)
		if(!reagents.has_reagent(R, D.reagents_list[R]*amount))
			say("Not enough reagents to complete prototype[amount > 1? "s" : ""].")
			return FALSE
	materials.mat_container.use_materials(efficient_mats, amount)
	materials.silo_log(src, "built", -amount, "[D.name]", efficient_mats)
	for(var/R in D.reagents_list)
		reagents.remove_reagent(R, D.reagents_list[R]*amount)
	busy = TRUE
	if(production_animation)
		flick(production_animation, src)
	var/timecoeff = D.lathe_time_factor / efficiency_coeff
	addtimer(CALLBACK(src, PROC_REF(reset_busy)), (30 * timecoeff * amount) ** 0.5)
	addtimer(CALLBACK(src, PROC_REF(do_print), D.build_path, amount, efficient_mats, D.dangerous_construction), (32 * timecoeff * amount) ** 0.8)
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
	SStgui.update_uis(src)


#undef MAX_SENT
