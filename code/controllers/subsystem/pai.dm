SUBSYSTEM_DEF(pai)
	name = "pAI"

	flags = SS_NO_INIT|SS_NO_FIRE

	/// List of pAI candidates, including those not submitted.
	var/list/candidates = list()
	/// Prevents a crew member from hitting "request pAI"
	var/request_spam = list()
	/// Prevents a pAI from submitting itself repeatedly and sounding an alert.
	var/submit_spam = list()
	/// All pAI cards on the map.
	var/list/pai_card_list = list()


/**
 * Pings ghosts to announce that someone is requesting a pAI
 *
 * Arguments
 * @pai - The card requesting assistance
 * @user - The player requesting a pAI
*/
/datum/controller/subsystem/pai/proc/findPAI(obj/item/paicard/pai, mob/user)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, span_warning("Due to growing incidents of SELF corrupted independent artificial intelligences, freeform personality devices have been temporarily banned in this sector."))
		return
	if(request_spam[user.ckey])
		to_chat(user, span_warning("Request sent too recently."))
		return
	request_spam[user.ckey] = TRUE
	playsound(src, 'sound/machines/ping.ogg', 20, TRUE)
	to_chat(user, span_notice("You have requested pAI assistance."))
	var/mutable_appearance/alert_overlay = mutable_appearance('icons/obj/aicards.dmi', "pai")
	notify_ghosts("[user] is requesting a pAI personality! Use the pAI button to submit yourself as one.", source=user, alert_overlay = alert_overlay, action=NOTIFY_ORBIT, header="pAI Request!", ignore_key = POLL_IGNORE_PAI)
	addtimer(VARSET_LIST_CALLBACK(request_spam, user.ckey, FALSE), 10 SECONDS)
	return TRUE

/**
 * This is the primary window proc when the pAI candidate
 * hud menu is pressed by observers.
 *
 * Arguments
 * @user - The ghost doing the pressing.
 */
/datum/controller/subsystem/pai/proc/recruitWindow(mob/user)
	/// Searches for a previous candidate upon opening the menu
	var/datum/pai_candidate/candidate = candidates[user.ckey]
	if(isnull(candidate))
		candidate = new /datum/pai_candidate()
		candidate.ckey = user.ckey
		candidates[user.ckey] = candidate
	ui_interact(user)

/datum/controller/subsystem/pai/ui_state(mob/user)
	return GLOB.observer_state

/datum/controller/subsystem/pai/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiSubmit")
		ui.open()

/datum/controller/subsystem/pai/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	/// The matching candidate from search
	var/datum/pai_candidate/candidate = candidates[user.ckey]
	if(isnull(candidate))
		return data
	data["comments"] = candidate.comments
	data["description"] = candidate.description
	data["name"] = candidate.name
	data["ready"] = check_ready(candidate)
	var/datum/pai_candidate/default_candidate = new
	default_candidate.load(user)
	data["default_name"] = default_candidate.name
	data["default_description"] = default_candidate.description
	data["default_comments"] = default_candidate.comments
	default_candidate = null
	return data

/datum/controller/subsystem/pai/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	/// The matching candidate from search
	var/datum/pai_candidate/candidate = candidates[usr.ckey]
	if(is_banned_from(usr.ckey, ROLE_PAI))
		to_chat(usr, span_warning("You are banned from playing pAI!"))
		ui.close()
		return FALSE
	if(isnull(candidate))
		to_chat(usr, span_warning("There was an error. Please resubmit."))
		ui.close()
		return FALSE
	if(CHAT_FILTER_CHECK(params["candidate"]["comments"]))
		to_chat(usr, span_warning("Your OOC comment contains prohibited word(s)!"))
		return FALSE
	if(CHAT_FILTER_CHECK(params["candidate"]["description"]))
		to_chat(usr, span_warning("Your description contains prohibited word(s)!"))
		return FALSE
	if(CHAT_FILTER_CHECK(params["candidate"]["name"]))
		to_chat(usr, span_warning("Your name contains prohibited word(s)!"))
		return FALSE
	switch(action)
		if("submit")
			candidate.comments = params["candidate"]["comments"]
			candidate.description = params["candidate"]["description"]
			candidate.name = params["candidate"]["name"]
			candidate.ready = TRUE
			ui.close()
			submit_alert()
		if("save")
			candidate.comments = params["candidate"]["comments"]
			candidate.description = params["candidate"]["description"]
			candidate.name = params["candidate"]["name"]
			candidate.save(usr)
		if("delete")
			if(!candidate.ready)
				return FALSE
			candidate.ready = FALSE
			to_chat(usr, span_notice("Your candidacy has been deleted. You can no longer be selected as a pAI personality."))
	return TRUE


/**
 * Pings all pAI cards on the station that new candidates are available.
 */
/datum/controller/subsystem/pai/proc/submit_alert()
	if(submit_spam[usr.ckey])
		to_chat(usr, span_warning("Your candidacy has been submitted, but pAI cards have been alerted too recently."))
		return FALSE
	submit_spam[usr.ckey] = TRUE
	for(var/obj/item/paicard/paicard in pai_card_list)
		if(!paicard.pai)
			paicard.alertUpdate()
	to_chat(usr, span_notice("Your pAI candidacy has been submitted!"))
	addtimer(VARSET_LIST_CALLBACK(submit_spam, usr.ckey, FALSE), 10 SECONDS)
	return TRUE


/**
 * Checks if a candidate is ready so that they may be displayed in the pAI
 * card's candidate window
 */
/datum/controller/subsystem/pai/proc/check_ready(datum/pai_candidate/candidate)
	if(!candidate.ready)
		return FALSE
	for(var/mob/dead/observer/observer in GLOB.player_list)
		if(observer.ckey == candidate.ckey)
			return candidate
	return FALSE

