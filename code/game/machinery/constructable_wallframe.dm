
/obj/item/wallframe/machine
	name = "unhooked wall-mounted machine frame"
	desc = "A frame for a wall-mounted machine."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "wall_0"
	materials = list(/datum/material/iron = 10000)
	w_class = WEIGHT_CLASS_BULKY
	result_path = /obj/structure/frame/machine/wall
	pixel_shift = -28

/obj/item/circuitboard/machine/wall
	

/obj/machinery/wall
	density = FALSE

/obj/machinery/wall/spawn_frame(disassembled)
	var/obj/structure/frame/machine/wall/M = new(loc)
	. = M
	M.dir = dir
	M.pixel_x = pixel_x
	M.pixel_y = pixel_y
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "[M.base_icon_state]_1"

/obj/structure/frame/machine/wall
	name = "wall-mounted machine frame"
	icon_state = "wall_0"
	base_icon_state = "wall"
	anchored = TRUE
	density = FALSE

/obj/structure/frame/machine/wall/accepts_circuit(obj/item/circuitboard/circuit)
	return istype(circuit, /obj/item/circuitboard/machine/wall)

//Wrench now only used to deconstruct
/obj/structure/frame/machine/wall/wrench_act(mob/living/user, obj/item/I)
	switch(state)
		if(1)
			user.visible_message("<span class='warning'>[user] disassembles the frame.</span>", \
								"<span class='notice'>You start to disassemble the frame...</span>", "You hear banging and clanking.")
			if(I.use_tool(src, user, 40, volume=50))
				to_chat(user, "<span class='notice'>You disassemble the frame.</span>")
				var/obj/item/wallframe/machine/M = new (loc)
				M.add_fingerprint(user)
				qdel(src)
			return TRUE

	return ..()

/obj/structure/frame/machine/wall/screwdriver_act(mob/living/user, obj/item/I)
	switch(state)
		if(1)
			//Screwdriver no longer used to deconstruct
			return
		if(3)
			var/component_check = 1
			for(var/R in req_components)
				if(req_components[R] > 0)
					component_check = 0
					break
			if(component_check)
				I.play_tool_sound(src)
				var/obj/machinery/new_machine = new circuit.build_path(loc)
				if(new_machine.circuit)
					QDEL_NULL(new_machine.circuit)
				new_machine.circuit = circuit
				new_machine.setAnchored(anchored)
				new_machine.dir = dir
				new_machine.pixel_x = pixel_x
				new_machine.pixel_y = pixel_y
				new_machine.on_construction()
				for(var/obj/O in new_machine.component_parts)
					qdel(O)
				new_machine.component_parts = list()
				for(var/obj/O in src)
					O.moveToNullspace()
					new_machine.component_parts += O
				circuit.moveToNullspace()
				new_machine.RefreshParts()
				qdel(src)
			return TRUE

	return ..()
