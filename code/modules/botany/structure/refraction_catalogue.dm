/obj/machinery/refraction_catalogue
	name = "refraction matrix"
	desc = "An experimental device used to calculate plant reagent refraction coefficients."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "refractor"
	density = TRUE
	anchored = FALSE
	pass_flags = PASSTABLE
	//interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

	//TODO: sampling reagents also helps reveal other reagents, reduces nearby reagents obscuration - Racc
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

/obj/machinery/refraction_catalogue/attackby(obj/item/C, mob/user)
//Disk
	if(istype(C, /obj/item/disk/plant_disk) && !disk)
		C.forceMove(src)
		disk = C
		ui_update()
		return

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
	data["reagent_data"] = SSbotany.refraction_reagents["[list_accuracy]"]
	data["selected_reagent"] = selected_reagent
	data["accuracy"] = accuracy
	return data

/obj/machinery/refraction_catalogue/ui_act(action, params)
	. = ..()
	if(..())
		return
	switch(action)
		if("select_reagent")
			selected_reagent = params["key"]
			grid_x = params["grid_x"]
			grid_y = params["grid_y"]
		if("upload_coords")
			if(!SSbotany.refraction_coords["[list_accuracy]"]["[grid_x]:[grid_y]"])
				return //TODO: Does it matter if the UI doesnt update here? - Racc
			if(disk.saved)
				QDEL_NULL(disk.saved)
			var/datum/plant_trait/refraction/trait = new(null, grid_x, grid_y, list_accuracy)
			disk.set_saved(trait)
	ui_update()

