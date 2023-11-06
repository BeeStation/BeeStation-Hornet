/obj/machinery/computer/fake
	circuit = /obj/item/circuitboard/computer/fake

/obj/machinery/computer/fake/Initialize(mapload)
	. = ..()
	update_fake()

/obj/machinery/computer/fake/proc/update_fake()
	var/obj/item/circuitboard/computer/fake/circuit_board = circuit
	smoothing_flags = initial(circuit_board.fake_preset.smoothing_flags)
	if(!initial(circuit_board.fake_preset.smoothing_groups))
		smoothing_groups = null
	icon = initial(circuit_board.fake_preset.icon)
	icon_state = initial(circuit_board.fake_preset.icon_state)
	base_icon_state = initial(circuit_board.fake_preset.base_icon_state)
	icon_screen = initial(circuit_board.fake_preset.icon_screen)
	icon_keyboard = initial(circuit_board.fake_preset.icon_keyboard)
	if(circuit_board.fake_name)
		name = circuit_board.fake_name
	else
		name = initial(circuit_board.fake_preset.name)
	if(circuit_board.fake_desc)
		desc = circuit_board.fake_desc
	else
		desc = initial(circuit_board.fake_preset.desc)

	desc += " Oh, wait. It's just a screensaver."

	update_icon()

/obj/machinery/computer/fake/attackby(obj/item/I, mob/user, params)
	var/obj/item/circuitboard/computer/fake/circuit_board = circuit
	if(I.tool_behaviour == TOOL_MULTITOOL) // kinda QoL. Deconstruction is pain
		if(circuit_board.adjust_fake_info(user))
			update_fake()
			return
	..()

/obj/machinery/computer/fake/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	to_chat(user, "<span class='notice'>After you tab the screen a few times, you notice it's not functional.</span>")

/obj/machinery/computer/fake/attack_ai(mob/user)
	. = ..()
	if(.)
		return
	notify_silicon(user)

/obj/machinery/computer/fake/attack_robot(mob/user)
	. = ..()
	if(.)
		return
	notify_silicon(user)

/obj/machinery/computer/fake/proc/notify_silicon(mob/user)
	to_chat(user, "<span class='notice'>After you tab the screen a few times, you notice it's not functional.</span>")

/obj/item/circuitboard/computer/fake
	name = "DonkCo. Screenhonker"
	desc = "This computer circuit only serves a purpose of a screensaver. You can adjust it with a multitool."

	var/fake_name
	var/fake_desc
	var/obj/machinery/computer/fake_preset = /obj/machinery/computer/upload/ai // funny default

	var/static/list/available_list
	var/static/list/blacklist // not really blacklist. Some computers are a bit glitchy

	build_path = /obj/machinery/computer/fake

/obj/item/circuitboard/computer/fake/Initialize(mapload)
	. = ..()

	if(!blacklist)
		blacklist = typecacheof(list(
			/obj/machinery/computer/fake,
			/obj/machinery/computer/upload, // subtype whitelisted
			/obj/machinery/computer/arcade,
			/obj/machinery/computer/arcade/orion_trail/kobayashi,

		), only_root_path = TRUE)

	if(!available_list)
		available_list = list()
		for(var/obj/machinery/computer/each_computer as anything in subtypesof(/obj/machinery/computer))
			if(!initial(each_computer.name) \
				|| !initial(each_computer.desc) \
				|| !initial(each_computer.icon_screen) \
				|| is_type_in_typecache(each_computer, blacklist))
				continue
			var/actual_key = "[initial(each_computer.name)] ([each_computer])"
			available_list[actual_key] = each_computer

/obj/item/circuitboard/computer/fake/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		adjust_fake_info(user)
	. = ..()

/obj/item/circuitboard/computer/fake/proc/adjust_fake_info(mob/user)
	var/taken_action = input("Select options", "Multitool toying") as null|anything in list("Get a preset", "Change name", "Change desc", "Reset name and desc")
	if(!taken_action)
		return

	switch(taken_action)
		if("Get a preset")
			var/chosen_circuit = tgui_input_list(user, "Preset circuits", "Multitool toying", available_list)
			if(!chosen_circuit)
				return
			fake_preset = available_list[chosen_circuit]
			to_chat(user, "<span class='notice'>You have set the fake preset of the circuit as [chosen_circuit].</span>")
			return TRUE

		if("Change name")
			fake_name = stripped_input(user, "Fake name:", "Put a fake name", "", MAX_NAME_LEN)
			if(OOC_FILTER_CHECK(fake_name))
				to_chat(user, "<span class='warning'>Your input contains prohibited word(s)!</span>")
				return
			to_chat(user, "<span class='notice'>You have set the fake name of the circuit.</span>")
			return TRUE

		if("Change desc")
			fake_desc = stripped_input(user, "Fake desc:", "Put a fake description", "", MAX_MESSAGE_LEN)
			if(OOC_FILTER_CHECK(fake_desc))
				to_chat(user, "<span class='warning'>Your input contains prohibited word(s)!</span>")
				return
			to_chat(user, "<span class='notice'>You have set the fake description of the circuit.</span>")
			return TRUE

		if("Reset name and desc")
			fake_name = null
			fake_desc = null
			to_chat(user, "<span class='notice'>You have reset the fake name and description of the circuit.</span>")
			return TRUE
