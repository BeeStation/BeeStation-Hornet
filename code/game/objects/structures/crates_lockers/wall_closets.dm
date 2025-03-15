/obj/structure/wall_closet
	name = "wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	anchored = TRUE
	icon = 'icons/obj/storage/wall_closet.dmi'
	icon_state = "generic"
	var/theme_color = "#5f5f5f"
	var/list/closet_contents

/obj/structure/wall_closet/Initialize(mapload)
	. = ..()
	Initalize_closet_storage()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/wall_closet/LateInitialize()
	Pickup_items()

/obj/structure/wall_closet/proc/Initalize_closet_storage()
	closet_contents = list()
	for(var/i = 1, i <= 20, i++)
		var/list/item_entry = list()
		closet_contents += list(item_entry)

/obj/structure/wall_closet/proc/Pickup_items()
	var/atom/L = drop_location()
	for(var/obj/item/I in L)
		if(!Closet_insert_item(I))
			break

/obj/structure/wall_closet/proc/Closet_insert_item(obj/item/inserted_item, ui_index)
	if(contents.len >= 20)
		return FALSE
	if(!ui_index)
		for(var/index = 1, index <= closet_contents.len, index++)
			var/list/L = list()
			L = closet_contents[index]
			if(L.len <= 0)
				ui_index = index
				break
	inserted_item.forceMove(src)
	closet_contents[ui_index]["item"] = inserted_item
	closet_contents[ui_index]["name"] = inserted_item.name
	closet_contents[ui_index]["icon"] = inserted_item.icon
	closet_contents[ui_index]["icon_state"] = inserted_item.icon_state
	closet_contents[ui_index]["show"] = TRUE
	return TRUE

/obj/structure/wall_closet/proc/Closet_remove_item(ui_index)
	var/obj/item/removed_item = closet_contents[ui_index]["item"]
	usr.put_in_hands(removed_item)
	var/list/L = list()
	L = closet_contents[ui_index]
	L.Cut()

/obj/structure/wall_closet/ui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WallCloset")
		ui.set_autoupdate(FALSE)
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
		if("ItemClick")
			var/ui_index = params["SlotKey"]
			if(closet_contents[ui_index]["item"])
				Closet_remove_item(ui_index)
				return TRUE

			if(usr.get_active_held_item())
				var/obj/item/I = usr.get_active_held_item()
				Closet_insert_item(I, ui_index)

			return TRUE

/obj/structure/wall_closet/attacked_by(obj/item/I, mob/living/user)
	if(istype(I, /obj/item) && !user.combat_mode)
		Closet_insert_item(I)
		ui_update()
		return
	. = ..()

/obj/structure/wall_closet/Destroy()
	dump_contents()
	return ..()

/obj/structure/wall_closet/dump_contents()
	var/atom/L = drop_location()
	new /obj/item/stack/sheet/iron (L, 2)
	for(var/obj/item/I in src)
		I.forceMove(L)

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

/obj/item/wallframe/wall_closet
	name = "wall closet frame"
	desc = "A closet, on a wall!"
	icon = 'icons/obj/storage/wall_closet.dmi'
	icon_state = "generic"
	result_path = /obj/structure/wall_closet
	pixel_shift = 30

/obj/item/wallframe/wall_closet/emergency
	name = "emergency wall closet frame"
	icon_state = "emergency"
	result_path = /obj/structure/wall_closet/emergency

/obj/item/wallframe/wall_closet/fire
	name = "fire wall closet frame"
	icon_state = "fire"
	result_path = /obj/structure/wall_closet/fire

/obj/item/wallframe/wall_closet/tool
	name = "tool wall closet frame"
	icon_state = "tool"
	result_path = /obj/structure/wall_closet/tool

/obj/item/wallframe/wall_closet/freezer
	name = "freezer wall closet frame"
	icon_state = "freezer"
	result_path = /obj/structure/wall_closet/freezer

