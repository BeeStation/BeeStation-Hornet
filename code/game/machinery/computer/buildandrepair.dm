/obj/structure/frame/computer
	name = "computer frame"
	icon_state = "0"
	state = FRAME_STATE_EMPTY

/obj/structure/frame/computer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_rotation)

/obj/structure/frame/computer/add_context_self(datum/screentip_context/context, mob/user)
	switch(state)
		if(FRAME_STATE_EMPTY)
			context.add_left_click_tool_action("[anchored ? "Un" : ""]anchor", TOOL_WRENCH)
			if(anchored && !circuit)
				context.add_left_click_item_action("Install board", /obj/item/circuitboard/computer)
				return
			else
				context.add_left_click_tool_action("Unweld frame", TOOL_WELDER)
			return
		if(FRAME_COMPUTER_STATE_BOARD_INSTALLED)
			if(circuit)
				context.add_left_click_tool_action("Pry out board", TOOL_CROWBAR)
				context.add_left_click_tool_action("Secure board", TOOL_SCREWDRIVER)
			return
		if(FRAME_COMPUTER_STATE_BOARD_SECURED)
			context.add_left_click_tool_action("Unsecure board", TOOL_SCREWDRIVER)
			context.add_left_click_item_action("Install cable", /obj/item/stack/cable_coil)
			return
		if(FRAME_COMPUTER_STATE_WIRED)
			context.add_left_click_tool_action("Cut out cable", TOOL_WIRECUTTER)
			context.add_left_click_item_action("Install panel", /obj/item/stack/sheet/glass)
			return
		if(FRAME_COMPUTER_STATE_GLASSED)
			context.add_left_click_tool_action("Pry out glass", TOOL_CROWBAR)
			context.add_left_click_tool_action("Complete frame", TOOL_SCREWDRIVER)
			return

/// Installs the board in the computer
/obj/structure/frame/computer/proc/install_board(obj/item/circuitboard/computer/board, mob/user, by_hand)
	if(by_hand && !user.transferItemToLoc(board, src))
		return FALSE
	else if(!board.forceMove(src))
		return FALSE

	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	to_chat(user, span_notice("You place [board] inside the frame."))
	icon_state = "1"
	circuit = board
	circuit.add_fingerprint(user)

	return TRUE

/obj/structure/frame/computer/attackby(obj/item/P, mob/living/user, params)
	add_fingerprint(user)
	switch(state)
		if(FRAME_STATE_EMPTY)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start wrenching the frame into place..."))
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, span_notice("You wrench the frame into place."))
					set_anchored(TRUE)
					state = 1
				return
			if(P.tool_behaviour == TOOL_WELDER)
				if(!P.tool_start_check(user, amount=0))
					return

				to_chat(user, span_notice("You start deconstructing the frame..."))
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, span_notice("You deconstruct the frame."))
					new /obj/item/stack/sheet/iron(drop_location(), 5, TRUE, user)
					qdel(src)
				return
		if(1)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start to unfasten the frame..."))
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, span_notice("You unfasten the frame."))
					set_anchored(FALSE)
					state = 0
				return

			if(!circuit)
				//attempt to install circuitboard from part replacer
				if(istype(P, /obj/item/storage/part_replacer) && P.contents.len)
					var/obj/item/storage/part_replacer/replacer = P
					// map of circuitboard names to the board
					var/list/circuit_boards = list()
					for(var/obj/item/circuitboard/computer/board in replacer.contents)
						circuit_boards[board.name] = board
					if(!length(circuit_boards))
						return
					//if there is only one board directly install it else pick from list
					var/obj/item/circuitboard/computer/target_board
					if(circuit_boards.len == 1)
						for(var/board_name in circuit_boards)
							target_board = circuit_boards[board_name]
					else
						var/option = tgui_input_list(user, "Select Circuitboard To Install"," Available Boards", circuit_boards)
						target_board = circuit_boards[option]
						if(!target_board)
							return

					if(install_board(target_board, user, by_hand = FALSE))
						replacer.play_rped_sound()
						//automatically screw the board in as well, a perk of using the rped
						to_chat(user, span_notice("You screw [circuit] into place."))
						state = 2
						icon_state = "2"
						//attack again so we can install the cable & glass
						attackby(replacer, user, params)
						return

				//attempt to install circuitboard by hand
				if(istype(P, /obj/item/circuitboard/computer))
					install_board(P, user, by_hand = TRUE)
					return
				else if(istype(P, /obj/item/circuitboard))
					to_chat(user, span_warning("This frame does not accept circuit boards of this type!"))
					return
			else
				if(P.tool_behaviour == TOOL_SCREWDRIVER)
					P.play_tool_sound(src)
					to_chat(user, span_notice("You screw [circuit] into place."))
					state = 2
					icon_state = "2"
					return
				if(P.tool_behaviour == TOOL_CROWBAR)
					P.play_tool_sound(src)
					to_chat(user, span_notice("You remove [circuit]."))
					state = 1
					icon_state = "0"
					circuit.forceMove(drop_location())
					circuit.add_fingerprint(user)
					circuit = null
					return
		if(2)
			if(P.tool_behaviour == TOOL_SCREWDRIVER && circuit)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You unfasten the circuit board."))
				state = 1
				icon_state = "1"
			else
				//serach for cable which can either be the attacking item or inside an rped
				var/obj/item/stack/cable_coil/cable = null
				if(istype(P, /obj/item/stack/cable_coil))
					cable = P
				else if(istype(P, /obj/item/storage/part_replacer))
					cable = locate(/obj/item/stack/cable_coil) in P.contents
				if(!cable)
					return

				//install cable
				if(!cable.tool_start_check(user, amount = 5))
					return
				to_chat(user, span_notice("You start adding cables to the frame..."))
				if(cable.use_tool(src, user, istype(P, /obj/item/storage/part_replacer) ? 0 : 20, volume = 50, amount = 5))
					if(state != 2)
						return
					to_chat(user, span_notice("You add cables to the frame."))
					state = 3
					icon_state = "3"

				//if the item was an rped then it could have glass sheets for the next stage so let it continue
				if(istype(P, /obj/item/storage/part_replacer))
					var/obj/item/storage/part_replacer/replacer = P
					replacer.play_rped_sound()
					//reattack to install the glass sheets as well
					attackby(replacer, user, params)
				return
		if(3)
			if(P.tool_behaviour == TOOL_WIRECUTTER)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You remove the cables."))
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new (drop_location(), 5)
				if (!QDELETED(A))
					A.add_fingerprint(user)
			else
				//search for glass sheets which can either be the attacking item or inside an rped
				var/obj/item/stack/sheet/glass/glass_sheets = null
				if(istype(P, /obj/item/stack/sheet/glass))
					glass_sheets = P
				else if(istype(P, /obj/item/storage/part_replacer))
					glass_sheets = locate(/obj/item/stack/sheet/glass) in P.contents
				if(!glass_sheets)
					return

				//install glass sheets
				if(!glass_sheets.tool_start_check(user, amount = 2))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				to_chat(user, span_notice("You start to put in the glass panel..."))
				if(glass_sheets.use_tool(src, user, istype(P, /obj/item/storage/part_replacer) ? 0 : 20, amount = 2))
					if(state != 3)
						return
					to_chat(user, span_notice("You put in the glass panel."))
					state = 4
					icon_state = "4"

				if(istype(P, /obj/item/storage/part_replacer))
					var/obj/item/storage/part_replacer/replacer = P
					replacer.play_rped_sound()
				return
		if(4)
			if(P.tool_behaviour == TOOL_CROWBAR)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You remove the glass panel."))
				state = 3
				icon_state = "3"
				new /obj/item/stack/sheet/glass(drop_location(), 2, TRUE, user)
				return
			if(P.tool_behaviour == TOOL_SCREWDRIVER)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You connect the monitor."))

				var/obj/machinery/new_machine = new circuit.build_path(loc)
				new_machine.setDir(dir)
				transfer_fingerprints_to(new_machine)

				if(istype(new_machine, /obj/machinery/computer))
					var/obj/machinery/computer/new_computer = new_machine

					// Machines will init with a set of default components.
					// Triggering handle_atom_del will make the machine realise it has lost a component_parts and then deconstruct.
					// Move to nullspace so we don't trigger handle_atom_del, then qdel.
					// Finally, replace new machine's parts with this frame's parts.
					if(new_computer.circuit)
						// Move to nullspace and delete.
						new_computer.circuit.moveToNullspace()
						QDEL_NULL(new_computer.circuit)
					for(var/old_part in new_computer.component_parts)
						var/atom/movable/movable_part = old_part
						// Move to nullspace and delete.
						movable_part.moveToNullspace()
						qdel(movable_part)

					// Set anchor state and move the frame's parts over to the new machine.
					// Then refresh parts and call on_construction().
					new_computer.set_anchored(anchored)
					new_computer.component_parts = list()

					circuit.forceMove(new_computer)
					new_computer.component_parts += circuit
					new_computer.circuit = circuit

					for(var/new_part in src)
						var/atom/movable/movable_part = new_part
						movable_part.forceMove(new_computer)
						new_computer.component_parts += movable_part

					new_computer.RefreshParts()
					new_computer.on_construction(user)

				qdel(src)
				return
	if(user.combat_mode)
		return ..()

/obj/structure/frame/computer/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(state == 4)
			new /obj/item/shard(drop_location())
			new /obj/item/shard(drop_location())
		if(state >= 3)
			new /obj/item/stack/cable_coil(drop_location(), 5)
	..()
