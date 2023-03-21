/datum/computer_file/program/status
	filename = "statusdisplay"
	filedesc = "Status Display"
	program_icon = "signal"
	program_icon_state = "generic"
	requires_ntnet = TRUE
	size = 4

	extended_desc = "An app used to change the message on the station status displays."
	tgui_id = "NtosStatus"

	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE

	var/upper_text
	var/lower_text
	var/picture

/datum/computer_file/program/status/proc/SendSignal(type)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = type))
	switch(type)
		if("message")
			var/data1 = reject_bad_text(upper_text || "", MAX_STATUS_LINE_LENGTH)
			var/data2 = reject_bad_text(lower_text || "", MAX_STATUS_LINE_LENGTH)
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			message_admins("[ADMIN_LOOKUPFLW(usr)] changed the Status Message to - [data1], [data2] - From the Status Display app.")
			log_game("[key_name(usr)] changed the Status Message to - [data1], [data2] - From the Status Display app.")
		if("alert")
			status_signal.data["picture_state"] = picture

	frequency.post_signal(computer, status_signal)

/datum/computer_file/program/status/proc/SetText(position, text)
	switch(position)
		if("upper")
			upper_text = text
		if("lower")
			lower_text = text

/datum/computer_file/program/status/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("stat_send")
			SendSignal("message")
		if("stat_update")
			SetText(params["position"], params["text"])
		if("stat_pic")
			var/chosen_picture = params["picture"]
			if (!(chosen_picture in GLOB.approved_status_pictures))
				return
			picture = chosen_picture
			SendSignal("alert")

/datum/computer_file/program/status/ui_data(mob/user)
	var/list/data = list()

	data["upper"] = upper_text
	data["lower"] = lower_text

	return data
