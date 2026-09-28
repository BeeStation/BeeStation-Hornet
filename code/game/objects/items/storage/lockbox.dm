/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "lockbox+l"
	base_icon_state = "lockbox"
	inhand_icon_state = "lockbox+l"
	lefthand_file = 'icons/mob/inhands/equipment/case_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/case_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	req_access = list(ACCESS_ARMORY)
	storage_type = /datum/storage/lockbox

/obj/item/storage/lockbox/examine()
	. = ..()
	if(obj_flags & EMAGGED)
		. += span_warning("It appears to be broken.")

/obj/item/storage/lockbox/update_icon_state()
	. = ..()
	var/suffix = ""
	if(obj_flags & EMAGGED)
		suffix = "+b"
	else if(atom_storage.locked)
		suffix = "+l"

	icon_state = "[base_icon_state][suffix]"
	inhand_icon_state = "[base_icon_state][suffix]"

/obj/item/storage/lockbox/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/card/card = tool.GetID()
	if(isnull(card))
		return ..()

	if(can_unlock(user, card))
		toggle_locked(user)
		return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/item/storage/lockbox/proc/can_unlock(mob/living/user, obj/item/card/id/id_card, silent = FALSE)
	if(obj_flags & EMAGGED)
		if(!silent)
			balloon_alert(user, "it's broken!")
		return FALSE
	if(!check_access(id_card))
		if(!silent)
			balloon_alert(user, "access denied!")
		return FALSE
	return TRUE

/obj/item/storage/lockbox/proc/toggle_locked(mob/living/user)
	atom_storage.locked = !atom_storage.locked
	update_appearance(UPDATE_ICON_STATE)
	balloon_alert(user, atom_storage.locked ? "locked" : "unlocked")

/obj/item/storage/lockbox/on_emag(mob/user)
	..()
	atom_storage.locked = FALSE
	update_appearance(UPDATE_ICON_STATE)
	user?.visible_message(span_warning("[user] breaks [src] with an electromagnetic card!"))

/obj/item/storage/lockbox/loyalty
	name = "lockbox of mindshield implants"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/loyalty/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/implantcase/mindshield(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	icon_state = "medalbox+l"
	inhand_icon_state = "medalbox+l"
	base_icon_state = "medalbox"
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_CAPTAIN)
	storage_type = /datum/storage/lockbox/medal
	var/open = FALSE

/obj/item/storage/lockbox/medal/add_context_self(datum/screentip_context/context, mob/user)
	if(!atom_storage.locked)
		context.add_alt_click_action(open ? "Close" : "Open")

/obj/item/storage/lockbox/medal/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE) || atom_storage.locked)
		return
	open = !open
	update_appearance(UPDATE_ICON)

/obj/item/storage/lockbox/medal/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	open = TRUE
	update_appearance(UPDATE_ICON)

/obj/item/storage/lockbox/medal/Exited(atom/movable/gone, direction)
	. = ..()
	open = TRUE
	if(!QDELING(src))
		update_appearance(UPDATE_ICON)

/obj/item/storage/lockbox/medal/PopulateContents()
	new /obj/item/clothing/accessory/medal/gold/captain(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/silver/security(src)
	new /obj/item/clothing/accessory/medal/bronze_heart(src)
	new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)
	new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/conduct(src)

/obj/item/storage/lockbox/medal/update_icon_state()
	. = ..()
	if(atom_storage.locked)
		icon_state = "[base_icon_state]+l"
		inhand_icon_state = "[base_icon_state]+l"
		return

	icon_state = base_icon_state
	inhand_icon_state = base_icon_state
	if(open)
		icon_state += "open"
	if(obj_flags & EMAGGED)
		icon_state += "+b"
		inhand_icon_state += "+b"

/obj/item/storage/lockbox/medal/update_overlays()
	. = ..()
	if(!length(contents) || !open || atom_storage.locked)
		return
	for (var/i in 1 to length(contents))
		var/obj/item/clothing/accessory/medal/M = contents[i]
		var/mutable_appearance/medalicon = mutable_appearance(initial(icon), M.medaltype)
		if(i > 1 && i <= 5)
			medalicon.pixel_x += ((i-1)*4)
		else if(i > 5)
			medalicon.pixel_y -= 7
			medalicon.pixel_x += ((i-6)*4)
		. += medalicon

/obj/item/storage/lockbox/medal/sec
	name = "security medal box"
	desc = "A locked box used to store medals to be given to members of the security department."
	req_access = list(ACCESS_HOS)

/obj/item/storage/lockbox/medal/sec/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/silver/security(src)

/obj/item/storage/lockbox/medal/cargo
	name = "cargo award box"
	desc = "A locked box used to store awards to be given to members of the cargo department."
	req_access = list(ACCESS_QM)

/obj/item/storage/lockbox/medal/cargo/PopulateContents()
	new /obj/item/clothing/accessory/medal/ribbon/cargo(src)

/obj/item/storage/lockbox/medal/service
	name = "service award box"
	desc = "A locked box used to store awards to be given to members of the service department."
	req_access = list(ACCESS_HOP)

/obj/item/storage/lockbox/medal/service/PopulateContents()
	new /obj/item/clothing/accessory/medal/silver/excellence(src)

/obj/item/storage/lockbox/medal/sci
	name = "science medal box"
	desc = "A locked box used to store medals to be given to members of the science department."
	req_access = list(ACCESS_RD)

/obj/item/storage/lockbox/medal/sci/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)

/obj/item/storage/lockbox/medal/med
	name = "medical medal box"
	desc = "A locked box used to store medals to be given to members of the medical department."
	req_access = list(ACCESS_CMO)

/obj/item/storage/lockbox/medal/med/PopulateContents()
	new /obj/item/clothing/accessory/medal/med_medal(src)
	new /obj/item/clothing/accessory/medal/med_medal2(src)
