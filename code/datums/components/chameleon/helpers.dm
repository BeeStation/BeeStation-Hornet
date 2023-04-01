/proc/list_chameleon_disguises(base_disguise_path, disguise_blacklist = list())
	. = list()
	for(var/path in typesof(base_disguise_path))
		if(!path || !ispath(path, /obj/item) || is_type_in_typecache(path, disguise_blacklist))
			continue
		var/obj/item/base_disguise = path
		if((initial(base_disguise.item_flags) & ABSTRACT) || !initial(base_disguise.icon_state))
			continue
		. += path

/proc/generate_human_outfit_icon(outfit_path)
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_OUTFIT)
	for(var/I in mannequin.get_equipped_items(TRUE))
		qdel(I)
	mannequin.set_species(/datum/species/human, TRUE)
	mannequin.setDir(SOUTH)
	mannequin.equipOutfit(outfit_path, TRUE)
	COMPILE_OVERLAYS(mannequin)
	var/icon/asset = getFlatIcon(mannequin, no_anim = TRUE)
	asset.Scale(asset.Width() * 2, asset.Height() * 2)
	. = asset
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_OUTFIT)

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
