/obj/item/bluespace_anchor
	name = "bluespace anchor"
	desc = "A portable device that, once deployed, will stablise the volatile bluespace instabilities around it, preventing teleportation. Consumes a large amount of power."

	icon = 'icons/obj/bluespace_anchor.dmi'
	icon_state = "anchor_undeployed"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT

	var/obj/item/stock_parts/cell/power_cell

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/bluespace_anchor)

/obj/item/bluespace_anchor/Initialize(mapload, obj/item/stock_parts/cell/cell)
	. = ..()
	set_cell(cell)

/obj/item/bluespace_anchor/Destroy()
	//Delete the power cell
	if(power_cell)
		QDEL_NULL(power_cell)
	. = ..()

/obj/item/bluespace_anchor/proc/set_cell(cell)
	if(power_cell)
		power_cell.forceMove(get_turf(src))
		UnregisterSignal(power_cell, COMSIG_QDELETING)
	power_cell = cell
	if(power_cell)
		power_cell.forceMove(src)

/obj/item/bluespace_anchor/screwdriver_act(mob/living/user, obj/item/I)
	if(!power_cell)
		to_chat(user, span_notice("There is no cell inside [src]."))
		return
	to_chat(user, span_notice("You remove the cell inside [src]."))
	set_cell(null)

/obj/item/bluespace_anchor/attack_self(mob/user)
	user.visible_message(span_notice("[user] begins deploying [src]."), span_notice("You begin deploying [src]..."))
	if(!do_after(user, 4 SECONDS, target = src))
		return
	var/stored_cell = power_cell
	set_cell(null)
	new /obj/machinery/bluespace_anchor(get_turf(user), stored_cell)
	qdel(src)

/obj/item/bluespace_anchor/attackby(obj/item/I, mob/living/user, params)
	var/obj/item/stock_parts/cell/cell = I
	if(!istype(cell))
		return ..()
	if(power_cell)
		to_chat(user, span_notice("Remove the power cell inside [src] first!"))
		return
	set_cell(cell)
	to_chat(user, span_notice("You insert [cell] into [src]."))
