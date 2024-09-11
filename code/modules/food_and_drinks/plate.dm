/obj/item/plate
	name = "plate"
	desc = "Holds food. Powerful. Good for morale when you're not eating your spaghetti off of a desk."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "plate"
	w_class = WEIGHT_CLASS_BULKY //No backpack.
	///How many things fit on this plate?
	var/max_items = 8
	///The offset from side to side the food items can have on the plate
	var/max_x_offset = 4
	///The max height offset the food can reach on the plate
	var/max_height_offset = 5
	///Offset of where the click is calculated from, due to how food is positioned in their DMIs.
	var/placement_offset = -15
	/// If the plate will shatter when thrown
	var/fragile = TRUE

/obj/item/plate/Initialize(mapload)
	. = ..()

	if(fragile)
		AddElement(/datum/element/shatters_when_thrown)

/obj/item/plate/attackby(obj/item/I, mob/user, params)
	if(!IS_EDIBLE(I))
		to_chat(user, "<span class='notice'>[src] is made for food, and food alone!</span>")
		return
	if(contents.len >= max_items)
		to_chat(user, "<span class='notice'>[src] can't fit more items!</span>")
		return
	var/list/modifiers = params2list(params)
	//Center the icon where the user clicked.
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return
	if(user.transferItemToLoc(I, src, silent = FALSE))
		I.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -max_x_offset, max_x_offset)
		I.pixel_y = min(text2num(LAZYACCESS(modifiers, ICON_Y)) + placement_offset, max_height_offset)
		to_chat(user, "<span class='notice'>You place [I] on [src].</span>")
		AddToPlate(I, user)
		update_appearance()
	else
		return ..()

/obj/item/plate/pre_attack(atom/A, mob/living/user, params)
	if(!iscarbon(A))
		return
	if(!contents.len)
		return
	var/obj/item/object_to_eat = contents[1]
	A.attackby(object_to_eat, user)
	return TRUE //No normal attack

///This proc adds the food to viscontents and makes sure it can deregister if this changes.
/obj/item/plate/proc/AddToPlate(obj/item/item_to_plate, mob/user)
	vis_contents += item_to_plate
	item_to_plate.flags_1 |= IS_ONTOP_1
	RegisterSignal(item_to_plate, COMSIG_MOVABLE_MOVED, PROC_REF(ItemMoved))
	RegisterSignal(item_to_plate, COMSIG_PARENT_QDELETING, PROC_REF(ItemMoved))
	///ovens update
	//update_appearance()

///This proc cleans up any signals on the item when it is removed from a plate, and ensures it has the correct state again.
/obj/item/plate/proc/ItemRemovedFromPlate(obj/item/removed_item)
	removed_item.flags_1 &= ~IS_ONTOP_1
	vis_contents -= removed_item
	UnregisterSignal(removed_item, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))

///This proc is called by signals that remove the food from the plate.
/obj/item/plate/proc/ItemMoved(obj/item/moved_item, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	ItemRemovedFromPlate(moved_item)

/obj/item/plate/large
	name = "buffet plate"
	desc = "A large plate made for the professional catering industry but also apppreciated by mukbangers and other persons of considerable size and heft."
	icon_state = "plate_large"
	max_items = 12
	max_x_offset = 8
	max_height_offset = 12

/obj/item/plate/small
	name = "appetizer plate"
	desc = "A small plate, perfect for appetizers, desserts or trendy modern cusine."
	icon_state = "plate_small"
	max_items = 4
	max_x_offset = 4
	max_height_offset = 5

/obj/item/plate_shard
	name = "ceramic shard"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "plate_shard1"
	base_icon_state = "plate_shard"
	force = 5
	throwforce = 5
	sharpness = IS_SHARP
	/// How many variants of shard there are
	var/variants = 5

/obj/item/plate_shard/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/caltrop, min_damage = force)

	icon_state = "[base_icon_state][pick(1,variants)]"
