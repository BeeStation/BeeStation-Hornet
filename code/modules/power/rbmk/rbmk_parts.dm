/**
 * This file contain the eight parts surrounding the main core, those are: fuel input, moderator input, waste output, control rod computer and the corners
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
	desc = "A computer which can remotely raise / lower the control rods of a reactor."

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

/obj/machinery/atmospherics/components/unary/rbmk
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "reactor_off"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	layer = OBJ_LAYER
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	circuit = /obj/item/circuitboard/machine/thermomachine
	///Vars for the state of the icon of the object (open, off, active)
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	///Check if the machine has been activated
	var/active = FALSE


/obj/machinery/atmospherics/components/unary/rbmk/Initialize(mapload)
	. = ..()
	initialize_directions = dir


/obj/machinery/atmospherics/components/unary/rbmk/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(active)
		icon_state = icon_state_active
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
	icon_state = "coolant_input_off"
	icon_state_open = "coolant_input_open"
	icon_state_off = "coolant_input_off"
	icon_state_active = "coolant_input_active"
	circuit = /obj/item/circuitboard/machine/rbmk/RBMK_coolant_input

/obj/machinery/atmospherics/components/unary/rbmk/waste_output
	name = "RBMK waste output port"
	desc = "Waste port for the RBMK Fusion Reactor, designed to output the hot waste gases coming from the core of the machine."
	icon_state = "waste_output_off"
	icon_state_open = "waste_output_open"
	icon_state_off = "waste_output_off"
	icon_state_active = "waste_output_active"
	circuit = /obj/item/circuitboard/machine/rbmk/RBMK_waste_output

/obj/machinery/atmospherics/components/unary/rbmk/moderator_input
	name = "RBMK moderator input port"
	desc = "Moderator port for the RBMK Fusion Reactor, designed to move gases inside the machine to cool and control the flow of the reaction."
	icon_state = "moderator_input_off"
	icon_state_open = "moderator_input_open"
	icon_state_off = "moderator_input_off"
	icon_state_active = "moderator_input_active"
	circuit = /obj/item/circuitboard/machine/rbmk/RBMK_moderator_input

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
	density = FALSE //burns you if you're dumb enough to walk over it
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	power_channel = AREA_USAGE_ENVIRON
	var/active = FALSE
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	///Check if reaction has started
	var/reaction_started = FALSE

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

/obj/machinery/rbmk/corner
	name = "RBMK corner"
	desc = "Structural piece of the machine."
	icon_state = "corner_off"
	circuit = /obj/item/circuitboard/machine/rbmk/RBMK_corner
	icon_state_off = "corner_off"
	icon_state_open = "corner_open"
	icon_state_active = "corner_active"

/obj/item/book/manual/wiki/rbmk
	name = "\improper Haynes nuclear reactor owner's manual"
	icon_state ="bookEngineering2"
	author = "CogWerk Engineering Reactor Design Department"
	title = "Haynes nuclear reactor owner's manual"
	page_link = "Guide_to_the_Nuclear_Reactor"

/obj/item/RBMK_box
	name = "RBMK box"
	desc = "If you see this, call the police."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "error"
	///What kind of box are we handling?
	var/box_type = "impossible"
	///What's the path of the machine we making
	var/part_path

/obj/item/RBMK_box/corner
	name = "RBMK box corner"
	desc = "Place this as the corner of your 3x3 multiblock fusion reactor"
	icon_state = "box_corner"
	box_type = "corner"
	part_path = /obj/machinery/rbmk/corner

/obj/item/RBMK_box/body
	name = "RBMK box body"
	desc = "Place this on the sides of the core box of your 3x3 multiblock fusion reactor"
	box_type = "body"
	icon_state = "box_body"

/obj/item/RBMK_box/body/coolant_input
	name = "RBMK box coolant input"
	icon_state = "box_coolant"
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/coolant_input

/obj/item/RBMK_box/body/moderator_input
	name = "RBMK box moderator input"
	icon_state = "box_moderator"
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/moderator_input

/obj/item/RBMK_box/body/waste_output
	name = "RBMK box waste output"
	icon_state = "box_waste"
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/waste_output

/obj/item/RBMK_box/core
	name = "RBMK box core"
	desc = "Activate this with a multitool to deploy the full machine after setting up the other boxes"
	icon_state = "box_core"
	box_type = "core"
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/core

/obj/item/RBMK_box/core/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/list/parts = list()
	for(var/obj/item/RBMK_box/box in orange(1,src))
		var/direction = get_dir(src, box)
		if(box.box_type == "corner")
			if(ISDIAGONALDIR(direction))
				switch(direction)
					if(NORTHEAST)
						direction = EAST
					if(SOUTHEAST)
						direction = SOUTH
					if(SOUTHWEST)
						direction = WEST
					if(NORTHWEST)
						direction = NORTH
				box.dir = direction
				parts |= box
			continue
		if(box.box_type == "body")
			if(direction in GLOB.cardinals)
				box.dir = direction
				parts |= box
			continue
	if(parts.len == 8)
		build_reactor(parts)
	return

/obj/item/RBMK_box/core/proc/build_reactor(list/parts)
	for(var/obj/item/RBMK_box/box in parts)
		if(box.box_type == "corner")
			var/obj/machinery/rbmk/corner/corner = new box.part_path(box.loc)
			corner.dir = box.dir
			qdel(box)
			continue
		if(box.box_type == "body")
			qdel(box)
			continue

	new/obj/machinery/atmospherics/components/unary/rbmk/core(loc, TRUE)
	qdel(src)
