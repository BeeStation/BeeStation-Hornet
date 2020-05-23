///We take a constant input of reagents, and produce a patch once a set volume is reached
/obj/machinery/plumbing/patch_dispenser
	name = "patch dispenser"
	desc = "A dispenser that dispenses patches."
	icon_state = "pill_press" //TODO SPRITE IT !!!!!!
	var/patch_name = "factory patch"
	var/patch_size = 40
	///the icon_state number for the patch.
	var/list/stored_patches = list()
	///max amount of patches allowed on our tile before we start storing them instead
	var/max_floor_patches = 10

	ui_x = 300
	ui_y = 120

/obj/machinery/plumbing/patch_dispenser/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The [name] currently has [stored_patches.len] stored. There needs to be less than [max_floor_patches] on the floor to continue dispensing.</span>"

/obj/machinery/plumbing/patch_dispenser/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)

/obj/machinery/plumbing/patch_dispenser/process()
	if(stat & NOPOWER)
		return
	if(reagents.total_volume >= patch_size)
		var/obj/item/reagent_containers/pill/patch/P
		P = new/obj/item/reagent_containers/pill/patch(drop_location())
		reagents.trans_to(P, patch_size)
		P.name = patch_name
		stored_patches += P
	if(stored_patches.len)
		var/patch_amount = 0
		for(var/obj/item/reagent_containers/pill/patch/P in loc)
			patch_amount++
			if(patch_amount >= max_floor_patches) //too much so just stop
				break
		if(patch_amount < max_floor_patches)
			var/atom/movable/AM = stored_patches[1] //AM because forceMove is all we need
			stored_patches -= AM
			AM.forceMove(drop_location())

/obj/machinery/plumbing/patch_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PatchDispenser", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/plumbing/patch_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["patch_size"] = patch_size
	data["patch_name"] = patch_name
	return data

/obj/machinery/plumbing/patch_dispenser/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("change_patch_size")
			patch_size = CLAMP(text2num(params["volume"]), 0, 40)
		if("change_patch_name")
			var/new_name = stripped_input(usr, "Enter a patch name.", name, patch_name)
			patch_name = new_name + " patch"
