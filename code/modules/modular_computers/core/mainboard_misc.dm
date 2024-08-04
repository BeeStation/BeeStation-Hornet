/// Turn on the computer
/obj/item/mainboard/proc/turn_on(mob/user, open_ui = TRUE)
	if(enabled)
		if(open_ui)
			ui_interact(user)
		return TRUE
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	// if(obj_integrity <= integrity_failure * max_integrity)
	// 	if(issynth)
	// 		to_chat(user, "<span class='warning'>You send an activation signal to \the [src], but it responds with an error code. It must be damaged.</span>")
	// 	else
	// 		to_chat(user, "<span class='warning'>You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again.</span>")
	// 	return FALSE

	// If we have a recharger, enable it automatically. Lets computer without a battery work.
	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGE]
	if(recharger)
		recharger.enabled = 1

	if(isnull(all_components[MC_CPU]))
		if(issynth)
			to_chat(user, "<span class='warning'>You send an activation signal to \the [src], but nothing happens.</span>")
		else
			to_chat(user, "<span class='warning'>You press the power button, but nothing happens.</span>")

	if(all_components[MC_CPU] && use_power()) // use_power() checks if the PC is powered
		if(issynth)
			to_chat(user, "<span class='notice'>You send an activation signal to \the [src], turning it on.</span>")
		else
			to_chat(user, "<span class='notice'>You press the power button and start up \the [src].</span>")
		enabled = 1
		update_icon()
		if(open_ui)
			ui_interact(user)
		return TRUE
	else // Unpowered
		if(issynth)
			to_chat(user, "<span class='warning'>You send an activation signal to \the [src] but it does not respond.</span>")
		else
			to_chat(user, "<span class='warning'>You press the power button but \the [src] does not respond.</span>")
	return FALSE

/// A power-off event
/obj/item/mainboard/proc/shutdown_computer(loud = 1)
	kill_program(forced = TRUE)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(forced = TRUE)
		idle_threads.Remove(P)
	if(loud && !isnull(physical_holder))
		physical_holder.visible_message("<span class='notice'>\The [src] shuts down.</span>")
	enabled = 0
	update_icon()

/// Relays kill program request to currently active program. Use this to quit current program.
/obj/item/mainboard/proc/kill_program(forced = FALSE, update = TRUE)
	if(active_program)
		if(active_program in idle_threads)
			idle_threads.Remove(active_program)
		active_program.kill_program(forced)
		active_program = null
	if(update)
		var/mob/user = usr
		if(user && istype(user))
			ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.
		update_icon()

/// Return an Examine-friendly list of all the internal components
/obj/item/mainboard/proc/internal_parts_examine(mob/user)
	. = list()
	var/user_is_adjacent = Adjacent(user)

	var/obj/item/computer_hardware/goober/ai/ai_slot = all_components[MC_AI]
	if(istype(ai_slot))
		if(ai_slot.stored_card)
			if(user_is_adjacent)
				. += "It has an intelliCard slot which contains [ai_slot.stored_card.name]"
			else
				. += "It has an intelliCard slot, which appears to be occupied."
			. += "<span class='info'>Alt-click to eject the intelliCard.</span>"
		else
			. += "It has an open slot for an intelliCard."

	var/obj/item/computer_hardware/goober/pai/pai_slot = all_components[MC_PAI]
	if(istype(pai_slot))
		if(pai_slot.stored_card)
			if(user_is_adjacent)
				. += "It has an personal AI slot which contains [pai_slot.stored_card.name]"
			else
				. += "It has a personal AI slot, which appears to be occupied."
			. += "<span class='info'>Alt-click to eject the intelliCard.</span>"
		else
			. += "It has an open slot for an personal AI."

	// The first slot is the authentication slot for doors and such, the second is the slot where we insert an ID we want to modify
	var/obj/item/computer_hardware/id_slot/first_slot = all_components[MC_ID_AUTH]
	var/obj/item/computer_hardware/id_slot/second_slot = all_components[MC_ID_MODIFY]
	var/two_slots = istype(first_slot) && istype(second_slot)
	if(first_slot || second_slot)
		if(first_slot?.stored_card || second_slot.stored_card)
			var/obj/item/card/id/first_ID = first_slot?.stored_card
			var/obj/item/card/id/second_ID = second_slot?.stored_card
			var/two_cards = istype(first_ID) && istype(second_ID)
			if(user_is_adjacent)
				. += "It has [two_slots ? "two slots" : "a slot"] for identification cards installed[two_cards ? " which contain [first_ID] and [second_ID]" : ", one of which contains [first_ID ? first_ID : second_ID]"]."
			else
				. += "It has [two_slots ? "two slots" : "a slot"] for identification cards installed, [two_cards ? "both of which appear" : "and one of them appears"] to be occupied."
			. += "<span class='info'>Alt-click [src] to eject the identification card[two_cards ? "s":""].</span>"
		else
			. += "It has [two_slots ? "two slots" : "a slot"] installed for identification cards."

	var/obj/item/computer_hardware/printer/printer_slot = all_components[MC_PRINT]
	if(printer_slot)
		. += "It has a printer installed."
		if(user_is_adjacent)
			. += "The printer's paper levels are at: [printer_slot.stored_paper]/[printer_slot.max_paper].</span>"

/// Everything regarding opening a specific program
/obj/item/mainboard/proc/open_program(mob/user, datum/computer_file/program/program, in_background = FALSE)
	if(program.computer != src)
		CRASH("tried to open program that does not belong to this computer")

	if(!program || !istype(program)) // Program not found or it's not executable program.
		to_chat(user, "<span class='danger'>\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning.</span>")
		return FALSE

	if(!program.is_supported_by_hardware(get_hardware_type(), 1, user))
		return FALSE

	// The program is already running. Resume it.
	if(!in_background)
		if(program in idle_threads)
			program.program_state = PROGRAM_STATE_ACTIVE
			active_program = program
			program.alert_pending = FALSE
			idle_threads.Remove(program)
			update_icon()
			return TRUE
	else if(program in idle_threads)
		return TRUE
	var/obj/item/computer_hardware/processor_unit/PU = all_components[MC_CPU]
	if(idle_threads.len > PU.max_idle_programs)
		to_chat(user, "<span class='danger'>\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error.</span>")
		return FALSE

	if(program.requires_ntnet && !get_ntnet_status(program.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
		to_chat(user, "<span class='danger'>\The [src]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning.</span>")
		return FALSE

	if(!program.on_start(user))
		return FALSE

	if(!in_background)
		active_program = program
		program.alert_pending = FALSE
		ui_interact(user)
	else
		program.program_state = PROGRAM_STATE_BACKGROUND
		idle_threads.Add(program)
	update_icon()
	return TRUE

/obj/item/mainboard/proc/get_hardware_type()
	var/obj/item/modular_computer/item = physical_holder
	var/obj/machinery/modular_computer/machine = physical_holder
	return item?.hardware_flag || machine?.hardware_flag

/// Check if we can install this mainboard into the device.
/// Useful for when we install something, and then try to insert it into a tablet
/obj/item/mainboard/proc/can_install_mainboard(atom/movable/install_into, mob/user = null)
	var/obj/item/modular_computer/item = install_into
	var/obj/machinery/modular_computer/machine = install_into
	if(isnull(item) && isnull(machine))
		return FALSE

	for(var/obj/item/computer_hardware/comp in all_components)
		if(!comp.can_install_component(install_into, user))
			return FALSE

	return TRUE

// Network procs
/// Check the status of NTNet
/obj/item/mainboard/proc/get_ntnet_status(specific_action = 0)
	var/obj/item/computer_hardware/network_card/network_card = all_components[MC_NET]
	if(network_card)
		return network_card.get_signal(specific_action)
	else
		return 0

/// Send a network log to NTnet
/obj/item/mainboard/proc/send_ntnet_log(text)
	if(!get_ntnet_status())
		return FALSE
	var/obj/item/computer_hardware/network_card/network_card = all_components[MC_NET]
	return SSnetworks.add_log(text, network_card.GetComponent(/datum/component/ntnet_interface).network, network_card.hardware_id)

// id related
/obj/item/mainboard/proc/update_id_display()
	var/obj/item/computer_hardware/identifier/id = all_components[MC_IDENTIFY]
	if(id)
		id.UpdateDisplay()

/obj/item/mainboard/proc/on_id_insert()
	ui_update()
	var/obj/item/computer_hardware/id_slot/cardholder = all_components[MC_ID_AUTH]

	// handle autoimprinting if we can
	// We shouldn't auto-imprint if ID modification is open.
	if(isnull(cardholder) || !can_save_id || !cardholder.auto_imprint || istype(active_program, /datum/computer_file/program/card_mod))
		return
	if(cardholder.current_identification == cardholder.saved_identification && cardholder.current_job == cardholder.saved_job)
		return
	if(!cardholder.current_identification || !cardholder.current_job)
		return
	cardholder.saved_identification = cardholder.current_identification
	cardholder.saved_job = cardholder.current_job
	update_id_display()
	play_processing_sound()
	addtimer(CALLBACK(src, PROC_REF(play_success_sound)), 1.3 SECONDS)


// sound related

/**
  * Displays notification text alongside a soundbeep when requested to by a program.
  *
  * After checking that the requesting program is allowed to send an alert, creates
  * a visible message of the requested text alongside a soundbeep. This proc adds
  * text to indicate that the message is coming from this device and the program
  * on it, so the supplied text should be the exact message and ending punctuation.
  *
  * Arguments:
  * The program calling this proc.
  * The message that the program wishes to display.
 */

/obj/item/mainboard/proc/alert_call(datum/computer_file/program/caller, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return
	play_physical_sound(sound, 50, TRUE)
	visible_message("<span class='notice'>The [src] displays a [caller.filedesc] notification: [alerttext]</span>")
	var/mob/living/holder = physical_holder?.loc
	if(istype(holder))
		to_chat(holder, "[icon2html(src)] <span class='notice'>The [src] displays a [caller.filedesc] notification: [alerttext]</span>")

/// Use the bundled ringtone
/obj/item/mainboard/proc/ring(ringtone)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED)) // beeeeeeeepbeeeeeeeep
		play_physical_sound(pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
	else
		play_physical_sound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
	visible_message("*[ringtone]*")

/obj/item/mainboard/proc/play_processing_sound()
	play_physical_sound('sound/machines/terminal_processing.ogg', 15, TRUE)

/obj/item/mainboard/proc/play_success_sound()
	play_physical_sound('sound/machines/terminal_success.ogg', 15, TRUE)

/obj/item/mainboard/proc/play_error_sound()
	play_physical_sound('sound/machines/terminal_error.ogg', 15, TRUE)

/obj/item/mainboard/proc/play_select_sound()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		play_physical_sound(pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
	else
		play_physical_sound('sound/machines/terminal_select.ogg', 15, TRUE)

/obj/item/mainboard/proc/play_disk_sound()
	play_physical_sound('sound/machines/terminal_insert_disc.ogg', 50)

/obj/item/mainboard/proc/play_physical_sound(sound, vol, vary)
	var/obj/machinery/modular_computer/MC = physical_holder
	if(istype(MC))
		playsound(MC, sound, vol, vary)
