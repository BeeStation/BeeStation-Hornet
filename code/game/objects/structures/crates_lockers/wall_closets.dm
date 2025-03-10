/obj/structure/wall_closet
	name = "wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon = 'icons/obj/storage/wall_closet.dmi'
	icon_state = "generic"
	var/theme_color = "#5f5f5f"
	var/storage_capacity = 20
	var/list/closet_contents

/obj/structure/wall_closet/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/wall_closet/LateInitialize()
	. = ..()
	take_contents()
	compose_closet_contents()

/obj/structure/wall_closet/proc/insert(obj/item/AM)
	if(contents.len >= storage_capacity)
		return -1
	AM.forceMove(src)
	return TRUE

/obj/structure/wall_closet/proc/take_contents()
	var/atom/L = drop_location()
	for(var/obj/item/AM in L)
		if(AM != src && insert(AM) == -1) // limit reached
			break

/obj/structure/wall_closet/ui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WallCloset")
		ui.open()

/obj/structure/wall_closet/ui_data(mob/user)
	var/list/data = list()
	data["color"] = theme_color
	data["contents"] = closet_contents
	return data

/obj/structure/wall_closet/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("takeOut")
			message_admins("param[params["item"]]")
			var/index = text2num(params["item"]) + 1
			message_admins("index[index]")
			var/obj/item/I = contents[index]
			usr.put_in_hands(I)
			message_admins("user[usr]")
			compose_closet_contents()
			return TRUE

/obj/structure/wall_closet/proc/compose_closet_contents()
	closet_contents = list()
	var/obj/item/I
	for(I in contents)
		var/list/item_entry = list()
		item_entry["name"] = I.name
		message_admins("composing[I.name]")
		item_entry["icon"] = I.icon
		item_entry["icon_state"] = I.icon_state
		closet_contents += list(item_entry)

/obj/structure/wall_closet/attacked_by(obj/item/I, mob/living/user)
	if(istype(I, /obj/item) && !user.combat_mode)
		I.forceMove(src)
		compose_closet_contents()
		ui_update()
		return
	. = ..()


//closet variants

/obj/structure/wall_closet/generic

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/generic, 30)

/obj/structure/wall_closet/freezer
	name = "wall freezer"
	desc = "It's a freezer, but on a wall."
	icon_state = "freezer"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/freezer, 30)

/obj/structure/wall_closet/med
	name = "medical wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "med"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/med, 30)

/obj/structure/wall_closet/chemistry
	name = "chemistry wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "chemistry"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/chemistry, 30)

/obj/structure/wall_closet/sec
	name = "security wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "sec"
	theme_color = "#8b3737"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/sec, 30)

/obj/structure/wall_closet/brig_phys
	name = "brig physycian's wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "brig_phys"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/brig_phys, 30)

/obj/structure/wall_closet/engi
	name = "engineering wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "engi"
	theme_color = "#c4a623"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/engi, 30)

/obj/structure/wall_closet/tool
	name = "tool wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "tool"
	theme_color = "#c4a623"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/tool, 30)

/obj/structure/wall_closet/emergency
	name = "emergency wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "emergency"
	theme_color = "#639ec5"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/emergency, 30)

/obj/structure/wall_closet/fire
	name = "fire wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "fire"
	theme_color = "#971717"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/fire, 30)

/obj/structure/wall_closet/science
	name = "science wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "science"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/science, 30)

/obj/structure/wall_closet/hydro
	name = "hydroponics wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "hydro"
	theme_color = "#457a37"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/hydro, 30)

/obj/structure/wall_closet/syndicate
	name = "syndicate wall closet"
	desc = "It's a nefarious, wall mounted, storage unit."
	icon_state = "syndicate"
	theme_color = "#915252"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/syndicate, 30)
