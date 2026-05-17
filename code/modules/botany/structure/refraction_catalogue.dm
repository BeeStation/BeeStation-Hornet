/obj/machinery/refraction_catalogue
	name = "refraction matrix"
	desc = "An experimental device used to calculate plant reagent refraction coefficients."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "refractor"
	density = TRUE
	anchored = FALSE
	pass_flags_self = PASSSTRUCTURE
	pass_flags = NONE

	//TODO: - The code for this and all UIs needs to be improved probably - Racc

	var/selected_reagent

	/*
		//TODO: Upgrading parts will lower list_accuracy(good) - Racc
		Make it an option to scroll forward and backwards through these lists
	*/
	///Controls which reagent list we're using - lower is better :trolled:
	var/list_accuracy = GRID_MAX_ACCURACY
	///Controls the offset / obfuscation - higher is better
	var/accuracy = 0 //Mostly for testing, debug, and admin foolery

	var/grid_x = 0
	var/grid_y = 0

	///Inserted disk we're saving data too
	var/obj/item/disk/plant_disk/disk

	///Refernece to our screen effect
	var/obj/effect/hydroponics_screen/screen

	///
	var/list/sampled_reagents = list()

/obj/machinery/refraction_catalogue/Initialize(mapload)
	. = ..()
	new /obj/item/sticker/sticky_note/tutorial/refraction(src)
	screen = new(src, "refractor_on")

/obj/machinery/refraction_catalogue/add_context_self(datum/screentip_context/context, mob/user)
	. = ..()
	if(!isliving(user))
		return
	context.add_left_click_item_action("Seedify Produce", /obj/item/food/grown)

/obj/machinery/refraction_catalogue/RefreshParts()
	. = ..()
	//TODO: - Racc
	var/total_rating = 0
	for(var/obj/item/stock_parts/S in component_parts)
		total_rating += S.rating
	return total_rating

/obj/machinery/refraction_catalogue/attackby(obj/item/C, mob/user)
//Disk
	if(istype(C, /obj/item/disk/plant_disk) && !disk)
		C.forceMove(src)
		disk = C
//Reagent container, for sampling
	else if(istype(C, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = C
		if(!length(container.reagents.reagent_list))
			to_chat(user, span_warning("[container] is empty!"))
			return
		var/length_check = 0
		for(var/datum/reagent/reagent as anything in container.reagents.reagent_list)
		//Flight checks
			if(!SSbotany.refraction_reagents["[list_accuracy]"]["[reagent.type]"])
				continue
			if(reagent.type in sampled_reagents)
				continue
		//Log the reagent
			sampled_reagents += "[reagent.type]"
			length_check += 1
		if(!length_check)
			say("ERROR: Unable to sequence sample. Refraction index not present.")
			playsound(src, 'sound/machines/terminal_error.ogg', 60)
			return
		to_chat(user, span_notice("You sample reagents from [container]."))
		playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)
	ui_update()

/obj/machinery/refraction_catalogue/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
//Remove disk
	if(!disk)
		return
	disk.forceMove(get_turf(src))
	user.put_in_active_hand(disk)
	disk = null

/obj/machinery/refraction_catalogue/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReagentGridAlt")
		ui.open()

/obj/machinery/refraction_catalogue/ui_data(mob/user)
	var/list/data = list()
	data["all_reagent_data"] = SSbotany.refraction_reagents["[list_accuracy]"]
	data["reagent_data"] = SSbotany.refraction_reagents["[list_accuracy]"]-sampled_reagents
	data["selected_reagent"] = selected_reagent
	data["accuracy"] = accuracy
	data["sampled_reagents"] = SSbotany.refraction_reagents["[list_accuracy]"]&sampled_reagents
	return data

/obj/machinery/refraction_catalogue/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("select_reagent")
			selected_reagent = params["key"]
			grid_x = params["grid_x"]
			grid_y = params["grid_y"]
		if("upload_coords")
			if(!disk)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: No disk inserted!")
				return
			if(disk.saved)
				QDEL_NULL(disk.saved)
			var/datum/plant_trait/refraction/trait = new(null, grid_x, grid_y, list_accuracy)
			disk.set_saved(trait)
			playsound(src, 'sound/machines/ping.ogg', 30)
	screen.flash()
	return TRUE

