/obj/item/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	icon_state = "wallet"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_ID

	var/obj/item/card/id/front_id = null
	var/obj/item/card/id/cached_front_id = null
	var/list/combined_access
	var/cached_flat_icon

/obj/item/storage/wallet/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 4
	STR.cant_hold = typecacheof(list(/obj/item/screwdriver/power)) //Must be specifically called out since normal screwdrivers can fit but not the wrench form of the drill
	STR.can_hold = typecacheof(list(
		/obj/item/stack/spacecash,
		/obj/item/holochip,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/dice,
		/obj/item/disk,
		/obj/item/implanter,
		/obj/item/lighter,
		/obj/item/lipstick,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/screwdriver,
		/obj/item/stamp))

/obj/item/storage/wallet/Exited(atom/movable/AM)
	. = ..()
	refreshID()

/obj/item/storage/wallet/proc/refreshID()
	LAZYCLEARLIST(combined_access)
	if(!(front_id in src))
		front_id = null
	for(var/obj/item/card/id/I in contents)
		if(!front_id)
			front_id = I
		LAZYINITLIST(combined_access)
		combined_access |= I.access
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_id == src)
			H.sec_hud_set_ID()
	update_icon()

/obj/item/storage/wallet/Entered(atom/movable/AM)
	. = ..()
	refreshID()

/obj/item/storage/wallet/update_icon(list/override_overlays)
	if(!override_overlays && front_id == cached_front_id) //Icon didn't actually change
		return
	cut_overlays()
	cached_flat_icon = null
	cached_front_id = front_id
	if(front_id)
		var/list/add_overlays = list()
		add_overlays += mutable_appearance(front_id.icon, front_id.icon_state)
		if(override_overlays)
			add_overlays += override_overlays
		else
			add_overlays += front_id.overlays
		add_overlays += mutable_appearance(icon, "wallet_overlay")
		add_overlay(add_overlays)

/obj/item/storage/wallet/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
	return cached_flat_icon

/obj/item/storage/wallet/get_examine_string(mob/user, thats = FALSE)
	if(front_id)
		return "[icon2html(get_cached_flat_icon(), user)] [thats? "That's ":""][get_examine_name(user)]" //displays all overlays in chat
	return ..()

/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/GetAccess()
	if(LAZYLEN(combined_access))
		return combined_access
	else
		return ..()

/obj/item/storage/wallet/random
	icon_state = "random_wallet"

/obj/item/storage/wallet/random/PopulateContents()
	new /obj/item/holochip(src, rand(5,30))
	update_icon()
