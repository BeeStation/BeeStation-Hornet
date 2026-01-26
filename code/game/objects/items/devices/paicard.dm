/obj/item/paicard
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

/obj/item/paicard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is staring sadly at [src]! [user.p_they()] can't keep living without real human intimacy!"))
	return OXYLOSS

/obj/item/paicard/Initialize(mapload)
	SSpai.pai_card_list += src
	. = ..()
	update_icon()

/obj/item/paicard/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, emotion_icon))
		update_icon()

/obj/item/paicard/handle_atom_del(atom/A)
	if(A == pai) //double check /mob/living/silicon/pai/Destroy() if you change these.
		pai = null
		emotion_icon = initial(emotion_icon)
		update_icon()
	add_overlay("pai-off")
	return ..()

/obj/item/paicard/update_overlays()
	. = ..()
	. += "pai-[emotion_icon]"
	if(pai?.hacking_cable)
		. += "[initial(icon_state)]-connector"

/obj/item/paicard/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	SSpai.pai_card_list -= src
	if(!QDELETED(pai))
		QDEL_NULL(pai)
	return ..()

/obj/item/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	ui_interact(user)

/// Opens the TGUI window
/obj/item/paicard/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiCard")
		ui.set_autoupdate(TRUE)
		ui.open()

/// Ensures the paicard is in hand
/obj/item/paicard/ui_state(mob/user)
	return GLOB.paicard_state

/// Data sent to TGUI
/obj/item/paicard/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["candidates"] = list()
	if(!pai)
		data["candidates"] = pool_candidates()
		data["pai"] = null
		return data
	data["pai"] = list()
	data["pai"]["can_holo"] = pai.canholo
	data["pai"]["dna"] = pai.master_dna
	data["pai"]["emagged"] = pai.emagged
	data["pai"]["laws"] = pai.laws.supplied
	data["pai"]["master"] = pai.master
	data["pai"]["name"] = pai.name
	data["pai"]["transmit"] = pai.can_transmit
	data["pai"]["receive"] = pai.can_receive
	return data

/obj/item/paicard/ui_act(action, list/params)
	. = ..()
	if(.)
		return FALSE
	switch(action)
		if("download")
			/// The individual candidate to download
			var/datum/pai_candidate/candidate = SSpai.candidates[params["ckey"]]
			if(isnull(candidate))
				return FALSE
			if(src.pai)
				return FALSE
			if(SSpai.check_ready(candidate) != candidate)
				return FALSE
			/// The newly downloaded pAI personality
			var/mob/living/silicon/pai/pai = new(src)
			pai.name = candidate.name || pick(GLOB.ninja_names)
			pai.real_name = pai.name
			pai.ckey = candidate.ckey
			src.setPersonality(pai)
			candidate.ready = FALSE
			SSpai.candidates[candidate.ckey] = candidate
		if("fix_speech")
			pai.fix_speech()
			return TRUE
		if("request")
			if(!pai)
				SSpai.findPAI(src, usr)
		if("set_dna")
			if(pai.master_dna)
				return
			if(!iscarbon(usr))
				balloon_alert(usr, "incompatible DNA signature")
				return FALSE
			var/mob/living/carbon/master = usr
			pai.master = master.real_name
			pai.master_dna = master.dna.unique_enzymes
			to_chat(src, span_bolddanger("You have been bound to a new master: [usr.real_name]!"))
			pai.laws.set_zeroth_law("Serve your master.")
			pai.holochassis_ready = TRUE
			return TRUE

		if("set_laws")
			var/newlaws = stripped_multiline_input(usr, "Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.laws.supplied[1])
			if(!in_range(src, usr))
				return FALSE
			if(newlaws && pai)
				pai.add_supplied_law(0,newlaws)
		if("toggle_holo")
			if(pai.canholo)
				to_chat(pai, span_warning("Your owner has disabled your holomatrix projectors!"))
				pai.canholo = FALSE
				to_chat(usr, span_notice("You disable your pAI's holomatrix!"))
			else
				to_chat(pai, span_notice("Your owner has enabled your holomatrix projectors!"))
				pai.canholo = TRUE
				to_chat(usr, span_notice("You enable your pAI's holomatrix!"))

		if("toggle_radio")
			var/transmitting = params["option"] == "transmit" //it can't be both so if we know it's not transmitting it must be receiving.
			var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
			if(transmitting)
				pai.can_transmit = !pai.can_transmit
			else //receiving
				pai.can_receive = !pai.can_receive
			pai.radio.wires.cut(transmit_holder, usr)//wires.cut toggles cut and uncut states
			transmit_holder = (transmitting ? pai.can_transmit : pai.can_receive) //recycling can be fun!
			to_chat(usr, span_notice("You [transmit_holder ? "enable" : "disable"] your pAI's [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
			to_chat(pai, span_notice("Your owner has [transmit_holder ? "enabled" : "disabled"] your [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
		if("wipe_pai")
			var/confirm = alert(usr, "Are you certain you wish to delete the current personality? This action cannot be undone.", "Personality Wipe", "Yes", "No")
			if(confirm == "Yes")
				if(pai)
					to_chat(pai, span_warning("You feel yourself slipping away from reality."))
					to_chat(pai, span_danger("Byte by byte you lose your sense of self."))
					to_chat(pai, span_userdanger("Your mental faculties leave you."))
					to_chat(pai, span_rose("oblivion... "))
					pai.death()
	return TRUE

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	pai = personality
	emotion_icon = "null"
	update_icon()

	pai.modularInterface?.saved_identification = pai.name

	playsound(loc, 'sound/effects/pai_boot.ogg', 50, 1, -1)
	audible_message("\The [src] plays a cheerful startup noise!")


/obj/item/paicard/proc/alertUpdate()
	var/mutable_appearance/alert_image = mutable_appearance(icon, icon_state = "pai-alert")
	flick_overlay_view(alert_image, 5 SECONDS)
	playsound(src, 'sound/machines/ping.ogg', 100)
	audible_message(span_info("[src] flashes a message across its screen, \"Additional personalities available for download.\""), span_notice("[src] vibrates with an alert."))

/obj/item/paicard/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(pai && !pai.holoform)
		pai.emp_act(severity)

/**
 * Gathers a list of candidates to display in the download candidate
 * window. If the candidate isn't marked ready, ie they have not
 * pressed submit, they will be skipped over.
 *
 * @return - An array of candidate objects.
 */
/obj/item/paicard/proc/pool_candidates()
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
