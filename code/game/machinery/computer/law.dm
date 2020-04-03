

/obj/machinery/computer/upload
	var/mob/living/silicon/current = null //The target of future law uploads
	icon_screen = "command"

/obj/machinery/computer/upload/Initialize()
	. = ..()
	AddComponent(/datum/component/gps, "Encrypted Upload")

/obj/machinery/computer/upload/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/aiModule))
		var/obj/item/aiModule/M = O
		if(stat & (NOPOWER|BROKEN|MAINT))
			return
		if(!current)
			to_chat(user, "<span class='caution'>You haven't selected anything to transmit laws to!</span>")
			return
		if(!can_upload_to(current))
			to_chat(user, "<span class='caution'>Upload failed!</span> Check to make sure [current.name] is functioning properly.")
			current = null
			return
		var/turf/currentloc = get_turf(current)
		if(currentloc && user.z != currentloc.z)
			to_chat(user, "<span class='caution'>Upload failed!</span> Unable to establish a connection to [current.name]. You're too far away!")
			current = null
			return
		if(isipc(current))
			add_ipc_laws(user,M,current)
			return
		M.install(current.laws, user)
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
		to_chat(user, "<span class='caution'>No active AIs detected!</span>")
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
		to_chat(user, "<span class='caution'>No active unslaved cyborgs detected!</span>")
	else
		to_chat(user, "[current.name] selected for law changes.")

/obj/machinery/computer/upload/borg/can_upload_to(mob/living/silicon/robot/B)
	if(!B || !iscyborg(B))
		return FALSE
	if(B.scrambledcodes || B.emagged)
		return FALSE
	return ..()


/obj/machinery/computer/upload/ipc
	name = "IPC upload console"
	desc = "Used to upload laws to IPCs."
	circuit = /obj/item/circuitboard/computer/ipcupload
	icon_keyboard = "syndie_key"

/obj/machinery/computer/upload/ipc/interact(mob/user)
	current = select_active_ipc(user)

	if(!current)
		to_chat(user, "<span class='caution'>No active IPCs detected!</span>")
	else
		to_chat(user, "[current.name] selected for law changes.")

/obj/machinery/computer/upload/ipc/can_upload_to(mob/living/carbon/human/H)
	if(!H || !isIPC(H))
		return FALSE
	if(H.stat == DEAD)
		return FALSE
	return TRUE

/obj/machinery/computer/upload/proc/add_ipc_laws(mob/user,obj/item/aiModule/lawboard,mob/living/carbon/human/target)
	if(!target.mind)
		to_chat(user, "<span class='warning'>[target] doesn't respond to the law upload, as if [target.p_they()] lacked a mind...</span>")
		return
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='warning'>The law upload is blocked by [target]'s mindshield!</span>")
		return
	if(!lawboard.bypass_law_amt_check && (!lawboard.laws.len || lawboard.laws[1] == ""))
		return
	var/list/laws = list()
	var/datum/antagonist/brainwashed/B = target.mind.has_antag_datum(/datum/antagonist/brainwashed)
	if(B)
		for(var/i in B.objectives)
			var/datum/objective/X = i
			laws += X.explanation_text
	else
		if(is_type_in_list(lawboard,list(/obj/item/aiModule/remove,/obj/item/aiModule/reset)))
			return
		if(!istype(lawboard,/obj/item/aiModule/core))
			laws += list("You may not injure a human being or, through inaction, allow a human being to come to harm.",\
					"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")
		var/area/a = get_area(src)
		target.say("; ERROR: Unauthorized law upload detected from [a.name]!!", forced = "law upload")
		target.dna.features["ipc_screen"] = "Red"
		target.eye_color = "#FFFFFF"
		target.update_body()

	if(is_type_in_list(lawboard,list(/obj/item/aiModule/zeroth,/obj/item/aiModule/syndicate)))
		laws = lawboard.laws + laws
	else if(istype(lawboard,/obj/item/aiModule/core))
		laws = lawboard.laws
	else if(istype(lawboard,/obj/item/aiModule/remove))
		var/obj/item/aiModule/remove/removeboard = lawboard
		laws -= laws[removeboard.lawpos]
	else if(istype(lawboard,/obj/item/aiModule/reset))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
		return
	else
		laws += lawboard.laws

	brainwash(target, laws, TRUE)
	to_chat(user, "<span class='notice'>Upload complete. [target.name]'s laws have been modified.</span>")
