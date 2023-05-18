// /program/ files are executable programs that do things.
/datum/computer_file/program
	filetype = "PRG"
	filename = "UnknownProgram"				// File name. FILE NAME MUST BE UNIQUE IF YOU WANT THE PROGRAM TO BE DOWNLOADABLE FROM NTNET!
	/// List of required accesses to *run* the program.
	var/list/required_access = list()
	/// List of required access to download or file host the program
	var/list/transfer_access = list()
	var/program_state = PROGRAM_STATE_KILLED// PROGRAM_STATE_KILLED or PROGRAM_STATE_BACKGROUND or PROGRAM_STATE_ACTIVE - specifies whether this program is running.
	var/obj/item/modular_computer/computer	// Device that runs this program.
	var/filedesc = "Unknown Program"		// User-friendly name of this program.
	/// Category in the NTDownloader.
	var/category = PROGRAM_CATEGORY_MISC
	var/extended_desc = "N/A"				// Short description of this program's function.
	var/program_icon_state = null			// Program-specific screen icon state
	var/requires_ntnet = 0					// Set to 1 for program to require nonstop NTNet connection to run. If NTNet connection is lost program crashes.
	var/requires_ntnet_feature = 0			// Optional, if above is set to 1 checks for specific function of NTNet (currently NTNET_SOFTWAREDOWNLOAD, NTNET_PEERTOPEER, NTNET_SYSTEMCONTROL and NTNET_COMMUNICATION)
	var/ntnet_status = 1					// NTNet status, updated every tick by computer running this program. Don't use this for checks if NTNet works, computers do that. Use this for calculations, etc.
	var/usage_flags = PROGRAM_ALL			// Bitflags (PROGRAM_CONSOLE, PROGRAM_LAPTOP, PROGRAM_TABLET combination) or PROGRAM_ALL
	var/network_destination = null			// Optional string that describes what NTNet server/system this program connects to. Used in default logging.
	var/available_on_ntnet = 1				// Whether the program can be downloaded from NTNet. Set to 0 to disable.
	var/available_on_syndinet = 0			// Whether the program can be downloaded from SyndiNet (accessible via emagging the computer). Set to 1 to enable.
	var/tgui_id								// ID of TGUI interface
	var/ui_style							// ID of custom TGUI style (optional)
	var/ui_header = null					// Example: "something.gif" - a header image that will be rendered in computer's UI when this program is running at background. Images are taken from /icons/program_icons. Be careful not to use too large images!
	/// Font Awesome icon to use as this program's icon in the modular computer main menu. Defaults to a basic program maximize window icon if not overridden.
	var/program_icon = "window-maximize-o"
	/// Whether this program can send alerts while minimized or closed. Used to show a mute button per program in the file manager
	var/alert_able = FALSE
	/// Whether the user has muted this program's ability to send alerts.
	var/alert_silenced = FALSE
	/// Whether to highlight our program in the main screen. Intended for alerts, but loosely available for any need to notify of changed conditions. Think Windows task bar highlighting. Available even if alerts are muted.
	var/alert_pending = FALSE
	/// If this program should process attack calls
	var/use_attack = FALSE
	/// If this program should process attack_obj calls
	var/use_attack_obj = FALSE

/datum/computer_file/program/New(obj/item/modular_computer/comp = null)
	..()
	if(istype(comp))
		computer = comp
	else if(istype(holder?.holder, /obj/item/modular_computer))
		computer = holder.holder

/datum/computer_file/program/Destroy()
	computer = null
	. = ..()

/datum/computer_file/program/clone()
	var/datum/computer_file/program/temp = ..()
	temp.required_access = required_access
	temp.filedesc = filedesc
	temp.program_icon_state = program_icon_state
	temp.requires_ntnet = requires_ntnet
	temp.requires_ntnet_feature = requires_ntnet_feature
	temp.usage_flags = usage_flags
	return temp

// Relays icon update to the computer.
/datum/computer_file/program/proc/update_computer_icon()
	if(computer)
		computer.update_icon()

// Attempts to create a log in global ntnet datum. Returns 1 on success, 0 on fail.
/datum/computer_file/program/proc/generate_network_log(text)
	if(computer)
		return computer.add_log(text)
	return 0

/datum/computer_file/program/proc/is_supported_by_hardware(hardware_flag = 0, loud = 0, mob/user = null)
	if(!(hardware_flag & usage_flags))
		if(loud && computer && user)
			to_chat(user, "<span class='danger'>\The [computer] flashes an \"Hardware Error - Incompatible software\" warning.</span>")
		return 0
	return 1

/datum/computer_file/program/proc/get_signal(specific_action = 0)
	if(computer)
		return computer.get_ntnet_status(specific_action)
	return 0

// Called by Process() on device that runs us, once every tick.
/datum/computer_file/program/proc/process_tick(delta_time)
	return 1

/**
  *Check if the user can run program. Only humans and silicons can operate computer. Automatically called in on_start()
  *ID must be inserted into a card slot to be read. If the program is not currently installed (as is the case when
  *NT Software Hub is checking available software), a list can be given to be used instead.
  *Arguments:
  *user is a ref of the mob using the device.
  *loud is a bool deciding if this proc should use to_chats
  *access_to_check is an access level that will be checked against the ID
  *transfer, if TRUE and access_to_check is null, will tell this proc to use the program's transfer_access in place of access_to_check
  *access can contain a list of access numbers to check against. If access is not empty, it will be used istead of checking any inserted ID.
*/
/datum/computer_file/program/proc/can_run(mob/user, loud = FALSE, access_to_check, transfer = FALSE, var/list/access)
	if(issilicon(user))
		return TRUE

	if(IsAdminGhost(user))
		return TRUE

	if(!transfer && computer && (computer.obj_flags & EMAGGED))	//emags can bypass the execution locks but not the download ones.
		return TRUE

	// Defaults to required_access
	if(!access_to_check)
		if(transfer && transfer_access)
			access_to_check = transfer_access
		else
			access_to_check = required_access
	if(!islist(access_to_check))
		access_to_check = list(access_to_check)
	if(!length(access_to_check)) // No required_access, allow it.
		return TRUE

	if(!length(access))
		var/obj/item/card/id/access_card
		var/obj/item/computer_hardware/card_slot/card_slot
		if(computer)
			card_slot = computer.all_components[MC_CARD]
			access_card = card_slot?.GetID()

		if(!access_card)
			if(loud)
				to_chat(user, "<span class='danger'>\The [computer] flashes an \"RFID Error - Unable to scan ID\" warning.</span>")
			return FALSE
		access = access_card.GetAccess()

	for(var/singular_access in access_to_check)
		if(check_access_textified(access, singular_access))//For loop checks every individual access entry in the access list. If the user's ID has access to any entry, then we're good.
			return TRUE
	if(loud)
		to_chat(user, "<span class='danger'>\The [computer] flashes an \"Access Denied\" warning.</span>")
	return FALSE

/**
 * Called on program startup.
 *
 * May be overridden to add extra logic. Remember to include ..() call. Return 1 on success, 0 on failure.
 * When implementing new program based device, use this to run the program.
 * Arguments:
 * * user - The mob that started the program
 **/
/datum/computer_file/program/proc/on_start(mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	if(can_run(user, 1))
		if(requires_ntnet && network_destination)
			generate_network_log("Connection opened to [network_destination].")
		program_state = PROGRAM_STATE_ACTIVE
		return TRUE
	return FALSE

/**
  *
  *Called by the device when it is emagged.
  *
  *Emagging the device allows certain programs to unlock new functions. However, the program will
  *need to be downloaded first, and then handle the unlock on their own in their run_emag() proc.
  *The device will allow an emag to be run multiple times, so the user can re-emag to run the
  *override again, should they download something new. The run_emag() proc should return TRUE if
  *the emagging affected anything, and FALSE if no change was made (already emagged, or has no
  *emag functions).
**/
/datum/computer_file/program/proc/run_emag()
	return FALSE

/**
 * Kills the running program
 *
 * Use this proc to kill the program. Designed to be implemented by each program if it requires on-quit logic, such as the NTNRC client.
 * Arguments:
 * * forced - Boolean to determine if this was a forced close. Should be TRUE if the user did not willingly close the program.
 **/
/datum/computer_file/program/proc/kill_program(forced = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	program_state = PROGRAM_STATE_KILLED
	if(network_destination)
		generate_network_log("Connection to [network_destination] closed.")
	return 1

/// Return TRUE if nothing was processed. Return FALSE to prevent further actions running.
/// Set use_attack = TRUE to receive proccalls from the parent computer.
/datum/computer_file/program/proc/attack(atom/target, mob/living/user, params)
	return TRUE

/// Return TRUE if nothing was processed. Return FALSE to prevent further actions running.
/// Set use_attack_obj = TRUE to receive proccalls from the parent computer.
/datum/computer_file/program/proc/attack_obj(obj/target, mob/living/user)
	return TRUE

/// Called when the datum/tgui is initialized by the computer
/datum/computer_file/program/proc/on_ui_create(mob/user, datum/tgui/ui)
	return

/// Called when ui_close is called on the computer while this program is active. Any behavior in this should also be in kill_program.
/datum/computer_file/program/proc/on_ui_close(mob/user, datum/tgui/tgui)
	return
