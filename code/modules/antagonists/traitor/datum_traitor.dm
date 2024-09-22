/datum/antagonist/traitor
	name = "Traitor"
	roundend_category = "traitors"
	antagpanel_category = "Traitor"
	banning_key = ROLE_TRAITOR
	required_living_playtime = 4
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5				//10 seconds per hijack stage by default
	var/special_role = ROLE_TRAITOR
	/// Shown when giving uplinks and codewords to the player
	var/employer = "The Syndicate"
	var/traitor_kind = TRAITOR_HUMAN //Set on initial assignment
	var/datum/weakref/uplink_ref
	var/datum/contractor_hub/contractor_hub
	/// If this specific traitor has been assigned codewords. This is not always true, because it varies by faction.
	var/has_codewords = FALSE

/datum/antagonist/traitor/on_gain()
	if(owner.current && isAI(owner.current))
		traitor_kind = TRAITOR_AI
		ui_name = "AntagInfoMalf"

	SSticker.mode.traitors += owner
	owner.special_role = special_role
	if(give_objectives)
		forge_traitor_objectives()
	finalize_traitor()
	..()

/datum/antagonist/traitor/apply_innate_effects()
	handle_clown_mutation(owner.current, silent ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")

/datum/antagonist/traitor/remove_innate_effects()
	handle_clown_mutation(owner.current, removing=FALSE)

/datum/antagonist/traitor/on_removal()
	//Remove malf powers.
	if(traitor_kind == TRAITOR_AI && owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.set_zeroth_law("")
		A.remove_verb(/mob/living/silicon/ai/proc/choose_modules)
		A.malf_picker.remove_malf_verbs(A)
		qdel(A.malf_picker)
		QDEL_NULL(A.radio.keyslot)
		A.radio.recalculateChannels()

	SSticker.mode.traitors -= owner
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer the [special_role]! </span>")
	owner.special_role = null
	..()

/datum/antagonist/traitor/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/message = hearing_args[HEARING_RAW_MESSAGE]
	message = GLOB.syndicate_code_phrase_regex.Replace(message, "<span class='blue'>$1</span>")
	message = GLOB.syndicate_code_response_regex.Replace(message, "<span class='red'>$1</span>")
	hearing_args[HEARING_RAW_MESSAGE] = message

/datum/antagonist/traitor/proc/add_objective(datum/objective/O)
	objectives += O
	log_objective(owner, O.explanation_text)

/datum/antagonist/traitor/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/traitor/proc/forge_traitor_objectives()
	switch(traitor_kind)
		if(TRAITOR_AI)
			forge_ai_objectives()
		else
			forge_human_objectives()

/datum/antagonist/traitor/greet()
	var/list/msg = list()
	msg += "<span class='alertsyndie'>You are the [owner.special_role].</span>"
	msg += "<span class='alertsyndie'>Use the 'Traitor Info and Backstory' action at the top left in order to select a backstory and review your objectives, uplink location, and codewords!</span>"
	to_chat(owner.current, EXAMINE_BLOCK(msg.Join("\n")))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Traitor",
		"Complete your objectives, no matter the cost.")
	if(traitor_kind == TRAITOR_AI)
		has_codewords = TRUE

/datum/antagonist/traitor/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(owner.current)
	set_antag_hud(owner.current, "traitor")

/datum/antagonist/traitor/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/traitor/proc/finalize_traitor()
	switch(traitor_kind)
		if(TRAITOR_AI)
			add_law_zero()
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)
			owner.current.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MALF)
		if(TRAITOR_HUMAN)
			ui_interact(owner.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/traitor/apply_innate_effects(mob/living/mob_override)
	. = ..()
	update_traitor_icons_added()
	var/mob/living/M = mob_override || owner.current
	if(isAI(M) && traitor_kind == TRAITOR_AI)
		var/mob/living/silicon/ai/A = M
		A.hack_software = TRUE
	// Give codewords to the new mob on mind transfer.
	if(mob_override && istype(faction) && faction.give_codewords)
		give_codewords(mob_override)

/datum/antagonist/traitor/remove_innate_effects(mob/living/mob_override)
	. = ..()
	update_traitor_icons_removed()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(istype(A)  && traitor_kind == TRAITOR_AI)
		A.hack_software = FALSE
	// Remove codewords from the old mob on mind transfer.
	if(mob_override && istype(faction) && faction.give_codewords)
		remove_codewords(mob_override)

/// Enables displaying codewords to this traitor.
/datum/antagonist/traitor/proc/give_codewords(mob/living/mob_override)
	if((!mob_override && !owner.current) || !istype(faction))
		return
	has_codewords = TRUE
	RegisterSignal(mob_override || owner.current, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

/datum/antagonist/traitor/proc/remove_codewords(mob/living/mob_override)
	if((!mob_override && !owner.current) || !istype(faction))
		return
	has_codewords = FALSE
	UnregisterSignal(mob_override || owner.current, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

/datum/antagonist/traitor/proc/equip(var/silent = FALSE)
	if(traitor_kind == TRAITOR_HUMAN)
		var/obj/item/uplink_loc = owner.equip_traitor(employer, silent, src)
		var/datum/component/uplink/uplink = uplink_loc?.GetComponent(/datum/component/uplink)
		if(uplink)
			uplink_ref = WEAKREF(uplink)

/datum/antagonist/traitor/proc/assign_exchange_role()
	//set faction
	var/faction = "red"
	if(owner == SSticker.mode.exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? SSticker.mode.exchange_blue : SSticker.mode.exchange_red))
	exchange_objective.owner = owner
	add_objective(exchange_objective)

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		add_objective(backstab_objective)

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/folder/syndicate/folder
	if(owner == SSticker.mode.exchange_red)
		folder = new/obj/item/folder/syndicate/red(mob.loc)
	else
		folder = new/obj/item/folder/syndicate/blue(mob.loc)

	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if (equipped_slot)
		where = "In your [equipped_slot]"
	to_chat(mob, "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another Syndicate group wants. We have set up a meeting with one of their agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>")

/datum/antagonist/traitor/antag_panel_data()
	// Traitor Backstory
	var/backstory_text = "<b>Traitor Backstory:</b><br>"
	if(istype(faction))
		backstory_text += "<b>Faction:</b> <span class='tooltip' style=\"font-size: 12px\">\[ [faction.name]<span class='tooltiptext' style=\"width: 320px; padding: 5px;\">[faction.description]</span> \]</span><br>"
	else
		backstory_text += "<font color='red'>No faction selected!</font><br>"
	if(istype(backstory))
		backstory_text += "<b>Backstory:</b> <span class='tooltip' style=\"font-size: 12px\">\[ [backstory.name]<span class='tooltiptext' style=\"width: 320px; padding: 5px;\">[backstory.description]</span> \]</span><br>"
	else
		backstory_text += "<font color='red'>No backstory selected!</font><br>"
	return backstory_text

//TODO Collate
/datum/antagonist/traitor/roundend_report()
	var/list/result = list()

	var/traitorwin = TRUE

	result += printplayer(owner)

	var/TC_uses = 0
	var/effective_tc = 0
	var/uplink_true = FALSE
	var/purchases = ""
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[owner.key]
	if(H)
		TC_uses = H.total_spent
		effective_tc = H.effective_amount
		uplink_true = TRUE
		purchases += H.generate_render(FALSE)

	var/objectives_text = ""
	if(objectives.len)//If the traitor had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			objectives_text += "<br><B>Objective #[count]</B>: [objective.get_completion_message()]"
			if(!objective.check_completion())
				traitorwin = FALSE
			count++

	if(uplink_true)
		var/effective_message = TC_uses < effective_tc ? " / effectively worth [effective_tc] TC" : ""
		var/uplink_text = "(used [TC_uses] TC[effective_message]) [purchases]"
		if(TC_uses==0 && traitorwin)
			var/static/icon/badass = icon('icons/badass.dmi', "badass")
			uplink_text += "<BIG>[icon2html(badass, world)]</BIG>"
		result += uplink_text

	result += objectives_text

	var/backstory_text = "<br>"
	if(istype(faction))
		backstory_text += "<b>Faction:</b> <span class='tooltip_container' style=\"font-size: 12px\">\[ [faction.name]<span class='tooltip_hover' style=\"width: 320px; padding: 5px;\">[faction.description]</span> \]</span><br>"
	if(istype(backstory))
		backstory_text += "<b>Backstory:</b> <span class='tooltip_container' style=\"font-size: 12px\">\[ [backstory.name]<span class='tooltip_hover' style=\"width: 320px; padding: 5px;\">[backstory.description]</span> \]</span><br>"
	else
		backstory_text += "<span class='redtext'>No backstory was selected!</span><br>"
	result += backstory_text

	var/special_role_text = LOWER_TEXT(name)

	if (contractor_hub)
		result += contractor_round_end()

	if(traitorwin)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

/// Proc detailing contract kit buys/completed contracts/additional info
/datum/antagonist/traitor/proc/contractor_round_end()
	var result = ""
	var total_spent_rep = 0

	var/completed_contracts = 0
	var/tc_total = contractor_hub.contract_TC_payed_out + contractor_hub.contract_TC_to_redeem
	for (var/datum/syndicate_contract/contract in contractor_hub.assigned_contracts)
		if (contract.status == CONTRACT_STATUS_COMPLETE)
			completed_contracts++

	var/contractor_item_icons = "" // Icons of purchases
	var/contractor_support_unit = "" // Set if they had a support unit - and shows appended to their contracts completed

	/// Get all the icons/total cost for all our items bought
	for (var/datum/contractor_item/contractor_purchase in contractor_hub.purchased_items)
		contractor_item_icons += "<span class='tooltip_container'>\[ <i class=\"fas [contractor_purchase.item_icon]\"></i><span class='tooltip_hover'><b>[contractor_purchase.name] - [contractor_purchase.cost] Rep</b><br><br>[contractor_purchase.desc]</span> \]</span>"

		total_spent_rep += contractor_purchase.cost

		/// Special case for reinforcements, we want to show their ckey and name on round end.
		if (istype(contractor_purchase, /datum/contractor_item/contractor_partner))
			var/datum/contractor_item/contractor_partner/partner = contractor_purchase
			contractor_support_unit += "<br><b>[partner.partner_mind.key]</b> played <b>[partner.partner_mind.current.name]</b>, their contractor support unit."

	if (contractor_hub.purchased_items.len)
		result += "<br>(used [total_spent_rep] Rep) "
		result += contractor_item_icons
	result += "<br>"
	if (completed_contracts > 0)
		var/pluralCheck = "contract"
		if (completed_contracts > 1)
			pluralCheck = "contracts"

		result += "Completed <span class='greentext'>[completed_contracts]</span> [pluralCheck] for a total of \
					<span class='greentext'>[tc_total] TC</span>![contractor_support_unit]<br>"

	return result

/datum/antagonist/traitor/roundend_report_footer()
	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	var message = "<br><b>The code phrases were:</b> <span class='bluetext'>[phrases]</span><br>\
					<b>The code responses were:</b> <span class='redtext'>[responses]</span><br>"

	return message


/datum/antagonist/traitor/is_gamemode_hero()
	return SSticker.mode.name == "traitor"

/datum/antagonist/traitor/excommunicate
	name = "Excommunicate Traitor"
	banning_key = ROLE_EXCOMM
	special_role = ROLE_EXCOMM
