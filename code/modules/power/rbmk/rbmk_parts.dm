/**
 * This file contain the five main parts of the RBMK, those are the: fuel input, moderator input, waste output, control rod computer and rbmk core
 */

/obj/machinery/computer/reactor
	name = "reactor control console"
	desc = "Scream"
	light_color = "#55BA55"
	light_power = 1
	light_range = 3
	icon_state = "oldcomp"
	icon_screen = "stock_computer"
	icon_keyboard = null
	var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor
	var/active = FALSE

/obj/machinery/computer/reactor/Initialize()
	. = ..()

/obj/machinery/computer/reactor/control_rods
	name = "control rod management computer"
	desc = "A computer which can remotely raise / lower the control rods of an RBMK class nuclear reactor."
	circuit = /obj/item/circuitboard/computer/control_rods

/obj/machinery/computer/reactor/control_rods/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/control_rods/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RbmkControlRods")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/reactor/control_rods/ui_act(action, params)
	if(..())
		return
	if(!reactor)
		return
	if(action == "input")
		var/input = text2num(params["target"])
		reactor.desired_k = clamp(input, 0, 3)

/obj/machinery/computer/reactor/control_rods/ui_data(mob/user)
	var/list/data = list()
	data["control_rods"] = 0
	data["k"] = 0
	data["desiredK"] = 0
	if(reactor)
		data["k"] = reactor.K
		data["desiredK"] = reactor.desired_k
		data["control_rods"] = 100 - (reactor.desired_k / 3 * 100) //Rod insertion is extrapolated as a function of the percentage of K
	return data

/obj/machinery/computer/reactor/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		var/datum/component/buffer/heldmultitool = get_held_buffer_item(usr)
		if(heldmultitool)
			var/obj/machinery/atmospherics/components/unary/rbmk/core/T = heldmultitool.target
			if(istype(T) && T != src)
				if(!(src in T.linked_interface))
					T.linked_interface += src
					T.ui_update()
					reactor = T
					to_chat(user, "<span class='notice'>You upload the link to the [src].</span>")


/obj/machinery/computer/reactor/proc/get_held_buffer_item(mob/user)
	// Let's double check
	var/obj/item/held_item = user.get_active_held_item()
	if(!issilicon(user) && held_item?.GetComponent(/datum/component/buffer))
		return held_item?.GetComponent(/datum/component/buffer)
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		return U.aiMulti.GetComponent(/datum/component/buffer)
	else if(iscyborg(user) && in_range(user, src))
		if(held_item?.GetComponent(/datum/component/buffer))
			return held_item?.GetComponent(/datum/component/buffer)
	return null

/obj/machinery/atmospherics/components/unary/rbmk
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "reactor_closed"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	layer = OBJ_LAYER
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	circuit = /obj/item/circuitboard/machine/thermomachine
	///Vars for the state of the icon of the object (open, off, active)
	var/icon_state_open
	var/icon_state_off
	///Check if the machine has been activated
	var/active = FALSE


/obj/machinery/atmospherics/components/unary/rbmk/Initialize(mapload)
	. = ..()
	initialize_directions = dir


/obj/machinery/atmospherics/components/unary/rbmk/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/atmospherics/components/unary/rbmk/update_overlays()
	. = ..()

/obj/machinery/atmospherics/components/unary/rbmk/update_layer()
	return

/obj/machinery/atmospherics/components/unary/rbmk/coolant_input
	name = "RBMK coolant input port"
	desc = "Input port for the RBMK Fusion Reactor, designed to take in coolant."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "coolant_input"

/obj/machinery/atmospherics/components/unary/rbmk/waste_output
	name = "RBMK waste output port"
	desc = "Waste port for the RBMK Fusion Reactor, designed to output the hot waste gases coming from the core of the machine."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "waste_output"

/obj/machinery/atmospherics/components/unary/rbmk/moderator_input
	name = "RBMK moderator input port"
	desc = "Moderator port for the RBMK Fusion Reactor, designed to move gases inside the machine to cool and control the flow of the reaction."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "moderator_input"

/*
* Interface and corners
*/
/obj/machinery/rbmk
	name = "rbmk_core"
	desc = "rbmk_core"
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "reactor_off"
	move_resist = INFINITY
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	power_channel = AREA_USAGE_ENVIRON
	var/active = FALSE
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	var/reaction_started = FALSE //Check if reaction has started

/obj/machinery/rbmk/attackby(obj/item/I, mob/user, params)
	if(!reaction_started)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/rbmk/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(active)
		icon_state = icon_state_active
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/item/book/manual/wiki/rbmk
	name = "\improper Haynes nuclear reactor owner's manual"
	icon_state ="bookEngineering2"
	author = "CogWerk Engineering Reactor Design Department"
	title = "Haynes nuclear reactor owner's manual"
	page_link = "Guide_to_the_Nuclear_Reactor"

/obj/item/RBMK_box
	name = "RBMK box"
	desc = "If you see this, call the police."
	icon = 'icons/obj/storage.dmi'
	icon_state = "box"
	var/box_type = "impossible" //	///What kind of box are we handling?
	var/part_path //What's the path of the machine we making?

/obj/item/RBMK_box/body
	name = "RBMK box body"
	desc = "A main storage body housing for your RBMK nuclear reactor."
	icon_state = "box" //Change later to actual sprite
	box_type = "normal"

/obj/item/RBMK_box/body/coolant_input
	name = "RBMK box coolant input"
	icon_state = "box"  //Change later to actual sprite
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/coolant_input
	box_type = "coolant_input"

/obj/item/RBMK_box/body/moderator_input
	name = "RBMK box moderator input"
	icon_state = "box"  //Change later to actual sprite
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/moderator_input
	box_type = "moderator_input"

/obj/item/RBMK_box/body/waste_output
	name = "RBMK box waste output"
	icon_state = "box"  //Change later to actual sprite
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/waste_output
	box_type = "waste_output"

/obj/item/RBMK_box/core
	name = "RBMK box core"
	desc = "A box for the center piece core of the RBMK nuclear reactor."
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/core
	box_type = "center"

/obj/item/RBMK_box/core/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/list/parts = list()
	var/types_seen = list()
	for(var/obj/item/RBMK_box/box in orange(1,src))

		var/direction = get_dir(src, box)
		box.dir = direction
		if(box.box_type in list("coolant_input", "waste_output", "moderator_input"))
			if(box.Adjacent(box, src))
				if(box.box_type in types_seen)
					return
				else
					parts |= box
					types_seen += box.box_type
		else
			parts |= box
	if(parts.len == 8)
		build_reactor(parts)
	return

/obj/item/RBMK_box/core/proc/build_reactor(list/parts)
	for(var/obj/item/RBMK_box/box in orange(1,src))
		if(box.box_type == "coolant_input")
			var/obj/machinery/atmospherics/components/unary/rbmk/coolant_input/coolant_input_machine = new/obj/machinery/atmospherics/components/unary/rbmk/coolant_input(box.loc, TRUE)
			coolant_input_machine.dir = box.dir
			coolant_input_machine.SetInitDirections()
			coolant_input_machine.build_network()
		else if(box.box_type == "moderator_input")
			var/obj/machinery/atmospherics/components/unary/rbmk/moderator_input/moderator_input_machine = new/obj/machinery/atmospherics/components/unary/rbmk/moderator_input(box.loc, TRUE)
			moderator_input_machine.dir = box.dir
			moderator_input_machine.SetInitDirections()
			moderator_input_machine.build_network()
		else if(box.box_type == "waste_output")
			var/obj/machinery/atmospherics/components/unary/rbmk/waste_output/waste_output_machine = new/obj/machinery/atmospherics/components/unary/rbmk/waste_output(box.loc, TRUE)
			waste_output_machine.dir = box.dir
			waste_output_machine.SetInitDirections()
			waste_output_machine.build_network()
	new/obj/machinery/atmospherics/components/unary/rbmk/core(loc, TRUE)
	for(var/obj/item/RBMK_box/box in parts)
		qdel(box)
	qdel(src)
