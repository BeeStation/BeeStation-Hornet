/obj/machinery/refraction_catalogue
	name = "refraction matrix"
	desc = "An experimental device used to calculate plant reagent refraction coefficients."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE
	pass_flags = PASSTABLE
	//interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	//TODO: sampling reagents also helps reveal other reagents, reduces nearby reagents obscuration - Racc
	//TODO: - The code for this and all UIs needs to be improved probably - Racc
	//TODO: Have each level of accuracy be a different map, increased accuracy gives maps with more bunched in chemicals with smaller radius - Racc

	var/selected_reagent

	var/accuracy = 0

	var/grid_x = 0
	var/grid_y = 0


/obj/machinery/refraction_catalogue/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReagentGridAlt")
		ui.open()

/obj/machinery/refraction_catalogue/ui_data(mob/user)
	var/list/data = list()
	data["reagent_data"] = SSbotany.refraction_reagents
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
			if(SSbotany.refraction_coords["[grid_x]:[grid_y]"])
				say("hit")
				//var/datum/reagent/reagent = text2path(SSbotany.refraction_coords["[grid_x]:[grid_y]"])
			else
				say("miss")
	ui_update()

