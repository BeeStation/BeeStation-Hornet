/proc/ui_grod_hand_position(i) //values based on old hand ui positions (CENTER:-/+16,SOUTH:5)
	var/x_off = -(!(i % 2))
	var/y_off = round((i-1) / 2)
	return"CENTER+[x_off]:16,SOUTH+[y_off+1]:13"

/datum/hud/human/grod/New(mob/living/carbon/human/owner)
	..()

	//left
	grodpocket = new /atom/movable/screen/grod/pocket
	grodpocket.icon = ui_style
	grodpocket.icon_state = "pocket"
	grodpocket.hud = src
	infodisplay += grodpocket

	//right
	grodpocket = new /atom/movable/screen/grod/pocket/right
	grodpocket.icon = ui_style
	grodpocket.icon_state = "pocket"
	grodpocket.hud = src
	infodisplay += grodpocket

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_icon()

/atom/movable/screen/grod
	//invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/grod/pocket
	name = "pocket"
	///Ref component
	var/datum/component/grod_pockets/pocket
	///Index for hand
	var/index = 1
	///Overlay for item
	var/mutable_appearance/item_overlay

/atom/movable/screen/grod/pocket/right
	index = 2

/atom/movable/screen/grod/pocket/Initialize(mapload)
	. = ..()
	screen_loc = ui_grod_hand_position(index)
	if(isliving(usr))
		var/mob/living/carbon/U = usr
		pocket = U.GetComponent(/datum/component/grod_pockets)

/atom/movable/screen/grod/pocket/Click()
	if(isliving(usr))
		var/mob/living/carbon/U = usr
		var/obj/item/I = U.get_active_held_item()
		cut_overlay(item_overlay)
		if(pocket.handle_storage(index, I))
			item_overlay = mutable_appearance(I.icon, I.icon_state)
			add_overlay(item_overlay)

//Specialized component for hud
/datum/component/grod_pockets
	///Item slots for left & right
	var/list/item_slots = list(null, null)

/datum/component/grod_pockets/Initialize(...)
	. = ..()
	if(isliving(parent))
		var/mob/living/carbon/U = parent
		U.hud_type = /datum/hud/human/grod
		U.create_mob_hud()

/datum/component/grod_pockets/proc/handle_storage(slot, obj/item/I)
	var/mob/living/M = parent
	if(!istype(M))
		return
	//Store item
	if(istype(I) && I.w_class <= WEIGHT_CLASS_NORMAL)
		if(item_slots[slot])
			to_chat(M, "<span class='warning'>This hand is full!</span>")
			return item_slots[slot]
		item_slots[slot] = I
		I.forceMove(M)
		M.update_inv_hands()
		return I
	//Retrieve item
	else if(isnull(I) && item_slots[slot])
		var/obj/item/T = item_slots[slot]
		item_slots[slot] = null
		M.equip_to_slot(T, ITEM_SLOT_HANDS)
		return null
