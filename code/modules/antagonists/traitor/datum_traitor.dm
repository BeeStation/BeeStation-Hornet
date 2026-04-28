/datum/antagonist/traitor
	name = "Traitor"
	roundend_category = "traitors"
	antagpanel_category = "Traitor"
	banning_key = ROLE_TRAITOR
	required_living_playtime = 2
	antag_moodlet = /datum/mood_event/focused
	faction = FACTION_SYNDICATE
	hijack_speed = 0.5				//10 seconds per hijack stage by default
	leave_behaviour = ANTAGONIST_LEAVE_KEEP
	var/special_role = ROLE_TRAITOR
	/// Shown when giving uplinks and codewords to the player
	var/employer = "The Syndicate"
	var/datum/weakref/uplink_ref
	var/datum/contractor_hub/contractor_hub
	/// The backup code which, when typed into any PDA, will turn it into an uplink
	var/backup_code = ""
	/// If this specific traitor has been assigned codewords. This is not always true, because it varies by faction.
	var/has_codewords = FALSE

/datum/antagonist/traitor/on_gain()
	owner.special_role = special_role
	if(give_objectives)
		forge_objectives()
	..()

/datum/antagonist/traitor/apply_innate_effects()
	handle_clown_mutation(owner.current, silent ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")

/datum/antagonist/traitor/remove_innate_effects()
	handle_clown_mutation(owner.current, removing=FALSE)

/datum/antagonist/traitor/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,span_userdanger(" You are no longer the [special_role]! "))
	owner.special_role = null
	..()

/datum/antagonist/traitor/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/message = hearing_args[HEARING_RAW_MESSAGE]
	message = GLOB.syndicate_code_phrase_regex.Replace(message, span_blue("$1"))
	message = GLOB.syndicate_code_response_regex.Replace(message, span_red("$1"))
	hearing_args[HEARING_RAW_MESSAGE] = message

/datum/antagonist/traitor/proc/add_objective(datum/objective/O)
	objectives += O
	log_objective(owner, O.explanation_text)

/datum/antagonist/traitor/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/traitor/greet()
	var/list/msg = list()

	msg += span_alertsyndie("You are the [owner.special_role].")
	msg += span_alertsyndie("Use the 'Traitor Info and Backstory' action at the top left in order to select a backstory and review your objectives, uplink location, and codewords!")
	owner.current.client?.tgui_panel?.give_antagonist_popup("Traitor", "Complete your objectives, no matter the cost.")

	ui_interact(owner.current)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

	to_chat(owner.current, examine_block(msg.Join("\n")))

/datum/antagonist/traitor/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(owner.current)
	set_antag_hud(owner.current, "traitor")

/datum/antagonist/traitor/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/traitor/apply_innate_effects(mob/living/mob_override)
	. = ..()
	update_traitor_icons_added()
	// Give codewords to the new mob on mind transfer.
	if(mob_override)
		give_codewords(mob_override)
	RegisterSignal(SSdcs, COMSIG_GLOB_TABLET_CHANGE_RINGTONE, PROC_REF(check_backup_code))

/datum/antagonist/traitor/remove_innate_effects(mob/living/mob_override)
	. = ..()
	update_traitor_icons_removed()
	// Remove codewords from the old mob on mind transfer.
	if(mob_override)
		remove_codewords(mob_override)
	UnregisterSignal(SSdcs, COMSIG_GLOB_TABLET_CHANGE_RINGTONE)

/// Enables displaying codewords to this traitor.
/datum/antagonist/traitor/proc/give_codewords(mob/living/mob_override)
	if((!mob_override && !owner.current))
		return
	has_codewords = TRUE
	RegisterSignal(mob_override || owner.current, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

/datum/antagonist/traitor/proc/remove_codewords(mob/living/mob_override)
	if((!mob_override && !owner.current))
		return
	has_codewords = FALSE
	UnregisterSignal(mob_override || owner.current, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

/// When any code is typed, if our owner is typing it into a PDA then convert that PDA into an uplink
/datum/antagonist/traitor/proc/check_backup_code(datum/source, obj/item/modular_computer/computer, mob/user, entered_code)
	SIGNAL_HANDLER
	if (user != owner.current)
		return NONE
	if (entered_code != backup_code)
		return NONE
	// Unlock the uplink
	var/datum/component/uplink/uplink = uplink_ref.resolve()
	if (!uplink)
		return NONE
	// Remove the uplink from the old location
	if (uplink.parent != null)
		var/uplink_parent = uplink.parent
		uplink.ClearFromParent()
		// De-activate the uplink implant
		if (istype(uplink_parent, /obj/item/implant))
			qdel(uplink_parent)
	// Add the uplink to the new location and unlock
	computer.TakeComponent(uplink)
	uplink.unlock()
	uplink.interact(null, user)
	return COMPONENT_STOP_RINGTONE_CHANGE

/datum/antagonist/traitor/proc/equip(silent = FALSE)
	var/obj/item/uplink_loc = owner.equip_traitor(src, employer, silent, src)
	if (!uplink_loc)
		return
	for (var/datum/component/uplink/uplink in uplink_loc.GetComponents(/datum/component/uplink))
		// Not our uplink
		if (uplink.owner && uplink.owner != owner)
			continue
		uplink.persistent = TRUE
		if(uplink)
			uplink_ref = WEAKREF(uplink)
		// Generate the emergency code for when you lose your uplink
		backup_code = "[random_code(3)] [pick(GLOB.phonetic_alphabet)]"
		antag_memory += "Your backup code is <b>[backup_code]</b>. Type this into any PDA to access your uplink.<br>"
		return
	CRASH("Failed to find the uplink that we just equipped on the traitor")

/datum/antagonist/traitor/antag_panel_data()
	// Traitor Backstory
	var/backstory_text = "<b>Traitor Backstory:</b><br>"
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
	LAZYINITLIST(GLOB.uplink_logs_by_key)
	var/datum/uplink_log/H = GLOB.uplink_logs_by_key[owner.key]
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

	if (H)
		result += "<br>"
		result += H.render_directives()

	var/backstory_text = "<br>"
	if(istype(backstory))
		backstory_text += "<b>Backstory:</b> <span class='tooltip_container' style=\"font-size: 12px\">\[ [backstory.name]<span class='tooltip_hover' style=\"width: 320px; padding: 5px;\">[backstory.description]</span> \]</span><br>"
	else
		backstory_text += "[span_redtext("No backstory was selected!")]<br>"
	result += backstory_text

	var/special_role_text = LOWER_TEXT(name)

	if (contractor_hub)
		result += contractor_round_end()

	if(traitorwin)
		result += span_greentext("The [special_role_text] was successful!")
	else
		result += span_redtext("The [special_role_text] has failed!")
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
			contractor_support_unit += "<br><b>[partner.partner_mind.current.name]</b>, their contractor support unit."

	if (contractor_hub.purchased_items.len)
		result += "<br>(used [total_spent_rep] Rep) "
		result += contractor_item_icons
	result += "<br>"
	if (completed_contracts > 0)
		var/pluralCheck = "contract"
		if (completed_contracts > 1)
			pluralCheck = "contracts"

		result += "Completed [span_greentext("[completed_contracts]")] [pluralCheck] for a total of \
					[span_greentext("[tc_total] TC")]![contractor_support_unit]<br>"

	return result

/datum/antagonist/traitor/roundend_report_footer()
	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	var message = "<br><b>The code phrases were:</b> [span_bluetext("[phrases]")]<br>\
					<b>The code responses were:</b> [span_redtext("[responses]")]<br>"

	return message
