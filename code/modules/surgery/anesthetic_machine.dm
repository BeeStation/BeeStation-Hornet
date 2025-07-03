/obj/machinery/anesthetic_machine
	name = "Anesthetic Tank Holder"
	desc = "A wheeled machine that can hold an anesthetic tank and distribute the air using a breath mask."
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "breath_machine"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/item/clothing/mask/breath/machine/attached_mask
	var/obj/item/tank/attached_tank = null
	var/mask_out = FALSE

/obj/machinery/anesthetic_machine/Initialize(mapload)
	. = ..()
	attached_mask = new /obj/item/clothing/mask/breath/machine(src, src)
	update_icon()

/obj/machinery/anesthetic_machine/update_icon()
	cut_overlays()
	if(mask_out)
		add_overlay("mask_off")
	else
		add_overlay("mask_on")
	if(attached_tank)
		add_overlay("tank_on")


/obj/machinery/anesthetic_machine/attack_hand(mob/living/user)
	. = ..()
	if(retract_mask())
		visible_message(span_notice("[user] retracts the mask back into \the [src]."))

/obj/machinery/anesthetic_machine/attacked_by(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/tank))
		if(attached_tank) // If there is an attached tank, remove it and drop it on the floor
			attached_tank.forceMove(loc)
		I.forceMove(src) // Put new tank in, set it as attached tank
		visible_message(span_warning("[user] inserts [I] into [src]."))
		attached_tank = I
		update_icon()
		return
	. = ..()

/obj/machinery/anesthetic_machine/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(attached_tank)// If attached tank, remove it.
		attached_tank.forceMove(loc)
		to_chat(user, span_notice("You remove \the [attached_tank]."))
		attached_tank = null
		update_icon()
		if(mask_out)
			retract_mask()

/obj/machinery/anesthetic_machine/proc/retract_mask()
	if(mask_out)
		if(iscarbon(attached_mask.loc)) // If mask is on a mob
			var/mob/living/carbon/M = attached_mask.loc
			M.transferItemToLoc(attached_mask, src, TRUE)
			M.internal = null
		else
			attached_mask.forceMove(src)
		mask_out = FALSE
		update_icon()
		return TRUE
	return FALSE

/obj/machinery/anesthetic_machine/MouseDrop(mob/living/carbon/target)
	. = ..()
	if(!iscarbon(target))
		return
	if(Adjacent(target) && usr.Adjacent(target))
		if(attached_tank && !mask_out)
			usr.visible_message(span_warning("[usr] attempts to attach \the [src] to [target]."), span_notice("You attempt to attach \the [src] to [target]."))
			if(!do_after(usr, target != usr ? (7 SECONDS) : (1 SECONDS), target))
				return
			if(!target.equip_to_appropriate_slot(attached_mask))
				to_chat(usr, span_warning("You are unable to attach \the [src] to [target]!"))
				return
			else
				usr.visible_message(span_warning("[usr] attaches \the [src] to [target]."), span_notice("You attach \the [src] to [target]."))
				target.external = attached_tank
				mask_out = TRUE
				START_PROCESSING(SSmachines, src)
				update_icon()
		else
			to_chat(usr, span_warning("[mask_out ? "The machine is already in use!" : "The machine has no attached tank!"]"))

/obj/machinery/anesthetic_machine/process()
	if(!mask_out) // If not on someone, stop processing
		return PROCESS_KILL

	if(get_dist(src, get_turf(attached_mask)) > 1) // If too far away, detach
		to_chat(attached_mask.loc, span_warning("\The [attached_mask] is ripped off of your face!"))
		retract_mask()
		return PROCESS_KILL

/obj/machinery/anesthetic_machine/Destroy()
	if(mask_out)
		retract_mask()
	QDEL_NULL(attached_mask)
	. = ..()

/obj/machinery/anesthetic_machine/atom_destruction()
	if(mask_out)
		retract_mask()
	QDEL_NULL(attached_mask)
	new /obj/item/clothing/mask/breath(src)
	if(attached_tank)
		attached_tank.forceMove(get_turf(src))
		attached_tank.visible_message(span_notice("[attached_tank] falls to the ground from the destroyed Anesthetic Tank Holder."))
	return ..()

/obj/machinery/anesthetic_machine/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(attached_tank)
		to_chat(user, span_warning("You need to remove the anesthetic tank first!"))
		return
	if(!mask_out)
		visible_message(span_warning("[user] attempts to detach the breath mask from [src]."), span_notice("You attempt to detach the breath mask from [src]."))
		if(!do_after(user, 100, src, timed_action_flags = IGNORE_HELD_ITEM))
			to_chat(user, span_warning("You fail to dettach the breath mask from [src]!"))
			return
		visible_message(span_warning("[user] detaches the breath mask from [src]."), span_notice("You detach the breath mask from [src]."))
		new /obj/machinery/iv_drip(loc)
		QDEL_NULL(attached_mask)
		user.put_in_hands(new /obj/item/clothing/mask/breath)
		qdel(src)

/obj/machinery/anesthetic_machine/examine(mob/user)
	. = ..()
	if(attached_tank)
		. += span_notice("[icon2html(attached_tank, user)] It has \a [attached_tank] mounted onto it. The tank's gauge reads [round(attached_tank.air_contents.total_moles(), 0.01)] mol at [round(attached_tank.air_contents.return_pressure(),0.01)] kPa.")
	else if(!mask_out)
		. += span_notice("There is no tank mounted and the breath mask could be <b>detached</b> from it.")

CREATION_TEST_IGNORE_SELF(/obj/item/clothing/mask/breath/machine)

/obj/item/clothing/mask/breath/machine
	var/obj/machinery/anesthetic_machine/machine_attached
	clothing_flags = MASKINTERNALS | MASKEXTENDRANGE

/obj/item/clothing/mask/breath/machine/Initialize(mapload, machine_attached)
	. = ..()
	if (!machine_attached)
		CRASH("Anaethetic mask created without an attached machine")
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	src.machine_attached = machine_attached

/obj/item/clothing/mask/breath/machine/Destroy()
	machine_attached = null
	return ..()

/obj/item/clothing/mask/breath/machine/dropped(mob/user)
	..()
	if(loc != machine_attached) // If not already in machine, go back in when dropped (dropped is called on unequip)
		to_chat(user, span_notice("The mask snaps back into \the [machine_attached]."))
		machine_attached.retract_mask()
