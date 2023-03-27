/datum/computer_file/program/signaller
	filename = "signaller"
	filedesc = "Remote Signaller"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "signal"
	extended_desc = "A small built-in frequency app that sends out signaller signals with the appropriate hardware."
	size = 2
	tgui_id = "NtosSignaller"
	program_icon = "satellite-dish"
	usage_flags = PROGRAM_TABLET | PROGRAM_LAPTOP
	///What is the saved signal frequency?
	var/signal_frequency = FREQ_SIGNALER
	/// What is the saved signal code?
	var/signal_code = DEFAULT_SIGNALER_CODE
	/// Radio connection datum used by signallers.
	var/datum/radio_frequency/radio_connection

/datum/computer_file/program/signaller/on_start(mob/living/user)
	. = ..()
	if (!.)
		return
	set_frequency(signal_frequency)
	if(!computer?.get_modular_computer_part(MC_SIGNALLER)) //Giving a clue to users why the program is spitting out zeros.
		to_chat(user, "<span class='warning'>\The [computer] flashes an error: \"hardware\\signal_hardware\\startup.bin -- file not found\".</span>")

/datum/computer_file/program/signaller/kill_program(forced)
	. = ..()
	SSradio.remove_object(computer, signal_frequency)

/datum/computer_file/program/signaller/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/computer_hardware/radio_card/sensor = computer?.get_modular_computer_part(MC_SIGNALLER)
	if(sensor?.check_functionality())
		data["frequency"] = signal_frequency
		data["code"] = signal_code
		data["minFrequency"] = MIN_FREE_FREQ
		data["maxFrequency"] = MAX_FREE_FREQ
	data["connection"] = !!radio_connection
	return data

/datum/computer_file/program/signaller/ui_act(action, list/params)
	if(..())
		return TRUE
	var/obj/item/computer_hardware/radio_card/sensor = computer?.get_modular_computer_part(MC_SIGNALLER)
	if(!(sensor?.check_functionality()))
		playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
		return
	switch(action)
		if("signal")
			INVOKE_ASYNC(src, PROC_REF(signal))
			. = TRUE
		if("freq")
			var/new_signal_frequency = sanitize_frequency(unformat_frequency(params["freq"]), TRUE)
			set_frequency(new_signal_frequency)
			. = TRUE
		if("code")
			signal_code = text2num(params["code"])
			signal_code = round(signal_code)
			. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				signal_frequency = initial(signal_frequency)
			else
				signal_code = initial(signal_code)
			. = TRUE

/datum/computer_file/program/signaller/proc/signal()
	if(!radio_connection)
		playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
		return

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(computer)
	if(usr)
		GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> with frequency: [format_frequency(signal_frequency)]/[signal_code]")
		log_telecomms("[time] <B>:</B> [usr.key] used [src] @ location [AREACOORD(T)] <B>:</B> with frequency: [format_frequency(signal_frequency)]/[signal_code]")
		message_admins("<B>:</B> [usr.key] used [src] @ location [AREACOORD(T)] <B>:</B> with frequency: [format_frequency(signal_frequency)]/[signal_code]")

	var/datum/signal/signal = new(list("code" = signal_code))
	radio_connection.post_signal(src, signal)

/datum/computer_file/program/signaller/proc/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != signal_code)
		return
	var/obj/item/computer_hardware/radio_card/sensor = computer?.get_modular_computer_part(MC_SIGNALLER)
	if(!(sensor?.check_functionality()))
		return
	computer.audible_message("[icon2html(computer, hearers(computer))] *beep* *beep* *beep*", null, 1)
	playsound(get_turf(computer), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE

/datum/computer_file/program/signaller/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, signal_frequency)
	signal_frequency = new_frequency
	radio_connection = SSradio.add_object(src, signal_frequency, RADIO_SIGNALER)
	return
