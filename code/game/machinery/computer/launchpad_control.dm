/obj/machinery/computer/launchpad
	name = "launchpad control console"
	desc = "Used to teleport objects to and from a launchpad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/computer/launchpad_console

	/// If set, then the launchpad will automatically call itself back after this tiem.
	var/recall_time = 0

	var/selected_id
	var/list/obj/machinery/launchpad/launchpads
	var/maximum_pads = 4

/obj/machinery/computer/launchpad/attack_paw(mob/user)
	to_chat(user, span_warning("You are too primitive to use this computer!"))
	return

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/launchpad)

DEFINE_BUFFER_HANDLER(/obj/machinery/computer/launchpad)
	if(istype(buffer, /obj/machinery/launchpad))
		if(LAZYLEN(launchpads) < maximum_pads)
			launchpads |= buffer
			RegisterSignal(buffer, COMSIG_QDELETING, PROC_REF(launchpad_deleted))
			FLUSH_BUFFER(buffer_parent)
			ui_update()
			to_chat(user, span_notice("You upload the data from the [buffer_parent.name]'s buffer."))
		else
			to_chat(user, span_warning("[src] cannot handle any more connections!"))
		return COMPONENT_BUFFER_RECEIVED
	return NONE

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

/// Performs checks on whether or not the launch pad can be used.
/// Returns `null` if there are no errors, otherwise will return the error string.
/obj/machinery/computer/launchpad/proc/teleport_checks(obj/machinery/launchpad/pad)
	if(QDELETED(pad))
		return "ERROR: Launchpad not responding. Check launchpad integrity."
	if(!pad.is_available())
		return "ERROR: Launchpad not operative. Make sure the launchpad is ready and powered."
	if(pad.teleporting)
		return "ERROR: Launchpad busy."
	var/turf/pad_turf = get_turf(pad)
	if(pad_turf && is_centcom_level(pad_turf.z))
		return "ERROR: Launchpad not operative. Heavy area shielding makes teleporting impossible."
	for (var/obj/machinery/bluespace_anchor/anchor as() in GLOB.active_bluespace_anchors)
		//Not nearby
		if (anchor.get_virtual_z_level() != src.get_virtual_z_level() || get_dist(src, anchor) > anchor.range)
			continue
		//Check it
		if(!anchor.try_activate())
			continue
		playsound(anchor, 'sound/magic/repulse.ogg', 80, TRUE)
		//Anchored...
		return "ERROR: Launchpad unable to teleport. Shielding makes teleporting impossible."
	return null

/obj/machinery/computer/launchpad/proc/teleport(mob/user, obj/machinery/launchpad/pad, sending)
	if(QDELETED(pad))
		to_chat(user, span_warning("ERROR: Launchpad not responding. Check launchpad integrity."))
		return
	if(!pad.is_available())
		to_chat(user, span_warning("ERROR: Launchpad not operative. Make sure the launchpad is ready and powered.</span>"))
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
	data["recall_time"] = recall_time
	data["can_adjust_recall_time"] = TRUE
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
		if("set_recall")
			var/recall_timer = tgui_input_number(usr, "How long until the machine automatically recalls? (0 to disable)", "Recall time", 0, 300, 0)
			if (isnull(recall_timer) || recall_timer < 0 || recall_timer > 300)
				return FALSE
			recall_time = recall_timer
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
			if (recall_time)
				addtimer(CALLBACK(src, PROC_REF(teleport), usr, current_pad, FALSE), recall_time * 10)
			. = TRUE

		if("pull")
			teleport(usr, current_pad, FALSE)
			. = TRUE

/obj/machinery/computer/launchpad/Initialize(mapload)
	launchpads = list()
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/bluespace_launchpad,
	))

/obj/item/circuit_component/bluespace_launchpad
	display_name = "Bluespace Launchpad Console"
	desc = "Teleports anything to and from any location on the station. Doesn't use actual GPS coordinates, but rather offsets from the launchpad itself. Can only go as far as the launchpad can go, which depends on its parts."

	var/datum/port/input/launchpad_id
	var/datum/port/input/x_pos
	var/datum/port/input/y_pos
	var/datum/port/input/send_trigger
	var/datum/port/input/retrieve_trigger

	var/datum/port/output/sent
	var/datum/port/output/retrieved
	var/datum/port/output/on_fail
	var/datum/port/output/why_fail

	var/obj/machinery/computer/launchpad/attached_console

/obj/item/circuit_component/bluespace_launchpad/get_ui_notices()
	. = ..()
	var/current_launchpad = launchpad_id.value
	if(isnull(current_launchpad))
		return

	var/obj/machinery/launchpad/the_pad = attached_console.launchpads[current_launchpad]
	if(isnull(the_pad))
		return

	. += create_ui_notice("Minimum Range: [-the_pad.range]", "orange", "minus")
	. += create_ui_notice("Maximum Range: [the_pad.range]", "orange", "plus")

/obj/item/circuit_component/bluespace_launchpad/populate_ports()
	launchpad_id = add_input_port("Launchpad ID", PORT_TYPE_NUMBER, trigger = null, default = 1)
	x_pos = add_input_port("X offset", PORT_TYPE_NUMBER)
	y_pos = add_input_port("Y offset", PORT_TYPE_NUMBER)
	send_trigger = add_input_port("Send", PORT_TYPE_SIGNAL)
	retrieve_trigger = add_input_port("Retrieve", PORT_TYPE_SIGNAL)

	sent = add_output_port("Sent", PORT_TYPE_SIGNAL)
	retrieved = add_output_port("Retrieved", PORT_TYPE_SIGNAL)
	why_fail = add_output_port("Fail reason", PORT_TYPE_STRING)
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/bluespace_launchpad/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/computer/launchpad))
		attached_console = parent

/obj/item/circuit_component/bluespace_launchpad/unregister_usb_parent(atom/movable/parent)
	attached_console = null
	return ..()

/obj/item/circuit_component/bluespace_launchpad/input_received(datum/port/input/port)
	if(!attached_console || length(attached_console.launchpads) == 0)
		why_fail.set_output("No launchpads connected!")
		on_fail.set_output(COMPONENT_SIGNAL)
		return


	if(!launchpad_id.value)
		return

	var/obj/machinery/launchpad/the_pad = KEYBYINDEX(attached_console.launchpads, launchpad_id.value)
	if(isnull(the_pad))
		why_fail.set_output("Invalid launchpad selected!")
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	the_pad.set_offset(x_pos.value, y_pos.value)

	if(COMPONENT_TRIGGERED_BY(port, x_pos))
		x_pos.set_value(the_pad.x_offset)
		return

	if(COMPONENT_TRIGGERED_BY(port, y_pos))
		y_pos.set_value(the_pad.y_offset)
		return

	var/checks = attached_console.teleport_checks(the_pad)
	if(!isnull(checks))
		why_fail.set_output(checks)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	if(COMPONENT_TRIGGERED_BY(send_trigger, port))
		INVOKE_ASYNC(the_pad, TYPE_PROC_REF(/obj/machinery/launchpad, doteleport), null, TRUE, parent.get_creator())
		sent.set_output(COMPONENT_SIGNAL)

	if(COMPONENT_TRIGGERED_BY(retrieve_trigger, port))
		INVOKE_ASYNC(the_pad, TYPE_PROC_REF(/obj/machinery/launchpad, doteleport), null, FALSE, parent.get_creator())
		retrieved.set_output(COMPONENT_SIGNAL)
