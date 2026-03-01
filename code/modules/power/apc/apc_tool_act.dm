//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/W)
	. = TRUE
	if (opened)
		if(integration_cog)
			to_chat(user, span_notice("You begin prying something out of the APC."))
			W.play_tool_sound(src)
			if(W.use_tool(src, user, 50))
				to_chat(user, span_warning("You screw up breaking whatever was inside!"))
				QDEL_NULL(integration_cog)
		else if (has_electronics == APC_ELECTRONICS_INSTALLED)
			if (terminal)
				to_chat(user, span_warning("Disconnect the wires first!"))
				return
			W.play_tool_sound(src)
			to_chat(user, span_notice("You attempt to remove the power control board.") )
			if(W.use_tool(src, user, 50))
				if (has_electronics == APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_MISSING
					if (machine_stat & BROKEN)
						user.visible_message(\
							"[user.name] has broken the power control board inside [src.name]!",\
							span_notice("You break the charred power control board and remove the remains."),
							span_italics("You hear a crack."))
						return
					else if (obj_flags & EMAGGED)
						obj_flags &= ~EMAGGED
						user.visible_message(\
							"[user.name] has discarded an emagged power control board from [src.name]!",\
							span_notice("You discard the emagged power control board."))
						return
					else if (malfhack)
						user.visible_message(\
							"[user.name] has discarded a strangely programmed power control board from [src.name]!",\
							span_notice("You discard the strangely programmed board."))
						malfai = null
						malfhack = 0
						return
					else
						user.visible_message(\
							"[user.name] has removed the power control board from [src.name]!",\
							span_notice("You remove the power control board."))
						new /obj/item/electronics/apc(loc)
						return
		else if (opened!=APC_COVER_REMOVED)
			opened = APC_COVER_CLOSED
			coverlocked = TRUE //closing cover relocks it
			update_appearance()
			return
	else if (!(machine_stat & BROKEN))
		if(coverlocked && !(machine_stat & MAINT)) // locked...
			to_chat(user, span_warning("The cover is locked and cannot be opened!"))
			return
		else if (panel_open)
			to_chat(user, span_warning("Exposed wires prevents you from opening it!"))
			return
		else
			opened = APC_COVER_OPENED
			update_appearance()
			return

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	. = TRUE
	if(opened)
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!",span_notice("You remove \the [cell]."))
			var/turf/T = get_turf(user)
			cell.forceMove(T)
			cell.update_appearance()
			cell = null
			charging = APC_NOT_CHARGING
			update_appearance()
			return
		else
			switch (has_electronics)
				if (APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_SECURED
					set_machine_stat(machine_stat & ~MAINT)
					W.play_tool_sound(src)
					to_chat(user, span_notice("You screw the circuit electronics into place."))
				if (APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					set_machine_stat(machine_stat | MAINT)
					W.play_tool_sound(src)
					to_chat(user, span_notice("You unfasten the electronics."))
				else
					to_chat(user, span_warning("There is nothing to secure!"))
					return
			update_appearance()
	else if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The interface is broken!"))
		return
	else
		panel_open = !panel_open
		to_chat(user, "The wires have been [panel_open ? "exposed" : "unexposed"].")
		update_appearance()

/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/W)
	if (terminal && opened)
		terminal.dismantle(user, W)
		return TRUE

/obj/machinery/power/apc/welder_act(mob/living/user, obj/item/W)
	if (opened && !has_electronics && !terminal)
		if(!W.tool_start_check(user, amount=3))
			return
		user.visible_message("[user.name] welds [src].", \
							span_notice("You start welding the APC frame."), \
							span_italics("You hear welding."))
		if(W.use_tool(src, user, 50, volume=50, amount=3))
			if ((machine_stat & BROKEN) || opened==APC_COVER_REMOVED)
				new /obj/item/stack/sheet/iron(loc)
				user.visible_message(\
					"[user.name] has cut [src] apart with [W].",\
					span_notice("You disassembled the broken APC frame."))
			else
				new /obj/item/wallframe/apc(loc)
				user.visible_message(\
					"[user.name] has cut [src] from the wall with [W].",\
					span_notice("You cut the APC frame from the wall."))
			qdel(src)
			return TRUE

/obj/machinery/power/apc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS)
		if(!has_electronics)
			if(machine_stat & BROKEN)
				to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
				return FALSE
			return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
		else if(!cell)
			if(machine_stat & MAINT)
				to_chat(user, span_warning("There's no connector for a power cell."))
				return FALSE
			return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 50, "cost" = 10) //16 for a wall
		else
			to_chat(user, span_warning("[src] has both electronics and a cell."))
			return FALSE
	return FALSE

/obj/machinery/power/apc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			if(!has_electronics)
				if(machine_stat & BROKEN)
					to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
					return
				user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
				span_notice("You adapt a power control board and click it into place in [src]'s guts."))
				has_electronics = TRUE
				locked = FALSE
				return TRUE
			else if(!cell)
				if(machine_stat & MAINT)
					to_chat(user, span_warning("There's no connector for a power cell."))
					return FALSE
				var/obj/item/stock_parts/cell/crap/empty/C = new(src)
				C.forceMove(src)
				cell = C
				user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
				span_warning("Your [the_rcd.name] whirrs with strain as you create a weak power cell and place it into [src]!"))
				update_appearance()
				return TRUE
			else
				to_chat(user, span_warning("[src] has both electronics and a cell."))
				return FALSE
	return FALSE

/obj/machinery/power/apc/should_emag(mob/user)
	if(!..() || malfhack)
		return FALSE
	if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
		return FALSE
	if(panel_open)
		to_chat(user, span_warning("You must close the panel first!"))
		return FALSE
	if(machine_stat & (BROKEN | MAINT))
		to_chat(user, span_warning("Nothing happens!"))
		return FALSE
	return TRUE

/obj/machinery/power/apc/on_emag(mob/user)
	..()
	flick("apc-spark", src)
	playsound(src, "sparks", 75, 1)
	locked = FALSE
	wires.ui_update()
	to_chat(user, span_notice("You emag the APC interface."))
	update_appearance()
	flicker_hacked_icon()

// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_CONTENTS))
		if(cell)
			cell.emp_act(severity)
		if(occupier)
			occupier.emp_act(severity)
	if(. & EMP_PROTECT_SELF)
		return
	lighting = 0
	equipment = 0
	environ = 0
	update_appearance()
	update()
	addtimer(CALLBACK(src, PROC_REF(reset), APC_RESET_EMP), 600)
