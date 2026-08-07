/obj/item/inducer
	name = "heavy-duty inducer"
	desc = "A tool for inductively charging internal power cells. It is ruggedized for frequent use."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	inhand_icon_state = "inducer-engi"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 7
	var/transfer_coef = 2
	var/opened = FALSE
	var/cell_type = /obj/item/stock_parts/cell/high/plus
	var/obj/item/stock_parts/cell/cell
	var/recharging = FALSE

/obj/item/inducer/Initialize(mapload)
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type

/obj/item/inducer/proc/induce(obj/item/stock_parts/cell/target, coefficient)
	var/totransfer = min(cell.charge, cell.chargerate) * transfer_coef
	target.give(totransfer * POWER_TRANSFER_LOSS)
	cell.use(totransfer)
	cell.update_icon()
	target.update_icon()

/obj/item/inducer/get_cell()
	return cell

/obj/item/inducer/emp_act(severity)
	. = ..()
	if(cell && !(. & EMP_PROTECT_CONTENTS))
		cell.emp_act(severity)

/obj/item/inducer/attack_atom(obj/O, mob/living/carbon/user, params)
	if(user.combat_mode)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(O, user))
		return

	return ..()

/obj/item/inducer/proc/cantbeused(mob/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to use [src]!"))
		return TRUE

	if(!cell)
		to_chat(user, span_warning("[src] doesn't have a power cell installed!"))
		return TRUE

	if(!cell.charge)
		to_chat(user, span_warning("[src]'s battery is dead!"))
		return TRUE
	return FALSE


/obj/item/inducer/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		W.play_tool_sound(src)
		if(!opened)
			to_chat(user, span_notice("You unscrew the battery compartment."))
			opened = TRUE
			update_icon()
			return
		else
			to_chat(user, span_notice("You close the battery compartment."))
			opened = FALSE
			update_icon()
			return
	if(istype(W, /obj/item/stock_parts/cell))
		if(opened)
			if(!cell)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, span_notice("You insert [W] into [src]."))
				cell = W
				update_icon()
				return
			else
				to_chat(user, span_notice("[src] already has \a [cell] installed!"))
				return

	if(cantbeused(user))
		return

	if(recharge(W, user))
		return

	return ..()

/obj/item/inducer/proc/recharge(atom/movable/A, mob/user)
	if(!isturf(A) && user.loc == A)
		return FALSE
	if(recharging)
		return TRUE
	else
		recharging = TRUE
	var/obj/item/stock_parts/cell/C = A.get_cell()
	var/obj/O
	var/obj/item/organ/stomach/battery/battery
	if(istype(A, /obj/item/gun/energy))
		to_chat(user, span_alert("Error unable to interface with device."))
		return FALSE
	if(istype(A, /obj/item/clothing/suit/space))
		to_chat(user, span_alert("Error unable to interface with device."))
		return FALSE
	if(istype(A, /obj))
		O = A
	if(iscarbon(A))
		var/mob/living/carbon/human_target = A
		if(HAS_TRAIT(human_target, TRAIT_POWERHUNGRY))
			battery = human_target.get_organ_slot(ORGAN_SLOT_STOMACH)
			if(!istype(battery))
				return

	var/maxcharge = battery?.max_charge || C?.maxcharge
	if(C || battery)
		var/done_any = FALSE
		if((battery?.charge || C.charge) >= maxcharge)
			to_chat(user, span_notice("[A] is fully charged!"))
			recharging = FALSE
			return TRUE
		user.visible_message("[user] starts recharging [A] with [src].",span_notice("You start recharging [A] with [src]."))
		while((battery?.charge || C.charge) < maxcharge)
			if(do_after(user, 10, target = user) && cell.charge)
				done_any = TRUE
				if(battery)
					battery.adjust_charge(min(cell.charge,250))
				else
					induce(C)
				do_sparks(1, FALSE, A)
				if(O)
					O.update_icon()
			else
				break
		if(done_any) // Only show a message if we succeeded at least once
			user.visible_message("[user] recharged [A]!",span_notice("You recharged [A]!"))
		recharging = FALSE
		return TRUE
	recharging = FALSE


/obj/item/inducer/attack(mob/M, mob/living/user)
	if(user.combat_mode)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(M, user))
		return
	return ..()


/obj/item/inducer/attack_self(mob/user)
	if(opened && cell)
		user.visible_message("[user] removes [cell] from [src]!",span_notice("You remove [cell]."))
		cell.update_icon()
		user.put_in_hands(cell)
		cell = null
		update_icon()
	if(!opened)
		recharge(user, user)


/obj/item/inducer/examine(mob/living/M)
	. = ..()
	if(cell)
		. += span_notice("Its display shows: [display_power(cell.charge)].")
	else
		. += span_notice("Its display is dark.")
	if(opened)
		. += span_notice("Its battery compartment is open.")

/obj/item/inducer/update_overlays()
	. = ..()
	if(opened)
		if(!cell)
			. += "inducer-nobat"
		else
			. += "inducer-bat"

///Starts empty for engineering protolathe
/obj/item/inducer/eng
	name = "heavy-duty inducer"
	cell_type = null
	opened = TRUE

/obj/item/inducer/eng/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/inducer/sci
	name = "inducer"
	icon_state = "inducer-sci"
	inhand_icon_state = "inducer-sci"
	desc = "A tool for inductively charging internal power cells. This one has a science color scheme, and is less potent than its engineering counterpart."
	cell_type = null
	transfer_coef = 1
	opened = TRUE

/obj/item/inducer/sci/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/inducer/sci/with_cell
	cell_type = /obj/item/stock_parts/cell/high
	opened = FALSE
