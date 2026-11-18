/obj/machinery/computer/reactor_control_rods
	name = "control rod management computer"
	desc = "A computer which can remotely raise / lower the control rods of an RBMK class nuclear reactor."
	circuit = /obj/item/circuitboard/computer/control_rods
	icon_screen = "smmon_1"
	icon_keyboard = "tech_key"
	light_color = "#55BA55"
	light_power = 1
	light_range = 3

	var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor

/obj/machinery/computer/reactor_control_rods/Destroy()
	reactor = null
	return ..()

/obj/machinery/computer/reactor_control_rods/process()
	. = ..()
	if(reactor)
		var/last_status = reactor.desired_reate_of_reaction
		switch(last_status)
			if(0 to 0.5)
				icon_screen = "smmon_1"
			if(0.5 to 1)
				icon_screen = "smmon_2"
			if(1 to 1.5)
				icon_screen = "smmon_3"
			if(1.5 to 2)
				icon_screen = "smmon_4"
			if(2 to 2.5)
				icon_screen = "smmon_5"
			if(2.5 to 3)
				icon_screen = "smmon_6"
	else
		icon_screen = "smmon_1"
	update_overlays()
	update_appearance()

/obj/machinery/computer/reactor_control_rods/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RbmkControlRods")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/reactor_control_rods/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!reactor)
		return
	if(action == "input")
		var/input = text2num(params["target"])
		reactor.desired_reate_of_reaction = clamp(input, 0, 3)

/obj/machinery/computer/reactor_control_rods/ui_data(mob/user)
	var/list/data = list()
	if(reactor)
		data["k"] = reactor.rate_of_reaction
		data["desiredK"] = reactor.desired_reate_of_reaction
		data["control_rods"] = 100 - (reactor.desired_reate_of_reaction / 3 * 100) //Rod insertion is extrapolated as a function of the percentage of rate_of_reaction
	else
		data["control_rods"] = 0
		data["k"] = 0
		data["desiredK"] = 0
	return data

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/reactor_control_rods)

DEFINE_BUFFER_HANDLER(/obj/machinery/computer/reactor_control_rods)
	var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor_core = buffer
	if(!istype(reactor_core) || reactor_core.linked_interface == src)
		return NONE

	reactor_core.linked_interface = src
	reactor_core.ui_update()
	reactor = reactor_core
	to_chat(user, span_notice("You upload the link to the [src]."))
	return COMPONENT_BUFFER_RECEIVED

/obj/machinery/atmospherics/components/unary/rbmk
	abstract_type = /obj/machinery/atmospherics/components/unary/rbmk
	icon = 'icons/obj/machines/power/rbmk/rbmk_parts.dmi'
	layer = NUCLEAR_REACTOR_LAYER + 0.001
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	circuit = /obj/item/circuitboard/machine/thermomachine
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	circuit = /obj/item/circuitboard/machine/thermomachine
	showpipe = FALSE

/obj/machinery/atmospherics/components/unary/rbmk/update_layer()
	return

/obj/machinery/atmospherics/components/unary/rbmk/coolant_input
	name = "\improper RBMK coolant input port"
	desc = "Input port for the RBMK Fission Reactor, designed to take in coolant."
	icon_state = "input_pipe"

/obj/machinery/atmospherics/components/unary/rbmk/waste_output
	name = "RBMK waste output port"
	desc = "\improper Waste port for the RBMK Fission Reactor, designed to output the hot waste gases coming from the core of the machine."
	icon_state = "output_pipe"

/obj/machinery/atmospherics/components/unary/rbmk/moderator_input
	name = "RBMK moderator input port"
	desc = "\improper Moderator port for the RBMK Fission Reactor, designed to move gases inside the machine to cool and control the flow of the reaction."
	icon_state = "moderator_pipe"

/obj/item/book/manual/wiki/rbmk
	name = "\improper Hayne's nuclear reactor owner's manual"
	icon_state = "bookEngineering2"
	author = "CogWerk Engineering Reactor Design Department"
	title = "Haynes nuclear reactor owner's manual"
	page_link = "Guide_to_the_Nuclear_Reactor"

/obj/item/rbmk_box
	abstract_type = /obj/item/rbmk_box
	icon = 'icons/obj/machines/power/rbmk/rbmk_parts.dmi'
	item_flags = NO_PIXEL_RANDOM_DROP

	/// What's the path of the machine we making?
	var/part_path = null

/obj/item/rbmk_box/body
	name = "\improper RBMK box body"
	desc = "A main storage body housing for your RBMK nuclear reactor."
	icon_state = "wall"

/obj/item/rbmk_box/body/coolant_input
	name = "\improper RBMK box coolant input"
	icon_state = "input"
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/coolant_input

/obj/item/rbmk_box/body/moderator_input
	name = "\improper RBMK box moderator input"
	icon_state = "moderator"
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/moderator_input

/obj/item/rbmk_box/body/waste_output
	name = "\improper RBMK box waste output"
	icon_state = "output"
	part_path = /obj/machinery/atmospherics/components/unary/rbmk/waste_output

/obj/item/rbmk_box/core
	name = "\improper RBMK box core"
	icon_state = "core"
	desc = "A box for the center piece core of the RBMK nuclear reactor."
	part_path = null

/obj/item/rbmk_box/core/multitool_act(mob/living/user, obj/item/tool)
	var/list/parts = try_get_parts()
	if(length(parts) == 8)
		var/obj/machinery/atmospherics/components/unary/rbmk/core/new_core = build_reactor(parts)
		new_core.activate()
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/rbmk_box/core/proc/try_get_parts()
	var/list/parts = list()

	var/static/list/types_required
	if(!types_required)
		types_required = list()
		for(var/obj/item/rbmk_box/box_type as anything in subtypesof(/obj/item/rbmk_box))
			if(ispath(box_type::part_path, /obj/machinery/atmospherics/components/unary/rbmk))
				types_required += box_type::part_path

	var/list/types_seen = list()
	var/list/locations_used = list()
	for(var/obj/item/rbmk_box/nearby_box in orange(1, src))
		if(nearby_box.loc in locations_used)
			continue

		// ports must be in cardinal directions
		if((nearby_box.part_path in types_required) && (get_dir(nearby_box, src) in GLOB.cardinals))
			// no duplicate boxes please
			if(nearby_box.part_path in types_seen)
				continue
			types_seen += nearby_box.part_path

		parts += nearby_box
		locations_used += nearby_box.loc

	if(length(types_seen) == length(types_required))
		return parts

/obj/item/rbmk_box/core/proc/build_reactor(list/parts, list/user)
	for(var/obj/item/rbmk_box/box in parts)
		// the list will contain RBMK body parts, i.e: ones with no part_path set.
		if(ispath(box.part_path, /obj/machinery/atmospherics/components/unary/rbmk))
			var/obj/machinery/atmospherics/components/unary/rbmk/box_port = new box.part_path(box.loc)
			box_port.setDir(get_dir(src, box))
			box_port.set_init_directions()
			box_port.connect_nodes()
		qdel(box)

	var/obj/machinery/atmospherics/components/unary/rbmk/core/new_core = new(loc) // create object before qdel'ing ourselves
	qdel(src)
	return new_core

/obj/item/rbmk_box/core/pre_assemble_reactor

/obj/item/rbmk_box/core/pre_assemble_reactor/Initialize(mapload)
	. = ..()
	var/list/parts = try_get_parts()
	if(length(parts) == 8)
		var/obj/machinery/atmospherics/components/unary/rbmk/core/new_core = build_reactor(parts)
		new_core.activate()
