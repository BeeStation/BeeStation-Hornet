/proc/atom_icon_hash(atom/atom)
	var/list/parts = list()
	if(initial(atom.icon))
		parts += "[initial(atom.icon)]"
	if(initial(atom.icon_state))
		parts += "[initial(atom.icon_state)]"
	if(initial(atom.greyscale_colors))
		parts += "[initial(atom.greyscale_colors)]"
	return md5(parts.Join("~"))

/proc/list_chameleon_disguises(base_disguise_path, disguise_blacklist = list(), hide_duplicates = TRUE)
	. = list()
	var/list/used_hashes = list()
	for(var/path in typesof(base_disguise_path))
		if(!path || !ispath(path, /obj/item) || is_type_in_typecache(path, disguise_blacklist))
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
