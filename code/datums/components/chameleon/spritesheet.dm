/datum/asset/spritesheet/chameleon
	name = "chameleon"

/datum/asset/spritesheet/chameleon/create_spritesheets()
	var/list/disguises = list()
	// First, get everything we need to make icons of.
	for(var/chameleon_path in subtypesof(/datum/component/chameleon))
		var/datum/component/chameleon/chameleon = chameleon_path
		if(!initial(chameleon.base_disguise_path))
			continue
		disguises |= list_chameleon_disguises(initial(chameleon.base_disguise_path), initial(chameleon.disguise_whitelist), initial(chameleon.disguise_blacklist), initial(chameleon.hide_duplicates))
	// Then, we need to generate the actual icons.
	for(var/item_path in disguises)
		add_item(item_path)
	// I like this better than hardcoding a list of all chameleon items.
	for(var/item_path in subtypesof(/obj/item))
		var/item_path_txt = "[item_path]"
		if(!findtext(item_path_txt, "/chameleon") || findtext(item_path_txt, "/broken") || (item_path in disguises))
			continue
		add_item(item_path)

/datum/asset/spritesheet/chameleon/proc/add_item(item_path)
	var/icon/asset
	var/icon/icon_file
	var/obj/item/item = item_path
	if(initial(item.greyscale_colors) && initial(item.greyscale_config))
		icon_file = SSgreyscale.GetColoredIconByType(initial(item.greyscale_config), initial(item.greyscale_colors))
	else
		icon_file = initial(item.icon)
	var/icon_state = initial(item.icon_state)
	var/icon_states_list = icon_states(icon_file)
	if(icon_state in icon_states_list)
		asset = icon(icon_file, icon_state, dir=SOUTH, frame=1)
		var/color = initial(item.color)
		if (!isnull(color) && color != "#FFFFFF")
			asset.Blend(color, ICON_MULTIPLY)
	else
		asset = icon('icons/turf/floors.dmi', "", dir=SOUTH, frame=1)
	asset.Scale(asset.Width() * 2, asset.Height() * 2)
	var/item_id = replacetext(replacetext("[item]", "/obj/item/", ""), "/", "-")
	Insert(item_id, asset)
