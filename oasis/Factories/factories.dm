/obj/machinery/factories
	name = "factory prototype"
	desc = "you arent meant to see this"
	icon = 'icons/obj/mining.dmi'
	icon_state = "silo"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/factories

/obj/machinery/factories/material_dispenser
		name = "material_dispenser"
		desc = "this machine can dispense material from a linked silo"
		circuit = /obj/item/circuitboard/machine/factories/material_dispenser
		var/datum/component/remote_materials/materials
		var/mat_type
		var/on = FALSE
		var/target_Ammount = 1
		var/list/allowed_mats = list(/datum/material/iron, /datum/material/glass, /datum/material/copper, /datum/material/silver, /datum/material/gold, /datum/material/diamond, /datum/material/plasma, /datum/material/uranium, /datum/material/bananium, /datum/material/titanium, /datum/material/bluespace, /datum/material/plastic)

/obj/machinery/factories/material_dispenser/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "dispenser", mapload)
	RefreshParts()

/obj/machinery/factories/material_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!ui)
		ui = new(user, src, ui_key, "MaterialDispenser", name, 300, 300, master_ui, state)
		ui.open()

/obj/machinery/factories/material_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["allowed_mats"] = allowed_mats
	data["targetAmmount"] = target_Ammount
	return data

/obj/machinery/factories/material_dispenser/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("ammount")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_Ammount = clamp(target, 1, 10)
		if("mat_type")
			var/type = params["type"]
			mat_type = type
		if("on")
			on = TRUE
		if("off")
			on = FALSE

/obj/machinery/factories/material_dispenser/process()
	var/datum/component/material_container/mat_container = materials.mat_container
	if(on)
		if (!mat_container)
			say("No access to material storage, please contact the quartermaster.")
			return 0
		if (materials.on_hold())
			say("Mineral access is on hold, please contact the quartermaster.")
			return 0
		var/datum/material/M = text2path(mat_type)
		mat_container.retrieve_sheets(target_Ammount,getmaterialref(M))

/*/obj/machinery/factories/material_dispenser/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

obj/machinery/factories/material_dispenser/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	setDir(turn(dir,45))
*/