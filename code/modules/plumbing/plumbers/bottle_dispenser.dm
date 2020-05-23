///We take a constant input of reagents, and produce a bottle once a set volume is reached
/obj/machinery/plumbing/bottle_dispenser
	name = "bottle dispenser"
	desc = "A dispenser that dispenses bottles."
	icon_state = "pill_press" //TODO SPRITE IT !!!!!!
	var/bottle_name = "factory bottle"
	var/bottle_size = 30
	///the icon_state number for the bottle.
	var/list/stored_bottles = list()
	///max amount of bottles allowed on our tile before we start storing them instead
	var/max_floor_bottles = 10

	ui_x = 300
	ui_y = 120

/obj/machinery/plumbing/bottle_dispenser/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The [name] currently has [stored_bottles.len] stored. There needs to be less than [max_floor_bottles] on the floor to continue dispensing.</span>"

/obj/machinery/plumbing/bottle_dispenser/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)

/obj/machinery/plumbing/bottle_dispenser/process()
	if(stat & NOPOWER)
		return
	if(reagents.total_volume >= bottle_size)
		var/obj/item/reagent_containers/glass/bottle/P
		P = new/obj/item/reagent_containers/glass/bottle(drop_location())
		reagents.trans_to(P, bottle_size)
		P.name = bottle_name
		stored_bottles += P
	if(stored_bottles.len)
		var/bottle_amount = 0
		for(var/obj/item/reagent_containers/glass/bottle/P in loc)
			bottle_amount++
			if(bottle_amount >= max_floor_bottles) //too much so just stop
				break
		if(bottle_amount < max_floor_bottles)
			var/atom/movable/AM = stored_bottles[1] //AM because forceMove is all we need
			stored_bottles -= AM
			AM.forceMove(drop_location())

/obj/machinery/plumbing/bottle_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BottleDispenser", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/plumbing/bottle_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["bottle_size"] = bottle_size
	data["bottle_name"] = bottle_name
	return data

/obj/machinery/plumbing/bottle_dispenser/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("change_bottle_size")
			bottle_size = CLAMP(text2num(params["volume"]), 0, 30)
		if("change_bottle_name")
			var/new_name = stripped_input(usr, "Enter a bottle name.", name, bottle_name)
			bottle_name = new_name + " bottle"
