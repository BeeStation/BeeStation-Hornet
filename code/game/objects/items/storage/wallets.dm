/obj/item/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	icon_state = "wallet"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_ID
	storage_type = /datum/storage/wallet

	var/obj/item/card/id/front_id = null
	var/list/combined_access
	var/overlay_icon_state = "wallet_overlay"

/obj/item/storage/wallet/Exited(atom/movable/gone, direction)
	. = ..()
	if(isidcard(gone))
		refresh_id()

/obj/item/storage/wallet/proc/refresh_id()
	LAZYCLEARLIST(combined_access)

	front_id = null
	for(var/obj/item/card/id/id_card in contents)
		if(!front_id)
			front_id = id_card

		LAZYINITLIST(combined_access)
		combined_access |= id_card.access

	if(ishuman(loc))
		var/mob/living/carbon/human/wearing_human = loc
		if(wearing_human.wear_id == src)
			wearing_human.sec_hud_set_ID()

	update_label()
	update_appearance(UPDATE_ICON)
	update_slot_icon()

/obj/item/storage/wallet/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isidcard(arrived))
		refresh_id()

/obj/item/storage/wallet/update_overlays()
	. = ..()
	if(!front_id)
		return
	. += mutable_appearance(front_id.icon, front_id.icon_state)
	. += front_id.overlays
	. += mutable_appearance(icon, overlay_icon_state)

/obj/item/storage/wallet/proc/update_label()
	if(front_id)
		name = "[src::name] displaying [front_id]"
	else
		name = src::name

/obj/item/storage/wallet/examine()
	. = ..()
	if(front_id)
		. += span_notice("Alt-click to remove the id.")

/obj/item/storage/wallet/get_id_examine_strings(mob/user)
	. = ..()
	if(front_id)
		. += front_id.get_id_examine_strings(user)

/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/RemoveID()
	if(!front_id)
		return
	. = front_id
	front_id.forceMove(get_turf(src))

/obj/item/storage/wallet/InsertID(obj/item/inserting_item)
	var/obj/item/card/inserting_id = inserting_item.RemoveID()
	if(!inserting_id)
		return FALSE
	attackby(inserting_id)
	if(inserting_id in contents)
		return TRUE
	return FALSE

/obj/item/storage/wallet/GetAccess()
	if(LAZYLEN(combined_access))
		return combined_access
	else
		return ..()

/obj/item/storage/wallet/random
	icon_state = "random_wallet"
	worn_icon_state = "wallet"

/obj/item/storage/wallet/random/Initialize(mapload)
	. = ..()
	icon_state = "wallet"

/obj/item/storage/wallet/random/PopulateContents()
	new /obj/item/holochip(src, rand(5,30))
	new /obj/effect/spawner/random/entertainment/wallet_storage(src)
