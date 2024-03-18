/obj/structure/frame/computer
	name = "computer frame"
	icon_state = "0"
	state = 0

/obj/structure/frame/computer/attackby(obj/item/P, mob/user, params)
	add_fingerprint(user)
	switch(state)
		if(0)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start wrenching the frame into place...</span>")
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					setAnchored(TRUE)
					state = 1
				return
			if(P.tool_behaviour == TOOL_WELDER)
				if(!P.tool_start_check(user, amount=0))
					return

				to_chat(user, "<span class='notice'>You start deconstructing the frame...</span>")
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					new /obj/item/stack/sheet/iron(drop_location(), 5, TRUE, user)
					qdel(src)
				return
		if(1)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start to unfasten the frame...</span>")
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					setAnchored(FALSE)
					state = 0
				return
			if(istype(P, /obj/item/circuitboard/computer) && !circuit)
				if(!user.transferItemToLoc(P, src))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You place [P] inside the frame.</span>")
				icon_state = "1"
				circuit = P
				circuit.add_fingerprint(user)
				return

			else if(istype(P, /obj/item/circuitboard) && !circuit)
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return
			if(P.tool_behaviour == TOOL_SCREWDRIVER && circuit)
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You screw [circuit] into place.</span>")
				state = 2
				icon_state = "2"
				return
			if(P.tool_behaviour == TOOL_CROWBAR && circuit)
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You remove [circuit].</span>")
				state = 1
				icon_state = "0"
				circuit.forceMove(drop_location())
				circuit.add_fingerprint(user)
				circuit = null
				return
		if(2)
			if(P.tool_behaviour == TOOL_SCREWDRIVER && circuit)
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
				return
			if(istype(P, /obj/item/stack/cable_coil))
				if(!P.tool_start_check(user, amount=5))
					return
				to_chat(user, "<span class='notice'>You start adding cables to the frame...</span>")
				if(P.use_tool(src, user, 20, volume=50, amount=5))
					if(state != 2)
						return
					to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
					state = 3
					icon_state = "3"
				return
		if(3)
			if(P.tool_behaviour == TOOL_WIRECUTTER)
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 2
				icon_state = "2"
				new /obj/item/stack/cable_coil(drop_location(), 5, TRUE, user)
				return
			if(istype(P, /obj/item/stack/sheet/glass))
				if(!P.tool_start_check(user, amount=2))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You start to put in the glass panel...</span>")
				if(P.use_tool(src, user, 20, amount=2))
					if(state != 3)
						return
					to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
					state = 4
					src.icon_state = "4"
				return
		if(4)
			if(P.tool_behaviour == TOOL_CROWBAR)
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				icon_state = "3"
				new /obj/item/stack/sheet/glass(drop_location(), 2, TRUE, user)
				return
			if(P.tool_behaviour == TOOL_SCREWDRIVER)
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")

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
					new_computer.anchored = anchored
					new_computer.component_parts = list()

					circuit.forceMove(new_computer)
					new_computer.component_parts += circuit
					new_computer.circuit = circuit

					for(var/new_part in src)
						var/atom/movable/movable_part = new_part
						movable_part.forceMove(new_computer)
						new_computer.component_parts += movable_part

					new_computer.RefreshParts()
					new_computer.on_construction()

				qdel(src)
				return
	if(user.a_intent == INTENT_HARM)
		return ..()


/obj/structure/frame/computer/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(state == 4)
			new /obj/item/shard(drop_location())
			new /obj/item/shard(drop_location())
		if(state >= 3)
			new /obj/item/stack/cable_coil(drop_location(), 5)
	..()

/obj/structure/frame/computer/AltClick(mob/user)
	if(!isliving(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>You must unwrench [src] before rotating it!</span>")
		return

	setDir(turn(dir, -90))
