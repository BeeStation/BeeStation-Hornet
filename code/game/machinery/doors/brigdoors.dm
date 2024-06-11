/**
 * Brig Door control displays.
 *
 * This is a controls the timer for the brig doors, displays the timer on itself and
 * has a popup window when used, allowing to set the timer.
 */
/obj/machinery/status_display/door_timer
	name = "door timer"
	desc = "A remote control for a door."
	current_mode = SD_MESSAGE
	req_access = list(ACCESS_SECURITY)
	text_color = "#F44"
	header_text_color = "#F88"
	layer = ABOVE_WINDOW_LAYER
	var/id = null // id of linked machinery/lockers

	var/activation_time = 0
	var/timer_duration = 0

	var/timing = FALSE // boolean, true/1 timer is on, false/0 means it's not timing
	///List of weakrefs to nearby doors
	var/list/doors = list()
	///List of weakrefs to nearby flashers
	var/list/flashers = list()
	///List of weakrefs to nearby closets
	var/list/closets = list()
	///needed to send messages to sec radio
	var/obj/item/radio/sec_radio

/obj/machinery/status_display/door_timer/Initialize(mapload)
	. = ..()

	sec_radio = new/obj/item/radio(src)
	sec_radio.set_listening(FALSE)

	if(id != null)
		for(var/obj/machinery/door/window/brigdoor/M in urange(20, src))
			if (M.id == id)
				doors += WEAKREF(M)

		for(var/obj/machinery/flasher/F in urange(20, src))
			if(F.id == id)
				flashers += WEAKREF(F)

		for(var/obj/structure/closet/secure_closet/brig/C in urange(20, src))
			if(C.id == id)
				closets += WEAKREF(C)

	if(!length(doors) && !length(flashers) && length(closets))
		obj_break()

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/status_display/door_timer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	if(!timing)
		return PROCESS_KILL

	if(REALTIMEOFDAY - activation_time >= timer_duration)
		timer_end() // open doors, reset timer, clear status screen
	update_content()

/**
 * Update the display content.
 */
/obj/machinery/status_display/door_timer/proc/update_content()
	var/time_left = time_left(seconds = TRUE)

	if(time_left == 0)
		set_messages("", "")
		return

	var/disp1 = name
	var/disp2 = "[add_leading(num2text((time_left / 60) % 60), 2, "0")]:[add_leading(num2text(time_left % 60), 2, "0")]"
	set_messages(disp1, disp2)

/**
 * Starts counting down the timer and closes linked the door.
 * The timer is expected to have already been set by set_timer()
 */
/obj/machinery/status_display/door_timer/proc/timer_start()
	if(machine_stat & (NOPOWER|BROKEN))
		return 0

	activation_time = REALTIMEOFDAY
	timing = TRUE
	begin_processing()

	for(var/datum/weakref/door_ref as anything in doors)
		var/obj/machinery/door/window/brigdoor/door = door_ref.resolve()
		if(!door)
			doors -= door_ref
			continue
		if(door.density)
			continue
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/window/brigdoor, close))

	for(var/datum/weakref/closet_ref as anything in closets)
		var/obj/structure/closet/secure_closet/brig/closet = closet_ref.resolve()
		if(!closet)
			closets -= closet_ref
			continue
		if(closet.broken)
			continue
		if(closet.opened && !closet.close())
			continue
		closet.locked = TRUE
		closet.update_appearance()
	return 1

/**
 * Stops the timer and resets the timer to 0, and opens the linked door.
 * Arguments:
 * * forced - TRUE if it was forced to stop rather than timing out. Will skip radioing, etc.
 */
/obj/machinery/status_display/door_timer/proc/timer_end(forced = FALSE)
	if(machine_stat & (NOPOWER|BROKEN))
		return 0

	if(!forced)
		sec_radio.set_frequency(FREQ_SECURITY)
		sec_radio.talk_into(src, "Timer has expired. Releasing prisoner.", FREQ_SECURITY)

	timing = FALSE
	activation_time = null
	set_timer(0)
	end_processing()
	ui_update()

	for(var/datum/weakref/door_ref as anything in doors)
		var/obj/machinery/door/window/brigdoor/door = door_ref.resolve()
		if(!door)
			doors -= door_ref
			continue
		if(!door.density)
			continue
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/window/brigdoor, open))

	for(var/datum/weakref/closet_ref as anything in closets)
		var/obj/structure/closet/secure_closet/brig/closet = closet_ref.resolve()
		if(!closet)
			closets -= closet_ref
			continue
		if(closet.broken)
			continue
		if(closet.opened)
			continue
		closet.locked = FALSE
		closet.update_appearance()

	return 1

/**
 * Return time left.
 * Arguments:
 * * seconds - return time in seconds it TRUE, else deciseconds.
 */
/obj/machinery/status_display/door_timer/proc/time_left(seconds = FALSE)
	. = max(0, timer_duration - (activation_time ? REALTIMEOFDAY - activation_time : 0))
	if(seconds)
		. /= 10

/**
 * Set the timer. Does NOT automatically start counting down, but does update the display.
 *
 * returns TRUE if no change occurred
 *
 * Arguments:
 * value - time in deciseconds to set the timer for.
 */
/obj/machinery/status_display/door_timer/proc/set_timer(value)
	var/new_time = clamp(value, 0, CONFIG_GET(number/brig_timer_max) MINUTES)
	. = new_time == timer_duration //return 1 on no change
	timer_duration = new_time
	update_content()

/obj/machinery/status_display/door_timer/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(timing)
		. = TRUE // Autoupdate while timer is counting down

/obj/machinery/status_display/door_timer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BrigTimer", name)
		ui.open()

/obj/machinery/status_display/door_timer/ui_data()
	var/list/data = list()
	var/time_left = time_left(seconds = TRUE)
	data["seconds"] = round(time_left % 60)
	data["minutes"] = round((time_left - data["seconds"]) / 60)
	data["timing"] = timing
	data["flash_charging"] = FALSE
	for(var/datum/weakref/flash_ref as anything in flashers)
		var/obj/machinery/flasher/flasher = flash_ref.resolve()
		if(!flasher)
			flashers -= flash_ref
			continue
		if(flasher.last_flash && (flasher.last_flash + 15 SECONDS) > world.time)
			data["flash_charging"] = TRUE
			break
	return data

/obj/machinery/status_display/door_timer/ui_act(action, params)
	. = ..()
	if(.)
		return
	. = TRUE

	var/mob/user = usr

	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return FALSE

	switch(action)
		if("time")
			var/value = text2num(params["adjust"])
			if(value)
				. = !set_timer(time_left()+value)
				usr.investigate_log(" modified the timer by [value/10] seconds for cell [id], currently [time_left(seconds = TRUE)]", INVESTIGATE_RECORDS)
				user.log_message("modified the timer by [value/10] seconds for cell [id], currently [time_left(seconds = TRUE)]", LOG_ATTACK)
		if("start")
			timer_start()
			usr.investigate_log(" has started [id]'s timer of [time_left(seconds = TRUE)] seconds", INVESTIGATE_RECORDS)
			user.log_message("has started [id]'s timer of [time_left(seconds = TRUE)] seconds", LOG_ATTACK)
		if("stop")
			usr.investigate_log(" has stopped [id]'s timer of [time_left(seconds = TRUE)] seconds", INVESTIGATE_RECORDS)
			user.log_message("[key_name(usr)] has stopped [id]'s timer of [time_left(seconds = TRUE)] seconds", LOG_ATTACK)
			timer_end(forced = TRUE)
		if("flash")
			usr.investigate_log(" has flashed cell [id]", INVESTIGATE_RECORDS)
			user.log_message("[key_name(usr)] has flashed cell [id]", LOG_ATTACK)
			for(var/datum/weakref/flash_ref as anything in flashers)
				var/obj/machinery/flasher/flasher = flash_ref.resolve()
				if(!flasher)
					flashers -= flash_ref
					continue
				flasher.flash()
		if("preset")
			var/preset = params["preset"]
			var/preset_time = time_left()
			switch(preset)
				if("short")
					preset_time = CONFIG_GET(number/brig_timer_preset_short) MINUTES
				if("medium")
					preset_time = CONFIG_GET(number/brig_timer_preset_med) MINUTES
				if("long")
					preset_time = CONFIG_GET(number/brig_timer_preset_long) MINUTES
			. = !set_timer(preset_time)
			usr.investigate_log(" set cell [id]'s timer to [preset_time/10] seconds", INVESTIGATE_RECORDS)
			user.log_message("set cell [id]'s timer to [preset_time/10] seconds", LOG_ATTACK)
			if(timing)
				activation_time = REALTIMEOFDAY
		else
			. = FALSE
