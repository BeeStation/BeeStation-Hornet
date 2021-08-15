///We take a constant input of reagents, and produce a pill once a set volume is reached
/obj/machinery/plumbing/pill_press
	name = "pill press"
	desc = "A press that presses pills."
	icon_state = "pill_press"
	active_power_usage = 100
	///the minimum size a pill can be
	var/minimum_pill = 5
	///the maximum size a pill can be
	var/maximum_pill = 50
	///the size of the pill
	var/pill_size = 10
	///pill name
	var/pill_name = "factory pill"
	///the icon_state number for the pill.
	var/pill_number = RANDOM_PILL_STYLE
	///list of id's and icons for the pill selection of the ui
	var/list/pill_styles
	///list of pills stored in the machine, so we dont have 610 pills on one tile
	var/list/stored_pills = list()
	var/max_stored_pills = 3
	///max amount of pills allowed on our tile before we start storing them instead
	var/max_floor_pills = 10




/obj/machinery/plumbing/pill_press/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The [name] currently has [stored_pills.len] stored. There needs to be less than [max_floor_pills] on the floor to continue dispensing.</span>"

/obj/machinery/plumbing/pill_press/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)

	//expertly copypasted from chemmasters
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	pill_styles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		var/list/SL = list()
		SL["id"] = x
		SL["class_name"] = assets.icon_class_name("pill[x]")
		pill_styles += list(SL)

/obj/machinery/plumbing/pill_press/process()
	if(stat & NOPOWER)
		return
	if((reagents.total_volume >= pill_size) && (stored_pills.len < max_stored_pills))
		var/obj/item/reagent_containers/pill/P = new(src)
		reagents.trans_to(P, pill_size)
		P.name = pill_name
		stored_pills += P
		if(pill_number == RANDOM_PILL_STYLE)
			P.icon_state = "pill[rand(1,21)]"
		else
			P.icon_state = "pill[pill_number]"
		if(P.icon_state == "pill4") //mirrored from chem masters
			P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
	if(stored_pills.len)
		var/pill_amount = 0
		for(var/obj/item/reagent_containers/pill/P in loc)
			pill_amount++
			if(pill_amount >= max_floor_pills) //too much so just stop
				break
		if(pill_amount < max_floor_pills)
			var/atom/movable/AM = stored_pills[1] //AM because forceMove is all we need
			stored_pills -= AM
			AM.forceMove(drop_location())

/obj/machinery/plumbing/pill_press/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/pills),
	)


/obj/machinery/plumbing/pill_press/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/pill_press/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemPress")
		ui.open()

/obj/machinery/plumbing/pill_press/ui_data(mob/user)
	var/list/data = list()
	data["pill_style"] = pill_number
	data["pill_size"] = pill_size
	data["pill_name"] = pill_name
	data["pill_styles"] = pill_styles
	return data

/obj/machinery/plumbing/pill_press/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("change_pill_style")
			pill_number = CLAMP(text2num(params["id"]), 1 , PILL_STYLE_COUNT)
		if("change_pill_size")
			pill_size = CLAMP(text2num(params["volume"]), minimum_pill, maximum_pill)
		if("change_pill_name")
			var/new_name = stripped_input(usr, "Enter a pill name.", name, pill_name)
			if(findtext(new_name, "pill")) //names like pillatron and Pilliam are thus valid
				pill_name = new_name
			else
				pill_name = new_name + " pill"
