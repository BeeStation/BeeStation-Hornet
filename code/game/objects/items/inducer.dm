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
	/// Charge in the power source that this refuses to draw below.
	var/charge_reserve = 0

/obj/item/inducer/Initialize(mapload)
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type

/// The cell this inducer pulls charge out of. Not always the installed one - see /obj/item/inducer/cyborg.
/obj/item/inducer/proc/get_power_source()
	return cell

/obj/item/inducer/proc/induce(obj/item/stock_parts/cell/target)
	var/obj/item/stock_parts/cell/source = get_power_source()
	if(!source)
		return
	var/totransfer = min(source.charge - charge_reserve, source.chargerate * transfer_coef)
	if(totransfer <= 0)
		return
	// The 15% loss applies to charge given, not charge used
	var/transferred = target.give(totransfer * POWER_TRANSFER_LOSS)
	if(transferred <= 0)
		return
	source.use(transferred / POWER_TRANSFER_LOSS)
	source.update_icon()
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

	var/obj/item/stock_parts/cell/source = get_power_source()
	if(!source)
		to_chat(user, span_warning("[src] doesn't have a power cell installed!"))
		return TRUE

	if(source.charge <= charge_reserve)
		to_chat(user, span_warning("[src] is out of power!"))
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

/obj/item/inducer/proc/recharge(atom/movable/A, mob/living/user)
	if(!isturf(A) && user.loc == A)
		return FALSE
	if(recharging)
		return TRUE
	recharging = TRUE

	if(istype(A, /obj/item/gun/energy) || istype(A, /obj/item/clothing/suit/space))
		to_chat(user, span_alert("Error unable to interface with device."))
		recharging = FALSE
		return FALSE

	var/obj/item/stock_parts/cell/powercell = A.get_cell()
	var/obj/O
	var/obj/item/organ/stomach/electrical/biobattery

	if(istype(A, /obj))
		O = A
	else if(iscarbon(A))
		var/mob/living/carbon/human_target = A
		biobattery = human_target.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(!istype(biobattery))
			to_chat(user, span_alert("Error, unable to interface with this entity."))
			recharging = FALSE
			return FALSE

	if(!powercell && !biobattery)
		recharging = FALSE
		return FALSE

	var/maxcharge = biobattery?.cell.maxcharge || powercell?.maxcharge
	if((biobattery?.cell.charge || powercell.charge) >= maxcharge)
		to_chat(user, span_notice("[A] is fully charged!"))
		recharging = FALSE
		return TRUE

	user.visible_message("[user] starts recharging [A] with [src].", span_notice("You start recharging [A] with [src]."))
	var/done_any = FALSE
	while((biobattery?.cell.charge || powercell.charge) < maxcharge)
		var/obj/item/stock_parts/cell/source = get_power_source()
		if(!do_after(user, 10, target = user) || !source || source.charge <= charge_reserve)
			break
		done_any = TRUE
		if(biobattery)
			biobattery.adjust_charge(min(source.charge, 250))
		else
			induce(powercell)
		do_sparks(1, FALSE, A)
		if(O)
			O.update_icon()

	if(done_any) // Only show a message if we succeeded at least once
		user.visible_message("[user] recharged [A]!", span_notice("You recharged [A]!"))
	recharging = FALSE
	return TRUE


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
	var/obj/item/stock_parts/cell/source = get_power_source()
	if(source)
		. += span_notice("Its display shows: [display_power(source.charge)].")
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

/// Cyborg module. Has no battery of its own - it spends the chassis' charge instead.
/obj/item/inducer/cyborg
	name = "internal inducer"
	desc = "An integrated inducer that charges a device's internal cell with power drawn from its cyborg chassis."
	cell_type = null
	transfer_coef = 3
	charge_reserve = 500

/// The cyborg we are a module of. Modules sit in the model while stowed and on the borg itself while active.
/obj/item/inducer/cyborg/proc/get_borg()
	if(iscyborg(loc))
		return loc
	if(istype(loc, /obj/item/robot_model))
		var/obj/item/robot_model/model = loc
		if(iscyborg(model.loc))
			return model.loc
	return null

/obj/item/inducer/cyborg/get_power_source()
	var/mob/living/silicon/robot/borg = get_borg()
	return borg?.cell

/obj/item/inducer/cyborg/recharge(atom/movable/A, mob/living/user)
	var/mob/living/silicon/robot/borg = get_borg()
	// No feeding our own cell back into itself.
	if(borg && (A == borg || (borg.cell && (A == borg.cell || A.get_cell() == borg.cell))))
		balloon_alert(user, "can't charge yourself!")
		return TRUE
	return ..()

// No battery compartment to get at - the chassis is the battery.
/obj/item/inducer/cyborg/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER || istype(W, /obj/item/stock_parts/cell))
		return
	return ..()
