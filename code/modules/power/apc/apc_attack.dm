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
			set_cell(W)
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
			set_cell(C)
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

	if(isethereal(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/stomach/battery/stomach = H.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(!stomach)
			return
		// Maximum values for percentage calculation
		var/max_hunger = NUTRITION_LEVEL_FED       // typically 600
		var/max_apc_charge = cell ? cell.maxcharge : 100

		// Continuous loop
		var/keep_going = TRUE
		while(keep_going)
			// Check if user is still in the same tile and alive/conscious
			if(QDELETED(H) || H.stat != CONSCIOUS || get_dist(H, src) > 1)
				keep_going = FALSE
				break

			if(H.combat_mode)  // Drain APC → gain hunger
				// ethereals can't drain APCs under half charge, this is so that they are forced to look to alternative power sources if the station is running low
				if(!cell || cell.charge < max_apc_charge * 0.5)
					to_chat(H, span_warning("The APC's inner circuitry prevent you from draining anymore."))
					break
				// Check if Ethereal is already at max hunger (prevent overflow)
				if(H.nutrition >= max_hunger - (max_hunger * 0.1))
					to_chat(H, span_warning("You are already fully charged! Cannot drain more."))
					break
			else  // Give power to APC → lose hunger
				// Need at least 10% Ethereal hunger to give
				if(H.nutrition < max_hunger * 0.1)
					to_chat(H, span_warning("You don't have enough energy to transfer."))
					break
				// APC must have room for 10% more charge
				if(!cell || cell.charge >= max_apc_charge - (max_apc_charge * 0.1))
					to_chat(H, span_warning("The APC cannot accept more charge."))
					break

			// Start the transfer
			if(H.combat_mode)
				to_chat(H, span_notice("You start draining energy from the APC."))
			else
				to_chat(H, span_notice("You start transferring some of your energy to the APC."))

			// Perform the do_after (user must stand still for APC_DRAIN_TIME)
			if(!do_after(H, APC_DRAIN_TIME, target = src, progress = TRUE))
				to_chat(H, span_warning("You stop interacting with the APC."))
				break

			// Small chance of electrocution during the process (15%)
			if(prob(15))
				H.visible_message(span_danger("[H] gets shocked by [src]!"), \
								  span_userdanger("You are jolted by an electrical discharge from [src]!"))
				playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE)
				do_sparks(3, TRUE, src)
				H.electrocute_act(rand(5, 15), src, siemens_coeff = 0.5, flags = SHOCK_NOGLOVES)
				// Shock does not interrupt the transfer; it's just an additional hazard.

			// Re-check conditions after the delay (they might have changed)
			if(H.combat_mode)  // Drain
				if(!cell || cell.charge < max_apc_charge * 0.5)
					to_chat(H, span_warning("The APC no longer has enough charge to drain."))
					break
				if(H.nutrition >= max_hunger - (max_hunger * 0.1))
					to_chat(H, span_warning("You are already fully charged!"))
					break
				// Perform drain
				var/hunger_gain = max_hunger * 0.1
				H.adjust_nutrition(hunger_gain)
				cell.charge = max(0, cell.charge - (max_apc_charge * 0.1))
				to_chat(H, span_notice("You drain energy from the APC."))
				H.balloon_alert(H, "Drained APC (+10% energy)")
				playsound(src, 'sound/machines/defib_charge.ogg', 30, TRUE)
				update_icon()
			else  // Give
				if(H.nutrition < max_hunger * 0.1)
					to_chat(H, span_warning("You no longer have enough energy to transfer."))
					break
				if(!cell || cell.charge >= max_apc_charge - (max_apc_charge * 0.1))
					to_chat(H, span_warning("The APC cannot accept more charge."))
					break
				// Perform give
				var/hunger_loss = max_hunger * 0.1
				H.adjust_nutrition(-hunger_loss)
				cell.charge = min(max_apc_charge, cell.charge + (max_apc_charge * 0.1))
				to_chat(H, span_notice("You transfer some of your energy to the APC."))
				H.balloon_alert(H, "Transferred energy (+10% APC)")
				playsound(src, 'sound/machines/defib_charge.ogg', 30, TRUE)
				update_icon()

			// Small delay to prevent infinite loop if something fails
			sleep(1) // Let other processes run

		return

	if(opened && (!issilicon(user)))
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!",span_notice("You remove \the [cell]."))
			var/obj/item/stock_parts/cell/removed_cell = cell
			set_cell(null)
			user.put_in_hands(removed_cell)
			removed_cell.update_appearance()
			charging = APC_NOT_CHARGING
			src.update_appearance()
		return
	if((machine_stat & MAINT) && !opened) //no board; no interface
		return

/obj/machinery/power/apc/atom_break(damage_flag)
	. = ..()
	if(.)
		set_broken()

/obj/machinery/power/apc/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	ui_interact(eminence)

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/exchange_parts(mob/user, obj/item/storage/part_replacer/replacer_tool)
	try_rped_swap(replacer_tool, user)
	return TRUE

/obj/machinery/power/apc/proc/try_rped_swap(obj/item/storage/part_replacer/replacer, mob/living/user)
	var/is_bluespace = istype(replacer, /obj/item/storage/part_replacer/bluespace)

	if(!opened && !is_bluespace)
		to_chat(user, span_warning("You need to open [src]'s cover first!"))
		return

	if(machine_stat & MAINT)
		to_chat(user, span_warning("There is no connector for a power cell!"))
		return

	if(replacer.works_from_distance)
		to_chat(user, display_parts(user))

	var/current_rating = cell?.rating || 0
	var/obj/item/stock_parts/cell/best_cell

	for(var/obj/item/stock_parts/cell/candidate in replacer)
		if(candidate.rating <= current_rating)
			continue
		if(!best_cell || candidate.rating > best_cell.rating)
			best_cell = candidate
		else if(candidate.rating == best_cell.rating && candidate.charge > best_cell.charge)
			best_cell = candidate // We choose the best one and the best one that is fully charged if there is one

	if(!best_cell)
		return

	if(is_bluespace && (best_cell.rigged || best_cell.corrupted))
		best_cell.charge = best_cell.maxcharge
		best_cell.explode() // bomba (reused from regular corrupted RPED exchange)
		return

	var/obj/item/stock_parts/cell/old_cell = cell
	set_cell(best_cell)
	best_cell.forceMove(src)
	cell.update_appearance()

	if(old_cell)
		old_cell.forceMove(replacer)

	charging = APC_NOT_CHARGING
	update_appearance()

	to_chat(user, span_notice("[capitalize("[old_cell || "empty slot"]")] replaced with [best_cell]."))
	replacer.play_rped_sound()

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
