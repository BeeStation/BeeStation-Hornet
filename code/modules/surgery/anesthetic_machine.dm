/obj/machinery/anesthetic_machine
	name = "Anesthetic Tank Holder"
	desc = "A wheeled machine that can hold an anesthetic tank and distribute the air using a breath mask."
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "iv_drip"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/item/clothing/mask/breath/machine/attached_mask
	var/obj/item/tank/attached_tank = null
	var/mask_out = FALSE

/obj/machinery/anesthetic_machine/Initialize()
	. = ..()
	attached_mask = new /obj/item/clothing/mask/breath/machine(src)
	attached_mask.machine_attached = src

/obj/machinery/anesthetic_machine/attack_hand(mob/living/user)
	. = ..()
	if(mask_out && iscarbon(attached_mask.loc)) // If mask is out, put it back into the machine
		var/mob/living/carbon/M = attached_mask.loc
		M.transferItemToLoc(attached_mask, src, TRUE)
		visible_message("<span class='notice'>[user] retracts the mask back into the [src], taking it off of [M].</span>")
		mask_out = FALSE
		M.internal = null

/obj/machinery/anesthetic_machine/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/tank))
		if(attached_tank) // If there is an attached tank, remove it and drop it on the floor
			attached_tank.forceMove(loc)
		I.forceMove(src) // Put new tank in, set it as attached tank
		to_chat(user, "You replace the [attached_tank] with the [I].")
		attached_tank = I

/obj/machinery/anesthetic_machine/AltClick(mob/user)
	. = ..()
	if(attached_tank) // If attached tank, remove it.
		attached_tank.forceMove(loc)
		to_chat(user, "<span class='notice'>You remove the [attached_tank].</span>")
		attached_tank = null

/obj/machinery/anesthetic_machine/MouseDrop(mob/living/carbon/target)
	. = ..()
	if(Adjacent(target) && usr.Adjacent(target))
		if(attached_tank && !mask_out)
			usr.visible_message("<span class='warning'>[usr] attemps to attach the [src] to [target].</span>", "<span class='notice'>You attempt to attach the [src] to [target].</span>")
			if(!do_after(usr, 20, TRUE, target))
				return
			if(!target.equip_to_appropriate_slot(attached_mask))
				to_chat(usr, "<span class='warning'>You are unable to attach the [src] to [target]!</span>")
				return
			else
				usr.visible_message("<span class='warning'>[usr] attaches the [src] to [target].</span>", "<span class='notice'>You attach the [src] to [target].</span>")
				target.internal = attached_tank
				mask_out = TRUE
				target.update_internals_hud_icon(1)

/obj/item/clothing/mask/breath/machine
	var/obj/machinery/anesthetic_machine/machine_attached

/obj/item/clothing/mask/breath/machine/dropped(mob/user)
	. = ..()
	if(loc != machine_attached) // If not already in machine, go back in when dropped (dropped is called on unequip)
		to_chat(user, "<span class='notice'>The mask snaps back into the [src].</span>")
		machine_attached.mask_out = FALSE
		forceMove(machine_attached)
