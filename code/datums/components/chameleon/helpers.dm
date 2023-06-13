/proc/atom_icon_hash(atom/atom)
	var/list/parts = list()
	if(initial(atom.icon))
		parts += "[initial(atom.icon)]"
	if(initial(atom.icon_state))
		parts += "[initial(atom.icon_state)]"
	if(initial(atom.greyscale_colors))
		parts += "[initial(atom.greyscale_colors)]"
	return rustg_hash_string(RUSTG_HASH_XXH64, parts.Join("~"))

/proc/list_chameleon_disguises(base_disguise_path, disguise_whitelist, disguise_blacklist = list(), hide_duplicates = TRUE)
	. = list()
	var/list/used_hashes = list()
	// To prevent issues with our duplicate detection, first we're gonna loop through all the job outfits and add their thingies first.
	if(hide_duplicates)
		for(var/outfit_path in subtypesof(/datum/outfit/job))
			var/datum/outfit/job/job_outfit = outfit_path
			if(!initial(job_outfit.can_be_admin_equipped))
				continue
			var/datum/outfit/job/outfit = new outfit_path
			for(var/clothing_path in outfit.get_chameleon_disguise_info())
				if(!clothing_path || (clothing_path in .) || !ispath(clothing_path, base_disguise_path) || is_type_in_typecache(clothing_path, disguise_blacklist))
					continue
				if((base_disguise_path && !ispath(clothing_path, base_disguise_path)) || (disguise_whitelist && !is_type_in_typecache(clothing_path, clothing_path)))
					continue
				var/obj/item/base_disguise = clothing_path
				if((initial(base_disguise.item_flags) & ABSTRACT) || !initial(base_disguise.icon_state))
					continue
				var/icon_hash = atom_icon_hash(clothing_path)
				if(icon_hash in used_hashes)
					continue
				used_hashes += icon_hash
				. += clothing_path
			qdel(outfit)
	for(var/path in disguise_whitelist ? assoc_list_strip_value(disguise_whitelist) : typesof(base_disguise_path))
		if(!path || (path in .) || !ispath(path, /obj/item) || is_type_in_typecache(path, disguise_blacklist))
			continue
		var/obj/item/base_disguise = path
		if((initial(base_disguise.item_flags) & ABSTRACT) || !initial(base_disguise.icon_state))
			continue
		if(hide_duplicates)
			var/icon_hash = atom_icon_hash(path)
			if(icon_hash in used_hashes)
				continue
			used_hashes += icon_hash
		. += path

/proc/generate_chameleon_preset_icon(preset)
	if(!islist(preset) || !LAZYLEN(preset))
		return
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_OUTFIT)
	for(var/I in mannequin.get_equipped_items(TRUE))
		qdel(I)
	mannequin.set_species(/datum/species/human, TRUE)
	mannequin.setDir(SOUTH)
	for(var/slot in preset)
		var/item = preset[slot]
		if(!ispath(item) || !ispath(item, /obj/item))
			continue
		mannequin.equip_to_slot_or_del(new item, text2num(slot))
	COMPILE_OVERLAYS(mannequin)
	var/icon/asset = getFlatIcon(mannequin, no_anim = TRUE)
	asset.Scale(asset.Width() * 2, asset.Height() * 2)
	. = asset
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_OUTFIT)
