/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)

	if(issilicon(user) && get_dist(src,user)>1)
		return attack_hand(user)

	if	(istype(W, /obj/item/stock_parts/cell) && opened)
		if(cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed!</span>")
			return
		else
			if (machine_stat & MAINT)
				to_chat(user, "<span class='warning'>There is no connector for your power cell!</span>")
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			user.visible_message(\
				"[user.name] has inserted the power cell to [src.name]!",\
				"<span class='notice'>You insert the power cell.</span>")
			chargecount = 0
			update_appearance()
	else if (W.GetID())
		togglelock(user)
	else if (istype(W, /obj/item/stack/cable_coil) && opened)
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			CRASH("attackby on APC when it's not on a turf")
		if (host_turf.intact)
			to_chat(user, "<span class='warning'>You must remove the floor plating in front of the APC first!</span>")
			return
		else if (terminal)
			to_chat(user, "<span class='warning'>This APC is already wired!</span>")
			return
		else if (!has_electronics)
			to_chat(user, "<span class='warning'>There is nothing to wire!</span>")
			return

		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need ten lengths of cable for APC!</span>")
			return
		user.visible_message("[user.name] adds cables to the APC frame.", \
							"<span class='notice'>You start adding cables to the APC frame.</span>")
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
				to_chat(user, "<span class='notice'>You add cables to the APC frame.</span>")
				make_terminal()
				terminal.connect_to_network()
	else if (istype(W, /obj/item/electronics/apc) && opened)
		if (has_electronics)
			to_chat(user, "<span class='warning'>There is already a board inside the [src]!</span>")
			return
		else if (machine_stat & BROKEN)
			to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged!</span>")
			return

		user.visible_message("[user.name] inserts the power control board into [src].", \
							"<span class='notice'>You start to insert the power control board into the frame.</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 10, target = src))
			if(!has_electronics)
				has_electronics = APC_ELECTRONICS_INSTALLED
				locked = FALSE
				wires.ui_update()
				to_chat(user, "<span class='notice'>You place the power control board inside the frame.</span>")
				qdel(W)
	else if(istype(W, /obj/item/electroadaptive_pseudocircuit) && opened)
		var/obj/item/electroadaptive_pseudocircuit/P = W
		if(!has_electronics)
			if(machine_stat & BROKEN)
				to_chat(user, "<span class='warning'>[src]'s frame is too damaged to support a circuit.</span>")
				return
			if(!P.adapt_circuit(user, 50))
				return
			user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
			"<span class='notice'>You adapt a power control board and click it into place in [src]'s guts.</span>")
			has_electronics = APC_ELECTRONICS_INSTALLED
			locked = FALSE
			wires.ui_update()
		else if(!cell)
			if(machine_stat & MAINT)
				to_chat(user, "<span class='warning'>There's no connector for a power cell.</span>")
				return
			if(!P.adapt_circuit(user, 500))
				return
			var/obj/item/stock_parts/cell/crap/empty/C = new(src)
			C.forceMove(src)
			cell = C
			chargecount = 0
			user.visible_message("<span class='notice'>[user] fabricates a weak power cell and places it into [src].</span>", \
			"<span class='warning'>Your [P.name] whirs with strain as you create a weak power cell and place it into [src]!</span>")
			update_appearance()
		else
			to_chat(user, "<span class='warning'>[src] has both electronics and a cell.</span>")
			return
	else if (istype(W, /obj/item/wallframe/apc) && opened)
		if (!(machine_stat & BROKEN || opened==APC_COVER_REMOVED || obj_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, "<span class='warning'>You find no reason for repairing this APC.</span>")
			return
		if (!(machine_stat & BROKEN) && opened==APC_COVER_REMOVED)
		// Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message("[user.name] replaces missing APC's cover.",\
							"<span class='notice'>You begin to replace the APC's cover.</span>")
			if(do_after(user, 20, target = src)) // replacing cover is quicker than replacing whole frame
				to_chat(user, "<span class='notice'>You replace the missing APC cover.</span>")
				qdel(W)
				opened = APC_COVER_OPENED
				update_appearance()
			return
		if (has_electronics)
			to_chat(user, "<span class='warning'>You cannot repair this APC until you remove the electronics still inside!</span>")
			return
		user.visible_message("[user.name] replaces the damaged APC frame with a new one.",\
							"<span class='notice'>You begin to replace the damaged APC frame.</span>")
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You replace the damaged APC frame with a new one.</span>")
			qdel(W)
			set_machine_stat(machine_stat & ~BROKEN)
			obj_integrity = max_integrity
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

/obj/machinery/power/apc/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(isethereal(user))
		var/mob/living/carbon/human/H = user
		var/datum/species/ethereal/E = H.dna.species
		if(E.drain_time > world.time)
			return
		var/obj/item/organ/stomach/battery/stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
		if(H.a_intent == INTENT_HARM)
			if(!istype(stomach))
				to_chat(H, "<span class='warning'>You can't receive charge!</span>")
				return
			if(H.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
				to_chat(user, "<span class='warning'>You are already fully charged!</span>")
				return
			if(cell.charge <= cell.maxcharge/4) // if charge is under 25% you shouldn't drain it
				to_chat(H, "<span class='warning'>The APC doesn't have much power, you probably shouldn't drain anymore.</span>")
				return

			E.drain_time = world.time + 80
			to_chat(H, "<span class='notice'>You start channeling some power through the APC into your body.</span>")
			while(do_after(user, 75, target = src))
				if(!istype(stomach))
					to_chat(H, "<span class='warning'>You can't receive charge!</span>")
					return
				if(cell.charge <= cell.maxcharge/4)
					to_chat(H, "<span class='warning'>The APC doesn't have much power, you probably shouldn't drain anymore.</span>")
					E.drain_time = 0
					return
				E.drain_time = world.time + 80
				if(cell.charge > cell.maxcharge/4 + 250)
					stomach.adjust_charge(250)
					cell.charge -= 250
					to_chat(H, "<span class='notice'>You receive some charge from the APC.</span>")
				else
					stomach.adjust_charge(cell.charge - cell.maxcharge/4)
					cell.charge = cell.maxcharge/4
					to_chat(H, "<span class='warning'>The APC doesn't have much power, you probably shouldn't drain anymore.</span>")
					E.drain_time = 0
					return
				if(stomach.charge >= stomach.max_charge)
					to_chat(H, "<span class='notice'>You are now fully charged.</span>")
					E.drain_time = 0
					return
			to_chat(H, "<span class='warning'>You fail to receive charge from the APC!</span>")
			E.drain_time = 0
			return
		else if(H.a_intent == INTENT_GRAB)
			if(!istype(stomach))
				to_chat(H, "<span class='warning'>You can't transfer charge!</span>")
				return
			E.drain_time = world.time + 80
			to_chat(H, "<span class='notice'>You start channeling power through your body into the APC.</span>")
			while(do_after(user, 75, target = src))
				if(!istype(stomach))
					to_chat(H, "<span class='warning'>You can't transfer charge!</span>")
					return
				E.drain_time = world.time + 80
				if(stomach.charge > 250)
					to_chat(H, "<span class='notice'>You transfer some power to the APC.</span>")
					stomach.adjust_charge(-250)
					cell.charge = min(cell.charge + 250, cell.maxcharge)
				else
					to_chat(H, "<span class='notice'>You transfer the last of your charge to the APC.</span>")
					cell.charge = min(cell.charge + stomach.charge, cell.maxcharge)
					stomach.set_charge(0)
					E.drain_time = 0
					return
				if(cell.charge >= cell.maxcharge)
					to_chat(H, "<span class='notice'>The APC is now fully recharged.</span>")
					E.drain_time = 0
					return
			to_chat(H, "<span class='warning'>You fail to transfer power to the APC!</span>")
			E.drain_time = 0
			return

	if(opened && (!issilicon(user)))
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!","<span class='notice'>You remove \the [cell].</span>")
			user.put_in_hands(cell)
			cell.update_appearance()
			src.cell = null
			charging = APC_NOT_CHARGING
			src.update_appearance()
		return
	if((machine_stat & MAINT) && !opened) //no board; no interface
		return

/obj/machinery/power/apc/obj_break(damage_flag)
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
				to_chat(user, "<span class='danger'>\The [src] has eee disabled!</span>")
			return FALSE
	return TRUE

/obj/machinery/power/apc/can_interact(mob/user)
	. = ..()
	if (!. && !QDELETED(remote_control))
		. = remote_control.can_interact(user)

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = CLAMP(malfai.malf_picker.processing_time - 10,0,1000)
	machine_stat |= BROKEN
	operating = FALSE
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
