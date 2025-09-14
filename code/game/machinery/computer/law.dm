/obj/machinery/computer/upload
	var/mob/living/silicon/current = null //The target of future law uploads
	icon_screen = "command"

/obj/machinery/computer/upload/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Encrypted Upload")
	if(!mapload)
		log_game("A [name] was created at [AREACOORD(src)].")
		message_admins("A [name] was created at [ADMIN_VERBOSEJMP(src)].")
	GLOB.uploads_list += src

/obj/machinery/computer/upload/Destroy()
	GLOB.uploads_list -= src
	return ..()

/obj/machinery/computer/upload/examine(mob/user)
	. = ..()
	if(!current)
		. += "No silicon selected."
	else
		. += "Currently selected silicon: [current.name]."

/obj/machinery/computer/upload/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/ai_module))
		var/obj/item/ai_module/M = O
		if(machine_stat & (NOPOWER|BROKEN|MAINT))
			return
		if(!current)
			to_chat(user, span_warning("You haven't selected anything to transmit laws to!"))
			return
		var/input = tgui_input_text(user, "Please enter the Upload code.", "Uplode Code Check")
		if(!GLOB.upload_code)
			GLOB.upload_code = random_code(4)
		if(input != GLOB.upload_code)
			to_chat(user, span_warning("Upload failed! The code inputted was incorrect!"))
			return
		if(!can_upload_to(current))
			to_chat(user, span_warning("Upload failed! Check to make sure [current.name] is functioning properly."))
			current = null
			return
		var/turf/currentloc = get_turf(current)
		var/turf/user_turf = get_turf(user)
		if(currentloc && user.get_virtual_z_level() != currentloc.get_virtual_z_level() && (!is_station_level(currentloc.z) || !is_station_level(user_turf.z)))
			to_chat(user, span_warning("Upload failed! Unable to establish a connection to [current.name]. You're too far away!"))
			current = null
			return
		M.install(current.laws, user)
		if(alert("Do you wish to scramble the upload code?", "Scramble Code", "Yes", "No") != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has scrambled the upload code [GLOB.upload_code]!")
		GLOB.upload_code = random_code(4)
		to_chat(user, span_notice("You scramble the upload code"))
	else
		return ..()

/obj/machinery/computer/upload/proc/can_upload_to(mob/living/silicon/S)
	if(S.stat == DEAD)
		return FALSE
	return TRUE

/obj/machinery/computer/upload/ai
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	circuit = /obj/item/circuitboard/computer/aiupload

/obj/machinery/computer/upload/ai/interact(mob/user)
	current = select_active_ai(user)

	if (!current)
		to_chat(user, span_warning("No active AIs detected!"))
	else
		to_chat(user, "[current.name] selected for law changes.")

/obj/machinery/computer/upload/ai/can_upload_to(mob/living/silicon/ai/A)
	if(!A || !isAI(A))
		return FALSE
	if(A.control_disabled)
		return FALSE
	return ..()


/obj/machinery/computer/upload/borg
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	circuit = /obj/item/circuitboard/computer/borgupload

/obj/machinery/computer/upload/borg/interact(mob/user)
	current = select_active_free_borg(user)

	if(!current)
		to_chat(user, span_warning("No active unslaved cyborgs detected!"))
	else
		to_chat(user, "[current.name] selected for law changes.")

/obj/machinery/computer/upload/borg/can_upload_to(mob/living/silicon/robot/B)
	if(!B || !iscyborg(B))
		return FALSE
	if(B.scrambledcodes || B.emagged)
		return FALSE
	return ..()
