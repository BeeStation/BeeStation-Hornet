/obj/item/pai_card
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	/// If the pAIcard is slotted in a PDA
	var/slotted = FALSE
	/// Any pAI personalities inserted
	var/mob/living/silicon/pai/pai
	///what emotion icon we have. handled in /mob/living/silicon/pai/Topic()
	var/emotion_icon = "off"
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	custom_price = PAYCHECK_MEDIUM * 4

/obj/item/pai_card/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is staring sadly at [src]! [user.p_they()] can't keep living without real human intimacy!"))
	return OXYLOSS

/obj/item/pai_card/Initialize(mapload)
	. = ..()
	SSpai.pai_card_list += src
	update_appearance(UPDATE_OVERLAYS)

/obj/item/pai_card/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, emotion_icon))
		update_appearance(UPDATE_OVERLAYS)

/obj/item/pai_card/handle_atom_del(atom/A)
	if(A == pai) //double check /mob/living/silicon/pai/Destroy() if you change these.
		pai = null
		emotion_icon = initial(emotion_icon)
		update_appearance(UPDATE_OVERLAYS)
	add_overlay("pai-off")
	return ..()

/obj/item/pai_card/update_overlays()
	. = ..()
	. += "pai-[emotion_icon]"
	if(pai?.hacking_cable)
		. += "[initial(icon_state)]-connector"

/obj/item/pai_card/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	SSpai.pai_card_list -= src
	if(!QDELETED(pai))
		QDEL_NULL(pai)
	return ..()

/obj/item/pai_card/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(pai && !pai.holoform)
		pai.emp_act(severity)

/obj/item/pai_card/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	ui_interact(user)

/// Opens the TGUI window
/obj/item/pai_card/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiCard")
		ui.set_autoupdate(TRUE)
		ui.open()

/// Ensures the paicard is in hand
/obj/item/pai_card/ui_state(mob/user)
	return GLOB.paicard_state

/// Data sent to TGUI
/obj/item/pai_card/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["candidates"] = list()
	if(!pai)
		data["candidates"] = pool_candidates()
		data["pai"] = null
		return data
	data["pai"] = list()
	data["pai"]["can_holo"] = pai.can_holo
	data["pai"]["dna"] = pai.master_dna
	data["pai"]["emagged"] = pai.emagged
	data["pai"]["laws"] = pai.laws.supplied
	data["pai"]["master"] = pai.master_name
	data["pai"]["name"] = pai.name
	data["pai"]["transmit"] = pai.can_transmit
	data["pai"]["receive"] = pai.can_receive
	return data

/obj/item/pai_card/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE

	// Actions that don't require a pAI
	switch(action)
		if("download")
			download_candidate(usr, params["ckey"])
			return TRUE
		if("request")
			if(!pai)
				SSpai.find_pai(src, usr)
			return TRUE

	if(!pai)
		return FALSE

	// pAI specific actions.
	switch(action)
		if("fix_speech")
			pai.fix_speech()
			return TRUE
		if("set_dna")
			pai.set_dna(usr)
			return TRUE
		if("set_laws")
			pai.set_laws(usr)
			return TRUE
		if("toggle_holo")
			pai.toggle_holo()
			return TRUE
		if("toggle_radio")
			pai.toggle_radio(params["option"])
			return TRUE
		if("wipe_pai")
			pai.wipe_pai(usr)
			ui.close()
			return TRUE

/obj/item/pai_card/proc/set_personality(mob/living/silicon/pai/personality)
	pai = personality
	emotion_icon = "null"
	update_appearance(UPDATE_OVERLAYS)

	pai.modularInterface?.saved_identification = pai.name

	playsound(loc, 'sound/effects/pai_boot.ogg', 50, 1, -1)
	audible_message("\The [src] plays a cheerful startup noise!")


/obj/item/pai_card/proc/alertUpdate()
	var/mutable_appearance/alert_image = mutable_appearance(icon, icon_state = "pai-alert")
	flick_overlay_view(alert_image, 5 SECONDS)
	playsound(src, 'sound/machines/ping.ogg', 100)
	audible_message(span_info("[src] flashes a message across its screen, \"Additional personalities available for download.\""), span_notice("[src] vibrates with an alert."))

/**
 * Downloads a candidate from the list and removes them from SSpai.candidates
 *
 * @param {string} ckey The ckey of the candidate to download
 *
 * @returns {boolean} - TRUE if the candidate was downloaded, FALSE if not
 */
/obj/item/pai_card/proc/download_candidate(mob/user, ckey)
	if(pai)
		return
	var/datum/pai_candidate/candidate = SSpai.candidates[ckey]
	if(isnull(candidate))
		return
	if(SSpai.check_ready(candidate) != candidate)
		balloon_alert(user, "download interrupted")
		return
	var/mob/living/silicon/pai/new_pai = new(src)
	new_pai.name = candidate.name || pick(GLOB.ninja_names)
	new_pai.real_name = new_pai.name
	new_pai.ckey = candidate.ckey
	set_personality(new_pai)
	candidate.ready = FALSE
	SSpai.candidates[candidate.ckey] = candidate
	return TRUE

/**
 * Gathers a list of candidates to display in the download candidate
 * window. If the candidate isn't marked ready, ie they have not
 * pressed submit, they will be skipped over.
 *
 * @return - An array of candidate objects.
 */
/obj/item/pai_card/proc/pool_candidates()
	/// Array of pAI candidates
	var/list/candidates = SSpai.candidates
	var/list/ready_candidates = list()
	if(length(SSpai.candidates))
		for(var/key in candidates)
			var/datum/pai_candidate/checked_candidate = candidates[key]
			if(!SSpai.check_ready(checked_candidate))
				continue
			/// The object containing the candidate data.
			var/list/candidate = list()
			candidate["comments"] = checked_candidate.comments
			candidate["description"] = checked_candidate.description
			candidate["ckey"] = checked_candidate.ckey
			candidate["name"] = checked_candidate.name
			ready_candidates += list(candidate)
	return ready_candidates
