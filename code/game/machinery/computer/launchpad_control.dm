/obj/machinery/computer/launchpad
	name = "launchpad control console"
	desc = "Used to teleport objects to and from a launchpad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/computer/launchpad_console



	var/selected_id
	var/list/obj/machinery/launchpad/launchpads
	var/maximum_pads = 4

/obj/machinery/computer/launchpad/Initialize(mapload)
	launchpads = list()
	. = ..()

/obj/machinery/computer/launchpad/attack_paw(mob/user)
	to_chat(user, "<span class='warning'>You are too primitive to use this computer!</span>")
	return

/obj/machinery/computer/launchpad/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/launchpad))
			if(LAZYLEN(launchpads) < maximum_pads)
				launchpads |= M.buffer
				RegisterSignal(M.buffer, COMSIG_PARENT_QDELETING, PROC_REF(launchpad_deleted))
				M.buffer = null
				ui_update()
				to_chat(user, "<span class='notice'>You upload the data from the [W.name]'s buffer.</span>")
			else
				to_chat(user, "<span class='warning'>[src] cannot handle any more connections!</span>")
	else
		return ..()

/obj/machinery/computer/launchpad/proc/launchpad_deleted(datum/source)
	SIGNAL_HANDLER
	var/source_id = launchpads.Find(source)
	if(source_id && selected_id)
		if(selected_id > source_id)
			selected_id--
		else if(selected_id == source_id)
			selected_id = null
	launchpads -= source
	ui_update()

/obj/machinery/computer/launchpad/proc/pad_exists(number)
	var/obj/machinery/launchpad/pad = launchpads[number]
	if(QDELETED(pad))
		return FALSE
	return TRUE

/obj/machinery/computer/launchpad/proc/teleport(mob/user, obj/machinery/launchpad/pad, sending)
	if(QDELETED(pad))
		to_chat(user, "<span class='warning'>ERROR: Launchpad not responding. Check launchpad integrity.</span>")
		return
	if(!pad.isAvailable())
		to_chat(user, "<span class='warning'>ERROR: Launchpad not operative. Make sure the launchpad is ready and powered.</span>")
		return
	pad.doteleport(user, sending)

/obj/machinery/computer/launchpad/proc/get_pad(number)
	var/obj/machinery/launchpad/pad = launchpads[number]
	return pad


/obj/machinery/computer/launchpad/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/launchpad/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LaunchpadConsole")
		ui.open()

/obj/machinery/computer/launchpad/ui_data(mob/user)
	var/list/data = list()
	var/list/pad_list = list()
	for(var/i in 1 to LAZYLEN(launchpads))
		if(pad_exists(i))
			var/obj/machinery/launchpad/pad = get_pad(i)
			var/list/this_pad = list()
			this_pad["name"] = pad.display_name
			this_pad["id"] = i
			if(pad.machine_stat & NOPOWER)
				this_pad["inactive"] = TRUE
			pad_list += list(this_pad)
		else
			launchpads -= get_pad(i)
	data["launchpads"] = pad_list
	data["selected_id"] = selected_id
	if(selected_id)
		var/obj/machinery/launchpad/current_pad = launchpads[selected_id]
		data["x"] = current_pad.x_offset
		data["y"] = current_pad.y_offset
		data["pad_name"] = current_pad.display_name
		data["range"] = current_pad.range
		data["selected_pad"] = current_pad
		if(QDELETED(current_pad) || (current_pad.machine_stat & NOPOWER))
			data["pad_active"] = FALSE
			return data
		data["pad_active"] = TRUE

	return data

/obj/machinery/computer/launchpad/ui_act(action, params)
	if(..())
		return
	var/obj/machinery/launchpad/current_pad = launchpads[selected_id]
	switch(action)
		if("select_pad")
			selected_id = text2num(params["id"])
			. = TRUE
		if("set_pos")
			var/new_x = text2num(params["x"])
			var/new_y = text2num(params["y"])
			current_pad.set_offset(new_x, new_y)
			. = TRUE
		if("move_pos")
			var/plus_x = text2num(params["x"])
			var/plus_y = text2num(params["y"])
			current_pad.set_offset(
				x = current_pad.x_offset + plus_x,
				y = current_pad.y_offset + plus_y
			)
			. = TRUE
		if("rename")
			var/new_name = params["name"]
			if(!new_name)
				return
			current_pad.display_name = new_name
			. = TRUE
		if("remove")
			if(usr && alert(usr, "Are you sure?", "Unlink Launchpad", "I'm Sure", "Abort") == "I'm Sure")
				launchpads -= current_pad
				selected_id = null
			. = TRUE
		if("launch")
			teleport(usr, current_pad, TRUE)
			. = TRUE

		if("pull")
			teleport(usr, current_pad, FALSE)
			. = TRUE
