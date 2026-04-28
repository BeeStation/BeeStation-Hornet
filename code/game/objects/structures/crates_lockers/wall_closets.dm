/obj/structure/wall_closet
	name = "wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	anchored = TRUE
	icon = 'icons/obj/storage/wall_closet.dmi'
	icon_state = "generic"
	var/theme_color = "#5f5f5f"
	var/list/closet_contents
	var/user_count = 0

/obj/structure/wall_closet/Initialize(mapload)
	. = ..()
	initalize_closet_storage()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/obj/structure/wall_closet/LateInitialize()
	pickup_items()

/obj/structure/wall_closet/proc/initalize_closet_storage()
	closet_contents = list()
	for(var/I in 1 to 20)
		var/list/item_entry = list()
		closet_contents += list(item_entry)

/obj/structure/wall_closet/proc/pickup_items()
	var/atom/L = drop_location()
	for(var/obj/item/I in L)
		if(!closet_insert_item(I, update_icons = FALSE))
			break

/obj/structure/wall_closet/proc/closet_insert_item(obj/item/inserted_item, ui_index, update_icons = TRUE)
	if(contents.len >= 20)
		return FALSE
	if(!ui_index)
		for(var/index in 1 to closet_contents.len)
			var/list/L = list()
			L = closet_contents[index]
			if(L.len <= 0)
				ui_index = index
				break
	closet_contents[ui_index]["item"] = inserted_item
	inserted_item.forceMove(src)
	if(update_icons)
		update_contents_icons()
	return TRUE

/obj/structure/wall_closet/proc/update_contents_icons()
	for(var/list/list_item in closet_contents)
		if(!list_item.len <= 0)
			var/obj/item/current_item = list_item["item"]
			for(var/image in current_item.overlays)
				var/image/current_overlay = image
				if(current_overlay.plane != LIGHTING_PLANE && current_overlay.plane != EMISSIVE_PLANE || current_item.greyscale_colors || current_item.greyscale_config || current_item.color) //i HATE this "list of shit that breaks" but i have no idea how to solve this any other way
					list_item["image"] = FAST_REF(current_item.appearance)
					usr << output(current_item, "push_appearance_placeholder_id")
					break
			if(!list_item["image"])
				list_item["icon"] = current_item.icon
				list_item["icon_state"] = current_item.icon_state
			list_item["name"] = current_item.name
			list_item["show"] = TRUE

/obj/structure/wall_closet/proc/closet_remove_item(ui_index)
	var/obj/item/removed_item = closet_contents[ui_index]["item"]
	usr.put_in_hands(removed_item)
	var/list/L = list()
	L = closet_contents[ui_index]
	L.Cut()

/obj/structure/wall_closet/ui_close(mob/user)
	if(!isliving(user))
		return
	--user_count
	if(!user_count)
		playsound(src, 'sound/machines/closet_close.ogg', 30, 1, -3)
		layer = initial(layer)
		icon_state = initial(icon_state)


/obj/structure/wall_closet/attackby(obj/item/I, mob/living/user)
	if(!user.combat_mode)
		if(closet_insert_item(I))
			to_chat(user, span_notice("you stash \the [I.name] into \the [src.name]"))
			playsound(src, 'sound/machines/closet_close.ogg', 30, 1, -3)
		ui_update()
		return
	return ..()

/obj/structure/wall_closet/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(contents.len)
		user.balloon_alert_to_viewers("The [src.name] still has items inside!")
		return TRUE
	tool.play_tool_sound(src, 75)
	if(!do_after(user, 5 SECONDS, target = src))
		return TRUE
	playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
	to_chat(user, span_notice("you take apart the [src.name]"))
	qdel(src)
	return TRUE

/obj/structure/wall_closet/ui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	update_contents_icons()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WallCloset")
		ui.set_autoupdate(FALSE)
		ui.open()
		if(!isliving(user))
			return
		if(!user_count)
			playsound(src, 'sound/machines/closet_open.ogg', 30, 1, -3)
			layer = LOW_ITEM_LAYER
			icon_state = "[initial(icon_state)]_open"
		++user_count


/obj/structure/wall_closet/attack_robot(mob/user)
	if(!Adjacent(user))
		return
	ui_interact(user)
	return

/obj/structure/wall_closet/ui_data(mob/user)
	var/list/data = list()
	data["color"] = theme_color
	data["contents"] = closet_contents
	return data

/obj/structure/wall_closet/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(istype(usr, /mob/living/silicon))
		return
	switch(action)
		if("ItemClick")
			var/ui_index = params["SlotKey"]
			if(closet_contents[ui_index]["item"])
				closet_remove_item(ui_index)
				return TRUE

			if(usr.get_active_held_item())
				var/obj/item/I = usr.get_active_held_item()
				closet_insert_item(I, ui_index)

			return TRUE

/obj/structure/wall_closet/ui_status(mob/user)
	if(!in_range(user,src))
		return UI_CLOSE
	return ..()

/obj/structure/wall_closet/Destroy()
	dump_contents()
	closet_contents = null
	return ..()

/obj/structure/wall_closet/dump_contents()
	var/atom/L = drop_location()
	new /obj/item/stack/sheet/iron (L, 2)
	for(var/obj/item/I in src)
		I.forceMove(L)

//closet variants

/obj/structure/wall_closet/generic

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/generic, 34)

/obj/structure/wall_closet/freezer
	name = "wall freezer"
	desc = "It's a freezer, but on a wall."
	icon_state = "freezer"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/freezer, 34)

/obj/structure/wall_closet/med
	name = "medical wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "med"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/med, 34)

/obj/structure/wall_closet/chemistry
	name = "chemistry wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "chemistry"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/chemistry, 34)

/obj/structure/wall_closet/sec
	name = "security wall closet"
	desc = "It's a just, wall mounted, storage unit."
	icon_state = "sec"
	theme_color = "#8b3737"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/sec, 34)

/obj/structure/wall_closet/brig_phys
	name = "brig physycian's wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "brig_phys"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/brig_phys, 34)

/obj/structure/wall_closet/engi
	name = "engineering wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "engi"
	theme_color = "#c4a623"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/engi, 34)

/obj/structure/wall_closet/tool
	name = "tool wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "tool"
	theme_color = "#c4a623"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/tool, 34)

/obj/structure/wall_closet/emergency
	name = "emergency wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "emergency"
	theme_color = "#639ec5"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/emergency, 34)

/obj/structure/wall_closet/fire
	name = "fire-safety wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "fire"
	theme_color = "#971717"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/fire, 34)

/obj/structure/wall_closet/science
	name = "science wall closet"
	desc = "It's a scientific, wall mounted, storage unit."
	icon_state = "science"
	theme_color = "#e7e7e7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/science, 34)

/obj/structure/wall_closet/hydro
	name = "hydroponics wall closet"
	desc = "It's a basic, wall mounted, storage unit."
	icon_state = "hydro"
	theme_color = "#457a37"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/hydro, 34)

/obj/structure/wall_closet/syndicate
	name = "syndicate wall closet"
	desc = "It's a nefarious, wall mounted, storage unit."
	icon_state = "syndicate"
	theme_color = "#915252"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/syndicate, 34)

/obj/structure/wall_closet/command
	name = "command wall closet"
	desc = "It's a high quality, wall mounted, storage unit."
	icon_state = "command"
	theme_color = "#345171"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_closet/command, 34)

/obj/item/wallframe/wall_closet
	name = "wall closet frame"
	desc = "A closet, on a wall!"
	icon = 'icons/obj/storage/wall_closet.dmi'
	icon_state = "generic"
	result_path = /obj/structure/wall_closet
	pixel_shift = 34

/obj/item/wallframe/wall_closet/emergency
	name = "emergency wall closet frame"
	icon_state = "emergency"
	result_path = /obj/structure/wall_closet/emergency

/obj/item/wallframe/wall_closet/fire
	name = "fire-safety wall closet frame"
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

