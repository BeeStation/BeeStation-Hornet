// Ethereals:
/// How long it takes an ethereal to drain or charge APCs. Also used as a spam limiter.
#define ETHEREAL_APC_DRAIN_TIME (3 SECONDS)
/// How much power ethereals gain/drain from APCs.
#define ETHEREAL_APC_POWER_GAIN (0.1 * STANDARD_ETHEREAL_CHARGE)
/// Delay between ethereal action and balloon alert, to avoid colliding with previously queued balloon alerts.
#define ETHEREAL_APC_ALERT_DELAY (0.75 SECONDS)

/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)

	if(issilicon(user) && get_dist(src,user)>1)
		return attack_hand(user)

	if	(istype(W, /obj/item/stock_parts/cell) && opened)
		if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
			return
		else
			if (machine_stat & MAINT)
				to_chat(user, span_warning("There is no connector for your power cell!"))
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			user.visible_message(\
				"[user.name] has inserted the power cell to [src.name]!",\
				span_notice("You insert the power cell."))
			update_appearance()
	else if (W.GetID())
		togglelock(user)
	else if (istype(W, /obj/item/stack/cable_coil) && opened)
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			CRASH("attackby on APC when it's not on a turf")
		if (host_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
			to_chat(user, span_warning("You must remove the floor plating in front of the APC first!"))
			return
		else if (terminal)
			to_chat(user, span_warning("This APC is already wired!"))
			return
		else if (!has_electronics)
			to_chat(user, span_warning("There is nothing to wire!"))
			return

		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, span_warning("You need ten lengths of cable for APC!"))
			return
		user.visible_message("[user.name] adds cables to the APC frame.", \
							span_notice("You start adding cables to the APC frame."))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			if (C.get_amount() < 10 || !C)
				return
			if (C.get_amount() >= 10 && !terminal && opened && has_electronics)
				var/turf/T = get_turf(src)
				var/obj/structure/cable/N = T.get_cable_node()
				if (prob(50) && electrocute_mob(usr, N, N, 1, TRUE))
					do_sparks(5, TRUE, src)
					return
				C.use(10)
				to_chat(user, span_notice("You add cables to the APC frame."))
				make_terminal()
				terminal.connect_to_network()
	else if (istype(W, /obj/item/electronics/apc) && opened)
		if (has_electronics)
			to_chat(user, span_warning("There is already a board inside the [src]!"))
			return
		else if (machine_stat & BROKEN)
			to_chat(user, span_warning("You cannot put the board inside, the frame is damaged!"))
			return

		user.visible_message("[user.name] inserts the power control board into [src].", \
							span_notice("You start to insert the power control board into the frame."))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 10, target = src))
			if(!has_electronics)
				has_electronics = APC_ELECTRONICS_INSTALLED
				locked = FALSE
				wires.ui_update()
				to_chat(user, span_notice("You place the power control board inside the frame."))
				qdel(W)
	else if(istype(W, /obj/item/electroadaptive_pseudocircuit) && opened)
		var/obj/item/electroadaptive_pseudocircuit/P = W
		if(!has_electronics)
			if(machine_stat & BROKEN)
				to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
				return
			if(!P.adapt_circuit(user, 50))
				return
			user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
			span_notice("You adapt a power control board and click it into place in [src]'s guts."))
			has_electronics = APC_ELECTRONICS_INSTALLED
			locked = FALSE
			wires.ui_update()
		else if(!cell)
			if(machine_stat & MAINT)
				to_chat(user, span_warning("There's no connector for a power cell."))
				return
			if(!P.adapt_circuit(user, 500))
				return
			var/obj/item/stock_parts/cell/crap/empty/C = new(src)
			C.forceMove(src)
			cell = C
			user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
			span_warning("Your [P.name] whirs with strain as you create a weak power cell and place it into [src]!"))
			update_appearance()
		else
			to_chat(user, span_warning("[src] has both electronics and a cell."))
			return
	else if (istype(W, /obj/item/wallframe/apc) && opened)
		if (!(machine_stat & BROKEN || opened==APC_COVER_REMOVED || atom_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, span_warning("You find no reason for repairing this APC."))
			return
		if (!(machine_stat & BROKEN) && opened==APC_COVER_REMOVED)
		// Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message("[user.name] replaces missing APC's cover.",\
							span_notice("You begin to replace the APC's cover."))
			if(do_after(user, 20, target = src)) // replacing cover is quicker than replacing whole frame
				to_chat(user, span_notice("You replace the missing APC cover."))
				qdel(W)
				opened = APC_COVER_OPENED
				update_appearance()
			return
		if (has_electronics)
			to_chat(user, span_warning("You cannot repair this APC until you remove the electronics still inside!"))
			return
		user.visible_message("[user.name] replaces the damaged APC frame with a new one.",\
							span_notice("You begin to replace the damaged APC frame."))
		if(do_after(user, 50, target = src))
			to_chat(user, span_notice("You replace the damaged APC frame with a new one."))
			qdel(W)
			set_machine_stat(machine_stat & ~BROKEN)
			atom_integrity = max_integrity
			if (opened==APC_COVER_REMOVED)
				opened = APC_COVER_OPENED
			update_appearance()

	else if(istype(W, /obj/item/apc_powercord))
		return //because we put our fancy code in the right places, and this is all in the powercord's afterattack()

	else if(panel_open && !opened && is_wire_tool(W))
		wires.interact(user)
	else
		return ..()

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(opened && (!issilicon(user)))
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!",span_notice("You remove \the [cell]."))
			user.put_in_hands(cell)
			cell.update_appearance()
			src.cell = null
			charging = APC_NOT_CHARGING
			src.update_appearance()
		return
	if((machine_stat & MAINT) && !opened) //no board; no interface
		return

/obj/machinery/power/apc/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/stomach/electrical/ethereal/maybe_ethereal_stomach = human_user.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!istype(maybe_ethereal_stomach))
		togglelock(user)
	else
		if(maybe_ethereal_stomach.cell.charge >= ETHEREAL_CHARGE_NORMAL)
			togglelock(user)
		ethereal_interact(human_user, maybe_ethereal_stomach, modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Special behavior for when an ethereal interacts with an APC.
/obj/machinery/power/apc/proc/ethereal_interact(mob/living/carbon/human/user, obj/item/organ/stomach/electrical/ethereal/used_stomach, list/modifiers)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	if(isnull(cell))
		return
	if(used_stomach.drain_time > world.time)
		return
	if(user.combat_mode)
		discharge_to_ethereal(user, used_stomach)
	else
		charge_from_ethereal(user, used_stomach)

/// Handles discharging our internal cell to an ethereal and their stomach
/obj/machinery/power/apc/proc/discharge_to_ethereal(mob/living/carbon/human/user, obj/item/organ/stomach/electrical/ethereal/used_stomach)
	var/half_max_charge = cell.maxcharge / 2
	// Ethereals can't drain APCs under half charge, so that they are forced to look to alternative power sources if the station is running low
	if(cell.charge < half_max_charge)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "safeties prevent draining!"), ETHEREAL_APC_ALERT_DELAY)
		return

	var/obj/item/stock_parts/cell/stomach_cell = used_stomach.cell
	used_stomach.drain_time = world.time + ETHEREAL_APC_DRAIN_TIME
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "draining power..."), ETHEREAL_APC_ALERT_DELAY)
	while(do_after(user, ETHEREAL_APC_DRAIN_TIME, target = src))
		if(isnull(used_stomach) || (used_stomach != user.get_organ_slot(ORGAN_SLOT_STOMACH)))
			balloon_alert(user, "stomach removed!?")
			return
		if(isnull(cell))
			balloon_alert(user, "cell removed!")
			return
		if(cell.charge < half_max_charge)
			balloon_alert(user, "safeties kicked in!")
			return

		var/our_available_charge = cell.charge - half_max_charge
		var/stomach_used_charge = stomach_cell.used_charge()
		var/potential_charge = min(our_available_charge, stomach_used_charge)
		var/to_drain = min(ETHEREAL_APC_POWER_GAIN, potential_charge)
		var/energy_drained = cell.use(to_drain, force = TRUE)
		used_stomach.adjust_charge(energy_drained)

		if(stomach_cell.used_charge() <= 0)
			balloon_alert(user, "your charge is full!")
			return
		if(cell.charge <= 0)
			balloon_alert(user, "apc is empty!")
			return

/// Handles charging our internal cell from an ethereal and their stomach
/obj/machinery/power/apc/proc/charge_from_ethereal(mob/living/carbon/human/user, obj/item/organ/stomach/electrical/ethereal/used_stomach)
	if(cell.charge >= cell.maxcharge)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "apc full!"), ETHEREAL_APC_ALERT_DELAY)
		return
	var/obj/item/stock_parts/cell/stomach_cell = used_stomach.cell
	if(stomach_cell.charge <= 0)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "charge is too low!"), ETHEREAL_APC_ALERT_DELAY)
		return

	used_stomach.drain_time = world.time + ETHEREAL_APC_DRAIN_TIME
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "transferring power..."), ETHEREAL_APC_ALERT_DELAY)
	if(!do_after(user, ETHEREAL_APC_DRAIN_TIME, target = src))
		return
	if(isnull(used_stomach) || (used_stomach != user.get_organ_slot(ORGAN_SLOT_STOMACH)))
		balloon_alert(user, "stomach removed!?")
		return
	if(isnull(cell))
		balloon_alert(user, "cell removed!")
		return

	var/stomach_charge = stomach_cell.charge
	var/our_used_charge = cell.used_charge()
	var/potential_charge = min(stomach_charge, our_used_charge)
	var/to_drain = min(ETHEREAL_APC_POWER_GAIN, potential_charge)
	var/energy_drained = used_stomach.adjust_charge(-to_drain)
	cell.give(-energy_drained)

	if(cell.used_charge() <= 0)
		balloon_alert(user, "apc is full!")
		return
	if(stomach_cell.charge <= 0)
		balloon_alert(user, "out of charge!")

/obj/machinery/power/apc/atom_break(damage_flag)
	. = ..()
	if(.)
		set_broken()

/obj/machinery/power/apc/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	ui_interact(eminence)

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(IsAdminGhost(user))
		return TRUE
	if(user.has_unlimited_silicon_privilege)
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(!allowed(user))
			return FALSE
		if (                                                             \
			src.aidisabled ||                                            \
			malfhack && istype(malfai) &&                                \
			(                                                            \
				(istype(AI) && (malfai!=AI && malfai != AI.parent)) ||   \
				(istype(robot) && (robot in malfai.connected_robots))    \
			)                                                            \
		)
			if(!loud)
				to_chat(user, span_danger("\The [src] has been disabled!"))
			return FALSE
	return TRUE

/obj/machinery/power/apc/can_interact(mob/user)
	. = ..()
	if (!. && !QDELETED(remote_control))
		. = remote_control.can_interact(user)

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = clamp(malfai.malf_picker.processing_time - 10,0,1000)
	operating = FALSE
	atom_break()
	if(occupier)
		malfvacate(1)
	update_appearance()
	update()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	do_sparks(5, TRUE, src)
	if(isalien(user))
		return 0
	if(electrocute_mob(user, src, src, 1, TRUE))
		return 1
	else
		return 0

#undef ETHEREAL_APC_DRAIN_TIME
#undef ETHEREAL_APC_POWER_GAIN
#undef ETHEREAL_APC_ALERT_DELAY
